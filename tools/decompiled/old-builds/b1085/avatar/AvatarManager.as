package avatar
{
   import buddy.BuddyEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.SortLayer;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.popup.*;
   import den.DenItem;
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
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class AvatarManager
   {
      
      public static var joiningNewRoom:Boolean;
      
      private static var _avLayer:SortLayer;
      
      private static var _flyingAvLayer:SortLayer;
      
      private static var _chatLayer:DisplayLayer;
      
      private static var _avatarList:Object;
      
      private static var _avatarViewList:Object;
      
      private static var _initCallback:Function;
      
      private static var _avatarViewOffScreenHud:Object;
      
      private static var _avatarAttachmentOffscreen:Dictionary;
      
      private static var _offScreenMap:Object;
      
      private static var _adventurePlayerData:Object;
      
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
      
      public static const THROTTLE_SEND_PLAYER_COLOR:int = 12;
      
      public static const GHOST_MIN_ALPHA:int = 45;
      
      private static var _playerSfsUserId:int = -1;
      
      private static var _playerAlpha:uint = 100;
      
      public function AvatarManager()
      {
         super();
      }
      
      public static function init(param1:*, param2:DisplayLayer, param3:SortLayer) : void
      {
         _avLayer = param1;
         _flyingAvLayer = param3;
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
            if(_roomEnviroType == Utility.ENVIRO_LAND)
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
            createAvatar(_playerSfsUserId,0,0,_loc2_.dbAvId,_loc2_.avName,_loc2_.userName,_loc2_.type,_roomEnviroType == Utility.ENVIRO_LAND ? LayerAnim.AN_IDLE_SE : LayerAnim.AN_SWIM_E,-1,_loc2_.colors,_loc3_,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : int(gMainFrame.userInfo.playerUserInfo.nameBarData));
            if(Boolean(playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_LAND) && Boolean(playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_OCEAN))
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
            loadSelfAssetsResult(true);
         }
         else
         {
            createAvatar(_playerSfsUserId,0,0,gMainFrame.userInfo.myDbAvId,"",gMainFrame.server.userName,-1,_roomEnviroType == Utility.ENVIRO_LAND ? LayerAnim.AN_IDLE_SE : LayerAnim.AN_SWIM_E,-1,null,0,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : int(gMainFrame.userInfo.playerUserInfo.nameBarData));
            AvatarXtCommManager.requestADForAvatar(gMainFrame.userInfo.myDbAvId,true,loadSelfAssetsResult,playerAvatar);
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
      
      public static function loadSelfAssetsResult(param1:Boolean = false) : void
      {
         if(!param1)
         {
            updateNeededAvatarItemsAfterAD();
         }
         _avatarViewList[_playerSfsUserId].preload(_initCallback);
      }
      
      private static function updateNeededAvatarItemsAfterAD() : void
      {
         if(!(playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
         {
            if(playerAvatarWorldView.parent == _flyingAvLayer)
            {
               _avLayer.addChild(playerAvatarWorldView);
            }
         }
         else if(playerAvatarWorldView.parent == _avLayer)
         {
            _flyingAvLayer.addChild(playerAvatarWorldView);
         }
         AvatarManager.setupActivePet();
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
               updateAvatar(_playerSfsUserId,param1,param2,true);
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
      
      public static function createAvatar(param1:int, param2:int, param3:int, param4:int, param5:String, param6:String, param7:int, param8:int, param9:int, param10:Array, param11:uint, param12:int, param13:Boolean, param14:AccessoryState = null, param15:int = 0, param16:Object = null, param17:Object = null) : void
      {
         var _loc23_:AvatarInfo = null;
         var _loc24_:Object = null;
         if(param5 == "")
         {
            param5 = gMainFrame.clientInfo.avName;
         }
         var _loc18_:Avatar = new Avatar();
         _loc18_.init(param4,param5,param7,param10,param14,param6,param1,_roomEnviroType);
         _avatarList[param1] = _loc18_;
         if(param6 == gMainFrame.userInfo.myUserName)
         {
            if(AvatarManager.playerAvatarWorldView)
            {
               AvatarManager.playerAvatarWorldView.resetAvatar(_loc18_);
            }
         }
         var _loc19_:AvatarWorldView = new AvatarWorldView();
         _loc19_.initWorldView(_loc18_,param17 != null ? param17 : _chatLayer,param12,param13,false,GuiManager.actionMgr,GuiManager,param15,_roomEnviroType);
         _loc19_.setPos(param2,param3,false);
         if(param11 > 0)
         {
            _loc19_.setBlendColor(param11);
         }
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            if(_offScreenMap[param1] == null)
            {
               _offScreenMap[param1] = new Dictionary(false);
            }
         }
         var _loc20_:int = param8 & 0x07FFFFFF;
         var _loc21_:Boolean = param8 & 0x80000000 ? true : false;
         _loc19_.playAnim(_loc20_,_loc21_);
         if(param16 != null)
         {
            param16.addChild(_loc19_);
         }
         else if(!(_loc18_.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
         {
            _avLayer.addChild(_loc19_);
         }
         else
         {
            _flyingAvLayer.addChild(_loc19_);
         }
         _avatarViewList[param1] = _loc19_;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            _adventurePlayerData[param1] = {
               "isMember":Utility.isMember(param12),
               "nameBarData":param15,
               "userName":param6,
               "avName":param5
            };
            _loc23_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc18_.userName);
            if((Boolean(_loc23_)) && _loc23_.questTorchStatus)
            {
               QuestManager.addTorch(_loc19_,QuestManager.QUEST_TORCH_LITSIZE,-15,-50);
            }
         }
         _loc19_.visible = _chatLayer.visible;
         if(param9 > 0)
         {
            _avatarViewList[param1].setEmote(null,param9);
         }
         var _loc22_:int = int(gMainFrame.server.userId);
         if(param1 != _loc22_)
         {
            if(_avatarViewList[_loc22_])
            {
               _avatarViewList[_loc22_].moveToFront();
            }
         }
         else
         {
            _sendPlayerColorThrottle = 0;
            if(param11 == 0 && _playerSplashColor != 0)
            {
               clearPlayerSplashColor();
            }
            if(param16 == null)
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
                  _loc24_ = PetManager.myActivePet;
                  if(_loc24_)
                  {
                     _loc19_.setActivePet(_loc24_.lBits,_loc24_.uBits,_loc24_.eBits,_loc24_.name,_playerPetSparkleId);
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
                  _loc19_.setCustomAdventureMessage(_playerCustomPVP.infoText,_playerCustomPVP.userMessage,_playerCustomPVP.difficulty,_playerCustomPVP.severity,true);
               }
               if(_playerCustomAdventure)
               {
                  _loc19_.setCustomAdventureMessage(_playerCustomAdventure.infoText,_playerCustomAdventure.userMessage,_playerCustomAdventure.difficulty,_playerCustomAdventure.severity,false);
               }
            }
            DebugUtility.debugTrace("ghostMode - creating self avatar - ghostMode:" + gMainFrame.clientInfo.invisMode);
            if(gMainFrame.clientInfo.invisMode)
            {
               _loc19_.alpha = 0.5;
            }
            else
            {
               _loc19_.alpha = _playerAlpha / 100;
            }
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
            _loc5_.init(_loc3_.defId,_loc4_,_loc3_.titleStrId,false,null);
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
      
      public static function getAvatarByDbAvId(param1:int) : Avatar
      {
         var _loc2_:Avatar = null;
         for each(_loc2_ in _avatarList)
         {
            if(_loc2_.dbAvId == param1)
            {
               return _loc2_;
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
            if(_loc2_.userName == param1)
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
         else if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && param2 != playerSfsUserId)
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
      
      public static function setPlayerAttachmentEmot(param1:int, param2:String = null, param3:int = 2880) : void
      {
         if(_playerAttachmentEmotDefId != param1 || _playerAttachmentEmotExtra != param2)
         {
            _playerAttachmentEmotTimer = param3;
            _playerAttachmentEmotDefId = param1;
            _playerAttachmentEmotExtra = param2;
            UserCommXtCommManager.sendAvatarAttachmentEmot(_playerAttachmentEmotDefId,param2);
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
         else if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && param3 != playerSfsUserId)
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
         var _loc4_:AvatarWorldView = null;
         var _loc5_:MovieClip = null;
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
         if(BuddyCard.currBuddyCardUserName == _avatarList[param1].userName)
         {
            BuddyCard.avatarLeftRoom();
         }
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && (param1 == _playerSfsUserId || _avatarList[param1].dbAvId == gMainFrame.userInfo.myDbAvId))
         {
            for each(_loc4_ in _avatarViewList)
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
            if(param1 != _playerSfsUserId || _avatarList[param1].dbAvId == gMainFrame.userInfo.myDbAvId)
            {
               _avatarList[param1].destroy();
            }
            _avatarViewList[param1].destroy();
            _avatarViewList[param1] = null;
            delete _avatarViewList[param1];
         }
         if(param1 == _playerSfsUserId || Boolean(_avatarList[param1]) && Boolean(_avatarList[param1].dbAvId == gMainFrame.userInfo.myDbAvId))
         {
            for each(_loc5_ in _avatarViewOffScreenHud)
            {
               if(Boolean(_loc5_.parent) && _loc5_.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc5_);
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
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:String = null;
         var _loc23_:uint = 0;
         var _loc24_:Boolean = false;
         var _loc25_:String = null;
         var _loc26_:int = 0;
         var _loc27_:int = 0;
         var _loc28_:int = 0;
         var _loc29_:String = null;
         var _loc30_:String = null;
         var _loc35_:Array = null;
         var _loc36_:UserInfo = null;
         var _loc37_:UserInfo = null;
         var _loc38_:Array = null;
         var _loc39_:Array = null;
         var _loc40_:Object = null;
         var _loc41_:MinigameInfo = null;
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
         var _loc8_:int = int(param1[_loc2_++]);
         var _loc9_:String = param1[_loc2_++];
         var _loc10_:int = int(param1[_loc2_++]);
         var _loc11_:Array = [uint(param1[_loc2_++]),uint(param1[_loc2_++]),uint(param1[_loc2_++])];
         var _loc12_:int = int(param1[_loc2_++]);
         var _loc13_:int = gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST ? int(param1[_loc2_++]) : 0;
         var _loc14_:Boolean = gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST ? param1[_loc2_++] == 1 : false;
         var _loc15_:int = int(param1[_loc2_++]);
         var _loc16_:int = int(param1[_loc2_++]);
         var _loc17_:int = Utility.NON_MEMBER;
         var _loc31_:* = 0;
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc17_ = int(param1[_loc2_++]);
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc18_ = int(param1[_loc2_++]);
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc19_ = int(param1[_loc2_++]);
            _loc20_ = int(param1[_loc2_++]);
            _loc21_ = int(param1[_loc2_++]);
            _loc22_ = param1[_loc2_++];
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc23_ = uint(param1[_loc2_++]);
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc24_ = Boolean(int(param1[_loc2_++]));
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc25_ = param1[_loc2_++];
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc26_ = int(param1[_loc2_++]);
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc27_ = int(param1[_loc2_++]);
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc28_ = int(param1[_loc2_++]);
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc29_ = param1[_loc2_++];
         }
         if(_loc16_ & 1 << _loc31_++)
         {
            _loc30_ = param1[_loc2_++];
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
         var _loc32_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByDbAvId(_loc8_);
         if(_loc32_)
         {
            _loc32_.avName = _loc9_;
            _loc32_.type = _loc10_;
            _loc32_.colors = _loc11_;
            _loc32_.currEnviroType = _roomEnviroType;
            _loc32_.questLevel = _loc12_;
            _loc32_.questXp = 0;
            _loc32_.questXPPercentage = 0;
            _loc32_.questHealthPercentage = _loc13_;
            _loc32_.questTorchStatus = _loc14_;
            _loc36_ = gMainFrame.userInfo.getUserInfoByUserName(_loc7_);
            _loc36_.accountType = _loc17_;
            _loc36_.isGuide = _loc24_;
            _loc36_.nameBarData = _loc18_;
            _loc36_.userNameModeratedFlag = _loc15_;
         }
         else
         {
            _loc37_ = new UserInfo();
            _loc32_ = new AvatarInfo();
            _loc32_.init(_loc8_,_loc9_,_loc7_,_loc10_,_loc11_,0,0,0,0,_loc12_);
            _loc32_.questHealthPercentage = _loc13_;
            _loc32_.questTorchStatus = _loc14_;
            _loc38_ = [];
            _loc38_[_loc32_.dbAvId] = _loc32_;
            _loc37_.init(_loc7_,_loc38_,_loc32_.dbAvId);
            _loc37_.accountType = _loc17_;
            _loc37_.isGuide = _loc24_;
            _loc37_.nameBarData = _loc18_;
            _loc37_.userNameModeratedFlag = _loc15_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc7_,_loc37_);
         }
         createAvatar(_loc3_,_loc4_,_loc5_,_loc8_,_loc9_,_loc7_,_loc10_,_loc6_,_loc26_,_loc11_,_loc23_,_loc17_,_loc24_,null,_loc18_);
         var _loc33_:AvatarWorldView = _avatarViewList[_loc3_];
         if(_loc33_)
         {
            _loc33_.setActivePet(_loc19_,_loc20_,_loc21_,_loc22_,_loc27_);
            _loc33_.updateNameBarHealth(_loc13_);
         }
         var _loc34_:Avatar = _avatarList[_loc3_];
         if(Boolean(_loc25_) && _loc25_ != "")
         {
            _loc35_ = _loc25_.split(",");
            _setAvatarAttachmentEmot(int(_loc35_[0]),_loc35_[1],_loc3_);
         }
         if(Boolean(_loc29_) && _loc29_ != "")
         {
            _loc35_ = _loc29_.split("|");
            _loc39_ = _loc35_[0].split(",");
            _loc40_ = QuestXtCommManager.getScriptDef(_loc39_[0]);
            if(_loc40_)
            {
               addCustomAdventureMessage(LocalizationManager.translateIdOnly(_loc40_.titleStrId),_loc35_[1] + "|" + _loc39_[0],_loc3_,_loc39_[2],int(param1[6]));
            }
         }
         if(Boolean(_loc30_) && _loc30_ != "")
         {
            _loc35_ = _loc30_.split("|");
            _loc41_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc35_[1]);
            addCustomPvpMessage(LocalizationManager.translateIdOnly(_loc41_.titleStrId),_loc30_,_loc3_,0,int(param1[6]));
         }
         QuestManager.playerJoinedQuestRoom(_loc3_);
         if(buddyCardAvatarView)
         {
            if(_loc7_ == buddyCardAvatarView.userName)
            {
               BuddyCard.updateCurrBuddyCardAvatar(_loc34_);
            }
         }
         ItemXtCommManager.insertAvIntoAcIlQueue(_loc8_,_loc34_,processAcIlCombo);
         processAcIlCombo(_loc8_,true);
      }
      
      private static function getSfsUserIdByDbAvId(param1:int) : int
      {
         var _loc2_:Avatar = null;
         if(_avatarList)
         {
            for each(_loc2_ in _avatarList)
            {
               if(_loc2_.dbAvId == param1)
               {
                  return _loc2_.sfsUserId;
               }
            }
         }
         return -1;
      }
      
      public static function processAcIlCombo(param1:int, param2:Boolean = false, param3:Object = null) : void
      {
         var _loc5_:Object = null;
         var _loc6_:Avatar = null;
         var _loc4_:int = getSfsUserIdByDbAvId(param1);
         if(_acQueue[param1])
         {
            if(_acQueue[param1].acReceived == true && !param2)
            {
               for each(_loc5_ in _acQueue)
               {
                  if(_loc5_ == _acQueue[param1])
                  {
                     delete _acQueue[param1];
                     break;
                  }
               }
            }
            else if(_acQueue[param1].ilReceived == true && param2)
            {
               if(Boolean(_avatarList[_loc4_]) && Boolean(_acQueue[param1].ilResponse))
               {
                  _loc6_ = _avatarList[_loc4_];
                  ItemXtCommManager.insertIntoILAvatarQueue(_loc6_.dbAvId,null,_loc6_);
                  ItemXtCommManager.handleIlWhenBeforeACAfterReceivingAC(_acQueue[param1].ilResponse);
                  for each(_loc5_ in _acQueue)
                  {
                     if(_loc5_ == _acQueue[param1])
                     {
                        delete _acQueue[param1];
                        break;
                     }
                  }
               }
               else
               {
                  ItemXtCommManager.removeFromILAvatarQueue(param1);
               }
            }
         }
         else
         {
            _acQueue[param1] = {
               "ilReceived":!param2,
               "acReceived":param2,
               "ilResponse":param3
            };
         }
      }
      
      public static function getDefaultAvatarByDefId(param1:int) : Avatar
      {
         var _loc2_:Object = gMainFrame.userInfo.getAvatarDefByAvType(param1);
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:Array = [_loc2_.colorLayer1,_loc2_.colorLayer2,_loc2_.colorLayer3];
         var _loc4_:Avatar = new Avatar();
         _loc4_.init(-1,"redemAvt",param1,_loc3_);
         var _loc5_:Array = [];
         _loc5_[0] = ItemXtCommManager.getBodyModFromDefId(1,param1,true,false);
         _loc5_[1] = ItemXtCommManager.getBodyModFromDefId(_loc2_.defEyes,param1,true,false);
         if(_loc2_.defPattern > 0)
         {
            _loc5_[2] = ItemXtCommManager.getBodyModFromDefId(_loc2_.defPattern,param1,true,false);
         }
         _loc4_.itemResponseIntegrate(_loc5_);
         return _loc4_;
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
   }
}

