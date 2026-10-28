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
      
      public static var SETTINGS_DOOR_BELL:int = 2;
      
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
      
      public function init(initPopupLayer:DisplayLayer, xPos:int, yPos:int, initCloseCallback:Function = null) : void
      {
         this._popupLayer = initPopupLayer;
         this._closeCallback = initCloseCallback;
         this._mySettings = GETDEFINITIONBYNAME("MySettings");
         this._mySettings.x = xPos;
         this._mySettings.y = yPos;
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
         if(Boolean(this._toggleWindows))
         {
            this._toggleWindows.destroy();
            this._toggleWindows = null;
         }
         if(Boolean(this._toggleScrollBar))
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
         var numWindowsPerView:int = 0;
         var itemWindowHeight:int = 0;
         var itemWindowWidth:int = 0;
         var daysRemaining:int = 0;
         if(Boolean(gMainFrame.userInfo.isMember))
         {
            this._mySettings.statusNonmember.visible = false;
            daysRemaining = int(gMainFrame.clientInfo.numDaysLeftOnSubscription);
            if(daysRemaining > 0)
            {
               this._mySettings.gotoAndStop("memberScrollSubscription");
               numWindowsPerView = 5;
            }
            else
            {
               this._mySettings.gotoAndStop("memberScroll");
               numWindowsPerView = 6;
            }
            itemWindowHeight = int(this._mySettings.itemWindow.height);
            itemWindowWidth = int(this._mySettings.itemWindow.width);
            if(daysRemaining > 0)
            {
               if(daysRemaining > 1)
               {
                  LocalizationManager.translateIdAndInsert(this._mySettings.timeRemaining.timeTxt,11361,daysRemaining);
               }
               else
               {
                  LocalizationManager.translateIdAndInsert(this._mySettings.timeRemaining.timeTxt,11362,daysRemaining);
               }
            }
         }
         else
         {
            this._mySettings.statusMember.visible = false;
            this._mySettings.gotoAndStop("nonMemScroll");
            this._mySettings.joinBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onJoinBtn,false,0,true);
            numWindowsPerView = 5;
            itemWindowHeight = int(this._mySettings.itemWindow.height);
            itemWindowWidth = int(this._mySettings.itemWindow.width);
         }
         var toggleLists:Array = [{
            "type":TOGGLE_TYPE_JOIN,
            "frame":"world",
            "labelTxt":6395,
            "btnTxt":6366
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"lock",
            "labelTxt":6271,
            "onTxt":6393,
            "offTxt":6301
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"doorBell",
            "labelTxt":18420,
            "onTxt":6324,
            "offTxt":6322
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
         }];
         this._toggleWindows = new WindowGenerator();
         this._toggleWindows.init(1,numWindowsPerView,toggleLists.length,0,4,0,ItemWindowToggle,toggleLists,null);
         this._mySettings.itemWindow.addChild(this._toggleWindows);
         this._toggleScrollBar = new SBScrollbar();
         this._toggleScrollBar.init(this._toggleWindows,itemWindowWidth,itemWindowHeight,2,"scrollbar2",this._toggleWindows.boxHeight + 4);
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onJoinBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var url:String = gMainFrame.clientInfo.websiteURL + "membership";
         var request:URLRequest = new URLRequest(url);
         try
         {
            navigateToURL(request,"_blank");
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
            if(Boolean(joinBtn))
            {
               joinBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onJoinBtn);
            }
         }
      }
   }
}

