package room
{
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarWorldView;
   import com.sbi.analytics.GATracker;
   import com.sbi.debug.DebugUtility;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   import quest.QuestManager;
   
   public class RoomManagerView extends RoomManagerBase
   {
      
      protected static const USE_PLAYER_GOTO_SPAWN_LOCATION:String = "use_player_goto_spawn_location";
      
      private static const TAN_30:Number = 0.5773502691896;
      
      private static const PLAYER_INDICATOR_RADIUS:int = 8;
      
      public static var _speedMutiplier:int;
      
      protected var _mousePos:Point;
      
      protected var _bMouseMove:Boolean;
      
      protected var _bMouseDown:Boolean;
      
      protected var _bMouseDownNew:Boolean;
      
      protected var _bMouseRight:int;
      
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
      
      private var _textFieldJumpVelocity:TextField;
      
      private var _textFieldGravity:TextField;
      
      private var _textFieldJumpVelocityS:TextField;
      
      private var _textFieldGravityS:TextField;
      
      public function RoomManagerView()
      {
         super();
      }
      
      override public function init(param1:LayerManager) : void
      {
         super.init(param1);
         _followCursorPos = new Point();
         _mousePos = new Point();
         _slideList = [];
         _keyboardEnabled = true;
         _debugLog = new String();
         _speedMutiplier = 1;
         gMainFrame.stage.addEventListener("mouseMove",onMouseMoveEvt);
         gMainFrame.stage.addEventListener("mouseDown",onMouseDownEvt);
         gMainFrame.stage.addEventListener("mouseUp",onMouseUpEvt);
         gMainFrame.stage.addEventListener("rightMouseDown",onMouseRightEvt);
         gMainFrame.stage.addEventListener("rightMouseUp",onMouseRightUpEvt);
         gMainFrame.stage.addEventListener("focusOut",onDeactivate);
         gMainFrame.stage.addEventListener("deactivate",onDeactivate);
         gMainFrame.stage.addEventListener("keyDown",onKeyDownEvt);
         gMainFrame.stage.addEventListener("keyUp",onKeyUpEvt);
         _miniMaps = new Dictionary();
         _avatarDirection = new Point();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         gMainFrame.stage.removeEventListener("mouseMove",onMouseMoveEvt);
         gMainFrame.stage.removeEventListener("mouseDown",onMouseDownEvt);
         gMainFrame.stage.removeEventListener("mouseUp",onMouseUpEvt);
         gMainFrame.stage.removeEventListener("rightMouseDown",onMouseRightEvt);
         gMainFrame.stage.removeEventListener("rightMouseUp",onMouseRightUpEvt);
         gMainFrame.stage.removeEventListener("focusOut",onDeactivate);
         gMainFrame.stage.removeEventListener("deactivate",onDeactivate);
         gMainFrame.stage.removeEventListener("keyDown",onKeyDownEvt);
         gMainFrame.stage.removeEventListener("keyUp",onKeyUpEvt);
      }
      
      override public function exitRoom(param1:Boolean = false) : void
      {
         super.exitRoom(param1);
         _movePlayerToPos = null;
         _bMouseDown = false;
         _bMouseDownNew = false;
         _bMouseMove = false;
         _bTestPortal = false;
         _playerSlideSpawnPoint = null;
         _slideList = [];
         _avatarDirection.x = _avatarDirection.y = 0;
      }
      
      override protected function onRoomLoaded_base(param1:Function, param2:Object, param3:Boolean = false) : void
      {
         _movePlayerToPos = null;
         _followPath = null;
         _bMouseDown = false;
         _bMouseDownNew = false;
         _lastGridCell = -1;
         _avLastValidCell = -1;
         super.onRoomLoaded_base(param1,param2,param3);
      }
      
      public function setGotoSpawnLocation(param1:int, param2:int) : void
      {
         _playerGotoSpawnLocationX = param1;
         _playerGotoSpawnLocationY = param2;
         _playerGotoSpawnPoint = "use_player_goto_spawn_location";
      }
      
      public function setGotoSpawnPoint(param1:String) : void
      {
         _playerGotoSpawnPoint = param1;
      }
      
      public function resetThrottle() : void
      {
         _followCursorThrottle = 0;
      }
      
      protected function walkToSpawn(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Point = null;
         _loc2_ = findSpawn(_spawns,param1);
         if(_loc2_)
         {
            _bTestPortal = false;
            _movePlayerToPos = new Point(_loc2_.x,_loc2_.y);
            _loc3_ = getRandomRadiusOffset(_loc2_.r);
            _movePlayerToPos.x += _loc3_.x;
            _movePlayerToPos.y += _loc3_.y;
            convertToWorldSpace(_movePlayerToPos);
         }
      }
      
      private function onKeyDownEvt(param1:KeyboardEvent, param2:String = null) : void
      {
         if(QuestManager.isSideScrollQuest())
         {
            switch(int(param1.keyCode) - 32)
            {
               case 0:
                  break;
               case 5:
               case 6:
               case 7:
               case 8:
                  gMainFrame.stage.focus = null;
                  break;
               default:
                  if(_textFieldGravity == null)
                  {
                     GuiManager.setFocusToChatTextWithEvent(param1,param2);
                  }
            }
         }
         var _loc3_:Boolean = false;
         switch(param1.keyCode)
         {
            case 17:
               break;
            case 37:
               if(_ctrlPressed)
               {
                  _speedMutiplier = 1;
               }
               else if(_avatarDirection.x >= 0)
               {
                  _leftArrow = true;
                  _loc3_ = true;
                  _avatarDirection.x = -1;
               }
               break;
            case 39:
               if(_ctrlPressed)
               {
                  if(QuestManager.isSideScrollQuest() && AvatarManager.playerAvatarWorldView)
                  {
                     AvatarManager.playerAvatarWorldView._bArrowEnabled = !AvatarManager.playerAvatarWorldView._bArrowEnabled;
                  }
                  _speedMutiplier = 1;
               }
               else if(_avatarDirection.x <= 0)
               {
                  _rightArrow = true;
                  _loc3_ = true;
                  _avatarDirection.x = 1;
               }
               break;
            case 38:
               if(_ctrlPressed)
               {
                  if(QuestManager.isSideScrollQuest())
                  {
                     AvatarManager.playerAvatarWorldView.float(true);
                  }
                  _speedMutiplier = _speedMutiplier + 1;
               }
               else if(QuestManager.isSideScrollQuest() == false)
               {
                  if(_avatarDirection.y >= 0)
                  {
                     _upArrow = true;
                     _loc3_ = true;
                     _avatarDirection.y = -1;
                  }
               }
               else
               {
                  _upArrow = true;
               }
               break;
            case 40:
               if(_ctrlPressed)
               {
                  if(QuestManager.isSideScrollQuest())
                  {
                     AvatarManager.playerAvatarWorldView.float(false);
                  }
                  _speedMutiplier = _speedMutiplier - 1;
               }
               else if(QuestManager.isSideScrollQuest() == false)
               {
                  if(_avatarDirection.y <= 0)
                  {
                     _downArrow = true;
                     _loc3_ = true;
                     _avatarDirection.y = 1;
                  }
               }
               else
               {
                  _downArrow = true;
               }
         }
         if(_loc3_ && QuestManager.isSideScrollQuest() == false)
         {
            if(AvatarManager.roomEnviroType == 0 && Math.abs(_avatarDirection.x) > 0 && Math.abs(_avatarDirection.y) > 0)
            {
               _avatarDirection.y = (_avatarDirection.y > 0 ? 1 : -1) * 0.5773502691896 * Math.abs(_avatarDirection.x);
            }
            _avatarDirection.normalize(1);
         }
      }
      
      public function textInputCapture(param1:KeyboardEvent) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(param1.currentTarget == _textFieldGravity)
         {
            _loc3_ = Number(_textFieldGravity.text);
            if(_loc3_ > 1000 && _loc3_ < 4000)
            {
               AvatarManager.playerAvatarWorldView.GRAVITY = _loc3_;
            }
         }
         else
         {
            _loc2_ = Number(_textFieldJumpVelocity.text);
            if(_loc2_ < 4000 && _loc2_ > 200)
            {
               AvatarManager.playerAvatarWorldView.BOUNCE_SPEED = _loc2_;
            }
         }
      }
      
      public function updatePlayerPos(param1:int, param2:int) : void
      {
         if(_miniMap != null)
         {
            param1 = ((param1 + _mainBackObj.x - _grid.min.x) / _grid.r2 - _miniMap.offsetX) * _miniMap.scale + _miniMap.centerOffsetX;
            param2 = ((param2 + _mainBackObj.y - _grid.min.y) / _grid.r2 - _miniMap.offsetY) * _miniMap.scale + _miniMap.centerOffsetY;
            if(_miniMapStamp == null)
            {
               _miniMapStamp = new Shape();
               _miniMapStamp.graphics.beginFill(0,0.1);
               _miniMapStamp.graphics.drawCircle(0,0,8);
               _miniMapStamp.graphics.endFill();
               _miniMapMatrix = new Matrix();
            }
            if(_miniMapMatrix.tx != param1 || _miniMapMatrix.ty != param2)
            {
               _miniMapMatrix.tx = param1;
               _miniMapMatrix.ty = param2;
               _miniMap.overlay.bitmapData.draw(_miniMapStamp,_miniMapMatrix,null,"alpha");
               _miniMap.playerIndicator.x = param1;
               _miniMap.playerIndicator.y = param2;
            }
         }
      }
      
      public function removeAndClearMiniMap() : void
      {
         if(_miniMap && _miniMap.parent)
         {
            _miniMap.parent.removeChild(_miniMap);
         }
         _miniMap = null;
         _miniMaps = new Dictionary();
      }
      
      public function removeMiniMap() : void
      {
         if(_miniMap && _miniMap.parent)
         {
            _miniMap.parent.removeChild(_miniMap);
         }
         _miniMap = null;
      }
      
      public function updateMinimap() : void
      {
         var _loc1_:Bitmap = null;
         var _loc4_:BitmapData = null;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         if(_miniMap && _miniMap.parent && !_miniMap.hasOwnProperty("noUpdates"))
         {
            _loc1_ = _miniMap.getChildAt(1) as Bitmap;
            if(_loc1_)
            {
               _loc4_ = _loc1_.bitmapData;
               _loc5_ = 0;
               while(_loc5_ < _miniMap.croppedHeight)
               {
                  _loc2_ = _miniMap.leftX + (_loc5_ + _miniMap.topY) * _grid.width;
                  _loc6_ = 0;
                  while(_loc6_ < _miniMap.croppedWidth)
                  {
                     _loc3_ = int(_grid.grid[_loc6_ + _loc2_]);
                     if(_loc3_ == 0)
                     {
                        _loc4_.setPixel(_loc6_,_loc5_,8024881);
                     }
                     _loc6_++;
                  }
                  _loc5_++;
               }
            }
         }
      }
      
      private function mapBitmapLoaded(param1:MovieClip) : void
      {
         param1.scaleX = param1.scaleY = 0.5;
         _miniMap.addChildAt(param1,1);
      }
      
      public function createMiniMap() : void
      {
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc7_:int = 0;
         var _loc18_:Boolean = false;
         var _loc9_:Number = NaN;
         var _loc20_:int = 0;
         var _loc6_:int = 0;
         var _loc21_:int = 0;
         var _loc23_:int = 0;
         var _loc4_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc11_:BitmapData = null;
         var _loc14_:int = 0;
         var _loc16_:int = 0;
         var _loc10_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc15_:Bitmap = null;
         var _loc17_:Array = null;
         var _loc8_:Array = null;
         var _loc22_:MediaHelper = null;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc19_:Sprite = null;
         if(GuiManager.mainHud.miniMap != null)
         {
            _miniMap = _miniMaps[_pathName];
            if(_miniMap)
            {
               GuiManager.mainHud.miniMap.ba.itemLayer.addChild(_miniMap);
            }
            else if(_grid)
            {
               _miniMap = new MovieClip();
               _loc9_ = 0;
               _loc18_ = false;
               _loc25_ = 0;
               while(_loc25_ < _grid.width)
               {
                  _loc24_ = 0;
                  while(_loc24_ < _grid.height)
                  {
                     _loc7_ = int(_grid.grid[_loc25_ + _loc24_ * _grid.width]);
                     if(_loc7_ == 0)
                     {
                        _loc20_ = _loc25_;
                        _loc18_ = true;
                        break;
                     }
                     _loc24_++;
                  }
                  if(_loc18_)
                  {
                     break;
                  }
                  _loc25_++;
               }
               _loc18_ = false;
               _loc25_ = _grid.width - 1;
               while(_loc25_ >= 0)
               {
                  _loc24_ = 0;
                  while(_loc24_ < _grid.height)
                  {
                     _loc7_ = int(_grid.grid[_loc25_ + _loc24_ * _grid.width]);
                     if(_loc7_ == 0)
                     {
                        _loc6_ = _loc25_;
                        _loc18_ = true;
                        break;
                     }
                     _loc24_++;
                  }
                  if(_loc18_)
                  {
                     break;
                  }
                  _loc25_--;
               }
               _loc18_ = false;
               _loc24_ = 0;
               while(_loc24_ < _grid.height)
               {
                  _loc4_ = _loc24_ * _grid.width;
                  _loc25_ = 0;
                  while(_loc25_ < _grid.width)
                  {
                     _loc7_ = int(_grid.grid[_loc25_ + _loc4_]);
                     if(_loc7_ == 0)
                     {
                        _loc21_ = _loc24_;
                        _loc18_ = true;
                        break;
                     }
                     _loc25_++;
                  }
                  if(_loc18_)
                  {
                     break;
                  }
                  _loc24_++;
               }
               _loc18_ = false;
               _loc24_ = _grid.height - 1;
               while(_loc24_ >= 0)
               {
                  _loc4_ = _loc24_ * _grid.width;
                  _loc25_ = 0;
                  while(_loc25_ < _grid.width)
                  {
                     _loc7_ = int(_grid.grid[_loc25_ + _loc4_]);
                     if(_loc7_ == 0)
                     {
                        _loc23_ = _loc24_;
                        _loc18_ = true;
                        break;
                     }
                     _loc25_++;
                  }
                  if(_loc18_)
                  {
                     break;
                  }
                  _loc24_--;
               }
               _miniMap.offsetX = _loc20_;
               _miniMap.offsetY = _loc21_;
               _loc12_ = int(GuiManager.mainHud.miniMap.ba.itemLayer.width);
               _loc13_ = int(GuiManager.mainHud.miniMap.ba.itemLayer.height);
               _loc11_ = new BitmapData(_loc12_,_loc13_,true,4278190080);
               _miniMap.addChild(new Bitmap(_loc11_,"auto",true));
               _loc14_ = _loc6_ - _loc20_ + 1;
               _loc16_ = _loc23_ - _loc21_ + 1;
               _miniMap.croppedWidth = _loc14_;
               _miniMap.croppedHeight = _loc16_;
               _miniMap.leftX = _loc20_;
               _miniMap.topY = _loc21_;
               _loc11_ = new BitmapData(_loc14_,_loc16_,false,0);
               _loc24_ = 0;
               while(_loc24_ < _loc16_)
               {
                  _loc4_ = _loc20_ + (_loc24_ + _loc21_) * _grid.width;
                  _loc25_ = 0;
                  while(_loc25_ < _loc14_)
                  {
                     _loc7_ = int(_grid.grid[_loc25_ + _loc4_]);
                     if(_loc7_ == 0)
                     {
                        _loc11_.setPixel(_loc25_,_loc24_,8024881);
                     }
                     _loc25_++;
                  }
                  _loc24_++;
               }
               _loc10_ = _loc14_ / _loc16_;
               _loc5_ = _loc12_ / _loc13_;
               _loc17_ = volumeManager.findVolume("map");
               if(_loc17_)
               {
                  _loc8_ = _loc17_[0].message.split(",");
                  _loc22_ = new MediaHelper();
                  _loc15_ = new Bitmap();
                  _loc22_.init(_loc8_[_loc8_.length > QuestManager._questDifficultyLevel ? QuestManager._questDifficultyLevel : 0],mapBitmapLoaded);
                  _miniMap.noUpdates = 1;
               }
               else
               {
                  _loc15_ = new Bitmap(_loc11_,"auto",true);
                  _miniMap.addChild(_loc15_);
               }
               _loc3_ = _loc10_ < _loc5_ ? _loc13_ / _loc16_ : _loc12_ / _loc14_;
               _loc15_.scaleX = _loc15_.scaleY = _miniMap.scale = _loc3_;
               _loc1_ = (_loc12_ - _loc14_ * _loc3_) * 0.5;
               _loc2_ = (_loc13_ - _loc16_ * _loc3_) * 0.5;
               _miniMap.centerOffsetX = _loc1_;
               _miniMap.centerOffsetY = _loc2_;
               _loc15_.x += _loc1_;
               _loc15_.y += _loc2_;
               _loc19_ = new Sprite();
               _miniMap.addChild(_loc19_);
               _loc19_.blendMode = "layer";
               _loc11_ = new BitmapData(_loc12_,_loc13_,true,4278190080);
               _miniMap.overlay = new Bitmap(_loc11_,"auto",true);
               _loc19_.addChild(_miniMap.overlay);
               _miniMap.x = -_miniMap.width * 0.5;
               _miniMap.y = -_miniMap.height * 0.5;
               GuiManager.mainHud.miniMap.ba.itemLayer.addChild(_miniMap);
               _miniMap.playerIndicator = GETDEFINITIONBYNAME("miniMapDotCont");
               _miniMap.addChild(_miniMap.playerIndicator);
               _miniMaps[_pathName] = _miniMap;
            }
         }
      }
      
      private function onKeyUpEvt(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         switch(param1.keyCode)
         {
            case 17:
               _ctrlPressed = false;
               break;
            case 37:
               if(_leftArrow)
               {
                  _leftArrow = false;
                  if(_avatarDirection.x < 0)
                  {
                     _avatarDirection.x = _rightArrow ? 1 : 0;
                     _loc2_ = true;
                  }
               }
               break;
            case 39:
               if(_rightArrow)
               {
                  _rightArrow = false;
                  if(_avatarDirection.x > 0)
                  {
                     _avatarDirection.x = _leftArrow ? -1 : 0;
                     _loc2_ = true;
                  }
               }
               break;
            case 38:
               if(_upArrow)
               {
                  _upArrow = false;
                  if(_avatarDirection.y < 0 && QuestManager.isSideScrollQuest() == false)
                  {
                     _avatarDirection.y = _downArrow ? 1 : 0;
                     _loc2_ = true;
                  }
               }
               break;
            case 40:
               if(_downArrow)
               {
                  _downArrow = false;
                  if(_avatarDirection.y > 0 && QuestManager.isSideScrollQuest() == false)
                  {
                     _avatarDirection.y = _upArrow ? -1 : 0;
                     _loc2_ = true;
                  }
               }
         }
         if(_loc2_ && QuestManager.isSideScrollQuest() == false)
         {
            _avatarDirection.normalize(1);
         }
      }
      
      private function onDeactivate(param1:Event) : void
      {
         _leftArrow = _rightArrow = _upArrow = _downArrow = _bMouseDown = false;
         _avatarDirection.x = _avatarDirection.y = _bMouseRight = 0;
      }
      
      private function onMouseMoveEvt(param1:MouseEvent) : void
      {
         if(GuiManager.isModal() || DarkenManager.isDarkened)
         {
            return;
         }
         if(_layerManager.bkg == null || _mainBackObj == null || !_bTestPortal)
         {
            return;
         }
         if(_bMouseDown)
         {
            _followCursorPos.x = param1.stageX;
            _followCursorPos.y = param1.stageY;
            if(_drawPath)
            {
               _debugLog = _debugLog.concat(getTimer() - _startTime + " MOUSE_MOVE, stageX=" + param1.stageX + ", stageY=" + param1.stageY);
               if(_computeCoordinates)
               {
                  _immediateCoordinates = convertScreenToWorldSpace(_followCursorPos.x,_followCursorPos.y);
                  _debugLog = _debugLog.concat(" worldX=" + _immediateCoordinates.x + ", worldY=" + _immediateCoordinates.y);
               }
               _debugLog = _debugLog.concat("\n");
            }
         }
         _mousePos.x = param1.stageX;
         _mousePos.y = param1.stageY;
         _bMouseMove = true;
      }
      
      private function onMouseDownEvt(param1:MouseEvent) : void
      {
         GuiManager.handleMouseDown();
         if(GuiManager.isModal() || AvatarSwitch.isSwitching() || DarkenManager.isDarkened)
         {
            return;
         }
         if(_layerManager.bkg == null || _mainBackObj == null || !_bTestPortal)
         {
            return;
         }
         if(QuestManager.mouseHandleDown(param1) == false || QuestManager.isSideScrollQuest())
         {
            if(_drawPath)
            {
               if(_startTime < 0)
               {
                  _startTime = getTimer();
               }
               _debugLog = _debugLog.concat(getTimer() - _startTime + " MOUSE_DOWN, stageX=" + param1.stageX + ", stageY=" + param1.stageY);
               if(_computeCoordinates)
               {
                  _immediateCoordinates = convertScreenToWorldSpace(_followCursorPos.x,_followCursorPos.y);
                  _debugLog = _debugLog.concat(" worldX=" + _immediateCoordinates.x + ", worldY=" + _immediateCoordinates.y);
               }
               _debugLog = _debugLog.concat("\n");
            }
            _bMouseDown = true;
            _bMouseDownNew = true;
            _followCursorPos.x = param1.stageX;
            _followCursorPos.y = param1.stageY;
            _followCursorThrottle = 0;
            _mousePos.x = param1.stageX;
            _mousePos.y = param1.stageY;
            _bMouseMove = true;
         }
      }
      
      private function onMouseRightEvt(param1:MouseEvent) : void
      {
         _bMouseRight = _bMouseRight + 1;
      }
      
      private function onMouseRightUpEvt(param1:MouseEvent) : void
      {
         _bMouseRight = 0;
      }
      
      private function onMouseUpEvt(param1:MouseEvent) : void
      {
         forceMouseUp();
         if(_drawPath)
         {
            _debugLog = _debugLog.concat(getTimer() - _startTime + " MOUSE_UP\n");
         }
      }
      
      public function forceMouseUp() : void
      {
         _bMouseDown = false;
         _bMouseDownNew = false;
         _lastGridCell = -1;
      }
      
      public function setFocus(param1:Boolean = true) : void
      {
         if(!param1)
         {
            forceMouseUp();
         }
      }
      
      public function heartbeat_movePlayer(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         _frameTime = param2 / 1000;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         if(_movePlayerToPos)
         {
            movePlayerToLocation(_movePlayerToPos.x,_movePlayerToPos.y);
            _movePlayerToPos = null;
         }
         else if(AvatarManager.playerAvatarWorldView != null && !AvatarManager.playerAvatarWorldView.moving)
         {
            if(_playerSlideSpawnPoint)
            {
               walkToSpawn(_playerSlideSpawnPoint);
               _playerSlideSpawnPoint = null;
            }
            else if(_followPath)
            {
               movePlayerOnPath();
            }
            else
            {
               _bTestPortal = true;
            }
         }
         else if(_mainBackObj)
         {
            if(AvatarManager.playerAvatarWorldView != null && _mainBackObj != null)
            {
               _loc3_ = _roomGrid.getCellIndex(AvatarManager.playerAvatarWorldView.x + _mainBackObj.x,AvatarManager.playerAvatarWorldView.y + _mainBackObj.y);
               if(_avLastValidCell != _loc3_)
               {
                  _loc4_ = _roomGrid.convertCellToCoords(_loc3_);
                  if(!_roomGrid.testGridCell(_loc4_.x,_loc4_.y))
                  {
                     _avLastValidCell = _loc3_;
                  }
               }
            }
         }
      }
      
      private function sideScrollMovement() : void
      {
         if(_keyboardEnabled && !DarkenManager.isDarkened && !GuiManager.volumeMgr.visible && AvatarManager.playerAvatarWorldView && _movePlayerToPos == null && _followPath == null && _playerSlideSpawnPoint == null && _bTestPortal)
         {
            if(_drawPath)
            {
               drawDebugLayer(null);
            }
            if(AvatarManager.playerAvatarWorldView.animId == 22)
            {
               _avatarDirection.x = 0;
               AvatarManager.playerAvatarWorldView.sideScrollMovement(_avatarDirection,false,false,false,false,convertScreenToWorldSpace(gMainFrame.stage.mouseX,gMainFrame.stage.mouseY));
            }
            else if(_textFieldGravity == null)
            {
               AvatarManager.playerAvatarWorldView.sideScrollMovement(_avatarDirection,_upArrow,_downArrow,_leftArrow,_rightArrow,convertScreenToWorldSpace(gMainFrame.stage.mouseX,gMainFrame.stage.mouseY),_bMouseDown,_bMouseRight);
            }
         }
      }
      
      protected function followCursorTest() : void
      {
         var _loc6_:Point = null;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Boolean = false;
         if(QuestManager.isSideScrollQuest())
         {
            if(volumeManager.isSceneSet())
            {
               sideScrollMovement();
            }
            return;
         }
         if(_followCursorThrottle <= 0 && _bMouseDown)
         {
            if(_computeCoordinates && _immediateCoordinates)
            {
               _loc6_ = _immediateCoordinates;
            }
            else
            {
               _loc6_ = convertScreenToWorldSpace(_followCursorPos.x,_followCursorPos.y);
            }
            _loc5_ = _roomGrid.getCellIndex(_loc6_.x + _mainBackObj.x,_loc6_.y + _mainBackObj.y);
            if(_lastGridCell != _loc5_)
            {
               _lastGridCell = _loc5_;
               _movePlayerToPos = _loc6_;
               _followPath = null;
               _followCursorThrottle = 12;
               if(_drawPath)
               {
                  _debugLog = _debugLog.concat(getTimer() - _startTime + " Processing cursor posX=" + _followCursorPos.x + ", cursor posY=" + _followCursorPos.y + ", moving to " + _loc6_.x + "," + _loc6_.y + "\n");
               }
            }
         }
         else
         {
            _followCursorThrottle = _followCursorThrottle - 1;
         }
         if(_keyboardEnabled && !DarkenManager.isDarkened && !GuiManager.volumeMgr.visible && AvatarManager.playerAvatarWorldView && _movePlayerToPos == null && _followPath == null && _playerSlideSpawnPoint == null && _bTestPortal)
         {
            if(_avatarDirection.x != 0 || _avatarDirection.y != 0)
            {
               if(_frameTime >= 0.2)
               {
                  _frameTime = 0.2;
               }
               _loc6_ = new Point();
               _loc3_ = 24 * _speedMutiplier * _frameTime / 0.07;
               _loc1_ = _avatarDirection.x * _loc3_;
               _loc2_ = _avatarDirection.y * _loc3_;
               _loc6_.x = AvatarManager.playerAvatarWorldView.x;
               _loc6_.y = AvatarManager.playerAvatarWorldView.y;
               _loc4_ = true;
               if((_loc4_ || _forceCollision) && collisionTestGrid(_loc6_.x + _loc1_,_loc6_.y + _loc2_) != 0)
               {
                  if(_loc1_ != 0 && _loc2_ != 0)
                  {
                     if(collisionTestGrid(_loc6_.x,_loc6_.y + _loc2_) != 0)
                     {
                        if(collisionTestGrid(_loc6_.x + _loc1_,_loc6_.y) == 0)
                        {
                           AvatarManager.movePlayer(_loc6_.x + _loc1_,_loc6_.y);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(_loc6_.x,_loc6_.y + _loc2_);
                     }
                  }
                  else if(_loc1_ == 0)
                  {
                     _loc1_ = Math.abs(_loc2_);
                     if(collisionTestGrid(_loc6_.x + 25,_loc6_.y + _loc2_) != 0)
                     {
                        if(collisionTestGrid(_loc6_.x - 25,_loc6_.y + _loc2_) == 0)
                        {
                           AvatarManager.movePlayer(_loc6_.x - _loc1_,_loc6_.y + _loc2_);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(_loc6_.x + _loc1_,_loc6_.y + _loc2_);
                     }
                  }
                  else
                  {
                     _loc2_ = Math.abs(_loc1_);
                     if(collisionTestGrid(_loc6_.x + _loc1_,_loc6_.y - 25) != 0)
                     {
                        if(collisionTestGrid(_loc6_.x + _loc1_,_loc6_.y + 25) == 0)
                        {
                           AvatarManager.movePlayer(_loc6_.x + _loc1_,_loc6_.y + _loc2_);
                        }
                     }
                     else
                     {
                        AvatarManager.movePlayer(_loc6_.x + _loc1_,_loc6_.y - _loc2_);
                     }
                  }
               }
               else
               {
                  AvatarManager.movePlayer(_loc6_.x + _loc1_,_loc6_.y + _loc2_);
               }
            }
         }
      }
      
      protected function updateSplashVolumes() : void
      {
         var _loc5_:Object = null;
         var _loc2_:* = undefined;
         var _loc1_:Object = null;
         var _loc3_:String = null;
         if(_volumeManager.hasSplashVolume)
         {
            _loc5_ = AvatarManager.avatarViewList;
            for(var _loc4_:Object in _loc5_)
            {
               _loc2_ = _loc5_[_loc4_];
               _loc1_ = _volumeManager.testSplashVolumes(new Point(_loc2_.x,_loc2_.y));
               if(_loc1_)
               {
                  _loc3_ = _loc1_.message;
               }
               _loc2_.setSplashVolumeVolume(_loc1_);
            }
         }
      }
      
      protected function updateSocialVolumes() : void
      {
         _socialTriggerThrottle = _socialTriggerThrottle + 1;
         if(_socialTriggerThrottle > 20)
         {
            _socialTriggerThrottle = 0;
            _volumeManager.updateSocialTriggers(AvatarManager.avatarViewList);
         }
      }
      
      private function movePlayerToLocation(param1:int, param2:int) : void
      {
         var _loc5_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(AvatarManager.playerAvatar)
         {
            _loc3_ = AvatarManager.playerAvatarWorldView.x;
            _loc4_ = AvatarManager.playerAvatarWorldView.y;
            if(_roomGrid)
            {
               _loc5_ = _roomGrid.convertCellToCoords(_roomGrid.getCellIndex(_loc3_ + _mainBackObj.x,_loc4_ + _mainBackObj.y));
               if(_roomGrid.testGridCell(_loc5_.x,_loc5_.y) && _avLastValidCell >= 0)
               {
                  _loc5_ = _roomGrid.getCellIndexToWorldPos(_avLastValidCell);
                  _loc3_ = _loc5_.x - _mainBackObj.x;
                  _loc4_ = _loc5_.y - _mainBackObj.y;
               }
               _loc5_ = _roomGrid.findClosestOpenGridCell(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
               if(_loc5_)
               {
                  param1 = _loc5_.x - _mainBackObj.x;
                  param2 = _loc5_.y - _mainBackObj.y;
                  _followPath = _roomGrid.findPathOptimized(new Point(_loc3_ + _mainBackObj.x,_loc4_ + _mainBackObj.y),new Point(param1 + _mainBackObj.x,param2 + _mainBackObj.y));
                  if(_followPath == null || _followPath.length == 0)
                  {
                     _followPath = null;
                  }
                  else
                  {
                     if(_drawPath)
                     {
                        drawDebugLayer(_followPath);
                     }
                     movePlayerOnPath();
                  }
               }
            }
         }
      }
      
      public function setGridDepth(param1:uint) : void
      {
         _roomGrid.setGridDepth(param1);
      }
      
      public function getGridCellType() : int
      {
         var _loc1_:Object = null;
         if(_mainBackObj)
         {
            _loc1_ = _roomGrid.convertCellToCoords(_roomGrid.getCellIndex(AvatarManager.playerAvatarWorldView.x + _mainBackObj.x,AvatarManager.playerAvatarWorldView.y + _mainBackObj.y));
            return _roomGrid.testGridCell(_loc1_.x,_loc1_.y);
         }
         return 0;
      }
      
      private function movePlayerOnPath() : void
      {
         var _loc1_:Object = null;
         if(_mainBackObj)
         {
            _loc1_ = _roomGrid.getCellIndexToWorldPos(_followPath[0]);
            AvatarManager.movePlayer(_loc1_.x - _mainBackObj.x,_loc1_.y - _mainBackObj.y);
            if(_followPath.length == 1)
            {
               _followPath = null;
            }
            else
            {
               _followPath.splice(0,1);
            }
         }
      }
      
      public function killPlayerPath() : void
      {
         _followPath = null;
      }
      
      public function setMovePlayerPosition(param1:Point) : void
      {
         _movePlayerToPos = param1;
      }
      
      public function attachAvatarToSlide(param1:AvatarWorldView, param2:String, param3:String = null) : void
      {
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:Object = null;
         var _loc4_:* = undefined;
         var _loc8_:Point = new Point();
         var _loc5_:Array = _slideList[param2];
         DebugUtility.debugErrorTracking("attachAvatarToSlides spot 1");
         if(param3)
         {
            _playerSlideSpawnPoint = param3;
         }
         if(_loc5_ == null && _layers)
         {
            DebugUtility.debugErrorTracking("attachAvatarToSlides spot 2");
            _loc9_ = 0;
            while(_loc9_ < _layers.length)
            {
               _loc6_ = _layers[_loc9_];
               if(_loc6_ && _loc6_.name == param2)
               {
                  break;
               }
               _loc9_++;
            }
            if(_loc6_ && _loc6_.s)
            {
               DebugUtility.debugErrorTracking("attachAvatarToSlides spot 3");
               _loc4_ = _loc6_.s.content;
               if(_loc4_ != null)
               {
                  _loc5_ = [];
                  if("totalFrames" in _loc4_)
                  {
                     DebugUtility.debugErrorTracking("attachAvatarToSlides spot 4");
                     _loc9_ = 0;
                     while(_loc9_ < _loc4_.totalFrames)
                     {
                        _loc4_.gotoAndStop(_loc9_);
                        if("player" in _loc4_)
                        {
                           _loc8_.x = _loc4_.player.x + _loc6_.x;
                           _loc8_.y = _loc4_.player.y + _loc6_.y;
                           convertToWorldSpace(_loc8_);
                           _loc5_[_loc9_] = {
                              "x":_loc8_.x,
                              "y":_loc8_.y
                           };
                        }
                        else
                        {
                           GATracker.trackError("AttachAvatarToSlide: player not in c where c is " + _loc4_ + ("name" in _loc4_ ? " name is " + _loc4_.name : ""),false);
                        }
                        _loc9_++;
                     }
                     DebugUtility.debugErrorTracking("attachAvatarToSlides spot 5");
                     _slideList[param2] = _loc5_;
                  }
               }
            }
         }
         DebugUtility.debugErrorTracking("attachAvatarToSlides spot 6");
         if(_loc5_ && param1)
         {
            param1.startSlide(_loc5_);
         }
         DebugUtility.debugErrorTracking("attachAvatarToSlides spot 7");
         _movePlayerToPos = null;
         _followPath = null;
         _bMouseDown = false;
         DebugUtility.clearDebugErrorTracking();
      }
      
      public function getLengthLineIntersectGrid(param1:Point, param2:Point, param3:Number) : Number
      {
         var _loc8_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:Number = Math.sqrt((param1.x - param2.x) * (param1.x - param2.x) + (param1.y - param2.y) * (param1.y - param2.y));
         var _loc6_:Number = (param2.x - param1.x) / _loc9_;
         var _loc10_:Number = (param2.y - param1.y) / _loc9_;
         var _loc12_:Number = 10;
         var _loc11_:Number = Number(_grid.r2);
         while(_loc12_ < param3)
         {
            _loc8_ = param1.x + _loc6_ * _loc12_;
            _loc5_ = param1.y + _loc10_ * _loc12_;
            _loc4_ = (_loc8_ + _mainBackObj.x - _grid.min.x) / _grid.r2;
            _loc7_ = (_loc5_ + _mainBackObj.y - _grid.min.y) / _grid.r2;
            if(_roomGrid.testGridCell(_loc4_,_loc7_) == 1)
            {
               break;
            }
            _loc12_ += _loc11_;
         }
         return _loc12_ + 50;
      }
   }
}

