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
      
      public static const LEVEL_SHAPES:Array = new Array(1851,1858,1853,1857);
      
      public static const MAX_COLORS:int = 10;
      
      private static var BADGE_ID_VIP_CAMERA:int = 31;
      
      private var _iconIdsArray:Array;
      
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
      
      public function NameBar(initNubType:String = "nonBuddy", initIsBlocked:Boolean = false)
      {
         super();
         if(Boolean(this["e"].currentFrameLabel))
         {
            this._left = this["e"][String(this["e"].currentFrameLabel)];
         }
         else
         {
            this._left = this["e"];
         }
         if(Boolean(this["n"].currentFrameLabel))
         {
            this._mid = this["n"][String(this["n"].currentFrameLabel)];
         }
         else
         {
            this._mid = this["n"];
         }
         if(this["meter"] != null)
         {
            if(Boolean(this["meter"].currentFrameLabel))
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
            if(Boolean(this["shape"].currentFrameLabel))
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
         this.isBlocked = initIsBlocked;
         this.nubType = initNubType;
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
      
      public static function set getNamebarIconsFunc(func:Function) : void
      {
         _getNamebarIconsFunc = func;
      }
      
      public static function isVIPBadge(packedNamebarData:int) : Boolean
      {
         var badgeIcon:int = packedNamebarData >> 8 & 0xFF;
         return badgeIcon + 1 == BADGE_ID_VIP_CAMERA;
      }
      
      public function destroy() : void
      {
         this.removeListeners();
      }
      
      public function set isBlocked(value:Boolean) : void
      {
         this._isBlocked = value;
         if(this._nubType != GUIDE)
         {
            this._right.blocked.visible = this._isBlocked;
         }
      }
      
      public function setColorAndBadge(packedData:int) : void
      {
         this._packedNameBarData = packedData;
         var color:int = packedData & 0xFF;
         var badgeIcon:int = packedData >> 8 & 0xFF;
         this._badgeId = badgeIcon + 1;
         if(Boolean(this["e"].currentFrameLabel))
         {
            this.setColor(color);
            this.setBadgeIcon(badgeIcon);
         }
      }
      
      public function setColorBadgeAndXp(packedData:int, level:int, isMember:Boolean, isInQuestRoom:Boolean = false) : void
      {
         this.setColorAndBadge(packedData);
         var showQuestLevel:Boolean = (packedData >> 16 & 0xFF) == 0 && isMember;
         this._isMember = isMember;
         if(level > 0 && (isInQuestRoom || showQuestLevel))
         {
            if(Boolean(this._currShapeMouse) && Boolean(this._currShapeMouse.level != null) && this._currShapeMouse.level == level)
            {
               this.setCurrShape();
            }
            else if(level > 0)
            {
               this.setShape(level);
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
      
      public function setNubType(value:String, changeDimensions:Boolean = true) : void
      {
         this.nubType = value;
         this.resize(changeDimensions);
      }
      
      public function setAvName(value:String, changeDimensions:Boolean = true) : void
      {
         this._avName.txt.text = value;
         this.resize(changeDimensions);
      }
      
      public function removeShape() : void
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
      
      public function updateMeter(value:int) : void
      {
         this.setMeter(value);
      }
      
      public function getMeterValue() : int
      {
         if(Boolean(this["meter"]))
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
      
      public function set nubData(data:Array) : void
      {
         this._nubDataArray = data;
      }
      
      public function get iconIds() : Array
      {
         return this._iconIdsArray;
      }
      
      public function set iconIds(ids:Array) : void
      {
         this._iconIdsArray = ids;
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
      
      public function set xpShapeIcons(obj:Object) : void
      {
         this._currShapeMouse = obj.mouseIcon;
         this._currShapeUp = obj.upIcon;
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
      
      private function setColor(colorValue:int) : void
      {
         var frameId:int = 0;
         if(colorValue == 0)
         {
            frameId = 4;
         }
         else if(colorValue > 3 && colorValue <= MAX_COLORS)
         {
            frameId = colorValue + 1;
         }
         else
         {
            frameId = Math.min(4,colorValue);
         }
         this._currframeName = this["e"].currentLabels[frameId - 1].name;
         this["e"].gotoAndStop(this._currframeName);
         this._left = this["e"][this._currframeName];
         this["n"].gotoAndStop(this._currframeName);
         this._mid = this["n"][this._currframeName];
         if(Boolean(this._meter))
         {
            this["meter"].gotoAndStop(this._currframeName);
            this._meter = this["meter"][this._currframeName];
         }
         if(Boolean(this._shape))
         {
            this["shape"].gotoAndStop(this._currframeName);
            this._shape = this["shape"][this._currframeName];
         }
         if(Boolean(this["selnub"].nub.currentFrameLabel))
         {
            this["selnub"].nub.gotoAndStop(this._currframeName);
            this._right = this["selnub"];
         }
         if(Boolean(this._avName.currentFrameLabel))
         {
            this._avName.gotoAndStop(this._currframeName);
         }
         this._left.mouse.gotoAndStop(1);
         this._mid.mouse.gotoAndStop(1);
         if(Boolean(this._shape))
         {
            this._shape.mouse.gotoAndStop(1);
         }
         if(Boolean(this._right.nub.currentFrameLabel))
         {
            this._right.nub[this._currframeName].mouse.gotoAndStop(1);
         }
         else
         {
            this._right.nub.mouse.gotoAndStop(1);
         }
      }
      
      private function setBadgeIcon(badgeIcon:int) : void
      {
         var id:int = 0;
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
               id = int(this._iconIdsArray[badgeIcon]);
               badgeIcon *= 2;
               if(badgeIcon % 2 != 0)
               {
                  badgeIcon++;
               }
               if(Boolean(this._iconImages[badgeIcon]) && Boolean(this._iconImages[badgeIcon + 1]))
               {
                  this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.mouse.icon.addChild(this._iconImages[badgeIcon]);
                  this._right.nub[String(this._right.nub.currentFrameLabel)].mouse.up.icon.addChild(this._iconImages[badgeIcon + 1]);
               }
               else
               {
                  this._nubDataArray[badgeIcon] = this._right.nub[String(this._right.nub.currentFrameLabel)].mouse;
                  this.loadIcon(id,badgeIcon);
               }
            }
         }
         else
         {
            this._nameBarDataToBeLoaded = this._packedNameBarData;
         }
      }
      
      private function set nubType(value:String) : void
      {
         if(value == "")
         {
            this._right.visible = false;
         }
         else
         {
            this._right.visible = true;
            this._nubType = value;
            this._right.gotoAndStop(this._nubType);
            if(Boolean(this._right.nub.currentFrameLabel))
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
      
      private function resize(changeDimensions:Boolean) : void
      {
         var offset:int = 0;
         var mid:MovieClip = null;
         var left:MovieClip = null;
         var shape:MovieClip = null;
         var meter:MovieClip = null;
         if(changeDimensions)
         {
            mid = this._mid.parent != this ? MovieClip(this._mid.parent) : this._mid;
            left = this._left.parent != this ? MovieClip(this._left.parent) : this._left;
            shape = Boolean(this._shape) && this._shape.parent != this ? MovieClip(this._shape.parent) : this._shape;
            meter = Boolean(this._meter) && this._meter.parent != this ? MovieClip(this._meter.parent) : this._meter;
            if(this._nubType == NON_BUDDY && !this._isBlocked)
            {
               offset = 10;
            }
            else
            {
               offset = 20;
            }
            this._avName.txt.width = 300;
            if(this._avName.txt.textWidth + offset < 60)
            {
               mid.width = 60 + 0.5 * this._right.width;
            }
            else
            {
               mid.width = Math.ceil(this._avName.txt.textWidth + offset);
            }
            mid.x = mid.width * 0.5 * -1;
            this._avName.txt.width = mid.width - offset + 5;
            left.x = mid.x - left.width;
            this._avName.x = mid.x + (this._isMember ? 2 : -2);
            this._right.x = mid.x + mid.width - 1;
            if(Boolean(shape))
            {
               shape.x = left.x;
            }
            if(Boolean(meter))
            {
               meter.width = this._avName.txt.width + 18;
               meter.x = this._avName.x - 7;
            }
         }
         this._left.mouse.gotoAndStop(1);
         this._mid.mouse.gotoAndStop(1);
         if(Boolean(this._shape))
         {
            this._shape.mouse.gotoAndStop(1);
         }
         if(Boolean(this._right.nub.currentFrameLabel))
         {
            this._right.nub[this._currframeName].mouse.gotoAndStop(1);
         }
         else
         {
            this._right.nub.mouse.gotoAndStop(1);
         }
      }
      
      private function loadIcon(id:int, index:int) : void
      {
         var iconsMediaHelper:MediaHelper = new MediaHelper();
         iconsMediaHelper.init(id,this.onIconsLoaded,index);
         this._iconsMediaHelperArray[index] = iconsMediaHelper;
         iconsMediaHelper = new MediaHelper();
         iconsMediaHelper.init(id,this.onIconsLoaded,index + 1);
         this._iconsMediaHelperArray[index + 1] = iconsMediaHelper;
      }
      
      private function onIconsLoaded(img:MovieClip) : void
      {
         var nub:Object = null;
         var index:int = 0;
         if(Boolean(img))
         {
            img.cacheAsBitmap = true;
            index = int(img.passback);
            this._iconImages[index] = img;
            if(img.passback % 2 == 0)
            {
               nub = this._nubDataArray[index].mouse.icon;
               while(nub.numChildren > 0)
               {
                  nub.removeChildAt(0);
               }
               nub.addChild(img);
            }
            else
            {
               nub = this._nubDataArray[index - 1].up.icon;
               while(nub.numChildren > 0)
               {
                  nub.removeChildAt(0);
               }
               nub.addChild(img);
            }
            if(Boolean(this._iconsMediaHelperArray[index]))
            {
               this._iconsMediaHelperArray[index].destroy();
               this._iconsMediaHelperArray[index] = null;
               delete this._iconsMediaHelperArray[index];
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
      
      private function setShape(level:int) : void
      {
         var shapeId:int = 0;
         if(level > 0)
         {
            if(this._currShapeMouse == null || this._currShapeMouse.level != level && Math.floor(this._currShapeMouse.level / 5) != Math.floor(level / 5))
            {
               shapeId = Math.floor(level / 5) > LEVEL_SHAPES.length - 1 ? int(LEVEL_SHAPES[LEVEL_SHAPES.length - 1]) : int(LEVEL_SHAPES[Math.floor(level / 5)]);
               this._levelShapeHelper = new MediaHelper();
               this._levelShapeHelper.init(shapeId,this.onLevelShapeLoaded,-1);
               this._shapesMediaHelperArray.push(this._levelShapeHelper);
               this._levelShapeHelper = new MediaHelper();
               this._levelShapeHelper.init(shapeId,this.onLevelShapeLoaded,level);
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
               this._currShapeMouse.text.text = level;
               this._currShapeUp.text.text = level;
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
      
      private function onLevelShapeLoaded(img:MovieClip) : void
      {
         var shape:MovieClip = null;
         if(Boolean(img))
         {
            shape = MovieClip(img.getChildAt(0));
            if(img.passback == -1)
            {
               this._currShapeUp = shape;
               if(this._isMember)
               {
                  this._currShapeUp.gotoAndStop("member");
               }
               if(Boolean(this._currShapeMouse))
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
               this._currShapeMouse = shape;
               if(this._isMember)
               {
                  this._currShapeMouse.gotoAndStop("member");
               }
               this._currShapeMouse.level = this._currShapeMouse.text.text = img.passback;
               if(Boolean(this._currShapeUp))
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
      
      private function setMeter(healthPercentage:int) : void
      {
         if(Boolean(this["meter"]))
         {
            this["meter"].hpBar.width = this["meter"].hpBarContainer.width * (healthPercentage / 100);
         }
      }
      
      private function onOverHandler(evt:MouseEvent) : void
      {
         this._left.mouse.gotoAndPlay(1);
         this._mid.mouse.gotoAndPlay(1);
         if(Boolean(this._shape))
         {
            this._shape.mouse.gotoAndPlay(1);
         }
         if(Boolean(this._right.nub.currentFrameLabel))
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
      
      private function onOutHandler(evt:MouseEvent) : void
      {
         var rightNub:MovieClip = null;
         if(Boolean(this._right.nub[String(this._right.nub.currentFrameLabel)]))
         {
            rightNub = this._right.nub[String(this._right.nub.currentFrameLabel)];
         }
         else
         {
            rightNub = this._right.nub;
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
         if(Boolean(this._shape))
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
         if(rightNub.mouse.currentFrame > 1)
         {
            this.playBackwards(rightNub.mouse);
         }
         else
         {
            rightNub.mouse.stop();
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
      
      private function playBackwards(mc:MovieClip) : void
      {
         mc.addEventListener(Event.ENTER_FRAME,this.pbFrameHandler,false,0,true);
      }
      
      private function pbFrameHandler(evt:Event) : void
      {
         var mch:MovieClip = null;
         if(Boolean(evt.target as MovieClip))
         {
            mch = MovieClip(evt.target);
            if(mch.currentFrame == 1)
            {
               mch.removeEventListener(Event.ENTER_FRAME,this.pbFrameHandler);
               return;
            }
            mch.prevFrame();
         }
      }
   }
}

