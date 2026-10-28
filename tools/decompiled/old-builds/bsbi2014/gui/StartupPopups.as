package gui
{
   import achievement.Achievement;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import com.sbi.analytics.SBTracker;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.popup.SBOkPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import ecard.ECard;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Circular;
   import gskinner.motion.easing.Quadratic;
   import item.Item;
   import item.SimpleIcon;
   import loader.DenItemHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import room.RoomManagerWorld;
   
   public class StartupPopups
   {
      
      public static const GEMS_MEDIA_ID:int = 1086;
      
      public static const DIAMOND_MEDIA_ID:int = 2221;
      
      public static const DIAMOND_ANIMAL_REDEEM_ID:int = 2254;
      
      public static const JOEY_MEDIA_ID:int = 2541;
      
      private const EXPIRING_MESSAGE:int = 1953;
      
      private const PROMOTION_CODE:int = 1068;
      
      private const WELCOME_POPUP:int = 85;
      
      private const NEW_MEMBER:int = 117;
      
      private const DEMOTION_MESSAGE:int = 156;
      
      private const PLAYER_ENGAGEMENT:int = 1567;
      
      private var _loadTheseMediaItems:Array;
      
      private var _mediaViews:Array;
      
      private var _popupImages:Array;
      
      private var _popupLayer:DisplayLayer;
      
      private var _imageBeingLoaded:Boolean;
      
      private var _imageToLoad:MovieClip;
      
      private var _expiringPopup:MovieClip;
      
      private var _codePopup:MovieClip;
      
      private var _welcomePopup:MovieClip;
      
      private var _loginBonusPopup:MovieClip;
      
      private var _newMemberPopup:MovieClip;
      
      private var _demotionMessagePopup:MovieClip;
      
      private var _joeyPopup:MovieClip;
      
      private var _welcomeRoomURI:String;
      
      private var _redemptionList:Array;
      
      private var _currRedemECard:ECard;
      
      private var _clothingIcon:LayerBitmap;
      
      private var _clothingIconHelper:SimpleIcon;
      
      private var _denIconHelper:DenItemHelper;
      
      private var _avtView:AvatarView;
      
      private var _extendingMembershipJAGMsgId:int;
      
      private var _numPetsToCreate:int;
      
      private var _numPetCallbacks:int;
      
      private var _numDiamondsReceiving:int;
      
      private var _diamondECards:Array;
      
      private var _diamondRedeemPopup:MovieClip;
      
      private var _numJumpGemsReceiving:int;
      
      private var _jumpGemsECards:Array;
      
      private var _isFromDailySpin:Boolean;
      
      public function StartupPopups()
      {
         super();
      }
      
      public function init(initPopupLayer:DisplayLayer, isFromDailySpin:Boolean = false) : void
      {
         this._popupLayer = initPopupLayer;
         this._loadTheseMediaItems = new Array();
         this._mediaViews = new Array();
         this._popupImages = new Array();
         this._redemptionList = new Array();
         this._diamondECards = [];
         this._jumpGemsECards = [];
         this._imageBeingLoaded = false;
         this._isFromDailySpin = isFromDailySpin;
         RoomManagerWorld.instance.callback_InitialDataRequest = this.requestInitialData;
         if(gMainFrame.clientInfo.numRedemptionCards > 0 || !gMainFrame.userInfo.isMember && gMainFrame.clientInfo.numAJHQGiftCards > 0 || this._isFromDailySpin)
         {
            ECardXtCommManager.sendECardListRequest(this.redemptionCardsRequest);
            this._loadTheseMediaItems.push(this.PROMOTION_CODE);
         }
         else
         {
            this.setupAndLoadAllPopups();
         }
      }
      
      private function setupAndLoadAllPopups() : void
      {
         var popupsMediaHelper:MediaHelper = null;
         if(!this._isFromDailySpin)
         {
            if(Boolean(gMainFrame.userInfo.isMember && gMainFrame.clientInfo.numDaysLeftOnSubscription > 0 && gMainFrame.clientInfo.numDaysLeftOnSubscription < 6 && GuiManager.sharedObj) && (Boolean(GuiManager.sharedObj.data.expiration == null || GuiManager.sharedObj.data.expiration + 86400000 <= new Date().millisecondsUTC)) && gMainFrame.clientInfo.dbUserId % 2 == 0)
            {
               this._loadTheseMediaItems.push(this.EXPIRING_MESSAGE);
            }
            if(Boolean(gMainFrame.clientInfo.accountTypeChanged) && Boolean(gMainFrame.userInfo.isMember) || this._extendingMembershipJAGMsgId > 0)
            {
               this._loadTheseMediaItems.push(this.NEW_MEMBER);
            }
            if(!gMainFrame.userInfo.isMember && AvatarSwitch.availSlotFlags == 0)
            {
               this._loadTheseMediaItems.push(this.DEMOTION_MESSAGE);
            }
            if(GuiManager.wasInFFM)
            {
               this._loadTheseMediaItems.push(this.PLAYER_ENGAGEMENT);
            }
         }
         for(var i:int = 0; i < this._loadTheseMediaItems.length; i++)
         {
            popupsMediaHelper = new MediaHelper();
            popupsMediaHelper.init(this._loadTheseMediaItems[i],this.popupsMediaCallback,true);
            this._mediaViews[i] = popupsMediaHelper;
         }
         if(this._loadTheseMediaItems.length == 0)
         {
            DarkenManager.showLoadingSpiral(false);
            this.requestInitialData();
            this.destroy();
         }
      }
      
      private function popupsMediaCallback(img:MovieClip) : void
      {
         var i:int = 0;
         if(Boolean(img))
         {
            for(i = 0; i < this._loadTheseMediaItems.length; i++)
            {
               if(img.mediaHelper.id == this._loadTheseMediaItems[i])
               {
                  this._popupImages[i] = img;
                  break;
               }
            }
            this.loadNextPopup();
         }
      }
      
      public function requestInitialData() : void
      {
         if(Boolean(gMainFrame.clientInfo.hasOnlineBuddies) && Utility.canBuddy())
         {
            BuddyList.startBuddyListBtnGlow();
         }
         if(this._loadTheseMediaItems.length == 0)
         {
            if(Boolean(gMainFrame.userInfo.isMember) && gMainFrame.userInfo.userVarCache.getUserVarValueById(Achievement.MEMBER_NEW) == -1)
            {
               AchievementXtCommManager.requestSetUserVar(Achievement.MEMBER_NEW,1);
            }
            GuiManager.guiStartupChecks();
         }
         if(gMainFrame.clientInfo.numUnreadECards > 0)
         {
            ECardManager.unreadCount = gMainFrame.clientInfo.numUnreadECards;
         }
      }
      
      public function setWelcomeRoomName(name:String) : void
      {
         this._welcomeRoomURI = name;
      }
      
      private function destroy() : void
      {
         var i:int = 0;
         SBTracker.flush();
         if(Boolean(this._welcomeRoomURI))
         {
            SBTracker.trackPageview(this._welcomeRoomURI);
         }
         if(Boolean(this._mediaViews))
         {
            for(i = 0; i < this._mediaViews.length; i++)
            {
               this._mediaViews[i].destroy();
               this._mediaViews[i] = null;
            }
         }
         RoomManagerWorld.instance.callback_InitialDataRequest = null;
         this._expiringPopup = null;
         this._codePopup = null;
         this._welcomePopup = null;
         this._loginBonusPopup = null;
         this._newMemberPopup = null;
         this._demotionMessagePopup = null;
         this._imageBeingLoaded = false;
         this._loadTheseMediaItems = null;
         this._mediaViews = null;
         this._popupImages = null;
      }
      
      private function loadNextPopup(doStartUpChecks:Boolean = true) : void
      {
         var i:int = 0;
         if(!this._loadTheseMediaItems)
         {
            return;
         }
         if(this._loadTheseMediaItems.length > 0 && this._popupImages.length > 0 && !this._imageBeingLoaded)
         {
            i = 0;
            if(i < this._loadTheseMediaItems.length)
            {
               while(true)
               {
                  if(Boolean(this._popupImages[i]))
                  {
                     switch(this._loadTheseMediaItems[i])
                     {
                        case this.PROMOTION_CODE:
                           this._imageBeingLoaded = true;
                           this._currRedemECard = this._redemptionList[0];
                           if(Boolean(this._currRedemECard))
                           {
                              SBTracker.push();
                              SBTracker.trackPageview("/game/play/popup/promotionCode/#" + this._currRedemECard.msg,-1,SBTracker.TYPE_EVENT);
                              this.loadRedemptionImage(this._currRedemECard);
                           }
                           break;
                        case this.EXPIRING_MESSAGE:
                           this._imageBeingLoaded = true;
                           SBTracker.push();
                           SBTracker.trackPageview("/game/play/popup/expiration/" + gMainFrame.clientInfo.numDaysLeftOnSubscription);
                           this.createExpiringPopup(this._popupImages[i]);
                           break;
                        case this.WELCOME_POPUP:
                           this._imageBeingLoaded = true;
                           this.createWelcomePopup(this._popupImages[i]);
                           break;
                        case this.NEW_MEMBER:
                           this._imageBeingLoaded = true;
                           SBTracker.push();
                           SBTracker.trackPageview("/game/play/popup/newMember",-1,SBTracker.TYPE_EVENT);
                           this.createNewMemberPopup(this._popupImages[i]);
                           break;
                        case this.DEMOTION_MESSAGE:
                           this._imageBeingLoaded = true;
                           this._imageToLoad = this._popupImages[i];
                           SBTracker.push();
                           SBTracker.trackPageview("/game/play/popup/demotion/page1");
                           this.createDemotionPopup(this._imageToLoad);
                           break;
                        case this.PLAYER_ENGAGEMENT:
                           this._imageBeingLoaded = true;
                           this._imageToLoad = this._popupImages[i];
                           SBTracker.trackPageview("/game/play/popup/playerEngagement",-1,SBTracker.TYPE_EVENT);
                           this.createPlayerEngagement(this._imageToLoad);
                     }
                     if(this._imageBeingLoaded)
                     {
                        this._loadTheseMediaItems.splice(i,1);
                        this._popupImages.splice(i,1);
                        break;
                     }
                  }
                  break;
               }
            }
         }
         else if(this._loadTheseMediaItems.length == 0)
         {
            if(Boolean(gMainFrame.userInfo.isMember) && gMainFrame.userInfo.userVarCache.getUserVarValueById(Achievement.MEMBER_NEW) == -1)
            {
               AchievementXtCommManager.requestSetUserVar(Achievement.MEMBER_NEW,1);
            }
            if(doStartUpChecks)
            {
               GuiManager.guiStartupChecks();
            }
            this.destroy();
         }
      }
      
      private function redemptionCardsRequest(list:Array) : void
      {
         var currCard:ECard = null;
         for(var i:int = 0; i < list.length; i++)
         {
            currCard = list[i];
            if(currCard.isRedemptionJAG)
            {
               if(currCard.type == ECard.TYPE_SUBSCRIPTION)
               {
                  this._extendingMembershipJAGMsgId = currCard.msgId;
               }
               else if(currCard.type == ECard.TYPE_DIAMOND)
               {
                  if(currCard.giftColor != 0)
                  {
                     this._redemptionList.push(list[i]);
                  }
                  else
                  {
                     if(this._numDiamondsReceiving == 0)
                     {
                        this._redemptionList.push(list[i]);
                     }
                     else
                     {
                        this._diamondECards.push(list[i]);
                     }
                     this._numDiamondsReceiving += int(currCard.giftId);
                  }
               }
               else if(currCard.type == ECard.TYPE_GEMS)
               {
                  if(currCard.stampMediaId > 0)
                  {
                     if(currCard.stampMediaId == 1)
                     {
                        if(this._numJumpGemsReceiving == 0)
                        {
                           this._redemptionList.push(list[i]);
                        }
                        else
                        {
                           this._jumpGemsECards.push(list[i]);
                        }
                        this._numJumpGemsReceiving += int(currCard.giftId);
                     }
                  }
                  else
                  {
                     this._redemptionList.push(list[i]);
                  }
               }
               else
               {
                  this._redemptionList.push(list[i]);
               }
            }
         }
         if(this._redemptionList.length <= 0)
         {
            for(i = 0; i < this._loadTheseMediaItems.length; i++)
            {
               if(this._loadTheseMediaItems[i] == this.PROMOTION_CODE)
               {
                  this._loadTheseMediaItems.splice(i,1);
                  break;
               }
            }
         }
         this.setupAndLoadAllPopups();
      }
      
      private function createExpiringPopup(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            GuiManager.setSharedObj("expiration",new Date().millisecondsUTC);
            this._expiringPopup = MovieClip(img.getChildAt(0)).expiringMemberPopup;
            this._expiringPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.popupMouseDownHandler,false,0,true);
            this._expiringPopup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.popupCloseHandler,false,0,true);
            this._expiringPopup["renewBtn"].addEventListener(MouseEvent.MOUSE_DOWN,this.onRenew,false,0,true);
            if(gMainFrame.clientInfo.numDaysLeftOnSubscription > 1)
            {
               LocalizationManager.translateIdAndInsert(this._expiringPopup.daysTxt,11119,gMainFrame.clientInfo.numDaysLeftOnSubscription);
            }
            else
            {
               LocalizationManager.translateIdAndInsert(this._expiringPopup.daysTxt,11118,gMainFrame.clientInfo.numDaysLeftOnSubscription);
            }
            this._expiringPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._expiringPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._popupLayer.addChild(this._expiringPopup.parent.parent);
            this._expiringPopup.scaleX = this._expiringPopup.scaleY = 0.1;
            new GTween(this._expiringPopup,0.25,{
               "scaleX":1.2,
               "scaleY":1.2
            },{
               "ease":Circular.easeIn,
               "onComplete":this.onExpiringPopupTweenComplete
            });
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._expiringPopup.parent.parent);
         }
      }
      
      private function createWelcomePopup(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._welcomePopup = img;
            this._welcomePopup.getChildAt(0)["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.popupCloseHandler,false,0,true);
            this._welcomePopup.addEventListener(MouseEvent.MOUSE_DOWN,this.popupMouseDownHandler,false,0,true);
            this._welcomePopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._welcomePopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._popupLayer.addChild(this._welcomePopup);
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._welcomePopup);
         }
      }
      
      private function createNewMemberPopup(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._newMemberPopup = MovieClip(img.getChildAt(0)).newMemberPopup;
            this._newMemberPopup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.popupCloseHandler,false,0,true);
            if(this._extendingMembershipJAGMsgId > 0)
            {
               this._newMemberPopup["c"].p1.visible = false;
               this._newMemberPopup["c"].p2.visible = false;
            }
            else
            {
               this._newMemberPopup["c"].p2.visible = false;
               this._newMemberPopup["c"].p3.visible = false;
               this._newMemberPopup["c"].p1.features.addEventListener(MouseEvent.MOUSE_DOWN,this.newMemberFeaturesBtn,false,0,true);
               this._newMemberPopup["c"].p2.back.addEventListener(MouseEvent.MOUSE_DOWN,this.newMemberBackBtn,false,0,true);
            }
            this._newMemberPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.popupMouseDownHandler,false,0,true);
            this._newMemberPopup.parent.parent.x = MainFrame.VIEW_WIDTH * 0.5;
            this._newMemberPopup.parent.parent.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._popupLayer.addChild(this._newMemberPopup.parent.parent);
            this._newMemberPopup.scaleX = this._newMemberPopup.scaleY = 0.1;
            new GTween(this._newMemberPopup,0.25,{
               "scaleX":1.2,
               "scaleY":1.2
            },{
               "ease":Circular.easeIn,
               "onComplete":this.onNewMemberTweenComplete
            });
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._newMemberPopup.parent.parent);
         }
      }
      
      private function onDiamondRedeemPopupLoaded(img:MovieClip) : void
      {
         var avt:Avatar = null;
         var avtView:AvatarView = null;
         var posPoint:Point = null;
         if(Boolean(img))
         {
            DarkenManager.showLoadingSpiral(false);
            this._diamondRedeemPopup = MovieClip(img.getChildAt(0));
            this._diamondRedeemPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.popupMouseDownHandler,false,0,true);
            this._diamondRedeemPopup.saveBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSaveDiamonds,false,0,true);
            this._diamondRedeemPopup.redeemBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRedeemDiamonds,false,0,true);
            this._diamondRedeemPopup.diamondItem = DiamondXtCommManager.getDiamondItem(img.passback.diamondDef);
            this._diamondRedeemPopup.numDiamondsReceived = img.passback.numDiamondsReceived;
            avt = AvatarUtility.creationAvatars[AvatarUtility.findAvatarIndexByType(this._diamondRedeemPopup.diamondItem.refDefId)];
            avtView = new AvatarView();
            avtView.init(avt);
            avtView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
            if(Boolean(this._diamondRedeemPopup))
            {
               this._diamondRedeemPopup.avatarName = LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(this._diamondRedeemPopup.diamondItem.refDefId).titleStrRef);
               LocalizationManager.translateIdAndInsert(this._diamondRedeemPopup.txt,11385,this._diamondRedeemPopup.avatarName);
            }
            posPoint = AvatarUtility.getAnimalItemWindowOffset(this._diamondRedeemPopup.diamondItem.refDefId);
            avtView.x = posPoint.x;
            avtView.y = posPoint.y;
            this._diamondRedeemPopup.itemLayer.addChild(avtView);
            this._diamondRedeemPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._diamondRedeemPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._popupLayer.addChild(this._diamondRedeemPopup);
            DarkenManager.darken(this._diamondRedeemPopup);
         }
      }
      
      private function destroyDiamondRedeemPopup(evt:MouseEvent = null) : void
      {
         var o:Object = null;
         if(Boolean(evt))
         {
            evt.stopPropagation();
            SBOkPopup.destroyInParentChain(evt.target.parent);
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._currRedemECard.msgId,false,this.onGiftAcceptRejectResponse);
         this._diamondRedeemPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.popupMouseDownHandler);
         this._diamondRedeemPopup.saveBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSaveDiamonds);
         this._diamondRedeemPopup.redeemBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRedeemDiamonds);
         for(var i:int = 0; i < this._diamondRedeemPopup.itemLayer.numChildren; i++)
         {
            o = this._diamondRedeemPopup.itemLayer.getChildAt(0);
            if(o is AvatarView)
            {
               o.destroy(true);
               o = null;
               break;
            }
         }
         DarkenManager.unDarken(this._diamondRedeemPopup);
         this._popupLayer.removeChild(this._diamondRedeemPopup);
         this._diamondRedeemPopup = null;
         this._imageBeingLoaded = false;
         this.loadNextPopup();
      }
      
      private function onNewMemberTweenComplete(tween:GTween) : void
      {
         new GTween(this._newMemberPopup,0.3,{
            "scaleX":1,
            "scaleY":1
         },{"ease":Quadratic.easeIn});
      }
      
      private function onExpiringPopupTweenComplete(tween:GTween) : void
      {
         new GTween(this._expiringPopup,0.3,{
            "scaleX":1,
            "scaleY":1
         },{"ease":Quadratic.easeIn});
      }
      
      private function createPlayerEngagement(img:MovieClip) : void
      {
         GuiManager.initPlayerEngagement(this.loadNextPopup);
      }
      
      private function createDemotionPopup(img:MovieClip) : void
      {
         GuiManager.initDemotionMessage(this.loadNextPopup);
      }
      
      private function checkRedemptionStatus() : void
      {
         GuiManager.destroyPromotionalPopup();
         if(this._redemptionList.length > 0)
         {
            this._currRedemECard = this._redemptionList[0];
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/promotionCode/#" + this._currRedemECard.msg,-1,SBTracker.TYPE_EVENT);
            this.loadRedemptionImage(this._currRedemECard);
         }
         else
         {
            this._imageBeingLoaded = false;
            this.loadNextPopup();
         }
      }
      
      private function setupGiftPopup(img:Sprite) : void
      {
         var giftName:String = null;
         var splitMsg:Array = null;
         DarkenManager.showLoadingSpiral(false);
         var onGiftCloseMsg:String = "";
         var tempMsg:String = this._currRedemECard.msg;
         if(this._currRedemECard.type == ECard.TYPE_DEN_ROOM || this._currRedemECard.type == ECard.TYPE_AVT)
         {
            splitMsg = tempMsg.split("|");
            if(splitMsg.length == 5)
            {
               onGiftCloseMsg = LocalizationManager.translateIdAndInsertOnly(int(splitMsg[1]),LocalizationManager.translateIdOnly(int(splitMsg[2])),Utility.convertNumberToString(int(splitMsg[3])),LocalizationManager.translateIdOnly(int(splitMsg[4])));
            }
            else if(splitMsg.length == 4)
            {
               onGiftCloseMsg = LocalizationManager.translateIdAndInsertOnly(int(splitMsg[1]),LocalizationManager.translateIdOnly(int(splitMsg[2])),LocalizationManager.translateIdOnly(int(splitMsg[3])));
            }
         }
         var popupType:int = this._currRedemECard.isAJHQGift ? GiftPopup.POPUP_TYPE_HQ : GiftPopup.POPUP_TYPE_PROMO;
         if(this._currRedemECard.type == ECard.TYPE_DIAMOND)
         {
            giftName = LocalizationManager.translateIdAndInsertOnly(this._numDiamondsReceiving > 1 ? LocalizationManager.DIAMONDS_CAPITALIZED : LocalizationManager.DIAMOND_CAPITALIZED,this._numDiamondsReceiving);
         }
         else
         {
            giftName = this._currRedemECard.giftName;
         }
         GuiManager.openGiftPopup(img,giftName,this._currRedemECard.giftId,this._currRedemECard.type,this.keepGiftCallback,this.rejectGiftCallback,this.checkRedemptionStatus,GiftPopup.buttonsTypeForECardType(this._currRedemECard.type),onGiftCloseMsg,popupType,tempMsg,true);
         this._redemptionList.splice(0,1);
      }
      
      private function keepPetCallback() : void
      {
         var msgId:int = this._currRedemECard.msgId;
         if(!GuiManager.closePromoPopup())
         {
            this._redemptionList.splice(0,1);
            ++this._numPetCallbacks;
            if(this._numPetCallbacks == this._numPetsToCreate)
            {
               this.checkRedemptionStatus();
            }
         }
      }
      
      private function keepGiftCallback() : void
      {
         var i:int = 0;
         var msgId:int = this._currRedemECard.msgId;
         var type:int = this._currRedemECard.type;
         var stampMediaId:int = this._currRedemECard.stampMediaId;
         if(!GuiManager.closePromoPopup())
         {
            this.checkRedemptionStatus();
         }
         DarkenManager.showLoadingSpiral(true);
         if(type == ECard.TYPE_DIAMOND)
         {
            for(i = 0; i < this._diamondECards.length; i++)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._diamondECards[i].msgId,true,this.onGiftAcceptRejectResponse);
            }
            this._diamondECards = null;
            this._numDiamondsReceiving = 0;
         }
         else if(type == ECard.TYPE_GEMS)
         {
            if(stampMediaId > 0)
            {
               if(stampMediaId == 1)
               {
                  for(i = 0; i < this._jumpGemsECards.length; i++)
                  {
                     ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._jumpGemsECards[i].msgId,true,this.onGiftAcceptRejectResponse);
                  }
                  this._jumpGemsECards = null;
                  this._numJumpGemsReceiving = 0;
               }
            }
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(msgId,true,this.onGiftAcceptRejectResponse);
      }
      
      private function rejectGiftCallback() : void
      {
         var i:int = 0;
         var msgId:int = this._currRedemECard.msgId;
         var type:int = this._currRedemECard.type;
         var stampMediaId:int = this._currRedemECard.stampMediaId;
         if(!GuiManager.closePromoPopup())
         {
            this.checkRedemptionStatus();
         }
         DarkenManager.showLoadingSpiral(true);
         if(type == ECard.TYPE_DIAMOND)
         {
            for(i = 0; i < this._diamondECards.length; i++)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._diamondECards[i].msgId,false,this.onGiftAcceptRejectResponse);
            }
            this._diamondECards = null;
            this._numDiamondsReceiving = 0;
         }
         else if(type == ECard.TYPE_GEMS)
         {
            if(stampMediaId > 0)
            {
               if(stampMediaId == 1)
               {
                  for(i = 0; i < this._jumpGemsECards.length; i++)
                  {
                     ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._jumpGemsECards[i].msgId,false,this.onGiftAcceptRejectResponse);
                  }
                  this._jumpGemsECards = null;
                  this._numJumpGemsReceiving = 0;
               }
            }
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(msgId,false,this.onGiftAcceptRejectResponse);
      }
      
      private function onGiftAcceptRejectResponse(msgId:int, status:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         ECardManager.onDeleteResponse([msgId],true);
      }
      
      private function onExtendingMembershipResponse(msgId:int, status:Boolean) : void
      {
         ECardManager.onDeleteResponse([msgId],true);
      }
      
      private function loadRedemptionImage(currCard:ECard) : void
      {
         var def:Object = null;
         var mh:MediaHelper = null;
         var denRoomDef:Object = null;
         var mh1:MediaHelper = null;
         var avt:Avatar = null;
         if(currCard.type == ECard.TYPE_CLOTHING)
         {
            this._clothingIcon = new LayerBitmap();
            this._clothingIconHelper = new SimpleIcon();
            this._clothingIconHelper.init(this._clothingIcon,currCard.giftColor,currCard.giftId,1,true,false,this.clothingIconReceived);
         }
         else if(currCard.type == ECard.TYPE_DEN_ACC || currCard.type == ECard.TYPE_DEN_AUDIO)
         {
            def = DenXtCommManager.getDenItemDef(currCard.giftId);
            if(!def)
            {
               return;
            }
            this._denIconHelper = new DenItemHelper();
            this._denIconHelper.init(uint(currCard.giftId << 16 | DenItem.getIconId(def.sortCat)),this.denIconReceived,currCard.giftColor);
         }
         else if(currCard.type == ECard.TYPE_GEMS || currCard.type == ECard.TYPE_DIAMOND)
         {
            mh = new MediaHelper();
            if(currCard.giftColor != 0)
            {
               mh.init(DIAMOND_ANIMAL_REDEEM_ID,this.onDiamondRedeemPopupLoaded,{
                  "diamondDef":currCard.giftColor,
                  "numDiamondsReceived":currCard.giftId
               });
               this._mediaViews.push(mh);
            }
            else
            {
               mh.init(currCard.type == ECard.TYPE_GEMS ? uint(GEMS_MEDIA_ID) : uint(DIAMOND_MEDIA_ID),this.onMediaHelperIconReceived,currCard.stampMediaId);
               this._mediaViews.push(mh);
            }
         }
         else if(currCard.type == ECard.TYPE_DEN_ROOM)
         {
            denRoomDef = gMainFrame.userInfo.getDenRoomDefByDefId(currCard.giftId);
            if(!denRoomDef)
            {
               trace("Error loading image for denRoomDefId=" + currCard.giftId);
               return;
            }
            mh1 = new MediaHelper();
            mh1.init(denRoomDef.mediaId,this.onMediaHelperIconReceived);
            this._mediaViews.push(mh1);
         }
         else if(currCard.type == ECard.TYPE_AVT)
         {
            avt = AvatarManager.getDefaultAvatarByDefId(currCard.giftId);
            if(!avt)
            {
               trace("Error loading avatar using avDefId=" + currCard.giftId);
               return;
            }
            this._avtView = new AvatarView();
            this._avtView.init(avt);
            this._avtView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,this.avatarViewReceived);
         }
         else if(currCard.type == ECard.TYPE_PET)
         {
            ++this._numPetsToCreate;
            if(currCard.stampMediaId > 0)
            {
               GuiManager.openJumpPopup(true,this.onJumpPopupClose,null,currCard.giftId);
            }
            else
            {
               PetManager.openPetFinder(PetManager.petNameForDefId(currCard.giftId),this.keepPetCallback,true);
            }
         }
         else if(currCard.type == ECard.TYPE_SUBSCRIPTION)
         {
         }
      }
      
      private function avatarViewReceived(la:LayerAnim, animId:int) : void
      {
         var img:Sprite = new Sprite();
         img.addChild(this._avtView);
         var offset:Point = BuddyCard.getAvOffsetByDefId(this._avtView.avTypeId);
         this._avtView.x = offset.x;
         this._avtView.y = offset.y;
         this.setupGiftPopup(img);
      }
      
      private function clothingIconReceived() : void
      {
         var img:Sprite = new Sprite();
         img.addChild(this._clothingIcon);
         img.x = -img.width * 0.5;
         img.y = -img.height * 0.5;
         this.setupGiftPopup(img);
      }
      
      private function denIconReceived(helper:DenItemHelper) : void
      {
         var img:Sprite = null;
         var scale:Number = NaN;
         if(Boolean(helper) && Boolean(helper.displayObject))
         {
            img = new Sprite();
            scale = DenItem.WIND_MED_SIZE / Math.max(helper.displayObject.width,helper.displayObject.height);
            helper.displayObject.width *= scale;
            helper.displayObject.height *= scale;
            img.addChild(helper.displayObject);
            img.x = -img.width * 0.5;
            img.y = -img.height * 0.5;
            this.setupGiftPopup(img);
         }
      }
      
      private function onMediaHelperIconReceived(img:MovieClip) : void
      {
         if(img.passback > 0)
         {
            if(img.passback == 1)
            {
               GuiManager.openJumpPopup(false,this.onJumpPopupClose,img,this._numJumpGemsReceiving);
            }
         }
         else
         {
            this.setupGiftPopup(img);
         }
      }
      
      private function onJumpPopupClose(isJoey:Boolean, currGiftId:int, gemsImage:MovieClip = null) : void
      {
         if(isJoey)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId(currGiftId),this.keepPetCallback,true);
         }
         else
         {
            this._redemptionList.splice(0,1);
            this.keepGiftCallback();
         }
      }
      
      private function popupCloseHandler(m:MouseEvent) : void
      {
         var popup:MovieClip = null;
         if(Boolean(m))
         {
            m.stopPropagation();
         }
         if(Boolean(m.currentTarget.parent))
         {
            popup = m.currentTarget.root;
            if(this._extendingMembershipJAGMsgId > 0)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._extendingMembershipJAGMsgId,false,this.onExtendingMembershipResponse);
               this._extendingMembershipJAGMsgId = 0;
            }
            DarkenManager.unDarken(popup);
            popup.visible = false;
            popup = null;
            this._imageBeingLoaded = false;
            this.loadNextPopup();
         }
      }
      
      private function popupMouseDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
      }
      
      private function newMemberFeaturesBtn(m:MouseEvent) : void
      {
         m.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/newMemberFeatures",-1,SBTracker.TYPE_EVENT);
         m.currentTarget.parent.parent.p1.visible = false;
         m.currentTarget.parent.parent.p2.visible = true;
      }
      
      private function newMemberBackBtn(m:MouseEvent) : void
      {
         m.stopPropagation();
         SBTracker.pop();
         m.currentTarget.parent.parent.p1.visible = true;
         m.currentTarget.parent.parent.p2.visible = false;
      }
      
      private function onRenew(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/demotion/renew");
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
      
      private function onSaveDiamonds(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         new SBOkPopup(this._popupLayer,LocalizationManager.translateIdAndInsertOnly(14802,this._diamondRedeemPopup.numDiamondsReceived),true,this.destroyDiamondRedeemPopup);
      }
      
      private function onRedeemDiamonds(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         AvatarSwitch.addAvatar(AvatarSwitch.avatars.length,false,this.onAvatarAdded,false,false,this._diamondRedeemPopup.diamondItem.refDefId,true,Item.DIAMOND_CURRENCY,this._diamondRedeemPopup.diamondItem.value,GenericListXtCommManager.REDEMPTION_STORE_LIST_ID,this._diamondRedeemPopup.diamondItem.defId);
      }
      
      private function onAvatarAdded(status:int) : void
      {
         if(status == 1)
         {
            this.destroyDiamondRedeemPopup();
         }
         else if(status == -1)
         {
            new SBOkPopup(this._popupLayer,LocalizationManager.translateIdAndInsertOnly(11382,this._diamondRedeemPopup.avatarName),true,this.destroyDiamondRedeemPopup);
         }
         else
         {
            new SBOkPopup(this._popupLayer,LocalizationManager.translateIdOnly(11225),true,this.destroyDiamondRedeemPopup);
         }
      }
   }
}

