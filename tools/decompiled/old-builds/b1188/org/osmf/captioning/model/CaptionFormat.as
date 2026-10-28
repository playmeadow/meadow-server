package org.osmf.captioning.model
{
   public class CaptionFormat
   {
      
      public static const UNDEFINED_INDEX:int = -1;
      
      private static const MISSING_STYLE_ERROR_MSG:String = "CaptionStyle is required for CaptionFormat objects";
      
      private var _startIndex:int;
      
      private var _endIndex:int;
      
      private var _style:CaptionStyle;
      
      public function CaptionFormat(param1:CaptionStyle, param2:int = -1, param3:int = -1)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError(MISSING_STYLE_ERROR_MSG);
         }
         this._startIndex = param2;
         this._endIndex = param3;
         this._style = param1;
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

