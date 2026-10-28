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
      
      public function CaptionStyle(id:String)
      {
         super();
         this._id = id;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get backgroundColor() : Object
      {
         return this._backgroundColor;
      }
      
      public function set backgroundColor(value:Object) : void
      {
         this._backgroundColor = value;
      }
      
      public function get backgroundColorAlpha() : Object
      {
         return this._backgroundColorAlpha;
      }
      
      public function set backgroundColorAlpha(value:Object) : void
      {
         this._backgroundColorAlpha = value;
      }
      
      public function get textColor() : Object
      {
         return this._textColor;
      }
      
      public function set textColor(value:Object) : void
      {
         this._textColor = value;
      }
      
      public function get textColorAlpha() : Object
      {
         return this._textColorAlpha;
      }
      
      public function set textColorAlpha(value:Object) : void
      {
         this._textColorAlpha = value;
      }
      
      public function get fontFamily() : String
      {
         return this._fontFamily;
      }
      
      public function set fontFamily(value:String) : void
      {
         this._fontFamily = value;
      }
      
      public function get fontSize() : int
      {
         return this._fontSize;
      }
      
      public function set fontSize(value:int) : void
      {
         this._fontSize = value;
      }
      
      public function get fontStyle() : String
      {
         return this._fontStyle;
      }
      
      public function set fontStyle(value:String) : void
      {
         this._fontStyle = value;
      }
      
      public function get fontWeight() : String
      {
         return this._fontWeight;
      }
      
      public function set fontWeight(value:String) : void
      {
         this._fontWeight = value;
      }
      
      public function get textAlign() : String
      {
         return this._textAlign;
      }
      
      public function set textAlign(value:String) : void
      {
         this._textAlign = value;
      }
      
      public function get wrapOption() : Boolean
      {
         return this._wrapOption;
      }
      
      public function set wrapOption(value:Boolean) : void
      {
         this._wrapOption = value;
      }
   }
}

