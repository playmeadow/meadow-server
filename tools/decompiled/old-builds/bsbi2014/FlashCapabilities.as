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
         var capFlags:int = 0;
         if(Capabilities.avHardwareDisable)
         {
            capFlags |= 1 << CAPABILITIES_AV_HARDWARE_DISABLE;
         }
         if(Capabilities.hasAccessibility)
         {
            capFlags |= 1 << CAPABILITIES_HAS_ACCESSIBILITY;
         }
         if(Capabilities.hasAudio)
         {
            capFlags |= 1 << CAPABILITIES_HAS_AUDIO;
         }
         if(Capabilities.hasAudioEncoder)
         {
            capFlags |= 1 << CAPABILITIES_HAS_AUDIO_ENCODER;
         }
         if(Capabilities.hasEmbeddedVideo)
         {
            capFlags |= 1 << CAPABILITIES_HAS_EMBEDDED_VIDEO;
         }
         if(Capabilities.hasIME)
         {
            capFlags |= 1 << CAPABILITIES_HAS_IME;
         }
         if(Capabilities.hasMP3)
         {
            capFlags |= 1 << CAPABILITIES_HAS_MP3;
         }
         if(Capabilities.hasPrinting)
         {
            capFlags |= 1 << CAPABILITIES_HAS_PRINTING;
         }
         if(Capabilities.hasScreenBroadcast)
         {
            capFlags |= 1 << CAPABILITIES_HAS_SCREEN_BROADCAST;
         }
         if(Capabilities.hasScreenPlayback)
         {
            capFlags |= 1 << CAPABILITIES_HAS_SCREEN_PLAYBACK;
         }
         if(Capabilities.hasStreamingAudio)
         {
            capFlags |= 1 << CAPABILITIES_HAS_STREAMING_AUDIO;
         }
         if(Capabilities.hasStreamingVideo)
         {
            capFlags |= 1 << CAPABILITIES_HAS_STREAMING_VIDEO;
         }
         if(Capabilities.hasTLS)
         {
            capFlags |= 1 << CAPABILITIES_HAS_TLS;
         }
         if(Capabilities.hasVideoEncoder)
         {
            capFlags |= 1 << CAPABILITIES_HAS_VIDEO_ENCODER;
         }
         if(Capabilities.isDebugger)
         {
            capFlags |= 1 << CAPABILITIES_IS_DEBUGGER;
         }
         if(Capabilities.isEmbeddedInAcrobat)
         {
            capFlags |= 1 << CAPABILITIES_IS_EMBEDDED_IN_ACROBAT;
         }
         if(Capabilities.localFileReadDisable)
         {
            capFlags |= 1 << CAPABILITIES_LOCAL_FILE_READ_DISABLE;
         }
         var capPlayerType:int = CAPABILITIES_UNKNOWN_VALUE;
         switch(Capabilities.playerType)
         {
            case "ActiveX":
               capPlayerType = int(CAPABILITIES_PLAYER_TYPE_ACTIVEX);
               break;
            case "Desktop":
               capPlayerType = int(CAPABILITIES_PLAYER_TYPE_DESKTOP);
               break;
            case "External":
               capPlayerType = int(CAPABILITIES_PLAYER_TYPE_EXTERNAL);
               break;
            case "PlugIn":
               capPlayerType = int(CAPABILITIES_PLAYER_TYPE_PLUGIN);
               break;
            case "StandAlone":
               capPlayerType = int(CAPABILITIES_PLAYER_TYPE_STANDALONE);
         }
         var capScreenColor:int = CAPABILITIES_UNKNOWN_VALUE;
         switch(Capabilities.screenColor)
         {
            case "color":
               capScreenColor = int(CAPABILITIES_SCREEN_COLOR_COLOR);
               break;
            case "gray":
               capScreenColor = int(CAPABILITIES_SCREEN_COLOR_GRAY);
               break;
            case "bw":
               capScreenColor = int(CAPABILITIES_SCREEN_COLOR_BW);
         }
         var capVersionArray:Array = Capabilities.version.substring(Capabilities.version.indexOf(" ") + 1).split(",");
         var capArray:Array = [];
         capArray.push(capFlags);
         capArray.push(Capabilities.language);
         capArray.push(Capabilities.manufacturer);
         capArray.push(Capabilities.os);
         capArray.push(Capabilities.pixelAspectRatio);
         capArray.push(capPlayerType);
         capArray.push(capScreenColor);
         capArray.push(Capabilities.screenDPI);
         capArray.push(Capabilities.screenResolutionX);
         capArray.push(Capabilities.screenResolutionY);
         for(var i:int = 0; i < 4; i++)
         {
            if(i < capVersionArray.length)
            {
               capArray.push(capVersionArray[i]);
            }
            else
            {
               capArray.push(0);
            }
         }
         gMainFrame.server.setXtObject_Str("us",capArray);
      }
   }
}

