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
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import ecard.ECard;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import item.SimpleIcon;
   import loader.DenItemHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class ECardInbox
   {
      
      public static const AJHQ_JAG_ID:int = 1194;
      
      public static const NEWS_CREW_JAG_ID:int = 1630;
      
      public static var eCardIsOpen:Boolean;
      
      public static var eCardWasOpen:Boolean;
      
      public static var ffmCallback:Function;
      
      public static var initialConditionsCallback:Function;
      
      public static var nextSetCallback:Function;
      
      private const AJHQ_JAG_ORIG_Y_POS:Number = 35.55;
      
      private const ECARD_INBOX_MEDIA_ID:int = 1353;
      
      private var _eCardInbox:MovieClip;
      
      private var _nameBars:MovieClip;
      
      private var _onCloseCallback:Function;
      
      private var _createCard:Function;
      
      private var _currCardIdx:int;
      
      private var _currMsgId:int = -1;
      
      private var _isTabOpen:Boolean;
      
      private var _inbox:Array;
      
      private var _toolTipPositions:Object;
      
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
      
      private var _inboxItemWindows:WindowAndScrollbarGenerator;
      
      private var _reportAPlayer:ReportAPlayer;
      
      private var _eCardLoadingSpiral:LoadingSpiral;
      
      private var _windowsLoadingSpiral:LoadingSpiral;
      
      public function ECardInbox()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Array, param3:Function, param4:Function) : void
      {
         _guiLayer = param1;
         _createCard = param3;
         _onCloseCallback = param4;
         _inbox = param2;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/JaG/#inbox/open");
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1353,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:ECard = null;
         var _loc2_:int = 0;
         SBTracker.pop();
         if(gMainFrame.server.isConnected)
         {
            KeepAlive.stopKATimer(_eCardInbox);
         }
         if(_inbox)
         {
            _loc2_ = 0;
            while(_loc2_ < _inbox.length)
            {
               _loc1_ = _inbox[_loc2_];
               if(_loc1_ && _loc1_.isBuddy)
               {
                  if(_loc1_.acceptBtn)
                  {
                     _loc1_.acceptBtn.removeEventListener("mouseDown",onAcceptBtn);
                  }
                  if(_loc1_.rejectBtn)
                  {
                     _loc1_.rejectBtn.removeEventListener("mouseDown",onRejectBtn);
                  }
               }
               _loc2_++;
            }
         }
         if(_giftPopup)
         {
            _giftPopup.destroy();
         }
         if(_buddyRequestAvatarView)
         {
            _buddyRequestAvatarView.destroy();
            _buddyRequestAvatarView = null;
         }
         AvatarManager.showAvtAndChatLayers(true);
         DarkenManager.unDarken(_eCardInbox);
         if(_eCardInbox && _eCardInbox.parent == _guiLayer)
         {
            _guiLayer.removeChild(_eCardInbox);
         }
         removeListeners();
         _eCardInbox = null;
      }
      
      public function updateUnreadCount() : void
      {
         var _loc1_:int = ECardManager.unreadCount;
         _eCardInbox.newEcardCount.visible = _loc1_ > 0;
         _eCardInbox.newEcardCount.eCardCountTxt.text = _loc1_;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _eCardInbox = param1.getChildAt(0) as MovieClip;
         _eCardInbox.x = 900 * 0.5;
         _eCardInbox.y = 550 * 0.5;
         KeepAlive.startKATimer(_eCardInbox);
         _eCardLoadingSpiral = new LoadingSpiral(_eCardInbox.eCardCont.eCardItemWindow,_eCardInbox.eCardCont.eCardItemWindow.width * 0.5,_eCardInbox.eCardCont.eCardItemWindow.height * 0.5);
         _windowsLoadingSpiral = new LoadingSpiral(_eCardInbox.inboxItemWindow,_eCardInbox.inboxItemWindow.width * 0.5,_eCardInbox.inboxItemWindow.height * 0.5);
         _nameBars = _eCardInbox.fromTab.nameBars;
         _nameBars.nonmember.visible = false;
         _nameBars.member.visible = false;
         _eCardInbox.nonMemIcon.visible = false;
         _eCardInbox.giftBig.visible = false;
         _eCardInbox.cardSlot.noMailPopup.visible = !ECardManager.isFirstTime;
         _currCardIdx = 0;
         setupInboxWindows();
         setupToolTipPositions();
         drawCurrECard();
         updateUnreadCount();
         addListeners();
         _guiLayer.addChild(_eCardInbox);
         DarkenManager.darken(_eCardInbox);
         if(ECardManager.isFirstTime)
         {
            ECardXtCommManager.sendECardListRequest();
            ECardManager.isFirstTime = false;
         }
         AvatarManager.showAvtAndChatLayers(false);
      }
      
      public function processECardList(param1:Array = null) : void
      {
         if(param1)
         {
            param1 = param1.concat();
            _inbox = param1;
            if(_currCardIdx == -1)
            {
               _currCardIdx = 0;
            }
            if(_inbox.length == 0)
            {
               _eCardLoadingSpiral.visible = false;
               _eCardInbox.cardSlot.noMailPopup.visible = true;
               _eCardInbox.countTxt.text = "0/0";
            }
            _inboxItemWindows.insertMany(_inbox,false,true,onInboxWindowsLoaded);
         }
         drawCurrECard();
      }
      
      public function processECardPush(param1:ECard) : void
      {
         _inbox.unshift(param1);
         _inboxItemWindows.insertItem(param1,false,true);
         drawCurrECard();
      }
      
      public function updateECard(param1:ECard) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _inbox.length)
         {
            if(_inbox[_loc2_].msgId == param1.msgId)
            {
               _inboxItemWindows.updateItem(_loc2_,param1);
               break;
            }
            _loc2_++;
         }
      }
      
      public function onDeleteResponse(param1:Array, param2:Boolean) : void
      {
         var _loc3_:ECard = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(param2)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               _loc4_ = 0;
               while(_loc4_ < _inbox.length)
               {
                  _loc3_ = _inbox[_loc4_];
                  if(_loc3_ != null && _loc3_.msgId == param1[_loc5_])
                  {
                     _inboxItemWindows.deleteItem(_loc4_,_inbox);
                     if(_loc3_.msgId == _currMsgId)
                     {
                        if(_loc3_.isBuddy)
                        {
                           _loc3_.acceptBtn.removeEventListener("mouseDown",onAcceptBtn);
                           _loc3_.rejectBtn.removeEventListener("mouseDown",onRejectBtn);
                        }
                        else if(_loc3_.isGift)
                        {
                           _eCardInbox.giftBig.visible = false;
                           destroyGiftPopup();
                        }
                     }
                     break;
                  }
                  _loc4_++;
               }
               _loc5_++;
            }
            if(_inbox.length == 0)
            {
               _eCardInbox.cardSlot.noMailPopup.visible = true;
               _eCardInbox.countTxt.text = "0/0";
               _currCardIdx = -1;
            }
            else if(_currCardIdx > _inbox.length - 1)
            {
               _currCardIdx = _inbox.length - 1;
            }
            if(_inbox[_currCardIdx])
            {
               _currMsgId = _inbox[_currCardIdx].msgId;
            }
            else
            {
               _currMsgId = -1;
            }
            _inboxItemWindows.callUpdateOnWindow(_currCardIdx);
            ECardManager.setInboxAfterDelete = _inbox;
            drawCurrECard();
         }
         else
         {
            DebugUtility.debugTrace("Error on deletion");
         }
      }
      
      public function onECardLoaded(param1:ECard) : void
      {
         if(param1)
         {
            if(param1.isFromVoice)
            {
               _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.visible = false;
            }
            else if(param1.msg != "" && !SafeChatManager.containsInTreeArray(param1.msg,1))
            {
               _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.visible = true;
            }
            else
            {
               _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.visible = false;
            }
            if(param1.isBuddy || param1.isEmailReset)
            {
               if(param1.isBuddy)
               {
                  if(param1.acceptBtn)
                  {
                     setupBuddyRequest(param1);
                  }
               }
               else if(param1.changeEmailBtn)
               {
                  setupChangeEmailRequest(param1);
               }
            }
            if(_inboxItemWindows)
            {
               _inboxItemWindows.findItemAndUpdate(param1);
            }
            _eCardLoadingSpiral.visible = false;
            if((_eCardInbox.eCardCont as MovieClip).hitTestPoint(gMainFrame.stage.mouseX,gMainFrame.stage.mouseY))
            {
               onECardItemWindowOverOut(null);
            }
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
         _onCloseCallback();
      }
      
      private function setupToolTipPositions() : void
      {
         var _loc1_:Point = null;
         _toolTipPositions = {};
         _loc1_ = _eCardInbox.newBtn.localToGlobal(new Point(_eCardInbox.newBtn.width * 0.5,-10));
         _toolTipPositions[_eCardInbox.newBtn] = _loc1_;
         _loc1_ = _eCardInbox.replyBtn.localToGlobal(new Point(_eCardInbox.replyBtn.width * 0.5,-10));
         _toolTipPositions[_eCardInbox.replyBtn] = _loc1_;
         _loc1_ = _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.localToGlobal(new Point(0,-10));
         _loc1_.x += _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.width * 0.5;
         _toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn] = _loc1_;
         _loc1_ = _nameBars.localToGlobal(new Point(50,-35));
         _toolTipPositions[_nameBars] = _loc1_;
         _loc1_ = _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.localToGlobal(new Point(0,-10));
         _loc1_.x += _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.width * 0.5;
         _toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn] = _loc1_;
      }
      
      private function setupInboxWindows() : void
      {
         _inboxItemWindows = new WindowAndScrollbarGenerator();
         _inboxItemWindows.init(_eCardInbox.inboxItemWindow.width,_eCardInbox.inboxItemWindow.height,5,0,1,5,0,0,0,0,ItemWindowECard,_inbox,"",0,{
            "mouseOver":windowMouseOver,
            "mouseDown":windowMouseDown,
            "mouseOut":windowMouseOut
         },{
            "currSelectedIndex":getCurrCardIndex,
            "readFunction":readCurrECard
         },onInboxWindowsLoaded,true,false,false,false,false);
         while(_eCardInbox.inboxItemWindow.numChildren > 2)
         {
            _eCardInbox.inboxItemWindow.removeChildAt(_eCardInbox.inboxItemWindow.numChildren - 1);
         }
         _eCardInbox.inboxItemWindow.addChild(_inboxItemWindows);
      }
      
      private function onInboxWindowsLoaded() : void
      {
         _windowsLoadingSpiral.visible = false;
      }
      
      private function getCurrCardIndex() : int
      {
         return _currCardIdx;
      }
      
      private function drawCurrECard() : void
      {
         var _loc1_:ECard = null;
         BuddyCard.closeBuddyCard();
         if(_buddyRequestAvatarView)
         {
            _buddyRequestAvatarView.destroy();
            _buddyRequestAvatarView = null;
         }
         if(_inbox && _inbox[_currCardIdx])
         {
            _loc1_ = _inbox[_currCardIdx];
            _currMsgId = _loc1_.msgId;
            _eCardInbox.cardSlot.noMailPopup.visible = false;
            _eCardInbox.AJIcon.visible = false;
            _eCardInbox.eCardCont.eCard_MouseOver.alpha = 0;
            while(_eCardInbox.eCardCont.eCardItemWindow.numChildren > 1)
            {
               _eCardInbox.eCardCont.eCardItemWindow.removeChildAt(_eCardInbox.eCardCont.eCardItemWindow.numChildren - 1);
            }
            _eCardLoadingSpiral.setNewParent(_eCardInbox.eCardCont.eCardItemWindow,_eCardInbox.eCardCont.eCardItemWindow.width * 0.5,_eCardInbox.eCardCont.eCardItemWindow.height * 0.5);
            _eCardLoadingSpiral.visible = true;
            _eCardInbox.eCardCont.eCardItemWindow.addChild(_loc1_.cardImg);
            if(_loc1_.isGift)
            {
               _eCardInbox.giftBig.visible = true;
            }
            else
            {
               _eCardInbox.giftBig.visible = false;
            }
            if(_loc1_.isSenderMember)
            {
               _nameBars.member.visible = true;
               _nameBars.nonmember.visible = false;
               _eCardInbox.nonMemIcon.visible = false;
               if(_loc1_.isFromVoice)
               {
                  _nameBars.nonmember.iconIds = GuiManager.getNamebarBadgeList();
                  _nameBars.member.setNubType(NameBar.GUIDE,false);
                  _nameBars.member.setColorAndBadge(0);
                  _nameBars.member.setAvName(_loc1_.senderUserName,false,null,false);
               }
               else
               {
                  _nameBars.member.iconIds = GuiManager.getNamebarBadgeList();
                  _nameBars.member.setNubType(NameBar.BUDDY,false);
                  _nameBars.member.setColorAndBadge(_loc1_.nameBarData);
                  _nameBars.member.setAvName(_loc1_.senderModeratedUserName,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),null,false);
               }
               _nameBars.member.isBlocked = false;
            }
            else
            {
               _eCardInbox.nonMemIcon.visible = true;
               _nameBars.member.visible = false;
               _nameBars.nonmember.visible = true;
               _nameBars.nonmember.txt.text = _loc1_.senderModeratedUserName;
            }
            _nameBars.mouseEnabled = true;
            _nameBars.mouseChildren = true;
            _eCardInbox.countTxt.text = _inbox.length - _currCardIdx + "/" + _inbox.length;
            _eCardInbox.fromTab.visible = true;
            _eCardInbox.replyBtn.visible = true;
            _eCardInbox.newBtn.activateGrayState(!Utility.canBuddy() || !Utility.canJAG());
            if(_eCardInbox.replyBtn.hasGrayState)
            {
               _eCardInbox.replyBtn.activateGrayState(!Utility.canBuddy() || !Utility.canJAG());
            }
            if(_loc1_.isFromVoice)
            {
               if(_eCardInbox.stampSlot)
               {
                  _eCardInbox.stampSlot.visible = false;
               }
               if(_eCardInbox.replyBtn.hasGrayState)
               {
                  _eCardInbox.replyBtn.activateGrayState(true);
               }
               _nameBars.mouseEnabled = false;
               _nameBars.mouseChildren = false;
               _eCardInbox.AJIcon.visible = true;
            }
            else if(_loc1_.isSenderArchived)
            {
               if(_eCardInbox.replyBtn.hasGrayState)
               {
                  _eCardInbox.replyBtn.activateGrayState(true);
               }
            }
         }
         else if(_eCardInbox)
         {
            while(_eCardInbox.eCardCont.eCardItemWindow.numChildren > 1)
            {
               _eCardInbox.eCardCont.eCardItemWindow.removeChildAt(_eCardInbox.eCardCont.eCardItemWindow.numChildren - 1);
            }
            _eCardLoadingSpiral.setNewParent(_eCardInbox.eCardCont.eCardItemWindow,_eCardInbox.eCardCont.eCardItemWindow.width * 0.5,_eCardInbox.eCardCont.eCardItemWindow.height * 0.5);
            _eCardInbox.countTxt.text = "0/0";
            _eCardInbox.fromTab.visible = false;
            _eCardInbox.replyBtn.visible = false;
            _eCardInbox.AJIcon.visible = false;
            _eCardInbox.eCardCont.eCard_MouseOver.alpha = 0;
            _eCardLoadingSpiral.visible = false;
         }
      }
      
      private function displayGiftPopup() : void
      {
         var _loc1_:Object = null;
         var _loc3_:Object = null;
         var _loc2_:ECard = _inbox[_currCardIdx];
         if(_loc2_)
         {
            DarkenManager.showLoadingSpiral(true);
            if(_loc2_.isGift)
            {
               switch(_loc2_.type)
               {
                  case 1:
                     _clothingIcon = new LayerBitmap();
                     _clothingIconHelper = new SimpleIcon();
                     _clothingIconHelper.init(_clothingIcon,_loc2_.giftColor,_loc2_.giftId,1,true,false,clothingIconReceived);
                     break;
                  case 3:
                  case 99:
                     _loc1_ = DenXtCommManager.getDenItemDef(_loc2_.giftId);
                     if(!_loc1_)
                     {
                        return;
                     }
                     _denIconHelper = new DenItemHelper();
                     _denIconHelper.init(uint(_loc2_.giftId << 16 | DenItem.getIconId(_loc1_.sortCat)),denIconReceived,_loc2_.giftColor);
                     break;
                  case 5:
                     _loc3_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc2_.giftId);
                     _mediaHelper = new MediaHelper();
                     _mediaHelper.init(_loc3_.mediaId,onMediaIconReceived);
                     break;
                  case 8:
                     _petBits = PetManager.packPetBits(PetManager.createRandomPet(_loc2_.giftId));
                     _guiPet = new GuiPet(0,_petBits[0],_petBits[1],_petBits[2],0,_loc2_.giftName,onPetLoaded);
               }
            }
         }
      }
      
      private function clothingIconReceived() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         var _loc1_:ECard = _inbox[_currCardIdx];
         var _loc2_:Sprite = new Sprite();
         _loc2_.addChild(_clothingIcon);
         _loc2_.x = -_loc2_.width * 0.5;
         _loc2_.y = -_loc2_.height * 0.5;
         setupGiftPopup(_loc2_);
      }
      
      private function denIconReceived(param1:DenItemHelper) : void
      {
         var _loc5_:Sprite = null;
         var _loc3_:MovieClip = null;
         var _loc6_:int = 0;
         var _loc2_:Number = NaN;
         var _loc4_:Sprite = null;
         if(param1 && param1.displayObject)
         {
            _loc5_ = param1.displayObject;
            _loc3_ = MovieClip(Loader(_loc5_.getChildAt(0)).content);
            _loc6_ = 0;
            while(_loc6_ < _loc3_.currentLabels.length)
            {
               if(_loc3_.currentLabels[_loc6_].name == "icon")
               {
                  _loc3_.gotoAndStop("icon");
                  break;
               }
               _loc6_++;
            }
            _loc2_ = 168 / Math.max(_loc5_.width,_loc5_.height);
            _loc5_.width *= _loc2_;
            _loc5_.height *= _loc2_;
            _loc4_ = new Sprite();
            _loc4_.addChild(_loc5_);
            _loc4_.x = -_loc4_.width * 0.5;
            _loc4_.y = -_loc4_.height * 0.5;
            setupGiftPopup(_loc4_);
         }
      }
      
      private function onMediaIconReceived(param1:MovieClip) : void
      {
         if(param1)
         {
            setupGiftPopup(param1);
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _guiPet.scaleX = 3;
         _guiPet.scaleY = 3;
         _guiPet.y += _guiPet.height * 0.5;
         setupGiftPopup(_guiPet);
      }
      
      private function setupGiftPopup(param1:Sprite) : void
      {
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:ECard = _inbox[_currCardIdx];
         _giftPopup = new GiftPopup();
         _giftPopup.init(_guiLayer,param1,_loc2_.giftName,_loc2_.giftId,_loc2_.isFromVoice ? 6 : 0,GiftPopup.giftTypeForECardType(_loc2_.type),keepGiftCallback,rejectGiftCallback,destroyGiftPopup,true,GiftPopup.buttonsTypeForECardType(_loc2_.type),_loc2_.secondaryType,null,null,_petBits);
      }
      
      private function keepGiftCallback() : void
      {
         if(gMainFrame.userInfo.isMember)
         {
            DarkenManager.showLoadingSpiral(true);
            ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currMsgId,true,onGiftAcceptDismissResponse);
         }
      }
      
      private function rejectGiftCallback() : void
      {
         DarkenManager.showLoadingSpiral(true);
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currMsgId,false,onGiftAcceptDismissResponse);
      }
      
      private function destroyGiftPopup() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
      }
      
      private function onAcceptBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(BuddyManager.buddyCount < 100)
         {
            ECardXtCommManager.sendECardBuddyRequest(_currMsgId,true);
            if(_currMsgId >= 0)
            {
               onDeleteResponse([_inbox[_currCardIdx].msgId],true);
            }
         }
         else
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14708));
         }
      }
      
      private function onRejectBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         ECardXtCommManager.sendECardBuddyRequest(_currMsgId,false);
         if(_currMsgId >= 0)
         {
            onDeleteResponse([_inbox[_currCardIdx].msgId],true);
         }
      }
      
      private function onChangeEmailBtn(param1:MouseEvent) : void
      {
         var _loc3_:URLRequest = null;
         param1.stopPropagation();
         var _loc2_:String = (_inbox[_currCardIdx] as ECard).msg;
         if(_loc2_ != "" && _loc2_.indexOf("animaljam.com") != -1)
         {
            _loc3_ = new URLRequest((_inbox[_currCardIdx] as ECard).msg);
            navigateToURL(_loc3_,"_self");
         }
         onCancelEmailBtn(param1);
      }
      
      private function onCancelEmailBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         ECardXtCommManager.sendECardDeleteRequest(_currMsgId,ECardManager.onDeleteResponse);
      }
      
      private function deleteBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_inbox.length > 0)
         {
            if(_inbox[_currCardIdx].isGift)
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14718),true,deleteMessageConfirmCallback);
            }
            else
            {
               deleteMessageConfirmCallback({"status":true});
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function deleteMessageConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            if(_currMsgId >= 0)
            {
               DarkenManager.showLoadingSpiral(true);
               ECardXtCommManager.sendECardDeleteRequest(_currMsgId,ECardManager.onDeleteResponse);
            }
         }
      }
      
      private function readCurrECard() : void
      {
         var _loc1_:ECard = _inbox[_currCardIdx];
         if(!_loc1_.isRead)
         {
            ECardXtCommManager.sendECardReadRequest(_currMsgId,onReadResponse);
         }
      }
      
      private function onReadResponse(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _inbox.length)
         {
            if(_inbox[_loc3_])
            {
               if(_inbox[_loc3_].msgId == param1)
               {
                  _inbox[_loc3_].isReadInProcess = false;
                  if(param2)
                  {
                     _inbox[_loc3_].isRead = true;
                     ECardManager.unreadCount--;
                  }
                  else
                  {
                     DebugUtility.debugTrace("Error on reading");
                  }
                  break;
               }
            }
            _loc3_++;
         }
      }
      
      private function onGiftAcceptDismissResponse(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < _inbox.length)
            {
               if(_inbox[_loc3_])
               {
                  if(_inbox[_loc3_].msgId == param1)
                  {
                     _inbox[_loc3_].type = 0;
                     if(_loc3_ == _currCardIdx)
                     {
                        if(_eCardInbox)
                        {
                           _eCardInbox.giftBig.visible = false;
                        }
                        _inboxItemWindows.callUpdateOnWindow(_loc3_);
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
         if(!_eCardInbox.newBtn.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14652),_toolTipPositions[_eCardInbox.newBtn].x,_toolTipPositions[_eCardInbox.newBtn].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function replyBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_eCardInbox.replyBtn.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14653),_toolTipPositions[_eCardInbox.replyBtn].x,_toolTipPositions[_eCardInbox.replyBtn].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function deleteBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onECardItemWindowOverOut(param1);
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14654),_toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn].x,_toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn].y);
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
         if(!_eCardInbox.newBtn.isGray)
         {
            _createCard("","",0);
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
         if(!_eCardInbox.replyBtn.isGray)
         {
            if(_inbox[_currCardIdx])
            {
               _createCard(_inbox[_currCardIdx].senderUserName,_inbox[_currCardIdx].senderModeratedUserName,_inbox[_currCardIdx].senderSGAccountType,true);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function fromTabHandler(param1:MouseEvent = null) : void
      {
         var _loc2_:String = null;
         var _loc4_:Buddy = null;
         var _loc3_:UserInfo = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_inbox[_currCardIdx].isFromVoice)
         {
            _loc2_ = _inbox[_currCardIdx].senderUserName;
            if(BuddyList.listRequested)
            {
               _loc4_ = BuddyManager.getBuddyByUserName(_loc2_);
               if(_loc4_)
               {
                  BuddyCard.showBuddyCard({
                     "userName":_loc4_.userName,
                     "onlineStatus":_loc4_.onlineStatus
                  });
               }
               else
               {
                  _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(_loc2_);
                  if(!_loc3_)
                  {
                     AvatarXtCommManager.requestAvatarGet(_loc2_,onUserLookUpReceived,true);
                  }
                  else
                  {
                     onUserLookUpReceived(_loc2_,true,0);
                  }
               }
            }
            else
            {
               BuddyXtCommManager.sendBuddyListRequest(fromTabHandler);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function fromTabOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_inbox[_currCardIdx].isFromVoice)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14655),_toolTipPositions[_nameBars].x,_toolTipPositions[_nameBars].y);
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
         displayGiftPopup();
      }
      
      private function onReportBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_inbox.length > 0)
         {
            if(_reportAPlayer)
            {
               _reportAPlayer.destroy();
            }
            else
            {
               _reportAPlayer = new ReportAPlayer();
               _reportAPlayer.init(2,_guiLayer,onReportAPlayerClose,true,_inbox[_currCardIdx].senderUserName,_inbox[_currCardIdx].senderModeratedUserName,true,null,900 * 0.5,550 * 0.5);
            }
         }
      }
      
      private function onReportOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onECardItemWindowOverOut(param1);
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14633),_toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn].x,_toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn].y);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onReportOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onReportAPlayerClose(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
         if(param1)
         {
            if(_currMsgId >= 0)
            {
               DarkenManager.showLoadingSpiral(true);
               ECardXtCommManager.sendECardDeleteRequest(_currMsgId,ECardManager.onDeleteResponse);
            }
         }
      }
      
      private function windowMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function windowMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function windowMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = _currCardIdx;
         if(param1.currentTarget.index != _loc2_)
         {
            _currCardIdx = param1.currentTarget.index;
            drawCurrECard();
            _inboxItemWindows.callUpdateOnWindow(_loc2_);
            param1.currentTarget.update();
         }
      }
      
      private function onLeftRight(param1:MouseEvent) : void
      {
         var _loc2_:int = _currCardIdx;
         if(param1.currentTarget == _eCardInbox.eCardCont.eCard_MouseOver.leftBtn)
         {
            if(_currCardIdx - 1 < 0)
            {
               _currCardIdx = 0;
            }
            else
            {
               _currCardIdx = _currCardIdx - 1;
            }
         }
         else if(_currCardIdx + 1 > _inbox.length - 1)
         {
            _currCardIdx = _inbox.length - 1;
         }
         else
         {
            _currCardIdx = _currCardIdx + 1;
         }
         if(_currCardIdx != _loc2_)
         {
            _inboxItemWindows.callUpdateOnWindow(_loc2_);
            _inboxItemWindows.callUpdateOnWindow(_currCardIdx);
            _inboxItemWindows.scrollToIndex(_currCardIdx,false);
            drawCurrECard();
         }
      }
      
      private function onChangeEmailButtonsLoaded() : void
      {
         var _loc1_:ECard = null;
         if(_eCardInbox)
         {
            if(_inbox && _inbox[_currCardIdx])
            {
               _loc1_ = _inbox[_currCardIdx];
               if(_loc1_.isEmailReset && _loc1_.changeEmailBtn)
               {
                  setupChangeEmailRequest(_loc1_);
               }
            }
         }
      }
      
      private function setupChangeEmailRequest(param1:ECard) : void
      {
         param1.changeEmailBtn.addEventListener("mouseDown",onChangeEmailBtn,false,0,true);
         param1.cancelEmailBtn.addEventListener("mouseDown",onCancelEmailBtn,false,0,true);
      }
      
      private function onBuddyButtonsLoaded() : void
      {
         var _loc1_:ECard = null;
         if(_eCardInbox)
         {
            if(_inbox && _inbox[_currCardIdx])
            {
               _loc1_ = _inbox[_currCardIdx];
               if(_loc1_.isBuddy && _loc1_.acceptBtn)
               {
                  setupBuddyRequest(_loc1_);
               }
            }
         }
      }
      
      private function onECardItemWindowOverOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_eCardInbox.cardSlot.noMailPopup.visible && (param1 == null || param1.type == "mouseOver"))
         {
            _eCardInbox.eCardCont.eCard_MouseOver.alpha = 1;
         }
         else
         {
            _eCardInbox.eCardCont.eCard_MouseOver.alpha = 0;
         }
      }
      
      private function setupBuddyRequest(param1:ECard) : void
      {
         param1.acceptBtn.addEventListener("mouseDown",onAcceptBtn,false,0,true);
         param1.rejectBtn.addEventListener("mouseDown",onRejectBtn,false,0,true);
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
            param1.memberNameBar.setAvName(param1.senderModeratedUserName,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),null,false);
            param1.memberNameBar.isBlocked = false;
         }
         else
         {
            param1.memberNameBar.visible = false;
            param1.nonMemberNameBar.visible = true;
            param1.nonMemberUserName.text = param1.senderModeratedUserName;
         }
         _loadingSpiralAvatar = new LoadingSpiral(param1.charBox);
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1.senderUserName);
         if(!_loc2_)
         {
            AvatarXtCommManager.requestAvatarGet(param1.senderUserName,onAvatarGetReceived);
         }
         else
         {
            onAvatarGetReceived(param1.senderUserName,true,0);
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc4_:UserInfo = null;
         var _loc5_:ECard = _inbox[_currCardIdx];
         if(param2 && param1.toLowerCase() == _loc5_.senderUserName.toLowerCase() && _loc5_.isBuddy)
         {
            _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(_loc5_.senderUserName);
            if(_loc4_)
            {
               _buddyRequestAvatar = AvatarManager.getAvatarByUserName(_loc5_.senderUserName);
               if(_buddyRequestAvatar == null)
               {
                  _buddyRequestAvatar = AvatarUtility.generateNew(_loc4_.currPerUserAvId,null,_loc5_.senderUserName,-1,0,onAvatarItemData);
               }
               drawMainAvatar(_buddyRequestAvatar);
            }
         }
      }
      
      private function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && _buddyRequestAvatar != null)
         {
            drawMainAvatar(_buddyRequestAvatar);
         }
      }
      
      private function drawMainAvatar(param1:Avatar) : void
      {
         if(_inbox[_currCardIdx].isBuddy)
         {
            _buddyRequestAvatarView = new AvatarView();
            _buddyRequestAvatarView.init(param1);
            if(param1.avTypeId >= 0)
            {
               _buddyRequestAvatarView.playAnim(13,false,1,positionAndAddBuddyRequestAvatarView);
            }
         }
      }
      
      private function positionAndAddBuddyRequestAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc4_:Point = BuddyCard.getAvOffsetByDefId(_buddyRequestAvatarView.avTypeId);
         _buddyRequestAvatarView.x = _loc4_.x;
         _buddyRequestAvatarView.y = _loc4_.y;
         var _loc3_:ECard = _inbox[_currCardIdx];
         if(_loc3_ && _loc3_.isBuddy && _loc3_.charBox)
         {
            _loc3_.charBox.addChild(_buddyRequestAvatarView);
         }
         _loadingSpiralAvatar.visible = false;
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc5_:ECard = null;
         var _loc4_:UserInfo = null;
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(param2)
         {
            if(param3 != -1)
            {
               _loc5_ = _inbox[_currCardIdx];
               if(!(_loc5_ && _loc5_.isSenderMember && !_loc5_.isFromVoice))
               {
                  return;
               }
               _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(param1);
               if(_loc4_ != null && _loc4_.nameBarData != _loc5_.nameBarData)
               {
                  _loc5_.nameBarData = _loc4_.nameBarData;
                  _loc5_.memberNameBar.setColorAndBadge(_loc5_.nameBarData);
               }
            }
            BuddyCard.showBuddyCard({
               "userName":param1,
               "onlineStatus":param3
            });
         }
      }
      
      private function addListeners() : void
      {
         _eCardInbox.addEventListener("mouseDown",onPopup,false,0,true);
         _eCardInbox.bx.addEventListener("mouseDown",onClose,false,0,true);
         _eCardInbox.eCardCont.addEventListener("mouseOver",onECardItemWindowOverOut,false,0,true);
         _eCardInbox.eCardCont.addEventListener("mouseOut",onECardItemWindowOverOut,false,0,true);
         if(Utility.canBuddy())
         {
            _eCardInbox.newBtn.addEventListener("mouseDown",newBtnHandler,false,0,true);
            _eCardInbox.newBtn.addEventListener("mouseOver",newBtnOverHandler,false,0,true);
            _eCardInbox.newBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            _eCardInbox.replyBtn.addEventListener("mouseDown",replyBtnHandler,false,0,true);
            _eCardInbox.replyBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            _eCardInbox.replyBtn.addEventListener("mouseOver",replyBtnOverHandler,false,0,true);
         }
         else
         {
            _eCardInbox.newBtn.activateGrayState(true);
            _eCardInbox.replyBtn.activateGrayState(true);
         }
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.addEventListener("mouseDown",deleteBtnHandler,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.addEventListener("mouseOver",deleteBtnOverHandler,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.addEventListener("mouseDown",onReportBtn,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.addEventListener("mouseOver",onReportOver,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.addEventListener("mouseOut",onReportOut,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.leftBtn.addEventListener("mouseDown",onLeftRight,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.rightBtn.addEventListener("mouseDown",onLeftRight,false,0,true);
         _nameBars.addEventListener("mouseDown",fromTabHandler,false,0,true);
         _nameBars.addEventListener("mouseOver",fromTabOverHandler,false,0,true);
         _nameBars.addEventListener("mouseOut",fromTabOutHandler,false,0,true);
         _eCardInbox.giftBig.addEventListener("mouseDown",onGiftBigBtn,false,0,true);
      }
      
      private function removeListeners() : void
      {
         _eCardInbox.removeEventListener("mouseDown",onPopup);
         _eCardInbox.bx.removeEventListener("mouseDown",onClose);
         _eCardInbox.eCardCont.addEventListener("mouseOver",onECardItemWindowOverOut);
         _eCardInbox.eCardCont.addEventListener("mouseOut",onECardItemWindowOverOut);
         if(Utility.canBuddy())
         {
            _eCardInbox.newBtn.removeEventListener("mouseDown",newBtnHandler);
            _eCardInbox.newBtn.removeEventListener("mouseOver",newBtnOverHandler);
            _eCardInbox.newBtn.removeEventListener("mouseOut",btnOutHandler);
            _eCardInbox.replyBtn.removeEventListener("mouseDown",replyBtnHandler);
            _eCardInbox.replyBtn.removeEventListener("mouseOut",btnOutHandler);
            _eCardInbox.replyBtn.removeEventListener("mouseOver",replyBtnOverHandler);
         }
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.removeEventListener("mouseDown",deleteBtnHandler);
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.removeEventListener("mouseOver",deleteBtnOverHandler);
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.removeEventListener("mouseOut",btnOutHandler);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.removeEventListener("mouseDown",onReportBtn);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.removeEventListener("mouseOver",onReportOver);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.removeEventListener("mouseOut",onReportOut);
         _eCardInbox.eCardCont.eCard_MouseOver.leftBtn.addEventListener("mouseDown",onLeftRight);
         _eCardInbox.eCardCont.eCard_MouseOver.rightBtn.addEventListener("mouseDown",onLeftRight);
         _nameBars.removeEventListener("mouseOver",fromTabOverHandler);
         _nameBars.removeEventListener("mouseOut",fromTabOutHandler);
         _eCardInbox.giftBig.removeEventListener("mouseDown",onGiftBigBtn);
      }
   }
}

