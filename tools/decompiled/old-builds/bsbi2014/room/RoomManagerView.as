package room
{
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarWorldView;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.system.System;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   import quest.QuestManager;
   
   public class RoomManagerView extends RoomManagerBase
   {
      
      public static var _speedMutiplier:int;
      
      protected static const USE_PLAYER_GOTO_SPAWN_LOCATION:String = "use_player_goto_spawn_location";
      
      private static const TAN_30:Number = 0.5773502691896;
      
      private static const PLAYER_INDICATOR_RADIUS:int = 8;
      
      protected var _mousePos:Point;
      
      protected var _bMouseMove:Boolean;
      
      protected var _bMouseDown:Boolean;
      
      protected var _bMouseDownNew:Boolean;
      
      protected var _bTestPortal:Boolean;
      
      protected var _playerGotoSpawnPoint:String;
      
      protected var _playerGotoSpawnLocationX:int;
      
      protected var _playerGotoSpawnLocationY:int;
      
      protected var _leftArrow:Boolean;
      
      protected var _rightArrow:Boolean;
      
      protected var _upArrow:Boolean;
      
      protected var _downArrow:Boolean;
      
      protected var _ctrlPressed:Boolean;
      
      protected var _avatarDirection:Point;
      
      protected var _keyboardEnabled:Boolean;
      
      private var _followPath:Vector.<int>;
      
      private var _movePlayerToPos:Point;
      
      private var _lastGridCell:int;
      
      private var _avLastValidCell:int;
      
      private var _followCursorPos:Point;
      
      private var _followCursorThrottle:int;
      
      private var _playerSlideSpawnPoint:String;
      
      private var _slideList:Array;
      
      private var _socialTriggerThrottle:int;
      
      private var _drawPath:Boolean;
      
      private var _debugLog:String;
      
      private var _startTime:int;
      
      private var _computeCoordinates:Boolean;
      
      private var _immediateCoordinates:Point;
      
      private var _frameTime:Number;
      
      private var _miniMap:MovieClip;
      
      protected var _pathName:String;
      
      private var _miniMaps:Dictionary;
      
      private var _miniMapStamp:Shape;
      
      private var _miniMapMatrix:Matrix;
      
      private var _forceCollision:Boolean;
      
      public function RoomManagerView()
      {
         super();
      }
      
      override public function init(layerManager:LayerManager) : void
      {
         super.init(layerManager);
         this._followCursorPos = new Point();
         this._mousePos = new Point();
         this._slideList = [];
         this._keyboardEnabled = true;
         this._debugLog = new String();
         _speedMutiplier = 1;
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveEvt);
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt);
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpEvt);
         gMainFrame.stage.addEventListener(FocusEvent.FOCUS_OUT,this.onDeactivate);
         gMainFrame.stage.addEventListener(Event.DEACTIVATE,this.onDeactivate);
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDownEvt);
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpEvt);
         this._miniMaps = new Dictionary();
         this._avatarDirection = new Point();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveEvt);
         gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt);
         gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpEvt);
         gMainFrame.stage.removeEventListener(FocusEvent.FOCUS_OUT,this.onDeactivate);
         gMainFrame.stage.removeEventListener(Event.DEACTIVATE,this.onDeactivate);
         gMainFrame.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDownEvt);
         gMainFrame.stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUpEvt);
      }
      
      override public function exitRoom(isDenPreview:Boolean = false) : void
      {
         super.exitRoom(isDenPreview);
         this._movePlayerToPos = null;
         this._bMouseDown = false;
         this._bMouseDownNew = false;
         this._bMouseMove = false;
         this._bTestPortal = false;
         this._playerSlideSpawnPoint = null;
         this._slideList = [];
      }
      
      override protected function onRoomLoaded_base(callback:Function, initScene:Object, initIsDenPreview:Boolean = false) : void
      {
         this._movePlayerToPos = null;
         this._followPath = null;
         this._bMouseDown = false;
         this._bMouseDownNew = false;
         this._lastGridCell = -1;
         this._avLastValidCell = -1;
         super.onRoomLoaded_base(callback,initScene,initIsDenPreview);
      }
      
      public function setGotoSpawnLocation(inX:int, inY:int) : void
      {
         this._playerGotoSpawnLocationX = inX;
         this._playerGotoSpawnLocationY = inY;
         this._playerGotoSpawnPoint = USE_PLAYER_GOTO_SPAWN_LOCATION;
      }
      
      public function setGotoSpawnPoint(value:String) : void
      {
         this._playerGotoSpawnPoint = value;
      }
      
      public function resetThrottle() : void
      {
         this._followCursorThrottle = 0;
      }
      
      protected function walkToSpawn(toSpawn:String) : void
      {
         var spawn:Object = null;
         var pos:Point = null;
         spawn = findSpawn(_spawns,toSpawn);
         if(Boolean(spawn))
         {
            this._bTestPortal = false;
            this._movePlayerToPos = new Point(spawn.x,spawn.y);
            pos = getRandomRadiusOffset(spawn.r);
            this._movePlayerToPos.x += pos.x;
            this._movePlayerToPos.y += pos.y;
            convertToWorldSpace(this._movePlayerToPos);
         }
      }
      
      private function onKeyDownEvt(evt:KeyboardEvent) : void
      {
         var directionChanged:Boolean = false;
         switch(evt.keyCode)
         {
            case Keyboard.CONTROL:
               this._ctrlPressed = true;
               break;
            case Keyboard.LEFT:
               if(this._ctrlPressed)
               {
                  _speedMutiplier = 1;
               }
               else if(this._avatarDirection.x >= 0)
               {
                  this._leftArrow = true;
                  directionChanged = true;
                  this._avatarDirection.x = -1;
               }
               break;
            case Keyboard.RIGHT:
               if(this._ctrlPressed)
               {
                  _speedMutiplier = 1;
               }
               else if(this._avatarDirection.x <= 0)
               {
                  this._rightArrow = true;
                  directionChanged = true;
                  this._avatarDirection.x = 1;
               }
               break;
            case Keyboard.UP:
               if(this._ctrlPressed)
               {
                  ++_speedMutiplier;
               }
               else if(this._avatarDirection.y >= 0)
               {
                  this._upArrow = true;
                  directionChanged = true;
                  this._avatarDirection.y = -1;
               }
               break;
            case Keyboard.DOWN:
               if(this._ctrlPressed)
               {
                  --_speedMutiplier;
               }
               else if(this._avatarDirection.y <= 0)
               {
                  this._downArrow = true;
                  directionChanged = true;
                  this._avatarDirection.y = 1;
               }
         }
         switch(evt.keyCode)
         {
            case Keyboard.NUMPAD_9:
               this._startTime = -1;
               this._drawPath = !this._drawPath;
               break;
            case Keyboard.NUMPAD_8:
               this._forceCollision = !this._forceCollision;
               break;
            case Keyboard.NUMPAD_1:
               System.setClipboard(this._debugLog);
               this._debugLog = "";
               trace("copied");
               break;
            case Keyboard.NUMPAD_2:
               this._computeCoordinates = !this._computeCoordinates;
               trace("computerCoordinates: " + this._computeCoordinates);
         }
         if(directionChanged)
         {
            if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND && Math.abs(this._avatarDirection.x) > 0 && Math.abs(this._avatarDirection.y) > 0)
            {
               this._avatarDirection.y = (this._avatarDirection.y > 0 ? 1 : -1) * TAN_30 * Math.abs(this._avatarDirection.x);
            }
            this._avatarDirection.normalize(1);
         }
      }
      
      public function updatePlayerPos(x:int, y:int) : void
      {
         if(this._miniMap != null)
         {
            x = ((x + _mainBackObj.x - _grid.min.x) / _grid.r2 - this._miniMap.offsetX) * this._miniMap.scale + this._miniMap.centerOffsetX;
            y = ((y + _mainBackObj.y - _grid.min.y) / _grid.r2 - this._miniMap.offsetY) * this._miniMap.scale + this._miniMap.centerOffsetY;
            if(this._miniMapStamp == null)
            {
               this._miniMapStamp = new Shape();
               this._miniMapStamp.graphics.beginFill(0,0.1);
               this._miniMapStamp.graphics.drawCircle(0,0,PLAYER_INDICATOR_RADIUS);
               this._miniMapStamp.graphics.endFill();
               this._miniMapMatrix = new Matrix();
            }
            if(this._miniMapMatrix.tx != x || this._miniMapMatrix.ty != y)
            {
               this._miniMapMatrix.tx = x;
               this._miniMapMatrix.ty = y;
               this._miniMap.overlay.bitmapData.draw(this._miniMapStamp,this._miniMapMatrix,null,BlendMode.ALPHA);
               this._miniMap.playerIndicator.x = x;
               this._miniMap.playerIndicator.y = y;
            }
         }
      }
      
      public function removeAndClearMiniMap() : void
      {
         if(Boolean(this._miniMap) && Boolean(this._miniMap.parent))
         {
            this._miniMap.parent.removeChild(this._miniMap);
         }
         this._miniMap = null;
         this._miniMaps = new Dictionary();
      }
      
      public function removeMiniMap() : void
      {
         if(Boolean(this._miniMap) && Boolean(this._miniMap.parent))
         {
            this._miniMap.parent.removeChild(this._miniMap);
         }
         this._miniMap = null;
      }
      
      public function updateMinimap() : void
      {
         var bmp:Bitmap = null;
         var myBitmapData:BitmapData = null;
         var y:int = 0;
         var index:int = 0;
         var x:int = 0;
         var cell:int = 0;
         if(Boolean(this._miniMap) && Boolean(this._miniMap.parent) && !this._miniMap.hasOwnProperty("noUpdates"))
         {
            bmp = this._miniMap.getChildAt(1) as Bitmap;
            if(Boolean(bmp))
            {
               myBitmapData = bmp.bitmapData;
               for(y = 0; y < this._miniMap.croppedHeight; y++)
               {
                  index = this._miniMap.leftX + (y + this._miniMap.topY) * _grid.width;
                  for(x = 0; x < this._miniMap.croppedWidth; x++)
                  {
                     cell = int(_grid.grid[x + index]);
                     if(cell == 0)
                     {
                        myBitmapData.setPixel(x,y,8024881);
                     }
                  }
               }
            }
         }
      }
      
      private function mapBitmapLoaded(img:MovieClip) : void
      {
         img.scaleX = img.scaleY = 0.5;
         this._miniMap.addChildAt(img,1);
      }
      
      public function createMiniMap() : void
      {
         var y:Number = NaN;
         var x:Number = NaN;
         var cell:int = 0;
         var doBreak:Boolean = false;
         var y1:Number = NaN;
         var leftX:int = 0;
         var rightX:int = 0;
         var topY:int = 0;
         var bottomY:int = 0;
         var index:int = 0;
         var fullWidth:int = 0;
         var fullHeight:int = 0;
         var myBitmapData:BitmapData = null;
         var croppedWidth:int = 0;
         var croppedHeight:int = 0;
         var aspectCurrent:Number = NaN;
         var aspectTarget:Number = NaN;
         var scale:Number = NaN;
         var bmp:Bitmap = null;
         var maps:Array = null;
         var centerOffsetX:Number = NaN;
         var centerOffsetY:Number = NaN;
         var container:Sprite = null;
         var mapIds:Array = null;
         var mh:MediaHelper = null;
         if(GuiManager.mainHud.miniMap != null)
         {
            this._miniMap = this._miniMaps[this._pathName];
            if(Boolean(this._miniMap))
            {
               GuiManager.mainHud.miniMap.ba.itemLayer.addChild(this._miniMap);
            }
            else if(Boolean(_grid))
            {
               this._miniMap = new MovieClip();
               y1 = 0;
               doBreak = false;
               for(x = 0; x < _grid.width; x++)
               {
                  for(y = 0; y < _grid.height; y++)
                  {
                     cell = int(_grid.grid[x + y * _grid.width]);
                     if(cell == 0)
                     {
                        leftX = x;
                        doBreak = true;
                        break;
                     }
                  }
                  if(doBreak)
                  {
                     break;
                  }
               }
               doBreak = false;
               for(x = _grid.width - 1; x >= 0; x--)
               {
                  for(y = 0; y < _grid.height; y++)
                  {
                     cell = int(_grid.grid[x + y * _grid.width]);
                     if(cell == 0)
                     {
                        rightX = x;
                        doBreak = true;
                        break;
                     }
                  }
                  if(doBreak)
                  {
                     break;
                  }
               }
               doBreak = false;
               for(y = 0; y < _grid.height; y++)
               {
                  index = y * _grid.width;
                  for(x = 0; x < _grid.width; x++)
                  {
                     cell = int(_grid.grid[x + index]);
                     if(cell == 0)
                     {
                        topY = y;
                        doBreak = true;
                        break;
                     }
                  }
                  if(doBreak)
                  {
                     break;
                  }
               }
               doBreak = false;
               for(y = _grid.height - 1; y >= 0; y--)
               {
                  index = y * _grid.width;
                  for(x = 0; x < _grid.width; x++)
                  {
                     cell = int(_grid.grid[x + index]);
                     if(cell == 0)
                     {
                        bottomY = y;
                        doBreak = true;
                        break;
                     }
                  }
                  if(doBreak)
                  {
                     break;
                  }
               }
               this._miniMap.offsetX = leftX;
               this._miniMap.offsetY = topY;
               fullWidth = int(GuiManager.mainHud.miniMap.ba.itemLayer.width);
               fullHeight = int(GuiManager.mainHud.miniMap.ba.itemLayer.height);
               myBitmapData = new BitmapData(fullWidth,fullHeight,true,4278190080);
               this._miniMap.addChild(new Bitmap(myBitmapData,"auto",true));
               croppedWidth = rightX - leftX + 1;
               croppedHeight = bottomY - topY + 1;
               this._miniMap.croppedWidth = croppedWidth;
               this._miniMap.croppedHeight = croppedHeight;
               this._miniMap.leftX = leftX;
               this._miniMap.topY = topY;
               myBitmapData = new BitmapData(croppedWidth,croppedHeight,false,0);
               for(y = 0; y < croppedHeight; y++)
               {
                  index = leftX + (y + topY) * _grid.width;
                  for(x = 0; x < croppedWidth; x++)
                  {
                     cell = int(_grid.grid[x + index]);
                     if(cell == 0)
                     {
                        myBitmapData.setPixel(x,y,8024881);
                     }
                  }
               }
               aspectCurrent = croppedWidth / croppedHeight;
               aspectTarget = fullWidth / fullHeight;
               maps = volumeManager.findVolume("map");
               if(Boolean(maps))
               {
                  mapIds = maps[0].message.split(",");
                  mh = new MediaHelper();
                  bmp = new Bitmap();
                  mh.init(mapIds[mapIds.length > QuestManager._questDifficultyLevel ? QuestManager._questDifficultyLevel : 0],this.mapBitmapLoaded);
                  this._miniMap.noUpdates = 1;
               }
               else
               {
                  bmp = new Bitmap(myBitmapData,"auto",true);
                  this._miniMap.addChild(bmp);
               }
               scale = aspectCurrent < aspectTarget ? fullHeight / croppedHeight : fullWidth / croppedWidth;
               bmp.scaleX = bmp.scaleY = this._miniMap.scale = scale;
               centerOffsetX = (fullWidth - croppedWidth * scale) * 0.5;
               centerOffsetY = (fullHeight - croppedHeight * scale) * 0.5;
               this._miniMap.centerOffsetX = centerOffsetX;
               this._miniMap.centerOffsetY = centerOffsetY;
               bmp.x += centerOffsetX;
               bmp.y += centerOffsetY;
               container = new Sprite();
               this._miniMap.addChild(container);
               container.blendMode = BlendMode.LAYER;
               myBitmapData = new BitmapData(fullWidth,fullHeight,true,4278190080);
               this._miniMap.overlay = new Bitmap(myBitmapData,"auto",true);
               container.addChild(this._miniMap.overlay);
               this._miniMap.x = -this._miniMap.width * 0.5;
               this._miniMap.y = -this._miniMap.height * 0.5;
               GuiManager.mainHud.miniMap.ba.itemLayer.addChild(this._miniMap);
               this._miniMap.playerIndicator = GETDEFINITIONBYNAME("miniMapDotCont");
               this._miniMap.addChild(this._miniMap.playerIndicator);
               this._miniMaps[this._pathName] = this._miniMap;
            }
         }
      }
      
      private function onKeyUpEvt(evt:KeyboardEvent) : void
      {
         var directionChanged:Boolean = false;
         switch(evt.keyCode)
         {
            case Keyboard.CONTROL:
               this._ctrlPressed = false;
               break;
            case Keyboard.LEFT:
               if(this._leftArrow)
               {
                  this._leftArrow = false;
                  if(this._avatarDirection.x < 0)
                  {
                     this._avatarDirection.x = this._rightArrow ? 1 : 0;
                     directionChanged = true;
                  }
               }
               break;
            case Keyboard.RIGHT:
               if(this._rightArrow)
               {
                  this._rightArrow = false;
                  if(this._avatarDirection.x > 0)
                  {
                     this._avatarDirection.x = this._leftArrow ? -1 : 0;
                     directionChanged = true;
                  }
               }
               break;
            case Keyboard.UP:
               if(this._upArrow)
               {
                  this._upArrow = false;
                  if(this._avatarDirection.y < 0)
                  {
                     this._avatarDirection.y = this._downArrow ? 1 : 0;
                     directionChanged = true;
                  }
               }
               break;
            case Keyboard.DOWN:
               if(this._downArrow)
               {
                  this._downArrow = false;
                  if(this._avatarDirection.y > 0)
                  {
                     this._avatarDirection.y = this._upArrow ? -1 : 0;
                     directionChanged = true;
                  }
               }
         }
         if(directionChanged)
         {
            this._avatarDirection.normalize(1);
         }
      }
      
      private function onDeactivate(evt:Event) : void
      {
         this._leftArrow = this._rightArrow = this._upArrow = this._downArrow = false;
         this._avatarDirection.x = this._avatarDirection.y = 0;
      }
      
      private function onMouseMoveEvt(evt:MouseEvent) : void
      {
         if(GuiManager.isModal() || DarkenManager.isDarkened)
         {
            return;
         }
         if(_layerManager.bkg == null || _mainBackObj == null || !this._bTestPortal)
         {
            return;
         }
         if(this._bMouseDown)
         {
            this._followCursorPos.x = evt.stageX;
            this._followCursorPos.y = evt.stageY;
            if(this._drawPath)
            {
               this._debugLog = this._debugLog.concat(getTimer() - this._startTime + " MOUSE_MOVE, stageX=" + evt.stageX + ", stageY=" + evt.stageY);
               if(this._computeCoordinates)
               {
                  this._immediateCoordinates = convertScreenToWorldSpace(this._followCursorPos.x,this._followCursorPos.y);
                  this._debugLog = this._debugLog.concat(" worldX=" + this._immediateCoordinates.x + ", worldY=" + this._immediateCoordinates.y);
               }
               this._debugLog = this._debugLog.concat("\n");
            }
         }
         this._mousePos.x = evt.stageX;
         this._mousePos.y = evt.stageY;
         this._bMouseMove = true;
      }
      
      private function onMouseDownEvt(evt:MouseEvent) : void
      {
         GuiManager.handleMouseDown();
         if(GuiManager.isModal() || AvatarSwitch.isSwitching() || DarkenManager.isDarkened)
         {
            return;
         }
         if(_layerManager.bkg == null || _mainBackObj == null || !this._bTestPortal)
         {
            return;
         }
         if(QuestManager.mouseHandleDown(evt) == false)
         {
            if(this._drawPath)
            {
               if(this._startTime < 0)
               {
                  this._startTime = getTimer();
               }
               this._debugLog = this._debugLog.concat(getTimer() - this._startTime + " MOUSE_DOWN, stageX=" + evt.stageX + ", stageY=" + evt.stageY);
               if(this._computeCoordinates)
               {
                  this._immediateCoordinates = convertScreenToWorldSpace(this._followCursorPos.x,this._followCursorPos.y);
                  this._debugLog = this._debugLog.concat(" worldX=" + this._immediateCoordinates.x + ", worldY=" + this._immediateCoordinates.y);
               }
               this._debugLog = this._debugLog.concat("\n");
            }
            this._bMouseDown = true;
            this._bMouseDownNew = true;
            this._followCursorPos.x = evt.stageX;
            this._followCursorPos.y = evt.stageY;
            this._followCursorThrottle = 0;
            this._mousePos.x = evt.stageX;
            this._mousePos.y = evt.stageY;
            this._bMouseMove = true;
         }
      }
      
      private function onMouseUpEvt(evt:MouseEvent) : void
      {
         this.forceMouseUp();
         if(this._drawPath)
         {
            this._debugLog = this._debugLog.concat(getTimer() - this._startTime + " MOUSE_UP\n");
         }
      }
      
      public function forceMouseUp() : void
      {
         this._bMouseDown = false;
         this._bMouseDownNew = false;
         this._lastGridCell = -1;
      }
      
      public function setFocus(focus:Boolean = true) : void
      {
         if(!focus)
         {
            this.forceMouseUp();
         }
      }
      
      public function heartbeat_movePlayer(ms:int, frameTimems:int) : void
      {
         var cell:int = 0;
         var pos:Object = null;
         this._frameTime = frameTimems / 1000;
         if(this._frameTime > 0.5)
         {
            this._frameTime = 0.5;
         }
         if(Boolean(this._movePlayerToPos))
         {
            this.movePlayerToLocation(this._movePlayerToPos.x,this._movePlayerToPos.y);
            this._movePlayerToPos = null;
         }
         else if(AvatarManager.playerAvatarWorldView != null && !AvatarManager.playerAvatarWorldView.moving)
         {
            if(Boolean(this._playerSlideSpawnPoint))
            {
               this.walkToSpawn(this._playerSlideSpawnPoint);
               this._playerSlideSpawnPoint = null;
            }
            else if(Boolean(this._followPath))
            {
               this.movePlayerOnPath();
            }
            else
            {
               this._bTestPortal = true;
            }
         }
         else if(Boolean(_mainBackObj))
         {
            if(AvatarManager.playerAvatarWorldView != null && _mainBackObj != null)
            {
               cell = _roomGrid.getCellIndex(AvatarManager.playerAvatarWorldView.x + _mainBackObj.x,AvatarManager.playerAvatarWorldView.y + _mainBackObj.y);
               if(this._avLastValidCell != cell)
               {
                  pos = _roomGrid.convertCellToCoords(cell);
                  if(!_roomGrid.testGridCell(pos.x,pos.y))
                  {
                     this._avLastValidCell = cell;
                  }
               }
            }
         }
      }
      
      protected function followCursorTest() : void
      {
         var pt:Point = null;
         var cell:int = 0;
         var speed:int = 0;
         var px:Number = NaN;
         var py:Number = NaN;
         var doCollision:Boolean = false;
         if(this._followCursorThrottle <= 0 && this._bMouseDown)
         {
            if(this._computeCoordinates && Boolean(this._immediateCoordinates))
            {
               pt = this._immediateCoordinates;
            }
            else
            {
               pt = convertScreenToWorldSpace(this._followCursorPos.x,this._followCursorPos.y);
            }
            cell = _roomGrid.getCellIndex(pt.x + _mainBackObj.x,pt.y + _mainBackObj.y);
            if(this._lastGridCell != cell)
            {
               this._lastGridCell = cell;
               this._movePlayerToPos = pt;
               this._followPath = null;
               this._followCursorThrottle = 12;
               if(this._drawPath)
               {
                  this._debugLog = this._debugLog.concat(getTimer() - this._startTime + " Processing cursor posX=" + this._followCursorPos.x + ", cursor posY=" + this._followCursorPos.y + ", moving to " + pt.x + "," + pt.y + "\n");
               }
            }
         }
         else
         {
            --this._followCursorThrottle;
         }
         if(Boolean(this._keyboardEnabled && !DarkenManager.isDarkened && !GuiManager.volumeMgr.visible && AvatarManager.playerAvatarWorldView && this._movePlayerToPos == null && this._followPath == null) && Boolean(this._playerSlideSpawnPoint == null) && this._bTestPortal)
         {
            if(this._avatarDirection.x != 0 || this._avatarDirection.y != 0)
            {
               pt = new Point();
               speed = 24 * _speedMutiplier * this._frameTime / 0.07;
               px = this._avatarDirection.x * speed;
               py = this._avatarDirection.y * speed;
               pt.x = AvatarManager.playerAvatarWorldView.x;
               pt.y = AvatarManager.playerAvatarWorldView.y;
               doCollision = true;
               doCollision = false;
               if((doCollision || this._forceCollision) && collisionTestGrid(pt.x + px,pt.y + py) != 0)
               {
                  if(px != 0 && py != 0)
                  {
                     if(collisionTestGrid(pt.x,pt.y + py) != 0)
                     {
                        if(collisionTestGrid(pt.x + px,pt.y) == 0)
                        {
                           AvatarManager.movePlayer(pt.x + px,pt.y);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(pt.x,pt.y + py);
                     }
                  }
                  else if(px == 0)
                  {
                     px = Math.abs(py);
                     if(collisionTestGrid(pt.x + 25,pt.y + py) != 0)
                     {
                        if(collisionTestGrid(pt.x - 25,pt.y + py) == 0)
                        {
                           AvatarManager.movePlayer(pt.x - px,pt.y + py);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(pt.x + px,pt.y + py);
                     }
                  }
                  else
                  {
                     py = Math.abs(px);
                     if(collisionTestGrid(pt.x + px,pt.y - 25) != 0)
                     {
                        if(collisionTestGrid(pt.x + px,pt.y + 25) == 0)
                        {
                           AvatarManager.movePlayer(pt.x + px,pt.y + py);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(pt.x + px,pt.y - py);
                     }
                  }
               }
               else
               {
                  AvatarManager.movePlayer(pt.x + px,pt.y + py);
               }
            }
         }
      }
      
      protected function updateSplashVolumes() : void
      {
         var avList:Object = null;
         var key:Object = null;
         var a:* = undefined;
         var v:Object = null;
         var m:String = null;
         if(_volumeManager.hasSplashVolume)
         {
            avList = AvatarManager.avatarViewList;
            for(key in avList)
            {
               a = avList[key];
               v = _volumeManager.testSplashVolumes(new Point(a.x,a.y));
               if(Boolean(v))
               {
                  m = v.message;
               }
               a.setSplashVolume(v != null,m);
            }
         }
      }
      
      protected function updateSocialVolumes() : void
      {
         ++this._socialTriggerThrottle;
         if(this._socialTriggerThrottle > 20)
         {
            this._socialTriggerThrottle = 0;
            _volumeManager.updateSocialTriggers(AvatarManager.avatarViewList);
         }
      }
      
      private function movePlayerToLocation(x:int, y:int) : void
      {
         var pos:Object = null;
         var px:Number = NaN;
         var py:Number = NaN;
         if(Boolean(AvatarManager.playerAvatar))
         {
            px = AvatarManager.playerAvatarWorldView.x;
            py = AvatarManager.playerAvatarWorldView.y;
            if(Boolean(_roomGrid))
            {
               pos = _roomGrid.convertCellToCoords(_roomGrid.getCellIndex(px + _mainBackObj.x,py + _mainBackObj.y));
               if(Boolean(_roomGrid.testGridCell(pos.x,pos.y)) && this._avLastValidCell >= 0)
               {
                  pos = _roomGrid.getCellIndexToWorldPos(this._avLastValidCell);
                  px = pos.x - _mainBackObj.x;
                  py = pos.y - _mainBackObj.y;
               }
               pos = _roomGrid.findClosestOpenGridCell(x + _mainBackObj.x,y + _mainBackObj.y);
               if(Boolean(pos))
               {
                  x = pos.x - _mainBackObj.x;
                  y = pos.y - _mainBackObj.y;
                  this._followPath = _roomGrid.findPathOptimized(new Point(px + _mainBackObj.x,py + _mainBackObj.y),new Point(x + _mainBackObj.x,y + _mainBackObj.y));
                  if(this._followPath == null || this._followPath.length == 0)
                  {
                     this._followPath = null;
                  }
                  else
                  {
                     if(this._drawPath)
                     {
                        drawDebugLayer(this._followPath);
                     }
                     this.movePlayerOnPath();
                  }
               }
            }
         }
      }
      
      public function setGridDepth(depth:uint) : void
      {
         _roomGrid.setGridDepth(depth);
      }
      
      public function getGridCellType() : int
      {
         var pos:Object = null;
         if(Boolean(_mainBackObj))
         {
            pos = _roomGrid.convertCellToCoords(_roomGrid.getCellIndex(AvatarManager.playerAvatarWorldView.x + _mainBackObj.x,AvatarManager.playerAvatarWorldView.y + _mainBackObj.y));
            return _roomGrid.testGridCell(pos.x,pos.y);
         }
         return 0;
      }
      
      private function movePlayerOnPath() : void
      {
         var pos:Object = null;
         if(Boolean(_mainBackObj))
         {
            pos = _roomGrid.getCellIndexToWorldPos(this._followPath[0]);
            AvatarManager.movePlayer(pos.x - _mainBackObj.x,pos.y - _mainBackObj.y);
            if(this._followPath.length == 1)
            {
               this._followPath = null;
            }
            else
            {
               this._followPath.splice(0,1);
            }
         }
      }
      
      public function killPlayerPath() : void
      {
         this._followPath = null;
      }
      
      public function attachAvatarToSlide(av:AvatarWorldView, name:String, playerSlideSpawnPoint:String = null) : void
      {
         var i:int = 0;
         var j:int = 0;
         var layer:Object = null;
         var c:* = undefined;
         var pos:Point = new Point();
         var a:Array = this._slideList[name];
         if(Boolean(playerSlideSpawnPoint))
         {
            this._playerSlideSpawnPoint = playerSlideSpawnPoint;
         }
         if(a == null && Boolean(_layers))
         {
            for(i = 0; i < _layers.length; i++)
            {
               layer = _layers[i];
               if(layer.name == name)
               {
                  break;
               }
            }
            if(Boolean(layer))
            {
               c = layer.s.content;
               a = [];
               for(i = 0; i < c.totalFrames; i++)
               {
                  c.gotoAndStop(i);
                  pos.x = c.player.x + layer.x;
                  pos.y = c.player.y + layer.y;
                  convertToWorldSpace(pos);
                  a[i] = {
                     "x":pos.x,
                     "y":pos.y
                  };
               }
               this._slideList[name] = a;
            }
         }
         if(Boolean(a) && Boolean(av))
         {
            av.startSlide(a);
         }
         this._movePlayerToPos = null;
         this._followPath = null;
         this._bMouseDown = false;
      }
      
      public function getLengthLineIntersectGrid(inStart:Point, inLinePoint:Point, inMaxLength:Number) : Number
      {
         var testX:Number = NaN;
         var testY:Number = NaN;
         var cellX:int = 0;
         var cellY:int = 0;
         var lineNormal:Number = Math.sqrt((inStart.x - inLinePoint.x) * (inStart.x - inLinePoint.x) + (inStart.y - inLinePoint.y) * (inStart.y - inLinePoint.y));
         var lineNormalX:Number = (inLinePoint.x - inStart.x) / lineNormal;
         var lineNormalY:Number = (inLinePoint.y - inStart.y) / lineNormal;
         var returnLength:Number = 10;
         var segmentStep:Number = Number(_grid.r2);
         while(returnLength < inMaxLength)
         {
            testX = inStart.x + lineNormalX * returnLength;
            testY = inStart.y + lineNormalY * returnLength;
            cellX = (testX + _mainBackObj.x - _grid.min.x) / _grid.r2;
            cellY = (testY + _mainBackObj.y - _grid.min.y) / _grid.r2;
            if(_roomGrid.testGridCell(cellX,cellY) == 1)
            {
               break;
            }
            returnLength += segmentStep;
         }
         return returnLength + 50;
      }
   }
}

