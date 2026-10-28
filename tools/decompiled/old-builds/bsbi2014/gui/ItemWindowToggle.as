package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBAudio;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gamePlayFlow.GamePlay;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class ItemWindowToggle extends ItemWindowBase
   {
      
      private var _lock:MovieClip;
      
      public function ItemWindowToggle(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         super("mySettingsToggle|false",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.goNowBtn.visible = false;
         _window.woodenCursorBtn.visible = false;
         _window.defaultCursorBtn.visible = false;
         _window.toggleBtn.visible = false;
         _window.toggleTxt.visible = false;
         switch(_currItem.type)
         {
            case MySettings.TOGGLE_TYPE_TOGGLE_BTN:
               _window.toggleBtn.visible = true;
               _window.toggleBtn.toggleKnob.gotoAndStop("up");
               _window.toggleBtn.toggleBG.gotoAndStop("up");
               _window.icon.gotoAndStop(_currItem.frame);
               _window.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown,false,0,true);
               _window.toggleBtn.addEventListener(MouseEvent.ROLL_OVER,this.handleMouseOver,false,0,true);
               _window.toggleBtn.addEventListener(MouseEvent.ROLL_OUT,this.handleMouseOut,false,0,true);
               break;
            case MySettings.TOGGLE_TYPE_TEXT:
               _window.toggleTxt.visible = true;
               _window.icon.gotoAndStop(_currItem.frame);
               break;
            case MySettings.TOGGLE_TYPE_CURSOR:
               _window.woodenCursorBtn.visible = true;
               _window.defaultCursorBtn.visible = true;
               _window.icon.visible = false;
               if(Boolean(GuiManager.sharedObj) && (GuiManager.sharedObj.data.cursor == "custom" || GuiManager.sharedObj.data.cursor == null))
               {
                  _window.woodenCursorBtn.upToDownState();
                  _window.woodenCursorBtn.mouseEnabled = false;
                  _window.woodenCursorBtn.mouseChildren = false;
               }
               else
               {
                  _window.defaultCursorBtn.upToDownState();
                  _window.defaultCursorBtn.mouseEnabled = false;
                  _window.defaultCursorBtn.mouseChildren = false;
               }
               _window.woodenCursorBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown,false,0,true);
               _window.defaultCursorBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown,false,0,true);
               break;
            case MySettings.TOGGLE_TYPE_JOIN:
               _window.goNowBtn.visible = true;
               _window.goNowBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown,false,0,true);
               _window.icon.gotoAndStop(_currItem.frame);
         }
         switch(_currItem.frame)
         {
            case "lock":
               if(gMainFrame.userInfo.isMyDenPrivate)
               {
                  _window.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               else
               {
                  _window.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "world":
               _window.goNowBtn.down.txt.text = ServerSelector.getShardName(RoomManagerWorld.instance.shardId);
               _window.goNowBtn.mouse.mouse.txt.text = ServerSelector.getShardName(RoomManagerWorld.instance.shardId);
               _window.goNowBtn.mouse.up.txt.text = ServerSelector.getShardName(RoomManagerWorld.instance.shardId);
               break;
            case "music":
               if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
               {
                  _window.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               else
               {
                  _window.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "buddyRequest":
               if(Utility.isSettingOn(MySettings.SETTINGS_BUDDY_REQUESTS))
               {
                  _window.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               else
               {
                  _window.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "gameInvites":
               if(Utility.isSettingOn(MySettings.SETTINGS_GAME_INVITES))
               {
                  _window.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               else
               {
                  _window.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "doorBell":
               if(Utility.isSettingOn(MySettings.SETTINGS_DOOR_BELL))
               {
                  _window.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               else
               {
                  _window.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "intro":
         }
         LocalizationManager.translateId(_window.labelTxt,_currItem.labelTxt);
      }
      
      private function handleMouseDown(evt:MouseEvent) : void
      {
         var settingUV:int = 0;
         var setValue:int = 0;
         evt.stopPropagation();
         if(_currItem.type == MySettings.TOGGLE_TYPE_TOGGLE_BTN)
         {
            switch(_currItem.frame)
            {
               case "lock":
                  this._lock = MovieClip(evt.currentTarget);
                  GuiManager.onToggleDenLock(this.onDenLockUnlock);
                  break;
               case "music":
                  SBAudio.toggleMuteAll();
                  GuiManager.toggleMuteVideo();
                  if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
                  {
                     evt.currentTarget.gotoAndPlay("off");
                     _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("off");
                     GuiManager.depressSoundButton(true);
                  }
                  else
                  {
                     evt.currentTarget.gotoAndPlay("on");
                     _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("on");
                     GuiManager.depressSoundButton(false);
                  }
                  break;
               case "buddyRequest":
               case "gameInvites":
               case "doorBell":
                  settingUV = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_SETTINGS));
                  setValue = -1;
                  if(_currItem.frame == "buddyRequest")
                  {
                     setValue = MySettings.SETTINGS_BUDDY_REQUESTS;
                  }
                  else if(_currItem.frame == "gameInvites")
                  {
                     setValue = MySettings.SETTINGS_GAME_INVITES;
                  }
                  else if(_currItem.frame == "doorBell")
                  {
                     setValue = MySettings.SETTINGS_DOOR_BELL;
                  }
                  if(setValue != -1)
                  {
                     if(settingUV == -1)
                     {
                        if(setValue == MySettings.SETTINGS_DOOR_BELL)
                        {
                           evt.currentTarget.gotoAndPlay("on");
                           _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("on");
                        }
                        else
                        {
                           evt.currentTarget.gotoAndPlay("off");
                           _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("off");
                        }
                        AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,setValue);
                     }
                     else if(evt.currentTarget.currentFrameLabel == "on" || evt.currentTarget.currentFrameLabel == "startingOn")
                     {
                        evt.currentTarget.gotoAndPlay("off");
                        _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("off");
                        if(setValue == MySettings.SETTINGS_DOOR_BELL)
                        {
                           AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,setValue,null,false);
                        }
                        else
                        {
                           AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,setValue);
                        }
                     }
                     else
                     {
                        evt.currentTarget.gotoAndPlay("on");
                        _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("on");
                        if(setValue == MySettings.SETTINGS_DOOR_BELL)
                        {
                           AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,setValue);
                        }
                        else
                        {
                           AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_SETTINGS,setValue,null,false);
                        }
                     }
                  }
            }
            LocalizationManager.translateId(_window.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
            LocalizationManager.translateId(_window.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
         }
         else if(_currItem.type == MySettings.TOGGLE_TYPE_CURSOR)
         {
            if(evt.currentTarget.mouse.currentFrame == 3)
            {
               evt.currentTarget.mouseEnabled = false;
               evt.currentTarget.mouseChildren = false;
            }
            if(evt.currentTarget != _window.defaultCursorBtn)
            {
               GuiManager.setSharedObj("cursor","custom");
               CursorManager.switchToCursor(CursorManager.CUSTOM_CURSOR);
               _window.defaultCursorBtn.downToUpState();
               _window.defaultCursorBtn.mouseEnabled = true;
               _window.defaultCursorBtn.mouseChildren = true;
            }
            else
            {
               GuiManager.setSharedObj("cursor","default");
               CursorManager.switchToCursor(CursorManager.DEFAULT_CURSOR);
               _window.woodenCursorBtn.downToUpState();
               _window.woodenCursorBtn.mouseEnabled = true;
               _window.woodenCursorBtn.mouseChildren = true;
            }
         }
         else if(_currItem.type == MySettings.TOGGLE_TYPE_JOIN)
         {
            switch(_currItem.frame)
            {
               case "world":
                  ServerSelector.init(GuiManager.guiLayer,null,GamePlay(gMainFrame.gamePlay).joinChosenShardIdNode);
                  break;
               case "intro":
                  GuiManager.startFFM();
            }
         }
      }
      
      private function handleMouseOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(_currItem.type == MySettings.TOGGLE_TYPE_TOGGLE_BTN)
         {
            if(evt.currentTarget.toggleBG.currentFrameLabel != "up")
            {
               evt.currentTarget.toggleBG.gotoAndStop("up");
            }
            if(evt.currentTarget.toggleKnob.currentFrameLabel != "up")
            {
               evt.currentTarget.toggleKnob.gotoAndStop("up");
            }
         }
      }
      
      private function handleMouseOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(_currItem.type == MySettings.TOGGLE_TYPE_TOGGLE_BTN)
         {
            if(evt.currentTarget.toggleBG.currentFrameLabel != "over")
            {
               evt.currentTarget.toggleBG.gotoAndStop("over");
            }
            if(evt.currentTarget.toggleKnob.currentFrameLabel != "over")
            {
               evt.currentTarget.toggleKnob.gotoAndStop("over");
            }
         }
      }
      
      private function onDenLockUnlock(needsToSendRequest:Boolean = true) : void
      {
         if(needsToSendRequest)
         {
            gMainFrame.userInfo.isMyDenPrivate = !gMainFrame.userInfo.isMyDenPrivate;
            DenXtCommManager.requestSetDenPrivacy(gMainFrame.userInfo.isMyDenPrivate,true);
            GuiManager.refreshDenLockSettings();
         }
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            this._lock.gotoAndPlay("off");
            _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("off");
         }
         else
         {
            this._lock.gotoAndPlay("on");
            _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("on");
         }
      }
   }
}

