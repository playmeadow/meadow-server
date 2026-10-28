package avatar
{
   import buddy.BuddyEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
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
   import item.Item;
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
      
      public static var joiningNewRoom:Boolean;
      
      private static var _avLayer:SortLayer;
      
      private static var _flyingAvLayer:SortLayer;
      
      private static var _previewRoomAvLayer:SortLayer;
      
      private static var _previewFlyingRoomAvLayer:SortLayer;
      
      private static var _chatLayer:DisplayLayer;
      
      private static var _avatarList:Object;
      
      private static var _avatarViewList:Object;
      
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
      
      public static const THROTTLE_SEND_PLAYER_COLOR:int = 12;
      
      public static const GHOST_MIN_ALPHA:int = 45;
      
      private static var _playerSfsUserId:int = -1;
      
      private static var _playerAlpha:uint = 100;
      
      private static const Flower:Class = AvatarManager_Flower;
      
      private static const FlowerIdle:Class = AvatarManager_FlowerIdle;
      
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
         _avatarList = new Object();
         _avatarViewList = new Object();
         _avatarViewOffScreenHud = new Object();
         _avatarAttachmentOffscreen = new Dictionary();
         _adventurePlayerData = new Object();
         _offScreenMap = new Object();
         _playerSfsUserId = gMainFrame.server.userId;
         _acQueue = new Object();
         _previousRoomEnviroType = -1;
         _waitForLangPack = false;
         _waitForLangPackSfsUserIdToACResponseDataMap = new Object();
         _lastThrottledPositions = new Vector.<Point>();
         _lastSentPositions = new Vector.<Point>();
         _flowerPool = new Vector.<MovieClip>();
         _flowerIdlePool = new Vector.<MovieClip>();
         _flowerLayer = new DisplayLayer();
         BuddyManager.eventDispatcher.addEventListener(BuddyEvent.BUDDY_CHANGED,toggleNamebarSelNubs,false,0,true);
      }
      
      public static function set playerSfsUserId(param1:int) : void
      {
         _playerSfsUserId = param1;
      }
      
      public static function showAvtAndChatLayers(param1:Boolean) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = _avLayer.numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = _avLayer.getChildAt(_loc4_);
            if(_loc3_ is AvatarWorldView)
            {
               _loc3_.visible = param1;
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
         var _loc3_:uint = 0;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         _initCallback = param1;
         var _loc2_:AvatarInfo = gMainFrame.userInfo.playerAvatarInfo;
         if(Boolean(_loc2_) && _loc2_.type != -1)
         {
            _loc3_ = 0;
            if(_roomEnviroType == SbiConstants.ENVIRO_LAND)
            {
               _loc3_ = 0;
               if(_playerSplashColorLevel)
               {
                  _loc3_ = uint(_playerSplashColorLevel << 24 | _playerSplashColor);
               }
            }
            else
            {
               _loc3_ = 0;
               clearPlayerSplashColor();
            }
            createAvatar(_playerSfsUserId,0,0,_loc2_.perUserAvId,_loc2_.avName,_loc2_.userName,_loc2_.type,_roomEnviroType == SbiConstants.ENVIRO_LAND ? LayerAnim.AN_IDLE_SE : LayerAnim.AN_SWIM_E,-1,_loc2_.colors,_loc3_,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,_loc2_.customAvId,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : int(gMainFrame.userInfo.playerUserInfo.nameBarData));
            if(Boolean(playerAvatar.enviroTypeFlag & 1 << SbiConstants.ENVIRO_LAND) && Boolean(playerAvatar.enviroTypeFlag & 1 << SbiConstants.ENVIRO_OCEAN))
            {
               _loc4_ = [];
               _loc5_ = _loc2_.getItems(true);
               _loc6_ = 0;
               while(_loc6_ < _loc5_.length)
               {
                  if(_loc5_[_loc6_].type == Item.BODY_MOD_TYPE)
                  {
                     _loc4_.push(_loc5_[_loc6_]);
                  }
                  _loc6_++;
               }
               playerAvatar.itemResponseIntegrate(_loc4_.concat(_loc2_.getFullItems(true).concat()));
            }
            else
            {
               playerAvatar.itemResponseIntegrate(_loc2_.getItems(true));
            }
            loadSelfAssetsResult(true,true);
         }
         else
         {
            createAvatar(_playerSfsUserId,0,0,gMainFrame.userInfo.myPerUserAvId,"",gMainFrame.server.userName,-1,_roomEnviroType == SbiConstants.ENVIRO_LAND ? LayerAnim.AN_IDLE_SE : LayerAnim.AN_SWIM_E,-1,null,0,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,-1,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : int(gMainFrame.userInfo.playerUserInfo.nameBarData));
            AvatarXtCommManager.requestADForAvatar(gMainFrame.userInfo.myPerUserAvId,true,loadSelfAssetsResult,playerAvatar);
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
         if(!(playerAvatar.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR))
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
         var _loc1_:Dictionary = null;
         for each(_loc1_ in _offScreenMap)
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
               if(!(playerAvatar.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR))
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
         var _loc3_:DenItem = null;
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
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
         var _loc23_:AvatarInfo = null;
         var _loc25_:Object = null;
         var _loc26_:Boolean = false;
         var _loc27_:Object = null;
         if(param5 == "")
         {
            param5 = gMainFrame.clientInfo.avName;
         }
         var _loc19_:Avatar = new Avatar();
         _loc19_.init(param4,param5,param7,param10,param14,param15,param6,param1,_roomEnviroType);
         _avatarList[param1] = _loc19_;
         if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            if(AvatarManager.playerAvatarWorldView)
            {
               AvatarManager.playerAvatarWorldView.resetAvatar(_loc19_);
            }
         }
         var _loc20_:AvatarWorldView = new AvatarWorldView();
         _loc20_.initWorldView(_loc19_,param18 != null ? param18 : _chatLayer,param12,param13,false,GuiManager.actionMgr,GuiManager,param16,_roomEnviroType);
         _loc20_.setPos(param2,param3,false);
         if(param11 > 0)
         {
            _loc20_.setBlendColor(param11);
         }
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST)
         {
            if(_offScreenMap[param1] == null)
            {
               _offScreenMap[param1] = new Dictionary(false);
            }
         }
         var _loc21_:int = param8 & 0x07FFFFFF;
         var _loc22_:Boolean = param8 & 0x80000000 ? true : false;
         _loc20_.playAnim(_loc21_,_loc22_);
         _avatarViewList[param1] = _loc20_;
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST)
         {
            _adventurePlayerData[param1] = {
               "isMember":Utility.isMember(param12),
               "nameBarData":param16,
               "userName":param6,
               "avName":param5
            };
            _loc23_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc19_.userName);
            if((Boolean(_loc23_)) && _loc23_.questTorchStatus)
            {
               QuestManager.addTorch(_loc20_,QuestManager.QUEST_TORCH_LITSIZE,-15,-50);
            }
         }
         if(!_isMyAvtInPreviewRoom || _chatLayer.visible == true)
         {
            _loc20_.visible = _chatLayer.visible;
         }
         if(param9 > 0)
         {
            _avatarViewList[param1].setEmote(null,param9);
         }
         var _loc24_:int = int(gMainFrame.server.userId);
         if(param1 != _loc24_)
         {
            if(_avatarViewList[_loc24_])
            {
               _avatarViewList[_loc24_].moveToFront();
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
                  _loc25_ = PetManager.myActivePet;
                  if(_loc25_)
                  {
                     _loc20_.setActivePet(_loc25_.lBits,_loc25_.uBits,_loc25_.eBits,_loc25_.name,_playerPetSparkleId);
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
                  _loc20_.setCustomAdventureMessage(_playerCustomPVP.infoText,_playerCustomPVP.userMessage,_playerCustomPVP.difficulty,_playerCustomPVP.severity,true);
               }
               if(_playerCustomAdventure)
               {
                  _loc20_.setCustomAdventureMessage(_playerCustomAdventure.infoText,_playerCustomAdventure.userMessage,_playerCustomAdventure.difficulty,_playerCustomAdventure.severity,false);
               }
            }
            DebugUtility.debugTrace("ghostMode - creating self avatar - ghostMode:" + gMainFrame.clientInfo.invisMode);
            if(gMainFrame.clientInfo.invisMode)
            {
               _loc20_.alpha = 0.5;
            }
            else
            {
               _loc20_.alpha = _playerAlpha / 100;
            }
         }
         if(param17 != null)
         {
            param17.addChild(_loc20_);
            if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _lastKnownAvtViewParent = param17;
            }
         }
         else if(GuiManager.isBeYourPetRoom())
         {
            _loc26_ = true;
            if(param1 == _loc24_)
            {
               _loc26_ = _loc20_.isActivePetGroundPet();
            }
            else
            {
               _loc23_ = gMainFrame.userInfo.getAvatarInfoByUserName(param6);
               if(_loc23_)
               {
                  _loc27_ = _loc23_.currPet;
                  if(_loc27_)
                  {
                     _loc26_ = PetManager.isGround(PetManager.petTypeForDefId(_loc27_.lBits & 0xFF));
                  }
               }
            }
            if(_loc26_)
            {
               _avLayer.addChild(_loc20_);
               if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
               {
                  _lastKnownAvtViewParent = _avLayer;
               }
            }
            else
            {
               _flyingAvLayer.addChild(_loc20_);
               if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
               {
                  _lastKnownAvtViewParent = _flyingAvLayer;
               }
            }
         }
         else if(!(_loc19_.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR))
         {
            _avLayer.addChild(_loc20_);
            if(param6.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _lastKnownAvtViewParent = _avLayer;
            }
         }
         else
         {
            _flyingAvLayer.addChild(_loc20_);
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
            if(Boolean(_loc1_) && Boolean(playerAvatarWorldView))
            {
               playerAvatarWorldView.setActivePet(_loc1_.lBits,_loc1_.uBits,_loc1_.eBits,_loc1_.name,_playerPetSparkleId);
            }
         }
      }
      
      public static function createNPCs(param1:Array, param2:Array) : void
      {
         var _loc3_:Object = null;
         var _loc5_:NPCView = null;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = QuestManager.getNPCDef(param1[_loc4_]);
            _loc5_ = new NPCView();
            _loc5_.init(_loc3_.defId,_loc4_,_loc3_.titleStrId,_loc3_.avatarRefId,false,null);
            _loc5_.x = param2[_loc4_].x;
            _loc5_.y = param2[_loc4_].y;
            _loc5_.addEventListener(MouseEvent.MOUSE_DOWN,onNPCDown,false,0,true);
            _avLayer.addChild(_loc5_);
            _loc4_++;
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
         var _loc8_:Point = null;
         var _loc9_:int = 0;
         if(!_avatarList[param1])
         {
            DebugUtility.debugTrace("updateAvatar(): ERROR: sfsUserId:" + param1 + " not found in _avatarList:" + _avatarList);
            return;
         }
         var _loc7_:AvatarWorldView = _avatarViewList[param1];
         _loc7_.setPos(param2,param3,param5);
         if(param4 && !joiningNewRoom && param1 == _playerSfsUserId && !gMainFrame.clientInfo.invisMode)
         {
            _loc8_ = new Point(param2,param3);
            _loc9_ = _loc7_.lastIdleAnim | (_loc7_.lastIdleFlip ? 2147483648 : 0);
            if(_throttle == 0)
            {
               if(_lastSentPositions.length > 0 && _loc8_.equals(_lastSentPositions[_lastSentPositions.length - 1]))
               {
                  return;
               }
               gMainFrame.server.setXtObject_Str("au",["1",param2,param3,_loc9_,param6 ? "1" : "0"]);
               _throttle = 12;
               _lastSentPositions.push(_loc8_);
               if(_lastSentPositions.length > 2)
               {
                  _lastSentPositions.shift();
               }
               _lastThrottledPositions.length = 0;
            }
            else if(!param6)
            {
               if(_lastThrottledPositions.length > 0 && _loc8_.equals(_lastThrottledPositions[_lastThrottledPositions.length - 1]))
               {
                  return;
               }
               _lastThrottledPackAnimFlip = _loc9_;
               _lastThrottledPositions.push(_loc8_);
               if(_lastThrottledPositions.length > 2)
               {
                  _lastThrottledPositions.shift();
               }
            }
         }
      }
      
      public static function processLastThrottledUpdate() : void
      {
         var _loc2_:Array = null;
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc1_:int = int(_lastThrottledPositions.length);
         if(_loc1_ == 0)
         {
            return;
         }
         if(_loc1_ == 1)
         {
            _loc3_ = _lastThrottledPositions[0];
            _lastThrottledPositions.length = 0;
            if(_loc3_.equals(_lastSentPositions[_lastSentPositions.length - 1]))
            {
               return;
            }
            _loc2_ = [1,_loc3_.x,_loc3_.y];
            _lastSentPositions.push(new Point(_loc3_.x,_loc3_.y));
         }
         else if(_loc1_ > 1)
         {
            _loc3_ = _lastThrottledPositions[_loc1_ - 2];
            _loc4_ = _lastThrottledPositions[_loc1_ - 1];
            _lastThrottledPositions.length = 0;
            if(_lastSentPositions.length == 2 && _loc3_.equals(_lastSentPositions[0]) && _loc4_.equals(_lastSentPositions[1]))
            {
               return;
            }
            _loc2_ = [2,_loc3_.x,_loc3_.y,_loc4_.x,_loc4_.y];
            _lastSentPositions.push(_loc3_);
            _lastSentPositions.push(_loc4_);
         }
         _loc2_.push(_lastThrottledPackAnimFlip);
         _loc2_.push("0");
         gMainFrame.server.setXtObject_Str("au",_loc2_);
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
         var _loc3_:Avatar = null;
         for each(_loc3_ in _avatarList)
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
         var _loc2_:Avatar = null;
         for each(_loc2_ in _avatarList)
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
         var _loc2_:Avatar = null;
         for each(_loc2_ in _avatarList)
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
         if(Boolean(param2 > -1) && Boolean(_avatarViewList[param2]) && !MinigameManager.inMinigame())
         {
            _avatarViewList[param2].setMessage(param1,param3);
         }
         else if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && param2 != playerSfsUserId)
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
         if(Boolean(param3 > -1) && Boolean(_avatarViewList[param3]) && !MinigameManager.inMinigame())
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
         if(param3 > -1 && Boolean(_avatarViewList[param3]))
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
         else if(param2 > -1 && Boolean(_avatarViewList[param2]))
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
         else if(Boolean(param2 > -1) && Boolean(_avatarViewList[param2]) && !MinigameManager.inMinigame())
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
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         var _loc5_:AvatarWorldView = null;
         if(param1 != gMainFrame.server.userId)
         {
            if(AvatarManager.playerAvatarWorldView != null)
            {
               _loc2_ = _avatarViewList[param1].avatarPos;
               _loc3_ = AvatarManager.playerAvatarWorldView.avatarPos;
               _loc4_ = Math.sqrt((_loc2_.x - _loc3_.x) * (_loc2_.x - _loc3_.x) + (_loc2_.y - _loc3_.y) * (_loc2_.y - _loc3_.y));
               if(_loc4_ < 100)
               {
                  if(_avatarViewList[param1].lastIdleAnim == LayerAnim.AN_HOP && AvatarManager.playerAvatarWorldView.lastIdleAnim == LayerAnim.AN_SLEEP)
                  {
                     movePlayer(_loc3_.x + 1,_loc3_.y);
                  }
                  else if(_avatarViewList[param1].lastIdleAnim == LayerAnim.AN_SLEEP && AvatarManager.playerAvatarWorldView.lastIdleAnim == LayerAnim.AN_HOP)
                  {
                     updateAvatar(param1,_loc3_.x + 1,_loc3_.y,false);
                  }
               }
            }
         }
         else if(_avatarViewList[param1].lastIdleAnim == LayerAnim.AN_SLEEP)
         {
            for each(_loc5_ in _avatarViewList)
            {
               if(_loc5_.userId != param1)
               {
                  if(_loc5_.lastIdleAnim == LayerAnim.AN_HOP)
                  {
                     _loc2_ = _loc5_.avatarPos;
                     _loc3_ = _avatarViewList[param1].avatarPos;
                     _loc4_ = Math.sqrt((_loc2_.x - _loc3_.x) * (_loc2_.x - _loc3_.x) + (_loc2_.y - _loc3_.y) * (_loc2_.y - _loc3_.y));
                     if(_loc4_ < 100)
                     {
                        movePlayer(_loc3_.x,_loc3_.y);
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
      
      public static function resetCustomAdventureState() : void
      {
         _playerCustomAdventure = null;
      }
      
      public static function setChatBalloonReadyForClear(param1:int) : void
      {
         if(param1 >= 0 && Boolean(_avatarViewList[param1]))
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
         if(param3 >= 0 && Boolean(_avatarViewList[param3]))
         {
            _avatarViewList[param3].setAvAttachment(param1,param2);
            if(param3 == _playerSfsUserId && _playerAttachmentEmotTimer > 0)
            {
               _playerAttachmentEmotDefId = UserCommXtCommManager.getEmoticonDefId(param1);
            }
         }
         else if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && param3 != playerSfsUserId)
         {
            _loc4_ = _avatarViewOffScreenHud[param3];
            if(_loc4_)
            {
               setViewHudAttachmentBySfsId(param3,param1);
            }
         }
      }
      
      public static function _setAvatarBlendColor(param1:int, param2:uint) : void
      {
         if(Boolean(param1 >= 0) && Boolean(_avatarViewList[param1]) && param1 != _playerSfsUserId)
         {
            _avatarViewList[param1].setBlendColor(param2);
         }
      }
      
      public static function _setAvatarAlphaLevel(param1:int, param2:uint) : void
      {
         if(Boolean(param1 >= 0) && Boolean(_avatarViewList[param1]) && param1 != _playerSfsUserId)
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
         if(param1 == playerSfsUserId && param2 == WorldPet.ACTION_SPARKLE)
         {
            _playerPetSparkleId = param3;
            if(_playerPetSparkleId > 0)
            {
               _loc6_ = PetManager.myActivePet;
               if(_loc6_)
               {
                  _loc6_.isSparkling = true;
               }
               _playerPetSparkleTimer = WorldPet.PET_SPARKLE_TIME;
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
         var _loc5_:AvatarWorldView = null;
         var _loc6_:MovieClip = null;
         if(!_avatarList[param1] || !_avatarViewList[param1])
         {
            if(param2)
            {
               _loc3_ = _avatarViewOffScreenHud[param1];
               if(_loc3_)
               {
                  if(Boolean(_loc3_.parent) && _loc3_.parent == GuiManager.guiLayer)
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
         if(BuddyCard.currBuddyCardUserName == _avatarList[param1].userName.toLowerCase())
         {
            BuddyCard.avatarLeftRoom();
         }
         var _loc4_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_avatarList[param1].userName,_avatarList[param1].perUserAvId);
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && (Boolean(param1 == _playerSfsUserId) || Boolean(_loc4_ && _loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && _loc4_.perUserAvId == gMainFrame.userInfo.myPerUserAvId)))
         {
            for each(_loc5_ in _avatarViewList)
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
            if(param1 != _playerSfsUserId || Boolean(_loc4_ && _loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase()) && Boolean(_loc4_.perUserAvId == gMainFrame.userInfo.myPerUserAvId))
            {
               _avatarList[param1].destroy();
            }
            _avatarViewList[param1].destroy();
            _avatarViewList[param1] = null;
            delete _avatarViewList[param1];
         }
         if(param1 == _playerSfsUserId || Boolean(_avatarList[param1] && _loc4_ && _loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase()) && Boolean(_loc4_.perUserAvId == gMainFrame.userInfo.myPerUserAvId))
         {
            for each(_loc6_ in _avatarViewOffScreenHud)
            {
               if(Boolean(_loc6_.parent) && _loc6_.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc6_);
               }
            }
            if(param2 || QuestManager.questExitPending)
            {
               _avatarViewOffScreenHud = new Object();
               _offScreenMap = new Object();
               _avatarAttachmentOffscreen = new Dictionary();
               _adventurePlayerData = new Object();
            }
         }
         else if(param2)
         {
            _loc3_ = _avatarViewOffScreenHud[param1];
            if(_loc3_)
            {
               if(Boolean(_loc3_.parent) && _loc3_.parent == GuiManager.guiLayer)
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
         var _loc2_:String = null;
         var _loc1_:Array = [];
         for(_loc2_ in _avatarList)
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
         var _loc4_:Object = null;
         var _loc3_:Array = [];
         for(_loc4_ in _avatarList)
         {
            if(!_avatarViewList[_loc4_].heartbeat(param1,param2))
            {
               _loc3_.push(_loc4_);
            }
         }
         while(_loc3_.length > 0)
         {
            removeAvatar(_loc3_.pop());
         }
         if(_throttle > 0)
         {
            --_throttle;
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
               --_playerAttachmentEmotTimer;
               if(!_playerAttachmentEmotTimer)
               {
                  _playerAttachmentEmotDefId = 0;
                  UserCommXtCommManager.sendAvatarAttachmentEmot(0);
               }
            }
         }
         if(_playerPetSparkleTimer > 0)
         {
            --_playerPetSparkleTimer;
            if(!_playerPetSparkleTimer)
            {
               _playerPetSparkleId = 0;
               UserCommXtCommManager.sendPetAction(WorldPet.ACTION_SPARKLE,0);
            }
         }
         processPlayerSplashColor();
      }
      
      public static function processPlayerSplashColor() : void
      {
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:Object = null;
         var _loc1_:AvatarWorldView = playerAvatarWorldView;
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_.inSplashVolume() && !AvatarSwitch.isSwitching())
         {
            _loc3_ = 20;
            _loc4_ = false;
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
                  if((Boolean(_loc5_)) && Boolean(_loc5_.isGround) && Boolean(_loc5_.isSparkling))
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
                  _loc3_ = 10;
                  _loc4_ = true;
                  break;
               case "fire":
                  _playerSplashColor = 11141120;
                  _playerSplashColorLevelMax = 200;
                  if(_playerSplashColorLevel < 60)
                  {
                     _playerSplashColorLevel = 60;
                  }
                  _loc3_ = 10;
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
                     --_playerAlpha;
                     if(_playerAlpha < GHOST_MIN_ALPHA)
                     {
                        _playerAlpha = GHOST_MIN_ALPHA;
                     }
                  }
            }
            if(_loc1_.isSplashAnim() || _loc4_)
            {
               if(_playerSplashColorLevel < _playerSplashColorLevelMax && --_playerSplashColorCountdown < 0)
               {
                  _playerSplashColorCountdown = 10;
                  _playerSplashColorLevel += _loc3_;
                  if(_playerSplashColorLevel > _playerSplashColorLevelMax)
                  {
                     _playerSplashColorLevel = _playerSplashColorLevelMax;
                  }
               }
            }
         }
         else
         {
            if(_playerSplashColorLevel > 0 && --_playerSplashColorCountdown < 0)
            {
               if(_playerSplashColorLevel > 240)
               {
                  _playerSplashColorLevel = _playerSplashColorLevel - 1;
                  _playerSplashColorCountdown = 32;
               }
               else
               {
                  _playerSplashColorCountdown = 10;
                  _playerSplashColorLevel -= _playerSplashColorLevel > 2 ? 2 : _playerSplashColorLevel;
               }
               if(_playerSplashColorLevel < 60)
               {
                  _playerSplashColorLevel = 0;
               }
            }
            if(_playerAlpha < 100 && --_playerAlphaCountdown < 0)
            {
               _playerAlphaCountdown = _playerAlpha > GHOST_MIN_ALPHA + 10 ? 16 : 80;
               ++_playerAlpha;
            }
         }
         var _loc2_:uint = uint(_playerSplashColorLevel << 24 | _playerSplashColor);
         if(_playerSplashColorLevel == 0 || _playerSplashColor == 0)
         {
            _loc2_ = 0;
         }
         if(--_sendPlayerColorThrottle < 0)
         {
            _sendPlayerColorThrottle = THROTTLE_SEND_PLAYER_COLOR;
            if(_lastPlayerSplashColor != _loc2_)
            {
               _loc1_.setBlendColor(_loc2_);
               _lastPlayerSplashColor = _loc2_;
               UserCommXtCommManager.sendAvatarBlendColor(_loc2_);
            }
            if(_lastPlayerAlpha != _playerAlpha)
            {
               _loc1_.setAlphaLevel(_playerAlpha);
               _lastPlayerAlpha = _playerAlpha;
               UserCommXtCommManager.sendAvatarAlphaLevel(_playerAlpha);
            }
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
         if(param1.status)
         {
            return;
         }
         throw new Error("ERROR: Unable to load avatar assets!");
      }
      
      public static function finishHandleAvatarCreate() : void
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         if(_waitForLangPack)
         {
            _waitForLangPack = false;
            for each(_loc1_ in _waitForLangPackSfsUserIdToACResponseDataMap)
            {
               avatarCreateResponse(_loc1_);
            }
            for(_loc2_ in _waitForLangPackSfsUserIdToACResponseDataMap)
            {
               delete _waitForLangPackSfsUserIdToACResponseDataMap[_loc2_];
            }
         }
      }
      
      public static function avatarUpdateResponse(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:AvatarWorldView = null;
         var _loc7_:Point = null;
         var _loc8_:Boolean = false;
         var _loc9_:* = 2;
         var _loc10_:int = int(param1[_loc9_++]);
         if(_loc10_ <= 0)
         {
            throw new Error("got empty \'au\' from server!");
         }
         var _loc11_:int = 0;
         while(_loc11_ < _loc10_)
         {
            _loc2_ = int(param1[_loc9_++]);
            _loc3_ = int(param1[_loc9_++]);
            if(_loc3_ <= 0)
            {
               throw new Error("got empty position update from server!");
            }
            _loc4_ = 0;
            _loc5_ = [];
            while(_loc4_ < _loc3_)
            {
               _loc5_.push(new Point(int(param1[_loc9_++]),int(param1[_loc9_++])));
               _loc4_++;
            }
            _loc8_ = param1[_loc9_++] != "0";
            if(_loc2_ != _playerSfsUserId)
            {
               _loc6_ = _avatarViewList[_loc2_];
               if(_loc6_ != null)
               {
                  if(!_loc8_)
                  {
                     _loc6_.setPath(_loc5_);
                  }
                  else
                  {
                     _loc7_ = _loc5_[_loc5_.length - 1];
                     _loc6_.setPos(_loc7_.x,_loc7_.y,false);
                  }
               }
            }
            _loc11_++;
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
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:String = null;
         var _loc25_:uint = 0;
         var _loc26_:Boolean = false;
         var _loc27_:String = null;
         var _loc28_:int = 0;
         var _loc29_:int = 0;
         var _loc30_:int = 0;
         var _loc31_:String = null;
         var _loc32_:String = null;
         var _loc38_:Array = null;
         var _loc39_:UserInfo = null;
         var _loc40_:UserInfo = null;
         var _loc41_:Array = null;
         var _loc42_:Array = null;
         var _loc43_:Object = null;
         var _loc44_:MinigameInfo = null;
         if(_waitForLangPack)
         {
            _waitForLangPackSfsUserIdToACResponseDataMap[param1[2]] = param1;
            return;
         }
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:int = int(param1[_loc2_++]);
         var _loc7_:String = param1[_loc2_++];
         var _loc8_:String = param1[_loc2_++];
         var _loc9_:int = int(param1[_loc2_++]);
         var _loc10_:String = param1[_loc2_++];
         var _loc11_:int = int(param1[_loc2_++]);
         var _loc12_:int = int(param1[_loc2_++]);
         var _loc13_:Array = [uint(param1[_loc2_++]),uint(param1[_loc2_++]),uint(param1[_loc2_++])];
         var _loc14_:int = int(param1[_loc2_++]);
         var _loc15_:int = gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST ? int(param1[_loc2_++]) : 0;
         var _loc16_:Boolean = gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST ? param1[_loc2_++] == 1 : false;
         var _loc17_:int = int(param1[_loc2_++]);
         var _loc18_:int = int(param1[_loc2_++]);
         var _loc19_:int = SbiConstants.NON_MEMBER;
         var _loc33_:* = 0;
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc19_ = int(param1[_loc2_++]);
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc20_ = int(param1[_loc2_++]);
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc21_ = int(param1[_loc2_++]);
            _loc22_ = int(param1[_loc2_++]);
            _loc23_ = int(param1[_loc2_++]);
            _loc24_ = param1[_loc2_++];
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc25_ = uint(param1[_loc2_++]);
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc26_ = Boolean(int(param1[_loc2_++]));
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc27_ = param1[_loc2_++];
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc28_ = int(param1[_loc2_++]);
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc29_ = int(param1[_loc2_++]);
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc30_ = int(param1[_loc2_++]);
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc31_ = param1[_loc2_++];
         }
         if(_loc18_ & 1 << _loc33_++)
         {
            _loc32_ = param1[_loc2_++];
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            ExternalInterface.call("mrc",["uer",_loc7_,true]);
            DebugUtility.debugTrace("mrc uer sent, checking goto user - RoomXtCommManager.loadingNewRoom:" + RoomXtCommManager.loadingNewRoom + " user:" + _loc7_);
            if(!RoomXtCommManager.loadingNewRoom)
            {
               RoomManagerWorld.instance.modGotoUser(_loc7_,_loc4_,_loc5_);
            }
         }
         var _loc34_:Object = {
            "name":_loc24_,
            "lBits":_loc21_,
            "uBits":_loc22_,
            "eBits":_loc23_
         };
         _loc34_.defId = PetManager.getDefIdFromLBits(_loc34_.lBits);
         _loc34_.type = PetManager.petTypeForDefId(_loc34_.defId);
         _loc34_.isGround = PetManager.isGround(_loc34_.type);
         var _loc35_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc7_,_loc9_);
         if(_loc35_)
         {
            _loc35_.avName = _loc10_;
            _loc35_.type = _loc11_;
            _loc35_.colors = _loc13_;
            _loc35_.currEnviroType = _roomEnviroType;
            _loc35_.questLevel = _loc14_;
            _loc35_.questXp = 0;
            _loc35_.questXPPercentage = 0;
            _loc35_.questHealthPercentage = _loc15_;
            _loc35_.questTorchStatus = _loc16_;
            _loc35_.currPet = _loc34_;
            _loc35_.customAvId = _loc12_;
            _loc39_ = gMainFrame.userInfo.getUserInfoByUserName(_loc7_);
            _loc39_.accountType = _loc19_;
            _loc39_.isGuide = _loc26_;
            _loc39_.nameBarData = _loc20_;
            _loc39_.userNameModeratedFlag = _loc17_;
         }
         else
         {
            _loc40_ = new UserInfo();
            _loc35_ = new AvatarInfo();
            _loc35_.init(_loc9_,_loc10_,_loc7_,_loc8_,_loc11_,_loc13_,0,_loc34_,_loc12_,0,0,_loc14_);
            _loc35_.questHealthPercentage = _loc15_;
            _loc35_.questTorchStatus = _loc16_;
            _loc41_ = [];
            _loc41_[_loc35_.perUserAvId] = _loc35_;
            _loc40_.init(_loc7_,_loc8_,_loc41_,_loc35_.perUserAvId);
            _loc40_.accountType = _loc19_;
            _loc40_.isGuide = _loc26_;
            _loc40_.nameBarData = _loc20_;
            _loc40_.userNameModeratedFlag = _loc17_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc7_,_loc40_);
         }
         createAvatar(_loc3_,_loc4_,_loc5_,_loc9_,_loc10_,_loc7_,_loc11_,_loc6_,_loc28_,_loc13_,_loc25_,_loc19_,_loc26_,_loc12_,null,_loc20_);
         var _loc36_:AvatarWorldView = _avatarViewList[_loc3_];
         if(_loc36_)
         {
            _loc36_.setActivePet(_loc21_,_loc22_,_loc23_,_loc24_,_loc29_);
            _loc36_.updateNameBarHealth(_loc15_);
         }
         var _loc37_:Avatar = _avatarList[_loc3_];
         if(Boolean(_loc27_) && _loc27_ != "")
         {
            _loc38_ = _loc27_.split(",");
            _setAvatarAttachmentEmot(int(_loc38_[0]),_loc38_[1],_loc3_);
         }
         if(Boolean(_loc31_) && _loc31_ != "")
         {
            _loc38_ = _loc31_.split("|");
            _loc42_ = _loc38_[0].split(",");
            _loc43_ = QuestXtCommManager.getScriptDef(_loc42_[0]);
            if(_loc43_)
            {
               addCustomAdventureMessage(LocalizationManager.translateIdOnly(_loc43_.titleStrId),_loc38_[1] + "|" + _loc42_[0],_loc3_,_loc42_[2],int(param1[6]));
            }
         }
         if(Boolean(_loc32_) && _loc32_ != "")
         {
            _loc38_ = _loc32_.split("|");
            _loc44_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc38_[1]);
            addCustomPvpMessage(LocalizationManager.translateIdOnly(_loc44_.titleStrId),_loc32_,_loc3_,0,int(param1[6]));
         }
         QuestManager.playerJoinedQuestRoom(_loc3_);
         if(buddyCardAvatarView)
         {
            if(_loc7_.toLowerCase() == buddyCardAvatarView.userName.toLowerCase())
            {
               BuddyCard.updateCurrBuddyCardAvatar(_loc37_);
            }
         }
         ItemXtCommManager.insertAvIntoAcIlQueue(_loc9_,_loc37_,processAcIlCombo);
         processAcIlCombo(_loc7_,_loc9_,true);
      }
      
      private static function getSfsUserIdByUsernamePerUserAvId(param1:String, param2:int) : int
      {
         var _loc3_:Avatar = null;
         if(_avatarList)
         {
            for each(_loc3_ in _avatarList)
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
         var _loc6_:Object = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Avatar = null;
         var _loc5_:int = getSfsUserIdByUsernamePerUserAvId(param1,param2);
         if(_acQueue[param1])
         {
            _loc8_ = Utility.numProperties(_acQueue[param1]);
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               if(_acQueue[param1].hasOwnProperty(param2))
               {
                  if(_acQueue[param1][param2].acReceived == true && !param3)
                  {
                     _loc7_ = true;
                  }
                  else if(_acQueue[param1][param2].ilReceived == true && param3)
                  {
                     if(Boolean(_avatarList[_loc5_]) && Boolean(_acQueue[param1][param2].ilResponse))
                     {
                        _loc10_ = _avatarList[_loc5_];
                        ItemXtCommManager.insertIntoILAvatarQueue(_loc10_.perUserAvId,null,_loc10_);
                        ItemXtCommManager.handleIlWhenBeforeACAfterReceivingAC(_acQueue[param1][param2].ilResponse);
                        _loc7_ = true;
                     }
                     else
                     {
                        ItemXtCommManager.removeFromILAvatarQueue(param1,param2);
                        _loc7_ = false;
                     }
                  }
                  if(_loc7_)
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
         var _loc4_:Object = null;
         var _loc9_:uint = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc3_:Object = gMainFrame.userInfo.getAvatarDefByAvType(param1,param2);
         if(_loc3_ == null)
         {
            return null;
         }
         if(param2)
         {
            _loc4_ = gMainFrame.userInfo.getAvatarDefByAvType(_loc3_.avatarRefId,false);
            param1 = int(_loc3_.avatarRefId);
         }
         else
         {
            _loc4_ = _loc3_;
         }
         var _loc5_:uint = uint(_loc4_.colorLayer2);
         var _loc6_:Array = [];
         _loc6_[0] = ItemXtCommManager.getBodyModFromDefId(1,param1,true,false);
         _loc6_[1] = ItemXtCommManager.getBodyModFromDefId(_loc4_.defEyes,param1,true,false);
         if(param2)
         {
            if(_loc3_.patternRefId > 0)
            {
               _loc6_[2] = ItemXtCommManager.getBodyModFromDefId(_loc3_.patternRefId,param1,true,false);
               _loc9_ = uint(_loc6_[2].colors[0]);
               _loc10_ = _loc9_ >> 24;
               _loc11_ = _loc9_ >> 16 & 0xFF;
               _loc12_ = _loc9_ >> 8 & 0xFF;
               _loc13_ = _loc9_ & 0xFF;
               _loc5_ = _loc5_ = uint(_loc10_ << 24 | _loc11_ << 16 | _loc12_ << 8 | _loc13_);
            }
         }
         else if(_loc4_.defPattern > 0)
         {
            _loc6_[2] = ItemXtCommManager.getBodyModFromDefId(_loc4_.defPattern,param1,true,false);
         }
         var _loc7_:Array = [_loc4_.colorLayer1,_loc5_,_loc4_.colorLayer3];
         var _loc8_:Avatar = new Avatar();
         _loc8_.init(-1,"redemAvt",param1,_loc7_,param2 ? int(_loc3_.id) : -1);
         _loc8_.itemResponseIntegrate(_loc6_);
         return _loc8_;
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
         var _loc2_:AvatarWorldView = null;
         for each(_loc2_ in _avatarViewList)
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
         return !((param1 & _loc2_) == 0 || (_loc2_ & 1 << SbiConstants.ENVIRO_AIR) != 0 && (param1 & 1 << SbiConstants.ENVIRO_AIR) == 0);
      }
      
      public static function getFlower(param1:Boolean = false) : MovieClip
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Vector.<MovieClip> = null;
         var _loc4_:Loader = null;
         _loc3_ = param1 ? _flowerIdlePool : _flowerPool;
         if(_loc3_.length > 10)
         {
            _loc2_ = _loc3_.shift();
            _loc4_ = _loc2_.getChildAt(0) as Loader;
            if(Boolean(_loc4_.content) && !(_loc4_.content as MovieClip).readyToUse)
            {
               _loc2_ = param1 ? new FlowerIdle() : new Flower();
            }
         }
         else
         {
            _loc2_ = param1 ? new FlowerIdle() : new Flower();
         }
         _loc2_.visible = true;
         _loc3_.push(_loc2_);
         if(_layerManager == null)
         {
            _layerManager = RoomManagerWorld.instance.layerManager;
         }
         if(_loc2_.parent)
         {
            _flowerLayer.removeChild(_loc2_);
         }
         if(param1)
         {
            _layerManager.room_avatars.addChild(_loc2_);
         }
         else
         {
            _flowerLayer.addChild(_loc2_);
         }
         if(_flowerLayer.parent == null)
         {
            _layerManager.room_bkg_group.addChildAt(_flowerLayer,1);
         }
         return _loc2_;
      }
      
      public static function clearSpecialPatternLayer() : void
      {
         var _loc1_:Loader = null;
         var _loc2_:MovieClip = null;
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

