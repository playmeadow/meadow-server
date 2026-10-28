package avatar
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   
   public class NameBar extends MovieClip
   {
      
      public static var NON_BUDDY:String = "nonBuddy";
      
      public static var BUDDY:String = "buddy";
      
      public static var GUIDE:String = "guide";
      
      public static const MAX_COLORS:int = 10;
      
      private static var BADGE_ID_VIP_CAMERA:int = 31;
      
      private static var _getNamebarIconsFunc:Function;
      
      public static const LEVEL_SHAPES:Array = new Array(1851,1858,1853,1857);
      
      private var _iconIdsArray:Array;
      
      private var _isBlocked:Boolean;
      
      private var _nubType:String;
      
      private var _left:MovieClip;
      
      private var _mid:MovieClip;
      
      private var _right:MovieClip;
      
      private var _avName:MovieClip;
      
      private var _meter:MovieClip;
      
      private var _shape:MovieClip;
      
      private var _host:MovieClip;
      
      private var _iconsMediaHelperArray:Array;
      
      private var _iconImages:Array;
      
      private var _nubDataArray:Array;
      
      private var _nameBarDataToBeLoaded:int;
      
      private var _currFrameName:String;
      
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
            _left = this["e"][String(this["e"].currentFrameLabel)];
         }
         else
         {
            _left = this["e"];
         }
         if(this["n"].currentFrameLabel)
         {
            _mid = this["n"][String(this["n"].currentFrameLabel)];
         }
         else
         {
            _mid = this["n"];
         }
         if(this["meter"] != null)
         {
            if(this["meter"].currentFrameLabel)
            {
               _meter = this["meter"][String(this["meter"].currentFrameLabel)];
            }
            else
            {
               _meter = this["meter"];
            }
         }
         if(this["shape"] != null)
         {
            if(this["shape"].currentFrameLabel)
            {
               _shape = this["shape"][String(this["shape"].currentFrameLabel)];
            }
            else
            {
               _shape = this["shape"];
            }
         }
         if(this["hostTag"] != null)
         {
            if(this["hostTag"].currentFrameLabel)
            {
               _host = this["hostTag"][String(this["hostTag"].currentFrameLabel)];
            }
            else
            {
               _host = this["hostTag"];
            }
         }
         _right = this["selnub"];
         _avName = this["c"];
         if(!(_left && _mid && _right && _avName && _avName.txt))
         {
            throw new Error("NameBar is missing parts or parts are named improperly!");
         }
         _currFrameName = "black";
         isBlocked = param2;
         nubType = param1;
         isHostingCustomParty = false;
         _iconsMediaHelperArray = [];
         _shapesMediaHelperArray = [];
         _iconImages = [];
         _nubDataArray = [];
         if(_getNamebarIconsFunc != null)
         {
            _iconIdsArray = _getNamebarIconsFunc();
         }
         if(!_iconIdsArray)
         {
            _iconIdsArray = [];
         }
         _nameBarDataToBeLoaded = -1;
         this.cacheAsBitmap = true;
         addEventListener("rollOver",onOverHandler,false,0,true);
         addEventListener("rollOut",onOutHandler,false,0,true);
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
         removeListeners();
      }
      
      public function set isBlocked(param1:Boolean) : void
      {
         _isBlocked = param1;
         if(_nubType != GUIDE)
         {
            _right.blocked.visible = _isBlocked;
         }
      }
      
      public function set isHostingCustomParty(param1:Boolean) : void
      {
         if(_host)
         {
            this["hostTag"].visible = param1;
         }
      }
      
      public function setColorAndBadge(param1:int) : void
      {
         _packedNameBarData = param1;
         var _loc2_:int = param1 & 0xFF;
         var _loc3_:int = param1 >> 8 & 0xFF;
         _badgeId = _loc3_ + 1;
         if(this["e"].currentFrameLabel)
         {
            setColor(_loc2_);
            setBadgeIcon(_loc3_);
         }
      }
      
      public function setColorBadgeAndXp(param1:int, param2:int, param3:Boolean, param4:Boolean = false) : void
      {
         setColorAndBadge(param1);
         var _loc5_:Boolean = (param1 >> 16 & 0x0F) == 0 && param3;
         _isMember = param3;
         if(param2 > 0 && (param4 || _loc5_))
         {
            if(_currShapeMouse && _currShapeMouse.level != null && _currShapeMouse.level == param2)
            {
               setCurrShape();
            }
            else if(param2 > 0)
            {
               setShape(param2);
            }
         }
         else
         {
            while(_shape.mouse.up.icon.numChildren > 0)
            {
               _shape.mouse.up.icon.removeChildAt(0);
            }
            while(_shape.mouse.mouse.icon.numChildren > 0)
            {
               _shape.mouse.mouse.icon.removeChildAt(0);
            }
         }
      }
      
      public function setNubType(param1:String, param2:Boolean = true) : void
      {
         nubType = param1;
         resize(param2);
      }
      
      public function setAvName(param1:Object, param2:Boolean = false, param3:Object = null, param4:Boolean = true) : void
      {
         if(param2)
         {
            if(param3 != null)
            {
               _avName.txt.text = param3.getModeratedUserName();
            }
            else if(param1 is String)
            {
               _avName.txt.text = param1;
            }
            else
            {
               _avName.txt.text = param1.avName;
            }
         }
         else if(param1 is String)
         {
            _avName.txt.text = param1;
         }
         else
         {
            _avName.txt.text = param1.avName;
         }
         resize(param4);
      }
      
      public function removeShape() : void
      {
         while(_shape.mouse.up.icon.numChildren > 0)
         {
            _shape.mouse.up.icon.removeChildAt(0);
         }
         while(_shape.mouse.mouse.icon.numChildren > 0)
         {
            _shape.mouse.mouse.icon.removeChildAt(0);
         }
      }
      
      public function updateMeter(param1:int) : void
      {
         setMeter(param1);
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
         removeEventListener("rollOver",onOverHandler);
         removeEventListener("rollOut",onOutHandler);
      }
      
      public function get nubData() : Array
      {
         return _nubDataArray;
      }
      
      public function set nubData(param1:Array) : void
      {
         _nubDataArray = param1;
      }
      
      public function get iconIds() : Array
      {
         return _iconIdsArray;
      }
      
      public function set iconIds(param1:Array) : void
      {
         _iconIdsArray = param1;
      }
      
      public function get packedNameBarData() : int
      {
         return _packedNameBarData;
      }
      
      public function get xpShapeIcons() : Object
      {
         return {
            "mouseIcon":_currShapeMouse,
            "upIcon":_currShapeUp
         };
      }
      
      public function set xpShapeIcons(param1:Object) : void
      {
         _currShapeMouse = param1.mouseIcon;
         _currShapeUp = param1.upIcon;
         if(_currShapeMouse && _currShapeMouse.level != null)
         {
            setShape(_currShapeMouse.level);
         }
      }
      
      public function get currentLevel() : int
      {
         if(_currShapeMouse && _currShapeMouse.level != null)
         {
            return _currShapeMouse.level;
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
         else if(param1 > 3 && param1 < 10)
         {
            _loc2_ = param1 + 1;
         }
         else
         {
            _loc2_ = Math.min(4,param1);
         }
         _currFrameName = this["e"].currentLabels[_loc2_ - 1].name;
         this["e"].gotoAndStop(_currFrameName);
         _left = this["e"][_currFrameName];
         this["n"].gotoAndStop(_currFrameName);
         _mid = this["n"][_currFrameName];
         if(_meter)
         {
            this["meter"].gotoAndStop(_currFrameName);
            _meter = this["meter"][_currFrameName];
         }
         if(_shape)
         {
            this["shape"].gotoAndStop(_currFrameName);
            _shape = this["shape"][_currFrameName];
         }
         if(_host)
         {
            this["hostTag"].gotoAndStop(_currFrameName);
            _host = this["hostTag"][_currFrameName];
            _host.mouse.gotoAndStop(1);
         }
         if(this["selnub"].nub.currentFrameLabel)
         {
            this["selnub"].nub.gotoAndStop(_currFrameName);
            _right = this["selnub"];
         }
         if(_avName.currentFrameLabel)
         {
            _avName.gotoAndStop(_currFrameName);
         }
         _left.mouse.gotoAndStop(1);
         _mid.mouse.gotoAndStop(1);
         if(_shape)
         {
            _shape.mouse.gotoAndStop(1);
         }
         if(_right.nub.currentFrameLabel)
         {
            _right.nub[_currFrameName].mouse.gotoAndStop(1);
         }
         else
         {
            _right.nub.mouse.gotoAndStop(1);
         }
      }
      
      private function setBadgeIcon(param1:int) : void
      {
         var _loc2_:int = 0;
         if(_iconIdsArray.length > 0)
         {
            if(this["selnub"].currentFrameLabel == "buddy")
            {
               while(_right.nub[String(_right.nub.currentFrameLabel)].mouse.mouse.icon.numChildren > 0)
               {
                  _right.nub[String(_right.nub.currentFrameLabel)].mouse.mouse.icon.removeChildAt(0);
               }
               while(_right.nub[String(_right.nub.currentFrameLabel)].mouse.up.icon.numChildren > 0)
               {
                  _right.nub[String(_right.nub.currentFrameLabel)].mouse.up.icon.removeChildAt(0);
               }
               _loc2_ = int(_iconIdsArray[param1]);
               param1 *= 2;
               if(param1 % 2 != 0)
               {
                  param1++;
               }
               if(_iconImages[param1] && _iconImages[param1 + 1])
               {
                  _right.nub[String(_right.nub.currentFrameLabel)].mouse.mouse.icon.addChild(_iconImages[param1]);
                  _right.nub[String(_right.nub.currentFrameLabel)].mouse.up.icon.addChild(_iconImages[param1 + 1]);
               }
               else
               {
                  _nubDataArray[param1] = _right.nub[String(_right.nub.currentFrameLabel)].mouse;
                  loadIcon(_loc2_,param1);
               }
            }
         }
         else
         {
            _nameBarDataToBeLoaded = _packedNameBarData;
         }
      }
      
      private function set nubType(param1:String) : void
      {
         if(param1 == "")
         {
            _right.visible = false;
         }
         else
         {
            _right.visible = true;
            _nubType = param1;
            _right.gotoAndStop(_nubType);
            if(_right.nub.currentFrameLabel)
            {
               _right.nub.gotoAndStop(_currFrameName);
               _right.nub[_currFrameName].mouse.gotoAndStop(1);
            }
            else
            {
               _right.nub.mouse.gotoAndStop(1);
            }
            if(_isBlocked && _nubType != GUIDE)
            {
               _right.blocked.gotoAndStop(1);
            }
         }
      }
      
      private function resize(param1:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc2_:MovieClip = null;
         if(param1)
         {
            _loc5_ = _mid.parent != this ? MovieClip(_mid.parent) : _mid;
            _loc3_ = _left.parent != this ? MovieClip(_left.parent) : _left;
            _loc4_ = _shape && _shape.parent != this ? MovieClip(_shape.parent) : _shape;
            _loc2_ = _meter && _meter.parent != this ? MovieClip(_meter.parent) : _meter;
            if(_nubType == NON_BUDDY && !_isBlocked)
            {
               _loc6_ = 10;
            }
            else
            {
               _loc6_ = 20;
            }
            _avName.txt.width = 300;
            if(_avName.txt.textWidth + _loc6_ < 60)
            {
               _loc5_.width = 60 + 0.5 * _right.width;
            }
            else
            {
               _loc5_.width = Math.ceil(_avName.txt.textWidth + _loc6_);
            }
            _loc5_.x = _loc5_.width * 0.5 * -1;
            _avName.txt.width = _loc5_.width - _loc6_ + 5;
            _loc3_.x = _loc5_.x - _loc3_.width;
            _avName.x = _loc5_.x + (_isMember ? 2 : -2);
            _right.x = _loc5_.x + _loc5_.width - 1;
            if(_loc4_)
            {
               _loc4_.x = _loc3_.x;
            }
            if(_loc2_)
            {
               _loc2_.width = _avName.txt.width + 18;
               _loc2_.x = _avName.x - 7;
            }
         }
         _left.mouse.gotoAndStop(1);
         _mid.mouse.gotoAndStop(1);
         if(_shape)
         {
            _shape.mouse.gotoAndStop(1);
         }
         if(_right.nub.currentFrameLabel)
         {
            _right.nub[_currFrameName].mouse.gotoAndStop(1);
         }
         else
         {
            _right.nub.mouse.gotoAndStop(1);
         }
      }
      
      private function loadIcon(param1:int, param2:int) : void
      {
         var _loc3_:MediaHelper = new MediaHelper();
         _loc3_.init(param1,onIconsLoaded,param2);
         _iconsMediaHelperArray[param2] = _loc3_;
         _loc3_ = new MediaHelper();
         _loc3_.init(param1,onIconsLoaded,param2 + 1);
         _iconsMediaHelperArray[param2 + 1] = _loc3_;
      }
      
      private function onIconsLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(param1)
         {
            param1.cacheAsBitmap = true;
            _loc3_ = int(param1.passback);
            _iconImages[_loc3_] = param1;
            if(param1.passback % 2 == 0)
            {
               _loc2_ = _nubDataArray[_loc3_].mouse.icon;
               while(_loc2_.numChildren > 0)
               {
                  _loc2_.removeChildAt(0);
               }
               _loc2_.addChild(param1);
            }
            else
            {
               _loc2_ = _nubDataArray[_loc3_ - 1].up.icon;
               while(_loc2_.numChildren > 0)
               {
                  _loc2_.removeChildAt(0);
               }
               _loc2_.addChild(param1);
            }
            if(_iconsMediaHelperArray[_loc3_])
            {
               _iconsMediaHelperArray[_loc3_].destroy();
               _iconsMediaHelperArray[_loc3_] = null;
               delete _iconsMediaHelperArray[_loc3_];
            }
         }
      }
      
      private function setCurrShape() : void
      {
         while(_shape.mouse.up.icon.numChildren > 0)
         {
            _shape.mouse.up.icon.removeChildAt(0);
         }
         _shape.mouse.up.icon.addChild(_currShapeUp);
         while(_shape.mouse.mouse.icon.numChildren > 0)
         {
            _shape.mouse.mouse.icon.removeChildAt(0);
         }
         _shape.mouse.mouse.icon.addChild(_currShapeMouse);
      }
      
      private function setShape(param1:int) : void
      {
         var _loc2_:int = 0;
         if(param1 > 0)
         {
            if(_currShapeMouse == null || _currShapeMouse.level != param1 && Math.floor(_currShapeMouse.level / 5) != Math.floor(param1 / 5))
            {
               _loc2_ = int(Math.floor(param1 / 5) > LEVEL_SHAPES.length - 1 ? LEVEL_SHAPES[LEVEL_SHAPES.length - 1] : LEVEL_SHAPES[Math.floor(param1 / 5)]);
               _levelShapeHelper = new MediaHelper();
               _levelShapeHelper.init(_loc2_,onLevelShapeLoaded,-1);
               _shapesMediaHelperArray.push(_levelShapeHelper);
               _levelShapeHelper = new MediaHelper();
               _levelShapeHelper.init(_loc2_,onLevelShapeLoaded,param1);
               _shapesMediaHelperArray.push(_levelShapeHelper);
            }
            else
            {
               while(_shape.mouse.up.icon.numChildren > 0)
               {
                  _shape.mouse.up.icon.removeChildAt(0);
               }
               _shape.mouse.up.icon.addChild(_currShapeUp);
               while(_shape.mouse.mouse.icon.numChildren > 0)
               {
                  _shape.mouse.mouse.icon.removeChildAt(0);
               }
               _shape.mouse.mouse.icon.addChild(_currShapeMouse);
               _currShapeMouse.text.text = param1;
               _currShapeUp.text.text = param1;
            }
         }
         else
         {
            while(_shape.mouse.up.icon.numChildren > 0)
            {
               _shape.mouse.up.icon.removeChildAt(0);
            }
            while(_shape.mouse.mouse.icon.numChildren > 0)
            {
               _shape.mouse.mouse.icon.removeChildAt(0);
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
               _currShapeUp = _loc2_;
               if(_isMember)
               {
                  _currShapeUp.gotoAndStop("member");
               }
               if(_currShapeMouse)
               {
                  _currShapeUp.text.text = _currShapeMouse.level;
               }
               _shapesMediaHelperArray[0].destroy();
               _shapesMediaHelperArray.splice(0,1);
               while(_shape.mouse.up.icon.numChildren > 0)
               {
                  _shape.mouse.up.icon.removeChildAt(0);
               }
               _shape.mouse.up.icon.addChild(_currShapeUp);
            }
            else
            {
               _currShapeMouse = _loc2_;
               if(_isMember)
               {
                  _currShapeMouse.gotoAndStop("member");
               }
               _currShapeMouse.level = _currShapeMouse.text.text = param1.passback;
               if(_currShapeUp)
               {
                  _currShapeUp.text.text = _currShapeMouse.level;
               }
               _shapesMediaHelperArray[_shapesMediaHelperArray.length - 1].destroy();
               _shapesMediaHelperArray.pop();
               while(_shape.mouse.mouse.icon.numChildren > 0)
               {
                  _shape.mouse.mouse.icon.removeChildAt(0);
               }
               _shape.mouse.mouse.icon.addChild(_currShapeMouse);
            }
            _shape.mouse.gotoAndStop(1);
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
         _left.mouse.gotoAndPlay(1);
         _mid.mouse.gotoAndPlay(1);
         if(_shape)
         {
            _shape.mouse.gotoAndPlay(1);
         }
         if(_host)
         {
            _host.mouse.gotoAndPlay(1);
         }
         if(_right.nub.currentFrameLabel)
         {
            _right.nub[String(_right.nub.currentFrameLabel)].mouse.gotoAndPlay(1);
         }
         else
         {
            _right.nub.mouse.gotoAndPlay(1);
         }
         if(_isBlocked && _nubType != GUIDE)
         {
            _right.blocked.mouse.gotoAndPlay(1);
         }
      }
      
      private function onOutHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(_right.nub[String(_right.nub.currentFrameLabel)])
         {
            _loc2_ = _right.nub[String(_right.nub.currentFrameLabel)];
         }
         else
         {
            _loc2_ = _right.nub;
         }
         if(_left.mouse.currentFrame > 1)
         {
            playBackwards(_left.mouse);
         }
         else
         {
            _left.mouse.stop();
         }
         if(_mid.mouse.currentFrame > 1)
         {
            playBackwards(_mid.mouse);
         }
         else
         {
            _mid.mouse.stop();
         }
         if(_shape)
         {
            if(_shape.mouse.currentFrame > 1)
            {
               playBackwards(_shape.mouse);
            }
            else
            {
               _shape.mouse.stop();
            }
         }
         if(_host)
         {
            if(_host.mouse.currentFrame > 1)
            {
               playBackwards(_host.mouse);
            }
            else
            {
               _host.mouse.stop();
            }
         }
         if(_loc2_.mouse.currentFrame > 1)
         {
            playBackwards(_loc2_.mouse);
         }
         else
         {
            _loc2_.mouse.stop();
         }
         if(_isBlocked && _nubType != GUIDE)
         {
            if(_right.blocked.mouse.currentFrame > 1)
            {
               playBackwards(_right.blocked.mouse);
            }
            else
            {
               _right.blocked.mouse.stop();
            }
         }
      }
      
      private function playBackwards(param1:MovieClip) : void
      {
         param1.addEventListener("enterFrame",pbFrameHandler,false,0,true);
      }
      
      private function pbFrameHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.target as MovieClip)
         {
            _loc2_ = MovieClip(param1.target);
            if(_loc2_.currentFrame == 1)
            {
               _loc2_.removeEventListener("enterFrame",pbFrameHandler);
               return;
            }
            _loc2_.prevFrame();
         }
      }
   }
}

