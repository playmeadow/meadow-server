package gui
{
   import com.sbi.corelib.audio.SBAudio;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import localization.LocalizationManager;
   
   public class MySettings
   {
      
      public static var SETTINGS_BUDDY_REQUESTS:int = 0;
      
      public static var SETTINGS_GAME_INVITES:int = 1;
      
      public static var TOGGLE_TYPE_TOGGLE_BTN:int = 0;
      
      public static var TOGGLE_TYPE_TEXT:int = 1;
      
      public static var TOGGLE_TYPE_CURSOR:int = 2;
      
      public static var TOGGLE_TYPE_JOIN:int = 3;
      
      private var _mySettings:MovieClip;
      
      private var _popupLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _wallPrivacyDropDown:GuiDropdown;
      
      private var _toggleWindows:WindowGenerator;
      
      private var _toggleScrollBar:SBScrollbar;
      
      public function MySettings()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:int, param3:int, param4:Function = null) : void
      {
         this._popupLayer = param1;
         this._closeCallback = param4;
         this._mySettings = GETDEFINITIONBYNAME("MySettings");
         this._mySettings.x = param2;
         this._mySettings.y = param3;
         this._popupLayer.addChild(this._mySettings);
         this.setupContent();
         this.addEventListeners();
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         this._popupLayer.removeChild(this._mySettings);
         this._closeCallback = null;
         this._mySettings = null;
         if(this._toggleWindows)
         {
            this._toggleWindows.destroy();
            this._toggleWindows = null;
         }
         if(this._toggleScrollBar)
         {
            this._toggleScrollBar.destroy();
            this._toggleWindows = null;
         }
      }
      
      public function updateSoundBtn() : void
      {
         if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
         {
            this._mySettings.musicToggle.toggleBtn.gotoAndPlay("off");
         }
         else
         {
            this._mySettings.musicToggle.toggleBtn.gotoAndPlay("on");
         }
      }
      
      public function updateWorldMessage() : void
      {
      }
      
      private function setupContent() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         if(gMainFrame.userInfo.isMember)
         {
            this._mySettings.statusNonmember.visible = false;
            _loc5_ = int(gMainFrame.clientInfo.numDaysLeftOnSubscription);
            if(_loc5_ > 0)
            {
               this._mySettings.gotoAndStop("memberScrollSubscription");
               _loc1_ = 5;
            }
            else
            {
               this._mySettings.gotoAndStop("memberScroll");
               _loc1_ = 6;
            }
            _loc2_ = int(this._mySettings.itemWindow.height);
            _loc3_ = int(this._mySettings.itemWindow.width);
            if(_loc5_ > 0)
            {
               if(_loc5_ > 1)
               {
                  LocalizationManager.translateIdAndInsert(this._mySettings.timeRemaining.timeTxt,11361,_loc5_);
               }
               else
               {
                  LocalizationManager.translateIdAndInsert(this._mySettings.timeRemaining.timeTxt,11362,_loc5_);
               }
            }
         }
         else
         {
            this._mySettings.statusMember.visible = false;
            this._mySettings.gotoAndStop("nonMemScroll");
            this._mySettings.joinBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onJoinBtn,false,0,true);
            _loc1_ = 5;
            _loc2_ = int(this._mySettings.itemWindow.height);
            _loc3_ = int(this._mySettings.itemWindow.width);
         }
         var _loc4_:Array = [{
            "type":TOGGLE_TYPE_TEXT,
            "frame":"world",
            "labelTxt":6395,
            "text":6366
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"lock",
            "labelTxt":6271,
            "onTxt":6393,
            "offTxt":6301
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"music",
            "labelTxt":6373,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_CURSOR,
            "frame":"",
            "labelTxt":6269
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"buddyRequest",
            "labelTxt":6251,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"gameInvites",
            "labelTxt":6282,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_JOIN,
            "frame":"intro",
            "labelTxt":15677,
            "btnTxt":9691
         }];
         this._toggleWindows = new WindowGenerator();
         this._toggleWindows.init(1,_loc1_,_loc4_.length,0,4,0,ItemWindowToggle,_loc4_,null);
         this._mySettings.itemWindow.addChild(this._toggleWindows);
         this._toggleScrollBar = new SBScrollbar();
         this._toggleScrollBar.init(this._toggleWindows,_loc3_,_loc2_,2,"scrollbar2",this._toggleWindows.boxHeight + 4);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onJoinBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:String = gMainFrame.clientInfo.websiteURL + "membership";
         var _loc3_:URLRequest = new URLRequest(_loc2_);
         try
         {
            navigateToURL(_loc3_,"_blank");
         }
         catch(e:Error)
         {
         }
      }
      
      private function addEventListeners() : void
      {
         with(this._mySettings)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         with(this._mySettings)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            bx.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
            if(joinBtn)
            {
               joinBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onJoinBtn);
            }
         }
      }
   }
}

