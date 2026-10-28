package room
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.SceneLoader;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import loader.MediaHelper;
   import ru.etcs.utils.getDefinitionNames;
   
   public class RoomManagerBase
   {
      
      protected static const ENABLE_DEBUG_DRAW:Boolean = false;
      
      protected var _scrollOffset:Point;
      
      protected var _scene:SceneLoader;
      
      protected var _layers:Array;
      
      protected var _portals:Array;
      
      protected var _spawns:Array;
      
      protected var _lines:Array;
      
      protected var _actionPoints:Array;
      
      protected var _roomSettings:Object;
      
      protected var _volumes:Array;
      
      protected var _paths:Array;
      
      protected var _stageMin:Point;
      
      protected var _stageMax:Point;
      
      protected var _grid:Object;
      
      protected var _roomGrid:RoomGrid;
      
      protected var _mainBackObj:Object;
      
      protected var _roomMusic:SBMusic;
      
      protected var _gaRoomName:String;
      
      protected var _sfxMediaHelpers:Array;
      
      protected var _parentIndices:Dictionary;
      
      protected var _assetsLoaded:Boolean;
      
      protected var _persistentObject:Object;
      
      protected var _volumeManager:VolumeManager;
      
      protected var _layerManager:LayerManager;
      
      protected var _assetPool:Dictionary;
      
      protected var _objectSwapper:Object;
      
      protected var _checkSurroundingAssets:Boolean;
      
      private var _buckets:Array;
      
      private var _isDenPreview:Boolean;
      
      public function RoomManagerBase()
      {
         super();
      }
      
      public function get volumeManager() : VolumeManager
      {
         return _volumeManager;
      }
      
      public function get layerManager() : LayerManager
      {
         return _layerManager;
      }
      
      public function get scrollOffset() : Point
      {
         return _scrollOffset;
      }
      
      public function init(param1:LayerManager) : void
      {
         _layerManager = param1;
         _scene = new SceneLoader(LoadProgress.show);
         _volumeManager = new VolumeManager();
         _roomGrid = new RoomGrid();
         _scrollOffset = new Point(0,0);
         _stageMin = new Point(0,0);
         _stageMax = new Point(0,0);
         _sfxMediaHelpers = [];
         _objectSwapper = {};
         gMainFrame.stage.addEventListener("RoomEventLoadSfx",onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener("RoomEventPlaySfx",onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener("RoomEventPlaySwfSfx",onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener("RoomEventPlaySwfSfxByClass",onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener("RoomEventAttachEmote",onRoomEvent,false,0,true);
      }
      
      public function destroy() : void
      {
         gMainFrame.stage.removeEventListener("RoomEventLoadSfx",onRoomEvent);
         gMainFrame.stage.removeEventListener("RoomEventPlaySfx",onRoomEvent);
         gMainFrame.stage.removeEventListener("RoomEventPlaySwfSfx",onRoomEvent);
         gMainFrame.stage.removeEventListener("RoomEventPlaySwfSfxByClass",onRoomEvent);
         gMainFrame.stage.removeEventListener("RoomEventAttachEmote",onRoomEvent);
      }
      
      public function exitRoom(param1:Boolean = false) : void
      {
         _layerManager.bkg.visible = false;
         _persistentObject = null;
         if(_roomMusic && !param1)
         {
            _roomMusic.stop();
         }
         if(_mainBackObj)
         {
            _assetsLoaded = false;
            _scrollOffset.x = 0;
            _scrollOffset.y = 0;
            updateBackground(true);
            while(_layerManager.room_bkg.numChildren)
            {
               _layerManager.room_bkg.removeChildAt(0);
            }
            while(_layerManager.room_fg.numChildren)
            {
               _layerManager.room_fg.removeChildAt(0);
            }
            while(_layerManager.room_super_fg.numChildren)
            {
               _layerManager.room_super_fg.removeChildAt(0);
            }
            while(_layerManager.room_bkg_main.numChildren)
            {
               _layerManager.room_bkg_main.removeChildAt(0);
            }
            if(!param1)
            {
               while(_layerManager.room_avatars.numChildren)
               {
                  _layerManager.room_avatars.removeChildAt(0);
               }
               while(_layerManager.flying_avatars.numChildren)
               {
                  _layerManager.flying_avatars.removeChildAt(0);
               }
               while(_layerManager.preview_room_avatar.numChildren)
               {
                  _layerManager.preview_room_avatar.removeChildAt(0);
               }
               while(_layerManager.preview_room_flying_avatar.numChildren)
               {
                  _layerManager.preview_room_flying_avatar.removeChildAt(0);
               }
               while(_layerManager.room_chat.numChildren)
               {
                  _layerManager.room_chat.removeChildAt(0);
               }
            }
            while(_layerManager.room_orbs.numChildren)
            {
               _layerManager.room_orbs.removeChildAt(0);
            }
            if(_buckets)
            {
               _buckets = null;
            }
            if(!param1)
            {
               _layerManager.room_avatars.release();
            }
            _mainBackObj = null;
            _layers = null;
            _volumeManager.release();
            _grid = null;
            _portals = null;
            _spawns = null;
            _lines = null;
            _volumes = null;
            _paths = null;
            _actionPoints = null;
            _scene.release();
         }
      }
      
      protected function loadRoom_base(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var _loc5_:String = param1;
         exitRoom(param3);
         if(gMainFrame.clientInfo.extCallsActive)
         {
            ExternalInterface.call("mrc",["sr",gMainFrame.server.getCurrentRoomName()]);
            DebugUtility.debugTrace("mrc:sr command sent - roomname:" + gMainFrame.server.getCurrentRoomName() + " fullName:" + _loc5_);
         }
         _loc5_ = _loc5_.replace(/\./g,"/");
         var _loc4_:int = _loc5_.indexOf("#");
         if(_loc4_ >= 0)
         {
            _loc5_ = _loc5_.substring(0,_loc4_);
         }
         _loc5_ += ".xroom";
         _gaRoomName = "/game/play/room/#" + _loc5_;
         LoadProgress.load("roomDefs/" + _loc5_.toLowerCase(),6,param2);
      }
      
      protected function resetCurrentRoom_base(param1:String) : void
      {
         var _loc3_:String = param1;
         _loc3_ = _loc3_.replace(/\./g,"/");
         var _loc2_:int = _loc3_.indexOf("#");
         if(_loc2_ >= 0)
         {
            _loc3_ = _loc3_.substring(0,_loc2_);
         }
         _loc3_ += ".xroom";
         _isDenPreview = false;
      }
      
      protected function onRoomLoaded_base(param1:Function, param2:Object, param3:Boolean = false) : void
      {
         var _loc8_:int = 0;
         var _loc7_:* = null;
         var _loc6_:Object = null;
         var _loc4_:Number = NaN;
         _layerManager.bkg.visible = false;
         _layerManager.bkg.x = 0;
         _layerManager.bkg.y = 0;
         _isDenPreview = param3;
         var _loc5_:Object = param2 != null ? param2 : LoadProgress.entry.data;
         if(_loc5_ == null)
         {
            throw "error loading room:" + _gaRoomName;
         }
         _scene.setScene(_loc5_);
         _scene.addEventListener("complete",param1);
         _roomSettings = _scene.getActorList("ActorSettings")[0];
         _stageMin.x = _roomSettings.xmin;
         _stageMin.y = _roomSettings.ymin;
         _stageMax.x = _roomSettings.xmax;
         _stageMax.y = _roomSettings.ymax;
         _grid = _roomSettings.grid;
         _roomGrid.setGrid(_grid);
         if(_roomSettings.hasOwnProperty("music") && _gaRoomName.indexOf("player_den") == -1)
         {
            if(_roomSettings.hasOwnProperty("musicVol") && _roomSettings.musicVol >= 0 && _roomSettings.musicVol <= 100)
            {
               _loc4_ = _roomSettings.musicVol / 100;
            }
            else
            {
               _loc4_ = 0.5;
            }
            playMusicTrack(_roomSettings.music,_loc4_);
         }
         _layers = _scene.getActorList("ActorLayer");
         _loc8_ = 0;
         while(_loc8_ < _layers.length)
         {
            _loc6_ = _layers[_loc8_];
            if(_loc6_.layer == 0)
            {
               _layerManager.room_avatars.x = _loc6_.x;
               _layerManager.room_avatars.y = _loc6_.y;
               _layerManager.flying_avatars.x = _loc6_.x;
               _layerManager.flying_avatars.y = _loc6_.y;
               _layerManager.room_bkg_main.x = _loc6_.x;
               _layerManager.room_bkg_main.y = _loc6_.y;
               _layerManager.room_chat.x = _loc6_.x;
               _layerManager.room_chat.y = _loc6_.y;
               _layerManager.room_orbs.x = _loc6_.x;
               _layerManager.room_orbs.y = _loc6_.y;
               if(param3)
               {
                  _layerManager.preview_room_avatar.x = _loc6_.x;
                  _layerManager.preview_room_avatar.y = _loc6_.y;
                  _layerManager.preview_room_flying_avatar.x = _loc6_.x;
                  _layerManager.preview_room_flying_avatar.y = _loc6_.y;
               }
               _mainBackObj = _loc6_;
               break;
            }
            _loc8_++;
         }
         _portals = _scene.getActorList("ActorPortal");
         _spawns = _scene.getActorList("ActorSpawn");
         _lines = _scene.getActorList("ActorCollisionPoint");
         _volumes = _scene.getActorList("ActorVolume");
         _actionPoints = _scene.getActorList("ActorAction");
         _paths = _scene.getActorList("ActorPath");
         _scrollOffset.x = -_stageMin.x;
         _scrollOffset.y = -_stageMin.y;
         if(!param3)
         {
            SBTracker.flush();
            SBTracker.trackPageview(_gaRoomName);
         }
      }
      
      protected function roomLoadComplete() : void
      {
         LoadProgress.show(false);
      }
      
      protected function sceneAssetsLoaded(param1:Event) : void
      {
         var _loc8_:int = 0;
         var _loc11_:int = 0;
         var _loc10_:Point = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc9_:Object = null;
         var _loc5_:Object = null;
         var _loc3_:Rectangle = null;
         _scene.removeEventListener("complete",sceneAssetsLoaded);
         _assetPool = new Dictionary();
         _parentIndices = new Dictionary();
         if(!_layers)
         {
            return;
         }
         _loc11_ = 0;
         while(_loc11_ < _layers.length)
         {
            _loc6_ = _layers[_loc11_];
            _loc7_ = _layerManager.room_bkg.numChildren;
            _loc4_ = _layerManager.room_fg.numChildren;
            _loc2_ = _layerManager.room_super_fg.numChildren;
            _loc6_.s.mouseEnabled = false;
            _loc6_.s.mouseChildren = false;
            _loc9_ = _layerManager.room_avatars;
            switch(_loc6_.layer)
            {
               case 0:
                  _loc6_.pIndex = _loc7_++;
                  _parentIndices[_loc6_.s] = _loc6_.pIndex;
                  _layerManager.room_bkg.addChild(_loc6_.s);
                  break;
               case 1:
                  _loc9_.addChild(_loc6_.s);
                  break;
               case 2:
                  _loc6_.pIndex = _loc4_++;
                  _parentIndices[_loc6_.s] = _loc6_.pIndex;
                  _layerManager.room_fg.addChild(_loc6_.s);
                  break;
               case 4:
                  _loc6_.pIndex = _loc2_++;
                  _parentIndices[_loc6_.s] = _loc6_.pIndex;
                  _layerManager.room_super_fg.addChild(_loc6_.s);
            }
            if(_loc6_.hasOwnProperty("sortHeight"))
            {
               _loc6_.s.name = _loc6_.sortHeight;
            }
            _loc11_++;
         }
         if(_portals)
         {
            _loc11_ = 0;
            while(_loc11_ < _portals.length)
            {
               _loc6_ = _portals[_loc11_];
               if(_loc6_.type == 1)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _layers.length)
                  {
                     _loc5_ = _layers[_loc8_];
                     if(_loc5_.name == _loc6_["goto"])
                     {
                        _loc5_.s.parent.removeChild(_loc5_.s);
                        _loc5_.excludeFromCull = 1;
                        break;
                     }
                     _loc8_++;
                  }
               }
               _loc11_++;
            }
         }
         _loc11_ = 0;
         while(_loc11_ < _layers.length)
         {
            _loc6_ = _layers[_loc11_];
            if(_loc6_.layer)
            {
               _loc10_ = new Point(_loc6_.x,_loc6_.y);
               convertToWorldSpace(_loc10_);
               setLayerMatrix(_loc6_,_loc10_.x,_loc10_.y);
            }
            if(_loc6_.typeIndex == 1 || _loc6_.typeIndex == 2 || _loc6_.dx != 1 || _loc6_.dy != 1)
            {
               _loc6_.excludeFromCull = 1;
            }
            _loc11_++;
         }
         if(!_scene._useDynamicLoading)
         {
            _loc11_ = 0;
            while(_loc11_ < _layers.length)
            {
               _loc6_ = _layers[_loc11_];
               _loc3_ = _loc6_.s.getBounds(_loc6_.s.parent);
               _loc6_.offsetX = _loc3_.left - _loc6_.s.x;
               _loc6_.offsetY = _loc3_.top - _loc6_.s.y;
               _loc11_++;
            }
         }
         _assetsLoaded = true;
         _checkSurroundingAssets = true;
         updateBackground();
         setupBuckets();
         _volumeManager.setScene(_scene,new Point(_mainBackObj.x,_mainBackObj.y));
         _layerManager.bkg.visible = true;
         if(!_isDenPreview)
         {
            _layerManager.showAvatarsAndRelatedItems(true);
         }
         else
         {
            _layerManager.showAvatarsAndRelatedItems(false);
         }
      }
      
      private function setupBuckets() : void
      {
         var _loc13_:int = 0;
         var _loc8_:Object = null;
         var _loc20_:Sprite = null;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:Number = NaN;
         var _loc12_:int = 0;
         var _loc10_:int = 0;
         var _loc9_:int = 0;
         var _loc19_:int = 0;
         var _loc1_:int = 0;
         var _loc16_:int = 0;
         var _loc5_:int = 0;
         var _loc17_:int = 0;
         var _loc21_:int = 0;
         var _loc15_:int = 0;
         var _loc18_:Object = null;
         var _loc2_:Number = 1.7976931348623157e+308;
         var _loc7_:Number = Number.MIN_VALUE;
         var _loc11_:Number = 1.7976931348623157e+308;
         var _loc14_:Number = Number.MIN_VALUE;
         if(_scene._useDynamicLoading && _layers.length > 1000)
         {
            _loc13_ = 0;
            while(_loc13_ < _layers.length)
            {
               _loc8_ = _layers[_loc13_];
               _loc6_ = 0;
               _loc4_ = 0;
               if(_loc8_.layer == 1)
               {
                  _loc20_ = _layerManager.room_avatars;
                  _loc6_ = _loc20_.parent.x;
                  _loc4_ = _loc20_.parent.y;
               }
               else
               {
                  _loc20_ = _layerManager.room_bkg;
               }
               _loc6_ += _loc8_.offsetX;
               _loc4_ += _loc8_.offsetY;
               _loc3_ = _layerManager.bkg.scaleX;
               _loc12_ = (_loc8_.s.x + _loc20_.x + _loc6_) * _loc3_;
               _loc10_ = (_loc8_.s.x + _loc8_.width + _loc20_.x + _loc6_) * _loc3_;
               _loc9_ = (_loc8_.s.y + _loc20_.y + _loc4_) * _loc3_;
               _loc19_ = (_loc8_.s.y + _loc8_.height + _loc20_.y + _loc4_) * _loc3_;
               _loc8_.bLeft = _loc12_;
               _loc8_.bRight = _loc10_;
               _loc8_.bTop = _loc9_;
               _loc8_.bBottom = _loc19_;
               if(_loc12_ < _loc2_)
               {
                  _loc2_ = _loc12_;
               }
               if(_loc10_ > _loc7_)
               {
                  _loc7_ = _loc10_;
               }
               if(_loc9_ < _loc11_)
               {
                  _loc11_ = _loc9_;
               }
               if(_loc19_ > _loc14_)
               {
                  _loc14_ = _loc19_;
               }
               _loc13_++;
            }
            _loc1_ = Math.ceil((_loc7_ - _loc2_) / 2700);
            _loc16_ = Math.ceil((_loc14_ - _loc11_) / 2700);
            _loc5_ = (_loc7_ - _loc2_) / _loc1_;
            _loc17_ = (_loc14_ - _loc11_) / _loc16_;
            _buckets = [];
            _loc21_ = 0;
            while(_loc21_ < _loc16_)
            {
               _loc15_ = 0;
               while(_loc15_ < _loc1_)
               {
                  _buckets[_loc1_ * _loc21_ + _loc15_] = {
                     "x":_loc2_ + _loc5_ * _loc15_,
                     "y":_loc11_ + _loc17_ * _loc21_,
                     "width":_loc5_,
                     "height":_loc17_,
                     "scrollOffsetX":_scrollOffset.x,
                     "scrollOffsetY":_scrollOffset.y
                  };
                  _loc15_++;
               }
               _loc21_++;
            }
            _loc13_ = 0;
            while(_loc13_ < _layers.length)
            {
               _loc8_ = _layers[_loc13_];
               _loc15_ = Math.floor(((_loc8_.bRight + _loc8_.bLeft) * 0.5 - _loc2_) / _loc5_);
               _loc21_ = Math.floor(((_loc8_.bBottom + _loc8_.bTop) * 0.5 - _loc11_) / _loc17_);
               _loc8_.bucketIndex = _loc1_ * _loc21_ + _loc15_;
               _loc18_ = _buckets[_loc8_.bucketIndex];
               if(_loc8_.bRight > _loc18_.x + _loc18_.width)
               {
                  _loc18_.width = _loc8_.bRight - _loc18_.x;
               }
               if(_loc8_.bLeft < _loc18_.x)
               {
                  _loc18_.width += _loc18_.x - _loc8_.bLeft;
                  _loc18_.x = _loc8_.bLeft;
               }
               if(_loc8_.bBottom > _loc18_.y + _loc18_.height)
               {
                  _loc18_.height = _loc8_.bBottom - _loc18_.y;
               }
               if(_loc8_.bTop < _loc18_.y)
               {
                  _loc18_.height += _loc18_.y - _loc8_.bTop;
                  _loc18_.y = _loc8_.bTop;
               }
               if(_loc8_.bucketIndex < 0 || _loc8_.bucketIndex >= _buckets.length)
               {
                  throw new Error("Bucket index out of range!");
               }
               _loc13_++;
            }
         }
      }
      
      public function findSpawn(param1:Array, param2:String) : Object
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         if(param1 == null)
         {
            param1 = _spawns;
         }
         if(param1 != null)
         {
            while(_loc4_ < param1.length)
            {
               if(param1[_loc4_].name == param2)
               {
                  _loc3_ = param1[_loc4_];
                  break;
               }
               _loc4_++;
            }
         }
         return _loc3_;
      }
      
      public function findLayers(param1:String) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         if(_layers != null)
         {
            while(_loc3_ < _layers.length)
            {
               if(_layers[_loc3_].name == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = [];
                  }
                  _loc2_.push(_layers[_loc3_]);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      protected function playMusicTrack(param1:String, param2:Number) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(!_roomMusic)
         {
            if(_persistentObject)
            {
               _persistentObject.muteChanged(true);
            }
            _roomMusic = new SBMusic(param1,true,param2);
         }
         else
         {
            _roomMusic.stop();
            _roomMusic.playNewMusic(param1,true,param2);
         }
         if(_roomMusic && SBAudio.isMusicMuted)
         {
            _roomMusic.toggleMute();
         }
      }
      
      protected function playPreviousMusicTrack() : void
      {
         if(_roomMusic)
         {
            _roomMusic.stop();
            if(_roomMusic.previouslyPlayedFilename == null || _roomMusic.previouslyPlayedFilename == "")
            {
               if(_persistentObject)
               {
                  _roomMusic = null;
                  _persistentObject.muteChanged(SBAudio.isMusicMuted);
               }
               return;
            }
            _roomMusic.playNewMusic(_roomMusic.previouslyPlayedFilename,true,_roomMusic.previousVolume);
            if(SBAudio.isMusicMuted)
            {
               _roomMusic.toggleMute();
            }
         }
      }
      
      public function debugAudioVolumeChanged(param1:Number) : void
      {
         if(_roomMusic)
         {
            _roomMusic.volume = param1;
         }
      }
      
      private function onRoomEvent(param1:RoomEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         switch(param1.type)
         {
            case "RoomEventLoadSfx":
               _loc3_ = int(param1.secondaryType);
               if(_loc3_ > 0)
               {
                  loadRoomEventSfx(int(param1.secondaryType));
               }
               break;
            case "RoomEventPlaySfx":
               playRoomEventSfx(param1.secondaryType);
               break;
            case "RoomEventPlaySwfSfx":
               _loc2_ = _scene.getLayer(param1.secondaryType);
               if(_loc2_)
               {
                  if(!SBAudio.isMusicMuted)
                  {
                     _loc2_.loader.content.playSound(param1.tertiaryType);
                  }
                  if(param1.persistent)
                  {
                     _persistentObject = _loc2_.loader.content;
                     _roomMusic = null;
                  }
               }
               break;
            case "RoomEventPlaySwfSfxByClass":
               if(!SBAudio.isMusicMuted)
               {
                  param1.target.playSound();
               }
               break;
            case "RoomEventAttachEmote":
               AvatarManager.setPlayerAttachmentEmot(parseInt(param1.secondaryType));
         }
      }
      
      public function loadRoomEventSfx(param1:int) : void
      {
         var _loc2_:MediaHelper = null;
         if(_sfxMediaHelpers[param1] == null)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(param1,onSfxLoaded,true);
            _sfxMediaHelpers[param1] = _loc2_;
         }
      }
      
      private function playRoomEventSfx(param1:String) : void
      {
         if(param1 != "aj_water_fs1" && param1 != "aj_water_fs2" && param1 != "aj_water_fs3")
         {
            SBAudio.playCachedSound(param1);
         }
      }
      
      private function onSfxLoaded(param1:MovieClip) : void
      {
         var _loc6_:int = 0;
         var _loc2_:String = null;
         var _loc5_:Array = getDefinitionNames(param1.loaderInfo);
         var _loc4_:Array = [];
         _loc6_ = 0;
         while(_loc6_ < _loc5_.length)
         {
            _loc2_ = _loc5_[_loc6_];
            if(_loc2_ && _loc2_ != "")
            {
               SBAudio.addCachedSound(_loc2_,param1.loaderInfo.applicationDomain.getDefinition(_loc2_) as Class);
            }
            _loc6_++;
         }
         var _loc3_:int = int(param1.mediaHelper.id);
         _sfxMediaHelpers[_loc3_].destroy();
         delete _sfxMediaHelpers[_loc3_];
      }
      
      public function collisionTestGrid(param1:int, param2:int) : uint
      {
         if(!_mainBackObj)
         {
            return 0;
         }
         var _loc3_:Object = _roomGrid.convertWorldPosToGrid(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
         return _roomGrid.testGridCell(_loc3_.x,_loc3_.y);
      }
      
      public function enableVolume(param1:String, param2:Boolean) : void
      {
         _roomGrid.enableVolume(param1,param2);
         _volumeManager.setVolumesEnabled(param1,param2);
      }
      
      public function rebuildGrid() : void
      {
         if(_grid.hasOwnProperty("packedGrid"))
         {
            _grid.packedGrid.position = 0;
         }
         _roomGrid.setGrid(_grid);
      }
      
      protected function scrollRoom(param1:Point, param2:int) : void
      {
         var _loc3_:Number = param1.x;
         var _loc6_:Number = param1.y;
         var _loc5_:Number = calcScrollAmount(_loc3_,_layerManager.bkg.scaleX,400,900,_mainBackObj.dx,param2,gMainFrame.clientInfo.roomType == 7);
         var _loc4_:Number = calcScrollAmount(_loc6_,_layerManager.bkg.scaleY,250,550,_mainBackObj.dy,param2,gMainFrame.clientInfo.roomType == 7);
         _scrollOffset.x += _loc5_;
         _scrollOffset.y += _loc4_;
         if(_loc5_ || _loc4_)
         {
            updateBackground();
         }
      }
      
      protected function calcScrollAmount(param1:Number, param2:Number, param3:int, param4:int, param5:Number, param6:int, param7:Boolean = true) : Number
      {
         var _loc8_:Number = 0;
         var _loc11_:int = param6 * 1.5;
         var _loc9_:Number = param3 - param1;
         var _loc10_:Number = param1 - (param4 - param3);
         if(param7)
         {
            param6 = Math.max(_loc10_,_loc9_);
         }
         if(_loc10_ > 0)
         {
            _loc8_ = param6;
            if(_loc10_ < _loc8_)
            {
               _loc8_ = _loc10_;
            }
            _loc8_ *= -1;
         }
         else if(_loc9_ > 0)
         {
            _loc8_ = param6;
            if(_loc9_ < _loc8_)
            {
               _loc8_ = _loc9_;
            }
         }
         if(param5)
         {
            _loc8_ /= param5;
         }
         if(_loc8_ != 0 && param2 != 1)
         {
            _loc8_ /= param2;
         }
         return _loc8_;
      }
      
      protected function updateBackground(param1:Boolean = false) : void
      {
         var _loc9_:* = null;
         var _loc8_:int = 0;
         var _loc6_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Object = null;
         var _loc7_:Number = _scrollOffset.x;
         var _loc4_:Number = _scrollOffset.y;
         if(_loc4_ > -_stageMin.y)
         {
            _loc4_ = -_stageMin.y;
         }
         else if(_loc4_ < -_stageMax.y)
         {
            _loc4_ = -_stageMax.y;
         }
         if(_loc7_ > -_stageMin.x)
         {
            _loc7_ = -_stageMin.x;
         }
         else if(_loc7_ < -_stageMax.x)
         {
            _loc7_ = -_stageMax.x;
         }
         _scrollOffset.x = _loc7_;
         _scrollOffset.y = _loc4_;
         if(_buckets)
         {
            setActiveBuckets();
         }
         var _loc5_:uint = 0;
         _loc8_ = 0;
         while(_loc8_ < _layers.length)
         {
            _loc3_ = _layers[_loc8_];
            if(_loc3_.layer != 1)
            {
               _loc6_ = _loc3_.x + _loc7_ * _loc3_.dx;
               _loc2_ = _loc3_.y + _loc4_ * _loc3_.dy;
               if(_loc3_.s == _mainBackObj.s)
               {
                  _layerManager.room_bkg_group.x = _loc6_ - _loc3_.x;
                  _layerManager.room_bkg_group.y = _loc2_ - _loc3_.y;
                  _layerManager.room_chat.x = _loc6_;
                  _layerManager.room_chat.y = _loc2_;
                  _layerManager.flying_avatars.x = _loc6_;
                  _layerManager.flying_avatars.y = _loc2_;
                  _layerManager.room_orbs.x = _loc6_;
                  _layerManager.room_orbs.y = _loc2_;
                  _layerManager.preview_room_flying_avatar.x = _loc6_;
                  _layerManager.preview_room_flying_avatar.y = _loc2_;
               }
               if(!_loc3_.flip)
               {
                  _loc3_.s.x = _loc6_;
                  _loc3_.s.y = _loc2_;
               }
               else
               {
                  setLayerMatrix(_loc3_,_loc6_,_loc2_);
               }
            }
            if(_assetsLoaded && _loc3_.excludeFromCull != 1 && _loc3_.s)
            {
               if(!_buckets || _buckets[_loc3_.bucketIndex].active)
               {
                  _loc5_ += checkStageValidity(_loc3_);
               }
            }
            _loc8_++;
         }
         if(!param1 && _checkSurroundingAssets && _loc5_ == 0)
         {
            _scene.forceLoadComplete();
            _checkSurroundingAssets = false;
         }
      }
      
      private function setActiveBuckets() : void
      {
         var _loc3_:Object = null;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc11_:int = -100;
         var _loc10_:int = 1000;
         var _loc6_:int = -100;
         var _loc5_:int = 650;
         var _loc2_:int = 0;
         var _loc1_:Number = _layerManager.bkg.scaleX;
         _loc2_ = 0;
         while(_loc2_ < _buckets.length)
         {
            _loc3_ = _buckets[_loc2_];
            _loc9_ = _loc3_.x + (_scrollOffset.x - _loc3_.scrollOffsetX) * _loc1_;
            _loc8_ = _loc3_.x + _loc3_.width + (_scrollOffset.x - _loc3_.scrollOffsetX) * _loc1_;
            _loc7_ = _loc3_.y + (_scrollOffset.y - _loc3_.scrollOffsetY) * _loc1_;
            _loc4_ = _loc3_.y + _loc3_.height + (_scrollOffset.y - _loc3_.scrollOffsetY) * _loc1_;
            _loc3_.active = !(_loc5_ < _loc7_ || _loc6_ > _loc4_ || _loc10_ < _loc9_ || _loc11_ > _loc8_);
            _loc2_++;
         }
      }
      
      protected function checkStageValidity(param1:Object) : uint
      {
         var _loc16_:Sprite = null;
         var _loc6_:Object = null;
         var _loc3_:int = 0;
         var _loc13_:uint = 0;
         var _loc12_:int = -100;
         var _loc10_:int = 1000;
         var _loc7_:int = -100;
         var _loc17_:int = 650;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(param1.layer == 1)
         {
            _loc16_ = _layerManager.room_avatars;
            _loc5_ = _loc16_.parent.x;
            _loc4_ = _loc16_.parent.y;
         }
         else
         {
            _loc16_ = _layerManager.room_bkg;
         }
         _loc5_ += param1.offsetX;
         _loc4_ += param1.offsetY;
         var _loc2_:Number = _layerManager.bkg.scaleX;
         var _loc11_:int = (param1.s.x + _loc16_.x + _loc5_) * _loc2_;
         var _loc9_:int = (param1.s.x + param1.width + _loc16_.x + _loc5_) * _loc2_;
         var _loc8_:int = (param1.s.y + _loc16_.y + _loc4_) * _loc2_;
         var _loc15_:int = (param1.s.y + param1.height + _loc16_.y + _loc4_) * _loc2_;
         var _loc14_:Array = _assetPool[param1.assetName];
         if(!(_loc17_ < _loc8_ || _loc7_ > _loc15_ || _loc10_ < _loc11_ || _loc12_ > _loc9_))
         {
            if(param1.loaded == 0)
            {
               if(_loc14_ && _loc14_.length > 0)
               {
                  _loc6_ = _loc14_.pop();
                  swapObjects(param1,_loc6_);
               }
               else
               {
                  _scene.loadLayer(param1);
                  _loc13_ = 1;
               }
            }
            if(param1.s.parent == null)
            {
               if(param1.layer != 1)
               {
                  insertOrdered(param1);
               }
               else
               {
                  _layerManager.room_avatars.addChild(param1.s);
               }
               _loc3_ = 0;
               if(_loc14_ && (_loc3_ = _loc14_.indexOf(param1)) != -1)
               {
                  _loc14_.splice(_loc3_,1);
               }
            }
         }
         else if(param1.s.parent)
         {
            param1.s.parent.removeChild(param1.s);
            if(param1.loaded == 2 && _scene.isValidDynamicAsset(param1))
            {
               if(_loc14_ == null)
               {
                  _assetPool[param1.assetName] = _loc14_ = [];
               }
               _loc14_.push(param1);
            }
         }
         return _loc13_;
      }
      
      private function swapObjects(param1:Object, param2:Object) : void
      {
         _objectSwapper.s = param1.s;
         param1.s = param2.s;
         param2.s = _objectSwapper.s;
         _parentIndices[param1.s] = param1.pIndex;
         _parentIndices[param2.s] = param2.pIndex;
         _objectSwapper.sx = param1.s.x;
         _objectSwapper.sy = param1.s.y;
         _objectSwapper.srotation = param1.s.rotation;
         _objectSwapper.sscaleX = param1.s.scaleX;
         _objectSwapper.sscaleY = param1.s.scaleY;
         _objectSwapper.loaded = param1.loaded;
         param1.s.x = param2.s.x;
         param1.s.y = param2.s.y;
         param1.s.rotation = param2.s.rotation;
         param1.s.scaleX = param2.s.scaleX;
         param1.s.scaleY = param2.s.scaleY;
         param1.loaded = param2.loaded;
         param2.s.x = _objectSwapper.sx;
         param2.s.y = _objectSwapper.sy;
         param2.s.rotation = _objectSwapper.srotation;
         param2.s.scaleX = _objectSwapper.sscaleX;
         param2.s.scaleY = _objectSwapper.sscaleY;
         param2.loaded = _objectSwapper.loaded;
      }
      
      private function insertOrdered(param1:Object) : void
      {
         var _loc3_:Sprite = null;
         var _loc2_:Object = null;
         var _loc4_:int = 0;
         if(param1.layer == 0)
         {
            _loc3_ = _layerManager.room_bkg;
         }
         else if(param1.layer == 4)
         {
            _loc3_ = _layerManager.room_super_fg;
         }
         else
         {
            _loc3_ = _layerManager.room_fg;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc3_.numChildren)
         {
            _loc2_ = _loc3_.getChildAt(_loc4_);
            if(_parentIndices[_loc2_] > param1.pIndex)
            {
               break;
            }
            _loc4_++;
         }
         _loc3_.addChildAt(param1.s,_loc4_);
      }
      
      protected function setLayerMatrix(param1:Object, param2:Number, param3:Number) : void
      {
         var _loc6_:Matrix = null;
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         if(!param1.flip)
         {
            param1.s.x = param2;
            param1.s.y = param3;
         }
         else
         {
            _loc6_ = param1.s.transform.matrix;
            _loc6_.identity();
            _loc8_ = Number(param1.scaleX);
            _loc7_ = Number(param1.scaleY);
            _loc5_ = param2;
            _loc4_ = param3;
            if(param1.flip & 1)
            {
               _loc8_ *= -1;
               _loc5_ += param1.width;
            }
            if(param1.flip & 2)
            {
               _loc7_ *= -1;
               _loc4_ += param1.height;
            }
            _loc6_.scale(_loc8_,_loc7_);
            _loc6_.translate(_loc5_,_loc4_);
            param1.s.transform.matrix = _loc6_;
         }
      }
      
      public function convertToWorldSpace(param1:Point) : void
      {
         if(_mainBackObj)
         {
            param1.x -= _mainBackObj.x;
            param1.y -= _mainBackObj.y;
         }
      }
      
      public function convertScreenToWorldSpace(param1:int, param2:int) : Point
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_mainBackObj)
         {
            _loc4_ = (param1 - _layerManager.bkg.x) / _layerManager.bkg.scaleX - (_mainBackObj.x + _mainBackObj.dx * _scrollOffset.x);
            _loc3_ = (param2 - _layerManager.bkg.y) / _layerManager.bkg.scaleY - (_mainBackObj.y + _mainBackObj.dy * _scrollOffset.y);
         }
         return new Point(_loc4_,_loc3_);
      }
      
      public function convertWorldToScreen(param1:int, param2:int) : Point
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_mainBackObj)
         {
            _loc4_ = param1 + (_mainBackObj.x + _mainBackObj.dx * _scrollOffset.x) * _layerManager.bkg.scaleX + _layerManager.bkg.x;
            _loc3_ = param2 + (_mainBackObj.y + _mainBackObj.dy * _scrollOffset.y) * _layerManager.bkg.scaleY + _layerManager.bkg.y;
         }
         return new Point(_loc4_,_loc3_);
      }
      
      public function bkgScalePoint() : Point
      {
         return new Point(_layerManager.bkg.scaleX,_layerManager.bkg.scaleY);
      }
      
      protected function getRandomRadiusOffset(param1:Number) : Point
      {
         var _loc3_:Point = new Point();
         var _loc2_:Number = Math.random() * (2 * 3.141592653589793);
         param1 = Math.random() * param1;
         _loc3_.x = Math.cos(_loc2_) * param1;
         _loc3_.y = Math.sin(_loc2_) * param1;
         return _loc3_;
      }
      
      public function convertPathToWorldSpace() : void
      {
         var _loc4_:int = 0;
         var _loc1_:Object = null;
         var _loc3_:int = 0;
         var _loc2_:Point = null;
         if(_paths)
         {
            _loc4_ = 0;
            while(_loc4_ < _paths.length)
            {
               _loc1_ = _paths[_loc4_];
               _loc3_ = 0;
               while(_loc3_ < _loc1_.points.length)
               {
                  if(_loc1_.points[_loc3_])
                  {
                     _loc2_ = new Point(_loc1_.points[_loc3_].x,_loc1_.points[_loc3_].y);
                     convertToWorldSpace(_loc2_);
                     _loc1_.points[_loc3_].x = _loc2_.x;
                     _loc1_.points[_loc3_].y = _loc2_.y;
                  }
                  _loc3_++;
               }
               _loc4_++;
            }
         }
      }
      
      public function findPathByName(param1:String) : Object
      {
         var _loc3_:int = 0;
         var _loc2_:Object = null;
         if(_paths)
         {
            param1.toLowerCase();
            _loc3_ = 0;
            while(_loc3_ < _paths.length)
            {
               _loc2_ = _paths[_loc3_];
               if(_loc2_.name == param1)
               {
                  return _loc2_;
               }
               _loc3_++;
            }
         }
         return null;
      }
      
      protected function drawDebugLayer(param1:Vector.<int> = null) : void
      {
         var _loc8_:int = 0;
         var _loc11_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc7_:Object = null;
         var _loc5_:Object = null;
         var _loc3_:* = undefined;
         var _loc13_:Object = null;
         var _loc6_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc4_:int = 0;
         var _loc9_:Object = null;
         _layerManager.debugShape.x = -_mainBackObj.x;
         _layerManager.debugShape.y = -_mainBackObj.y;
         _layerManager.room_bkg_main.addChild(_layerManager.debugShape);
         var _loc2_:Graphics = _layerManager.debugShape.graphics;
         _loc2_.clear();
         var _loc12_:Number = 0.2;
         if(_portals)
         {
            _loc2_.beginFill(16711680,_loc12_);
            _loc11_ = 0;
            while(_loc11_ < _portals.length)
            {
               _loc7_ = _portals[_loc11_];
               _loc2_.drawCircle(_loc7_.x,_loc7_.y,_loc7_.r);
               if(_loc7_.type == 1)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _layers.length)
                  {
                     _loc5_ = _layers[_loc8_];
                     if(_loc5_.name == _loc7_["goto"])
                     {
                        break;
                     }
                     _loc8_++;
                  }
                  if(_loc5_)
                  {
                     _loc3_ = _loc5_.s.content;
                     if(_loc3_)
                     {
                        _loc8_ = 0;
                        while(_loc8_ < _loc3_.totalFrames)
                        {
                           _loc3_.gotoAndStop(_loc8_);
                           _loc15_ = _loc3_.player.x + _loc5_.x;
                           _loc14_ = _loc3_.player.y + _loc5_.y;
                           _loc2_.drawCircle(_loc15_,_loc14_,10);
                           _loc8_++;
                        }
                     }
                  }
               }
               _loc11_++;
            }
         }
         _loc2_.endFill();
         _loc2_.beginFill(65280,_loc12_);
         _loc11_ = 0;
         while(_loc11_ < _spawns.length)
         {
            _loc7_ = _spawns[_loc11_];
            _loc2_.drawCircle(_loc7_.x,_loc7_.y,_loc7_.r);
            _loc11_++;
         }
         _loc2_.endFill();
         if(_actionPoints)
         {
            _loc2_.beginFill(255,_loc12_);
            _loc11_ = 0;
            while(_loc11_ < _actionPoints.length)
            {
               _loc7_ = _actionPoints[_loc11_];
               _loc2_.drawCircle(_loc7_.x,_loc7_.y,_loc7_.r);
               _loc11_++;
            }
            _loc2_.endFill();
         }
         if(_lines)
         {
            _loc2_.lineStyle(2,16777215);
            _loc11_ = 0;
            while(_loc11_ < _lines.length)
            {
               _loc7_ = _lines[_loc11_];
               _loc2_.moveTo(_loc7_.x,_loc7_.y);
               _loc2_.lineTo(_loc7_.x1,_loc7_.y1);
               _loc11_++;
            }
         }
         if(_paths)
         {
            _loc2_.lineStyle(2,255);
            _loc11_ = 0;
            while(_loc11_ < _paths.length)
            {
               _loc7_ = _paths[_loc11_];
               _loc8_ = 0;
               while(_loc8_ < _loc7_.points.length)
               {
                  _loc13_ = _loc7_.points[_loc8_];
                  if(_loc8_ == 0)
                  {
                     _loc2_.moveTo(_loc13_.x,_loc13_.y);
                  }
                  else
                  {
                     _loc2_.lineTo(_loc13_.x,_loc13_.y);
                  }
                  _loc8_++;
               }
               _loc11_++;
            }
         }
         if(_volumes)
         {
            _loc2_.lineStyle(2,255);
            _loc11_ = 0;
            while(_loc11_ < _volumes.length)
            {
               _loc7_ = _volumes[_loc11_];
               _loc8_ = 0;
               while(_loc8_ < _loc7_.points.length)
               {
                  _loc13_ = _loc7_.points[_loc8_];
                  if(_loc8_ == 0)
                  {
                     _loc2_.moveTo(_loc13_.x,_loc13_.y);
                  }
                  else
                  {
                     _loc2_.lineTo(_loc13_.x,_loc13_.y);
                  }
                  _loc8_++;
               }
               _loc11_++;
            }
         }
         if(_grid)
         {
            _loc6_ = _grid.min.y + _grid.r;
            _loc14_ = 0;
            while(_loc14_ < _grid.height)
            {
               _loc10_ = _grid.min.x + _grid.r;
               _loc15_ = 0;
               while(_loc15_ < _grid.width)
               {
                  _loc2_.lineStyle(2,0);
                  _loc4_ = int(_grid.grid[_loc15_ + _loc14_ * _grid.width]);
                  if(_loc4_)
                  {
                     _loc2_.beginFill(_loc4_ == 1 ? 16776960 : 255,0.9);
                  }
                  _loc2_.drawRect(_loc10_ - _grid.r,_loc6_ - _grid.r,_grid.r2,_grid.r2);
                  _loc2_.endFill();
                  _loc10_ += _grid.r2;
                  _loc15_++;
               }
               _loc6_ += _grid.r2;
               _loc14_++;
            }
            if(param1)
            {
               _loc11_ = 0;
               while(_loc11_ < param1.length)
               {
                  _loc9_ = _roomGrid.getCellIndexToWorldPos(param1[_loc11_]);
                  _loc2_.beginFill(16711680,0.75);
                  _loc2_.drawRect(_loc9_.x - _grid.r,_loc9_.y - _grid.r,_grid.r2,_grid.r2);
                  _loc2_.endFill();
                  _loc11_++;
               }
            }
         }
      }
   }
}

