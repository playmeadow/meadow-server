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
      
      public function RoomManagerBase()
      {
         super();
      }
      
      public function get volumeManager() : VolumeManager
      {
         return this._volumeManager;
      }
      
      public function get scrollOffset() : Point
      {
         return this._scrollOffset;
      }
      
      public function init(param1:LayerManager) : void
      {
         this._layerManager = param1;
         this._scene = new SceneLoader();
         this._volumeManager = new VolumeManager();
         this._roomGrid = new RoomGrid();
         this._scrollOffset = new Point(0,0);
         this._stageMin = new Point(0,0);
         this._stageMax = new Point(0,0);
         this._sfxMediaHelpers = [];
         this._parentIndices = new Dictionary();
         gMainFrame.stage.addEventListener(RoomEvent.LOAD_SFX,this.onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener(RoomEvent.PLAY_SFX,this.onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener(RoomEvent.PLAY_SWFSFX,this.onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener(RoomEvent.PLAY_SWFSFXBYCLASS,this.onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener(RoomEvent.ATTACH_EMOTE,this.onRoomEvent,false,0,true);
      }
      
      public function destroy() : void
      {
         gMainFrame.stage.removeEventListener(RoomEvent.LOAD_SFX,this.onRoomEvent);
         gMainFrame.stage.removeEventListener(RoomEvent.PLAY_SFX,this.onRoomEvent);
         gMainFrame.stage.removeEventListener(RoomEvent.PLAY_SWFSFX,this.onRoomEvent);
         gMainFrame.stage.removeEventListener(RoomEvent.PLAY_SWFSFXBYCLASS,this.onRoomEvent);
         gMainFrame.stage.removeEventListener(RoomEvent.ATTACH_EMOTE,this.onRoomEvent);
      }
      
      public function exitRoom() : void
      {
         this._layerManager.bkg.visible = false;
         this._persistentObject = null;
         if(this._roomMusic)
         {
            this._roomMusic.stop();
         }
         if(this._mainBackObj)
         {
            this._scrollOffset.x = 0;
            this._scrollOffset.y = 0;
            this.updateBackground();
            while(this._layerManager.room_bkg.numChildren)
            {
               this._layerManager.room_bkg.removeChildAt(0);
            }
            while(this._layerManager.room_fg.numChildren)
            {
               this._layerManager.room_fg.removeChildAt(0);
            }
            while(this._layerManager.room_bkg_main.numChildren)
            {
               this._layerManager.room_bkg_main.removeChildAt(0);
            }
            while(this._layerManager.room_avatars.numChildren)
            {
               this._layerManager.room_avatars.removeChildAt(0);
            }
            while(this._layerManager.room_chat.numChildren)
            {
               this._layerManager.room_chat.removeChildAt(0);
            }
            while(this._layerManager.room_orbs.numChildren)
            {
               this._layerManager.room_orbs.removeChildAt(0);
            }
            this._layerManager.room_avatars.release();
            this._mainBackObj = null;
            this._layers = null;
            this._assetsLoaded = false;
            this._volumeManager.release();
            this._grid = null;
            this._portals = null;
            this._spawns = null;
            this._lines = null;
            this._volumes = null;
            this._paths = null;
            this._actionPoints = null;
            this._scene.release();
         }
      }
      
      protected function loadRoom_base(param1:String, param2:Function) : void
      {
         var _loc3_:String = param1;
         this.exitRoom();
         if(gMainFrame.clientInfo.extCallsActive)
         {
            ExternalInterface.call("mrc",["sr",gMainFrame.server.getCurrentRoomName()]);
            DebugUtility.debugTrace("mrc:sr command sent - roomname:" + gMainFrame.server.getCurrentRoomName() + " fullName:" + _loc3_);
         }
         _loc3_ = _loc3_.replace(/\./g,"/");
         var _loc4_:int = _loc3_.indexOf("#");
         if(_loc4_ >= 0)
         {
            _loc3_ = _loc3_.substring(0,_loc4_);
         }
         _loc3_ += ".xroom";
         this._gaRoomName = "/game/play/room/#" + _loc3_;
         LoadProgress.load(MainFrame.ROOMS_FOLDER + _loc3_.toLowerCase(),LoadProgress.LOADING_ROOM,param2);
      }
      
      protected function onRoomLoaded_base(param1:Function) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Point = null;
         var _loc4_:Object = null;
         var _loc6_:Number = NaN;
         this._layerManager.bkg.visible = false;
         this._layerManager.bkg.x = 0;
         this._layerManager.bkg.y = 0;
         var _loc5_:Object = LoadProgress.entry.data;
         if(_loc5_ == null)
         {
            throw "error loading room:" + this._gaRoomName;
         }
         this._scene.setScene(_loc5_);
         this._scene.addEventListener(Event.COMPLETE,param1);
         this._roomSettings = this._scene.getActorList("ActorSettings")[0];
         this._stageMin.x = this._roomSettings.xmin;
         this._stageMin.y = this._roomSettings.ymin;
         this._stageMax.x = this._roomSettings.xmax;
         this._stageMax.y = this._roomSettings.ymax;
         this._grid = this._roomSettings.grid;
         this._roomGrid.setGrid(this._grid);
         if(this._roomSettings.hasOwnProperty("music") && this._gaRoomName.indexOf("player_den") == -1)
         {
            if(this._roomSettings.hasOwnProperty("musicVol") && this._roomSettings.musicVol >= 0 && this._roomSettings.musicVol <= 100)
            {
               _loc6_ = this._roomSettings.musicVol / 100;
            }
            else
            {
               _loc6_ = 0.5;
            }
            this.playMusicTrack(this._roomSettings.music,_loc6_);
         }
         this._layers = this._scene.getActorList("ActorLayer");
         _loc2_ = 0;
         while(_loc2_ < this._layers.length)
         {
            _loc4_ = this._layers[_loc2_];
            if(_loc4_.layer == 0)
            {
               this._layerManager.room_avatars.x = _loc4_.x;
               this._layerManager.room_avatars.y = _loc4_.y;
               this._layerManager.room_bkg_main.x = _loc4_.x;
               this._layerManager.room_bkg_main.y = _loc4_.y;
               this._layerManager.room_chat.x = _loc4_.x;
               this._layerManager.room_chat.y = _loc4_.y;
               this._layerManager.room_orbs.x = _loc4_.x;
               this._layerManager.room_orbs.y = _loc4_.y;
               this._mainBackObj = _loc4_;
               break;
            }
            _loc2_++;
         }
         this._portals = this._scene.getActorList("ActorPortal");
         this._spawns = this._scene.getActorList("ActorSpawn");
         this._lines = this._scene.getActorList("ActorCollisionPoint");
         this._volumes = this._scene.getActorList("ActorVolume");
         this._actionPoints = this._scene.getActorList("ActorAction");
         this._paths = this._scene.getActorList("ActorPath");
         this._scrollOffset.x = -this._stageMin.x;
         this._scrollOffset.y = -this._stageMin.y;
         SBTracker.flush();
         SBTracker.trackPageview(this._gaRoomName);
      }
      
      protected function roomLoadComplete() : void
      {
         LoadProgress.show(false);
      }
      
      protected function sceneAssetsLoaded(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Point = null;
         var _loc5_:Rectangle = null;
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         this._scene.removeEventListener(Event.COMPLETE,this.sceneAssetsLoaded);
         _loc2_ = 0;
         while(_loc2_ < this._layers.length)
         {
            _loc6_ = this._layers[_loc2_];
            _loc6_.s.mouseEnabled = false;
            _loc6_.s.mouseChildren = false;
            _loc7_ = this._layerManager.room_avatars;
            _loc6_.width = _loc6_.s.width;
            _loc6_.height = _loc6_.s.height;
            switch(_loc6_.layer)
            {
               case 0:
                  _loc6_.pIndex = this._layerManager.room_bkg.numChildren;
                  this._parentIndices[_loc6_.s] = _loc6_.pIndex;
                  this._layerManager.room_bkg.addChild(_loc6_.s);
                  break;
               case 1:
                  _loc7_.addChild(_loc6_.s);
                  break;
               case 2:
                  _loc6_.pIndex = this._layerManager.room_fg.numChildren;
                  this._parentIndices[_loc6_.s] = _loc6_.pIndex;
                  this._layerManager.room_fg.addChild(_loc6_.s);
            }
            _loc2_++;
         }
         if(this._portals)
         {
            _loc2_ = 0;
            while(_loc2_ < this._portals.length)
            {
               _loc6_ = this._portals[_loc2_];
               if(_loc6_.type == 1)
               {
                  _loc3_ = 0;
                  while(_loc3_ < this._layers.length)
                  {
                     _loc8_ = this._layers[_loc3_];
                     if(_loc8_.name == _loc6_["goto"])
                     {
                        _loc8_.s.parent.removeChild(_loc8_.s);
                        _loc8_.excludeFromCull = 1;
                        break;
                     }
                     _loc3_++;
                  }
               }
               _loc2_++;
            }
         }
         _loc2_ = 0;
         while(_loc2_ < this._layers.length)
         {
            _loc6_ = this._layers[_loc2_];
            if(_loc6_.layer)
            {
               _loc4_ = new Point(_loc6_.x,_loc6_.y);
               this.convertToWorldSpace(_loc4_);
               this.setLayerMatrix(_loc6_,_loc4_.x,_loc4_.y);
            }
            if(_loc6_.typeIndex == 1 || _loc6_.typeIndex == 2)
            {
               _loc6_.excludeFromCull = 1;
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this._layers.length)
         {
            _loc6_ = this._layers[_loc2_];
            _loc5_ = _loc6_.s.getBounds(_loc6_.s.parent);
            _loc6_.offsetX = _loc5_.left - _loc6_.s.x;
            _loc6_.offsetY = _loc5_.top - _loc6_.s.y;
            _loc2_++;
         }
         this._assetsLoaded = true;
         this.updateBackground();
         this._volumeManager.setScene(this._scene,new Point(this._mainBackObj.x,this._mainBackObj.y));
         this._layerManager.bkg.visible = true;
         if(ENABLE_DEBUG_DRAW)
         {
            this.drawDebugLayer();
         }
      }
      
      public function findSpawn(param1:Array, param2:String) : Object
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         if(param1 == null)
         {
            param1 = this._spawns;
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
         if(this._layers != null)
         {
            while(_loc3_ < this._layers.length)
            {
               if(this._layers[_loc3_].name == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = new Array();
                  }
                  _loc2_.push(this._layers[_loc3_]);
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
         if(!this._roomMusic)
         {
            if(this._persistentObject)
            {
               this._persistentObject.muteChanged(true);
            }
            this._roomMusic = new SBMusic(param1,true,param2);
         }
         else
         {
            this._roomMusic.stop();
            this._roomMusic.playNewMusic(param1,true,param2);
         }
         if(Boolean(this._roomMusic) && SBAudio.isMusicMuted)
         {
            this._roomMusic.toggleMute();
         }
      }
      
      protected function playPreviousMusicTrack() : void
      {
         if(this._roomMusic)
         {
            this._roomMusic.stop();
            if(this._roomMusic.previouslyPlayedFilename == null || this._roomMusic.previouslyPlayedFilename == "")
            {
               if(this._persistentObject)
               {
                  this._roomMusic = null;
                  this._persistentObject.muteChanged(SBAudio.isMusicMuted);
               }
               return;
            }
            this._roomMusic.playNewMusic(this._roomMusic.previouslyPlayedFilename,true,this._roomMusic.previousVolume);
            if(SBAudio.isMusicMuted)
            {
               this._roomMusic.toggleMute();
            }
         }
      }
      
      public function debugAudioVolumeChanged(param1:Number) : void
      {
         if(this._roomMusic)
         {
            this._roomMusic.volume = param1;
         }
      }
      
      private function onRoomEvent(param1:RoomEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         switch(param1.type)
         {
            case RoomEvent.LOAD_SFX:
               _loc3_ = int(param1.secondaryType);
               if(_loc3_ > 0)
               {
                  this.loadRoomEventSfx(int(param1.secondaryType));
               }
               break;
            case RoomEvent.PLAY_SFX:
               this.playRoomEventSfx(param1.secondaryType);
               break;
            case RoomEvent.PLAY_SWFSFX:
               _loc2_ = this._scene.getLayer(param1.secondaryType);
               if(_loc2_)
               {
                  if(!SBAudio.isMusicMuted)
                  {
                     _loc2_.loader.content.playSound(param1.tertiaryType);
                  }
                  if(param1.persistent)
                  {
                     this._persistentObject = _loc2_.loader.content;
                     this._roomMusic = null;
                  }
               }
               break;
            case RoomEvent.PLAY_SWFSFXBYCLASS:
               if(!SBAudio.isMusicMuted)
               {
                  param1.target.playSound();
               }
               break;
            case RoomEvent.ATTACH_EMOTE:
               AvatarManager.setPlayerAttachmentEmot(parseInt(param1.secondaryType));
         }
      }
      
      public function loadRoomEventSfx(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(param1,this.onSfxLoaded,true);
         this._sfxMediaHelpers[param1] = _loc2_;
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
         var _loc6_:String = null;
         var _loc2_:Array = getDefinitionNames(param1.loaderInfo);
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc4_];
            if((Boolean(_loc6_)) && _loc6_ != "")
            {
               SBAudio.addCachedSound(_loc6_,param1.loaderInfo.applicationDomain.getDefinition(_loc6_) as Class);
            }
            _loc4_++;
         }
         var _loc5_:int = int(param1.mediaHelper.id);
         this._sfxMediaHelpers[_loc5_].destroy();
         delete this._sfxMediaHelpers[_loc5_];
      }
      
      public function collisionTestGrid(param1:int, param2:int) : uint
      {
         if(!this._mainBackObj)
         {
            return 0;
         }
         var _loc3_:Object = this._roomGrid.convertWorldPosToGrid(param1 + this._mainBackObj.x,param2 + this._mainBackObj.y);
         return this._roomGrid.testGridCell(_loc3_.x,_loc3_.y);
      }
      
      public function enableVolume(param1:String, param2:Boolean) : void
      {
         this._roomGrid.enableVolume(param1,param2);
      }
      
      protected function scrollRoom(param1:Point, param2:int) : void
      {
         var _loc3_:Number = param1.x;
         var _loc4_:Number = param1.y;
         var _loc5_:Number = this.calcScrollAmount(_loc3_,this._layerManager.bkg.scaleX,400,MainFrame.VIEW_WIDTH,this._mainBackObj.dx,param2,gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST);
         var _loc6_:Number = this.calcScrollAmount(_loc4_,this._layerManager.bkg.scaleY,250,MainFrame.VIEW_HEIGHT,this._mainBackObj.dy,param2,gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST);
         this._scrollOffset.x += _loc5_;
         this._scrollOffset.y += _loc6_;
         if(Boolean(_loc5_) || Boolean(_loc6_))
         {
            this.updateBackground();
         }
      }
      
      protected function calcScrollAmount(param1:Number, param2:Number, param3:int, param4:int, param5:Number, param6:int, param7:Boolean = true) : Number
      {
         var _loc8_:Number = 0;
         var _loc9_:int = param6 * 1.5;
         var _loc10_:Number = param3 - param1;
         var _loc11_:Number = param1 - (param4 - param3);
         if(param7)
         {
            param6 = Math.max(_loc11_,_loc10_);
         }
         if(_loc11_ > 0)
         {
            _loc8_ = param6;
            if(_loc11_ < _loc8_)
            {
               _loc8_ = _loc11_;
            }
            _loc8_ *= -1;
         }
         else if(_loc10_ > 0)
         {
            _loc8_ = param6;
            if(_loc10_ < _loc8_)
            {
               _loc8_ = _loc10_;
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
      
      protected function updateBackground() : void
      {
         var _loc1_:Point = null;
         var _loc2_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Object = null;
         var _loc3_:Number = this._scrollOffset.x;
         var _loc4_:Number = this._scrollOffset.y;
         if(_loc4_ > -this._stageMin.y)
         {
            _loc4_ = -this._stageMin.y;
         }
         else if(_loc4_ < -this._stageMax.y)
         {
            _loc4_ = -this._stageMax.y;
         }
         if(_loc3_ > -this._stageMin.x)
         {
            _loc3_ = -this._stageMin.x;
         }
         else if(_loc3_ < -this._stageMax.x)
         {
            _loc3_ = -this._stageMax.x;
         }
         this._scrollOffset.x = _loc3_;
         this._scrollOffset.y = _loc4_;
         _loc2_ = 0;
         while(_loc2_ < this._layers.length)
         {
            _loc7_ = this._layers[_loc2_];
            if(_loc7_.layer != 1)
            {
               _loc5_ = _loc7_.x + _loc3_ * _loc7_.dx;
               _loc6_ = _loc7_.y + _loc4_ * _loc7_.dy;
               if(_loc7_.s == this._mainBackObj.s)
               {
                  this._layerManager.room_bkg_group.x = _loc5_ - _loc7_.x;
                  this._layerManager.room_bkg_group.y = _loc6_ - _loc7_.y;
                  this._layerManager.room_chat.x = _loc5_;
                  this._layerManager.room_chat.y = _loc6_;
                  this._layerManager.room_orbs.x = _loc5_;
                  this._layerManager.room_orbs.y = _loc6_;
               }
               this.setLayerMatrix(_loc7_,_loc5_,_loc6_);
            }
            if(this._assetsLoaded && _loc7_.excludeFromCull != 1)
            {
               this.checkStageValidity(_loc7_);
            }
            _loc2_++;
         }
      }
      
      protected function checkStageValidity(param1:Object) : void
      {
         var _loc6_:Sprite = null;
         var _loc2_:int = 0;
         var _loc3_:int = 900;
         var _loc4_:int = 0;
         var _loc5_:int = 550;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1.layer == 1)
         {
            _loc6_ = this._layerManager.room_avatars;
            _loc7_ = _loc6_.parent.x;
            _loc8_ = _loc6_.parent.y;
         }
         else
         {
            _loc6_ = this._layerManager.room_bkg;
         }
         _loc7_ += param1.offsetX;
         _loc8_ += param1.offsetY;
         var _loc9_:Number = this._layerManager.bkg.scaleX;
         var _loc10_:int = (param1.s.x + _loc6_.x + _loc7_) * _loc9_;
         var _loc11_:int = (param1.s.x + param1.width + _loc6_.x + _loc7_) * _loc9_;
         var _loc12_:int = (param1.s.y + _loc6_.y + _loc8_) * _loc9_;
         var _loc13_:int = (param1.s.y + param1.height + _loc6_.y + _loc8_) * _loc9_;
         if(!(_loc5_ < _loc12_ || _loc4_ > _loc13_ || _loc3_ < _loc10_ || _loc2_ > _loc11_))
         {
            if(param1.s.parent == null)
            {
               this.insertOrdered(param1);
            }
         }
         else if(param1.s.parent)
         {
            param1.s.parent.removeChild(param1.s);
         }
      }
      
      private function insertOrdered(param1:Object) : void
      {
         var _loc2_:Sprite = null;
         var _loc4_:Object = null;
         var _loc3_:Boolean = false;
         if(param1.layer == 0)
         {
            _loc2_ = this._layerManager.room_bkg;
         }
         else if(param1.layer == 1)
         {
            _loc2_ = this._layerManager.room_avatars;
            _loc3_ = true;
         }
         else
         {
            _loc2_ = this._layerManager.room_fg;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.numChildren)
         {
            _loc4_ = _loc2_.getChildAt(_loc5_);
            if(this._parentIndices[_loc4_] > param1.pIndex)
            {
               break;
            }
            _loc5_++;
         }
         if(_loc3_)
         {
            _loc2_.addChild(param1.s);
         }
         else
         {
            _loc2_.addChildAt(param1.s,_loc5_);
         }
      }
      
      protected function setLayerMatrix(param1:Object, param2:Number, param3:Number) : void
      {
         var _loc4_:Matrix = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(!param1.flip)
         {
            param1.s.x = param2;
            param1.s.y = param3;
         }
         else
         {
            _loc4_ = param1.s.transform.matrix;
            _loc4_.identity();
            _loc5_ = Number(param1.scaleX);
            _loc6_ = Number(param1.scaleY);
            _loc7_ = param2;
            _loc8_ = param3;
            if(param1.flip & 1)
            {
               _loc5_ *= -1;
               _loc7_ += param1.width;
            }
            if(param1.flip & 2)
            {
               _loc6_ *= -1;
               _loc8_ += param1.height;
            }
            _loc4_.scale(_loc5_,_loc6_);
            _loc4_.translate(_loc7_,_loc8_);
            param1.s.transform.matrix = _loc4_;
         }
      }
      
      public function convertToWorldSpace(param1:Point) : void
      {
         if(this._mainBackObj)
         {
            param1.x -= this._mainBackObj.x;
            param1.y -= this._mainBackObj.y;
         }
      }
      
      public function convertScreenToWorldSpace(param1:int, param2:int) : Point
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._mainBackObj)
         {
            _loc3_ = (param1 - this._layerManager.bkg.x) / this._layerManager.bkg.scaleX - (this._mainBackObj.x + this._mainBackObj.dx * this._scrollOffset.x);
            _loc4_ = (param2 - this._layerManager.bkg.y) / this._layerManager.bkg.scaleY - (this._mainBackObj.y + this._mainBackObj.dy * this._scrollOffset.y);
         }
         return new Point(_loc3_,_loc4_);
      }
      
      public function convertWorldToScreen(param1:int, param2:int) : Point
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._mainBackObj)
         {
            _loc3_ = param1 + (this._mainBackObj.x + this._mainBackObj.dx * this._scrollOffset.x) * this._layerManager.bkg.scaleX + this._layerManager.bkg.x;
            _loc4_ = param2 + (this._mainBackObj.y + this._mainBackObj.dy * this._scrollOffset.y) * this._layerManager.bkg.scaleY + this._layerManager.bkg.y;
         }
         return new Point(_loc3_,_loc4_);
      }
      
      public function bkgScalePoint() : Point
      {
         return new Point(this._layerManager.bkg.scaleX,this._layerManager.bkg.scaleY);
      }
      
      protected function getRandomRadiusOffset(param1:Number) : Point
      {
         var _loc2_:Point = new Point();
         var _loc3_:Number = Math.random() * (2 * Math.PI);
         param1 = Math.random() * param1;
         _loc2_.x = Math.cos(_loc3_) * param1;
         _loc2_.y = Math.sin(_loc3_) * param1;
         return _loc2_;
      }
      
      public function convertPathToWorldSpace() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:Point = null;
         if(this._paths)
         {
            _loc1_ = 0;
            while(_loc1_ < this._paths.length)
            {
               _loc2_ = this._paths[_loc1_];
               _loc3_ = 0;
               while(_loc3_ < _loc2_.points.length)
               {
                  if(_loc2_.points[_loc3_])
                  {
                     _loc4_ = new Point(_loc2_.points[_loc3_].x,_loc2_.points[_loc3_].y);
                     this.convertToWorldSpace(_loc4_);
                     _loc2_.points[_loc3_].x = _loc4_.x;
                     _loc2_.points[_loc3_].y = _loc4_.y;
                  }
                  _loc3_++;
               }
               _loc1_++;
            }
         }
      }
      
      public function findPathByName(param1:String) : Object
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this._paths)
         {
            param1.toLowerCase();
            _loc2_ = 0;
            while(_loc2_ < this._paths.length)
            {
               _loc3_ = this._paths[_loc2_];
               if(_loc3_.name == param1)
               {
                  return _loc3_;
               }
               _loc2_++;
            }
         }
         return null;
      }
      
      protected function drawDebugLayer(param1:Vector.<int> = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc11_:* = undefined;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:int = 0;
         var _loc15_:Object = null;
         this._layerManager.debugShape.x = -this._mainBackObj.x;
         this._layerManager.debugShape.y = -this._mainBackObj.y;
         this._layerManager.room_bkg_main.addChild(this._layerManager.debugShape);
         var _loc7_:Graphics = this._layerManager.debugShape.graphics;
         _loc7_.clear();
         var _loc8_:Number = 0.2;
         if(this._portals)
         {
            _loc7_.beginFill(16711680,_loc8_);
            _loc2_ = 0;
            while(_loc2_ < this._portals.length)
            {
               _loc6_ = this._portals[_loc2_];
               _loc7_.drawCircle(_loc6_.x,_loc6_.y,_loc6_.r);
               if(_loc6_.type == 1)
               {
                  _loc3_ = 0;
                  while(_loc3_ < this._layers.length)
                  {
                     _loc10_ = this._layers[_loc3_];
                     if(_loc10_.name == _loc6_["goto"])
                     {
                        break;
                     }
                     _loc3_++;
                  }
                  if(_loc10_)
                  {
                     _loc11_ = _loc10_.s.content;
                     if(_loc11_)
                     {
                        _loc3_ = 0;
                        while(_loc3_ < _loc11_.totalFrames)
                        {
                           _loc11_.gotoAndStop(_loc3_);
                           _loc4_ = _loc11_.player.x + _loc10_.x;
                           _loc5_ = _loc11_.player.y + _loc10_.y;
                           _loc7_.drawCircle(_loc4_,_loc5_,10);
                           _loc3_++;
                        }
                     }
                  }
               }
               _loc2_++;
            }
         }
         _loc7_.endFill();
         _loc7_.beginFill(65280,_loc8_);
         _loc2_ = 0;
         while(_loc2_ < this._spawns.length)
         {
            _loc6_ = this._spawns[_loc2_];
            _loc7_.drawCircle(_loc6_.x,_loc6_.y,_loc6_.r);
            _loc2_++;
         }
         _loc7_.endFill();
         if(this._actionPoints)
         {
            _loc7_.beginFill(255,_loc8_);
            _loc2_ = 0;
            while(_loc2_ < this._actionPoints.length)
            {
               _loc6_ = this._actionPoints[_loc2_];
               _loc7_.drawCircle(_loc6_.x,_loc6_.y,_loc6_.r);
               _loc2_++;
            }
            _loc7_.endFill();
         }
         if(this._lines)
         {
            _loc7_.lineStyle(2,16777215);
            _loc2_ = 0;
            while(_loc2_ < this._lines.length)
            {
               _loc6_ = this._lines[_loc2_];
               _loc7_.moveTo(_loc6_.x,_loc6_.y);
               _loc7_.lineTo(_loc6_.x1,_loc6_.y1);
               _loc2_++;
            }
         }
         if(this._paths)
         {
            _loc7_.lineStyle(2,255);
            _loc2_ = 0;
            while(_loc2_ < this._paths.length)
            {
               _loc6_ = this._paths[_loc2_];
               _loc3_ = 0;
               while(_loc3_ < _loc6_.points.length)
               {
                  _loc9_ = _loc6_.points[_loc3_];
                  if(_loc3_ == 0)
                  {
                     _loc7_.moveTo(_loc9_.x,_loc9_.y);
                  }
                  else
                  {
                     _loc7_.lineTo(_loc9_.x,_loc9_.y);
                  }
                  _loc3_++;
               }
               _loc2_++;
            }
         }
         if(this._volumes)
         {
            _loc7_.lineStyle(2,255);
            _loc2_ = 0;
            while(_loc2_ < this._volumes.length)
            {
               _loc6_ = this._volumes[_loc2_];
               _loc3_ = 0;
               while(_loc3_ < _loc6_.points.length)
               {
                  _loc9_ = _loc6_.points[_loc3_];
                  if(_loc3_ == 0)
                  {
                     _loc7_.moveTo(_loc9_.x,_loc9_.y);
                  }
                  else
                  {
                     _loc7_.lineTo(_loc9_.x,_loc9_.y);
                  }
                  _loc3_++;
               }
               _loc2_++;
            }
         }
         if(this._grid)
         {
            _loc12_ = this._grid.min.y + this._grid.r;
            _loc5_ = 0;
            while(_loc5_ < this._grid.height)
            {
               _loc13_ = this._grid.min.x + this._grid.r;
               _loc4_ = 0;
               while(_loc4_ < this._grid.width)
               {
                  _loc7_.lineStyle(2,0);
                  _loc14_ = int(this._grid.grid[_loc4_ + _loc5_ * this._grid.width]);
                  if(_loc14_)
                  {
                     _loc7_.beginFill(_loc14_ == 1 ? 16776960 : 255,0.9);
                  }
                  _loc7_.drawRect(_loc13_ - this._grid.r,_loc12_ - this._grid.r,this._grid.r2,this._grid.r2);
                  _loc7_.endFill();
                  _loc13_ += this._grid.r2;
                  _loc4_++;
               }
               _loc12_ += this._grid.r2;
               _loc5_++;
            }
            if(param1)
            {
               _loc2_ = 0;
               while(_loc2_ < param1.length)
               {
                  _loc15_ = this._roomGrid.getCellIndexToWorldPos(param1[_loc2_]);
                  _loc7_.beginFill(16711680,0.75);
                  _loc7_.drawRect(_loc15_.x - this._grid.r,_loc15_.y - this._grid.r,this._grid.r2,this._grid.r2);
                  _loc7_.endFill();
                  _loc2_++;
               }
            }
         }
      }
   }
}

