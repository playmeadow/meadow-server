package com.sbi.loader
{
   import com.adobe.crypto.MD5;
   import com.carlcalderon.arthropod.Debug;
   import com.sbi.debug.DebugUtility;
   import flash.net.URLRequest;
   
   public class LoaderCache
   {
      
      public static var cdnSalt:String;
      
      public static var mainClassNames:Array;
      
      public static var _contentURL:String = "http://dev-sfs01.smartbombinteractive.com:8008/animal/";
      
      public static var buildVersion:String = "0";
      
      public static var deployVersion:String = "0";
      
      public static var localMode:Boolean = true;
      
      private static var _clientIp:String = "127.0.0.1";
      
      private static var _urlIndex:int = 0;
      
      private var _list:Array = null;
      
      public function LoaderCache()
      {
         super();
         this._list = new Array();
      }
      
      public static function get contentURL() : String
      {
         return _contentURL;
      }
      
      public static function set contentURL(value:String) : void
      {
         var regexp:RegExp = new RegExp("https*://","ig");
         _contentURL = value.replace(regexp,"");
      }
      
      public static function get clientIp() : String
      {
         return _clientIp;
      }
      
      public static function set clientIp(value:String) : void
      {
         _clientIp = value;
      }
      
      public static function fetchCDNHash(assetPath:String, cdnRoot:String = "/") : String
      {
         var finalHashableString:String = cdnSalt + cdnRoot + assetPath + clientIp;
         return MD5.hash(finalHashableString);
      }
      
      public static function fetchCDNURL(assetPath:String, cdnRoot:String = "/", useDeployVersion:Boolean = true) : String
      {
         var cdnURL:String = null;
         var rootStr:String = cdnRoot;
         var cdnURLDeployVersionStr:String = "";
         var deployVersionStr:String = deployVersion;
         if(deployVersionStr != "0" && useDeployVersion)
         {
            cdnURLDeployVersionStr = deployVersionStr + "/";
            rootStr += cdnURLDeployVersionStr;
         }
         var cdnHash:String = fetchCDNHash(assetPath,rootStr);
         if(useDeployVersion)
         {
            cdnURL = "http://" + contentURL + cdnURLDeployVersionStr + assetPath + "?px-hash=" + cdnHash + "&v=" + LoaderCache.buildVersion;
         }
         else
         {
            cdnURL = "http://" + contentURL + cdnURLDeployVersionStr + assetPath + "?px-hash=" + cdnHash;
         }
         Debug.log("CdnURL = " + cdnURL);
         return cdnURL;
      }
      
      public static function fetchCDNURLRequest(assetPath:String, cdnRoot:String = "/", useDeployVersion:Boolean = true) : URLRequest
      {
         var cdnURL:String = fetchCDNURL(assetPath,cdnRoot,useDeployVersion);
         return new URLRequest(cdnURL);
      }
      
      public function openFile(swf:String, completeCallback:Function, progressCallback:Function = null, dataFormat:String = "binary") : void
      {
         var entry:* = undefined;
         if(!this.findFile(swf))
         {
            entry = this.createLoaderCacheEntry(swf);
            this._list[swf] = entry;
         }
         else
         {
            DebugUtility.debugTrace("*LoaderCache name collision: " + swf);
         }
         this._list[swf].setCompleteCallback(completeCallback);
         if(progressCallback != null)
         {
            this._list[swf].setProgressCallback(progressCallback);
         }
         this._list[swf].load(dataFormat);
      }
      
      public function destroy() : void
      {
         var key:Object = null;
         for(key in this._list)
         {
            this.remove(String(key));
         }
      }
      
      private function findFile(name:String) : Boolean
      {
         return this._list[name] == null ? false : true;
      }
      
      public function remove(swf:String) : void
      {
         this._list[swf].destroy();
         this._list[swf] = null;
      }
      
      private function createLoaderCacheEntry(swf:String) : *
      {
         var l:* = undefined;
         var i:int = swf.lastIndexOf(".");
         var ext:String = swf.slice(i + 1,swf.length).toLowerCase();
         switch(ext)
         {
            case "swf":
            case "png":
            case "jpg":
            case "jpeg":
               l = new LoaderCacheEntry_Loader(swf);
               break;
            default:
               l = new LoaderCacheEntry_URL(swf);
         }
         l.parent = this;
         return l;
      }
   }
}

