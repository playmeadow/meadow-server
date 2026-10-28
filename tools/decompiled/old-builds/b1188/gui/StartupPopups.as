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
      
      private var _holidayBanner:MovieClip;
      
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
      
      public function init(param1:DisplayLayer, param2:Boolean = false) : void
      {
         this._popupLayer = param1;
         this._loadTheseMediaItems = new Array();
         this._mediaViews = new Array();
         this._popupImages = new Array();
         this._redemptionList = new Array();
         this._diamondECards = [];
         this._jumpGemsECards = [];
         this._imageBeingLoaded = false;
         this._isFromDailySpin = param2;
         RoomManagerWorld.instance.callback_InitialDataRequest = this.requestInitialData;
         if((gMainFrame.clientInfo.numRedemptionCards > 0 || !gMainFrame.userInfo.isMember && gMainFrame.clientInfo.numAJHQGiftCards > 0 || this._isFromDailySpin) && !gMainFrame.clientInfo.invisiMode)
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
         var _loc1_:MediaHelper = null;
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
            if(!gMainFrame.userInfo.isMember && AvatarSwitch.availSlotFlags == SwitchManager.ALL_SLOTS_DISABLED_FOR_DEMOTION)
            {
               this._loadTheseMediaItems.push(this.DEMOTION_MESSAGE);
            }
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._loadTheseMediaItems.length)
         {
            _loc1_ = new MediaHelper();
            _loc1_.init(this._loadTheseMediaItems[_loc2_],this.popupsMediaCallback,true);
            this._mediaViews[_loc2_] = _loc1_;
            _loc2_++;
         }
         if(this._loadTheseMediaItems.length == 0)
         {
            DarkenManager.showLoadingSpiral(false);
            this.requestInitialData();
            this.destroy();
         }
      }
      
      private function popupsMediaCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < this._loadTheseMediaItems.length)
            {
               if(param1.mediaHelper.id == this._loadTheseMediaItems[_loc2_])
               {
                  this._popupImages[_loc2_] = param1;
                  break;
               }
               _loc2_++;
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
      
      public function setWelcomeRoomName(param1:String) : void
      {
         this._welcomeRoomURI = param1;
      }
      
      private function destroy() : void
      {
         var _loc1_:int = 0;
         SBTracker.flush();
         if(this._welcomeRoomURI)
         {
            SBTracker.trackPageview(this._welcomeRoomURI);
         }
         if(this._mediaViews)
         {
            _loc1_ = 0;
            while(_loc1_ < this._mediaViews.length)
            {
               this._mediaViews[_loc1_].destroy();
               this._mediaViews[_loc1_] = null;
               _loc1_++;
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
      
      private function loadNextPopup(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         if(!this._loadTheseMediaItems)
         {
            return;
         }
         if(this._loadTheseMediaItems.length > 0 && this._popupImages.length > 0 && !this._imageBeingLoaded)
         {
            _loc2_ = 0;
            if(_loc2_ < this._loadTheseMediaItems.length)
            {
               while(true)
               {
                  if(this._popupImages[_loc2_])
                  {
                     switch(this._loadTheseMediaItems[_loc2_])
                     {
                        case this.PROMOTION_CODE:
                           this._imageBeingLoaded = true;
                           this._currRedemECard = this._redemptionList[0];
                           if(this._currRedemECard)
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
                           this.createExpiringPopup(this._popupImages[_loc2_]);
                           break;
                        case this.WELCOME_POPUP:
                           this._imageBeingLoaded = true;
                           this.createWelcomePopup(this._popupImages[_loc2_]);
                           break;
                        case this.NEW_MEMBER:
                           this._imageBeingLoaded = true;
                           SBTracker.push();
                           SBTracker.trackPageview("/game/play/popup/newMember",-1,SBTracker.TYPE_EVENT);
                           this.createNewMemberPopup(this._popupImages[_loc2_]);
                           break;
                        case this.DEMOTION_MESSAGE:
                           this._imageBeingLoaded = true;
                           this._imageToLoad = this._popupImages[_loc2_];
                           SBTracker.push();
                           SBTracker.trackPageview("/game/play/popup/demotion/page1");
                           this.createDemotionPopup(this._imageToLoad);
                           break;
                        case this.PLAYER_ENGAGEMENT:
                           this._imageBeingLoaded = true;
                           this._imageToLoad = this._popupImages[_loc2_];
                           SBTracker.trackPageview("/game/play/popup/playerEngagement",-1,SBTracker.TYPE_EVENT);
                           this.createPlayerEngagement(this._imageToLoad);
                     }
                     if(this._imageBeingLoaded)
                     {
                        this._loadTheseMediaItems.splice(_loc2_,1);
                        this._popupImages.splice(_loc2_,1);
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
            if(param1)
            {
               GuiManager.guiStartupChecks();
            }
            this.destroy();
         }
      }
      
      private function redemptionCardsRequest(param1:Array) : void
      {
         var _loc2_:ECard = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = param1[_loc3_];
            if(_loc2_.isRedemptionJAG)
            {
               if(_loc2_.type == ECard.TYPE_SUBSCRIPTION)
               {
                  this._extendingMembershipJAGMsgId = _loc2_.msgId;
               }
               else if(_loc2_.type == ECard.TYPE_DIAMOND)
               {
                  if(_loc2_.giftColor != 0)
                  {
                     this._redemptionList.push(param1[_loc3_]);
                  }
                  else
                  {
                     if(this._numDiamondsReceiving == 0)
                     {
                        this._redemptionList.push(param1[_loc3_]);
                     }
                     else
                     {
                        this._diamondECards.push(param1[_loc3_]);
                     }
                     this._numDiamondsReceiving += int(_loc2_.giftId);
                  }
               }
               else if(_loc2_.type == ECard.TYPE_GEMS)
               {
                  if(_loc2_.stampMediaId > 0)
                  {
                     if(_loc2_.stampMediaId == 1)
                     {
                        if(this._numJumpGemsReceiving == 0)
                        {
                           this._redemptionList.push(param1[_loc3_]);
                        }
                        else
                        {
                           this._jumpGemsECards.push(param1[_loc3_]);
                        }
                        this._numJumpGemsReceiving += int(_loc2_.giftId);
                     }
                  }
                  else
                  {
                     this._redemptionList.push(param1[_loc3_]);
                  }
               }
               else
               {
                  this._redemptionList.push(param1[_loc3_]);
               }
            }
            _loc3_++;
         }
         if(this._redemptionList.length <= 0)
         {
            _loc3_ = 0;
            while(_loc3_ < this._loadTheseMediaItems.length)
            {
               if(this._loadTheseMediaItems[_loc3_] == this.PROMOTION_CODE)
               {
                  this._loadTheseMediaItems.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
         this.setupAndLoadAllPopups();
      }
      
      private function createExpiringPopup(param1:MovieClip) : void
      {
         if(param1)
         {
            GuiManager.setSharedObj("expiration",new Date().millisecondsUTC);
            this._expiringPopup = MovieClip(param1.getChildAt(0)).expiringMemberPopup;
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
      
      private function createWelcomePopup(param1:MovieClip) : void
      {
         if(param1)
         {
            this._welcomePopup = param1;
            this._welcomePopup.getChildAt(0)["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.popupCloseHandler,false,0,true);
            this._welcomePopup.addEventListener(MouseEvent.MOUSE_DOWN,this.popupMouseDownHandler,false,0,true);
            this._welcomePopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._welcomePopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._popupLayer.addChild(this._welcomePopup);
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._welcomePopup);
         }
      }
      
      private function createNewMemberPopup(param1:MovieClip) : void
      {
         if(param1)
         {
            this._newMemberPopup = MovieClip(param1.getChildAt(0)).newMemberPopup;
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
      
      private function onDiamondRedeemPopupLoaded(param1:MovieClip) : void
      {
         var _loc2_:Avatar = null;
         var _loc3_:AvatarView = null;
         var _loc4_:Point = null;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            this._diamondRedeemPopup = MovieClip(param1.getChildAt(0));
            this._diamondRedeemPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.popupMouseDownHandler,false,0,true);
            this._diamondRedeemPopup.saveBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSaveDiamonds,false,0,true);
            this._diamondRedeemPopup.redeemBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRedeemDiamonds,false,0,true);
            this._diamondRedeemPopup.diamondItem = DiamondXtCommManager.getDiamondItem(param1.passback.diamondDef);
            this._diamondRedeemPopup.numDiamondsReceived = param1.passback.numDiamondsReceived;
            _loc2_ = AvatarUtility.findCreationAvatarByType(this._diamondRedeemPopup.diamondItem.refDefId,-1);
            _loc3_ = new AvatarView();
            _loc3_.init(_loc2_);
            _loc3_.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
            if(this._diamondRedeemPopup)
            {
               this._diamondRedeemPopup.avatarName = LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(this._diamondRedeemPopup.diamondItem.refDefId,false).titleStrRef);
               LocalizationManager.translateIdAndInsert(this._diamondRedeemPopup.txt,11385,this._diamondRedeemPopup.avatarName);
            }
            _loc4_ = AvatarUtility.getAnimalItemWindowOffset(this._diamondRedeemPopup.diamondItem.refDefId);
            _loc3_.x = _loc4_.x;
            _loc3_.y = _loc4_.y;
            this._diamondRedeemPopup.itemLayer.addChild(_loc3_);
            this._diamondRedeemPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._diamondRedeemPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._popupLayer.addChild(this._diamondRedeemPopup);
            DarkenManager.darken(this._diamondRedeemPopup);
         }
      }
      
      private function destroyDiamondRedeemPopup(param1:MouseEvent = null) : void
      {
         var _loc3_:Object = null;
         if(param1)
         {
            param1.stopPropagation();
            SBOkPopup.destroyInParentChain(param1.target.parent);
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._currRedemECard.msgId,false,this.onGiftAcceptRejectResponse);
         this._diamondRedeemPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.popupMouseDownHandler);
         this._diamondRedeemPopup.saveBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSaveDiamonds);
         this._diamondRedeemPopup.redeemBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRedeemDiamonds);
         var _loc2_:int = 0;
         while(_loc2_ < this._diamondRedeemPopup.itemLayer.numChildren)
         {
            _loc3_ = this._diamondRedeemPopup.itemLayer.getChildAt(0);
            if(_loc3_ is AvatarView)
            {
               _loc3_.destroy(true);
               _loc3_ = null;
               break;
            }
            _loc2_++;
         }
         DarkenManager.unDarken(this._diamondRedeemPopup);
         this._popupLayer.removeChild(this._diamondRedeemPopup);
         this._diamondRedeemPopup = null;
         this._imageBeingLoaded = false;
         this.loadNextPopup();
      }
      
      private function onNewMemberTweenComplete(param1:GTween) : void
      {
         new GTween(this._newMemberPopup,0.3,{
            "scaleX":1,
            "scaleY":1
         },{"ease":Quadratic.easeIn});
      }
      
      private function onExpiringPopupTweenComplete(param1:GTween) : void
      {
         new GTween(this._expiringPopup,0.3,{
            "scaleX":1,
            "scaleY":1
         },{"ease":Quadratic.easeIn});
      }
      
      private function createPlayerEngagement(param1:MovieClip) : void
      {
         GuiManager.initPlayerEngagement(this.loadNextPopup);
      }
      
      private function createDemotionPopup(param1:MovieClip) : void
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
      
      private function setupGiftPopup(param1:Sprite) : void
      {
         var _loc5_:String = null;
         var _loc6_:Array = null;
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:String = "";
         var _loc3_:String = this._currRedemECard.msg;
         if(this._currRedemECard.type == ECard.TYPE_DEN_ROOM || this._currRedemECard.type == ECard.TYPE_AVT || this._currRedemECard.type == ECard.TYPE_CUSTOM_AVT)
         {
            _loc6_ = _loc3_.split("|");
            if(_loc6_.length == 5)
            {
               _loc2_ = LocalizationManager.translateIdAndInsertOnly(int(_loc6_[1]),LocalizationManager.translateIdOnly(int(_loc6_[2])),Utility.convertNumberToString(int(_loc6_[3])),LocalizationManager.translateIdOnly(int(_loc6_[4])));
            }
            else if(_loc6_.length == 4)
            {
               _loc2_ = LocalizationManager.translateIdAndInsertOnly(int(_loc6_[1]),LocalizationManager.translateIdOnly(int(_loc6_[2])),LocalizationManager.translateIdOnly(int(_loc6_[3])));
            }
         }
         var _loc4_:int = this._currRedemECard.isAJHQGift ? GiftPopup.POPUP_TYPE_HQ : GiftPopup.POPUP_TYPE_PROMO;
         if(this._currRedemECard.type == ECard.TYPE_DIAMOND)
         {
            _loc5_ = LocalizationManager.translateIdAndInsertOnly(this._numDiamondsReceiving > 1 ? LocalizationManager.DIAMONDS_CAPITALIZED : LocalizationManager.DIAMOND_CAPITALIZED,this._numDiamondsReceiving);
         }
         else
         {
            _loc5_ = this._currRedemECard.giftName;
         }
         GuiManager.openGiftPopup(param1,_loc5_,this._currRedemECard.giftId,this._currRedemECard.type,this.keepGiftCallback,this.rejectGiftCallback,this.checkRedemptionStatus,GiftPopup.buttonsTypeForECardType(this._currRedemECard.type),_loc2_,_loc4_,_loc3_,true);
         this._redemptionList.splice(0,1);
      }
      
      private function keepPetCallback() : void
      {
         var _loc1_:int = this._currRedemECard.msgId;
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
         var _loc4_:int = 0;
         var _loc1_:int = this._currRedemECard.msgId;
         var _loc2_:int = this._currRedemECard.type;
         var _loc3_:int = this._currRedemECard.stampMediaId;
         if(!GuiManager.closePromoPopup())
         {
            this.checkRedemptionStatus();
         }
         DarkenManager.showLoadingSpiral(true);
         if(_loc2_ == ECard.TYPE_DIAMOND)
         {
            _loc4_ = 0;
            while(_loc4_ < this._diamondECards.length)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._diamondECards[_loc4_].msgId,true,this.onGiftAcceptRejectResponse);
               _loc4_++;
            }
            this._diamondECards = null;
            this._numDiamondsReceiving = 0;
         }
         else if(_loc2_ == ECard.TYPE_GEMS)
         {
            if(_loc3_ > 0)
            {
               if(_loc3_ == 1)
               {
                  _loc4_ = 0;
                  while(_loc4_ < this._jumpGemsECards.length)
                  {
                     ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._jumpGemsECards[_loc4_].msgId,true,this.onGiftAcceptRejectResponse);
                     _loc4_++;
                  }
                  this._jumpGemsECards = null;
                  this._numJumpGemsReceiving = 0;
               }
            }
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_loc1_,true,this.onGiftAcceptRejectResponse);
      }
      
      private function rejectGiftCallback() : void
      {
         var _loc4_:int = 0;
         var _loc1_:int = this._currRedemECard.msgId;
         var _loc2_:int = this._currRedemECard.type;
         var _loc3_:int = this._currRedemECard.stampMediaId;
         if(!GuiManager.closePromoPopup())
         {
            this.checkRedemptionStatus();
         }
         DarkenManager.showLoadingSpiral(true);
         if(_loc2_ == ECard.TYPE_DIAMOND)
         {
            _loc4_ = 0;
            while(_loc4_ < this._diamondECards.length)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._diamondECards[_loc4_].msgId,false,this.onGiftAcceptRejectResponse);
               _loc4_++;
            }
            this._diamondECards = null;
            this._numDiamondsReceiving = 0;
         }
         else if(_loc2_ == ECard.TYPE_GEMS)
         {
            if(_loc3_ > 0)
            {
               if(_loc3_ == 1)
               {
                  _loc4_ = 0;
                  while(_loc4_ < this._jumpGemsECards.length)
                  {
                     ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._jumpGemsECards[_loc4_].msgId,false,this.onGiftAcceptRejectResponse);
                     _loc4_++;
                  }
                  this._jumpGemsECards = null;
                  this._numJumpGemsReceiving = 0;
               }
            }
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_loc1_,false,this.onGiftAcceptRejectResponse);
      }
      
      private function onGiftAcceptRejectResponse(param1:int, param2:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         ECardManager.onDeleteResponse([param1],true);
      }
      
      private function onExtendingMembershipResponse(param1:int, param2:Boolean) : void
      {
         ECardManager.onDeleteResponse([param1],true);
      }
      
      private function loadRedemptionImage(param1:ECard) : void
      {
         var _loc2_:Object = null;
         var _loc3_:MediaHelper = null;
         var _loc4_:Object = null;
         var _loc5_:MediaHelper = null;
         var _loc6_:Avatar = null;
         if(param1.type == ECard.TYPE_CLOTHING)
         {
            this._clothingIcon = new LayerBitmap();
            this._clothingIconHelper = new SimpleIcon();
            this._clothingIconHelper.init(this._clothingIcon,param1.giftColor,param1.giftId,1,true,false,this.clothingIconReceived);
         }
         else if(param1.type == ECard.TYPE_DEN_ACC || param1.type == ECard.TYPE_DEN_AUDIO)
         {
            _loc2_ = DenXtCommManager.getDenItemDef(param1.giftId);
            if(!_loc2_)
            {
               return;
            }
            this._denIconHelper = new DenItemHelper();
            this._denIconHelper.init(uint(param1.giftId << 16 | DenItem.getIconId(_loc2_.sortCat)),this.denIconReceived,param1.giftColor);
         }
         else if(param1.type == ECard.TYPE_GEMS || param1.type == ECard.TYPE_DIAMOND)
         {
            _loc3_ = new MediaHelper();
            if(param1.giftColor != 0)
            {
               _loc3_.init(DIAMOND_ANIMAL_REDEEM_ID,this.onDiamondRedeemPopupLoaded,{
                  "diamondDef":param1.giftColor,
                  "numDiamondsReceived":param1.giftId
               });
               this._mediaViews.push(_loc3_);
            }
            else
            {
               _loc3_.init(param1.type == ECard.TYPE_GEMS ? uint(GEMS_MEDIA_ID) : uint(DIAMOND_MEDIA_ID),this.onMediaHelperIconReceived,param1.stampMediaId);
               this._mediaViews.push(_loc3_);
            }
         }
         else if(param1.type == ECard.TYPE_DEN_ROOM)
         {
            _loc4_ = gMainFrame.userInfo.getDenRoomDefByDefId(param1.giftId);
            if(!_loc4_)
            {
               return;
            }
            _loc5_ = new MediaHelper();
            _loc5_.init(_loc4_.mediaId,this.onMediaHelperIconReceived);
            this._mediaViews.push(_loc5_);
         }
         else if(param1.type == ECard.TYPE_AVT || param1.type == ECard.TYPE_CUSTOM_AVT)
         {
            _loc6_ = null;
            if(param1.type == ECard.TYPE_CUSTOM_AVT)
            {
               _loc6_ = AvatarManager.getDefaultAvatarByDefId(param1.giftId,true);
            }
            else
            {
               _loc6_ = AvatarManager.getDefaultAvatarByDefId(param1.giftId);
            }
            if(_loc6_ == null)
            {
               return;
            }
            this._avtView = new AvatarView();
            this._avtView.init(_loc6_);
            this._avtView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,this.avatarViewReceived);
         }
         else if(param1.type == ECard.TYPE_PET)
         {
            ++this._numPetsToCreate;
            if(param1.stampMediaId > 0)
            {
               GuiManager.openJumpPopup(true,this.onJumpPopupClose,null,param1.giftId);
            }
            else
            {
               PetManager.openPetFinder(PetManager.petNameForDefId(param1.giftId),this.keepPetCallback,true);
            }
         }
         else if(param1.type == ECard.TYPE_SUBSCRIPTION)
         {
         }
      }
      
      private function avatarViewReceived(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Sprite = new Sprite();
         _loc3_.addChild(this._avtView);
         var _loc4_:Point = BuddyCard.getAvOffsetByDefId(this._avtView.avTypeId);
         this._avtView.x = _loc4_.x;
         this._avtView.y = _loc4_.y;
         this.setupGiftPopup(_loc3_);
      }
      
      private function clothingIconReceived() : void
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.addChild(this._clothingIcon);
         _loc1_.x = -_loc1_.width * 0.5;
         _loc1_.y = -_loc1_.height * 0.5;
         this.setupGiftPopup(_loc1_);
      }
      
      private function denIconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Number = NaN;
         if(Boolean(param1) && Boolean(param1.displayObject))
         {
            _loc2_ = new Sprite();
            _loc3_ = DenItem.WIND_MED_SIZE / Math.max(param1.displayObject.width,param1.displayObject.height);
            param1.displayObject.width *= _loc3_;
            param1.displayObject.height *= _loc3_;
            _loc2_.addChild(param1.displayObject);
            _loc2_.x = -_loc2_.width * 0.5;
            _loc2_.y = -_loc2_.height * 0.5;
            this.setupGiftPopup(_loc2_);
         }
      }
      
      private function onMediaHelperIconReceived(param1:MovieClip) : void
      {
         if(param1.passback > 0)
         {
            if(param1.passback == 1)
            {
               GuiManager.openJumpPopup(false,this.onJumpPopupClose,param1,this._numJumpGemsReceiving);
            }
         }
         else
         {
            this.setupGiftPopup(param1);
         }
      }
      
      private function onJumpPopupClose(param1:Boolean, param2:int, param3:MovieClip = null) : void
      {
         if(param1)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId(param2),this.keepPetCallback,true);
         }
         else
         {
            this._redemptionList.splice(0,1);
            this.keepGiftCallback();
         }
      }
      
      private function popupCloseHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.parent)
         {
            _loc2_ = param1.currentTarget.root;
            if(this._extendingMembershipJAGMsgId > 0)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(this._extendingMembershipJAGMsgId,false,this.onExtendingMembershipResponse);
               this._extendingMembershipJAGMsgId = 0;
            }
            DarkenManager.unDarken(_loc2_);
            _loc2_.visible = false;
            _loc2_ = null;
            this._imageBeingLoaded = false;
            this.loadNextPopup();
         }
      }
      
      private function popupMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function newMemberFeaturesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/newMemberFeatures",-1,SBTracker.TYPE_EVENT);
         param1.currentTarget.parent.parent.p1.visible = false;
         param1.currentTarget.parent.parent.p2.visible = true;
      }
      
      private function newMemberBackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.pop();
         param1.currentTarget.parent.parent.p1.visible = true;
         param1.currentTarget.parent.parent.p2.visible = false;
      }
      
      private function onRenew(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/demotion/renew");
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
      
      private function onSaveDiamonds(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBOkPopup(this._popupLayer,LocalizationManager.translateIdAndInsertOnly(14802,this._diamondRedeemPopup.numDiamondsReceived),true,this.destroyDiamondRedeemPopup);
      }
      
      private function onRedeemDiamonds(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AvatarSwitch.addAvatar(AvatarSwitch.avatars.length,false,this.onAvatarAdded,false,false,false,this._diamondRedeemPopup.diamondItem.refDefId,true,GenericListXtCommManager.REDEMPTION_STORE_LIST_ID,this._diamondRedeemPopup.diamondItem.defId);
      }
      
      private function onAvatarAdded(param1:int) : void
      {
         if(param1 == 1)
         {
            this.destroyDiamondRedeemPopup();
         }
         else if(param1 == -1)
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

