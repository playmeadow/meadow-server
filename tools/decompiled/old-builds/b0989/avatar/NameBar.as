package avatar
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   
   public class NameBar extends MovieClip
   {
      
      private static var _getNamebarIconsFunc:Function;
      
      public static var NON_BUDDY:String = "nonBuddy";
      
      public static var BUDDY:String = "buddy";
      
      public static var GUIDE:String = "guide";
      
      private static var BADGE_ID_VIP_CAMERA:int = 31;
      
      private static const LEVEL_SHAPES:Array = new Array(1851,1858,1853,1857);
      
      private var _iconIdsArray:Array;
      
      private const MAX_COLORS:int = 10;
      
      private var _isBlocked:Boolean;
      
      private var _nubType:String;
      
      private var _left:MovieClip;
      
      private var _mid:MovieClip;
      
      private var _right:MovieClip;
      
      private var _avName:MovieClip;
      
      private var _meter:MovieClip;
      
      private var _shape:MovieClip;
      
      private var _iconsMediaHelperArray:Array;
      
      private var _iconImages:Array;
      
      private var _nubDataArray:Array;
      
      private var _nameBarDataToBeLoaded:int;
      
      private var _currframeName:String;
      
      private var _packedNameBarData:int;
      
      private var _badgeId:int;
      
      private var _levelShapeHelper:MediaHelper;
      
      private var _shapesMediaHelperArray:Array;
      
      private var _currShapeMouse:MovieClip;
      
      private var _currShapeUp:MovieClip;
      
      private var _isMember:Boolean;
      
      public function NameBar(param1:String = "nonBuddy", param2:Boolean = false)
      {
         super();
         if(this["e"].currentFrameLabel)
         {
            this._left = this["e"][String(this["e"].currentFrameLabel)];
         }
         else
         {
            this._left = this["e"];
         }
         if(this["n"].currentFrameLabel)
         {
            this._mid = this["n"][String(this["n"].currentFrameLabel)];
         }
         else
         {
            this._mid = this["n"];
         }
         if(this["meter"] != null)
         {
            if(this["meter"].currentFrameLabel)
            {
               this._meter = this["meter"][String(this["meter"].currentFrameLabel)];
            }
            else
            {
               this._meter = this["meter"];
            }
         }
         if(this["shape"] != null)
         {
            if(this["shape"].currentFrameLabel)
            {
               this._shape = this["shape"][String(this["shape"].currentFrameLabel)];
            }
            else
            {
               this._shape = this["shape"];
            }
         }
         this._right = this["selnub"];
         this._avName = this["c"];
         if(!(Boolean(this._left) && Boolean(this._mid) && Boolean(this._right) && Boolean(this._avName) && this._avName.txt))
         {
            throw new Error("NameBar is missing parts or parts are named improperly!");
         }
         this._currframeName = "black";
         this.isBlocked = param2;
         this.nubType = param1;
         this._iconsMediaHelperArray = [];
         this._shapesMediaHelperArray = [];
         this._iconImages = [];
         this._nubDataArray = [];
         if(_getNamebarIconsFunc != null)
         {
            this._iconIdsArray = _getNamebarIconsFunc();
         }
         if(!this._iconIdsArray)
         {
            this._iconIdsArray = [];
         }
         this._nameBarDataToBeLoaded = -1;
         this.cacheAsBitmap = true;
         addEventListener(MouseEvent.ROLL_OVER,this.onOverHandler,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onOutHandler,false,0,true);
      }
      
      public static function set getNamebarIconsFunc(param1:Function) : void
      {
         _getNamebarIconsFunc = param1;
      }
      
      public static function isVIPBadge(param1:int) : Boolean
      {
         var _loc2_:int = param1 >> 8 & 0xFF;
         return _loc2_ + 1 == BADGE_ID_VIP_CAMERA;
      }
      
      public function destroy() : void
      {
         this.removeListeners();
      }
      
      public function set isBlocked(param1:Boolean) : void
      {
         this._isBlocked = param1;
         if(this._nubType != GUIDE)
         {
            this._right.blocked.visible = this._isBlocked;
         }
      }
      
      public function setColorAndBadge(param1:int) : void
      {
         this._packedNameBarData = param1;
         var _loc2_:int = param1 & 0xFF;
         var _loc3_:int = param1 >> 8 & 0xFF;
         this._badgeId = _loc3_ + 1;
         if(this["e"].currentFrameLabel)
         {
            this.setColor(_loc2_);
            this.setBadgeIcon(_loc3_);
            if(Boolean(this._currShapeMouse) && this._currShapeMouse.level != null)
            {
               this.setCurrShape();
            }
         }
      }
      
      public function setNubType(param1:String, param2:Boolean = true) : void
      {
         this.nubType = param1;
         this.resize(param2);
      }
      
      public function setAvName(param1:String, param2:Boolean = true) : void
      {
         this._avName.txt.text = param1;
         this.resize(param2);
      }
      
      public function showHealthBar(param1:Boolean, param2:int = -1, param3:Boolean = false, param4:int = 0) : void
      {
         if(this._meter)
         {
            this["meter"].visible = param1;
            this._isMember = param3;
            if(param2 != -1 && param2 > 0)
            {
               this.setShape(param2);
            }
            if(param1)
            {
               this.setMeter(param4);
            }
         }
      }
      
      public function setQuestLevel(param1:int, param2:Boolean, param3:Boolean) : void
      {
         this._isMember = param2;
         if(param3)
         {
            this.setShape(param1);
         }
      }
      
      public function updateMeter(param1:int) : void
      {
         this.setMeter(param1);
      }
      
      public function getMeterValue() : int
      {
         if(this["meter"])
         {
            return this["meter"].hpBar.width;
         }
         return 0;
      }
      
      public function removeListeners() : void
      {
         removeEventListener(MouseEvent.ROLL_OVER,this.onOverHandler);
         removeEventListener(MouseEvent.ROLL_OUT,this.onOutHandler);
      }
      
      public function get nubData() : Array
      {
         return this._nubDataArray;
      }
      
      public function set nubData(param1:Array) : void
      {
         this._nubDataArray = param1;
      }
      
      public function get iconIds() : Array
      {
         return this._iconIdsArray;
      }
      
      public function set iconIds(param1:Array) : void
      {
         this._iconIdsArray = param1;
      }
      
      public function get packedNameBarData() : int
      {
         return this._packedNameBarData;
      }
      
      public function get xpShapeIcons() : Object
      {
         return {
            "mouseIcon":this._currShapeMouse,
            "upIcon":this._currShapeUp
         };
      }
      
      public function set xpShapeIcons(param1:Object) : void
      {
         this._currShapeMouse = param1.mouseIcon;
         this._currShapeUp = param1.upIcon;
         if(Boolean(this._currShapeMouse) && this._currShapeMouse.level != null)
         {
            this.setShape(this._currShapeMouse.level);
         }
      }
      
      public function get currentLevel() : int
      {
         if(Boolean(this._currShapeMouse) && this._currShapeMouse.level != null)
         {
            return this._currShapeMouse.level;
         }
         return 0;
      }
      
      private function setColor(param1:int) : void
      {
         var _loc2_:int = 0;
         if(param1 == 0)
         {
            _loc2_ = 4;
         }
         else if(param1 > 3 && param1 <= this.MAX_COLORS)
         {
            _loc2_ = param1 + 1;
         }
         else
         {
            _loc2_ = Math.min(4,param1);
         }
         this._currframeName = this["e"].currentLabels[_loc2_ - 1].name;
         this["e"].gotoAndStop(this._currframeName);
         this._left = this["e"][this._currframeName];
         this["n"].gotoAndStop(this._currframeName);
         this._mid = this["n"][this._currframeName];
         if(this._meter)
         {
            this["meter"].gotoAndStop(this._currframeName);
            this._meter = this["meter"][this._currframeName];
         }
         if(this._shape)
         {
            this["shape"].gotoAndStop(this._currframeName);
            this._shape = this["shape"][this._currframeName];
         }
         if(this["selnub"].nub.currentFrameLabel)
         {
            this["selnub"].nub.gotoAndStop(this._currframeName);
            this._right = this["selnub"];
         }
         if(this._avName.currentFrameLabel)
         {
            this._avName.gotoAndStop(this._currframeName);
         }
         this._left.mouse.gotoAndStop(1);
         this._mid.mouse.gotoAndStop(1);
         if(this._shape)
         {
            this._shape.mouse.gotoAndStop(1);
         }
         if(this._right.nub.currentFrameLabel)
         {
            this._right.nub[this._currframeName].mouse.gotoAndStop(1);
         }
         else
         {
            this._right.nub.mouse.gotoAndStop(1);
         }
      }
      
      private function setBadgeIcon(param1:int) : void
      {
         var _loc2_:int = 0;
         if(this._iconIdsArray.length > 0)
         {
            if(this["selnub"].currentFrameLabel == "buddy")
            {
               while(this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.mouse.icon.numChildren > 0)
               {
                  this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.mouse.icon.removeChildAt(0);
               }
               while(this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.up.icon.numChildren > 0)
               {
                  this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.up.icon.removeChildAt(0);
               }
               _loc2_ = int(this._iconIdsArray[param1]);
               param1 *= 2;
               if(param1 % 2 != 0)
               {
                  param1++;
               }
               if(Boolean(this._iconImages[param1]) && Boolean(this._iconImages[param1 + 1]))
               {
                  this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.mouse.icon.addChild(this._iconImages[param1]);
                  this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.up.icon.addChild(this._iconImages[param1 + 1]);
               }
               else
               {
                  this._nubDataArray[param1] = this._right.nub[String(this._right.nub.currentFrameLabel)].mouse;
                  this.loadIcon(_loc2_,param1);
               }
            }
         }
         else
         {
            this._nameBarDataToBeLoaded = this._packedNameBarData;
         }
      }
      
      private function set nubType(param1:String) : void
      {
         if(param1 == "")
         {
            this._right.visible = false;
         }
         else
         {
            this._right.visible = true;
            this._nubType = param1;
            this._right.gotoAndStop(this._nubType);
            if(this._right.nub.currentFrameLabel)
            {
               this._right.nub.gotoAndStop(this._currframeName);
               this._right.nub[this._currframeName].mouse.gotoAndStop(1);
            }
            else
            {
               this._right.nub.mouse.gotoAndStop(1);
            }
            if(this._isBlocked && this._nubType != GUIDE)
            {
               this._right.blocked.gotoAndStop(1);
            }
         }
      }
      
      private function resize(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = null;
         var _loc6_:MovieClip = null;
         if(param1)
         {
            _loc3_ = this._mid.parent != this ? MovieClip(this._mid.parent) : this._mid;
            _loc4_ = this._left.parent != this ? MovieClip(this._left.parent) : this._left;
            _loc5_ = Boolean(this._shape) && this._shape.parent != this ? MovieClip(this._shape.parent) : this._shape;
            _loc6_ = Boolean(this._meter) && this._meter.parent != this ? MovieClip(this._meter.parent) : this._meter;
            if(this._nubType == NON_BUDDY && !this._isBlocked)
            {
               _loc2_ = 10;
            }
            else
            {
               _loc2_ = 20;
            }
            this._avName.txt.width = 300;
            if(this._avName.txt.textWidth + _loc2_ < 60)
            {
               _loc3_.width = 60 + 0.5 * this._right.width;
            }
            else
            {
               _loc3_.width = Math.ceil(this._avName.txt.textWidth + _loc2_);
            }
            _loc3_.x = _loc3_.width * 0.5 * -1;
            this._avName.txt.width = _loc3_.width - _loc2_ + 5;
            _loc4_.x = _loc3_.x - _loc4_.width;
            this._avName.x = _loc3_.x + 2;
            this._right.x = _loc3_.x + _loc3_.width - 1;
            if(_loc5_)
            {
               _loc5_.x = _loc4_.x - _loc5_.width * 0.5;
            }
            if(_loc6_)
            {
               _loc6_.width = this._avName.txt.width + 18;
               _loc6_.x = this._avName.x - 7;
            }
         }
         this._left.mouse.gotoAndStop(1);
         this._mid.mouse.gotoAndStop(1);
         if(this._shape)
         {
            this._shape.mouse.gotoAndStop(1);
         }
         if(this._right.nub.currentFrameLabel)
         {
            this._right.nub[this._currframeName].mouse.gotoAndStop(1);
         }
         else
         {
            this._right.nub.mouse.gotoAndStop(1);
         }
      }
      
      private function loadIcon(param1:int, param2:int) : void
      {
         var _loc3_:MediaHelper = new MediaHelper();
         _loc3_.init(param1,this.onIconsLoaded,param2);
         this._iconsMediaHelperArray[param2] = _loc3_;
         _loc3_ = new MediaHelper();
         _loc3_.init(param1,this.onIconsLoaded,param2 + 1);
         this._iconsMediaHelperArray[param2 + 1] = _loc3_;
      }
      
      private function onIconsLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(param1)
         {
            param1.cacheAsBitmap = true;
            _loc3_ = int(param1.passback);
            this._iconImages[_loc3_] = param1;
            if(param1.passback % 2 == 0)
            {
               _loc2_ = this._nubDataArray[_loc3_].mouse.icon;
               while(_loc2_.numChildren > 0)
               {
                  _loc2_.removeChildAt(0);
               }
               _loc2_.addChild(param1);
            }
            else
            {
               _loc2_ = this._nubDataArray[_loc3_ - 1].up.icon;
               while(_loc2_.numChildren > 0)
               {
                  _loc2_.removeChildAt(0);
               }
               _loc2_.addChild(param1);
            }
            if(this._iconsMediaHelperArray[_loc3_])
            {
               this._iconsMediaHelperArray[_loc3_].destroy();
               this._iconsMediaHelperArray[_loc3_] = null;
               delete this._iconsMediaHelperArray[_loc3_];
            }
         }
      }
      
      private function setCurrShape() : void
      {
         while(this._shape.mouse.up.icon.numChildren > 0)
         {
            this._shape.mouse.up.icon.removeChildAt(0);
         }
         this._shape.mouse.up.icon.addChild(this._currShapeUp);
         while(this._shape.mouse.mouse.icon.numChildren > 0)
         {
            this._shape.mouse.mouse.icon.removeChildAt(0);
         }
         this._shape.mouse.mouse.icon.addChild(this._currShapeMouse);
      }
      
      private function setShape(param1:int) : void
      {
         if(param1 > 0)
         {
            if(this._currShapeMouse == null || this._currShapeMouse.level != param1 && Math.floor(this._currShapeMouse.level / 5) != Math.floor(param1 / 5))
            {
               this._levelShapeHelper = new MediaHelper();
               this._levelShapeHelper.init(LEVEL_SHAPES[Math.floor(param1 / 5)],this.onLevelShapeLoaded,-1);
               this._shapesMediaHelperArray.push(this._levelShapeHelper);
               this._levelShapeHelper = new MediaHelper();
               this._levelShapeHelper.init(LEVEL_SHAPES[Math.floor(param1 / 5)],this.onLevelShapeLoaded,param1);
               this._shapesMediaHelperArray.push(this._levelShapeHelper);
            }
            else
            {
               while(this._shape.mouse.up.icon.numChildren > 0)
               {
                  this._shape.mouse.up.icon.removeChildAt(0);
               }
               this._shape.mouse.up.icon.addChild(this._currShapeUp);
               while(this._shape.mouse.mouse.icon.numChildren > 0)
               {
                  this._shape.mouse.mouse.icon.removeChildAt(0);
               }
               this._shape.mouse.mouse.icon.addChild(this._currShapeMouse);
               this._currShapeMouse.text.text = param1;
               this._currShapeUp.text.text = param1;
            }
         }
         else
         {
            while(this._shape.mouse.up.icon.numChildren > 0)
            {
               this._shape.mouse.up.icon.removeChildAt(0);
            }
            while(this._shape.mouse.mouse.icon.numChildren > 0)
            {
               this._shape.mouse.mouse.icon.removeChildAt(0);
            }
         }
      }
      
      private function onLevelShapeLoaded(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            _loc2_ = MovieClip(param1.getChildAt(0));
            if(param1.passback == -1)
            {
               this._currShapeUp = _loc2_;
               if(this._isMember)
               {
                  this._currShapeUp.gotoAndStop("member");
               }
               if(this._currShapeMouse)
               {
                  this._currShapeUp.text.text = this._currShapeMouse.level;
               }
               this._shapesMediaHelperArray[0].destroy();
               this._shapesMediaHelperArray.splice(0,1);
               while(this._shape.mouse.up.icon.numChildren > 0)
               {
                  this._shape.mouse.up.icon.removeChildAt(0);
               }
               this._shape.mouse.up.icon.addChild(this._currShapeUp);
            }
            else
            {
               this._currShapeMouse = _loc2_;
               if(this._isMember)
               {
                  this._currShapeMouse.gotoAndStop("member");
               }
               this._currShapeMouse.level = this._currShapeMouse.text.text = param1.passback;
               if(this._currShapeUp)
               {
                  this._currShapeUp.text.text = this._currShapeMouse.level;
               }
               this._shapesMediaHelperArray[this._shapesMediaHelperArray.length - 1].destroy();
               this._shapesMediaHelperArray.pop();
               while(this._shape.mouse.mouse.icon.numChildren > 0)
               {
                  this._shape.mouse.mouse.icon.removeChildAt(0);
               }
               this._shape.mouse.mouse.icon.addChild(this._currShapeMouse);
            }
            this._shape.mouse.gotoAndStop(1);
         }
      }
      
      private function setMeter(param1:int) : void
      {
         if(this["meter"])
         {
            this["meter"].hpBar.width = this["meter"].hpBarContainer.width * (param1 / 100);
         }
      }
      
      private function onOverHandler(param1:MouseEvent) : void
      {
         this._left.mouse.gotoAndPlay(1);
         this._mid.mouse.gotoAndPlay(1);
         if(this._shape)
         {
            this._shape.mouse.gotoAndPlay(1);
         }
         if(this._right.nub.currentFrameLabel)
         {
            this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.gotoAndPlay(1);
         }
         else
         {
            this._right.nub.mouse.gotoAndPlay(1);
         }
         if(this._isBlocked && this._nubType != GUIDE)
         {
            this._right.blocked.mouse.gotoAndPlay(1);
         }
      }
      
      private function onOutHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(this._right.nub[String(this._right.nub.currentFrameLabel)])
         {
            _loc2_ = this._right.nub[String(this._right.nub.currentFrameLabel)];
         }
         else
         {
            _loc2_ = this._right.nub;
         }
         if(this._left.mouse.currentFrame > 1)
         {
            this.playBackwards(this._left.mouse);
         }
         else
         {
            this._left.mouse.stop();
         }
         if(this._mid.mouse.currentFrame > 1)
         {
            this.playBackwards(this._mid.mouse);
         }
         else
         {
            this._mid.mouse.stop();
         }
         if(this._shape)
         {
            if(this._shape.mouse.currentFrame > 1)
            {
               this.playBackwards(this._shape.mouse);
            }
            else
            {
               this._shape.mouse.stop();
            }
         }
         if(_loc2_.mouse.currentFrame > 1)
         {
            this.playBackwards(_loc2_.mouse);
         }
         else
         {
            _loc2_.mouse.stop();
         }
         if(this._isBlocked && this._nubType != GUIDE)
         {
            if(this._right.blocked.mouse.currentFrame > 1)
            {
               this.playBackwards(this._right.blocked.mouse);
            }
            else
            {
               this._right.blocked.mouse.stop();
            }
         }
      }
      
      private function playBackwards(param1:MovieClip) : void
      {
         param1.addEventListener(Event.ENTER_FRAME,this.pbFrameHandler,false,0,true);
      }
      
      private function pbFrameHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.target as MovieClip)
         {
            _loc2_ = MovieClip(param1.target);
            if(_loc2_.currentFrame == 1)
            {
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.pbFrameHandler);
               return;
            }
            _loc2_.prevFrame();
         }
      }
   }
}

