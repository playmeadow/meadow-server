package gui
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopupManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import quest.QuestXtCommManager;
   
   public class AdventureJoin
   {
      
      public static const NORMAL_TYPE:String = "normal";
      
      public static const CUSTOM_WAITING_TYPE:String = "custParty";
      
      public static const CUSTOM_SETTINGS_TYPE:String = "custSettings";
      
      public static const NO_LOBBY:String = "noPlayers";
      
      private const MEDIA_ID:int = 2249;
      
      private var _scriptDef:Object;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _numPlayersMC:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _inParamsWaiting:Object;
      
      private var _artLoadingSpiral:LoadingSpiral;
      
      private var _closeCallback:Function;
      
      private var _savedParams:Array;
      
      private var _type:String;
      
      private var _modeDropDown:GuiDropdown;
      
      private var _difficulty:int;
      
      private var _numPlayersText:String;
      
      private var _bigPet:GuiPet;
      
      public function AdventureJoin()
      {
         super();
      }
      
      public function init(param1:int, param2:String, param3:int, param4:Function) : void
      {
         this._savedParams = [];
         this._scriptDef = QuestXtCommManager.getScriptDef(param1);
         this._type = param2;
         this._difficulty = param3;
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = param4;
         DarkenManager.showLoadingSpiral(true);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this.MEDIA_ID,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         SBPopupManager.closeAll();
         TradeManager.closeAllTradingRelatedPopups();
         this.removeEventListeners();
         if(this._bigPet)
         {
            this._bigPet.destroy();
            this._bigPet = null;
         }
         this._mediaHelper.destroy();
         this._mediaHelper = null;
         if(this._popup)
         {
            DarkenManager.unDarken(this._popup);
            this._guiLayer.removeChild(this._popup);
            this._popup = null;
         }
      }
      
      public function handleWaitResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Avatar = null;
         var _loc8_:AvatarInfo = null;
         if(Boolean(this._popup) && (this._type == NORMAL_TYPE || this._type == CUSTOM_WAITING_TYPE))
         {
            _loc2_ = int(this._scriptDef.avatarLimit);
            _loc3_ = 1;
            _loc4_ = 1;
            while(_loc4_ < _loc2_ + 1)
            {
               while(this._numPlayersMC["p" + _loc4_].char.charLayer.numChildren > 0)
               {
                  this._numPlayersMC["p" + _loc4_].char.charLayer.removeChildAt(0);
               }
               this._numPlayersMC["p" + _loc4_].char.gotoAndPlay("waiting");
               this._numPlayersMC["p" + _loc4_].char.nameBar.lastName_txt.text = "";
               _loc4_++;
            }
            _loc5_ = 2;
            for(; _loc5_ < _loc2_ + 2; _loc5_++)
            {
               if(_loc5_ < param1.length)
               {
                  _loc6_ = int(param1[_loc5_]);
                  this._numPlayersMC["p" + (_loc5_ - 1)].char.gotoAndPlay("up");
                  _loc7_ = AvatarManager.getAvatarBySfsUserId(_loc6_);
                  if(_loc7_)
                  {
                     _loc8_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc7_.userName);
                  }
                  if(_loc7_ == null || _loc8_ == null)
                  {
                     this._savedParams[_loc6_] = this._numPlayersMC["p" + (_loc5_ - 1)];
                     AvatarXtCommManager.requestAvatarGetBySfsId(_loc6_,this.onAvatarGetReceived);
                     continue;
                  }
                  this.setupAvatar(this._numPlayersMC["p" + (_loc5_ - 1)],_loc7_,_loc8_.currPet);
               }
               else
               {
                  this._numPlayersMC["p" + (_loc5_ - 1)].char.gotoAndPlay("waiting");
                  LocalizationManager.translateId(this._numPlayersMC["p" + (_loc5_ - 1)].char.nameBar.firstName_txt,11101);
                  this._numPlayersMC["p" + (_loc5_ - 1)].char.nameBar.lastName_txt.text = "";
               }
               this._numPlayersMC["p" + (_loc5_ - 1)].char.nameBar.visible = false;
            }
         }
         else
         {
            this._inParamsWaiting = param1;
         }
      }
      
      private function setupAvatar(param1:MovieClip, param2:Avatar, param3:Object) : void
      {
         var _loc4_:GuiPet = null;
         var _loc5_:AvatarView = null;
         var _loc6_:Point = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         if(this._scriptDef.playAsPet)
         {
            _loc4_ = new GuiPet(0,param3.lBits,param3.uBits,param3.eBits,param3.type,param3.name,this.onBigPetLoaded);
            param1.char.charLayer.addChild(_loc4_);
            param1.char.nameBar.firstName_txt.text = _loc4_.petName;
         }
         else
         {
            _loc5_ = new AvatarView();
            _loc5_.init(param2);
            _loc5_.playAnim(LayerAnim.AN_HUD_AVT);
            _loc5_.scaleX = 0.7;
            _loc5_.scaleY = 0.7;
            _loc6_ = AvatarUtility.getAvatarMinigameLobbyOffset(_loc5_.avTypeId);
            _loc5_.x = _loc6_.x;
            _loc5_.y = _loc6_.y + 5;
            param1.char.charLayer.addChild(_loc5_);
            _loc7_ = param2.avName;
            _loc8_ = _loc7_.indexOf(" ");
            if(_loc8_ != -1)
            {
               _loc9_ = _loc7_.substr(0,_loc8_);
               _loc10_ = _loc7_.substr(_loc8_ + 1,_loc7_.length);
            }
            else
            {
               _loc9_ = _loc7_;
            }
            param1.char.nameBar.firstName_txt.text = _loc9_;
            if(_loc10_)
            {
               param1.char.nameBar.lastName_txt.text = _loc10_;
            }
         }
         param1.char.nameBar.visible = false;
      }
      
      private function onBigPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         param2.y += 30;
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:int) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:int = 0;
         var _loc7_:Avatar = null;
         if(Boolean(this._popup) && param2)
         {
            _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
            if(!_loc5_)
            {
               throw new Error("onAvatarSFSGetReceived and avInfo is null");
            }
            _loc6_ = _loc5_.perUserAvId;
            _loc7_ = AvatarManager.getAvatarByUserName(param1);
            if(_loc7_ == null)
            {
               _loc7_ = AvatarUtility.generateNew(_loc6_,null,param1,-1,0);
            }
            this.setupAvatar(this._savedParams[param4],_loc7_,_loc5_.currPet);
            delete this._savedParams[param4];
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         var _loc2_:AvatarView = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         this._popup = MovieClip(param1.getChildAt(0));
         if(this._type == NO_LOBBY)
         {
            this._popup.gotoAndStop(NO_LOBBY);
            LocalizationManager.translateId(this._popup.contTxt,this._scriptDef.descStrId);
            this._artLoadingSpiral = new LoadingSpiral(this._popup.artWindow,this._popup.artWindow.width * 0.5,this._popup.artWindow.height * 0.5);
            this._mediaHelper = new MediaHelper();
            this._mediaHelper.init(this._scriptDef.mediaRefId,this.onArtLoaded);
         }
         else
         {
            this._popup.gotoAndStop(NORMAL_TYPE);
            switch(this._scriptDef.avatarLimit)
            {
               case 4:
                  this._numPlayersMC = this._popup.fourPlayers;
                  this._popup.sixPlayers.visible = false;
                  this._popup.eightPlayers.visible = false;
                  this._popup.twelvePlayers.visible = false;
                  break;
               case 6:
                  this._numPlayersMC = this._popup.sixPlayers;
                  this._popup.fourPlayers.visible = false;
                  this._popup.eightPlayers.visible = false;
                  this._popup.twelvePlayers.visible = false;
                  break;
               case 8:
                  this._numPlayersMC = this._popup.eightPlayers;
                  this._popup.sixPlayers.visible = false;
                  this._popup.fourPlayers.visible = false;
                  this._popup.twelvePlayers.visible = false;
                  break;
               case 12:
                  this._numPlayersMC = this._popup.twelvePlayers;
                  this._popup.sixPlayers.visible = false;
                  this._popup.fourPlayers.visible = false;
                  this._popup.eightPlayers.visible = false;
            }
            LocalizationManager.translateId(this._numPlayersMC.contTxt,this._scriptDef.descStrId);
            this._artLoadingSpiral = new LoadingSpiral(this._popup.artWindow,this._popup.artWindow.width * 0.5,this._popup.artWindow.height * 0.5);
            this._mediaHelper = new MediaHelper();
            this._mediaHelper.init(this._scriptDef.mediaRefId,this.onArtLoaded);
            if(this._type == NORMAL_TYPE || this._type == CUSTOM_WAITING_TYPE)
            {
               _loc2_ = new AvatarView();
               _loc2_.init(AvatarManager.playerAvatar);
               _loc2_.playAnim(LayerAnim.AN_HUD_AVT);
               this._numPlayersMC.p1.char.charLayer.addChild(_loc2_);
               if(this._type == CUSTOM_WAITING_TYPE)
               {
                  this._popup.playBtn.visible = false;
                  this._popup.playBg.visible = false;
               }
               _loc3_ = AvatarManager.playerAvatar.avName;
               _loc4_ = _loc3_.indexOf(" ");
               if(_loc4_ != -1)
               {
                  _loc5_ = _loc3_.substr(0,_loc4_);
                  _loc6_ = _loc3_.substr(_loc4_ + 1,_loc3_.length);
               }
               else
               {
                  _loc5_ = _loc3_;
               }
               this._numPlayersMC.p1.char.nameBar.firstName_txt.text = _loc5_;
               if(_loc6_)
               {
                  this._numPlayersMC.p1.char.nameBar.lastName_txt.text = _loc6_;
               }
               this._numPlayersMC.p1.char.nameBar.visible = false;
               _loc7_ = 2;
               while(_loc7_ < this._scriptDef.avatarLimit + 1)
               {
                  this._numPlayersMC["p" + _loc7_].char.gotoAndPlay("waiting");
                  LocalizationManager.translateId(this._numPlayersMC["p" + _loc7_].char.nameBar.firstName_txt,11101);
                  this._numPlayersMC["p" + _loc7_].char.nameBar.lastName_txt.text = "";
                  _loc7_++;
               }
            }
            else if(this._type == CUSTOM_SETTINGS_TYPE)
            {
               this._modeDropDown = new GuiDropdown(this._popup.mode.dropdown);
               this._modeDropDown.init(0,0);
            }
         }
         if(this._difficulty == 0)
         {
            this._popup.hardMode.visible = false;
         }
         LocalizationManager.translateId(this._popup.titleTxt,this._scriptDef.titleStrId);
         this.addEventListeners();
         this._popup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         this._guiLayer.addChild(this._popup);
         DarkenManager.darken(this._popup);
         if(this._inParamsWaiting != null)
         {
            this.handleWaitResponse(this._inParamsWaiting);
            this._inParamsWaiting = null;
         }
      }
      
      private function onArtLoaded(param1:MovieClip) : void
      {
         while(this._popup.artWindow.numChildren > 0)
         {
            this._popup.artWindow.removeChildAt(0);
         }
         this._popup.artWindow.addChild(param1);
         if(this._artLoadingSpiral != null)
         {
            this._artLoadingSpiral.destroy();
            this._artLoadingSpiral = null;
         }
      }
      
      private function onBuddyToggle(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.currentLabel == "on" || param1.currentTarget.currentLabel == "startingOn")
         {
            param1.currentTarget.gotoAndPlay("off");
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
         }
      }
      
      private function onDropDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         var _loc1_:int = 0;
         if(this._popup)
         {
            this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            this._popup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
            if(this._type == NO_LOBBY)
            {
               this._popup.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
            }
            else
            {
               _loc1_ = 1;
               while(_loc1_ < this._scriptDef.avatarLimit + 1)
               {
                  this._numPlayersMC["p" + _loc1_].char.addEventListener(MouseEvent.ROLL_OVER,this.onCharRollOver,false,0,true);
                  this._numPlayersMC["p" + _loc1_].char.addEventListener(MouseEvent.ROLL_OUT,this.onCharRollOut,false,0,true);
                  _loc1_++;
               }
               if(this._type == NORMAL_TYPE)
               {
                  this._popup.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
               }
               else if(this._type == CUSTOM_SETTINGS_TYPE)
               {
                  this._popup.buddiesOnly.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuddyToggle,false,0,true);
                  this._modeDropDown.currDropDown.addEventListener(MouseEvent.MOUSE_DOWN,this.onDropDown,false,0,true);
                  this._popup.inviteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onInviteBtn,false,0,true);
               }
            }
         }
      }
      
      private function removeEventListeners() : void
      {
         var _loc1_:int = 0;
         if(this._popup)
         {
            this._popup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._popup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn);
            if(this._type == NO_LOBBY)
            {
               this._popup.playBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn);
            }
            else
            {
               _loc1_ = 1;
               while(_loc1_ < this._scriptDef.avatarLimit + 1)
               {
                  this._numPlayersMC["p" + _loc1_].char.removeEventListener(MouseEvent.ROLL_OVER,this.onCharRollOver);
                  this._numPlayersMC["p" + _loc1_].char.removeEventListener(MouseEvent.ROLL_OUT,this.onCharRollOut);
                  _loc1_++;
               }
               if(this._type == NORMAL_TYPE)
               {
                  this._popup.playBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn);
               }
               else if(this._type == CUSTOM_SETTINGS_TYPE)
               {
                  this._popup.buddiesOnly.toggleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBuddyToggle);
                  this._modeDropDown.currDropDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDropDown);
                  this._popup.inviteBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onInviteBtn);
               }
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestJoinCancel();
         if(this._closeCallback != null)
         {
            this._closeCallback();
            this._closeCallback = null;
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onPlayBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         var _loc2_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         if(Boolean(_loc2_) && _loc2_.questLevel < this._scriptDef.levelMin)
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,this._scriptDef.levelMin));
            return;
         }
         if(this._type == CUSTOM_SETTINGS_TYPE)
         {
            QuestXtCommManager.sendQuestCreatePrivate(this._scriptDef.defId,this._modeDropDown.selectedIdx,false);
         }
         else if(this._type == NORMAL_TYPE)
         {
            QuestXtCommManager.sendQuestStartRequest();
         }
         else if(this._type == NO_LOBBY)
         {
            QuestXtCommManager.sendQuestCreateJoinPublic(this._scriptDef.defId,0);
         }
      }
      
      private function onInviteBtn(param1:MouseEvent) : void
      {
         this.onPlayBtn(param1);
      }
      
      private function onCharRollOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.gotoAndStop("over");
         param1.currentTarget.nameBar.visible = true;
      }
      
      private function onCharRollOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.gotoAndStop("up");
         param1.currentTarget.nameBar.visible = false;
      }
   }
}

