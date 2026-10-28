package
{
   import com.sbi.corelib.Utils;
   import com.sbi.corelib.audio.SBAudio;
   import flash.net.SharedObject;
   import flash.utils.Dictionary;
   
   public class AJAudio
   {
      
      private static var _hasLoadedDailySpinSfx:Boolean;
      
      private static var _hasLoadedGiftUnwrapSfx:Boolean;
      
      private static var _hasLoadedJourneyBookWorldSfx:Boolean;
      
      private static var _hasLoadedJourneyBookBookSfx:Boolean;
      
      private static var _hasLoadedTradeSfx:Boolean;
      
      private static var _defaultVolumes:Dictionary;
      
      public function AJAudio()
      {
         super();
      }
      
      public static function init(muteCallback:Function = null) : void
      {
         var cachedSounds:Object = null;
         if(!SBAudio.isInitialized)
         {
            cachedSounds = {};
            cachedSounds["HudBtnRollover"] = {
               "className":Utils.getDefByName("HudBtnRollover") as Class,
               "volume":0.2
            };
            cachedSounds["HudBtnClick"] = {
               "className":Utils.getDefByName("HudBtnClick") as Class,
               "volume":0.2
            };
            cachedSounds["SubMenuBtnRollover"] = {
               "className":Utils.getDefByName("SubMenuBtnRollover") as Class,
               "volume":0.2
            };
            cachedSounds["SubMenuBtnClick"] = {
               "className":Utils.getDefByName("SubMenuBtnClick") as Class,
               "volume":0.2
            };
            cachedSounds["ExitBtnRollover"] = {
               "className":Utils.getDefByName("ExitBtnRollover") as Class,
               "volume":0.2
            };
            cachedSounds["ExitBtnClick"] = {
               "className":Utils.getDefByName("ExitBtnClick") as Class,
               "volume":0.2
            };
            cachedSounds["ScrollUpDown"] = {
               "className":Utils.getDefByName("ScrollUpDown") as Class,
               "volume":0.2
            };
            cachedSounds["ScrollLeftRight"] = {
               "className":Utils.getDefByName("ScrollLeftRight") as Class,
               "volume":0.2
            };
            cachedSounds["TextType"] = {
               "className":Utils.getDefByName("TextType") as Class,
               "volume":0.2
            };
            cachedSounds["TextEnter"] = {
               "className":Utils.getDefByName("TextEnter") as Class,
               "volume":0.2
            };
            cachedSounds["IdleWarningSound"] = {
               "className":Utils.getDefByName("IdleWarningSound") as Class,
               "volume":0.2
            };
            cachedSounds["ShopCachingSound"] = {
               "className":Utils.getDefByName("ShopCachingSound") as Class,
               "volume":0.2
            };
            cachedSounds["GemsEarnedSound"] = {
               "className":Utils.getDefByName("GemsEarnedSound") as Class,
               "volume":0.2
            };
            cachedSounds["ItemRecycledSound"] = {
               "className":Utils.getDefByName("ItemRecycledSound") as Class,
               "volume":0.2
            };
            cachedSounds["MailReceivedSound"] = {
               "className":Utils.getDefByName("MailReceivedSound") as Class,
               "volume":0.2
            };
            cachedSounds["BuddyOnlineOfflineSound"] = {
               "className":Utils.getDefByName("BuddyOnlineOfflineSound") as Class,
               "volume":0.2
            };
            cachedSounds["NewspaperSound"] = {
               "className":Utils.getDefByName("NewspaperSound") as Class,
               "volume":0.2
            };
            cachedSounds["MailSentSound"] = {
               "className":Utils.getDefByName("MailSentSound") as Class,
               "volume":0.2
            };
            cachedSounds["AchievementSound"] = {
               "className":Utils.getDefByName("AchievementSound") as Class,
               "volume":0.2
            };
            cachedSounds["BuddyCardOpen"] = {
               "className":Utils.getDefByName("BuddyCardOpen") as Class,
               "volume":0.2
            };
            cachedSounds["BuddyCardClose"] = {
               "className":Utils.getDefByName("BuddyCardClose") as Class,
               "volume":0.2
            };
            cachedSounds["LimitedChatErrorSound"] = {
               "className":Utils.getDefByName("LimitedChatErrorSound") as Class,
               "volume":0.2
            };
            cachedSounds["ChatOpenSound"] = {
               "className":Utils.getDefByName("ChatOpenSound") as Class,
               "volume":0.2
            };
            cachedSounds["ChatCloseSound"] = {
               "className":Utils.getDefByName("ChatCloseSound") as Class,
               "volume":0.2
            };
            cachedSounds["RandomLever"] = {
               "className":Utils.getDefByName("RandomLever") as Class,
               "volume":0.2
            };
            cachedSounds["NameGenRotationSound"] = {
               "className":Utils.getDefByName("NameGenRotationSound") as Class,
               "volume":1
            };
            cachedSounds["NameGenStopSound"] = {
               "className":Utils.getDefByName("NameGenStopSound") as Class,
               "volume":1
            };
            cachedSounds["DoorBellSound"] = {
               "className":Utils.getDefByName("DoorBellSound") as Class,
               "volume":1
            };
            SBAudio.init(cachedSounds,muteCallback);
            _defaultVolumes = new Dictionary();
            _defaultVolumes["FW_TRAIL_1"] = 0.2;
            _defaultVolumes["FW_TRAIL_2"] = 0.2;
            _defaultVolumes["FW_TRAIL_3"] = 0.2;
            _defaultVolumes["FW_LAUNCH_1"] = 0.3;
            _defaultVolumes["FW_LAUNCH_2"] = 0.3;
            _defaultVolumes["FW_LAUNCH_3"] = 0.3;
            _defaultVolumes["FW_EXPLOSION_1"] = 0.3;
            _defaultVolumes["FW_EXPLOSION_2"] = 0.3;
            _defaultVolumes["FW_EXPLOSION_3"] = 0.3;
            _defaultVolumes["DOOR_WOOD_OPEN"] = 0.3;
            _defaultVolumes["DOOR_WOOD_CLOSE"] = 0.3;
            _defaultVolumes["DOOR_SLIDE"] = 0.3;
            _defaultVolumes["DOOR_STONE_SLIDE"] = 0.3;
            _defaultVolumes["aj_water_fs1"] = 0;
            _defaultVolumes["aj_water_fs2"] = 0;
            _defaultVolumes["aj_water_fs3"] = 0;
         }
      }
      
      public static function loadSfx(className:String, classVar:Class, defVolume:Number = 0.3) : void
      {
         if(Boolean(_defaultVolumes[className]))
         {
            defVolume = Number(_defaultVolumes[className]);
         }
         SBAudio.addCachedSound(className,classVar,defVolume);
      }
      
      public static function setupSharedObject(sharedObj:SharedObject) : void
      {
         SBAudio.setupSharedObject(sharedObj);
      }
      
      public static function playSfx(className:String, loopCount:int = 1) : void
      {
         SBAudio.playCachedSound(className,loopCount);
      }
      
      public static function stopSfx(className:String) : void
      {
         SBAudio.stopCachedSound(className);
      }
      
      public static function playHudBtnRollover() : void
      {
         playSfx("HudBtnRollover");
      }
      
      public static function playHudBtnClick() : void
      {
         playSfx("HudBtnClick");
      }
      
      public static function playSubMenuBtnRollover() : void
      {
         playSfx("SubMenuBtnRollover");
      }
      
      public static function playSubMenuBtnClick() : void
      {
         playSfx("SubMenuBtnClick");
      }
      
      public static function playExitBtnRollover() : void
      {
         playSfx("ExitBtnRollover");
      }
      
      public static function playExitBtnClick() : void
      {
         playSfx("ExitBtnClick");
      }
      
      public static function playScrollUpDown() : void
      {
         playSfx("ScrollUpDown");
      }
      
      public static function playScrollLeftRight() : void
      {
         playSfx("ScrollLeftRight");
      }
      
      public static function playTextType() : void
      {
         playSfx("TextType");
      }
      
      public static function playTextEnter() : void
      {
         playSfx("TextEnter");
      }
      
      public static function playIdleWarningSound() : void
      {
         playSfx("IdleWarningSound");
      }
      
      public static function playShopCachingSound() : void
      {
         playSfx("ShopCachingSound");
      }
      
      public static function playGemsEarnedSound() : void
      {
         playSfx("GemsEarnedSound");
      }
      
      public static function playItemRecycledSound() : void
      {
         playSfx("ItemRecycledSound");
      }
      
      public static function playMailReceivedSound() : void
      {
         playSfx("MailReceivedSound");
      }
      
      public static function playMailSentSound() : void
      {
         playSfx("MailSentSound");
      }
      
      public static function playBuddyOnlineOfflineSound() : void
      {
         playSfx("BuddyOnlineOfflineSound");
      }
      
      public static function playNewspaperSound() : void
      {
         playSfx("NewspaperSound");
      }
      
      public static function playAchievementSound() : void
      {
         playSfx("AchievementSound");
      }
      
      public static function playBuddyCardOpen() : void
      {
         playSfx("BuddyCardOpen");
      }
      
      public static function playBuddyCardClose() : void
      {
         playSfx("BuddyCardClose");
      }
      
      public static function playLimitedChatErrorSound() : void
      {
         playSfx("LimitedChatErrorSound");
      }
      
      public static function playChatOpenSound() : void
      {
         playSfx("ChatOpenSound");
      }
      
      public static function playChatCloseSound() : void
      {
         playSfx("ChatCloseSound");
      }
      
      public static function playRandomLever() : void
      {
         playSfx("RandomLever");
      }
      
      public static function playNameGenRotationSound(loopCount:int = 1) : void
      {
         playSfx("NameGenRotationSound",loopCount);
      }
      
      public static function playNameGenStopSound() : void
      {
         playSfx("NameGenStopSound");
      }
      
      public static function playDoorBellSound() : void
      {
         playSfx("DoorBellSound");
      }
      
      public static function stopNameGenRotationSound() : void
      {
         stopSfx("NameGenRotationSound");
      }
      
      public static function stopRandomLever() : void
      {
         stopSfx("RandomLever");
      }
      
      public static function get hasLoadedDailySpinSfx() : Boolean
      {
         return _hasLoadedDailySpinSfx;
      }
      
      public static function set hasLoadedDailySpinSfx(value:Boolean) : void
      {
         _hasLoadedDailySpinSfx = value;
      }
      
      public static function playDailySpinSpin() : void
      {
         if(!_hasLoadedDailySpinSfx)
         {
            return;
         }
         playSfx("DailySpinSpin");
      }
      
      public static function playDailySpinBub1() : void
      {
         if(!_hasLoadedDailySpinSfx)
         {
            return;
         }
         playSfx("DailySpinBub1");
      }
      
      public static function playDailySpinBub2() : void
      {
         if(!_hasLoadedDailySpinSfx)
         {
            return;
         }
         playSfx("DailySpinBub2");
      }
      
      public static function playDailySpinBub3() : void
      {
         if(!_hasLoadedDailySpinSfx)
         {
            return;
         }
         playSfx("DailySpinBub3");
      }
      
      public static function get hasLoadedGiftUnwrapSfx() : Boolean
      {
         return _hasLoadedGiftUnwrapSfx;
      }
      
      public static function set hasLoadedGiftUnwrapSfx(value:Boolean) : void
      {
         _hasLoadedGiftUnwrapSfx = value;
      }
      
      public static function playGiftUnwrap() : void
      {
         if(!_hasLoadedGiftUnwrapSfx)
         {
            return;
         }
         playSfx("GiftUnwrap");
      }
      
      public static function playTreasureUnwrap() : void
      {
         if(!_hasLoadedGiftUnwrapSfx)
         {
            return;
         }
         playSfx("TreasureUnwrap");
      }
      
      public static function get hasLoadedJourneyBookWorldSfx() : Boolean
      {
         return _hasLoadedJourneyBookWorldSfx;
      }
      
      public static function set hasLoadedJourneyBookWorldSfx(value:Boolean) : void
      {
         _hasLoadedJourneyBookWorldSfx = value;
      }
      
      public static function playJBPrizeEarned() : void
      {
         if(!_hasLoadedJourneyBookWorldSfx)
         {
            return;
         }
         playSfx("JBPrizeEarned");
      }
      
      public static function playJBWorldFactClose() : void
      {
         if(!_hasLoadedJourneyBookWorldSfx)
         {
            return;
         }
         playSfx("JBWorldFactClose");
      }
      
      public static function playJBWorldFactOpen() : void
      {
         if(!_hasLoadedJourneyBookWorldSfx)
         {
            return;
         }
         playSfx("JBWorldFactOpen");
      }
      
      public static function get hasLoadedJourneyBookBookSfx() : Boolean
      {
         return _hasLoadedJourneyBookBookSfx;
      }
      
      public static function set hasLoadedJourneyBookBookSfx(value:Boolean) : void
      {
         _hasLoadedJourneyBookBookSfx = value;
      }
      
      public static function playJBBookFactClose() : void
      {
         if(!_hasLoadedJourneyBookBookSfx)
         {
            return;
         }
         playSfx("JBBookFactClose");
      }
      
      public static function playJBBookFactOpen() : void
      {
         if(!_hasLoadedJourneyBookBookSfx)
         {
            return;
         }
         playSfx("JBBookFactOpen");
      }
      
      public static function get hasLoadedTradeSfx() : Boolean
      {
         return _hasLoadedTradeSfx;
      }
      
      public static function set hasLoadedTradeSfx(value:Boolean) : void
      {
         _hasLoadedTradeSfx = value;
      }
      
      public static function playTradeSuccessSound() : void
      {
         if(!_hasLoadedTradeSfx)
         {
            return;
         }
         playSfx("TradeSuccessSound");
      }
      
      public static function playTradeFailedSound() : void
      {
         if(!_hasLoadedTradeSfx)
         {
            return;
         }
         playSfx("TradeFailedSound");
      }
      
      public static function playTradeRequestSound() : void
      {
         if(!_hasLoadedTradeSfx)
         {
            return;
         }
         playSfx("TradeRequestSound");
      }
   }
}

