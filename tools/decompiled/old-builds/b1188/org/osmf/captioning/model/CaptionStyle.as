package org.osmf.captioning.model
{
   public class CaptionStyle
   {
      
      private var _id:String;
      
      private var _backgroundColor:Object;
      
      private var _backgroundColorAlpha:Object;
      
      private var _textColor:Object;
      
      private var _textColorAlpha:Object;
      
      private var _fontFamily:String;
      
      private var _fontSize:int;
      
      private var _fontStyle:String;
      
      private var _fontWeight:String;
      
      private var _textAlign:String;
      
      private var _wrapOption:Boolean;
      
      public function CaptionStyle(param1:String)
      {
         super();
         this._id = param1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get backgroundColor() : Object
      {
         return this._backgroundColor;
      }
      
      public function set backgroundColor(param1:Object) : void
      {
         this._backgroundColor = param1;
      }
      
      public function get backgroundColorAlpha() : Object
      {
         return this._backgroundColorAlpha;
      }
      
      public function set backgroundColorAlpha(param1:Object) : void
      {
         this._backgroundColorAlpha = param1;
      }
      
      public function get textColor() : Object
      {
         return this._textColor;
      }
      
      public function set textColor(param1:Object) : void
      {
         this._textColor = param1;
      }
      
      public function get textColorAlpha() : Object
      {
         return this._textColorAlpha;
      }
      
      public function set textColorAlpha(param1:Object) : void
      {
         this._textColorAlpha = param1;
      }
      
      public function get fontFamily() : String
      {
         return this._fontFamily;
      }
      
      public function set fontFamily(param1:String) : void
      {
         this._fontFamily = param1;
      }
      
      public function get fontSize() : int
      {
         return this._fontSize;
      }
      
      public function set fontSize(param1:int) : void
      {
         this._fontSize = param1;
      }
      
      public function get fontStyle() : String
      {
         return this._fontStyle;
      }
      
      public function set fontStyle(param1:String) : void
      {
         this._fontStyle = param1;
      }
      
      public function get fontWeight() : String
      {
         return this._fontWeight;
      }
      
      public function set fontWeight(param1:String) : void
      {
         this._fontWeight = param1;
      }
      
      public function get textAlign() : String
      {
         return this._textAlign;
      }
      
      public function set textAlign(param1:String) : void
      {
         this._textAlign = param1;
      }
      
      public function get wrapOption() : Boolean
      {
         return this._wrapOption;
      }
      
      public function set wrapOption(param1:Boolean) : void
      {
         this._wrapOption = param1;
      }
   }
}

