package avatar
{
   import buddy.BuddyEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.SortLayer;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.popup.*;
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
   import gui.BuddyCard;
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
      
      private static var _isMyAvtInPreviewRoom:Boolean;
      
      private static var _flowerPool:Vector.<MovieClip>;
      
      private static var _flowerIdlePool:Vector.<MovieClip>;
      
      private static var _flowerLayer:DisplayLayer;
      
      private static var _layerManager:LayerManager;
      
      private static const Flower:Class = SpringFlower_3_swf$6de89290a5c709e78b2080105104cfc61916305515;
      
      private static const FlowerIdle:Class = ground_idle_2_swf$04e320fb87eedb0cfb7bddf96dfc3a79442030440;
      
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
      
      public static function loadSelfAssets(param1:Function) : void
      {
         var _loc4_:* = 0;
         var _loc3_:Array = null;
         var _loc2_:Array = null;
         var _loc6_:int = 0;
         _initCallback = param1;
         var _loc5_:AvatarInfo = gMainFrame.userInfo.playerAvatarInfo;
         if(_loc5_ && _loc5_.type != -1)
         {
            _loc4_ = 0;
            if(_roomEnviroType == 0)
            {
               _loc4_ = 0;
               if(_playerSplashColorLevel)
               {
                  _loc4_ = uint(_playerSplashColorLevel << 24 | _playerSplashColor);
               }
            }
            else
            {
               _loc4_ = 0;
               clearPlayerSplashColor();
            }
            createAvatar(_playerSfsUserId,0,0,_loc5_.perUserAvId,_loc5_.avName,_loc5_.userName,_loc5_.type,_roomEnviroType == 0 ? 14 : 29,-1,_loc5_.colors,_loc4_,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,_loc5_.customAvId,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : gMainFrame.userInfo.playerUserInfo.nameBarData);
            AvatarManager.updateCustomPartyHostingDataForMyself();
            if(playerAvatar.enviroTypeFlag & 1 << 0 && playerAvatar.enviroTypeFlag & 1 << 1)
            {
               _loc3_ = [];
               _loc2_ = _loc5_.getItems(true);
               _loc6_ = 0;
               while(_loc6_ < _loc2_.length)
               {
                  if(_loc2_[_loc6_].type == 0)
                  {
                     _loc3_.push(_loc2_[_loc6_]);
                  }
                  _loc6_++;
               }
               playerAvatar.itemResponseIntegrate(_loc3_.concat(_loc5_.getFullItems(true).concat()));
            }
            else
            {
               playerAvatar.itemResponseIntegrate(_loc5_.getItems(true));
            }
            loadSelfAssetsResult(true,true);
         }
         else
         {
            createAvatar(_playerSfsUserId,0,0,gMainFrame.userInfo.myPerUserAvId,"",gMainFrame.server.userName,-1,_roomEnviroType == 0 ? 14 : 29,-1,null,0,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,-1,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : gMainFrame.userInfo.playerUserInfo.nameBarData);
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
         playerAvatar.inventoryDenFull.itemArray = gMainFrame.userInfo.playerUserInfo.denItemsFull;
         if(_previousRoomEnviroType != -1 && _previousRoomEnviroType != roomEnviroType)
         {
            playerAvatar.inventoryDenPartial.itemArray = gMainFrame.userInfo.playerUserInfo.denItemsPartial = enviroItems(gMainFrame.userInfo.playerUserInfo.denItemsFull);
         }
         else
         {
            playerAvatar.inventoryDenPartial.itemArray = gMainFrame.userInfo.playerUserInfo.denItemsPartial;
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
      
      public static function movePlayer(param1:Number, param2:Number) : void
      {
         if(_playerSfsUserId >= 0)
         {
            if(!MinigameManager.inMinigame() && !SBPopupManager.modalSBPopup)
            {
               updateAvatar(_playerSfsUserId,param1,param2,_isMyAvtInPreviewRoom ? false : true);
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
      
      private static function enviroItems(param1:Array) : Array
      {
         var _loc2_:Array = [];
         for each(var _loc3_:DenItem in param1)
         {
            if(_loc3_.enviroType == AvatarManager.roomEnviroType)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public static function createAvatar(param1:int, param2:int, param3:int, param4:int, param5:String, param6:String, param7:int, param8:int, param9:int, param10:Array, param11:uint, param12:int, param13:Boolean, param14:int, param15:AccessoryState = null, param16:int = 0, param17:Object = null, param18:Object = null) : void
      {
         var _loc26_:AvatarInfo = null;
         var _loc19_:Object = null;
         var _loc24_:Boolean = false;
         var _loc21_:Object = null;
         if(param5 == "")
         {
            param5 = gMainFrame.clientInfo.avName;
         }
         var _loc22_:Avatar = new Avatar();
         _loc22_.init(param4,param5,param7,param10,param14,param15,param6,param1,_roomEnviroType);
         _avatarList[param1] = _loc22_;
         if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            if(AvatarManager.playerAvatarWorldView)
            {
               AvatarManager.playerAvatarWorldView.resetAvatar(_loc22_);
            }
         }
         var _loc23_:AvatarWorldView = new AvatarWorldView();
         _loc23_.initWorldView(_loc22_,param18 != null ? param18 : _chatLayer,param12,param13,false,GuiManager.actionMgr,GuiManager,param16,_roomEnviroType);
         _loc23_.setPos(param2,param3,false);
         if(param11 > 0)
         {
            _loc23_.setBlendColor(param11);
         }
         if(gMainFrame.clientInfo.roomType == 7)
         {
            if(_offScreenMap[param1] == null)
            {
               _offScreenMap[param1] = new Dictionary(false);
            }
         }
         var _loc20_:int = param8 & 0x07FFFFFF;
         var _loc27_:Boolean = param8 & 0x80000000 ? true : false;
         _loc23_.playAnim(_loc20_,_loc27_);
         _avatarViewList[param1] = _loc23_;
         if(gMainFrame.clientInfo.roomType == 7)
         {
            _adventurePlayerData[param1] = {
               "isMember":Utility.isMember(param12),
               "nameBarData":param16,
               "userName":param6,
               "avName":param5
            };
            _loc26_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc22_.userName);
            if(_loc26_ && _loc26_.questTorchStatus)
            {
               QuestManager.addTorch(_loc23_,1.3,-15,-50);
            }
         }
         if(!_isMyAvtInPreviewRoom || _chatLayer.visible == true)
         {
            _loc23_.visible = _chatLayer.visible;
         }
         if(param9 > 0)
         {
            _avatarViewList[param1].setEmote(null,param9);
         }
         var _loc25_:int = int(gMainFrame.server.userId);
         if(param1 != _loc25_)
         {
            if(_avatarViewList[_loc25_])
            {
               _avatarViewList[_loc25_].moveToFront();
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
                  if(param7 == -1)
                  {
                     _needToResetPet = true;
                  }
                  else
                  {
                     _needToResetPet = false;
                  }
                  _loc19_ = PetManager.myActivePet;
                  if(_loc19_)
                  {
                     _loc23_.setActivePet(_loc19_.lBits,_loc19_.uBits,_loc19_.eBits,_loc19_.name,_playerPetSparkleId);
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
                  _loc23_.setCustomAdventureMessage(_playerCustomPVP.infoText,_playerCustomPVP.userMessage,_playerCustomPVP.difficulty,_playerCustomPVP.severity,true);
               }
               if(_playerCustomAdventure)
               {
                  _loc23_.setCustomAdventureMessage(_playerCustomAdventure.infoText,_playerCustomAdventure.userMessage,_playerCustomAdventure.difficulty,_playerCustomAdventure.severity,false);
               }
            }
            DebugUtility.debugTrace("ghostMode - creating self avatar - ghostMode:" + gMainFrame.clientInfo.invisMode);
            if(gMainFrame.clientInfo.invisMode)
            {
               _loc23_.alpha = 0.5;
            }
            else
            {
               _loc23_.alpha = _playerAlpha / 100;
            }
         }
         if(param17 != null)
         {
            param17.addChild(_loc23_);
            if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _lastKnownAvtViewParent = param17;
            }
         }
         else if(GuiManager.isBeYourPetRoom())
         {
            _loc24_ = true;
            if(param1 == _loc25_)
            {
               _loc24_ = _loc23_.isActivePetGroundPet();
            }
            else
            {
               _loc26_ = gMainFrame.userInfo.getAvatarInfoByUserName(param6);
               if(_loc26_)
               {
                  _loc21_ = _loc26_.currPet;
                  if(_loc21_)
                  {
                     _loc24_ = PetManager.isGround(PetManager.petTypeForDefId(_loc21_.lBits & 0xFF));
                  }
               }
            }
            if(_loc24_)
            {
               _avLayer.addChild(_loc23_);
               if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
               {
                  _lastKnownAvtViewParent = _avLayer;
               }
            }
            else
            {
               _flyingAvLayer.addChild(_loc23_);
               if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
               {
                  _lastKnownAvtViewParent = _flyingAvLayer;
               }
            }
         }
         else if(!(_loc22_.enviroTypeFlag & 1 << 2))
         {
            _avLayer.addChild(_loc23_);
            if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _lastKnownAvtViewParent = _avLayer;
            }
         }
         else
         {
            _flyingAvLayer.addChild(_loc23_);
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
         var _loc3_:Object = null;
         var _loc5_:int = 0;
         var _loc4_:NPCView = null;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc3_ = QuestManager.getNPCDef(param1[_loc5_]);
            _loc4_ = new NPCView();
            _loc4_.init(_loc3_.defId,_loc5_,_loc3_.titleStrId,_loc3_.avatarRefId,false,null);
            _loc4_.x = param2[_loc5_].x;
            _loc4_.y = param2[_loc5_].y;
            _loc4_.addEventListener("mouseDown",onNPCDown,false,0,true);
            _avLayer.addChild(_loc4_);
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
         var _loc8_:int = 0;
         if(!_avatarList[param1])
         {
            DebugUtility.debugTrace("updateAvatar(): ERROR: sfsUserId:" + param1 + " not found in _avatarList:" + _avatarList);
            return;
         }
         var _loc9_:AvatarWorldView = _avatarViewList[param1];
         _loc9_.setPos(param2,param3,param5);
         if(param4 && !joiningNewRoom && param1 == _playerSfsUserId && !gMainFrame.clientInfo.invisMode)
         {
            _loc7_ = new Point(param2,param3);
            _loc8_ = _loc9_.lastIdleAnim | (_loc9_.lastIdleFlip ? 2147483648 : 0);
            if(_throttle == 0)
            {
               if(_lastSentPositions.length > 0 && _loc7_.equals(_lastSentPositions[_lastSentPositions.length - 1]))
               {
                  return;
               }
               gMainFrame.server.setXtObject_Str("au",["1",param2,param3,_loc8_,param6 ? "1" : "0"]);
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
               _lastThrottledPackAnimFlip = _loc8_;
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
         var _loc1_:Array = null;
         var _loc3_:Point = null;
         var _loc2_:Point = null;
         var _loc4_:int = int(_lastThrottledPositions.length);
         if(_loc4_ == 0)
         {
            return;
         }
         if(_loc4_ == 1)
         {
            _loc3_ = _lastThrottledPositions[0];
            _lastThrottledPositions.length = 0;
            if(_loc3_.equals(_lastSentPositions[_lastSentPositions.length - 1]))
            {
               return;
            }
            _loc1_ = [1,_loc3_.x,_loc3_.y];
            _lastSentPositions.push(new Point(_loc3_.x,_loc3_.y));
         }
         else if(_loc4_ > 1)
         {
            _loc3_ = _lastThrottledPositions[_loc4_ - 2];
            _loc2_ = _lastThrottledPositions[_loc4_ - 1];
            _lastThrottledPositions.length = 0;
            if(_lastSentPositions.length == 2 && _loc3_.equals(_lastSentPositions[0]) && _loc2_.equals(_lastSentPositions[1]))
            {
               return;
            }
            _loc1_ = [2,_loc3_.x,_loc3_.y,_loc2_.x,_loc2_.y];
            _lastSentPositions.push(_loc3_);
            _lastSentPositions.push(_loc2_);
         }
         _loc1_.push(_lastThrottledPackAnimFlip);
         _loc1_.push("0");
         gMainFrame.server.setXtObject_Str("au",_loc1_);
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
            _avatarViewList[param2].setMessage(param1,param3);
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
         var _loc2_:Point = null;
         var _loc4_:Point = null;
         var _loc3_:int = 0;
         if(param1 != gMainFrame.server.userId)
         {
            if(AvatarManager.playerAvatarWorldView != null)
            {
               _loc2_ = _avatarViewList[param1].avatarPos;
               _loc4_ = AvatarManager.playerAvatarWorldView.avatarPos;
               _loc3_ = Math.sqrt((_loc2_.x - _loc4_.x) * (_loc2_.x - _loc4_.x) + (_loc2_.y - _loc4_.y) * (_loc2_.y - _loc4_.y));
               if(_loc3_ < 100)
               {
                  if(_avatarViewList[param1].lastIdleAnim == 17 && AvatarManager.playerAvatarWorldView.lastIdleAnim == 22)
                  {
                     movePlayer(_loc4_.x + 1,_loc4_.y);
                  }
                  else if(_avatarViewList[param1].lastIdleAnim == 22 && AvatarManager.playerAvatarWorldView.lastIdleAnim == 17)
                  {
                     updateAvatar(param1,_loc4_.x + 1,_loc4_.y,false);
                  }
               }
            }
         }
         else if(_avatarViewList[param1].lastIdleAnim == 22)
         {
            for each(var _loc5_:AvatarWorldView in _avatarViewList)
            {
               if(_loc5_.userId != param1)
               {
                  if(_loc5_.lastIdleAnim == 17)
                  {
                     _loc2_ = _loc5_.avatarPos;
                     _loc4_ = _avatarViewList[param1].avatarPos;
                     _loc3_ = Math.sqrt((_loc2_.x - _loc4_.x) * (_loc2_.x - _loc4_.x) + (_loc2_.y - _loc4_.y) * (_loc2_.y - _loc4_.y));
                     if(_loc3_ < 100)
                     {
                        movePlayer(_loc4_.x,_loc4_.y);
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
         var _loc4_:Object = null;
         var _loc5_:AvatarWorldView = _avatarViewList[param1];
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:WorldPet = _loc5_.getActivePet();
         if(!_loc6_)
         {
            return;
         }
         _loc6_.setAction(param2,param3);
         if(param1 == playerSfsUserId && param2 == 1)
         {
            _playerPetSparkleId = param3;
            if(_playerPetSparkleId > 0)
            {
               _loc4_ = PetManager.myActivePet;
               if(_loc4_)
               {
                  _loc4_.isSparkling = true;
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
         var _loc6_:MovieClip = null;
         if(!_avatarList[param1] || !_avatarViewList[param1])
         {
            if(param2)
            {
               _loc6_ = _avatarViewOffScreenHud[param1];
               if(_loc6_)
               {
                  if(_loc6_.parent && _loc6_.parent == GuiManager.guiLayer)
                  {
                     GuiManager.guiLayer.removeChild(_loc6_);
                  }
                  _loc6_ = null;
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
         if(BuddyCard.currBuddyCardUserName == _avatarList[param1].userName.toLowerCase())
         {
            BuddyCard.avatarLeftRoom();
         }
         var _loc4_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_avatarList[param1].userName,_avatarList[param1].perUserAvId);
         if(gMainFrame.clientInfo.roomType == 7 && (param1 == _playerSfsUserId || _loc4_ && _loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && _loc4_.perUserAvId == gMainFrame.userInfo.myPerUserAvId))
         {
            for each(var _loc5_:AvatarWorldView in _avatarViewList)
            {
               delete _avatarViewList[_loc5_.avatarData.sfsUserId];
               _avatarList[_loc5_.avatarData.sfsUserId].destroy();
               delete _avatarList[_loc5_.avatarData.sfsUserId];
               _loc5_.destroy();
               _loc5_ = null;
            }
         }
         else
         {
            if(param1 != _playerSfsUserId || _loc4_ && _loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && _loc4_.perUserAvId == gMainFrame.userInfo.myPerUserAvId)
            {
               _avatarList[param1].destroy();
            }
            _avatarViewList[param1].destroy();
            _avatarViewList[param1] = null;
            delete _avatarViewList[param1];
         }
         if(param1 == _playerSfsUserId || _avatarList[param1] && _loc4_ && _loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && _loc4_.perUserAvId == gMainFrame.userInfo.myPerUserAvId)
         {
            for each(var _loc3_:MovieClip in _avatarViewOffScreenHud)
            {
               if(_loc3_.parent && _loc3_.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc3_);
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
            _loc6_ = _avatarViewOffScreenHud[param1];
            if(_loc6_)
            {
               if(_loc6_.parent && _loc6_.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc6_);
               }
               _loc6_ = null;
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
      }
      
      public static function heartbeat(param1:int, param2:int) : void
      {
         var _loc4_:AvatarWorldView = null;
         var _loc3_:Array = [];
         for(var _loc5_:Object in _avatarList)
         {
            _loc4_ = _avatarViewList[_loc5_];
            if(_loc4_ && !_loc4_.heartbeat(param1,param2))
            {
               _loc3_.push(_loc5_);
            }
         }
         while(_loc3_.length > 0)
         {
            removeAvatar(_loc3_.pop());
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
         var _loc4_:int = 0;
         var _loc6_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc1_:Object = null;
         var _loc5_:AvatarWorldView = playerAvatarWorldView;
         if(_loc5_ == null)
         {
            return;
         }
         if(_loc5_.inSplashVolume() && !AvatarSwitch.isSwitching())
         {
            _loc4_ = 20;
            _loc6_ = false;
            _loc2_ = false;
            switch(_loc5_.splashLiquid)
            {
               case "mud":
                  _playerSplashColor = 6045747;
                  _playerSplashColorLevelMax = 255;
                  if(_playerSplashColorLevel < 100)
                  {
                     _playerSplashColorLevel = 100;
                  }
                  _loc1_ = PetManager.myActivePet;
                  if(_loc1_ && _loc1_.isGround && _loc1_.isSparkling)
                  {
                     _loc1_.isSparkling = false;
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
                  _loc4_ = 10;
                  _loc6_ = true;
                  break;
               case "fire":
                  _playerSplashColor = 11141120;
                  _playerSplashColorLevelMax = 200;
                  if(_playerSplashColorLevel < 60)
                  {
                     _playerSplashColorLevel = 60;
                  }
                  _loc4_ = 10;
                  _loc6_ = true;
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
                  _loc4_ = 10;
                  break;
               case "fallleaves":
                  handleNotInSplashUpdates();
                  _loc2_ = true;
            }
            if(!_loc2_ && (_loc5_.isSplashAnim() || _loc6_))
            {
               if(_playerSplashColorLevel < _playerSplashColorLevelMax && --_playerSplashColorCountdown < 0)
               {
                  _playerSplashColorCountdown = 10;
                  _playerSplashColorLevel += _loc4_;
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
               _loc5_.setBlendColor(_loc3_);
               _lastPlayerSplashColor = _loc3_;
               UserCommXtCommManager.sendAvatarBlendColor(_loc3_);
            }
            if(_lastPlayerAlpha != _playerAlpha)
            {
               _loc5_.setAlphaLevel(_playerAlpha);
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
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         var _loc10_:Array = null;
         var _loc7_:AvatarWorldView = null;
         var _loc6_:Point = null;
         var _loc9_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 2;
         var _loc11_:int = int(param1[_loc5_++]);
         if(_loc11_ <= 0)
         {
            throw new Error("got empty \'au\' from server!");
         }
         _loc4_ = 0;
         while(_loc4_ < _loc11_)
         {
            _loc2_ = int(param1[_loc5_++]);
            _loc3_ = int(param1[_loc5_++]);
            if(_loc3_ <= 0)
            {
               throw new Error("got empty position update from server!");
            }
            _loc8_ = 0;
            _loc10_ = [];
            while(_loc8_ < _loc3_)
            {
               _loc10_.push(new Point(int(param1[_loc5_++]),int(param1[_loc5_++])));
               _loc8_++;
            }
            _loc9_ = param1[_loc5_++] != "0";
            if(_loc2_ != _playerSfsUserId)
            {
               _loc7_ = _avatarViewList[_loc2_];
               if(_loc7_ != null)
               {
                  if(!_loc9_)
                  {
                     _loc7_.setPath(_loc10_);
                  }
                  else
                  {
                     _loc6_ = _loc10_[_loc10_.length - 1];
                     _loc7_.setPos(_loc6_.x,_loc6_.y,false);
                  }
               }
            }
            _loc4_++;
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
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc35_:int = 0;
         var _loc36_:int = 0;
         var _loc9_:String = null;
         var _loc18_:* = 0;
         var _loc29_:Boolean = false;
         var _loc30_:String = null;
         var _loc32_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:int = 0;
         var _loc22_:String = null;
         var _loc17_:String = null;
         var _loc28_:int = 0;
         var _loc25_:UserInfo = null;
         var _loc11_:UserInfo = null;
         var _loc10_:Array = null;
         var _loc45_:Array = null;
         var _loc27_:Array = null;
         var _loc6_:Object = null;
         var _loc16_:MinigameInfo = null;
         if(_waitForLangPack)
         {
            _waitForLangPackSfsUserIdToACResponseDataMap[param1[2]] = param1;
            return;
         }
         var _loc39_:int = 2;
         var _loc23_:int = int(param1[_loc39_++]);
         var _loc21_:int = int(param1[_loc39_++]);
         var _loc19_:int = int(param1[_loc39_++]);
         var _loc7_:int = int(param1[_loc39_++]);
         var _loc41_:String = param1[_loc39_++];
         var _loc20_:String = param1[_loc39_++];
         var _loc40_:int = int(param1[_loc39_++]);
         var _loc2_:String = param1[_loc39_++];
         var _loc24_:int = int(param1[_loc39_++]);
         var _loc26_:int = int(param1[_loc39_++]);
         var _loc38_:Array = [uint(param1[_loc39_++]),uint(param1[_loc39_++]),uint(param1[_loc39_++])];
         var _loc37_:int = int(param1[_loc39_++]);
         var _loc33_:int = int(gMainFrame.clientInfo.roomType == 7 ? int(param1[_loc39_++]) : 0);
         var _loc31_:Boolean = gMainFrame.clientInfo.roomType == 7 ? param1[_loc39_++] == 1 : false;
         var _loc42_:int = int(param1[_loc39_++]);
         var _loc15_:int = int(param1[_loc39_++]);
         var _loc44_:int = 1;
         var _loc34_:int = 0;
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc44_ = int(param1[_loc39_++]);
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc5_ = int(param1[_loc39_++]);
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc3_ = int(param1[_loc39_++]);
            _loc35_ = int(param1[_loc39_++]);
            _loc36_ = int(param1[_loc39_++]);
            _loc9_ = param1[_loc39_++];
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc18_ = uint(param1[_loc39_++]);
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc29_ = Boolean(int(param1[_loc39_++]));
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc30_ = param1[_loc39_++];
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc32_ = int(param1[_loc39_++]);
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc4_ = int(param1[_loc39_++]);
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc8_ = int(param1[_loc39_++]);
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc22_ = param1[_loc39_++];
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc17_ = param1[_loc39_++];
         }
         if(_loc15_ & 1 << _loc34_++)
         {
            _loc28_ = int(param1[_loc39_++]);
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            ExternalInterface.call("mrc",["uer",_loc41_,true]);
            DebugUtility.debugTrace("mrc uer sent, checking goto user - RoomXtCommManager.loadingNewRoom:" + RoomXtCommManager.loadingNewRoom + " user:" + _loc41_);
            if(!RoomXtCommManager.loadingNewRoom)
            {
               RoomManagerWorld.instance.modGotoUser(_loc41_,_loc21_,_loc19_);
            }
         }
         var _loc12_:Object = {
            "name":_loc9_,
            "lBits":_loc3_,
            "uBits":_loc35_,
            "eBits":_loc36_
         };
         _loc12_.defId = PetManager.getDefIdFromLBits(_loc12_.lBits);
         _loc12_.type = PetManager.petTypeForDefId(_loc12_.defId);
         _loc12_.isGround = PetManager.isGround(_loc12_.type);
         var _loc14_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc41_,_loc40_);
         if(_loc14_)
         {
            _loc14_.avName = _loc2_;
            _loc14_.type = _loc24_;
            _loc14_.colors = _loc38_;
            _loc14_.currEnviroType = _roomEnviroType;
            _loc14_.questLevel = _loc37_;
            _loc14_.questXp = 0;
            _loc14_.questXPPercentage = 0;
            _loc14_.questHealthPercentage = _loc33_;
            _loc14_.questTorchStatus = _loc31_;
            _loc14_.currPet = _loc12_;
            _loc14_.customAvId = _loc26_;
            _loc25_ = gMainFrame.userInfo.getUserInfoByUserName(_loc41_);
            _loc25_.accountType = _loc44_;
            _loc25_.isGuide = _loc29_;
            _loc25_.nameBarData = _loc5_;
            _loc25_.userNameModeratedFlag = _loc42_;
            _loc25_.timeLeftHostingCustomParty = _loc28_;
         }
         else
         {
            _loc11_ = new UserInfo();
            _loc14_ = new AvatarInfo();
            _loc14_.init(_loc40_,_loc2_,_loc41_,_loc20_,_loc24_,_loc38_,0,_loc12_,_loc26_,0,0,_loc37_);
            _loc14_.questHealthPercentage = _loc33_;
            _loc14_.questTorchStatus = _loc31_;
            _loc10_ = [];
            _loc10_[_loc14_.perUserAvId] = _loc14_;
            _loc11_.init(_loc41_,_loc20_,_loc10_,_loc14_.perUserAvId);
            _loc11_.accountType = _loc44_;
            _loc11_.isGuide = _loc29_;
            _loc11_.nameBarData = _loc5_;
            _loc11_.userNameModeratedFlag = _loc42_;
            _loc11_.timeLeftHostingCustomParty = _loc28_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc41_,_loc11_);
         }
         createAvatar(_loc23_,_loc21_,_loc19_,_loc40_,_loc2_,_loc41_,_loc24_,_loc7_,_loc32_,_loc38_,_loc18_,_loc44_,_loc29_,_loc26_,null,_loc5_,null,null);
         var _loc13_:AvatarWorldView = _avatarViewList[_loc23_];
         if(_loc13_)
         {
            _loc13_.setActivePet(_loc3_,_loc35_,_loc36_,_loc9_,_loc4_);
            _loc13_.updateNameBarHealth(_loc33_);
         }
         var _loc43_:Avatar = _avatarList[_loc23_];
         if(_loc30_ && _loc30_ != "")
         {
            _loc45_ = _loc30_.split(",");
            _setAvatarAttachmentEmot(int(_loc45_[0]),_loc45_[1],_loc23_);
         }
         if(_loc22_ && _loc22_ != "")
         {
            _loc45_ = _loc22_.split("|");
            _loc27_ = _loc45_[0].split(",");
            _loc6_ = QuestXtCommManager.getScriptDef(_loc27_[0]);
            if(_loc6_)
            {
               addCustomAdventureMessage(LocalizationManager.translateIdOnly(_loc6_.titleStrId),_loc45_[1] + "|" + _loc27_[0],_loc23_,_loc27_[2],int(param1[6]));
            }
         }
         if(_loc17_ && _loc17_ != "")
         {
            _loc45_ = _loc17_.split("|");
            _loc16_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc45_[1]);
            addCustomPvpMessage(LocalizationManager.translateIdOnly(_loc16_.titleStrId),_loc17_,_loc23_,0,int(param1[6]));
         }
         QuestManager.playerJoinedQuestRoom(_loc23_);
         if(buddyCardAvatarView)
         {
            if(_loc41_.toLowerCase() == buddyCardAvatarView.userName.toLowerCase())
            {
               BuddyCard.updateCurrBuddyCardAvatar(_loc43_);
            }
         }
         ItemXtCommManager.insertAvIntoAcIlQueue(_loc40_,_loc43_,processAcIlCombo);
         processAcIlCombo(_loc41_,_loc40_,true);
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
         var _loc9_:* = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:Avatar = null;
         var _loc8_:int = getSfsUserIdByUsernamePerUserAvId(param1,param2);
         if(_acQueue[param1])
         {
            _loc6_ = Utility.numProperties(_acQueue[param1]);
            _loc10_ = 0;
            while(_loc10_ < _loc6_)
            {
               if(_acQueue[param1].hasOwnProperty(param2))
               {
                  if(_acQueue[param1][param2].acReceived == true && !param3)
                  {
                     _loc5_ = true;
                  }
                  else if(_acQueue[param1][param2].ilReceived == true && param3)
                  {
                     if(_avatarList[_loc8_] && _acQueue[param1][param2].ilResponse)
                     {
                        _loc7_ = _avatarList[_loc8_];
                        ItemXtCommManager.insertIntoILAvatarQueue(_loc7_.perUserAvId,null,_loc7_);
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
               _loc10_++;
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
         var _loc4_:Object = null;
         var _loc13_:* = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:int = 0;
         var _loc10_:Object = gMainFrame.userInfo.getAvatarDefByAvType(param1,param2);
         if(_loc10_ == null)
         {
            trace("Error loading " + (param2 ? "customAvatarDef" : "avatarDef") + "where defId=" + param1);
            return null;
         }
         if(param2)
         {
            _loc4_ = gMainFrame.userInfo.getAvatarDefByAvType(_loc10_.avatarRefId,false);
            param1 = int(_loc10_.avatarRefId);
         }
         else
         {
            _loc4_ = _loc10_;
         }
         var _loc11_:uint = uint(_loc4_.colorLayer2);
         var _loc12_:Array = [];
         _loc12_[0] = ItemXtCommManager.getBodyModFromDefId(1,param1,true,false);
         _loc12_[1] = ItemXtCommManager.getBodyModFromDefId(_loc4_.defEyes,param1,true,false);
         if(param2)
         {
            if(_loc10_.patternRefId > 0)
            {
               _loc12_[2] = ItemXtCommManager.getBodyModFromDefId(_loc10_.patternRefId,param1,true,false);
               _loc13_ = uint(_loc12_[2].colors[0]);
               _loc5_ = _loc13_ >> 24;
               _loc6_ = _loc13_ >> 16 & 0xFF;
               _loc8_ = _loc13_ >> 8 & 0xFF;
               _loc3_ = _loc13_ & 0xFF;
               _loc11_ = _loc11_ = uint(_loc5_ << 24 | _loc6_ << 16 | _loc8_ << 8 | _loc3_);
            }
         }
         else if(_loc4_.defPattern > 0)
         {
            _loc12_[2] = ItemXtCommManager.getBodyModFromDefId(_loc4_.defPattern,param1,true,false);
         }
         var _loc7_:Array = [_loc4_.colorLayer1,_loc11_,_loc4_.colorLayer3];
         var _loc9_:Avatar = new Avatar();
         _loc9_.init(-1,"redemAvt",param1,_loc7_,param2 ? _loc10_.id : -1);
         _loc9_.itemResponseIntegrate(_loc12_);
         return _loc9_;
      }
      
      public static function avatarRemoveResponse(param1:Array) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = int(param1[2]);
         if(_waitForLangPack && _waitForLangPackSfsUserIdToACResponseDataMap[_loc2_] !== undefined)
         {
            delete _waitForLangPackSfsUserIdToACResponseDataMap[_loc2_];
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            _loc3_ = _avatarList[_loc2_].userName;
            ExternalInterface.call("mrc",["uer",_loc3_,false]);
         }
         if(param1.length > 3 && int(param1[3]) > 0)
         {
            if(_avatarViewList[_loc2_])
            {
               updateAvatar(_loc2_,int(param1[4]),int(param1[5]),false);
               _avatarViewList[_loc2_].deleteOnMoveComplete = true;
            }
         }
         else
         {
            removeAvatar(_loc2_);
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
         var _loc3_:* = undefined;
         var _loc2_:Loader = null;
         _loc3_ = param1 ? _flowerIdlePool : _flowerPool;
         if(_loc3_.length > 10)
         {
            _loc4_ = _loc3_.shift();
            _loc2_ = _loc4_.getChildAt(0) as Loader;
            if(_loc2_.content && !(_loc2_.content as MovieClip).readyToUse)
            {
               _loc4_ = param1 ? new FlowerIdle() : new Flower();
            }
         }
         else
         {
            _loc4_ = param1 ? new FlowerIdle() : new Flower();
         }
         _loc4_.visible = true;
         _loc3_.push(_loc4_);
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
         var _loc1_:Loader = null;
         var _loc2_:* = null;
         if(_flowerLayer)
         {
            while(_flowerLayer.numChildren > 0)
            {
               _flowerLayer.removeChildAt(0);
            }
         }
         for each(_loc2_ in _flowerIdlePool)
         {
            _loc1_ = _loc2_.getChildAt(0) as Loader;
            if(_loc1_.content)
            {
               (_loc1_.content as MovieClip).readyToUse = true;
            }
            if(_loc2_.parent)
            {
               _loc2_.parent.removeChild(_loc2_);
            }
         }
      }
   }
}

