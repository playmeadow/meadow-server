package gui
{
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
   import flash.text.TextFieldAutoSize;
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
      
      public static var wasInFFM:Boolean;
      
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
      
      private static var _swap:MovieClip;
      
      private static var _swapPopup:SBPopup;
      
      private static var _awards:MovieClip;
      
      private static var _awardsPopup:SBPopup;
      
      private static var _timer:MovieClip;
      
      private static var _timerPopup:SBPopup;
      
      private static var _report:MovieClip;
      
      private static var _reportPopup:SBPopup;
      
      private static var _rulesPopup:SBPopup;
      
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
      
      private static var _tutorialMediaHelper:MediaHelper;
      
      private static var _talkingTutorialPopup:MovieClip;
      
      private static var _tutorialTextPopup:MovieClip;
      
      private static var _talkingLoadingSpiral:LoadingSpiral;
      
      private static var _giftGemsMediaHelper:MediaHelper;
      
      private static var _talkingTutorialTimer:Timer;
      
      private static const DAILY_GIFT_NUM_DAYS:int = 25;
      
      private static const MAX_GEMS:int = 1000;
      
      private static const JB_LIST_ID:int = 53;
      
      private static const NEWSPAPER_LIST_ID:int = 34;
      
      private static const DIAMOND_SHOP_INFO:int = 2222;
      
      private static const AJ_JUMP_POPUP:int = 2540;
      
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
      
      public static function init(initGuiLayer:DisplayLayer, initFpsLayer:DisplayLayer, initWorldLayer:SortLayer, initChatLayer:DisplayLayer, initBkgLayer:DisplayLayer, setFocus:Function) : void
      {
         _roomMgr = RoomManagerWorld.instance;
         DarkenManager.init(initGuiLayer);
         SBPopupManager.darken = DarkenManager.darken;
         SBPopupManager.lighten = DarkenManager.unDarken;
         DarkenManager.setFocus = setFocus;
         guiLayer = initGuiLayer;
         fpsLayer = initFpsLayer;
         worldLayer = initWorldLayer;
         chatLayer = initChatLayer;
         bgLayer = initBkgLayer;
         mainHud = GETDEFINITIONBYNAME("MainHud");
         mainHud.x = 6;
         mainHud.y = 5;
         mainHud.cacheAsBitmap = true;
         mainHud.safeChatTreeWindow.visible = false;
         mainHud.actionsWindow.visible = false;
         mainHud.emotesWindow.visible = false;
         if(Boolean(mainHud.swapBtn.hasGrayState))
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
         var dpdh:DefPacksDefHelper = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_NAMEBAR_BADGE,namebarBadgeDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_NAMEBAR_BADGE] = dpdh;
      }
      
      public static function setupAllItems() : void
      {
         chatHist = new ChatHistory(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,UserCommXtCommManager.onSendMessage,mainHud.predictTxtTag,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow);
         SafeChatManager.init(UserCommXtCommManager.sendAvatarSafeChat,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
         emoteMgr = new EmoticonManager(onEmoteClick,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
         actionMgr = new ActionManager(UserCommXtCommManager.sendAvatarAction,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
         mainHud.furnBtn.visible = false;
         mainHud.mySettingsBtn.glow.visible = false;
         if(Boolean(mainHud.mySettingsBtn.hasGrayState))
         {
            mainHud.mySettingsBtn.activateGrayState(false);
         }
         if(Boolean(mainHud.reportBtn.hasGrayState))
         {
            mainHud.reportBtn.activateGrayState(false);
         }
         InstructionScreenBuilder.init(guiLayer);
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
      
      public static function setSharedObj(objectType:String, value:*) : void
      {
         if(_sharedObj != null)
         {
            switch(objectType)
            {
               case "cursor":
                  if(_sharedObj.data.cursor != value)
                  {
                     _sharedObj.data.cursor = value;
                  }
                  break;
               case "msgColor":
                  if(_sharedObj.data.msgColor != value)
                  {
                     _sharedObj.data.msgColor = value;
                  }
                  break;
               case "msgPattern":
                  if(_sharedObj.data.msgPattern != value)
                  {
                     _sharedObj.data.msgPattern = value;
                  }
                  break;
               case "expiration":
                  if(_sharedObj.data.expiration != value)
                  {
                     _sharedObj.data.expiration = value;
                  }
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
      
      public static function startFFM(isFromKeyBoard:Boolean = false) : void
      {
         if(Boolean(gMainFrame.server.getCurrentRoom()))
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
         var roomName:String = "ffm" + gMainFrame.userInfo.myUserName;
         RoomXtCommManager.sendNonDenRoomJoinRequest(roomName);
      }
      
      private static function ffmAssetsLoadedCallback() : void
      {
         LoadProgress.show(true);
         QuestXtCommManager.sendQuestCreateJoinPublic(25);
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
         InstructionScreenBuilder.destroy();
         DarkenManager.destroy();
         ItemXtCommManager.setHudAvtItemListLayerAnim(null);
         _reconnecting = false;
      }
      
      private static function setToolTipText() : void
      {
         if(Boolean(mainHud.buddyListBtn))
         {
            mainHud.buddyListBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14656),mainHud.x,40);
         }
         if(Boolean(mainHud.eCardBtn))
         {
            mainHud.eCardBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14657),mainHud.x,40);
         }
         if(Boolean(mainHud.newsBtn))
         {
            mainHud.newsBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14658),mainHud.x,40);
         }
         if(Boolean(mainHud.mySettingsBtn))
         {
            mainHud.mySettingsBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14659),mainHud.x,45);
         }
         if(Boolean(mainHud.reportBtn))
         {
            mainHud.reportBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14660),mainHud.x,45);
         }
         if(Boolean(mainHud.charWindow))
         {
            mainHud.charWindow.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14673),mainHud.x,mainHud.currentFrameLabel == "quest" ? -40 : -55);
         }
         if(Boolean(mainHud.swapBtn))
         {
            mainHud.swapBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14661),mainHud.x,-35);
         }
         if(Boolean(mainHud.actionsBtn))
         {
            mainHud.actionsBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14662),mainHud.x,-30);
         }
         if(Boolean(mainHud.emotesBtn))
         {
            mainHud.emotesBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14663),mainHud.x,-30);
         }
         if(Boolean(mainHud.sendChatBtn))
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
         if(Boolean(mainHud.safeChatBtn))
         {
            mainHud.safeChatBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14664),mainHud.x,-30);
         }
         if(Boolean(mainHud.denBtn))
         {
            mainHud.denBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14665),mainHud.x,-35);
         }
         if(Boolean(mainHud.soundBtn))
         {
            mainHud.soundBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14666),mainHud.x,-25);
         }
         if(Boolean(mainHud.worldMapBtn))
         {
            mainHud.worldMapBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14667),mainHud.x,-50);
         }
         if(Boolean(mainHud.awardsBtn))
         {
            mainHud.awardsBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(11239),mainHud.x,40);
         }
         if(Boolean(mainHud.book))
         {
            mainHud.book.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14668),mainHud.x,40);
         }
         if(Boolean(mainHud.partyBtn))
         {
            mainHud.partyBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14669),mainHud.x,40);
         }
         if(Boolean(mainHud.questPlayersBtn))
         {
            mainHud.questPlayersBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14670),mainHud.x,-30);
         }
         if(Boolean(mainHud.questingExit_btnQuest))
         {
            mainHud.questingExit_btnQuest.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14671),mainHud.x,-35);
         }
         if(Boolean(mainHud.miniMap_btnQuest))
         {
            mainHud.miniMap_btnQuest.initToolTip(guiLayer,LocalizationManager.translateIdOnly(14672),mainHud.x,-35);
         }
         if(Boolean(mainHud.chatRepeatBtn))
         {
            mainHud.chatRepeatBtn.initToolTip(guiLayer,LocalizationManager.translateIdOnly(18215),mainHud.x,-24);
         }
      }
      
      private static function blockMouseHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      public static function setSwapBtnGray(enable:Boolean) : void
      {
         if(Boolean(mainHud.swapBtn) && mainHud.swapBtn.isGray != enable)
         {
            mainHud.swapBtn.activateGrayState(enable);
         }
      }
      
      public static function isModal() : Boolean
      {
         return volumeMgr.visible;
      }
      
      public static function setupGemGiftPopup(numGems:int) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _giftGemsMediaHelper = new MediaHelper();
         _giftGemsMediaHelper.init(StartupPopups.GEMS_MEDIA_ID,onGemIconLoaded,numGems);
      }
      
      private static function onGemIconLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(img))
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(guiLayer,img,LocalizationManager.translateIdAndInsertOnly(LocalizationManager.GEMS_CAPITALIZED,img.passback),img.passback,GiftPopup.POPUP_TYPE_PRIZE,GiftPopup.GIFT_TYPE_GEMS,null,keepGemGiftCallback,null,false,GiftPopup.BUTTONS_TYPE_OK);
         }
         _giftGemsMediaHelper.destroy();
         _giftGemsMediaHelper = null;
      }
      
      private static function keepGemGiftCallback() : void
      {
         if(Boolean(_giftPopup))
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         if(Boolean(denEditor))
         {
            denEditor.onDenTutorialGiftClose();
         }
      }
      
      public static function onItemPrize(data:Object) : void
      {
         _prizeData = {
            "userVarId":int(data[2]),
            "isClothing":data[3] == "1",
            "itemDefId":int(data[4]),
            "itemName":LocalizationManager.translateIdOnly(int(data[5])),
            "desc":LocalizationManager.translateIdOnly(int(data[6])),
            "color":uint(data[7])
         };
      }
      
      public static function showPrizePopupIfAny() : Boolean
      {
         var def:Object = null;
         if(Boolean(_prizeData))
         {
            def = DenXtCommManager.getDenItemDef(_prizeData.itemDefId);
            if(!def)
            {
               return false;
            }
            _prizeDenItemHelper = new DenItemHelper();
            _prizeDenItemHelper.init(uint(_prizeData.itemDefId << 16 | DenItem.getIconId(def.sortCat)),onPrizeIconReceived,_prizeData.color);
            return true;
         }
         return false;
      }
      
      private static function onPrizeIconReceived(helper:DenItemHelper) : void
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
            _prizeImg = img;
            _prizeOkPopup = new SBOkPopup(guiLayer,_prizeData.desc,true,onPrizeDescOkDown);
         }
      }
      
      private static function onPrizeDescOkDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
         if(Boolean(_giftPopup))
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         _prizeData = null;
         if(Boolean(_prizeDenItemHelper))
         {
            _prizeDenItemHelper.destroy();
            _prizeDenItemHelper = null;
         }
         _prizeImg = null;
         guiStartupChecks();
      }
      
      public static function guiStartupChecks() : void
      {
         var dailyGemVarValue:int = 0;
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(!showPrizePopupIfAny())
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP_STARTUP) != gMainFrame.clientInfo.newspaperTimestamp)
               {
                  GuiManager.onNewsPaperBtn(null);
                  AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP_STARTUP,gMainFrame.clientInfo.newspaperTimestamp);
               }
               else if(!_hasClosedGemBonus)
               {
                  dailyGemVarValue = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_DAILY_GEM_BONUS));
                  if(dailyGemVarValue == -1 || (dailyGemVarValue & 0xFFFF) < gMainFrame.clientInfo.jamaaDate)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     if(gMainFrame.clientInfo.dailyGiftIndex >= 0 && gMainFrame.clientInfo.dailyGiftIndex < DAILY_GIFT_NUM_DAYS)
                     {
                        openDailyGift(gMainFrame.clientInfo.dailyGiftIndex);
                     }
                     else
                     {
                        openGemBonusWheel(dailyGemVarValue);
                     }
                  }
               }
            }
         }
      }
      
      public static function openGiftPopup(icon:Sprite, name:String, defId:int, eCardType:int, onKeep:Function, onReject:Function, onClose:Function, buttonsType:int, onCloseMsg:String, popupType:int, msgText:String, isFromStartup:Boolean) : void
      {
         _giftPopup = new GiftPopup();
         _giftPopup.init(guiLayer,icon,name,defId,popupType,GiftPopup.giftTypeForECardType(eCardType),onKeep,onReject,onClose,false,buttonsType,Utility.ENVIRO_LAND,onCloseMsg,msgText,null,isFromStartup);
      }
      
      public static function closePromoPopup() : Boolean
      {
         if(Boolean(_giftPopup))
         {
            _giftPopup.close();
            return true;
         }
         return false;
      }
      
      public static function destroyPromotionalPopup() : void
      {
         if(Boolean(_giftPopup))
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
      }
      
      public static function initMessagePopups(isFromDailyGift:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _startupPopups = new StartupPopups();
         _startupPopups.init(guiLayer,isFromDailyGift);
      }
      
      public static function initDemotionMessage(callback:Function) : void
      {
         _demotionMessage = new DemotionMessages();
         _demotionMessage.init(callback);
      }
      
      public static function initPlayerEngagement(callback:Function) : void
      {
         _playerEngagement = new PlayerEngagement();
         _playerEngagement.init(callback);
      }
      
      public static function set reconnecting(r:Boolean) : void
      {
         _reconnecting = r;
      }
      
      public static function get reconnecting() : Boolean
      {
         return _reconnecting;
      }
      
      public static function initMoviePlayer(mediaId:int, videos:Array, descr:Array, subtitleIds:Array, shouldRepeat:Boolean = true, width:int = 512, height:int = 288) : void
      {
         if(Boolean(_videoPlayer))
         {
            _videoPlayer.destroy();
         }
         _videoPlayer = new VideoPlayerOSMF();
         _videoPlayer.init(videos,subtitleIds,descr,mediaId,-1,shouldRepeat,width,height);
      }
      
      public static function setVideoPlayerSkin(frameId:int) : void
      {
         if(Boolean(_videoPlayer))
         {
            _videoPlayer.setSkinFrame(frameId);
         }
      }
      
      private static function gemsGlowTimerHandler(te:TimerEvent) : void
      {
         _gemsGlowTimer.stop();
         if(Boolean(mainHud.gemsBtn))
         {
            mainHud.gemsBtn.glow.visible = false;
         }
      }
      
      public static function startGemsFlash() : void
      {
         _gemsGlowTimer.start();
         AJAudio.playGemsEarnedSound();
         if(Boolean(mainHud.gemsBtn))
         {
            mainHud.gemsBtn.glow.visible = true;
         }
      }
      
      public static function startDenBtnGlow() : void
      {
         if(Boolean(mainHud.denBtn))
         {
            _denBtnGlowTimer.start();
            mainHud.denBtn.glow.visible = true;
         }
      }
      
      public static function denBtnGlowTimerHandler(te:TimerEvent) : void
      {
         _denBtnGlowTimer.reset();
         if(Boolean(mainHud.denBtn))
         {
            mainHud.denBtn.glow.visible = false;
         }
      }
      
      public static function onNewsPaperBtn(evt:MouseEvent) : void
      {
         _newsOpenedFromBtn = evt != null;
         if(_newsOpenedFromBtn)
         {
            evt.stopPropagation();
         }
         if(!mainHud.newsBtn.isGray)
         {
            if(Boolean(_pageFlip))
            {
               _pageFlip.destroy();
            }
            if(Boolean(mainHud.newsBtn.glow.visible) && Boolean(evt))
            {
               mainHud.newsBtn.glow.visible = false;
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP,gMainFrame.clientInfo.newspaperTimestamp);
            }
            DarkenManager.showLoadingSpiral(true);
            GenericListXtCommManager.requestGenericList(NEWSPAPER_LIST_ID,onNewsPaperMediaListReceived);
         }
      }
      
      private static function onNewsPaperMediaListReceived(glId:int, mediaIds:Array, locStrs:Array) : void
      {
         SBTracker.push();
         _pageFlip = new PageFlip();
         _pageFlip.init(guiLayer,mediaIds,true,onPageFlipCloseNP,onFlipNP);
      }
      
      public static function onJourneyBookBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            if(Boolean(mainHud.book.glow.visible))
            {
               mainHud.book.glow.visible = false;
            }
            openJourneyBook();
         }
      }
      
      public static function openJourneyBook(showInfoPopup:Boolean = false) : void
      {
         if(Boolean(_pageFlip))
         {
            _pageFlip.destroy();
         }
         DarkenManager.showLoadingSpiral(true);
         if(showInfoPopup)
         {
            GenericListXtCommManager.requestGenericList(JB_LIST_ID,onJourneyBookMediaListReceivedWithInfo);
         }
         else
         {
            GenericListXtCommManager.requestGenericList(JB_LIST_ID,onJourneyBookMediaListReceived);
         }
      }
      
      private static function onJourneyBookMediaListReceived(glId:int, mediaIds:Array, locStrs:Array, showInfoPopup:Boolean = false) : void
      {
         SBTracker.push();
         var pageNum:int = 1;
         for(var i:int = 0; i < locStrs.length; i++)
         {
            if(LocalizationManager.translateIdOnly(locStrs[i]).toLowerCase() == _currRoomDisplayNameModeratedLocalized.toLowerCase())
            {
               pageNum = i + 1;
               break;
            }
         }
         _pageFlip = new PageFlip();
         _pageFlip.init(guiLayer,mediaIds,true,onEBookClose,onJourneyBookFlipNP,false,false,false,true,pageNum,showInfoPopup);
      }
      
      private static function onJourneyBookMediaListReceivedWithInfo(glId:int, mediaIds:Array, locStrs:Array) : void
      {
         onJourneyBookMediaListReceived(glId,mediaIds,locStrs,true);
      }
      
      public static function showJBGlow(show:Boolean) : void
      {
         if(mainHud.book != null && !mainHud.book.isGray)
         {
            mainHud.book.glow.visible = show;
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
      
      public static function openEBook(mediaListId:int, isRectangular:Boolean, isAJEBook:Boolean) : void
      {
         if(Boolean(_pageFlip))
         {
            _pageFlip.destroy();
         }
         _isRectangularEBook = isRectangular;
         _isAJEBook = isAJEBook;
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestGenericList(mediaListId,onMediaListReceived);
      }
      
      private static function onMediaListReceived(glId:int, mediaIds:Array, locStrs:Array) : void
      {
         _currentBookId = glId;
         SBTracker.push();
         _pageFlip = new PageFlip();
         _pageFlip.init(guiLayer,mediaIds,false,onEBookClose,onEBookFlipNP,_isRectangularEBook,_isAJEBook);
         DarkenManager.showLoadingSpiral(false);
      }
      
      public static function onMyUserVarsReceived() : void
      {
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP) != gMainFrame.clientInfo.newspaperTimestamp)
         {
            mainHud.newsBtn.glow.visible = true;
         }
      }
      
      private static function onJourneyBookFlipNP(pageName:String) : void
      {
         SBTracker.trackPageview("/game/play/popup/jb/#" + pageName);
      }
      
      private static function onFlipNP(pageNumber:int) : void
      {
         SBTracker.trackPageview("/game/play/popup/newspaper/#page" + pageNumber);
      }
      
      private static function onEBookFlipNP(pageNumber:int) : void
      {
         SBTracker.trackPageview("/game/play/popup/#book_" + _currentBookId + "/page" + pageNumber);
      }
      
      public static function openJumpPopup(isJoey:Boolean, callback:Function, gemsImage:MovieClip, currGiftId:int) : void
      {
         SBTracker.trackPageview("/game/play/popup/ajJump" + (isJoey ? "/joey" : "/gems"),-1,SBTracker.TYPE_EVENT);
         if(Boolean(_joeyPopup))
         {
            if(!_joeyPopup.isJoey && !isJoey)
            {
               LocalizationManager.translateIdAndInsert(_joeyPopup.contentTxt,LocalizationManager.GEMS_CAPITALIZED,Utility.convertNumberToString(_joeyPopup.currGiftId + currGiftId));
               _joeyPopup.currGiftId += currGiftId;
               return;
            }
            if(Boolean(_joeyPopup.isJoey) && isJoey)
            {
               return;
            }
            DarkenManager.unDarken(_joeyPopup);
            guiLayer.removeChild(_joeyPopup);
            _secondaryJoeyPopup = _joeyPopup;
         }
         var mh:MediaHelper = new MediaHelper();
         mh.init(AJ_JUMP_POPUP,onJumpPopupLoaded,{
            "isJoey":isJoey,
            "callback":callback,
            "gemsImage":gemsImage,
            "currGiftId":currGiftId
         });
      }
      
      private static function onJumpPopupLoaded(img:MovieClip) : void
      {
         var mh:MediaHelper = null;
         if(Boolean(img))
         {
            _joeyPopup = MovieClip(img.getChildAt(0));
            _joeyPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _joeyPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            _joeyPopup.callback = img.passback.callback;
            _joeyPopup.isJoey = img.passback.isJoey;
            _joeyPopup.currGiftId = img.passback.currGiftId;
            _joeyPopup.image = img.passback.gemsImage;
            _joeyPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            _joeyPopup.xBtn.addEventListener(MouseEvent.MOUSE_DOWN,jumpCloseHandler,false,0,true);
            mh = new MediaHelper();
            if(Boolean(img.passback.isJoey))
            {
               mh.init(StartupPopups.JOEY_MEDIA_ID,onJumpImageLoaded,_joeyPopup);
               LocalizationManager.translateId(_joeyPopup.contentTxt,11137);
            }
            else
            {
               if(Boolean(_joeyPopup.image))
               {
                  _joeyPopup.itemWindow.addChild(_joeyPopup.image);
               }
               else
               {
                  mh.init(StartupPopups.GEMS_MEDIA_ID,onJumpImageLoaded,_joeyPopup);
               }
               LocalizationManager.translateIdAndInsert(_joeyPopup.contentTxt,LocalizationManager.GEMS_CAPITALIZED,_joeyPopup.currGiftId);
            }
            guiLayer.addChild(_joeyPopup);
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_joeyPopup);
            img.mediaHelper.destroy();
            delete img.mediaHelper;
            delete img.passback;
         }
      }
      
      private static function onJumpImageLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            img.passback.itemWindow.addChild(img);
            img.mediaHelper.destroy();
            delete img.mediaHelper;
            delete img.passback;
         }
      }
      
      private static function jumpCloseHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         _joeyPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
         _joeyPopup.xBtn.removeEventListener(MouseEvent.MOUSE_DOWN,jumpCloseHandler);
         DarkenManager.unDarken(_joeyPopup);
         guiLayer.removeChild(_joeyPopup);
         var tempJoey:MovieClip = _joeyPopup;
         _joeyPopup = null;
         if(Boolean(_secondaryJoeyPopup))
         {
            _joeyPopup = _secondaryJoeyPopup;
            guiLayer.addChild(_joeyPopup);
            DarkenManager.darken(_joeyPopup);
            _secondaryJoeyPopup = null;
         }
         if(Boolean(tempJoey.callback))
         {
            tempJoey.callback(tempJoey.isJoey,tempJoey.currGiftId,tempJoey.image);
         }
         tempJoey = null;
      }
      
      public static function onSwapBtnClickHandler(evt:MouseEvent) : void
      {
         if(Boolean(mainHud.swapBtn) && Boolean(mainHud.swapBtn.isGray) || RoomXtCommManager.isSwitching)
         {
            return;
         }
         evt.stopPropagation();
         _roomMgr.forceStopMovement();
         if(Boolean(_avtSwitcher))
         {
            _avtSwitcher.destroy();
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/avatarSwitch");
         _avtSwitcher = new AvatarSwitcher();
         _avtSwitcher.init(guiLayer,onAvtSwitchClose,false,false);
      }
      
      private static function onPetSwapBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(GuiManager.isBeYourPetRoom())
         {
            if(Boolean(_petInventory))
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
         var pAvtWorldView:AvatarWorldView = AvatarManager.playerAvatarWorldView;
         if(Boolean(pAvtWorldView))
         {
            pAvtWorldView.setPos(pAvtWorldView.x,pAvtWorldView.y,false);
            pAvtWorldView.updateChatBallonBgOffsets();
            if(!pAvtWorldView.isActivePetGroundPet())
            {
               actionMgr.grayOutPetDanceBtn(true);
            }
            else
            {
               actionMgr.grayOutPetDanceBtn(false);
            }
            _roomMgr.rebuildGrid();
            if(Boolean(RoomManagerWorld.instance.collisionTestGrid(pAvtWorldView.x,pAvtWorldView.y)))
            {
               _roomMgr.teleportPlayerToDefault();
            }
         }
      }
      
      public static function switchToOceanAnimal(obj:Object) : void
      {
         if(Boolean(obj.status))
         {
            if(Boolean(mainHud.swapBtn) && Boolean(mainHud.swapBtn.isGray) || RoomXtCommManager.isSwitching)
            {
               return;
            }
            if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(switchToOceanAnimal,obj);
               return;
            }
            _roomMgr.forceStopMovement();
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/noOceanAnimal");
            _avtSwitcher = new AvatarSwitcher();
            _avtSwitcher.init(guiLayer,onAvtSwitchClose,false,true,obj.passback);
         }
      }
      
      public static function openAvatarChoose() : void
      {
         if(Boolean(_avtSwitcher))
         {
            _avtSwitcher.destroy();
         }
         _avtSwitcher = new AvatarSwitcher();
         _avtSwitcher.init(guiLayer,chooseAvatarCloseCallback,true,false);
      }
      
      public static function openDenRoomSwitcher(isRecycling:Boolean = false, closeCallback:Function = null, openStoreOnly:Boolean = false, openIdx:int = -1, openGLId:int = -1, shopItemIndex:int = -1) : void
      {
         if(Boolean(_denSwitcher))
         {
            _denSwitcher.destroy();
         }
         if(!isRecycling)
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/denSwitch");
         }
         if(closeCallback == null)
         {
            closeCallback = onDenSwitchClose;
         }
         _denSwitcher = new DenSwitcher();
         _denSwitcher.init(AvatarManager.playerAvatar,guiLayer,isRecycling,openStoreOnly,closeCallback,openIdx,openGLId,shopItemIndex,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      public static function get denSwitcherCurrentIndex() : int
      {
         if(Boolean(_denSwitcher))
         {
            return _denSwitcher.idx;
         }
         return -1;
      }
      
      public static function showDenSwitcher(show:Boolean) : void
      {
         if(Boolean(_denSwitcher))
         {
            _denSwitcher.showDenSwitcher(show);
         }
      }
      
      public static function updateDenRoomCount(count:int, entering:Boolean, userNameEnteringLeaving:String) : void
      {
         if(userNameEnteringLeaving == gMainFrame.userInfo.myUserName)
         {
            if(entering)
            {
               count--;
            }
         }
         else if(denEditor != null)
         {
            count--;
         }
         if(Boolean(mainHud.denCount))
         {
            if(count > 0)
            {
               if(_currentDenRoomCount < count)
               {
                  GuiManager.startDenBtnGlow();
                  if(!Utility.isSettingOn(MySettings.SETTINGS_DOOR_BELL))
                  {
                     AJAudio.playDoorBellSound();
                  }
               }
               mainHud.denCount.denCountTxt.text = count;
               mainHud.denCount.visible = true;
            }
            else
            {
               mainHud.denCount.visible = false;
            }
         }
         _currentDenRoomCount = count;
      }
      
      private static function chooseAvatarCloseCallback() : void
      {
         if(Boolean(_avtSwitcher))
         {
            _avtSwitcher.destroy();
            _avtSwitcher = null;
         }
         _demotionMessage.hasChosen = true;
         _demotionMessage.goToNextPage();
      }
      
      private static function onSoundBtnClickHandler(evt:MouseEvent) : void
      {
         SBAudio.toggleMuteAll();
         toggleMuteVideo();
         if(Boolean(_mySettings))
         {
            _mySettings.updateSoundBtn();
         }
      }
      
      public static function updateSettingsMessage() : void
      {
         if(Boolean(_mySettings))
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
      
      public static function depressSoundButton(depress:Boolean) : void
      {
         if(depress)
         {
            mainHud.soundBtn.upToDownState();
         }
         else
         {
            mainHud.soundBtn.downToUpState();
         }
      }
      
      private static function onAwardsBtnClickHandler(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.isGray)
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
      
      public static function onPartyBtn(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(!mainHud.partyBtn.isGray)
         {
            if(!evt)
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
            if(Boolean(mainHud.partyBtn.glow.visible))
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
      
      public static function showPartyBtnGlow(show:Boolean) : void
      {
         if(Boolean(mainHud.partyBtn) && !mainHud.partyBtn.isGray)
         {
            if(gMainFrame.userInfo.firstFiveMinutes > 0)
            {
               mainHud.partyBtn.glow.visible = show;
            }
         }
      }
      
      private static function onGemsBtnRollOverHandler(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.isGray)
         {
            toolTipBigGems.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.gemCount),evt.currentTarget.x + mainHud.x + evt.currentTarget.mouse.width + 65,evt.currentTarget.y + 5,false);
            if(gMainFrame.clientInfo.ticketCount > 0)
            {
               evt.currentTarget.mouse.itemHitArea.visible = true;
               evt.currentTarget.mouse.tickets.visible = true;
               evt.currentTarget.mouse.itemHitArea.height = 50;
               toolTipBigTickets.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.ticketCount),evt.currentTarget.x + mainHud.x + evt.currentTarget.mouse.width + 65,evt.currentTarget.y + 48,false);
               toolTipBigTickets.startTimer(evt);
            }
            else
            {
               evt.currentTarget.mouse.itemHitArea.visible = false;
               evt.currentTarget.mouse.tickets.visible = false;
            }
            evt.currentTarget.mouse.orb.visible = false;
            evt.currentTarget.mouse.orbTicketSpot.visible = false;
            if(gMainFrame.clientInfo.diamondCount > 0)
            {
               evt.currentTarget.mouse.itemHitArea.visible = true;
               if(gMainFrame.clientInfo.ticketCount > 0)
               {
                  evt.currentTarget.mouse.diamondTicketSpot.visible = false;
                  evt.currentTarget.mouse.itemHitArea.height = 100;
                  evt.currentTarget.mouse.diamondOrbSpot.visible = true;
                  evt.currentTarget.mouse.diamond.visible = false;
                  toolTipBigDiamonds.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.diamondCount),evt.currentTarget.x + mainHud.x + evt.currentTarget.mouse.width + 65,evt.currentTarget.y + 100,false);
               }
               else
               {
                  evt.currentTarget.mouse.itemHitArea.height = 50;
                  evt.currentTarget.mouse.diamondTicketSpot.visible = true;
                  evt.currentTarget.mouse.diamondOrbSpot.visible = false;
                  evt.currentTarget.mouse.diamond.visible = false;
                  toolTipBigDiamonds.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.diamondCount),evt.currentTarget.x + mainHud.x + evt.currentTarget.mouse.width + 65,evt.currentTarget.y + 49,false);
               }
               toolTipBigDiamonds.startTimer(evt);
            }
            else
            {
               evt.currentTarget.mouse.diamondTicketSpot.visible = false;
               evt.currentTarget.mouse.diamondOrbSpot.visible = false;
               evt.currentTarget.mouse.diamond.visible = false;
            }
            if(PartyManager.visible)
            {
               PartyManager.bringToFront();
            }
            toolTipBigGems.startTimer(evt);
         }
      }
      
      private static function onGemsBtnRollOutHandler(evt:MouseEvent) : void
      {
         evt.currentTarget.mouse.itemHitArea.visible = false;
         toolTipBigGems.visible = false;
         toolTipBigTickets.visible = false;
         toolTipBigDiamonds.visible = false;
      }
      
      private static function onMySettingsBtnClickHandler(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.isGray)
         {
            if(_mySettings != null)
            {
               _mySettings.destroy();
               _mySettings = null;
            }
            else
            {
               if(Boolean(_reportAPlayer))
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
      
      private static function onReportBtnClickHandler(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.isGray)
         {
            if(Boolean(_reportAPlayer))
            {
               _reportAPlayer.destroy();
               _reportAPlayer = null;
            }
            else
            {
               if(Boolean(_mySettings))
               {
                  _mySettings.destroy();
                  _mySettings = null;
                  mainHud.mySettingsBtn.downToUpState();
               }
               _reportAPlayer = new ReportAPlayer();
               _reportAPlayer.init(guiLayer,onReportAPlayerClose,false,null,null,756,130);
            }
         }
      }
      
      public static function displayRulesPopup(visible:Boolean, closeCallback:Function = null) : void
      {
         if(visible)
         {
            if(Boolean(_rulesPopup))
            {
               _rulesPopup.destroy();
               _rulesPopup = null;
            }
            _rulesPopup = new SBPopup(guiLayer,GETDEFINITIONBYNAME("ReportRulesPopupSkin"),GETDEFINITIONBYNAME("ReportRulesPopupContent"),true,true,false,false,true);
            _rulesPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _rulesPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            if(closeCallback != null)
            {
               _rulesPopup.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,closeCallback,false,0,true);
            }
         }
         else if(Boolean(_rulesPopup))
         {
            _rulesPopup.destroy();
            _rulesPopup = null;
         }
      }
      
      public static function openJammerCentral() : void
      {
         if(Boolean(_jammerCentral))
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
         if(Boolean(_jammerCentral))
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
      
      private static function onLionMediaLoaded(img:MovieClip) : void
      {
         var lionAvt:Avatar = null;
         var tempItems:Array = null;
         var temp:Item = null;
         var lionAvtView:AvatarView = null;
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(img))
         {
            _lionFoundPopup = MovieClip(img.getChildAt(0));
            _lionFoundPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _lionFoundPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            guiLayer.addChild(_lionFoundPopup);
            DarkenManager.darken(_lionFoundPopup);
            _lionFoundPopup.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
            _lionFoundPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,closeLionPopup,false,0,true);
            _lionFoundPopup.oopsPopup.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
            _lionFoundPopup.oopsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,closeLionOopsPopup,false,0,true);
            _lionFoundPopup.donateBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLionDonateBtn,false,0,true);
            lionAvt = new Avatar();
            lionAvt.init(-1,"Lion King",17,[388317183,117440512,83836927],null,"Lion King");
            tempItems = [];
            temp = new Item();
            tempItems[0] = temp;
            temp.init(1,1,0,-1,-1);
            temp = new Item();
            tempItems[1] = temp;
            temp.init(4,2,0,-1,-1);
            lionAvt.itemResponseIntegrate(tempItems);
            lionAvtView = new AvatarView();
            lionAvtView.init(lionAvt,null);
            lionAvtView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
            lionAvtView.x = 140;
            lionAvtView.y = 60;
            _lionFoundPopup.amlBG.amlMask.amlBox.addChild(lionAvtView);
            _lionFoundPopup.oopsPopup.visible = false;
         }
      }
      
      private static function closeLionPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(_lionFoundPopup);
         guiLayer.removeChild(_lionFoundPopup);
         _lionFoundPopup = null;
      }
      
      private static function closeLionOopsPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         _lionFoundPopup.oopsPopup.visible = false;
      }
      
      private static function onLionDonateBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function onLionCurrencyCheck(success:Boolean) : void
      {
         if(!success)
         {
            if(Boolean(_lionFoundPopup))
            {
               _lionFoundPopup.oopsPopup.visible = true;
            }
         }
      }
      
      private static function denBtnMouseDownHandler(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.isGray)
         {
            evt.currentTarget.downToUpState();
            evt.stopPropagation();
            DarkenManager.showLoadingSpiral(true);
            DenXtCommManager.requestDenJoinFull("den" + gMainFrame.userInfo.myUserName);
            mainHud.denBtn.downToUpState();
         }
      }
      
      public static function onExitRoom(isBuddyList:Boolean = false) : void
      {
         if(!isBuddyList)
         {
            BuddyList.closeBuddyList();
         }
         NGFactManager.closeFact();
         if(!isBuddyList)
         {
            if(_mySettings != null)
            {
               _mySettings.destroy();
               _mySettings = null;
               mainHud.mySettingsBtn.downToUpState();
            }
            if(Boolean(_reportAPlayer))
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
         if(Boolean(_videoPlayer))
         {
            _videoPlayer.destroy();
            _videoPlayer = null;
         }
         if(PartyManager.visible)
         {
            PartyManager.close();
         }
         if(Boolean(_pageFlip))
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
         if(Boolean(_avEditor))
         {
            _avEditor.destroy();
            _avEditor = null;
         }
         if(Boolean(chatHist))
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
         if(Boolean(_avEditor))
         {
            TradeManager.resetNumTradeItems(_avEditor.numClothingItemsInTradeListInitially,_avEditor.numDenItemsInTradeListInitially);
            _avEditor.destroy();
            _avEditor = null;
         }
         if(Boolean(_roomMgr))
         {
            _roomMgr.onRecycleClose();
         }
         if(Boolean(denEditor))
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
         if(Boolean(_reportAPlayer))
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
         if(Boolean(denEditor))
         {
            denEditor.resetPetWindowList();
         }
      }
      
      public static function refreshDenLockSettings() : void
      {
         if(Boolean(denEditor))
         {
            denEditor.refreshDenLockSettings();
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
         var dailyGemVarValue:int = 0;
         if(Boolean(_pageFlip))
         {
            SBTracker.pop();
            _pageFlip.destroy();
            _pageFlip = null;
         }
         if(!_newsOpenedFromBtn && !_hasClosedGemBonus)
         {
            dailyGemVarValue = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_DAILY_GEM_BONUS));
            if(dailyGemVarValue == -1 || (dailyGemVarValue & 0xFFFF) < gMainFrame.clientInfo.jamaaDate)
            {
               DarkenManager.showLoadingSpiral(true);
               if(gMainFrame.clientInfo.dailyGiftIndex >= 0 && gMainFrame.clientInfo.dailyGiftIndex < DAILY_GIFT_NUM_DAYS)
               {
                  openDailyGift(gMainFrame.clientInfo.dailyGiftIndex);
               }
               else
               {
                  openGemBonusWheel(dailyGemVarValue);
               }
            }
         }
      }
      
      public static function openDailyGift(dailyIndex:int) : void
      {
         if(Boolean(_dailyGiftManager))
         {
            _dailyGiftManager.destroy();
            _dailyGiftManager = null;
         }
         DarkenManager.showLoadingSpiral(true);
         _dailyGiftManager = new DailyGiftManager();
         _dailyGiftManager.init(dailyIndex,onDailyGiftClose);
      }
      
      private static function onDailyGiftClose() : void
      {
         _dailyGiftManager.destroy();
         _dailyGiftManager = null;
      }
      
      public static function openMuseumDonation() : void
      {
         if(Boolean(_museumDonation))
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
      
      public static function openGemBonusWheel(dailyGemVarValue:int) : void
      {
         if(Boolean(_gemBonusWheel))
         {
            _gemBonusWheel.destroy();
            _gemBonusWheel = null;
         }
         _gemBonusWheel = new GemBonusSpinWheel();
         _gemBonusWheel.init(dailyGemVarValue,onGemBonusClose);
      }
      
      public static function setGemBonusValues(value:int) : void
      {
         if(Boolean(_gemBonusWheel))
         {
            _gemBonusWheel.setupValuesAndSpin(value);
         }
      }
      
      private static function onGemBonusClose() : void
      {
         _gemBonusWheel.destroy();
         _gemBonusWheel = null;
         _hasClosedGemBonus = true;
      }
      
      public static function onEBookClose() : void
      {
         if(Boolean(_pageFlip))
         {
            SBTracker.pop();
            _pageFlip.destroy();
            _pageFlip = null;
         }
      }
      
      public static function onAvtSwitchClose() : void
      {
         SBTracker.pop();
         if(Boolean(_avtSwitcher))
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
         if(Boolean(_avtSwitcher))
         {
            _avtSwitcher.destroy();
            _avtSwitcher = null;
         }
      }
      
      public static function onDenSwitchClose(isRecycling:Boolean = false) : void
      {
         if(!isRecycling)
         {
            SBTracker.pop();
         }
         if(Boolean(_denSwitcher))
         {
            _denSwitcher.destroy();
            _denSwitcher = null;
         }
      }
      
      public static function onMySettingsClose() : void
      {
         if(Boolean(_mySettings))
         {
            mainHud.mySettingsBtn.downToUpState();
            _mySettings.destroy();
            _mySettings = null;
         }
      }
      
      public static function onReportAPlayerClose(hasReported:Boolean) : void
      {
         if(Boolean(_reportAPlayer))
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
         if(Boolean(_imageDisplayPopup))
         {
            _imageDisplayPopup.destroy();
         }
         _imageDisplayPopup = new ImageDisplayPopup(onImageDisplayClose,189,372);
      }
      
      private static function onImageDisplayClose() : void
      {
         if(Boolean(_imageDisplayPopup))
         {
            _imageDisplayPopup.destroy();
            _imageDisplayPopup = null;
         }
      }
      
      private static function onDiamondInfoLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _diamondShopInfoPopup = MovieClip(img.getChildAt(0));
         _diamondShopInfoPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
         _diamondShopInfoPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondInfoClose,false,0,true);
         _diamondShopInfoPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         _diamondShopInfoPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         guiLayer.addChild(_diamondShopInfoPopup);
         DarkenManager.darken(_diamondShopInfoPopup);
      }
      
      private static function onDiamondInfoClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(_diamondShopInfoPopup);
         guiLayer.removeChild(_diamondShopInfoPopup);
      }
      
      private static function mainHudMouseDownHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,clickedOutsideChatCui,false,0,true);
      }
      
      private static function charWindowDownHandler(evt:MouseEvent) : void
      {
         var gameObj:Object = null;
         if(!evt.currentTarget.isGray)
         {
            evt.stopPropagation();
            if(!RoomXtCommManager.isSwitching && !QuestManager.isInPrivateAdventureState)
            {
               if(isBeYourPetRoom())
               {
                  DarkenManager.showLoadingSpiral(false);
                  gameObj = {"typeDefId":52};
                  MinigameManager.handleGameClick(gameObj,null,false,showHudAvt);
               }
               else
               {
                  openAvatarEditor();
               }
               toolTip.resetTimerAndSetVisibility();
               if(Boolean(mainHud.charHelp))
               {
                  mainHud.charHelp.visible = false;
               }
            }
         }
      }
      
      public static function openPhotoBooth() : void
      {
         if(Boolean(_photoBooth))
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
      
      public static function openAvatarEditor(callback:Function = null) : void
      {
         _avEditorCloseCallback = callback;
         if(Boolean(_avEditor))
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
         if(Boolean(_avEditor))
         {
            _avEditor.openRecycle();
         }
      }
      
      public static function openAvatarCreator(isChoosingOceanAvatars:Boolean, isChoosing:Boolean, avatarTypeToShow:int = -1, skipToNameScreen:Boolean = false, currencyType:int = 0, specialValue:int = -1) : void
      {
         if(Boolean(_avatarCreator))
         {
            guiLayer.removeChild(_avatarCreator);
            _avatarCreator.destroy();
         }
         _avatarCreator = new GuiAvatarCreationAssets();
         _avatarCreator.initFromWorld(isChoosingOceanAvatars,isChoosing,avatarTypeToShow,skipToNameScreen,currencyType,specialValue);
         guiLayer.addChild(_avatarCreator);
      }
      
      public static function closeAvatarCreator() : void
      {
         if(Boolean(_avatarCreator))
         {
            guiLayer.removeChild(_avatarCreator);
            _avatarCreator.destroy();
            _avatarCreator = null;
         }
      }
      
      public static function openTutorialTextPopup(message:String, x:int, y:int) : void
      {
         if(Boolean(_tutorialTextPopup))
         {
            _tutorialTextPopup.x = x;
            _tutorialTextPopup.y = y;
            _tutorialTextPopup.message_txt.text = message;
            _tutorialTextPopup.balloon_bg.m.height = Math.floor(_tutorialTextPopup.message_txt.height + 10);
            _tutorialTextPopup.balloon_bg.b.y = Math.round(_tutorialTextPopup.balloon_bg.m.y + _tutorialTextPopup.balloon_bg.m.height);
         }
         else
         {
            _tutorialMediaHelper = new MediaHelper();
            _tutorialMediaHelper.init(2875,onTutorialLoaded,{
               "message":message,
               "x":x,
               "y":y
            });
         }
      }
      
      public static function closeTutorialTextPopup() : void
      {
         if(Boolean(_tutorialTextPopup))
         {
            guiLayer.removeChild(_tutorialTextPopup);
            _tutorialTextPopup = null;
         }
      }
      
      private static function onTutorialLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _tutorialTextPopup = MovieClip(img.getChildAt(0));
            _tutorialTextPopup.x = img.passback.x;
            _tutorialTextPopup.y = img.passback.y;
            _tutorialTextPopup.message_txt.autoSize = TextFieldAutoSize.CENTER;
            _tutorialTextPopup.message_txt.text = img.passback.message;
            _tutorialTextPopup.balloon_bg.m.height = Math.floor(_tutorialTextPopup.message_txt.height + 10);
            _tutorialTextPopup.balloon_bg.b.y = Math.round(_tutorialTextPopup.balloon_bg.m.y + _tutorialTextPopup.balloon_bg.m.height);
            guiLayer.addChild(_tutorialTextPopup);
            _tutorialMediaHelper.destroy();
            _tutorialMediaHelper = null;
         }
      }
      
      public static function openTalkingTutorial(message:String, titleTxt:String, x:int, y:int, buttonToTurnOn:MovieClip, layerToTurnOn:MovieClip = null) : void
      {
         if(Boolean(_talkingTutorialPopup))
         {
            if(x != -1)
            {
               _talkingTutorialPopup.x = x;
            }
            if(y != -1)
            {
               _talkingTutorialPopup.y = y;
            }
            _talkingTutorialPopup.cont.popupCont.txt.text = message;
            _talkingTutorialPopup.cont.popupCont.bg.m.height = Math.floor(_talkingTutorialPopup.cont.popupCont.txt.textHeight + 6);
            _talkingTutorialPopup.cont.popupCont.bg.b.y = Math.floor(_talkingTutorialPopup.cont.popupCont.bg.m.y + _talkingTutorialPopup.cont.popupCont.bg.m.height);
            _talkingTutorialPopup.buttonToTurnOn = buttonToTurnOn;
            _talkingTutorialPopup.layerToTurnOn = layerToTurnOn;
            if(titleTxt != "")
            {
               _talkingTutorialPopup.cont.popupCont.talkingHeadTitleTxt.text = titleTxt;
            }
            if(_talkingTutorialPopup.cont.currentFrameLabel != "closed")
            {
               _talkingTutorialPopup.cont.gotoAndStop("closed");
            }
            if(_talkingTutorialTimer == null)
            {
               _talkingTutorialTimer = new Timer(1000);
               _talkingTutorialTimer.addEventListener(TimerEvent.TIMER,onTalkingTutorialTimerComplete,false,0,true);
            }
            if(Boolean(_talkingTutorialPopup.talkingHead))
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndStop(1);
            }
            _talkingTutorialTimer.reset();
            _talkingTutorialTimer.start();
         }
         else
         {
            _tutorialMediaHelper = new MediaHelper();
            _tutorialMediaHelper.init(2872,onTalkingTutorialLoaded,{
               "message":message,
               "titleTxt":titleTxt,
               "x":x,
               "y":y,
               "buttonToTurnOn":buttonToTurnOn,
               "layerToTurnOn":layerToTurnOn
            });
         }
      }
      
      private static function onTalkingTutorialTimerComplete(t:TimerEvent) : void
      {
         if(Boolean(_talkingTutorialPopup))
         {
            if(_talkingTutorialPopup.cont.currentFrameLabel == "closed")
            {
               _talkingTutorialPopup.cont.gotoAndPlay("opening");
               if(Boolean(_talkingTutorialPopup.talkingHead))
               {
                  _talkingTutorialPopup.talkingHead.NPC.gotoAndPlay(1);
               }
               _talkingTutorialPopup.lizaHeadFrameHolder.glow.visible = false;
            }
            if(Boolean(_talkingTutorialPopup.buttonToTurnOn))
            {
               _talkingTutorialPopup.buttonToTurnOn.setButtonState(2);
            }
            if(Boolean(_talkingTutorialPopup.layerToTurnOn))
            {
               _talkingTutorialPopup.layerToTurnOn.visible = true;
            }
            _talkingTutorialTimer.reset();
         }
      }
      
      private static function onTalkingTutorialLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _talkingTutorialPopup = MovieClip(img.getChildAt(0));
            _talkingTutorialPopup.scaleX = 0.7;
            _talkingTutorialPopup.scaleY = 0.7;
            _talkingTutorialPopup.x = img.passback.x;
            _talkingTutorialPopup.y = img.passback.y;
            _talkingTutorialPopup.addEventListener(MouseEvent.MOUSE_DOWN,onTutorialPopup,false,0,true);
            _talkingTutorialPopup.cont.popupCont.bx.addEventListener(MouseEvent.MOUSE_DOWN,onTutorialPopup,false,0,true);
            _talkingTutorialPopup.cont.popupCont.txt.autoSize = TextFieldAutoSize.CENTER;
            _talkingTutorialPopup.cont.popupCont.txt.text = img.passback.message;
            _talkingTutorialPopup.cont.popupCont.bg.m.height = Math.floor(_talkingTutorialPopup.cont.popupCont.txt.textHeight + 6);
            _talkingTutorialPopup.cont.popupCont.bg.b.y = Math.floor(_talkingTutorialPopup.cont.popupCont.bg.m.y + _talkingTutorialPopup.cont.popupCont.bg.m.height);
            _talkingTutorialPopup.cont.popupCont.talkingHeadTitleTxt.text = img.passback.titleTxt;
            _talkingTutorialPopup.lizaHeadFrameHolder.glow.visible = false;
            _talkingTutorialPopup.buttonToTurnOn = img.passback.buttonToTurnOn;
            _talkingTutorialPopup.layerToTurnOn = img.passback.layerToTurnOn;
            _talkingLoadingSpiral = new LoadingSpiral(_talkingTutorialPopup.itemRenderPlaceholder.itemWindow,_talkingTutorialPopup.itemRenderPlaceholder.itemWindow.width * 0.5,_talkingTutorialPopup.itemRenderPlaceholder.itemWindow.height * 0.5);
            _tutorialMediaHelper = new MediaHelper();
            _tutorialMediaHelper.init(1877,onTalkingHeadMediaLoaded);
            _talkingTutorialPopup.cont.gotoAndPlay("opening");
            guiLayer.addChild(_talkingTutorialPopup);
            if(_talkingTutorialPopup.cont.currentFrameLabel != "closed")
            {
               _talkingTutorialPopup.cont.gotoAndStop("closed");
            }
            if(_talkingTutorialTimer == null)
            {
               _talkingTutorialTimer = new Timer(1000);
               _talkingTutorialTimer.addEventListener(TimerEvent.TIMER,onTalkingTutorialTimerComplete,false,0,true);
            }
            _talkingTutorialTimer.reset();
            _talkingTutorialTimer.start();
         }
      }
      
      private static function onTalkingHeadMediaLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            if(_talkingTutorialPopup != null)
            {
               _talkingTutorialPopup.talkingHead = img.getChildAt(0);
               _talkingTutorialPopup.itemRenderPlaceholder.itemWindow.addChild(img);
               _talkingLoadingSpiral.visible = false;
               if(Boolean(_tutorialMediaHelper))
               {
                  _tutorialMediaHelper.destroy();
                  _tutorialMediaHelper = null;
               }
               _talkingTutorialPopup.talkingHead.NPC.gotoAndStop(0);
            }
         }
      }
      
      private static function onTutorialPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(_talkingTutorialPopup.cont.currentFrameLabel == "closed")
         {
            _talkingTutorialPopup.cont.gotoAndPlay("opening");
            if(Boolean(_talkingTutorialPopup.talkingHead))
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndPlay(1);
            }
            _talkingTutorialPopup.lizaHeadFrameHolder.glow.visible = false;
            if(Boolean(_talkingTutorialPopup.buttonToTurnOn))
            {
               _talkingTutorialPopup.buttonToTurnOn.setButtonState(2);
            }
            if(Boolean(_talkingTutorialPopup.layerToTurnOn))
            {
               _talkingTutorialPopup.layerToTurnOn.visible = true;
            }
         }
         else
         {
            _talkingTutorialPopup.cont.gotoAndPlay("closing");
            if(Boolean(_talkingTutorialPopup.talkingHead))
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndStop(1);
            }
            _talkingTutorialPopup.lizaHeadFrameHolder.glow.visible = true;
            if(Boolean(_talkingTutorialPopup.buttonToTurnOn))
            {
               _talkingTutorialPopup.buttonToTurnOn.setButtonState(1);
            }
            if(Boolean(_talkingTutorialPopup.layerToTurnOn))
            {
               _talkingTutorialPopup.layerToTurnOn.visible = false;
            }
         }
      }
      
      public static function closeTalkingTutorialPopup() : void
      {
         if(Boolean(_talkingTutorialPopup))
         {
            if(Boolean(_tutorialMediaHelper))
            {
               _tutorialMediaHelper.destroy();
               _tutorialMediaHelper = null;
            }
            guiLayer.removeChild(_talkingTutorialPopup);
            _talkingTutorialPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onTutorialPopup);
            _talkingTutorialPopup.cont.popupCont.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onTutorialPopup);
            _talkingTutorialPopup = null;
            if(Boolean(_talkingTutorialTimer))
            {
               _talkingTutorialTimer.reset();
               _talkingTutorialTimer = null;
            }
         }
      }
      
      public static function onEnterRoom(roomType:int) : void
      {
         var bShowQuestHud:Boolean = false;
         var questScriptDef:Object = null;
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
         if(mainHud.currentFrame != roomType + 1 || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            bShowQuestHud = false;
            if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && QuestManager._questScriptDefId != 0)
            {
               questScriptDef = QuestXtCommManager.getScriptDef(QuestManager._questScriptDefId);
               if(questScriptDef != null && questScriptDef.hudType == 0)
               {
                  bShowQuestHud = true;
               }
            }
            if(bShowQuestHud)
            {
               if(mainHud.currentFrameLabel != "quest")
               {
                  enableGameHud(true,"quest");
               }
            }
            else
            {
               if(mainHud.currentFrameLabel == "quest")
               {
                  enableGameHud(false);
               }
               mainHud.gotoAndStop(roomType + 1);
               mainHud.chat.chatHistoryBG.chatHistBox.hud01_chatHistory.gotoAndStop(roomType + 1);
               if(Boolean(chatHist))
               {
                  chatHist.clearChat();
               }
            }
            actionMgr.turnOnOceanActions(roomType == Utility.ENVIRO_OCEAN);
         }
         if(GuiManager.isBeYourPetRoom())
         {
            if(Boolean(mainHud.swapBtn))
            {
               mainHud.swapBtn.visible = false;
            }
            actionMgr.turnOnPetActions(true);
         }
         else
         {
            if(Boolean(mainHud.swapBtn))
            {
               mainHud.swapBtn.visible = true;
            }
            actionMgr.turnOnPetActions(false);
         }
      }
      
      public static function setFocusToChatText() : void
      {
         if(Boolean(chatHist))
         {
            chatHist.setFocusOnMsgText();
         }
      }
      
      public static function showHudAvt() : void
      {
         var myPet:Object = null;
         var avt:Avatar = null;
         while(mainHud.charWindow.charLayer.numChildren > 0)
         {
            mainHud.charWindow.charLayer.removeChildAt(0);
         }
         if(GuiManager.isBeYourPetRoom())
         {
            myPet = PetManager.myActivePet;
            if(Boolean(myPet))
            {
               new GuiPet(myPet.idx,myPet.lBits,myPet.uBits,myPet.eBits,myPet.type,myPet.name,onBigPetLoaded);
            }
         }
         else
         {
            avt = AvatarManager.playerAvatar;
            if(Boolean(_hudAvtView))
            {
               if(_hudAvtView.parent == mainHud.charWindow.charLayer)
               {
                  mainHud.charWindow.charLayer.removeChild(_hudAvtView);
               }
               _hudAvtView.destroy();
            }
            _hudAvtView = new AvatarView();
            _hudAvtView.init(avt);
            _hudAvtView.playAnim(LayerAnim.AN_HUD_AVT,false,LayerAnim.PLAY_ONE_SHOT,null);
            positionHudAvatar();
            mainHud.charWindow.charLayer.addChild(_hudAvtView);
         }
         if(mainHud.currentFrameLabel != "quest")
         {
            mainHud.text01_charName.text = gMainFrame.userInfo.userNameModerated;
         }
      }
      
      public static function grayHudAvatar(gray:Boolean) : void
      {
         if(Boolean(_hudAvtView))
         {
            if(gray)
            {
               _hudAvtView.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
            }
            else
            {
               _hudAvtView.filters = null;
            }
         }
      }
      
      private static function onBigPetLoaded(myPet:MovieClip, pet:GuiPet) : void
      {
         myPet.scaleX = myPet.scaleY = 1.7;
         myPet.y += mainHud.charWindow.mouse.height * 0.5 - 10;
         mainHud.charWindow.charLayer.addChild(myPet);
      }
      
      public static function positionHudAvatar() : void
      {
         var avatarOffset:Point = AvatarUtility.getAvatarHudPosition(_hudAvtView.avTypeId);
         _hudAvtView.x = avatarOffset.x;
         _hudAvtView.y = avatarOffset.y;
      }
      
      public static function activateDenHud(activate:Boolean) : void
      {
         if(Boolean(mainHud.denBtn))
         {
            mainHud.denBtn.removeEventListener(MouseEvent.MOUSE_DOWN,denBtnMouseDownHandler);
            mainHud.denBtn.visible = !activate;
         }
         if(!activate)
         {
            if(Boolean(mainHud.denBtn))
            {
               mainHud.denBtn.addEventListener(MouseEvent.MOUSE_DOWN,denBtnMouseDownHandler,false,0,true);
            }
            if(Boolean(denEditor))
            {
               denEditor.destroy();
               denEditor = null;
               mainHud.furnBtn.visible = false;
            }
            BuddyList.destroyInWorldBuddyList();
         }
         else
         {
            if(Boolean(denEditor))
            {
               denEditor.destroy();
               denEditor = null;
            }
            denEditor = new DenEditor();
            denEditor.init(AvatarManager.playerAvatar,guiLayer,mainHud);
         }
      }
      
      public static function showDenHudItems(show:Boolean) : void
      {
         if(Boolean(denEditor))
         {
            denEditor.toggleEditorHud(show);
         }
      }
      
      public static function onPetsChanged() : void
      {
         if(Boolean(denEditor))
         {
            denEditor.reloadDenItems();
         }
      }
      
      public static function onToggleDenLock(callback:Function) : void
      {
         if(Boolean(denEditor))
         {
            if(Boolean(denEditor))
            {
               denEditor.openDenLockPopup(callback);
               return;
            }
         }
         callback();
      }
      
      public static function clickedOutsideChatCui(evt:MouseEvent) : void
      {
         if(!mainHud.contains(DisplayObject(evt.target)))
         {
            if(Boolean(mainHud.safeChatTreeWindow.visible))
            {
               mainHud.safeChatTreeWindow.visible = false;
            }
            if(Boolean(mainHud.emotesWindow.visible))
            {
               mainHud.emotesWindow.visible = false;
            }
            if(Boolean(mainHud.actionsWindow.visible))
            {
               mainHud.actionsWindow.visible = false;
            }
         }
         gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_UP,clickedOutsideChatCui);
      }
      
      public static function onEmoteClick(emote:Sprite) : void
      {
         UserCommXtCommManager.sendAvatarEmote(emote);
      }
      
      public static function resizeHudZoneNameBar(zoneNameBar:MovieClip) : void
      {
         zoneNameBar.mouse.name_txt.width = zoneNameBar.mouse.name_txt.textWidth + 5;
         zoneNameBar.mouse.mid.width = zoneNameBar.mouse.name_txt.textWidth + 5 + 0.5 * zoneNameBar.mouse.left.width;
         zoneNameBar.mouse.mid.x = zoneNameBar.mouse.right.x - zoneNameBar.mouse.mid.width + 1;
         zoneNameBar.mouse.left.x = zoneNameBar.mouse.mid.x - 0.5 * zoneNameBar.mouse.left.width;
         zoneNameBar.mouse.name_txt.x = zoneNameBar.mouse.mid.x + 12;
      }
      
      private static function layerGuiMouseDownHandler(evt:MouseEvent) : void
      {
         if(!mainHud.contains(DisplayObject(evt.target)))
         {
            if(Boolean(mainHud.safeChatTreeWindow.visible))
            {
               mainHud.safeChatBtn.dispatchEvent(evt);
            }
            if(Boolean(mainHud.emotesWindow.visible))
            {
               mainHud.emotesBtn.dispatchEvent(evt);
            }
            if(Boolean(mainHud.actionsWindow.visible))
            {
               mainHud.actionsBtn.dispatchEvent(evt);
            }
         }
      }
      
      private static function layerBkgMouseUpHandler(evt:MouseEvent) : void
      {
         if(Boolean(chatHist))
         {
            chatHist.setFocusOnMsgText();
         }
      }
      
      public static function setRoomNameDisplay(newRoomDisplayName:String, newRoomDisplayNameId:int) : void
      {
         var regEx:RegExp = null;
         var split:Array = null;
         var ui:UserInfo = null;
         _currRoomDisplayName = newRoomDisplayName;
         _currRoomDisplayNameId = newRoomDisplayNameId;
         if(Boolean(mainHud.zoneNameTxt))
         {
            if(newRoomDisplayName.indexOf(gMainFrame.userInfo.myUserName) == 0)
            {
               if(gMainFrame.clientInfo.userNameModerated == 0)
               {
                  regEx = new RegExp(gMainFrame.userInfo.myUserName,"gi");
                  _currRoomDisplayNameModeratedLocalized = _currRoomDisplayName.replace(regEx,LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               }
               else
               {
                  _currRoomDisplayNameModeratedLocalized = _currRoomDisplayNameId != 0 ? LocalizationManager.translateIdOnly(newRoomDisplayNameId) : _currRoomDisplayName;
               }
            }
            else
            {
               split = _currRoomDisplayName.split("\'");
               ui = gMainFrame.userInfo.getUserInfoByUserName(split[0]);
               if(Boolean(ui) && ui.userNameModeratedFlag == 0)
               {
                  if(split[1] != "s Den")
                  {
                     throw new Error("Expected different room name");
                  }
                  _currRoomDisplayNameModeratedLocalized = LocalizationManager.translateIdOnly(11138);
               }
               else
               {
                  _currRoomDisplayNameModeratedLocalized = _currRoomDisplayNameId != 0 ? LocalizationManager.translateIdOnly(newRoomDisplayNameId) : _currRoomDisplayName;
               }
            }
            mainHud.zoneNameTxt.text = _currRoomDisplayNameModeratedLocalized;
            resizeHudZoneNameBar(mainHud.zoneName);
         }
      }
      
      public static function handleMouseDown() : void
      {
         if(Boolean(chatHist))
         {
            chatHist.dimChat();
         }
         SafeChatManager.closeSafeChat();
         if(Boolean(actionMgr))
         {
            actionMgr.closeActions();
         }
         if(Boolean(emoteMgr))
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
      
      public static function addQuestXP(xpPercentage:Number) : void
      {
         if(Boolean(mainHud.xpMeter))
         {
            if(!isBeYourPetRoom())
            {
               mainHud.xpMeter.xpBar.visible = true;
               mainHud.xpMeter.xpBar.width = mainHud.xpMeter.xpBarContainer.width * (xpPercentage / 100);
            }
            else
            {
               mainHud.xpMeter.xpBar.visible = false;
            }
         }
      }
      
      public static function setQuestHearts(hpPercentage:Number) : void
      {
         var scriptDefId:int = 0;
         var questScriptDef:Object = null;
         var totalHearts:Number = NaN;
         var ai:AvatarInfo = null;
         if(Boolean(mainHud.heartWindow))
         {
            if(Boolean(_heartItemWindow))
            {
               if(Boolean(_heartItemWindow.parent) && _heartItemWindow.parent == mainHud.heartWindow)
               {
                  mainHud.heartWindow.removeChild(_heartItemWindow);
               }
               _heartItemWindow.destroy();
            }
            scriptDefId = QuestManager._questScriptDefId;
            questScriptDef = QuestXtCommManager.getScriptDef(QuestManager._questScriptDefId);
            totalHearts = 0;
            if(questScriptDef != null && Boolean(questScriptDef.playAsPet))
            {
               totalHearts = 1;
            }
            else
            {
               ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
               totalHearts = Math.round(ai.healthBase * 0.5);
            }
            _heartItemWindow = new WindowGenerator();
            _heartItemWindow.init(totalHearts,1,totalHearts,0,0,0,ItemWindowHeart,null,"",null,{"hpPercentage":hpPercentage},onHeartsLoaded,true,false);
            mainHud.heartWindow.addChild(_heartItemWindow);
         }
      }
      
      private static function onHeartsLoaded() : void
      {
         for(var i:int = 0; i < _heartItemWindow.bg.numChildren; i++)
         {
            MovieClip(_heartItemWindow.bg.getChildAt(i)).updateFrame();
         }
      }
      
      public static function updateXPShape(img:MovieClip) : void
      {
         var shape:MovieClip = null;
         if(Boolean(mainHud.xpLevelShape))
         {
            with(mainHud)
            {
               
               while(xpLevelShape.numChildren > 0)
               {
                  xpLevelShape.removeChildAt(0);
               }
               shape = MovieClip(img.getChildAt(0));
               if(Boolean(shape))
               {
                  shape.text.text = img.passback;
                  xpLevelShape.addChild(shape);
               }
            }
         }
      }
      
      public static function updateShapeXP(level:int) : void
      {
         var shape:MovieClip = null;
         if(Boolean(mainHud.xpLevelShape))
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
      
      public static function showDiamondConfirmation(cost:int, callback:Function) : void
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
         _diamondConfirmationPopup.callback = callback;
         _diamondConfirmationPopup.diamondTxt.text = Utility.convertNumberToString(cost);
         guiLayer.addChild(_diamondConfirmationPopup);
         DarkenManager.darken(_diamondConfirmationPopup);
      }
      
      public static function onMinimapBtn(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.isGray)
         {
            if(Boolean(mainHud.miniMap.visible))
            {
               mainHud.miniMap.visible = false;
            }
            else
            {
               if(Boolean(mainHud.playersCont.visible))
               {
                  mainHud.playersCont.visible = false;
                  mainHud.questPlayersBtn.downToUpState();
               }
               mainHud.miniMap.visible = true;
            }
         }
      }
      
      private static function onMinimapZoon(evt:MouseEvent) : void
      {
         if(evt.currentTarget.parent.currentFrameLabel == "small")
         {
            evt.currentTarget.parent.gotoAndStop("big");
            evt.currentTarget.mouse.plus.visible = false;
         }
         else
         {
            evt.currentTarget.parent.gotoAndStop("small");
            evt.currentTarget.mouse.plus.visible = true;
         }
      }
      
      private static function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function onDiamondConfBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(_diamondConfirmationPopup);
         guiLayer.removeChild(_diamondConfirmationPopup);
         if(evt.currentTarget.name == "buyBtn")
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
      
      private static function onMainHudOver(evt:MouseEvent) : void
      {
         QuestManager.updatePrivateAdventureIndexComparedToMainHud();
      }
      
      public static function safeChatBtnDownHandler(evt:MouseEvent) : void
      {
         if(!mainHud.safeChatBtn.isGray)
         {
            if(Boolean(mainHud.safeChatTreeWindow.visible))
            {
               SafeChatManager.closeSafeChat();
            }
            else
            {
               if(Boolean(mainHud.emotesWindow.visible))
               {
                  mainHud.emotesBtn.dispatchEvent(evt);
               }
               if(Boolean(mainHud.actionsWindow.visible))
               {
                  mainHud.actionsBtn.dispatchEvent(evt);
               }
               if(Boolean(evt))
               {
                  evt.stopPropagation();
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
      
      private static function namebarBadgeDefResponse(dfdh:DefPacksDefHelper) : void
      {
         var def:Object = null;
         var data:Object = null;
         for each(data in dfdh.def)
         {
            def = {
               "defId":int(data.id),
               "pendingFlagsBit":int(data.pendingFlagsBit),
               "mediaRefId":int(data.mediaRefId)
            };
            _namebarBadgeDefs[def.defId] = def;
         }
      }
      
      public static function loadNameBarBadgeList() : void
      {
         GenericListXtCommManager.requestGenericList(NAME_BAR_ICONS_LIST_ID,onNameBarListLoaded);
      }
      
      private static function onNameBarListLoaded(badgeDefIds:Array) : void
      {
         var badgeDef:Object = null;
         _namebarBadgeList = [];
         for(var i:int = 0; i < badgeDefIds.length; i++)
         {
            badgeDef = getNamebarBadgeDef(badgeDefIds[i]);
            if(badgeDef)
            {
               _namebarBadgeList[i] = badgeDef.mediaRefId;
            }
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
      
      public static function getNamebarBadgeDef(defId:int) : Object
      {
         return _namebarBadgeDefs[defId];
      }
      
      public static function enableGameHud(inEnable:Boolean, inGameHudName:String = null, gameCallbackHandler:Object = null) : void
      {
         var ai:AvatarInfo = null;
         if(Boolean(denEditor))
         {
            denEditor.destroy();
            denEditor = null;
         }
         if(inEnable)
         {
            volumeMgr.enable(false);
            removeListeners();
            _originalHudFrame = mainHud.currentFrame;
            mainHud.gotoAndStop(inGameHudName);
            (mainHud as GuiHud).init(true);
            addListeners();
            GuiManager.chatHist.toggleInGameHud(true);
            if(inGameHudName == "quest")
            {
               ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
               addQuestXP(ai.questXPPercentage);
               setQuestHearts(ai.questHealthPercentage);
               QuestManager.loadLevelShape(ai.questLevel);
               if(_needToRebuildMainHud)
               {
                  rebuildMainHud();
               }
               else
               {
                  chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,mainHud.predictTxtTagQuest,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow,false);
                  SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_ADVENTURE);
                  SafeChatManager.reload(false,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
                  actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
                  emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
                  setToolTipText();
               }
               setupSoundButton();
               GuiManager.mainHud.miniMap_btnQuest.upToDownState();
               mainHud.playersCont.visible = false;
               mainHud.miniMap.visible = true;
            }
            if(Boolean(gameCallbackHandler))
            {
               if(mainHud.combatCardDeckBtn != null)
               {
                  mainHud.combatCardDeckBtn.addEventListener(MouseEvent.MOUSE_DOWN,gameCallbackHandler.onCardDeckBtnClickHandler,false,0,true);
               }
            }
         }
         else if(_originalHudFrame != -1)
         {
            if(Boolean(gameCallbackHandler))
            {
               if(mainHud.combatCardDeckBtn != null)
               {
                  mainHud.combatCardDeckBtn.removeEventListener(MouseEvent.MOUSE_DOWN,gameCallbackHandler.onCardDeckBtnClickHandler);
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
               chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,mainHud.predictTxtTag,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow,false);
               SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_SAFECHAT);
               SafeChatManager.reload(false,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
               actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
               emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
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
            if(Boolean(mainHud.swapBtn.hasGrayState))
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
            mainHud.denCount.visible = false;
         }
         setRoomNameDisplay(_currRoomDisplayName,_currRoomDisplayNameId);
         setFocusToChatText();
         _needToRebuildMainHud = false;
      }
      
      public static function rebuildMainHud() : void
      {
         _needToRebuildMainHud = true;
         if(Boolean(chatHist))
         {
            (mainHud as GuiHud).init(true);
            chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,mainHud.predictTxtTag == null ? mainHud.predictTxtTagQuest : mainHud.predictTxtTag,mainHud.chatRepeatBtn,mainHud.chatRepeatWindow,true);
            SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_SAFECHAT);
            SafeChatManager.reload(true,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
            actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
            emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
            PartyManager.reload();
            if(Boolean(mainHud.worldMapBtn))
            {
               volumeMgr.enable(true,mainHud.worldMapBtn,mainHud.zoneName,mainHud.worldHelp);
            }
            setToolTipText();
            if(Boolean(mainHud.eCardBtn))
            {
               ECardManager.init(guiLayer,mainHud.eCardBtn,true);
            }
            if(Boolean(mainHud.buddyListBtn))
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
      }
      
      public static function grayOutHudItemsForPrivateLobby(show:Boolean) : void
      {
         mainHud.partyBtn.activateGrayState(show);
         mainHud.book.activateGrayState(show);
         mainHud.swapBtn.activateGrayState(show);
         mainHud.buddyListBtn.activateGrayState(show);
         mainHud.eCardBtn.activateGrayState(show);
         mainHud.awardsBtn.activateGrayState(show);
         mainHud.newsBtn.activateGrayState(show);
         actionMgr.grayGameTab(show);
      }
   }
}

