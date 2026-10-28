package org.osmf.captioning.model
{
   public class CaptionFormat
   {
      
      public static const UNDEFINED_INDEX:int = -1;
      
      private static const MISSING_STYLE_ERROR_MSG:String = "CaptionStyle is required for CaptionFormat objects";
      
      private var _startIndex:int;
      
      private var _endIndex:int;
      
      private var _style:CaptionStyle;
      
      public function CaptionFormat(style:CaptionStyle, start:int = -1, end:int = -1)
      {
         super();
         if(style == null)
         {
            throw new ArgumentError(MISSING_STYLE_ERROR_MSG);
         }
         this._startIndex = start;
         this._endIndex = end;
         this._style = style;
      }
      
      public function get startIndex() : int
      {
         return this._startIndex;
      }
      
      public function get endIndex() : int
      {
         return this._endIndex;
      }
      
      public function get style() : CaptionStyle
      {
         return this._style;
      }
   }
}

