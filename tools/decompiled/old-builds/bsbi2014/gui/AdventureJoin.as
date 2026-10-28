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
      
      public function init(initScriptDefId:int, type:String, difficulty:int, initCloseCallback:Function) : void
      {
         this._savedParams = [];
         this._scriptDef = QuestXtCommManager.getScriptDef(initScriptDefId);
         this._type = type;
         this._difficulty = difficulty;
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = initCloseCallback;
         DarkenManager.showLoadingSpiral(true);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this.MEDIA_ID,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         SBPopupManager.closeAll();
         TradeManager.closeAllTradingRelatedPopups();
         this.removeEventListeners();
         if(Boolean(this._bigPet))
         {
            this._bigPet.destroy();
            this._bigPet = null;
         }
         this._mediaHelper.destroy();
         this._mediaHelper = null;
         if(Boolean(this._popup))
         {
            DarkenManager.unDarken(this._popup);
            this._guiLayer.removeChild(this._popup);
            this._popup = null;
         }
      }
      
      public function handleWaitResponse(params:Object) : void
      {
         var maxAllowedPlayers:int = 0;
         var minReqPlayers:int = 0;
         var c:int = 0;
         var w:int = 0;
         var wid:int = 0;
         var joinedAvatarRef:Avatar = null;
         var joinedAvatarInfo:AvatarInfo = null;
         if(Boolean(this._popup) && (this._type == NORMAL_TYPE || this._type == CUSTOM_WAITING_TYPE))
         {
            maxAllowedPlayers = int(this._scriptDef.avatarLimit);
            minReqPlayers = 1;
            for(c = 1; c < maxAllowedPlayers + 1; c++)
            {
               while(this._numPlayersMC["p" + c].char.charLayer.numChildren > 0)
               {
                  this._numPlayersMC["p" + c].char.charLayer.removeChildAt(0);
               }
               this._numPlayersMC["p" + c].char.gotoAndPlay("waiting");
               this._numPlayersMC["p" + c].char.nameBar.lastName_txt.text = "";
            }
            for(w = 2; w < maxAllowedPlayers + 2; w++)
            {
               if(w < params.length)
               {
                  wid = int(params[w]);
                  this._numPlayersMC["p" + (w - 1)].char.gotoAndPlay("up");
                  joinedAvatarRef = AvatarManager.getAvatarBySfsUserId(wid);
                  if(Boolean(joinedAvatarRef))
                  {
                     joinedAvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(joinedAvatarRef.userName);
                  }
                  if(joinedAvatarRef == null || joinedAvatarInfo == null)
                  {
                     this._savedParams[wid] = this._numPlayersMC["p" + (w - 1)];
                     AvatarXtCommManager.requestAvatarGetBySfsId(wid,this.onAvatarGetReceived);
                     continue;
                  }
                  this.setupAvatar(this._numPlayersMC["p" + (w - 1)],joinedAvatarRef,joinedAvatarInfo.currPet);
               }
               else
               {
                  this._numPlayersMC["p" + (w - 1)].char.gotoAndPlay("waiting");
                  LocalizationManager.translateId(this._numPlayersMC["p" + (w - 1)].char.nameBar.firstName_txt,11101);
                  this._numPlayersMC["p" + (w - 1)].char.nameBar.lastName_txt.text = "";
               }
               this._numPlayersMC["p" + (w - 1)].char.nameBar.visible = false;
            }
         }
         else
         {
            this._inParamsWaiting = params;
         }
      }
      
      private function setupAvatar(positionMC:MovieClip, avt:Avatar, currPet:Object) : void
      {
         var bigPet:GuiPet = null;
         var avtView:AvatarView = null;
         var offset:Point = null;
         var avName:String = null;
         var space:int = 0;
         var firstName:String = null;
         var lastName:String = null;
         if(Boolean(this._scriptDef.playAsPet))
         {
            bigPet = new GuiPet(0,currPet.lBits,currPet.uBits,currPet.eBits,currPet.type,currPet.name,this.onBigPetLoaded);
            positionMC.char.charLayer.addChild(bigPet);
            positionMC.char.nameBar.firstName_txt.text = bigPet.petName;
         }
         else
         {
            avtView = new AvatarView();
            avtView.init(avt);
            avtView.playAnim(LayerAnim.AN_HUD_AVT);
            avtView.scaleX = 0.7;
            avtView.scaleY = 0.7;
            offset = AvatarUtility.getAvatarMinigameLobbyOffset(avtView.avTypeId);
            avtView.x = offset.x;
            avtView.y = offset.y + 5;
            positionMC.char.charLayer.addChild(avtView);
            avName = avt.avName;
            space = avName.indexOf(" ");
            if(space != -1)
            {
               firstName = avName.substr(0,space);
               lastName = avName.substr(space + 1,avName.length);
            }
            else
            {
               firstName = avName;
            }
            positionMC.char.nameBar.firstName_txt.text = firstName;
            if(Boolean(lastName))
            {
               positionMC.char.nameBar.lastName_txt.text = lastName;
            }
         }
         positionMC.char.nameBar.visible = false;
      }
      
      private function onBigPetLoaded(content:MovieClip, guiPet:GuiPet) : void
      {
         guiPet.y += 30;
      }
      
      private function onAvatarGetReceived(userName:String, status:Boolean, onlineStatus:int, sfsUserId:int) : void
      {
         var avInfo:AvatarInfo = null;
         var perUserAvId:int = 0;
         var avt:Avatar = null;
         if(Boolean(this._popup))
         {
            avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
            if(!avInfo)
            {
               throw new Error("onAvatarSFSGetReceived and avInfo is null");
            }
            perUserAvId = avInfo.perUserAvId;
            avt = AvatarManager.getAvatarByUserName(userName);
            if(avt == null)
            {
               avt = AvatarUtility.generateNew(perUserAvId,null,userName,-1,0);
            }
            this.setupAvatar(this._savedParams[sfsUserId],avt,avInfo.currPet);
            delete this._savedParams[sfsUserId];
         }
      }
      
      private function onMediaLoaded(img:MovieClip) : void
      {
         var avtView:AvatarView = null;
         var avName:String = null;
         var space:int = 0;
         var firstName:String = null;
         var lastName:String = null;
         var w:int = 0;
         DarkenManager.showLoadingSpiral(false);
         this._popup = MovieClip(img.getChildAt(0));
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
               avtView = new AvatarView();
               avtView.init(AvatarManager.playerAvatar);
               avtView.playAnim(LayerAnim.AN_HUD_AVT);
               this._numPlayersMC.p1.char.charLayer.addChild(avtView);
               if(this._type == CUSTOM_WAITING_TYPE)
               {
                  this._popup.playBtn.visible = false;
                  this._popup.playBg.visible = false;
               }
               avName = AvatarManager.playerAvatar.avName;
               space = avName.indexOf(" ");
               if(space != -1)
               {
                  firstName = avName.substr(0,space);
                  lastName = avName.substr(space + 1,avName.length);
               }
               else
               {
                  firstName = avName;
               }
               this._numPlayersMC.p1.char.nameBar.firstName_txt.text = firstName;
               if(Boolean(lastName))
               {
                  this._numPlayersMC.p1.char.nameBar.lastName_txt.text = lastName;
               }
               this._numPlayersMC.p1.char.nameBar.visible = false;
               for(w = 2; w < this._scriptDef.avatarLimit + 1; w++)
               {
                  this._numPlayersMC["p" + w].char.gotoAndPlay("waiting");
                  LocalizationManager.translateId(this._numPlayersMC["p" + w].char.nameBar.firstName_txt,11101);
                  this._numPlayersMC["p" + w].char.nameBar.lastName_txt.text = "";
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
      
      private function onArtLoaded(img:MovieClip) : void
      {
         while(this._popup.artWindow.numChildren > 0)
         {
            this._popup.artWindow.removeChildAt(0);
         }
         this._popup.artWindow.addChild(img);
         if(this._artLoadingSpiral != null)
         {
            this._artLoadingSpiral.destroy();
            this._artLoadingSpiral = null;
         }
      }
      
      private function onBuddyToggle(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.currentLabel == "on" || evt.currentTarget.currentLabel == "startingOn")
         {
            evt.currentTarget.gotoAndPlay("off");
         }
         else
         {
            evt.currentTarget.gotoAndPlay("on");
         }
      }
      
      private function onDropDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         var i:int = 0;
         if(Boolean(this._popup))
         {
            this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            this._popup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
            if(this._type == NO_LOBBY)
            {
               this._popup.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
            }
            else
            {
               for(i = 1; i < this._scriptDef.avatarLimit + 1; i++)
               {
                  this._numPlayersMC["p" + i].char.addEventListener(MouseEvent.ROLL_OVER,this.onCharRollOver,false,0,true);
                  this._numPlayersMC["p" + i].char.addEventListener(MouseEvent.ROLL_OUT,this.onCharRollOut,false,0,true);
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
         var i:int = 0;
         if(Boolean(this._popup))
         {
            this._popup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._popup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn);
            if(this._type == NO_LOBBY)
            {
               this._popup.playBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn);
            }
            else
            {
               for(i = 1; i < this._scriptDef.avatarLimit + 1; i++)
               {
                  this._numPlayersMC["p" + i].char.removeEventListener(MouseEvent.ROLL_OVER,this.onCharRollOver);
                  this._numPlayersMC["p" + i].char.removeEventListener(MouseEvent.ROLL_OUT,this.onCharRollOut);
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
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onCloseBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
      
      private function onPlayBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(evt.currentTarget.isGray))
         {
            return;
         }
         var ai:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         if(Boolean(ai) && ai.questLevel < this._scriptDef.levelMin)
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
      
      private function onInviteBtn(evt:MouseEvent) : void
      {
         this.onPlayBtn(evt);
      }
      
      private function onCharRollOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.gotoAndStop("over");
         evt.currentTarget.nameBar.visible = true;
      }
      
      private function onCharRollOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.gotoAndStop("up");
         evt.currentTarget.nameBar.visible = false;
      }
   }
}

