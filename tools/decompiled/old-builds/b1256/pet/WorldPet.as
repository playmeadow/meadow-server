package pet
{
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import gui.GuiManager;
   
   public class WorldPet extends PetBase
   {
      
      public static const ANIM_IDLE:int = 0;
      
      public static const ANIM_MOVE:int = 1;
      
      public static const ANIM_IDLE_UP:int = 2;
      
      public static const ANIM_MOVE_UP:int = 3;
      
      public static const ANIM_CLICK:int = 4;
      
      public static const ANIM_IDLE_WATER:int = 10;
      
      public static const ANIM_IDLE_MUD:int = 20;
      
      public static const ACTION_CLICK:int = 0;
      
      public static const ACTION_SPARKLE:int = 1;
      
      public static const PET_SPARKLE_TIME:int = 7200;
      
      private var _parent:AvatarWorldView;
      
      private var _mode:int;
      
      private var _x:int;
      
      private var _y:int;
      
      private var _targetX:int;
      
      private var _targetY:int;
      
      private var _bNewTarget:Boolean;
      
      private var _dirX:Number;
      
      private var _dirY:Number;
      
      private var _speed:Number;
      
      private var _lastAnim:int;
      
      private var _bFlip:Boolean;
      
      private var _bBack:Boolean;
      
      private var _bUpdateState:Boolean;
      
      private var _parentLastX:Number;
      
      private var _parentLastY:Number;
      
      private var _bSpecialMove:Boolean;
      
      private var _petLoaded:Boolean;
      
      private var _sparkle:int;
      
      private var _offsetX:int = 100;
      
      private var _offsetY:int = -50;
      
      private var _maxSpeed:Number = 1;
      
      private var _accel:Number = 0.03;
      
      private var _scale:Number = 1;
      
      private var _minX:Number = -70;
      
      private var _maxX:Number = 55;
      
      private var _airPetYOffest:Number = -80;
      
      private var _oceanPetXOffset:Number = 55;
      
      private var _petLandLowXOffset:Number = 30;
      
      public function WorldPet(param1:AvatarWorldView, param2:uint, param3:uint, param4:uint, param5:int = 0)
      {
         super(param2,param3,param4,onPetLoaded);
         _sparkle = param5;
         _parent = param1;
         _targetX = 0;
         _bNewTarget = true;
         _mode = 1;
         _lastAnim = -1;
         _bUpdateState = true;
         _bFlip = false;
         _bBack = false;
         _bSpecialMove = false;
         _parent.addChild(this);
         if(param1.userName.toLowerCase() == gMainFrame.server.userName.toLowerCase() && !GuiManager.isBeYourPetRoom())
         {
            this.addEventListener("mouseDown",onClick,false,0,true);
         }
         if(_type == 0 || _type == 2 || _type == 4)
         {
            if(GuiManager.isBeYourPetRoom())
            {
               _y = -5;
               GuiManager.actionMgr.grayOutPetDanceBtn(false);
            }
            else
            {
               _y = 0;
            }
         }
         else
         {
            GuiManager.actionMgr.grayOutPetDanceBtn(true);
            if(GuiManager.isBeYourPetRoom())
            {
               _y = -5;
            }
            else
            {
               _y = _airPetYOffest;
            }
         }
         _parentLastX = _parent.x;
         _parentLastY = _parent.y;
         if(GuiManager.isBeYourPetRoom())
         {
            _minX = 25;
            _maxX = -30;
            _x = _maxX;
            _parentLastX = 0;
         }
         else
         {
            if(_type == 2)
            {
               _minX -= _oceanPetXOffset;
               _maxX += _oceanPetXOffset;
            }
            else if(_type == 0)
            {
               if(param1.avTypeId != 5)
               {
                  _minX -= _petLandLowXOffset;
               }
            }
            _x = 0;
         }
         _targetX = 0;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.removeEventListener("mouseDown",onClick);
      }
      
      public function heartbeat(param1:int) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:Matrix = null;
         var _loc2_:int = 0;
         if(_content)
         {
            _loc4_ = _parent.isPetMovingTest() ? 1 : 0;
            if(GuiManager.isBeYourPetRoom())
            {
               if(_parentLastX != _parent.x)
               {
                  if(_parent.x > _parentLastX)
                  {
                     if(!_bFlip)
                     {
                        _parent.flipSplash(true);
                        _bFlip = true;
                        _x = _minX;
                     }
                  }
                  else if(_bFlip)
                  {
                     _parent.flipSplash(false);
                     _bFlip = false;
                     _x = _maxX;
                  }
                  _parentLastX = _parent.x;
               }
            }
            else
            {
               if(_targetX == 0)
               {
                  _targetX = _parent.hFlip ? _minX : _maxX;
               }
               if(_parentLastX != _parent.x)
               {
                  _bFlip = _parent.x > _parentLastX ? true : false;
                  if(Math.abs(_parentLastX - _parent.x) > 13)
                  {
                     _targetX = _bFlip ? _minX : _maxX;
                  }
                  _parentLastX = _parent.x;
               }
               if(_parentLastY != _parent.y)
               {
                  _bBack = _parent.y < _parentLastY - 10 ? true : false;
                  _parentLastY = _parent.y;
               }
               if(_x > _targetX)
               {
                  _x -= 10;
                  if(_x <= _targetX)
                  {
                     _x = _targetX;
                  }
                  _bFlip = _x == _targetX ? true : false;
               }
               if(_x < _targetX)
               {
                  _x += 10;
                  if(_x > _targetX)
                  {
                     _x = _targetX;
                  }
                  _bFlip = _x == _targetX ? false : true;
               }
               if(_x != _targetX)
               {
                  _loc4_ = 1;
               }
            }
            if(_bUpdateState)
            {
               PetManager.setPetState(_content,_lBits,_uBits,_eBits);
               _bUpdateState = false;
            }
            _loc3_ = _parent.inSplashVolume() ? 10 : 0;
            if(_loc3_ && _parent.splashLiquid == "mud")
            {
               _loc3_ = 20;
            }
            if(_parent.splashLiquid != "mud" && _parent.splashLiquid != "water")
            {
               _loc3_ = 0;
            }
            _loc5_ = _content.transform.matrix;
            _loc5_.identity();
            _loc5_.scale(_bFlip ? -_scale : _scale,_scale);
            _loc5_.translate(_x,_y - param1);
            _content.transform.matrix = _loc5_;
            _loc2_ = _loc3_ + _loc4_;
            if(_bBack)
            {
               _loc2_ += 2;
            }
            if(_lastAnim != _loc2_)
            {
               _lastAnim = _loc2_;
               _content.pet.setAnim(_loc2_);
            }
            if(_bSpecialMove)
            {
               _bSpecialMove = false;
               if(!_loc4_)
               {
                  _content.pet.setAnim(4 + _loc3_);
               }
            }
         }
      }
      
      public function setState(param1:Array) : void
      {
         _lBits = param1[0];
         _uBits = param1[1];
         _eBits = param1[2];
         _bUpdateState = true;
      }
      
      public function setAction(param1:int, param2:int = 0) : void
      {
         switch(param1)
         {
            case 0:
               onClick();
               break;
            case 1:
               setSparkle(param2);
         }
      }
      
      public function onClick(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
            UserCommXtCommManager.sendPetAction(0);
         }
         _bSpecialMove = true;
      }
      
      private function onPetLoaded(param1:MovieClip) : void
      {
         if(GuiManager.isBeYourPetRoom())
         {
            _content.pet.scaleX = _content.pet.scaleY = 2;
         }
         _content.pet.setSparkle(_sparkle);
      }
   }
}

