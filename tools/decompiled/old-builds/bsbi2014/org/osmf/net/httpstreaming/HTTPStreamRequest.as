package org.osmf.net.httpstreaming
{
   import flash.net.URLRequest;
   
   [ExcludeClass]
   public class HTTPStreamRequest
   {
      
      private var _urlRequest:URLRequest;
      
      private var _quality:int;
      
      private var _truncateAt:Number;
      
      private var _retryAfter:Number;
      
      private var _unpublishNotify:Boolean;
      
      public function HTTPStreamRequest(url:String = null, quality:int = -1, truncateAt:Number = -1, retryAfter:Number = -1, unpublishNotify:Boolean = false)
      {
         super();
         if(Boolean(url))
         {
            this._urlRequest = new URLRequest(HTTPStreamingUtils.normalizeURL(url));
         }
         else
         {
            this._urlRequest = null;
         }
         this._quality = quality;
         this._truncateAt = truncateAt;
         this._retryAfter = retryAfter;
         this._unpublishNotify = unpublishNotify;
      }
      
      public function get urlRequest() : URLRequest
      {
         return this._urlRequest;
      }
      
      public function get retryAfter() : Number
      {
         return this._retryAfter;
      }
      
      public function get unpublishNotify() : Boolean
      {
         return this._unpublishNotify;
      }
   }
}

