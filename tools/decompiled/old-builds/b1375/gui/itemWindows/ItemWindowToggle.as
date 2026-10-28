package gui.itemWindows
{
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBAudio;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gamePlayFlow.GamePlay;
   import gui.CursorManager;
   import gui.GuiHud;
   import gui.GuiManager;
   import gui.MySettings;
   import gui.ServerSelector;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class ItemWindowToggle extends ItemWindowBase
   {
      
      private var _lock:MovieClip;
      
      private var _currHeight:int;
      
      private var _mySettingsCloseFunction:Function;
      
      public function ItemWindowToggle(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _mySettingsCloseFunction = param9.onClose;
         super("mySettingsToggle|false",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get currFrameLabel() : String
      {
         return _currItem.frame;
      }
      
      public function resetConditions() : void
      {
         setChildrenAndInitialConditions();
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         addEventListeners();
         super.onWindowLoadCallback();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
      }
      
      override public function get height() : Number
      {
         return _currHeight;
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:Boolean = false;
         _currHeight = _window.height;
         _window.goNowBtn.visible = false;
         _window.woodenCursorBtn.visible = false;
         _window.defaultCursorBtn.visible = false;
         _window.toggleBtn.visible = false;
         _window.toggleTxt.visible = false;
         switch(_currItem.type)
         {
            case MySettings.TOGGLE_TYPE_TOGGLE_BTN:
               _window.toggleBtn.visible = true;
               _window.toggleBtn.toggleBtn.toggleKnob.gotoAndStop("up");
               _window.toggleBtn.toggleBtn.toggleBG.gotoAndStop("up");
               _window.icon.gotoAndStop(_currItem.frame);
               _window.toggleBtn.addEventListener("mouseDown",handleMouseDown,false,0,true);
               _window.toggleBtn.addEventListener("rollOver",handleMouseOver,false,0,true);
               _window.toggleBtn.addEventListener("rollOut",handleMouseOut,false,0,true);
               break;
            case MySettings.TOGGLE_TYPE_TEXT:
               _window.toggleTxt.visible = true;
               _window.icon.gotoAndStop(_currItem.frame);
               break;
            case MySettings.TOGGLE_TYPE_CURSOR:
               _window.woodenCursorBtn.visible = true;
               _window.defaultCursorBtn.visible = true;
               _window.icon.visible = false;
               if(GuiManager.sharedObj && (GuiManager.sharedObj.data.cursor == "custom" || GuiManager.sharedObj.data.cursor == null))
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
               _window.woodenCursorBtn.addEventListener("mouseDown",handleMouseDown,false,0,true);
               _window.defaultCursorBtn.addEventListener("mouseDown",handleMouseDown,false,0,true);
               break;
            case MySettings.TOGGLE_TYPE_JOIN:
               _window.goNowBtn.visible = true;
               _window.goNowBtn.addEventListener("mouseDown",handleMouseDown,false,0,true);
               _window.icon.gotoAndStop(_currItem.frame);
         }
         switch(_currItem.frame)
         {
            case "lock":
               if(gMainFrame.userInfo.isMyDenPrivate)
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "world":
               _window.goNowBtn.down.txt.text = ServerSelector.getShardName(RoomManagerWorld.instance.shardId);
               _window.goNowBtn.mouse.mouse.txt.text = ServerSelector.getShardName(RoomManagerWorld.instance.shardId);
               _window.goNowBtn.mouse.up.txt.text = ServerSelector.getShardName(RoomManagerWorld.instance.shardId);
               break;
            case "redeemCode":
               LocalizationManager.translateId(_window.goNowBtn.down.txt,_currItem.btnTxt);
               LocalizationManager.translateId(_window.goNowBtn.mouse.mouse.txt,_currItem.btnTxt);
               LocalizationManager.translateId(_window.goNowBtn.mouse.up.txt,_currItem.btnTxt);
               break;
            case "music":
               if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "buddyRequest":
               if(Utility.isSettingOn(MySettings.SETTINGS_BUDDY_REQUESTS))
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "gameInvites":
               if(Utility.isSettingOn(MySettings.SETTINGS_GAME_INVITES))
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "doorBell":
               if(Utility.isSettingOn(MySettings.SETTINGS_DOOR_BELL))
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "autoServer":
               if(Utility.isSettingOn(MySettings.SETTINGS_AUTO_SERVER_TRAVEL))
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "nameBadge":
               if(Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE))
               {
                  _window.toggleBtn.gotoAndStop("double");
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
               }
               else
               {
                  _window.toggleBtn.gotoAndStop("double");
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "denPlayerIcon":
               if(Utility.isSettingOn(MySettings.SETTINGS_DEN_PLAYER_ICON))
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "jammerWallIcon":
               if(Utility.isSettingOn(MySettings.SETTINGS_JAMMER_WALL_ICON))
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "predictTxt":
               _loc1_ = Utility.isSettingOn(MySettings.SETTINGS_CHAT_PREDICTION);
               if(gMainFrame.userInfo.sgChatType == 1)
               {
                  if(!Utility.hasChatSettingBeenSet())
                  {
                     _loc1_ = false;
                  }
               }
               if(_loc1_)
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOn");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOn");
               }
               else
               {
                  _window.toggleBtn.toggleBtn.gotoAndStop("startingOff");
                  _window.icon["" + _window.icon.currentFrameLabel].gotoAndStop("startingOff");
               }
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
               LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
               break;
            case "intro":
         }
         LocalizationManager.translateId(_window.labelTxtCont.labelTxt,_currItem.labelTxt);
      }
      
      private function handleMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(_currItem.type == MySettings.TOGGLE_TYPE_TOGGLE_BTN)
         {
            switch(_currItem.frame)
            {
               case "lock":
                  _lock = MovieClip(param1.currentTarget);
                  GuiManager.onToggleDenLock(onDenLockUnlock);
                  break;
               case "music":
                  SBAudio.toggleMuteAll();
                  GuiManager.toggleMuteVideo();
                  if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
                  {
                     param1.currentTarget.toggleBtn.gotoAndPlay("off");
                     _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("off");
                     GuiManager.depressSoundButton(true);
                  }
                  else
                  {
                     param1.currentTarget.toggleBtn.gotoAndPlay("on");
                     _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("on");
                     GuiManager.depressSoundButton(false);
                  }
                  break;
               case "buddyRequest":
               case "gameInvites":
               case "doorBell":
               case "autoServer":
               case "nameBadge":
               case "denPlayerIcon":
               case "jammerWallIcon":
               case "predictTxt":
                  _loc2_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(363));
                  _loc3_ = -1;
                  if(_currItem.frame == "buddyRequest")
                  {
                     _loc3_ = MySettings.SETTINGS_BUDDY_REQUESTS;
                  }
                  else if(_currItem.frame == "gameInvites")
                  {
                     _loc3_ = MySettings.SETTINGS_GAME_INVITES;
                  }
                  else if(_currItem.frame == "doorBell")
                  {
                     _loc3_ = MySettings.SETTINGS_DOOR_BELL;
                  }
                  else if(_currItem.frame == "autoServer")
                  {
                     _loc3_ = MySettings.SETTINGS_AUTO_SERVER_TRAVEL;
                  }
                  else if(_currItem.frame == "nameBadge")
                  {
                     _loc3_ = MySettings.SETTINGS_USERNAME_BADGE;
                  }
                  else if(_currItem.frame == "denPlayerIcon")
                  {
                     _loc3_ = MySettings.SETTINGS_DEN_PLAYER_ICON;
                  }
                  else if(_currItem.frame == "jammerWallIcon")
                  {
                     _loc3_ = MySettings.SETTINGS_JAMMER_WALL_ICON;
                  }
                  else if(_currItem.frame == "predictTxt")
                  {
                     _loc3_ = MySettings.SETTINGS_CHAT_PREDICTION;
                     if(gMainFrame.userInfo.sgChatType == 1)
                     {
                        if(!Utility.hasChatSettingBeenSet())
                        {
                           AchievementXtCommManager.requestSetUserVar(363,_loc3_);
                           _loc2_ = 0;
                        }
                     }
                     if(!Utility.hasChatSettingBeenSet())
                     {
                        AchievementXtCommManager.requestSetUserVar(452,1);
                     }
                  }
                  if(_loc3_ != -1)
                  {
                     if(_loc2_ == -1)
                     {
                        if(_loc3_ == MySettings.SETTINGS_DOOR_BELL || _loc3_ == MySettings.SETTINGS_USERNAME_BADGE)
                        {
                           param1.currentTarget.toggleBtn.gotoAndPlay("on");
                           if(_window.icon["" + _window.icon.currentFrameLabel].currentLabel)
                           {
                              _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("on");
                           }
                        }
                        else
                        {
                           param1.currentTarget.toggleBtn.gotoAndPlay("off");
                           if(_window.icon["" + _window.icon.currentFrameLabel].currentLabel)
                           {
                              _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("off");
                           }
                        }
                        AchievementXtCommManager.requestSetUserVar(363,_loc3_);
                     }
                     else if(param1.currentTarget.toggleBtn.currentFrameLabel == "on" || param1.currentTarget.toggleBtn.currentFrameLabel == "startingOn")
                     {
                        param1.currentTarget.toggleBtn.gotoAndPlay("off");
                        if(_window.icon["" + _window.icon.currentFrameLabel].currentLabel)
                        {
                           _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("off");
                        }
                        if(_loc3_ == MySettings.SETTINGS_DOOR_BELL || _loc3_ == MySettings.SETTINGS_USERNAME_BADGE)
                        {
                           AchievementXtCommManager.requestSetUserVar(363,_loc3_,null,false);
                        }
                        else
                        {
                           AchievementXtCommManager.requestSetUserVar(363,_loc3_);
                        }
                     }
                     else
                     {
                        param1.currentTarget.toggleBtn.gotoAndPlay("on");
                        if(_window.icon["" + _window.icon.currentFrameLabel].currentLabel)
                        {
                           _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("on");
                        }
                        if(_loc3_ == MySettings.SETTINGS_DOOR_BELL || _loc3_ == MySettings.SETTINGS_USERNAME_BADGE)
                        {
                           AchievementXtCommManager.requestSetUserVar(363,_loc3_);
                        }
                        else
                        {
                           AchievementXtCommManager.requestSetUserVar(363,_loc3_,null,false);
                        }
                     }
                     if(_loc3_ == MySettings.SETTINGS_JAMMER_WALL_ICON)
                     {
                        GuiManager.updateMainHudButtons(false,{
                           "btnName":(GuiManager.mainHud as GuiHud).playerWallBtn.name,
                           "show":param1.currentTarget.toggleBtn.currentLabel == "on"
                        });
                     }
                  }
            }
            LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.onTxt,_currItem.onTxt);
            LocalizationManager.translateId(_window.toggleBtn.toggleBtn.valueTxt.offTxt,_currItem.offTxt);
         }
         else if(_currItem.type == MySettings.TOGGLE_TYPE_CURSOR)
         {
            if(param1.currentTarget.mouse.currentFrame == 3)
            {
               param1.currentTarget.mouseEnabled = false;
               param1.currentTarget.mouseChildren = false;
            }
            if(param1.currentTarget != _window.defaultCursorBtn)
            {
               GuiManager.setSharedObj("cursor","custom");
               CursorManager.switchToCursor("custom_cursor");
               _window.defaultCursorBtn.downToUpState();
               _window.defaultCursorBtn.mouseEnabled = true;
               _window.defaultCursorBtn.mouseChildren = true;
            }
            else
            {
               GuiManager.setSharedObj("cursor","default");
               CursorManager.switchToCursor("Default_Cursor");
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
                  break;
               case "redeemCode":
                  if(_mySettingsCloseFunction != null)
                  {
                     _mySettingsCloseFunction(null);
                  }
                  GuiManager.openCodeRedemptionPopup();
            }
         }
      }
      
      private function handleMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currItem.type == MySettings.TOGGLE_TYPE_TOGGLE_BTN)
         {
            if(param1.currentTarget.toggleBtn.toggleBG.currentFrameLabel != "up")
            {
               param1.currentTarget.toggleBtn.toggleBG.gotoAndStop("up");
            }
            if(param1.currentTarget.toggleBtn.toggleKnob.currentFrameLabel != "up")
            {
               param1.currentTarget.toggleBtn.toggleKnob.gotoAndStop("up");
            }
         }
      }
      
      private function handleMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currItem.type == MySettings.TOGGLE_TYPE_TOGGLE_BTN)
         {
            if(param1.currentTarget.toggleBtn.toggleBG.currentFrameLabel != "over")
            {
               param1.currentTarget.toggleBtn.toggleBG.gotoAndStop("over");
            }
            if(param1.currentTarget.toggleBtn.toggleKnob.currentFrameLabel != "over")
            {
               param1.currentTarget.toggleBtn.toggleKnob.gotoAndStop("over");
            }
         }
      }
      
      private function onDenLockUnlock(param1:Boolean = true) : void
      {
         if(param1)
         {
            gMainFrame.userInfo.isMyDenPrivate = !gMainFrame.userInfo.isMyDenPrivate;
            DenXtCommManager.requestSetDenPrivacy(gMainFrame.userInfo.isMyDenPrivate,true);
            GuiManager.refreshDenLockSettings();
         }
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            _lock.toggleBtn.gotoAndPlay("off");
            _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("off");
         }
         else
         {
            _lock.toggleBtn.gotoAndPlay("on");
            _window.icon["" + _window.icon.currentFrameLabel].gotoAndPlay("on");
         }
      }
   }
}

