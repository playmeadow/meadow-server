"use strict";

const crypto = require("crypto");
const {Duplex} = require("stream");

// just enough of a WebSocket server (RFC 6455) for the browser version
// (public/play.html): Ruffle cannot open a TCP socket, so it sends the
// game's socket over a WebSocket (its socketProxy setting), one message
// for each piece of what the game wrote, and reads the server's answers
// the same way. what goes over it is the game socket's own bytes, so the
// connection is handed to lib/sfs.js as if it had come in on the game port.

const GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
// one frame may be no bigger: the game's messages are at most 64 KB
// (lib/sfs.js), and the browser splits nothing the game sends.
const MAX_FRAME = 1024 * 1024;
const OP_CONTINUATION = 0x0;
const OP_TEXT = 0x1;
const OP_BINARY = 0x2;
const OP_CLOSE = 0x8;
const OP_PING = 0x9;
const OP_PONG = 0xa;
// a ping this often: Cloudflare, in front of the website's name, closes a
// WebSocket that says nothing for 100 seconds, and a player standing still
// sends nothing for minutes (the game's keep-alive is every 3).
const PING_MS = 30000;

const header = (opcode, length) => {
  if (length < 126) {
    return Buffer.from([0x80 | opcode, length]);
  }
  if (length < 65536) {
    const head = Buffer.alloc(4);
    head[0] = 0x80 | opcode;
    head[1] = 126;
    head.writeUInt16BE(length, 2);
    return head;
  }
  const head = Buffer.alloc(10);
  head[0] = 0x80 | opcode;
  head[1] = 127;
  head.writeBigUInt64BE(BigInt(length), 2);
  return head;
};

// the stream lib/sfs.js reads and writes: the payloads of the browser's
// messages in, a binary message for each write out.
class WebSocketStream extends Duplex {
  constructor(raw, address) {
    super();
    this.raw = raw;
    this.remoteAddress = address;
    this.remotePort = raw.remotePort;
    this.pending = Buffer.alloc(0);
    this.closing = false;
    raw.on("data", chunk => this.onData(chunk));
    raw.on("error", () => this.destroy());
    raw.on("close", () => this.destroy());
    this.pinger = setInterval(() => {
      if (raw.writable && !this.closing) {
        raw.write(header(OP_PING, 0));
      }
    }, PING_MS);
    this.pinger.unref();
  }

  setNoDelay(on) {
    this.raw.setNoDelay(on);
  }

  setTimeout(ms, callback) {
    this.raw.setTimeout(ms, callback);
  }

  onData(chunk) {
    this.pending = this.pending.length === 0 ? chunk : Buffer.concat([this.pending, chunk]);
    while (!this.destroyed) {
      const frame = this.readFrame();
      if (!frame) {
        return;
      }
      switch (frame.opcode) {
        case OP_CONTINUATION:
        case OP_TEXT:
        case OP_BINARY:
          this.push(frame.payload);
          break;
        case OP_PING:
          this.raw.write(Buffer.concat([header(OP_PONG, frame.payload.length), frame.payload]));
          break;
        case OP_PONG:
          break;
        case OP_CLOSE:
        default:
          this.closeRaw();
          return;
      }
    }
  }

  // the next whole frame of what came in, or null until there is one. a
  // frame a browser would never send (unmasked, too big) closes it.
  readFrame() {
    const data = this.pending;
    if (data.length < 2) {
      return null;
    }
    const opcode = data[0] & 0x0f;
    const masked = (data[1] & 0x80) !== 0;
    let length = data[1] & 0x7f;
    let at = 2;
    if (length === 126) {
      if (data.length < 4) {
        return null;
      }
      length = data.readUInt16BE(2);
      at = 4;
    }
    else if (length === 127) {
      if (data.length < 10) {
        return null;
      }
      const long = data.readBigUInt64BE(2);
      length = long > BigInt(MAX_FRAME) ? MAX_FRAME + 1 : Number(long);
      at = 10;
    }
    if (!masked || length > MAX_FRAME) {
      this.closeRaw();
      return null;
    }
    if (data.length < at + 4 + length) {
      return null;
    }
    const mask = data.subarray(at, at + 4);
    const payload = Buffer.from(data.subarray(at + 4, at + 4 + length));
    for (let i = 0; i < payload.length; i++) {
      payload[i] ^= mask[i & 3];
    }
    this.pending = data.subarray(at + 4 + length);
    return {opcode, payload};
  }

  closeRaw() {
    if (!this.closing) {
      this.closing = true;
      this.raw.end(header(OP_CLOSE, 0));
    }
    this.destroy();
  }

  _read() {
    // what comes in is pushed as it comes (onData).
  }

  _write(chunk, encoding, callback) {
    if (!this.raw.writable) {
      callback();
      return;
    }
    this.raw.write(Buffer.concat([header(OP_BINARY, chunk.length), chunk]), () => callback());
  }

  _final(callback) {
    this.closeRaw();
    callback();
  }

  _destroy(err, callback) {
    clearInterval(this.pinger);
    if (!this.raw.destroyed) {
      // a close frame first where it can still go, then the socket.
      if (!this.closing && this.raw.writable) {
        this.closing = true;
        this.raw.end(header(OP_CLOSE, 0));
      }
      setTimeout(() => this.raw.destroy(), 1000).unref();
    }
    callback(err);
  }
}

// answers an HTTP upgrade (the server's "upgrade" event) and calls back
// with the connection as a stream, or refuses it and calls nothing.
const upgrade = (req, raw, head, address, onOpen) => {
  const key = String(req.headers["sec-websocket-key"] || "");
  if (String(req.headers.upgrade || "").toLowerCase() !== "websocket" || !/^[A-Za-z0-9+/]{22}==$/.test(key)) {
    raw.end("HTTP/1.1 400 Bad Request\r\nConnection: close\r\n\r\n");
    return;
  }
  const accept = crypto.createHash("sha1").update(key + GUID).digest("base64");
  raw.write("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
    + `Sec-WebSocket-Accept: ${accept}\r\n\r\n`);
  const stream = new WebSocketStream(raw, address);
  if (head && head.length) {
    stream.onData(head);
  }
  onOpen(stream);
};

module.exports = {upgrade};
