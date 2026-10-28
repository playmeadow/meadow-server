package pet
{
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import gui.GuiManager;
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
      
      public function WorldPet(parent:AvatarWorldView, lBits:uint, uBits:uint, eBits:uint, sparkle:int = 0)
      {
         super(lBits,uBits,eBits,this.onPetLoaded);
         this._sparkle = sparkle;
         this._parent = parent;
         this._targetX = 0;
         this._bNewTarget = true;
         this._mode = 1;
         this._lastAnim = -1;
         this._bUpdateState = true;
         this._bFlip = false;
         this._bBack = false;
         this._bSpecialMove = false;
         this._parent.addChild(this);
         if(parent.userName == gMainFrame.server.userName && !GuiManager.isBeYourPetRoom())
         {
            this.addEventListener(MouseEvent.MOUSE_DOWN,this.onClick,false,0,true);
         }
         if(_type == PetManager.TYPE_LAND_LOW || _type == PetManager.TYPE_OCEAN_LOW || _type == PetManager.TYPE_AMPHIB_LOW)
         {
            if(GuiManager.isBeYourPetRoom())
            {
               this._y = -5;
               GuiManager.actionMgr.grayOutPetDanceBtn(false);
            }
            else
            {
               this._y = 0;
            }
         }
         else
         {
            GuiManager.actionMgr.grayOutPetDanceBtn(true);
            if(GuiManager.isBeYourPetRoom())
            {
               this._y = -5;
            }
            else
            {
               this._y = this._airPetYOffest;
            }
         }
         this._parentLastX = this._parent.x;
         this._parentLastY = this._parent.y;
         if(GuiManager.isBeYourPetRoom())
         {
            this._minX = 25;
            this._maxX = -30;
            this._x = this._maxX;
            this._parentLastX = 0;
         }
         else
         {
            if(_type == PetManager.TYPE_OCEAN_LOW)
            {
               this._minX -= this._oceanPetXOffset;
               this._maxX += this._oceanPetXOffset;
            }
            else if(_type == PetManager.TYPE_LAND_LOW)
            {
               if(parent.avTypeId != SharedAvatarAnimalConstants.AV_KOALA)
               {
                  this._minX -= this._petLandLowXOffset;
               }
            }
            this._x = 0;
         }
         this._targetX = 0;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClick);
      }
      
      public function heartbeat() : void
      {
         var moving:int = 0;
         var splash:int = 0;
         var matrix:Matrix = null;
         var anim:int = 0;
         if(Boolean(_content))
         {
            moving = this._parent.isPetMovingTest() ? 1 : 0;
            if(GuiManager.isBeYourPetRoom())
            {
               if(this._parentLastX != this._parent.x)
               {
                  if(this._parent.x > this._parentLastX)
                  {
                     if(!this._bFlip)
                     {
                        this._parent.flipSplash(true);
                        this._bFlip = true;
                        this._x = this._minX;
                     }
                  }
                  else if(this._bFlip)
                  {
                     this._parent.flipSplash(false);
                     this._bFlip = false;
                     this._x = this._maxX;
                  }
                  this._parentLastX = this._parent.x;
               }
            }
            else
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
               if(this._x != this._targetX)
               {
                  moving = 1;
               }
            }
            if(this._bUpdateState)
            {
               PetManager.setPetState(_content,_lBits,_uBits,_eBits);
               this._bUpdateState = false;
            }
            splash = this._parent.inSplashVolume() ? ANIM_IDLE_WATER : ANIM_IDLE;
            if(Boolean(splash) && this._parent.splashLiquid == "mud")
            {
               splash = ANIM_IDLE_MUD;
            }
            if(this._parent.splashLiquid != "mud" && this._parent.splashLiquid != "water")
            {
               splash = ANIM_IDLE;
            }
            matrix = _content.transform.matrix;
            matrix.identity();
            matrix.scale(this._bFlip ? -this._scale : this._scale,this._scale);
            matrix.translate(this._x,this._y);
            _content.transform.matrix = matrix;
            anim = splash + moving;
            if(this._bBack)
            {
               anim += 2;
            }
            if(this._lastAnim != anim)
            {
               this._lastAnim = anim;
               _content.pet.setAnim(anim);
            }
            if(this._bSpecialMove)
            {
               this._bSpecialMove = false;
               if(!moving)
               {
                  _content.pet.setAnim(ANIM_CLICK + splash);
               }
            }
         }
      }
      
      public function setState(cats:Array) : void
      {
         _lBits = cats[0];
         _uBits = cats[1];
         _eBits = cats[2];
         this._bUpdateState = true;
      }
      
      public function setAction(actionId:int, extraId:int = 0) : void
      {
         switch(actionId)
         {
            case ACTION_CLICK:
               this.onClick();
               break;
            case ACTION_SPARKLE:
               setSparkle(extraId);
         }
      }
      
      public function onClick(e:MouseEvent = null) : void
      {
         if(Boolean(e))
         {
            e.stopPropagation();
            UserCommXtCommManager.sendPetAction(WorldPet.ACTION_CLICK);
         }
         this._bSpecialMove = true;
      }
      
      private function onPetLoaded(content:MovieClip) : void
      {
         if(GuiManager.isBeYourPetRoom())
         {
            _content.pet.scaleX = _content.pet.scaleY = 2;
         }
         _content.pet.setSparkle(this._sparkle);
      }
   }
}

