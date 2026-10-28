package gui
{
   import achievement.Achievement;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.SortLayer;
   import com.sbi.loader.FileServerEvent;
   import com.sbi.popup.*;
   import createAccountGui.GuiAvatarCreationAssets;
   import den.DenItem;
   import den.DenXtCommManager;
   import ecard.ECardManager;
   import flash.display.*;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.net.SharedObject;
   import flash.utils.Timer;
   import game.MinigameManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import loader.DenItemHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import movie.VideoPlayerOSMF;
   import pet.GuiPet;
   import pet.PetManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TutorialPopups;
   
   public final class GuiManager
   {
      
      public static var mainHud:MovieClip;
      
      public static var chatHist:ChatHistory;
      
      public static var actionMgr:ActionManager;
      
      public static var emoteMgr:EmoticonManager;
      
      public static var volumeMgr:VolumeSelector;
      
      public static var denEditor:DenEditor;
      
      public static var guiLayer:DisplayLayer;
      
      public static var fpsLayer:DisplayLayer;
      
      public static var worldLayer:SortLayer;
      
      public static var chatLayer:DisplayLayer;
      
      public static var bgLayer:DisplayLayer;
      
      public static var toolTip:ToolTipPopup;
      
      public static var toolTipBigGems:ToolTipBigPopup;
      
      public static var toolTipBigTickets:ToolTipBigPopup;
      
      public static var toolTipBigDiamonds:ToolTipBigPopup;
      
      public static var isInFFM:Boolean;
      
      private static var _currRoomDisplayName:String;
      
      private static var _currRoomDisplayNameModeratedLocalized:String;
      
      private static var _currRoomDisplayNameId:int;
      
      private static var _room:String;
      
      private static var _hudAvtView:AvatarView;
      
      private static var _avEditor:AvatarEditor;
      
      private static var _avtSwitcher:AvatarSwitcher;
      
      private static var _denSwitcher:DenSwitcher;
      
      private static var _mySettings:MySettings;
      
      private static var _reportAPlayer:ReportAPlayer;
      
      private static var _achievementViewer:AchievementViewer;
      
      private static var _startupPopups:StartupPopups;
      
      private static var _jammerCentral:BulletinBoard;
      
      private static var _gemBonusWheel:GemBonusSpinWheel;
      
      private static var _dailyGiftManager:DailyGiftManager;
      
      private static var _museumDonation:MuseumDonation;
      
      private static var _playerEngagement:PlayerEngagement;
      
      private static var _photoBooth:PhotoBooth;
      
      private static var _diamondConfirmationPopup:MovieClip;
      
      private static var _diamondShopInfoPopup:MovieClip;
      
      private static var _demotionMessage:DemotionMessages;
      
      private static var _scrollButtons:MovieClip;
      
      private static var _videoPlayer:VideoPlayerOSMF;
      
      private static var _pageFlip:PageFlip;
      
      private static var _imageDisplayPopup:ImageDisplayPopup;
      
      private static var _petInventory:PetInventory;
      
      private static var _joeyPopup:MovieClip;
      
      private static var _secondaryJoeyPopup:MovieClip;
      
      private static var _avatarCreator:GuiAvatarCreationAssets;
      
      private static var _eBookChooser:EBookChooser;
      
      private static var _holidayBanner:MovieClip;
      
      private static var _swap:MovieClip;
      
      private static var _swapPopup:SBPopup;
      
      private static var _awards:MovieClip;
      
      private static var _awardsPopup:SBPopup;
      
      private static var _timer:MovieClip;
      
      private static var _timerPopup:SBPopup;
      
      private static var _report:MovieClip;
      
      private static var _reportPopup:SBPopup;
      
      private static var _rulesPopup:SBPopup;
      
      private static var _differentVersionPopup:SBPopup;
      
      private static var _gemsGlowTimer:Timer;
      
      private static var _denBtnGlowTimer:Timer;
      
      private static var _tooManyGemsPopup:SBPopup;
      
      private static var _commands:Array;
      
      private static var _initialCommands:Array;
      
      private static var _denCommands:Array;
      
      private static var _clothesCommands:Array;
      
      private static var _furnitureCommands:Array;
      
      private static var _eCardCommands:Array;
      
      private static var _availShards:Array;
      
      private static var _avEditorCloseCallback:Function;
      
      private static var _diamondMediaHelper:MediaHelper;
      
      private static var _heartItemWindow:WindowGenerator;
      
      private static var _giftPopup:GiftPopup;
      
      private static var _prizeOkPopup:SBOkPopup;
      
      private static var _prizeData:Object;
      
      private static var _prizeDenItemHelper:DenItemHelper;
      
      private static var _prizeImg:Sprite;
      
      private static var _currentBookId:int;
      
      private static var _isRectangularEBook:Boolean;
      
      private static var _isAJEBook:Boolean;
      
      private static var _needToRebuildMainHud:Boolean;
      
      private static var _currentDenRoomCount:int;
      
      private static var _lionMediaHelper:MediaHelper;
      
      private static var _lionFoundPopup:MovieClip;
      
      private static var _newsOpenedFromBtn:Boolean;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _reconnecting:Boolean;
      
      private static var _hasClosedGemBonus:Boolean;
      
      private static var _namebarBadgeList:Array;
      
      private static var _sharedObj:SharedObject;
      
      private static var _giftGemsMediaHelper:MediaHelper;
      
      private static const DAILY_GIFT_NUM_DAYS:int = 31;
      
      private static const MAX_GEMS:int = 1000;
      
      private static const JB_LIST_ID:int = 53;
      
      private static const NEWSPAPER_LIST_ID_ENG:int = 34;
      
      private static const NEWSPAPER_LIST_ID_FRE:int = 287;
      
      private static const NEWSPAPER_LIST_ID_GER:int = 288;
      
      private static const NEWSPAPER_LIST_ID_SPA:int = 289;
      
      private static const NEWSPAPER_LIST_ID_POR:int = 290;
      
      private static const DIAMOND_SHOP_INFO:int = 2222;
      
      private static const AJ_JUMP_POPUP:int = 2540;
      
      private static const HOLIDAY_BANNER:int = 3871;
      
      private static const HOLIDAY_BANNER_START_TIME:int = 1427846400;
      
      private static const HOLIDAY_BANNER_END_TIME:int = 1427932799;
      
      public static const FFM:int = 0;
      
      public static const WAS_MEMBER_ADDITIONAL_ITEMS:int = 1;
      
      public static const SHOP_TUTORIAL:int = 3;
      
      public static const NAME_BAR_ICONS_LIST_ID:int = 110;
      
      public static var _originalHudFrame:int = -1;
      
      private static var _namebarBadgeDefs:Object = new Object();
      
      public function GuiManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:DisplayLayer, param3:SortLayer, param4:DisplayLayer, param5:DisplayLayer, param6:Function) : void
      {
         _roomMgr = RoomManagerWorld.instance;
         DarkenManager.init(param1);
         SBPopupManager.darken = DarkenManager.darken;
         SBPopupManager.lighten = DarkenManager.unDarken;
         DarkenManager.setFocus = param6;
         guiLayer = param1;
         fpsLayer = param2;
         worldLayer = param3;
         chatLayer = param4;
         bgLayer = param5;
         mainHud = GETDEFINITIONBYNAME("MainHud");
         mainHud.x = 6;
         mainHud.y = 5;
         mainHud.cacheAsBitmap = true;
         mainHud.safeChatTreeWindow.visible = false;
         mainHud.actionsWindow.visible = false;
         mainHud.emotesWindow.visible = false;
         if(mainHud.swapBtn.hasGrayState)
         {
            mainHud.swapBtn.activateGrayState(false);
         }
         mainHud.mainBlock.visible = false;
         mainHud.gemsBtnBlock.visible = false;
         mainHud.charWindowBlock.visible = false;
         _gemsGlowTimer = new Timer(5000);
         _denBtnGlowTimer = new Timer(4000);
         mainHud.gemsBtn.glow.visible = false;
         mainHud.awardsBtn.glow.visible = false;
         mainHud.newsBtn.glow.visible = false;
         mainHud.book.glow.visible = false;
         mainHud.book.gift.visible = false;
         mainHud.partyBtn.glow.visible = false;
         mainHud.playerWallBtn.glow.visible = false;
         mainHud.playerWallBtn.visible = false;
         mainHud.denBtn.glow.visible = false;
         mainHud.denCount.visible = false;
         guiLayer.addChild(mainHud);
         volumeMgr = new VolumeSelector();
         volumeMgr.VolumeSelctor(guiLayer);
         volumeMgr.enable(true,mainHud.worldMapBtn,mainHud.zoneName,mainHud.worldHelp);
         var _loc7_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc7_.init(DefPacksDefHelper.DEF_NAMEBAR_BADGE,namebarBadgeDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_NAMEBAR_BADGE] = _loc7_;
      }
      
      public static function setupAllItems() : void
      {
         chatHist = new ChatHistory(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,UserCommXtCommManager.onSendMessage,mainHud.predictTxtTag,mainHud.specialCharCont,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow);
         SafeChatManager.init(UserCommXtCommManager.sendAvatarSafeChat,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
         emoteMgr = new EmoticonManager(onEmoteClick,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,gMainFrame.userInfo.firstFiveMinutes > 0);
         actionMgr = new ActionManager(UserCommXtCommManager.sendAvatarAction,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
         mainHud.furnBtn.visible = false;
         mainHud.mySettingsBtn.glow.visible = false;
         if(mainHud.mySettingsBtn.hasGrayState)
         {
            mainHud.mySettingsBtn.activateGrayState(false);
         }
         if(mainHud.reportBtn.hasGrayState)
         {
            mainHud.reportBtn.activateGrayState(false);
         }
         addListeners();
         UpsellManager.init(guiLayer,PetManager.getPetInventoryMax);
         _availShards = [];
         setToolTipText();
         toolTip = GETDEFINITIONBYNAME("Tooltip");
         toolTipBigGems = GETDEFINITIONBYNAME("TooltipBig");
         toolTipBigTickets = GETDEFINITIONBYNAME("TooltipBig");
         toolTipBigDiamonds = GETDEFINITIONBYNAME("TooltipBig");
         _achievementViewer = new AchievementViewer();
         _achievementViewer.loadMedia(287);
         setupSoundButton();
      }
      
      public static function reAddEmotes() : void
      {
         if(emoteMgr)
         {
            emoteMgr.reAddAllEmotes();
         }
      }
      
      public static function setupSharedObject() : void
      {
         _sharedObj = null;
         if(gMainFrame.myFlashVarUserName != null)
         {
            try
            {
               _sharedObj = SharedObject.getLocal(gMainFrame.myFlashVarUserName);
               if(_sharedObj.data.cursor == null || _sharedObj.data.cursor == "custom")
               {
                  CursorManager.switchToCursor(CursorManager.CUSTOM_CURSOR);
               }
            }
            catch(e:Error)
            {
               CursorManager.switchToCursor(CursorManager.CUSTOM_CURSOR);
               _sharedObj = null;
            }
         }
         AJAudio.setupSharedObject(_sharedObj);
      }
      
      public static function setupSoundButton() : void
      {
         if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
         {
            depressSoundButton(true);
         }
      }
      
      public static function setSharedObj(param1:String, param2:*) : void
      {
         if(_sharedObj != null)
         {
            switch(param1)
            {
               case "cursor":
                  if(_sharedObj.data.cursor != param2)
                  {
                     _sharedObj.data.cursor = param2;
                  }
                  break;
               case "msgColor":
                  if(_sharedObj.data.msgColor != param2)
                  {
                     _sharedObj.data.msgColor = param2;
                  }
                  break;
               case "msgPattern":
                  if(_sharedObj.data.msgPattern != param2)
                  {
                     _sharedObj.data.msgPattern = param2;
                  }
                  break;
               case "expiration":
                  if(_sharedObj.data.expiration != param2)
                  {
                     _sharedObj.data.expiration = param2;
                  }
                  break;
               case "decorId":
                  if(_sharedObj.data.decorId != param2)
                  {
                     _sharedObj.data.decorId = param2;
                  }
                  break;
               case "reportedPosts":
                  _sharedObj.data.reportedPosts = param2;
            }
            try
            {
               _sharedObj.flush();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public static function get avatarEditor() : AvatarEditor
      {
         return _avEditor;
      }
      
      public static function get sharedObj() : SharedObject
      {
         return _sharedObj;
      }
      
      public static function startFFM(param1:Boolean = false) : void
      {
         if(gMainFrame.server.getCurrentRoom())
         {
            ffmAssetsLoadedCallback();
         }
         else
         {
            RoomXtCommManager.sendRoomFFMRequest(rfCallback);
         }
      }
      
      private static function rfCallback() : void
      {
         _roomMgr.callback_FFMRoomAssetsLoaded = ffmAssetsLoadedCallback;
         var _loc1_:String = "ffm" + gMainFrame.userInfo.myUserName;
         RoomXtCommManager.sendNonDenRoomJoinRequest(_loc1_);
      }
      
      private static function ffmAssetsLoadedCallback() : void
      {
         LoadProgress.show(true);
         QuestXtCommManager.sendQuestCreateJoinPublic(39);
         isInFFM = true;
      }
      
      public static function destroy() : void
      {
         removeListeners();
         chatHist.destroy();
         chatHist = null;
         SafeChatManager.destroy();
         emoteMgr.destroy();
         emoteMgr = null;
         actionMgr.destroy();
         actionMgr = null;
         volumeMgr.destroy();
         volumeMgr = null;
         DarkenManager.destroy();
         ItemXtCommManager.setHudAvtItemListLayerAnim(null);
         _reconnecting = false;
      }
      
      private static function setToolTipText() : void
      {
         if(mainHud.buddyListBtn)
         {
            mainHud.buddyListBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14656),mainHud.x,40);
         }
         if(mainHud.eCardBtn)
         {
            mainHud.eCardBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14657),mainHud.x,40);
         }
         if(mainHud.newsBtn)
         {
            mainHud.newsBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14658),mainHud.x,40);
         }
         if(mainHud.mySettingsBtn)
         {
            mainHud.mySettingsBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14659),mainHud.x,45);
         }
         if(mainHud.reportBtn)
         {
            mainHud.reportBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14660),mainHud.x,45);
         }
         if(mainHud.charWindow)
         {
            mainHud.charWindow.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14673),mainHud.x,mainHud.currentFrameLabel == "quest" ? -40 : -55);
         }
         if(mainHud.swapBtn)
         {
            mainHud.swapBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14661),mainHud.x,-35);
         }
         if(mainHud.actionsBtn)
         {
            mainHud.actionsBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14662),mainHud.x,-30);
         }
         if(mainHud.emotesBtn)
         {
            mainHud.emotesBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14663),mainHud.x,-30);
         }
         if(mainHud.sendChatBtn)
         {
            if(mainHud.currentFrameLabel == "quest")
            {
               mainHud.sendChatBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14648),528 + mainHud.x,497);
            }
            else
            {
               mainHud.sendChatBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14648),521 + mainHud.x,505);
            }
         }
         if(mainHud.safeChatBtn)
         {
            mainHud.safeChatBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14664),mainHud.x,-30);
         }
         if(mainHud.denBtn)
         {
            mainHud.denBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14665),mainHud.x,-35);
         }
         if(mainHud.soundBtn)
         {
            mainHud.soundBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14666),mainHud.x,-25);
         }
         if(mainHud.worldMapBtn)
         {
            mainHud.worldMapBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14667),mainHud.x,-50);
         }
         if(mainHud.awardsBtn)
         {
            mainHud.awardsBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(11239),mainHud.x,40);
         }
         if(mainHud.book)
         {
            mainHud.book.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14668),mainHud.x,40);
         }
         if(mainHud.partyBtn)
         {
            mainHud.partyBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14669),mainHud.x,40);
         }
         if(mainHud.questPlayersBtn)
         {
            mainHud.questPlayersBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14670),mainHud.x,-30);
         }
         if(mainHud.questingExit_btnQuest)
         {
            mainHud.questingExit_btnQuest.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14671),mainHud.x,-35);
         }
         if(mainHud.miniMap_btnQuest)
         {
            mainHud.miniMap_btnQuest.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14672),mainHud.x,-35);
         }
         if(mainHud.chatRepeatBtn)
         {
            mainHud.chatRepeatBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(18215),mainHud.x,-24);
         }
      }
      
      private static function blockMouseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      public static function setSwapBtnGray(param1:Boolean) : void
      {
         if(Boolean(mainHud.swapBtn) && mainHud.swapBtn.isGray != param1)
         {
            mainHud.swapBtn.activateGrayState(param1);
         }
      }
      
      public static function isModal() : Boolean
      {
         return volumeMgr.visible;
      }
      
      public static function setupGemGiftPopup(param1:int) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _giftGemsMediaHelper = new MediaHelper();
         _giftGemsMediaHelper.init(StartupPopups.GEMS_MEDIA_ID,onGemIconLoaded,param1);
      }
      
      private static function onGemIconLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(guiLayer,param1,LocalizationManager.translateIdAndInsertOnly(LocalizationManager.GEMS_CAPITALIZED,param1.passback),param1.passback,GiftPopup.POPUP_TYPE_PRIZE,GiftPopup.GIFT_TYPE_GEMS,null,keepGemGiftCallback,null,false,GiftPopup.BUTTONS_TYPE_OK);
         }
         _giftGemsMediaHelper.destroy();
         _giftGemsMediaHelper = null;
      }
      
      private static function keepGemGiftCallback() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         if(denEditor)
         {
            denEditor.onDenTutorialGiftClose();
         }
      }
      
      public static function onItemPrize(param1:Object) : void
      {
         _prizeData = {
            "userVarId":int(param1[2]),
            "isClothing":param1[3] == "1",
            "itemDefId":int(param1[4]),
            "itemName":LocalizationManager.translateIdOnly(int(param1[5])),
            "desc":LocalizationManager.translateIdOnly(int(param1[6])),
            "color":uint(param1[7])
         };
      }
      
      public static function showPrizePopupIfAny() : Boolean
      {
         var _loc1_:Object = null;
         if(_prizeData)
         {
            _loc1_ = DenXtCommManager.getDenItemDef(_prizeData.itemDefId);
            if(!_loc1_)
            {
               return false;
            }
            _prizeDenItemHelper = new DenItemHelper();
            _prizeDenItemHelper.init(uint(_prizeData.itemDefId << 16 | DenItem.getIconId(_loc1_.sortCat)),onPrizeIconReceived,_prizeData.color);
            return true;
         }
         return false;
      }
      
      private static function onPrizeIconReceived(param1:DenItemHelper) : void
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
            _prizeImg = _loc2_;
            _prizeOkPopup = new SBOkPopup(guiLayer,_prizeData.desc,true,onPrizeDescOkDown);
         }
      }
      
      private static function onPrizeDescOkDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _prizeOkPopup.destroy();
         _giftPopup = new GiftPopup();
         _giftPopup.init(guiLayer,_prizeImg,_prizeData.itemName,_prizeData.itemDefId,GiftPopup.POPUP_TYPE_PRIZE,GiftPopup.GIFT_TYPE_DEN_ACC,onKeepPrizeDown,onDiscardPrizeDown,destroyPrizePopup);
      }
      
      private static function onKeepPrizeDown() : void
      {
         AchievementXtCommManager.requestSetUserVar(_prizeData.userVarId,3 | _prizeData.color << 4);
         destroyPrizePopup();
      }
      
      private static function onDiscardPrizeDown() : void
      {
         AchievementXtCommManager.requestSetUserVar(_prizeData.userVarId,2 | _prizeData.color << 4);
         destroyPrizePopup();
      }
      
      private static function destroyPrizePopup() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         _prizeData = null;
         if(_prizeDenItemHelper)
         {
            _prizeDenItemHelper.destroy();
            _prizeDenItemHelper = null;
         }
         _prizeImg = null;
         guiStartupChecks();
      }
      
      public static function guiStartupChecks() : void
      {
         var _loc1_:Number = NaN;
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(!showPrizePopupIfAny())
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP_STARTUP) != gMainFrame.clientInfo.newspaperTimestamp)
               {
                  GuiManager.onNewsPaperBtn(null);
                  AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP_STARTUP,gMainFrame.clientInfo.newspaperTimestamp);
               }
               else
               {
                  if(!_hasClosedGemBonus)
                  {
                     _loc1_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_DAILY_GEM_BONUS));
                     if(_loc1_ == -1 || (_loc1_ & 0xFFFF) < gMainFrame.clientInfo.jamaaDate)
                     {
                        DarkenManager.showLoadingSpiral(true);
                        if(gMainFrame.clientInfo.dailyGiftIndex >= 0 && gMainFrame.clientInfo.dailyGiftIndex < DAILY_GIFT_NUM_DAYS)
                        {
                           openDailyGift(gMainFrame.clientInfo.dailyGiftIndex);
                        }
                        else
                        {
                           openGemBonusWheel(_loc1_);
                        }
                        return;
                     }
                  }
                  if(gMainFrame.userInfo.userVarCache.getUserVarValueById(Achievement.HOLIDAY_BANNER) != HOLIDAY_BANNER_START_TIME && (Utility.currTimeOffsetToMatchUTC() >= HOLIDAY_BANNER_START_TIME && Utility.currTimeOffsetToMatchUTC() <= HOLIDAY_BANNER_END_TIME))
                  {
                     openHolidayBanner();
                  }
               }
            }
         }
      }
      
      public static function openGiftPopup(param1:Sprite, param2:String, param3:int, param4:int, param5:Function, param6:Function, param7:Function, param8:int, param9:String, param10:int, param11:String, param12:Boolean) : void
      {
         _giftPopup = new GiftPopup();
         _giftPopup.init(guiLayer,param1,param2,param3,param10,GiftPopup.giftTypeForECardType(param4),param5,param6,param7,false,param8,SbiConstants.ENVIRO_LAND,param9,param11,null,param12);
      }
      
      public static function closePromoPopup() : Boolean
      {
         if(_giftPopup)
         {
            _giftPopup.close();
            return true;
         }
         return false;
      }
      
      public static function destroyPromotionalPopup() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
      }
      
      public static function initMessagePopups(param1:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _startupPopups = new StartupPopups();
         _startupPopups.init(guiLayer,param1);
      }
      
      public static function initDemotionMessage(param1:Function) : void
      {
         _demotionMessage = new DemotionMessages();
         _demotionMessage.init(param1);
      }
      
      public static function initPlayerEngagement(param1:Function) : void
      {
         _playerEngagement = new PlayerEngagement();
         _playerEngagement.init(param1);
      }
      
      public static function set reconnecting(param1:Boolean) : void
      {
         _reconnecting = param1;
      }
      
      public static function get reconnecting() : Boolean
      {
         return _reconnecting;
      }
      
      public static function initMoviePlayer(param1:int, param2:Array, param3:Array, param4:Array, param5:Boolean = true, param6:int = 512, param7:int = 288) : void
      {
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
         }
         _videoPlayer = new VideoPlayerOSMF();
         _videoPlayer.init(param2,param4,param3,param1,-1,param5,param6,param7);
      }
      
      public static function setVideoPlayerSkin(param1:int) : void
      {
         if(_videoPlayer)
         {
            _videoPlayer.setSkinFrame(param1);
         }
      }
      
      private static function gemsGlowTimerHandler(param1:TimerEvent) : void
      {
         _gemsGlowTimer.stop();
         if(mainHud.gemsBtn)
         {
            mainHud.gemsBtn.glow.visible = false;
         }
      }
      
      public static function startGemsFlash() : void
      {
         _gemsGlowTimer.start();
         AJAudio.playGemsEarnedSound();
         if(Boolean(mainHud.gemsBtn) && !mainHud.gemsBtn.isGray)
         {
            mainHud.gemsBtn.glow.visible = true;
         }
      }
      
      public static function startDenBtnGlow() : void
      {
         if(mainHud.denBtn)
         {
            _denBtnGlowTimer.start();
            mainHud.denBtn.glow.visible = true;
         }
      }
      
      public static function denBtnGlowTimerHandler(param1:TimerEvent) : void
      {
         _denBtnGlowTimer.reset();
         if(mainHud.denBtn)
         {
            mainHud.denBtn.glow.visible = false;
         }
      }
      
      public static function onNewsPaperBtn(param1:MouseEvent) : void
      {
         _newsOpenedFromBtn = param1 != null;
         if(_newsOpenedFromBtn)
         {
            param1.stopPropagation();
         }
         if(!mainHud.newsBtn.isGray)
         {
            if(_pageFlip)
            {
               _pageFlip.destroy();
            }
            if(Boolean(mainHud.newsBtn.glow.visible) && Boolean(param1))
            {
               mainHud.newsBtn.glow.visible = false;
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP,gMainFrame.clientInfo.newspaperTimestamp);
            }
            DarkenManager.showLoadingSpiral(true);
            GenericListXtCommManager.requestGenericList(getNewsPaperList(),onNewsPaperMediaListReceived);
         }
      }
      
      private static function getNewsPaperList() : int
      {
         if(LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
         {
            switch(LocalizationManager.currentLanguage)
            {
               case LocalizationManager.LANG_DE:
                  return NEWSPAPER_LIST_ID_GER;
               case LocalizationManager.LANG_FRE:
                  return NEWSPAPER_LIST_ID_FRE;
               case LocalizationManager.LANG_POR:
                  return NEWSPAPER_LIST_ID_POR;
               case LocalizationManager.LANG_SPA:
                  return NEWSPAPER_LIST_ID_SPA;
            }
         }
         return NEWSPAPER_LIST_ID_ENG;
      }
      
      private static function onNewsPaperMediaListReceived(param1:int, param2:Array, param3:Array) : void
      {
         if(param2.length != 0)
         {
            SBTracker.push();
            _pageFlip = new PageFlip();
            _pageFlip.init(guiLayer,param2,true,onPageFlipCloseNP,onFlipNP);
         }
         else
         {
            GenericListXtCommManager.requestGenericList(NEWSPAPER_LIST_ID_ENG,onNewsPaperMediaListReceived);
         }
      }
      
      public static function onJourneyBookBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(mainHud.book.glow.visible)
            {
               mainHud.book.glow.visible = false;
            }
            openJourneyBook();
         }
      }
      
      public static function openJourneyBook(param1:Boolean = false) : void
      {
         if(_pageFlip)
         {
            _pageFlip.destroy();
         }
         DarkenManager.showLoadingSpiral(true);
         if(param1)
         {
            GenericListXtCommManager.requestGenericList(JB_LIST_ID,onJourneyBookMediaListReceivedWithInfo);
         }
         else
         {
            GenericListXtCommManager.requestGenericList(JB_LIST_ID,onJourneyBookMediaListReceived);
         }
      }
      
      private static function onJourneyBookMediaListReceived(param1:int, param2:Array, param3:Array, param4:Boolean = false) : void
      {
         SBTracker.push();
         var _loc5_:int = 1;
         var _loc6_:int = 0;
         while(_loc6_ < param3.length)
         {
            if(LocalizationManager.translateIdOnly(param3[_loc6_]).toLowerCase() == _currRoomDisplayNameModeratedLocalized.toLowerCase())
            {
               _loc5_ = _loc6_ + 1;
               break;
            }
            _loc6_++;
         }
         _pageFlip = new PageFlip();
         _pageFlip.init(guiLayer,param2,true,onEBookClose,onJourneyBookFlipNP,false,false,false,true,_loc5_,param4);
      }
      
      private static function onJourneyBookMediaListReceivedWithInfo(param1:int, param2:Array, param3:Array) : void
      {
         onJourneyBookMediaListReceived(param1,param2,param3,true);
      }
      
      public static function showJBGlow(param1:Boolean) : void
      {
         if(mainHud.book != null && !mainHud.book.isGray)
         {
            mainHud.book.glow.visible = param1;
         }
      }
      
      public static function updateJBIcon() : void
      {
         if(JBManager.numUnclaimedGifts > 0)
         {
            mainHud.book.gift.visible = true;
            mainHud.book.gift.giftCountTxt.text = JBManager.numUnclaimedGifts;
         }
         else
         {
            mainHud.book.gift.visible = false;
            mainHud.book.gift.giftCountTxt.text = "";
         }
      }
      
      public static function openEBookChooser(param1:String) : void
      {
         if(_eBookChooser)
         {
            _eBookChooser.destroy();
         }
         _eBookChooser = new EBookChooser();
         _eBookChooser.init(param1,onEBookChooserClose);
      }
      
      private static function onEBookChooserClose() : void
      {
         if(_eBookChooser)
         {
            _eBookChooser.destroy();
            _eBookChooser = null;
         }
      }
      
      public static function openEBook(param1:int, param2:Boolean, param3:Boolean) : void
      {
         if(_pageFlip)
         {
            _pageFlip.destroy();
         }
         _isRectangularEBook = param2;
         _isAJEBook = param3;
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestGenericList(param1,onMediaListReceived);
      }
      
      private static function onMediaListReceived(param1:int, param2:Array, param3:Array) : void
      {
         _currentBookId = param1;
         SBTracker.push();
         _pageFlip = new PageFlip();
         _pageFlip.init(guiLayer,param2,false,onEBookClose,onEBookFlipNP,_isRectangularEBook,_isAJEBook);
         DarkenManager.showLoadingSpiral(false);
      }
      
      public static function onMyUserVarsReceived() : void
      {
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP) != gMainFrame.clientInfo.newspaperTimestamp)
         {
            mainHud.newsBtn.glow.visible = true;
         }
      }
      
      private static function onJourneyBookFlipNP(param1:String) : void
      {
         SBTracker.trackPageview("/game/play/popup/jb/#" + param1);
      }
      
      private static function onFlipNP(param1:int) : void
      {
         SBTracker.trackPageview("/game/play/popup/newspaper/#page" + param1);
      }
      
      private static function onEBookFlipNP(param1:int) : void
      {
         SBTracker.trackPageview("/game/play/popup/#book_" + _currentBookId + "/page" + param1);
      }
      
      public static function openJumpPopup(param1:Boolean, param2:Function, param3:MovieClip, param4:int) : void
      {
         SBTracker.trackPageview("/game/play/popup/ajJump" + (param1 ? "/joey" : "/gems"),-1,SBTracker.TYPE_EVENT);
         if(_joeyPopup)
         {
            if(!_joeyPopup.isJoey && !param1)
            {
               LocalizationManager.translateIdAndInsert(_joeyPopup.contentTxt,LocalizationManager.GEMS_CAPITALIZED,Utility.convertNumberToString(_joeyPopup.currGiftId + param4));
               _joeyPopup.currGiftId += param4;
               return;
            }
            if(Boolean(_joeyPopup.isJoey) && param1)
            {
               return;
            }
            DarkenManager.unDarken(_joeyPopup);
            guiLayer.removeChild(_joeyPopup);
            _secondaryJoeyPopup = _joeyPopup;
         }
         var _loc5_:MediaHelper = new MediaHelper();
         _loc5_.init(AJ_JUMP_POPUP,onJumpPopupLoaded,{
            "isJoey":param1,
            "callback":param2,
            "gemsImage":param3,
            "currGiftId":param4
         });
      }
      
      private static function onJumpPopupLoaded(param1:MovieClip) : void
      {
         var _loc2_:MediaHelper = null;
         if(param1)
         {
            _joeyPopup = MovieClip(param1.getChildAt(0));
            _joeyPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _joeyPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            _joeyPopup.callback = param1.passback.callback;
            _joeyPopup.isJoey = param1.passback.isJoey;
            _joeyPopup.currGiftId = param1.passback.currGiftId;
            _joeyPopup.image = param1.passback.gemsImage;
            _joeyPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            _joeyPopup.xBtn.addEventListener(MouseEvent.MOUSE_DOWN,jumpCloseHandler,false,0,true);
            _loc2_ = new MediaHelper();
            if(param1.passback.isJoey)
            {
               _loc2_.init(StartupPopups.JOEY_MEDIA_ID,onJumpImageLoaded,_joeyPopup);
               LocalizationManager.translateId(_joeyPopup.contentTxt,11137);
            }
            else
            {
               if(_joeyPopup.image)
               {
                  _joeyPopup.itemWindow.addChild(_joeyPopup.image);
               }
               else
               {
                  _loc2_.init(StartupPopups.GEMS_MEDIA_ID,onJumpImageLoaded,_joeyPopup);
               }
               LocalizationManager.translateIdAndInsert(_joeyPopup.contentTxt,LocalizationManager.GEMS_CAPITALIZED,_joeyPopup.currGiftId);
            }
            guiLayer.addChild(_joeyPopup);
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_joeyPopup);
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            delete param1.passback;
         }
      }
      
      private static function onJumpImageLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            param1.passback.itemWindow.addChild(param1);
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            delete param1.passback;
         }
      }
      
      private static function jumpCloseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _joeyPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
         _joeyPopup.xBtn.removeEventListener(MouseEvent.MOUSE_DOWN,jumpCloseHandler);
         DarkenManager.unDarken(_joeyPopup);
         guiLayer.removeChild(_joeyPopup);
         var _loc2_:MovieClip = _joeyPopup;
         _joeyPopup = null;
         if(_secondaryJoeyPopup)
         {
            _joeyPopup = _secondaryJoeyPopup;
            guiLayer.addChild(_joeyPopup);
            DarkenManager.darken(_joeyPopup);
            _secondaryJoeyPopup = null;
         }
         if(_loc2_.callback)
         {
            _loc2_.callback(_loc2_.isJoey,_loc2_.currGiftId,_loc2_.image);
         }
         _loc2_ = null;
      }
      
      public static function onSwapBtnClickHandler(param1:MouseEvent) : void
      {
         if(Boolean(mainHud.swapBtn) && Boolean(mainHud.swapBtn.isGray) || RoomXtCommManager.isSwitching)
         {
            return;
         }
         param1.stopPropagation();
         _roomMgr.forceStopMovement();
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/avatarSwitch");
         _avtSwitcher = new AvatarSwitcher();
         _avtSwitcher.init(guiLayer,onAvtSwitchClose,false,false);
      }
      
      private static function onPetSwapBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(GuiManager.isBeYourPetRoom())
         {
            if(_petInventory)
            {
               _petInventory.destroy();
            }
            _petInventory = new PetInventory();
            _petInventory.init(onPetInventoryClose);
         }
      }
      
      private static function onPetInventoryClose() : void
      {
         _petInventory = null;
         showHudAvt();
         var _loc1_:AvatarWorldView = AvatarManager.playerAvatarWorldView;
         if(_loc1_)
         {
            _loc1_.setPos(_loc1_.x,_loc1_.y,false);
            _loc1_.updateChatBallonBgOffsets();
            if(!_loc1_.isActivePetGroundPet())
            {
               actionMgr.grayOutPetDanceBtn(true);
            }
            else
            {
               actionMgr.grayOutPetDanceBtn(false);
            }
            _roomMgr.rebuildGrid();
            if(RoomManagerWorld.instance.collisionTestGrid(_loc1_.x,_loc1_.y))
            {
               _roomMgr.teleportPlayerToDefault();
            }
         }
      }
      
      public static function switchToOceanAnimal(param1:Object) : void
      {
         if(param1.status)
         {
            if(Boolean(mainHud.swapBtn) && Boolean(mainHud.swapBtn.isGray) || RoomXtCommManager.isSwitching)
            {
               return;
            }
            if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(switchToOceanAnimal,param1);
               return;
            }
            _roomMgr.forceStopMovement();
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/noOceanAnimal");
            _avtSwitcher = new AvatarSwitcher();
            _avtSwitcher.init(guiLayer,onAvtSwitchClose,false,true,param1.passback.switchRooms,param1.passback.switchDens);
         }
      }
      
      public static function openAvatarChoose() : void
      {
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
         }
         _avtSwitcher = new AvatarSwitcher();
         _avtSwitcher.init(guiLayer,chooseAvatarCloseCallback,true,false);
      }
      
      public static function openDenRoomSwitcher(param1:Boolean = false, param2:Function = null, param3:Boolean = false, param4:int = -1, param5:int = -1, param6:int = -1) : void
      {
         if(_denSwitcher)
         {
            _denSwitcher.destroy();
         }
         if(!param1)
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/denSwitch");
         }
         if(param2 == null)
         {
            param2 = onDenSwitchClose;
         }
         _denSwitcher = new DenSwitcher();
         _denSwitcher.init(AvatarManager.playerAvatar,guiLayer,param1,param3,param2,param4,param5,param6,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      public static function get denSwitcherCurrentIndex() : int
      {
         if(_denSwitcher)
         {
            return _denSwitcher.idx;
         }
         return -1;
      }
      
      public static function showDenSwitcher(param1:Boolean) : void
      {
         if(_denSwitcher)
         {
            _denSwitcher.showDenSwitcher(param1);
         }
      }
      
      public static function updateDenRoomCount(param1:int, param2:Boolean, param3:String) : void
      {
         if(param3 == gMainFrame.userInfo.myUserName)
         {
            if(param2)
            {
               param1--;
            }
         }
         else if(denEditor != null)
         {
            param1--;
         }
         if(mainHud.denCount)
         {
            if(param1 > 0)
            {
               if(_currentDenRoomCount < param1)
               {
                  GuiManager.startDenBtnGlow();
                  if(!Utility.isSettingOn(MySettings.SETTINGS_DOOR_BELL))
                  {
                     AJAudio.playDoorBellSound();
                  }
               }
               mainHud.denCount.denCountTxt.text = param1;
               mainHud.denCount.visible = true;
            }
            else
            {
               mainHud.denCount.visible = false;
            }
         }
         _currentDenRoomCount = param1;
      }
      
      private static function chooseAvatarCloseCallback() : void
      {
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
            _avtSwitcher = null;
         }
         _demotionMessage.hasChosen = true;
         _demotionMessage.goToNextPage();
      }
      
      private static function onSoundBtnClickHandler(param1:MouseEvent) : void
      {
         SBAudio.toggleMuteAll();
         toggleMuteVideo();
         if(_mySettings)
         {
            _mySettings.updateSoundBtn();
         }
         TutorialPopups.handleSoundBtnClick();
      }
      
      public static function updateSettingsMessage() : void
      {
         if(_mySettings)
         {
            _mySettings.updateWorldMessage();
         }
      }
      
      public static function toggleMuteVideo() : void
      {
         if(Boolean(_roomMgr.theaterWindow) && Boolean(GenericListGuiManager.movieSelector) && Boolean(GenericListGuiManager.movieSelector.videoPlayer))
         {
            GenericListGuiManager.movieSelector.videoPlayer.toggleSound();
         }
      }
      
      public static function depressSoundButton(param1:Boolean) : void
      {
         if(param1)
         {
            mainHud.soundBtn.upToDownState();
         }
         else
         {
            mainHud.soundBtn.downToUpState();
         }
      }
      
      private static function onAwardsBtnClickHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(BuddyList.visible)
            {
               BuddyList.closeBuddyList();
            }
            if(PartyManager.visible)
            {
               PartyManager.close();
            }
            if(Boolean(_achievementViewer) && _achievementViewer.hasBeenInited)
            {
               if(_achievementViewer.visible)
               {
                  _achievementViewer.close();
               }
               else
               {
                  _achievementViewer.open();
               }
            }
            else
            {
               if(_achievementViewer == null)
               {
                  _achievementViewer = new AchievementViewer();
               }
               _achievementViewer.init(mainHud.awardsBtn.x + 15,mainHud.awardsBtn.y + mainHud.awardsBtn.height * 0.5 - 5,287);
            }
         }
      }
      
      public static function onPartyBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!mainHud.partyBtn.isGray)
         {
            if(!param1)
            {
               mainHud.partyBtn.upToDownState();
            }
            if(BuddyList.visible)
            {
               BuddyList.closeBuddyList();
            }
            if(_achievementViewer.visible)
            {
               _achievementViewer.close();
            }
            if(mainHud.partyBtn.glow.visible)
            {
               mainHud.partyBtn.glow.visible = false;
            }
            if(PartyManager.visible)
            {
               PartyManager.close();
            }
            else
            {
               PartyManager.open();
            }
         }
      }
      
      public static function showPartyBtnGlow(param1:Boolean) : void
      {
         if(Boolean(mainHud.partyBtn) && !mainHud.partyBtn.isGray)
         {
            if(gMainFrame.userInfo.firstFiveMinutes > 0)
            {
               mainHud.partyBtn.glow.visible = param1;
            }
         }
      }
      
      private static function onGemsBtnRollOverHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            toolTipBigGems.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.gemCount),param1.currentTarget.x + mainHud.x + param1.currentTarget.mouse.width + 65,param1.currentTarget.y + 5,false);
            if(gMainFrame.clientInfo.ticketCount > 0)
            {
               param1.currentTarget.mouse.itemHitArea.visible = true;
               param1.currentTarget.mouse.tickets.visible = true;
               param1.currentTarget.mouse.itemHitArea.height = 50;
               toolTipBigTickets.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.ticketCount),param1.currentTarget.x + mainHud.x + param1.currentTarget.mouse.width + 65,param1.currentTarget.y + 48,false);
               toolTipBigTickets.startTimer(param1);
            }
            else
            {
               param1.currentTarget.mouse.itemHitArea.visible = false;
               param1.currentTarget.mouse.tickets.visible = false;
            }
            param1.currentTarget.mouse.orb.visible = false;
            param1.currentTarget.mouse.orbTicketSpot.visible = false;
            if(gMainFrame.clientInfo.diamondCount > 0)
            {
               param1.currentTarget.mouse.itemHitArea.visible = true;
               if(gMainFrame.clientInfo.ticketCount > 0)
               {
                  param1.currentTarget.mouse.diamondTicketSpot.visible = false;
                  param1.currentTarget.mouse.itemHitArea.height = 100;
                  param1.currentTarget.mouse.diamondOrbSpot.visible = true;
                  param1.currentTarget.mouse.diamond.visible = false;
                  toolTipBigDiamonds.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.diamondCount),param1.currentTarget.x + mainHud.x + param1.currentTarget.mouse.width + 65,param1.currentTarget.y + 100,false);
               }
               else
               {
                  param1.currentTarget.mouse.itemHitArea.height = 50;
                  param1.currentTarget.mouse.diamondTicketSpot.visible = true;
                  param1.currentTarget.mouse.diamondOrbSpot.visible = false;
                  param1.currentTarget.mouse.diamond.visible = false;
                  toolTipBigDiamonds.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.diamondCount),param1.currentTarget.x + mainHud.x + param1.currentTarget.mouse.width + 65,param1.currentTarget.y + 49,false);
               }
               toolTipBigDiamonds.startTimer(param1);
            }
            else
            {
               param1.currentTarget.mouse.diamondTicketSpot.visible = false;
               param1.currentTarget.mouse.diamondOrbSpot.visible = false;
               param1.currentTarget.mouse.diamond.visible = false;
            }
            if(PartyManager.visible)
            {
               PartyManager.bringToFront();
            }
            toolTipBigGems.startTimer(param1);
         }
      }
      
      private static function onGemsBtnRollOutHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.mouse.itemHitArea.visible = false;
         toolTipBigGems.visible = false;
         toolTipBigTickets.visible = false;
         toolTipBigDiamonds.visible = false;
      }
      
      private static function onMySettingsBtnClickHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(_mySettings != null)
            {
               _mySettings.destroy();
               _mySettings = null;
            }
            else
            {
               if(_reportAPlayer)
               {
                  _reportAPlayer.destroy();
                  _reportAPlayer = null;
                  mainHud.reportBtn.downToUpState();
               }
               _mySettings = new MySettings();
               _mySettings.init(guiLayer,740,240,onMySettingsClose);
            }
         }
      }
      
      private static function onReportBtnClickHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(_reportAPlayer)
            {
               _reportAPlayer.destroy();
               _reportAPlayer = null;
            }
            else
            {
               if(_mySettings)
               {
                  _mySettings.destroy();
                  _mySettings = null;
                  mainHud.mySettingsBtn.downToUpState();
               }
               _reportAPlayer = new ReportAPlayer();
               _reportAPlayer.init(guiLayer,onReportAPlayerClose,false,null,null,true,756,130);
            }
         }
      }
      
      public static function displayRulesPopup(param1:Boolean, param2:Function = null) : void
      {
         if(param1)
         {
            if(_rulesPopup)
            {
               _rulesPopup.destroy();
               _rulesPopup = null;
            }
            _rulesPopup = new SBPopup(guiLayer,GETDEFINITIONBYNAME("ReportRulesPopupSkin"),GETDEFINITIONBYNAME("ReportRulesPopupContent"),true,true,false,false,true);
            _rulesPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _rulesPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            if(param2 != null)
            {
               _rulesPopup.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,param2,false,0,true);
            }
         }
         else if(_rulesPopup)
         {
            _rulesPopup.destroy();
            _rulesPopup = null;
         }
      }
      
      public static function openJammerCentral() : void
      {
         if(_jammerCentral)
         {
            _jammerCentral.destroy();
            _jammerCentral = null;
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral");
         _jammerCentral = new BulletinBoard();
         _jammerCentral.init(guiLayer,onJammerCentralClose);
      }
      
      public static function refreshJammerCentral() : void
      {
         if(_jammerCentral)
         {
            _jammerCentral.refresh();
         }
      }
      
      private static function onJammerCentralClose() : void
      {
         SBTracker.flush(true);
         _jammerCentral.destroy();
         _jammerCentral = null;
      }
      
      public static function openLionFound() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _lionMediaHelper = new MediaHelper();
         _lionMediaHelper.init(1176,onLionMediaLoaded,true);
      }
      
      private static function onLionMediaLoaded(param1:MovieClip) : void
      {
         var _loc2_:Avatar = null;
         var _loc3_:Array = null;
         var _loc4_:Item = null;
         var _loc5_:AvatarView = null;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _lionFoundPopup = MovieClip(param1.getChildAt(0));
            _lionFoundPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _lionFoundPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            guiLayer.addChild(_lionFoundPopup);
            DarkenManager.darken(_lionFoundPopup);
            _lionFoundPopup.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
            _lionFoundPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,closeLionPopup,false,0,true);
            _lionFoundPopup.oopsPopup.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
            _lionFoundPopup.oopsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,closeLionOopsPopup,false,0,true);
            _lionFoundPopup.donateBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLionDonateBtn,false,0,true);
            _loc2_ = new Avatar();
            _loc2_.init(-1,"Lion King",17,[388317183,117440512,83836927],-1,null,"Lion King");
            _loc3_ = [];
            _loc4_ = new Item();
            _loc3_[0] = _loc4_;
            _loc4_.init(1,1,0,-1,-1);
            _loc4_ = new Item();
            _loc3_[1] = _loc4_;
            _loc4_.init(4,2,0,-1,-1);
            _loc2_.itemResponseIntegrate(_loc3_);
            _loc5_ = new AvatarView();
            _loc5_.init(_loc2_,null);
            _loc5_.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
            _loc5_.x = 140;
            _loc5_.y = 60;
            _lionFoundPopup.amlBG.amlMask.amlBox.addChild(_loc5_);
            _lionFoundPopup.oopsPopup.visible = false;
         }
      }
      
      private static function closeLionPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_lionFoundPopup);
         guiLayer.removeChild(_lionFoundPopup);
         _lionFoundPopup = null;
      }
      
      private static function closeLionOopsPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _lionFoundPopup.oopsPopup.visible = false;
      }
      
      private static function onLionDonateBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onLionCurrencyCheck(param1:Boolean) : void
      {
         if(!param1)
         {
            if(_lionFoundPopup)
            {
               _lionFoundPopup.oopsPopup.visible = true;
            }
         }
      }
      
      private static function denBtnMouseDownHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            param1.currentTarget.downToUpState();
            param1.stopPropagation();
            DarkenManager.showLoadingSpiral(true);
            DenXtCommManager.requestDenJoinFull("den" + gMainFrame.userInfo.myUserName);
            mainHud.denBtn.downToUpState();
         }
      }
      
      public static function onExitRoom(param1:Boolean = false) : void
      {
         if(!param1)
         {
            BuddyList.closeBuddyList();
         }
         NGFactManager.closeFact();
         if(!param1)
         {
            if(_mySettings != null)
            {
               _mySettings.destroy();
               _mySettings = null;
               mainHud.mySettingsBtn.downToUpState();
            }
            if(_reportAPlayer)
            {
               if(_reportAPlayer.visible)
               {
                  mainHud.reportBtn.downToUpState();
               }
               _reportAPlayer.destroy();
               _reportAPlayer = null;
            }
            chatHist.resetTreeSearch();
         }
         ReportAPlayer.closeReportFromCardPopoup();
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
            _videoPlayer = null;
         }
         if(PartyManager.visible)
         {
            PartyManager.close();
         }
         if(_pageFlip)
         {
            onPageFlipCloseNP();
         }
         if(ECardManager.eCardVisibility())
         {
            ECardManager.closeECard();
         }
         if(Boolean(volumeMgr) && volumeMgr.visible)
         {
            volumeMgr.show(false,VolumeSelector.WORLD_MAP);
         }
         if(Boolean(_achievementViewer) && _achievementViewer.visible)
         {
            _achievementViewer.close();
         }
         if(_avEditor)
         {
            _avEditor.destroy();
            _avEditor = null;
         }
         if(chatHist)
         {
            chatHist.closeChat();
            chatHist.closeChatRepeatWindow();
         }
         TradeManager.closeAllTradingRelatedPopups();
         QuestManager.closeAdventurePopups();
         showJBGlow(false);
      }
      
      public static function closeAnyInventoryRelatedWindows() : void
      {
         if(ECardManager.eCardVisibility())
         {
            ECardManager.closeECard();
         }
         if(_avEditor)
         {
            TradeManager.resetNumTradeItems(_avEditor.numClothingItemsInTradeListInitially,_avEditor.numDenItemsInTradeListInitially);
            _avEditor.destroy();
            _avEditor = null;
         }
         if(_roomMgr)
         {
            _roomMgr.onRecycleClose();
         }
         if(denEditor)
         {
            denEditor.closeDenCustomization();
            onDenSwitchClose();
         }
      }
      
      public static function closeAnyHudPopups() : void
      {
         BuddyList.closeBuddyList();
         NGFactManager.closeFact();
         if(_mySettings != null)
         {
            _mySettings.destroy();
            _mySettings = null;
            mainHud.mySettingsBtn.downToUpState();
         }
         if(_reportAPlayer)
         {
            if(_reportAPlayer.visible)
            {
               mainHud.reportBtn.downToUpState();
            }
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
         if(PartyManager.visible)
         {
            PartyManager.close();
         }
         if(Boolean(_achievementViewer) && _achievementViewer.visible)
         {
            _achievementViewer.close();
         }
      }
      
      public static function closeWorldMapIfOpen() : void
      {
         if(Boolean(volumeMgr) && volumeMgr.visible)
         {
            volumeMgr.show(false,VolumeSelector.WORLD_MAP);
         }
      }
      
      public static function resetPetWindowListInDen() : void
      {
         if(denEditor)
         {
            denEditor.resetPetWindowList();
         }
      }
      
      public static function refreshDenLockSettings() : void
      {
         if(denEditor)
         {
            denEditor.refreshDenLockSettings();
         }
      }
      
      public static function resetItemAndThemeDenWindows() : void
      {
         if(denEditor)
         {
            denEditor.clearItemWindows();
         }
      }
      
      public static function openWorldMap() : void
      {
         volumeMgr.show(true,VolumeSelector.WORLD_MAP);
      }
      
      public static function onPhotoBoothClose() : void
      {
         SBTracker.pop();
         _photoBooth.destroy();
         _photoBooth = null;
      }
      
      public static function onAvEditorClose() : void
      {
         SBTracker.pop();
         _avEditor.destroy();
         _avEditor = null;
         if(_avEditorCloseCallback != null)
         {
            _avEditorCloseCallback();
            _avEditorCloseCallback = null;
         }
      }
      
      public static function onPageFlipCloseNP() : void
      {
         var _loc1_:Number = NaN;
         if(_pageFlip)
         {
            SBTracker.pop();
            _pageFlip.destroy();
            _pageFlip = null;
         }
         if(!_newsOpenedFromBtn && !_hasClosedGemBonus)
         {
            _loc1_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_DAILY_GEM_BONUS));
            if(_loc1_ == -1 || (_loc1_ & 0xFFFF) < gMainFrame.clientInfo.jamaaDate)
            {
               DarkenManager.showLoadingSpiral(true);
               if(gMainFrame.clientInfo.dailyGiftIndex >= 0 && gMainFrame.clientInfo.dailyGiftIndex < DAILY_GIFT_NUM_DAYS)
               {
                  openDailyGift(gMainFrame.clientInfo.dailyGiftIndex);
               }
               else
               {
                  openGemBonusWheel(_loc1_);
               }
            }
         }
      }
      
      public static function openDailyGift(param1:int) : void
      {
         if(_dailyGiftManager)
         {
            _dailyGiftManager.destroy();
            _dailyGiftManager = null;
         }
         DarkenManager.showLoadingSpiral(true);
         _dailyGiftManager = new DailyGiftManager();
         _dailyGiftManager.init(param1,onDailyGiftClose);
      }
      
      private static function onDailyGiftClose() : void
      {
         _dailyGiftManager.destroy();
         _dailyGiftManager = null;
      }
      
      public static function openMuseumDonation() : void
      {
         if(_museumDonation)
         {
            _museumDonation.destroy();
            _museumDonation = null;
         }
         _museumDonation = new MuseumDonation();
         _museumDonation.init(onMuseumDonationClose);
      }
      
      private static function onMuseumDonationClose() : void
      {
         _museumDonation.destroy();
         _museumDonation = null;
      }
      
      public static function openGemBonusWheel(param1:int) : void
      {
         if(_gemBonusWheel)
         {
            _gemBonusWheel.destroy();
            _gemBonusWheel = null;
         }
         _gemBonusWheel = new GemBonusSpinWheel();
         _gemBonusWheel.init(param1,onGemBonusClose);
      }
      
      public static function setGemBonusValues(param1:uint) : void
      {
         if(_gemBonusWheel)
         {
            _gemBonusWheel.setupValuesAndSpin(param1);
         }
      }
      
      private static function onGemBonusClose() : void
      {
         _gemBonusWheel.destroy();
         _gemBonusWheel = null;
         _hasClosedGemBonus = true;
         guiStartupChecks();
      }
      
      public static function openHolidayBanner() : void
      {
         DarkenManager.showLoadingSpiral(true);
         var _loc1_:MediaHelper = new MediaHelper();
         _loc1_.init(HOLIDAY_BANNER,onHolidayBannerLoaded);
      }
      
      private static function onHolidayBannerLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _holidayBanner = MovieClip(param1.getChildAt(0));
         _holidayBanner.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
         _holidayBanner.bx.addEventListener(MouseEvent.MOUSE_DOWN,onCloseHolidayBanner,false,0,true);
         GuiManager.guiLayer.addChild(_holidayBanner);
         DarkenManager.darken(_holidayBanner);
         AchievementXtCommManager.requestSetUserVar(Achievement.HOLIDAY_BANNER,HOLIDAY_BANNER_START_TIME);
      }
      
      private static function onCloseHolidayBanner(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_holidayBanner)
         {
            DarkenManager.unDarken(_holidayBanner);
            GuiManager.guiLayer.removeChild(_holidayBanner);
            _holidayBanner.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            _holidayBanner.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onCloseHolidayBanner);
            _holidayBanner = null;
         }
      }
      
      public static function onEBookClose() : void
      {
         if(_pageFlip)
         {
            SBTracker.pop();
            _pageFlip.destroy();
            _pageFlip = null;
         }
      }
      
      public static function onAvtSwitchClose() : void
      {
         SBTracker.pop();
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
            _avtSwitcher = null;
         }
      }
      
      public static function closeAvtSwitcherFromRoomJoin() : void
      {
         if(Boolean(_avtSwitcher) && _avtSwitcher.isChoosing)
         {
            return;
         }
         if(!QuestManager.isInPrivateAdventureState)
         {
            setSwapBtnGray(false);
         }
         RoomXtCommManager.isSwitching = false;
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
            _avtSwitcher = null;
         }
      }
      
      public static function onDenSwitchClose(param1:Boolean = false) : void
      {
         if(!param1)
         {
            SBTracker.pop();
         }
         if(_denSwitcher)
         {
            _denSwitcher.destroy();
            _denSwitcher = null;
         }
      }
      
      public static function onMySettingsClose() : void
      {
         if(_mySettings)
         {
            mainHud.mySettingsBtn.downToUpState();
            _mySettings.destroy();
            _mySettings = null;
         }
      }
      
      public static function onReportAPlayerClose(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            mainHud.reportBtn.downToUpState();
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
      }
      
      public static function openDiamondShopInfo() : void
      {
         if(_diamondShopInfoPopup == null)
         {
            DarkenManager.showLoadingSpiral(true);
            _diamondMediaHelper = new MediaHelper();
            _diamondMediaHelper.init(DIAMOND_SHOP_INFO,onDiamondInfoLoaded);
         }
         else
         {
            guiLayer.addChild(_diamondShopInfoPopup);
            DarkenManager.darken(_diamondShopInfoPopup);
         }
      }
      
      public static function openDisplayImagesPopup() : void
      {
         if(_imageDisplayPopup)
         {
            _imageDisplayPopup.destroy();
         }
         _imageDisplayPopup = new ImageDisplayPopup(onImageDisplayClose,189,372);
      }
      
      private static function onImageDisplayClose() : void
      {
         if(_imageDisplayPopup)
         {
            _imageDisplayPopup.destroy();
            _imageDisplayPopup = null;
         }
      }
      
      private static function onDiamondInfoLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _diamondShopInfoPopup = MovieClip(param1.getChildAt(0));
         _diamondShopInfoPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
         _diamondShopInfoPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondInfoClose,false,0,true);
         _diamondShopInfoPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         _diamondShopInfoPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         guiLayer.addChild(_diamondShopInfoPopup);
         DarkenManager.darken(_diamondShopInfoPopup);
      }
      
      private static function onDiamondInfoClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_diamondShopInfoPopup);
         guiLayer.removeChild(_diamondShopInfoPopup);
      }
      
      public static function openVersionPopup(param1:Boolean) : void
      {
         if(param1)
         {
            _differentVersionPopup = new SBYesNoPopup(guiLayer,LocalizationManager.translateIdOnly(21795),true,onVersionPopupConfirm);
         }
         else
         {
            _differentVersionPopup = new SBOkPopup(guiLayer,LocalizationManager.translateIdOnly(21850),true,onVersionPopupConfirm);
         }
      }
      
      public static function isVersionPopupOpen() : Boolean
      {
         if(Boolean(_differentVersionPopup) && _differentVersionPopup.visible)
         {
            _differentVersionPopup.parent.setChildIndex(_differentVersionPopup,_differentVersionPopup.parent.numChildren - 1);
            return true;
         }
         return false;
      }
      
      private static function onVersionPopupConfirm(param1:Object = null) : void
      {
         if(Boolean(param1) && param1.hasOwnProperty("status"))
         {
            if(param1.status)
            {
               Utility.reloadSWFOrGetIp();
            }
         }
         else
         {
            param1.stopPropagation();
         }
         _differentVersionPopup.destroy();
         _differentVersionPopup = null;
      }
      
      private static function mainHudMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,clickedOutsideChatCui,false,0,true);
      }
      
      private static function charWindowDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(!param1.currentTarget.isGray)
         {
            param1.stopPropagation();
            if(!RoomXtCommManager.isSwitching && !QuestManager.isInPrivateAdventureState)
            {
               if(isBeYourPetRoom())
               {
                  DarkenManager.showLoadingSpiral(false);
                  _loc2_ = {"typeDefId":52};
                  MinigameManager.handleGameClick(_loc2_,null,false,showHudAvt);
               }
               else
               {
                  openAvatarEditor();
               }
               toolTip.resetTimerAndSetVisibility();
               if(mainHud.charHelp)
               {
                  mainHud.charHelp.visible = false;
               }
            }
         }
      }
      
      public static function openPhotoBooth() : void
      {
         if(_photoBooth)
         {
            _photoBooth.destroy();
            _photoBooth = null;
         }
         else
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/photoBooth");
            _photoBooth = new PhotoBooth();
            _photoBooth.init(onPhotoBoothClose);
         }
      }
      
      public static function openAvatarEditor(param1:Function = null) : void
      {
         _avEditorCloseCallback = param1;
         if(_avEditor)
         {
            _avEditor.destroy();
            _avEditor = null;
         }
         else
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/avatarEditor");
            _avEditor = new AvatarEditor();
            _avEditor.init(AvatarManager.playerAvatar,guiLayer,true,onAvEditorClose,isInFFM);
         }
      }
      
      public static function openAvEditorRecycle() : void
      {
         if(_avEditor)
         {
            _avEditor.openRecycle();
         }
      }
      
      public static function openAvatarCreator(param1:Boolean, param2:Boolean, param3:int = -1, param4:Boolean = false) : void
      {
         if(_avatarCreator)
         {
            guiLayer.removeChild(_avatarCreator);
            _avatarCreator.destroy();
         }
         _avatarCreator = new GuiAvatarCreationAssets();
         _avatarCreator.initFromWorld(param1,param2,param3,param4);
         guiLayer.addChild(_avatarCreator);
      }
      
      public static function closeAvatarCreator() : void
      {
         if(_avatarCreator)
         {
            guiLayer.removeChild(_avatarCreator);
            _avatarCreator.destroy();
            _avatarCreator = null;
         }
      }
      
      public static function openFastPassAvatarCreator() : void
      {
         if(_avatarCreator)
         {
            guiLayer.removeChild(_avatarCreator);
            _avatarCreator.destroy();
         }
         _avatarCreator = new GuiAvatarCreationAssets();
         _avatarCreator.initFromWorld(false,true,-1,false,true);
         guiLayer.addChild(_avatarCreator);
      }
      
      public static function onEnterRoom(param1:int) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         if(_currRoomDisplayName == "Brady Barr\'s Lab")
         {
            if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_BRADY_BARR_COUNT) < 0)
            {
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_BRADY_BARR_COUNT,1);
               GenericListGuiManager.genericListVolumeClicked(19,{"msg":"bb"});
            }
         }
         else if(_currRoomDisplayName == "Tierney\'s Aquarium")
         {
            if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_TIERNEY_THYS_COUNT) < 0)
            {
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TIERNEY_THYS_COUNT,1);
               GenericListGuiManager.genericListVolumeClicked(78,{"msg":"tt"});
            }
         }
         setFocusToChatText();
         if(mainHud.currentFrame != param1 + 1 || gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST)
         {
            _loc2_ = false;
            if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && QuestManager._questScriptDefId != 0)
            {
               _loc3_ = QuestXtCommManager.getScriptDef(QuestManager._questScriptDefId);
               if(_loc3_ != null && _loc3_.hudType == 0)
               {
                  _loc2_ = true;
               }
            }
            if(_loc2_)
            {
               if(mainHud.currentFrameLabel != "quest")
               {
                  enableGameHud(true,"quest");
               }
            }
            else
            {
               if(mainHud.currentFrameLabel == "quest" || mainHud.currentFrameLabel == "game")
               {
                  enableGameHud(false);
               }
               mainHud.gotoAndStop(param1 + 1);
               mainHud.chat.chatHistoryBG.chatHistBox.hud01_chatHistory.gotoAndStop(param1 + 1);
               if(chatHist)
               {
                  chatHist.clearChat();
               }
            }
            actionMgr.turnOnOceanActions(param1 == SbiConstants.ENVIRO_OCEAN);
         }
         if(GuiManager.isBeYourPetRoom())
         {
            if(mainHud.swapBtn)
            {
               mainHud.swapBtn.visible = false;
            }
            actionMgr.turnOnPetActions(true);
         }
         else
         {
            if(mainHud.swapBtn)
            {
               mainHud.swapBtn.visible = true;
            }
            actionMgr.turnOnPetActions(false);
         }
      }
      
      public static function setFocusToChatText() : void
      {
         if(chatHist)
         {
            chatHist.setFocusOnMsgText();
         }
      }
      
      public static function showHudAvt() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Avatar = null;
         while(mainHud.charWindow.charLayer.numChildren > 0)
         {
            mainHud.charWindow.charLayer.removeChildAt(0);
         }
         if(GuiManager.isBeYourPetRoom())
         {
            _loc1_ = PetManager.myActivePet;
            if(_loc1_)
            {
               new GuiPet(_loc1_.idx,_loc1_.lBits,_loc1_.uBits,_loc1_.eBits,_loc1_.type,_loc1_.name,onBigPetLoaded);
            }
         }
         else
         {
            _loc2_ = AvatarManager.playerAvatar;
            if(_hudAvtView)
            {
               if(_hudAvtView.parent == mainHud.charWindow.charLayer)
               {
                  mainHud.charWindow.charLayer.removeChild(_hudAvtView);
               }
               _hudAvtView.destroy();
            }
            _hudAvtView = new AvatarView();
            _hudAvtView.init(_loc2_);
            _hudAvtView.playAnim(LayerAnim.AN_HUD_AVT,false,LayerAnim.PLAY_ONE_SHOT,null);
            positionHudAvatar();
            mainHud.charWindow.charLayer.addChild(_hudAvtView);
         }
         if(mainHud.currentFrameLabel != "quest")
         {
            mainHud.text01_charName.text = gMainFrame.userInfo.userNameModerated;
         }
      }
      
      public static function grayHudAvatar(param1:Boolean) : void
      {
         if(_hudAvtView)
         {
            if(param1)
            {
               _hudAvtView.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
            }
            else
            {
               _hudAvtView.filters = null;
            }
         }
      }
      
      private static function onBigPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         param1.scaleX = param1.scaleY = 1.7;
         param1.y += mainHud.charWindow.mouse.height * 0.5 - 10;
         mainHud.charWindow.charLayer.addChild(param1);
      }
      
      public static function positionHudAvatar() : void
      {
         var _loc1_:Point = AvatarUtility.getAvatarHudPosition(_hudAvtView.avTypeId);
         _hudAvtView.x = _loc1_.x;
         _hudAvtView.y = _loc1_.y;
      }
      
      public static function activateDenHud(param1:Boolean) : void
      {
         if(mainHud.denBtn)
         {
            mainHud.denBtn.removeEventListener(MouseEvent.MOUSE_DOWN,denBtnMouseDownHandler);
            mainHud.denBtn.visible = !param1;
         }
         if(!param1)
         {
            if(mainHud.denBtn)
            {
               mainHud.denBtn.addEventListener(MouseEvent.MOUSE_DOWN,denBtnMouseDownHandler,false,0,true);
            }
            if(denEditor)
            {
               denEditor.destroy();
               denEditor = null;
               mainHud.furnBtn.visible = false;
            }
            BuddyList.destroyInWorldBuddyList();
         }
         else
         {
            if(denEditor)
            {
               denEditor.destroy();
               denEditor = null;
            }
            denEditor = new DenEditor();
            denEditor.init(AvatarManager.playerAvatar,guiLayer,mainHud);
         }
      }
      
      public static function showDenHudItems(param1:Boolean) : void
      {
         if(denEditor)
         {
            denEditor.toggleEditorHud(param1);
         }
      }
      
      public static function onPetsChanged() : void
      {
         if(denEditor)
         {
            denEditor.reloadDenItems();
         }
      }
      
      public static function onToggleDenLock(param1:Function) : void
      {
         if(denEditor)
         {
            if(denEditor)
            {
               denEditor.openDenLockPopup(param1);
               return;
            }
         }
         param1();
      }
      
      public static function clickedOutsideChatCui(param1:MouseEvent) : void
      {
         if(!mainHud.contains(DisplayObject(param1.target)))
         {
            if(mainHud.safeChatTreeWindow.visible)
            {
               mainHud.safeChatTreeWindow.visible = false;
            }
            if(Boolean(mainHud.emotesWindow.visible) && !isInFFM)
            {
               mainHud.emotesWindow.visible = false;
            }
            if(mainHud.actionsWindow.visible)
            {
               mainHud.actionsWindow.visible = false;
            }
         }
         gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_UP,clickedOutsideChatCui);
      }
      
      public static function onEmoteClick(param1:Sprite) : void
      {
         UserCommXtCommManager.sendAvatarEmote(param1);
      }
      
      public static function resizeHudZoneNameBar(param1:MovieClip) : void
      {
         param1.mouse.name_txt.width = param1.mouse.name_txt.textWidth + 5;
         param1.mouse.mid.width = param1.mouse.name_txt.textWidth + 5 + 0.5 * param1.mouse.left.width;
         param1.mouse.mid.x = param1.mouse.right.x - param1.mouse.mid.width + 1;
         param1.mouse.left.x = param1.mouse.mid.x - 0.5 * param1.mouse.left.width;
         param1.mouse.name_txt.x = param1.mouse.mid.x + 12;
      }
      
      private static function layerGuiMouseDownHandler(param1:MouseEvent) : void
      {
         if(!mainHud.contains(DisplayObject(param1.target)))
         {
            if(mainHud.safeChatTreeWindow.visible)
            {
               mainHud.safeChatBtn.dispatchEvent(param1);
            }
            if(mainHud.emotesWindow.visible)
            {
               mainHud.emotesBtn.dispatchEvent(param1);
            }
            if(mainHud.actionsWindow.visible)
            {
               mainHud.actionsBtn.dispatchEvent(param1);
            }
         }
      }
      
      private static function layerBkgMouseUpHandler(param1:MouseEvent) : void
      {
         if(chatHist)
         {
            chatHist.setFocusOnMsgText();
         }
      }
      
      public static function setRoomNameDisplay(param1:String, param2:int) : void
      {
         var _loc3_:RegExp = null;
         var _loc4_:Array = null;
         var _loc5_:UserInfo = null;
         _currRoomDisplayName = param1;
         _currRoomDisplayNameId = param2;
         if(mainHud.zoneNameTxt)
         {
            if(param1.indexOf(gMainFrame.userInfo.myUserName) == 0)
            {
               if(gMainFrame.clientInfo.userNameModerated == 0)
               {
                  _loc3_ = new RegExp(gMainFrame.userInfo.myUserName,"gi");
                  _currRoomDisplayNameModeratedLocalized = _currRoomDisplayName.replace(_loc3_,LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               }
               else
               {
                  _currRoomDisplayNameModeratedLocalized = _currRoomDisplayNameId != 0 ? LocalizationManager.translateIdOnly(param2) : LocalizationManager.translateIdAndInsertOnly(18427,gMainFrame.userInfo.myUserName);
               }
            }
            else
            {
               _loc4_ = _currRoomDisplayName.split("\'");
               _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(_loc4_[0]);
               if(_loc5_)
               {
                  if(_loc4_[1] == "s Den")
                  {
                     if(_loc5_.userNameModeratedFlag == 0)
                     {
                        _currRoomDisplayNameModeratedLocalized = LocalizationManager.translateIdOnly(11138);
                     }
                     else
                     {
                        _currRoomDisplayNameModeratedLocalized = _currRoomDisplayNameId != 0 ? LocalizationManager.translateIdOnly(param2) : LocalizationManager.translateIdAndInsertOnly(18427,_loc4_[0]);
                     }
                  }
                  else
                  {
                     _currRoomDisplayNameModeratedLocalized = _currRoomDisplayNameId != 0 ? LocalizationManager.translateIdOnly(param2) : _currRoomDisplayName;
                  }
               }
               else
               {
                  _currRoomDisplayNameModeratedLocalized = _currRoomDisplayNameId != 0 ? LocalizationManager.translateIdOnly(param2) : _currRoomDisplayName;
               }
            }
            mainHud.zoneNameTxt.text = _currRoomDisplayNameModeratedLocalized;
            resizeHudZoneNameBar(mainHud.zoneName);
         }
      }
      
      public static function handleMouseDown() : void
      {
         if(chatHist)
         {
            chatHist.dimChat();
         }
         SafeChatManager.closeSafeChat();
         if(actionMgr)
         {
            actionMgr.closeActions();
         }
         if(emoteMgr)
         {
            emoteMgr.closeEmotes();
         }
      }
      
      public static function handleGameExit() : void
      {
         mainHud.chatTxt.text = "";
         setFocusToChatText();
      }
      
      public static function isBeYourPetRoom() : Boolean
      {
         return QuestManager.isBeYourPetQuest() || PartyManager.isBeYourPetParty();
      }
      
      public static function addQuestXP(param1:Number) : void
      {
         if(mainHud.xpMeter)
         {
            if(!isBeYourPetRoom())
            {
               mainHud.xpMeter.xpBar.visible = true;
               mainHud.xpMeter.xpBar.width = mainHud.xpMeter.xpBarContainer.width * (param1 / 100);
            }
            else
            {
               mainHud.xpMeter.xpBar.visible = false;
            }
         }
      }
      
      public static function setQuestHearts(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         var _loc5_:AvatarInfo = null;
         if(mainHud.heartWindow)
         {
            if(_heartItemWindow)
            {
               if(Boolean(_heartItemWindow.parent) && _heartItemWindow.parent == mainHud.heartWindow)
               {
                  mainHud.heartWindow.removeChild(_heartItemWindow);
               }
               _heartItemWindow.destroy();
            }
            _loc2_ = QuestManager._questScriptDefId;
            _loc3_ = QuestXtCommManager.getScriptDef(QuestManager._questScriptDefId);
            _loc4_ = 0;
            if(_loc3_ != null && Boolean(_loc3_.playAsPet))
            {
               _loc4_ = 1;
            }
            else
            {
               _loc5_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
               _loc4_ = Math.round(_loc5_.healthBase * 0.5);
            }
            _heartItemWindow = new WindowGenerator();
            _heartItemWindow.init(_loc4_,1,_loc4_,0,0,0,ItemWindowHeart,null,"",null,{"hpPercentage":param1},onHeartsLoaded,true,false);
            mainHud.heartWindow.addChild(_heartItemWindow);
         }
      }
      
      private static function onHeartsLoaded() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < _heartItemWindow.bg.numChildren)
         {
            MovieClip(_heartItemWindow.bg.getChildAt(_loc1_)).updateFrame();
            _loc1_++;
         }
      }
      
      public static function updateXPShape(param1:MovieClip) : void
      {
         var shape:MovieClip = null;
         var img:MovieClip = param1;
         if(mainHud.xpLevelShape)
         {
            with(mainHud)
            {
               
               while(xpLevelShape.numChildren > 0)
               {
                  xpLevelShape.removeChildAt(0);
               }
               shape = MovieClip(img.getChildAt(0));
               if(shape)
               {
                  shape.text.text = img.passback;
                  xpLevelShape.addChild(shape);
               }
            }
         }
      }
      
      public static function updateShapeXP(param1:int) : void
      {
         var shape:MovieClip = null;
         var level:int = param1;
         if(mainHud.xpLevelShape)
         {
            with(mainHud)
            {
               
               if(xpLevelShape.numChildren > 0)
               {
                  shape = xpLevelShape.getChildAt(0);
                  if(Boolean(shape) && shape.hasOwnProperty("text"))
                  {
                     shape.text.text = level;
                  }
               }
            }
         }
      }
      
      public static function showDiamondConfirmation(param1:int, param2:Function) : void
      {
         if(_diamondConfirmationPopup == null)
         {
            _diamondConfirmationPopup = GETDEFINITIONBYNAME("diamondShopConf");
            _diamondConfirmationPopup.cancelBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn,false,0,true);
            _diamondConfirmationPopup.buyBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn,false,0,true);
            _diamondConfirmationPopup.closeButton.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn,false,0,true);
            _diamondConfirmationPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            _diamondConfirmationPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _diamondConfirmationPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         }
         _diamondConfirmationPopup.callback = param2;
         _diamondConfirmationPopup.diamondTxt.text = Utility.convertNumberToString(param1);
         guiLayer.addChild(_diamondConfirmationPopup);
         DarkenManager.darken(_diamondConfirmationPopup);
      }
      
      public static function onMinimapBtn(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(mainHud.miniMap.visible)
            {
               mainHud.miniMap.visible = false;
            }
            else
            {
               if(mainHud.playersCont.visible)
               {
                  mainHud.playersCont.visible = false;
                  mainHud.questPlayersBtn.downToUpState();
               }
               mainHud.miniMap.visible = true;
            }
         }
      }
      
      private static function onMinimapZoon(param1:MouseEvent) : void
      {
         if(param1.currentTarget.parent.currentFrameLabel == "small")
         {
            param1.currentTarget.parent.gotoAndStop("big");
            param1.currentTarget.mouse.plus.visible = false;
         }
         else
         {
            param1.currentTarget.parent.gotoAndStop("small");
            param1.currentTarget.mouse.plus.visible = true;
         }
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onDiamondConfBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_diamondConfirmationPopup);
         guiLayer.removeChild(_diamondConfirmationPopup);
         if(param1.currentTarget.name == "buyBtn")
         {
            _diamondConfirmationPopup.callback();
         }
         _diamondConfirmationPopup.cancelBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn);
         _diamondConfirmationPopup.buyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn);
         _diamondConfirmationPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
         _diamondConfirmationPopup = null;
      }
      
      private static function addListeners() : void
      {
         guiLayer.addEventListener(MouseEvent.MOUSE_DOWN,layerGuiMouseDownHandler,false,0,true);
         bgLayer.addEventListener(MouseEvent.MOUSE_UP,layerBkgMouseUpHandler,false,0,true);
         mainHud.addEventListener(MouseEvent.MOUSE_DOWN,mainHudMouseDownHandler,false,0,true);
         if(mainHud.charWindow != null)
         {
            mainHud.charWindow.addEventListener(MouseEvent.MOUSE_DOWN,charWindowDownHandler,false,0,true);
         }
         if(mainHud.swapBtn != null)
         {
            mainHud.swapBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSwapBtnClickHandler,false,0,true);
         }
         if(mainHud.awardsBtn != null)
         {
            mainHud.awardsBtn.addEventListener(MouseEvent.MOUSE_DOWN,onAwardsBtnClickHandler,false,0,true);
         }
         if(mainHud.gemsBtn != null)
         {
            mainHud.gemsBtn.addEventListener(MouseEvent.ROLL_OVER,onGemsBtnRollOverHandler,false,0,true);
            mainHud.gemsBtn.addEventListener(MouseEvent.ROLL_OUT,onGemsBtnRollOutHandler,false,0,true);
         }
         if(mainHud.mySettingsBtn != null)
         {
            mainHud.mySettingsBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMySettingsBtnClickHandler,false,0,true);
         }
         if(mainHud.reportBtn != null)
         {
            mainHud.reportBtn.addEventListener(MouseEvent.MOUSE_DOWN,onReportBtnClickHandler,false,0,true);
         }
         if(mainHud.soundBtn != null)
         {
            mainHud.soundBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSoundBtnClickHandler,false,0,true);
         }
         if(mainHud.newsBtn != null)
         {
            mainHud.newsBtn.addEventListener(MouseEvent.MOUSE_DOWN,onNewsPaperBtn,false,0,true);
         }
         if(mainHud.book != null)
         {
            mainHud.book.addEventListener(MouseEvent.MOUSE_DOWN,onJourneyBookBtn,false,0,true);
         }
         if(mainHud.partyBtn != null)
         {
            mainHud.partyBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPartyBtn,false,0,true);
         }
         if(mainHud.safeChatBtn != null)
         {
            mainHud.safeChatBtn.addEventListener(MouseEvent.MOUSE_DOWN,safeChatBtnDownHandler,false,0,true);
         }
         if(mainHud.questExitBtn != null)
         {
            mainHud.questExitBtn.addEventListener(MouseEvent.MOUSE_DOWN,QuestManager.onQuestExit,false,0,true);
         }
         if(mainHud.questPlayersBtn != null)
         {
            mainHud.questPlayersBtn.addEventListener(MouseEvent.MOUSE_DOWN,QuestManager.onQuestPlayersBtn,false,0,true);
         }
         if(mainHud.miniMap_btnQuest != null)
         {
            mainHud.miniMap_btnQuest.addEventListener(MouseEvent.MOUSE_DOWN,onMinimapBtn,false,0,true);
            mainHud.miniMap.zoom.addEventListener(MouseEvent.MOUSE_DOWN,onMinimapZoon,false,0,true);
         }
         if(mainHud.swapPet != null)
         {
            mainHud.swapPet.addEventListener(MouseEvent.MOUSE_DOWN,onPetSwapBtn,false,0,true);
         }
         mainHud.addEventListener(MouseEvent.MOUSE_OVER,onMainHudOver,false,0,true);
         _gemsGlowTimer.addEventListener(TimerEvent.TIMER,gemsGlowTimerHandler,false,0,true);
         _denBtnGlowTimer.addEventListener(TimerEvent.TIMER,denBtnGlowTimerHandler,false,0,true);
      }
      
      private static function removeListeners() : void
      {
         guiLayer.removeEventListener(MouseEvent.MOUSE_DOWN,layerGuiMouseDownHandler);
         bgLayer.removeEventListener(MouseEvent.MOUSE_UP,layerBkgMouseUpHandler);
         mainHud.removeEventListener(MouseEvent.MOUSE_DOWN,mainHudMouseDownHandler);
         if(mainHud.charWindow != null)
         {
            mainHud.charWindow.removeEventListener(MouseEvent.MOUSE_DOWN,charWindowDownHandler);
         }
         if(mainHud.swapBtn != null)
         {
            mainHud.swapBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSwapBtnClickHandler);
         }
         if(mainHud.awardsBtn != null)
         {
            mainHud.awardsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onAwardsBtnClickHandler);
         }
         if(mainHud.gemsBtn != null)
         {
            mainHud.gemsBtn.removeEventListener(MouseEvent.ROLL_OVER,onGemsBtnRollOverHandler);
            mainHud.gemsBtn.removeEventListener(MouseEvent.ROLL_OUT,onGemsBtnRollOutHandler);
         }
         if(mainHud.mySettingsBtn != null)
         {
            mainHud.mySettingsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMySettingsBtnClickHandler);
         }
         if(mainHud.reportBtn != null)
         {
            mainHud.reportBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onReportBtnClickHandler);
         }
         if(mainHud.soundBtn != null)
         {
            mainHud.soundBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSoundBtnClickHandler);
         }
         if(mainHud.newsBtn != null)
         {
            mainHud.newsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onNewsPaperBtn);
         }
         if(mainHud.book != null)
         {
            mainHud.book.removeEventListener(MouseEvent.MOUSE_DOWN,onJourneyBookBtn);
         }
         if(mainHud.partyBtn != null)
         {
            mainHud.partyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onPartyBtn);
         }
         if(mainHud.safeChatBtn != null)
         {
            mainHud.safeChatBtn.removeEventListener(MouseEvent.MOUSE_DOWN,safeChatBtnDownHandler);
         }
         if(mainHud.questExitBtn != null)
         {
            mainHud.questExitBtn.removeEventListener(MouseEvent.MOUSE_DOWN,QuestManager.onQuestExit);
         }
         if(mainHud.questPlayersBtn != null)
         {
            mainHud.questPlayersBtn.removeEventListener(MouseEvent.MOUSE_DOWN,QuestManager.onQuestPlayersBtn);
         }
         if(mainHud.miniMap_btnQuest != null)
         {
            mainHud.miniMap_btnQuest.removeEventListener(MouseEvent.MOUSE_DOWN,onMinimapBtn);
            mainHud.miniMap.zoom.removeEventListener(MouseEvent.MOUSE_DOWN,onMinimapZoon);
         }
         if(mainHud.swapPet != null)
         {
            mainHud.swapPet.removeEventListener(MouseEvent.MOUSE_DOWN,onPetSwapBtn);
         }
         mainHud.removeEventListener(MouseEvent.MOUSE_OVER,onMainHudOver);
         _gemsGlowTimer.removeEventListener(TimerEvent.TIMER,gemsGlowTimerHandler);
         _denBtnGlowTimer.removeEventListener(TimerEvent.TIMER,denBtnGlowTimerHandler);
      }
      
      private static function onMainHudOver(param1:MouseEvent) : void
      {
         QuestManager.updatePrivateAdventureIndexComparedToMainHud();
      }
      
      public static function safeChatBtnDownHandler(param1:MouseEvent) : void
      {
         if(!mainHud.safeChatBtn.isGray)
         {
            if(mainHud.safeChatTreeWindow.visible)
            {
               SafeChatManager.closeSafeChat();
            }
            else
            {
               if(mainHud.emotesWindow.visible)
               {
                  mainHud.emotesBtn.dispatchEvent(param1);
               }
               if(mainHud.actionsWindow.visible)
               {
                  mainHud.actionsBtn.dispatchEvent(param1);
               }
               if(param1)
               {
                  param1.stopPropagation();
               }
               SafeChatManager.openSafeChat(true);
            }
         }
      }
      
      public static function toggleHud() : void
      {
         if(mainHud.visible)
         {
            mainHud.visible = false;
            gMainFrame.stage.focus = null;
         }
         else if(!AvatarManager.isMyAvtInPreviewRoom)
         {
            mainHud.visible = true;
            setFocusToChatText();
         }
      }
      
      private static function namebarBadgeDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         for each(_loc3_ in param1.def)
         {
            _loc2_ = {
               "defId":int(_loc3_.id),
               "pendingFlagsBit":int(_loc3_.pendingFlagsBit),
               "mediaRefId":int(_loc3_.mediaRefId)
            };
            _namebarBadgeDefs[_loc2_.defId] = _loc2_;
         }
      }
      
      public static function loadNameBarBadgeList() : void
      {
         GenericListXtCommManager.requestGenericList(NAME_BAR_ICONS_LIST_ID,onNameBarListLoaded);
      }
      
      private static function onNameBarListLoaded(param1:Array) : void
      {
         var _loc3_:Object = null;
         _namebarBadgeList = [];
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = getNamebarBadgeDef(param1[_loc2_]);
            if(_loc3_)
            {
               _namebarBadgeList[_loc2_] = _loc3_.mediaRefId;
            }
            _loc2_++;
         }
      }
      
      public static function getNamebarBadgeList() : Array
      {
         return _namebarBadgeList;
      }
      
      public static function getNamebarBadgeDefs() : Object
      {
         return _namebarBadgeDefs;
      }
      
      public static function getNamebarBadgeDef(param1:int) : Object
      {
         return _namebarBadgeDefs[param1];
      }
      
      public static function enableGameHud(param1:Boolean, param2:String = null, param3:Object = null) : void
      {
         var _loc4_:AvatarInfo = null;
         var _loc5_:Object = null;
         if(denEditor)
         {
            denEditor.destroy();
            denEditor = null;
         }
         if(param1)
         {
            volumeMgr.enable(false);
            removeListeners();
            _originalHudFrame = mainHud.currentFrame;
            mainHud.gotoAndStop(param2);
            (mainHud as GuiHud).init(true);
            addListeners();
            GuiManager.chatHist.toggleInGameHud(true);
            if(param2 == "quest")
            {
               _loc4_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
               addQuestXP(_loc4_.questXPPercentage);
               setQuestHearts(_loc4_.questHealthPercentage);
               QuestManager.loadLevelShape(_loc4_.questLevel);
               if(_needToRebuildMainHud)
               {
                  rebuildMainHud();
               }
               else
               {
                  chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,UserCommXtCommManager.onSendMessage,mainHud.predictTxtTagQuest,mainHud.specialCharContQuest,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow,false);
                  SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_ADVENTURE);
                  SafeChatManager.reload(false,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
                  actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,UserCommXtCommManager.sendAvatarAction);
                  emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,onEmoteClick);
                  setToolTipText();
               }
               setupSoundButton();
               _loc5_ = QuestXtCommManager.getScriptDef(QuestManager._questScriptDefId);
               if(_loc5_ != null && (_loc5_.time != 1 && _loc5_.avatarLimit != 1))
               {
                  GuiManager.mainHud.miniMap_btnQuest.upToDownState();
                  mainHud.miniMap.visible = true;
               }
               else
               {
                  mainHud.miniMap.visible = false;
               }
               mainHud.playersCont.visible = false;
               if(param3)
               {
                  if(mainHud.combatCardDeckBtn != null)
                  {
                     mainHud.combatCardDeckBtn.addEventListener(MouseEvent.MOUSE_DOWN,param3.onCardDeckBtnClickHandler,false,0,true);
                  }
               }
            }
            else if(param2 == "game")
            {
               if(_needToRebuildMainHud)
               {
                  rebuildMainHud();
               }
               else
               {
                  chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,MinigameManager.sendChatMsg,mainHud.predictTxtTag,mainHud.specialCharCont,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow,false);
                  SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_ADVENTURE,MinigameManager.sendSafeChatMsg);
                  SafeChatManager.reload(false,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
                  actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,MinigameManager.sendActionMsg);
                  emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,MinigameManager.sendEmoteMsg);
                  setToolTipText();
               }
            }
         }
         else if(_originalHudFrame != -1)
         {
            if(param3)
            {
               if(mainHud.combatCardDeckBtn != null)
               {
                  mainHud.combatCardDeckBtn.removeEventListener(MouseEvent.MOUSE_DOWN,param3.onCardDeckBtnClickHandler);
               }
            }
            removeListeners();
            mainHud.gotoAndStop(_originalHudFrame);
            (mainHud as GuiHud).init(true);
            addListeners();
            setToolTipText();
            _originalHudFrame = -1;
            if(_needToRebuildMainHud)
            {
               rebuildMainHud();
            }
            else
            {
               chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,UserCommXtCommManager.onSendMessage,mainHud.predictTxtTag,mainHud.specialCharCont,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow,false);
               SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_SAFECHAT);
               SafeChatManager.reload(false,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
               actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,UserCommXtCommManager.sendAvatarAction);
               emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,onEmoteClick);
               volumeMgr.enable(true,mainHud.worldMapBtn,mainHud.zoneName,mainHud.worldHelp);
               setToolTipText();
               ECardManager.init(guiLayer,mainHud.eCardBtn,true);
               BuddyList.rebuildBtn(mainHud.buddyListBtn);
            }
            GuiManager.chatHist.toggleInGameHud(false);
            setupSoundButton();
            mainHud.safeChatTreeWindow.visible = false;
            mainHud.actionsWindow.visible = false;
            mainHud.emotesWindow.visible = false;
            if(mainHud.swapBtn.hasGrayState)
            {
               mainHud.swapBtn.activateGrayState(false);
            }
            mainHud.mainBlock.visible = false;
            mainHud.gemsBtnBlock.visible = false;
            mainHud.charWindowBlock.visible = false;
            mainHud.gemsBtn.glow.visible = false;
            mainHud.awardsBtn.glow.visible = false;
            mainHud.newsBtn.glow.visible = false;
            mainHud.denBtn.glow.visible = false;
            mainHud.book.glow.visible = false;
            mainHud.book.gift.visible = false;
            mainHud.partyBtn.glow.visible = false;
            mainHud.playerWallBtn.glow.visible = false;
            mainHud.playerWallBtn.visible = false;
            mainHud.mySettingsBtn.glow.visible = false;
            mainHud.furnBtn.glow.visible = false;
            mainHud.furnBtn.visible = false;
            mainHud.denCount.visible = false;
         }
         setRoomNameDisplay(_currRoomDisplayName,_currRoomDisplayNameId);
         setFocusToChatText();
      }
      
      public static function rebuildMainHud() : void
      {
         if(chatHist)
         {
            (mainHud as GuiHud).init(true);
            chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,UserCommXtCommManager.onSendMessage,mainHud.predictTxtTag == null ? mainHud.predictTxtTagQuest : mainHud.predictTxtTag,mainHud.specialCharCont == null ? mainHud.specialCharContQuest : mainHud.specialCharCont,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow,true);
            SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_SAFECHAT);
            SafeChatManager.reload(true,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
            actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,UserCommXtCommManager.sendAvatarAction);
            emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,onEmoteClick);
            PartyManager.reload();
            if(mainHud.worldMapBtn)
            {
               volumeMgr.enable(true,mainHud.worldMapBtn,mainHud.zoneName,mainHud.worldHelp);
            }
            setToolTipText();
            if(mainHud.eCardBtn)
            {
               ECardManager.init(guiLayer,mainHud.eCardBtn,true);
            }
            if(mainHud.buddyListBtn)
            {
               BuddyList.destroy();
               BuddyList.init(guiLayer,mainHud.buddyListBtn,true);
            }
            if(Boolean(mainHud.awardsBtn) && Boolean(_achievementViewer) && _achievementViewer.hasBeenInited)
            {
               _achievementViewer.destroy();
               _achievementViewer.init(mainHud.awardsBtn.x + 15,mainHud.awardsBtn.y + mainHud.awardsBtn.height * 0.5 - 5,287,true);
            }
            updateDenRoomCount(_currentDenRoomCount,false,gMainFrame.userInfo.myUserName);
         }
         if(LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG)
         {
            if(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_PREDICTIVE || PredictiveTextManager.lastRequestedPredictiveLanguage != LocalizationManager.currentLanguage || !PredictiveTextManager.hasRequestWordsList && LocalizationManager.accountLanguage != LocalizationManager.LANG_ENG)
            {
               PredictiveTextManager.requestAndCreateTextTreeNode();
            }
         }
         else
         {
            PredictiveTextManager.requestAndCreateTextTreeNode();
         }
         ItemXtCommManager.relocalizeItems();
         DenXtCommManager.relocalizeDenItems();
         DenXtCommManager.relocalizeDenRooms();
         PetManager.relocalizePetDefs();
         ItemXtCommManager.relocalizeCurrencyExchanges();
         _needToRebuildMainHud = false;
      }
      
      public static function grayOutHudItemsForPrivateLobby(param1:Boolean) : void
      {
         mainHud.partyBtn.activateGrayState(param1);
         mainHud.book.activateGrayState(param1);
         mainHud.swapBtn.activateGrayState(param1);
         mainHud.buddyListBtn.activateGrayState(param1);
         mainHud.eCardBtn.activateGrayState(param1);
         mainHud.awardsBtn.activateGrayState(param1);
         mainHud.newsBtn.activateGrayState(param1);
         actionMgr.grayGameTab(param1);
      }
   }
}

