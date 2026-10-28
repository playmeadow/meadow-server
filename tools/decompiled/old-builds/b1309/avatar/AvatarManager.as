package avatar
{
   import buddy.BuddyEvent;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.SortLayer;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.popup.SBPopupManager;
   import com.sbi.popup.SBStandardPopup;
   import den.DenItem;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import game.MinigameInfo;
   import game.MinigameManager;
   import gui.BuddyManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import item.ItemXtCommManager;
   import localization.LocalizationManager;
   import pet.PetManager;
   import pet.WorldPet;
   import quest.QuestActor;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.LayerManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class AvatarManager
   {
      
      public static const THROTTLE_SEND_PLAYER_COLOR:int = 12;
      
      public static const GHOST_MIN_ALPHA:int = 45;
      
      public static var joiningNewRoom:Boolean;
      
      private static var _avLayer:SortLayer;
      
      private static var _flyingAvLayer:SortLayer;
      
      private static var _previewRoomAvLayer:SortLayer;
      
      private static var _previewFlyingRoomAvLayer:SortLayer;
      
      private static var _chatLayer:DisplayLayer;
      
      private static var _avatarList:Object;
      
      private static var _avatarViewList:Object;
      
      private static var _playerSfsUserId:int = -1;
      
      private static var _initCallback:Function;
      
      private static var _avatarViewOffScreenHud:Object;
      
      private static var _avatarAttachmentOffscreen:Dictionary;
      
      private static var _offScreenMap:Object;
      
      private static var _adventurePlayerData:Object;
      
      private static var _lastKnownAvtViewParent:Object;
      
      private static var _playerAttachmentEmotDefId:int;
      
      private static var _playerAttachmentEmotExtra:String;
      
      private static var _playerAttachmentEmotTimer:int;
      
      private static var _playerCustomPVP:Object;
      
      private static var _playerCustomAdventure:Object;
      
      private static var _playerSplashColor:uint;
      
      private static var _playerSplashColorCountdown:int;
      
      private static var _playerSplashColorLevel:uint;
      
      private static var _playerSplashColorLevelMax:uint;
      
      private static var _lastPlayerSplashColor:uint;
      
      private static var _playerAlpha:uint = 100;
      
      private static var _lastPlayerAlpha:uint;
      
      private static var _playerAlphaCountdown:int;
      
      private static var _sendPlayerColorThrottle:int;
      
      private static var _playerPetSparkleTimer:int;
      
      private static var _playerPetSparkleId:int;
      
      private static var _needToResetPet:Boolean;
      
      private static var _acQueue:Object;
      
      private static var _roomEnviroType:int;
      
      private static var _previousRoomEnviroType:int;
      
      private static var _waitForLangPack:Boolean;
      
      private static var _waitForLangPackSfsUserIdToACResponseDataMap:Object;
      
      public static var buddyCardAvatarView:AvatarView;
      
      private static var _throttle:int;
      
      private static var _lastThrottledPackAnimFlip:int;
      
      private static var _lastThrottledPositions:Vector.<Point>;
      
      private static var _lastSentPositions:Vector.<Point>;
      
      private static var _auSent:Boolean;
      
      private static var _isMyAvtInPreviewRoom:Boolean;
      
      private static var _flowerPool:Vector.<MovieClip>;
      
      private static var _flowerIdlePool:Vector.<MovieClip>;
      
      private static var _flowerLayer:DisplayLayer;
      
      private static var _layerManager:LayerManager;
      
      private static const Flower:Class = SpringFlower_3_swf;
      
      private static const FlowerIdle:Class = ground_idle_2_swf$b17db665fbf54ad7a4df8b9b334eb7ac765492625;
      
      public function AvatarManager()
      {
         super();
      }
      
      public static function init(param1:*, param2:DisplayLayer, param3:SortLayer, param4:SortLayer, param5:SortLayer) : void
      {
         _avLayer = param1;
         _flyingAvLayer = param3;
         _previewRoomAvLayer = param4;
         _previewFlyingRoomAvLayer = param5;
         _chatLayer = param2;
         _avatarList = {};
         _avatarViewList = {};
         _avatarViewOffScreenHud = {};
         _avatarAttachmentOffscreen = new Dictionary();
         _adventurePlayerData = {};
         _offScreenMap = {};
         _playerSfsUserId = gMainFrame.server.userId;
         _acQueue = {};
         _previousRoomEnviroType = -1;
         _waitForLangPack = false;
         _waitForLangPackSfsUserIdToACResponseDataMap = {};
         _lastThrottledPositions = new Vector.<Point>();
         _lastSentPositions = new Vector.<Point>();
         _flowerPool = new Vector.<MovieClip>();
         _flowerIdlePool = new Vector.<MovieClip>();
         _flowerLayer = new DisplayLayer();
         BuddyManager.eventDispatcher.addEventListener("OnBuddyChanged",toggleNamebarSelNubs,false,0,true);
      }
      
      public static function set playerSfsUserId(param1:int) : void
      {
         _playerSfsUserId = param1;
      }
      
      public static function showAvtAndChatLayers(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         var _loc4_:int = 0;
         var _loc3_:int = _avLayer.numChildren;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = _avLayer.getChildAt(_loc4_);
            if(_loc2_ is AvatarWorldView)
            {
               _loc2_.visible = param1;
            }
            _loc4_++;
         }
         _chatLayer.visible = param1;
         _flyingAvLayer.visible = param1;
      }
      
      public static function get getFlyingLayer() : SortLayer
      {
         return _flyingAvLayer;
      }
      
      public static function get getAvatarLayer() : SortLayer
      {
         return _avLayer;
      }
      
      public static function set roomEnviroType(param1:int) : void
      {
         _roomEnviroType = param1;
      }
      
      public static function get roomEnviroType() : int
      {
         return _roomEnviroType;
      }
      
      public static function set waitForLangPack(param1:Boolean) : void
      {
         _waitForLangPack = param1;
      }
      
      public static function get waitForLangPack() : Boolean
      {
         return _waitForLangPack;
      }
      
      public static function loadSelfAssets(param1:Function, param2:int = 0, param3:int = 0) : void
      {
         var _loc6_:* = 0;
         var _loc4_:AccItemCollection = null;
         var _loc7_:AccItemCollection = null;
         var _loc5_:int = 0;
         _initCallback = param1;
         var _loc8_:AvatarInfo = gMainFrame.userInfo.playerAvatarInfo;
         if(_loc8_ && _loc8_.type != -1)
         {
            _loc6_ = 0;
            if(_roomEnviroType == 0)
            {
               _loc6_ = 0;
               if(_playerSplashColorLevel)
               {
                  _loc6_ = uint(_playerSplashColorLevel << 24 | _playerSplashColor);
               }
            }
            else
            {
               _loc6_ = 0;
               clearPlayerSplashColor();
            }
            createAvatar(_playerSfsUserId,0,0,_loc8_.perUserAvId,_loc8_.avName,_loc8_.userName,_loc8_.type,_roomEnviroType == 0 ? 14 : 29,-1,_loc8_.colors,_loc6_,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,_loc8_.customAvId,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : gMainFrame.userInfo.playerUserInfo.nameBarData);
            AvatarManager.updateCustomPartyHostingDataForMyself();
            if(playerAvatar.enviroTypeFlag & 1 << 0 && playerAvatar.enviroTypeFlag & 1 << 1)
            {
               _loc4_ = new AccItemCollection();
               _loc7_ = _loc8_.getItems(true);
               _loc5_ = 0;
               while(_loc5_ < _loc7_.length)
               {
                  if(_loc7_.getAccItem(_loc5_).type == 0)
                  {
                     _loc4_.pushAccItem(_loc7_.getAccItem(_loc5_));
                  }
                  _loc5_++;
               }
               playerAvatar.itemResponseIntegrate(new AccItemCollection(_loc4_.concatCollection(_loc8_.getFullItems(true))));
            }
            else
            {
               playerAvatar.itemResponseIntegrate(_loc8_.getItems(true));
            }
            loadSelfAssetsResult(true,true);
         }
         else
         {
            createAvatar(_playerSfsUserId,param2,param3,gMainFrame.userInfo.myPerUserAvId,"",gMainFrame.server.userName,0,_roomEnviroType == 0 ? 14 : 29,-1,null,0,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,-1,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : gMainFrame.userInfo.playerUserInfo.nameBarData);
            DebugUtility.debugTrace("created avatar - playerAvatar:" + playerAvatar + " _playerSfsUserId:" + _playerSfsUserId + " avatarList:" + _avatarList);
            try
            {
               AvatarXtCommManager.requestADForAvatar(gMainFrame.userInfo.myPerUserAvId,true,loadSelfAssetsResult,playerAvatar);
            }
            catch(e:Error)
            {
               DebugUtility.debugTrace("Error on initial requestADForAvatar! e:" + e.message,16711680);
               new SBStandardPopup(gMainFrame.stage,LocalizationManager.translateIdOnly(11202),false);
               return;
            }
         }
         playerAvatar.inventoryDenFull.denItemCollection = gMainFrame.userInfo.playerUserInfo.denItemsFull;
         if(_previousRoomEnviroType != -1 && _previousRoomEnviroType != roomEnviroType)
         {
            playerAvatar.inventoryDenPartial.denItemCollection = gMainFrame.userInfo.playerUserInfo.denItemsPartial = enviroItems(gMainFrame.userInfo.playerUserInfo.denItemsFull);
         }
         else
         {
            playerAvatar.inventoryDenPartial.denItemCollection = gMainFrame.userInfo.playerUserInfo.denItemsPartial;
         }
         _previousRoomEnviroType = roomEnviroType;
         gMainFrame.userInfo.playerUserInfo.accountType = gMainFrame.clientInfo.accountType;
         ItemXtCommManager.playerAvatar = playerAvatar;
      }
      
      public static function loadSelfAssetsResult(param1:Boolean, param2:Boolean = false) : void
      {
         if(param1)
         {
            if(!param2)
            {
               updateNeededAvatarItemsAfterAD();
            }
            _avatarViewList[_playerSfsUserId].preload(_initCallback);
         }
      }
      
      private static function updateNeededAvatarItemsAfterAD() : void
      {
         if(!(playerAvatar.enviroTypeFlag & 1 << 2))
         {
            if(playerAvatarWorldView.parent == _flyingAvLayer)
            {
               _flyingAvLayer.removeChild(playerAvatarWorldView);
               _avLayer.addChild(playerAvatarWorldView);
               _lastKnownAvtViewParent = _avLayer;
            }
         }
         else if(playerAvatarWorldView.parent == _avLayer)
         {
            _avLayer.removeChild(playerAvatarWorldView);
            _flyingAvLayer.addChild(playerAvatarWorldView);
            _lastKnownAvtViewParent = _flyingAvLayer;
         }
         AvatarManager.updateCustomPartyHostingDataForMyself();
         AvatarManager.setupActivePet();
         AvatarManager.updateEmitParticles();
         AvatarSwitch.updateCurrentAvatarAfterRedemption(playerAvatar);
         GuiManager.showHudAvt();
      }
      
      public static function destroy() : void
      {
         _acQueue = null;
      }
      
      public static function get playerSfsUserId() : int
      {
         return _playerSfsUserId;
      }
      
      public static function get playerAvatar() : Avatar
      {
         return _avatarList[_playerSfsUserId];
      }
      
      public static function get playerAvatarWorldView() : AvatarWorldView
      {
         return _avatarViewList[_playerSfsUserId];
      }
      
      public static function get avatarList() : Object
      {
         return _avatarList;
      }
      
      public static function get avatarViewList() : Object
      {
         return _avatarViewList;
      }
      
      public static function get adventurePlayerData() : Object
      {
         return _adventurePlayerData;
      }
      
      public static function get isMyAvtInPreviewRoom() : Boolean
      {
         return _isMyAvtInPreviewRoom;
      }
      
      public static function getViewHudMCBySfsId(param1:int) : MovieClip
      {
         return _avatarViewOffScreenHud[param1];
      }
      
      public static function setViewHudMCBySfsId(param1:int, param2:MovieClip) : void
      {
         _avatarViewOffScreenHud[param1] = param2;
      }
      
      public static function setOffScreenAttachmentBySfsId(param1:int, param2:MovieClip) : void
      {
         _avatarAttachmentOffscreen[param1] = param2;
      }
      
      public static function getOffScreenAttachmentBySfsId(param1:int) : MovieClip
      {
         return _avatarAttachmentOffscreen[param1];
      }
      
      public static function setViewHudAttachmentBySfsId(param1:int, param2:int) : void
      {
         if(_avatarViewOffScreenHud[param1])
         {
            _avatarViewOffScreenHud[param1].attachmentId = param2;
         }
      }
      
      public static function setOffScreenMapBySfsId(param1:int, param2:Point, param3:String) : void
      {
         if(_offScreenMap[param1] == null)
         {
            _offScreenMap[param1] = new Dictionary(false);
            _offScreenMap[param1][param3] = param2;
         }
         else
         {
            _offScreenMap[param1][param3] = param2;
         }
      }
      
      public static function getOffScreenMapBySfsId(param1:int) : Dictionary
      {
         return _offScreenMap[param1];
      }
      
      public static function getOffScreenMap() : Object
      {
         return _offScreenMap;
      }
      
      public static function updateAvatarOffscreenToMyPosition() : void
      {
         for each(var _loc1_:Dictionary in _offScreenMap)
         {
            if(_loc1_[gMainFrame.server.getCurrentRoomName(false)] == null)
            {
               _loc1_[gMainFrame.server.getCurrentRoomName(false)] = new Point(playerAvatarWorldView.x,playerAvatarWorldView.y);
            }
         }
      }
      
      public static function movePlayer(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         if(_playerSfsUserId >= 0)
         {
            if(!MinigameManager.inMinigame() && !SBPopupManager.modalSBPopup)
            {
               updateAvatar(_playerSfsUserId,param1,param2,_isMyAvtInPreviewRoom ? false : true,param3);
            }
         }
      }
      
      public static function updateAvatarNameBarNames() : void
      {
         for each(var _loc1_:AvatarWorldView in _avatarViewList)
         {
            _loc1_.updateNameBarName();
         }
      }
      
      public static function updatePlayerAvatarViewParent(param1:Boolean) : void
      {
         var _loc2_:AvatarWorldView = playerAvatarWorldView;
         if(_loc2_)
         {
            if(param1)
            {
               if(_loc2_.parent == _previewRoomAvLayer)
               {
                  _previewRoomAvLayer.removeChild(_loc2_);
               }
               else if(_loc2_.parent == _previewFlyingRoomAvLayer)
               {
                  _previewFlyingRoomAvLayer.removeChild(_loc2_);
               }
               _lastKnownAvtViewParent.addChild(_loc2_);
               _isMyAvtInPreviewRoom = false;
            }
            else
            {
               if(_loc2_.parent == _lastKnownAvtViewParent)
               {
                  _lastKnownAvtViewParent.removeChild(_loc2_);
               }
               if(!(playerAvatar.enviroTypeFlag & 1 << 2))
               {
                  _previewRoomAvLayer.addChild(_loc2_);
               }
               else
               {
                  _previewFlyingRoomAvLayer.addChild(_loc2_);
               }
               _isMyAvtInPreviewRoom = true;
            }
         }
      }
      
      private static function enviroItems(param1:DenItemCollection) : DenItemCollection
      {
         var _loc3_:DenItemCollection = new DenItemCollection();
         for each(var _loc2_:DenItem in param1.getCoreArray())
         {
            if(_loc2_.enviroType == AvatarManager.roomEnviroType)
            {
               _loc3_.pushDenItem(_loc2_);
            }
         }
         return _loc3_;
      }
      
      public static function createAvatar(param1:int, param2:int, param3:int, param4:int, param5:String, param6:String, param7:int, param8:int, param9:int, param10:Array, param11:uint, param12:int, param13:Boolean, param14:int, param15:AccessoryState = null, param16:int = 0, param17:Object = null, param18:Object = null) : void
      {
         var _loc24_:AvatarInfo = null;
         var _loc26_:Object = null;
         var _loc27_:Boolean = false;
         var _loc23_:Object = null;
         if(param5 == "")
         {
            param5 = gMainFrame.clientInfo.avName;
         }
         var _loc22_:Avatar = new Avatar();
         _loc22_.init(param4,param5,param7,param10,param14,param15,param6,param1,_roomEnviroType);
         if(_avatarList[param1])
         {
            _avatarList[param1].destroy();
         }
         _avatarList[param1] = _loc22_;
         if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            if(AvatarManager.playerAvatarWorldView)
            {
               AvatarManager.playerAvatarWorldView.resetAvatar(_loc22_);
            }
         }
         var _loc21_:AvatarWorldView = new AvatarWorldView();
         _loc21_.initWorldView(_loc22_,param18 != null ? param18 : _chatLayer,param12,param13,false,GuiManager.actionMgr,GuiManager,param16,_roomEnviroType);
         _loc21_.setPos(param2,param3,false);
         if(param11 > 0)
         {
            _loc21_.setBlendColor(param11);
         }
         if(gMainFrame.clientInfo.roomType == 7)
         {
            if(_offScreenMap[param1] == null)
            {
               _offScreenMap[param1] = new Dictionary(false);
            }
         }
         var _loc19_:int = param8 & 0x07FFFFFF;
         var _loc25_:Boolean = param8 & 0x80000000 ? true : false;
         _loc21_.playAnim(_loc19_,_loc25_);
         if(_avatarViewList[param1])
         {
            _avatarViewList[param1].destroy();
         }
         _avatarViewList[param1] = _loc21_;
         if(gMainFrame.clientInfo.roomType == 7)
         {
            _adventurePlayerData[param1] = {
               "isMember":Utility.isMember(param12),
               "nameBarData":param16,
               "userName":param6,
               "avName":param5
            };
            _loc24_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc22_.userName);
            if(_loc24_ && _loc24_.questTorchStatus)
            {
               QuestManager.addTorch(_loc21_,1.3,-15,-50);
            }
         }
         if(!_isMyAvtInPreviewRoom || _chatLayer.visible == true)
         {
            _loc21_.visible = _chatLayer.visible;
         }
         if(param9 > 0)
         {
            _avatarViewList[param1].setEmote(null,param9);
         }
         var _loc20_:int = int(gMainFrame.server.userId);
         if(param1 != _loc20_)
         {
            if(_avatarViewList[_loc20_])
            {
               _avatarViewList[_loc20_].moveToFront();
            }
         }
         else
         {
            _sendPlayerColorThrottle = 0;
            if(param11 == 0 && _playerSplashColor != 0)
            {
               clearPlayerSplashColor();
            }
            if(param17 == null)
            {
               if(PetManager.myActivePetInvId > 0)
               {
                  if(param7 < 1)
                  {
                     _needToResetPet = true;
                  }
                  else
                  {
                     _needToResetPet = false;
                  }
                  _loc26_ = PetManager.myActivePet;
                  if(_loc26_)
                  {
                     _loc21_.setActivePet(_loc26_.lBits,_loc26_.uBits,_loc26_.eBits,_loc26_.name,_playerPetSparkleId);
                  }
               }
               if(_playerAttachmentEmotDefId > 0)
               {
                  if(_playerAttachmentEmotTimer >= 0)
                  {
                     UserCommXtCommManager.sendAvatarAttachmentEmot(_playerAttachmentEmotDefId,_playerAttachmentEmotExtra);
                  }
                  else
                  {
                     _playerAttachmentEmotDefId = 0;
                     _playerAttachmentEmotExtra = null;
                     _playerAttachmentEmotTimer = -1;
                  }
               }
               if(_playerCustomPVP)
               {
                  _loc21_.setCustomAdventureMessage(_playerCustomPVP.infoText,_playerCustomPVP.userMessage,_playerCustomPVP.difficulty,_playerCustomPVP.severity,true);
               }
               if(_playerCustomAdventure)
               {
                  _loc21_.setCustomAdventureMessage(_playerCustomAdventure.infoText,_playerCustomAdventure.userMessage,_playerCustomAdventure.difficulty,_playerCustomAdventure.severity,false);
               }
            }
            DebugUtility.debugTrace("ghostMode - creating self avatar - ghostMode:" + gMainFrame.clientInfo.invisMode);
            if(gMainFrame.clientInfo.invisMode)
            {
               _loc21_.alpha = 0.5;
            }
            else
            {
               _loc21_.alpha = _playerAlpha / 100;
            }
         }
         if(param17 != null)
         {
            param17.addChild(_loc21_);
            if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _lastKnownAvtViewParent = param17;
            }
         }
         else if(GuiManager.isBeYourPetRoom())
         {
            _loc27_ = true;
            if(param1 == _loc20_)
            {
               _loc27_ = _loc21_.isActivePetGroundPet();
            }
            else
            {
               _loc24_ = gMainFrame.userInfo.getAvatarInfoByUserName(param6);
               if(_loc24_)
               {
                  _loc23_ = _loc24_.currPet;
                  if(_loc23_)
                  {
                     _loc27_ = PetManager.isGround(PetManager.petTypeForDefId(_loc23_.lBits & 0xFF));
                  }
               }
            }
            if(_loc27_)
            {
               _avLayer.addChild(_loc21_);
               if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
               {
                  _lastKnownAvtViewParent = _avLayer;
               }
            }
            else
            {
               _flyingAvLayer.addChild(_loc21_);
               if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
               {
                  _lastKnownAvtViewParent = _flyingAvLayer;
               }
            }
         }
         else if(!(_loc22_.enviroTypeFlag & 1 << 2))
         {
            _avLayer.addChild(_loc21_);
            if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _lastKnownAvtViewParent = _avLayer;
            }
         }
         else
         {
            _flyingAvLayer.addChild(_loc21_);
            if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _lastKnownAvtViewParent = _flyingAvLayer;
            }
         }
      }
      
      public static function updateEmitParticles() : void
      {
         if(playerAvatarWorldView)
         {
            playerAvatarWorldView.setupParticles();
         }
      }
      
      public static function setupActivePet() : void
      {
         var _loc1_:Object = null;
         if(_needToResetPet && PetManager.myActivePetInvId > 0)
         {
            _needToResetPet = false;
            _loc1_ = PetManager.myActivePet;
            if(_loc1_ && playerAvatarWorldView)
            {
               playerAvatarWorldView.setActivePet(_loc1_.lBits,_loc1_.uBits,_loc1_.eBits,_loc1_.name,_playerPetSparkleId);
            }
         }
      }
      
      public static function updateCustomPartyHostingDataForMyself() : void
      {
         var _loc1_:UserInfo = null;
         if(playerAvatarWorldView)
         {
            _loc1_ = gMainFrame.userInfo.playerUserInfo;
            playerAvatarWorldView.updateIsHostingCustomParty(_loc1_.isStillHosting);
         }
      }
      
      public static function createNPCs(param1:Array, param2:Array) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc3_:NPCView = null;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_ = QuestManager.getNPCDef(param1[_loc5_]);
            _loc3_ = new NPCView();
            _loc3_.init(_loc4_.defId,_loc5_,_loc4_.titleStrId,_loc4_.avatarRefId,false,null);
            _loc3_.x = param2[_loc5_].x;
            _loc3_.y = param2[_loc5_].y;
            _loc3_.addEventListener("mouseDown",onNPCDown,false,0,true);
            _avLayer.addChild(_loc3_);
            _loc5_++;
         }
      }
      
      public static function addQuestActor(param1:QuestActor, param2:Point) : void
      {
         param1.x = param2.x;
         param1.y = param2.y;
         _avLayer.addChild(param1);
      }
      
      private static function onNPCDown(param1:MouseEvent) : void
      {
         var _loc2_:NPCView = NPCView(param1.currentTarget);
         DarkenManager.showLoadingSpiral(true);
         MinigameManager.handleGameClick({
            "idx":5,
            "r":30,
            "spawn":"spawn",
            "type":0,
            "typeDefId":82,
            "x":_loc2_.x,
            "y":_loc2_.y
         },null,true,null,_loc2_.defId);
         RoomManagerWorld.instance.setGotoSpawnLocation(playerAvatarWorldView.avatarPos.x,playerAvatarWorldView.avatarPos.y);
      }
      
      public static function updateAvatar(param1:Object, param2:int, param3:int, param4:Boolean, param5:Boolean = true, param6:Boolean = false) : void
      {
         var _loc7_:Point = null;
         var _loc9_:int = 0;
         if(!_avatarList[param1])
         {
            DebugUtility.debugTrace("updateAvatar(): ERROR: sfsUserId:" + param1 + " not found in _avatarList:" + _avatarList);
            return;
         }
         var _loc8_:AvatarWorldView = _avatarViewList[param1];
         _loc8_.setPos(param2,param3,param5);
         if(param4 && !joiningNewRoom && param1 == _playerSfsUserId && !gMainFrame.clientInfo.invisMode)
         {
            _loc7_ = new Point(param2,param3);
            _loc9_ = _loc8_.lastIdleAnim | (_loc8_.lastIdleFlip ? 2147483648 : 0);
            if(_throttle == 0)
            {
               if(_lastSentPositions.length > 0 && _loc7_.equals(_lastSentPositions[_lastSentPositions.length - 1]))
               {
                  return;
               }
               if(QuestManager.isSideScrollQuest() && _auSent)
               {
                  QuestXtCommManager.questSideScrollAU(param2,param3,0);
               }
               else
               {
                  gMainFrame.server.setXtObject_Str("au",["1",param2,param3,_loc9_,param6 ? "1" : "0"]);
                  _auSent = true;
               }
               _throttle = 12;
               _lastSentPositions.push(_loc7_);
               if(_lastSentPositions.length > 2)
               {
                  _lastSentPositions.shift();
               }
               _lastThrottledPositions.length = 0;
            }
            else if(!param6)
            {
               if(_lastThrottledPositions.length > 0 && _loc7_.equals(_lastThrottledPositions[_lastThrottledPositions.length - 1]))
               {
                  return;
               }
               _lastThrottledPackAnimFlip = _loc9_;
               _lastThrottledPositions.push(_loc7_);
               if(_lastThrottledPositions.length > 2)
               {
                  _lastThrottledPositions.shift();
               }
            }
         }
      }
      
      public static function processLastThrottledUpdate() : void
      {
         var _loc3_:Array = null;
         var _loc1_:Point = null;
         var _loc2_:Point = null;
         var _loc4_:int = int(_lastThrottledPositions.length);
         if(_loc4_ == 0)
         {
            return;
         }
         if(_loc4_ == 1)
         {
            _loc1_ = _lastThrottledPositions[0];
            _lastThrottledPositions.length = 0;
            if(_loc1_.equals(_lastSentPositions[_lastSentPositions.length - 1]))
            {
               return;
            }
            _loc3_ = [1,_loc1_.x,_loc1_.y];
            _lastSentPositions.push(new Point(_loc1_.x,_loc1_.y));
         }
         else if(_loc4_ > 1)
         {
            _loc1_ = _lastThrottledPositions[_loc4_ - 2];
            _loc2_ = _lastThrottledPositions[_loc4_ - 1];
            _lastThrottledPositions.length = 0;
            if(_lastSentPositions.length == 2 && _loc1_.equals(_lastSentPositions[0]) && _loc2_.equals(_lastSentPositions[1]))
            {
               return;
            }
            _loc3_ = [2,_loc1_.x,_loc1_.y,_loc2_.x,_loc2_.y];
            _lastSentPositions.push(_loc1_);
            _lastSentPositions.push(_loc2_);
         }
         _loc3_.push(_lastThrottledPackAnimFlip);
         _loc3_.push("0");
         gMainFrame.server.setXtObject_Str("au",_loc3_);
         if(_lastSentPositions.length > 2)
         {
            _lastSentPositions.splice(0,_lastSentPositions.length - 2);
         }
      }
      
      public static function resetThrottle() : void
      {
         _throttle = 0;
      }
      
      public static function getAvatarBySfsUserId(param1:int) : Avatar
      {
         return _avatarList[param1];
      }
      
      public static function getAvatarByUsernamePerUserAvId(param1:String, param2:int) : Avatar
      {
         for each(var _loc3_:Avatar in _avatarList)
         {
            if(_loc3_.userName.toLowerCase() == param1.toLowerCase() && _loc3_.perUserAvId == param2)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public static function getAvatarByAvName(param1:String) : Avatar
      {
         for each(var _loc2_:Avatar in _avatarList)
         {
            if(_loc2_.avName == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function getAvatarByUserName(param1:String) : Avatar
      {
         for each(var _loc2_:Avatar in _avatarList)
         {
            if(_loc2_.userName.toLowerCase() == param1.toLowerCase())
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function getAvatarWorldViewBySfsUserId(param1:int) : AvatarWorldView
      {
         return _avatarViewList[param1];
      }
      
      public static function addAvatarMessage(param1:String, param2:int, param3:int) : void
      {
         var _loc4_:MovieClip = null;
         if(param2 > -1 && _avatarViewList[param2] && !MinigameManager.inMinigame())
         {
            AvatarWorldView(_avatarViewList[param2]).setMessage(param1,param3);
         }
         else if(gMainFrame.clientInfo.roomType == 7 && param2 != playerSfsUserId)
         {
            _loc4_ = _avatarViewOffScreenHud[param2];
            if(_loc4_)
            {
               _loc4_.questChatBalloon.setText(param1,gMainFrame.userInfo.isModerator && param3 > 1,false);
            }
         }
      }
      
      public static function addCustomAdventureMessage(param1:String, param2:String, param3:int, param4:int, param5:int) : void
      {
         if(param3 > -1 && _avatarViewList[param3] && !MinigameManager.inMinigame())
         {
            if(param3 == _playerSfsUserId)
            {
               if(param2 == "off")
               {
                  _playerCustomAdventure = null;
               }
               else
               {
                  _playerCustomAdventure = {
                     "infoText":param1,
                     "userMessage":param2,
                     "difficulty":param4,
                     "severity":param5
                  };
               }
            }
            _avatarViewList[param3].setCustomAdventureMessage(param1,param2,param4,param5);
         }
      }
      
      public static function addCustomPvpMessage(param1:String, param2:String, param3:int, param4:int, param5:int) : void
      {
         var _loc6_:Boolean = false;
         if(param3 > -1 && _avatarViewList[param3])
         {
            if(param3 == _playerSfsUserId)
            {
               if(param2.split("|")[0] == "off")
               {
                  _playerCustomPVP = null;
                  GuiManager.mainHud.emotesBtn.activateGrayState(false);
                  GuiManager.actionMgr.hideCancelBtn();
                  _loc6_ = true;
               }
               else if(!MinigameManager.inMinigame())
               {
                  _playerCustomPVP = {
                     "infoText":param1,
                     "userMessage":param2,
                     "difficulty":param4,
                     "severity":param5
                  };
                  GuiManager.mainHud.emotesBtn.downToUpState();
                  GuiManager.emoteMgr.closeEmotes();
                  GuiManager.mainHud.emotesBtn.activateGrayState(true);
                  _loc6_ = true;
               }
            }
            else if(!MinigameManager.inMinigame())
            {
               _loc6_ = true;
            }
            if(_loc6_)
            {
               _avatarViewList[param3].setCustomAdventureMessage(param1,param2,param4,param5,true);
            }
         }
      }
      
      public static function setAvatarEmote(param1:Sprite, param2:int = -2, param3:int = -1) : void
      {
         if(param2 == -2)
         {
            param2 = int(gMainFrame.server.userId);
            _avatarViewList[param2].setEmote(param1,param3);
         }
         else if(param2 > -1 && _avatarViewList[param2])
         {
            if(param2 != gMainFrame.server.userId || param3 >= 0)
            {
               _avatarViewList[param2].setEmote(param1,param3);
            }
         }
      }
      
      public static function setAvatarAction(param1:Sprite, param2:int = -2) : void
      {
         if(param2 == -2)
         {
            param2 = int(gMainFrame.server.userId);
            _avatarViewList[param2].setAction(param1);
            checkIfBeingHoppedOn(param2);
         }
         else if(param2 > -1 && _avatarViewList[param2] && !MinigameManager.inMinigame())
         {
            if(param2 != gMainFrame.server.userId)
            {
               _avatarViewList[param2].setAction(param1);
            }
            checkIfBeingHoppedOn(param2);
         }
      }
      
      private static function checkIfBeingHoppedOn(param1:int) : void
      {
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc2_:int = 0;
         var _loc3_:AvatarWorldView = _avatarViewList[param1];
         if(param1 != gMainFrame.server.userId)
         {
            if(AvatarManager.playerAvatarWorldView != null)
            {
               _loc5_ = _loc3_.avatarPos;
               _loc6_ = AvatarManager.playerAvatarWorldView.avatarPos;
               _loc2_ = Math.sqrt((_loc5_.x - _loc6_.x) * (_loc5_.x - _loc6_.x) + (_loc5_.y - _loc6_.y) * (_loc5_.y - _loc6_.y));
               if(_loc2_ < 100)
               {
                  if(_loc3_.lastIdleAnim == 17 && (AvatarManager.playerAvatarWorldView.lastIdleAnim == 22 || AvatarManager.playerAvatarWorldView.avTypeId == 6 && AvatarManager.playerAvatarWorldView.lastIdleAnim == 6))
                  {
                     movePlayer(_loc6_.x + 1,_loc6_.y);
                  }
                  else if((_loc3_.lastIdleAnim == 22 || _loc3_.avTypeId == 6 && _loc3_.lastIdleAnim == 6) && AvatarManager.playerAvatarWorldView.lastIdleAnim == 17)
                  {
                     updateAvatar(param1,_loc6_.x + 1,_loc6_.y,false);
                  }
               }
            }
         }
         else if(_loc3_.lastIdleAnim == 22 || _loc3_.avTypeId == 6 && _loc3_.lastIdleAnim == 6)
         {
            for each(var _loc4_:AvatarWorldView in _avatarViewList)
            {
               if(_loc4_.userId != param1)
               {
                  if(_loc4_.lastIdleAnim == 17)
                  {
                     _loc5_ = _loc4_.avatarPos;
                     _loc6_ = _loc3_.avatarPos;
                     _loc2_ = Math.sqrt((_loc5_.x - _loc6_.x) * (_loc5_.x - _loc6_.x) + (_loc5_.y - _loc6_.y) * (_loc5_.y - _loc6_.y));
                     if(_loc2_ < 100)
                     {
                        movePlayer(_loc6_.x,_loc6_.y);
                     }
                  }
               }
            }
         }
      }
      
      public static function isMyUserInCustomPVPState() : Boolean
      {
         return _playerCustomPVP != null;
      }
      
      public static function isMyUserInCustomAdventureHosting() : Boolean
      {
         return _playerCustomAdventure != null;
      }
      
      public static function resetCustomAdventureState() : void
      {
         _playerCustomAdventure = null;
      }
      
      public static function setChatBalloonReadyForClear(param1:int) : void
      {
         if(param1 >= 0 && _avatarViewList[param1])
         {
            _avatarViewList[param1].setChatBalloonReadyForClear();
         }
      }
      
      public static function setPlayerAttachmentEmot(param1:int, param2:String = null, param3:int = 2880, param4:Boolean = true) : void
      {
         if(_playerAttachmentEmotDefId != param1 || _playerAttachmentEmotExtra != param2)
         {
            _playerAttachmentEmotTimer = param3;
            _playerAttachmentEmotDefId = param1;
            _playerAttachmentEmotExtra = param2;
            if(param4)
            {
               UserCommXtCommManager.sendAvatarAttachmentEmot(_playerAttachmentEmotDefId,param2);
            }
         }
      }
      
      public static function _setAvatarAttachmentEmot(param1:int, param2:String, param3:int) : void
      {
         var _loc4_:MovieClip = null;
         if(param3 >= 0 && _avatarViewList[param3])
         {
            _avatarViewList[param3].setAvAttachment(param1,param2);
            if(param3 == _playerSfsUserId && _playerAttachmentEmotTimer > 0)
            {
               _playerAttachmentEmotDefId = UserCommXtCommManager.getEmoticonDefId(param1);
            }
         }
         else if(gMainFrame.clientInfo.roomType == 7 && param3 != playerSfsUserId)
         {
            _loc4_ = _avatarViewOffScreenHud[param3];
            if(_loc4_)
            {
               setViewHudAttachmentBySfsId(param3,param1);
            }
         }
         if(QuestManager._delayMinigameLaunches)
         {
            QuestManager.launchQueuedGame();
         }
      }
      
      public static function _setAvatarBlendColor(param1:int, param2:uint) : void
      {
         if(param1 >= 0 && _avatarViewList[param1] && param1 != _playerSfsUserId)
         {
            _avatarViewList[param1].setBlendColor(param2);
         }
      }
      
      public static function _setAvatarAlphaLevel(param1:int, param2:uint) : void
      {
         if(param1 >= 0 && _avatarViewList[param1] && param1 != _playerSfsUserId)
         {
            _avatarViewList[param1].setAlphaLevel(param2);
         }
      }
      
      public static function setPetAction(param1:int, param2:int, param3:int = 0) : void
      {
         var _loc6_:Object = null;
         var _loc4_:AvatarWorldView = _avatarViewList[param1];
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:WorldPet = _loc4_.getActivePet();
         if(!_loc5_)
         {
            return;
         }
         _loc5_.setAction(param2,param3);
         if(param1 == playerSfsUserId && param2 == 1)
         {
            _playerPetSparkleId = param3;
            if(_playerPetSparkleId > 0)
            {
               _loc6_ = PetManager.myActivePet;
               if(_loc6_)
               {
                  _loc6_.isSparkling = true;
               }
               _playerPetSparkleTimer = 7200;
            }
            else
            {
               _playerPetSparkleTimer = 0;
            }
         }
      }
      
      public static function removeAvatar(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:MovieClip = null;
         if(!_avatarList[param1] || !_avatarViewList[param1])
         {
            if(param2)
            {
               _loc3_ = _avatarViewOffScreenHud[param1];
               if(_loc3_)
               {
                  if(_loc3_.parent && _loc3_.parent == GuiManager.guiLayer)
                  {
                     GuiManager.guiLayer.removeChild(_loc3_);
                  }
                  _loc3_ = null;
                  delete _avatarViewOffScreenHud[param1];
                  delete _offScreenMap[param1];
                  delete _avatarAttachmentOffscreen[param1];
                  delete _adventurePlayerData[param1];
               }
            }
            else
            {
               DebugUtility.debugTrace("removeAvatar(): ERROR: sfsUserId:" + param1 + " not found in _avatarList:" + _avatarList);
            }
            return;
         }
         BuddyManager.avatarLeftRoom(_avatarList[param1].userName.toLowerCase());
         var _loc6_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_avatarList[param1].userName,_avatarList[param1].perUserAvId);
         if(gMainFrame.clientInfo.roomType == 7 && (param1 == _playerSfsUserId || _loc6_ && _loc6_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && _loc6_.perUserAvId == gMainFrame.userInfo.myPerUserAvId))
         {
            for each(var _loc4_:AvatarWorldView in _avatarViewList)
            {
               delete _avatarViewList[_loc4_.avatarData.sfsUserId];
               _avatarList[_loc4_.avatarData.sfsUserId].destroy();
               delete _avatarList[_loc4_.avatarData.sfsUserId];
               _loc4_.destroy();
               _loc4_ = null;
            }
         }
         else
         {
            if(param1 != _playerSfsUserId || _loc6_ && _loc6_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && _loc6_.perUserAvId == gMainFrame.userInfo.myPerUserAvId)
            {
               _avatarList[param1].destroy();
            }
            _avatarViewList[param1].destroy();
            _avatarViewList[param1] = null;
            delete _avatarViewList[param1];
         }
         if(param1 == _playerSfsUserId || _avatarList[param1] && _loc6_ && _loc6_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && _loc6_.perUserAvId == gMainFrame.userInfo.myPerUserAvId)
         {
            for each(var _loc5_:MovieClip in _avatarViewOffScreenHud)
            {
               if(_loc5_.parent && _loc5_.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc5_);
               }
            }
            if(param2 || QuestManager.questExitPending)
            {
               _avatarViewOffScreenHud = {};
               _offScreenMap = {};
               _avatarAttachmentOffscreen = new Dictionary();
               _adventurePlayerData = {};
            }
         }
         else if(param2)
         {
            _loc3_ = _avatarViewOffScreenHud[param1];
            if(_loc3_)
            {
               if(_loc3_.parent && _loc3_.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc3_);
               }
               _loc3_ = null;
               delete _avatarViewOffScreenHud[param1];
               delete _offScreenMap[param1];
               delete _avatarAttachmentOffscreen[param1];
               delete _adventurePlayerData[param1];
            }
         }
         _avatarList[param1] = null;
         delete _avatarList[param1];
      }
      
      public static function removeAllAvatars() : void
      {
         var _loc1_:Array = [];
         for(var _loc2_:String in _avatarList)
         {
            _loc1_.push(_loc2_);
         }
         while(_loc1_.length > 0)
         {
            removeAvatar(_loc1_.pop());
         }
         _auSent = false;
      }
      
      public static function heartbeat(param1:int, param2:int) : void
      {
         var _loc3_:AvatarWorldView = null;
         var _loc4_:Array = [];
         for(var _loc5_:Object in _avatarList)
         {
            _loc3_ = _avatarViewList[_loc5_];
            if(_loc3_ && !_loc3_.heartbeat(param1,param2))
            {
               _loc4_.push(_loc5_);
            }
         }
         while(_loc4_.length > 0)
         {
            removeAvatar(_loc4_.pop());
         }
         if(_throttle > 0)
         {
            _throttle = _throttle - 1;
         }
         if(_flowerLayer.parent)
         {
            _flowerLayer.x = _layerManager.room_avatars.x;
            _flowerLayer.y = _layerManager.room_avatars.y;
         }
         if(_playerAttachmentEmotTimer > 0)
         {
            if(!MinigameManager.inMinigame())
            {
               _playerAttachmentEmotTimer = _playerAttachmentEmotTimer - 1;
               if(!_playerAttachmentEmotTimer)
               {
                  _playerAttachmentEmotDefId = 0;
                  UserCommXtCommManager.sendAvatarAttachmentEmot(0);
               }
            }
         }
         if(_playerPetSparkleTimer > 0)
         {
            _playerPetSparkleTimer = _playerPetSparkleTimer - 1;
            if(!_playerPetSparkleTimer)
            {
               _playerPetSparkleId = 0;
               UserCommXtCommManager.sendPetAction(1,0);
            }
         }
         processPlayerSplashColor();
      }
      
      public static function processPlayerSplashColor() : void
      {
         var _loc6_:int = 0;
         var _loc4_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc5_:Object = null;
         var _loc1_:AvatarWorldView = playerAvatarWorldView;
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_.inSplashVolume() && !AvatarSwitch.isSwitching())
         {
            _loc6_ = 20;
            _loc4_ = false;
            _loc2_ = false;
            switch(_loc1_.splashLiquid)
            {
               case "mud":
                  _playerSplashColor = 6045747;
                  _playerSplashColorLevelMax = 255;
                  if(_playerSplashColorLevel < 100)
                  {
                     _playerSplashColorLevel = 100;
                  }
                  _loc5_ = PetManager.myActivePet;
                  if(_loc5_ && _loc5_.isGround && _loc5_.isSparkling)
                  {
                     _loc5_.isSparkling = false;
                     PetManager.sendPetSparkle(0);
                  }
                  break;
               case "ice":
                  _playerSplashColor = 9489663;
                  _playerSplashColorLevelMax = 200;
                  if(_playerSplashColorLevel < 60)
                  {
                     _playerSplashColorLevel = 60;
                  }
                  _loc6_ = 10;
                  _loc4_ = true;
                  break;
               case "fire":
                  _playerSplashColor = 11141120;
                  _playerSplashColorLevelMax = 200;
                  if(_playerSplashColorLevel < 60)
                  {
                     _playerSplashColorLevel = 60;
                  }
                  _loc6_ = 10;
                  _loc4_ = true;
                  break;
               case "water":
                  _playerSplashColor = 0;
                  _playerSplashColorLevel = 0;
                  _playerSplashColorLevelMax = 0;
                  break;
               case "ghost":
                  if(--_playerAlphaCountdown < 0)
                  {
                     _playerAlphaCountdown = 3;
                     _playerAlpha = _playerAlpha - 1;
                     if(_playerAlpha < 45)
                     {
                        _playerAlpha = 45;
                     }
                  }
                  break;
               case "acid":
                  _playerSplashColor = 5111317;
                  _playerSplashColorLevelMax = 200;
                  if(_playerSplashColorLevel < 60)
                  {
                     _playerSplashColorLevel = 60;
                  }
                  _loc6_ = 10;
                  break;
               case "fallleaves":
                  handleNotInSplashUpdates();
                  _loc2_ = true;
            }
            if(!_loc2_ && (_loc1_.isSplashAnim() || _loc4_))
            {
               if(_playerSplashColorLevel < _playerSplashColorLevelMax && --_playerSplashColorCountdown < 0)
               {
                  _playerSplashColorCountdown = 10;
                  _playerSplashColorLevel += _loc6_;
                  if(_playerSplashColorLevel > _playerSplashColorLevelMax)
                  {
                     _playerSplashColorLevel = _playerSplashColorLevelMax;
                  }
               }
            }
         }
         else
         {
            handleNotInSplashUpdates();
         }
         var _loc3_:uint = uint(_playerSplashColorLevel << 24 | _playerSplashColor);
         if(_playerSplashColorLevel == 0 || _playerSplashColor == 0)
         {
            _loc3_ = 0;
         }
         if(--_sendPlayerColorThrottle < 0)
         {
            _sendPlayerColorThrottle = 12;
            if(_lastPlayerSplashColor != _loc3_)
            {
               _loc1_.setBlendColor(_loc3_);
               _lastPlayerSplashColor = _loc3_;
               UserCommXtCommManager.sendAvatarBlendColor(_loc3_);
            }
            if(_lastPlayerAlpha != _playerAlpha)
            {
               _loc1_.setAlphaLevel(_playerAlpha);
               _lastPlayerAlpha = _playerAlpha;
               UserCommXtCommManager.sendAvatarAlphaLevel(_playerAlpha);
            }
         }
      }
      
      private static function handleNotInSplashUpdates() : void
      {
         if(_playerSplashColorLevel > 0 && --_playerSplashColorCountdown < 0)
         {
            if(_playerSplashColorLevel > 240)
            {
               _playerSplashColorLevel -= 1;
               _playerSplashColorCountdown = 32;
            }
            else
            {
               _playerSplashColorCountdown = 10;
               var _temp_6:* = §§findproperty(_playerSplashColorLevel);
               _playerSplashColorLevel -= _playerSplashColorLevel > 2 ? 2 : _playerSplashColorLevel;
            }
            if(_playerSplashColorLevel < 60)
            {
               _playerSplashColorLevel = 0;
            }
         }
         if(_playerAlpha < 100 && --_playerAlphaCountdown < 0)
         {
            _playerAlphaCountdown = _playerAlpha > 45 + 10 ? 16 : 80;
            _playerAlpha = _playerAlpha + 1;
         }
      }
      
      public static function clearPlayerSplashColor() : void
      {
         _playerSplashColor = 0;
         _playerSplashColorLevel = 0;
         _lastPlayerSplashColor = 0;
         _sendPlayerColorThrottle = 0;
         _playerAlphaCountdown = 0;
         _lastPlayerAlpha = 0;
         _playerSplashColorLevelMax = 0;
      }
      
      private static function loadAvatarAssetsComplete(param1:LoaderEvent) : void
      {
         if(!param1.status)
         {
            throw new Error("ERROR: Unable to load avatar assets!");
         }
      }
      
      public static function finishHandleAvatarCreate() : void
      {
         if(_waitForLangPack)
         {
            _waitForLangPack = false;
            for each(var _loc1_:Array in _waitForLangPackSfsUserIdToACResponseDataMap)
            {
               avatarCreateResponse(_loc1_);
            }
            for(var _loc2_:String in _waitForLangPackSfsUserIdToACResponseDataMap)
            {
               delete _waitForLangPackSfsUserIdToACResponseDataMap[_loc2_];
            }
         }
      }
      
      public static function avatarUpdateResponse(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:Array = null;
         var _loc8_:AvatarWorldView = null;
         var _loc5_:Point = null;
         var _loc11_:Boolean = false;
         var _loc9_:int = 0;
         var _loc7_:int = 2;
         var _loc6_:int = int(param1[_loc7_++]);
         if(_loc6_ <= 0)
         {
            throw new Error("got empty \'au\' from server!");
         }
         _loc9_ = 0;
         while(_loc9_ < _loc6_)
         {
            _loc3_ = int(param1[_loc7_++]);
            _loc10_ = int(param1[_loc7_++]);
            if(_loc10_ <= 0)
            {
               throw new Error("got empty position update from server!");
            }
            _loc2_ = 0;
            _loc4_ = [];
            while(_loc2_ < _loc10_)
            {
               _loc4_.push(new Point(int(param1[_loc7_++]),int(param1[_loc7_++])));
               _loc2_++;
            }
            _loc11_ = param1[_loc7_++] != "0";
            if(_loc3_ != _playerSfsUserId)
            {
               _loc8_ = _avatarViewList[_loc3_];
               if(_loc8_ != null)
               {
                  if(!_loc11_)
                  {
                     _loc8_.setPath(_loc4_);
                  }
                  else
                  {
                     _loc5_ = _loc4_[_loc4_.length - 1];
                     _loc8_.setPos(_loc5_.x,_loc5_.y,false);
                  }
               }
            }
            _loc9_++;
         }
      }
      
      public static function avatarPaintResponse(param1:Array) : void
      {
         if(param1[2] != "1")
         {
            DebugUtility.debugTrace("ERROR: avatar paint command failed!");
         }
      }
      
      public static function avatarCreateResponse(param1:Array) : void
      {
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         var _loc10_:int = 0;
         var _loc25_:int = 0;
         var _loc14_:String = null;
         var _loc22_:* = 0;
         var _loc42_:Boolean = false;
         var _loc16_:String = null;
         var _loc43_:int = 0;
         var _loc12_:int = 0;
         var _loc26_:int = 0;
         var _loc31_:String = null;
         var _loc37_:String = null;
         var _loc20_:int = 0;
         var _loc19_:UserInfo = null;
         var _loc35_:UserInfo = null;
         var _loc21_:Array = null;
         var _loc17_:Array = null;
         var _loc15_:Array = null;
         var _loc3_:Object = null;
         var _loc6_:MinigameInfo = null;
         if(_waitForLangPack)
         {
            _waitForLangPackSfsUserIdToACResponseDataMap[param1[2]] = param1;
            return;
         }
         var _loc29_:int = 2;
         var _loc18_:int = int(param1[_loc29_++]);
         var _loc40_:int = int(param1[_loc29_++]);
         var _loc38_:int = int(param1[_loc29_++]);
         var _loc13_:int = int(param1[_loc29_++]);
         var _loc41_:String = param1[_loc29_++];
         var _loc34_:String = param1[_loc29_++];
         var _loc30_:int = int(param1[_loc29_++]);
         var _loc9_:String = param1[_loc29_++];
         var _loc23_:int = int(param1[_loc29_++]);
         var _loc36_:int = int(param1[_loc29_++]);
         var _loc11_:Array = [uint(param1[_loc29_++]),uint(param1[_loc29_++]),uint(param1[_loc29_++])];
         var _loc45_:int = int(param1[_loc29_++]);
         var _loc44_:int = int(gMainFrame.clientInfo.roomType == 7 ? int(param1[_loc29_++]) : 0);
         var _loc46_:Boolean = gMainFrame.clientInfo.roomType == 7 ? param1[_loc29_++] == 1 : false;
         var _loc24_:int = int(param1[_loc29_++]);
         var _loc39_:int = int(param1[_loc29_++]);
         var _loc8_:int = int(param1[_loc29_++]);
         var _loc28_:int = 1;
         var _loc32_:int = 0;
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc28_ = int(param1[_loc29_++]);
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc7_ = int(param1[_loc29_++]);
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc5_ = int(param1[_loc29_++]);
            _loc10_ = int(param1[_loc29_++]);
            _loc25_ = int(param1[_loc29_++]);
            _loc14_ = param1[_loc29_++];
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc22_ = uint(param1[_loc29_++]);
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc42_ = Boolean(int(param1[_loc29_++]));
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc16_ = param1[_loc29_++];
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc43_ = int(param1[_loc29_++]);
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc12_ = int(param1[_loc29_++]);
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc26_ = int(param1[_loc29_++]);
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc31_ = param1[_loc29_++];
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc37_ = param1[_loc29_++];
         }
         if(_loc8_ & 1 << _loc32_++)
         {
            _loc20_ = int(param1[_loc29_++]);
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            ExternalInterface.call("mrc",["uer",_loc41_,true]);
            DebugUtility.debugTrace("mrc uer sent, checking goto user - RoomXtCommManager.loadingNewRoom:" + RoomXtCommManager.loadingNewRoom + " user:" + _loc41_);
            if(!RoomXtCommManager.loadingNewRoom)
            {
               RoomManagerWorld.instance.modGotoUser(_loc41_,_loc40_,_loc38_);
            }
         }
         var _loc27_:Object = {
            "name":_loc14_,
            "lBits":_loc5_,
            "uBits":_loc10_,
            "eBits":_loc25_
         };
         _loc27_.defId = PetManager.getDefIdFromLBits(_loc27_.lBits);
         _loc27_.type = PetManager.petTypeForDefId(_loc27_.defId);
         _loc27_.isGround = PetManager.isGround(_loc27_.type);
         var _loc33_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc41_,_loc30_);
         if(_loc33_)
         {
            _loc33_.avName = _loc9_;
            _loc33_.type = _loc23_;
            _loc33_.colors = _loc11_;
            _loc33_.currEnviroType = _roomEnviroType;
            _loc33_.questLevel = _loc45_;
            _loc33_.questXp = 0;
            _loc33_.questXPPercentage = 0;
            _loc33_.questHealthPercentage = _loc44_;
            _loc33_.questTorchStatus = _loc46_;
            _loc33_.currPet = _loc27_;
            _loc33_.customAvId = _loc36_;
            _loc19_ = gMainFrame.userInfo.getUserInfoByUserName(_loc41_);
            _loc19_.accountType = _loc28_;
            _loc19_.isGuide = _loc42_;
            _loc19_.nameBarData = _loc7_;
            _loc19_.userNameModeratedFlag = _loc24_;
            _loc19_.timeLeftHostingCustomParty = _loc20_;
            _loc19_.daysSinceLastLogin = _loc39_;
         }
         else
         {
            _loc35_ = new UserInfo();
            _loc33_ = new AvatarInfo();
            _loc33_.init(_loc30_,_loc9_,_loc41_,_loc34_,_loc23_,_loc11_,0,_loc27_,_loc36_,0,0,0,_loc45_);
            _loc33_.questHealthPercentage = _loc44_;
            _loc33_.questTorchStatus = _loc46_;
            _loc21_ = [];
            _loc21_[_loc33_.perUserAvId] = _loc33_;
            _loc35_.init(_loc41_,_loc34_,_loc21_,_loc33_.perUserAvId,_loc28_,_loc24_,_loc20_,_loc39_);
            _loc35_.isGuide = _loc42_;
            _loc35_.nameBarData = _loc7_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc41_,_loc35_);
         }
         createAvatar(_loc18_,_loc40_,_loc38_,_loc30_,_loc9_,_loc41_,_loc23_,_loc13_,_loc43_,_loc11_,_loc22_,_loc28_,_loc42_,_loc36_,null,_loc7_,null,null);
         var _loc2_:AvatarWorldView = _avatarViewList[_loc18_];
         if(_loc2_)
         {
            _loc2_.setActivePet(_loc5_,_loc10_,_loc25_,_loc14_,_loc12_);
            _loc2_.updateNameBarHealth(_loc44_);
         }
         var _loc4_:Avatar = _avatarList[_loc18_];
         if(_loc16_ && _loc16_ != "")
         {
            _loc17_ = _loc16_.split(",");
            _setAvatarAttachmentEmot(int(_loc17_[0]),_loc17_[1],_loc18_);
         }
         if(_loc31_ && _loc31_ != "")
         {
            _loc17_ = _loc31_.split("|");
            _loc15_ = _loc17_[0].split(",");
            _loc3_ = QuestXtCommManager.getScriptDef(_loc15_[0]);
            if(_loc3_)
            {
               addCustomAdventureMessage(LocalizationManager.translateIdOnly(_loc3_.titleStrId),_loc17_[1] + "|" + _loc15_[0],_loc18_,_loc15_[2],int(param1[6]));
            }
         }
         if(_loc37_ && _loc37_ != "")
         {
            _loc17_ = _loc37_.split("|");
            _loc6_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc17_[1]);
            addCustomPvpMessage(LocalizationManager.translateIdOnly(_loc6_.titleStrId),_loc37_,_loc18_,0,int(param1[6]));
         }
         QuestManager.playerJoinedQuestRoom(_loc18_);
         if(buddyCardAvatarView)
         {
            if(_loc41_.toLowerCase() == buddyCardAvatarView.userName.toLowerCase())
            {
               BuddyManager.updateCurrBuddyCardAvatar(_loc4_);
            }
         }
         ItemXtCommManager.insertAvIntoAcIlQueue(_loc30_,_loc4_,processAcIlCombo);
         processAcIlCombo(_loc41_,_loc30_,true);
      }
      
      private static function getSfsUserIdByUsernamePerUserAvId(param1:String, param2:int) : int
      {
         if(_avatarList)
         {
            for each(var _loc3_:Avatar in _avatarList)
            {
               if(_loc3_.userName.toLowerCase() == param1.toLowerCase() && _loc3_.perUserAvId == param2)
               {
                  return _loc3_.sfsUserId;
               }
            }
         }
         return -1;
      }
      
      public static function processAcIlCombo(param1:String, param2:int, param3:Boolean = false, param4:Object = null) : void
      {
         var _loc7_:* = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:Avatar = null;
         var _loc10_:int = getSfsUserIdByUsernamePerUserAvId(param1,param2);
         if(_acQueue[param1])
         {
            _loc6_ = Utility.numProperties(_acQueue[param1]);
            _loc9_ = 0;
            while(_loc9_ < _loc6_)
            {
               if(_acQueue[param1].hasOwnProperty(param2))
               {
                  if(_acQueue[param1][param2].acReceived == true && !param3)
                  {
                     _loc5_ = true;
                  }
                  else if(_acQueue[param1][param2].ilReceived == true && param3)
                  {
                     if(_avatarList[_loc10_] && _acQueue[param1][param2].ilResponse)
                     {
                        _loc8_ = _avatarList[_loc10_];
                        ItemXtCommManager.insertIntoILAvatarQueue(_loc8_.perUserAvId,null,_loc8_);
                        ItemXtCommManager.handleIlWhenBeforeACAfterReceivingAC(_acQueue[param1][param2].ilResponse);
                        _loc5_ = true;
                     }
                     else
                     {
                        ItemXtCommManager.removeFromILAvatarQueue(param1,param2);
                        _loc5_ = false;
                     }
                  }
                  if(_loc5_)
                  {
                     delete _acQueue[param1][param2];
                     if(Utility.numProperties(_acQueue[param1]) == 0)
                     {
                        delete _acQueue[param1];
                     }
                  }
               }
               _loc9_++;
            }
         }
         else
         {
            _acQueue[param1] = {};
            _acQueue[param1][param2] = {
               "ilReceived":!param3,
               "acReceived":param3,
               "ilResponse":param4
            };
         }
      }
      
      public static function getDefaultAvatarByDefId(param1:int, param2:Boolean = false) : Avatar
      {
         var _loc11_:AvatarDef = null;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:AvatarDef = gMainFrame.userInfo.getAvatarDefByAvType(param1,param2);
         if(_loc4_ == null)
         {
            trace("Error loading " + (param2 ? "customAvatarDef" : "avatarDef") + "where defId=" + param1);
            return null;
         }
         if(param2)
         {
            _loc11_ = gMainFrame.userInfo.getAvatarDefByAvType((_loc4_ as CustomAvatarDef).avatarRefId,false);
            param1 = (_loc4_ as CustomAvatarDef).avatarRefId;
         }
         else
         {
            _loc11_ = _loc4_;
         }
         var _loc7_:uint = _loc11_.colorLayer2;
         var _loc12_:AccItemCollection = new AccItemCollection();
         _loc12_.setAccItem(0,ItemXtCommManager.getBodyModFromDefId(1,param1,true,false));
         _loc12_.setAccItem(1,ItemXtCommManager.getBodyModFromDefId(_loc11_.defEyes,param1,true,false));
         if(param2)
         {
            if(_loc4_.patternRefId > 0)
            {
               _loc12_.setAccItem(2,ItemXtCommManager.getBodyModFromDefId(_loc4_.patternRefId,param1,true,false));
               _loc5_ = uint(_loc12_.getAccItem(2).colors[0]);
               _loc6_ = _loc5_ >> 24;
               _loc8_ = _loc5_ >> 16 & 0xFF;
               _loc9_ = _loc5_ >> 8 & 0xFF;
               _loc3_ = _loc5_ & 0xFF;
               _loc7_ = _loc7_ = uint(_loc6_ << 24 | _loc8_ << 16 | _loc9_ << 8 | _loc3_);
            }
         }
         else if(_loc11_.defPattern > 0)
         {
            _loc12_.setAccItem(2,ItemXtCommManager.getBodyModFromDefId(_loc11_.defPattern,param1,true,false));
         }
         var _loc10_:Array = [_loc11_.colorLayer1,_loc7_,_loc11_.colorLayer3];
         var _loc13_:Avatar = new Avatar();
         _loc13_.init(-1,"redemAvt",param1,_loc10_,param2 ? _loc4_.defId : -1);
         _loc13_.itemResponseIntegrate(_loc12_);
         return _loc13_;
      }
      
      public static function avatarRemoveResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = int(param1[2]);
         if(_waitForLangPack && _waitForLangPackSfsUserIdToACResponseDataMap[_loc3_] !== undefined)
         {
            delete _waitForLangPackSfsUserIdToACResponseDataMap[_loc3_];
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            _loc2_ = _avatarList[_loc3_].userName;
            ExternalInterface.call("mrc",["uer",_loc2_,false]);
         }
         if(param1.length > 3 && int(param1[3]) > 0)
         {
            if(_avatarViewList[_loc3_])
            {
               updateAvatar(_loc3_,int(param1[4]),int(param1[5]),false);
               _avatarViewList[_loc3_].deleteOnMoveComplete = true;
            }
         }
         else
         {
            removeAvatar(_loc3_);
         }
      }
      
      public static function toggleNamebarSelNubs(param1:BuddyEvent) : void
      {
         for each(var _loc2_:AvatarWorldView in _avatarViewList)
         {
            _loc2_.toggleNamebarSelNub();
         }
      }
      
      public static function connectionLost() : void
      {
         if(_avatarList[_playerSfsUserId])
         {
            removeAvatar(_playerSfsUserId);
         }
         _playerSfsUserId = -1;
      }
      
      public static function isValidEnviro(param1:int) : Boolean
      {
         var _loc2_:int = playerAvatar.enviroTypeFlag;
         return !((param1 & _loc2_) == 0 || (_loc2_ & 1 << 2) != 0 && (param1 & 1 << 2) == 0);
      }
      
      public static function getFlower(param1:Boolean = false) : MovieClip
      {
         var _loc4_:MovieClip = null;
         var _loc2_:* = undefined;
         var _loc3_:Loader = null;
         _loc2_ = param1 ? _flowerIdlePool : _flowerPool;
         if(_loc2_.length > 10)
         {
            _loc4_ = _loc2_.shift();
            _loc3_ = _loc4_.getChildAt(0) as Loader;
            if(_loc3_.content && !(_loc3_.content as MovieClip).readyToUse)
            {
               _loc4_ = param1 ? new FlowerIdle() : new Flower();
            }
         }
         else
         {
            _loc4_ = param1 ? new FlowerIdle() : new Flower();
         }
         _loc4_.visible = true;
         _loc2_.push(_loc4_);
         if(_layerManager == null)
         {
            _layerManager = RoomManagerWorld.instance.layerManager;
         }
         if(_loc4_.parent)
         {
            _flowerLayer.removeChild(_loc4_);
         }
         if(param1)
         {
            _layerManager.room_avatars.addChild(_loc4_);
         }
         else
         {
            _flowerLayer.addChild(_loc4_);
         }
         if(_flowerLayer.parent == null)
         {
            _layerManager.room_bkg_group.addChildAt(_flowerLayer,1);
         }
         return _loc4_;
      }
      
      public static function clearSpecialPatternLayer() : void
      {
         var _loc2_:Loader = null;
         var _loc1_:* = null;
         if(_flowerLayer)
         {
            while(_flowerLayer.numChildren > 0)
            {
               _flowerLayer.removeChildAt(0);
            }
         }
         for each(_loc1_ in _flowerIdlePool)
         {
            _loc2_ = _loc1_.getChildAt(0) as Loader;
            if(_loc2_.content)
            {
               (_loc2_.content as MovieClip).readyToUse = true;
            }
            if(_loc1_.parent)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
         }
      }
   }
}

