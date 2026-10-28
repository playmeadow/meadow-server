package com.sbi.loader
{
   import com.adobe.crypto.MD5;
   import com.sbi.debug.DebugUtility;
   import flash.net.URLRequest;
   
   public class LoaderCache
   {
      
      public static var _contentURL:String = "animaljam.smartbombinteractive.com/content/";
      
      public static var buildVersion:String = "0";
      
      public static var deployVersion:String = "0";
      
      public static var localMode:Boolean = true;
      
      public static var cdnSalt:String;
      
      public static var mainClassNames:Array;
      
      private var _list:Array = null;
      
      public function LoaderCache()
      {
         super();
         _list = [];
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
      
      public static function fetchCDNURL(param1:String, param2:String = "/", param3:Boolean = true) : String
      {
         var _loc7_:String = null;
         var _loc4_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = param2;
         var _loc6_:String = "";
         var _loc5_:String = deployVersion;
         if(_loc5_ != "0" && param3)
         {
            _loc6_ = _loc5_ + "/";
            _loc9_ += _loc6_;
         }
         var _loc10_:Array = param1.split("/");
         if(_loc5_ == "0" || !param3)
         {
            _loc4_ = param1;
         }
         else if(_loc10_.length == 1)
         {
            _loc4_ = MD5.hash(_loc10_[0]);
         }
         else
         {
            _loc8_ = _loc10_.pop();
            _loc4_ = _loc10_.join("/") + "/" + MD5.hash(_loc8_);
         }
         if(param3)
         {
            if(_loc5_ == "0")
            {
               _loc7_ = "http://" + contentURL + _loc6_ + param1 + "?v=" + LoaderCache.buildVersion;
            }
            else
            {
               _loc7_ = "http://" + contentURL + _loc6_ + _loc4_ + "?v=" + LoaderCache.buildVersion;
            }
         }
         else if(_loc5_ == "0")
         {
            _loc7_ = "http://" + contentURL + _loc6_ + param1;
         }
         else
         {
            _loc7_ = "http://" + contentURL + _loc6_ + _loc4_;
         }
         return _loc7_;
      }
      
      public static function fetchCDNURLRequest(param1:String, param2:String = "/", param3:Boolean = true) : URLRequest
      {
         var _loc5_:String = fetchCDNURL(param1,param2,param3);
         return new URLRequest(_loc5_);
      }
      
      public function openFile(param1:String, param2:Function, param3:Function = null, param4:String = "binary") : void
      {
         var _loc5_:* = undefined;
         if(!findFile(param1))
         {
            _loc5_ = createLoaderCacheEntry(param1);
            _list[param1] = _loc5_;
         }
         else
         {
            DebugUtility.debugTrace("*LoaderCache name collision: " + param1);
         }
         _list[param1].setCompleteCallback(param2);
         if(param3 != null)
         {
            _list[param1].setProgressCallback(param3);
         }
         _list[param1].load(param4);
      }
      
      public function destroy() : void
      {
         for(var _loc1_:Object in _list)
         {
            remove(String(_loc1_));
         }
      }
      
      private function findFile(param1:String) : Boolean
      {
         return _list[param1] == null ? false : true;
      }
      
      public function remove(param1:String) : void
      {
         _list[param1].destroy();
         _list[param1] = null;
      }
      
      private function createLoaderCacheEntry(param1:String) : *
      {
         var _loc4_:* = undefined;
         var _loc3_:int = param1.lastIndexOf(".");
         var _loc2_:String = param1.slice(_loc3_ + 1,param1.length).toLowerCase();
         switch(_loc2_)
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

