package pet
{
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import gui.SharedAvatarAnimalConstants;
   
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
      
      public static const PET_SPARKLE_TIME:int = 60 * 5 * 24;
      
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
         super(param2,param3,param4,this.onPetLoaded);
         this._sparkle = param5;
         this._parent = param1;
         this._targetX = 0;
         this._bNewTarget = true;
         this._mode = 1;
         this._lastAnim = -1;
         this._bUpdateState = true;
         this._bFlip = false;
         this._bBack = false;
         this._bSpecialMove = false;
         this._parent.addChild(this);
         if(param1.userName == gMainFrame.server.userName)
         {
            this.addEventListener(MouseEvent.MOUSE_DOWN,this.onClick,false,0,true);
         }
         if(_type == PetManager.TYPE_LAND_LOW || _type == PetManager.TYPE_OCEAN_LOW || _type == PetManager.TYPE_AMPHIB_LOW)
         {
            this._y = 0;
         }
         else
         {
            this._y = this._airPetYOffest;
         }
         this._parentLastX = this._parent.x;
         this._parentLastY = this._parent.y;
         if(_type == PetManager.TYPE_OCEAN_LOW)
         {
            this._minX -= this._oceanPetXOffset;
            this._maxX += this._oceanPetXOffset;
         }
         else if(_type == PetManager.TYPE_LAND_LOW)
         {
            if(param1.avTypeId != SharedAvatarAnimalConstants.AV_KOALA)
            {
               this._minX -= this._petLandLowXOffset;
            }
         }
         this._x = 0;
         this._targetX = 0;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClick);
      }
      
      public function heartbeat() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Matrix = null;
         var _loc4_:int = 0;
         if(_content)
         {
            if(this._targetX == 0)
            {
               this._targetX = this._parent.hFlip ? int(this._minX) : int(this._maxX);
            }
            if(this._parentLastX != this._parent.x)
            {
               this._bFlip = this._parent.x > this._parentLastX ? true : false;
               if(Math.abs(this._parentLastX - this._parent.x) > 13)
               {
                  this._targetX = this._bFlip ? int(this._minX) : int(this._maxX);
               }
               this._parentLastX = this._parent.x;
            }
            if(this._parentLastY != this._parent.y)
            {
               this._bBack = this._parent.y < this._parentLastY - 10 ? true : false;
               this._parentLastY = this._parent.y;
            }
            if(this._x > this._targetX)
            {
               this._x -= 10;
               if(this._x <= this._targetX)
               {
                  this._x = this._targetX;
               }
               this._bFlip = this._x == this._targetX ? true : false;
            }
            if(this._x < this._targetX)
            {
               this._x += 10;
               if(this._x > this._targetX)
               {
                  this._x = this._targetX;
               }
               this._bFlip = this._x == this._targetX ? false : true;
            }
            if(this._bUpdateState)
            {
               PetManager.setPetState(_content,_lBits,_uBits,_eBits);
               this._bUpdateState = false;
            }
            _loc1_ = this._parent.inSplashVolume() ? ANIM_IDLE_WATER : ANIM_IDLE;
            if(Boolean(_loc1_) && this._parent.splashLiquid == "mud")
            {
               _loc1_ = ANIM_IDLE_MUD;
            }
            if(this._parent.splashLiquid != "mud" && this._parent.splashLiquid != "water")
            {
               _loc1_ = ANIM_IDLE;
            }
            _loc2_ = this._parent.isPetMovingTest() ? 1 : 0;
            if(this._x != this._targetX)
            {
               _loc2_ = 1;
            }
            _loc3_ = _content.transform.matrix;
            _loc3_.identity();
            _loc3_.scale(this._bFlip ? -this._scale : this._scale,this._scale);
            _loc3_.translate(this._x,this._y);
            _content.transform.matrix = _loc3_;
            _loc4_ = _loc1_ + _loc2_;
            if(this._bBack)
            {
               _loc4_ += 2;
            }
            if(this._lastAnim != _loc4_)
            {
               this._lastAnim = _loc4_;
               _content.pet.setAnim(_loc4_);
            }
            if(this._bSpecialMove)
            {
               this._bSpecialMove = false;
               if(!_loc2_)
               {
                  _content.pet.setAnim(ANIM_CLICK + _loc1_);
               }
            }
         }
      }
      
      public function setState(param1:Array) : void
      {
         _lBits = param1[0];
         _uBits = param1[1];
         _eBits = param1[2];
         this._bUpdateState = true;
      }
      
      public function setAction(param1:int, param2:int = 0) : void
      {
         switch(param1)
         {
            case ACTION_CLICK:
               this.onClick();
               break;
            case ACTION_SPARKLE:
               setSparkle(param2);
         }
      }
      
      private function onClick(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
            UserCommXtCommManager.sendPetAction(WorldPet.ACTION_CLICK);
         }
         this._bSpecialMove = true;
      }
      
      private function onPetLoaded(param1:MovieClip) : void
      {
         _content.pet.setSparkle(this._sparkle);
      }
   }
}

