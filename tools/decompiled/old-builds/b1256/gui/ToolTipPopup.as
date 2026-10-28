package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
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
         msgTxt = this["txt"];
         right = this["r"];
         middle = this["m"];
         left = this["l"];
         extraInfo = this["tooltipCont"];
         enabled = false;
         visible = false;
         toolTipTimer = new Timer(225);
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      public function init(param1:DisplayObjectContainer, param2:String, param3:int, param4:int, param5:Boolean = true) : void
      {
         setChild(param1);
         msgTxt.autoSize = "left";
         setToolTipText(param2);
         setPos(param3,param4);
         _useTimer = param5;
      }
      
      public function setToolTipText(param1:String) : void
      {
         var _loc3_:Array = null;
         var _loc2_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:TextField = null;
         var _loc4_:TextField = null;
         var _loc9_:int = 0;
         if(param1 && param1 != "" && param1 != msgTxt.text)
         {
            _loc3_ = param1.split("|");
            msgTxt.text = _loc3_[0];
            middle.width = Math.ceil(msgTxt.textWidth + 5);
            middle.x = Math.round(-middle.width * 0.5);
            msgTxt.x = middle.x;
            left.x = middle.x - left.width;
            right.x = middle.x + middle.width;
            enabled = true;
            if(_loc3_.length > 1 && extraInfo)
            {
               extraInfo.visible = true;
               _loc3_.shift();
               _loc2_ = _loc3_.length * 0.5;
               _loc9_ = 0;
               while(_loc9_ < 2)
               {
                  _loc5_ = extraInfo["att" + (_loc9_ + 1)];
                  _loc4_ = extraInfo["value" + (_loc9_ + 1)];
                  if(_loc9_ < _loc2_)
                  {
                     _loc5_.visible = true;
                     _loc4_.visible = true;
                     _loc5_.autoSize = "left";
                     _loc4_.autoSize = "left";
                     _loc5_.text = _loc3_[_loc7_++];
                     _loc4_.text = _loc3_[_loc7_++];
                     _loc8_ += _loc5_.textHeight;
                     _loc6_ = Math.max(_loc6_,_loc5_.width + _loc4_.width + 5);
                  }
                  else
                  {
                     _loc5_.visible = false;
                     _loc4_.visible = false;
                  }
                  _loc9_++;
               }
               extraInfo.m.height = _loc8_;
               extraInfo.b.y = extraInfo.m.y + extraInfo.m.height;
               extraInfo.t.width = extraInfo.b.width = extraInfo.m.width = _loc6_;
               extraInfo.t.x = extraInfo.b.x = extraInfo.m.x = middle.x + middle.width * 0.5 - extraInfo.m.width * 0.5;
               _loc9_ = 0;
               while(_loc9_ < _loc2_)
               {
                  _loc5_ = extraInfo["att" + (_loc9_ + 1)];
                  _loc4_ = extraInfo["value" + (_loc9_ + 1)];
                  _loc5_.x = extraInfo.b.x + 2;
                  _loc4_.x = extraInfo.b.x + extraInfo.b.width - _loc4_.width - 2;
                  _loc5_.y = _loc4_.y = extraInfo.m.y + 2 + _loc9_ * _loc5_.textHeight;
                  _loc9_++;
               }
            }
            else if(extraInfo)
            {
               extraInfo.visible = false;
            }
         }
         else if(extraInfo)
         {
            extraInfo.visible = false;
         }
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         var _loc5_:Point = this.parent.localToGlobal(new Point(param1,param2));
         var _loc4_:int = Math.round(this.width * 0.5);
         var _loc3_:int = Math.round(this.height * 0.5);
         if(_loc5_.x - _loc4_ < 0)
         {
            _loc5_.x += _loc4_ - _loc5_.x;
         }
         else if(_loc5_.x + _loc4_ > 900)
         {
            _loc5_.x -= _loc5_.x + _loc4_ - 900;
         }
         if(_loc5_.y - _loc3_ < 0)
         {
            _loc5_.y += _loc3_ - _loc5_.y;
         }
         else if(_loc5_.y + _loc3_ > 550)
         {
            _loc5_.y -= _loc5_.y + _loc3_ - 550;
         }
         _loc5_ = this.parent.globalToLocal(_loc5_);
         this.x = _loc5_.x;
         this.y = _loc5_.y;
      }
      
      public function bringToolToFront() : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function startTimer(param1:MouseEvent = null) : void
      {
         if(_useTimer)
         {
            bringToolToFront();
            toolTipTimer.start();
            toolTipTimer.addEventListener("timer",toolTipTimerHandler,false,0,true);
            _currEvent = param1;
         }
         else
         {
            visible = true;
         }
      }
      
      public function isTimerRunning() : Boolean
      {
         return toolTipTimer.running;
      }
      
      public function resetTimerAndSetVisibility() : void
      {
         toolTipTimer.reset();
         toolTipTimer.removeEventListener("timer",toolTipTimerHandler);
         visible = false;
         _currEvent = null;
      }
      
      public function toolTipTimerHandler(param1:TimerEvent) : void
      {
         toolTipTimer.stop();
         if(_currEvent && _currEvent.currentTarget.hitTestPoint(_currEvent.stageX,_currEvent.stageY))
         {
            visible = true;
         }
         else
         {
            resetTimerAndSetVisibility();
         }
      }
      
      public function setChild(param1:DisplayObjectContainer) : void
      {
         param1.addChild(this);
      }
   }
}

