package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   
   public class ToolTipPopup extends MovieClip
   {
      
      private const NUM_EXTRA_TEXT_LINES:int = 2;
      
      public var msgTxt:TextField;
      
      public var right:MovieClip;
      
      public var middle:MovieClip;
      
      public var left:MovieClip;
      
      public var extraInfo:MovieClip;
      
      public var toolTipTimer:Timer;
      
      private var _useTimer:Boolean;
      
      private var _currEvent:MouseEvent;
      
      public function ToolTipPopup()
      {
         super();
         this.msgTxt = this["txt"];
         this.right = this["r"];
         this.middle = this["m"];
         this.left = this["l"];
         this.extraInfo = this["tooltipCont"];
         enabled = false;
         visible = false;
         this.toolTipTimer = new Timer(225);
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      public function init(param1:DisplayObjectContainer, param2:String, param3:int, param4:int, param5:Boolean = true) : void
      {
         this.setChild(param1);
         this.msgTxt.autoSize = TextFieldAutoSize.LEFT;
         this.setToolTipText(param2);
         this.setPos(param3,param4);
         this._useTimer = param5;
      }
      
      public function setToolTipText(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:* = 0;
         var _loc7_:TextField = null;
         var _loc8_:TextField = null;
         var _loc9_:int = 0;
         if(Boolean(param1) && Boolean(param1 != "") && param1 != this.msgTxt.text)
         {
            _loc2_ = param1.split("|");
            this.msgTxt.text = _loc2_[0];
            this.middle.width = Math.ceil(this.msgTxt.textWidth + 5);
            this.middle.x = Math.round(-this.middle.width * 0.5);
            this.msgTxt.x = this.middle.x;
            this.left.x = this.middle.x - this.left.width;
            this.right.x = this.middle.x + this.middle.width;
            enabled = true;
            if(_loc2_.length > 1 && Boolean(this.extraInfo))
            {
               this.extraInfo.visible = true;
               _loc2_.shift();
               _loc3_ = _loc2_.length * 0.5;
               _loc9_ = 0;
               while(_loc9_ < this.NUM_EXTRA_TEXT_LINES)
               {
                  _loc7_ = this.extraInfo["att" + (_loc9_ + 1)];
                  _loc8_ = this.extraInfo["value" + (_loc9_ + 1)];
                  if(_loc9_ < _loc3_)
                  {
                     _loc7_.visible = true;
                     _loc8_.visible = true;
                     _loc7_.autoSize = TextFieldAutoSize.LEFT;
                     _loc8_.autoSize = TextFieldAutoSize.LEFT;
                     _loc7_.text = _loc2_[_loc6_++];
                     _loc8_.text = _loc2_[_loc6_++];
                     _loc4_ += _loc7_.textHeight;
                     _loc5_ = Math.max(_loc5_,_loc7_.width + _loc8_.width + 5);
                  }
                  else
                  {
                     _loc7_.visible = false;
                     _loc8_.visible = false;
                  }
                  _loc9_++;
               }
               this.extraInfo.m.height = _loc4_;
               this.extraInfo.b.y = this.extraInfo.m.y + this.extraInfo.m.height;
               this.extraInfo.t.width = this.extraInfo.b.width = this.extraInfo.m.width = _loc5_;
               this.extraInfo.t.x = this.extraInfo.b.x = this.extraInfo.m.x = this.middle.x + this.middle.width * 0.5 - this.extraInfo.m.width * 0.5;
               _loc9_ = 0;
               while(_loc9_ < _loc3_)
               {
                  _loc7_ = this.extraInfo["att" + (_loc9_ + 1)];
                  _loc8_ = this.extraInfo["value" + (_loc9_ + 1)];
                  _loc7_.x = this.extraInfo.b.x + 2;
                  _loc8_.x = this.extraInfo.b.x + this.extraInfo.b.width - _loc8_.width - 2;
                  _loc7_.y = _loc8_.y = this.extraInfo.m.y + 2 + _loc9_ * _loc7_.textHeight;
                  _loc9_++;
               }
            }
            else if(this.extraInfo)
            {
               this.extraInfo.visible = false;
            }
         }
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         var _loc3_:Point = this.parent.localToGlobal(new Point(param1,param2));
         var _loc4_:int = Math.round(this.width * 0.5);
         var _loc5_:int = Math.round(this.height * 0.5);
         if(_loc3_.x - _loc4_ < 0)
         {
            _loc3_.x += _loc4_ - _loc3_.x;
         }
         else if(_loc3_.x + _loc4_ > 900)
         {
            _loc3_.x -= _loc3_.x + _loc4_ - 900;
         }
         if(_loc3_.y - _loc5_ < 0)
         {
            _loc3_.y += _loc5_ - _loc3_.y;
         }
         else if(_loc3_.y + _loc5_ > 550)
         {
            _loc3_.y -= _loc3_.y + _loc5_ - 550;
         }
         _loc3_ = this.parent.globalToLocal(_loc3_);
         this.x = _loc3_.x;
         this.y = _loc3_.y;
      }
      
      public function bringToolToFront() : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function startTimer(param1:MouseEvent = null) : void
      {
         if(this._useTimer)
         {
            this.bringToolToFront();
            this.toolTipTimer.start();
            this.toolTipTimer.addEventListener(TimerEvent.TIMER,this.toolTipTimerHandler,false,0,true);
            this._currEvent = param1;
         }
         else
         {
            visible = true;
         }
      }
      
      public function isTimerRunning() : Boolean
      {
         return this.toolTipTimer.running;
      }
      
      public function resetTimerAndSetVisibility() : void
      {
         this.toolTipTimer.reset();
         this.toolTipTimer.removeEventListener(TimerEvent.TIMER,this.toolTipTimerHandler);
         visible = false;
         this._currEvent = null;
      }
      
      public function toolTipTimerHandler(param1:TimerEvent) : void
      {
         this.toolTipTimer.stop();
         if(Boolean(this._currEvent) && Boolean(this._currEvent.currentTarget.hitTestPoint(this._currEvent.stageX,this._currEvent.stageY)))
         {
            visible = true;
         }
         else
         {
            this.resetTimerAndSetVisibility();
         }
      }
      
      public function setChild(param1:DisplayObjectContainer) : void
      {
         param1.addChild(this);
      }
   }
}

