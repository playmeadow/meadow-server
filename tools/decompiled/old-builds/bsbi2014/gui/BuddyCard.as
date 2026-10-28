package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
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
      
      public static function init(init_popupLayer:DisplayLayer) : void
      {
         _popupLayer = init_popupLayer;
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
         if(Boolean(_buddyRoomTimer))
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
         if(Boolean(_mainAvatarView))
         {
            _mainAvatarView.destroy();
            _mainAvatarView = null;
         }
         if(Boolean(_mainPetView))
         {
            _mainPetView.destroy();
            _mainPetView = null;
         }
         if(Boolean(_buddyCardPopup))
         {
            _buddyCardPopup.closeCallback = null;
            _buddyCardPopup.destroy();
         }
         if(Boolean(_pvpItemWindows))
         {
            if(Boolean(_pvpItemWindows.parent))
            {
               _pvpItemWindows.parent.removeChild(_pvpItemWindows);
            }
            _pvpItemWindows.destroy();
            _pvpItemWindows = null;
         }
         if(Boolean(_pvpScrollBar))
         {
            _pvpScrollBar.destroy();
            _pvpScrollBar = null;
         }
         if(Boolean(_tradeItemWindows))
         {
            if(Boolean(_tradeItemWindows.parent))
            {
               _tradeItemWindows.parent.removeChild(_tradeItemWindows);
            }
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         if(Boolean(_tradeScrollBar))
         {
            _tradeScrollBar.destroy();
            _tradeScrollBar = null;
         }
         if(Boolean(_itemWindows))
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _buddyCardMC = null;
         AvatarManager.buddyCardAvatarView = null;
      }
      
      private static function destroyCharacters() : void
      {
         if(Boolean(_dropDownScrollbar))
         {
            _dropDownScrollbar.destroy();
            _dropDownScrollbar = null;
         }
         if(Boolean(_itemWindows))
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
      }
      
      public static function showBuddyCard(player:Object, shouldDarkenBuddyCard:Boolean = false) : void
      {
         var isArchived:Boolean = false;
         var aui:UserInfo = null;
         var myCurrRoomName:String = null;
         var bud:Buddy = null;
         var avInfo:AvatarInfo = null;
         var userName:String = player.userName;
         var onlineStatus:int = int(player.onlineStatus);
         isArchived = onlineStatus == SFClient.STATUS_OFFLINE_ARCHIVED;
         if(isArchived)
         {
            aui = gMainFrame.userInfo.getUserInfoByUserName(userName);
            if(Boolean(aui))
            {
               aui.setTimeOfLastAchievementRequest(0);
            }
         }
         if(_currUserName != userName)
         {
            myCurrRoomName = gMainFrame.server.getCurrentRoomName(false);
            _avatarTimeStamp = 0;
            _achievementTimeStamp = 0;
            _petsTimeStamp = 0;
            destroyCard();
            _shouldDarkenBuddyCard = shouldDarkenBuddyCard;
            _currUserIsArchived = isArchived;
            _currUserName = userName;
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
            if(myCurrRoomName != "den" + userName && gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST)
            {
               _buddyCardMC.denBtn.activateGrayState(false);
            }
            else
            {
               _buddyCardMC.denBtn.activateGrayState(true);
            }
            if(onlineStatus < SFClient.STATUS_ONLINE || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
            {
               if(Boolean(_buddyCardMC.tradeTabBtn.hasGrayState))
               {
                  _buddyCardMC.tradeTabBtn.activateGrayState(true);
               }
               if(Boolean(_buddyCardMC.gameTabBtn.hasGrayState))
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
            bud = BuddyManager.getBuddyByUserName(userName);
            _currUserIsBuddy = bud != null;
            if(_currUserIsBuddy)
            {
               _currUserIsOnline = bud.isOnline;
               if(_currUserIsOnline)
               {
                  BuddyXtCommManager.sendBuddyRoomRequest(userName);
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
               BuddyXtCommManager.sendBuddyRoomRequest(userName);
               if(!_buddyCardMC.denBtn.isGray && !isArchived)
               {
                  DenXtCommManager.requestUserDenPrivacy(_currUserName);
               }
            }
            _buddyCardMC.addBuddyBtn.visible = !_currUserIsBuddy;
            _buddyCardMC.removeBuddyBtn.visible = _currUserIsBuddy;
            _currUserIsBlocked = BuddyManager.isBlocked(_currUserName);
            _buddyCardMC.blockBtn.visible = !_currUserIsBlocked;
            _buddyCardMC.unblockBtn.visible = _currUserIsBlocked;
            if(gMainFrame.userInfo.isModerator)
            {
               if(myCurrRoomName != "den" + userName)
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
            if(!isArchived)
            {
               _buddyCardMC.charBox.gotoAndStop(1);
               avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
               if(!avInfo)
               {
                  AvatarXtCommManager.requestAvatarGet(userName,onAvatarGetReceived);
                  return;
               }
               onAvatarGetReceived(userName,true,onlineStatus,avInfo);
            }
            else
            {
               if(bud != null)
               {
                  _buddyCardMC.avatarNameTxt.text = "";
                  _buddyCardMC.userNameTxt.text = bud.userNameModerated;
               }
               else
               {
                  _buddyCardMC.userNameTxt.text = _currUserName;
               }
               _buddyCardMC.charBox.gotoAndStop(4);
               _loadingSpiralAvatar.visible = false;
               clearPetAndAvatarViews();
               _currPerUserAvId = -1;
               _currPetIdx = -1;
               _buddyCardMC.avatarNameTxt.text = "";
               if(!_currUserIsBuddy)
               {
                  _buddyCardMC.addBuddyBtn.activateGrayState(true);
               }
               if(!_buddyCardMC.goToBtn.isGray)
               {
                  _buddyCardMC.goToBtn.activateGrayState(true);
               }
               if(!_buddyCardMC.denBtn.isGray)
               {
                  _buddyCardMC.denBtn.activateGrayState(true);
               }
               if(!_buddyCardMC.mailBtn.isGray)
               {
                  _buddyCardMC.mailBtn.activateGrayState(true);
               }
               _buddyCardMC.blockBtn.visible = true;
               _buddyCardMC.unblockBtn.visible = false;
               if(!_buddyCardMC.blockBtn.isGray)
               {
                  _buddyCardMC.blockBtn.activateGrayState(true);
               }
               if(Boolean(_buddyCardMC.reportBtn.hasGrayState) && !_buddyCardMC.reportBtn.isGray)
               {
                  _buddyCardMC.reportBtn.activateGrayState(true);
               }
               _buddyCardMC.dropDown.visible = false;
               _buddyCardMC.shamanTag.visible = false;
               _buddyCardMC.shamanBlock.visible = false;
               _buddyCardMC.memberKey.visible = false;
               _buddyCardMC.memberNameBar.visible = false;
               SBTracker.trackPageview("game/play/popup/buddyCard/archived",-1,SBTracker.TYPE_EVENT);
            }
         }
      }
      
      private static function onAvatarGetReceived(userName:String, status:Boolean, onlineStatus:int, avInfo:AvatarInfo = null) : void
      {
         var perUserAvId:int = 0;
         var avt:Avatar = null;
         var ui:UserInfo = null;
         if(status && userName == _currUserName)
         {
            if(onlineStatus == SFClient.STATUS_OFFLINE_ARCHIVED)
            {
               resetBuddyCardForArchiveMode();
               return;
            }
            if(!avInfo)
            {
               avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
               if(!avInfo)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            perUserAvId = avInfo.perUserAvId;
            avt = AvatarManager.getAvatarByUserName(_currUserName);
            if(avt == null)
            {
               if(_offlineBuddyAvatar == null)
               {
                  _offlineBuddyAvatar = AvatarUtility.generateNew(perUserAvId,null,_currUserName,-1,0,onAvatarItemData);
               }
               else if(_offlineBuddyAvatar.userName != avInfo.userName)
               {
                  _offlineBuddyAvatar.destroy();
                  _offlineBuddyAvatar = AvatarUtility.generateNew(perUserAvId,null,_currUserName,-1,0,onAvatarItemData);
               }
               avt = _offlineBuddyAvatar;
            }
            ui = gMainFrame.userInfo.getUserInfoByUserName(_currUserName);
            _currUserNameModerated = ui.getModeratedUserName();
            _currUserAccountType = ui.getAccountType();
            if(avInfo.isMember)
            {
               _currNameBarData = ui.nameBarData;
               _buddyCardMC.nonmemberNameBar.visible = false;
               _buddyCardMC.memberNameBar.nubType = "";
               _buddyCardMC.memberNameBar.setColorAndBadge(ui.nameBarData);
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
            drawMainAvatar(avt);
            _currPerUserAvId = perUserAvId;
            if((Boolean(ui && ui.isGuide) || Boolean(avt.isShaman)) && !(Boolean(gMainFrame.userInfo.isModerator) || Boolean(gMainFrame.userInfo.isGuide)))
            {
               if(Boolean(ui) && ui.isGuide)
               {
                  _buddyCardMC.memberNameBar.setAvName(LocalizationManager.translateIdOnly(11236),false);
                  _buddyCardMC.shamanDescTxt.text = getGuideText(avt.userName);
                  _buddyCardMC.shamanDescTxt.height = _buddyCardMC.shamanDescTxt.textHeight + 5;
                  _buddyCardMC.shamanDescTxt.y = 0 - _buddyCardMC.shamanDescTxt.height / 2;
               }
               else
               {
                  _buddyCardMC.memberNameBar.setAvName(LocalizationManager.translateIdOnly(11237),false);
                  _buddyCardMC.avatarNameTxt.text = avt.shamanName;
                  _buddyCardMC.shamanDescTxt.text = avt.shamanText;
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
            if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
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
      }
      
      private static function drawMainAvatar(avt:Avatar, shouldRedraw:Boolean = false) : void
      {
         var currAI:AvatarInfo = null;
         if(Boolean(_buddyCardMC) && (_currPerUserAvId != avt.perUserAvId || shouldRedraw))
         {
            if(Utility.isOcean(avt.enviroTypeFlag))
            {
               if(Utility.isLand(avt.enviroTypeFlag))
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
            currAI = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(avt.userName,avt.perUserAvId);
            if(Boolean(currAI) && currAI.questLevel > 0)
            {
               loadXPShape(currAI.questLevel);
            }
            else
            {
               _buddyCardMC.xpShape.visible = false;
            }
            _mainAvatarView = new AvatarView();
            _mainAvatarView.init(avt);
            if(avt.avTypeId >= 0)
            {
               _mainAvatarView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,positionAndAddMainAvatarView);
            }
            _buddyCardMC.avatarNameTxt.text = avt.avName;
            _currPetIdx = -1;
            _currPerUserAvId = avt.perUserAvId;
            AvatarManager.buddyCardAvatarView = _mainAvatarView;
         }
      }
      
      private static function loadXPShape(curLevel:int) : void
      {
         var frameId:int = Utility.getColorId(_currNameBarData);
         if(_buddyCardMC.xpShape.currentFrame != frameId)
         {
            _buddyCardMC.xpShape.gotoAndStop(frameId);
         }
         Utility.createXpShape(curLevel,!_buddyCardMC.nonmemberNameBar.visible,_buddyCardMC.xpShape[_buddyCardMC.xpShape.currentLabels[frameId - 1].name].mouse.up.icon,null,int.MAX_VALUE);
      }
      
      public static function onAvatarItemData() : void
      {
         if(_offlineBuddyAvatar != null)
         {
            drawMainAvatar(_offlineBuddyAvatar,true);
         }
      }
      
      private static function clearPetAndAvatarViews() : void
      {
         if(Boolean(_mainPetView))
         {
            if(Boolean(_buddyCardMC.charBox.contains(_mainPetView)))
            {
               _buddyCardMC.charBox.removeChild(_mainPetView);
            }
            _mainPetView = null;
         }
         if(Boolean(_mainAvatarView))
         {
            if(Boolean(_buddyCardMC.charBox.contains(_mainAvatarView)))
            {
               _buddyCardMC.charBox.removeChild(_mainAvatarView);
            }
            _mainAvatarView.destroy();
            _mainAvatarView = null;
         }
      }
      
      private static function drawMainPet(myPet:GuiPet) : void
      {
         var i:int = 0;
         if(_currPetIdx != myPet.idx)
         {
            _buddyCardMC.charBox.gotoAndStop(1);
            _loadingSpiralAvatar = new LoadingSpiral(_buddyCardMC.charBox);
            if(Boolean(_mainPetView))
            {
               if(Boolean(_buddyCardMC.charBox.contains(_mainPetView)))
               {
                  _buddyCardMC.charBox.removeChild(_mainPetView);
               }
               _mainPetView = null;
            }
            if(Boolean(_mainAvatarView))
            {
               if(Boolean(_buddyCardMC.charBox.contains(_mainAvatarView)))
               {
                  _buddyCardMC.charBox.removeChild(_mainAvatarView);
               }
               _mainAvatarView.destroy();
               _mainAvatarView = null;
               AvatarManager.buddyCardAvatarView = null;
            }
            _currPerUserAvId = -1;
            _currPetIdx = myPet.idx;
            for(i = 0; i < _pets.length; i++)
            {
               if(_pets[i].idx == _currPetIdx)
               {
                  createMainPetView(i);
                  break;
               }
            }
         }
      }
      
      private static function createMainPetView(idx:int) : void
      {
         _mainPetView = new GuiPet(_pets[idx].idx,_pets[idx].lBits,_pets[idx].uBits,_pets[idx].eBits,_pets[idx].type,_pets[idx].name,onMainPetLoaded);
         _buddyCardMC.avatarNameTxt.text = _mainPetView.petName;
         if(Boolean(_buddyCardPopup) && Boolean(_buddyCardMC))
         {
            if(_mainPetView.canGoOnLand() && !_mainPetView.canGoInOcean() || AvatarManager.roomEnviroType == Utility.ENVIRO_LAND && _mainPetView.canGoOnLand())
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
      
      private static function onMainPetLoaded(content:MovieClip, pet:GuiPet) : void
      {
         _mainPetView.y += _buddyCardMC.charBox.height * 0.4;
         _mainPetView.scaleX = _mainPetView.scaleY = 4.5;
         _loadingSpiralAvatar.visible = false;
      }
      
      private static function positionAndAddMainAvatarView(layerAnim:LayerAnim, animId:int) : void
      {
         var offset:Point = getAvOffsetByDefId(_mainAvatarView.avTypeId);
         _mainAvatarView.x = offset.x;
         _mainAvatarView.y = offset.y;
         if(Boolean(_buddyCardPopup) && Boolean(_buddyCardMC))
         {
            _buddyCardMC.charBox.addChild(_mainAvatarView);
         }
         _loadingSpiralAvatar.visible = false;
      }
      
      public static function getAvOffsetByDefId(avtDefId:int) : Point
      {
         switch(avtDefId)
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
            default:
               return new Point(115,110);
         }
      }
      
      private static function checkBuddyRoomAgainstMine(buddyRoomIsGame:Boolean) : void
      {
         var bud:Buddy = null;
         if(gMainFrame.server.getCurrentRoomName() != _buddyRoomName)
         {
            bud = BuddyManager.getBuddyByUserName(_currUserName);
            if(Boolean(!buddyRoomIsGame) && Boolean(bud) && bud.isOnline)
            {
               if(Boolean(_buddyCardMC.goToBtn.isGray) && gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST)
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
      
      public static function userNameChange(oldUserName:String, newUserName:String, newModeratedUserName:String) : void
      {
         if(Boolean(oldUserName) && Boolean(newUserName))
         {
            if(_currUserName == oldUserName)
            {
               _currUserName = newUserName;
               _currUserNameModerated = newModeratedUserName;
            }
            if(Boolean(_buddyCardMC))
            {
               _buddyCardMC.memberNameBar.setAvName(_currUserNameModerated,false);
               _buddyCardMC.userNameTxt.text = _currUserNameModerated;
            }
         }
      }
      
      public static function updateCurrBuddyCardAvatar(newAvt:Avatar = null) : void
      {
         if(newAvt == null)
         {
            newAvt = _offlineBuddyAvatar;
         }
         else if(Boolean(_buddyCardMC) && _buddyCardMC.visible)
         {
            drawMainAvatar(newAvt);
         }
         if(Boolean(_mainAvatarView))
         {
            _mainAvatarView.resetAvatar(newAvt);
         }
         if(Boolean(_buddyCardMC) && Boolean(_buddyCardMC.avatarNameTxt))
         {
            _buddyCardMC.avatarNameTxt.text = newAvt.avName;
         }
         if(_isDropDownOpen && Boolean(_buddyCardMC.charsBtnUp.visible))
         {
            requestAvatarList();
         }
      }
      
      public static function updateDropDown(avatarName:String) : void
      {
         if(Boolean(_currUserName == avatarName && _isDropDownOpen) && Boolean(_buddyCardMC.charsBtnUp.visible) && !_isFromUserClickRequest)
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
      
      public static function grayOutGoToDenBtn(shouldBeGray:Boolean, denOwnerName:String = "") : void
      {
         if(Boolean(_buddyCardMC))
         {
            if(shouldBeGray && gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
            {
               return;
            }
            _buddyCardMC.goToBtn.activateGrayState(shouldBeGray);
            if(_currUserName == denOwnerName || denOwnerName == null)
            {
               _buddyCardMC.denBtn.activateGrayState(shouldBeGray);
            }
         }
      }
      
      public static function resetBuddyCardForArchiveMode() : void
      {
         var resetUsername:String = _currUserName;
         _currUserName = null;
         _currUserNameModerated = "";
         _currUserAccountType = 0;
         showBuddyCard({
            "userName":resetUsername,
            "onlineStatus":SFClient.STATUS_OFFLINE_ARCHIVED
         });
      }
      
      public static function closeBuddyCard() : void
      {
         _buddyRoomTimer.reset();
         removeCardListeners();
         destroyCard();
      }
      
      private static function addRemoveBlockDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
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
      
      private static function addRemoveBlockDownOverHandler(m:MouseEvent) : void
      {
         if(!m.currentTarget.isGray)
         {
            if(BuddyManager.isBlocked(_currUserName))
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14628),790,175);
               GuiManager.toolTip.startTimer(m);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14629),790,175);
               GuiManager.toolTip.startTimer(m);
            }
         }
      }
      
      private static function requestAvatarList(isFromUserClick:Boolean = false) : void
      {
         _loadingSpiralDropDown.visible = true;
         _isFromUserClickRequest = isFromUserClick;
         AvatarXtCommManager.requestAvatarList([1,_currUserName],drawAvatarsInDropDown);
      }
      
      private static function drawAvatarsInDropDown(isArchived:Boolean) : void
      {
         var j:int = 0;
         var o:Object = null;
         var k:int = 0;
         var i:int = 0;
         var avt:Avatar = null;
         var avtView:AvatarView = null;
         if(isArchived)
         {
            resetBuddyCardForArchiveMode();
            return;
         }
         _userInfo = gMainFrame.userInfo.getUserInfoByUserName(_currUserName);
         if(Boolean(_userInfo) && _currUserName == _userInfo.userName)
         {
            if(Boolean(_avatarViews))
            {
               for(k = 0; k < _avatarViews.length; k++)
               {
                  _avatarViews[k].destroy();
                  _avatarViews[k] = null;
               }
               _avatarViews.splice(0,_avatarViews.length);
               _avatarViews = null;
            }
            if(Boolean(_playerAvatars))
            {
               for(i = 0; i < _playerAvatars.length; i++)
               {
                  _playerAvatars[i].destroy();
                  _playerAvatars[i] = null;
               }
               _playerAvatars = null;
            }
            _playerAvatars = new Array();
            _avatarViews = new Array();
            _numViewsLoaded = 0;
            _numberOfAvatars = 0;
            j = 0;
            for each(o in _userInfo.avList)
            {
               avt = new Avatar();
               avt.init(o.perUserAvId,o.userName,o.type,o.colors,null,_currUserName);
               avt = AvatarUtility.generateNew(o.perUserAvId,avt,o.userName,AvatarManager.roomEnviroType);
               _playerAvatars.push(avt);
               avtView = new AvatarView();
               avtView.init(avt,updateViewPosition);
               avtView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,onViewLoaded);
               _avatarViews.push(avtView);
               updateViewPosition(avtView);
               j++;
            }
            _numberOfAvatars = j;
         }
      }
      
      private static function onViewLoaded(la:LayerAnim, id:int) : void
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
      
      public static function updateViewPosition(avtView:AvatarView) : void
      {
         var xOffset:int = 0;
         var yOffset:int = 0;
         switch(avtView.avTypeId)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               xOffset = 62;
               yOffset = 51;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               xOffset = 45;
               yOffset = 70;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               xOffset = 70;
               yOffset = 62;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               xOffset = 87;
               yOffset = 63;
               avtView.scaleX = 0.5;
               avtView.scaleY = 0.5;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               xOffset = 64;
               yOffset = 55;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               xOffset = 82;
               yOffset = 67;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               xOffset = 100;
               yOffset = 57;
               avtView.scaleX = 0.6;
               avtView.scaleY = 0.6;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               xOffset = 70;
               yOffset = 58;
               avtView.scaleX = 0.35;
               avtView.scaleY = 0.35;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               xOffset = 67;
               yOffset = 55;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               xOffset = 70;
               yOffset = 55;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               xOffset = 73;
               yOffset = 57;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               xOffset = 75;
               yOffset = 80;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               xOffset = 63;
               yOffset = 60;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               xOffset = 65;
               yOffset = 55;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               xOffset = 69;
               yOffset = 60;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               xOffset = 65;
               yOffset = 70;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               xOffset = 79;
               yOffset = 70;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               xOffset = 75;
               yOffset = 60;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               xOffset = 64;
               yOffset = 63;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               xOffset = 60;
               yOffset = 67;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               xOffset = 60;
               yOffset = 65;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               xOffset = 60;
               yOffset = 75;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               xOffset = 62;
               yOffset = 63;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               xOffset = 59;
               yOffset = 63;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               xOffset = 70;
               yOffset = 73;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               xOffset = 75;
               yOffset = 73;
               avtView.scaleX = 0.4;
               avtView.scaleY = 0.4;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               xOffset = 65;
               yOffset = 48;
               avtView.scaleX = 0.3;
               avtView.scaleY = 0.3;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               xOffset = 55;
               yOffset = 48;
               avtView.scaleX = 0.25;
               avtView.scaleY = 0.25;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               xOffset = 55;
               yOffset = 48;
               avtView.scaleX = 0.25;
               avtView.scaleY = 0.25;
               break;
            default:
               xOffset = 65;
               yOffset = 59;
               avtView.scaleX = 0.5;
               avtView.scaleY = 0.5;
         }
         avtView.x = xOffset;
         avtView.y = yOffset;
      }
      
      public static function onDenPrivacyResponse(userName:String, isDenPrivate:Boolean) : void
      {
         if(userName == _currUserName)
         {
            if(Boolean(_buddyCardMC))
            {
               if(!gMainFrame.userInfo.isModerator && (gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST || isDenPrivate))
               {
                  _buddyCardMC.denBtn.activateGrayState(isDenPrivate);
               }
            }
         }
      }
      
      private static function onPlayerWallPrivacyGet(status:Boolean, privacyId:int) : void
      {
         if(status)
         {
            if(privacyId == 0)
            {
               BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
            }
            else if(privacyId == 1)
            {
               if(_currUserIsBuddy)
               {
                  BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
               }
               else
               {
                  _buddyCardMC.playerWallBtn.activateGrayState(true);
               }
            }
            else if(privacyId == 2)
            {
               _buddyCardMC.playerWallBtn.activateGrayState(true);
            }
         }
      }
      
      public static function onTradeListReceived(userName:String, tradeList:Array) : void
      {
         if(userName == _currUserName)
         {
            _tradeList = tradeList;
            createTradeWindows();
         }
      }
      
      public static function getTradeList() : Array
      {
         return _tradeList;
      }
      
      private static function createAvatarWindows() : void
      {
         var numItems:int = 0;
         var xCount:int = 0;
         var yCount:int = 0;
         var i:int = 0;
         var scrollHeight:Number = NaN;
         var mc:MovieClip = null;
         if(Boolean(_dropDownScrollbar))
         {
            _dropDownScrollbar.destroy();
            _dropDownScrollbar = null;
         }
         if(Boolean(_itemWindows) && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(Boolean(_avatarViews))
         {
            numItems = int(_avatarViews.length);
            xCount = Math.min(numItems,4);
            yCount = Math.ceil(xCount / 4);
            _itemWindows = new WindowGenerator();
            _itemWindows.init(xCount,yCount,numItems,2,0,0,ItemWindowAvtPetSml,_avatarViews,"",{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{
               "isMember":!_buddyCardMC.nonmemberNameBar.visible,
               "nameBarData":_currNameBarData
            },null,false,false);
            _buddyCardMC.dropDown.itemWindow.addChild(_itemWindows);
            for(i = 0; i < numItems; i++)
            {
               mc = MovieClip(_itemWindows.bg.getChildAt(i));
               if(_userInfo.currPerUserAvId == _playerAvatars[i].perUserAvId)
               {
                  mc.sel.visible = true;
               }
            }
            scrollHeight = Math.ceil(numItems / 4) * 66;
            _dropDownScrollbar = new SBScrollbar();
            _dropDownScrollbar.init(_itemWindows,276,132,0,"scrollbar2",66,0,scrollHeight);
         }
      }
      
      private static function requestAchievementsList() : void
      {
         _loadingSpiralDropDown.visible = true;
         AchievementXtCommManager.requestAchievements(_currUserName,achievementListCallback);
      }
      
      private static function achievementListCallback(aList:Array, isArchived:Boolean = false) : void
      {
         var i:int = 0;
         if(isArchived)
         {
            resetBuddyCardForArchiveMode();
            return;
         }
         _achievements = [];
         if(Boolean(aList))
         {
            for(i = 0; i < aList.length; i++)
            {
               _achievements.push(aList[i]);
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
         var numItemsInCurrentArray:int = 0;
         var xCount:int = 0;
         var yCount:int = 0;
         if(Boolean(_dropDownScrollbar))
         {
            _dropDownScrollbar.destroy();
            _dropDownScrollbar = null;
         }
         if(Boolean(_itemWindows) && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(Boolean(_achievements))
         {
            numItemsInCurrentArray = int(_achievements.length);
            xCount = Math.min(numItemsInCurrentArray,4);
            yCount = Math.ceil(xCount / 4);
            _itemWindows = new WindowGenerator();
            _itemWindows.init(xCount,yCount,numItemsInCurrentArray,6,6,0,ItemWindowBase,_achievements,"image",{
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{"itemClassName":"awardSmlCont"},null,false,false);
            _buddyCardMC.dropDown.itemWindow.addChild(_itemWindows);
            _dropDownScrollbar = new SBScrollbar();
            _dropDownScrollbar.init(_itemWindows,276,132,0,"scrollbar2",66);
         }
      }
      
      private static function requestPetsList() : void
      {
         _loadingSpiralDropDown.visible = true;
         PetXtCommManager.sendPetListRequest(_currUserName,petListCallback);
      }
      
      private static function petListCallback(pList:Array, isArchived:Boolean) : void
      {
         var i:int = 0;
         if(isArchived)
         {
            resetBuddyCardForArchiveMode();
            return;
         }
         _pets = [];
         _petViews = [];
         if(Boolean(pList))
         {
            for(i = 0; i < pList.length; i++)
            {
               _pets.push(pList[i]);
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
         for(var i:int = 0; i < _pets.length; i++)
         {
            _petViews.push(new GuiPet(_pets[i].idx,_pets[i].lBits,_pets[i].uBits,_pets[i].eBits,_pets[i].type,_pets[i].name,null));
         }
      }
      
      private static function createPetsWindows() : void
      {
         var numItemsInCurrentArray:int = 0;
         var xCount:int = 0;
         var yCount:int = 0;
         if(Boolean(_dropDownScrollbar))
         {
            _dropDownScrollbar.destroy();
            _dropDownScrollbar = null;
         }
         if(Boolean(_itemWindows) && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(Boolean(_pets))
         {
            numItemsInCurrentArray = int(_pets.length);
            xCount = Math.min(numItemsInCurrentArray,4);
            yCount = Math.ceil(xCount / 4);
            _itemWindows = new WindowGenerator();
            _itemWindows.init(xCount,yCount,numItemsInCurrentArray,2,0,0,ItemWindowAvtPetSml,_petViews,"",{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{"isPet":true},null,false,false);
            _buddyCardMC.dropDown.itemWindow.addChild(_itemWindows);
            _dropDownScrollbar = new SBScrollbar();
            _dropDownScrollbar.init(_itemWindows,276,132,0,"scrollbar2",66);
         }
      }
      
      private static function getPVPIcons() : void
      {
         var pvpGameHelper:MediaHelper = null;
         _views = new Array();
         for(var i:int = 0; i < _pvpGameList.length; i++)
         {
            pvpGameHelper = new MediaHelper();
            pvpGameHelper.init(_pvpGameList[i].gameCardMediaId,mediaHelperCallback,true);
            _views[i] = pvpGameHelper;
         }
      }
      
      private static function mediaHelperCallback(img:MovieClip) : void
      {
         var mc:MovieClip = null;
         for(var i:int = 0; i < _views.length; i++)
         {
            if(_views[i] == img.mediaHelper)
            {
               mc = MovieClip(_pvpItemWindows.bg.getChildAt(i));
               mc.itemLayer.addChild(img);
            }
         }
      }
      
      private static function createPVPWindows() : void
      {
         if(Boolean(_pvpScrollBar))
         {
            _pvpScrollBar.destroy();
            _pvpScrollBar = null;
         }
         if(Boolean(_pvpItemWindows) && _pvpItemWindows.numChildren > 0)
         {
            _pvpItemWindows.destroy();
            _pvpItemWindows = null;
         }
         var numItemsInCurrentArray:int = int(_pvpGameList.length);
         var xCount:int = Math.min(numItemsInCurrentArray,2);
         _pvpItemWindows = new WindowGenerator();
         _pvpItemWindows.init(xCount,xCount,numItemsInCurrentArray,2,2,0,ItemWindowGame,null,"",{
            "mouseDown":sideMenuMouseDown,
            "mouseOver":sideMenuMouseOver,
            "mouseOut":winMouseSideOut
         },null,null,false,false);
         _buddyCardMC.gameTabItemWindow.addChild(_pvpItemWindows);
         _pvpScrollBar = new SBScrollbar();
         _pvpScrollBar.init(_pvpItemWindows,155,156,0,"scrollbar2",78,0,Math.ceil(numItemsInCurrentArray / xCount) * 78);
      }
      
      private static function createTradeWindows() : void
      {
         if(Boolean(_tradeScrollBar))
         {
            _tradeScrollBar.destroy();
            _tradeScrollBar = null;
         }
         if(Boolean(_tradeItemWindows))
         {
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         if(Boolean(_tradeItemWindows) && _tradeItemWindows.numChildren > 0)
         {
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         var numItemsInCurrentArray:int = int(_tradeList.length);
         var xCount:int = Math.min(numItemsInCurrentArray,2);
         _tradeItemWindows = new WindowGenerator();
         _tradeItemWindows.init(xCount,xCount,numItemsInCurrentArray,2,2,1,ItemWindowOriginal,_tradeList,"icon",{
            "mouseDown":sideMenuMouseDown,
            "mouseOver":sideMenuMouseOver,
            "mouseOut":winMouseSideOut
         },{"isViewingATradeList":true},null,false,false);
         _buddyCardMC.tradeTabItemWindow.addChild(_tradeItemWindows);
         _loadingSpiralPullOut.visible = false;
         _tradeScrollBar = new SBScrollbar();
         _tradeScrollBar.init(_tradeItemWindows,176,172,0,"scrollbar2",86);
      }
      
      private static function winMouseOver(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.hasOwnProperty("charLayer"))
         {
            GuiManager.toolTip.init(_buddyCardMC.dropDown.itemWindow,_achievements[evt.currentTarget.index].name,evt.currentTarget.x + evt.currentTarget.width * 0.5,evt.currentTarget.y + _itemWindows.y + 50);
            GuiManager.toolTip.startTimer(evt);
         }
         else
         {
            evt.currentTarget.gotoAndStop("over");
            GuiManager.toolTip.init(_buddyCardMC.dropDown.itemWindow,Boolean(evt.currentTarget.isPet) ? _petViews[evt.currentTarget.index].petName : _playerAvatars[evt.currentTarget.index].avName,evt.currentTarget.x + evt.currentTarget.sel.width * 0.5,evt.currentTarget.y + _itemWindows.y + 50);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private static function sideMenuMouseOver(evt:MouseEvent) : void
      {
         var image:MovieClip = null;
         if(_isGameTabOpen)
         {
            if(evt.currentTarget.parent.numChildren > 0)
            {
               GuiManager.toolTip.init(_buddyCardMC.gameTabItemWindow,LocalizationManager.translateIdOnly(_pvpGameList[evt.currentTarget.index].titleStrId),evt.currentTarget.x + evt.currentTarget.width * 0.5,evt.currentTarget.y + _pvpItemWindows.y + 70);
               GuiManager.toolTip.startTimer(evt);
            }
         }
         else if(_isTradingTabOpen)
         {
            if(evt.currentTarget.numChildren >= 2)
            {
               image = evt.currentTarget.getChildAt(1);
               if(evt.currentTarget.cir.currentFrameLabel == "down")
               {
                  evt.currentTarget.cir.gotoAndStop("downMouse");
               }
               else if(evt.currentTarget.cir.currentFrameLabel != "downMouse")
               {
                  evt.currentTarget.cir.gotoAndStop("over");
               }
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private static function winMouseSideOut(evt:MouseEvent) : void
      {
         if(_isTradingTabOpen)
         {
            if(evt.currentTarget.numChildren >= 2 && Boolean(evt.currentTarget.cir))
            {
               if(evt.currentTarget.cir.currentFrameLabel == "downMouse")
               {
                  evt.currentTarget.cir.gotoAndStop("down");
               }
               else if(evt.currentTarget.cir.currentFrameLabel != "down")
               {
                  evt.currentTarget.cir.gotoAndStop("up");
               }
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function winMouseOut(evt:MouseEvent) : void
      {
         if(Boolean(_isDropDownOpen) && Boolean(_buddyCardMC) && (Boolean(_buddyCardMC.petsBtnUp.visible) || Boolean(_buddyCardMC.charsBtnUp.visible)))
         {
            evt.currentTarget.gotoAndStop("up");
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function winMouseClick(evt:MouseEvent) : void
      {
         var mc:MovieClip = null;
         evt.currentTarget.gotoAndStop("down");
         for(var j:int = 0; j < _itemWindows.bg.numChildren; j++)
         {
            mc = MovieClip(_itemWindows.bg.getChildAt(j));
            mc.sel.visible = false;
         }
         evt.currentTarget.sel.visible = true;
         if(Boolean(evt.currentTarget.isPet))
         {
            _buddyCardMC.xpShape.visible = false;
            drawMainPet(_petViews[evt.currentTarget.index]);
         }
         else
         {
            _buddyCardMC.xpShape.visible = true;
            drawMainAvatar(_playerAvatars[evt.currentTarget.index]);
         }
      }
      
      private static function sideMenuMouseDown(evt:MouseEvent) : void
      {
         var bud:Buddy = null;
         var gameDefId:int = 0;
         var uScoreIdx:int = 0;
         var idx:int = 0;
         evt.stopPropagation();
         if(_isGameTabOpen)
         {
            if(_buddyShardId != RoomManagerWorld.instance.shardId && _buddyRoomName != gMainFrame.server.getCurrentRoomName())
            {
               uScoreIdx = _buddyRoomName.indexOf("_");
               if(uScoreIdx > 0 && !isNaN(Number(_buddyRoomName.charAt(uScoreIdx - 1))) && !isNaN(Number(_buddyRoomName.charAt(uScoreIdx + 1))))
               {
                  new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14701,_currUserNameModerated));
               }
               else if(QuestManager.isInPrivateAdventureState)
               {
                  QuestManager.showLeaveQuestLobbyPopup(sideMenuMouseDown,evt);
               }
               else
               {
                  new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14702),true,onConfirmServerSwitch);
               }
               return;
            }
            gameDefId = int(_pvpGameList[evt.currentTarget.index].gameDefId);
            MinigameXtCommManager.sendMinigamePvpMsg(gameDefId,MinigameXtCommManager.PVP_REQUEST_OR_ACCEPT,_currUserName);
            MinigameManager.displaySentRequestPopup(_pvpGameList[evt.currentTarget.index].gameCardMediaId,_currUserNameModerated);
            MinigameManager.readySelfForPvpGame({"typeDefId":gameDefId},_currUserName,true);
            closeBuddyCard();
         }
         else if(_isTradingTabOpen)
         {
            bud = BuddyManager.getBuddyByUserName(_currUserName);
            if(Boolean(bud) && Boolean(_buddyShardId != RoomManagerWorld.instance.shardId) && _buddyRoomName != gMainFrame.server.getCurrentRoomName())
            {
               idx = _buddyRoomName.indexOf("_");
               if(idx > 0 && !isNaN(Number(_buddyRoomName.charAt(idx - 1))) && !isNaN(Number(_buddyRoomName.charAt(idx + 1))))
               {
                  new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(11388,_currUserNameModerated));
               }
               else if(QuestManager.isInPrivateAdventureState)
               {
                  QuestManager.showLeaveQuestLobbyPopup(sideMenuMouseDown,evt);
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
               "type":(_tradeList[evt.currentTarget.index] is Item ? 0 : 1),
               "invIdx":_tradeList[evt.currentTarget.index].invIdx
            });
         }
      }
      
      private static function onConfirmServerSwitch(o:Object) : void
      {
         if(Boolean(o.status))
         {
            gotoDownHandler(null);
         }
      }
      
      private static function getShard(roomName:String) : int
      {
         return int(roomName.substring(roomName.lastIndexOf("#") + 1,roomName.length));
      }
      
      private static function dropDownHandler(m:MouseEvent) : void
      {
         var now:Number = new Date().getTime();
         if(m.currentTarget.name == _buddyCardMC.charsBtnUp.name)
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
                  if(now - _avatarTimeStamp > REQUEST_INTERVAL)
                  {
                     requestAvatarList(true);
                     _avatarTimeStamp = now;
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
         else if(m.currentTarget.name == _buddyCardMC.charsBtnDn.name && !_loadingSpiralDropDown.visible)
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
            if(now - _avatarTimeStamp > REQUEST_INTERVAL)
            {
               requestAvatarList(true);
               _avatarTimeStamp = now;
            }
            else
            {
               createAvatarWindows();
            }
         }
         else if(m.currentTarget.name == _buddyCardMC.awardsBtnUp.name)
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
                  if(now - _achievementTimeStamp > REQUEST_INTERVAL)
                  {
                     requestAchievementsList();
                     _achievementTimeStamp = now;
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
         else if(m.currentTarget.name == _buddyCardMC.awardsBtnDn.name && !_loadingSpiralDropDown.visible)
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
            if(now - _achievementTimeStamp > REQUEST_INTERVAL)
            {
               requestAchievementsList();
               _achievementTimeStamp = now;
            }
            else
            {
               createAchievementsWindows();
            }
         }
         else if(m.currentTarget.name == _buddyCardMC.petsBtnUp.name)
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
                  if(now - _petsTimeStamp > REQUEST_INTERVAL)
                  {
                     requestPetsList();
                     _petsTimeStamp = now;
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
         else if(m.currentTarget.name == _buddyCardMC.petsBtnDn.name && !_loadingSpiralDropDown.visible)
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
            if(now - _petsTimeStamp > REQUEST_INTERVAL)
            {
               requestPetsList();
               _petsTimeStamp = now;
            }
            else
            {
               createPetsWindows();
            }
         }
      }
      
      private static function sideMenuHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!_isGameTabOpen && m.currentTarget.name == _buddyCardMC.gameTabBtn.name)
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
                  if(Boolean(_pvpScrollBar))
                  {
                     _pvpScrollBar.destroy();
                  }
                  _pvpScrollBar = new SBScrollbar();
                  _pvpScrollBar.init(_pvpItemWindows,155,156,0,"scrollbar2",77);
               }
               openSideMenu(_buddyCardMC.gameTab);
            }
         }
         else if(m.currentTarget.name == _buddyCardMC.gameTabBtn.name && _isGameTabOpen)
         {
            closeSideMenu(_buddyCardMC.gameTab);
         }
         else if(m.currentTarget.name == _buddyCardMC.tradeTabBtn.name && _isTradingTabOpen)
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
      
      private static function sideMenuOverHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(m.currentTarget.name == _buddyCardMC.gameTabBtn.name)
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
         GuiManager.toolTip.startTimer(m);
      }
      
      private static function dropDownOverHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(m.currentTarget.name == _buddyCardMC.charsBtnUp.name)
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
         else if(m.currentTarget.name == _buddyCardMC.awardsBtnUp.name)
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
         else if(m.currentTarget.name == _buddyCardMC.petsBtnUp.name)
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
         else if(m.currentTarget.name == _buddyCardMC.charsBtnDn.name)
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
         else if(m.currentTarget.name == _buddyCardMC.awardsBtnDn.name)
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
         else if(m.currentTarget.name == _buddyCardMC.petsBtnDn.name)
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
         GuiManager.toolTip.startTimer(m);
      }
      
      private static function btnOutHandler(m:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function openDropDown(dropDown:MovieClip) : void
      {
         if(_bDropDownTweenFinished && !_isDropDownOpen)
         {
            new GTween(dropDown,0.5,{"y":dropDown.y + 173},{
               "ease":TweenManager.quadratic,
               "onComplete":dropDownComplete
            });
            _bDropDownTweenFinished = false;
            _isDropDownOpen = true;
            AJAudio.playBuddyCardOpen();
         }
      }
      
      private static function closeDropDown(dropDown:MovieClip) : void
      {
         if(_isDropDownOpen && _bDropDownTweenFinished)
         {
            new GTween(dropDown,0.5,{"y":dropDown.y - 173},{
               "ease":TweenManager.quadratic,
               "onComplete":dropDownComplete
            });
            _bDropDownTweenFinished = false;
            _isDropDownOpen = false;
            AJAudio.playBuddyCardClose();
         }
      }
      
      private static function openSideMenu(sideMenu:MovieClip) : void
      {
         var bud:Buddy = BuddyManager.getBuddyByUserName(_currUserName);
         if(sideMenu == _buddyCardMC.gameTab && _sideMenuTweenFinished && !_isGameTabOpen && !_buddyCardMC.gameTabBtn.isGray)
         {
            new GTween(sideMenu,0.5,{"x":sideMenu.x - 208},{
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
         else if(sideMenu == _buddyCardMC.tradeTab && _sideMenuTweenFinished && !_isTradingTabOpen && !_buddyCardMC.tradeTabBtn.isGray)
         {
            new GTween(sideMenu,0.5,{"x":sideMenu.x - 218},{
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
      
      private static function closeSideMenu(sideMenu:MovieClip) : void
      {
         if(sideMenu == _buddyCardMC.gameTab && _isGameTabOpen && _sideMenuTweenFinished)
         {
            new GTween(sideMenu,0.5,{"x":sideMenu.x + 208},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            _sideMenuTweenFinished = false;
            _isGameTabOpen = false;
            AJAudio.playBuddyCardClose();
         }
         else if(sideMenu == _buddyCardMC.tradeTab && _isTradingTabOpen && _sideMenuTweenFinished)
         {
            new GTween(sideMenu,0.5,{"x":sideMenu.x + 218},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            _sideMenuTweenFinished = false;
            _isTradingTabOpen = false;
            AJAudio.playBuddyCardClose();
         }
      }
      
      private static function dropDownComplete(tween:GTween) : void
      {
         _bDropDownTweenFinished = true;
      }
      
      private static function sideMenuComplete(tween:GTween) : void
      {
         _sideMenuTweenFinished = true;
      }
      
      private static function buddyCardAddIgnoreConfirmCallback(o:Object) : void
      {
         if(Boolean(o.status))
         {
            _buddyCardMC.blockBtn.activateGrayState(true);
            BuddyXtCommManager.sendBuddyBlockRequest(_currUserName);
         }
      }
      
      private static function buddyCardRemoveIgnoreConfirmCallback(o:Object) : void
      {
         if(Boolean(o.status))
         {
            _buddyCardMC.unblockBtn.activateGrayState(true);
            BuddyXtCommManager.sendBuddyUnblockRequest(_currUserName);
         }
      }
      
      private static function gotoDownHandler(m:MouseEvent) : void
      {
         if(Boolean(m))
         {
            m.stopPropagation();
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
               QuestManager.showLeaveQuestLobbyPopup(gotoDownHandler,m);
            }
         }
      }
      
      private static function goToRollOverHandler(m:MouseEvent) : void
      {
         if(_currUserIsBuddy && !_buddyCardMC.goToBtn.isGray)
         {
            if(_buddyCardMC.locationPopupTxt.text != "")
            {
               _buddyCardMC.locationPopup.visible = true;
            }
         }
      }
      
      private static function goToRollOutHandler(m:MouseEvent) : void
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
         return _currUserName;
      }
      
      private static function denDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(Boolean(_buddyCardMC.denBtn.isGray) || Boolean(_buddyCardMC.wasSearched))
         {
            return;
         }
         if(_currUserName != "")
         {
            if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(denDownHandler,m);
               return;
            }
            if(!RoomXtCommManager.isSwitching)
            {
               DenXtCommManager.requestDenJoinFull("den" + _currUserName);
            }
         }
      }
      
      private static function denDownOverHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(Boolean(_buddyCardMC.denBtn.isGray) || Boolean(_buddyCardMC.wasSearched))
         {
            return;
         }
         GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14632),790,120);
         GuiManager.toolTip.startTimer(m);
      }
      
      private static function reportDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
         {
            if(Boolean(_reportAPlayer))
            {
               _reportAPlayer.destroy();
            }
            else
            {
               _reportAPlayer = new ReportAPlayer();
               _reportAPlayer.init(GuiManager.guiLayer,onReportAPlayerClose,true,_currUserName,_currUserNameModerated,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
            }
         }
      }
      
      private static function reportDownOverHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14633),845,175);
            GuiManager.toolTip.startTimer(m);
         }
      }
      
      private static function onReportAPlayerClose(hasReported:Boolean) : void
      {
         if(Boolean(_reportAPlayer))
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
      }
      
      private static function mailDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
         {
            ECardManager.createCard(_currUserName,_currUserNameModerated,_currUserAccountType,false);
         }
      }
      
      private static function mailDownOverHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14634),827,120);
            GuiManager.toolTip.startTimer(m);
         }
      }
      
      private static function addRemoveBuddyDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
         {
            if(m.currentTarget.name == _buddyCardMC.addBuddyBtn.name)
            {
               if(BuddyManager.isBuddy(_currUserName))
               {
                  throw new Error("ERROR: Trying to add a buddy that is already a buddy! userName=" + _currUserName);
               }
               _buddyCardMC.addBuddyBtn.activateGrayState(true);
               BuddyManager.addRemoveBuddy(_currUserName,_currUserNameModerated,true);
            }
            else if(m.currentTarget.name == _buddyCardMC.removeBuddyBtn.name)
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
      
      private static function addRemoveBuddyDownOverHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
         {
            if(m.currentTarget.name == _buddyCardMC.addBuddyBtn.name)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14635),818,52);
            }
            else if(m.currentTarget.name == _buddyCardMC.removeBuddyBtn.name)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14636),818,52);
            }
            GuiManager.toolTip.startTimer(m);
         }
      }
      
      private static function onPlayerWallDown(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!_buddyCardMC.playerWallBtn.isGray)
         {
            PlayerWallManager.openStrangersPlayerWall(_currUserName);
         }
      }
      
      private static function onPlayerWallOver(m:MouseEvent) : void
      {
         if(!_buddyCardMC.playerWallBtn.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14637),845,62);
            GuiManager.toolTip.startTimer(m);
         }
      }
      
      private static function removeBuddyConfirmCallback(o:Object) : void
      {
         if(Boolean(o.status))
         {
            _buddyCardMC.removeBuddyBtn.activateGrayState(true);
            BuddyManager.addRemoveBuddy(o.passback.currUserName,o.passback.currUserNameModerated,false);
         }
      }
      
      private static function buddyRoomTimerHandler(te:TimerEvent) : void
      {
         BuddyXtCommManager.sendBuddyRoomRequest(_currUserName);
      }
      
      private static function closeTradeHelp(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         _buddyCardMC.tradeHelpPopup.visible = false;
      }
      
      private static function buddyChangedHandler(evt:BuddyEvent) : void
      {
         var bud:Buddy = null;
         var updatedBlockStatus:Boolean = false;
         if(evt.userName == _currUserName)
         {
            bud = BuddyManager.getBuddyByUserName(_currUserName);
            if(_currUserIsBuddy && !bud)
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
               if(!_currUserIsArchived && _currUserIsOnline)
               {
                  _buddyCardMC.tradeTabBtn.activateGrayState(false);
                  _buddyCardMC.gameTabBtn.activateGrayState(false);
               }
               else if(!_currUserIsOnline)
               {
                  _buddyCardMC.tradeTabBtn.activateGrayState(true);
                  _buddyCardMC.gameTabBtn.activateGrayState(true);
               }
               if(!_currUserIsArchived && gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST)
               {
                  DenXtCommManager.requestUserDenPrivacy(_currUserName);
               }
               _buddyRoomTimer.reset();
            }
            else if(!_currUserIsBuddy && Boolean(bud))
            {
               _currUserIsOnline = bud.isOnline;
               _currUserIsBuddy = true;
               _buddyCardMC.addBuddyBtn.visible = false;
               _buddyCardMC.addBuddyBtn.activateGrayState(false);
               _buddyCardMC.removeBuddyBtn.visible = true;
               if(gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST)
               {
                  _buddyCardMC.denBtn.activateGrayState(false);
               }
               _buddyCardMC.gameTabBtn.activateGrayState(false);
               _buddyCardMC.tradeTabBtn.activateGrayState(false);
               if(gMainFrame.server.getCurrentRoomName() != _buddyRoomName)
               {
                  _buddyCardMC.goToBtn.activateGrayState(false);
               }
               _buddyRoomTimer.start();
            }
            else if(Boolean(!_currUserIsOnline) && Boolean(bud) && bud.isOnline)
            {
               _currUserIsOnline = true;
               _buddyCardMC.gameTabBtn.activateGrayState(false);
               _buddyCardMC.tradeTabBtn.activateGrayState(false);
               _buddyRoomTimer.start();
            }
            else if(Boolean(_currUserIsOnline) && Boolean(bud) && !bud.isOnline)
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
               updatedBlockStatus = BuddyManager.isBlocked(_currUserName);
               if(_currUserIsBlocked && !updatedBlockStatus)
               {
                  _currUserIsBlocked = false;
                  _buddyCardMC.blockBtn.visible = true;
                  _buddyCardMC.unblockBtn.visible = false;
                  _buddyCardMC.unblockBtn.activateGrayState(false);
               }
               else if(!_currUserIsBlocked && updatedBlockStatus)
               {
                  _currUserIsBlocked = true;
                  _buddyCardMC.blockBtn.visible = false;
                  _buddyCardMC.blockBtn.activateGrayState(false);
                  _buddyCardMC.unblockBtn.visible = true;
               }
            }
         }
      }
      
      public static function buddyRoomResponseHandler(brName:String, brDisplayName:String, brDisplayNameId:int, brIsGame:Boolean, brShard:int) : void
      {
         var displayNameSplit:Array = null;
         var roomName:String = null;
         if(Boolean(_buddyCardPopup) && Boolean(_buddyCardMC))
         {
            if(_buddyRoomName != brName || brDisplayName != _buddyRoomDisplayName)
            {
               _buddyRoomName = brName;
               _buddyShardId = brShard;
               if(brDisplayName == null || brDisplayName == "")
               {
                  LocalizationManager.translateId(_buddyCardMC.locationPopupTxt,11235);
                  _buddyRoomDisplayName = _buddyCardMC.locationPopupTxt.text;
                  resizeLocationToolTip();
                  _buddyCardMC.goToBtn.activateGrayState(true);
                  _buddyRoomTimer.reset();
                  return;
               }
               if(brDisplayName == "Choosing Server")
               {
                  _buddyCardMC.locationPopupTxt.text = _buddyRoomDisplayName = brDisplayName;
                  resizeLocationToolTip();
                  _buddyCardMC.goToBtn.activateGrayState(true);
                  return;
               }
               if(brDisplayName == LocalizationManager.translateIdOnly(11235))
               {
                  _buddyRoomTimer.reset();
                  _buddyCardMC.locationPopupTxt.text = _buddyRoomDisplayName = brDisplayName;
                  resizeLocationToolTip();
                  _buddyCardMC.goToBtn.activateGrayState(true);
                  return;
               }
               displayNameSplit = brDisplayName.split("\'");
               if(Boolean(displayNameSplit) && displayNameSplit.length > 1)
               {
                  if(_currUserName == displayNameSplit[0])
                  {
                     brDisplayName = _currUserNameModerated + "\'" + displayNameSplit[1];
                  }
               }
               roomName = _buddyRoomDisplayName = brDisplayName;
               if(Boolean(_buddyCardPopup))
               {
                  if(roomName.indexOf("Den") < 0)
                  {
                     if(brDisplayNameId != 0)
                     {
                        _buddyCardMC.locationPopupTxt.text = LocalizationManager.translateIdOnly(brDisplayNameId);
                     }
                     else
                     {
                        _buddyCardMC.locationPopupTxt.text = normalizeName(roomName);
                     }
                  }
                  else
                  {
                     _buddyCardMC.locationPopupTxt.text = roomName;
                  }
                  resizeLocationToolTip();
                  checkBuddyRoomAgainstMine(brIsGame);
               }
            }
         }
      }
      
      public static function buddyBlockInfoResponseHandler(blockeeUserName:String, isBlocked:Boolean) : void
      {
         if(_currUserName == blockeeUserName)
         {
         }
      }
      
      private static function onInfoBtnDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(TRADE_TUT_LIST_ID);
      }
      
      private static function normalizeName(name:String) : String
      {
         var i:int = 0;
         var words:Array = name.split(" ");
         for(var len:int = int(words.length); i < len; )
         {
            words[i] = capitalizeFirstLetter(words[i]);
            i++;
         }
         return words.join(" ");
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
      
      private static function capitalizeFirstLetter(word:String) : String
      {
         var firstLetter:String = null;
         var otherLetters:String = null;
         switch(word)
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
               firstLetter = word.substr(0,1);
               firstLetter = firstLetter.toUpperCase();
               otherLetters = word.substring(1);
               word = firstLetter + otherLetters;
         }
         return word;
      }
      
      private static function getGuideText(guidesName:String) : String
      {
         var msg:String = null;
         var _loc3_:String = guidesName;
         switch(0)
         {
         }
         return "";
      }
      
      private static function onCardDown(evt:MouseEvent) : void
      {
         _popupLayer.addChild(_buddyCardPopup);
         _buddyCardPopup.x = BUDDY_POPUP_X;
         _buddyCardPopup.y = BUDDY_POPUP_Y;
         evt.stopPropagation();
      }
      
      private static function stopListeners(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function addCardListeners() : void
      {
         if(Boolean(_buddyCardMC))
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
            if(!Utility.canJAG() || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
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
         if(Boolean(_buddyCardMC))
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

