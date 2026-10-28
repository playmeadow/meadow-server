package room
{
   import Party.PartyXtCommManager;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarWorldView;
   import avatar.AvatarXtCommManager;
   import avatar.UserCommXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopup;
   import com.sbi.popup.SBPopupManager;
   import com.sbi.popup.SBStandardPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenXtCommManager;
   import ecard.ECardManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.GradientType;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import game.MinigameInfo;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gamePlayFlow.GamePlay;
   import gui.AdventureExpertPopup;
   import gui.AdventureJoin;
   import gui.BuddyCard;
   import gui.BuddyManager;
   import gui.ChatHistory;
   import gui.DarkenManager;
   import gui.DenPreviewManager;
   import gui.FeedbackManager;
   import gui.GenericListGuiManager;
   import gui.GuiManager;
   import gui.JBManager;
   import gui.NGFactManager;
   import gui.PartyManager;
   import gui.PollManager;
   import gui.PredictiveTextManager;
   import gui.RecycleItems;
   import gui.SafeChatManager;
   import gui.ServerSelector;
   import gui.UpsellManager;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   
   public class RoomManagerWorld extends RoomManagerView
   {
      
      private static var _instance:RoomManagerWorld;
      
      public static var _ffmCloseCallback:Function;
      
      private static const ROOM_SFX_MEDIA_ID:int = 1625;
      
      private static const ACTION_POINT_TYPE_MINIGAME:int = 0;
      
      private static const ACTION_POINT_TYPE_SHOP:int = 1;
      
      private static const ACTION_POINT_TYPE_NGFACT:int = 2;
      
      private static const ACTION_POINT_TYPE_POLL:int = 3;
      
      private static const ACTION_POINT_TYPE_FEEDBACK:int = 4;
      
      private static const ACTION_POINT_TYPE_QUEST_ACTOR:int = 5;
      
      private static const ACTION_POINT_TYPE_LAUNCH_QUEST:int = 6;
      
      private static const ACTION_POINT_TYPE_QUEST_RESPAWN:int = 7;
      
      public static const ROOM_MODE_AVATAR:int = 0;
      
      public static const ROOM_MODE_DEN:int = 1;
      
      public static const ROOM_MODE_CAMERAFOCUS_TO_TARGET:int = 2;
      
      public static const ROOM_MODE_CAMERAFOCUS_STAY:int = 3;
      
      public static const ROOM_MODE_CAMERAFOCUS_RETURN:int = 4;
      
      private static var _hasOpenedClothesShop:Boolean = false;
      
      private static var _hasOpenedDenShop:Boolean = false;
      
      private var _roomMode:int;
      
      private var _roomEnviroType:int;
      
      private var _bIsMyDen:Boolean;
      
      private var _gotoUsername:String;
      
      private var _cameraFocusTimer:Number;
      
      private var _cameraFocusToTime:Number;
      
      private var _cameraFocusStayTime:Number;
      
      private var _cameraFocusReturnTime:Number;
      
      private var _cameraFocusPoint:Point;
      
      private var _cameraReturnPoint:Point;
      
      private var _cameraSpeedX:Number;
      
      private var _cameraSpeedY:Number;
      
      private var _bAttemptingToJoinMinigameRoom:Boolean;
      
      private var _lastGoodRoomName:String;
      
      private var _fullRoomSpawn:String;
      
      private var _lastPortal:Object;
      
      private var _shardId:int;
      
      public var _gotNewShardId:Boolean;
      
      private var _forceInvisMode:Boolean;
      
      private var _factDefIds:Array;
      
      private var _factDefLocs:Array;
      
      private var _denOwnerName:String;
      
      private var _denCatId:int;
      
      private var _recycle:RecycleItems;
      
      private var _bounceVolumes:Array;
      
      private var _denItems:DenItemHolder;
      
      public var _bInDenShop:Boolean;
      
      private var _dragAccelX:Number;
      
      private var _dragAccelY:Number;
      
      private var _dragX:Number;
      
      private var _dragY:Number;
      
      private var _bLastShowDenHud:Boolean;
      
      private var _callback_FFMRoomAssetsLoaded:Function;
      
      private var _callback_InitialDataRequest:Function;
      
      private var _callback_TriggerWalkIn:Function;
      
      private var _theaterLayer:Object;
      
      private var _jbItems:Array;
      
      private var _shouldLoadMessagePopups:Boolean;
      
      private var _bMouseDownIgnore:Boolean;
      
      private var _bMouseDownForDenPortal:Boolean;
      
      private var _inAndOutItems:Object;
      
      private var _jamaaMS:Number = -1;
      
      private var _prevGetTimer:Number = 0;
      
      private var _customMinigameLoaderInfos:Array;
      
      private var _needsToSeeKickFromDenMessage:Boolean;
      
      private var _needsToSeeFacilitatorMessage:Boolean;
      
      private var _facilitatorMessage:Object;
      
      private var allPreviouslyNeededRoomItems:Object;
      
      public function RoomManagerWorld(lock:Class)
      {
         super();
         if(lock != SingletonLock)
         {
            throw new Error("Invalid access.  Use RoomManager.instance");
         }
      }
      
      public static function get instance() : RoomManagerWorld
      {
         if(!_instance)
         {
            _instance = new RoomManagerWorld(SingletonLock);
         }
         return _instance;
      }
      
      public static function getObjUnderPoint(pos:Point, dispLayer:DisplayObjectContainer) : Object
      {
         var i:int = 0;
         var itemsUnderPoint:Array = dispLayer.getObjectsUnderPoint(pos);
         var total:int = int(itemsUnderPoint.length);
         if(total > 0)
         {
            for(i = total - 1; i >= 0; i--)
            {
               if(fullHitTest(itemsUnderPoint[i].root,pos))
               {
                  return itemsUnderPoint[i].root;
               }
            }
         }
         return null;
      }
      
      public static function fullHitTest(img:DisplayObject, pos:Point) : Boolean
      {
         var bmapData:BitmapData = null;
         var returnVal:Boolean = false;
         if(Boolean(img) && Boolean(img is MovieClip) && img.hasOwnProperty("isJBItem"))
         {
            return img.hitTestPoint(pos.x,pos.y,true);
         }
         if(Boolean(img))
         {
            try
            {
               bmapData = new BitmapData(img.width,img.height,true,0);
               bmapData.draw(img,new Matrix());
               returnVal = bmapData.hitTest(new Point(0,0),0,img.globalToLocal(pos));
               bmapData.dispose();
               return returnVal;
            }
            catch(e:Error)
            {
               trace("Security sandbox violation caught or BitmapData invalid");
            }
            return false;
         }
         return false;
      }
      
      override public function init(layerManager:LayerManager) : void
      {
         super.init(layerManager);
         this._bAttemptingToJoinMinigameRoom = false;
         this._lastGoodRoomName = null;
         this._shardId = 0;
         this._gotNewShardId = false;
         this._forceInvisMode = false;
         this._denItems = new DenItemHolder(layerManager);
         gMainFrame.server.addEventListener(SFEvent.ON_JOIN_ROOM,this.onJoinRoom);
         this._denOwnerName = "";
         this._customMinigameLoaderInfos = [];
         loadRoomEventSfx(ROOM_SFX_MEDIA_ID);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         gMainFrame.server.removeEventListener(SFEvent.ON_JOIN_ROOM,this.onJoinRoom);
      }
      
      override public function exitRoom(isDenPreview:Boolean = false) : void
      {
         GuiManager.onExitRoom();
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            QuestManager.onExitRoom();
         }
         DarkenManager.clearDarkenList();
         super.exitRoom(isDenPreview);
         this._lastPortal = null;
         if(!isDenPreview)
         {
            this._denItems.release();
         }
         SBPopupManager.closeAll();
         SBPopupManager.destroyNonSBPopups();
         GenericListGuiManager.onRoomExit();
         if(Boolean(_scene) && Boolean(_spawns))
         {
            if(Boolean(this._theaterLayer))
            {
               this._theaterLayer = null;
            }
         }
         this._bIsMyDen = false;
         this.setRoomMode(ROOM_MODE_AVATAR);
         gMainFrame.stage.invalidate();
      }
      
      public function loadRoom(pathname:String, enviroType:int, roomType:int, secondaryDefId:int, zoom:int) : void
      {
         if(pathname != "qcqNoLoad")
         {
            if(pathname == "jamaa_township.first_five")
            {
               if(this._callback_FFMRoomAssetsLoaded != null)
               {
                  RoomXtCommManager._loadingNewRoom = false;
                  this._callback_FFMRoomAssetsLoaded();
                  this._callback_FFMRoomAssetsLoaded = null;
               }
            }
            else
            {
               _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = zoom / 100;
               this._roomEnviroType = enviroType;
               AvatarManager.roomEnviroType = this._roomEnviroType;
               loadRoom_base(pathname,this.loadAvatarAssets);
               gMainFrame.clientInfo.roomType = roomType;
               gMainFrame.clientInfo.secondaryDefId = secondaryDefId;
               if(this._denOwnerName != "")
               {
                  if(this._denOwnerName == gMainFrame.server.userName)
                  {
                     _gaRoomName += "/owner";
                  }
                  else
                  {
                     _gaRoomName += "/stranger";
                  }
               }
               DarkenManager.showLoadingSpiral(false);
               gMainFrame.stage.focus = null;
               _pathName = pathname;
            }
         }
      }
      
      public function reloadCurrentNormalRoom() : void
      {
         var myAvatarView:AvatarWorldView = null;
         if(Boolean(this.allPreviouslyNeededRoomItems))
         {
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = this.allPreviouslyNeededRoomItems.scale;
            this._roomEnviroType = this.allPreviouslyNeededRoomItems.enviroType;
            resetCurrentRoom_base(this.allPreviouslyNeededRoomItems.pathName);
            onRoomLoaded_base(this.sceneAssetsLoaded,this.allPreviouslyNeededRoomItems.scene);
            this.denItemHolder.reloadItems();
            convertPathToWorldSpace();
            this.initActionPoints();
            if(Boolean(AvatarManager.playerAvatarWorldView))
            {
               myAvatarView = AvatarManager.playerAvatarWorldView;
               myAvatarView.roomType = this.allPreviouslyNeededRoomItems.roomEnviroType;
               AvatarManager.updatePlayerAvatarViewParent(true);
               AvatarManager.resetThrottle();
               myAvatarView.setSplashVolume(this.allPreviouslyNeededRoomItems.isInSplash,this.allPreviouslyNeededRoomItems.splashLiquid);
               myAvatarView.playIdle();
               AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,this.allPreviouslyNeededRoomItems.pos.x,this.allPreviouslyNeededRoomItems.pos.y,false,false,true);
               this.setRoomMode(this.allPreviouslyNeededRoomItems.prevRoomMode);
            }
            _scrollOffset = this.allPreviouslyNeededRoomItems.scrollOffset;
            DenPreviewManager.handleAllRequiredVisibilities(true);
         }
      }
      
      public function loadDenPreviewRoom(pathname:String, roomEnviroType:int) : void
      {
         var isInSplash:Boolean = false;
         var splashLiquid:String = null;
         var myAvatarView:AvatarWorldView = null;
         var avtPos:Point = null;
         if(Boolean(AvatarManager.playerAvatarWorldView))
         {
            myAvatarView = AvatarManager.playerAvatarWorldView;
            avtPos = new Point(myAvatarView.avatarPos.x,myAvatarView.avatarPos.y);
            isInSplash = myAvatarView.inSplashVolume();
            splashLiquid = myAvatarView.splashLiquid;
            myAvatarView.setSplashVolume(false,null);
            myAvatarView.roomType = roomEnviroType;
            myAvatarView.playIdle();
         }
         this.allPreviouslyNeededRoomItems = {
            "pathName":_pathName,
            "scale":_layerManager.bkg.scaleX,
            "roomEnviroType":this._roomEnviroType,
            "scene":_scene.sceneObject,
            "pos":avtPos,
            "scrollOffset":new Point(_scrollOffset.x,_scrollOffset.y),
            "isInSplash":isInSplash,
            "splashLiquid":splashLiquid,
            "prevRoomMode":this._roomMode
         };
         loadRoom_base(pathname,this.loadDenPreviewAvatar,true);
      }
      
      public function getDarknessFromScene() : Array
      {
         var volume:Object = null;
         var i:int = 0;
         var volumeShape:Shape = null;
         var gradientLength:int = 0;
         var delta:int = 0;
         var numSoftEdges:int = 0;
         var params:Array = null;
         var d:Point = null;
         var mtx:Matrix = null;
         var normal:Point = null;
         var volumes:Array = _volumeManager.findVolumesByType(VolumeManager.VOLUMETYPE_DARKSOFT);
         var returnArray:Array = new Array();
         for each(volume in volumes)
         {
            volumeShape = new Shape();
            volumeShape.graphics.beginFill(0);
            volumeShape.graphics.moveTo(volume.v[0].x,volume.v[0].y);
            for(i = 1; i < volume.v.length; i++)
            {
               volumeShape.graphics.lineTo(volume.v[i].x,volume.v[i].y);
            }
            volumeShape.graphics.endFill();
            returnArray.push(volumeShape);
            gradientLength = 20;
            delta = 2;
            numSoftEdges = 1;
            if(Boolean(volume.message.length))
            {
               params = volume.message.split(",");
               if(params.length == 2)
               {
                  numSoftEdges = int(params[0]);
                  gradientLength = int(params[1]);
               }
            }
            for(i = 0; i < numSoftEdges; i++)
            {
               d = volume.v[i].subtract(volume.v[i + 1]);
               mtx = new Matrix();
               mtx.createGradientBox(d.length,gradientLength,-Math.PI / 2);
               normal = new Point(-d.y,d.x);
               normal.normalize(1);
               volumeShape = new Shape();
               volumeShape.graphics.beginGradientFill(GradientType.LINEAR,[0,0],[0,1],[0,255],mtx);
               volumeShape.graphics.drawRect(0,0,d.length,gradientLength);
               volumeShape.rotation = Math.atan2(d.y,d.x) * 180 / Math.PI;
               volumeShape.x = volume.v[i + 1].x - delta * normal.x;
               volumeShape.y = volume.v[i + 1].y - delta * normal.y;
               returnArray.push(volumeShape);
            }
         }
         volumes = _volumeManager.findVolumesByType(VolumeManager.VOLUMETYPE_DARKHARD);
         for each(volume in volumes)
         {
            volumeShape = new Shape();
            volumeShape.graphics.beginFill(0);
            volumeShape.graphics.moveTo(volume.v[0].x,volume.v[0].y);
            for(i = 1; i < volume.v.length; i++)
            {
               volumeShape.graphics.lineTo(volume.v[i].x,volume.v[i].y);
            }
            volumeShape.graphics.endFill();
            returnArray.push(volumeShape);
         }
         return returnArray;
      }
      
      private function loadAvatarAssets() : void
      {
         DebugUtility.debugTrace("loading self assets");
         AvatarManager.loadSelfAssets(this.onRoomLoaded);
         this._bIsMyDen = this._denOwnerName == gMainFrame.server.userName;
         if(this._bIsMyDen)
         {
            _playerGotoSpawnPoint = "myden";
         }
         GuiManager.activateDenHud(this._bIsMyDen);
         if(this._needsToSeeKickFromDenMessage)
         {
            this._needsToSeeKickFromDenMessage = false;
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18073));
         }
         if(this._needsToSeeFacilitatorMessage)
         {
            this._needsToSeeFacilitatorMessage = false;
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(this._facilitatorMessage.messageId,this._facilitatorMessage.duration));
            this._facilitatorMessage = null;
         }
      }
      
      private function loadDenPreviewAvatar() : void
      {
         AvatarManager.updatePlayerAvatarViewParent(false);
         DenPreviewManager.handleAllRequiredVisibilities(false);
         this.onDenPreviewRoomLoaded(null);
      }
      
      protected function onDenPreviewRoomLoaded(object:*) : void
      {
         var spawn:Object = null;
         var jumpAv:Avatar = null;
         var jumpToAv:AvatarWorldView = null;
         var pos:Point = null;
         onRoomLoaded_base(this.sceneAssetsLoaded,null,true);
         convertPathToWorldSpace();
         this.initActionPoints();
         if(this._gotoUsername == null || this._gotoUsername == "" || (jumpAv = AvatarManager.getAvatarByUserName(this._gotoUsername)) == null || (jumpToAv = AvatarManager.avatarViewList[jumpAv.sfsUserId]) == null)
         {
            if(_playerGotoSpawnPoint == USE_PLAYER_GOTO_SPAWN_LOCATION)
            {
               pos = new Point();
               spawn = {};
               spawn.x = pos.x = _playerGotoSpawnLocationX;
               spawn.y = pos.y = _playerGotoSpawnLocationY;
            }
            else
            {
               spawn = findSpawn(_spawns,_playerGotoSpawnPoint);
               if(!spawn)
               {
                  spawn = findSpawn(_spawns,"default");
                  if(!spawn)
                  {
                     spawn = {
                        "x":400,
                        "y":400,
                        "r":10,
                        "toSpawn":null
                     };
                  }
               }
               pos = getRandomRadiusOffset(spawn.r);
               spawn.x += pos.x;
               spawn.y += pos.y;
               pos = new Point(spawn.x,spawn.y);
               convertToWorldSpace(pos);
            }
            _playerGotoSpawnPoint = "default";
         }
         else
         {
            pos = new Point();
            spawn = {};
            spawn.x = pos.x = jumpToAv.x;
            spawn.y = pos.y = jumpToAv.y;
            spawn.x += _mainBackObj.x;
            spawn.y += _mainBackObj.y;
            this._gotoUsername = null;
         }
         _scrollOffset.x = MainFrame.VIEW_WIDTH * 0.5 - spawn.x;
         _scrollOffset.y = MainFrame.VIEW_HEIGHT * 0.5 - spawn.y;
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,pos.x,pos.y,false,false);
      }
      
      protected function onRoomLoaded(object:*) : void
      {
         var pos:Point = null;
         var spawn:Object = null;
         var jumpAv:Avatar = null;
         var jumpToAv:AvatarWorldView = null;
         onRoomLoaded_base(this.sceneAssetsLoaded,null);
         this._denCatId = Boolean(_roomSettings.denCatId) ? int(_roomSettings.denCatId) : -1;
         convertPathToWorldSpace();
         this.initActionPoints();
         var themePos:Object = findSpawn(_spawns,"den_theme");
         if(Boolean(themePos))
         {
            this._denItems.setThemePosition(themePos.x,themePos.y);
         }
         if(this._denOwnerName != "")
         {
            DenXtCommManager.denChangeDone();
         }
         if(Boolean(gMainFrame.clientInfo.extCallsActive))
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoUsername:" + this._gotoUsername);
            DebugUtility.debugTrace("onRoomLoaded - (jumpAv = AvatarManager.getAvatarByUserName(_gotoUsername)) == null:" + ((jumpAv = AvatarManager.getAvatarByUserName(this._gotoUsername)) == null));
            DebugUtility.debugTrace("onRoomLoaded - jumpAv:" + jumpAv);
            if(jumpAv != null)
            {
               DebugUtility.debugTrace("onRoomLoaded - (jumpToAv = AvatarManager.avatarViewList[jumpAv.sfsUserId]) == null:" + ((jumpToAv = AvatarManager.avatarViewList[jumpAv.sfsUserId]) == null));
            }
            DebugUtility.debugTrace("onRoomLoaded - jumpToAv:" + jumpToAv);
         }
         if(this._gotoUsername == null || this._gotoUsername == "" || (jumpAv = AvatarManager.getAvatarByUserName(this._gotoUsername)) == null || (jumpToAv = AvatarManager.avatarViewList[jumpAv.sfsUserId]) == null)
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoSpawnPoint:" + _playerGotoSpawnPoint);
            if(_playerGotoSpawnPoint == USE_PLAYER_GOTO_SPAWN_LOCATION)
            {
               pos = new Point();
               spawn = {};
               spawn.x = pos.x = _playerGotoSpawnLocationX;
               spawn.y = pos.y = _playerGotoSpawnLocationY;
            }
            else
            {
               spawn = findSpawn(_spawns,_playerGotoSpawnPoint);
               if(!spawn)
               {
                  spawn = findSpawn(_spawns,"default");
                  if(!spawn)
                  {
                     spawn = {
                        "x":400,
                        "y":400,
                        "r":10,
                        "toSpawn":null
                     };
                  }
               }
               pos = getRandomRadiusOffset(spawn.r);
               spawn.x += pos.x;
               spawn.y += pos.y;
               pos = new Point(spawn.x,spawn.y);
               convertToWorldSpace(pos);
            }
            _playerGotoSpawnPoint = "default";
         }
         else
         {
            DebugUtility.debugTrace("onRoomLoaded - pos:" + pos);
            pos = new Point();
            spawn = {};
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn:" + spawn + " pos:" + pos + " jumpToAv:" + jumpToAv);
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn.x:" + spawn.x + " pos.x:" + pos.x + " jumpToAv.x:" + jumpToAv.x);
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn.y:" + spawn.y + " pos.y:" + pos.y + " jumpToAv.y:" + jumpToAv.y);
            spawn.x = pos.x = jumpToAv.x;
            spawn.y = pos.y = jumpToAv.y;
            DebugUtility.debugTrace("onRoomLoaded - mainBackObj offset spawn:" + spawn + " _mainBackObj:" + _mainBackObj);
            spawn.x += _mainBackObj.x;
            spawn.y += _mainBackObj.y;
            DebugUtility.debugTrace("onRoomLoaded - after spawn:" + spawn + " pos:" + pos + " jumpToAv:" + jumpToAv);
            DebugUtility.debugTrace("onRoomLoaded - after spawn.x:" + spawn.x + " pos.x:" + pos.x + " jumpToAv.x:" + jumpToAv.x);
            DebugUtility.debugTrace("onRoomLoaded - after spawn.y:" + spawn.y + " pos.y:" + pos.y + " jumpToAv.y:" + jumpToAv.y);
            this._gotoUsername = null;
            DebugUtility.debugTrace("onRoomLoaded - set null _gotoUsername:" + this._gotoUsername);
         }
         if(Boolean(gMainFrame.clientInfo.extCallsActive))
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoUsername:" + this._gotoUsername + " jumpAv:" + jumpAv);
         }
         _scrollOffset.x = MainFrame.VIEW_WIDTH * 0.5 - spawn.x;
         _scrollOffset.y = MainFrame.VIEW_HEIGHT * 0.5 - spawn.y;
         AvatarManager.playerAvatarWorldView.playAnim(this._roomEnviroType == 0 ? LayerAnim.AN_IDLE_SE : LayerAnim.AN_FLOAT);
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,pos.x,pos.y,true,false);
         QuestManager.checkQuestOffScreenUsers();
         AvatarSwitch.playerInfoSet();
         _bTestPortal = true;
         if(spawn.toSpawn != null)
         {
            walkToSpawn(spawn.toSpawn);
         }
         GuiManager.onEnterRoom(this._roomEnviroType);
         GuiManager.showHudAvt();
         if(!gMainFrame.userInfo.playerUserInfo.denItemsFull)
         {
            DenXtCommManager.requestDenItems(null);
         }
         if(this._shouldLoadMessagePopups)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["lw"]);
            }
         }
      }
      
      private function initActionPoints() : void
      {
         var i:int = 0;
         var o:Object = null;
         var pos:Point = null;
         var factDefIds:Array = null;
         var factDefLocs:Array = null;
         var pollDefIds:Array = null;
         var pollDefLocs:Array = null;
         var feedbackDefIds:Array = null;
         var feedbackDefLocs:Array = null;
         var actionClick:MovieClip = null;
         var actionTotem:MovieClip = null;
         var SHOP_RADIUS:int = 0;
         var actLoader:Loader = null;
         var mgDefIds:Array = [];
         if(_actionPoints != null)
         {
            factDefIds = [];
            factDefLocs = [];
            pollDefIds = [];
            pollDefLocs = [];
            feedbackDefIds = [];
            feedbackDefLocs = [];
            for(i = 0; i < _actionPoints.length; i++)
            {
               o = _actionPoints[i];
               if(o.hasOwnProperty("type"))
               {
                  switch(o.type)
                  {
                     case ACTION_POINT_TYPE_MINIGAME:
                        if(!MinigameManager.minigameInfoCache.getMinigameInfo(o.typeDefId))
                        {
                           mgDefIds.push(o.typeDefId);
                        }
                        else
                        {
                           actionTotem = new MinigameManager.GameTotem() as MovieClip;
                           if(MinigameManager.minigameInfoCache.getMinigameInfo(o.typeDefId).petDefId > 0)
                           {
                              actLoader = actionTotem.getChildAt(0) as Loader;
                              actLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPetGameTotemLoaded);
                              this._customMinigameLoaderInfos.push(actLoader.contentLoaderInfo);
                           }
                           if(MinigameManager.minigameInfoCache.getMinigameInfo(o.typeDefId).gameDefId == 88)
                           {
                              actLoader = actionTotem.getChildAt(0) as Loader;
                              actLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onSafetyGameTotemLoaded);
                              this._customMinigameLoaderInfos.push(actLoader.contentLoaderInfo);
                           }
                           pos = new Point(o.x - actionTotem.width * 0.5,o.y - actionTotem.height);
                           convertToWorldSpace(pos);
                           actionTotem.x = pos.x;
                           actionTotem.y = pos.y;
                           _layerManager.room_orbs.addChild(actionTotem);
                           actionClick = actionTotem;
                        }
                        break;
                     case ACTION_POINT_TYPE_SHOP:
                        SHOP_RADIUS = 60;
                        pos = new Point(o.x - SHOP_RADIUS,o.y - SHOP_RADIUS);
                        convertToWorldSpace(pos);
                        o.pos = pos;
                        o.rad = SHOP_RADIUS;
                        break;
                     case ACTION_POINT_TYPE_NGFACT:
                        pos = new Point(o.x,o.y);
                        convertToWorldSpace(pos);
                        factDefLocs[o.typeDefId] = pos;
                        factDefIds.push(o.typeDefId);
                        break;
                     case ACTION_POINT_TYPE_POLL:
                        pos = new Point(o.x,o.y);
                        convertToWorldSpace(pos);
                        pollDefLocs[o.typeDefId] = pos;
                        pollDefIds.push(o.typeDefId);
                        break;
                     case ACTION_POINT_TYPE_FEEDBACK:
                        pos = new Point(o.x,o.y);
                        convertToWorldSpace(pos);
                        feedbackDefLocs[o.typeDefId] = pos;
                        feedbackDefIds.push(o.typeDefId);
                        break;
                     case ACTION_POINT_TYPE_LAUNCH_QUEST:
                        actionTotem = new MinigameManager.GameTotem() as MovieClip;
                        pos = new Point(o.x - actionTotem.width * 0.5,o.y - actionTotem.height);
                        convertToWorldSpace(pos);
                        actionTotem.x = pos.x;
                        actionTotem.y = pos.y;
                        _layerManager.room_orbs.addChild(actionTotem);
                        actionClick = actionTotem;
                        break;
                     case ACTION_POINT_TYPE_QUEST_ACTOR:
                        if(o.hasOwnProperty("name"))
                        {
                           pos = new Point(o.x,o.y);
                           convertToWorldSpace(pos);
                           QuestManager.initQuestActor(o.name,o.r,o.r2,null,pos,null,true,o.params);
                        }
                        break;
                     case ACTION_POINT_TYPE_QUEST_RESPAWN:
                        pos = new Point(o.x,o.y);
                        convertToWorldSpace(pos);
                        o.pos = pos;
                        break;
                     default:
                        throw new Error("Actionpoint type is not valid!");
                  }
                  o.idx = i;
                  if(Boolean(actionClick))
                  {
                     actionClick.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_ActionPoint,false,0,true);
                     actionClick.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOverEvt_ActionPoint,false,0,true);
                     actionClick.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOutEvt_ActionPoint,false,0,true);
                     o.clip = actionClick;
                  }
               }
            }
            if(factDefIds.length > 0)
            {
               this._factDefIds = factDefIds;
               this._factDefLocs = factDefLocs;
               if(Boolean(this._factDefIds) && Boolean(this._factDefLocs))
               {
                  NGFactManager.requestFactInfo(factDefIds,factDefLocs);
               }
            }
            if(pollDefIds.length > 0 && gMainFrame.userInfo.numLogins >= 3)
            {
               PollManager.setUpPolls(pollDefIds,pollDefLocs);
            }
            if(feedbackDefIds.length > 0)
            {
               FeedbackManager.setUpOrbs(feedbackDefIds,feedbackDefLocs);
            }
         }
         if(Boolean(_volumes))
         {
            for(i = 0; i < _volumes.length; i++)
            {
               o = _volumes[i];
               switch(o.type)
               {
                  case 1:
                     o.idx = i;
                     if(!MinigameManager.minigameInfoCache.getMinigameInfo(o.typeDefId))
                     {
                        mgDefIds.push(o.typeDefId);
                     }
               }
            }
         }
         if(mgDefIds.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(mgDefIds,false,this.setupMinigameActionPoints);
         }
      }
      
      public function setupMinigameActionPoints() : void
      {
         var o:Object = null;
         var pos:Point = null;
         var actionClick:MovieClip = null;
         var gameDef:MinigameInfo = null;
         var actionTotem:MovieClip = null;
         var gameLoader:Loader = null;
         if(!_actionPoints || _actionPoints.length <= 0)
         {
            return;
         }
         for(var i:int = 0; i < _actionPoints.length; i++)
         {
            o = _actionPoints[i];
            if(o.hasOwnProperty("type"))
            {
               if(o.type == ACTION_POINT_TYPE_MINIGAME)
               {
                  gameDef = MinigameManager.minigameInfoCache.getMinigameInfo(o.typeDefId);
                  if(!gameDef)
                  {
                     return;
                  }
                  actionTotem = new MinigameManager.GameTotem() as MovieClip;
                  pos = new Point(o.x - actionTotem.width * 0.5,o.y - actionTotem.height);
                  convertToWorldSpace(pos);
                  if(gameDef.petDefId > 0)
                  {
                     gameLoader = actionTotem.getChildAt(0) as Loader;
                     gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPetGameTotemLoaded);
                     this._customMinigameLoaderInfos.push(gameLoader.contentLoaderInfo);
                  }
                  if(gameDef.gameDefId == 88)
                  {
                     gameLoader = actionTotem.getChildAt(0) as Loader;
                     gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onSafetyGameTotemLoaded);
                     this._customMinigameLoaderInfos.push(gameLoader.contentLoaderInfo);
                  }
                  actionTotem.x = pos.x;
                  actionTotem.y = pos.y;
                  _layerManager.room_orbs.addChild(actionTotem);
                  actionClick = actionTotem;
                  actionClick.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_ActionPoint,false,0,true);
                  actionClick.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOverEvt_ActionPoint,false,0,true);
                  actionClick.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOutEvt_ActionPoint,false,0,true);
                  o.clip = actionClick;
               }
            }
         }
      }
      
      private function onPetGameTotemLoaded(e:Event) : void
      {
         var li:LoaderInfo = null;
         var totem:MovieClip = null;
         for(var i:int = 0; i < this._customMinigameLoaderInfos.length; i++)
         {
            li = this._customMinigameLoaderInfos[i];
            if(!(!li || li != LoaderInfo(e.target)))
            {
               this._customMinigameLoaderInfos.splice(i,1);
               totem = li.loader.content as MovieClip;
               totem.gotoAndPlay("petController");
               break;
            }
         }
      }
      
      private function onSafetyGameTotemLoaded(e:Event) : void
      {
         var li:LoaderInfo = null;
         var totem:MovieClip = null;
         for(var i:int = 0; i < this._customMinigameLoaderInfos.length; i++)
         {
            li = this._customMinigameLoaderInfos[i];
            if(!(!li || li != LoaderInfo(e.target)))
            {
               this._customMinigameLoaderInfos.splice(i,1);
               totem = li.loader.content as MovieClip;
               totem.gotoAndPlay("safetyquiz");
               break;
            }
         }
      }
      
      public function onNormalFactPopupsReady() : void
      {
         if(Boolean(this._factDefIds) && Boolean(this._factDefLocs))
         {
            NGFactManager.requestFactInfo(this._factDefIds,this._factDefLocs);
            this._factDefIds = null;
            this._factDefLocs = null;
         }
      }
      
      public function onJourneyBookFactDefReceived(jbFactDef:Object, nonUsedVar:int) : void
      {
         var jbItem:Object = null;
         var isSeen:Boolean = false;
         var refObjName:String = null;
         var j:int = 0;
         for(var i:int = 0; i < this._jbItems.length; i++)
         {
            jbItem = this._jbItems[i];
            if(jbItem.refId == jbFactDef.id && (jbItem.refObjName == "" || jbItem.refObjName.indexOf("start") == 0))
            {
               isSeen = Boolean(gMainFrame.userInfo.userVarCache.isBitSet(jbFactDef.userVarId,jbFactDef.bitIdx));
               if(isSeen)
               {
                  this._jbItems.splice(i,1);
               }
               else
               {
                  jbItem.isReady = true;
               }
               refObjName = jbItem.refObjName;
               while(refObjName != "" && refObjName != "end")
               {
                  if(refObjName.indexOf("start") == 0)
                  {
                     refObjName = refObjName.substr(6);
                     if(isSeen)
                     {
                        jbItem.s.content.visible = true;
                        if(Boolean(jbItem.s.content.hasOwnProperty("critter")))
                        {
                           jbItem.s.content.critter.visible = true;
                        }
                     }
                  }
                  jbItem = this.getJourneyBookItem(refObjName);
                  if(isSeen)
                  {
                     for(j = 0; j < this._jbItems.length; j++)
                     {
                        if(this._jbItems[j].refId == jbItem.refId)
                        {
                           this._jbItems.splice(j,1);
                        }
                     }
                     jbItem.s.content.visible = true;
                  }
                  else
                  {
                     jbItem.isReady = true;
                  }
                  refObjName = jbItem.refObjName;
               }
               break;
            }
         }
         JBManager.checkUnseenPage(this._jbItems);
      }
      
      public function playMusic(fileName:String, volume:Number) : void
      {
         playMusicTrack(fileName,volume);
      }
      
      public function playPreviousMusic() : void
      {
         playPreviousMusicTrack();
      }
      
      override protected function sceneAssetsLoaded(e:Event) : void
      {
         var o:Object = null;
         var jbItem:Object = null;
         var i:int = 0;
         var shouldAppear:Boolean = false;
         var startOffset:int = 0;
         var refObjName:String = null;
         var userVar:int = 0;
         var currIndex:int = 0;
         var volumes:Array = null;
         var v:Object = null;
         var helperObj:Object = null;
         super.sceneAssetsLoaded(e);
         this._jbItems = [];
         this._inAndOutItems = {};
         for(i = 0; i < _layers.length; i++)
         {
            o = _layers[i];
            if(o.typeIndex == 1)
            {
               shouldAppear = true;
               if(Boolean(o.s.content.hasOwnProperty("randomAppear")))
               {
                  shouldAppear = Boolean(o.s.content.randomAppear());
               }
               if(shouldAppear)
               {
                  o.s.content.isJBItem = true;
               }
               this._jbItems.push(o);
            }
            if(o.typeIndex == 1 || o.typeIndex == 2)
            {
               if(Boolean(o.delaySecs) && Boolean(!isNaN(o.delaySecs)) && Boolean(o.s.content.hasOwnProperty("playAnim")))
               {
                  if(o.typeIndex == 2 && o.offsetSecs != null && !isNaN(o.offsetSecs))
                  {
                     startOffset = int(o.offsetSecs);
                  }
                  else
                  {
                     startOffset = o.delaySecs / 2;
                  }
                  this._inAndOutItems[i] = [];
                  while(startOffset <= 60 * 60)
                  {
                     this._inAndOutItems[i].push(startOffset);
                     startOffset += o.delaySecs;
                  }
               }
            }
            if(!_scene._useDynamicLoading && o.layer == 1)
            {
               if(Boolean(o.s.hasOwnProperty("content")) && Boolean(o.s.content.hasOwnProperty("getSortHeight")))
               {
                  o.s.name = o.s.content.getSortHeight();
               }
            }
         }
         var defsToRequest:Array = [];
         for(i = 0; i < this._jbItems.length; i++)
         {
            jbItem = this._jbItems[i];
            jbItem.isReady = false;
            refObjName = jbItem.refObjName;
            if(refObjName == "" || refObjName.indexOf("start") == 0)
            {
               defsToRequest.push(jbItem.refId);
            }
            else
            {
               jbItem.s.content.visible = false;
            }
         }
         for(var j:int = 0; j < defsToRequest.length; j++)
         {
            NGFactManager.requestJourneyBookFactDef(defsToRequest[j],this.onJourneyBookFactDefReceived);
         }
         if(defsToRequest.length > 0)
         {
            if(gMainFrame.server.getCurrentRoom().name.indexOf("party") >= 0)
            {
               userVar = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_PARTY_JB_ENTER));
               currIndex = AchievementXtCommManager.UV_PARTY_JB_ENTER_BIT_ARRAY.indexOf(gMainFrame.clientInfo.secondaryDefId);
               if(userVar == -1 || (userVar >> currIndex & 1) == 0)
               {
                  GuiManager.openJourneyBook(true);
                  AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_PARTY_JB_ENTER,currIndex);
               }
            }
         }
         var mp:Object = _scene.getLayer("movie_player_streaming");
         if(Boolean(mp) && Boolean(mp.loader) && Boolean(mp.loader.content))
         {
            this._theaterLayer = mp.loader.content;
         }
         else
         {
            this._theaterLayer = null;
         }
         if(Boolean(this._theaterLayer))
         {
            this._theaterLayer.subtitle.text = "";
            this._theaterLayer.grayBox.visible = false;
            volumes = _scene.getActorList("ActorVolume");
            for each(v in volumes)
            {
               if(v.name == "movieselector")
               {
                  helperObj = null;
                  if(v.message != "")
                  {
                     helperObj = new Object();
                     helperObj.msg = v.message;
                  }
                  GenericListXtCommManager.requestStreamList(v.typeDefId,GenericListGuiManager.launchMovies,helperObj);
                  break;
               }
            }
         }
         this._bounceVolumes = _volumeManager.findVolume("bouncevolume");
         this.disableAvatarBounce();
         if(this._shouldLoadMessagePopups)
         {
            GuiManager.initMessagePopups();
            this._shouldLoadMessagePopups = false;
         }
         if(this._callback_InitialDataRequest != null)
         {
            this._callback_InitialDataRequest();
            this._callback_InitialDataRequest = null;
         }
         QuestManager.sceneAssetsLoaded();
         GuiManager.reconnecting = false;
         RoomXtCommManager.loadingNewRoom = false;
         if(this._callback_FFMRoomAssetsLoaded != null)
         {
            this._callback_FFMRoomAssetsLoaded();
            this._callback_FFMRoomAssetsLoaded = null;
         }
         gMainFrame.stage.invalidate();
         if(!_scene._useDynamicLoading)
         {
            setTimeout(LoadProgress.show,1000 / 24,false);
         }
      }
      
      public function broadcastMute(muted:Boolean) : void
      {
         if(Boolean(_persistentObject))
         {
            _persistentObject.muteChanged(muted);
         }
         QuestManager.muteChanged(muted);
      }
      
      public function teleportPlayer(inX:int, inY:int, inResetCamera:Boolean) : void
      {
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,inX,inY,true,false,true);
         if(inResetCamera)
         {
            scrollRoom(AvatarManager.playerAvatarWorldView.localToGlobal(new Point(0,0)),24 * 100 / 0.07);
         }
         this.forceStopMovement();
      }
      
      public function teleportPlayerToDefault() : void
      {
         var spawn:Object = findSpawn(_spawns,_playerGotoSpawnPoint);
         if(!spawn)
         {
            spawn = findSpawn(_spawns,"default");
            if(!spawn)
            {
               spawn = {
                  "x":400,
                  "y":400,
                  "r":10,
                  "toSpawn":null
               };
            }
         }
         var pos:Point = getRandomRadiusOffset(spawn.r);
         spawn.x += pos.x;
         spawn.y += pos.y;
         pos = new Point(spawn.x,spawn.y);
         convertToWorldSpace(pos);
         _playerGotoSpawnPoint = "default";
         this.teleportPlayer(pos.x,pos.y,true);
      }
      
      public function setGotoUsername(value:String, alreadyInRoom:Boolean) : void
      {
         var gotoAvView:AvatarWorldView = null;
         var gavx:int = 0;
         var gavy:int = 0;
         var gotoAv:Avatar = null;
         DebugUtility.debugTrace("setGotoUsername - value:" + value + " alreadyInRoom:" + alreadyInRoom);
         if(!alreadyInRoom || (gotoAv = AvatarManager.getAvatarByUserName(value)) == null)
         {
            this._gotoUsername = value;
         }
         else
         {
            gotoAvView = AvatarManager.avatarViewList[gotoAv.sfsUserId];
            gavx = gotoAvView.x;
            gavy = gotoAvView.y;
            _scrollOffset.x = MainFrame.VIEW_WIDTH / 2 - (gavx + _mainBackObj.x);
            _scrollOffset.y = MainFrame.VIEW_HEIGHT / 2 - (gavy + _mainBackObj.y);
            AvatarManager.resetThrottle();
            AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,gavx,gavy,true,false);
         }
         DebugUtility.debugTrace("setGotoUsername - _gotoUsername:" + this._gotoUsername + " gotoAv:" + gotoAv);
      }
      
      public function modGotoUser(acUserName:String, acX:int, acY:int) : void
      {
         DebugUtility.debugTrace("modGotoUser - _gotoUsername:" + this._gotoUsername + " acUserName:" + acUserName);
         if(this._gotoUsername == null || acUserName != this._gotoUsername)
         {
            return;
         }
         this._gotoUsername = null;
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,acX,acY,true,false);
      }
      
      private function onMouseDownEvt_ActionPoint(evt:MouseEvent) : void
      {
         var s:Object = null;
         evt.stopPropagation();
         if(_bTestPortal && Boolean(_actionPoints))
         {
            for each(s in _actionPoints)
            {
               if(s.type == ACTION_POINT_TYPE_MINIGAME)
               {
                  if(s.clip == evt.currentTarget)
                  {
                     if(QuestManager.isInPrivateAdventureState)
                     {
                        QuestManager.showLeaveQuestLobbyPopup(this.onMouseDownEvt_ActionPoint,evt);
                        return;
                     }
                     if(!RoomXtCommManager.isSwitching)
                     {
                        GuiManager.toolTip.resetTimerAndSetVisibility();
                        _playerGotoSpawnPoint = s.spawn;
                        MinigameManager.handleGameClick(s,this.onFrgJoined);
                        AJAudio.playSubMenuBtnClick();
                     }
                     break;
                  }
               }
               else if(s.type == ACTION_POINT_TYPE_LAUNCH_QUEST)
               {
                  if(s.clip == evt.currentTarget)
                  {
                     this.checkAndStartAdventure(s.typeDefId);
                  }
               }
            }
         }
      }
      
      private function onMouseOverEvt_ActionPoint(evt:MouseEvent) : void
      {
         var s:Object = null;
         AJAudio.playSubMenuBtnRollover();
         for each(s in _actionPoints)
         {
            if(s.type == ACTION_POINT_TYPE_MINIGAME)
            {
               if(s.clip == evt.currentTarget)
               {
                  MovieClip(s.clip).transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
                  GuiManager.toolTip.init(_layerManager.room_orbs,MinigameManager.getGameName(s.typeDefId),s.clip.x + 50,s.clip.y + 80);
                  GuiManager.toolTip.startTimer(evt);
                  break;
               }
            }
            else if(s.type == ACTION_POINT_TYPE_LAUNCH_QUEST)
            {
               if(s.clip == evt.currentTarget)
               {
                  MovieClip(s.clip).transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
                  GuiManager.toolTip.init(_layerManager.room_orbs,LocalizationManager.translateIdOnly(14679),s.clip.x + 50,s.clip.y + 80);
                  GuiManager.toolTip.startTimer(evt);
                  break;
               }
            }
         }
      }
      
      private function onMouseOutEvt_ActionPoint(evt:MouseEvent) : void
      {
         var s:Object = null;
         for each(s in _actionPoints)
         {
            if(s.type == ACTION_POINT_TYPE_MINIGAME)
            {
               if(s.clip == evt.currentTarget)
               {
                  GuiManager.toolTip.resetTimerAndSetVisibility();
                  MovieClip(s.clip).transform.colorTransform = new ColorTransform(1,1,1);
                  break;
               }
            }
            else if(s.type == ACTION_POINT_TYPE_LAUNCH_QUEST)
            {
               if(s.clip == evt.currentTarget)
               {
                  GuiManager.toolTip.resetTimerAndSetVisibility();
                  MovieClip(s.clip).transform.colorTransform = new ColorTransform(1,1,1);
                  break;
               }
            }
         }
      }
      
      public function checkAndStartAdventure(typeDefId:int, autoStart:Boolean = false) : void
      {
         var scriptDef:Object = null;
         var ai:AvatarInfo = null;
         var myPet:Object = null;
         if(QuestManager.isInPrivateAdventureState)
         {
            QuestManager.showLeaveQuestLobbyPopup(this.checkAndStartAdventure,typeDefId,autoStart);
            return;
         }
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         if(!RoomXtCommManager.isSwitching)
         {
            scriptDef = QuestXtCommManager.getScriptDef(typeDefId);
            if(Boolean(scriptDef.membersOnly) && !gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(UpsellManager.ADVENTURES,"adventure/" + typeDefId,null,null,autoStart);
               return;
            }
            ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(!Boolean(ai))
            {
               return;
            }
            if(Boolean(scriptDef.playAsPet))
            {
               myPet = PetManager.myActivePet;
               if(!Boolean(myPet))
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                  return;
               }
               if(!PetManager.canPetGoInEnviroType(myPet.type,scriptDef.avatarType))
               {
                  switch(scriptDef.avatarType)
                  {
                     case 1:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19648));
                        break;
                     case 2:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19649));
                        break;
                     case 4:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19650));
                        break;
                     case 5:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19655));
                  }
                  return;
               }
            }
            else
            {
               if(Boolean(AvatarManager.playerAvatar) && !AvatarManager.isValidEnviro(scriptDef.avatarType))
               {
                  switch(scriptDef.avatarType)
                  {
                     case 1:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
                        break;
                     case 2:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
                        break;
                     case 4:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
                        break;
                     case 5:
                  }
                  return;
               }
               if(ai.questLevel < scriptDef.levelMin)
               {
                  if(!autoStart)
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,scriptDef.levelMin));
                  }
                  else
                  {
                     new SBOkPopup(gMainFrame.stage,LocalizationManager.translateIdAndInsertOnly(14697,scriptDef.levelMin),false);
                  }
                  return;
               }
               if(scriptDef.avatarLimit == 1)
               {
                  if(scriptDef.hudType == 1)
                  {
                     QuestXtCommManager.sendQuestCreateJoinPublic(typeDefId);
                     return;
                  }
                  if(!autoStart)
                  {
                     new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14825),true,this.onConfirmStartAdventure,typeDefId);
                     return;
                  }
               }
               else if(scriptDef.time == 1)
               {
                  QuestManager.openAdventureJoin(scriptDef.defId,AdventureJoin.NO_LOBBY,0);
                  return;
               }
            }
            AdventureExpertPopup.init(typeDefId,autoStart);
         }
      }
      
      private function onConfirmStartAdventure(o:Object) : void
      {
         if(Boolean(o.status))
         {
            QuestXtCommManager.sendQuestCreateJoinPublic(o.passback);
         }
      }
      
      public function getNearestQuestRespawnPointPlayerIsIn(location:Point) : Object
      {
         var distanceSq:Number = NaN;
         var nearestPoint:Object = null;
         var s:Object = null;
         var distance:Number = NaN;
         if(_actionPoints != null)
         {
            nearestPoint = null;
            for each(s in _actionPoints)
            {
               if(s.type == ACTION_POINT_TYPE_QUEST_RESPAWN)
               {
                  distance = (location.x - s.pos.x) * (location.x - s.pos.x) + (location.y - s.pos.y) * (location.y - s.pos.y);
                  if(distance < s.r2 * s.r2 && (nearestPoint == null || distance < distanceSq))
                  {
                     nearestPoint = s;
                     distanceSq = distance;
                  }
               }
            }
         }
         return nearestPoint;
      }
      
      public function setRoomMode(mode:int) : void
      {
         if(this._roomMode == ROOM_MODE_DEN)
         {
            if(mode == ROOM_MODE_AVATAR)
            {
               KeepAlive.stopKATimer(gMainFrame.stage);
               this._denItems.saveState();
            }
            this._bLastShowDenHud = true;
         }
         else if(this._roomMode == ROOM_MODE_AVATAR && mode == ROOM_MODE_DEN)
         {
            KeepAlive.startKATimer(gMainFrame.stage);
         }
         if(mode == ROOM_MODE_CAMERAFOCUS_TO_TARGET)
         {
            if(this._cameraFocusToTime <= 0)
            {
               mode = ROOM_MODE_CAMERAFOCUS_STAY;
               _scrollOffset = this._cameraFocusPoint;
               updateBackground();
            }
         }
         if(mode == ROOM_MODE_CAMERAFOCUS_STAY)
         {
            if(this._cameraFocusStayTime <= 0)
            {
               mode = ROOM_MODE_CAMERAFOCUS_RETURN;
            }
         }
         switch(mode)
         {
            case ROOM_MODE_CAMERAFOCUS_TO_TARGET:
               this._cameraFocusTimer = 0;
               this._cameraSpeedX = (this._cameraFocusPoint.x - _scrollOffset.x) / this._cameraFocusToTime;
               this._cameraSpeedY = (this._cameraFocusPoint.y - _scrollOffset.y) / this._cameraFocusToTime;
               break;
            case ROOM_MODE_CAMERAFOCUS_STAY:
               this._cameraFocusTimer = 0;
               this._cameraSpeedX = 0;
               this._cameraSpeedY = 0;
               break;
            case ROOM_MODE_CAMERAFOCUS_RETURN:
               this._cameraFocusTimer = 0;
               this._cameraSpeedX = (this._cameraReturnPoint.x - _scrollOffset.x) / this._cameraFocusReturnTime;
               this._cameraSpeedY = (this._cameraReturnPoint.y - _scrollOffset.y) / this._cameraFocusReturnTime;
         }
         this._roomMode = mode;
         this._denItems.setRoomMode(this._roomMode);
      }
      
      public function setCameraFocus(inFocusPos:Point, inToTime:Number, inStayTime:Number, inReturnTime:Number, inOffsetPointToScreen:Boolean) : void
      {
         this.forceStopMovement();
         this._cameraReturnPoint = new Point(_scrollOffset.x,_scrollOffset.y);
         if(inOffsetPointToScreen)
         {
            this._cameraFocusPoint = new Point(MainFrame.VIEW_WIDTH / 2 - (inFocusPos.x + _mainBackObj.x),MainFrame.VIEW_HEIGHT / 2 - (inFocusPos.y + _mainBackObj.y));
         }
         else
         {
            this._cameraFocusPoint = inFocusPos;
         }
         this._cameraFocusToTime = inToTime;
         this._cameraFocusStayTime = inStayTime;
         this._cameraFocusReturnTime = inReturnTime;
         this.setRoomMode(ROOM_MODE_CAMERAFOCUS_TO_TARGET);
      }
      
      public function spawnNewDenItem(o:Object) : void
      {
         var pt:Point = null;
         pt = convertScreenToWorldSpace(450,275);
         o.x = pt.x;
         o.y = pt.y;
         this._denItems.setItems([o],true);
      }
      
      public function forceStopMovement() : void
      {
         killPlayerPath();
         if(Boolean(AvatarManager.playerAvatarWorldView))
         {
            AvatarManager.movePlayer(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
         }
      }
      
      public function get denItemHolder() : DenItemHolder
      {
         return this._denItems;
      }
      
      public function get denCatId() : int
      {
         return this._denCatId;
      }
      
      public function get shardId() : int
      {
         return this._shardId;
      }
      
      public function get forceInvisMode() : Boolean
      {
         return this._forceInvisMode;
      }
      
      public function get theaterWindow() : Object
      {
         return this._theaterLayer;
      }
      
      public function get roomEnviroType() : int
      {
         return this._roomEnviroType;
      }
      
      public function set shardId(newShardId:int) : void
      {
         var shardName:String = null;
         var selShardName:String = null;
         this._shardId = newShardId;
         var gamePlay:GamePlay = GamePlay(gMainFrame.gamePlay);
         if(gamePlay != null)
         {
            shardName = "[Not Initialized]";
            selShardName = ServerSelector.getShardName(newShardId);
            if(Boolean(selShardName))
            {
               shardName = selShardName;
            }
            gamePlay.debugShardIdTxt = "id=" + newShardId + " name=" + shardName;
         }
      }
      
      public function set forceInvisMode(setForceInvisMode:Boolean) : void
      {
         this._forceInvisMode = setForceInvisMode;
      }
      
      public function set callback_TriggerWalkIn(f:Function) : void
      {
         this._callback_TriggerWalkIn = f;
      }
      
      public function set callback_FFMRoomAssetsLoaded(f:Function) : void
      {
         this._callback_FFMRoomAssetsLoaded = f;
      }
      
      public function set callback_InitialDataRequest(f:Function) : void
      {
         this._callback_InitialDataRequest = f;
      }
      
      public function set needsToSeeKickFromDenMessage(value:Boolean) : void
      {
         this._needsToSeeKickFromDenMessage = value;
      }
      
      public function setNeedsToSeeFacilitatorMessage(value:Boolean, messageId:int, duration:int = 0) : void
      {
         this._needsToSeeFacilitatorMessage = true;
         this._facilitatorMessage = {
            "messageId":messageId,
            "duration":duration
         };
      }
      
      private function onFrgJoined() : void
      {
      }
      
      public function heartbeat(ms:int, frameTimems:int) : void
      {
         var vol:Object = null;
         var bMovePlayer:Boolean = true;
         switch(this._roomMode)
         {
            case ROOM_MODE_AVATAR:
               this.heartbeat_avatar(ms);
               break;
            case ROOM_MODE_DEN:
               this.heartbeat_den(ms);
               break;
            case ROOM_MODE_CAMERAFOCUS_TO_TARGET:
               bMovePlayer = false;
               this._cameraFocusTimer += ms * 0.001;
               if(this._cameraFocusTimer >= this._cameraFocusToTime)
               {
                  this.setRoomMode(ROOM_MODE_CAMERAFOCUS_STAY);
               }
               else
               {
                  _scrollOffset.x += this._cameraSpeedX * ms * 0.001;
                  _scrollOffset.y += this._cameraSpeedY * ms * 0.001;
                  updateBackground();
               }
               break;
            case ROOM_MODE_CAMERAFOCUS_STAY:
               bMovePlayer = false;
               this._cameraFocusTimer += ms * 0.001;
               if(this._cameraFocusTimer >= this._cameraFocusStayTime)
               {
                  this.setRoomMode(ROOM_MODE_CAMERAFOCUS_RETURN);
               }
               break;
            case ROOM_MODE_CAMERAFOCUS_RETURN:
               bMovePlayer = false;
               this._cameraFocusTimer += ms * 0.001;
               if(this._cameraFocusTimer >= this._cameraFocusReturnTime)
               {
                  this.setRoomMode(ROOM_MODE_AVATAR);
               }
               else
               {
                  _scrollOffset.x += this._cameraSpeedX * ms * 0.001;
                  _scrollOffset.y += this._cameraSpeedY * ms * 0.001;
                  updateBackground();
               }
         }
         updateSocialVolumes();
         updateSplashVolumes();
         this.updateLayerActors();
         if(this._bounceVolumes != null)
         {
            this.updateAvatarBounce();
         }
         if(bMovePlayer && Boolean(AvatarManager.playerAvatar))
         {
            vol = _volumeManager.testAvatarVolumes(new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y));
            if(Boolean(vol))
            {
               if(vol.type == 6)
               {
                  AvatarManager.setPlayerAttachmentEmot(vol.typeDefId,null,2);
               }
               else if(vol.type == 11)
               {
                  if(this._callback_TriggerWalkIn != null)
                  {
                     this._callback_TriggerWalkIn(vol.message);
                  }
               }
            }
            heartbeat_movePlayer(ms,frameTimems);
         }
         _layerManager.room_avatars.heartbeat();
         _layerManager.flying_avatars.heartbeat();
         if(_bMouseDownNew)
         {
            _bMouseDownNew = false;
         }
         var _frameTime:Number = frameTimems / 1000;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         var speedMultiplier:int = 1;
         speedMultiplier = RoomManagerView._speedMutiplier;
         if(Boolean(this._roomMode == ROOM_MODE_AVATAR) && Boolean(AvatarManager.playerAvatarWorldView) && Boolean(_mainBackObj))
         {
            scrollRoom(AvatarManager.playerAvatarWorldView.localToGlobal(new Point(0,0)),24 * speedMultiplier * _frameTime / 0.07);
         }
      }
      
      private function updateAvatarBounce() : void
      {
         var key:Object = null;
         var a:* = undefined;
         var avList:Object = AvatarManager.avatarViewList;
         for(key in avList)
         {
            a = avList[key];
            if(_volumeManager.testPointInVolume(new Point(a.x,a.y),this._bounceVolumes[0]))
            {
               a.setBounce(true);
            }
            else
            {
               a.setBounce(false);
            }
         }
      }
      
      private function disableAvatarBounce() : void
      {
         var key:Object = null;
         var avList:Object = AvatarManager.avatarViewList;
         for(key in avList)
         {
            avList[key].setBounce(false);
         }
      }
      
      private function heartbeat_den(ms:int) : void
      {
         var pt:Point = null;
         var x:Number = NaN;
         var y:Number = NaN;
         var scrollX:int = 0;
         var scrollY:int = 0;
         var scrollXAccel:Number = NaN;
         var scrollYAccel:Number = NaN;
         var xEdge:int = 0;
         var yEdge:int = 0;
         if(_bMouseMove || this._dragAccelX > 0 || this._dragAccelY > 0)
         {
            if(!this._bInDenShop)
            {
               x = _mousePos.x;
               y = _mousePos.y;
               if(_mousePos.x < 0)
               {
                  x = 0;
               }
               else if(_mousePos.x > MainFrame.VIEW_WIDTH)
               {
                  x = MainFrame.VIEW_WIDTH;
               }
               if(_mousePos.y < 0)
               {
                  y = 0;
               }
               else if(_mousePos.y > MainFrame.VIEW_HEIGHT)
               {
                  y = MainFrame.VIEW_HEIGHT;
               }
               if(_bMouseDown)
               {
                  if(this._denItems.isDragging)
                  {
                     xEdge = 100;
                     yEdge = 75;
                     if(_mousePos.x < xEdge)
                     {
                        scrollX = 1;
                        scrollXAccel = (_mousePos.x - xEdge) / -xEdge;
                     }
                     else if(_mousePos.x > MainFrame.VIEW_WIDTH - xEdge)
                     {
                        scrollX = -1;
                        scrollXAccel = (MainFrame.VIEW_WIDTH - xEdge - _mousePos.x) / -xEdge;
                     }
                     if(_mousePos.y < yEdge)
                     {
                        scrollY = 1;
                        scrollYAccel = (_mousePos.y - yEdge) / -yEdge;
                     }
                     else if(_mousePos.y > MainFrame.VIEW_HEIGHT - 120 - yEdge)
                     {
                        scrollY = -1;
                        scrollYAccel = (MainFrame.VIEW_HEIGHT - 120 - yEdge - _mousePos.y) / -yEdge;
                     }
                     if(scrollX != 0 || scrollY != 0)
                     {
                        scrollXAccel *= 12;
                        if(scrollXAccel > 12)
                        {
                           scrollXAccel = 12;
                        }
                        scrollYAccel *= 12;
                        if(scrollYAccel > 12)
                        {
                           scrollYAccel = 12;
                        }
                        this._dragAccelX += 0.75;
                        if(this._dragAccelX > scrollXAccel)
                        {
                           this._dragAccelX = scrollXAccel;
                        }
                        this._dragAccelY += 0.75;
                        if(this._dragAccelY > scrollYAccel)
                        {
                           this._dragAccelY = scrollYAccel;
                        }
                        _scrollOffset.x += scrollX * this._dragAccelX;
                        _scrollOffset.y += scrollY * this._dragAccelY;
                        updateBackground();
                     }
                     else
                     {
                        this._dragAccelX = 0;
                        this._dragAccelY = 0;
                     }
                  }
                  else
                  {
                     if(this._dragX != -999)
                     {
                        scrollX = this._dragX - _mousePos.x;
                        scrollY = this._dragY - _mousePos.y;
                        if(scrollX != 0 || scrollY != 0)
                        {
                           _scrollOffset.x -= scrollX;
                           _scrollOffset.y -= scrollY;
                           updateBackground();
                        }
                     }
                     this._dragX = _mousePos.x;
                     this._dragY = _mousePos.y;
                  }
               }
               else
               {
                  this._dragAccelX = 0;
                  this._dragAccelY = 0;
                  this._dragX = -999;
               }
               pt = convertScreenToWorldSpace(x,y);
               this._denItems.handleMouse(pt.x,pt.y,_bMouseDown);
            }
            _bMouseMove = false;
         }
         this.showDenHud(!(this._denItems.isDragging && _bMouseDown));
      }
      
      public function heartbeat_avatar(ms:int) : void
      {
         var hitItem:Object = null;
         var jbo:Object = null;
         var i:int = 0;
         var refObjName:String = null;
         var next:Object = null;
         if(_bMouseMove)
         {
            this.clickVolumeTest(_mousePos);
         }
         if(_bMouseDownNew && this._bMouseDownIgnore)
         {
            this._bMouseDownIgnore = false;
         }
         if(_bMouseDownNew)
         {
            if(Boolean(this._jbItems) && this._jbItems.length > 0)
            {
               hitItem = getObjUnderPoint(_mousePos,_layerManager.room_super_fg);
               if(!hitItem)
               {
                  hitItem = getObjUnderPoint(_mousePos,_layerManager.room_fg);
                  if(!hitItem)
                  {
                     hitItem = getObjUnderPoint(_mousePos,_layerManager.room_bkg_group);
                     if(!hitItem)
                     {
                        hitItem = getObjUnderPoint(_mousePos,_layerManager.room_bkg);
                     }
                  }
               }
               if(Boolean(hitItem))
               {
                  for(i = 0; i < this._jbItems.length; i++)
                  {
                     jbo = this._jbItems[i];
                     if(jbo.s.content == hitItem)
                     {
                        if(Boolean(jbo.isReady))
                        {
                           this._jbItems.splice(i,1);
                           if(jbo.refObjName == "" || jbo.refObjName == "end")
                           {
                              NGFactManager.showJourneyBookFact(jbo.refId);
                           }
                           else
                           {
                              refObjName = jbo.refObjName;
                              if(refObjName.indexOf("start") == 0)
                              {
                                 refObjName = refObjName.substr(6);
                              }
                              if(Boolean(jbo.s.content.hasOwnProperty("playAnim")))
                              {
                                 jbo.s.content.playAnim();
                              }
                              next = this.getJourneyBookItem(refObjName);
                              next.s.content.visible = true;
                              next.s.content.playAnim();
                           }
                        }
                        break;
                     }
                  }
               }
            }
            if(this._denOwnerName != "")
            {
               if(this._denItems.shouldStopMovement(_mousePos))
               {
                  this._bMouseDownIgnore = true;
               }
            }
         }
         if(!this._bMouseDownIgnore)
         {
            followCursorTest();
         }
         this.portalCollisionTest();
      }
      
      private function updateLayerActors() : void
      {
         var times:Array = null;
         var timesLength:int = 0;
         var j:int = 0;
         var idx:String = null;
         if(this._jamaaMS <= -1)
         {
            return;
         }
         var currGetTimer:int = getTimer();
         if(!_layers)
         {
            this._jamaaMS += currGetTimer - this._prevGetTimer;
            this._prevGetTimer = currGetTimer;
            return;
         }
         var currMS:Number = this._jamaaMS + (currGetTimer - this._prevGetTimer);
         for(idx in this._inAndOutItems)
         {
            times = this._inAndOutItems[idx];
            timesLength = int(times.length);
            for(j = 0; j < timesLength; j++)
            {
               if(this._jamaaMS * 0.001 % 3600 < times[j] && currMS * 0.001 % 3600 >= times[j])
               {
                  if(Boolean(_layers[idx]) && Boolean(_layers[idx].s) && Boolean(_layers[idx].s.content))
                  {
                     _layers[idx].s.content.playAnim();
                  }
               }
            }
         }
         this._prevGetTimer = currGetTimer;
         this._jamaaMS = currMS;
      }
      
      public function set jamaaMilliseconds(value:Number) : void
      {
         this._jamaaMS = value;
         this._prevGetTimer = getTimer();
      }
      
      private function showDenHud(bShow:Boolean) : void
      {
         if(this._bLastShowDenHud != bShow)
         {
            this._bLastShowDenHud = bShow;
            GuiManager.showDenHudItems(bShow);
         }
      }
      
      public function getNumJBItemsLeftInWorld() : int
      {
         return this._jbItems.length;
      }
      
      private function getJourneyBookItem(name:String) : Object
      {
         name = name.toLowerCase();
         for(var i:int = 0; i < this._jbItems.length; i++)
         {
            if(this._jbItems[i].name == name)
            {
               return this._jbItems[i];
            }
         }
         return null;
      }
      
      private function clickVolumeTest(pt:Point) : void
      {
         var vo:Object = null;
         var params:Array = null;
         var def:Object = null;
         var o:Object = null;
         var msgSplit:Array = null;
         if(!_volumes)
         {
            return;
         }
         pt = convertScreenToWorldSpace(pt.x,pt.y);
         vo = _volumeManager.testMouseVolumes(pt,_bMouseDown);
         if(Boolean(vo) && _bMouseDownNew)
         {
            switch(vo.type)
            {
               case 1:
                  MinigameManager.handleGameClick(vo,this.onFrgJoined,true);
                  break;
               case 3:
                  if(_ffmCloseCallback != null)
                  {
                     _ffmCloseCallback();
                     _hasOpenedClothesShop = true;
                  }
                  break;
               case 4:
                  if(_ffmCloseCallback != null)
                  {
                     _ffmCloseCallback();
                     _hasOpenedDenShop = true;
                  }
                  break;
               case 7:
                  params = vo.message.split("%");
                  switch(params[0])
                  {
                     case "museum":
                        NGFactManager.requestMuseumFactInfo(params);
                        break;
                     case "donation":
                        GuiManager.openMuseumDonation();
                        break;
                     case "jammercentral":
                        GuiManager.openJammerCentral();
                        break;
                     case "ebook":
                        GuiManager.openEBook(int(params[1]),params[2] == "true",params[3] == "true");
                        break;
                     case "pet":
                        PetManager.openPetFinder(params[1]);
                        break;
                     case "fact":
                        NGFactManager.showTierneyFact(params[1]);
                        break;
                     case "factbrady":
                        NGFactManager.showBradyFact(params[1]);
                        break;
                     case "carni":
                        DarkenManager.showLoadingSpiral(true);
                        PartyXtCommManager.sendJoinPartyRequest(18);
                        break;
                     case "photobooth":
                        GuiManager.openPhotoBooth();
                        break;
                     case "ajeventfact":
                        NGFactManager.requestFactInfo([params[1]]);
                        break;
                     case "diamondinfo":
                        GuiManager.openDiamondShopInfo();
                        break;
                     case "adventure":
                        this.checkAndStartAdventure(params[1]);
                        break;
                     case "displayimages":
                        GuiManager.openDisplayImagesPopup();
                  }
                  break;
               case 8:
                  if(_ffmCloseCallback != null && _hasOpenedClothesShop)
                  {
                     _ffmCloseCallback();
                  }
                  this.launchRecycle(RecycleItems.RECYCLE_ACCESSORIES);
                  break;
               case 9:
                  if(_ffmCloseCallback != null && _hasOpenedDenShop)
                  {
                     _ffmCloseCallback();
                  }
                  this.launchRecycle(RecycleItems.RECYCLE_DEN_ITEMS);
                  break;
               case 12:
                  def = gMainFrame.userInfo.getGenericListDefByDefId(vo.typeDefId);
                  if(Boolean(def))
                  {
                     o = new Object();
                     o.volName = vo.name;
                     if(def.typeId == DefPacksDefHelper.DEF_STREAM)
                     {
                        if(vo.message != "")
                        {
                           o = new Object();
                           msgSplit = vo.message.split("|");
                           if(msgSplit.length > 1)
                           {
                              o.msg = msgSplit[0];
                              o.width = msgSplit[1];
                              o.height = msgSplit[2];
                              o.shouldRepeat = msgSplit[3] != null && msgSplit[3] == "true" ? true : false;
                           }
                           else
                           {
                              o.msg = vo.message;
                           }
                        }
                        this._theaterLayer = _scene.getLayer("movie_player_streaming");
                     }
                     GenericListGuiManager.genericListVolumeClicked(vo.typeDefId,o);
                  }
                  break;
               case 13:
                  AvatarManager.setPlayerAttachmentEmot(vo.typeDefId,vo.message,60 * 24);
            }
            _volumeManager.clearHold(true);
            if(_bMouseDown && vo.bWalkTo == false)
            {
               _bMouseDown = false;
            }
         }
      }
      
      private function launchRecycle(recycleType:int) : void
      {
         if(Boolean(this._recycle))
         {
            this._recycle.destroy();
         }
         this._recycle = new RecycleItems();
         this._recycle.init(recycleType,GuiManager.guiLayer,false,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      public function onRecycleClose(itemRecycled:Boolean = false) : void
      {
         if(Boolean(this._recycle))
         {
            this._recycle.destroy();
            this._recycle = null;
         }
      }
      
      public function chosenLoginFinished() : void
      {
         if(_mainBackObj == null)
         {
            if(!gMainFrame.userInfo.avtDefsCached)
            {
               if(ItemXtCommManager.itemDefsHaveLoaded)
               {
                  if(PetXtCommManager.canLoadPetList)
                  {
                     PetXtCommManager.sendPetListRequest(gMainFrame.server.userName);
                  }
                  else
                  {
                     PetXtCommManager.canLoadPetList = true;
                  }
                  AvatarXtCommManager.requestAvatarList([1,gMainFrame.userInfo.myUserName],AvatarSwitch.myAvatarListCallback);
                  AvatarXtCommManager.requestAvatarInfo(this.setUpWorldJoin);
                  DenXtCommManager.requestDenRoomList();
                  PartyManager.initialDataRequest();
                  JBManager.init();
                  MinigameXtCommManager.sendMinigameInfoRequest([MinigameManager.PET_SALON_DEF_ID]);
                  if(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_PREDICTIVE || LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG || !PredictiveTextManager.hasRequestWordsList && LocalizationManager.accountLanguage != LocalizationManager.LANG_ENG)
                  {
                     PredictiveTextManager.requestAndCreateTextTreeNode();
                  }
                  GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVAIL_LIST_ID);
                  GenericListXtCommManager.requestGenericList(GenericListXtCommManager.MEDIA_JAG_CARD_LIST_ID,ECardManager.onCardsLoaded);
                  GenericListXtCommManager.requestGenericList(GenericListXtCommManager.MEDIA_JAG_STAMP_LIST_ID,ECardManager.onStampsLoaded);
                  SafeChatManager.requestSafeChatLists();
                  FlashCapabilities.SendCapabilities();
               }
               else
               {
                  ItemXtCommManager.functionToCallWhenDefsLoaded = this.chosenLoginFinished;
               }
            }
            else if(ItemXtCommManager.itemDefsHaveLoaded)
            {
               this.setUpWorldJoin();
            }
            else
            {
               ItemXtCommManager.functionToCallWhenDefsLoaded = this.chosenLoginFinished;
            }
         }
      }
      
      public function reconnectNodeSwitchLoginFinished() : void
      {
         if(_mainBackObj != null)
         {
            throw new Error("reconnecting/switching servers while still in a room?!");
         }
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            throw new Error("missing avatarOffsets and defs while reconnecting/switching servers!");
         }
         if(gMainFrame.userInfo.playerUserInfo == null)
         {
            AvatarXtCommManager.requestAvatarList([1,gMainFrame.userInfo.myUserName],AvatarSwitch.myAvatarListCallback);
         }
         this.setUpWorldJoin();
      }
      
      private function setUpWorldJoin() : void
      {
         AvatarUtility.init(AvatarManager.getAvatarByUsernamePerUserAvId,AvatarSwitch.getNumNonMemberAvailableAvatars);
         if(gMainFrame.userInfo.firstFiveMinutes <= 0)
         {
            GuiManager.startFFM();
         }
         else
         {
            this._gotNewShardId = true;
            this.joinNewShardRoom();
         }
      }
      
      public function minigameJoinRoom(roomName:String) : void
      {
         this._bAttemptingToJoinMinigameRoom = true;
         RoomXtCommManager.sendRoomJoinRequest(roomName,-1,true);
      }
      
      public function haveHadLastGoodRoomName() : Boolean
      {
         return this._lastGoodRoomName != null;
      }
      
      public function clearLastGoodRoomForServerSwitch() : void
      {
         this._lastGoodRoomName = null;
      }
      
      public function joinNewShardRoom(ignoreLastGoodRoomName:Boolean = false) : void
      {
         var startupRoom:String = null;
         var newShardRoomName:String = null;
         if(!this._gotNewShardId)
         {
            trace("ERROR: joinNewShardRoom was called before we gotNewShardId!");
            return;
         }
         DebugUtility.debugTrace("joinNewShardRoom called");
         this._gotNewShardId = false;
         var newJoinRoomNameOrId:String = null;
         if(Boolean(gMainFrame.clientInfo.hasOwnProperty("startUpRoom")) && gMainFrame.clientInfo.startUpRoom != null)
         {
            startupRoom = String(gMainFrame.clientInfo.startUpRoom);
            if(startupRoom.indexOf(QuestManager.SCRIPT_EDITOR_IXM_KEYWORD) == 0)
            {
               gMainFrame.clientInfo.autoStartRoom = QuestManager.SCRIPT_EDITOR_IXM_KEYWORD;
               gMainFrame.clientInfo.autoStartRoomShardId = int(startupRoom.substr(QuestManager.SCRIPT_EDITOR_IXM_KEYWORD.length));
            }
         }
         if(!ignoreLastGoodRoomName && this._lastGoodRoomName != null)
         {
            newShardRoomName = this._lastGoodRoomName.replace(/#[0-9]+/,"#" + this._shardId);
            if(this._lastGoodRoomName == newShardRoomName)
            {
               newJoinRoomNameOrId = gMainFrame.clientInfo.startUpRoom + "#" + this._shardId;
            }
            else
            {
               newJoinRoomNameOrId = newShardRoomName;
            }
         }
         else if(Boolean(gMainFrame.clientInfo.hasOwnProperty("autoStartRoom")) && gMainFrame.clientInfo.autoStartRoom != null && gMainFrame.clientInfo.autoStartRoom != "")
         {
            newJoinRoomNameOrId = gMainFrame.clientInfo.autoStartRoom;
            if(newJoinRoomNameOrId == QuestManager.SCRIPT_EDITOR_IXM_KEYWORD)
            {
               gMainFrame.server.joinDefaultRoom();
               gMainFrame.stage.focus = null;
               AvatarManager.loadSelfAssets(this.questRoomJoinCompleteAutoJoin);
               return;
            }
            DebugUtility.debugTrace("got autoStartRoom:" + newJoinRoomNameOrId + " - sending roomjoin request...");
            if(gMainFrame.clientInfo.autoStartRoomShardId == RoomXtCommManager.RT_PARAM_GET_SHARD_FROM_DEN)
            {
               DenXtCommManager.requestDenJoinFull(newJoinRoomNameOrId);
               return;
            }
         }
         else
         {
            newJoinRoomNameOrId = gMainFrame.clientInfo.startUpRoom + "#" + this._shardId;
         }
         DebugUtility.debugTrace("newJoinRoomNameOrId before sendNonDenRoomJoinRequest:" + newJoinRoomNameOrId);
         RoomXtCommManager.sendNonDenRoomJoinRequest(newJoinRoomNameOrId);
      }
      
      private function questRoomJoinCompleteAutoJoin(layerAnim:*) : void
      {
         GuiManager.reconnecting = false;
         RoomXtCommManager.loadingNewRoom = false;
         DarkenManager.showLoadingSpiral(false);
         LoadProgress.show(false);
         gMainFrame.stage.invalidate();
         this.checkAndStartAdventure(gMainFrame.clientInfo.autoStartRoomShardId,true);
      }
      
      private function onJoinRoom(evt:SFEvent) : void
      {
         var roomName:String = null;
         var firstThreeChars:String = null;
         var indexOfFirstFive:int = 0;
         var roomNameShardCharIdx:int = 0;
         var joinedShard:int = 0;
         var content:MovieClip = null;
         if(evt.status)
         {
            if(ServerSelector.isOpen())
            {
               ServerSelector.destroy();
            }
            GuiManager.closeAvtSwitcherFromRoomJoin();
            if(this._bAttemptingToJoinMinigameRoom)
            {
               this._bAttemptingToJoinMinigameRoom = false;
            }
            roomName = evt.obj.room.name;
            if(roomName.slice(0,7) != "quest_0")
            {
               firstThreeChars = roomName.slice(0,3);
               indexOfFirstFive = roomName.indexOf("first_five");
               if((this._lastGoodRoomName == null || this._lastGoodRoomName.slice(0,3) == "ffm") && firstThreeChars != "ffm" && indexOfFirstFive == -1)
               {
                  this._shouldLoadMessagePopups = true;
                  DarkenManager.showLoadingSpiral(true);
               }
               if(!evt.obj.subRoom)
               {
                  GuiManager.chatHist.clearChat();
                  AvatarManager.removeAllAvatars();
                  this._lastGoodRoomName = roomName;
                  if(firstThreeChars == "den")
                  {
                     this._denOwnerName = roomName.slice(3);
                  }
                  else
                  {
                     this._denOwnerName = "";
                     roomNameShardCharIdx = roomName.indexOf("#");
                     if(roomNameShardCharIdx != -1)
                     {
                        joinedShard = int(roomName.substring(roomNameShardCharIdx + 1));
                        if(joinedShard != this._shardId)
                        {
                           DebugUtility.debugTrace("joinedShard:" + joinedShard + " is different than current _shardId:" + this._shardId + "... updating _shardId to match.");
                           this.shardId = joinedShard;
                        }
                     }
                  }
                  if(AvatarManager.playerSfsUserId == -1)
                  {
                     GuiManager.chatHist.showChatInput(true);
                  }
                  if(roomName.indexOf("oceans") == 0)
                  {
                     gMainFrame.userInfo.worldMapRoomName = roomName.slice(7,roomName.indexOf("#"));
                  }
                  else
                  {
                     gMainFrame.userInfo.worldMapRoomName = roomName.slice(0,roomName.indexOf("."));
                  }
               }
            }
         }
         else
         {
            if(Boolean(evt.obj.roomFull))
            {
               DebugUtility.debugTrace("Room was full- show room popup? _bAttemptingToJoinMinigameRoom:" + this._bAttemptingToJoinMinigameRoom + " RoomXtCommManager.isSwitching:" + RoomXtCommManager.isSwitching + " _lastGoodRoomName:" + this._lastGoodRoomName + " gMainFrame.server.getCurrentRoomName():" + gMainFrame.server.getCurrentRoomName());
               if(!RoomXtCommManager.isSwitching && !this._bAttemptingToJoinMinigameRoom && this._lastGoodRoomName != null && this._lastGoodRoomName == gMainFrame.server.getCurrentRoomName())
               {
                  DebugUtility.debugTrace("Room is full!");
                  DarkenManager.showLoadingSpiral(false);
                  SBTracker.push();
                  roomName = RoomXtCommManager._joinRoomName;
                  roomName = roomName.slice(0,roomName.indexOf("#"));
                  if(isNaN(Number(roomName)))
                  {
                     SBTracker.trackPageview("/game/play/popup/joinFullRoom/#" + roomName,-1,SBTracker.TYPE_EVENT);
                  }
                  else
                  {
                     SBTracker.trackPageview("/game/play/popup/joinFullRoom",-1,SBTracker.TYPE_EVENT);
                  }
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14826),true,this.roomFullOkBtnHandler);
                  if(ServerSelector.isOpen())
                  {
                     ServerSelector.updatePopulationForRoomFullError();
                  }
               }
               else if(RoomXtCommManager.isSwitching)
               {
                  DebugUtility.debugTrace("All rooms for that animal type are full! Try again or reload and choose a different world.");
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14827),true,this.roomFullOkBtnHandler);
                  RoomXtCommManager.isSwitching = false;
               }
               else if(ServerSelector.isOpen())
               {
                  LoadProgress.show(false);
                  DarkenManager.showLoadingSpiral(false);
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14693),true);
                  ServerSelector.updatePopulationForRoomFullError();
               }
               else
               {
                  new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14828),false);
               }
            }
            else if(evt.message == "OA")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14829),true,GuiManager.switchToOceanAnimal,true);
            }
            else if(evt.message == "DP")
            {
               DarkenManager.showLoadingSpiral(false);
               content = GETDEFINITIONBYNAME("DenLockedPopupContent");
               if(evt.obj.denOwner != "" && BuddyManager.isBuddy(evt.obj.denOwner.toLowerCase()))
               {
                  LocalizationManager.translateId(content.bodyTxt1,19101);
               }
               new SBPopup(GuiManager.guiLayer,GETDEFINITIONBYNAME("DenLockedPopupSkin"),content,true,true,false,false,true);
               BuddyCard.grayOutGoToDenBtn(true,evt.obj.denOwner);
            }
            else if(evt.message == "DUA")
            {
               DarkenManager.showLoadingSpiral(false);
               if("den" + BuddyCard.currBuddyCardUserName == RoomXtCommManager._joinRoomName)
               {
                  BuddyCard.resetBuddyCardForArchiveMode();
               }
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14830),true);
            }
            else if(evt.message == "RQJF")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Tried to join a quest that does not belong to us!");
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14831),true);
            }
            else if(evt.message == "RDNE")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Tried to join a room that no longer exists!");
            }
            else if(evt.message == "JWD")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Joined a room that was being destroyed!");
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14832),true,this.roomFullOkBtnHandler);
               RoomXtCommManager.sendRoomJoinRequest(this._lastGoodRoomName);
            }
            else if(evt.message == "DG")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14833),true,this.roomFullOkBtnHandler);
               BuddyCard.grayOutGoToDenBtn(true);
            }
            else if(evt.message == "HAS")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18535),true);
            }
            else
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("got unknown join room error!");
            }
            RoomXtCommManager.loadingNewRoom = false;
            AvatarManager.joiningNewRoom = false;
         }
      }
      
      private function roomFullOkBtnHandler(evt:MouseEvent) : void
      {
         walkToSpawn(this._fullRoomSpawn);
         if(evt.currentTarget.parent.text.text == LocalizationManager.translateIdOnly(14826))
         {
            SBTracker.flush(true);
         }
         evt.stopPropagation();
         SBOkPopup.destroyInParentChain(evt.target.parent);
         GuiManager.openWorldMap();
      }
      
      private function portalCollisionTest() : void
      {
         var bInLastPortal:Boolean = false;
         var entry:Object = null;
         var pos:Point = null;
         var type:int = 0;
         var roomName:String = null;
         if(_bMouseDownNew)
         {
            this._bMouseDownForDenPortal = true;
         }
         if(!_bTestPortal || !AvatarManager.playerAvatarWorldView || !AvatarManager.playerAvatarWorldView.moving)
         {
            return;
         }
         if(Boolean(_portals))
         {
            pos = new Point();
            for each(entry in _portals)
            {
               if(!AvatarManager.playerAvatarWorldView)
               {
                  continue;
               }
               pos.x = entry.x;
               pos.y = entry.y;
               convertToWorldSpace(pos);
               if(!AvatarManager.playerAvatarWorldView.circleTest(pos.x,pos.y,entry.r))
               {
                  continue;
               }
               if(this._lastPortal == entry)
               {
                  bInLastPortal = true;
                  continue;
               }
               _bTestPortal = false;
               type = 0;
               if(Boolean(entry.type))
               {
                  type = int(entry.type);
               }
               switch(type)
               {
                  case 0:
                     roomName = String(entry["goto"]).toLowerCase() + "#" + this._shardId;
                     DarkenManager.showLoadingSpiral(true);
                     RoomXtCommManager.sendNonDenRoomJoinRequest(roomName);
                     _playerGotoSpawnPoint = entry.spawn;
                     this._fullRoomSpawn = entry.fullSpawn;
                     this._lastPortal = entry;
                     bInLastPortal = true;
                     break;
                  case 1:
                     if(!(AvatarManager.playerAvatarWorldView.avatarData.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
                     {
                        if(RoomManagerWorld.instance.collisionTestGrid(pos.x,pos.y) == 0)
                        {
                           UserCommXtCommManager.sendAvatarSlide(entry["goto"]);
                           attachAvatarToSlide(AvatarManager.playerAvatarWorldView,entry["goto"],entry.spawn);
                        }
                        else
                        {
                           this._lastPortal = entry;
                           bInLastPortal = true;
                        }
                     }
               }
            }
         }
         if(!bInLastPortal)
         {
            this._lastPortal = null;
            this._denItems.portalItemTest(this._bMouseDownForDenPortal,_mousePos);
            this._bMouseDownForDenPortal = false;
         }
      }
   }
}

class SingletonLock
{
   
   public function SingletonLock()
   {
      super();
   }
}
