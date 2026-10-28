package com.sbi.loader
{
   import com.sbi.debug.DebugUtility;
   import flash.net.URLRequest;
   
   public class LoaderCache
   {
      
      public static var cdnSalt:String;
      
      public static var mainClassNames:Array;
      
      public static var _contentURL:String = "animaljam.smartbombinteractive.com/content/";
      
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
      
      public static function set contentURL(param1:String) : void
      {
         var _loc2_:RegExp = new RegExp("https*://","ig");
         _contentURL = param1.replace(_loc2_,"");
      }
      
      public static function get clientIp() : String
      {
         return _clientIp;
      }
      
      public static function set clientIp(param1:String) : void
      {
         _clientIp = param1;
      }
      
      public static function fetchCDNURL(param1:String, param2:String = "/", param3:Boolean = true) : String
      {
         var _loc7_:String = null;
         var _loc4_:String = param2;
         var _loc5_:String = "";
         var _loc6_:String = deployVersion;
         if(_loc6_ != "0" && param3)
         {
            _loc5_ = _loc6_ + "/";
            _loc4_ += _loc5_;
         }
         if(param3)
         {
            if(_loc6_ == "0")
            {
               _loc7_ = "http://" + contentURL + _loc5_ + param1 + "?v=" + LoaderCache.buildVersion;
            }
            else
            {
               _loc7_ = "http://" + contentURL + _loc5_ + param1 + "?v=" + LoaderCache.buildVersion;
            }
         }
         else if(_loc6_ == "0")
         {
            _loc7_ = "http://" + contentURL + _loc5_ + param1;
         }
         else
         {
            _loc7_ = "http://" + contentURL + _loc5_ + param1;
         }
         return _loc7_;
      }
      
      public static function fetchCDNURLRequest(param1:String, param2:String = "/", param3:Boolean = true) : URLRequest
      {
         var _loc4_:String = fetchCDNURL(param1,param2,param3);
         return new URLRequest(_loc4_);
      }
      
      public function openFile(param1:String, param2:Function, param3:Function = null, param4:String = "binary") : void
      {
         var _loc5_:* = undefined;
         if(!this.findFile(param1))
         {
            _loc5_ = this.createLoaderCacheEntry(param1);
            this._list[param1] = _loc5_;
         }
         else
         {
            DebugUtility.debugTrace("*LoaderCache name collision: " + param1);
         }
         this._list[param1].setCompleteCallback(param2);
         if(param3 != null)
         {
            this._list[param1].setProgressCallback(param3);
         }
         this._list[param1].load(param4);
      }
      
      public function destroy() : void
      {
         var _loc1_:Object = null;
         for(_loc1_ in this._list)
         {
            this.remove(String(_loc1_));
         }
      }
      
      private function findFile(param1:String) : Boolean
      {
         return this._list[param1] == null ? false : true;
      }
      
      public function remove(param1:String) : void
      {
         this._list[param1].destroy();
         this._list[param1] = null;
      }
      
      private function createLoaderCacheEntry(param1:String) : *
      {
         var _loc4_:* = undefined;
         var _loc2_:int = param1.lastIndexOf(".");
         var _loc3_:String = param1.slice(_loc2_ + 1,param1.length).toLowerCase();
         switch(_loc3_)
         {
            case "swf":
            case "png":
            case "jpg":
            case "jpeg":
               _loc4_ = new LoaderCacheEntry_Loader(param1);
               break;
            default:
               _loc4_ = new LoaderCacheEntry_URL(param1);
         }
         _loc4_.parent = this;
         return _loc4_;
      }
   }
}

