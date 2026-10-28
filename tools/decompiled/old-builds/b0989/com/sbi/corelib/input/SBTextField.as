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
      
      public function SBTextField(param1:TextField, param2:TextField, param3:MovieClip, param4:Boolean = false, param5:Boolean = false, param6:Function = null)
      {
         super();
         this._inputTxt = param1;
         this._outputTxt = param2;
         this._clearOutput = param4;
         this._updateSizeFunction = param6;
         this._outputTxt.addEventListener(Event.SCROLL,this.scrollListener);
         if(this._inputTxt)
         {
            this._inputTxt.text = "";
         }
         this._smileyHistory = "";
         this._smileyarray = new Array();
         this._stringIndex = 0;
         this._smileyHolder = new MovieClip();
         this._smileyHolder.graphics.beginFill(0,0);
         this._smileyHolder.graphics.drawRect(param3.x,param3.y,param2.width,param2.height);
         this._smileyHolder.graphics.endFill();
         this._smileyHolder.mouseChildren = false;
         this._smileyHolder.mouseEnabled = false;
         if(!this._clearOutput)
         {
            this._smileyMask = new MovieClip();
            this._smileyMask.graphics.beginFill(16777215,1);
            this._smileyMask.graphics.drawRect(param3.x,param3.y,param3.width,param3.height);
            this._smileyMask.graphics.endFill();
            this._smileyHolder.mask = this._smileyMask;
         }
         if(param3.parent)
         {
            param3.parent.addChild(this._smileyHolder);
            if(!this._clearOutput)
            {
               param3.parent.addChild(this._smileyMask);
            }
         }
         else
         {
            param3.addChild(this._smileyHolder);
            if(!this._clearOutput)
            {
               param3.addChild(this._smileyMask);
            }
         }
         if(param2 == null || param3 == null)
         {
            throw new Error("Output Textfield and/or text display movie clip cannot be null. Output Textfield = " + param2 + " text Display MC = " + param3);
         }
      }
      
      public function destroy() : void
      {
      }
      
      public function trimHistory() : void
      {
         var _loc1_:String = this._outputTxt.text;
         var _loc2_:int = _loc1_.indexOf("\r") + 1;
         _loc1_ = _loc1_.substr(_loc2_);
         this.clear();
         this.appendText(_loc1_);
      }
      
      public function adjustSmileys(param1:Number) : void
      {
         this._smileyHolder.y -= param1;
      }
      
      public function get autoSize() : String
      {
         return this._outputTxt.autoSize;
      }
      
      public function set autoSize(param1:String) : void
      {
         this._outputTxt.autoSize = param1;
      }
      
      public function get text() : String
      {
         return this._outputTxt.text;
      }
      
      public function set text(param1:String) : void
      {
         if(this._clearOutput || param1 == "")
         {
            this.clear();
         }
         this.addText(param1);
      }
      
      public function get textColor() : uint
      {
         return this._outputTxt.textColor;
      }
      
      public function set textColor(param1:uint) : void
      {
         this._outputTxt.textColor = param1;
      }
      
      override public function get x() : Number
      {
         return this._outputTxt.x;
      }
      
      override public function set x(param1:Number) : void
      {
         this._outputTxt.x = param1;
      }
      
      override public function get y() : Number
      {
         return this._outputTxt.y;
      }
      
      override public function set y(param1:Number) : void
      {
         this._outputTxt.y = param1;
      }
      
      override public function get height() : Number
      {
         return this._outputTxt.height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._outputTxt.height = param1;
      }
      
      override public function get width() : Number
      {
         return this._outputTxt.width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._outputTxt.width = param1;
      }
      
      override public function get visible() : Boolean
      {
         return this._outputTxt.visible;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         this._outputTxt.visible = param1;
      }
      
      override public function get alpha() : Number
      {
         return this._outputTxt.alpha;
      }
      
      override public function set alpha(param1:Number) : void
      {
         this._outputTxt.alpha = param1;
      }
      
      public function appendText(param1:String) : void
      {
         if(this._clearOutput || param1 == "")
         {
            this.clear();
         }
         this.addText(param1);
      }
      
      public function set scrollV(param1:int) : void
      {
         this._outputTxt.scrollV = param1;
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
      
      public function set defaultTextFormat(param1:TextFormat) : void
      {
         param1.align = TextFormatAlign.LEFT;
         this._outputTxt.defaultTextFormat = param1;
      }
      
      public function setTextFormat(param1:TextFormat, param2:int = -1, param3:int = -1) : void
      {
         param1.align = TextFormatAlign.LEFT;
         this._outputTxt.setTextFormat(param1,param2,param3);
         this._outputTxt.defaultTextFormat = param1;
      }
      
      public function get numLines() : int
      {
         return this._outputTxt.numLines;
      }
      
      public function get selectable() : Boolean
      {
         return this._outputTxt.selectable;
      }
      
      public function set selectable(param1:Boolean) : void
      {
         this._outputTxt.selectable = param1;
      }
      
      public function getTextFormat(param1:int = -1, param2:int = -1) : TextFormat
      {
         return this._outputTxt.getTextFormat(param1,param2);
      }
      
      private function addText(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:Object = null;
         var _loc8_:TextField = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         if(param1 != "")
         {
            this._normalStringHistory += param1;
            _loc7_ = EmoticonUtility.formatStringForSmiley(param1,this._stringIndex,this._smileyarray,this.updateAllEmotes);
            param1 = _loc7_.str;
            this._stringIndex = _loc7_.stringIndex;
            this._smileyarray = _loc7_.smileyArray;
            this.updateAllEmotes = false;
            this._outputTxt.appendText(param1);
            if(this._outputTxt.scrollV + 1 >= this._outputTxt.maxScrollV)
            {
               this._outputTxt.scrollV = this._outputTxt.maxScrollV;
            }
            if(this.numLines >= this.CHAT_BUFFER_SIZE)
            {
               this._outputTxt.text = this._normalStringHistory;
               _loc8_ = this._outputTxt;
               while(_loc8_.numLines > this.CHAT_BUFFER_SIZE * 0.5)
               {
                  _loc10_ = _loc8_.text.indexOf("\r") + 1;
                  _loc8_.text = _loc8_.text.substr(_loc10_);
               }
               _loc9_ = _loc8_.text.split("\r").join("\n");
               this.updateAllEmotes = true;
               this.clear();
               this.text = _loc9_;
               _loc8_ = null;
               return;
            }
            setTimeout(this.setupSmileys,1000 / 24,param1);
         }
      }
      
      private function setupSmileys(param1:String) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Rectangle = null;
         var _loc6_:TextLineMetrics = null;
         var _loc7_:MovieClip = null;
         var _loc8_:Number = NaN;
         var _loc2_:Number = 0;
         var _loc3_:Array = [];
         for(; _loc4_ < this._smileyarray.length; _loc4_++)
         {
            if(this._smileyarray[_loc4_] != null)
            {
               if(!this._smileyarray[_loc4_].added)
               {
                  _loc5_ = this._outputTxt.getCharBoundaries(this._smileyarray[_loc4_].strindex);
                  if(_loc5_)
                  {
                     _loc6_ = this._outputTxt.getLineMetrics(this._outputTxt.numLines - 1);
                     _loc7_ = this._smileyarray[_loc4_].emoticon;
                     _loc7_.height = _loc6_.height;
                     _loc7_.scaleX = _loc7_.scaleY;
                     _loc8_ = _loc5_.x + _loc7_.width * 0.5;
                     if(_loc8_ > this._outputTxt.width)
                     {
                        _loc5_ = this._outputTxt.getCharBoundaries(this._smileyarray[_loc4_].strindex + 1);
                        if(!_loc5_)
                        {
                           continue;
                        }
                        _loc7_.x = _loc5_.x + this._outputTxt.x + _loc7_.width * 0.5 - 5;
                        _loc7_.y = _loc5_.y + this._outputTxt.y + _loc7_.height * 0.5;
                     }
                     else
                     {
                        _loc7_.x = _loc5_.x + this._outputTxt.x + _loc7_.width * 0.5;
                        _loc7_.y = _loc5_.y + this._outputTxt.y + _loc7_.height * 0.5;
                     }
                     this._smileyHolder.addChild(_loc7_);
                     this._smileyarray[_loc4_].added = true;
                  }
               }
            }
         }
         if(this._smileyHistory == "")
         {
            this._smileyHistory = param1;
         }
         else
         {
            this._smileyHistory += "\n" + param1;
         }
         this._smileyarray = [];
         if(this._updateSizeFunction != null)
         {
            this._updateSizeFunction();
         }
      }
      
      private function addSmileys(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this._smileyHolder.addChild(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      private function clear() : void
      {
         if(this._inputTxt)
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
      
      private function removeSpace(param1:String) : String
      {
         var _loc2_:int = 0;
         var _loc3_:String = "";
         var _loc4_:Array = param1.split("");
         _loc2_ = 0;
         while(_loc2_ < _loc4_.length)
         {
            if(_loc3_ == " ")
            {
               if(_loc4_[_loc2_] == " ")
               {
                  _loc4_[_loc2_] = "";
                  _loc3_ = " ";
               }
               else
               {
                  _loc3_ = _loc4_[_loc2_];
               }
            }
            else
            {
               _loc3_ = _loc4_[_loc2_];
            }
            _loc2_++;
         }
         return _loc4_.join("");
      }
      
      private function scrollListener(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:TextLineMetrics = null;
         var _loc4_:Number = NaN;
         if(!this._clearOutput)
         {
            _loc4_ = 0;
            _loc2_ = 0;
            while(_loc2_ < this._outputTxt.scrollV - 1)
            {
               _loc3_ = this._outputTxt.getLineMetrics(_loc2_);
               _loc4_ += _loc3_.height;
               _loc2_++;
            }
            this._smileyHolder.y = -_loc4_;
         }
      }
      
      private function setSize(param1:Number, param2:Number) : void
      {
         this._smileyMask.width = param1;
         this._smileyMask.height = param2 - 6;
      }
   }
}

