package
{
   import flash.system.Capabilities;
   
   public class FlashCapabilities
   {
      
      private static const CAPABILITIES_AV_HARDWARE_DISABLE:uint = 0;
      
      private static const CAPABILITIES_HAS_ACCESSIBILITY:uint = 1;
      
      private static const CAPABILITIES_HAS_AUDIO:uint = 2;
      
      private static const CAPABILITIES_HAS_AUDIO_ENCODER:uint = 3;
      
      private static const CAPABILITIES_HAS_EMBEDDED_VIDEO:uint = 4;
      
      private static const CAPABILITIES_HAS_IME:uint = 5;
      
      private static const CAPABILITIES_HAS_MP3:uint = 6;
      
      private static const CAPABILITIES_HAS_PRINTING:uint = 7;
      
      private static const CAPABILITIES_HAS_SCREEN_BROADCAST:uint = 8;
      
      private static const CAPABILITIES_HAS_SCREEN_PLAYBACK:uint = 9;
      
      private static const CAPABILITIES_HAS_STREAMING_AUDIO:uint = 10;
      
      private static const CAPABILITIES_HAS_STREAMING_VIDEO:uint = 11;
      
      private static const CAPABILITIES_HAS_TLS:uint = 12;
      
      private static const CAPABILITIES_HAS_VIDEO_ENCODER:uint = 13;
      
      private static const CAPABILITIES_IS_DEBUGGER:uint = 14;
      
      private static const CAPABILITIES_IS_EMBEDDED_IN_ACROBAT:uint = 15;
      
      private static const CAPABILITIES_LOCAL_FILE_READ_DISABLE:uint = 16;
      
      private static const CAPABILITIES_UNKNOWN_VALUE:int = -1;
      
      private static const CAPABILITIES_PLAYER_TYPE_ACTIVEX:uint = 0;
      
      private static const CAPABILITIES_PLAYER_TYPE_DESKTOP:uint = 1;
      
      private static const CAPABILITIES_PLAYER_TYPE_EXTERNAL:uint = 2;
      
      private static const CAPABILITIES_PLAYER_TYPE_PLUGIN:uint = 3;
      
      private static const CAPABILITIES_PLAYER_TYPE_STANDALONE:uint = 4;
      
      private static const CAPABILITIES_SCREEN_COLOR_COLOR:uint = 0;
      
      private static const CAPABILITIES_SCREEN_COLOR_GRAY:uint = 1;
      
      private static const CAPABILITIES_SCREEN_COLOR_BW:uint = 2;
      
      private static const CAPABILITIES_VERSION_PLATFORM_WIN:uint = 0;
      
      private static const CAPABILITIES_VERSION_PLATFORM_MAC:uint = 1;
      
      private static const CAPABILITIES_VERSION_PLATFORM_UNIX:uint = 2;
      
      public function FlashCapabilities()
      {
         super();
      }
      
      public static function SendCapabilities() : void
      {
         var _loc1_:int = 0;
         if(Capabilities.avHardwareDisable)
         {
            _loc1_ |= 1 << CAPABILITIES_AV_HARDWARE_DISABLE;
         }
         if(Capabilities.hasAccessibility)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_ACCESSIBILITY;
         }
         if(Capabilities.hasAudio)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_AUDIO;
         }
         if(Capabilities.hasAudioEncoder)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_AUDIO_ENCODER;
         }
         if(Capabilities.hasEmbeddedVideo)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_EMBEDDED_VIDEO;
         }
         if(Capabilities.hasIME)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_IME;
         }
         if(Capabilities.hasMP3)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_MP3;
         }
         if(Capabilities.hasPrinting)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_PRINTING;
         }
         if(Capabilities.hasScreenBroadcast)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_SCREEN_BROADCAST;
         }
         if(Capabilities.hasScreenPlayback)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_SCREEN_PLAYBACK;
         }
         if(Capabilities.hasStreamingAudio)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_STREAMING_AUDIO;
         }
         if(Capabilities.hasStreamingVideo)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_STREAMING_VIDEO;
         }
         if(Capabilities.hasTLS)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_TLS;
         }
         if(Capabilities.hasVideoEncoder)
         {
            _loc1_ |= 1 << CAPABILITIES_HAS_VIDEO_ENCODER;
         }
         if(Capabilities.isDebugger)
         {
            _loc1_ |= 1 << CAPABILITIES_IS_DEBUGGER;
         }
         if(Capabilities.isEmbeddedInAcrobat)
         {
            _loc1_ |= 1 << CAPABILITIES_IS_EMBEDDED_IN_ACROBAT;
         }
         if(Capabilities.localFileReadDisable)
         {
            _loc1_ |= 1 << CAPABILITIES_LOCAL_FILE_READ_DISABLE;
         }
         var _loc2_:int = CAPABILITIES_UNKNOWN_VALUE;
         switch(Capabilities.playerType)
         {
            case "ActiveX":
               _loc2_ = int(CAPABILITIES_PLAYER_TYPE_ACTIVEX);
               break;
            case "Desktop":
               _loc2_ = int(CAPABILITIES_PLAYER_TYPE_DESKTOP);
               break;
            case "External":
               _loc2_ = int(CAPABILITIES_PLAYER_TYPE_EXTERNAL);
               break;
            case "PlugIn":
               _loc2_ = int(CAPABILITIES_PLAYER_TYPE_PLUGIN);
               break;
            case "StandAlone":
               _loc2_ = int(CAPABILITIES_PLAYER_TYPE_STANDALONE);
         }
         var _loc3_:int = CAPABILITIES_UNKNOWN_VALUE;
         switch(Capabilities.screenColor)
         {
            case "color":
               _loc3_ = int(CAPABILITIES_SCREEN_COLOR_COLOR);
               break;
            case "gray":
               _loc3_ = int(CAPABILITIES_SCREEN_COLOR_GRAY);
               break;
            case "bw":
               _loc3_ = int(CAPABILITIES_SCREEN_COLOR_BW);
         }
         var _loc4_:Array = Capabilities.version.substring(Capabilities.version.indexOf(" ") + 1).split(",");
         var _loc5_:Array = [];
         _loc5_.push(_loc1_);
         _loc5_.push(Capabilities.language);
         _loc5_.push(Capabilities.manufacturer);
         _loc5_.push(Capabilities.os);
         _loc5_.push(Capabilities.pixelAspectRatio);
         _loc5_.push(_loc2_);
         _loc5_.push(_loc3_);
         _loc5_.push(Capabilities.screenDPI);
         _loc5_.push(Capabilities.screenResolutionX);
         _loc5_.push(Capabilities.screenResolutionY);
         var _loc6_:int = 0;
         while(_loc6_ < 4)
         {
            if(_loc6_ < _loc4_.length)
            {
               _loc5_.push(_loc4_[_loc6_]);
            }
            else
            {
               _loc5_.push(0);
            }
            _loc6_++;
         }
         gMainFrame.server.setXtObject_Str("us",_loc5_);
      }
   }
}

