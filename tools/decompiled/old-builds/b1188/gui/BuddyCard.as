package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
   import buddy.Buddy;
   import buddy.BuddyEvent;
   import buddy.BuddyXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFClient;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenXtCommManager;
   import ecard.ECardManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gskinner.motion.GTween;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetXtCommManager;
   import playerWall.PlayerWallManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TradeXtCommManager;
   
   public class BuddyCard
   {
      
      private static var _buddyCardPopup:SBPopup;
      
      private static var _buddyCardMC:MovieClip;
      
      private static var _popupLayer:DisplayLayer;
      
      private static var _buddyRoomTimer:Timer;
      
      private static var _buddyRoomName:String;
      
      private static var _buddyShardId:int;
      
      private static var _buddyRoomDisplayName:String;
      
      private static var _isDropDownOpen:Boolean;
      
      private static var _isGameTabOpen:Boolean;
      
      private static var _isTradingTabOpen:Boolean;
      
      private static var _achievementTimeStamp:Number;
      
      private static var _petsTimeStamp:Number;
      
      private static var _avatarTimeStamp:Number;
      
      private static var _shouldDarkenBuddyCard:Boolean;
      
      private static var _mainAvatarView:AvatarView;
      
      private static var _currPerUserAvId:int;
      
      private static var _currPetIdx:int;
      
      private static var _currUserName:String;
      
      private static var _currUserNameModerated:String;
      
      private static var _currUserAccountType:int;
      
      private static var _currUserIsBuddy:Boolean;
      
      private static var _currUserIsArchived:Boolean;
      
      private static var _currUserIsBlocked:Boolean;
      
      private static var _currUserIsOnline:Boolean;
      
      private static var _offlineBuddyAvatar:Avatar;
      
      private static var _avatarViews:Array;
      
      private static var _playerAvatars:Array;
      
      private static var _pvpGameList:Array;
      
      private static var _tradeList:Array;
      
      private static var _views:Array;
      
      private static var _itemWindows:WindowGenerator;
      
      private static var _pvpItemWindows:WindowGenerator;
      
      private static var _dropDownScrollbar:SBScrollbar;
      
      private static var _pvpScrollBar:SBScrollbar;
      
      private static var _tradeItemWindows:WindowGenerator;
      
      private static var _tradeScrollBar:SBScrollbar;
      
      private static var _madeChars:Boolean;
      
      private static var _numberOfAvatars:int;
      
      private static var _userInfo:UserInfo;
      
      private static var _achievements:Array;
      
      private static var _pets:Array;
      
      private static var _petViews:Array;
      
      private static var _mainPetView:GuiPet;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _loadingSpiralDropDown:LoadingSpiral;
      
      private static var _loadingSpiralAvatar:LoadingSpiral;
      
      private static var _loadingSpiralPullOut:LoadingSpiral;
      
      private static var _buddyListFullPopup:SBPopup;
      
      private static var _reportAPlayer:ReportAPlayer;
      
      private static var _numViewsLoaded:int;
      
      private static var _currNameBarData:int;
      
      private static var _isFromUserClickRequest:Boolean;
      
      private static const BUDDY_POPUP_X:int = 715;
      
      private static const BUDDY_POPUP_Y:int = 142;
      
      private static const REQUEST_INTERVAL:int = 10000;
      
      private static const TRADE_TUT_LIST_ID:int = 22;
      
      private static const LOADING_SPIRAL_SMALL:int = 397;
      
      private static var _bDropDownTweenFinished:Boolean = true;
      
      private static var _sideMenuTweenFinished:Boolean = true;
      
      public function BuddyCard()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer) : void
      {
         _popupLayer = param1;
         _buddyRoomTimer = new Timer(gMainFrame.clientInfo.buddyRoomTimerInterval);
         _buddyRoomTimer.addEventListener(TimerEvent.TIMER,buddyRoomTimerHandler,false,0,true);
         _avatarViews = new Array();
         _playerAvatars = new Array();
         _achievements = new Array();
         _pets = new Array();
         _petViews = new Array();
         _tradeList = new Array();
         _madeChars = false;
         BuddyManager.eventDispatcher.addEventListener(BuddyEvent.BUDDY_CHANGED,buddyChangedHandler,false,0,true);
      }
      
      public static function destroy() : void
      {
         destroyCard();
         _avatarViews = null;
         _playerAvatars = null;
         _shouldDarkenBuddyCard = false;
         if(_buddyRoomTimer)
         {
            _buddyRoomTimer.reset();
            _buddyRoomTimer.removeEventListener(TimerEvent.TIMER,buddyRoomTimerHandler);
            _buddyRoomTimer = null;
         }
         _loadingSpiralDropDown.destroy();
         _loadingSpiralAvatar.destroy();
         _loadingSpiralPullOut.destroy();
         AvatarManager.buddyCardAvatarView = null;
      }
      
      private static function destroyCard() : void
      {
         _buddyRoomDisplayName = "";
         _currUserName = "";
         _currUserNameModerated = "";
         _currUserAccountType = 0;
         _currNameBarData = 0;
         _currPerUserAvId = -1;
         _currPetIdx = -1;
         _buddyRoomName = "";
         _buddyShardId = -1;
         _currUserIsBuddy = false;
         _currUserIsArchived = false;
         _currUserIsBlocked = false;
         _currUserIsOnline = false;
         destroyCharacters();
         if(_shouldDarkenBuddyCard)
         {
            DarkenManager.unDarken(_buddyCardPopup);
         }
         if(_mainAvatarView)
         {
            _mainAvatarView.destroy();
            _mainAvatarView = null;
         }
         if(_mainPetView)
         {
            _mainPetView.destroy();
            _mainPetView = null;
         }
         if(_buddyCardPopup)
         {
            _buddyCardPopup.closeCallback = null;
            _buddyCardPopup.destroy();
         }
         if(_pvpItemWindows)
         {
            if(_pvpItemWindows.parent)
            {
               _pvpItemWindows.parent.removeChild(_pvpItemWindows);
            }
            _pvpItemWindows.destroy();
            _pvpItemWindows = null;
         }
         if(_pvpScrollBar)
         {
            _pvpScrollBar.destroy();
            _pvpScrollBar = null;
         }
         if(_tradeItemWindows)
         {
            if(_tradeItemWindows.parent)
            {
               _tradeItemWindows.parent.removeChild(_tradeItemWindows);
            }
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         if(_tradeScrollBar)
         {
            _tradeScrollBar.destroy();
            _tradeScrollBar = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _buddyCardMC = null;
         AvatarManager.buddyCardAvatarView = null;
      }
      
      private static function destroyCharacters() : void
      {
         if(_dropDownScrollbar)
         {
            _dropDownScrollbar.destroy();
            _dropDownScrollbar = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
      }
      
      public static function showBuddyCard(param1:Object, param2:Boolean = false) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:UserInfo = null;
         var _loc7_:String = null;
         var _loc8_:Buddy = null;
         var _loc9_:AvatarInfo = null;
         var _loc3_:String = param1.userName;
         var _loc4_:int = int(param1.onlineStatus);
         _loc5_ = _loc4_ == SFClient.STATUS_OFFLINE_ARCHIVED;
         if(_loc5_)
         {
            _loc6_ = gMainFrame.userInfo.getUserInfoByUserName(_loc3_);
            if(_loc6_)
            {
               _loc6_.setTimeOfLastAchievementRequest(0);
            }
         }
         if(_currUserName != _loc3_)
         {
            _loc7_ = gMainFrame.server.getCurrentRoomName(false);
            _avatarTimeStamp = 0;
            _achievementTimeStamp = 0;
            _petsTimeStamp = 0;
            destroyCard();
            _shouldDarkenBuddyCard = param2;
            _currUserIsArchived = _loc5_;
            _currUserName = _loc3_;
            _isDropDownOpen = false;
            _isGameTabOpen = false;
            _isTradingTabOpen = false;
            _buddyCardMC = GETDEFINITIONBYNAME("BuddyCardContent");
            _buddyCardMC.locationPopup.visible = false;
            _buddyCardMC.buddyAvNamePopup.visible = false;
            _buddyCardMC.awardsPopup.visible = false;
            _buddyCardMC.awardsBtnUp.visible = false;
            _buddyCardMC.tradeHelpPopup.visible = false;
            _buddyCardMC.goToBtn.activateGrayState(true);
            _buddyCardMC.petCodeBlock.visible = false;
            _buddyCardMC.shamanTag.visible = false;
            _buddyCardMC.shamanBlock.visible = false;
            _buddyCardMC.petsBtnUp.visible = false;
            _buddyCardMC.charsBtnUp.visible = false;
            _buddyCardMC.awardsBtnUp.visible = true;
            _buddyCardMC.petsBtnDn.visible = true;
            _buddyCardMC.locationPopupTxt.text = LocalizationManager.translateIdOnly(11234);
            _buddyRoomDisplayName = _buddyCardMC.locationPopupTxt.text;
            _buddyCardMC.avatarNameTxt.text = "";
            _buddyCardMC.userNameTxt.text = "";
            _buddyCardMC.locationPopup.tooltipCont.visible = false;
            _loadingSpiralAvatar = new LoadingSpiral(_buddyCardMC.charBox);
            if(_loc7_ != "den" + _loc3_ && shouldGrayOut())
            {
               _buddyCardMC.denBtn.activateGrayState(false);
            }
            else
            {
               _buddyCardMC.denBtn.activateGrayState(true);
            }
            if(_loc4_ < SFClient.STATUS_ONLINE || shouldGrayOut())
            {
               if(_buddyCardMC.tradeTabBtn.hasGrayState)
               {
                  _buddyCardMC.tradeTabBtn.activateGrayState(true);
               }
               if(_buddyCardMC.gameTabBtn.hasGrayState)
               {
                  _buddyCardMC.gameTabBtn.activateGrayState(true);
               }
            }
            _buddyCardPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("BuddyCardSkin"),_buddyCardMC);
            _buddyCardPopup.x = BUDDY_POPUP_X;
            _buddyCardPopup.y = BUDDY_POPUP_Y;
            _buddyCardPopup.closeCallback = closeBuddyCard;
            addCardListeners();
            if(_shouldDarkenBuddyCard)
            {
               DarkenManager.darken(_buddyCardPopup);
            }
            _loc8_ = BuddyManager.getBuddyByUserName(_loc3_);
            _currUserIsBuddy = _loc8_ != null;
            if(_currUserIsBuddy)
            {
               _currUserIsOnline = _loc8_.isOnline;
               _buddyCardMC.avatarNameTxt.text = "";
               _buddyCardMC.userNameTxt.text = _loc8_.userNameModerated;
               if(_currUserIsOnline)
               {
                  BuddyXtCommManager.sendBuddyRoomRequest(_loc3_);
                  _buddyRoomTimer.start();
                  _buddyCardMC.locationPopupTxt.text = LocalizationManager.translateIdOnly(11234);
               }
               else
               {
                  LocalizationManager.translateId(_buddyCardMC.locationPopupTxt,11235);
               }
               resizeLocationToolTip();
            }
            else
            {
               _buddyCardMC.userNameTxt.text = _currUserName;
               BuddyXtCommManager.sendBuddyRoomRequest(_loc3_);
            }
            _buddyCardMC.addBuddyBtn.visible = !_currUserIsBuddy;
            _buddyCardMC.removeBuddyBtn.visible = _currUserIsBuddy;
            _currUserIsBlocked = BuddyManager.isBlocked(_currUserName);
            _buddyCardMC.blockBtn.visible = !_currUserIsBlocked;
            _buddyCardMC.unblockBtn.visible = _currUserIsBlocked;
            if(gMainFrame.userInfo.isModerator)
            {
               if(_loc7_ != "den" + _loc3_)
               {
                  _buddyCardMC.denBtn.activateGrayState(false);
               }
            }
            if(!_loadingSpiralDropDown)
            {
               _loadingSpiralDropDown = new LoadingSpiral(_buddyCardMC.dropDown.itemWindow,_buddyCardMC.dropDown.itemWindow.width * 0.5,_buddyCardMC.dropDown.itemWindow.height * 0.5);
            }
            else
            {
               _loadingSpiralDropDown.setNewParent(_buddyCardMC.dropDown.itemWindow,_buddyCardMC.dropDown.itemWindow.width * 0.5,_buddyCardMC.dropDown.itemWindow.height * 0.5);
            }
            _loadingSpiralDropDown.visible = false;
            if(!_loadingSpiralPullOut)
            {
               _loadingSpiralPullOut = new LoadingSpiral(_buddyCardMC.tradeTabItemWindow,_buddyCardMC.tradeTabItemWindow.width * 0.5 + 15,_buddyCardMC.tradeTabItemWindow.height * 0.5);
            }
            _loadingSpiralPullOut.visible = false;
            setupAllGrayStates(true);
            if(!_loc5_)
            {
               _buddyCardMC.charBox.gotoAndStop(1);
               _loc9_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc3_);
               if(!_loc9_)
               {
                  AvatarXtCommManager.requestAvatarGet(_loc3_,onAvatarGetReceived);
                  return;
               }
               onAvatarGetReceived(_loc3_,true,_loc4_,_loc9_);
            }
            else
            {
               SBTracker.trackPageview("game/play/popup/buddyCard/archived",-1,SBTracker.TYPE_EVENT);
            }
         }
      }
      
      private static function setupAllGrayStates(param1:Boolean) : void
      {
         if(param1)
         {
            _buddyCardMC.charBox.gotoAndStop(4);
            if(_currUserIsArchived)
            {
               _loadingSpiralAvatar.visible = false;
            }
            clearPetAndAvatarViews();
            _currPerUserAvId = -1;
            _currPetIdx = -1;
            _buddyCardMC.avatarNameTxt.text = "";
         }
         if(!_currUserIsBuddy)
         {
            _buddyCardMC.addBuddyBtn.activateGrayState(param1);
         }
         _buddyCardMC.denBtn.activateGrayState(param1);
         if(!param1 && !MinigameManager.inMinigame())
         {
            _buddyCardMC.mailBtn.activateGrayState(param1);
         }
         if(_currUserIsArchived)
         {
            _buddyCardMC.blockBtn.visible = true;
            _buddyCardMC.unblockBtn.visible = false;
            _buddyCardMC.dropDown.visible = false;
            _buddyCardMC.memberKey.visible = false;
            _buddyCardMC.memberNameBar.visible = false;
            _buddyCardMC.goToBtn.activateGrayState(true);
         }
         _buddyCardMC.blockBtn.activateGrayState(param1);
         _buddyCardMC.reportBtn.activateGrayState(param1);
      }
      
      private static function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:AvatarInfo = null) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Avatar = null;
         var _loc7_:UserInfo = null;
         if(param2 && param1.toLowerCase() == _currUserName.toLowerCase())
         {
            _currUserName = param1;
            if(param3 == SFClient.STATUS_OFFLINE_ARCHIVED)
            {
               resetBuddyCardForArchiveMode();
               return;
            }
            if(param3 == SFClient.STATUS_DIFFERENT_VERSION)
            {
               closeBuddyCard();
               return;
            }
            if(!param4)
            {
               param4 = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
               if(!param4)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            setupAllGrayStates(false);
            if(!_currUserIsBuddy)
            {
               if(!_buddyCardMC.denBtn.isGray && !_currUserIsArchived)
               {
                  DenXtCommManager.requestUserDenPrivacy(_currUserName);
               }
            }
            _loc5_ = param4.perUserAvId;
            _loc6_ = AvatarManager.getAvatarByUserName(_currUserName);
            if(_loc6_ == null)
            {
               if(_offlineBuddyAvatar == null)
               {
                  _offlineBuddyAvatar = AvatarUtility.generateNew(_loc5_,null,_currUserName,-1,0,onAvatarItemData);
               }
               else if(_offlineBuddyAvatar.userName != param4.userName)
               {
                  _offlineBuddyAvatar.destroy();
                  _offlineBuddyAvatar = AvatarUtility.generateNew(_loc5_,null,_currUserName,-1,0,onAvatarItemData);
               }
               _loc6_ = _offlineBuddyAvatar;
            }
            _loc7_ = gMainFrame.userInfo.getUserInfoByUserName(_currUserName);
            _currUserNameModerated = _loc7_.getModeratedUserName();
            _currUserAccountType = _loc7_.getAccountType();
            if(param4.isMember)
            {
               _currNameBarData = _loc7_.nameBarData;
               _buddyCardMC.nonmemberNameBar.visible = false;
               _buddyCardMC.memberNameBar.nubType = "";
               _buddyCardMC.memberNameBar.setColorAndBadge(_loc7_.nameBarData);
               _buddyCardMC.memberNameBar.isBlocked = false;
               _buddyCardMC.memberNameBar.setAvName(_currUserNameModerated,false);
               _buddyCardMC.userNameTxt.visible = false;
               _buddyCardMC.memberNameBar.mouseEnabled = false;
               _buddyCardMC.memberNameBar.mouseChildren = false;
            }
            else
            {
               _buddyCardMC.memberKey.visible = false;
               _buddyCardMC.memberNameBar.visible = false;
            }
            _buddyCardMC.userNameTxt.text = _currUserNameModerated;
            drawMainAvatar(_loc6_,true);
            _currPerUserAvId = _loc5_;
            if((Boolean(_loc7_ && _loc7_.isGuide) || Boolean(_loc6_.isShaman)) && !(Boolean(gMainFrame.userInfo.isModerator) || Boolean(gMainFrame.userInfo.isGuide)))
            {
               if(Boolean(_loc7_) && _loc7_.isGuide)
               {
                  _buddyCardMC.memberNameBar.setAvName(LocalizationManager.translateIdOnly(11236),false);
                  _buddyCardMC.shamanDescTxt.text = getGuideText(_loc6_.userName);
                  _buddyCardMC.shamanDescTxt.height = _buddyCardMC.shamanDescTxt.textHeight + 5;
                  _buddyCardMC.shamanDescTxt.y = 0 - _buddyCardMC.shamanDescTxt.height / 2;
               }
               else
               {
                  _buddyCardMC.memberNameBar.setAvName(LocalizationManager.translateIdOnly(11237),false);
                  _buddyCardMC.avatarNameTxt.text = _loc6_.shamanName;
                  _buddyCardMC.shamanDescTxt.text = _loc6_.shamanText;
                  _buddyCardMC.shamanDescTxt.height = _buddyCardMC.shamanDescTxt.textHeight + 5;
                  _buddyCardMC.shamanDescTxt.y = 0 - _buddyCardMC.shamanDescTxt.height / 2;
               }
               _buddyCardMC.allBtns.visible = false;
               _buddyCardMC.shamanBlock.visible = true;
               _buddyCardMC.shamanTag.visible = true;
               _buddyCardMC.goToBtn.visible = false;
               _buddyCardMC.dropDown.visible = false;
               _buddyCardMC.tradeTabBtn.activateGrayState(true);
               _buddyCardMC.gameTabBtn.activateGrayState(true);
            }
            else
            {
               _buddyCardMC.shamanBlock.visible = false;
               _buddyCardMC.shamanTag.visible = false;
            }
            if(shouldGrayOut())
            {
               if(!_buddyCardMC.goToBtn.isGray)
               {
                  _buddyCardMC.goToBtn.activateGrayState(true);
               }
               if(!_buddyCardMC.denBtn.isGray)
               {
                  _buddyCardMC.denBtn.activateGrayState(true);
               }
            }
         }
         else
         {
            closeBuddyCard();
         }
      }
      
      private static function drawMainAvatar(param1:Avatar, param2:Boolean = false) : void
      {
         var _loc3_:AvatarInfo = null;
         if(Boolean(_buddyCardMC) && (_currPerUserAvId != param1.perUserAvId || param2))
         {
            if(Utility.isOcean(param1.enviroTypeFlag))
            {
               if(Utility.isLand(param1.enviroTypeFlag))
               {
                  _buddyCardMC.charBox.gotoAndStop(3);
               }
               else
               {
                  _buddyCardMC.charBox.gotoAndStop(2);
               }
            }
            else
            {
               _buddyCardMC.charBox.gotoAndStop(1);
            }
            clearPetAndAvatarViews();
            _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(param1.userName,param1.perUserAvId);
            if(Boolean(_loc3_) && _loc3_.questLevel > 0)
            {
               loadXPShape(_loc3_.questLevel);
            }
            else
            {
               _buddyCardMC.xpShape.visible = false;
            }
            _mainAvatarView = new AvatarView();
            _mainAvatarView.init(param1);
            if(param1.avTypeId >= 0)
            {
               _mainAvatarView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,positionAndAddMainAvatarView);
            }
            _buddyCardMC.avatarNameTxt.text = param1.avName;
            _currPetIdx = -1;
            _currPerUserAvId = param1.perUserAvId;
            AvatarManager.buddyCardAvatarView = _mainAvatarView;
         }
      }
      
      private static function loadXPShape(param1:int) : void
      {
         var _loc2_:int = Utility.getColorId(_currNameBarData);
         if(_buddyCardMC.xpShape.currentFrame != _loc2_)
         {
            _buddyCardMC.xpShape.gotoAndStop(_loc2_);
         }
         Utility.createXpShape(param1,!_buddyCardMC.nonmemberNameBar.visible,_buddyCardMC.xpShape[_buddyCardMC.xpShape.currentLabels[_loc2_ - 1].name].mouse.up.icon,null,int.MAX_VALUE);
      }
      
      public static function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && _offlineBuddyAvatar != null)
         {
            drawMainAvatar(_offlineBuddyAvatar,true);
         }
         else
         {
            closeBuddyCard();
         }
      }
      
      private static function shouldGrayOut() : Boolean
      {
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST || MinigameManager.inMinigame())
         {
            return true;
         }
         return false;
      }
      
      private static function clearPetAndAvatarViews() : void
      {
         if(_mainPetView)
         {
            if(_buddyCardMC.charBox.contains(_mainPetView))
            {
               _buddyCardMC.charBox.removeChild(_mainPetView);
            }
            _mainPetView = null;
         }
         if(_mainAvatarView)
         {
            if(_buddyCardMC.charBox.contains(_mainAvatarView))
            {
               _buddyCardMC.charBox.removeChild(_mainAvatarView);
            }
            _mainAvatarView.destroy();
            _mainAvatarView = null;
         }
      }
      
      private static function drawMainPet(param1:GuiPet) : void
      {
         var _loc2_:int = 0;
         if(_currPetIdx != param1.idx)
         {
            _buddyCardMC.charBox.gotoAndStop(1);
            _loadingSpiralAvatar = new LoadingSpiral(_buddyCardMC.charBox);
            if(_mainPetView)
            {
               if(_buddyCardMC.charBox.contains(_mainPetView))
               {
                  _buddyCardMC.charBox.removeChild(_mainPetView);
               }
               _mainPetView = null;
            }
            if(_mainAvatarView)
            {
               if(_buddyCardMC.charBox.contains(_mainAvatarView))
               {
                  _buddyCardMC.charBox.removeChild(_mainAvatarView);
               }
               _mainAvatarView.destroy();
               _mainAvatarView = null;
               AvatarManager.buddyCardAvatarView = null;
            }
            _currPerUserAvId = -1;
            _currPetIdx = param1.idx;
            _loc2_ = 0;
            while(_loc2_ < _pets.length)
            {
               if(_pets[_loc2_].idx == _currPetIdx)
               {
                  createMainPetView(_loc2_);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      private static function createMainPetView(param1:int) : void
      {
         _mainPetView = new GuiPet(_pets[param1].idx,_pets[param1].lBits,_pets[param1].uBits,_pets[param1].eBits,_pets[param1].type,_pets[param1].name,onMainPetLoaded);
         _buddyCardMC.avatarNameTxt.text = _mainPetView.petName;
         if(Boolean(_buddyCardPopup) && Boolean(_buddyCardMC))
         {
            if(_mainPetView.canGoOnLand() && !_mainPetView.canGoInOcean() || AvatarManager.roomEnviroType == SbiConstants.ENVIRO_LAND && _mainPetView.canGoOnLand())
            {
               _buddyCardMC.charBox.gotoAndStop(1);
            }
            else
            {
               _buddyCardMC.charBox.gotoAndStop(2);
            }
            _buddyCardMC.charBox.addChild(_mainPetView);
         }
      }
      
      private static function onMainPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _mainPetView.y += _buddyCardMC.charBox.height * 0.4;
         _mainPetView.scaleX = _mainPetView.scaleY = 4.5;
         _loadingSpiralAvatar.visible = false;
      }
      
      private static function positionAndAddMainAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = getAvOffsetByDefId(_mainAvatarView.avTypeId);
         _mainAvatarView.x = _loc3_.x;
         _mainAvatarView.y = _loc3_.y;
         if(Boolean(_buddyCardPopup) && Boolean(_buddyCardMC))
         {
            _buddyCardMC.charBox.addChild(_mainAvatarView);
         }
         _loadingSpiralAvatar.visible = false;
      }
      
      public static function getAvOffsetByDefId(param1:int) : Point
      {
         switch(param1)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               return new Point(120,35);
            case SharedAvatarAnimalConstants.AV_EAGLE:
               return new Point(92,140);
            case SharedAvatarAnimalConstants.AV_WOLF:
               return new Point(134,54);
            case SharedAvatarAnimalConstants.AV_KOALA:
               return new Point(125,58);
            case SharedAvatarAnimalConstants.AV_PANDA:
               return new Point(125,55);
            case SharedAvatarAnimalConstants.AV_MONKEY:
               return new Point(138,50);
            case SharedAvatarAnimalConstants.AV_BUNNY:
               return new Point(130,72);
            case SharedAvatarAnimalConstants.AV_RHINO:
               return new Point(120,88);
            case SharedAvatarAnimalConstants.AV_CROC:
               return new Point(134,90);
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               return new Point(125,53);
            case SharedAvatarAnimalConstants.AV_SEAL:
               return new Point(128,41);
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               return new Point(125,80);
            case SharedAvatarAnimalConstants.AV_SHARK:
               return new Point(128,85);
            case SharedAvatarAnimalConstants.AV_LION:
               return new Point(138,60);
            case SharedAvatarAnimalConstants.AV_HORSE:
               return new Point(132,80);
            case SharedAvatarAnimalConstants.AV_TURTLE:
               return new Point(122,70);
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               return new Point(125,60);
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               return new Point(125,79);
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               return new Point(122,65);
            case SharedAvatarAnimalConstants.AV_FOX:
               return new Point(126,75);
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               return new Point(126,92);
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               return new Point(130,110);
            case SharedAvatarAnimalConstants.AV_RACCOON:
               return new Point(110,105);
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               return new Point(121,70);
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               return new Point(125,65);
            case SharedAvatarAnimalConstants.AV_DEER:
               return new Point(135,75);
            case SharedAvatarAnimalConstants.AV_HYENA:
               return new Point(145,75);
            case SharedAvatarAnimalConstants.AV_OTTER:
               return new Point(130,72);
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               return new Point(125,72);
            case SharedAvatarAnimalConstants.AV_OWL:
               return new Point(132,75);
            default:
               return new Point(115,110);
         }
      }
      
      private static function checkBuddyRoomAgainstMine(param1:Boolean) : void
      {
         var _loc2_:Buddy = null;
         if(gMainFrame.server.getCurrentRoomName() != _buddyRoomName)
         {
            _loc2_ = BuddyManager.getBuddyByUserName(_currUserName);
            if(Boolean(!param1) && Boolean(_loc2_) && _loc2_.isOnline)
            {
               if(Boolean(_buddyCardMC.goToBtn.isGray) && !shouldGrayOut())
               {
                  _buddyCardMC.goToBtn.activateGrayState(false);
               }
            }
            else if(!_buddyCardMC.goToBtn.isGray)
            {
               _buddyCardMC.goToBtn.activateGrayState(true);
            }
         }
         else
         {
            _buddyCardMC.goToBtn.activateGrayState(true);
         }
      }
      
      public static function userNameChange(param1:String, param2:String, param3:String) : void
      {
         if(Boolean(param1) && Boolean(param2))
         {
            if(_currUserName.toLowerCase() == param1.toLowerCase())
            {
               _currUserName = param2;
               _currUserNameModerated = param3;
            }
            if(_buddyCardMC)
            {
               _buddyCardMC.memberNameBar.setAvName(_currUserNameModerated,false);
               _buddyCardMC.userNameTxt.text = _currUserNameModerated;
            }
         }
      }
      
      public static function updateCurrBuddyCardAvatar(param1:Avatar = null) : void
      {
         if(param1 == null)
         {
            param1 = _offlineBuddyAvatar;
         }
         else if(Boolean(_buddyCardMC) && _buddyCardMC.visible)
         {
            drawMainAvatar(param1);
         }
         if(_mainAvatarView)
         {
            _mainAvatarView.resetAvatar(param1);
         }
         if(Boolean(_buddyCardMC) && Boolean(_buddyCardMC.avatarNameTxt))
         {
            _buddyCardMC.avatarNameTxt.text = param1.avName;
         }
         if(_isDropDownOpen && Boolean(_buddyCardMC.charsBtnUp.visible))
         {
            requestAvatarList();
         }
      }
      
      public static function updateDropDown(param1:String) : void
      {
         if(Boolean(_currUserName && _currUserName.toLowerCase() == param1.toLowerCase()) && Boolean(_isDropDownOpen) && Boolean(_buddyCardMC.charsBtnUp.visible) && !_isFromUserClickRequest)
         {
            requestAvatarList();
         }
      }
      
      public static function avatarLeftRoom() : void
      {
         if(BuddyManager.isBuddy(_currUserName) || Boolean(gMainFrame.userInfo.isModerator))
         {
            _buddyCardMC.locationPopupTxt.text = LocalizationManager.translateIdOnly(11234);
            _buddyRoomDisplayName = _buddyCardMC.locationPopupTxt.text;
            _buddyRoomTimer.start();
            resizeLocationToolTip();
         }
         else
         {
            _buddyCardMC.goToBtn.activateGrayState(true);
            _buddyCardMC.locationPopupTxt.text = _buddyRoomDisplayName = "";
         }
      }
      
      public static function grayOutGoToDenBtn(param1:Boolean, param2:String = "") : void
      {
         if(_buddyCardMC)
         {
            if(param1 && shouldGrayOut())
            {
               return;
            }
            _buddyCardMC.goToBtn.activateGrayState(param1);
            if(param2 == null || _currUserName.toLowerCase() == param2.toLowerCase())
            {
               _buddyCardMC.denBtn.activateGrayState(param1);
            }
         }
      }
      
      public static function resetBuddyCardForArchiveMode() : void
      {
         var _loc1_:String = _currUserName;
         _currUserName = null;
         _currUserNameModerated = "";
         _currUserAccountType = 0;
         showBuddyCard({
            "userName":_loc1_,
            "onlineStatus":SFClient.STATUS_OFFLINE_ARCHIVED
         });
      }
      
      public static function closeBuddyCard() : void
      {
         _buddyRoomTimer.reset();
         removeCardListeners();
         destroyCard();
      }
      
      private static function addRemoveBlockDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(BuddyManager.isBlocked(_currUserName))
            {
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14699,_currUserNameModerated),true,buddyCardRemoveIgnoreConfirmCallback);
            }
            else
            {
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14700,_currUserNameModerated),true,buddyCardAddIgnoreConfirmCallback);
            }
         }
      }
      
      private static function addRemoveBlockDownOverHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(BuddyManager.isBlocked(_currUserName))
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14628),790,200);
               GuiManager.toolTip.startTimer(param1);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14629),790,200);
               GuiManager.toolTip.startTimer(param1);
            }
         }
      }
      
      private static function requestAvatarList(param1:Boolean = false) : void
      {
         _loadingSpiralDropDown.visible = true;
         _isFromUserClickRequest = param1;
         AvatarXtCommManager.requestAvatarList([1,_currUserName],drawAvatarsInDropDown);
      }
      
      private static function drawAvatarsInDropDown(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Avatar = null;
         var _loc7_:AvatarView = null;
         if(param1)
         {
            resetBuddyCardForArchiveMode();
            return;
         }
         if(GuiManager.isVersionPopupOpen())
         {
            closeBuddyCard();
            return;
         }
         _userInfo = gMainFrame.userInfo.getUserInfoByUserName(_currUserName);
         if(Boolean(_userInfo) && _currUserName.toLowerCase() == _userInfo.userName.toLowerCase())
         {
            if(_avatarViews)
            {
               _loc4_ = 0;
               while(_loc4_ < _avatarViews.length)
               {
                  _avatarViews[_loc4_].destroy();
                  _avatarViews[_loc4_] = null;
                  _loc4_++;
               }
               _avatarViews.splice(0,_avatarViews.length);
               _avatarViews = null;
            }
            if(_playerAvatars)
            {
               _loc5_ = 0;
               while(_loc5_ < _playerAvatars.length)
               {
                  _playerAvatars[_loc5_].destroy();
                  _playerAvatars[_loc5_] = null;
                  _loc5_++;
               }
               _playerAvatars = null;
            }
            _playerAvatars = new Array();
            _avatarViews = new Array();
            _numViewsLoaded = 0;
            _numberOfAvatars = 0;
            _loc2_ = 0;
            for each(_loc3_ in _userInfo.avList)
            {
               _loc6_ = new Avatar();
               _loc6_.init(_loc3_.perUserAvId,_loc3_.userName,_loc3_.type,_loc3_.colors,_loc3_.customAvId,null,_currUserName);
               _loc6_ = AvatarUtility.generateNew(_loc3_.perUserAvId,_loc6_,_loc3_.userName,AvatarManager.roomEnviroType);
               _playerAvatars.push(_loc6_);
               _loc7_ = new AvatarView();
               _loc7_.init(_loc6_,updateViewPosition);
               _loc7_.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,onViewLoaded);
               _avatarViews.push(_loc7_);
               updateViewPosition(_loc7_);
               _loc2_++;
            }
            _numberOfAvatars = _loc2_;
         }
      }
      
      private static function onViewLoaded(param1:LayerAnim, param2:int) : void
      {
         ++_numViewsLoaded;
         if(_numViewsLoaded == _numberOfAvatars)
         {
            _loadingSpiralDropDown.visible = false;
            if(_isDropDownOpen && Boolean(_buddyCardMC.charsBtnUp.visible))
            {
               createAvatarWindows();
               _isFromUserClickRequest = false;
            }
         }
      }
      
      public static function updateViewPosition(param1:AvatarView) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         switch(param1.avTypeId)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               _loc2_ = 62;
               _loc3_ = 51;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               _loc2_ = 45;
               _loc3_ = 70;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               _loc2_ = 70;
               _loc3_ = 62;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               _loc2_ = 87;
               _loc3_ = 63;
               param1.scaleX = 0.5;
               param1.scaleY = 0.5;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               _loc2_ = 64;
               _loc3_ = 55;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               _loc2_ = 82;
               _loc3_ = 67;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               _loc2_ = 100;
               _loc3_ = 57;
               param1.scaleX = 0.6;
               param1.scaleY = 0.6;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               _loc2_ = 70;
               _loc3_ = 58;
               param1.scaleX = 0.35;
               param1.scaleY = 0.35;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               _loc2_ = 67;
               _loc3_ = 55;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               _loc2_ = 70;
               _loc3_ = 55;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               _loc2_ = 73;
               _loc3_ = 57;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               _loc2_ = 75;
               _loc3_ = 80;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               _loc2_ = 63;
               _loc3_ = 60;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               _loc2_ = 65;
               _loc3_ = 55;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               _loc2_ = 69;
               _loc3_ = 60;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               _loc2_ = 65;
               _loc3_ = 70;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               _loc2_ = 79;
               _loc3_ = 70;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               _loc2_ = 75;
               _loc3_ = 60;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               _loc2_ = 64;
               _loc3_ = 63;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               _loc2_ = 60;
               _loc3_ = 67;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               _loc2_ = 60;
               _loc3_ = 65;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               _loc2_ = 60;
               _loc3_ = 75;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               _loc2_ = 62;
               _loc3_ = 63;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               _loc2_ = 59;
               _loc3_ = 63;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_ = 70;
               _loc3_ = 73;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               _loc2_ = 75;
               _loc3_ = 73;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               _loc2_ = 65;
               _loc3_ = 48;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               _loc2_ = 55;
               _loc3_ = 48;
               param1.scaleX = 0.25;
               param1.scaleY = 0.25;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               _loc2_ = 55;
               _loc3_ = 48;
               param1.scaleX = 0.25;
               param1.scaleY = 0.25;
               break;
            case SharedAvatarAnimalConstants.AV_OWL:
               _loc2_ = 63;
               _loc3_ = 47;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            default:
               _loc2_ = 65;
               _loc3_ = 59;
               param1.scaleX = 0.5;
               param1.scaleY = 0.5;
         }
         param1.x = _loc2_;
         param1.y = _loc3_;
      }
      
      public static function onDenPrivacyResponse(param1:String, param2:Boolean) : void
      {
         if(param1.toLowerCase() == _currUserName.toLowerCase())
         {
            if(_buddyCardMC)
            {
               if(!gMainFrame.userInfo.isModerator && (!shouldGrayOut() || param2))
               {
                  _buddyCardMC.denBtn.activateGrayState(param2);
               }
            }
         }
      }
      
      private static function onPlayerWallPrivacyGet(param1:Boolean, param2:int) : void
      {
         if(param1)
         {
            if(param2 == SbiConstants.PLAYER_WALL_EVERYONE)
            {
               BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
            }
            else if(param2 == SbiConstants.PLAYER_WALL_BUDDIES)
            {
               if(_currUserIsBuddy)
               {
                  BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
               }
            }
         }
      }
      
      public static function onTradeListReceived(param1:String, param2:Array) : void
      {
         if(param1.toLowerCase() == _currUserName.toLowerCase())
         {
            _tradeList = param2;
            createTradeWindows();
         }
      }
      
      public static function getTradeList() : Array
      {
         return _tradeList;
      }
      
      private static function createAvatarWindows() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:MovieClip = null;
         if(_dropDownScrollbar)
         {
            _dropDownScrollbar.destroy();
            _dropDownScrollbar = null;
         }
         if(Boolean(_itemWindows) && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_avatarViews)
         {
            _loc1_ = int(_avatarViews.length);
            _loc2_ = Math.min(_loc1_,4);
            _loc3_ = Math.ceil(_loc2_ / 4);
            _itemWindows = new WindowGenerator();
            _itemWindows.init(_loc2_,_loc3_,_loc1_,2,0,0,ItemWindowAvtPetSml,_avatarViews,"",{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{
               "isMember":!_buddyCardMC.nonmemberNameBar.visible,
               "nameBarData":_currNameBarData
            },null,false,false);
            _buddyCardMC.dropDown.itemWindow.addChild(_itemWindows);
            _loc4_ = 0;
            while(_loc4_ < _loc1_)
            {
               _loc6_ = MovieClip(_itemWindows.bg.getChildAt(_loc4_));
               if(_userInfo.currPerUserAvId == _playerAvatars[_loc4_].perUserAvId)
               {
                  _loc6_.sel.visible = true;
               }
               _loc4_++;
            }
            _loc5_ = Math.ceil(_loc1_ / 4) * 66;
            _dropDownScrollbar = new SBScrollbar();
            _dropDownScrollbar.init(_itemWindows,260,132,0,"scrollbar2",66,0,_loc5_);
         }
      }
      
      private static function requestAchievementsList() : void
      {
         _loadingSpiralDropDown.visible = true;
         AchievementXtCommManager.requestAchievements(_currUserName,achievementListCallback);
      }
      
      private static function achievementListCallback(param1:Array, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         if(param2)
         {
            resetBuddyCardForArchiveMode();
            return;
         }
         _achievements = [];
         if(param1)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _achievements.push(param1[_loc3_]);
               _loc3_++;
            }
         }
         _loadingSpiralDropDown.visible = false;
         if(_isDropDownOpen && Boolean(_buddyCardMC.awardsBtnUp.visible))
         {
            createAchievementsWindows();
         }
      }
      
      private static function createAchievementsWindows() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(_dropDownScrollbar)
         {
            _dropDownScrollbar.destroy();
            _dropDownScrollbar = null;
         }
         if(Boolean(_itemWindows) && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_achievements)
         {
            _loc1_ = int(_achievements.length);
            _loc2_ = Math.min(_loc1_,4);
            _loc3_ = Math.ceil(_loc2_ / 4);
            _itemWindows = new WindowGenerator();
            _itemWindows.init(_loc2_,_loc3_,_loc1_,6,6,0,ItemWindowBase,_achievements,"image",{
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{"itemClassName":"awardSmlCont"},null,false,false);
            _buddyCardMC.dropDown.itemWindow.addChild(_itemWindows);
            _dropDownScrollbar = new SBScrollbar();
            _dropDownScrollbar.init(_itemWindows,260,132,0,"scrollbar2",66);
         }
      }
      
      private static function requestPetsList() : void
      {
         _loadingSpiralDropDown.visible = true;
         PetXtCommManager.sendPetListRequest(_currUserName,petListCallback);
      }
      
      private static function petListCallback(param1:Array, param2:int) : void
      {
         var _loc3_:int = 0;
         if(param2 == 0)
         {
            closeBuddyCard();
            return;
         }
         if(param2 == -1)
         {
            resetBuddyCardForArchiveMode();
            return;
         }
         _pets = [];
         _petViews = [];
         if(param1)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _pets.push(param1[_loc3_]);
               _loc3_++;
            }
         }
         createGuiPets();
         _loadingSpiralDropDown.visible = false;
         if(_isDropDownOpen && Boolean(_buddyCardMC.petsBtnUp.visible))
         {
            createPetsWindows();
         }
      }
      
      private static function createGuiPets() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < _pets.length)
         {
            _petViews.push(new GuiPet(_pets[_loc1_].idx,_pets[_loc1_].lBits,_pets[_loc1_].uBits,_pets[_loc1_].eBits,_pets[_loc1_].type,_pets[_loc1_].name,null));
            _loc1_++;
         }
      }
      
      private static function createPetsWindows() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(_dropDownScrollbar)
         {
            _dropDownScrollbar.destroy();
            _dropDownScrollbar = null;
         }
         if(Boolean(_itemWindows) && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_pets)
         {
            _loc1_ = int(_pets.length);
            _loc2_ = Math.min(_loc1_,4);
            _loc3_ = Math.ceil(_loc2_ / 4);
            _itemWindows = new WindowGenerator();
            _itemWindows.init(_loc2_,_loc3_,_loc1_,2,0,0,ItemWindowAvtPetSml,_petViews,"",{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{"isPet":true},null,false,false);
            _buddyCardMC.dropDown.itemWindow.addChild(_itemWindows);
            _dropDownScrollbar = new SBScrollbar();
            _dropDownScrollbar.init(_itemWindows,260,132,0,"scrollbar2",66);
         }
      }
      
      private static function getPVPIcons() : void
      {
         var _loc2_:MediaHelper = null;
         _views = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < _pvpGameList.length)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(_pvpGameList[_loc1_].gameCardMediaId,mediaHelperCallback,true);
            _views[_loc1_] = _loc2_;
            _loc1_++;
         }
      }
      
      private static function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         while(_loc2_ < _views.length)
         {
            if(_views[_loc2_] == param1.mediaHelper)
            {
               _loc3_ = MovieClip(_pvpItemWindows.bg.getChildAt(_loc2_));
               _loc3_.itemLayer.addChild(param1);
            }
            _loc2_++;
         }
      }
      
      private static function createPVPWindows() : void
      {
         if(_pvpScrollBar)
         {
            _pvpScrollBar.destroy();
            _pvpScrollBar = null;
         }
         if(Boolean(_pvpItemWindows) && _pvpItemWindows.numChildren > 0)
         {
            _pvpItemWindows.destroy();
            _pvpItemWindows = null;
         }
         var _loc1_:int = int(_pvpGameList.length);
         var _loc2_:int = Math.min(_loc1_,2);
         _pvpItemWindows = new WindowGenerator();
         _pvpItemWindows.init(_loc2_,_loc2_,_loc1_,2,2,0,ItemWindowGame,null,"",{
            "mouseDown":sideMenuMouseDown,
            "mouseOver":sideMenuMouseOver,
            "mouseOut":winMouseSideOut
         },null,null,false,false);
         _buddyCardMC.gameTabItemWindow.addChild(_pvpItemWindows);
         _pvpScrollBar = new SBScrollbar();
         _pvpScrollBar.init(_pvpItemWindows,155,156,0,"scrollbar2",78,0,Math.ceil(_loc1_ / _loc2_) * 78);
      }
      
      private static function createTradeWindows() : void
      {
         if(_tradeScrollBar)
         {
            _tradeScrollBar.destroy();
            _tradeScrollBar = null;
         }
         if(_tradeItemWindows)
         {
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         if(Boolean(_tradeItemWindows) && _tradeItemWindows.numChildren > 0)
         {
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         var _loc1_:int = int(_tradeList.length);
         var _loc2_:int = Math.min(_loc1_,2);
         _tradeItemWindows = new WindowGenerator();
         _tradeItemWindows.init(_loc2_,_loc2_,_loc1_,2,2,1,ItemWindowOriginal,_tradeList,"icon",{
            "mouseDown":sideMenuMouseDown,
            "mouseOver":sideMenuMouseOver,
            "mouseOut":winMouseSideOut
         },{"isViewingATradeList":true},null,false,false);
         _buddyCardMC.tradeTabItemWindow.addChild(_tradeItemWindows);
         _loadingSpiralPullOut.visible = false;
         _tradeScrollBar = new SBScrollbar();
         _tradeScrollBar.init(_tradeItemWindows,176,172,0,"scrollbar2",86);
      }
      
      private static function winMouseOver(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.hasOwnProperty("charLayer"))
         {
            GuiManager.toolTip.init(_buddyCardMC.dropDown.itemWindow,_achievements[param1.currentTarget.index].name,param1.currentTarget.x + param1.currentTarget.width * 0.5,param1.currentTarget.y + _itemWindows.y + 50);
            GuiManager.toolTip.startTimer(param1);
         }
         else
         {
            param1.currentTarget.gotoAndStop("over");
            GuiManager.toolTip.init(_buddyCardMC.dropDown.itemWindow,param1.currentTarget.isPet ? _petViews[param1.currentTarget.index].petName : _playerAvatars[param1.currentTarget.index].avName,param1.currentTarget.x + param1.currentTarget.sel.width * 0.5,param1.currentTarget.y + _itemWindows.y + 50);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private static function sideMenuMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(_isGameTabOpen)
         {
            if(param1.currentTarget.parent.numChildren > 0)
            {
               GuiManager.toolTip.init(_buddyCardMC.gameTabItemWindow,LocalizationManager.translateIdOnly(_pvpGameList[param1.currentTarget.index].titleStrId),param1.currentTarget.x + param1.currentTarget.width * 0.5,param1.currentTarget.y + _pvpItemWindows.y + 70);
               GuiManager.toolTip.startTimer(param1);
            }
         }
         else if(_isTradingTabOpen)
         {
            if(param1.currentTarget.numChildren >= 2)
            {
               _loc2_ = param1.currentTarget.getChildAt(1);
               if(param1.currentTarget.cir.currentFrameLabel == "down")
               {
                  param1.currentTarget.cir.gotoAndStop("downMouse");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
               {
                  param1.currentTarget.cir.gotoAndStop("over");
               }
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private static function winMouseSideOut(param1:MouseEvent) : void
      {
         if(_isTradingTabOpen)
         {
            if(param1.currentTarget.numChildren >= 2 && Boolean(param1.currentTarget.cir))
            {
               if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
               {
                  param1.currentTarget.cir.gotoAndStop("down");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "down")
               {
                  param1.currentTarget.cir.gotoAndStop("up");
               }
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function winMouseOut(param1:MouseEvent) : void
      {
         if(Boolean(_isDropDownOpen) && Boolean(_buddyCardMC) && (Boolean(_buddyCardMC.petsBtnUp.visible) || Boolean(_buddyCardMC.charsBtnUp.visible)))
         {
            param1.currentTarget.gotoAndStop("up");
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function winMouseClick(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         param1.currentTarget.gotoAndStop("down");
         var _loc2_:int = 0;
         while(_loc2_ < _itemWindows.bg.numChildren)
         {
            _loc3_ = MovieClip(_itemWindows.bg.getChildAt(_loc2_));
            _loc3_.sel.visible = false;
            _loc2_++;
         }
         param1.currentTarget.sel.visible = true;
         if(param1.currentTarget.isPet)
         {
            _buddyCardMC.xpShape.visible = false;
            drawMainPet(_petViews[param1.currentTarget.index]);
         }
         else
         {
            _buddyCardMC.xpShape.visible = true;
            drawMainAvatar(_playerAvatars[param1.currentTarget.index]);
         }
      }
      
      private static function sideMenuMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Buddy = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         param1.stopPropagation();
         if(_isGameTabOpen)
         {
            if(_buddyShardId != RoomManagerWorld.instance.shardId && _buddyRoomName != gMainFrame.server.getCurrentRoomName())
            {
               _loc4_ = _buddyRoomName.indexOf("_");
               if(_loc4_ > 0 && !isNaN(Number(_buddyRoomName.charAt(_loc4_ - 1))) && !isNaN(Number(_buddyRoomName.charAt(_loc4_ + 1))))
               {
                  new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14701,_currUserNameModerated));
               }
               else if(QuestManager.isInPrivateAdventureState)
               {
                  QuestManager.showLeaveQuestLobbyPopup(sideMenuMouseDown,param1);
               }
               else
               {
                  new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14702),true,onConfirmServerSwitch);
               }
               return;
            }
            _loc3_ = int(_pvpGameList[param1.currentTarget.index].gameDefId);
            if(AvatarManager.isMyUserInCustomPVPState())
            {
               DarkenManager.showLoadingSpiral(true);
               UserCommXtCommManager.sendCustomPVPMessage(false,0,sideMenuMouseDown,param1);
               MinigameManager.readySelfForCustomPVPGame(-1,"");
               return;
            }
            DarkenManager.showLoadingSpiral(false);
            MinigameXtCommManager.sendMinigamePvpMsg(_loc3_,MinigameXtCommManager.PVP_REQUEST_OR_ACCEPT,_currUserName);
            MinigameManager.displaySentRequestPopup(_pvpGameList[param1.currentTarget.index].gameCardMediaId,_currUserNameModerated);
            MinigameManager.readySelfForPvpGame({"typeDefId":_loc3_},_currUserName,true);
            closeBuddyCard();
         }
         else if(_isTradingTabOpen)
         {
            _loc2_ = BuddyManager.getBuddyByUserName(_currUserName);
            if(Boolean(_loc2_) && Boolean(_buddyShardId != RoomManagerWorld.instance.shardId) && _buddyRoomName != gMainFrame.server.getCurrentRoomName())
            {
               _loc5_ = _buddyRoomName.indexOf("_");
               if(_loc5_ > 0 && !isNaN(Number(_buddyRoomName.charAt(_loc5_ - 1))) && !isNaN(Number(_buddyRoomName.charAt(_loc5_ + 1))))
               {
                  new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(11388,_currUserNameModerated));
               }
               else if(QuestManager.isInPrivateAdventureState)
               {
                  QuestManager.showLeaveQuestLobbyPopup(sideMenuMouseDown,param1);
               }
               else
               {
                  new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14704),true,onConfirmServerSwitch);
               }
               return;
            }
            TradeXtCommManager.sendTradeBusyRequest(true);
            TradeManager.isCurrentlyTrading = true;
            TradeManager.displayRequestTrade({
               "type":(_tradeList[param1.currentTarget.index] is Item ? 0 : 1),
               "invIdx":_tradeList[param1.currentTarget.index].invIdx
            });
         }
      }
      
      private static function onConfirmServerSwitch(param1:Object) : void
      {
         if(param1.status)
         {
            gotoDownHandler(null);
         }
      }
      
      private static function getShard(param1:String) : int
      {
         return int(param1.substring(param1.lastIndexOf("#") + 1,param1.length));
      }
      
      private static function dropDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = new Date().getTime();
         if(param1.currentTarget.name == _buddyCardMC.charsBtnUp.name)
         {
            if(!_isDropDownOpen)
            {
               if(!_loadingSpiralDropDown.visible)
               {
                  LocalizationManager.translateId(_buddyCardMC.dropDownTitleTxt,11238);
                  _buddyCardMC.charsBtnUp.visible = true;
                  _buddyCardMC.awardsBtnUp.visible = false;
                  _buddyCardMC.petsBtnUp.visible = false;
                  _madeChars = true;
                  openDropDown(_buddyCardMC.dropDown);
                  if(_loc2_ - _avatarTimeStamp > REQUEST_INTERVAL)
                  {
                     requestAvatarList(true);
                     _avatarTimeStamp = _loc2_;
                  }
                  else
                  {
                     createAvatarWindows();
                  }
               }
            }
            else
            {
               closeDropDown(_buddyCardMC.dropDown);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.charsBtnDn.name && !_loadingSpiralDropDown.visible)
         {
            if(_madeChars)
            {
               destroyCharacters();
            }
            LocalizationManager.translateId(_buddyCardMC.dropDownTitleTxt,11238);
            _buddyCardMC.charsBtnUp.visible = true;
            _buddyCardMC.awardsBtnUp.visible = false;
            _buddyCardMC.petsBtnUp.visible = false;
            if(!_isDropDownOpen)
            {
               openDropDown(_buddyCardMC.dropDown);
            }
            if(_loc2_ - _avatarTimeStamp > REQUEST_INTERVAL)
            {
               requestAvatarList(true);
               _avatarTimeStamp = _loc2_;
            }
            else
            {
               createAvatarWindows();
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.awardsBtnUp.name)
         {
            if(!_isDropDownOpen)
            {
               if(!_loadingSpiralDropDown.visible)
               {
                  LocalizationManager.translateId(_buddyCardMC.dropDownTitleTxt,11239);
                  _buddyCardMC.awardsBtnUp.visible = true;
                  _buddyCardMC.charsBtnUp.visible = false;
                  _buddyCardMC.petsBtnUp.visible = false;
                  openDropDown(_buddyCardMC.dropDown);
                  if(_loc2_ - _achievementTimeStamp > REQUEST_INTERVAL)
                  {
                     requestAchievementsList();
                     _achievementTimeStamp = _loc2_;
                  }
                  else
                  {
                     createAchievementsWindows();
                  }
               }
            }
            else
            {
               closeDropDown(_buddyCardMC.dropDown);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.awardsBtnDn.name && !_loadingSpiralDropDown.visible)
         {
            if(_madeChars)
            {
               destroyCharacters();
            }
            LocalizationManager.translateId(_buddyCardMC.dropDownTitleTxt,11239);
            _buddyCardMC.awardsBtnUp.visible = true;
            _buddyCardMC.charsBtnUp.visible = false;
            _buddyCardMC.petsBtnUp.visible = false;
            _madeChars = true;
            if(!_isDropDownOpen)
            {
               openDropDown(_buddyCardMC.dropDown);
            }
            if(_loc2_ - _achievementTimeStamp > REQUEST_INTERVAL)
            {
               requestAchievementsList();
               _achievementTimeStamp = _loc2_;
            }
            else
            {
               createAchievementsWindows();
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.petsBtnUp.name)
         {
            if(!_isDropDownOpen)
            {
               if(!_loadingSpiralDropDown.visible)
               {
                  LocalizationManager.translateId(_buddyCardMC.dropDownTitleTxt,11240);
                  _buddyCardMC.petsBtnUp.visible = true;
                  _buddyCardMC.awardsBtnUp.visible = false;
                  _buddyCardMC.charsBtnUp.visible = false;
                  openDropDown(_buddyCardMC.dropDown);
                  if(_loc2_ - _petsTimeStamp > REQUEST_INTERVAL)
                  {
                     requestPetsList();
                     _petsTimeStamp = _loc2_;
                  }
                  else
                  {
                     createPetsWindows();
                  }
               }
            }
            else
            {
               closeDropDown(_buddyCardMC.dropDown);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.petsBtnDn.name && !_loadingSpiralDropDown.visible)
         {
            if(_madeChars)
            {
               destroyCharacters();
            }
            LocalizationManager.translateId(_buddyCardMC.dropDownTitleTxt,11240);
            _buddyCardMC.petsBtnUp.visible = true;
            _buddyCardMC.awardsBtnUp.visible = false;
            _buddyCardMC.charsBtnUp.visible = false;
            _madeChars = true;
            if(!_isDropDownOpen)
            {
               openDropDown(_buddyCardMC.dropDown);
            }
            if(_loc2_ - _petsTimeStamp > REQUEST_INTERVAL)
            {
               requestPetsList();
               _petsTimeStamp = _loc2_;
            }
            else
            {
               createPetsWindows();
            }
         }
      }
      
      private static function sideMenuHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!_isGameTabOpen && param1.currentTarget.name == _buddyCardMC.gameTabBtn.name)
         {
            if(!_buddyCardMC.gameTabBtn.isGray)
            {
               if(_isTradingTabOpen)
               {
                  closeSideMenu(_buddyCardMC.tradeTab);
               }
               if(_pvpItemWindows == null)
               {
                  _pvpGameList = MinigameManager.minigameInfoCache.getAllReadyForPvpGameDefs();
                  createPVPWindows();
                  getPVPIcons();
               }
               else
               {
                  _buddyCardMC.gameTabItemWindow.addChild(_pvpItemWindows);
                  if(_pvpScrollBar)
                  {
                     _pvpScrollBar.destroy();
                  }
                  _pvpScrollBar = new SBScrollbar();
                  _pvpScrollBar.init(_pvpItemWindows,155,156,0,"scrollbar2",77);
               }
               openSideMenu(_buddyCardMC.gameTab);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.gameTabBtn.name && _isGameTabOpen)
         {
            closeSideMenu(_buddyCardMC.gameTab);
         }
         else if(param1.currentTarget.name == _buddyCardMC.tradeTabBtn.name && _isTradingTabOpen)
         {
            closeSideMenu(_buddyCardMC.tradeTab);
         }
         else if(!_buddyCardMC.tradeTabBtn.isGray)
         {
            if(_isGameTabOpen)
            {
               closeSideMenu(_buddyCardMC.gameTab);
            }
            _loadingSpiralPullOut.visible = true;
            TradeXtCommManager.sendTradeListRequest(_currUserName);
            openSideMenu(_buddyCardMC.tradeTab);
            if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TRADING,1))
            {
               _buddyCardMC.tradeHelpPopup.visible = true;
               LocalizationManager.translateId(_buddyCardMC.tradeHelpPopup.txt,11241);
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TRADING,1);
            }
         }
      }
      
      private static function sideMenuOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == _buddyCardMC.gameTabBtn.name)
         {
            if(_isGameTabOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14630),312,55);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14630),520,55);
            }
         }
         else if(_isTradingTabOpen)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14631),300,169);
         }
         else
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14631),520,169);
         }
         GuiManager.toolTip.startTimer(param1);
      }
      
      private static function dropDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == _buddyCardMC.charsBtnUp.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11238),792,260 + 150);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11238),792,260);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.awardsBtnUp.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11239),843,260 + 150);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11239),843,260);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.petsBtnUp.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11240),743,260 + 150);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11240),743,260);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.charsBtnDn.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11238),792,260 + 150);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11238),792,260);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.awardsBtnDn.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11239),843,260 + 150);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11239),843,260);
            }
         }
         else if(param1.currentTarget.name == _buddyCardMC.petsBtnDn.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11240),743,260 + 150);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11240),743,260);
            }
         }
         GuiManager.toolTip.startTimer(param1);
      }
      
      private static function btnOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function openDropDown(param1:MovieClip) : void
      {
         if(_bDropDownTweenFinished && !_isDropDownOpen)
         {
            new GTween(param1,0.5,{"y":param1.y + 173},{
               "ease":TweenManager.quadratic,
               "onComplete":dropDownComplete
            });
            _bDropDownTweenFinished = false;
            _isDropDownOpen = true;
            AJAudio.playBuddyCardOpen();
         }
      }
      
      private static function closeDropDown(param1:MovieClip) : void
      {
         if(_isDropDownOpen && _bDropDownTweenFinished)
         {
            new GTween(param1,0.5,{"y":param1.y - 173},{
               "ease":TweenManager.quadratic,
               "onComplete":dropDownComplete
            });
            _bDropDownTweenFinished = false;
            _isDropDownOpen = false;
            AJAudio.playBuddyCardClose();
         }
      }
      
      private static function openSideMenu(param1:MovieClip) : void
      {
         var _loc2_:Buddy = BuddyManager.getBuddyByUserName(_currUserName);
         if(param1 == _buddyCardMC.gameTab && _sideMenuTweenFinished && !_isGameTabOpen && !_buddyCardMC.gameTabBtn.isGray)
         {
            new GTween(param1,0.5,{"x":param1.x - 208},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            if(_buddyCardMC.getChildIndex(_buddyCardMC.gameTab) < _buddyCardMC.getChildIndex(_buddyCardMC.tradeTab))
            {
               _buddyCardMC.swapChildren(_buddyCardMC.gameTab,_buddyCardMC.tradeTab);
            }
            _sideMenuTweenFinished = false;
            _isGameTabOpen = true;
            AJAudio.playBuddyCardOpen();
         }
         else if(param1 == _buddyCardMC.tradeTab && _sideMenuTweenFinished && !_isTradingTabOpen && !_buddyCardMC.tradeTabBtn.isGray)
         {
            new GTween(param1,0.5,{"x":param1.x - 231},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            if(_buddyCardMC.getChildIndex(_buddyCardMC.gameTab) > _buddyCardMC.getChildIndex(_buddyCardMC.tradeTab))
            {
               _buddyCardMC.swapChildren(_buddyCardMC.gameTab,_buddyCardMC.tradeTab);
            }
            _sideMenuTweenFinished = false;
            _isTradingTabOpen = true;
            AJAudio.playBuddyCardOpen();
         }
      }
      
      private static function closeSideMenu(param1:MovieClip) : void
      {
         if(param1 == _buddyCardMC.gameTab && _isGameTabOpen && _sideMenuTweenFinished)
         {
            new GTween(param1,0.5,{"x":param1.x + 208},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            _sideMenuTweenFinished = false;
            _isGameTabOpen = false;
            AJAudio.playBuddyCardClose();
         }
         else if(param1 == _buddyCardMC.tradeTab && _isTradingTabOpen && _sideMenuTweenFinished)
         {
            new GTween(param1,0.5,{"x":param1.x + 231},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            _sideMenuTweenFinished = false;
            _isTradingTabOpen = false;
            AJAudio.playBuddyCardClose();
         }
      }
      
      private static function dropDownComplete(param1:GTween) : void
      {
         _bDropDownTweenFinished = true;
      }
      
      private static function sideMenuComplete(param1:GTween) : void
      {
         _sideMenuTweenFinished = true;
      }
      
      private static function buddyCardAddIgnoreConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            _buddyCardMC.blockBtn.activateGrayState(true);
            BuddyXtCommManager.sendBuddyBlockRequest(_currUserName);
         }
      }
      
      private static function buddyCardRemoveIgnoreConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            _buddyCardMC.unblockBtn.activateGrayState(true);
            BuddyXtCommManager.sendBuddyUnblockRequest(_currUserName);
         }
      }
      
      private static function gotoDownHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_buddyCardMC.goToBtn.isGray)
         {
            if(!GuiManager.mainHud.swapBtn.isGray)
            {
               DarkenManager.showLoadingSpiral(true);
               RoomXtCommManager.sendRoomJoinRequest(_buddyRoomName);
            }
            else if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(gotoDownHandler,param1);
            }
         }
      }
      
      private static function goToRollOverHandler(param1:MouseEvent) : void
      {
         if(_currUserIsBuddy && !_buddyCardMC.goToBtn.isGray)
         {
            if(_buddyCardMC.locationPopupTxt.text != "")
            {
               _buddyCardMC.locationPopup.visible = true;
            }
         }
      }
      
      private static function goToRollOutHandler(param1:MouseEvent) : void
      {
         _buddyCardMC.locationPopup.visible = false;
      }
      
      private static function resizeLocationToolTip() : void
      {
         _buddyCardMC.locationPopupTxt.width = int(_buddyCardMC.locationPopupTxt.textWidth + 5);
         _buddyCardMC.locationPopup.m.width = _buddyCardMC.locationPopupTxt.width;
         _buddyCardMC.locationPopup.l.x = 0;
         _buddyCardMC.locationPopup.m.x = _buddyCardMC.locationPopup.l.x + _buddyCardMC.locationPopup.l.width;
         _buddyCardMC.locationPopup.r.x = _buddyCardMC.locationPopup.m.x + _buddyCardMC.locationPopup.m.width;
         _buddyCardMC.locationPopupTxt.x = _buddyCardMC.locationPopup.m.x;
         _buddyCardMC.locationPopup.x = _buddyCardMC.goToBtn.x - (_buddyCardMC.locationPopup.l.width + _buddyCardMC.locationPopup.m.width + _buddyCardMC.locationPopup.r.width) * 0.5;
      }
      
      public static function get currBuddyCardUserName() : String
      {
         if(_currUserName != null)
         {
            return _currUserName.toLowerCase();
         }
         return "";
      }
      
      private static function denDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(Boolean(_buddyCardMC.denBtn.isGray) || Boolean(_buddyCardMC.wasSearched))
         {
            return;
         }
         if(_currUserName != "")
         {
            if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(denDownHandler,param1);
               return;
            }
            if(!RoomXtCommManager.isSwitching)
            {
               DenXtCommManager.requestDenJoinFull("den" + _currUserName);
            }
         }
      }
      
      private static function denDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(Boolean(_buddyCardMC.denBtn.isGray) || Boolean(_buddyCardMC.wasSearched))
         {
            return;
         }
         GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14632),822,92);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private static function reportDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_reportAPlayer)
            {
               _reportAPlayer.destroy();
            }
            else
            {
               _reportAPlayer = new ReportAPlayer();
               _reportAPlayer.init(GuiManager.guiLayer,onReportAPlayerClose,true,_currUserName,_currUserNameModerated,true,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
            }
         }
      }
      
      private static function reportDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14633),845,200);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private static function onReportAPlayerClose(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
      }
      
      private static function mailDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            ECardManager.createCard(_currUserName,_currUserNameModerated,_currUserAccountType,false);
         }
      }
      
      private static function mailDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14634),824,145);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private static function addRemoveBuddyDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == _buddyCardMC.addBuddyBtn.name)
            {
               if(BuddyManager.isBuddy(_currUserName))
               {
                  throw new Error("ERROR: Trying to add a buddy that is already a buddy! userName=" + _currUserName);
               }
               _buddyCardMC.addBuddyBtn.activateGrayState(true);
               BuddyManager.addRemoveBuddy(_currUserName,_currUserNameModerated,true);
            }
            else if(param1.currentTarget.name == _buddyCardMC.removeBuddyBtn.name)
            {
               if(!BuddyManager.isBuddy(_currUserName))
               {
                  throw new Error("ERROR: Trying to remove a buddy that is already not a buddy! userName=" + _currUserName);
               }
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14705,_currUserNameModerated),true,removeBuddyConfirmCallback,{
                  "currUserName":_currUserName,
                  "currUserNameModerated":_currUserNameModerated
               });
            }
         }
      }
      
      private static function addRemoveBuddyDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == _buddyCardMC.addBuddyBtn.name)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14635),822,37);
            }
            else if(param1.currentTarget.name == _buddyCardMC.removeBuddyBtn.name)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14636),822,37);
            }
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private static function onPlayerWallDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_buddyCardMC.playerWallBtn.isGray)
         {
            PlayerWallManager.openStrangersPlayerWall(_currUserName);
         }
      }
      
      private static function onPlayerWallOver(param1:MouseEvent) : void
      {
         if(!_buddyCardMC.playerWallBtn.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14637),845,62);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private static function removeBuddyConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            _buddyCardMC.removeBuddyBtn.activateGrayState(true);
            BuddyManager.addRemoveBuddy(param1.passback.currUserName,param1.passback.currUserNameModerated,false);
         }
      }
      
      private static function buddyRoomTimerHandler(param1:TimerEvent) : void
      {
         BuddyXtCommManager.sendBuddyRoomRequest(_currUserName);
      }
      
      private static function closeTradeHelp(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _buddyCardMC.tradeHelpPopup.visible = false;
      }
      
      private static function buddyChangedHandler(param1:BuddyEvent) : void
      {
         var _loc2_:Buddy = null;
         var _loc3_:Boolean = false;
         if(_currUserName != null && param1.userName.toLowerCase() == _currUserName.toLowerCase())
         {
            _loc2_ = BuddyManager.getBuddyByUserName(_currUserName);
            if(_currUserIsBuddy && !_loc2_)
            {
               _currUserIsBuddy = false;
               _buddyCardMC.addBuddyBtn.visible = true;
               if(_currUserIsArchived)
               {
                  _buddyCardMC.addBuddyBtn.activateGrayState(true);
               }
               _buddyCardMC.removeBuddyBtn.visible = false;
               _buddyCardMC.removeBuddyBtn.activateGrayState(false);
               _buddyCardMC.goToBtn.activateGrayState(true);
               _buddyCardMC.gameTabBtn.activateGrayState(true);
               if(!_currUserIsArchived && _currUserIsOnline && !shouldGrayOut())
               {
                  _buddyCardMC.tradeTabBtn.activateGrayState(false);
                  _buddyCardMC.gameTabBtn.activateGrayState(false);
               }
               else if(!_currUserIsOnline)
               {
                  _buddyCardMC.tradeTabBtn.activateGrayState(true);
                  _buddyCardMC.gameTabBtn.activateGrayState(true);
               }
               if(!_currUserIsArchived && !shouldGrayOut())
               {
                  DenXtCommManager.requestUserDenPrivacy(_currUserName);
               }
               _buddyRoomTimer.reset();
            }
            else if(!_currUserIsBuddy && Boolean(_loc2_))
            {
               _currUserIsOnline = _loc2_.isOnline;
               _currUserIsBuddy = true;
               _buddyCardMC.addBuddyBtn.visible = false;
               _buddyCardMC.addBuddyBtn.activateGrayState(false);
               _buddyCardMC.removeBuddyBtn.visible = true;
               if(!shouldGrayOut())
               {
                  _buddyCardMC.denBtn.activateGrayState(false);
                  _buddyCardMC.gameTabBtn.activateGrayState(false);
                  _buddyCardMC.tradeTabBtn.activateGrayState(false);
               }
               if(gMainFrame.server.getCurrentRoomName() != _buddyRoomName)
               {
                  _buddyCardMC.goToBtn.activateGrayState(false);
               }
               _buddyRoomTimer.start();
            }
            else if(Boolean(!_currUserIsOnline) && Boolean(_loc2_) && _loc2_.isOnline)
            {
               _currUserIsOnline = true;
               if(!shouldGrayOut())
               {
                  _buddyCardMC.gameTabBtn.activateGrayState(false);
                  _buddyCardMC.tradeTabBtn.activateGrayState(false);
               }
               _buddyRoomTimer.start();
               AvatarXtCommManager.requestAvatarGet(_currUserName,onAvatarGetReceived);
            }
            else if(Boolean(_currUserIsOnline) && Boolean(_loc2_) && !_loc2_.isOnline)
            {
               _currUserIsOnline = false;
               _buddyRoomDisplayName = "";
               _buddyShardId = -1;
               _buddyRoomName = "";
               _buddyRoomTimer.reset();
               _buddyCardMC.goToBtn.activateGrayState(true);
               _buddyCardMC.gameTabBtn.activateGrayState(true);
               _buddyCardMC.tradeTabBtn.activateGrayState(true);
               LocalizationManager.translateId(_buddyCardMC.locationPopupTxt,11235);
               resizeLocationToolTip();
            }
            else
            {
               _loc3_ = BuddyManager.isBlocked(_currUserName);
               if(_currUserIsBlocked && !_loc3_)
               {
                  _currUserIsBlocked = false;
                  _buddyCardMC.blockBtn.visible = true;
                  _buddyCardMC.unblockBtn.visible = false;
                  _buddyCardMC.unblockBtn.activateGrayState(false);
               }
               else if(!_currUserIsBlocked && _loc3_)
               {
                  _currUserIsBlocked = true;
                  _buddyCardMC.blockBtn.visible = false;
                  _buddyCardMC.blockBtn.activateGrayState(false);
                  _buddyCardMC.unblockBtn.visible = true;
               }
            }
         }
      }
      
      public static function buddyRoomResponseHandler(param1:String, param2:String, param3:int, param4:Boolean, param5:int) : void
      {
         var _loc6_:Array = null;
         var _loc7_:String = null;
         if(Boolean(_buddyCardPopup) && Boolean(_buddyCardMC))
         {
            if(_buddyRoomName != param1 || param2 != _buddyRoomDisplayName)
            {
               _buddyRoomName = param1;
               _buddyShardId = param5;
               if(param2 == null || param2 == "")
               {
                  LocalizationManager.translateId(_buddyCardMC.locationPopupTxt,11235);
                  _buddyRoomDisplayName = _buddyCardMC.locationPopupTxt.text;
                  resizeLocationToolTip();
                  _buddyCardMC.goToBtn.activateGrayState(true);
                  _buddyRoomTimer.reset();
                  return;
               }
               if(param2 == "Choosing Server")
               {
                  _buddyCardMC.locationPopupTxt.text = _buddyRoomDisplayName = param2;
                  resizeLocationToolTip();
                  _buddyCardMC.goToBtn.activateGrayState(true);
                  return;
               }
               if(param2 == LocalizationManager.translateIdOnly(11235))
               {
                  _buddyRoomTimer.reset();
                  _buddyCardMC.locationPopupTxt.text = _buddyRoomDisplayName = param2;
                  resizeLocationToolTip();
                  _buddyCardMC.goToBtn.activateGrayState(true);
                  return;
               }
               _loc6_ = param2.split("\'");
               if((Boolean(_loc6_)) && _loc6_.length > 1)
               {
                  if(_currUserName.toLowerCase() == _loc6_[0].toLowerCase())
                  {
                     param2 = _currUserNameModerated + "\'" + _loc6_[1];
                  }
               }
               _loc7_ = _buddyRoomDisplayName = param2;
               if(_buddyCardPopup)
               {
                  if(_loc7_.indexOf("Den") < 0)
                  {
                     if(param3 != 0)
                     {
                        _buddyCardMC.locationPopupTxt.text = LocalizationManager.translateIdOnly(param3);
                     }
                     else
                     {
                        _buddyCardMC.locationPopupTxt.text = normalizeName(_loc7_);
                     }
                  }
                  else
                  {
                     _buddyCardMC.locationPopupTxt.text = LocalizationManager.translateIdAndInsertOnly(18427,_currUserNameModerated);
                  }
                  resizeLocationToolTip();
                  checkBuddyRoomAgainstMine(param4);
               }
            }
         }
      }
      
      public static function buddyBlockInfoResponseHandler(param1:String, param2:Boolean) : void
      {
         if(_currUserName.toLowerCase() == param1.toLowerCase())
         {
         }
      }
      
      private static function onInfoBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(TRADE_TUT_LIST_ID);
      }
      
      private static function normalizeName(param1:String) : String
      {
         var _loc4_:int = 0;
         var _loc2_:Array = param1.split(" ");
         var _loc3_:int = int(_loc2_.length);
         while(_loc4_ < _loc3_)
         {
            _loc2_[_loc4_] = capitalizeFirstLetter(_loc2_[_loc4_]);
            _loc4_++;
         }
         return _loc2_.join(" ");
      }
      
      public static function joinBuddyInQuest() : Boolean
      {
         if(_currUserName != null && _currUserName.length > 0)
         {
            QuestXtCommManager.sendQuestJoinBuddy(_currUserName);
            return true;
         }
         return false;
      }
      
      private static function capitalizeFirstLetter(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         switch(param1)
         {
            case "and":
            case "the":
            case "in":
            case "an":
            case "or":
            case "at":
            case "of":
            case "a":
               break;
            default:
               _loc2_ = param1.substr(0,1);
               _loc2_ = _loc2_.toUpperCase();
               _loc3_ = param1.substring(1);
               param1 = _loc2_ + _loc3_;
         }
         return param1;
      }
      
      private static function getGuideText(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = param1;
         switch(0)
         {
         }
         return "";
      }
      
      private static function onCardDown(param1:MouseEvent) : void
      {
         _popupLayer.addChild(_buddyCardPopup);
         _buddyCardPopup.x = BUDDY_POPUP_X;
         _buddyCardPopup.y = BUDDY_POPUP_Y;
         param1.stopPropagation();
      }
      
      private static function stopListeners(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function addCardListeners() : void
      {
         if(_buddyCardMC)
         {
            if(Utility.canBuddy())
            {
               _buddyCardMC.addBuddyBtn.addEventListener(MouseEvent.MOUSE_DOWN,addRemoveBuddyDownHandler,false,0,true);
               _buddyCardMC.addBuddyBtn.addEventListener(MouseEvent.MOUSE_OVER,addRemoveBuddyDownOverHandler,false,0,true);
               _buddyCardMC.addBuddyBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
               _buddyCardMC.mailBtn.addEventListener(MouseEvent.MOUSE_DOWN,mailDownHandler,false,0,true);
               _buddyCardMC.mailBtn.addEventListener(MouseEvent.MOUSE_OVER,mailDownOverHandler,false,0,true);
               _buddyCardMC.mailBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            }
            else
            {
               _buddyCardMC.addBuddyBtn.activateGrayState(true);
               _buddyCardMC.mailBtn.activateGrayState(true);
            }
            if(!Utility.canJAG() || shouldGrayOut())
            {
               _buddyCardMC.mailBtn.activateGrayState(true);
            }
            if(Utility.canPVP())
            {
               _buddyCardMC.gameTabBtn.addEventListener(MouseEvent.MOUSE_DOWN,sideMenuHandler,false,0,true);
               _buddyCardMC.gameTabBtn.addEventListener(MouseEvent.MOUSE_OVER,sideMenuOverHandler,false,0,true);
               _buddyCardMC.gameTabBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            }
            else
            {
               _buddyCardMC.gameTabBtn.activateGrayState(true);
            }
            if(Utility.canTrade())
            {
               _buddyCardMC.tradeTabBtn.addEventListener(MouseEvent.MOUSE_DOWN,sideMenuHandler,false,0,true);
               _buddyCardMC.tradeTabBtn.addEventListener(MouseEvent.MOUSE_OVER,sideMenuOverHandler,false,0,true);
               _buddyCardMC.tradeTabBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            }
            else
            {
               _buddyCardMC.tradeTabBtn.activateGrayState(true);
            }
            _buddyCardMC.removeBuddyBtn.addEventListener(MouseEvent.MOUSE_DOWN,addRemoveBuddyDownHandler,false,0,true);
            _buddyCardMC.removeBuddyBtn.addEventListener(MouseEvent.MOUSE_OVER,addRemoveBuddyDownOverHandler,false,0,true);
            _buddyCardMC.removeBuddyBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.denBtn.addEventListener(MouseEvent.MOUSE_DOWN,denDownHandler,false,0,true);
            _buddyCardMC.denBtn.addEventListener(MouseEvent.MOUSE_OVER,denDownOverHandler,false,0,true);
            _buddyCardMC.denBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.blockBtn.addEventListener(MouseEvent.MOUSE_DOWN,addRemoveBlockDownHandler,false,0,true);
            _buddyCardMC.blockBtn.addEventListener(MouseEvent.MOUSE_OVER,addRemoveBlockDownOverHandler,false,0,true);
            _buddyCardMC.blockBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.unblockBtn.addEventListener(MouseEvent.MOUSE_DOWN,addRemoveBlockDownHandler,false,0,true);
            _buddyCardMC.unblockBtn.addEventListener(MouseEvent.MOUSE_OVER,addRemoveBlockDownOverHandler,false,0,true);
            _buddyCardMC.unblockBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.reportBtn.addEventListener(MouseEvent.MOUSE_DOWN,reportDownHandler,false,0,true);
            _buddyCardMC.reportBtn.addEventListener(MouseEvent.MOUSE_OVER,reportDownOverHandler,false,0,true);
            _buddyCardMC.reportBtn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.goToBtn.addEventListener(MouseEvent.MOUSE_DOWN,gotoDownHandler,false,0,true);
            _buddyCardMC.goToBtn.addEventListener(MouseEvent.MOUSE_OVER,goToRollOverHandler,false,0,true);
            _buddyCardMC.goToBtn.addEventListener(MouseEvent.MOUSE_OUT,goToRollOutHandler,false,0,true);
            _buddyCardMC.charsBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler,false,0,true);
            _buddyCardMC.charsBtnUp.addEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler,false,0,true);
            _buddyCardMC.charsBtnUp.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.awardsBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler,false,0,true);
            _buddyCardMC.awardsBtnUp.addEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler,false,0,true);
            _buddyCardMC.awardsBtnUp.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.petsBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler,false,0,true);
            _buddyCardMC.petsBtnUp.addEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler,false,0,true);
            _buddyCardMC.petsBtnUp.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.charsBtnDn.addEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler,false,0,true);
            _buddyCardMC.charsBtnDn.addEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler,false,0,true);
            _buddyCardMC.charsBtnDn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.awardsBtnDn.addEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler,false,0,true);
            _buddyCardMC.awardsBtnDn.addEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler,false,0,true);
            _buddyCardMC.awardsBtnDn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.petsBtnDn.addEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler,false,0,true);
            _buddyCardMC.petsBtnDn.addEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler,false,0,true);
            _buddyCardMC.petsBtnDn.addEventListener(MouseEvent.MOUSE_OUT,btnOutHandler,false,0,true);
            _buddyCardMC.tradeHelpPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,closeTradeHelp,false,0,true);
            _buddyCardMC.tradeTab.infoBtn.addEventListener(MouseEvent.MOUSE_DOWN,onInfoBtnDown,false,0,true);
            _buddyCardMC.addEventListener(MouseEvent.MOUSE_DOWN,stopListeners,false,0,true);
            _buddyCardMC.addEventListener(MouseEvent.MOUSE_OVER,stopListeners,false,0,true);
            _buddyCardMC.addEventListener(MouseEvent.MOUSE_OUT,stopListeners,false,0,true);
            _buddyCardPopup.addEventListener(MouseEvent.MOUSE_DOWN,onCardDown,false,0,true);
         }
      }
      
      private static function removeCardListeners() : void
      {
         if(_buddyCardMC)
         {
            if(Utility.canBuddy())
            {
               _buddyCardMC.addBuddyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,addRemoveBuddyDownHandler);
               _buddyCardMC.addBuddyBtn.removeEventListener(MouseEvent.MOUSE_OVER,addRemoveBuddyDownOverHandler);
               _buddyCardMC.addBuddyBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
               _buddyCardMC.mailBtn.removeEventListener(MouseEvent.MOUSE_DOWN,mailDownHandler);
               _buddyCardMC.mailBtn.removeEventListener(MouseEvent.MOUSE_OVER,mailDownOverHandler);
               _buddyCardMC.mailBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            }
            if(Utility.canTrade())
            {
               _buddyCardMC.tradeTabBtn.removeEventListener(MouseEvent.MOUSE_DOWN,sideMenuHandler);
               _buddyCardMC.tradeTabBtn.removeEventListener(MouseEvent.MOUSE_OVER,sideMenuOverHandler);
               _buddyCardMC.tradeTabBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            }
            if(Utility.canPVP())
            {
               _buddyCardMC.gameTabBtn.removeEventListener(MouseEvent.MOUSE_DOWN,sideMenuHandler);
               _buddyCardMC.gameTabBtn.removeEventListener(MouseEvent.MOUSE_OVER,sideMenuOverHandler);
               _buddyCardMC.gameTabBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            }
            _buddyCardMC.removeBuddyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,addRemoveBuddyDownHandler);
            _buddyCardMC.removeBuddyBtn.removeEventListener(MouseEvent.MOUSE_OVER,addRemoveBuddyDownOverHandler);
            _buddyCardMC.removeBuddyBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.denBtn.removeEventListener(MouseEvent.MOUSE_DOWN,denDownHandler);
            _buddyCardMC.denBtn.removeEventListener(MouseEvent.MOUSE_OVER,denDownOverHandler);
            _buddyCardMC.denBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.blockBtn.removeEventListener(MouseEvent.MOUSE_DOWN,addRemoveBlockDownHandler);
            _buddyCardMC.blockBtn.removeEventListener(MouseEvent.MOUSE_OVER,addRemoveBlockDownOverHandler);
            _buddyCardMC.blockBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.unblockBtn.removeEventListener(MouseEvent.MOUSE_DOWN,addRemoveBlockDownHandler);
            _buddyCardMC.unblockBtn.removeEventListener(MouseEvent.MOUSE_OVER,addRemoveBlockDownOverHandler);
            _buddyCardMC.unblockBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.reportBtn.removeEventListener(MouseEvent.MOUSE_DOWN,reportDownHandler);
            _buddyCardMC.reportBtn.removeEventListener(MouseEvent.MOUSE_OVER,reportDownOverHandler);
            _buddyCardMC.reportBtn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.goToBtn.removeEventListener(MouseEvent.MOUSE_DOWN,gotoDownHandler);
            _buddyCardMC.goToBtn.removeEventListener(MouseEvent.MOUSE_OVER,goToRollOverHandler);
            _buddyCardMC.goToBtn.removeEventListener(MouseEvent.MOUSE_OUT,goToRollOutHandler);
            _buddyCardMC.charsBtnUp.removeEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler);
            _buddyCardMC.charsBtnUp.removeEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler);
            _buddyCardMC.charsBtnUp.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.awardsBtnUp.removeEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler);
            _buddyCardMC.awardsBtnUp.removeEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler);
            _buddyCardMC.awardsBtnUp.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.petsBtnUp.removeEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler);
            _buddyCardMC.petsBtnUp.removeEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler);
            _buddyCardMC.petsBtnUp.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.charsBtnDn.removeEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler);
            _buddyCardMC.charsBtnDn.removeEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler);
            _buddyCardMC.charsBtnDn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.awardsBtnDn.removeEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler);
            _buddyCardMC.awardsBtnDn.removeEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler);
            _buddyCardMC.awardsBtnDn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.petsBtnDn.removeEventListener(MouseEvent.MOUSE_DOWN,dropDownHandler);
            _buddyCardMC.petsBtnDn.removeEventListener(MouseEvent.MOUSE_OVER,dropDownOverHandler);
            _buddyCardMC.petsBtnDn.removeEventListener(MouseEvent.MOUSE_OUT,btnOutHandler);
            _buddyCardMC.tradeHelpPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,closeTradeHelp);
            _buddyCardMC.tradeTab.infoBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onInfoBtnDown);
            _buddyCardMC.removeEventListener(MouseEvent.MOUSE_DOWN,stopListeners);
            _buddyCardMC.removeEventListener(MouseEvent.MOUSE_OVER,stopListeners);
            _buddyCardMC.removeEventListener(MouseEvent.MOUSE_OUT,stopListeners);
            _buddyCardPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onCardDown);
         }
      }
   }
}

