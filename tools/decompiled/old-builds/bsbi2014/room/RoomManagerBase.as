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
         return this._volumeManager;
      }
      
      public function get layerManager() : LayerManager
      {
         return this._layerManager;
      }
      
      public function get scrollOffset() : Point
      {
         return this._scrollOffset;
      }
      
      public function init(layerManager:LayerManager) : void
      {
         this._layerManager = layerManager;
         this._scene = new SceneLoader(LoadProgress.show);
         this._volumeManager = new VolumeManager();
         this._roomGrid = new RoomGrid();
         this._scrollOffset = new Point(0,0);
         this._stageMin = new Point(0,0);
         this._stageMax = new Point(0,0);
         this._sfxMediaHelpers = [];
         this._objectSwapper = new Object();
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
      
      public function exitRoom(isLoadingDenPreview:Boolean = false) : void
      {
         this._layerManager.bkg.visible = false;
         this._persistentObject = null;
         if(Boolean(this._roomMusic) && !isLoadingDenPreview)
         {
            this._roomMusic.stop();
         }
         if(Boolean(this._mainBackObj))
         {
            this._assetsLoaded = false;
            this._scrollOffset.x = 0;
            this._scrollOffset.y = 0;
            this.updateBackground(true);
            while(Boolean(this._layerManager.room_bkg.numChildren))
            {
               this._layerManager.room_bkg.removeChildAt(0);
            }
            while(Boolean(this._layerManager.room_fg.numChildren))
            {
               this._layerManager.room_fg.removeChildAt(0);
            }
            while(Boolean(this._layerManager.room_super_fg.numChildren))
            {
               this._layerManager.room_super_fg.removeChildAt(0);
            }
            while(Boolean(this._layerManager.room_bkg_main.numChildren))
            {
               this._layerManager.room_bkg_main.removeChildAt(0);
            }
            if(!isLoadingDenPreview)
            {
               while(Boolean(this._layerManager.room_avatars.numChildren))
               {
                  this._layerManager.room_avatars.removeChildAt(0);
               }
               while(Boolean(this._layerManager.flying_avatars.numChildren))
               {
                  this._layerManager.flying_avatars.removeChildAt(0);
               }
               while(Boolean(this._layerManager.preview_room_avatar.numChildren))
               {
                  this._layerManager.preview_room_avatar.removeChildAt(0);
               }
               while(Boolean(this._layerManager.preview_room_flying_avatar.numChildren))
               {
                  this._layerManager.preview_room_flying_avatar.removeChildAt(0);
               }
               while(Boolean(this._layerManager.room_chat.numChildren))
               {
                  this._layerManager.room_chat.removeChildAt(0);
               }
            }
            while(Boolean(this._layerManager.room_orbs.numChildren))
            {
               this._layerManager.room_orbs.removeChildAt(0);
            }
            if(Boolean(this._buckets))
            {
               this._buckets = null;
            }
            if(!isLoadingDenPreview)
            {
               this._layerManager.room_avatars.release();
            }
            this._mainBackObj = null;
            this._layers = null;
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
      
      protected function loadRoom_base(pathname:String, callback:Function, isLoadingDenPreview:Boolean = false) : void
      {
         var fullName:String = pathname;
         this.exitRoom(isLoadingDenPreview);
         if(Boolean(gMainFrame.clientInfo.extCallsActive))
         {
            ExternalInterface.call("mrc",["sr",gMainFrame.server.getCurrentRoomName()]);
            DebugUtility.debugTrace("mrc:sr command sent - roomname:" + gMainFrame.server.getCurrentRoomName() + " fullName:" + fullName);
         }
         fullName = fullName.replace(/\./g,"/");
         var poundIdx:int = fullName.indexOf("#");
         if(poundIdx >= 0)
         {
            fullName = fullName.substring(0,poundIdx);
         }
         fullName += ".xroom";
         this._gaRoomName = "/game/play/room/#" + fullName;
         LoadProgress.load(MainFrame.ROOMS_FOLDER + fullName.toLowerCase(),LoadProgress.LOADING_ROOM,callback);
      }
      
      protected function resetCurrentRoom_base(pathName:String) : void
      {
         var fullName:String = pathName;
         fullName = fullName.replace(/\./g,"/");
         var poundIdx:int = fullName.indexOf("#");
         if(poundIdx >= 0)
         {
            fullName = fullName.substring(0,poundIdx);
         }
         fullName += ".xroom";
         this._isDenPreview = false;
      }
      
      protected function onRoomLoaded_base(callback:Function, initScene:Object, isLoadingDenPreview:Boolean = false) : void
      {
         var i:int = 0;
         var pos:Point = null;
         var o:Object = null;
         var volume:Number = NaN;
         this._layerManager.bkg.visible = false;
         this._layerManager.bkg.x = 0;
         this._layerManager.bkg.y = 0;
         this._isDenPreview = isLoadingDenPreview;
         var scene:Object = initScene != null ? initScene : LoadProgress.entry.data;
         if(scene == null)
         {
            throw "error loading room:" + this._gaRoomName;
         }
         this._scene.setScene(scene);
         this._scene.addEventListener(Event.COMPLETE,callback);
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
               volume = this._roomSettings.musicVol / 100;
            }
            else
            {
               volume = 0.5;
            }
            this.playMusicTrack(this._roomSettings.music,volume);
         }
         this._layers = this._scene.getActorList("ActorLayer");
         for(i = 0; i < this._layers.length; i++)
         {
            o = this._layers[i];
            if(o.layer == 0)
            {
               this._layerManager.room_avatars.x = o.x;
               this._layerManager.room_avatars.y = o.y;
               this._layerManager.flying_avatars.x = o.x;
               this._layerManager.flying_avatars.y = o.y;
               this._layerManager.room_bkg_main.x = o.x;
               this._layerManager.room_bkg_main.y = o.y;
               this._layerManager.room_chat.x = o.x;
               this._layerManager.room_chat.y = o.y;
               this._layerManager.room_orbs.x = o.x;
               this._layerManager.room_orbs.y = o.y;
               if(isLoadingDenPreview)
               {
                  this._layerManager.preview_room_avatar.x = o.x;
                  this._layerManager.preview_room_avatar.y = o.y;
                  this._layerManager.preview_room_flying_avatar.x = o.x;
                  this._layerManager.preview_room_flying_avatar.y = o.y;
               }
               this._mainBackObj = o;
               break;
            }
         }
         this._portals = this._scene.getActorList("ActorPortal");
         this._spawns = this._scene.getActorList("ActorSpawn");
         this._lines = this._scene.getActorList("ActorCollisionPoint");
         this._volumes = this._scene.getActorList("ActorVolume");
         this._actionPoints = this._scene.getActorList("ActorAction");
         this._paths = this._scene.getActorList("ActorPath");
         this._scrollOffset.x = -this._stageMin.x;
         this._scrollOffset.y = -this._stageMin.y;
         if(!isLoadingDenPreview)
         {
            SBTracker.flush();
            SBTracker.trackPageview(this._gaRoomName);
         }
      }
      
      protected function roomLoadComplete() : void
      {
         LoadProgress.show(false);
      }
      
      protected function sceneAssetsLoaded(e:Event) : void
      {
         var i:int = 0;
         var j:int = 0;
         var pos:Point = null;
         var o:Object = null;
         var bgChildren:int = 0;
         var fgChildren:int = 0;
         var superfgChildren:int = 0;
         var sortLayer:Object = null;
         var layer:Object = null;
         var tempRect:Rectangle = null;
         this._scene.removeEventListener(Event.COMPLETE,this.sceneAssetsLoaded);
         this._assetPool = new Dictionary();
         this._parentIndices = new Dictionary();
         for(i = 0; i < this._layers.length; i++)
         {
            o = this._layers[i];
            bgChildren = this._layerManager.room_bkg.numChildren;
            fgChildren = this._layerManager.room_fg.numChildren;
            superfgChildren = this._layerManager.room_super_fg.numChildren;
            o.s.mouseEnabled = false;
            o.s.mouseChildren = false;
            sortLayer = this._layerManager.room_avatars;
            switch(o.layer)
            {
               case 0:
                  o.pIndex = bgChildren++;
                  this._parentIndices[o.s] = o.pIndex;
                  this._layerManager.room_bkg.addChild(o.s);
                  break;
               case 1:
                  sortLayer.addChild(o.s);
                  break;
               case 2:
                  o.pIndex = fgChildren++;
                  this._parentIndices[o.s] = o.pIndex;
                  this._layerManager.room_fg.addChild(o.s);
                  break;
               case 4:
                  o.pIndex = superfgChildren++;
                  this._parentIndices[o.s] = o.pIndex;
                  this._layerManager.room_super_fg.addChild(o.s);
            }
            if(o.hasOwnProperty("sortHeight"))
            {
               o.s.name = o.sortHeight;
            }
         }
         if(Boolean(this._portals))
         {
            for(i = 0; i < this._portals.length; i++)
            {
               o = this._portals[i];
               if(o.type == 1)
               {
                  for(j = 0; j < this._layers.length; j++)
                  {
                     layer = this._layers[j];
                     if(layer.name == o["goto"])
                     {
                        layer.s.parent.removeChild(layer.s);
                        layer.excludeFromCull = 1;
                        break;
                     }
                  }
               }
            }
         }
         for(i = 0; i < this._layers.length; i++)
         {
            o = this._layers[i];
            if(Boolean(o.layer))
            {
               pos = new Point(o.x,o.y);
               this.convertToWorldSpace(pos);
               this.setLayerMatrix(o,pos.x,pos.y);
            }
            if(o.typeIndex == 1 || o.typeIndex == 2 || o.dx != 1 || o.dy != 1)
            {
               o.excludeFromCull = 1;
            }
         }
         if(!this._scene._useDynamicLoading)
         {
            for(i = 0; i < this._layers.length; i++)
            {
               o = this._layers[i];
               tempRect = o.s.getBounds(o.s.parent);
               o.offsetX = tempRect.left - o.s.x;
               o.offsetY = tempRect.top - o.s.y;
            }
         }
         this._assetsLoaded = true;
         this.updateBackground();
         this._checkSurroundingAssets = true;
         this.setupBuckets();
         this._volumeManager.setScene(this._scene,new Point(this._mainBackObj.x,this._mainBackObj.y));
         this._layerManager.bkg.visible = true;
         if(!this._isDenPreview)
         {
            this._layerManager.showAvatarsAndRelatedItems(true);
         }
         else
         {
            this._layerManager.showAvatarsAndRelatedItems(false);
         }
         if(ENABLE_DEBUG_DRAW)
         {
            this.drawDebugLayer();
         }
      }
      
      private function setupBuckets() : void
      {
         var i:int = 0;
         var o:Object = null;
         var numCol:int = 0;
         var numRow:int = 0;
         var bucketW:int = 0;
         var bucketH:int = 0;
         var bi:int = 0;
         var potentialParent:Sprite = null;
         var offsetX:int = 0;
         var offsetY:int = 0;
         var scale:Number = NaN;
         var left2:int = 0;
         var right2:int = 0;
         var top2:int = 0;
         var bottom2:int = 0;
         var bj:int = 0;
         var currentBucket:Object = null;
         var staticLeft:Number = Number.MAX_VALUE;
         var staticRight:Number = Number.MIN_VALUE;
         var staticTop:Number = Number.MAX_VALUE;
         var staticBottom:Number = Number.MIN_VALUE;
         if(this._scene._useDynamicLoading && this._layers.length > 1000)
         {
            for(i = 0; i < this._layers.length; i++)
            {
               o = this._layers[i];
               offsetX = 0;
               offsetY = 0;
               if(o.layer == 1)
               {
                  potentialParent = this._layerManager.room_avatars;
                  offsetX = potentialParent.parent.x;
                  offsetY = potentialParent.parent.y;
               }
               else
               {
                  potentialParent = this._layerManager.room_bkg;
               }
               offsetX += o.offsetX;
               offsetY += o.offsetY;
               scale = this._layerManager.bkg.scaleX;
               left2 = (o.s.x + potentialParent.x + offsetX) * scale;
               right2 = (o.s.x + o.width + potentialParent.x + offsetX) * scale;
               top2 = (o.s.y + potentialParent.y + offsetY) * scale;
               bottom2 = (o.s.y + o.height + potentialParent.y + offsetY) * scale;
               o.bLeft = left2;
               o.bRight = right2;
               o.bTop = top2;
               o.bBottom = bottom2;
               if(left2 < staticLeft)
               {
                  staticLeft = left2;
               }
               if(right2 > staticRight)
               {
                  staticRight = right2;
               }
               if(top2 < staticTop)
               {
                  staticTop = top2;
               }
               if(bottom2 > staticBottom)
               {
                  staticBottom = bottom2;
               }
            }
            numCol = Math.ceil((staticRight - staticLeft) / 2700);
            numRow = Math.ceil((staticBottom - staticTop) / 2700);
            bucketW = (staticRight - staticLeft) / numCol;
            bucketH = (staticBottom - staticTop) / numRow;
            this._buckets = new Array();
            for(bi = 0; bi < numRow; bi++)
            {
               for(bj = 0; bj < numCol; bj++)
               {
                  this._buckets[numCol * bi + bj] = {
                     "x":staticLeft + bucketW * bj,
                     "y":staticTop + bucketH * bi,
                     "width":bucketW,
                     "height":bucketH,
                     "scrollOffsetX":this._scrollOffset.x,
                     "scrollOffsetY":this._scrollOffset.y
                  };
               }
            }
            for(i = 0; i < this._layers.length; i++)
            {
               o = this._layers[i];
               bj = Math.floor(((o.bRight + o.bLeft) * 0.5 - staticLeft) / bucketW);
               bi = Math.floor(((o.bBottom + o.bTop) * 0.5 - staticTop) / bucketH);
               o.bucketIndex = numCol * bi + bj;
               currentBucket = this._buckets[o.bucketIndex];
               if(o.bRight > currentBucket.x + currentBucket.width)
               {
                  currentBucket.width = o.bRight - currentBucket.x;
               }
               if(o.bLeft < currentBucket.x)
               {
                  currentBucket.width += currentBucket.x - o.bLeft;
                  currentBucket.x = o.bLeft;
               }
               if(o.bBottom > currentBucket.y + currentBucket.height)
               {
                  currentBucket.height = o.bBottom - currentBucket.y;
               }
               if(o.bTop < currentBucket.y)
               {
                  currentBucket.height += currentBucket.y - o.bTop;
                  currentBucket.y = o.bTop;
               }
               if(o.bucketIndex < 0 || o.bucketIndex >= this._buckets.length)
               {
                  throw new Error("Bucket index out of range!");
               }
            }
         }
      }
      
      public function findSpawn(a:Array, name:String) : Object
      {
         var i:int = 0;
         var o:Object = null;
         if(a == null)
         {
            a = this._spawns;
         }
         if(a != null)
         {
            while(i < a.length)
            {
               if(a[i].name == name)
               {
                  o = a[i];
                  break;
               }
               i++;
            }
         }
         return o;
      }
      
      public function findLayers(name:String) : Array
      {
         var i:int = 0;
         var outLayers:Array = null;
         if(this._layers != null)
         {
            while(i < this._layers.length)
            {
               if(this._layers[i].name == name)
               {
                  if(outLayers == null)
                  {
                     outLayers = new Array();
                  }
                  outLayers.push(this._layers[i]);
               }
               i++;
            }
         }
         return outLayers;
      }
      
      protected function playMusicTrack(filename:String, volume:Number) : void
      {
         if(filename == null || filename == "")
         {
            return;
         }
         if(!this._roomMusic)
         {
            if(Boolean(this._persistentObject))
            {
               this._persistentObject.muteChanged(true);
            }
            this._roomMusic = new SBMusic(filename,true,volume);
         }
         else
         {
            this._roomMusic.stop();
            this._roomMusic.playNewMusic(filename,true,volume);
         }
         if(Boolean(this._roomMusic) && SBAudio.isMusicMuted)
         {
            this._roomMusic.toggleMute();
         }
      }
      
      protected function playPreviousMusicTrack() : void
      {
         if(Boolean(this._roomMusic))
         {
            this._roomMusic.stop();
            if(this._roomMusic.previouslyPlayedFilename == null || this._roomMusic.previouslyPlayedFilename == "")
            {
               if(Boolean(this._persistentObject))
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
      
      public function debugAudioVolumeChanged(newVolume:Number) : void
      {
         if(Boolean(this._roomMusic))
         {
            this._roomMusic.volume = newVolume;
         }
      }
      
      private function onRoomEvent(evt:RoomEvent) : void
      {
         var o:Object = null;
         var sfxMediaId:int = 0;
         switch(evt.type)
         {
            case RoomEvent.LOAD_SFX:
               sfxMediaId = int(evt.secondaryType);
               if(sfxMediaId > 0)
               {
                  this.loadRoomEventSfx(int(evt.secondaryType));
               }
               break;
            case RoomEvent.PLAY_SFX:
               this.playRoomEventSfx(evt.secondaryType);
               break;
            case RoomEvent.PLAY_SWFSFX:
               o = this._scene.getLayer(evt.secondaryType);
               if(Boolean(o))
               {
                  if(!SBAudio.isMusicMuted)
                  {
                     o.loader.content.playSound(evt.tertiaryType);
                  }
                  if(evt.persistent)
                  {
                     this._persistentObject = o.loader.content;
                     this._roomMusic = null;
                  }
               }
               break;
            case RoomEvent.PLAY_SWFSFXBYCLASS:
               if(!SBAudio.isMusicMuted)
               {
                  evt.target.playSound();
               }
               break;
            case RoomEvent.ATTACH_EMOTE:
               AvatarManager.setPlayerAttachmentEmot(parseInt(evt.secondaryType));
         }
      }
      
      public function loadRoomEventSfx(mediaId:int) : void
      {
         var sfxMediaHelper:MediaHelper = null;
         if(this._sfxMediaHelpers[mediaId] == null)
         {
            sfxMediaHelper = new MediaHelper();
            sfxMediaHelper.init(mediaId,this.onSfxLoaded,true);
            this._sfxMediaHelpers[mediaId] = sfxMediaHelper;
         }
      }
      
      private function playRoomEventSfx(name:String) : void
      {
         if(name != "aj_water_fs1" && name != "aj_water_fs2" && name != "aj_water_fs3")
         {
            SBAudio.playCachedSound(name);
         }
      }
      
      private function onSfxLoaded(sfxMC:MovieClip) : void
      {
         var sfxClassName:String = null;
         var libraryAssetNames:Array = getDefinitionNames(sfxMC.loaderInfo);
         var sfxClasses:Array = [];
         for(var i:int = 0; i < libraryAssetNames.length; i++)
         {
            sfxClassName = libraryAssetNames[i];
            if(Boolean(sfxClassName) && sfxClassName != "")
            {
               SBAudio.addCachedSound(sfxClassName,sfxMC.loaderInfo.applicationDomain.getDefinition(sfxClassName) as Class);
            }
         }
         var index:int = int(sfxMC.mediaHelper.id);
         this._sfxMediaHelpers[index].destroy();
         delete this._sfxMediaHelpers[index];
      }
      
      public function collisionTestGrid(x:int, y:int) : uint
      {
         if(!this._mainBackObj)
         {
            return 0;
         }
         var gridXY:Object = this._roomGrid.convertWorldPosToGrid(x + this._mainBackObj.x,y + this._mainBackObj.y);
         return this._roomGrid.testGridCell(gridXY.x,gridXY.y);
      }
      
      public function enableVolume(volumeName:String, bEnable:Boolean) : void
      {
         this._roomGrid.enableVolume(volumeName,bEnable);
         this._volumeManager.setVolumesEnabled(volumeName,bEnable);
      }
      
      public function rebuildGrid() : void
      {
         if(this._grid.hasOwnProperty("packedGrid"))
         {
            this._grid.packedGrid.position = 0;
         }
         this._roomGrid.setGrid(this._grid);
      }
      
      protected function scrollRoom(gp:Point, amount:int) : void
      {
         var playerX:Number = gp.x;
         var playerY:Number = gp.y;
         var scrollX:Number = this.calcScrollAmount(playerX,this._layerManager.bkg.scaleX,400,MainFrame.VIEW_WIDTH,this._mainBackObj.dx,amount,gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST);
         var scrollY:Number = this.calcScrollAmount(playerY,this._layerManager.bkg.scaleY,250,MainFrame.VIEW_HEIGHT,this._mainBackObj.dy,amount,gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST);
         this._scrollOffset.x += scrollX;
         this._scrollOffset.y += scrollY;
         if(Boolean(scrollX) || Boolean(scrollY))
         {
            this.updateBackground();
         }
      }
      
      protected function calcScrollAmount(playerPos:Number, bkgScale:Number, border:int, screenSize:int, scale:Number, scrollAmount:int, instantMove:Boolean = true) : Number
      {
         var ret:Number = 0;
         var autoScrollAmount:int = scrollAmount * 1.5;
         var b1:Number = border - playerPos;
         var b2:Number = playerPos - (screenSize - border);
         if(instantMove)
         {
            scrollAmount = Math.max(b2,b1);
         }
         if(b2 > 0)
         {
            ret = scrollAmount;
            if(b2 < ret)
            {
               ret = b2;
            }
            ret *= -1;
         }
         else if(b1 > 0)
         {
            ret = scrollAmount;
            if(b1 < ret)
            {
               ret = b1;
            }
         }
         if(Boolean(scale))
         {
            ret /= scale;
         }
         if(ret != 0 && bkgScale != 1)
         {
            ret /= bkgScale;
         }
         return ret;
      }
      
      protected function updateBackground(isFromRoomExit:Boolean = false) : void
      {
         var pos:Point = null;
         var i:int = 0;
         var x1:Number = NaN;
         var y1:Number = NaN;
         var obj:Object = null;
         var x:Number = this._scrollOffset.x;
         var y:Number = this._scrollOffset.y;
         if(y > -this._stageMin.y)
         {
            y = -this._stageMin.y;
         }
         else if(y < -this._stageMax.y)
         {
            y = -this._stageMax.y;
         }
         if(x > -this._stageMin.x)
         {
            x = -this._stageMin.x;
         }
         else if(x < -this._stageMax.x)
         {
            x = -this._stageMax.x;
         }
         this._scrollOffset.x = x;
         this._scrollOffset.y = y;
         if(Boolean(this._buckets))
         {
            this.setActiveBuckets();
         }
         var assetsLoading:uint = 0;
         for(i = 0; i < this._layers.length; i++)
         {
            obj = this._layers[i];
            if(obj.layer != 1)
            {
               x1 = obj.x + x * obj.dx;
               y1 = obj.y + y * obj.dy;
               if(obj.s == this._mainBackObj.s)
               {
                  this._layerManager.room_bkg_group.x = x1 - obj.x;
                  this._layerManager.room_bkg_group.y = y1 - obj.y;
                  this._layerManager.room_chat.x = x1;
                  this._layerManager.room_chat.y = y1;
                  this._layerManager.flying_avatars.x = x1;
                  this._layerManager.flying_avatars.y = y1;
                  this._layerManager.room_orbs.x = x1;
                  this._layerManager.room_orbs.y = y1;
                  this._layerManager.preview_room_flying_avatar.x = x1;
                  this._layerManager.preview_room_flying_avatar.y = y1;
               }
               if(!obj.flip)
               {
                  obj.s.x = x1;
                  obj.s.y = y1;
               }
               else
               {
                  this.setLayerMatrix(obj,x1,y1);
               }
            }
            if(this._assetsLoaded && obj.excludeFromCull != 1 && Boolean(obj.s))
            {
               if(!this._buckets || Boolean(this._buckets[obj.bucketIndex].active))
               {
                  assetsLoading += this.checkStageValidity(obj);
               }
            }
         }
         if(!isFromRoomExit && this._checkSurroundingAssets && assetsLoading == 0)
         {
            this._scene.forceLoadComplete();
            this._checkSurroundingAssets = false;
         }
      }
      
      private function setActiveBuckets() : void
      {
         var bucket:Object = null;
         var left2:int = 0;
         var right2:int = 0;
         var top2:int = 0;
         var bottom2:int = 0;
         var left1:int = -100;
         var right1:int = 1000;
         var top1:int = -100;
         var bottom1:int = 650;
         var bucketIndex:int = 0;
         var scale:Number = this._layerManager.bkg.scaleX;
         for(bucketIndex = 0; bucketIndex < this._buckets.length; bucketIndex++)
         {
            bucket = this._buckets[bucketIndex];
            left2 = bucket.x + (this._scrollOffset.x - bucket.scrollOffsetX) * scale;
            right2 = bucket.x + bucket.width + (this._scrollOffset.x - bucket.scrollOffsetX) * scale;
            top2 = bucket.y + (this._scrollOffset.y - bucket.scrollOffsetY) * scale;
            bottom2 = bucket.y + bucket.height + (this._scrollOffset.y - bucket.scrollOffsetY) * scale;
            bucket.active = !(bottom1 < top2 || top1 > bottom2 || right1 < left2 || left1 > right2);
         }
      }
      
      protected function checkStageValidity(o:Object) : uint
      {
         var potentialParent:Sprite = null;
         var poolAsset:Object = null;
         var index:int = 0;
         var returnVal:uint = 0;
         var left1:int = -100;
         var right1:int = 1000;
         var top1:int = -100;
         var bottom1:int = 650;
         var offsetX:int = 0;
         var offsetY:int = 0;
         if(o.layer == 1)
         {
            potentialParent = this._layerManager.room_avatars;
            offsetX = potentialParent.parent.x;
            offsetY = potentialParent.parent.y;
         }
         else
         {
            potentialParent = this._layerManager.room_bkg;
         }
         offsetX += o.offsetX;
         offsetY += o.offsetY;
         var scale:Number = this._layerManager.bkg.scaleX;
         var left2:int = (o.s.x + potentialParent.x + offsetX) * scale;
         var right2:int = (o.s.x + o.width + potentialParent.x + offsetX) * scale;
         var top2:int = (o.s.y + potentialParent.y + offsetY) * scale;
         var bottom2:int = (o.s.y + o.height + potentialParent.y + offsetY) * scale;
         var pool:Array = this._assetPool[o.assetName];
         if(!(bottom1 < top2 || top1 > bottom2 || right1 < left2 || left1 > right2))
         {
            if(o.loaded == SceneLoader.LOAD_STATE_NOTLOADED)
            {
               if(Boolean(pool) && pool.length > 0)
               {
                  poolAsset = pool.pop();
                  this.swapObjects(o,poolAsset);
               }
               else
               {
                  this._scene.loadLayer(o);
                  returnVal = 1;
               }
            }
            if(o.s.parent == null)
            {
               if(o.layer != 1)
               {
                  this.insertOrdered(o);
               }
               else
               {
                  this._layerManager.room_avatars.addChild(o.s);
               }
               index = 0;
               if(Boolean(pool) && (index = pool.indexOf(o)) != -1)
               {
                  pool.splice(index,1);
               }
            }
         }
         else if(Boolean(o.s.parent))
         {
            o.s.parent.removeChild(o.s);
            if(o.loaded == SceneLoader.LOAD_STATE_LOADED && this._scene.isValidDynamicAsset(o))
            {
               if(pool == null)
               {
                  this._assetPool[o.assetName] = pool = new Array();
               }
               pool.push(o);
            }
         }
         return returnVal;
      }
      
      private function swapObjects(o1:Object, o2:Object) : void
      {
         this._objectSwapper.s = o1.s;
         o1.s = o2.s;
         o2.s = this._objectSwapper.s;
         this._parentIndices[o1.s] = o1.pIndex;
         this._parentIndices[o2.s] = o2.pIndex;
         this._objectSwapper.sx = o1.s.x;
         this._objectSwapper.sy = o1.s.y;
         this._objectSwapper.srotation = o1.s.rotation;
         this._objectSwapper.sscaleX = o1.s.scaleX;
         this._objectSwapper.sscaleY = o1.s.scaleY;
         this._objectSwapper.loaded = o1.loaded;
         o1.s.x = o2.s.x;
         o1.s.y = o2.s.y;
         o1.s.rotation = o2.s.rotation;
         o1.s.scaleX = o2.s.scaleX;
         o1.s.scaleY = o2.s.scaleY;
         o1.loaded = o2.loaded;
         o2.s.x = this._objectSwapper.sx;
         o2.s.y = this._objectSwapper.sy;
         o2.s.rotation = this._objectSwapper.srotation;
         o2.s.scaleX = this._objectSwapper.sscaleX;
         o2.s.scaleY = this._objectSwapper.sscaleY;
         o2.loaded = this._objectSwapper.loaded;
      }
      
      private function insertOrdered(o:Object) : void
      {
         var parentLayer:Sprite = null;
         var child:Object = null;
         if(o.layer == 0)
         {
            parentLayer = this._layerManager.room_bkg;
         }
         else if(o.layer == 4)
         {
            parentLayer = this._layerManager.room_super_fg;
         }
         else
         {
            parentLayer = this._layerManager.room_fg;
         }
         for(var i:int = 0; i < parentLayer.numChildren; i++)
         {
            child = parentLayer.getChildAt(i);
            if(this._parentIndices[child] > o.pIndex)
            {
               break;
            }
         }
         parentLayer.addChildAt(o.s,i);
      }
      
      protected function setLayerMatrix(o:Object, x:Number, y:Number) : void
      {
         var matrix:Matrix = null;
         var sx:Number = NaN;
         var sy:Number = NaN;
         var tx:Number = NaN;
         var ty:Number = NaN;
         if(!o.flip)
         {
            o.s.x = x;
            o.s.y = y;
         }
         else
         {
            matrix = o.s.transform.matrix;
            matrix.identity();
            sx = Number(o.scaleX);
            sy = Number(o.scaleY);
            tx = x;
            ty = y;
            if(Boolean(o.flip & 1))
            {
               sx *= -1;
               tx += o.width;
            }
            if(Boolean(o.flip & 2))
            {
               sy *= -1;
               ty += o.height;
            }
            matrix.scale(sx,sy);
            matrix.translate(tx,ty);
            o.s.transform.matrix = matrix;
         }
      }
      
      public function convertToWorldSpace(pos:Point) : void
      {
         if(Boolean(this._mainBackObj))
         {
            pos.x -= this._mainBackObj.x;
            pos.y -= this._mainBackObj.y;
         }
      }
      
      public function convertScreenToWorldSpace(x:int, y:int) : Point
      {
         var xp:int = 0;
         var yp:int = 0;
         if(Boolean(this._mainBackObj))
         {
            xp = (x - this._layerManager.bkg.x) / this._layerManager.bkg.scaleX - (this._mainBackObj.x + this._mainBackObj.dx * this._scrollOffset.x);
            yp = (y - this._layerManager.bkg.y) / this._layerManager.bkg.scaleY - (this._mainBackObj.y + this._mainBackObj.dy * this._scrollOffset.y);
         }
         return new Point(xp,yp);
      }
      
      public function convertWorldToScreen(x:int, y:int) : Point
      {
         var xp:int = 0;
         var yp:int = 0;
         if(Boolean(this._mainBackObj))
         {
            xp = x + (this._mainBackObj.x + this._mainBackObj.dx * this._scrollOffset.x) * this._layerManager.bkg.scaleX + this._layerManager.bkg.x;
            yp = y + (this._mainBackObj.y + this._mainBackObj.dy * this._scrollOffset.y) * this._layerManager.bkg.scaleY + this._layerManager.bkg.y;
         }
         return new Point(xp,yp);
      }
      
      public function bkgScalePoint() : Point
      {
         return new Point(this._layerManager.bkg.scaleX,this._layerManager.bkg.scaleY);
      }
      
      protected function getRandomRadiusOffset(r:Number) : Point
      {
         var p:Point = new Point();
         var a:Number = Math.random() * (2 * Math.PI);
         r = Math.random() * r;
         p.x = Math.cos(a) * r;
         p.y = Math.sin(a) * r;
         return p;
      }
      
      public function convertPathToWorldSpace() : void
      {
         var i:int = 0;
         var o:Object = null;
         var j:int = 0;
         var newPoint:Point = null;
         if(Boolean(this._paths))
         {
            for(i = 0; i < this._paths.length; i++)
            {
               o = this._paths[i];
               for(j = 0; j < o.points.length; j++)
               {
                  if(Boolean(o.points[j]))
                  {
                     newPoint = new Point(o.points[j].x,o.points[j].y);
                     this.convertToWorldSpace(newPoint);
                     o.points[j].x = newPoint.x;
                     o.points[j].y = newPoint.y;
                  }
               }
            }
         }
      }
      
      public function findPathByName(inPathName:String) : Object
      {
         var i:int = 0;
         var o:Object = null;
         if(Boolean(this._paths))
         {
            inPathName.toLowerCase();
            for(i = 0; i < this._paths.length; i++)
            {
               o = this._paths[i];
               if(o.name == inPathName)
               {
                  return o;
               }
            }
         }
         return null;
      }
      
      protected function drawDebugLayer(path:Vector.<int> = null) : void
      {
         var i:int = 0;
         var j:int = 0;
         var x:int = 0;
         var y:int = 0;
         var o:Object = null;
         var pt:Object = null;
         var layer:Object = null;
         var c:* = undefined;
         var y1:Number = NaN;
         var x1:Number = NaN;
         var cell:int = 0;
         var pos:Object = null;
         this._layerManager.debugShape.x = -this._mainBackObj.x;
         this._layerManager.debugShape.y = -this._mainBackObj.y;
         this._layerManager.room_bkg_main.addChild(this._layerManager.debugShape);
         var g:Graphics = this._layerManager.debugShape.graphics;
         g.clear();
         var alpha:Number = 0.2;
         if(Boolean(this._portals))
         {
            g.beginFill(16711680,alpha);
            for(i = 0; i < this._portals.length; i++)
            {
               o = this._portals[i];
               g.drawCircle(o.x,o.y,o.r);
               if(o.type == 1)
               {
                  for(j = 0; j < this._layers.length; j++)
                  {
                     layer = this._layers[j];
                     if(layer.name == o["goto"])
                     {
                        break;
                     }
                  }
                  if(Boolean(layer))
                  {
                     c = layer.s.content;
                     if(Boolean(c))
                     {
                        for(j = 0; j < c.totalFrames; j++)
                        {
                           c.gotoAndStop(j);
                           x = c.player.x + layer.x;
                           y = c.player.y + layer.y;
                           g.drawCircle(x,y,10);
                        }
                     }
                  }
               }
            }
         }
         g.endFill();
         g.beginFill(65280,alpha);
         for(i = 0; i < this._spawns.length; i++)
         {
            o = this._spawns[i];
            g.drawCircle(o.x,o.y,o.r);
         }
         g.endFill();
         if(Boolean(this._actionPoints))
         {
            g.beginFill(255,alpha);
            for(i = 0; i < this._actionPoints.length; i++)
            {
               o = this._actionPoints[i];
               g.drawCircle(o.x,o.y,o.r);
            }
            g.endFill();
         }
         if(Boolean(this._lines))
         {
            g.lineStyle(2,16777215);
            for(i = 0; i < this._lines.length; i++)
            {
               o = this._lines[i];
               g.moveTo(o.x,o.y);
               g.lineTo(o.x1,o.y1);
            }
         }
         if(Boolean(this._paths))
         {
            g.lineStyle(2,255);
            for(i = 0; i < this._paths.length; i++)
            {
               o = this._paths[i];
               for(j = 0; j < o.points.length; j++)
               {
                  pt = o.points[j];
                  if(j == 0)
                  {
                     g.moveTo(pt.x,pt.y);
                  }
                  else
                  {
                     g.lineTo(pt.x,pt.y);
                  }
               }
            }
         }
         if(Boolean(this._volumes))
         {
            g.lineStyle(2,255);
            for(i = 0; i < this._volumes.length; i++)
            {
               o = this._volumes[i];
               for(j = 0; j < o.points.length; j++)
               {
                  pt = o.points[j];
                  if(j == 0)
                  {
                     g.moveTo(pt.x,pt.y);
                  }
                  else
                  {
                     g.lineTo(pt.x,pt.y);
                  }
               }
            }
         }
         if(Boolean(this._grid))
         {
            y1 = this._grid.min.y + this._grid.r;
            for(y = 0; y < this._grid.height; y++)
            {
               x1 = this._grid.min.x + this._grid.r;
               for(x = 0; x < this._grid.width; x++)
               {
                  g.lineStyle(2,0);
                  cell = int(this._grid.grid[x + y * this._grid.width]);
                  if(Boolean(cell))
                  {
                     g.beginFill(cell == 1 ? 16776960 : 255,0.9);
                  }
                  g.drawRect(x1 - this._grid.r,y1 - this._grid.r,this._grid.r2,this._grid.r2);
                  g.endFill();
                  x1 += this._grid.r2;
               }
               y1 += this._grid.r2;
            }
            if(Boolean(path))
            {
               for(i = 0; i < path.length; i++)
               {
                  pos = this._roomGrid.getCellIndexToWorldPos(path[i]);
                  g.beginFill(16711680,0.75);
                  g.drawRect(pos.x - this._grid.r,pos.y - this._grid.r,this._grid.r2,this._grid.r2);
                  g.endFill();
               }
            }
         }
      }
   }
}

