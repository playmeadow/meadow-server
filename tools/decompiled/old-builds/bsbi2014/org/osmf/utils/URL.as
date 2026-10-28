package org.osmf.utils
{
   [ExcludeClass]
   public class URL
   {
      
      private var _rawUrl:String;
      
      private var _protocol:String;
      
      private var _userInfo:String;
      
      private var _host:String;
      
      private var _port:String;
      
      private var _path:String;
      
      private var _query:String;
      
      private var _fragment:String;
      
      public function URL(url:String)
      {
         super();
         this._rawUrl = url;
         this._protocol = "";
         this._userInfo = "";
         this._host = "";
         this._port = "";
         this._path = "";
         this._query = "";
         this._fragment = "";
         if(this._rawUrl != null && this._rawUrl.length > 0)
         {
            this._rawUrl = this._rawUrl.replace(/^\s+|\s+$/g,"");
            this.parseUrl();
         }
      }
      
      public function get rawUrl() : String
      {
         return this._rawUrl;
      }
      
      public function get protocol() : String
      {
         return this._protocol;
      }
      
      public function set protocol(value:String) : void
      {
         if(value != null)
         {
            this._protocol = value.replace(/:\/?\/?$/,"");
            this._protocol = this._protocol.toLowerCase();
         }
      }
      
      public function get userInfo() : String
      {
         return this._userInfo;
      }
      
      public function set userInfo(value:String) : void
      {
         if(value != null)
         {
            this._userInfo = value.replace(/@$/,"");
         }
      }
      
      public function get host() : String
      {
         return this._host;
      }
      
      public function set host(value:String) : void
      {
         this._host = value;
      }
      
      public function get port() : String
      {
         return this._port;
      }
      
      public function set port(value:String) : void
      {
         if(value != null)
         {
            this._port = value.replace(/(:)/,"");
         }
      }
      
      public function get path() : String
      {
         return this._path;
      }
      
      public function set path(value:String) : void
      {
         if(value != null)
         {
            this._path = value.replace(/^\//,"");
         }
      }
      
      public function get query() : String
      {
         return this._query;
      }
      
      public function set query(value:String) : void
      {
         if(value != null)
         {
            this._query = value.replace(/^\?/,"");
         }
      }
      
      public function get fragment() : String
      {
         return this._fragment;
      }
      
      public function set fragment(value:String) : void
      {
         if(value != null)
         {
            this._fragment = value.replace(/^#/,"");
         }
      }
      
      public function toString() : String
      {
         return this._rawUrl;
      }
      
      public function getParamValue(param:String) : String
      {
         if(this._query == null)
         {
            return "";
         }
         var pattern:RegExp = new RegExp("[/?&]*" + param + "=([^&#]*)","i");
         var result:Array = this._query.match(pattern);
         return result == null ? "" : result[1];
      }
      
      public function get absolute() : Boolean
      {
         return this.protocol != "";
      }
      
      public function get extension() : String
      {
         var lastDot:int = this.path.lastIndexOf(".");
         if(lastDot != -1)
         {
            return this.path.substr(lastDot + 1);
         }
         return "";
      }
      
      private function parseUrl() : void
      {
         var oneSlashRegExp:RegExp = null;
         var oneSlashResult:Array = null;
         var tempUrl:String = null;
         var pattern:RegExp = null;
         var result:Array = null;
         var hostName:String = null;
         if(this._rawUrl == null || this._rawUrl.length == 0)
         {
            return;
         }
         if(this._rawUrl.search(/:\//) == -1 && this._rawUrl.indexOf(":") != this._rawUrl.length - 1)
         {
            this.path = this._rawUrl;
         }
         else
         {
            oneSlashRegExp = /^(rtmp|rtmp[tse]|rtmpte)(:\/[^\/])/i;
            oneSlashResult = this._rawUrl.match(oneSlashRegExp);
            tempUrl = this._rawUrl;
            if(oneSlashResult != null)
            {
               tempUrl = this._rawUrl.replace(/:\//,"://localhost/");
            }
            pattern = /^([a-z+\w\+\.\-]+:\/?\/?)?([^\/?#]*)?(\/[^?#]*)?(\?[^#]*)?(\#.*)?/i;
            result = tempUrl.match(pattern);
            if(result != null)
            {
               this.protocol = result[1];
               hostName = result[2];
               this.path = result[3];
               this.query = result[4];
               this.fragment = result[5];
               pattern = /^([!-~]+@)?([^\/?#:]*)(:[\d]*)?/i;
               result = hostName.match(pattern);
               if(result != null)
               {
                  this.userInfo = result[1];
                  this.host = result[2];
                  this.port = result[3];
               }
            }
         }
      }
   }
}

