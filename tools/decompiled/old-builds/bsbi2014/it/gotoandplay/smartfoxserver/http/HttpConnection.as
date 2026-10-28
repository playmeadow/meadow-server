package it.gotoandplay.smartfoxserver.http
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
   public class HttpConnection extends EventDispatcher
   {
      
      private static const HANDSHAKE:String = "connect";
      
      private static const DISCONNECT:String = "disconnect";
      
      private static const CONN_LOST:String = "ERR#01";
      
      public static const HANDSHAKE_TOKEN:String = "#";
      
      private static const servletUrl:String = "BlueBox/HttpBox.do";
      
      private static const paramName:String = "sfsHttp";
      
      private var sessionId:String;
      
      private var connected:Boolean = false;
      
      private var ipAddr:String;
      
      private var port:int;
      
      private var webUrl:String;
      
      private var urlLoaderFactory:LoaderFactory;
      
      private var urlRequest:URLRequest;
      
      private var codec:IHttpProtocolCodec;
      
      public function HttpConnection()
      {
         super();
         this.codec = new RawProtocolCodec();
         this.urlLoaderFactory = new LoaderFactory(this.handleResponse,this.handleIOError);
      }
      
      public function getSessionId() : String
      {
         return this.sessionId;
      }
      
      public function isConnected() : Boolean
      {
         return this.connected;
      }
      
      public function connect(addr:String, port:int = 8080) : void
      {
         this.ipAddr = addr;
         this.port = port;
         this.webUrl = "http://" + this.ipAddr + ":" + this.port + "/" + servletUrl;
         this.sessionId = null;
         this.urlRequest = new URLRequest(this.webUrl);
         this.urlRequest.method = URLRequestMethod.POST;
         this.send(HANDSHAKE);
      }
      
      public function close() : void
      {
         this.send(DISCONNECT);
      }
      
      public function send(message:String) : void
      {
         var vars:URLVariables = null;
         var urlLoader:URLLoader = null;
         if(this.connected || !this.connected && message == HANDSHAKE || !this.connected && message == "poll")
         {
            vars = new URLVariables();
            vars[paramName] = this.codec.encode(this.sessionId,message);
            this.urlRequest.data = vars;
            if(message != "poll")
            {
               trace("[ Send ]: " + this.urlRequest.data);
            }
            urlLoader = this.urlLoaderFactory.getLoader();
            urlLoader.data = vars;
            urlLoader.load(this.urlRequest);
         }
      }
      
      private function handleResponse(evt:Event) : void
      {
         var event:HttpEvent = null;
         var loader:URLLoader = evt.target as URLLoader;
         var data:String = loader.data as String;
         var params:Object = {};
         if(data.charAt(0) == HANDSHAKE_TOKEN)
         {
            if(this.sessionId == null)
            {
               this.sessionId = this.codec.decode(data);
               this.connected = true;
               params.sessionId = this.sessionId;
               params.success = true;
               event = new HttpEvent(HttpEvent.onHttpConnect,params);
               dispatchEvent(event);
            }
            else
            {
               trace("**ERROR** SessionId is being rewritten");
            }
         }
         else
         {
            if(data.indexOf(CONN_LOST) == 0)
            {
               params.data = {};
               event = new HttpEvent(HttpEvent.onHttpClose,params);
            }
            else
            {
               params.data = data;
               event = new HttpEvent(HttpEvent.onHttpData,params);
            }
            dispatchEvent(event);
         }
      }
      
      private function handleIOError(error:IOErrorEvent) : void
      {
         var params:Object = {};
         params.message = error.text;
         var event:HttpEvent = new HttpEvent(HttpEvent.onHttpError,params);
         dispatchEvent(event);
      }
   }
}

