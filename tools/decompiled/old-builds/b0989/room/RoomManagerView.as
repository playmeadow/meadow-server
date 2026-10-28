package room
{
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarWorldView;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import flash.utils.getTimer;
   import gui.DarkenManager;
   import gui.GuiManager;
   import quest.QuestManager;
   
   public class RoomManagerView extends RoomManagerBase
   {
      
      protected static const USE_PLAYER_GOTO_SPAWN_LOCATION:String = "use_player_goto_spawn_location";
      
      private static const TAN_30:Number = 0.5773502691896;
      
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
      
      public function RoomManagerView()
      {
         super();
      }
      
      override public function init(param1:LayerManager) : void
      {
         super.init(param1);
         this._followCursorPos = new Point();
         this._mousePos = new Point();
         this._slideList = [];
         this._keyboardEnabled = true;
         this._debugLog = new String();
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveEvt);
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt);
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpEvt);
         gMainFrame.stage.addEventListener(FocusEvent.FOCUS_OUT,this.onDeactivate);
         gMainFrame.stage.addEventListener(Event.DEACTIVATE,this.onDeactivate);
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDownEvt);
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpEvt);
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
      
      override public function exitRoom() : void
      {
         super.exitRoom();
         this._movePlayerToPos = null;
         this._bMouseDown = false;
         this._bMouseDownNew = false;
         this._bMouseMove = false;
         this._bTestPortal = false;
         this._playerSlideSpawnPoint = null;
         if(this._slideList.length)
         {
            this._slideList = [];
         }
      }
      
      override protected function onRoomLoaded_base(param1:Function) : void
      {
         this._movePlayerToPos = null;
         this._followPath = null;
         this._bMouseDown = false;
         this._bMouseDownNew = false;
         this._lastGridCell = -1;
         this._avLastValidCell = -1;
         super.onRoomLoaded_base(param1);
      }
      
      public function setGotoSpawnLocation(param1:int, param2:int) : void
      {
         this._playerGotoSpawnLocationX = param1;
         this._playerGotoSpawnLocationY = param2;
         this._playerGotoSpawnPoint = USE_PLAYER_GOTO_SPAWN_LOCATION;
      }
      
      public function setGotoSpawnPoint(param1:String) : void
      {
         this._playerGotoSpawnPoint = param1;
      }
      
      public function resetThrottle() : void
      {
         this._followCursorThrottle = 0;
      }
      
      protected function walkToSpawn(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Point = null;
         _loc2_ = findSpawn(_spawns,param1);
         if(_loc2_)
         {
            this._bTestPortal = false;
            this._movePlayerToPos = new Point(_loc2_.x,_loc2_.y);
            _loc3_ = getRandomRadiusOffset(_loc2_.r);
            this._movePlayerToPos.x += _loc3_.x;
            this._movePlayerToPos.y += _loc3_.y;
            convertToWorldSpace(this._movePlayerToPos);
         }
      }
      
      private function onKeyDownEvt(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         switch(param1.keyCode)
         {
            case Keyboard.LEFT:
               if(this._avatarDirection.x >= 0)
               {
                  this._leftArrow = true;
                  _loc2_ = true;
                  this._avatarDirection.x = -1;
               }
               break;
            case Keyboard.RIGHT:
               if(this._avatarDirection.x <= 0)
               {
                  this._rightArrow = true;
                  _loc2_ = true;
                  this._avatarDirection.x = 1;
               }
               break;
            case Keyboard.UP:
               if(this._avatarDirection.y >= 0)
               {
                  this._upArrow = true;
                  _loc2_ = true;
                  this._avatarDirection.y = -1;
               }
               break;
            case Keyboard.DOWN:
               if(this._avatarDirection.y <= 0)
               {
                  this._downArrow = true;
                  _loc2_ = true;
                  this._avatarDirection.y = 1;
               }
         }
         if(_loc2_)
         {
            if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND && Math.abs(this._avatarDirection.x) > 0 && Math.abs(this._avatarDirection.y) > 0)
            {
               this._avatarDirection.y = (this._avatarDirection.y > 0 ? 1 : -1) * TAN_30 * Math.abs(this._avatarDirection.x);
            }
            this._avatarDirection.normalize(1);
         }
      }
      
      private function onKeyUpEvt(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         switch(param1.keyCode)
         {
            case Keyboard.LEFT:
               if(this._leftArrow)
               {
                  this._leftArrow = false;
                  if(this._avatarDirection.x < 0)
                  {
                     this._avatarDirection.x = this._rightArrow ? 1 : 0;
                     _loc2_ = true;
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
                     _loc2_ = true;
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
                     _loc2_ = true;
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
                     _loc2_ = true;
                  }
               }
         }
         if(_loc2_)
         {
            this._avatarDirection.normalize(1);
         }
      }
      
      private function onDeactivate(param1:Event) : void
      {
         this._leftArrow = this._rightArrow = this._upArrow = this._downArrow = false;
         this._avatarDirection.x = this._avatarDirection.y = 0;
      }
      
      private function onMouseMoveEvt(param1:MouseEvent) : void
      {
         var _loc2_:AvatarWorldView = null;
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
            this._followCursorPos.x = param1.stageX;
            this._followCursorPos.y = param1.stageY;
            if(this._drawPath)
            {
               this._debugLog = this._debugLog.concat(getTimer() - this._startTime + " MOUSE_MOVE, stageX=" + param1.stageX + ", stageY=" + param1.stageY);
               if(this._computeCoordinates)
               {
                  this._immediateCoordinates = convertScreenToWorldSpace(this._followCursorPos.x,this._followCursorPos.y);
                  this._debugLog = this._debugLog.concat(" worldX=" + this._immediateCoordinates.x + ", worldY=" + this._immediateCoordinates.y);
               }
               this._debugLog = this._debugLog.concat("\n");
            }
         }
         this._mousePos.x = param1.stageX;
         this._mousePos.y = param1.stageY;
         this._bMouseMove = true;
         for each(_loc2_ in AvatarManager.avatarViewList)
         {
            _loc2_.checkSelnub(param1);
         }
      }
      
      private function onMouseDownEvt(param1:MouseEvent) : void
      {
         GuiManager.handleMouseDown();
         if(GuiManager.isModal() || AvatarSwitch.isSwitching())
         {
            return;
         }
         if(_layerManager.bkg == null || _mainBackObj == null || !this._bTestPortal)
         {
            return;
         }
         if(QuestManager.mouseHandleDown(param1) == false)
         {
            if(this._drawPath)
            {
               if(this._startTime < 0)
               {
                  this._startTime = getTimer();
               }
               this._debugLog = this._debugLog.concat(getTimer() - this._startTime + " MOUSE_DOWN, stageX=" + param1.stageX + ", stageY=" + param1.stageY);
               if(this._computeCoordinates)
               {
                  this._immediateCoordinates = convertScreenToWorldSpace(this._followCursorPos.x,this._followCursorPos.y);
                  this._debugLog = this._debugLog.concat(" worldX=" + this._immediateCoordinates.x + ", worldY=" + this._immediateCoordinates.y);
               }
               this._debugLog = this._debugLog.concat("\n");
            }
            this._bMouseDown = true;
            this._bMouseDownNew = true;
            this._followCursorPos.x = param1.stageX;
            this._followCursorPos.y = param1.stageY;
            this._followCursorThrottle = 0;
            this._mousePos.x = param1.stageX;
            this._mousePos.y = param1.stageY;
            this._bMouseMove = true;
         }
      }
      
      private function onMouseUpEvt(param1:MouseEvent) : void
      {
         this.forceMouseUp();
         if(this._drawPath)
         {
            this._debugLog = this._debugLog.concat(getTimer() - this._startTime + " MOUSE_UP\n");
         }
      }
      
      private function forceMouseUp() : void
      {
         this._bMouseDown = false;
         this._bMouseDownNew = false;
         this._lastGridCell = -1;
      }
      
      public function setFocus(param1:Boolean = true) : void
      {
         if(!param1)
         {
            this.forceMouseUp();
         }
      }
      
      public function heartbeat_movePlayer(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         this._frameTime = param2 / 1000;
         if(this._frameTime > 0.5)
         {
            this._frameTime = 0.5;
         }
         if(this._movePlayerToPos)
         {
            this.movePlayerToLocation(this._movePlayerToPos.x,this._movePlayerToPos.y);
            this._movePlayerToPos = null;
         }
         else if(AvatarManager.playerAvatarWorldView != null && !AvatarManager.playerAvatarWorldView.moving)
         {
            if(this._playerSlideSpawnPoint)
            {
               this.walkToSpawn(this._playerSlideSpawnPoint);
               this._playerSlideSpawnPoint = null;
            }
            else if(this._followPath)
            {
               this.movePlayerOnPath();
            }
            else
            {
               this._bTestPortal = true;
            }
         }
         else if(_mainBackObj)
         {
            if(AvatarManager.playerAvatarWorldView != null && _mainBackObj != null)
            {
               _loc3_ = _roomGrid.getCellIndex(AvatarManager.playerAvatarWorldView.x + _mainBackObj.x,AvatarManager.playerAvatarWorldView.y + _mainBackObj.y);
               if(this._avLastValidCell != _loc3_)
               {
                  _loc4_ = _roomGrid.convertCellToCoords(_loc3_);
                  if(!_roomGrid.testGridCell(_loc4_.x,_loc4_.y))
                  {
                     this._avLastValidCell = _loc3_;
                  }
               }
            }
         }
      }
      
      protected function followCursorTest() : void
      {
         var _loc1_:Point = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Boolean = false;
         if(this._followCursorThrottle <= 0 && this._bMouseDown)
         {
            if(this._computeCoordinates)
            {
               _loc1_ = this._immediateCoordinates;
            }
            else
            {
               _loc1_ = convertScreenToWorldSpace(this._followCursorPos.x,this._followCursorPos.y);
            }
            _loc2_ = _roomGrid.getCellIndex(_loc1_.x + _mainBackObj.x,_loc1_.y + _mainBackObj.y);
            if(this._lastGridCell != _loc2_)
            {
               this._lastGridCell = _loc2_;
               this._movePlayerToPos = _loc1_;
               this._followPath = null;
               this._followCursorThrottle = 12;
               if(this._drawPath)
               {
                  this._debugLog = this._debugLog.concat(getTimer() - this._startTime + " Processing cursor posX=" + this._followCursorPos.x + ", cursor posY=" + this._followCursorPos.y + ", moving to " + _loc1_.x + "," + _loc1_.y + "\n");
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
               _loc1_ = new Point();
               _loc3_ = 24 * this._frameTime / 0.07;
               _loc4_ = this._avatarDirection.x * _loc3_;
               _loc5_ = this._avatarDirection.y * _loc3_;
               _loc1_.x = AvatarManager.playerAvatarWorldView.x;
               _loc1_.y = AvatarManager.playerAvatarWorldView.y;
               _loc6_ = true;
               if((_loc6_) && collisionTestGrid(_loc1_.x + _loc4_,_loc1_.y + _loc5_) != 0)
               {
                  if(_loc4_ != 0 && _loc5_ != 0)
                  {
                     if(collisionTestGrid(_loc1_.x,_loc1_.y + _loc5_) != 0)
                     {
                        if(collisionTestGrid(_loc1_.x + _loc4_,_loc1_.y) == 0)
                        {
                           AvatarManager.movePlayer(_loc1_.x + _loc4_,_loc1_.y);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(_loc1_.x,_loc1_.y + _loc5_);
                     }
                  }
                  else if(_loc4_ == 0)
                  {
                     _loc4_ = Math.abs(_loc5_);
                     if(collisionTestGrid(_loc1_.x + 25,_loc1_.y + _loc5_) != 0)
                     {
                        if(collisionTestGrid(_loc1_.x - 25,_loc1_.y + _loc5_) == 0)
                        {
                           AvatarManager.movePlayer(_loc1_.x - _loc4_,_loc1_.y + _loc5_);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(_loc1_.x + _loc4_,_loc1_.y + _loc5_);
                     }
                  }
                  else
                  {
                     _loc5_ = Math.abs(_loc4_);
                     if(collisionTestGrid(_loc1_.x + _loc4_,_loc1_.y - 25) != 0)
                     {
                        if(collisionTestGrid(_loc1_.x + _loc4_,_loc1_.y + 25) == 0)
                        {
                           AvatarManager.movePlayer(_loc1_.x + _loc4_,_loc1_.y + _loc5_);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(_loc1_.x + _loc4_,_loc1_.y - _loc5_);
                     }
                  }
               }
               else
               {
                  AvatarManager.movePlayer(_loc1_.x + _loc4_,_loc1_.y + _loc5_);
               }
            }
         }
      }
      
      protected function updateSplashVolumes() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:* = undefined;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         if(_volumeManager.hasSplashVolume)
         {
            _loc1_ = AvatarManager.avatarViewList;
            for(_loc2_ in _loc1_)
            {
               _loc3_ = _loc1_[_loc2_];
               _loc4_ = _volumeManager.testSplashVolumes(new Point(_loc3_.x,_loc3_.y));
               if(_loc4_)
               {
                  _loc5_ = _loc4_.message;
               }
               _loc3_.setSplashVolume(_loc4_ != null,_loc5_);
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
      
      private function movePlayerToLocation(param1:int, param2:int) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(AvatarManager.playerAvatar)
         {
            _loc4_ = AvatarManager.playerAvatarWorldView.x;
            _loc5_ = AvatarManager.playerAvatarWorldView.y;
            if(_roomGrid)
            {
               _loc3_ = _roomGrid.convertCellToCoords(_roomGrid.getCellIndex(_loc4_ + _mainBackObj.x,_loc5_ + _mainBackObj.y));
               if(Boolean(_roomGrid.testGridCell(_loc3_.x,_loc3_.y)) && this._avLastValidCell >= 0)
               {
                  _loc3_ = _roomGrid.getCellIndexToWorldPos(this._avLastValidCell);
                  _loc4_ = _loc3_.x - _mainBackObj.x;
                  _loc5_ = _loc3_.y - _mainBackObj.y;
               }
               _loc3_ = _roomGrid.findClosestOpenGridCell(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
               if(_loc3_)
               {
                  param1 = _loc3_.x - _mainBackObj.x;
                  param2 = _loc3_.y - _mainBackObj.y;
                  this._followPath = _roomGrid.findPathOptimized(new Point(_loc4_ + _mainBackObj.x,_loc5_ + _mainBackObj.y),new Point(param1 + _mainBackObj.x,param2 + _mainBackObj.y));
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
      
      public function setGridDepth(param1:uint) : void
      {
         _roomGrid.setGridDepth(param1);
      }
      
      private function movePlayerOnPath() : void
      {
         var _loc1_:Object = null;
         if(_mainBackObj)
         {
            _loc1_ = _roomGrid.getCellIndexToWorldPos(this._followPath[0]);
            AvatarManager.movePlayer(_loc1_.x - _mainBackObj.x,_loc1_.y - _mainBackObj.y);
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
      
      protected function killPlayerPath() : void
      {
         this._followPath = null;
      }
      
      public function attachAvatarToSlide(param1:AvatarWorldView, param2:String, param3:String = null) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:* = undefined;
         var _loc6_:Point = new Point();
         var _loc7_:Array = this._slideList[param2];
         if(param3)
         {
            this._playerSlideSpawnPoint = param3;
         }
         if(_loc7_ == null && Boolean(_layers))
         {
            _loc4_ = 0;
            while(_loc4_ < _layers.length)
            {
               _loc8_ = _layers[_loc4_];
               if(_loc8_.name == param2)
               {
                  break;
               }
               _loc4_++;
            }
            if(_loc8_)
            {
               _loc9_ = _loc8_.s.content;
               _loc7_ = [];
               _loc4_ = 0;
               while(_loc4_ < _loc9_.totalFrames)
               {
                  _loc9_.gotoAndStop(_loc4_);
                  _loc6_.x = _loc9_.player.x + _loc8_.x;
                  _loc6_.y = _loc9_.player.y + _loc8_.y;
                  convertToWorldSpace(_loc6_);
                  _loc7_[_loc4_] = {
                     "x":_loc6_.x,
                     "y":_loc6_.y
                  };
                  _loc4_++;
               }
               this._slideList[param2] = _loc7_;
            }
         }
         if(Boolean(_loc7_) && Boolean(param1))
         {
            param1.startSlide(_loc7_);
         }
         this._movePlayerToPos = null;
         this._followPath = null;
         this._bMouseDown = false;
      }
   }
}

