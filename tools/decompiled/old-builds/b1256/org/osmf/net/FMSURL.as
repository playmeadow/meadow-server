package org.osmf.net
{
   import org.osmf.utils.URL;
   
   public class FMSURL extends URL
   {
      
      private static const APPNAME_START_INDEX:uint = 0;
      
      private static const INSTANCENAME_START_INDEX:uint = 2;
      
      private static const STREAMNAME_START_INDEX:uint = 4;
      
      private static const DEFAULT_INSTANCE_NAME:String = "_definst_";
      
      public static const MP4_STREAM:String = "mp4";
      
      public static const MP3_STREAM:String = "mp3";
      
      public static const ID3_STREAM:String = "id3";
      
      public static const QUERY_STRING_STREAM:String = "streamName";
      
      public static const QUERY_STRING_STREAMTYPE:String = "streamType";
      
      private var _useInstance:Boolean;
      
      private var _appName:String;
      
      private var _instanceName:String;
      
      private var _streamName:String;
      
      private var _fileFormat:String;
      
      private var _origins:Vector.<FMSHost>;
      
      private var _edges:Vector.<FMSHost>;
      
      public function FMSURL(param1:String, param2:Boolean = false)
      {
         super(param1);
         _useInstance = param2;
         _appName = "";
         _instanceName = "";
         _streamName = "";
         _fileFormat = "";
         parsePath();
         parseQuery();
      }
      
      public function get useInstance() : Boolean
      {
         return _useInstance;
      }
      
      public function get appName() : String
      {
         return _appName;
      }
      
      public function get instanceName() : String
      {
         return _instanceName;
      }
      
      public function get streamName() : String
      {
         return _streamName;
      }
      
      public function get fileFormat() : String
      {
         return _fileFormat;
      }
      
      public function get edges() : Vector.<FMSHost>
      {
         return _edges;
      }
      
      public function get origins() : Vector.<FMSHost>
      {
         return _origins;
      }
      
      private function parsePath() : void
      {
         var _loc6_:RegExp = null;
         var _loc3_:* = 0;
         var _loc9_:int = 0;
         if(path == null || path.length == 0)
         {
            _streamName = getParamValue("streamName");
            _fileFormat = getParamValue("streamType");
            return;
         }
         var _loc4_:RegExp = /(\/)/;
         var _loc1_:Array = path.split(_loc4_);
         if(_loc1_ != null)
         {
            _appName = _loc1_[0];
            _instanceName = "";
            _streamName = "";
            _loc6_ = new RegExp("^.*/_definst_","i");
            if(path.search(_loc6_) > -1)
            {
               _useInstance = true;
            }
            _loc3_ = 4;
            if(_useInstance)
            {
               _instanceName = _loc1_[2];
            }
            else
            {
               _loc3_ = 2;
            }
            _loc9_ = _loc3_;
            while(_loc9_ < _loc1_.length)
            {
               _streamName += _loc1_[_loc9_];
               _loc9_++;
            }
            if(_streamName == null || _streamName == "")
            {
               _streamName = getParamValue("streamName");
            }
            if(_streamName.search(/^mp4:/i) > -1)
            {
               _fileFormat = "mp4";
            }
            else if(_streamName.search(/^mp3:/i) > -1)
            {
               _fileFormat = "mp3";
            }
            else if(_streamName.search(/^id3:/i) > -1)
            {
               _fileFormat = "id3";
            }
            if(_fileFormat == null || _fileFormat == "")
            {
               _fileFormat = getParamValue("streamType");
            }
         }
         var _loc2_:int = _streamName.indexOf("/mp4:");
         var _loc7_:int = _streamName.indexOf("/mp3:");
         var _loc5_:int = _streamName.indexOf("/id3:");
         var _loc8_:int = -1;
         if(_loc2_ > 0)
         {
            _loc8_ = _loc2_;
         }
         else if(_loc7_ > 0)
         {
            _loc8_ = _loc7_;
         }
         else if(_loc5_ > 0)
         {
            _loc8_ = _loc5_;
         }
         if(useInstance && _loc8_ > 0)
         {
            _instanceName += "/";
            _instanceName += _streamName.substr(0,_loc8_);
            _streamName = streamName.substr(_loc8_ + 1);
         }
      }
      
      private function parseQuery() : void
      {
         var _loc12_:int = 0;
         var _loc2_:int = 0;
         var _loc10_:int = 0;
         var _loc14_:int = 0;
         var _loc1_:FMSURL = null;
         if(query == null || query.length == 0 || query.search(/:\//) == -1)
         {
            return;
         }
         var _loc7_:Array = query.split("?");
         _loc12_ = 0;
         while(_loc12_ < _loc7_.length)
         {
            _loc2_ = int(_loc7_[_loc12_].toString().search(/:\//));
            if(_loc2_ == -1)
            {
               _loc7_.splice(_loc12_,1);
            }
            _loc12_++;
         }
         var _loc11_:Boolean = false;
         var _loc13_:int = 0;
         if(_loc7_.length >= 2)
         {
            _loc11_ = true;
            _loc13_ = _loc7_.length - 1;
         }
         var _loc8_:String = "";
         var _loc9_:String = "";
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         _loc10_ = 0;
         while(_loc10_ < _loc7_.length)
         {
            _loc14_ = int(_loc7_[_loc10_].toString().search(/:\//));
            _loc3_ = _loc14_ + 2;
            if(_loc7_[_loc10_].charAt(_loc3_) == "/")
            {
               _loc3_++;
            }
            _loc4_ = int(_loc7_[_loc10_].indexOf(":",_loc3_));
            _loc5_ = int(_loc7_[_loc10_].indexOf("/",_loc3_));
            if(_loc5_ < 0 && _loc4_ < 0)
            {
               _loc8_ = _loc7_[_loc10_].slice(_loc3_);
            }
            else if(_loc4_ >= 0 && _loc4_ < _loc5_)
            {
               _loc6_ = _loc4_;
               _loc8_ = _loc7_[_loc10_].slice(_loc3_,_loc6_);
               _loc3_ = _loc6_ + 1;
               _loc6_ = _loc5_;
               _loc9_ = _loc7_[_loc10_].slice(_loc3_,_loc6_);
            }
            else if(_loc7_[_loc10_].indexOf("://") != -1)
            {
               _loc6_ = _loc5_;
               _loc8_ = _loc7_[_loc10_].slice(_loc3_,_loc6_);
            }
            else
            {
               _loc6_ = int(_loc7_[_loc10_].indexOf("/"));
               _loc8_ = "localhost";
            }
            if(_loc10_ == _loc13_)
            {
               if(_origins == null)
               {
                  _origins = new Vector.<FMSHost>();
               }
               _origins.push(new FMSHost(_loc8_,_loc9_));
               _loc1_ = new FMSURL(_loc7_[_loc10_],_useInstance);
               if(_appName == "")
               {
                  _appName = _loc1_.appName;
               }
               if(_useInstance && _instanceName == "")
               {
                  _instanceName = _loc1_.instanceName;
               }
               if(_streamName == "")
               {
                  _streamName = _loc1_.streamName;
               }
            }
            else if(_loc7_[_loc10_] != query && _loc11_)
            {
               if(_edges == null)
               {
                  _edges = new Vector.<FMSHost>();
               }
               _edges.push(new FMSHost(_loc8_,_loc9_));
            }
            _loc10_++;
         }
      }
   }
}

