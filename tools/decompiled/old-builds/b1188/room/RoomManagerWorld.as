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
   import com.sbi.corelib.audio.SBAudio;
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
   import gui.PetAdoptionBanner;
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
      
      public function RoomManagerWorld(param1:Class)
      {
         super();
         if(param1 != SingletonLock)
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
      
      public static function getObjUnderPoint(param1:Point, param2:DisplayObjectContainer) : Object
      {
         var _loc5_:* = 0;
         var _loc3_:Array = param2.getObjectsUnderPoint(param1);
         var _loc4_:int = int(_loc3_.length);
         if(_loc4_ > 0)
         {
            _loc5_ = int(_loc4_ - 1);
            while(_loc5_ >= 0)
            {
               if(fullHitTest(_loc3_[_loc5_].root,param1))
               {
                  return _loc3_[_loc5_].root;
               }
               _loc5_--;
            }
         }
         return null;
      }
      
      public static function fullHitTest(param1:DisplayObject, param2:Point) : Boolean
      {
         var bmapData:BitmapData = null;
         var returnVal:Boolean = false;
         var img:DisplayObject = param1;
         var pos:Point = param2;
         if(Boolean(img) && Boolean(img is MovieClip) && img.hasOwnProperty("isJBItem"))
         {
            return img.hitTestPoint(pos.x,pos.y,true);
         }
         if(img)
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
            }
            return false;
         }
         return false;
      }
      
      override public function init(param1:LayerManager) : void
      {
         super.init(param1);
         this._bAttemptingToJoinMinigameRoom = false;
         this._lastGoodRoomName = null;
         this._shardId = 0;
         this._gotNewShardId = false;
         this._forceInvisMode = false;
         this._denItems = new DenItemHolder(param1);
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
      
      override public function exitRoom(param1:Boolean = false) : void
      {
         GuiManager.onExitRoom();
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST)
         {
            QuestManager.onExitRoom();
         }
         DarkenManager.clearDarkenList();
         super.exitRoom(param1);
         this._lastPortal = null;
         if(!param1)
         {
            this._denItems.release();
         }
         SBPopupManager.closeAll();
         SBPopupManager.destroyNonSBPopups();
         GenericListGuiManager.onRoomExit();
         AvatarManager.clearSpecialPatternLayer();
         if(Boolean(_scene) && Boolean(_spawns))
         {
            if(this._theaterLayer)
            {
               this._theaterLayer = null;
            }
         }
         this._bIsMyDen = false;
         this.setRoomMode(ROOM_MODE_AVATAR);
         gMainFrame.stage.invalidate();
      }
      
      public function loadRoom(param1:String, param2:int, param3:int, param4:int, param5:int) : void
      {
         if(param1 != "qcqNoLoad")
         {
            if(param1 == "jamaa_township.first_five")
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
               _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = param5 / 100;
               this._roomEnviroType = param2;
               AvatarManager.roomEnviroType = this._roomEnviroType;
               loadRoom_base(param1,this.loadAvatarAssets);
               gMainFrame.clientInfo.roomType = param3;
               gMainFrame.clientInfo.secondaryDefId = param4;
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
               _pathName = param1;
            }
         }
      }
      
      public function reloadCurrentNormalRoom() : void
      {
         var _loc1_:AvatarWorldView = null;
         if(this.allPreviouslyNeededRoomItems)
         {
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = this.allPreviouslyNeededRoomItems.scale;
            this._roomEnviroType = this.allPreviouslyNeededRoomItems.enviroType;
            resetCurrentRoom_base(this.allPreviouslyNeededRoomItems.pathName);
            onRoomLoaded_base(this.sceneAssetsLoaded,this.allPreviouslyNeededRoomItems.scene);
            this.denItemHolder.reloadItems();
            convertPathToWorldSpace();
            this.initActionPoints();
            if(AvatarManager.playerAvatarWorldView)
            {
               _loc1_ = AvatarManager.playerAvatarWorldView;
               _loc1_.roomType = this.allPreviouslyNeededRoomItems.roomEnviroType;
               AvatarManager.updatePlayerAvatarViewParent(true);
               AvatarManager.resetThrottle();
               _loc1_.setSplashVolume(this.allPreviouslyNeededRoomItems.isInSplash,this.allPreviouslyNeededRoomItems.splashLiquid);
               _loc1_.playIdle();
               AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,this.allPreviouslyNeededRoomItems.pos.x,this.allPreviouslyNeededRoomItems.pos.y,false,false,true);
               this.setRoomMode(this.allPreviouslyNeededRoomItems.prevRoomMode);
            }
            _scrollOffset = this.allPreviouslyNeededRoomItems.scrollOffset;
            DenPreviewManager.handleAllRequiredVisibilities(true);
         }
      }
      
      public function loadDenPreviewRoom(param1:String, param2:int) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         var _loc6_:AvatarWorldView = null;
         var _loc3_:Point = null;
         if(AvatarManager.playerAvatarWorldView)
         {
            _loc6_ = AvatarManager.playerAvatarWorldView;
            _loc3_ = new Point(_loc6_.avatarPos.x,_loc6_.avatarPos.y);
            _loc4_ = _loc6_.inSplashVolume();
            _loc5_ = _loc6_.splashLiquid;
            _loc6_.setSplashVolume(false,null);
            _loc6_.roomType = param2;
            _loc6_.playIdle();
         }
         this.allPreviouslyNeededRoomItems = {
            "pathName":_pathName,
            "scale":_layerManager.bkg.scaleX,
            "roomEnviroType":this._roomEnviroType,
            "scene":_scene.sceneObject,
            "pos":_loc3_,
            "scrollOffset":new Point(_scrollOffset.x,_scrollOffset.y),
            "isInSplash":_loc4_,
            "splashLiquid":_loc5_,
            "prevRoomMode":this._roomMode
         };
         loadRoom_base(param1,this.loadDenPreviewAvatar,true);
      }
      
      public function getDarknessFromScene() : Array
      {
         var _loc2_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:Shape = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:Point = null;
         var _loc11_:Matrix = null;
         var _loc12_:Point = null;
         var _loc1_:Array = _volumeManager.findVolumesByType(VolumeManager.VOLUMETYPE_DARKSOFT);
         var _loc3_:Array = new Array();
         for each(_loc2_ in _loc1_)
         {
            _loc5_ = new Shape();
            _loc5_.graphics.beginFill(0);
            _loc5_.graphics.moveTo(_loc2_.v[0].x,_loc2_.v[0].y);
            _loc4_ = 1;
            while(_loc4_ < _loc2_.v.length)
            {
               _loc5_.graphics.lineTo(_loc2_.v[_loc4_].x,_loc2_.v[_loc4_].y);
               _loc4_++;
            }
            _loc5_.graphics.endFill();
            _loc3_.push(_loc5_);
            _loc6_ = 20;
            _loc7_ = 2;
            _loc8_ = 1;
            if(_loc2_.message.length)
            {
               _loc9_ = _loc2_.message.split(",");
               if(_loc9_.length == 2)
               {
                  _loc8_ = int(_loc9_[0]);
                  _loc6_ = int(_loc9_[1]);
               }
            }
            _loc4_ = 0;
            while(_loc4_ < _loc8_)
            {
               _loc10_ = _loc2_.v[_loc4_].subtract(_loc2_.v[_loc4_ + 1]);
               _loc11_ = new Matrix();
               _loc11_.createGradientBox(_loc10_.length,_loc6_,-Math.PI / 2);
               _loc12_ = new Point(-_loc10_.y,_loc10_.x);
               _loc12_.normalize(1);
               _loc5_ = new Shape();
               _loc5_.graphics.beginGradientFill(GradientType.LINEAR,[0,0],[0,1],[0,255],_loc11_);
               _loc5_.graphics.drawRect(0,0,_loc10_.length,_loc6_);
               _loc5_.rotation = Math.atan2(_loc10_.y,_loc10_.x) * 180 / Math.PI;
               _loc5_.x = _loc2_.v[_loc4_ + 1].x - _loc7_ * _loc12_.x;
               _loc5_.y = _loc2_.v[_loc4_ + 1].y - _loc7_ * _loc12_.y;
               _loc3_.push(_loc5_);
               _loc4_++;
            }
         }
         _loc1_ = _volumeManager.findVolumesByType(VolumeManager.VOLUMETYPE_DARKHARD);
         for each(_loc2_ in _loc1_)
         {
            _loc5_ = new Shape();
            _loc5_.graphics.beginFill(0);
            _loc5_.graphics.moveTo(_loc2_.v[0].x,_loc2_.v[0].y);
            _loc4_ = 1;
            while(_loc4_ < _loc2_.v.length)
            {
               _loc5_.graphics.lineTo(_loc2_.v[_loc4_].x,_loc2_.v[_loc4_].y);
               _loc4_++;
            }
            _loc5_.graphics.endFill();
            _loc3_.push(_loc5_);
         }
         return _loc3_;
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
      
      protected function onDenPreviewRoomLoaded(param1:*) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Avatar = null;
         var _loc4_:AvatarWorldView = null;
         var _loc5_:Point = null;
         onRoomLoaded_base(this.sceneAssetsLoaded,null,true);
         convertPathToWorldSpace();
         this.initActionPoints();
         if(this._gotoUsername == null || this._gotoUsername == "" || (_loc3_ = AvatarManager.getAvatarByUserName(this._gotoUsername)) == null || (_loc4_ = AvatarManager.avatarViewList[_loc3_.sfsUserId]) == null)
         {
            if(_playerGotoSpawnPoint == USE_PLAYER_GOTO_SPAWN_LOCATION)
            {
               _loc5_ = new Point();
               _loc2_ = {};
               _loc2_.x = _loc5_.x = _playerGotoSpawnLocationX;
               _loc2_.y = _loc5_.y = _playerGotoSpawnLocationY;
            }
            else
            {
               _loc2_ = findSpawn(_spawns,_playerGotoSpawnPoint);
               if(!_loc2_)
               {
                  _loc2_ = findSpawn(_spawns,"default");
                  if(!_loc2_)
                  {
                     _loc2_ = {
                        "x":400,
                        "y":400,
                        "r":10,
                        "toSpawn":null
                     };
                  }
               }
               _loc5_ = getRandomRadiusOffset(_loc2_.r);
               _loc2_.x += _loc5_.x;
               _loc2_.y += _loc5_.y;
               _loc5_ = new Point(_loc2_.x,_loc2_.y);
               convertToWorldSpace(_loc5_);
            }
            _playerGotoSpawnPoint = "default";
         }
         else
         {
            _loc5_ = new Point();
            _loc2_ = {};
            _loc2_.x = _loc5_.x = _loc4_.x;
            _loc2_.y = _loc5_.y = _loc4_.y;
            _loc2_.x += _mainBackObj.x;
            _loc2_.y += _mainBackObj.y;
            this._gotoUsername = null;
         }
         _scrollOffset.x = MainFrame.VIEW_WIDTH * 0.5 - _loc2_.x;
         _scrollOffset.y = MainFrame.VIEW_HEIGHT * 0.5 - _loc2_.y;
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,_loc5_.x,_loc5_.y,false,false);
      }
      
      protected function onRoomLoaded(param1:*) : void
      {
         var _loc2_:Point = null;
         var _loc4_:Object = null;
         var _loc5_:Avatar = null;
         var _loc6_:AvatarWorldView = null;
         onRoomLoaded_base(this.sceneAssetsLoaded,null);
         this._denCatId = _roomSettings.denCatId ? int(_roomSettings.denCatId) : -1;
         convertPathToWorldSpace();
         this.initActionPoints();
         var _loc3_:Object = findSpawn(_spawns,"den_theme");
         if(_loc3_)
         {
            this._denItems.setThemePosition(_loc3_.x,_loc3_.y);
         }
         if(this._denOwnerName != "")
         {
            DenXtCommManager.denChangeDone();
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoUsername:" + this._gotoUsername);
            if(this._gotoUsername != null)
            {
               DebugUtility.debugTrace("onRoomLoaded - (jumpAv = AvatarManager.getAvatarByUserName(_gotoUsername)) == null:" + ((_loc5_ = AvatarManager.getAvatarByUserName(this._gotoUsername)) == null));
            }
            DebugUtility.debugTrace("onRoomLoaded - jumpAv:" + _loc5_);
            if(_loc5_ != null)
            {
               DebugUtility.debugTrace("onRoomLoaded - (jumpToAv = AvatarManager.avatarViewList[jumpAv.sfsUserId]) == null:" + ((_loc6_ = AvatarManager.avatarViewList[_loc5_.sfsUserId]) == null));
            }
            DebugUtility.debugTrace("onRoomLoaded - jumpToAv:" + _loc6_);
         }
         if(this._gotoUsername == null || this._gotoUsername == "" || (_loc5_ = AvatarManager.getAvatarByUserName(this._gotoUsername)) == null || (_loc6_ = AvatarManager.avatarViewList[_loc5_.sfsUserId]) == null)
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoSpawnPoint:" + _playerGotoSpawnPoint);
            if(_playerGotoSpawnPoint == USE_PLAYER_GOTO_SPAWN_LOCATION)
            {
               _loc2_ = new Point();
               _loc4_ = {};
               _loc4_.x = _loc2_.x = _playerGotoSpawnLocationX;
               _loc4_.y = _loc2_.y = _playerGotoSpawnLocationY;
            }
            else
            {
               _loc4_ = findSpawn(_spawns,_playerGotoSpawnPoint);
               if(!_loc4_)
               {
                  _loc4_ = findSpawn(_spawns,"default");
                  if(!_loc4_)
                  {
                     _loc4_ = {
                        "x":400,
                        "y":400,
                        "r":10,
                        "toSpawn":null
                     };
                  }
               }
               _loc2_ = getRandomRadiusOffset(_loc4_.r);
               _loc4_.x += _loc2_.x;
               _loc4_.y += _loc2_.y;
               _loc2_ = new Point(_loc4_.x,_loc4_.y);
               convertToWorldSpace(_loc2_);
            }
            _playerGotoSpawnPoint = "default";
         }
         else
         {
            DebugUtility.debugTrace("onRoomLoaded - pos:" + _loc2_);
            _loc2_ = new Point();
            _loc4_ = {};
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn:" + _loc4_ + " pos:" + _loc2_ + " jumpToAv:" + _loc6_);
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn.x:" + _loc4_.x + " pos.x:" + _loc2_.x + " jumpToAv.x:" + _loc6_.x);
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn.y:" + _loc4_.y + " pos.y:" + _loc2_.y + " jumpToAv.y:" + _loc6_.y);
            _loc4_.x = _loc2_.x = _loc6_.x;
            _loc4_.y = _loc2_.y = _loc6_.y;
            DebugUtility.debugTrace("onRoomLoaded - mainBackObj offset spawn:" + _loc4_ + " _mainBackObj:" + _mainBackObj);
            _loc4_.x += _mainBackObj.x;
            _loc4_.y += _mainBackObj.y;
            DebugUtility.debugTrace("onRoomLoaded - after spawn:" + _loc4_ + " pos:" + _loc2_ + " jumpToAv:" + _loc6_);
            DebugUtility.debugTrace("onRoomLoaded - after spawn.x:" + _loc4_.x + " pos.x:" + _loc2_.x + " jumpToAv.x:" + _loc6_.x);
            DebugUtility.debugTrace("onRoomLoaded - after spawn.y:" + _loc4_.y + " pos.y:" + _loc2_.y + " jumpToAv.y:" + _loc6_.y);
            this._gotoUsername = null;
            DebugUtility.debugTrace("onRoomLoaded - set null _gotoUsername:" + this._gotoUsername);
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoUsername:" + this._gotoUsername + " jumpAv:" + _loc5_);
         }
         _scrollOffset.x = MainFrame.VIEW_WIDTH * 0.5 - _loc4_.x;
         _scrollOffset.y = MainFrame.VIEW_HEIGHT * 0.5 - _loc4_.y;
         AvatarManager.playerAvatarWorldView.playAnim(this._roomEnviroType == 0 ? LayerAnim.AN_IDLE_SE : LayerAnim.AN_FLOAT);
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,_loc2_.x,_loc2_.y,true,false);
         QuestManager.checkQuestOffScreenUsers();
         AvatarSwitch.playerInfoSet();
         _bTestPortal = true;
         if(_loc4_.toSpawn != null)
         {
            walkToSpawn(_loc4_.toSpawn);
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
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Point = null;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         var _loc12_:MovieClip = null;
         var _loc13_:MovieClip = null;
         var _loc14_:int = 0;
         var _loc15_:Loader = null;
         var _loc4_:Array = [];
         if(_actionPoints != null)
         {
            _loc5_ = [];
            _loc6_ = [];
            _loc7_ = [];
            _loc8_ = [];
            _loc9_ = [];
            _loc10_ = [];
            _loc11_ = [];
            _loc1_ = 0;
            while(_loc1_ < _actionPoints.length)
            {
               _loc2_ = _actionPoints[_loc1_];
               if(_loc2_.hasOwnProperty("type"))
               {
                  switch(_loc2_.type)
                  {
                     case ACTION_POINT_TYPE_MINIGAME:
                        if(!MinigameManager.minigameInfoCache.getMinigameInfo(_loc2_.typeDefId))
                        {
                           _loc4_.push(_loc2_.typeDefId);
                        }
                        else
                        {
                           _loc13_ = new MinigameManager.GameTotem() as MovieClip;
                           if(MinigameManager.minigameInfoCache.getMinigameInfo(_loc2_.typeDefId).petDefId > 0)
                           {
                              _loc15_ = _loc13_.getChildAt(0) as Loader;
                              _loc15_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPetGameTotemLoaded);
                              this._customMinigameLoaderInfos.push(_loc15_.contentLoaderInfo);
                           }
                           if(MinigameManager.minigameInfoCache.getMinigameInfo(_loc2_.typeDefId).gameDefId == 88)
                           {
                              _loc15_ = _loc13_.getChildAt(0) as Loader;
                              _loc15_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onSafetyGameTotemLoaded);
                              this._customMinigameLoaderInfos.push(_loc15_.contentLoaderInfo);
                           }
                           _loc3_ = new Point(_loc2_.x - _loc13_.width * 0.5,_loc2_.y - _loc13_.height);
                           convertToWorldSpace(_loc3_);
                           _loc13_.x = _loc3_.x;
                           _loc13_.y = _loc3_.y;
                           _layerManager.room_orbs.addChild(_loc13_);
                           _loc12_ = _loc13_;
                        }
                        break;
                     case ACTION_POINT_TYPE_SHOP:
                        _loc14_ = 60;
                        _loc3_ = new Point(_loc2_.x - _loc14_,_loc2_.y - _loc14_);
                        convertToWorldSpace(_loc3_);
                        _loc2_.pos = _loc3_;
                        _loc2_.rad = _loc14_;
                        break;
                     case ACTION_POINT_TYPE_NGFACT:
                        _loc3_ = new Point(_loc2_.x,_loc2_.y);
                        convertToWorldSpace(_loc3_);
                        _loc6_[_loc2_.typeDefId] = _loc3_;
                        _loc5_.push(_loc2_.typeDefId);
                        break;
                     case ACTION_POINT_TYPE_POLL:
                        _loc3_ = new Point(_loc2_.x,_loc2_.y);
                        convertToWorldSpace(_loc3_);
                        _loc8_[_loc2_.typeDefId] = _loc3_;
                        _loc7_.push(_loc2_.typeDefId);
                        _loc9_[_loc2_.typeDefId] = _loc2_.params == "" ? 1 : _loc2_.params;
                        break;
                     case ACTION_POINT_TYPE_FEEDBACK:
                        _loc3_ = new Point(_loc2_.x,_loc2_.y);
                        convertToWorldSpace(_loc3_);
                        _loc11_[_loc2_.typeDefId] = _loc3_;
                        _loc10_.push(_loc2_.typeDefId);
                        break;
                     case ACTION_POINT_TYPE_LAUNCH_QUEST:
                        _loc13_ = new MinigameManager.GameTotem() as MovieClip;
                        _loc3_ = new Point(_loc2_.x - _loc13_.width * 0.5,_loc2_.y - _loc13_.height);
                        convertToWorldSpace(_loc3_);
                        _loc13_.x = _loc3_.x;
                        _loc13_.y = _loc3_.y;
                        _layerManager.room_orbs.addChild(_loc13_);
                        _loc12_ = _loc13_;
                        break;
                     case ACTION_POINT_TYPE_QUEST_ACTOR:
                        if(_loc2_.hasOwnProperty("name"))
                        {
                           _loc3_ = new Point(_loc2_.x,_loc2_.y);
                           convertToWorldSpace(_loc3_);
                           QuestManager.initQuestActor(_loc2_.name,_loc2_.r,_loc2_.r2,null,_loc3_,null,true,_loc2_.params);
                        }
                        break;
                     case ACTION_POINT_TYPE_QUEST_RESPAWN:
                        _loc3_ = new Point(_loc2_.x,_loc2_.y);
                        convertToWorldSpace(_loc3_);
                        _loc2_.pos = _loc3_;
                        break;
                     default:
                        throw new Error("Actionpoint type is not valid!");
                  }
                  _loc2_.idx = _loc1_;
                  if(_loc12_)
                  {
                     _loc12_.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_ActionPoint,false,0,true);
                     _loc12_.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOverEvt_ActionPoint,false,0,true);
                     _loc12_.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOutEvt_ActionPoint,false,0,true);
                     _loc2_.clip = _loc12_;
                  }
               }
               _loc1_++;
            }
            if(_loc5_.length > 0)
            {
               this._factDefIds = _loc5_;
               this._factDefLocs = _loc6_;
               if(Boolean(this._factDefIds) && Boolean(this._factDefLocs))
               {
                  NGFactManager.requestFactInfo(_loc5_,_loc6_);
               }
            }
            if(_loc7_.length > 0 && gMainFrame.userInfo.numLogins >= 3)
            {
               PollManager.setUpPolls(_loc7_,_loc8_,_loc9_);
            }
            if(_loc10_.length > 0)
            {
               FeedbackManager.setUpOrbs(_loc10_,_loc11_);
            }
         }
         if(_volumes)
         {
            _loc1_ = 0;
            while(_loc1_ < _volumes.length)
            {
               _loc2_ = _volumes[_loc1_];
               switch(_loc2_.type)
               {
                  case 1:
                     _loc2_.idx = _loc1_;
                     if(!MinigameManager.minigameInfoCache.getMinigameInfo(_loc2_.typeDefId))
                     {
                        _loc4_.push(_loc2_.typeDefId);
                     }
               }
               _loc1_++;
            }
         }
         if(_loc4_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc4_,false,this.setupMinigameActionPoints);
         }
      }
      
      public function setupMinigameActionPoints() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Point = null;
         var _loc4_:MovieClip = null;
         var _loc5_:MinigameInfo = null;
         var _loc6_:MovieClip = null;
         var _loc7_:Loader = null;
         if(!_actionPoints || _actionPoints.length <= 0)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _actionPoints.length)
         {
            _loc1_ = _actionPoints[_loc3_];
            if(_loc1_.hasOwnProperty("type"))
            {
               if(_loc1_.type == ACTION_POINT_TYPE_MINIGAME)
               {
                  _loc5_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc1_.typeDefId);
                  if(!_loc5_)
                  {
                     return;
                  }
                  _loc6_ = new MinigameManager.GameTotem() as MovieClip;
                  _loc2_ = new Point(_loc1_.x - _loc6_.width * 0.5,_loc1_.y - _loc6_.height);
                  convertToWorldSpace(_loc2_);
                  if(_loc5_.petDefId > 0)
                  {
                     _loc7_ = _loc6_.getChildAt(0) as Loader;
                     _loc7_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPetGameTotemLoaded);
                     this._customMinigameLoaderInfos.push(_loc7_.contentLoaderInfo);
                  }
                  if(_loc5_.gameDefId == 88)
                  {
                     _loc7_ = _loc6_.getChildAt(0) as Loader;
                     _loc7_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onSafetyGameTotemLoaded);
                     this._customMinigameLoaderInfos.push(_loc7_.contentLoaderInfo);
                  }
                  _loc6_.x = _loc2_.x;
                  _loc6_.y = _loc2_.y;
                  _layerManager.room_orbs.addChild(_loc6_);
                  _loc4_ = _loc6_;
                  _loc4_.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_ActionPoint,false,0,true);
                  _loc4_.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOverEvt_ActionPoint,false,0,true);
                  _loc4_.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOutEvt_ActionPoint,false,0,true);
                  _loc1_.clip = _loc4_;
               }
            }
            _loc3_++;
         }
      }
      
      private function onPetGameTotemLoaded(param1:Event) : void
      {
         var _loc2_:LoaderInfo = null;
         var _loc4_:MovieClip = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._customMinigameLoaderInfos.length)
         {
            _loc2_ = this._customMinigameLoaderInfos[_loc3_];
            if(!(!_loc2_ || _loc2_ != LoaderInfo(param1.target)))
            {
               this._customMinigameLoaderInfos.splice(_loc3_,1);
               _loc4_ = _loc2_.loader.content as MovieClip;
               _loc4_.gotoAndPlay("petController");
               break;
            }
            _loc3_++;
         }
      }
      
      private function onSafetyGameTotemLoaded(param1:Event) : void
      {
         var _loc2_:LoaderInfo = null;
         var _loc4_:MovieClip = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._customMinigameLoaderInfos.length)
         {
            _loc2_ = this._customMinigameLoaderInfos[_loc3_];
            if(!(!_loc2_ || _loc2_ != LoaderInfo(param1.target)))
            {
               this._customMinigameLoaderInfos.splice(_loc3_,1);
               _loc4_ = _loc2_.loader.content as MovieClip;
               _loc4_.gotoAndPlay("safetyquiz");
               break;
            }
            _loc3_++;
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
      
      public function onJourneyBookFactDefReceived(param1:Object, param2:int) : void
      {
         var _loc3_:Object = null;
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < this._jbItems.length)
         {
            _loc3_ = this._jbItems[_loc4_];
            if(_loc3_.refId == param1.id && (_loc3_.refObjName == "" || _loc3_.refObjName.indexOf("start") == 0))
            {
               _loc5_ = Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,param1.bitIdx));
               if(_loc5_)
               {
                  this._jbItems.splice(_loc4_,1);
               }
               else
               {
                  _loc3_.isReady = true;
               }
               _loc6_ = _loc3_.refObjName;
               while(_loc6_ != "" && _loc6_ != "end")
               {
                  if(_loc6_.indexOf("start") == 0)
                  {
                     _loc6_ = _loc6_.substr(6);
                     if(_loc5_)
                     {
                        _loc3_.s.content.visible = true;
                        if(_loc3_.s.content.hasOwnProperty("critter"))
                        {
                           _loc3_.s.content.critter.visible = true;
                        }
                     }
                  }
                  _loc3_ = this.getJourneyBookItem(_loc6_);
                  if(_loc5_)
                  {
                     _loc7_ = 0;
                     while(_loc7_ < this._jbItems.length)
                     {
                        if(this._jbItems[_loc7_].refId == _loc3_.refId)
                        {
                           this._jbItems.splice(_loc7_,1);
                        }
                        _loc7_++;
                     }
                     _loc3_.s.content.visible = true;
                  }
                  else
                  {
                     _loc3_.isReady = true;
                  }
                  _loc6_ = _loc3_.refObjName;
               }
               break;
            }
            _loc4_++;
         }
         JBManager.checkUnseenPage(this._jbItems);
      }
      
      public function playMusic(param1:String, param2:Number) : void
      {
         playMusicTrack(param1,param2);
      }
      
      public function playPreviousMusic() : void
      {
         playPreviousMusicTrack();
      }
      
      override protected function sceneAssetsLoaded(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc5_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc14_:Object = null;
         var _loc15_:Object = null;
         super.sceneAssetsLoaded(param1);
         this._jbItems = [];
         this._inAndOutItems = {};
         _loc5_ = 0;
         while(_loc5_ < _layers.length)
         {
            _loc2_ = _layers[_loc5_];
            if(_loc2_.typeIndex == 1)
            {
               _loc8_ = true;
               if(_loc2_.s.content.hasOwnProperty("randomAppear"))
               {
                  _loc8_ = Boolean(_loc2_.s.content.randomAppear());
               }
               if(_loc8_)
               {
                  _loc2_.s.content.isJBItem = true;
               }
               this._jbItems.push(_loc2_);
            }
            if(_loc2_.typeIndex == 1 || _loc2_.typeIndex == 2)
            {
               if(Boolean(_loc2_.delaySecs) && Boolean(!isNaN(_loc2_.delaySecs)) && Boolean(_loc2_.s.content.hasOwnProperty("playAnim")))
               {
                  if(_loc2_.typeIndex == 2 && _loc2_.offsetSecs != null && !isNaN(_loc2_.offsetSecs))
                  {
                     _loc9_ = int(_loc2_.offsetSecs);
                  }
                  else
                  {
                     _loc9_ = _loc2_.delaySecs / 2;
                  }
                  this._inAndOutItems[_loc5_] = [];
                  while(_loc9_ <= 60 * 60)
                  {
                     this._inAndOutItems[_loc5_].push(_loc9_);
                     _loc9_ += _loc2_.delaySecs;
                  }
               }
            }
            if(!_scene._useDynamicLoading && _loc2_.layer == 1)
            {
               if(Boolean(_loc2_.s.hasOwnProperty("content")) && Boolean(_loc2_.s.content.hasOwnProperty("getSortHeight")))
               {
                  _loc2_.s.name = _loc2_.s.content.getSortHeight();
               }
            }
            _loc5_++;
         }
         var _loc4_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < this._jbItems.length)
         {
            _loc3_ = this._jbItems[_loc5_];
            _loc3_.isReady = false;
            _loc10_ = _loc3_.refObjName;
            if(_loc10_ == "" || _loc10_.indexOf("start") == 0)
            {
               _loc4_.push(_loc3_.refId);
            }
            else
            {
               _loc3_.s.content.visible = false;
            }
            _loc5_++;
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_.length)
         {
            NGFactManager.requestJourneyBookFactDef(_loc4_[_loc6_],this.onJourneyBookFactDefReceived);
            _loc6_++;
         }
         if(_loc4_.length > 0)
         {
            if(gMainFrame.server.getCurrentRoom().name.indexOf("party") >= 0)
            {
               _loc11_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_PARTY_JB_ENTER));
               _loc12_ = AchievementXtCommManager.UV_PARTY_JB_ENTER_BIT_ARRAY.indexOf(gMainFrame.clientInfo.secondaryDefId);
               if(_loc11_ == -1 || (_loc11_ >> _loc12_ & 1) == 0)
               {
                  GuiManager.openJourneyBook(true);
                  AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_PARTY_JB_ENTER,_loc12_);
               }
            }
         }
         var _loc7_:Object = _scene.getLayer("movie_player_streaming");
         if((Boolean(_loc7_)) && Boolean(_loc7_.loader) && Boolean(_loc7_.loader.content))
         {
            this._theaterLayer = _loc7_.loader.content;
         }
         else
         {
            this._theaterLayer = null;
         }
         if(this._theaterLayer)
         {
            this._theaterLayer.subtitle.text = "";
            this._theaterLayer.grayBox.visible = false;
            _loc13_ = _scene.getActorList("ActorVolume");
            for each(_loc14_ in _loc13_)
            {
               if(_loc14_.name == "movieselector")
               {
                  _loc15_ = null;
                  if(_loc14_.message != "")
                  {
                     _loc15_ = new Object();
                     _loc15_.msg = _loc14_.message;
                  }
                  GenericListXtCommManager.requestStreamList(_loc14_.typeDefId,GenericListGuiManager.launchMovies,_loc15_);
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
      
      public function broadcastMute(param1:Boolean) : void
      {
         if(_persistentObject)
         {
            _persistentObject.muteChanged(param1);
         }
         QuestManager.muteChanged(param1);
      }
      
      public function teleportPlayer(param1:int, param2:int, param3:Boolean) : void
      {
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,param1,param2,true,false,true);
         if(param3)
         {
            scrollRoom(AvatarManager.playerAvatarWorldView.localToGlobal(new Point(0,0)),24 * 100 / 0.07);
         }
         this.forceStopMovement();
      }
      
      public function teleportPlayerToDefault() : void
      {
         var _loc1_:Object = findSpawn(_spawns,_playerGotoSpawnPoint);
         if(!_loc1_)
         {
            _loc1_ = findSpawn(_spawns,"default");
            if(!_loc1_)
            {
               _loc1_ = {
                  "x":400,
                  "y":400,
                  "r":10,
                  "toSpawn":null
               };
            }
         }
         var _loc2_:Point = getRandomRadiusOffset(_loc1_.r);
         _loc1_.x += _loc2_.x;
         _loc1_.y += _loc2_.y;
         _loc2_ = new Point(_loc1_.x,_loc1_.y);
         convertToWorldSpace(_loc2_);
         _playerGotoSpawnPoint = "default";
         this.teleportPlayer(_loc2_.x,_loc2_.y,true);
      }
      
      public function setGotoUsername(param1:String, param2:Boolean) : void
      {
         var _loc4_:AvatarWorldView = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:Avatar = null;
         DebugUtility.debugTrace("setGotoUsername - value:" + param1 + " alreadyInRoom:" + param2);
         if(!param2 || (_loc3_ = AvatarManager.getAvatarByUserName(param1)) == null)
         {
            this._gotoUsername = param1;
         }
         else
         {
            _loc4_ = AvatarManager.avatarViewList[_loc3_.sfsUserId];
            _loc5_ = _loc4_.x;
            _loc6_ = _loc4_.y;
            _scrollOffset.x = MainFrame.VIEW_WIDTH / 2 - (_loc5_ + _mainBackObj.x);
            _scrollOffset.y = MainFrame.VIEW_HEIGHT / 2 - (_loc6_ + _mainBackObj.y);
            AvatarManager.resetThrottle();
            AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,_loc5_,_loc6_,true,false);
         }
         DebugUtility.debugTrace("setGotoUsername - _gotoUsername:" + this._gotoUsername + " gotoAv:" + _loc3_);
      }
      
      public function modGotoUser(param1:String, param2:int, param3:int) : void
      {
         DebugUtility.debugTrace("modGotoUser - _gotoUsername:" + this._gotoUsername + " acUserName:" + param1);
         if(this._gotoUsername == null || param1 != this._gotoUsername)
         {
            return;
         }
         this._gotoUsername = null;
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,param2,param3,true,false);
      }
      
      private function onMouseDownEvt_ActionPoint(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(_bTestPortal && Boolean(_actionPoints))
         {
            for each(_loc2_ in _actionPoints)
            {
               if(_loc2_.type == ACTION_POINT_TYPE_MINIGAME)
               {
                  if(_loc2_.clip == param1.currentTarget)
                  {
                     if(QuestManager.isInPrivateAdventureState)
                     {
                        QuestManager.showLeaveQuestLobbyPopup(this.onMouseDownEvt_ActionPoint,param1);
                        return;
                     }
                     if(!RoomXtCommManager.isSwitching)
                     {
                        GuiManager.toolTip.resetTimerAndSetVisibility();
                        _playerGotoSpawnPoint = _loc2_.spawn;
                        MinigameManager.handleGameClick(_loc2_,this.onFrgJoined);
                        AJAudio.playSubMenuBtnClick();
                     }
                     break;
                  }
               }
               else if(_loc2_.type == ACTION_POINT_TYPE_LAUNCH_QUEST)
               {
                  if(_loc2_.clip == param1.currentTarget)
                  {
                     this.checkAndStartAdventure(_loc2_.typeDefId);
                  }
               }
            }
         }
      }
      
      private function onMouseOverEvt_ActionPoint(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         AJAudio.playSubMenuBtnRollover();
         for each(_loc2_ in _actionPoints)
         {
            if(_loc2_.type == ACTION_POINT_TYPE_MINIGAME)
            {
               if(_loc2_.clip == param1.currentTarget)
               {
                  MovieClip(_loc2_.clip).transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
                  GuiManager.toolTip.init(_layerManager.room_orbs,MinigameManager.getGameName(_loc2_.typeDefId),_loc2_.clip.x + 50,_loc2_.clip.y + 80);
                  GuiManager.toolTip.startTimer(param1);
                  break;
               }
            }
            else if(_loc2_.type == ACTION_POINT_TYPE_LAUNCH_QUEST)
            {
               if(_loc2_.clip == param1.currentTarget)
               {
                  MovieClip(_loc2_.clip).transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
                  GuiManager.toolTip.init(_layerManager.room_orbs,LocalizationManager.translateIdOnly(14679),_loc2_.clip.x + 50,_loc2_.clip.y + 80);
                  GuiManager.toolTip.startTimer(param1);
                  break;
               }
            }
         }
      }
      
      private function onMouseOutEvt_ActionPoint(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in _actionPoints)
         {
            if(_loc2_.type == ACTION_POINT_TYPE_MINIGAME)
            {
               if(_loc2_.clip == param1.currentTarget)
               {
                  GuiManager.toolTip.resetTimerAndSetVisibility();
                  MovieClip(_loc2_.clip).transform.colorTransform = new ColorTransform(1,1,1);
                  break;
               }
            }
            else if(_loc2_.type == ACTION_POINT_TYPE_LAUNCH_QUEST)
            {
               if(_loc2_.clip == param1.currentTarget)
               {
                  GuiManager.toolTip.resetTimerAndSetVisibility();
                  MovieClip(_loc2_.clip).transform.colorTransform = new ColorTransform(1,1,1);
                  break;
               }
            }
         }
      }
      
      public function checkAndStartAdventure(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:Object = null;
         var _loc4_:AvatarInfo = null;
         var _loc5_:Object = null;
         if(QuestManager.isInPrivateAdventureState)
         {
            QuestManager.showLeaveQuestLobbyPopup(this.checkAndStartAdventure,param1,param2);
            return;
         }
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         if(!RoomXtCommManager.isSwitching)
         {
            _loc3_ = QuestXtCommManager.getScriptDef(param1);
            if(Boolean(_loc3_.membersOnly) && !gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(UpsellManager.ADVENTURES,"adventure/" + param1,null,null,param2);
               return;
            }
            _loc4_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(!_loc4_)
            {
               return;
            }
            if(_loc3_.playAsPet)
            {
               _loc5_ = PetManager.myActivePet;
               if(!_loc5_)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                  return;
               }
               if(!PetManager.canPetGoInEnviroType(_loc5_.type,_loc3_.avatarType))
               {
                  switch(_loc3_.avatarType)
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
               if(Boolean(AvatarManager.playerAvatar) && !AvatarManager.isValidEnviro(_loc3_.avatarType))
               {
                  switch(_loc3_.avatarType)
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
               if(_loc4_.questLevel < _loc3_.levelMin)
               {
                  if(!param2)
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc3_.levelMin));
                  }
                  else
                  {
                     new SBOkPopup(gMainFrame.stage,LocalizationManager.translateIdAndInsertOnly(14697,_loc3_.levelMin),false);
                  }
                  return;
               }
               if(_loc3_.avatarLimit == 1)
               {
                  if(_loc3_.hudType == 1)
                  {
                     if(param1 == 39)
                     {
                        GuiManager.isInFFM = true;
                     }
                     QuestXtCommManager.sendQuestCreateJoinPublic(param1);
                     return;
                  }
                  if(!param2)
                  {
                     new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14825),true,this.onConfirmStartAdventure,param1);
                     return;
                  }
               }
               else if(_loc3_.time == 1)
               {
                  QuestManager.openAdventureJoin(_loc3_.defId,AdventureJoin.NO_LOBBY,0);
                  return;
               }
            }
            AdventureExpertPopup.init(param1,param2);
         }
      }
      
      private function onConfirmStartAdventure(param1:Object) : void
      {
         if(param1.status)
         {
            QuestXtCommManager.sendQuestCreateJoinPublic(param1.passback);
         }
      }
      
      public function getNearestQuestRespawnPointPlayerIsIn(param1:Point) : Object
      {
         var _loc2_:Number = NaN;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Number = NaN;
         if(_actionPoints != null)
         {
            _loc3_ = null;
            for each(_loc4_ in _actionPoints)
            {
               if(_loc4_.type == ACTION_POINT_TYPE_QUEST_RESPAWN)
               {
                  _loc5_ = (param1.x - _loc4_.pos.x) * (param1.x - _loc4_.pos.x) + (param1.y - _loc4_.pos.y) * (param1.y - _loc4_.pos.y);
                  if(_loc5_ < _loc4_.r2 * _loc4_.r2 && (_loc3_ == null || _loc5_ < _loc2_))
                  {
                     _loc3_ = _loc4_;
                     _loc2_ = _loc5_;
                  }
               }
            }
         }
         return _loc3_;
      }
      
      public function setRoomMode(param1:int) : void
      {
         if(this._roomMode == ROOM_MODE_DEN)
         {
            if(param1 == ROOM_MODE_AVATAR)
            {
               KeepAlive.stopKATimer(gMainFrame.stage);
               this._denItems.saveState();
            }
            this._bLastShowDenHud = true;
         }
         else if(this._roomMode == ROOM_MODE_AVATAR && param1 == ROOM_MODE_DEN)
         {
            KeepAlive.startKATimer(gMainFrame.stage);
         }
         if(param1 == ROOM_MODE_CAMERAFOCUS_TO_TARGET)
         {
            if(this._cameraFocusToTime <= 0)
            {
               param1 = ROOM_MODE_CAMERAFOCUS_STAY;
               _scrollOffset = this._cameraFocusPoint;
               updateBackground();
            }
         }
         if(param1 == ROOM_MODE_CAMERAFOCUS_STAY)
         {
            if(this._cameraFocusStayTime <= 0)
            {
               param1 = ROOM_MODE_CAMERAFOCUS_RETURN;
            }
         }
         switch(param1)
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
         this._roomMode = param1;
         this._denItems.setRoomMode(this._roomMode);
      }
      
      public function setCameraFocus(param1:Point, param2:Number, param3:Number, param4:Number, param5:Boolean) : void
      {
         this.forceStopMovement();
         this._cameraReturnPoint = new Point(_scrollOffset.x,_scrollOffset.y);
         if(param5)
         {
            this._cameraFocusPoint = new Point(MainFrame.VIEW_WIDTH / 2 - (param1.x + _mainBackObj.x),MainFrame.VIEW_HEIGHT / 2 - (param1.y + _mainBackObj.y));
         }
         else
         {
            this._cameraFocusPoint = param1;
         }
         this._cameraFocusToTime = param2;
         this._cameraFocusStayTime = param3;
         this._cameraFocusReturnTime = param4;
         this.setRoomMode(ROOM_MODE_CAMERAFOCUS_TO_TARGET);
      }
      
      public function spawnNewDenItem(param1:Object) : void
      {
         var _loc2_:Point = null;
         _loc2_ = convertScreenToWorldSpace(450,275);
         param1.x = _loc2_.x;
         param1.y = _loc2_.y;
         this._denItems.setItems([param1],true);
      }
      
      public function forceStopMovement() : void
      {
         killPlayerPath();
         if(AvatarManager.playerAvatarWorldView)
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
      
      public function set shardId(param1:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         this._shardId = param1;
         var _loc2_:GamePlay = GamePlay(gMainFrame.gamePlay);
         if(_loc2_ != null)
         {
            _loc3_ = "[Not Initialized]";
            _loc4_ = ServerSelector.getShardName(param1);
            if(_loc4_)
            {
               _loc3_ = _loc4_;
            }
            _loc2_.debugShardIdTxt = "id=" + param1 + " name=" + _loc3_;
         }
      }
      
      public function set forceInvisMode(param1:Boolean) : void
      {
         this._forceInvisMode = param1;
      }
      
      public function set callback_TriggerWalkIn(param1:Function) : void
      {
         this._callback_TriggerWalkIn = param1;
      }
      
      public function set callback_FFMRoomAssetsLoaded(param1:Function) : void
      {
         this._callback_FFMRoomAssetsLoaded = param1;
      }
      
      public function set callback_InitialDataRequest(param1:Function) : void
      {
         this._callback_InitialDataRequest = param1;
      }
      
      public function set needsToSeeKickFromDenMessage(param1:Boolean) : void
      {
         this._needsToSeeKickFromDenMessage = param1;
      }
      
      public function setNeedsToSeeFacilitatorMessage(param1:Boolean, param2:int, param3:int = 0) : void
      {
         this._needsToSeeFacilitatorMessage = true;
         this._facilitatorMessage = {
            "messageId":param2,
            "duration":param3
         };
      }
      
      private function onFrgJoined() : void
      {
      }
      
      public function heartbeat(param1:int, param2:int) : void
      {
         var _loc6_:Object = null;
         var _loc3_:Boolean = true;
         switch(this._roomMode)
         {
            case ROOM_MODE_AVATAR:
               this.heartbeat_avatar(param1);
               break;
            case ROOM_MODE_DEN:
               this.heartbeat_den(param1);
               break;
            case ROOM_MODE_CAMERAFOCUS_TO_TARGET:
               _loc3_ = false;
               this._cameraFocusTimer += param1 * 0.001;
               if(this._cameraFocusTimer >= this._cameraFocusToTime)
               {
                  this.setRoomMode(ROOM_MODE_CAMERAFOCUS_STAY);
               }
               else
               {
                  _scrollOffset.x += this._cameraSpeedX * param1 * 0.001;
                  _scrollOffset.y += this._cameraSpeedY * param1 * 0.001;
                  updateBackground();
               }
               break;
            case ROOM_MODE_CAMERAFOCUS_STAY:
               _loc3_ = false;
               this._cameraFocusTimer += param1 * 0.001;
               if(this._cameraFocusTimer >= this._cameraFocusStayTime)
               {
                  this.setRoomMode(ROOM_MODE_CAMERAFOCUS_RETURN);
               }
               break;
            case ROOM_MODE_CAMERAFOCUS_RETURN:
               _loc3_ = false;
               this._cameraFocusTimer += param1 * 0.001;
               if(this._cameraFocusTimer >= this._cameraFocusReturnTime)
               {
                  this.setRoomMode(ROOM_MODE_AVATAR);
               }
               else
               {
                  _scrollOffset.x += this._cameraSpeedX * param1 * 0.001;
                  _scrollOffset.y += this._cameraSpeedY * param1 * 0.001;
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
         if(_loc3_ && Boolean(AvatarManager.playerAvatar))
         {
            _loc6_ = _volumeManager.testAvatarVolumes(new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y));
            if(_loc6_)
            {
               if(_loc6_.type == 6)
               {
                  AvatarManager.setPlayerAttachmentEmot(_loc6_.typeDefId,null,2);
               }
               else if(_loc6_.type == 11)
               {
                  if(this._callback_TriggerWalkIn != null)
                  {
                     this._callback_TriggerWalkIn(_loc6_.message);
                  }
               }
            }
            heartbeat_movePlayer(param1,param2);
         }
         _layerManager.room_avatars.heartbeat();
         _layerManager.flying_avatars.heartbeat();
         if(_bMouseDownNew)
         {
            _bMouseDownNew = false;
         }
         var _loc4_:Number = param2 / 1000;
         if(_loc4_ > 0.5)
         {
            _loc4_ = 0.5;
         }
         var _loc5_:int = 1;
         if(Boolean(this._roomMode == ROOM_MODE_AVATAR) && Boolean(AvatarManager.playerAvatarWorldView) && Boolean(_mainBackObj))
         {
            scrollRoom(AvatarManager.playerAvatarWorldView.localToGlobal(new Point(0,0)),24 * _loc5_ * _loc4_ / 0.07);
         }
      }
      
      private function updateAvatarBounce() : void
      {
         var _loc2_:Object = null;
         var _loc3_:* = undefined;
         var _loc1_:Object = AvatarManager.avatarViewList;
         for(_loc2_ in _loc1_)
         {
            _loc3_ = _loc1_[_loc2_];
            if(_volumeManager.testPointInVolume(new Point(_loc3_.x,_loc3_.y),this._bounceVolumes[0]))
            {
               _loc3_.setBounce(true);
            }
            else
            {
               _loc3_.setBounce(false);
            }
         }
      }
      
      private function disableAvatarBounce() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Object = AvatarManager.avatarViewList;
         for(_loc2_ in _loc1_)
         {
            _loc1_[_loc2_].setBounce(false);
         }
      }
      
      private function heartbeat_den(param1:int) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(_bMouseMove || this._dragAccelX > 0 || this._dragAccelY > 0)
         {
            if(!this._bInDenShop)
            {
               _loc3_ = _mousePos.x;
               _loc4_ = _mousePos.y;
               if(_mousePos.x < 0)
               {
                  _loc3_ = 0;
               }
               else if(_mousePos.x > MainFrame.VIEW_WIDTH)
               {
                  _loc3_ = MainFrame.VIEW_WIDTH;
               }
               if(_mousePos.y < 0)
               {
                  _loc4_ = 0;
               }
               else if(_mousePos.y > MainFrame.VIEW_HEIGHT)
               {
                  _loc4_ = MainFrame.VIEW_HEIGHT;
               }
               if(_bMouseDown)
               {
                  if(this._denItems.isDragging)
                  {
                     _loc9_ = 100;
                     _loc10_ = 75;
                     if(_mousePos.x < _loc9_)
                     {
                        _loc5_ = 1;
                        _loc7_ = (_mousePos.x - _loc9_) / -_loc9_;
                     }
                     else if(_mousePos.x > MainFrame.VIEW_WIDTH - _loc9_)
                     {
                        _loc5_ = -1;
                        _loc7_ = (MainFrame.VIEW_WIDTH - _loc9_ - _mousePos.x) / -_loc9_;
                     }
                     if(_mousePos.y < _loc10_)
                     {
                        _loc6_ = 1;
                        _loc8_ = (_mousePos.y - _loc10_) / -_loc10_;
                     }
                     else if(_mousePos.y > MainFrame.VIEW_HEIGHT - 120 - _loc10_)
                     {
                        _loc6_ = -1;
                        _loc8_ = (MainFrame.VIEW_HEIGHT - 120 - _loc10_ - _mousePos.y) / -_loc10_;
                     }
                     if(_loc5_ != 0 || _loc6_ != 0)
                     {
                        _loc7_ *= 12;
                        if(_loc7_ > 12)
                        {
                           _loc7_ = 12;
                        }
                        _loc8_ *= 12;
                        if(_loc8_ > 12)
                        {
                           _loc8_ = 12;
                        }
                        this._dragAccelX += 0.75;
                        if(this._dragAccelX > _loc7_)
                        {
                           this._dragAccelX = _loc7_;
                        }
                        this._dragAccelY += 0.75;
                        if(this._dragAccelY > _loc8_)
                        {
                           this._dragAccelY = _loc8_;
                        }
                        _scrollOffset.x += _loc5_ * this._dragAccelX;
                        _scrollOffset.y += _loc6_ * this._dragAccelY;
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
                        _loc5_ = this._dragX - _mousePos.x;
                        _loc6_ = this._dragY - _mousePos.y;
                        if(_loc5_ != 0 || _loc6_ != 0)
                        {
                           _scrollOffset.x -= _loc5_;
                           _scrollOffset.y -= _loc6_;
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
               _loc2_ = convertScreenToWorldSpace(_loc3_,_loc4_);
               this._denItems.handleMouse(_loc2_.x,_loc2_.y,_bMouseDown);
            }
            _bMouseMove = false;
         }
         this.showDenHud(!(this._denItems.isDragging && _bMouseDown));
      }
      
      public function heartbeat_avatar(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Object = null;
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
               _loc2_ = getObjUnderPoint(_mousePos,_layerManager.room_super_fg);
               if(!_loc2_)
               {
                  _loc2_ = getObjUnderPoint(_mousePos,_layerManager.room_fg);
                  if(!_loc2_)
                  {
                     _loc2_ = getObjUnderPoint(_mousePos,_layerManager.room_bkg_group);
                     if(!_loc2_)
                     {
                        _loc2_ = getObjUnderPoint(_mousePos,_layerManager.room_bkg);
                     }
                  }
               }
               if(_loc2_)
               {
                  _loc4_ = 0;
                  while(_loc4_ < this._jbItems.length)
                  {
                     _loc3_ = this._jbItems[_loc4_];
                     if(_loc3_.s.content == _loc2_)
                     {
                        if(_loc3_.isReady)
                        {
                           this._jbItems.splice(_loc4_,1);
                           if(_loc3_.refObjName == "" || _loc3_.refObjName == "end")
                           {
                              NGFactManager.showJourneyBookFact(_loc3_.refId);
                           }
                           else
                           {
                              _loc5_ = _loc3_.refObjName;
                              if(_loc5_.indexOf("start") == 0)
                              {
                                 _loc5_ = _loc5_.substr(6);
                              }
                              if(_loc3_.s.content.hasOwnProperty("playAnim"))
                              {
                                 _loc3_.s.content.playAnim();
                              }
                              _loc6_ = this.getJourneyBookItem(_loc5_);
                              _loc6_.s.content.visible = true;
                              _loc6_.s.content.playAnim();
                           }
                        }
                        break;
                     }
                     _loc4_++;
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
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         if(this._jamaaMS <= -1)
         {
            return;
         }
         var _loc1_:int = getTimer();
         if(!_layers)
         {
            this._jamaaMS += _loc1_ - this._prevGetTimer;
            this._prevGetTimer = _loc1_;
            return;
         }
         var _loc2_:Number = this._jamaaMS + (_loc1_ - this._prevGetTimer);
         for(_loc6_ in this._inAndOutItems)
         {
            _loc3_ = this._inAndOutItems[_loc6_];
            _loc4_ = int(_loc3_.length);
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               if(this._jamaaMS * 0.001 % 3600 < _loc3_[_loc5_] && _loc2_ * 0.001 % 3600 >= _loc3_[_loc5_])
               {
                  if(Boolean(_layers[_loc6_]) && Boolean(_layers[_loc6_].s) && Boolean(_layers[_loc6_].s.content))
                  {
                     _layers[_loc6_].s.content.playAnim();
                  }
               }
               _loc5_++;
            }
         }
         this._prevGetTimer = _loc1_;
         this._jamaaMS = _loc2_;
      }
      
      public function set jamaaMilliseconds(param1:Number) : void
      {
         this._jamaaMS = param1;
         this._prevGetTimer = getTimer();
      }
      
      private function showDenHud(param1:Boolean) : void
      {
         if(this._bLastShowDenHud != param1)
         {
            this._bLastShowDenHud = param1;
            GuiManager.showDenHudItems(param1);
         }
      }
      
      public function getNumJBItemsLeftInWorld() : int
      {
         return this._jbItems.length;
      }
      
      private function getJourneyBookItem(param1:String) : Object
      {
         param1 = param1.toLowerCase();
         var _loc2_:int = 0;
         while(_loc2_ < this._jbItems.length)
         {
            if(this._jbItems[_loc2_].name == param1)
            {
               return this._jbItems[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      private function clickVolumeTest(param1:Point) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         if(!_volumes)
         {
            return;
         }
         param1 = convertScreenToWorldSpace(param1.x,param1.y);
         _loc2_ = _volumeManager.testMouseVolumes(param1,_bMouseDown);
         if(Boolean(_loc2_) && _bMouseDownNew)
         {
            switch(_loc2_.type)
            {
               case 1:
                  MinigameManager.handleGameClick(_loc2_,this.onFrgJoined,true);
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
                  _loc3_ = _loc2_.message.split("%");
                  switch(_loc3_[0])
                  {
                     case "museum":
                        NGFactManager.requestMuseumFactInfo(_loc3_);
                        break;
                     case "donation":
                        GuiManager.openMuseumDonation();
                        break;
                     case "jammercentral":
                        GuiManager.openJammerCentral();
                        break;
                     case "ebook":
                        GuiManager.openEBookChooser(_loc3_[1]);
                        break;
                     case "pet":
                        PetManager.openPetFinder(_loc3_[1]);
                        break;
                     case "fact":
                        NGFactManager.showTierneyFact(_loc3_[1]);
                        break;
                     case "factbrady":
                        NGFactManager.showBradyFact(_loc3_[1]);
                        break;
                     case "carni":
                        DarkenManager.showLoadingSpiral(true);
                        PartyXtCommManager.sendJoinPartyRequest(18);
                        break;
                     case "photobooth":
                        GuiManager.openPhotoBooth();
                        break;
                     case "ajeventfact":
                        NGFactManager.requestFactInfo([_loc3_[1]]);
                        break;
                     case "diamondinfo":
                        GuiManager.openDiamondShopInfo();
                        break;
                     case "adventure":
                        this.checkAndStartAdventure(_loc3_[1]);
                        break;
                     case "displayimages":
                        GuiManager.openDisplayImagesPopup();
                        break;
                     case "petbanner":
                        PetAdoptionBanner.init(_loc3_[1]);
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
                  _loc4_ = gMainFrame.userInfo.getGenericListDefByDefId(_loc2_.typeDefId);
                  if(_loc4_)
                  {
                     _loc5_ = new Object();
                     _loc5_.volName = _loc2_.name;
                     if(_loc4_.typeId == DefPacksDefHelper.DEF_STREAM)
                     {
                        if(_loc2_.message != "")
                        {
                           _loc5_ = new Object();
                           _loc6_ = _loc2_.message.split("|");
                           if(_loc6_.length > 1)
                           {
                              _loc5_.msg = _loc6_[0];
                              _loc5_.width = _loc6_[1];
                              _loc5_.height = _loc6_[2];
                              _loc5_.shouldRepeat = _loc6_[3] != null && _loc6_[3] == "true" ? true : false;
                           }
                           else
                           {
                              _loc5_.msg = _loc2_.message;
                           }
                        }
                        this._theaterLayer = _scene.getLayer("movie_player_streaming");
                     }
                     GenericListGuiManager.genericListVolumeClicked(_loc2_.typeDefId,_loc5_);
                  }
                  break;
               case 13:
                  AvatarManager.setPlayerAttachmentEmot(_loc2_.typeDefId,_loc2_.message,60 * 24);
            }
            _volumeManager.clearHold(true);
            if(_bMouseDown && _loc2_.bWalkTo == false)
            {
               _bMouseDown = false;
            }
         }
      }
      
      private function launchRecycle(param1:int) : void
      {
         if(this._recycle)
         {
            this._recycle.destroy();
         }
         this._recycle = new RecycleItems();
         this._recycle.init(param1,GuiManager.guiLayer,false,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      public function onRecycleClose(param1:Boolean = false) : void
      {
         if(this._recycle)
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
                  if(!gMainFrame.userInfo.needFastPass)
                  {
                     AvatarXtCommManager.requestAvatarList([1,gMainFrame.userInfo.myUserName],AvatarSwitch.myAvatarListCallback);
                  }
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
      
      public function setUpWorldJoin() : void
      {
         AvatarUtility.init(AvatarManager.getAvatarByUsernamePerUserAvId,AvatarSwitch.getNumNonMemberAvailableAvatars);
         if(gMainFrame.userInfo.needFastPass)
         {
            AvatarSwitch.playerInfoSet();
            AvatarSwitch.addFastPassAvatar(null);
         }
         else if(gMainFrame.userInfo.firstFiveMinutes <= 0)
         {
            GuiManager.startFFM();
         }
         else
         {
            this._gotNewShardId = true;
            this.joinNewShardRoom();
         }
      }
      
      public function minigameJoinRoom(param1:String) : void
      {
         this._bAttemptingToJoinMinigameRoom = true;
         RoomXtCommManager.sendRoomJoinRequest(param1,-1,true);
      }
      
      public function haveHadLastGoodRoomName() : Boolean
      {
         return this._lastGoodRoomName != null;
      }
      
      public function clearLastGoodRoomForServerSwitch() : void
      {
         this._lastGoodRoomName = null;
      }
      
      public function joinNewShardRoom(param1:Boolean = false) : void
      {
         var _loc3_:String = null;
         if(!this._gotNewShardId)
         {
            return;
         }
         DebugUtility.debugTrace("joinNewShardRoom called");
         this._gotNewShardId = false;
         var _loc2_:String = null;
         if(!param1 && this._lastGoodRoomName != null)
         {
            _loc3_ = this._lastGoodRoomName.replace(/#[0-9]+/,"#" + this._shardId);
            if(this._lastGoodRoomName == _loc3_)
            {
               _loc2_ = gMainFrame.clientInfo.startUpRoom + "#" + this._shardId;
            }
            else
            {
               _loc2_ = _loc3_;
            }
         }
         else if(Boolean(gMainFrame.clientInfo.hasOwnProperty("autoStartRoom")) && gMainFrame.clientInfo.autoStartRoom != null && gMainFrame.clientInfo.autoStartRoom != "")
         {
            _loc2_ = gMainFrame.clientInfo.autoStartRoom;
            if(_loc2_ == QuestManager.SCRIPT_EDITOR_IXM_KEYWORD)
            {
               gMainFrame.server.joinDefaultRoom();
               gMainFrame.stage.focus = null;
               AvatarManager.loadSelfAssets(this.questRoomJoinCompleteAutoJoin);
               return;
            }
            DebugUtility.debugTrace("got autoStartRoom:" + _loc2_ + " - sending roomjoin request...");
            if(gMainFrame.clientInfo.autoStartRoomShardId == RoomXtCommManager.RT_PARAM_GET_SHARD_FROM_DEN)
            {
               DenXtCommManager.requestDenJoinFull(_loc2_);
               return;
            }
         }
         else
         {
            _loc2_ = gMainFrame.clientInfo.startUpRoom + "#" + this._shardId;
         }
         DebugUtility.debugTrace("newJoinRoomNameOrId before sendNonDenRoomJoinRequest:" + _loc2_);
         RoomXtCommManager.sendNonDenRoomJoinRequest(_loc2_);
      }
      
      private function questRoomJoinCompleteAutoJoin(param1:*) : void
      {
         GuiManager.reconnecting = false;
         RoomXtCommManager.loadingNewRoom = false;
         DarkenManager.showLoadingSpiral(false);
         LoadProgress.show(false);
         gMainFrame.stage.invalidate();
         this.checkAndStartAdventure(gMainFrame.clientInfo.autoStartRoomShardId,true);
      }
      
      private function onJoinRoom(param1:SFEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:MovieClip = null;
         if(param1.status)
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
            _loc2_ = param1.obj.room.name;
            if(_loc2_.slice(0,7) != "quest_0")
            {
               _loc3_ = _loc2_.slice(0,3);
               _loc4_ = _loc2_.indexOf("first_five");
               if((this._lastGoodRoomName == null || this._lastGoodRoomName.slice(0,3) == "ffm") && _loc3_ != "ffm" && _loc4_ == -1)
               {
                  this._shouldLoadMessagePopups = true;
                  DarkenManager.showLoadingSpiral(true);
               }
               if(!param1.obj.subRoom)
               {
                  GuiManager.chatHist.clearChat();
                  AvatarManager.removeAllAvatars();
                  this._lastGoodRoomName = _loc2_;
                  if(_loc3_ == "den")
                  {
                     this._denOwnerName = _loc2_.slice(3);
                  }
                  else
                  {
                     this._denOwnerName = "";
                     _loc5_ = _loc2_.indexOf("#");
                     if(_loc5_ != -1)
                     {
                        _loc6_ = int(_loc2_.substring(_loc5_ + 1));
                        if(_loc6_ != this._shardId)
                        {
                           DebugUtility.debugTrace("joinedShard:" + _loc6_ + " is different than current _shardId:" + this._shardId + "... updating _shardId to match.");
                           this.shardId = _loc6_;
                        }
                     }
                  }
                  if(AvatarManager.playerSfsUserId == -1)
                  {
                     GuiManager.chatHist.showChatInput(true);
                  }
                  if(_loc2_.indexOf("oceans") == 0)
                  {
                     gMainFrame.userInfo.worldMapRoomName = _loc2_.slice(7,_loc2_.indexOf("#"));
                  }
                  else
                  {
                     gMainFrame.userInfo.worldMapRoomName = _loc2_.slice(0,_loc2_.indexOf("."));
                  }
               }
            }
         }
         else
         {
            if(param1.obj.roomFull)
            {
               DebugUtility.debugTrace("Room was full- show room popup? _bAttemptingToJoinMinigameRoom:" + this._bAttemptingToJoinMinigameRoom + " RoomXtCommManager.isSwitching:" + RoomXtCommManager.isSwitching + " _lastGoodRoomName:" + this._lastGoodRoomName + " gMainFrame.server.getCurrentRoomName():" + gMainFrame.server.getCurrentRoomName());
               if(!RoomXtCommManager.isSwitching && !this._bAttemptingToJoinMinigameRoom && this._lastGoodRoomName != null && this._lastGoodRoomName == gMainFrame.server.getCurrentRoomName())
               {
                  DebugUtility.debugTrace("Room is full!");
                  DarkenManager.showLoadingSpiral(false);
                  SBTracker.push();
                  _loc2_ = RoomXtCommManager._joinRoomName;
                  _loc2_ = _loc2_.slice(0,_loc2_.indexOf("#"));
                  if(isNaN(Number(_loc2_)))
                  {
                     SBTracker.trackPageview("/game/play/popup/joinFullRoom/#" + _loc2_,-1,SBTracker.TYPE_EVENT);
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
            else if(param1.message == "OA")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14829),true,GuiManager.switchToOceanAnimal,{
                  "switchRooms":true,
                  "switchDens":false
               });
            }
            else if(param1.message == "DP")
            {
               DarkenManager.showLoadingSpiral(false);
               _loc7_ = GETDEFINITIONBYNAME("DenLockedPopupContent");
               if(param1.obj.denOwner != "" && BuddyManager.isBuddy(param1.obj.denOwner.toLowerCase()))
               {
                  LocalizationManager.translateId(_loc7_.bodyTxt1,19101);
               }
               new SBPopup(GuiManager.guiLayer,GETDEFINITIONBYNAME("DenLockedPopupSkin"),_loc7_,true,true,false,false,true);
               BuddyCard.grayOutGoToDenBtn(true,param1.obj.denOwner);
            }
            else if(param1.message == "DUA")
            {
               DarkenManager.showLoadingSpiral(false);
               if(GuiManager.isVersionPopupOpen())
               {
                  BuddyCard.closeBuddyCard();
               }
               else
               {
                  if("den" + BuddyCard.currBuddyCardUserName == RoomXtCommManager._joinRoomName.toLowerCase())
                  {
                     BuddyCard.resetBuddyCardForArchiveMode();
                  }
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14830),true);
               }
            }
            else if(param1.message == "RQJF")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Tried to join a quest that does not belong to us!");
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14831),true);
            }
            else if(param1.message == "RDNE")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Tried to join a room that no longer exists!");
               QuestManager.handleRDNE();
            }
            else if(param1.message == "JWD")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Joined a room that was being destroyed!");
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14832),true,this.roomFullOkBtnHandler);
               RoomXtCommManager.sendRoomJoinRequest(this._lastGoodRoomName);
            }
            else if(param1.message == "DG")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14833),true,this.roomFullOkBtnHandler);
               BuddyCard.grayOutGoToDenBtn(true);
            }
            else if(param1.message == "HAS")
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
      
      private function roomFullOkBtnHandler(param1:MouseEvent) : void
      {
         walkToSpawn(this._fullRoomSpawn);
         if(param1.currentTarget.parent.text.text == LocalizationManager.translateIdOnly(14826))
         {
            SBTracker.flush(true);
         }
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         GuiManager.openWorldMap();
      }
      
      private function portalCollisionTest() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Object = null;
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         if(_bMouseDownNew)
         {
            this._bMouseDownForDenPortal = true;
         }
         if(!_bTestPortal || !AvatarManager.playerAvatarWorldView || !AvatarManager.playerAvatarWorldView.moving)
         {
            return;
         }
         if(_portals)
         {
            _loc3_ = new Point();
            for each(_loc2_ in _portals)
            {
               if(!AvatarManager.playerAvatarWorldView)
               {
                  continue;
               }
               _loc3_.x = _loc2_.x;
               _loc3_.y = _loc2_.y;
               convertToWorldSpace(_loc3_);
               if(!AvatarManager.playerAvatarWorldView.circleTest(_loc3_.x,_loc3_.y,_loc2_.r))
               {
                  continue;
               }
               if(this._lastPortal == _loc2_)
               {
                  _loc1_ = true;
                  continue;
               }
               _bTestPortal = false;
               _loc4_ = 0;
               if(_loc2_.type)
               {
                  _loc4_ = int(_loc2_.type);
               }
               switch(_loc4_)
               {
                  case 0:
                     _loc5_ = String(_loc2_["goto"]).toLowerCase() + "#" + this._shardId;
                     DarkenManager.showLoadingSpiral(true);
                     RoomXtCommManager.sendNonDenRoomJoinRequest(_loc5_);
                     _playerGotoSpawnPoint = _loc2_.spawn;
                     this._fullRoomSpawn = _loc2_.fullSpawn;
                     this._lastPortal = _loc2_;
                     _loc1_ = true;
                     break;
                  case 1:
                     if(!(AvatarManager.playerAvatarWorldView.avatarData.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR))
                     {
                        if(RoomManagerWorld.instance.collisionTestGrid(_loc3_.x,_loc3_.y) == 0)
                        {
                           UserCommXtCommManager.sendAvatarSlide(_loc2_["goto"]);
                           attachAvatarToSlide(AvatarManager.playerAvatarWorldView,_loc2_["goto"],_loc2_.spawn);
                           if(_loc2_["goto"] == "bounceslide1")
                           {
                              SBAudio.playCachedSound("aj_slideBounce2");
                           }
                           if(_loc2_["goto"] == "bounceslide2")
                           {
                              SBAudio.playCachedSound("aj_slideBounce1");
                           }
                        }
                        else
                        {
                           this._lastPortal = _loc2_;
                           _loc1_ = true;
                        }
                     }
               }
            }
         }
         if(!_loc1_)
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
