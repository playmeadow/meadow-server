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
      
      public function init(layer:DisplayObjectContainer, msg:String, xPos:int, yPos:int, shouldUseTimer:Boolean = true) : void
      {
         this.setChild(layer);
         this.msgTxt.autoSize = TextFieldAutoSize.LEFT;
         this.setToolTipText(msg);
         this.setPos(xPos,yPos);
         this._useTimer = shouldUseTimer;
      }
      
      public function setToolTipText(msg:String) : void
      {
         var splitText:Array = null;
         var numAtt:int = 0;
         var totalTextHeight:int = 0;
         var widestText:int = 0;
         var j:int = 0;
         var att:TextField = null;
         var value:TextField = null;
         var i:int = 0;
         if(Boolean(msg) && Boolean(msg != "") && msg != this.msgTxt.text)
         {
            splitText = msg.split("|");
            this.msgTxt.text = splitText[0];
            this.middle.width = Math.ceil(this.msgTxt.textWidth + 5);
            this.middle.x = Math.round(-this.middle.width * 0.5);
            this.msgTxt.x = this.middle.x;
            this.left.x = this.middle.x - this.left.width;
            this.right.x = this.middle.x + this.middle.width;
            enabled = true;
            if(splitText.length > 1 && Boolean(this.extraInfo))
            {
               this.extraInfo.visible = true;
               splitText.shift();
               numAtt = splitText.length * 0.5;
               for(i = 0; i < this.NUM_EXTRA_TEXT_LINES; i++)
               {
                  att = this.extraInfo["att" + (i + 1)];
                  value = this.extraInfo["value" + (i + 1)];
                  if(i < numAtt)
                  {
                     att.visible = true;
                     value.visible = true;
                     att.autoSize = TextFieldAutoSize.LEFT;
                     value.autoSize = TextFieldAutoSize.LEFT;
                     att.text = splitText[j++];
                     value.text = splitText[j++];
                     totalTextHeight += att.textHeight;
                     widestText = Math.max(widestText,att.width + value.width + 5);
                  }
                  else
                  {
                     att.visible = false;
                     value.visible = false;
                  }
               }
               this.extraInfo.m.height = totalTextHeight;
               this.extraInfo.b.y = this.extraInfo.m.y + this.extraInfo.m.height;
               this.extraInfo.t.width = this.extraInfo.b.width = this.extraInfo.m.width = widestText;
               this.extraInfo.t.x = this.extraInfo.b.x = this.extraInfo.m.x = this.middle.x + this.middle.width * 0.5 - this.extraInfo.m.width * 0.5;
               for(i = 0; i < numAtt; i++)
               {
                  att = this.extraInfo["att" + (i + 1)];
                  value = this.extraInfo["value" + (i + 1)];
                  att.x = this.extraInfo.b.x + 2;
                  value.x = this.extraInfo.b.x + this.extraInfo.b.width - value.width - 2;
                  att.y = value.y = this.extraInfo.m.y + 2 + i * att.textHeight;
               }
            }
            else if(Boolean(this.extraInfo))
            {
               this.extraInfo.visible = false;
            }
         }
         else if(Boolean(this.extraInfo))
         {
            this.extraInfo.visible = false;
         }
      }
      
      public function setPos(x:int, y:int) : void
      {
         var globalPoint:Point = this.parent.localToGlobal(new Point(x,y));
         var widthRounded:int = Math.round(this.width * 0.5);
         var heightRounded:int = Math.round(this.height * 0.5);
         if(globalPoint.x - widthRounded < 0)
         {
            globalPoint.x += widthRounded - globalPoint.x;
         }
         else if(globalPoint.x + widthRounded > 900)
         {
            globalPoint.x -= globalPoint.x + widthRounded - 900;
         }
         if(globalPoint.y - heightRounded < 0)
         {
            globalPoint.y += heightRounded - globalPoint.y;
         }
         else if(globalPoint.y + heightRounded > 550)
         {
            globalPoint.y -= globalPoint.y + heightRounded - 550;
         }
         globalPoint = this.parent.globalToLocal(globalPoint);
         this.x = globalPoint.x;
         this.y = globalPoint.y;
      }
      
      public function bringToolToFront() : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function startTimer(currEvent:MouseEvent = null) : void
      {
         if(this._useTimer)
         {
            this.bringToolToFront();
            this.toolTipTimer.start();
            this.toolTipTimer.addEventListener(TimerEvent.TIMER,this.toolTipTimerHandler,false,0,true);
            this._currEvent = currEvent;
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
      
      public function toolTipTimerHandler(t:TimerEvent) : void
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
      
      public function setChild(display:DisplayObjectContainer) : void
      {
         display.addChild(this);
      }
   }
}

