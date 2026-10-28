package com.sbi.corelib.input
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.text.TextLineMetrics;
   import flash.utils.setTimeout;
   import gui.EmoticonUtility;
   
   public class SBTextField extends MovieClip
   {
      
      private const CHAT_BUFFER_SIZE:int = 100;
      
      private var _inputTxt:TextField;
      
      private var _outputTxt:TextField;
      
      private var _smileyHolder:MovieClip;
      
      private var _smileyMask:MovieClip;
      
      private var _smileyHistory:String;
      
      private var _clearOutput:Boolean;
      
      private var _smileyarray:Array;
      
      private var _stringIndex:int;
      
      private var _normalStringHistory:String;
      
      private var _updateSizeFunction:Function;
      
      private var updateAllEmotes:Boolean;
      
      public function SBTextField(inputTextField:TextField, outputTextField:TextField, textDisplayMC:MovieClip, clearOutputEachTime:Boolean = false, useScrollBar:Boolean = false, updateSizeFunction:Function = null)
      {
         super();
         this._inputTxt = inputTextField;
         this._outputTxt = outputTextField;
         this._clearOutput = clearOutputEachTime;
         this._updateSizeFunction = updateSizeFunction;
         this._outputTxt.addEventListener(Event.SCROLL,this.scrollListener);
         if(Boolean(this._inputTxt))
         {
            this._inputTxt.text = "";
         }
         this._smileyHistory = "";
         this._smileyarray = new Array();
         this._stringIndex = 0;
         this._smileyHolder = new MovieClip();
         this._smileyHolder.graphics.beginFill(0,0);
         this._smileyHolder.graphics.drawRect(textDisplayMC.x,textDisplayMC.y,outputTextField.width,outputTextField.height);
         this._smileyHolder.graphics.endFill();
         this._smileyHolder.mouseChildren = false;
         this._smileyHolder.mouseEnabled = false;
         if(!this._clearOutput)
         {
            this._smileyMask = new MovieClip();
            this._smileyMask.graphics.beginFill(16777215,1);
            this._smileyMask.graphics.drawRect(textDisplayMC.x,textDisplayMC.y,textDisplayMC.width,textDisplayMC.height);
            this._smileyMask.graphics.endFill();
            this._smileyHolder.mask = this._smileyMask;
         }
         if(Boolean(textDisplayMC.parent))
         {
            textDisplayMC.parent.addChild(this._smileyHolder);
            if(!this._clearOutput)
            {
               textDisplayMC.parent.addChild(this._smileyMask);
            }
         }
         else
         {
            textDisplayMC.addChild(this._smileyHolder);
            if(!this._clearOutput)
            {
               textDisplayMC.addChild(this._smileyMask);
            }
         }
         if(outputTextField == null || textDisplayMC == null)
         {
            throw new Error("Output Textfield and/or text display movie clip cannot be null. Output Textfield = " + outputTextField + " text Display MC = " + textDisplayMC);
         }
      }
      
      public function destroy() : void
      {
      }
      
      public function trimHistory() : void
      {
         var tempStr:String = this._outputTxt.text;
         var index:int = tempStr.indexOf("\r") + 1;
         tempStr = tempStr.substr(index);
         this.clear();
         this.appendText(tempStr);
      }
      
      public function adjustSmileys(value:Number) : void
      {
         this._smileyHolder.y -= value;
      }
      
      public function get autoSize() : String
      {
         return this._outputTxt.autoSize;
      }
      
      public function set autoSize(value:String) : void
      {
         this._outputTxt.autoSize = value;
      }
      
      public function get text() : String
      {
         return this._outputTxt.text;
      }
      
      public function set text(value:String) : void
      {
         if(this._clearOutput || value == "")
         {
            this.clear();
         }
         this.addText(value);
      }
      
      public function get textColor() : uint
      {
         return this._outputTxt.textColor;
      }
      
      public function set textColor(value:uint) : void
      {
         this._outputTxt.textColor = value;
      }
      
      override public function get x() : Number
      {
         return this._outputTxt.x;
      }
      
      override public function set x(value:Number) : void
      {
         this._outputTxt.x = value;
      }
      
      override public function get y() : Number
      {
         return this._outputTxt.y;
      }
      
      override public function set y(value:Number) : void
      {
         this._outputTxt.y = value;
      }
      
      override public function get height() : Number
      {
         return this._outputTxt.height;
      }
      
      override public function set height(value:Number) : void
      {
         this._outputTxt.height = value;
      }
      
      override public function get width() : Number
      {
         return this._outputTxt.width;
      }
      
      override public function set width(value:Number) : void
      {
         this._outputTxt.width = value;
      }
      
      override public function get visible() : Boolean
      {
         return this._outputTxt.visible;
      }
      
      override public function set visible(value:Boolean) : void
      {
         this._outputTxt.visible = value;
      }
      
      override public function get alpha() : Number
      {
         return this._outputTxt.alpha;
      }
      
      override public function set alpha(value:Number) : void
      {
         this._outputTxt.alpha = value;
      }
      
      public function appendText(value:String) : void
      {
         if(this._clearOutput || value == "")
         {
            this.clear();
         }
         this.addText(value);
      }
      
      public function set scrollV(value:int) : void
      {
         this._outputTxt.scrollV = value;
      }
      
      public function get scrollV() : int
      {
         return this._outputTxt.scrollV;
      }
      
      public function get maxScrollV() : int
      {
         return this._outputTxt.maxScrollV;
      }
      
      public function get length() : int
      {
         return this._outputTxt.length;
      }
      
      public function set defaultTextFormat(format:TextFormat) : void
      {
         format.align = TextFormatAlign.LEFT;
         this._outputTxt.defaultTextFormat = format;
      }
      
      public function setTextFormat(format:TextFormat, beginIndex:int = -1, endIndex:int = -1) : void
      {
         format.align = TextFormatAlign.LEFT;
         this._outputTxt.setTextFormat(format,beginIndex,endIndex);
         this._outputTxt.defaultTextFormat = format;
      }
      
      public function get numLines() : int
      {
         return this._outputTxt.numLines;
      }
      
      public function get selectable() : Boolean
      {
         return this._outputTxt.selectable;
      }
      
      public function set selectable(value:Boolean) : void
      {
         this._outputTxt.selectable = value;
      }
      
      public function getTextFormat(beginIndex:int = -1, endIndex:int = -1) : TextFormat
      {
         return this._outputTxt.getTextFormat(beginIndex,endIndex);
      }
      
      private function addText(str:String) : void
      {
         var i:String = null;
         var smiley:String = null;
         var n:int = 0;
         var h:String = null;
         var htmltag:Boolean = false;
         var formatedObj:Object = null;
         var temp:TextField = null;
         var tempTxt:String = null;
         var index:int = 0;
         if(str != "")
         {
            this._normalStringHistory += str;
            formatedObj = EmoticonUtility.formatStringForSmiley(str,this._stringIndex,this._smileyarray,this.updateAllEmotes);
            str = formatedObj.str;
            this._stringIndex = formatedObj.stringIndex;
            this._smileyarray = formatedObj.smileyArray;
            this.updateAllEmotes = false;
            this._outputTxt.appendText(str);
            if(this._outputTxt.scrollV + 1 >= this._outputTxt.maxScrollV)
            {
               this._outputTxt.scrollV = this._outputTxt.maxScrollV;
            }
            if(this.numLines >= this.CHAT_BUFFER_SIZE)
            {
               this._outputTxt.text = this._normalStringHistory;
               temp = this._outputTxt;
               while(temp.numLines > this.CHAT_BUFFER_SIZE * 0.5)
               {
                  index = temp.text.indexOf("\r") + 1;
                  temp.text = temp.text.substr(index);
               }
               tempTxt = temp.text.split("\r").join("\n");
               this.updateAllEmotes = true;
               this.clear();
               this.text = tempTxt;
               temp = null;
               return;
            }
            setTimeout(this.setupSmileys,1000 / 24,str);
         }
      }
      
      private function setupSmileys(str:String) : void
      {
         var s:int = 0;
         var charboundaries:Rectangle = null;
         var finalLineMetrics:TextLineMetrics = null;
         var smileyMC:MovieClip = null;
         var currXPosition:Number = NaN;
         var lastYPosition:Number = 0;
         for(var itemsToAdd:Array = []; s < this._smileyarray.length; s++)
         {
            if(this._smileyarray[s] != null)
            {
               if(!this._smileyarray[s].added)
               {
                  charboundaries = this._outputTxt.getCharBoundaries(this._smileyarray[s].strindex);
                  if(Boolean(charboundaries))
                  {
                     finalLineMetrics = this._outputTxt.getLineMetrics(this._outputTxt.numLines - 1);
                     smileyMC = this._smileyarray[s].emoticon;
                     smileyMC.height = finalLineMetrics.height;
                     smileyMC.scaleX = smileyMC.scaleY;
                     currXPosition = charboundaries.x + smileyMC.width * 0.5;
                     if(currXPosition > this._outputTxt.width)
                     {
                        charboundaries = this._outputTxt.getCharBoundaries(this._smileyarray[s].strindex + 1);
                        if(!Boolean(charboundaries))
                        {
                           continue;
                        }
                        smileyMC.x = charboundaries.x + this._outputTxt.x + smileyMC.width * 0.5 - 5;
                        smileyMC.y = charboundaries.y + this._outputTxt.y + smileyMC.height * 0.5;
                     }
                     else
                     {
                        smileyMC.x = charboundaries.x + this._outputTxt.x + smileyMC.width * 0.5;
                        smileyMC.y = charboundaries.y + this._outputTxt.y + smileyMC.height * 0.5;
                     }
                     this._smileyHolder.addChild(smileyMC);
                     this._smileyarray[s].added = true;
                  }
               }
            }
         }
         if(this._smileyHistory == "")
         {
            this._smileyHistory = str;
         }
         else
         {
            this._smileyHistory += "\n" + str;
         }
         this._smileyarray = [];
         if(this._updateSizeFunction != null)
         {
            this._updateSizeFunction();
         }
      }
      
      private function addSmileys(itemsToAdd:Array) : void
      {
         for(var i:int = 0; i < itemsToAdd.length; i++)
         {
            this._smileyHolder.addChild(itemsToAdd[i]);
         }
      }
      
      private function clear() : void
      {
         if(Boolean(this._inputTxt))
         {
            this._inputTxt.text = "";
         }
         this._smileyHolder.y = 0;
         while(this._smileyHolder.numChildren > 0)
         {
            this._smileyHolder.removeChildAt(0);
         }
         this._outputTxt.text = "";
         this._smileyarray = [];
         this._smileyHistory = "";
         this._stringIndex = 0;
         this._normalStringHistory = "";
      }
      
      private function removeSpace(str:String) : String
      {
         var i:int = 0;
         var lastchar:String = "";
         var stringarray:Array = str.split("");
         for(i = 0; i < stringarray.length; i++)
         {
            if(lastchar == " ")
            {
               if(stringarray[i] == " ")
               {
                  stringarray[i] = "";
                  lastchar = " ";
               }
               else
               {
                  lastchar = stringarray[i];
               }
            }
            else
            {
               lastchar = stringarray[i];
            }
         }
         return stringarray.join("");
      }
      
      private function scrollListener(evt:Event) : void
      {
         var i:int = 0;
         var metrics:TextLineMetrics = null;
         var ypos:Number = NaN;
         if(!this._clearOutput)
         {
            ypos = 0;
            for(i = 0; i < this._outputTxt.scrollV - 1; i++)
            {
               metrics = this._outputTxt.getLineMetrics(i);
               ypos += metrics.height;
            }
            this._smileyHolder.y = -ypos;
         }
      }
      
      private function setSize(w:Number, h:Number) : void
      {
         this._smileyMask.width = w;
         this._smileyMask.height = h - 6;
      }
   }
}

