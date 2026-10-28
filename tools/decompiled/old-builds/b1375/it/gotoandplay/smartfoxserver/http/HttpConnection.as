package it.gotoandplay.smartfoxserver.http
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
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
         codec = new RawProtocolCodec();
         urlLoaderFactory = new LoaderFactory(handleResponse,handleIOError);
      }
      
      public function getSessionId() : String
      {
         return this.sessionId;
      }
      
      public function isConnected() : Boolean
      {
         return this.connected;
      }
      
      public function connect(param1:String, param2:int = 8080) : void
      {
         this.ipAddr = param1;
         this.port = param2;
         this.webUrl = "http://" + this.ipAddr + ":" + this.port + "/" + "BlueBox/HttpBox.do";
         this.sessionId = null;
         urlRequest = new URLRequest(webUrl);
         urlRequest.method = "POST";
         send("connect");
      }
      
      public function close() : void
      {
         send("disconnect");
      }
      
      public function send(param1:String) : void
      {
         var _loc3_:URLVariables = null;
         var _loc2_:URLLoader = null;
         if(connected || !connected && param1 == "connect" || !connected && param1 == "poll")
         {
            _loc3_ = new URLVariables();
            _loc3_["sfsHttp"] = codec.encode(this.sessionId,param1);
            urlRequest.data = _loc3_;
            if(param1 != "poll")
            {
               trace("[ Send ]: " + urlRequest.data);
            }
            _loc2_ = urlLoaderFactory.getLoader();
            _loc2_.data = _loc3_;
            _loc2_.load(urlRequest);
         }
      }
      
      private function handleResponse(param1:Event) : void
      {
         var _loc2_:HttpEvent = null;
         var _loc3_:URLLoader = param1.target as URLLoader;
         var _loc4_:String = _loc3_.data as String;
         var _loc5_:Object = {};
         if(_loc4_.charAt(0) == "#")
         {
            if(sessionId == null)
            {
               sessionId = codec.decode(_loc4_);
               connected = true;
               _loc5_.sessionId = this.sessionId;
               _loc5_.success = true;
               _loc2_ = new HttpEvent("onHttpConnect",_loc5_);
               dispatchEvent(_loc2_);
            }
            else
            {
               trace("**ERROR** SessionId is being rewritten");
            }
         }
         else
         {
            if(_loc4_.indexOf("ERR#01") == 0)
            {
               _loc5_.data = {};
               _loc2_ = new HttpEvent("onHttpClose",_loc5_);
            }
            else
            {
               _loc5_.data = _loc4_;
               _loc2_ = new HttpEvent("onHttpData",_loc5_);
            }
            dispatchEvent(_loc2_);
         }
      }
      
      private function handleIOError(param1:IOErrorEvent) : void
      {
         var _loc3_:Object = {};
         _loc3_.message = param1.text;
         var _loc2_:HttpEvent = new HttpEvent("onHttpError",_loc3_);
         dispatchEvent(_loc2_);
      }
   }
}

