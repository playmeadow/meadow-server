package org.osmf.captioning.model
{
   import flash.errors.IllegalOperationError;
   import org.osmf.metadata.TimelineMarker;
   import org.osmf.utils.OSMFStrings;
   
   public class Caption extends TimelineMarker
   {
      
      private var _id:uint;
      
      private var _captionText:String;
      
      private var _formats:Vector.<CaptionFormat>;
      
      public function Caption(id:uint, start:Number, end:Number, captionText:String)
      {
         var duration:Number = end > 0 ? end - start : NaN;
         super(start,duration);
         this._id = id;
         this._captionText = captionText;
      }
      
      public function addCaptionFormat(value:CaptionFormat) : void
      {
         if(this._formats == null)
         {
            this._formats = new Vector.<CaptionFormat>();
         }
         this._formats.push(value);
      }
      
      public function get numCaptionFormats() : int
      {
         var num:int = 0;
         if(this._formats != null)
         {
            num = int(this._formats.length);
         }
         return num;
      }
      
      public function getCaptionFormatAt(index:int) : CaptionFormat
      {
         if(this._formats == null || index >= this._formats.length || index < 0)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this._formats[index];
      }
      
      public function get text() : String
      {
         return this._captionText;
      }
      
      public function get clearText() : String
      {
         var clrTxt:String = "";
         if(this._captionText != null && this._captionText.length > 0)
         {
            clrTxt = this._captionText.replace(/<(.|\n)*?>/g,"");
         }
         return clrTxt;
      }
   }
}

