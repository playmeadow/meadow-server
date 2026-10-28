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
      
      public function init(initGuiLayer:DisplayLayer, initInbox:Array, initCreateCard:Function, initCloseCallback:Function) : void
      {
         this._guiLayer = initGuiLayer;
         this._createCard = initCreateCard;
         this._onCloseCallback = initCloseCallback;
         this._inbox = initInbox;
         this._eCardInbox = ECardManager.eCardInboxAndCreation;
         this.initialSetup();
      }
      
      public function destroy() : void
      {
         var currECard:ECard = null;
         var i:int = 0;
         SBTracker.pop();
         if(this._eCardInbox.currentFrameLabel != "inbox")
         {
            this._eCardInbox.gotoAndStop("inbox");
         }
         if(gMainFrame.server.isConnected)
         {
            KeepAlive.stopKATimer(this._eCardInbox);
         }
         if(Boolean(this._inbox))
         {
            for(i = 0; i < this._inbox.length; i++)
            {
               currECard = this._inbox[i];
               if(Boolean(currECard) && currECard.isBuddy)
               {
                  if(Boolean(currECard.acceptBtn))
                  {
                     currECard.acceptBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAcceptBtn);
                  }
                  if(Boolean(currECard.rejectBtn))
                  {
                     currECard.rejectBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRejectBtn);
                  }
               }
            }
         }
         if(Boolean(this._giftPopup))
         {
            this._giftPopup.destroy();
         }
         if(Boolean(this._buddyRequestAvatarView))
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
      
      public function showHide(hide:Boolean) : void
      {
         if(hide)
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
      
      public function reloadInbox(newCards:Array = null) : void
      {
         if(Boolean(newCards))
         {
            this._inbox = newCards;
            this._currCardIdx = this._inbox.length - 1;
            if(this._inbox.length == 0)
            {
               loadingSpiral.visible = false;
               this._eCardInbox.cardSlot.noMailPopup.visible = true;
            }
         }
         this.drawCurrECard();
      }
      
      public function onDeleteResponse(msgIds:Array, status:Boolean) : void
      {
         var tempECard:ECard = null;
         var i:int = 0;
         var j:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(status)
         {
            for(i = 0; i < msgIds.length; i++)
            {
               for(j = 0; j < this._inbox.length; j++)
               {
                  tempECard = this._inbox[j];
                  if(tempECard != null && tempECard.msgId == msgIds[i])
                  {
                     this._inbox.splice(j,1);
                     if(this._currCardIdx > this._inbox.length - 1)
                     {
                        this._currCardIdx = this._inbox.length - 1;
                     }
                     if(tempECard.msgId == this._currMsgId)
                     {
                        if(tempECard.isBuddy)
                        {
                           tempECard.acceptBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAcceptBtn);
                           tempECard.rejectBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRejectBtn);
                        }
                        else if(tempECard.isGift)
                        {
                           this._eCardInbox.giftBig.visible = false;
                        }
                        if(Boolean(this._inbox[this._currCardIdx]))
                        {
                           this._currMsgId = this._inbox[this._currCardIdx].msgId;
                        }
                     }
                     break;
                  }
               }
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
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onClose(evt:MouseEvent = null) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         this._onCloseCallback();
      }
      
      public function get visibility() : Boolean
      {
         return this._eCardInbox.visible;
      }
      
      private function drawCurrECard() : void
      {
         var currECard:ECard = null;
         var myNewFormat:TextFormat = null;
         if(Boolean(this._buddyRequestAvatarView))
         {
            this._buddyRequestAvatarView.destroy();
            this._buddyRequestAvatarView = null;
         }
         if(Boolean(this._inbox) && Boolean(this._inbox[this._currCardIdx]))
         {
            currECard = this._inbox[this._currCardIdx];
            this._currMsgId = currECard.msgId;
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
            this._eCardInbox.cardSlot.cardLayer.addChild(currECard.cardImg);
            this._eCardInbox.stampSlot.stampLayer.addChild(currECard.stampImg);
            if(currECard.isGift)
            {
               this._eCardInbox.giftBig.visible = true;
            }
            else
            {
               this._eCardInbox.giftBig.visible = false;
            }
            if(currECard.cardMediaId == this.AJHQ_JAG_ID || currECard.cardMediaId == this.NEWS_CREW_JAG_ID)
            {
               if(isNaN(parseInt(currECard.msg)))
               {
                  this._eCardInbox.hqMsgTxt.text = currECard.msg;
               }
               else
               {
                  this._eCardInbox.hqMsgTxt.text = LocalizationManager.translateIdOnly(int(currECard.msg));
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
               myNewFormat = this._eCardInbox.msgTxt.getTextFormat();
               myNewFormat.size = 50;
               this._eCardInbox.msgTxt.setTextFormat(myNewFormat);
               this._eCardInbox.msgTxt.text = currECard.msg;
               if(currECard.msg != "" && !SafeChatManager.containsInTreeArray(currECard.msg,SafeChatManager.TREE_ECARDTEXT))
               {
                  this._eCardInbox.report_btn.visible = true;
               }
               else
               {
                  this._eCardInbox.report_btn.visible = false;
               }
               if(this._eCardInbox.msgTxt.textHeight / Number(this._eCardInbox.msgTxt.getTextFormat().size) > 1 || this._eCardInbox.msgTxt.textHeight / Number(50) > 1)
               {
                  myNewFormat.size = 30;
                  this._eCardInbox.msgTxt.setTextFormat(myNewFormat);
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
                  myNewFormat.size = 50;
                  this._eCardInbox.msgTxt.setTextFormat(myNewFormat);
                  this._eCardInbox.msgTxt.y = 129;
               }
               this._eCardInbox.hqMsgTxt.text = "";
            }
            if(currECard.isSenderMember)
            {
               this._nameBars.member.visible = true;
               this._nameBars.nonmember.visible = false;
               if(currECard.isFromVoice)
               {
                  this._nameBars.nonmember.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
                  this._nameBars.nonmember.nubData = AvatarManager.playerAvatarWorldView.nubData;
                  this._nameBars.member.setNubType(NameBar.GUIDE,false);
                  this._nameBars.member.setColorAndBadge(0);
                  this._nameBars.member.setAvName(currECard.senderUserName,false);
               }
               else
               {
                  this._nameBars.member.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
                  this._nameBars.member.nubData = AvatarManager.playerAvatarWorldView.nubData;
                  this._nameBars.member.setNubType(NameBar.BUDDY,false);
                  this._nameBars.member.setColorAndBadge(currECard.nameBarData);
                  this._nameBars.member.setAvName(currECard.senderModeratedUserName,false);
               }
               this._nameBars.member.isBlocked = false;
            }
            else
            {
               this._nameBars.member.visible = false;
               this._nameBars.nonmember.visible = true;
               this._nameBars.nonmember.txt.text = currECard.senderModeratedUserName;
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
            if(Boolean(this._eCardInbox.replyBtn.hasGrayState))
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
            if(!currECard.isRead)
            {
               ECardXtCommManager.sendECardReadRequest(this._currMsgId,this.onReadResponse);
            }
            if(currECard.isBuddy)
            {
               if(Boolean(currECard.acceptBtn))
               {
                  this.setupBuddyRequest(currECard);
               }
               else
               {
                  currECard.setBuddyButtonsLoadedCallback(this.onBuddyButtonsLoaded);
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
            if(currECard.isFromVoice)
            {
               this._eCardInbox.stampSlot.visible = false;
               if(Boolean(this._eCardInbox.replyBtn.hasGrayState))
               {
                  this._eCardInbox.replyBtn.activateGrayState(true);
               }
               this._nameBars.mouseEnabled = false;
               this._nameBars.mouseChildren = false;
               this._eCardInbox.AJIcon.visible = true;
            }
            else if(currECard.isSenderArchived)
            {
               if(Boolean(this._eCardInbox.replyBtn.hasGrayState))
               {
                  this._eCardInbox.replyBtn.activateGrayState(true);
               }
            }
         }
         else if(Boolean(this._eCardInbox))
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
         var currCard:ECard = null;
         var def:Object = null;
         var denRoomDef:Object = null;
         currCard = this._inbox[this._currCardIdx];
         if(Boolean(currCard))
         {
            DarkenManager.showLoadingSpiral(true);
            if(currCard.isGift)
            {
               switch(currCard.type)
               {
                  case ECard.TYPE_CLOTHING:
                     this._clothingIcon = new LayerBitmap();
                     this._clothingIconHelper = new SimpleIcon();
                     this._clothingIconHelper.init(this._clothingIcon,currCard.giftColor,currCard.giftId,1,true,false,this.clothingIconReceived);
                     break;
                  case ECard.TYPE_DEN_ACC:
                  case ECard.TYPE_DEN_AUDIO:
                     def = DenXtCommManager.getDenItemDef(currCard.giftId);
                     if(!def)
                     {
                        return;
                     }
                     this._denIconHelper = new DenItemHelper();
                     this._denIconHelper.init(uint(currCard.giftId << 16 | DenItem.getIconId(def.sortCat)),this.denIconReceived,currCard.giftColor);
                     break;
                  case ECard.TYPE_DEN_ROOM:
                     denRoomDef = gMainFrame.userInfo.getDenRoomDefByDefId(currCard.giftId);
                     this._mediaHelper = new MediaHelper();
                     this._mediaHelper.init(denRoomDef.mediaId,this.onMediaIconReceived);
                     break;
                  case ECard.TYPE_PET:
                     this._petBits = PetFinder.packPetBits(PetFinder.createRandomPet(currCard.giftId));
                     this._guiPet = new GuiPet(0,this._petBits[0],this._petBits[1],this._petBits[2],PetBase.TYPE_LAND_GROUND,currCard.giftName,this.onPetLoaded);
               }
            }
         }
      }
      
      private function clothingIconReceived() : void
      {
         if(Boolean(this._giftPopup))
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
         var tempECard:ECard = this._inbox[this._currCardIdx];
         var img:Sprite = new Sprite();
         img.addChild(this._clothingIcon);
         img.x = -img.width * 0.5;
         img.y = -img.height * 0.5;
         this.setupGiftPopup(img);
      }
      
      private function denIconReceived(helper:DenItemHelper) : void
      {
         var displayObject:Sprite = null;
         var mc:MovieClip = null;
         var i:int = 0;
         var scale:Number = NaN;
         var img:Sprite = null;
         if(Boolean(helper) && Boolean(helper.displayObject))
         {
            displayObject = helper.displayObject;
            mc = MovieClip(Loader(displayObject.getChildAt(0)).content);
            for(i = 0; i < mc.currentLabels.length; i++)
            {
               if(mc.currentLabels[i].name == "icon")
               {
                  mc.gotoAndStop("icon");
                  break;
               }
            }
            scale = DenItem.WIND_MED_SIZE / Math.max(displayObject.width,displayObject.height);
            displayObject.width *= scale;
            displayObject.height *= scale;
            img = new Sprite();
            img.addChild(displayObject);
            img.x = -img.width * 0.5;
            img.y = -img.height * 0.5;
            this.setupGiftPopup(img);
         }
      }
      
      private function onMediaIconReceived(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this.setupGiftPopup(img);
         }
      }
      
      private function onPetLoaded(content:MovieClip, pet:GuiPet) : void
      {
         this._guiPet.scaleX = 3;
         this._guiPet.scaleY = 3;
         this._guiPet.y += this._guiPet.height * 0.5;
         this.setupGiftPopup(this._guiPet);
      }
      
      private function setupGiftPopup(img:Sprite) : void
      {
         DarkenManager.showLoadingSpiral(false);
         var tempECard:ECard = this._inbox[this._currCardIdx];
         this._giftPopup = new GiftPopup();
         this._giftPopup.init(this._guiLayer,img,tempECard.giftName,tempECard.giftId,tempECard.isFromVoice ? GiftPopup.POPUP_TYPE_HQ : GiftPopup.POPUP_TYPE_JAG,GiftPopup.giftTypeForECardType(tempECard.type),this.keepGiftCallback,this.rejectGiftCallback,this.destroyGiftPopup,true,GiftPopup.buttonsTypeForECardType(tempECard.type),tempECard.secondaryType,null,null,this._petBits);
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
         if(Boolean(this._giftPopup))
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
      }
      
      private function onAcceptBtn(e:MouseEvent) : void
      {
         e.stopPropagation();
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
      
      private function onRejectBtn(e:MouseEvent) : void
      {
         e.stopPropagation();
         ECardXtCommManager.sendECardBuddyRequest(this._currMsgId,false);
         if(this._currMsgId >= 0)
         {
            this.onDeleteResponse([this._inbox[this._currCardIdx].msgId],true);
         }
      }
      
      private function arrowBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            if(Boolean(evt) && evt.currentTarget.name == this._eCardInbox.leftBtn.name)
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
      
      private function deleteBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._inbox[this._currCardIdx].isGift))
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14718),true,this.deleteMessageConfirmCallback);
         }
         else
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14719),true,this.deleteMessageConfirmCallback);
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function deleteMessageConfirmCallback(o:Object) : void
      {
         if(Boolean(o.status))
         {
            if(this._currMsgId >= 0)
            {
               DarkenManager.showLoadingSpiral(true);
               ECardXtCommManager.sendECardDeleteRequest(this._currMsgId,ECardManager.onDeleteResponse);
            }
         }
      }
      
      private function onReadResponse(msgId:int, status:Boolean) : void
      {
         var i:int = 0;
         if(status)
         {
            for(i = 0; i < this._inbox.length; i++)
            {
               if(Boolean(this._inbox[i]))
               {
                  if(this._inbox[i].msgId == msgId)
                  {
                     this._inbox[i].isRead = true;
                     --ECardManager.unreadCount;
                     break;
                  }
               }
            }
         }
         else
         {
            DebugUtility.debugTrace("Error on reading");
         }
      }
      
      private function onGiftAcceptDismissResponse(msgId:int, status:Boolean) : void
      {
         var i:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(this._giftPopup))
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
         if(status)
         {
            for(i = 0; i < this._inbox.length; i++)
            {
               if(Boolean(this._inbox[i]))
               {
                  if(this._inbox[i].msgId == msgId)
                  {
                     this._inbox[i].type = ECard.TYPE_STANDARD;
                     if(i == this._currCardIdx)
                     {
                        if(Boolean(this._eCardInbox))
                        {
                           this._eCardInbox.giftBig.visible = false;
                        }
                     }
                     break;
                  }
               }
            }
         }
         else
         {
            DebugUtility.debugTrace("Error with accepting/dismissing gift");
         }
      }
      
      private function newBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!this._eCardInbox.newBtn.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14652),73,438);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function replyBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!this._eCardInbox.replyBtn.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14653),788,44);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function deleteBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14654),857,447);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function btnOutHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function newBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
      
      private function replyBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!this._eCardInbox.replyBtn.isGray)
         {
            if(Boolean(this._inbox[this._currCardIdx]))
            {
               this._createCard(this._inbox[this._currCardIdx].senderUserName,this._inbox[this._currCardIdx].senderModeratedUserName,this._inbox[this._currCardIdx].senderSGAccountType,true);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function fromTabHandler(evt:MouseEvent = null) : void
      {
         var userName:String = null;
         var bud:Buddy = null;
         var userInfo:UserInfo = null;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(!this._inbox[this._currCardIdx].isFromVoice)
         {
            userName = this._inbox[this._currCardIdx].senderUserName;
            if(BuddyList.listRequested)
            {
               bud = BuddyManager.getBuddyByUserName(userName);
               if(Boolean(bud))
               {
                  BuddyCard.showBuddyCard({
                     "userName":bud.userName,
                     "onlineStatus":bud.onlineStatus
                  });
               }
               else
               {
                  userInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
                  if(!userInfo)
                  {
                     AvatarXtCommManager.requestAvatarGet(userName,this.onUserLookUpReceived,true);
                  }
                  else
                  {
                     this.onUserLookUpReceived(userName,true,0);
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
      
      private function fromTabOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!this._inbox[this._currCardIdx].isFromVoice)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14655),700,491);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function fromTabOutHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onGiftBigBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.displayGiftPopup();
      }
      
      private function onReportBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._reportAPlayer))
         {
            this._reportAPlayer.destroy();
         }
         else
         {
            this._reportAPlayer = new ReportAPlayer();
            this._reportAPlayer.init(this._guiLayer,this.onReportAPlayerClose,true,this._inbox[this._currCardIdx].senderUserName,this._inbox[this._currCardIdx].senderModeratedUserName,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
      }
      
      private function onReportOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14633),845,380);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onReportOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onReportAPlayerClose(hasReported:Boolean) : void
      {
         if(Boolean(this._reportAPlayer))
         {
            this._reportAPlayer.destroy();
            this._reportAPlayer = null;
         }
         if(hasReported)
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
         var currECard:ECard = null;
         if(Boolean(this._eCardInbox))
         {
            if(Boolean(this._inbox) && Boolean(this._inbox[this._currCardIdx]))
            {
               currECard = this._inbox[this._currCardIdx];
               if(currECard.isBuddy && Boolean(currECard.acceptBtn))
               {
                  this.setupBuddyRequest(currECard);
               }
            }
         }
      }
      
      private function setupBuddyRequest(currECard:ECard) : void
      {
         currECard.acceptBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAcceptBtn,false,0,true);
         currECard.rejectBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRejectBtn,false,0,true);
         currECard.nonMemberNameBar.mouseChildren = false;
         currECard.nonMemberNameBar.mouseEnabled = false;
         currECard.memberNameBar.mouseChildren = false;
         currECard.memberNameBar.mouseEnabled = false;
         if(currECard.isSenderMember)
         {
            currECard.nonMemberNameBar.visible = false;
            currECard.memberNameBar.visible = true;
            currECard.nonMemberUserName.visible = false;
            currECard.nonMemberNameBar.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
            currECard.nonMemberNameBar.nubData = AvatarManager.playerAvatarWorldView.nubData;
            currECard.memberNameBar.setNubType(NameBar.BUDDY,false);
            currECard.memberNameBar.setColorAndBadge(currECard.nameBarData);
            currECard.memberNameBar.setAvName(currECard.senderModeratedUserName,false);
            currECard.memberNameBar.isBlocked = false;
         }
         else
         {
            currECard.memberNameBar.visible = false;
            currECard.nonMemberNameBar.visible = true;
            currECard.nonMemberUserName.text = currECard.senderModeratedUserName;
         }
         this._loadingSpiralAvatar = new LoadingSpiral(currECard.charBox);
         var ui:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(currECard.senderUserName);
         if(!ui)
         {
            AvatarXtCommManager.requestAvatarGet(currECard.senderUserName,this.onAvatarGetReceived);
         }
         else
         {
            this.onAvatarGetReceived(currECard.senderUserName,true,0);
         }
      }
      
      private function onAvatarGetReceived(userName:String, status:Boolean, onlineStatus:int) : void
      {
         var ui:UserInfo = null;
         var currECard:ECard = this._inbox[this._currCardIdx];
         if(status && userName == currECard.senderUserName && currECard.isBuddy)
         {
            ui = gMainFrame.userInfo.getUserInfoByUserName(currECard.senderUserName);
            if(Boolean(ui))
            {
               this._buddyRequestAvatar = AvatarManager.getAvatarByUserName(currECard.senderUserName);
               if(this._buddyRequestAvatar == null)
               {
                  this._buddyRequestAvatar = AvatarUtility.generateNew(ui.currPerUserAvId,null,currECard.senderUserName,-1,0,this.onAvatarItemData);
               }
               this.drawMainAvatar(this._buddyRequestAvatar);
            }
         }
      }
      
      public function onAvatarItemData() : void
      {
         if(this._buddyRequestAvatar != null)
         {
            this.drawMainAvatar(this._buddyRequestAvatar);
         }
      }
      
      private function drawMainAvatar(avt:Avatar) : void
      {
         if(Boolean(this._inbox[this._currCardIdx].isBuddy))
         {
            this._buddyRequestAvatarView = new AvatarView();
            this._buddyRequestAvatarView.init(avt);
            if(avt.avTypeId >= 0)
            {
               this._buddyRequestAvatarView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,this.positionAndAddBuddyRequestAvatarView);
            }
         }
      }
      
      private function positionAndAddBuddyRequestAvatarView(layerAnim:LayerAnim, animId:int) : void
      {
         var offset:Point = BuddyCard.getAvOffsetByDefId(this._buddyRequestAvatarView.avTypeId);
         this._buddyRequestAvatarView.x = offset.x;
         this._buddyRequestAvatarView.y = offset.y;
         var currECard:ECard = this._inbox[this._currCardIdx];
         if(Boolean(currECard) && Boolean(currECard.isBuddy) && Boolean(currECard.charBox))
         {
            currECard.charBox.addChild(this._buddyRequestAvatarView);
         }
         this._loadingSpiralAvatar.visible = false;
      }
      
      private function onUserLookUpReceived(userName:String, status:Boolean, onlineStatus:int) : void
      {
         var currECard:ECard = null;
         var ui:UserInfo = null;
         if(status)
         {
            if(onlineStatus != SFClient.STATUS_OFFLINE_ARCHIVED)
            {
               currECard = this._inbox[this._currCardIdx];
               if(currECard.isSenderMember && !currECard.isFromVoice)
               {
                  ui = gMainFrame.userInfo.getUserInfoByUserName(userName);
                  if(ui.nameBarData != currECard.nameBarData)
                  {
                     currECard.nameBarData = ui.nameBarData;
                     currECard.memberNameBar.setColorAndBadge(currECard.nameBarData);
                  }
               }
            }
            GuiManager.toolTip.resetTimerAndSetVisibility();
            BuddyCard.showBuddyCard({
               "userName":userName,
               "onlineStatus":onlineStatus
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

