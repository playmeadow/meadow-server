package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.popup.SBOkPopup;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.getDefinitionByName;
   import playerWall.PlayerWallManager;
   import playerWall.PlayerWallXtCommManager;
   import room.RoomManagerWorld;
   
   public class MySettings
   {
      
      public static var SETTINGS_BUDDY_REQUESTS:int = 0;
      
      public static var SETTINGS_GAME_INVITES:int = 1;
      
      private var _mySettings:MovieClip;
      
      private var _popupLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _wallPrivacyDropDown:GuiDropdown;
      
      public function MySettings()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:int, param3:int, param4:Function = null) : void
      {
         this._popupLayer = param1;
         this._closeCallback = param4;
         this._mySettings = new (getDefinitionByName("MySettings") as Class)();
         this._mySettings.x = param2;
         this._mySettings.y = param3;
         this.setupContent();
         this.addEventListeners();
         this._popupLayer.addChild(this._mySettings);
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         this._popupLayer.removeChild(this._mySettings);
         this._closeCallback = null;
         this._mySettings = null;
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
         if(gMainFrame.userInfo.isMember)
         {
            this._mySettings.statusNonmember.visible = false;
            _loc1_ = int(gMainFrame.clientInfo.numDaysLeftOnSubscription);
            if(_loc1_ > 0)
            {
               this._mySettings.gotoAndStop("complex");
               if(_loc1_ > 1)
               {
                  this._mySettings.timeRemaining.timeTxt.text = _loc1_ + " Days Remaining";
               }
               else
               {
                  this._mySettings.timeRemaining.timeTxt.text = _loc1_ + " Day Remaining";
               }
               this._mySettings.joinBtn.visible = false;
            }
         }
         else
         {
            this._mySettings.statusMember.visible = false;
            this._mySettings.gotoAndStop("complex");
            this._mySettings.timeRemaining.visible = false;
            this._mySettings.joinBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onJoinBtn,false,0,true);
         }
         this._mySettings.denLockToggle.toggleBtn.toggleKnob.gotoAndStop("up");
         this._mySettings.denLockToggle.toggleBtn.toggleBG.gotoAndStop("up");
         this._mySettings.musicToggle.toggleBtn.toggleKnob.gotoAndStop("up");
         this._mySettings.musicToggle.toggleBtn.toggleBG.gotoAndStop("up");
         this._mySettings.buddyToggle.toggleBtn.toggleKnob.gotoAndStop("up");
         this._mySettings.buddyToggle.toggleBtn.toggleBG.gotoAndStop("up");
         this._mySettings.gameToggle.toggleBtn.toggleKnob.gotoAndStop("up");
         this._mySettings.gameToggle.toggleBtn.toggleBG.gotoAndStop("up");
         if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
         {
            this._mySettings.musicToggle.toggleBtn.gotoAndStop("startingOff");
         }
         else
         {
            this._mySettings.musicToggle.toggleBtn.gotoAndStop("startingOn");
         }
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            this._mySettings.denLockToggle.toggleBtn.gotoAndStop("startingOff");
         }
         else
         {
            this._mySettings.denLockToggle.toggleBtn.gotoAndStop("startingOn");
         }
         if(Boolean(GuiManager.sharedObj) && (GuiManager.sharedObj.data.cursor == "custom" || GuiManager.sharedObj.data.cursor == null))
         {
            this._mySettings.cursorToggle.woodenCursorBtn.upToDownState();
            this._mySettings.cursorToggle.woodenCursorBtn.mouseEnabled = false;
            this._mySettings.cursorToggle.woodenCursorBtn.mouseChildren = false;
         }
         else
         {
            this._mySettings.cursorToggle.defaulltCursorBtn.upToDownState();
            this._mySettings.cursorToggle.defaulltCursorBtn.mouseEnabled = false;
            this._mySettings.cursorToggle.defaulltCursorBtn.mouseChildren = false;
         }
         if(this.isSettingOn(SETTINGS_BUDDY_REQUESTS))
         {
            this._mySettings.buddyToggle.toggleBtn.gotoAndStop("startingOn");
         }
         else
         {
            this._mySettings.buddyToggle.toggleBtn.gotoAndStop("startingOff");
         }
         if(this.isSettingOn(SETTINGS_GAME_INVITES))
         {
            this._mySettings.gameToggle.toggleBtn.gotoAndStop("startingOn");
         }
         else
         {
            this._mySettings.gameToggle.toggleBtn.gotoAndStop("startingOff");
         }
         this._mySettings.serverName.worldTxt.text = ServerSelector.getShardName(RoomManagerWorld.instance.shardId);
      }
      
      private function isSettingOn(param1:int) : Boolean
      {
         var _loc2_:int = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_SETTINGS));
         if(_loc2_ == -1)
         {
            return true;
         }
         if((_loc2_ >> param1 & 1) == 1)
         {
            return false;
         }
         return true;
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
      
      private function onDenLockUnlock(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         gMainFrame.userInfo.isMyDenPrivate = !gMainFrame.userInfo.isMyDenPrivate;
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            param1.currentTarget.gotoAndPlay("off");
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
         }
         DenXtCommManager.requestSetDenPrivacy(gMainFrame.userInfo.isMyDenPrivate);
         GuiManager.refreshDenLockSettings();
      }
      
      private function onPlayerWallPrivacyDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._wallPrivacyDropDown.selectedIdx == 0)
         {
            this._mySettings.playerwall_dropdown.lockedIcon.visible = false;
            this._mySettings.playerwall_dropdown.unlockedIcon.visible = true;
         }
         else
         {
            this._mySettings.playerwall_dropdown.lockedIcon.visible = true;
            this._mySettings.playerwall_dropdown.unlockedIcon.visible = false;
         }
         if(this._wallPrivacyDropDown.selectedIdx != PlayerWallManager.privacyId)
         {
            this._wallPrivacyDropDown.blockItemDown = true;
            PlayerWallXtCommManager.sendPrivacySetRequest(gMainFrame.server.userName + "\n" + this._wallPrivacyDropDown.selectedIdx,this.onPrivacySetResponse);
         }
      }
      
      private function onPrivacySetResponse(param1:Boolean, param2:int) : void
      {
         this._wallPrivacyDropDown.blockItemDown = false;
         if(param1)
         {
            PlayerWallManager.privacyId = param2;
         }
         else
         {
            new SBOkPopup(this._popupLayer,"Problem setting Privacy");
         }
      }
      
      private function onToggleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleBG.gotoAndStop("over");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("over");
         }
      }
      
      private function onToggleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleBG.gotoAndStop("up");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("up");
         }
      }
      
      private function onMusicOnOff(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBAudio.toggleMuteAll();
         GuiManager.toggleMuteVideo();
         if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
         {
            param1.currentTarget.gotoAndPlay("off");
            GuiManager.depressSoundButton(true);
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
            GuiManager.depressSoundButton(false);
         }
      }
      
      private function onCursorsDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.mouse.currentFrame == 3)
         {
            param1.currentTarget.mouseEnabled = false;
            param1.currentTarget.mouseChildren = false;
         }
         if(param1.currentTarget != this._mySettings.cursorToggle.defaulltCursorBtn)
         {
            GuiManager.setSharedObj("cursor","custom");
            CursorManager.switchToCursor(CursorManager.CUSTOM_CURSOR);
            this._mySettings.cursorToggle.defaulltCursorBtn.downToUpState();
            this._mySettings.cursorToggle.defaulltCursorBtn.mouseEnabled = true;
            this._mySettings.cursorToggle.defaulltCursorBtn.mouseChildren = true;
         }
         else
         {
            GuiManager.setSharedObj("cursor","default");
            CursorManager.switchToCursor(CursorManager.DEFAULT_CURSOR);
            this._mySettings.cursorToggle.woodenCursorBtn.downToUpState();
            this._mySettings.cursorToggle.woodenCursorBtn.mouseEnabled = true;
            this._mySettings.cursorToggle.woodenCursorBtn.mouseChildren = true;
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
      
      private function onBuddyToggle(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_SETTINGS));
         if(_loc2_ == -1)
         {
            param1.currentTarget.gotoAndPlay("off");
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,SETTINGS_BUDDY_REQUESTS);
         }
         else if(param1.currentTarget.currentFrameLabel == "on" || param1.currentTarget.currentFrameLabel == "startingOn")
         {
            param1.currentTarget.gotoAndPlay("off");
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,SETTINGS_BUDDY_REQUESTS);
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,SETTINGS_BUDDY_REQUESTS,null,false);
         }
      }
      
      private function onGameToggle(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_SETTINGS));
         if(_loc2_ == -1)
         {
            param1.currentTarget.gotoAndPlay("off");
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,SETTINGS_GAME_INVITES);
         }
         else if(param1.currentTarget.currentFrameLabel == "on" || param1.currentTarget.currentFrameLabel == "startingOn")
         {
            param1.currentTarget.gotoAndPlay("off");
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,SETTINGS_GAME_INVITES);
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,SETTINGS_GAME_INVITES,null,false);
         }
      }
      
      private function addEventListeners() : void
      {
         with(this._mySettings)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
            denLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDenLockUnlock,false,0,true);
            denLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OVER,onToggleOver,false,0,true);
            denLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OUT,onToggleOut,false,0,true);
            musicToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMusicOnOff,false,0,true);
            musicToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OVER,onToggleOver,false,0,true);
            musicToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OUT,onToggleOut,false,0,true);
            cursorToggle.defaulltCursorBtn.addEventListener(MouseEvent.MOUSE_DOWN,onCursorsDown,false,0,true);
            cursorToggle.woodenCursorBtn.addEventListener(MouseEvent.MOUSE_DOWN,onCursorsDown,false,0,true);
            buddyToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,onBuddyToggle,false,0,true);
            buddyToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OVER,onToggleOver,false,0,true);
            buddyToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OUT,onToggleOut,false,0,true);
            gameToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,onGameToggle,false,0,true);
            gameToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OVER,onToggleOver,false,0,true);
            gameToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OUT,onToggleOut,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         with(this._mySettings)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            bx.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
            denLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDenLockUnlock);
            denLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OVER,onToggleOver);
            denLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OUT,onToggleOut);
            musicToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMusicOnOff);
            musicToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OVER,onToggleOver);
            musicToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OUT,onToggleOut);
            cursorToggle.defaulltCursorBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onCursorsDown);
            cursorToggle.woodenCursorBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onCursorsDown);
            if(joinBtn)
            {
               joinBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onJoinBtn);
            }
            buddyToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onBuddyToggle);
            buddyToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OVER,onToggleOver);
            buddyToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OUT,onToggleOut);
            gameToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onGameToggle);
            gameToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OVER,onToggleOver);
            gameToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OUT,onToggleOut);
         }
      }
   }
}

