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
      
      public static const THROTTLE_SEND_PLAYER_COLOR:int = 12;
      
      public static const GHOST_MIN_ALPHA:int = 45;
      
      private static var _playerSfsUserId:int = -1;
      
      private static var _playerAlpha:uint = 100;
      
      public function AvatarManager()
      {
         super();
      }
      
      public static function init(initAvatarLayer:*, initChatLayer:DisplayLayer, initFlyingLayer:SortLayer, initPreviewRoomLayer:SortLayer, initPreviewFlyingRoomLayer:SortLayer) : void
      {
         _avLayer = initAvatarLayer;
         _flyingAvLayer = initFlyingLayer;
         _previewRoomAvLayer = initPreviewRoomLayer;
         _previewFlyingRoomAvLayer = initPreviewFlyingRoomLayer;
         _chatLayer = initChatLayer;
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
      
      public static function set playerSfsUserId(s:int) : void
      {
         _playerSfsUserId = s;
      }
      
      public static function showAvtAndChatLayers(show:Boolean) : void
      {
         var obj:Object = null;
         var numChildren:int = _avLayer.numChildren;
         for(var i:int = 0; i < numChildren; i++)
         {
            obj = _avLayer.getChildAt(i);
            if(obj is AvatarWorldView)
            {
               obj.visible = show;
            }
         }
         _chatLayer.visible = show;
         _flyingAvLayer.visible = show;
      }
      
      public static function get getFlyingLayer() : SortLayer
      {
         return _flyingAvLayer;
      }
      
      public static function get getAvatarLayer() : SortLayer
      {
         return _avLayer;
      }
      
      public static function set roomEnviroType(type:int) : void
      {
         _roomEnviroType = type;
      }
      
      public static function get roomEnviroType() : int
      {
         return _roomEnviroType;
      }
      
      public static function set waitForLangPack(wait:Boolean) : void
      {
         _waitForLangPack = wait;
      }
      
      public static function get waitForLangPack() : Boolean
      {
         return _waitForLangPack;
      }
      
      public static function loadSelfAssets(initCallback:Function) : void
      {
         var blendColor:uint = 0;
         var tempArray:Array = null;
         var items:Array = null;
         var i:int = 0;
         _initCallback = initCallback;
         var cachedInfo:AvatarInfo = gMainFrame.userInfo.playerAvatarInfo;
         if(Boolean(cachedInfo) && cachedInfo.type != -1)
         {
            blendColor = 0;
            if(_roomEnviroType == Utility.ENVIRO_LAND)
            {
               blendColor = 0;
               if(Boolean(_playerSplashColorLevel))
               {
                  blendColor = uint(_playerSplashColorLevel << 24 | _playerSplashColor);
               }
            }
            else
            {
               blendColor = 0;
               clearPlayerSplashColor();
            }
            createAvatar(_playerSfsUserId,0,0,cachedInfo.perUserAvId,cachedInfo.avName,cachedInfo.userName,cachedInfo.type,_roomEnviroType == Utility.ENVIRO_LAND ? LayerAnim.AN_IDLE_SE : LayerAnim.AN_SWIM_E,-1,cachedInfo.colors,blendColor,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : int(gMainFrame.userInfo.playerUserInfo.nameBarData));
            if(Boolean(playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_LAND) && Boolean(playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_OCEAN))
            {
               tempArray = [];
               items = cachedInfo.getItems(true);
               for(i = 0; i < items.length; i++)
               {
                  if(items[i].type == Item.BODY_MOD_TYPE)
                  {
                     tempArray.push(items[i]);
                  }
               }
               playerAvatar.itemResponseIntegrate(tempArray.concat(cachedInfo.getFullItems(true).concat()));
            }
            else
            {
               playerAvatar.itemResponseIntegrate(cachedInfo.getItems(true));
            }
            loadSelfAssetsResult(true);
         }
         else
         {
            createAvatar(_playerSfsUserId,0,0,gMainFrame.userInfo.myPerUserAvId,"",gMainFrame.server.userName,-1,_roomEnviroType == Utility.ENVIRO_LAND ? LayerAnim.AN_IDLE_SE : LayerAnim.AN_SWIM_E,-1,null,0,gMainFrame.clientInfo.accountType,gMainFrame.userInfo.isGuide,null,gMainFrame.userInfo.playerUserInfo == null ? 0 : int(gMainFrame.userInfo.playerUserInfo.nameBarData));
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
      
      public static function loadSelfAssetsResult(isFromCache:Boolean = false) : void
      {
         if(!isFromCache)
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
      
      public static function getViewHudMCBySfsId(playerSfsUserId:int) : MovieClip
      {
         return _avatarViewOffScreenHud[playerSfsUserId];
      }
      
      public static function setViewHudMCBySfsId(playerSfsUserId:int, view:MovieClip) : void
      {
         _avatarViewOffScreenHud[playerSfsUserId] = view;
      }
      
      public static function setOffScreenAttachmentBySfsId(playerSfsUserId:int, attachment:MovieClip) : void
      {
         _avatarAttachmentOffscreen[playerSfsUserId] = attachment;
      }
      
      public static function getOffScreenAttachmentBySfsId(playerSfsUserId:int) : MovieClip
      {
         return _avatarAttachmentOffscreen[playerSfsUserId];
      }
      
      public static function setViewHudAttachmentBySfsId(playerSfsUserId:int, attachmentId:int) : void
      {
         if(Boolean(_avatarViewOffScreenHud[playerSfsUserId]))
         {
            _avatarViewOffScreenHud[playerSfsUserId].attachmentId = attachmentId;
         }
      }
      
      public static function setOffScreenMapBySfsId(playerSfsUserId:int, lastPos:Point, roomNameId:String) : void
      {
         if(_offScreenMap[playerSfsUserId] == null)
         {
            _offScreenMap[playerSfsUserId] = new Dictionary(false);
            _offScreenMap[playerSfsUserId][roomNameId] = lastPos;
         }
         else
         {
            _offScreenMap[playerSfsUserId][roomNameId] = lastPos;
         }
      }
      
      public static function getOffScreenMapBySfsId(playerSfsUserId:int) : Dictionary
      {
         return _offScreenMap[playerSfsUserId];
      }
      
      public static function getOffScreenMap() : Object
      {
         return _offScreenMap;
      }
      
      public static function updateAvatarOffscreenToMyPosition() : void
      {
         var offscreenDictionary:Dictionary = null;
         for each(offscreenDictionary in _offScreenMap)
         {
            if(offscreenDictionary[gMainFrame.server.getCurrentRoomName(false)] == null)
            {
               offscreenDictionary[gMainFrame.server.getCurrentRoomName(false)] = new Point(playerAvatarWorldView.x,playerAvatarWorldView.y);
            }
         }
      }
      
      public static function movePlayer(x:Number, y:Number) : void
      {
         if(_playerSfsUserId >= 0)
         {
            if(!MinigameManager.inMinigame() && !SBPopupManager.modalSBPopup)
            {
               updateAvatar(_playerSfsUserId,x,y,_isMyAvtInPreviewRoom ? false : true);
            }
         }
      }
      
      public static function updatePlayerAvatarViewParent(chooseNormalParent:Boolean) : void
      {
         var myAvtView:AvatarWorldView = playerAvatarWorldView;
         if(Boolean(myAvtView))
         {
            if(chooseNormalParent)
            {
               if(myAvtView.parent == _previewRoomAvLayer)
               {
                  _previewRoomAvLayer.removeChild(myAvtView);
               }
               else if(myAvtView.parent == _previewFlyingRoomAvLayer)
               {
                  _previewFlyingRoomAvLayer.removeChild(myAvtView);
               }
               _lastKnownAvtViewParent.addChild(myAvtView);
               _isMyAvtInPreviewRoom = false;
            }
            else
            {
               if(myAvtView.parent == _lastKnownAvtViewParent)
               {
                  _lastKnownAvtViewParent.removeChild(myAvtView);
               }
               if(!(playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
               {
                  _previewRoomAvLayer.addChild(myAvtView);
               }
               else
               {
                  _previewFlyingRoomAvLayer.addChild(myAvtView);
               }
               _isMyAvtInPreviewRoom = true;
            }
         }
      }
      
      private static function enviroItems(items:Array) : Array
      {
         var denItem:DenItem = null;
         var modifiedItems:Array = [];
         for each(denItem in items)
         {
            if(denItem.enviroType == AvatarManager.roomEnviroType)
            {
               modifiedItems.push(denItem);
            }
         }
         return modifiedItems;
      }
      
      public static function createAvatar(sfsUserId:int, x:int, y:int, perUserAvId:int, avName:String, userName:String, cAvType:int, acPackAnimFlip:int, permEmoteMediaId:int, cColors:Array, blendColor:uint, accountType:int, isGuide:Boolean, accState:AccessoryState = null, nameBarData:int = 0, customAvLayer:Object = null, customChatLayer:Object = null) : void
      {
         var ai:AvatarInfo = null;
         var myPet:Object = null;
         var isGround:Boolean = false;
         var currPet:Object = null;
         if(avName == "")
         {
            avName = gMainFrame.clientInfo.avName;
         }
         var avt:Avatar = new Avatar();
         avt.init(perUserAvId,avName,cAvType,cColors,accState,userName,sfsUserId,_roomEnviroType);
         _avatarList[sfsUserId] = avt;
         if(userName == gMainFrame.userInfo.myUserName)
         {
            if(Boolean(AvatarManager.playerAvatarWorldView))
            {
               AvatarManager.playerAvatarWorldView.resetAvatar(avt);
            }
         }
         var avtv:AvatarWorldView = new AvatarWorldView();
         avtv.initWorldView(avt,customChatLayer != null ? customChatLayer : _chatLayer,accountType,isGuide,false,GuiManager.actionMgr,GuiManager,nameBarData,_roomEnviroType);
         avtv.setPos(x,y,false);
         if(blendColor > 0)
         {
            avtv.setBlendColor(blendColor);
         }
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            if(_offScreenMap[sfsUserId] == null)
            {
               _offScreenMap[sfsUserId] = new Dictionary(false);
            }
         }
         var animId:int = acPackAnimFlip & 0x07FFFFFF;
         var bFlip:Boolean = Boolean(acPackAnimFlip & 0x80000000) ? true : false;
         avtv.playAnim(animId,bFlip);
         _avatarViewList[sfsUserId] = avtv;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            _adventurePlayerData[sfsUserId] = {
               "isMember":Utility.isMember(accountType),
               "nameBarData":nameBarData,
               "userName":userName,
               "avName":avName
            };
            ai = gMainFrame.userInfo.getAvatarInfoByUserName(avt.userName);
            if(Boolean(ai) && ai.questTorchStatus)
            {
               QuestManager.addTorch(avtv,QuestManager.QUEST_TORCH_LITSIZE,-15,-50);
            }
         }
         if(!_isMyAvtInPreviewRoom || _chatLayer.visible == true)
         {
            avtv.visible = _chatLayer.visible;
         }
         if(permEmoteMediaId > 0)
         {
            _avatarViewList[sfsUserId].setEmote(null,permEmoteMediaId);
         }
         var myId:int = int(gMainFrame.server.userId);
         if(sfsUserId != myId)
         {
            if(Boolean(_avatarViewList[myId]))
            {
               _avatarViewList[myId].moveToFront();
            }
         }
         else
         {
            _sendPlayerColorThrottle = 0;
            if(blendColor == 0 && _playerSplashColor != 0)
            {
               clearPlayerSplashColor();
            }
            if(customAvLayer == null)
            {
               if(PetManager.myActivePetInvId > 0)
               {
                  if(cAvType == -1)
                  {
                     _needToResetPet = true;
                  }
                  else
                  {
                     _needToResetPet = false;
                  }
                  myPet = PetManager.myActivePet;
                  if(Boolean(myPet))
                  {
                     avtv.setActivePet(myPet.lBits,myPet.uBits,myPet.eBits,myPet.name,_playerPetSparkleId);
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
               if(Boolean(_playerCustomPVP))
               {
                  avtv.setCustomAdventureMessage(_playerCustomPVP.infoText,_playerCustomPVP.userMessage,_playerCustomPVP.difficulty,_playerCustomPVP.severity,true);
               }
               if(Boolean(_playerCustomAdventure))
               {
                  avtv.setCustomAdventureMessage(_playerCustomAdventure.infoText,_playerCustomAdventure.userMessage,_playerCustomAdventure.difficulty,_playerCustomAdventure.severity,false);
               }
            }
            DebugUtility.debugTrace("ghostMode - creating self avatar - ghostMode:" + gMainFrame.clientInfo.invisMode);
            if(Boolean(gMainFrame.clientInfo.invisMode))
            {
               avtv.alpha = 0.5;
            }
            else
            {
               avtv.alpha = _playerAlpha / 100;
            }
         }
         if(customAvLayer != null)
         {
            customAvLayer.addChild(avtv);
            if(userName == gMainFrame.userInfo.myUserName)
            {
               _lastKnownAvtViewParent = customAvLayer;
            }
         }
         else if(GuiManager.isBeYourPetRoom())
         {
            isGround = true;
            if(sfsUserId == myId)
            {
               isGround = avtv.isActivePetGroundPet();
            }
            else
            {
               ai = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
               if(Boolean(ai))
               {
                  currPet = ai.currPet;
                  if(Boolean(currPet))
                  {
                     isGround = PetManager.isGround(PetManager.petTypeForDefId(currPet.lBits & 0xFF));
                  }
               }
            }
            if(isGround)
            {
               _avLayer.addChild(avtv);
               if(userName == gMainFrame.userInfo.myUserName)
               {
                  _lastKnownAvtViewParent = _avLayer;
               }
            }
            else
            {
               _flyingAvLayer.addChild(avtv);
               if(userName == gMainFrame.userInfo.myUserName)
               {
                  _lastKnownAvtViewParent = _flyingAvLayer;
               }
            }
         }
         else if(!(avt.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
         {
            _avLayer.addChild(avtv);
            if(userName == gMainFrame.userInfo.myUserName)
            {
               _lastKnownAvtViewParent = _avLayer;
            }
         }
         else
         {
            _flyingAvLayer.addChild(avtv);
            if(userName == gMainFrame.userInfo.myUserName)
            {
               _lastKnownAvtViewParent = _flyingAvLayer;
            }
         }
      }
      
      public static function setupActivePet() : void
      {
         var myPet:Object = null;
         if(_needToResetPet && PetManager.myActivePetInvId > 0)
         {
            _needToResetPet = false;
            myPet = PetManager.myActivePet;
            if(Boolean(myPet) && Boolean(playerAvatarWorldView))
            {
               playerAvatarWorldView.setActivePet(myPet.lBits,myPet.uBits,myPet.eBits,myPet.name,_playerPetSparkleId);
            }
         }
      }
      
      public static function createNPCs(npcDefIds:Array, npcLocs:Array) : void
      {
         var npcDef:Object = null;
         var npc:NPCView = null;
         for(var i:int = 0; i < npcDefIds.length; i++)
         {
            npcDef = QuestManager.getNPCDef(npcDefIds[i]);
            npc = new NPCView();
            npc.init(npcDef.defId,i,npcDef.titleStrId,false,null);
            npc.x = npcLocs[i].x;
            npc.y = npcLocs[i].y;
            npc.addEventListener(MouseEvent.MOUSE_DOWN,onNPCDown,false,0,true);
            _avLayer.addChild(npc);
         }
      }
      
      public static function addQuestActor(inQuestActor:QuestActor, inPos:Point) : void
      {
         inQuestActor.x = inPos.x;
         inQuestActor.y = inPos.y;
         _avLayer.addChild(inQuestActor);
      }
      
      private static function onNPCDown(evt:MouseEvent) : void
      {
         var npc:NPCView = NPCView(evt.currentTarget);
         DarkenManager.showLoadingSpiral(true);
         MinigameManager.handleGameClick({
            "idx":5,
            "r":30,
            "spawn":"spawn",
            "type":0,
            "typeDefId":82,
            "x":npc.x,
            "y":npc.y
         },null,true,null,npc.defId);
         RoomManagerWorld.instance.setGotoSpawnLocation(playerAvatarWorldView.avatarPos.x,playerAvatarWorldView.avatarPos.y);
      }
      
      public static function updateAvatar(sfsUserId:Object, x:int, y:int, bNotifyServer:Boolean, bInterpolate:Boolean = true, transportAvatar:Boolean = false) : void
      {
         var newPosition:Point = null;
         var packAnimFlip:int = 0;
         if(!_avatarList[sfsUserId])
         {
            DebugUtility.debugTrace("updateAvatar(): ERROR: sfsUserId:" + sfsUserId + " not found in _avatarList:" + _avatarList);
            return;
         }
         var avView:AvatarWorldView = _avatarViewList[sfsUserId];
         avView.setPos(x,y,bInterpolate);
         if(bNotifyServer && !joiningNewRoom && sfsUserId == _playerSfsUserId && !gMainFrame.clientInfo.invisMode)
         {
            newPosition = new Point(x,y);
            packAnimFlip = avView.lastIdleAnim | (avView.lastIdleFlip ? 2147483648 : 0);
            if(_throttle == 0)
            {
               if(_lastSentPositions.length > 0 && newPosition.equals(_lastSentPositions[_lastSentPositions.length - 1]))
               {
                  return;
               }
               gMainFrame.server.setXtObject_Str("au",["1",x,y,packAnimFlip,transportAvatar ? "1" : "0"]);
               _throttle = 12;
               _lastSentPositions.push(newPosition);
               if(_lastSentPositions.length > 2)
               {
                  _lastSentPositions.shift();
               }
               _lastThrottledPositions.length = 0;
            }
            else if(!transportAvatar)
            {
               if(_lastThrottledPositions.length > 0 && newPosition.equals(_lastThrottledPositions[_lastThrottledPositions.length - 1]))
               {
                  return;
               }
               _lastThrottledPackAnimFlip = packAnimFlip;
               _lastThrottledPositions.push(newPosition);
               if(_lastThrottledPositions.length > 2)
               {
                  _lastThrottledPositions.shift();
               }
            }
         }
      }
      
      public static function processLastThrottledUpdate() : void
      {
         var auRequest:Array = null;
         var p1:Point = null;
         var p2:Point = null;
         var numPositions:int = int(_lastThrottledPositions.length);
         if(numPositions == 0)
         {
            return;
         }
         if(numPositions == 1)
         {
            p1 = _lastThrottledPositions[0];
            _lastThrottledPositions.length = 0;
            if(p1.equals(_lastSentPositions[_lastSentPositions.length - 1]))
            {
               return;
            }
            auRequest = [1,p1.x,p1.y];
            _lastSentPositions.push(new Point(p1.x,p1.y));
         }
         else if(numPositions > 1)
         {
            p1 = _lastThrottledPositions[numPositions - 2];
            p2 = _lastThrottledPositions[numPositions - 1];
            _lastThrottledPositions.length = 0;
            if(_lastSentPositions.length == 2 && p1.equals(_lastSentPositions[0]) && p2.equals(_lastSentPositions[1]))
            {
               return;
            }
            auRequest = [2,p1.x,p1.y,p2.x,p2.y];
            _lastSentPositions.push(p1);
            _lastSentPositions.push(p2);
         }
         auRequest.push(_lastThrottledPackAnimFlip);
         auRequest.push("0");
         gMainFrame.server.setXtObject_Str("au",auRequest);
         if(_lastSentPositions.length > 2)
         {
            _lastSentPositions.splice(0,_lastSentPositions.length - 2);
         }
      }
      
      public static function resetThrottle() : void
      {
         _throttle = 0;
      }
      
      public static function getAvatarBySfsUserId(sfsUserId:int) : Avatar
      {
         return _avatarList[sfsUserId];
      }
      
      public static function getAvatarByUsernamePerUserAvId(userName:String, perUserAvId:int) : Avatar
      {
         var av:Avatar = null;
         for each(av in _avatarList)
         {
            if(av.userName == userName && av.perUserAvId == perUserAvId)
            {
               return av;
            }
         }
         return null;
      }
      
      public static function getAvatarByAvName(gaAvName:String) : Avatar
      {
         var av:Avatar = null;
         for each(av in _avatarList)
         {
            if(av.avName == gaAvName)
            {
               return av;
            }
         }
         return null;
      }
      
      public static function getAvatarByUserName(gaUserName:String) : Avatar
      {
         var av:Avatar = null;
         for each(av in _avatarList)
         {
            if(av.userName == gaUserName)
            {
               return av;
            }
         }
         return null;
      }
      
      public static function getAvatarWorldViewBySfsUserId(sfsUserId:int) : AvatarWorldView
      {
         return _avatarViewList[sfsUserId];
      }
      
      public static function addAvatarMessage(txt:String, userId:int, severity:int) : void
      {
         var hudView:MovieClip = null;
         if(Boolean(userId > -1) && Boolean(_avatarViewList[userId]) && !MinigameManager.inMinigame())
         {
            _avatarViewList[userId].setMessage(txt,severity);
         }
         else if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && userId != playerSfsUserId)
         {
            hudView = _avatarViewOffScreenHud[userId];
            if(Boolean(hudView))
            {
               hudView.questChatBalloon.setText(txt,gMainFrame.userInfo.isModerator && severity > 1,false);
            }
         }
      }
      
      public static function addCustomAdventureMessage(adventureInfoText:String, userText:String, userId:int, difficulty:int, severity:int) : void
      {
         if(Boolean(userId > -1) && Boolean(_avatarViewList[userId]) && !MinigameManager.inMinigame())
         {
            if(userId == _playerSfsUserId)
            {
               if(userText == "off")
               {
                  _playerCustomAdventure = null;
               }
               else
               {
                  _playerCustomAdventure = {
                     "infoText":adventureInfoText,
                     "userMessage":userText,
                     "difficulty":difficulty,
                     "severity":severity
                  };
               }
            }
            _avatarViewList[userId].setCustomAdventureMessage(adventureInfoText,userText,difficulty,severity);
         }
      }
      
      public static function addCustomPvpMessage(pvpInfoText:String, userText:String, userId:int, difficulty:int, severity:int) : void
      {
         var allowMessage:Boolean = false;
         if(userId > -1 && Boolean(_avatarViewList[userId]))
         {
            if(userId == _playerSfsUserId)
            {
               if(userText.split("|")[0] == "off")
               {
                  _playerCustomPVP = null;
                  GuiManager.mainHud.emotesBtn.activateGrayState(false);
                  GuiManager.actionMgr.hideCancelBtn();
                  allowMessage = true;
               }
               else if(!MinigameManager.inMinigame())
               {
                  _playerCustomPVP = {
                     "infoText":pvpInfoText,
                     "userMessage":userText,
                     "difficulty":difficulty,
                     "severity":severity
                  };
                  GuiManager.mainHud.emotesBtn.downToUpState();
                  GuiManager.emoteMgr.closeEmotes();
                  GuiManager.mainHud.emotesBtn.activateGrayState(true);
                  allowMessage = true;
               }
            }
            else if(!MinigameManager.inMinigame())
            {
               allowMessage = true;
            }
            if(allowMessage)
            {
               _avatarViewList[userId].setCustomAdventureMessage(pvpInfoText,userText,difficulty,severity,true);
            }
         }
      }
      
      public static function setAvatarEmote(emote:Sprite, userId:int = -2, permEmoteMediaId:int = -1) : void
      {
         if(userId == -2)
         {
            userId = int(gMainFrame.server.userId);
            _avatarViewList[userId].setEmote(emote,permEmoteMediaId);
         }
         else if(userId > -1 && Boolean(_avatarViewList[userId]))
         {
            if(userId != gMainFrame.server.userId || permEmoteMediaId >= 0)
            {
               _avatarViewList[userId].setEmote(emote,permEmoteMediaId);
            }
         }
      }
      
      public static function setAvatarAction(action:Sprite, userId:int = -2) : void
      {
         if(userId == -2)
         {
            userId = int(gMainFrame.server.userId);
            _avatarViewList[userId].setAction(action);
            checkIfBeingHoppedOn(userId);
         }
         else if(Boolean(userId > -1) && Boolean(_avatarViewList[userId]) && !MinigameManager.inMinigame())
         {
            if(userId != gMainFrame.server.userId)
            {
               _avatarViewList[userId].setAction(action);
            }
            checkIfBeingHoppedOn(userId);
         }
      }
      
      private static function checkIfBeingHoppedOn(userId:int) : void
      {
         var position:Point = null;
         var myPosition:Point = null;
         var distance:int = 0;
         var avtView:AvatarWorldView = null;
         if(userId != gMainFrame.server.userId)
         {
            if(AvatarManager.playerAvatarWorldView != null)
            {
               position = _avatarViewList[userId].avatarPos;
               myPosition = AvatarManager.playerAvatarWorldView.avatarPos;
               distance = Math.sqrt((position.x - myPosition.x) * (position.x - myPosition.x) + (position.y - myPosition.y) * (position.y - myPosition.y));
               if(distance < 100)
               {
                  if(_avatarViewList[userId].lastIdleAnim == LayerAnim.AN_HOP && AvatarManager.playerAvatarWorldView.lastIdleAnim == LayerAnim.AN_SLEEP)
                  {
                     movePlayer(myPosition.x + 1,myPosition.y);
                  }
                  else if(_avatarViewList[userId].lastIdleAnim == LayerAnim.AN_SLEEP && AvatarManager.playerAvatarWorldView.lastIdleAnim == LayerAnim.AN_HOP)
                  {
                     updateAvatar(userId,myPosition.x + 1,myPosition.y,false);
                  }
               }
            }
         }
         else if(_avatarViewList[userId].lastIdleAnim == LayerAnim.AN_SLEEP)
         {
            for each(avtView in _avatarViewList)
            {
               if(avtView.userId != userId)
               {
                  if(avtView.lastIdleAnim == LayerAnim.AN_HOP)
                  {
                     position = avtView.avatarPos;
                     myPosition = _avatarViewList[userId].avatarPos;
                     distance = Math.sqrt((position.x - myPosition.x) * (position.x - myPosition.x) + (position.y - myPosition.y) * (position.y - myPosition.y));
                     if(distance < 100)
                     {
                        movePlayer(myPosition.x,myPosition.y);
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
      
      public static function setChatBalloonReadyForClear(userId:int) : void
      {
         if(userId >= 0 && Boolean(_avatarViewList[userId]))
         {
            _avatarViewList[userId].setChatBalloonReadyForClear();
         }
      }
      
      public static function setPlayerAttachmentEmot(emotDefId:int, extra:String = null, timer:int = 2880, sendMessage:Boolean = true) : void
      {
         if(_playerAttachmentEmotDefId != emotDefId || _playerAttachmentEmotExtra != extra)
         {
            _playerAttachmentEmotTimer = timer;
            _playerAttachmentEmotDefId = emotDefId;
            _playerAttachmentEmotExtra = extra;
            if(sendMessage)
            {
               UserCommXtCommManager.sendAvatarAttachmentEmot(_playerAttachmentEmotDefId,extra);
            }
         }
      }
      
      public static function _setAvatarAttachmentEmot(mediaId:int, extra:String, sfsUserId:int) : void
      {
         var hudView:MovieClip = null;
         if(sfsUserId >= 0 && Boolean(_avatarViewList[sfsUserId]))
         {
            _avatarViewList[sfsUserId].setAvAttachment(mediaId,extra);
            if(sfsUserId == _playerSfsUserId && _playerAttachmentEmotTimer > 0)
            {
               _playerAttachmentEmotDefId = UserCommXtCommManager.getEmoticonDefId(mediaId);
            }
         }
         else if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && sfsUserId != playerSfsUserId)
         {
            hudView = _avatarViewOffScreenHud[sfsUserId];
            if(Boolean(hudView))
            {
               setViewHudAttachmentBySfsId(sfsUserId,mediaId);
            }
         }
      }
      
      public static function _setAvatarBlendColor(sfsUserId:int, c:uint) : void
      {
         if(Boolean(sfsUserId >= 0) && Boolean(_avatarViewList[sfsUserId]) && sfsUserId != _playerSfsUserId)
         {
            _avatarViewList[sfsUserId].setBlendColor(c);
         }
      }
      
      public static function _setAvatarAlphaLevel(sfsUserId:int, a:uint) : void
      {
         if(Boolean(sfsUserId >= 0) && Boolean(_avatarViewList[sfsUserId]) && sfsUserId != _playerSfsUserId)
         {
            _avatarViewList[sfsUserId].setAlphaLevel(a);
         }
      }
      
      public static function setPetAction(sfsUserId:int, actionId:int, extraId:int = 0) : void
      {
         var myPet:Object = null;
         var awv:AvatarWorldView = _avatarViewList[sfsUserId];
         if(!awv)
         {
            return;
         }
         var wp:WorldPet = awv.getActivePet();
         if(!wp)
         {
            return;
         }
         wp.setAction(actionId,extraId);
         if(sfsUserId == playerSfsUserId && actionId == WorldPet.ACTION_SPARKLE)
         {
            _playerPetSparkleId = extraId;
            if(_playerPetSparkleId > 0)
            {
               myPet = PetManager.myActivePet;
               if(Boolean(myPet))
               {
                  myPet.isSparkling = true;
               }
               _playerPetSparkleTimer = WorldPet.PET_SPARKLE_TIME;
            }
            else
            {
               _playerPetSparkleTimer = 0;
            }
         }
      }
      
      public static function removeAvatar(sfsUserId:int, needsToRemoveOffScreenView:Boolean = false) : void
      {
         var offScreenObj:MovieClip = null;
         var avtView:AvatarWorldView = null;
         var offScreenObject:MovieClip = null;
         if(!_avatarList[sfsUserId] || !_avatarViewList[sfsUserId])
         {
            if(needsToRemoveOffScreenView)
            {
               offScreenObj = _avatarViewOffScreenHud[sfsUserId];
               if(Boolean(offScreenObj))
               {
                  if(Boolean(offScreenObj.parent) && offScreenObj.parent == GuiManager.guiLayer)
                  {
                     GuiManager.guiLayer.removeChild(offScreenObj);
                  }
                  offScreenObj = null;
                  delete _avatarViewOffScreenHud[sfsUserId];
                  delete _offScreenMap[sfsUserId];
                  delete _avatarAttachmentOffscreen[sfsUserId];
                  delete _adventurePlayerData[sfsUserId];
               }
            }
            else
            {
               DebugUtility.debugTrace("removeAvatar(): ERROR: sfsUserId:" + sfsUserId + " not found in _avatarList:" + _avatarList);
            }
            return;
         }
         if(BuddyCard.currBuddyCardUserName == _avatarList[sfsUserId].userName)
         {
            BuddyCard.avatarLeftRoom();
         }
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && (sfsUserId == _playerSfsUserId || _avatarList[sfsUserId].perUserAvId == gMainFrame.userInfo.myPerUserAvId))
         {
            for each(avtView in _avatarViewList)
            {
               delete _avatarViewList[avtView.avatarData.sfsUserId];
               _avatarList[avtView.avatarData.sfsUserId].destroy();
               delete _avatarList[avtView.avatarData.sfsUserId];
               avtView.destroy();
               avtView = null;
            }
         }
         else
         {
            if(sfsUserId != _playerSfsUserId || _avatarList[sfsUserId].perUserAvId == gMainFrame.userInfo.myPerUserAvId)
            {
               _avatarList[sfsUserId].destroy();
            }
            _avatarViewList[sfsUserId].destroy();
            _avatarViewList[sfsUserId] = null;
            delete _avatarViewList[sfsUserId];
         }
         if(sfsUserId == _playerSfsUserId || Boolean(_avatarList[sfsUserId]) && Boolean(_avatarList[sfsUserId].perUserAvId == gMainFrame.userInfo.myPerUserAvId))
         {
            for each(offScreenObject in _avatarViewOffScreenHud)
            {
               if(Boolean(offScreenObject.parent) && offScreenObject.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(offScreenObject);
               }
            }
            if(needsToRemoveOffScreenView || QuestManager.questExitPending)
            {
               _avatarViewOffScreenHud = new Object();
               _offScreenMap = new Object();
               _avatarAttachmentOffscreen = new Dictionary();
               _adventurePlayerData = new Object();
            }
         }
         else if(needsToRemoveOffScreenView)
         {
            offScreenObj = _avatarViewOffScreenHud[sfsUserId];
            if(Boolean(offScreenObj))
            {
               if(Boolean(offScreenObj.parent) && offScreenObj.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(offScreenObj);
               }
               offScreenObj = null;
               delete _avatarViewOffScreenHud[sfsUserId];
               delete _offScreenMap[sfsUserId];
               delete _avatarAttachmentOffscreen[sfsUserId];
               delete _adventurePlayerData[sfsUserId];
            }
         }
         _avatarList[sfsUserId] = null;
         delete _avatarList[sfsUserId];
      }
      
      public static function removeAllAvatars() : void
      {
         var key:String = null;
         var remList:Array = [];
         for(key in _avatarList)
         {
            remList.push(key);
         }
         while(remList.length > 0)
         {
            removeAvatar(remList.pop());
         }
      }
      
      public static function heartbeat(amms:int, frameTimems:int) : void
      {
         var key:Object = null;
         var remKeys:Array = [];
         for(key in _avatarList)
         {
            if(!_avatarViewList[key].heartbeat(amms,frameTimems))
            {
               remKeys.push(key);
            }
         }
         while(remKeys.length > 0)
         {
            removeAvatar(remKeys.pop());
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
         var colorLevelSpeed:int = 0;
         var bSplashNoMove:Boolean = false;
         var myPet:Object = null;
         var p:AvatarWorldView = playerAvatarWorldView;
         if(p == null)
         {
            return;
         }
         if(p.inSplashVolume() && !AvatarSwitch.isSwitching())
         {
            colorLevelSpeed = 20;
            bSplashNoMove = false;
            switch(p.splashLiquid)
            {
               case "mud":
                  _playerSplashColor = 6045747;
                  _playerSplashColorLevelMax = 255;
                  if(_playerSplashColorLevel < 100)
                  {
                     _playerSplashColorLevel = 100;
                  }
                  myPet = PetManager.myActivePet;
                  if(Boolean(myPet) && Boolean(myPet.isGround) && Boolean(myPet.isSparkling))
                  {
                     myPet.isSparkling = false;
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
                  colorLevelSpeed = 10;
                  bSplashNoMove = true;
                  break;
               case "fire":
                  _playerSplashColor = 11141120;
                  _playerSplashColorLevelMax = 200;
                  if(_playerSplashColorLevel < 60)
                  {
                     _playerSplashColorLevel = 60;
                  }
                  colorLevelSpeed = 10;
                  bSplashNoMove = true;
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
            if(p.isSplashAnim() || bSplashNoMove)
            {
               if(_playerSplashColorLevel < _playerSplashColorLevelMax && --_playerSplashColorCountdown < 0)
               {
                  _playerSplashColorCountdown = 10;
                  _playerSplashColorLevel += colorLevelSpeed;
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
                  _playerSplashColorLevel -= 1;
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
               trace(_playerAlphaCountdown);
               ++_playerAlpha;
            }
         }
         var c:uint = uint(_playerSplashColorLevel << 24 | _playerSplashColor);
         if(_playerSplashColorLevel == 0 || _playerSplashColor == 0)
         {
            c = 0;
         }
         if(--_sendPlayerColorThrottle < 0)
         {
            _sendPlayerColorThrottle = THROTTLE_SEND_PLAYER_COLOR;
            if(_lastPlayerSplashColor != c)
            {
               p.setBlendColor(c);
               _lastPlayerSplashColor = c;
               UserCommXtCommManager.sendAvatarBlendColor(c);
            }
            if(_lastPlayerAlpha != _playerAlpha)
            {
               p.setAlphaLevel(_playerAlpha);
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
      
      private static function loadAvatarAssetsComplete(evt:LoaderEvent) : void
      {
         if(evt.status)
         {
            return;
         }
         throw new Error("ERROR: Unable to load avatar assets!");
      }
      
      public static function finishHandleAvatarCreate() : void
      {
         var data:Array = null;
         var k:String = null;
         if(_waitForLangPack)
         {
            _waitForLangPack = false;
            for each(data in _waitForLangPackSfsUserIdToACResponseDataMap)
            {
               avatarCreateResponse(data);
            }
            for(k in _waitForLangPackSfsUserIdToACResponseDataMap)
            {
               delete _waitForLangPackSfsUserIdToACResponseDataMap[k];
            }
         }
      }
      
      public static function avatarUpdateResponse(data:Array) : void
      {
         var uid:int = 0;
         var posUpdatesLength:int = 0;
         var p:int = 0;
         var posUpdates:Array = null;
         var avView:AvatarWorldView = null;
         var finalPoint:Point = null;
         var isTransport:Boolean = false;
         var di:int = 2;
         var numUpdatedAvatars:int = int(data[di++]);
         if(numUpdatedAvatars <= 0)
         {
            throw new Error("got empty \'au\' from server!");
         }
         for(var uai:int = 0; uai < numUpdatedAvatars; uai++)
         {
            uid = int(data[di++]);
            posUpdatesLength = int(data[di++]);
            if(posUpdatesLength <= 0)
            {
               throw new Error("got empty position update from server!");
            }
            p = 0;
            posUpdates = [];
            while(p < posUpdatesLength)
            {
               posUpdates.push(new Point(int(data[di++]),int(data[di++])));
               p++;
            }
            isTransport = data[di++] != "0";
            if(uid != _playerSfsUserId)
            {
               avView = _avatarViewList[uid];
               if(avView != null)
               {
                  if(!isTransport)
                  {
                     avView.setPath(posUpdates);
                  }
                  else
                  {
                     finalPoint = posUpdates[posUpdates.length - 1];
                     avView.setPos(finalPoint.x,finalPoint.y,false);
                  }
               }
            }
         }
      }
      
      public static function avatarPaintResponse(data:Array) : void
      {
         if(data[2] != "1")
         {
            DebugUtility.debugTrace("ERROR: avatar paint command failed!");
         }
      }
      
      public static function avatarCreateResponse(data:Array) : void
      {
         var nameBarData:int = 0;
         var lBits:int = 0;
         var uBits:int = 0;
         var eBits:int = 0;
         var petName:String = null;
         var blendColor:uint = 0;
         var isGuide:Boolean = false;
         var avtAttachment:String = null;
         var permEmoteMediaId:int = 0;
         var petSparkle:int = 0;
         var alphaLevel:int = 0;
         var customAdventureMessage:String = null;
         var customPvpMessage:String = null;
         var split:Array = null;
         var ui:UserInfo = null;
         var setUserInfo:UserInfo = null;
         var avList:Array = null;
         var adventureInfoSplit:Array = null;
         var questScriptDef:Object = null;
         var jmi:MinigameInfo = null;
         if(_waitForLangPack)
         {
            _waitForLangPackSfsUserIdToACResponseDataMap[data[2]] = data;
            return;
         }
         var i:int = 2;
         var sfsUserId:int = int(data[i++]);
         var acX:int = int(data[i++]);
         var acY:int = int(data[i++]);
         var acPackAnimFlip:int = int(data[i++]);
         var acUserName:String = data[i++];
         var perUserAvId:int = int(data[i++]);
         var acAvName:String = data[i++];
         var acType:int = int(data[i++]);
         var acColors:Array = [uint(data[i++]),uint(data[i++]),uint(data[i++])];
         var questXPLevel:int = int(data[i++]);
         var questHealthPercentage:int = gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST ? int(data[i++]) : 0;
         var questTorchStatus:Boolean = gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST ? data[i++] == 1 : false;
         var userNameModeratedFlag:int = int(data[i++]);
         var optFlag:int = int(data[i++]);
         var accountType:int = Utility.NON_MEMBER;
         var j:int = 0;
         if(Boolean(optFlag & 1 << j++))
         {
            accountType = int(data[i++]);
         }
         if(Boolean(optFlag & 1 << j++))
         {
            nameBarData = int(data[i++]);
         }
         if(Boolean(optFlag & 1 << j++))
         {
            lBits = int(data[i++]);
            uBits = int(data[i++]);
            eBits = int(data[i++]);
            petName = data[i++];
         }
         if(Boolean(optFlag & 1 << j++))
         {
            blendColor = uint(data[i++]);
         }
         if(Boolean(optFlag & 1 << j++))
         {
            isGuide = Boolean(int(data[i++]));
         }
         if(Boolean(optFlag & 1 << j++))
         {
            avtAttachment = data[i++];
         }
         if(Boolean(optFlag & 1 << j++))
         {
            permEmoteMediaId = int(data[i++]);
         }
         if(Boolean(optFlag & 1 << j++))
         {
            petSparkle = int(data[i++]);
         }
         if(Boolean(optFlag & 1 << j++))
         {
            alphaLevel = int(data[i++]);
         }
         if(Boolean(optFlag & 1 << j++))
         {
            customAdventureMessage = data[i++];
         }
         if(Boolean(optFlag & 1 << j++))
         {
            customPvpMessage = data[i++];
         }
         if(Boolean(gMainFrame.clientInfo.extCallsActive))
         {
            ExternalInterface.call("mrc",["uer",acUserName,true]);
            DebugUtility.debugTrace("mrc uer sent, checking goto user - RoomXtCommManager.loadingNewRoom:" + RoomXtCommManager.loadingNewRoom + " user:" + acUserName);
            if(!RoomXtCommManager.loadingNewRoom)
            {
               RoomManagerWorld.instance.modGotoUser(acUserName,acX,acY);
            }
         }
         var currPet:Object = {
            "name":petName,
            "lBits":lBits,
            "uBits":uBits,
            "eBits":eBits
         };
         currPet.defId = PetManager.getDefIdFromLBits(currPet.lBits);
         currPet.type = PetManager.petTypeForDefId(currPet.defId);
         currPet.isGround = PetManager.isGround(currPet.type);
         var acAvCacheInfo:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(acUserName,perUserAvId);
         if(Boolean(acAvCacheInfo))
         {
            acAvCacheInfo.avName = acAvName;
            acAvCacheInfo.type = acType;
            acAvCacheInfo.colors = acColors;
            acAvCacheInfo.currEnviroType = _roomEnviroType;
            acAvCacheInfo.questLevel = questXPLevel;
            acAvCacheInfo.questXp = 0;
            acAvCacheInfo.questXPPercentage = 0;
            acAvCacheInfo.questHealthPercentage = questHealthPercentage;
            acAvCacheInfo.questTorchStatus = questTorchStatus;
            acAvCacheInfo.currPet = currPet;
            ui = gMainFrame.userInfo.getUserInfoByUserName(acUserName);
            ui.accountType = accountType;
            ui.isGuide = isGuide;
            ui.nameBarData = nameBarData;
            ui.userNameModeratedFlag = userNameModeratedFlag;
         }
         else
         {
            setUserInfo = new UserInfo();
            acAvCacheInfo = new AvatarInfo();
            acAvCacheInfo.init(perUserAvId,acAvName,acUserName,acType,acColors,0,currPet,0,0,questXPLevel);
            acAvCacheInfo.questHealthPercentage = questHealthPercentage;
            acAvCacheInfo.questTorchStatus = questTorchStatus;
            avList = [];
            avList[acAvCacheInfo.perUserAvId] = acAvCacheInfo;
            setUserInfo.init(acUserName,avList,acAvCacheInfo.perUserAvId);
            setUserInfo.accountType = accountType;
            setUserInfo.isGuide = isGuide;
            setUserInfo.nameBarData = nameBarData;
            setUserInfo.userNameModeratedFlag = userNameModeratedFlag;
            gMainFrame.userInfo.setUserInfoByUserName(acUserName,setUserInfo);
         }
         createAvatar(sfsUserId,acX,acY,perUserAvId,acAvName,acUserName,acType,acPackAnimFlip,permEmoteMediaId,acColors,blendColor,accountType,isGuide,null,nameBarData);
         var awv:AvatarWorldView = _avatarViewList[sfsUserId];
         if(Boolean(awv))
         {
            awv.setActivePet(lBits,uBits,eBits,petName,petSparkle);
            awv.updateNameBarHealth(questHealthPercentage);
         }
         var newAvatar:Avatar = _avatarList[sfsUserId];
         if(Boolean(avtAttachment) && avtAttachment != "")
         {
            split = avtAttachment.split(",");
            _setAvatarAttachmentEmot(int(split[0]),split[1],sfsUserId);
         }
         if(Boolean(customAdventureMessage) && customAdventureMessage != "")
         {
            split = customAdventureMessage.split("|");
            adventureInfoSplit = split[0].split(",");
            questScriptDef = QuestXtCommManager.getScriptDef(adventureInfoSplit[0]);
            if(Boolean(questScriptDef))
            {
               addCustomAdventureMessage(LocalizationManager.translateIdOnly(questScriptDef.titleStrId),split[1] + "|" + adventureInfoSplit[0],sfsUserId,adventureInfoSplit[2],int(data[6]));
            }
         }
         if(Boolean(customPvpMessage) && customPvpMessage != "")
         {
            split = customPvpMessage.split("|");
            jmi = MinigameManager.minigameInfoCache.getMinigameInfo(split[1]);
            addCustomPvpMessage(LocalizationManager.translateIdOnly(jmi.titleStrId),customPvpMessage,sfsUserId,0,int(data[6]));
         }
         QuestManager.playerJoinedQuestRoom(sfsUserId);
         if(Boolean(buddyCardAvatarView))
         {
            if(acUserName == buddyCardAvatarView.userName)
            {
               BuddyCard.updateCurrBuddyCardAvatar(newAvatar);
            }
         }
         ItemXtCommManager.insertAvIntoAcIlQueue(perUserAvId,newAvatar,processAcIlCombo);
         processAcIlCombo(acUserName,perUserAvId,true);
      }
      
      private static function getSfsUserIdByUsernamePerUserAvId(userName:String, perUserAvId:int) : int
      {
         var a:Avatar = null;
         if(Boolean(_avatarList))
         {
            for each(a in _avatarList)
            {
               if(a.userName == userName && a.perUserAvId == perUserAvId)
               {
                  return a.sfsUserId;
               }
            }
         }
         return -1;
      }
      
      public static function processAcIlCombo(userName:String, perUserAvId:int, fromAc:Boolean = false, ilResponse:Object = null) : void
      {
         var acQueue:Object = null;
         var shouldDelete:Boolean = false;
         var acQueueLength:int = 0;
         var i:int = 0;
         var ilAvatar:Avatar = null;
         var sfsId:int = getSfsUserIdByUsernamePerUserAvId(userName,perUserAvId);
         if(Boolean(_acQueue[userName]))
         {
            acQueueLength = Utility.numProperties(_acQueue[userName]);
            for(i = 0; i < acQueueLength; i++)
            {
               if(Boolean(_acQueue[userName].hasOwnProperty(perUserAvId)))
               {
                  if(_acQueue[userName][perUserAvId].acReceived == true && !fromAc)
                  {
                     shouldDelete = true;
                  }
                  else if(_acQueue[userName][perUserAvId].ilReceived == true && fromAc)
                  {
                     if(Boolean(_avatarList[sfsId]) && Boolean(_acQueue[userName][perUserAvId].ilResponse))
                     {
                        ilAvatar = _avatarList[sfsId];
                        ItemXtCommManager.insertIntoILAvatarQueue(ilAvatar.perUserAvId,null,ilAvatar);
                        ItemXtCommManager.handleIlWhenBeforeACAfterReceivingAC(_acQueue[userName][perUserAvId].ilResponse);
                        shouldDelete = true;
                     }
                     else
                     {
                        ItemXtCommManager.removeFromILAvatarQueue(userName,perUserAvId);
                        shouldDelete = false;
                     }
                  }
                  if(shouldDelete)
                  {
                     delete _acQueue[userName][perUserAvId];
                     if(Utility.numProperties(_acQueue[userName]) == 0)
                     {
                        delete _acQueue[userName];
                     }
                  }
               }
            }
         }
         else
         {
            _acQueue[userName] = {};
            _acQueue[userName][perUserAvId] = {
               "ilReceived":!fromAc,
               "acReceived":fromAc,
               "ilResponse":ilResponse
            };
         }
      }
      
      public static function getDefaultAvatarByDefId(avtDefId:int) : Avatar
      {
         var avtDef:Object = gMainFrame.userInfo.getAvatarDefByAvType(avtDefId);
         if(!avtDef)
         {
            trace("Error loading avatarDef where defId=" + avtDefId);
            return null;
         }
         var colors:Array = [avtDef.colorLayer1,avtDef.colorLayer2,avtDef.colorLayer3];
         var avt:Avatar = new Avatar();
         avt.init(-1,"redemAvt",avtDefId,colors);
         var items:Array = [];
         items[0] = ItemXtCommManager.getBodyModFromDefId(1,avtDefId,true,false);
         items[1] = ItemXtCommManager.getBodyModFromDefId(avtDef.defEyes,avtDefId,true,false);
         if(avtDef.defPattern > 0)
         {
            items[2] = ItemXtCommManager.getBodyModFromDefId(avtDef.defPattern,avtDefId,true,false);
         }
         avt.itemResponseIntegrate(items);
         return avt;
      }
      
      public static function avatarRemoveResponse(data:Array) : void
      {
         var rname:String = null;
         var rid:int = int(data[2]);
         if(_waitForLangPack && _waitForLangPackSfsUserIdToACResponseDataMap[rid] !== undefined)
         {
            delete _waitForLangPackSfsUserIdToACResponseDataMap[rid];
         }
         if(Boolean(gMainFrame.clientInfo.extCallsActive))
         {
            rname = _avatarList[rid].userName;
            ExternalInterface.call("mrc",["uer",rname,false]);
         }
         if(data.length > 3 && int(data[3]) > 0)
         {
            if(Boolean(_avatarViewList[rid]))
            {
               updateAvatar(rid,int(data[4]),int(data[5]),false);
               _avatarViewList[rid].deleteOnMoveComplete = true;
            }
         }
         else
         {
            removeAvatar(rid);
         }
      }
      
      public static function toggleNamebarSelNubs(evt:BuddyEvent) : void
      {
         var av:AvatarWorldView = null;
         for each(av in _avatarViewList)
         {
            av.toggleNamebarSelNub();
         }
      }
      
      public static function connectionLost() : void
      {
         if(Boolean(_avatarList[_playerSfsUserId]))
         {
            removeAvatar(_playerSfsUserId);
         }
         _playerSfsUserId = -1;
      }
      
      public static function isValidEnviro(enviroType:int) : Boolean
      {
         var avatarEnviroType:int = playerAvatar.enviroTypeFlag;
         return !((enviroType & avatarEnviroType) == 0 || (avatarEnviroType & 1 << Utility.ENVIRO_AIR) != 0 && (enviroType & 1 << Utility.ENVIRO_AIR) == 0);
      }
   }
}

