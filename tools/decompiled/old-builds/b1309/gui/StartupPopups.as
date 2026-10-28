package gui
{
   import achievement.Achievement;
   import achievement.AchievementXtCommManager;
   import adoptAPet.AdoptAPetManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
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
      
      private const EMAIL_CONFIRMATION:int = 4573;
      
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
      
      private var _numDiamondRefundsReceiving:int;
      
      private var _diamondECards:Array;
      
      private var _diamondRedeemPopup:MovieClip;
      
      private var _adoptAPetCardsReceiving:Array;
      
      private var _numJumpGemsReceiving:int;
      
      private var _jumpGemsECards:Array;
      
      private var _checkRedemptionsOnly:Boolean;
      
      private var _closeCallback:Function;
      
      private var _showFirstAdoptAPetPopup:Boolean;
      
      private var _hasRedeemedAvatar:Boolean;
      
      public function StartupPopups()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Function, param3:Boolean = false) : void
      {
         _popupLayer = param1;
         _loadTheseMediaItems = [];
         _mediaViews = [];
         _popupImages = [];
         _redemptionList = [];
         _diamondECards = [];
         _jumpGemsECards = [];
         _imageBeingLoaded = false;
         _closeCallback = param2;
         _checkRedemptionsOnly = param3;
         RoomManagerWorld.instance.callback_InitialDataRequest = requestInitialData;
         if((gMainFrame.clientInfo.numRedemptionCards > 0 || !gMainFrame.userInfo.isMember && gMainFrame.clientInfo.numAJHQGiftCards > 0 || _checkRedemptionsOnly) && !gMainFrame.clientInfo.invisiMode)
         {
            DarkenManager.showLoadingSpiral(true);
            ECardManager.isFirstTime = false;
            ECardXtCommManager.sendECardListRequest(redemptionCardsRequest);
            _loadTheseMediaItems.push(1068);
         }
         else
         {
            setupAndLoadAllPopups();
         }
      }
      
      public function setupInGameRedemption() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _loadTheseMediaItems = [];
         _mediaViews = [];
         _popupImages = [];
         _redemptionList = [];
         _diamondECards = [];
         _jumpGemsECards = [];
         _adoptAPetCardsReceiving = null;
         _imageBeingLoaded = false;
         _checkRedemptionsOnly = true;
         ECardManager.isFirstTime = false;
         ECardXtCommManager.sendECardListRequest(redemptionCardsRequest);
         _loadTheseMediaItems.push(1068);
      }
      
      private function setupAndLoadAllPopups() : void
      {
         var _loc2_:MediaHelper = null;
         var _loc1_:int = 0;
         if(!_checkRedemptionsOnly)
         {
            if(gMainFrame.userInfo.isMember && gMainFrame.clientInfo.numDaysLeftOnSubscription > 0 && gMainFrame.clientInfo.numDaysLeftOnSubscription < 6 && GuiManager.sharedObj && (GuiManager.sharedObj.data.expiration == null || GuiManager.sharedObj.data.expiration + 86400000 <= new Date().millisecondsUTC) && gMainFrame.clientInfo.dbUserId % 2 == 0)
            {
               _loadTheseMediaItems.push(1953);
            }
            if(gMainFrame.clientInfo.accountTypeChanged && gMainFrame.userInfo.isMember || _extendingMembershipJAGMsgId > 0)
            {
               gMainFrame.clientInfo.accountTypeChanged = false;
               _loadTheseMediaItems.push(117);
            }
            if(!gMainFrame.userInfo.isMember && AvatarSwitch.availSlotFlags == 0)
            {
               _loadTheseMediaItems.push(156);
            }
            if((gMainFrame.userInfo.userVarCache.getUserVarValueById(428) == -1 || gMainFrame.userInfo.userVarCache.getUserVarValueById(428) != gMainFrame.clientInfo.jamaaDate) && gMainFrame.clientInfo.numDaysBeforeExpiring > 0 && gMainFrame.clientInfo.numDaysBeforeExpiring <= 7)
            {
               _loadTheseMediaItems.push(4573);
            }
         }
         else if(gMainFrame.clientInfo.accountTypeChanged && gMainFrame.userInfo.isMember || _extendingMembershipJAGMsgId > 0)
         {
            gMainFrame.clientInfo.accountTypeChanged = false;
            _loadTheseMediaItems.push(117);
         }
         _loc1_ = 0;
         while(_loc1_ < _loadTheseMediaItems.length)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(_loadTheseMediaItems[_loc1_],popupsMediaCallback,true);
            _mediaViews[_loc1_] = _loc2_;
            _loc1_++;
         }
         if(_loadTheseMediaItems.length == 0)
         {
            DarkenManager.showLoadingSpiral(false);
            requestInitialData();
            destroy();
         }
      }
      
      private function popupsMediaCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < _loadTheseMediaItems.length)
            {
               if(param1.mediaHelper.id == _loadTheseMediaItems[_loc2_])
               {
                  _popupImages[_loc2_] = param1;
                  break;
               }
               _loc2_++;
            }
            loadNextPopup();
         }
      }
      
      public function requestInitialData() : void
      {
         if(gMainFrame.clientInfo.hasOnlineBuddies && Utility.canBuddy())
         {
            BuddyList.startBuddyListBtnGlow();
         }
         if(_loadTheseMediaItems.length == 0)
         {
            if(gMainFrame.userInfo.isMember && gMainFrame.userInfo.userVarCache.getUserVarValueById(Achievement.MEMBER_NEW) == -1)
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
         _welcomeRoomURI = param1;
      }
      
      private function destroy() : void
      {
         var _loc1_:int = 0;
         SBTracker.flush();
         if(_welcomeRoomURI)
         {
            SBTracker.trackPageview(_welcomeRoomURI);
         }
         if(_mediaViews)
         {
            _loc1_ = 0;
            while(_loc1_ < _mediaViews.length)
            {
               _mediaViews[_loc1_].destroy();
               _mediaViews[_loc1_] = null;
               _loc1_++;
            }
         }
         RoomManagerWorld.instance.callback_InitialDataRequest = null;
         _expiringPopup = null;
         _codePopup = null;
         _welcomePopup = null;
         _loginBonusPopup = null;
         _newMemberPopup = null;
         _demotionMessagePopup = null;
         _imageBeingLoaded = false;
         _loadTheseMediaItems = null;
         _mediaViews = null;
         _popupImages = null;
         _adoptAPetCardsReceiving = null;
         _hasRedeemedAvatar = false;
         if(_closeCallback != null)
         {
            _closeCallback();
            _closeCallback = null;
         }
      }
      
      private function loadNextPopup(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         if(!_loadTheseMediaItems)
         {
            return;
         }
         if(_loadTheseMediaItems.length > 0 && _popupImages.length > 0 && !_imageBeingLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = 0;
            while(_loc2_ < _loadTheseMediaItems.length)
            {
               if(_popupImages[_loc2_])
               {
                  switch(_loadTheseMediaItems[_loc2_])
                  {
                     case 1068:
                        _imageBeingLoaded = true;
                        _currRedemECard = _redemptionList[0];
                        if(_currRedemECard)
                        {
                           SBTracker.push();
                           SBTracker.trackPageview("/game/play/popup/promotionCode/#" + _currRedemECard.msg,-1,1);
                           loadRedemptionImage(_currRedemECard);
                        }
                        break;
                     case 1953:
                        _imageBeingLoaded = true;
                        SBTracker.push();
                        SBTracker.trackPageview("/game/play/popup/expiration/" + gMainFrame.clientInfo.numDaysLeftOnSubscription);
                        createExpiringPopup(_popupImages[_loc2_]);
                        break;
                     case 85:
                        _imageBeingLoaded = true;
                        createWelcomePopup(_popupImages[_loc2_]);
                        break;
                     case 117:
                        _imageBeingLoaded = true;
                        SBTracker.push();
                        SBTracker.trackPageview("/game/play/popup/newMember",-1,1);
                        createNewMemberPopup(_popupImages[_loc2_]);
                        break;
                     case 156:
                        _imageBeingLoaded = true;
                        _imageToLoad = _popupImages[_loc2_];
                        SBTracker.push();
                        SBTracker.trackPageview("/game/play/popup/demotion/page1");
                        createDemotionPopup(_imageToLoad);
                        break;
                     case 1567:
                        _imageBeingLoaded = true;
                        _imageToLoad = _popupImages[_loc2_];
                        SBTracker.trackPageview("/game/play/popup/playerEngagement",-1,1);
                        createPlayerEngagement(_imageToLoad);
                        break;
                     case 4573:
                        _imageBeingLoaded = true;
                        _imageToLoad = _popupImages[_loc2_];
                        SBTracker.trackPageview("/game/play/popup/emailConfirmation",-1,1);
                        createEmailConfirmation(_imageToLoad);
                  }
                  if(_imageBeingLoaded)
                  {
                     _loadTheseMediaItems.splice(_loc2_,1);
                     _popupImages.splice(_loc2_,1);
                     break;
                  }
               }
               _loc2_++;
            }
         }
         else if(_loadTheseMediaItems.length == 0)
         {
            if(_hasRedeemedAvatar)
            {
               AvatarXtCommManager.requestAvatarList([1,gMainFrame.userInfo.myUserName],AvatarSwitch.updateAfterRedeemingAvatar);
            }
            if(gMainFrame.userInfo.isMember && gMainFrame.userInfo.userVarCache.getUserVarValueById(Achievement.MEMBER_NEW) == -1)
            {
               AchievementXtCommManager.requestSetUserVar(Achievement.MEMBER_NEW,1);
            }
            if(param1)
            {
               GuiManager.guiStartupChecks();
            }
            destroy();
         }
      }
      
      private function redemptionCardsRequest(param1:Array) : void
      {
         var _loc3_:ECard = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1[_loc2_];
            if(_loc3_.isRedemptionJAG)
            {
               if(_loc3_.type == 7)
               {
                  _extendingMembershipJAGMsgId = _loc3_.msgId;
               }
               else if(_loc3_.type == 9)
               {
                  if(_loc3_.giftColor != 0)
                  {
                     _redemptionList.push(_loc3_);
                  }
                  else
                  {
                     if(_numDiamondRefundsReceiving != 0 || _numDiamondsReceiving != 0)
                     {
                        _diamondECards.push(_loc3_);
                     }
                     else
                     {
                        _redemptionList.push(_loc3_);
                     }
                     if(_loc3_.stampMediaId != 2)
                     {
                        _numDiamondsReceiving += _loc3_.giftId;
                     }
                     else
                     {
                        _numDiamondRefundsReceiving += _loc3_.giftId;
                     }
                  }
               }
               else if(_loc3_.type == 4)
               {
                  if(_loc3_.stampMediaId > 0)
                  {
                     if(_loc3_.stampMediaId == 1)
                     {
                        if(_numJumpGemsReceiving == 0)
                        {
                           _redemptionList.push(_loc3_);
                        }
                        else
                        {
                           _jumpGemsECards.push(_loc3_);
                        }
                        _numJumpGemsReceiving += _loc3_.giftId;
                     }
                  }
                  else
                  {
                     _redemptionList.push(_loc3_);
                  }
               }
               else if(_loc3_.type == 12)
               {
                  if(_adoptAPetCardsReceiving == null)
                  {
                     _adoptAPetCardsReceiving = [];
                     _adoptAPetCardsReceiving.push(_loc3_);
                     _redemptionList.push(_loc3_);
                  }
                  else
                  {
                     _adoptAPetCardsReceiving.push(_loc3_);
                  }
               }
               else
               {
                  _redemptionList.push(_loc3_);
               }
            }
            _loc2_++;
         }
         if(_redemptionList.length <= 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _loadTheseMediaItems.length)
            {
               if(_loadTheseMediaItems[_loc2_] == 1068)
               {
                  _loadTheseMediaItems.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
         }
         setupAndLoadAllPopups();
      }
      
      private function createExpiringPopup(param1:MovieClip) : void
      {
         if(param1)
         {
            GuiManager.setSharedObj("expiration",new Date().millisecondsUTC);
            _expiringPopup = MovieClip(param1.getChildAt(0)).expiringMemberPopup;
            _expiringPopup.addEventListener("mouseDown",popupMouseDownHandler,false,0,true);
            _expiringPopup["bx"].addEventListener("mouseDown",popupCloseHandler,false,0,true);
            _expiringPopup["renewBtn"].addEventListener("mouseDown",onRenew,false,0,true);
            if(gMainFrame.clientInfo.numDaysLeftOnSubscription > 1)
            {
               LocalizationManager.translateIdAndInsert(_expiringPopup.daysTxt,11119,gMainFrame.clientInfo.numDaysLeftOnSubscription);
            }
            else
            {
               LocalizationManager.translateIdAndInsert(_expiringPopup.daysTxt,11118,gMainFrame.clientInfo.numDaysLeftOnSubscription);
            }
            _expiringPopup.x = 900 * 0.5;
            _expiringPopup.y = 550 * 0.5;
            _popupLayer.addChild(_expiringPopup.parent.parent);
            _expiringPopup.scaleX = _expiringPopup.scaleY = 0.1;
            new GTween(_expiringPopup,0.25,{
               "scaleX":1.2,
               "scaleY":1.2
            },{
               "ease":Circular.easeIn,
               "onComplete":onExpiringPopupTweenComplete
            });
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_expiringPopup.parent.parent);
         }
      }
      
      private function createWelcomePopup(param1:MovieClip) : void
      {
         if(param1)
         {
            _welcomePopup = param1;
            _welcomePopup.getChildAt(0)["bx"].addEventListener("mouseDown",popupCloseHandler,false,0,true);
            _welcomePopup.addEventListener("mouseDown",popupMouseDownHandler,false,0,true);
            _welcomePopup.x = 900 * 0.5;
            _welcomePopup.y = 550 * 0.5;
            _popupLayer.addChild(_welcomePopup);
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_welcomePopup);
         }
      }
      
      private function createNewMemberPopup(param1:MovieClip) : void
      {
         if(param1)
         {
            _newMemberPopup = MovieClip(param1.getChildAt(0)).newMemberPopup;
            _newMemberPopup["bx"].addEventListener("mouseDown",popupCloseHandler,false,0,true);
            if(_extendingMembershipJAGMsgId > 0)
            {
               _newMemberPopup["c"].p1.visible = false;
               _newMemberPopup["c"].p2.visible = false;
            }
            else
            {
               _newMemberPopup["c"].p2.visible = false;
               _newMemberPopup["c"].p3.visible = false;
               _newMemberPopup["c"].p1.features.addEventListener("mouseDown",newMemberFeaturesBtn,false,0,true);
               _newMemberPopup["c"].p2.back.addEventListener("mouseDown",newMemberBackBtn,false,0,true);
            }
            _newMemberPopup.addEventListener("mouseDown",popupMouseDownHandler,false,0,true);
            _newMemberPopup.parent.parent.x = 900 * 0.5;
            _newMemberPopup.parent.parent.y = 550 * 0.5;
            _popupLayer.addChild(_newMemberPopup.parent.parent);
            _newMemberPopup.scaleX = _newMemberPopup.scaleY = 0.1;
            new GTween(_newMemberPopup,0.25,{
               "scaleX":1.2,
               "scaleY":1.2
            },{
               "ease":Circular.easeIn,
               "onComplete":onNewMemberTweenComplete
            });
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_newMemberPopup.parent.parent);
         }
      }
      
      private function onDiamondRedeemPopupLoaded(param1:MovieClip) : void
      {
         var _loc4_:Avatar = null;
         var _loc2_:AvatarView = null;
         var _loc3_:Point = null;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _diamondRedeemPopup = MovieClip(param1.getChildAt(0));
            _diamondRedeemPopup.addEventListener("mouseDown",popupMouseDownHandler,false,0,true);
            _diamondRedeemPopup.saveBtn.addEventListener("mouseDown",onSaveDiamonds,false,0,true);
            _diamondRedeemPopup.redeemBtn.addEventListener("mouseDown",onRedeemDiamonds,false,0,true);
            _diamondRedeemPopup.diamondItem = DiamondXtCommManager.getDiamondItem(param1.passback.diamondDef);
            _diamondRedeemPopup.numDiamondsReceived = param1.passback.numDiamondsReceived;
            _loc4_ = AvatarUtility.findCreationAvatarByType(_diamondRedeemPopup.diamondItem.refDefId,-1);
            _loc2_ = new AvatarView();
            _loc2_.init(_loc4_);
            _loc2_.playAnim(13,false,1,null);
            if(_diamondRedeemPopup)
            {
               _diamondRedeemPopup.avatarName = LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(_diamondRedeemPopup.diamondItem.refDefId,false).titleStrRef);
               LocalizationManager.translateIdAndInsert(_diamondRedeemPopup.txt,11385,_diamondRedeemPopup.avatarName);
            }
            _loc3_ = AvatarUtility.getAnimalItemWindowOffset(_diamondRedeemPopup.diamondItem.refDefId);
            _loc2_.x = _loc3_.x;
            _loc2_.y = _loc3_.y;
            _diamondRedeemPopup.itemLayer.addChild(_loc2_);
            _diamondRedeemPopup.x = 900 * 0.5;
            _diamondRedeemPopup.y = 550 * 0.5;
            _popupLayer.addChild(_diamondRedeemPopup);
            DarkenManager.darken(_diamondRedeemPopup);
         }
      }
      
      private function destroyDiamondRedeemPopup(param1:MouseEvent = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1)
         {
            param1.stopPropagation();
            SBOkPopup.destroyInParentChain(param1.target.parent);
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currRedemECard.msgId,false,onGiftAcceptRejectResponse);
         _diamondRedeemPopup.removeEventListener("mouseDown",popupMouseDownHandler);
         _diamondRedeemPopup.saveBtn.removeEventListener("mouseDown",onSaveDiamonds);
         _diamondRedeemPopup.redeemBtn.removeEventListener("mouseDown",onRedeemDiamonds);
         _loc2_ = 0;
         while(_loc2_ < _diamondRedeemPopup.itemLayer.numChildren)
         {
            _loc3_ = _diamondRedeemPopup.itemLayer.getChildAt(0);
            if(_loc3_ is AvatarView)
            {
               _loc3_.destroy(true);
               _loc3_ = null;
               break;
            }
            _loc2_++;
         }
         DarkenManager.unDarken(_diamondRedeemPopup);
         _popupLayer.removeChild(_diamondRedeemPopup);
         _diamondRedeemPopup = null;
         _imageBeingLoaded = false;
         loadNextPopup();
      }
      
      private function onAcceptCloseDiamondRefundPopup() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _diamondECards.length)
         {
            if(_diamondECards[_loc1_].stampMediaId == 2)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_diamondECards[_loc1_].msgId,true,onGiftAcceptRejectResponse);
            }
            _loc1_++;
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currRedemECard.msgId,false,onGiftAcceptRejectResponse);
         _imageBeingLoaded = false;
         loadNextPopup();
      }
      
      private function onNewMemberTweenComplete(param1:GTween) : void
      {
         new GTween(_newMemberPopup,0.3,{
            "scaleX":1,
            "scaleY":1
         },{"ease":Quadratic.easeIn});
      }
      
      private function onExpiringPopupTweenComplete(param1:GTween) : void
      {
         new GTween(_expiringPopup,0.3,{
            "scaleX":1,
            "scaleY":1
         },{"ease":Quadratic.easeIn});
      }
      
      private function createPlayerEngagement(param1:MovieClip) : void
      {
         GuiManager.initPlayerEngagement(loadNextPopup);
      }
      
      private function createDemotionPopup(param1:MovieClip) : void
      {
         GuiManager.initDemotionMessage(loadNextPopup);
      }
      
      private function createEmailConfirmation(param1:MovieClip) : void
      {
         GuiManager.initEmailConfirmation(loadNextPopup,param1);
      }
      
      private function checkRedemptionStatus() : void
      {
         GuiManager.destroyPromotionalPopup();
         if(_redemptionList.length > 0)
         {
            DarkenManager.showLoadingSpiral(true);
            _currRedemECard = _redemptionList[0];
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/promotionCode/#" + _currRedemECard.msg,-1,1);
            loadRedemptionImage(_currRedemECard);
         }
         else
         {
            _imageBeingLoaded = false;
            loadNextPopup();
         }
      }
      
      private function setupGiftPopup(param1:Sprite) : void
      {
         var _loc6_:Array = null;
         var _loc4_:String = null;
         var _loc3_:String = "";
         var _loc5_:String = _currRedemECard.msg;
         if(_currRedemECard.type == 5 || _currRedemECard.type == 6 || _currRedemECard.type == 10)
         {
            _loc6_ = _loc5_.split("|");
            if(_loc6_.length == 5)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(int(_loc6_[1]),LocalizationManager.translateIdOnly(int(_loc6_[2])),Utility.convertNumberToString(int(_loc6_[3])),LocalizationManager.translateIdOnly(int(_loc6_[4])));
            }
            else if(_loc6_.length == 4)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(int(_loc6_[1]),LocalizationManager.translateIdOnly(int(_loc6_[2])),LocalizationManager.translateIdOnly(int(_loc6_[3])));
            }
         }
         var _loc2_:int = _currRedemECard.isAJHQGift ? 6 : 1;
         if(_currRedemECard.type == 9)
         {
            _loc4_ = LocalizationManager.translateIdAndInsertOnly(_numDiamondsReceiving > 1 ? 11103 : 11116,_numDiamondsReceiving);
         }
         else
         {
            _loc4_ = _currRedemECard.giftName;
         }
         GuiManager.openGiftPopup(param1,_loc4_,_currRedemECard.giftId,_currRedemECard.type,keepGiftCallback,rejectGiftCallback,checkRedemptionStatus,GiftPopup.buttonsTypeForECardType(_currRedemECard.type),_loc3_,_loc2_,_loc5_,true);
         _redemptionList.splice(0,1);
      }
      
      private function keepPetCallback() : void
      {
         var _loc1_:int = _currRedemECard.msgId;
         if(!GuiManager.closePromoPopup())
         {
            _redemptionList.splice(0,1);
            _numPetCallbacks = _numPetCallbacks + 1;
            if(_numPetCallbacks == _numPetsToCreate)
            {
               checkRedemptionStatus();
            }
         }
      }
      
      private function keepGiftCallback() : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = _currRedemECard.msgId;
         var _loc4_:int = _currRedemECard.type;
         var _loc1_:int = _currRedemECard.stampMediaId;
         if(!GuiManager.closePromoPopup())
         {
            checkRedemptionStatus();
         }
         DarkenManager.showLoadingSpiral(true);
         if(_loc4_ == 9)
         {
            _loc3_ = 0;
            while(_loc3_ < _diamondECards.length)
            {
               if(_diamondECards[_loc3_].stampMediaId != 2)
               {
                  ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_diamondECards[_loc3_].msgId,true,onGiftAcceptRejectResponse);
               }
               _loc3_++;
            }
            _numDiamondsReceiving = 0;
         }
         else if(_loc4_ == 4)
         {
            if(_loc1_ > 0)
            {
               if(_loc1_ == 1)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _jumpGemsECards.length)
                  {
                     ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_jumpGemsECards[_loc3_].msgId,true,onGiftAcceptRejectResponse);
                     _loc3_++;
                  }
                  _jumpGemsECards = null;
                  _numJumpGemsReceiving = 0;
               }
            }
         }
         else if(_loc4_ == 12)
         {
            if(_adoptAPetCardsReceiving)
            {
               _loc3_ = 0;
               while(_loc3_ < _adoptAPetCardsReceiving.length)
               {
                  ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_adoptAPetCardsReceiving[_loc3_].msgId,true,onGiftAcceptRejectResponse);
                  _loc3_++;
               }
               _adoptAPetCardsReceiving = null;
            }
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_loc2_,true,onGiftAcceptRejectResponse);
      }
      
      private function rejectGiftCallback() : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = _currRedemECard.msgId;
         var _loc4_:int = _currRedemECard.type;
         var _loc1_:int = _currRedemECard.stampMediaId;
         if(!GuiManager.closePromoPopup())
         {
            checkRedemptionStatus();
         }
         DarkenManager.showLoadingSpiral(true);
         if(_loc4_ == 9)
         {
            _loc3_ = 0;
            while(_loc3_ < _diamondECards.length)
            {
               if(_diamondECards[_loc3_].stampMediaId != 2)
               {
                  ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_diamondECards[_loc3_].msgId,false,onGiftAcceptRejectResponse);
               }
               _loc3_++;
            }
            _numDiamondsReceiving = 0;
         }
         else if(_loc4_ == 4)
         {
            if(_loc1_ > 0)
            {
               if(_loc1_ == 1)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _jumpGemsECards.length)
                  {
                     ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_jumpGemsECards[_loc3_].msgId,false,onGiftAcceptRejectResponse);
                     _loc3_++;
                  }
                  _jumpGemsECards = null;
                  _numJumpGemsReceiving = 0;
               }
            }
         }
         else if(_loc4_ == 12)
         {
            if(_adoptAPetCardsReceiving)
            {
               _loc3_ = 0;
               while(_loc3_ < _adoptAPetCardsReceiving.length)
               {
                  ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_adoptAPetCardsReceiving[_loc3_].msgId,true,onGiftAcceptRejectResponse);
                  _loc3_++;
               }
               _adoptAPetCardsReceiving = null;
            }
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_loc2_,false,onGiftAcceptRejectResponse);
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
         var _loc6_:MediaHelper = null;
         var _loc3_:Object = null;
         var _loc4_:MediaHelper = null;
         var _loc7_:Avatar = null;
         var _loc5_:int = 0;
         if(param1.type == 1)
         {
            _clothingIcon = new LayerBitmap();
            _clothingIconHelper = new SimpleIcon();
            _clothingIconHelper.init(_clothingIcon,param1.giftColor,param1.giftId,1,true,false,clothingIconReceived);
         }
         else if(param1.type == 3 || param1.type == 99)
         {
            _loc2_ = DenXtCommManager.getDenItemDef(param1.giftId);
            if(!_loc2_)
            {
               return;
            }
            _denIconHelper = new DenItemHelper();
            _denIconHelper.init(uint(param1.giftId << 16 | DenItem.getIconId(_loc2_.sortCat)),denIconReceived,param1.giftColor,0,0,0,0,0,param1.additionalGiftData);
         }
         else if(param1.type == 4 || param1.type == 9)
         {
            _loc6_ = new MediaHelper();
            if(param1.giftColor != 0)
            {
               _loc6_.init(2254,onDiamondRedeemPopupLoaded,{
                  "diamondDef":param1.giftColor,
                  "numDiamondsReceived":param1.giftId
               });
               _mediaViews.push(_loc6_);
            }
            else if(param1.stampMediaId == 2)
            {
               Utility.setupDiamondRefundPopup(_popupLayer,_numDiamondRefundsReceiving,onAcceptCloseDiamondRefundPopup);
            }
            else
            {
               _loc6_.init(param1.type == 4 ? 1086 : 2221,onMediaHelperIconReceived,param1.stampMediaId);
               _mediaViews.push(_loc6_);
            }
         }
         else if(param1.type == 5)
         {
            _loc3_ = gMainFrame.userInfo.getDenRoomDefByDefId(param1.giftId);
            if(!_loc3_)
            {
               trace("Error loading image for denRoomDefId=" + param1.giftId);
               return;
            }
            _loc4_ = new MediaHelper();
            _loc4_.init(_loc3_.mediaId,onMediaHelperIconReceived);
            _mediaViews.push(_loc4_);
         }
         else if(param1.type == 6 || param1.type == 10)
         {
            _loc7_ = null;
            if(param1.type == 10)
            {
               _loc7_ = AvatarManager.getDefaultAvatarByDefId(param1.giftId,true);
            }
            else
            {
               _loc7_ = AvatarManager.getDefaultAvatarByDefId(param1.giftId);
            }
            if(_loc7_ == null)
            {
               trace("Error loading avatar using avDefId=" + param1.giftId);
               return;
            }
            _avtView = new AvatarView();
            _avtView.init(_loc7_);
            _avtView.playAnim(13,false,1,avatarViewReceived);
            _hasRedeemedAvatar = true;
         }
         else if(param1.type == 8)
         {
            _numPetsToCreate = _numPetsToCreate + 1;
            if(param1.stampMediaId > 0)
            {
               GuiManager.openJumpPopup(true,onJumpPopupClose,null,param1.giftId);
            }
            else
            {
               PetManager.openPetFinder(PetManager.petNameForDefId(param1.giftId),keepPetCallback,true);
            }
         }
         else if(param1.type == 12)
         {
            if(!AdoptAPetManager.hasAtLeastOneUsableAdoptAPet)
            {
               AdoptAPetManager.shouldShowFirstAdoptAPetPopup = true;
            }
            _loc5_ = 0;
            while(_loc5_ < _adoptAPetCardsReceiving.length)
            {
               AdoptAPetManager.setUsableAdoptAPetDef(_adoptAPetCardsReceiving[_loc5_].giftId);
               _loc5_++;
            }
            _redemptionList.splice(0,1);
            keepGiftCallback();
         }
         else if(param1.type != 7)
         {
            ECardXtCommManager.sendECardAcceptDiscardGiftRequest(param1.msgId,true,onGiftAcceptRejectResponse);
         }
      }
      
      private function avatarViewReceived(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Sprite = new Sprite();
         _loc3_.addChild(_avtView);
         var _loc4_:Point = AvatarUtility.getAvOffsetByDefId(_avtView.avTypeId);
         _avtView.x = _loc4_.x;
         _avtView.y = _loc4_.y;
         setupGiftPopup(_loc3_);
      }
      
      private function clothingIconReceived() : void
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.addChild(_clothingIcon);
         _loc1_.x = -_loc1_.width * 0.5;
         _loc1_.y = -_loc1_.height * 0.5;
         setupGiftPopup(_loc1_);
      }
      
      private function denIconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Number = NaN;
         if(param1 && param1.displayObject)
         {
            _loc2_ = new Sprite();
            _loc3_ = 168 / Math.max(param1.displayObject.width,param1.displayObject.height);
            param1.displayObject.width *= _loc3_;
            param1.displayObject.height *= _loc3_;
            _loc2_.addChild(param1.displayObject);
            _loc2_.x = -_loc2_.width * 0.5;
            _loc2_.y = -_loc2_.height * 0.5;
            setupGiftPopup(_loc2_);
         }
      }
      
      private function onMediaHelperIconReceived(param1:MovieClip) : void
      {
         if(param1.passback > 0)
         {
            if(param1.passback == 1)
            {
               GuiManager.openJumpPopup(false,onJumpPopupClose,param1,_numJumpGemsReceiving);
            }
         }
         else
         {
            setupGiftPopup(param1);
         }
      }
      
      private function onJumpPopupClose(param1:Boolean, param2:int, param3:MovieClip = null) : void
      {
         if(param1)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId(param2),keepPetCallback,true);
         }
         else
         {
            _redemptionList.splice(0,1);
            keepGiftCallback();
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
            if(_extendingMembershipJAGMsgId > 0)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_extendingMembershipJAGMsgId,false,onExtendingMembershipResponse);
               _extendingMembershipJAGMsgId = 0;
            }
            DarkenManager.unDarken(_loc2_);
            _loc2_.visible = false;
            _loc2_ = null;
            _imageBeingLoaded = false;
            loadNextPopup();
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
         SBTracker.trackPageview("/game/play/popup/newMemberFeatures",-1,1);
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
         var _loc3_:String = gMainFrame.clientInfo.websiteURL + "membership";
         var _loc2_:URLRequest = new URLRequest(_loc3_);
         try
         {
            navigateToURL(_loc2_,"_blank");
         }
         catch(e:Error)
         {
         }
      }
      
      private function onSaveDiamonds(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14802,_diamondRedeemPopup.numDiamondsReceived),true,destroyDiamondRedeemPopup);
      }
      
      private function onRedeemDiamonds(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AvatarSwitch.addAvatar(AvatarSwitch.avatars.length,false,onAvatarAdded,false,false,false,_diamondRedeemPopup.diamondItem.refDefId,true,172,_diamondRedeemPopup.diamondItem.defId);
      }
      
      private function onAvatarAdded(param1:int) : void
      {
         if(param1 == 1)
         {
            destroyDiamondRedeemPopup();
         }
         else if(param1 == -1)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(11382,_diamondRedeemPopup.avatarName),true,destroyDiamondRedeemPopup);
         }
         else
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(11225),true,destroyDiamondRedeemPopup);
         }
      }
   }
}

