package org.osmf.media
{
   public class URLResource extends MediaResourceBase
   {
      
      private var _url:String;
      
      public function URLResource(url:String)
      {
         super();
         this._url = url;
      }
      
      public function get url() : String
      {
         return this._url;
      }
   }
}

