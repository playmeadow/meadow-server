package gui
{
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.NameBar;
   import avatar.UserInfo;
   import buddy.Buddy;
   import buddy.BuddyXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.client.SFClient;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.popup.*;
   import den.DenItem;
   import den.DenXtCommManager;
   import ecard.ECard;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFormat;
   import item.SimpleIcon;
   import loader.DenItemHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetBase;
   import pet.PetManager;
   
   public class ECardInbox
   {
      
      public static var loadingSpiral:LoadingSpiral;
      
      public static var eCardIsOpen:Boolean;
      
      public static var eCardWasOpen:Boolean;
      
      public static var ffmCallback:Function;
      
      public static var initialConditionsCallback:Function;
      
      public static var nextSetCallback:Function;
      
      private const AJHQ_JAG_ID:int = 1194;
      
      private const NEWS_CREW_JAG_ID:int = 1630;
      
      private const AJHQ_JAG_ORIG_Y_POS:Number = 35.55;
      
      private var _eCardInbox:MovieClip;
      
      private var _nameBars:MovieClip;
      
      private var _onCloseCallback:Function;
      
      private var _createCard:Function;
      
      private var _currCardIdx:int;
      
      private var _currMsgId:int = -1;
      
      private var _isTabOpen:Boolean;
      
      private var _inbox:Array;
      
      private var _guiLayer:DisplayLayer;
      
      private var _giftPopup:GiftPopup;
      
      private var _clothingIcon:LayerBitmap;
      
      private var _clothingIconHelper:SimpleIcon;
      
      private var _denIconHelper:DenItemHelper;
      
      private var _mediaHelper:MediaHelper;
      
      private var _guiPet:GuiPet;
      
      private var _petBits:Array;
      
      private var _loadingSpiralAvatar:LoadingSpiral;
      
      private var _buddyRequestAvatar:Avatar;
      
      private var _buddyRequestAvatarView:AvatarView;
      
      private var _reportAPlayer:ReportAPlayer;
      
      public function ECardInbox()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Array, param3:Function, param4:Function) : void
      {
         this._guiLayer = param1;
         this._createCard = param3;
         this._onCloseCallback = param4;
         this._inbox = param2;
         this._eCardInbox = ECardManager.eCardInboxAndCreation;
         this.initialSetup();
      }
      
      public function destroy() : void
      {
         var _loc1_:ECard = null;
         var _loc2_:int = 0;
         SBTracker.pop();
         if(this._eCardInbox.currentFrameLabel != "inbox")
         {
            this._eCardInbox.gotoAndStop("inbox");
         }
         if(gMainFrame.server.isConnected)
         {
            KeepAlive.stopKATimer(this._eCardInbox);
         }
         if(this._inbox)
         {
            _loc2_ = 0;
            while(_loc2_ < this._inbox.length)
            {
               _loc1_ = this._inbox[_loc2_];
               if(Boolean(_loc1_) && _loc1_.isBuddy)
               {
                  if(_loc1_.acceptBtn)
                  {
                     _loc1_.acceptBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAcceptBtn);
                  }
                  if(_loc1_.rejectBtn)
                  {
                     _loc1_.rejectBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRejectBtn);
                  }
               }
               _loc2_++;
            }
         }
         if(this._giftPopup)
         {
            this._giftPopup.destroy();
         }
         if(this._buddyRequestAvatarView)
         {
            this._buddyRequestAvatarView.destroy();
            this._buddyRequestAvatarView = null;
         }
         DarkenManager.unDarken(this._eCardInbox);
         if(Boolean(this._eCardInbox) && this._eCardInbox.parent == this._guiLayer)
         {
            this._guiLayer.removeChild(this._eCardInbox);
         }
         this.removeListeners();
         this._eCardInbox = null;
      }
      
      private function initialSetup() : void
      {
         this._guiLayer.addChild(this._eCardInbox);
         this._eCardInbox.gotoAndStop("inbox");
         this._nameBars = this._eCardInbox.fromTab.nameBars;
         this._nameBars.nonmember.visible = false;
         this._nameBars.member.visible = false;
         this._eCardInbox.giftBig.visible = false;
         this._eCardInbox.report_btn.visible = false;
         loadingSpiral = new LoadingSpiral(DisplayObjectContainer(this._eCardInbox));
         this._currCardIdx = this._inbox.length - 1;
         this.drawCurrECard();
         KeepAlive.startKATimer(this._eCardInbox);
         this.addListeners();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/JaG/#inbox/open");
         this._eCardInbox.cardSlot.noMailPopup.visible = !ECardManager.isFirstTime;
         loadingSpiral.visible = ECardManager.isFirstTime;
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(this._eCardInbox);
         this._eCardInbox.visible = true;
         if(ECardManager.isFirstTime)
         {
            ECardXtCommManager.sendECardListRequest();
            ECardManager.isFirstTime = false;
         }
      }
      
      public function showHide(param1:Boolean) : void
      {
         if(param1)
         {
            this.removeListeners();
            this._eCardInbox.gotoAndStop("create");
         }
         else
         {
            this._eCardInbox.gotoAndStop("inbox");
            this._nameBars = this._eCardInbox.fromTab.nameBars;
            this._nameBars.nonmember.visible = false;
            this._nameBars.member.visible = false;
            this._eCardInbox.giftBig.visible = false;
            this.drawCurrECard();
            this.addListeners();
         }
      }
      
      public function reloadInbox(param1:Array = null) : void
      {
         if(param1)
         {
            this._inbox = param1;
            this._currCardIdx = this._inbox.length - 1;
            if(this._inbox.length == 0)
            {
               loadingSpiral.visible = false;
               this._eCardInbox.cardSlot.noMailPopup.visible = true;
            }
         }
         this.drawCurrECard();
      }
      
      public function onDeleteResponse(param1:Array, param2:Boolean) : void
      {
         var _loc3_:ECard = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(param2)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc5_ = 0;
               while(_loc5_ < this._inbox.length)
               {
                  _loc3_ = this._inbox[_loc5_];
                  if(_loc3_ != null && _loc3_.msgId == param1[_loc4_])
                  {
                     this._inbox.splice(_loc5_,1);
                     if(this._currCardIdx > this._inbox.length - 1)
                     {
                        this._currCardIdx = this._inbox.length - 1;
                     }
                     if(_loc3_.msgId == this._currMsgId)
                     {
                        if(_loc3_.isBuddy)
                        {
                           _loc3_.acceptBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAcceptBtn);
                           _loc3_.rejectBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRejectBtn);
                        }
                        else if(_loc3_.isGift)
                        {
                           this._eCardInbox.giftBig.visible = false;
                        }
                        if(this._inbox[this._currCardIdx])
                        {
                           this._currMsgId = this._inbox[this._currCardIdx].msgId;
                        }
                     }
                     break;
                  }
                  _loc5_++;
               }
               _loc4_++;
            }
            if(this._inbox.length == 0)
            {
               this._eCardInbox.cardSlot.noMailPopup.visible = true;
               this._eCardInbox.report_btn.visible = false;
            }
            this.drawCurrECard();
         }
         else
         {
            DebugUtility.debugTrace("Error on deletion");
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this._onCloseCallback();
      }
      
      public function get visibility() : Boolean
      {
         return this._eCardInbox.visible;
      }
      
      private function drawCurrECard() : void
      {
         var _loc1_:ECard = null;
         var _loc2_:TextFormat = null;
         if(this._buddyRequestAvatarView)
         {
            this._buddyRequestAvatarView.destroy();
            this._buddyRequestAvatarView = null;
         }
         if(Boolean(this._inbox) && Boolean(this._inbox[this._currCardIdx]))
         {
            _loc1_ = this._inbox[this._currCardIdx];
            this._currMsgId = _loc1_.msgId;
            this._eCardInbox.cardSlot.noMailPopup.visible = false;
            this._eCardInbox.AJIcon.visible = false;
            while(this._eCardInbox.cardSlot.cardLayer.numChildren > 1)
            {
               this._eCardInbox.cardSlot.cardLayer.removeChild(this._eCardInbox.cardSlot.cardLayer.getChildAt(1));
            }
            while(this._eCardInbox.stampSlot.stampLayer.numChildren > 1)
            {
               this._eCardInbox.stampSlot.stampLayer.removeChild(this._eCardInbox.stampSlot.stampLayer.getChildAt(1));
            }
            this._eCardInbox.cardSlot.cardLayer.addChild(_loc1_.cardImg);
            this._eCardInbox.stampSlot.stampLayer.addChild(_loc1_.stampImg);
            if(_loc1_.isGift)
            {
               this._eCardInbox.giftBig.visible = true;
            }
            else
            {
               this._eCardInbox.giftBig.visible = false;
            }
            if(_loc1_.cardMediaId == this.AJHQ_JAG_ID || _loc1_.cardMediaId == this.NEWS_CREW_JAG_ID)
            {
               if(isNaN(parseInt(_loc1_.msg)))
               {
                  this._eCardInbox.hqMsgTxt.text = _loc1_.msg;
               }
               else
               {
                  this._eCardInbox.hqMsgTxt.text = LocalizationManager.translateIdOnly(int(_loc1_.msg));
               }
               this._eCardInbox.hqMsgTxt.y = this.AJHQ_JAG_ORIG_Y_POS;
               if(this._eCardInbox.hqMsgTxt.textHeight < this._eCardInbox.hqMsgTxt.height)
               {
                  if(this._eCardInbox.hqMsgTxt.numLines == 1)
                  {
                     this._eCardInbox.hqMsgTxt.y -= (this._eCardInbox.hqMsgTxt.textHeight - this._eCardInbox.hqMsgTxt.height) * 0.5 + this._eCardInbox.hqMsgTxt.textHeight * 0.5;
                  }
                  else
                  {
                     this._eCardInbox.hqMsgTxt.y -= (this._eCardInbox.hqMsgTxt.textHeight - this._eCardInbox.hqMsgTxt.height) * 0.5;
                  }
               }
               this._eCardInbox.msgTxt.text = "";
               this._eCardInbox.report_btn.visible = false;
            }
            else
            {
               _loc2_ = this._eCardInbox.msgTxt.getTextFormat();
               _loc2_.size = 50;
               this._eCardInbox.msgTxt.setTextFormat(_loc2_);
               this._eCardInbox.msgTxt.text = _loc1_.msg;
               if(_loc1_.msg != "" && !SafeChatManager.containsInTreeArray(_loc1_.msg,SafeChatManager.TREE_ECARDTEXT))
               {
                  this._eCardInbox.report_btn.visible = true;
               }
               else
               {
                  this._eCardInbox.report_btn.visible = false;
               }
               if(this._eCardInbox.msgTxt.textHeight / Number(this._eCardInbox.msgTxt.getTextFormat().size) > 1 || this._eCardInbox.msgTxt.textHeight / Number(50) > 1)
               {
                  _loc2_.size = 30;
                  this._eCardInbox.msgTxt.setTextFormat(_loc2_);
                  if(this._eCardInbox.msgTxt.textHeight / Number(this._eCardInbox.msgTxt.getTextFormat().size) < 1)
                  {
                     this._eCardInbox.msgTxt.y = 140;
                  }
                  else
                  {
                     this._eCardInbox.msgTxt.y = 126;
                  }
               }
               else
               {
                  _loc2_.size = 50;
                  this._eCardInbox.msgTxt.setTextFormat(_loc2_);
                  this._eCardInbox.msgTxt.y = 129;
               }
               this._eCardInbox.hqMsgTxt.text = "";
            }
            if(_loc1_.isSenderMember)
            {
               this._nameBars.member.visible = true;
               this._nameBars.nonmember.visible = false;
               if(_loc1_.isFromVoice)
               {
                  this._nameBars.nonmember.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
                  this._nameBars.nonmember.nubData = AvatarManager.playerAvatarWorldView.nubData;
                  this._nameBars.member.setNubType(NameBar.GUIDE,false);
                  this._nameBars.member.setColorAndBadge(0);
                  this._nameBars.member.setAvName(_loc1_.senderUserName,false);
               }
               else
               {
                  this._nameBars.member.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
                  this._nameBars.member.nubData = AvatarManager.playerAvatarWorldView.nubData;
                  this._nameBars.member.setNubType(NameBar.BUDDY,false);
                  this._nameBars.member.setColorAndBadge(_loc1_.nameBarData);
                  this._nameBars.member.setAvName(_loc1_.senderModeratedUserName,false);
               }
               this._nameBars.member.isBlocked = false;
            }
            else
            {
               this._nameBars.member.visible = false;
               this._nameBars.nonmember.visible = true;
               this._nameBars.nonmember.txt.text = _loc1_.senderModeratedUserName;
            }
            this._eCardInbox.currCountTxt.text = this._inbox.length - this._currCardIdx;
            this._eCardInbox.slashTxt.text = "/";
            this._eCardInbox.totalCountTxt.text = this._inbox.length;
            this._eCardInbox.fromTab.visible = true;
            this._eCardInbox.replyBtn.visible = true;
            this._eCardInbox.leftBtn.visible = true;
            this._eCardInbox.rightBtn.visible = true;
            this._eCardInbox.trashBtn.visible = true;
            this._eCardInbox.newBtn.activateGrayState(!Utility.canBuddy() || !Utility.canJAG());
            if(this._eCardInbox.replyBtn.hasGrayState)
            {
               this._eCardInbox.replyBtn.activateGrayState(!Utility.canBuddy() || !Utility.canJAG());
            }
            this._nameBars.mouseEnabled = true;
            this._nameBars.mouseChildren = true;
            if(this._inbox.length <= 1)
            {
               this._eCardInbox.leftBtn.activateGrayState(true);
               this._eCardInbox.rightBtn.activateGrayState(true);
            }
            else
            {
               this._eCardInbox.leftBtn.activateGrayState(false);
               this._eCardInbox.rightBtn.activateGrayState(false);
            }
            if(!_loc1_.isRead)
            {
               ECardXtCommManager.sendECardReadRequest(this._currMsgId,this.onReadResponse);
            }
            if(_loc1_.isBuddy)
            {
               if(_loc1_.acceptBtn)
               {
                  this.setupBuddyRequest(_loc1_);
               }
               else
               {
                  _loc1_.setBuddyButtonsLoadedCallback(this.onBuddyButtonsLoaded);
               }
               this._eCardInbox.hqMsgTxt.visible = false;
               this._eCardInbox.msgTxt.visible = false;
               this._eCardInbox.stampSlot.visible = false;
            }
            else
            {
               this._eCardInbox.hqMsgTxt.visible = true;
               this._eCardInbox.msgTxt.visible = true;
               this._eCardInbox.stampSlot.visible = true;
            }
            if(_loc1_.isFromVoice)
            {
               this._eCardInbox.stampSlot.visible = false;
               if(this._eCardInbox.replyBtn.hasGrayState)
               {
                  this._eCardInbox.replyBtn.activateGrayState(true);
               }
               this._nameBars.mouseEnabled = false;
               this._nameBars.mouseChildren = false;
               this._eCardInbox.AJIcon.visible = true;
            }
            else if(_loc1_.isSenderArchived)
            {
               if(this._eCardInbox.replyBtn.hasGrayState)
               {
                  this._eCardInbox.replyBtn.activateGrayState(true);
               }
            }
         }
         else if(this._eCardInbox)
         {
            while(this._eCardInbox.cardSlot.cardLayer.numChildren > 1)
            {
               this._eCardInbox.cardSlot.cardLayer.removeChild(this._eCardInbox.cardSlot.cardLayer.getChildAt(1));
            }
            while(this._eCardInbox.stampSlot.stampLayer.numChildren > 1)
            {
               this._eCardInbox.stampSlot.stampLayer.removeChild(this._eCardInbox.stampSlot.stampLayer.getChildAt(1));
            }
            this._eCardInbox.msgTxt.text = "";
            this._eCardInbox.hqMsgTxt.text = "";
            this._eCardInbox.currCountTxt.text = "";
            this._eCardInbox.slashTxt.text = "";
            this._eCardInbox.totalCountTxt.text = "";
            this._eCardInbox.fromTab.visible = false;
            this._eCardInbox.replyBtn.visible = false;
            this._eCardInbox.leftBtn.visible = false;
            this._eCardInbox.rightBtn.visible = false;
            this._eCardInbox.trashBtn.visible = false;
            this._eCardInbox.AJIcon.visible = false;
            this._eCardInbox.report_btn.visible = false;
         }
      }
      
      private function displayGiftPopup() : void
      {
         var _loc1_:ECard = null;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         _loc1_ = this._inbox[this._currCardIdx];
         if(_loc1_)
         {
            DarkenManager.showLoadingSpiral(true);
            if(_loc1_.isGift)
            {
               switch(_loc1_.type)
               {
                  case ECard.TYPE_CLOTHING:
                     this._clothingIcon = new LayerBitmap();
                     this._clothingIconHelper = new SimpleIcon();
                     this._clothingIconHelper.init(this._clothingIcon,_loc1_.giftColor,_loc1_.giftId,1,true,false,this.clothingIconReceived);
                     break;
                  case ECard.TYPE_DEN_ACC:
                  case ECard.TYPE_DEN_AUDIO:
                     _loc2_ = DenXtCommManager.getDenItemDef(_loc1_.giftId);
                     if(!_loc2_)
                     {
                        return;
                     }
                     this._denIconHelper = new DenItemHelper();
                     this._denIconHelper.init(uint(_loc1_.giftId << 16 | DenItem.getIconId(_loc2_.sortCat)),this.denIconReceived,_loc1_.giftColor);
                     break;
                  case ECard.TYPE_DEN_ROOM:
                     _loc3_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc1_.giftId);
                     this._mediaHelper = new MediaHelper();
                     this._mediaHelper.init(_loc3_.mediaId,this.onMediaIconReceived);
                     break;
                  case ECard.TYPE_PET:
                     this._petBits = PetManager.packPetBits(PetManager.createRandomPet(_loc1_.giftId));
                     this._guiPet = new GuiPet(0,this._petBits[0],this._petBits[1],this._petBits[2],PetBase.TYPE_LAND_GROUND,_loc1_.giftName,this.onPetLoaded);
               }
            }
         }
      }
      
      private function clothingIconReceived() : void
      {
         if(this._giftPopup)
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
         var _loc1_:ECard = this._inbox[this._currCardIdx];
         var _loc2_:Sprite = new Sprite();
         _loc2_.addChild(this._clothingIcon);
         _loc2_.x = -_loc2_.width * 0.5;
         _loc2_.y = -_loc2_.height * 0.5;
         this.setupGiftPopup(_loc2_);
      }
      
      private function denIconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Sprite = null;
         if(Boolean(param1) && Boolean(param1.displayObject))
         {
            _loc2_ = param1.displayObject;
            _loc3_ = MovieClip(Loader(_loc2_.getChildAt(0)).content);
            _loc4_ = 0;
            while(_loc4_ < _loc3_.currentLabels.length)
            {
               if(_loc3_.currentLabels[_loc4_].name == "icon")
               {
                  _loc3_.gotoAndStop("icon");
                  break;
               }
               _loc4_++;
            }
            _loc5_ = DenItem.WIND_MED_SIZE / Math.max(_loc2_.width,_loc2_.height);
            _loc2_.width *= _loc5_;
            _loc2_.height *= _loc5_;
            _loc6_ = new Sprite();
            _loc6_.addChild(_loc2_);
            _loc6_.x = -_loc6_.width * 0.5;
            _loc6_.y = -_loc6_.height * 0.5;
            this.setupGiftPopup(_loc6_);
         }
      }
      
      private function onMediaIconReceived(param1:MovieClip) : void
      {
         if(param1)
         {
            this.setupGiftPopup(param1);
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         this._guiPet.scaleX = 3;
         this._guiPet.scaleY = 3;
         this._guiPet.y += this._guiPet.height * 0.5;
         this.setupGiftPopup(this._guiPet);
      }
      
      private function setupGiftPopup(param1:Sprite) : void
      {
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:ECard = this._inbox[this._currCardIdx];
         this._giftPopup = new GiftPopup();
         this._giftPopup.init(this._guiLayer,param1,_loc2_.giftName,_loc2_.giftId,_loc2_.isFromVoice ? GiftPopup.POPUP_TYPE_HQ : GiftPopup.POPUP_TYPE_JAG,GiftPopup.giftTypeForECardType(_loc2_.type),this.keepGiftCallback,this.rejectGiftCallback,this.destroyGiftPopup,true,GiftPopup.buttonsTypeForECardType(_loc2_.type),_loc2_.secondaryType,null,null,this._petBits);
      }
      
      private function keepGiftCallback() : void
      {
         if(gMainFrame.userInfo.isMember)
         {
            DarkenManager.showLoadingSpiral(true);
            ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._currMsgId,true,this.onGiftAcceptDismissResponse);
         }
      }
      
      private function rejectGiftCallback() : void
      {
         DarkenManager.showLoadingSpiral(true);
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._currMsgId,false,this.onGiftAcceptDismissResponse);
      }
      
      private function destroyGiftPopup() : void
      {
         if(this._giftPopup)
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
      }
      
      private function onAcceptBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(BuddyManager.buddyCount < BuddyManager.MAX_BUDDY_COUNT)
         {
            ECardXtCommManager.sendECardBuddyRequest(this._currMsgId,true);
            if(this._currMsgId >= 0)
            {
               this.onDeleteResponse([this._inbox[this._currCardIdx].msgId],true);
            }
         }
         else
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14708));
         }
      }
      
      private function onRejectBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         ECardXtCommManager.sendECardBuddyRequest(this._currMsgId,false);
         if(this._currMsgId >= 0)
         {
            this.onDeleteResponse([this._inbox[this._currCardIdx].msgId],true);
         }
      }
      
      private function arrowBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(Boolean(param1) && param1.currentTarget.name == this._eCardInbox.leftBtn.name)
            {
               if(this._currCardIdx >= this._inbox.length - 1)
               {
                  this._currCardIdx = 0;
               }
               else
               {
                  ++this._currCardIdx;
               }
            }
            else if(this._currCardIdx <= 0)
            {
               this._currCardIdx = this._inbox.length - 1;
            }
            else
            {
               --this._currCardIdx;
            }
            this.drawCurrECard();
         }
      }
      
      private function deleteBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._inbox[this._currCardIdx].isGift)
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14718),true,this.deleteMessageConfirmCallback);
         }
         else
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14719),true,this.deleteMessageConfirmCallback);
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function deleteMessageConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            if(this._currMsgId >= 0)
            {
               DarkenManager.showLoadingSpiral(true);
               ECardXtCommManager.sendECardDeleteRequest(this._currMsgId,ECardManager.onDeleteResponse);
            }
         }
      }
      
      private function onReadResponse(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < this._inbox.length)
            {
               if(this._inbox[_loc3_])
               {
                  if(this._inbox[_loc3_].msgId == param1)
                  {
                     this._inbox[_loc3_].isRead = true;
                     --ECardManager.unreadCount;
                     break;
                  }
               }
               _loc3_++;
            }
         }
         else
         {
            DebugUtility.debugTrace("Error on reading");
         }
      }
      
      private function onGiftAcceptDismissResponse(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(this._giftPopup)
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
         if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < this._inbox.length)
            {
               if(this._inbox[_loc3_])
               {
                  if(this._inbox[_loc3_].msgId == param1)
                  {
                     this._inbox[_loc3_].type = ECard.TYPE_STANDARD;
                     if(_loc3_ == this._currCardIdx)
                     {
                        if(this._eCardInbox)
                        {
                           this._eCardInbox.giftBig.visible = false;
                        }
                     }
                     break;
                  }
               }
               _loc3_++;
            }
         }
         else
         {
            DebugUtility.debugTrace("Error with accepting/dismissing gift");
         }
      }
      
      private function newBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._eCardInbox.newBtn.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14652),73,438);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function replyBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._eCardInbox.replyBtn.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14653),788,44);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function deleteBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14654),857,447);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function newBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._eCardInbox.newBtn.isGray)
         {
            this._createCard("","",0);
            if(nextSetCallback != null)
            {
               nextSetCallback(1);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function replyBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._eCardInbox.replyBtn.isGray)
         {
            if(this._inbox[this._currCardIdx])
            {
               this._createCard(this._inbox[this._currCardIdx].senderUserName,this._inbox[this._currCardIdx].senderModeratedUserName,this._inbox[this._currCardIdx].senderSGAccountType,true);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function fromTabHandler(param1:MouseEvent = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:Buddy = null;
         var _loc4_:UserInfo = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!this._inbox[this._currCardIdx].isFromVoice)
         {
            _loc2_ = this._inbox[this._currCardIdx].senderUserName;
            if(BuddyList.listRequested)
            {
               _loc3_ = BuddyManager.getBuddyByUserName(_loc2_);
               if(_loc3_)
               {
                  BuddyCard.showBuddyCard({
                     "userName":_loc3_.userName,
                     "onlineStatus":_loc3_.onlineStatus
                  });
               }
               else
               {
                  _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(_loc2_);
                  if(!_loc4_)
                  {
                     AvatarXtCommManager.requestAvatarGet(_loc2_,this.onUserLookUpReceived,true);
                  }
                  else
                  {
                     this.onUserLookUpReceived(_loc2_,true,0);
                  }
               }
            }
            else
            {
               BuddyXtCommManager.sendBuddyListRequest(this.fromTabHandler);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function fromTabOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._inbox[this._currCardIdx].isFromVoice)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14655),700,491);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function fromTabOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onGiftBigBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.displayGiftPopup();
      }
      
      private function onReportBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._reportAPlayer)
         {
            this._reportAPlayer.destroy();
         }
         else
         {
            this._reportAPlayer = new ReportAPlayer();
            this._reportAPlayer.init(this._guiLayer,this.onReportAPlayerClose,true,this._inbox[this._currCardIdx].senderUserName,this._inbox[this._currCardIdx].senderModeratedUserName,true,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
      }
      
      private function onReportOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14633),845,380);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onReportOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onReportAPlayerClose(param1:Boolean) : void
      {
         if(this._reportAPlayer)
         {
            this._reportAPlayer.destroy();
            this._reportAPlayer = null;
         }
         if(param1)
         {
            if(this._currMsgId >= 0)
            {
               DarkenManager.showLoadingSpiral(true);
               ECardXtCommManager.sendECardDeleteRequest(this._currMsgId,ECardManager.onDeleteResponse);
            }
         }
      }
      
      private function onBuddyButtonsLoaded() : void
      {
         var _loc1_:ECard = null;
         if(this._eCardInbox)
         {
            if(Boolean(this._inbox) && Boolean(this._inbox[this._currCardIdx]))
            {
               _loc1_ = this._inbox[this._currCardIdx];
               if(_loc1_.isBuddy && Boolean(_loc1_.acceptBtn))
               {
                  this.setupBuddyRequest(_loc1_);
               }
            }
         }
      }
      
      private function setupBuddyRequest(param1:ECard) : void
      {
         param1.acceptBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAcceptBtn,false,0,true);
         param1.rejectBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRejectBtn,false,0,true);
         param1.nonMemberNameBar.mouseChildren = false;
         param1.nonMemberNameBar.mouseEnabled = false;
         param1.memberNameBar.mouseChildren = false;
         param1.memberNameBar.mouseEnabled = false;
         if(param1.isSenderMember)
         {
            param1.nonMemberNameBar.visible = false;
            param1.memberNameBar.visible = true;
            param1.nonMemberUserName.visible = false;
            param1.nonMemberNameBar.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
            param1.nonMemberNameBar.nubData = AvatarManager.playerAvatarWorldView.nubData;
            param1.memberNameBar.setNubType(NameBar.BUDDY,false);
            param1.memberNameBar.setColorAndBadge(param1.nameBarData);
            param1.memberNameBar.setAvName(param1.senderModeratedUserName,false);
            param1.memberNameBar.isBlocked = false;
         }
         else
         {
            param1.memberNameBar.visible = false;
            param1.nonMemberNameBar.visible = true;
            param1.nonMemberUserName.text = param1.senderModeratedUserName;
         }
         this._loadingSpiralAvatar = new LoadingSpiral(param1.charBox);
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1.senderUserName);
         if(!_loc2_)
         {
            AvatarXtCommManager.requestAvatarGet(param1.senderUserName,this.onAvatarGetReceived);
         }
         else
         {
            this.onAvatarGetReceived(param1.senderUserName,true,0);
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc5_:UserInfo = null;
         var _loc4_:ECard = this._inbox[this._currCardIdx];
         if(param2 && param1.toLowerCase() == _loc4_.senderUserName.toLowerCase() && _loc4_.isBuddy)
         {
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(_loc4_.senderUserName);
            if(_loc5_)
            {
               this._buddyRequestAvatar = AvatarManager.getAvatarByUserName(_loc4_.senderUserName);
               if(this._buddyRequestAvatar == null)
               {
                  this._buddyRequestAvatar = AvatarUtility.generateNew(_loc5_.currPerUserAvId,null,_loc4_.senderUserName,-1,0,this.onAvatarItemData);
               }
               this.drawMainAvatar(this._buddyRequestAvatar);
            }
         }
      }
      
      public function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && this._buddyRequestAvatar != null)
         {
            this.drawMainAvatar(this._buddyRequestAvatar);
         }
      }
      
      private function drawMainAvatar(param1:Avatar) : void
      {
         if(this._inbox[this._currCardIdx].isBuddy)
         {
            this._buddyRequestAvatarView = new AvatarView();
            this._buddyRequestAvatarView.init(param1);
            if(param1.avTypeId >= 0)
            {
               this._buddyRequestAvatarView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,this.positionAndAddBuddyRequestAvatarView);
            }
         }
      }
      
      private function positionAndAddBuddyRequestAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = BuddyCard.getAvOffsetByDefId(this._buddyRequestAvatarView.avTypeId);
         this._buddyRequestAvatarView.x = _loc3_.x;
         this._buddyRequestAvatarView.y = _loc3_.y;
         var _loc4_:ECard = this._inbox[this._currCardIdx];
         if((Boolean(_loc4_)) && Boolean(_loc4_.isBuddy) && Boolean(_loc4_.charBox))
         {
            _loc4_.charBox.addChild(this._buddyRequestAvatarView);
         }
         this._loadingSpiralAvatar.visible = false;
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc4_:ECard = null;
         var _loc5_:UserInfo = null;
         if(param2)
         {
            if(param3 != SFClient.STATUS_OFFLINE_ARCHIVED)
            {
               _loc4_ = this._inbox[this._currCardIdx];
               if(_loc4_.isSenderMember && !_loc4_.isFromVoice)
               {
                  _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(param1);
                  if(_loc5_.nameBarData != _loc4_.nameBarData)
                  {
                     _loc4_.nameBarData = _loc5_.nameBarData;
                     _loc4_.memberNameBar.setColorAndBadge(_loc4_.nameBarData);
                  }
               }
            }
            GuiManager.toolTip.resetTimerAndSetVisibility();
            BuddyCard.showBuddyCard({
               "userName":param1,
               "onlineStatus":param3
            });
         }
      }
      
      private function addListeners() : void
      {
         this._eCardInbox.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._eCardInbox.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         if(Utility.canBuddy())
         {
            this._eCardInbox.newBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.newBtnHandler,false,0,true);
            this._eCardInbox.newBtn.addEventListener(MouseEvent.MOUSE_OVER,this.newBtnOverHandler,false,0,true);
            this._eCardInbox.newBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
            this._eCardInbox.replyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.replyBtnHandler,false,0,true);
            this._eCardInbox.replyBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
            this._eCardInbox.replyBtn.addEventListener(MouseEvent.MOUSE_OVER,this.replyBtnOverHandler,false,0,true);
         }
         else
         {
            this._eCardInbox.newBtn.activateGrayState(true);
            this._eCardInbox.replyBtn.activateGrayState(true);
         }
         this._eCardInbox.trashBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.deleteBtnHandler,false,0,true);
         this._eCardInbox.trashBtn.addEventListener(MouseEvent.MOUSE_OVER,this.deleteBtnOverHandler,false,0,true);
         this._eCardInbox.trashBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._nameBars.addEventListener(MouseEvent.MOUSE_DOWN,this.fromTabHandler,false,0,true);
         this._nameBars.addEventListener(MouseEvent.MOUSE_OVER,this.fromTabOverHandler,false,0,true);
         this._nameBars.addEventListener(MouseEvent.MOUSE_OUT,this.fromTabOutHandler,false,0,true);
         this._eCardInbox.giftBig.addEventListener(MouseEvent.MOUSE_DOWN,this.onGiftBigBtn,false,0,true);
         this._eCardInbox.report_btn.addEventListener(MouseEvent.MOUSE_DOWN,this.onReportBtn,false,0,true);
         this._eCardInbox.report_btn.addEventListener(MouseEvent.MOUSE_OVER,this.onReportOver,false,0,true);
         this._eCardInbox.report_btn.addEventListener(MouseEvent.MOUSE_OUT,this.onReportOut,false,0,true);
         this._eCardInbox.leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler,false,0,true);
         this._eCardInbox.rightBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler,false,0,true);
      }
      
      private function removeListeners() : void
      {
         this._eCardInbox.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._eCardInbox.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         if(Utility.canBuddy())
         {
            this._eCardInbox.newBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.newBtnHandler);
            this._eCardInbox.newBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.newBtnOverHandler);
            this._eCardInbox.newBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
            this._eCardInbox.replyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.replyBtnHandler);
            this._eCardInbox.replyBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
            this._eCardInbox.replyBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.replyBtnOverHandler);
         }
         this._eCardInbox.trashBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.deleteBtnHandler);
         this._eCardInbox.trashBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.deleteBtnOverHandler);
         this._eCardInbox.trashBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._nameBars.removeEventListener(MouseEvent.MOUSE_DOWN,this.fromTabHandler);
         this._nameBars.removeEventListener(MouseEvent.MOUSE_OVER,this.fromTabOverHandler);
         this._nameBars.removeEventListener(MouseEvent.MOUSE_OUT,this.fromTabOutHandler);
         this._eCardInbox.giftBig.removeEventListener(MouseEvent.MOUSE_DOWN,this.onGiftBigBtn);
         this._eCardInbox.report_btn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onReportBtn);
         this._eCardInbox.report_btn.removeEventListener(MouseEvent.MOUSE_OVER,this.onReportOver);
         this._eCardInbox.report_btn.removeEventListener(MouseEvent.MOUSE_OUT,this.onReportOut);
         this._eCardInbox.leftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler);
         this._eCardInbox.rightBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler);
      }
   }
}

