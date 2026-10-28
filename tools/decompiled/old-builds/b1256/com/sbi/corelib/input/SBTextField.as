package com.sbi.corelib.input
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
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
      
      private var _hasOnlyOneEmote:Boolean;
      
      public function SBTextField(param1:TextField, param2:TextField, param3:MovieClip, param4:Boolean = false, param5:Boolean = false, param6:Function = null)
      {
         super();
         _inputTxt = param1;
         _outputTxt = param2;
         _clearOutput = param4;
         _updateSizeFunction = param6;
         _outputTxt.addEventListener("scroll",scrollListener);
         if(_inputTxt)
         {
            _inputTxt.text = "";
         }
         _smileyHistory = "";
         _smileyarray = [];
         _stringIndex = 0;
         _smileyHolder = new MovieClip();
         _smileyHolder.graphics.beginFill(0,0);
         _smileyHolder.graphics.drawRect(param3.x,param3.y,param2.width,param2.height);
         _smileyHolder.graphics.endFill();
         _smileyHolder.mouseChildren = false;
         _smileyHolder.mouseEnabled = false;
         if(!_clearOutput)
         {
            _smileyMask = new MovieClip();
            _smileyMask.graphics.beginFill(16777215,1);
            _smileyMask.graphics.drawRect(param3.x,param3.y,param3.width,param3.height);
            _smileyMask.graphics.endFill();
            _smileyHolder.mask = _smileyMask;
         }
         if(param3.parent)
         {
            param3.parent.addChild(_smileyHolder);
            if(!_clearOutput)
            {
               param3.parent.addChild(_smileyMask);
            }
         }
         else
         {
            param3.addChild(_smileyHolder);
            if(!_clearOutput)
            {
               param3.addChild(_smileyMask);
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
         var _loc1_:String = _outputTxt.text;
         var _loc2_:int = _loc1_.indexOf("\r") + 1;
         _loc1_ = _loc1_.substr(_loc2_);
         clear();
         appendText(_loc1_);
      }
      
      public function adjustSmileys(param1:Number) : void
      {
         _smileyHolder.y -= param1;
      }
      
      public function get autoSize() : String
      {
         return _outputTxt.autoSize;
      }
      
      public function set autoSize(param1:String) : void
      {
         _outputTxt.autoSize = param1;
      }
      
      public function get text() : String
      {
         return _outputTxt.text;
      }
      
      public function set text(param1:String) : void
      {
         if(_clearOutput || param1 == "")
         {
            clear();
         }
         addText(param1);
      }
      
      public function get textColor() : uint
      {
         return _outputTxt.textColor;
      }
      
      public function set textColor(param1:uint) : void
      {
         _outputTxt.textColor = param1;
      }
      
      override public function get x() : Number
      {
         return _outputTxt.x;
      }
      
      override public function set x(param1:Number) : void
      {
         _outputTxt.x = param1;
      }
      
      override public function get y() : Number
      {
         return _outputTxt.y;
      }
      
      override public function set y(param1:Number) : void
      {
         _outputTxt.y = param1;
      }
      
      override public function get height() : Number
      {
         return _outputTxt.height;
      }
      
      override public function set height(param1:Number) : void
      {
         _outputTxt.height = param1;
      }
      
      override public function get width() : Number
      {
         return _outputTxt.width;
      }
      
      override public function set width(param1:Number) : void
      {
         _outputTxt.width = param1;
      }
      
      override public function get visible() : Boolean
      {
         return _outputTxt.visible;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         _outputTxt.visible = param1;
      }
      
      override public function get alpha() : Number
      {
         return _outputTxt.alpha;
      }
      
      override public function set alpha(param1:Number) : void
      {
         _outputTxt.alpha = param1;
      }
      
      public function appendText(param1:String) : void
      {
         if(_clearOutput || param1 == "")
         {
            clear();
         }
         addText(param1);
      }
      
      public function set scrollV(param1:int) : void
      {
         _outputTxt.scrollV = param1;
      }
      
      public function get scrollV() : int
      {
         return _outputTxt.scrollV;
      }
      
      public function get maxScrollV() : int
      {
         return _outputTxt.maxScrollV;
      }
      
      public function get length() : int
      {
         return _outputTxt.length;
      }
      
      public function set defaultTextFormat(param1:TextFormat) : void
      {
         param1.align = "left";
         _outputTxt.defaultTextFormat = param1;
      }
      
      public function setTextFormat(param1:TextFormat, param2:int = -1, param3:int = -1) : void
      {
         param1.align = "left";
         _outputTxt.setTextFormat(param1,param2,param3);
         _outputTxt.defaultTextFormat = param1;
      }
      
      public function get numLines() : int
      {
         return _outputTxt.numLines;
      }
      
      public function get selectable() : Boolean
      {
         return _outputTxt.selectable;
      }
      
      public function set selectable(param1:Boolean) : void
      {
         _outputTxt.selectable = param1;
      }
      
      public function getTextFormat(param1:int = -1, param2:int = -1) : TextFormat
      {
         return _outputTxt.getTextFormat(param1,param2);
      }
      
      private function addText(param1:String) : void
      {
         var _loc10_:* = null;
         var _loc5_:* = null;
         var _loc6_:int = 0;
         var _loc9_:* = null;
         var _loc4_:Boolean = false;
         var _loc2_:Object = null;
         var _loc7_:TextField = null;
         var _loc8_:String = null;
         var _loc3_:int = 0;
         if(param1 != "")
         {
            _normalStringHistory += param1;
            updateAllEmotes = true;
            _loc2_ = EmoticonUtility.formatStringForSmiley(param1,_stringIndex,_smileyarray,updateAllEmotes);
            param1 = _loc2_.str;
            _stringIndex = _loc2_.stringIndex;
            _smileyarray = _loc2_.smileyArray;
            _hasOnlyOneEmote = _loc2_.hasOnlyOne;
            _outputTxt.appendText(param1);
            if(_outputTxt.scrollV + 1 >= _outputTxt.maxScrollV)
            {
               _outputTxt.scrollV = _outputTxt.maxScrollV;
            }
            if(numLines >= 100)
            {
               _outputTxt.text = _normalStringHistory;
               _loc7_ = _outputTxt;
               while(_loc7_.numLines > 100 * 0.5)
               {
                  _loc3_ = _loc7_.text.indexOf("\r") + 1;
                  _loc7_.text = _loc7_.text.substr(_loc3_);
               }
               _loc8_ = _loc7_.text.split("\r").join("\n");
               updateAllEmotes = true;
               clear();
               text = _loc8_;
               _loc7_ = null;
               return;
            }
            setTimeout(setupSmileys,41.666666666666664,param1);
         }
      }
      
      private function setupSmileys(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Rectangle = null;
         var _loc8_:TextLineMetrics = null;
         var _loc5_:MovieClip = null;
         var _loc7_:Number = NaN;
         var _loc6_:Number = 0;
         var _loc2_:Array = [];
         for(; _loc3_ < _smileyarray.length; _loc3_++)
         {
            if(_smileyarray[_loc3_] != null)
            {
               if(!_smileyarray[_loc3_].added)
               {
                  _loc4_ = _outputTxt.getCharBoundaries(_smileyarray[_loc3_].strindex);
                  if(_loc4_)
                  {
                     _loc8_ = _outputTxt.getLineMetrics(_outputTxt.numLines - 1);
                     _loc5_ = _smileyarray[_loc3_].emoticon;
                     if(_hasOnlyOneEmote)
                     {
                        _loc5_.scaleX = _loc5_.scaleY = 2;
                     }
                     else
                     {
                        _loc5_.height = _loc8_.height;
                        _loc5_.scaleX = _loc5_.scaleY;
                     }
                     _loc7_ = _loc4_.x + _loc5_.width * 0.5;
                     if(_loc7_ > _outputTxt.width)
                     {
                        _loc4_ = _outputTxt.getCharBoundaries(_smileyarray[_loc3_].strindex + 1);
                        if(!_loc4_)
                        {
                           continue;
                        }
                        _loc5_.x = _loc4_.x + _outputTxt.x + _loc5_.width * 0.5 - 5;
                        _loc5_.y = _loc4_.y + _outputTxt.y + _loc5_.height * 0.5;
                     }
                     else
                     {
                        _loc5_.x = _loc4_.x + _outputTxt.x + _loc5_.width * 0.5;
                        _loc5_.y = _loc4_.y + _outputTxt.y + _loc5_.height * 0.5;
                     }
                     _smileyHolder.addChild(_loc5_);
                     _smileyarray[_loc3_].added = true;
                  }
               }
            }
         }
         if(_smileyHistory == "")
         {
            _smileyHistory = param1;
         }
         else
         {
            _smileyHistory += "\n" + param1;
         }
         _smileyarray = [];
         if(_updateSizeFunction != null)
         {
            _updateSizeFunction();
         }
      }
      
      private function clear() : void
      {
         if(_inputTxt)
         {
            _inputTxt.text = "";
         }
         _smileyHolder.y = 0;
         while(_smileyHolder.numChildren > 0)
         {
            _smileyHolder.removeChildAt(0);
         }
         _outputTxt.text = "";
         _smileyarray = [];
         _smileyHistory = "";
         _stringIndex = 0;
         _normalStringHistory = "";
         _hasOnlyOneEmote = false;
      }
      
      private function removeSpace(param1:String) : String
      {
         var _loc4_:int = 0;
         var _loc3_:String = "";
         var _loc2_:Array = param1.split("");
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc3_ == " ")
            {
               if(_loc2_[_loc4_] == " ")
               {
                  _loc2_[_loc4_] = "";
                  _loc3_ = " ";
               }
               else
               {
                  _loc3_ = _loc2_[_loc4_];
               }
            }
            else
            {
               _loc3_ = _loc2_[_loc4_];
            }
            _loc4_++;
         }
         return _loc2_.join("");
      }
      
      private function scrollListener(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc2_:TextLineMetrics = null;
         var _loc3_:Number = NaN;
         if(!_clearOutput)
         {
            _loc3_ = 0;
            _loc4_ = 0;
            while(_loc4_ < _outputTxt.scrollV - 1)
            {
               _loc2_ = _outputTxt.getLineMetrics(_loc4_);
               _loc3_ += _loc2_.height;
               _loc4_++;
            }
            _smileyHolder.y = -_loc3_;
         }
      }
      
      private function setSize(param1:Number, param2:Number) : void
      {
         _smileyMask.width = param1;
         _smileyMask.height = param2 - 6;
      }
   }
}

