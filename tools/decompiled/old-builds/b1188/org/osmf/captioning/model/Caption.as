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
      
      public function Caption(param1:uint, param2:Number, param3:Number, param4:String)
      {
         var _loc5_:Number = param3 > 0 ? param3 - param2 : NaN;
         super(param2,_loc5_);
         this._id = param1;
         this._captionText = param4;
      }
      
      public function addCaptionFormat(param1:CaptionFormat) : void
      {
         if(this._formats == null)
         {
            this._formats = new Vector.<CaptionFormat>();
         }
         this._formats.push(param1);
      }
      
      public function get numCaptionFormats() : int
      {
         var _loc1_:int = 0;
         if(this._formats != null)
         {
            _loc1_ = int(this._formats.length);
         }
         return _loc1_;
      }
      
      public function getCaptionFormatAt(param1:int) : CaptionFormat
      {
         if(this._formats == null || param1 >= this._formats.length || param1 < 0)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this._formats[param1];
      }
      
      public function get text() : String
      {
         return this._captionText;
      }
      
      public function get clearText() : String
      {
         var _loc1_:String = "";
         if(this._captionText != null && this._captionText.length > 0)
         {
            _loc1_ = this._captionText.replace(/<(.|\n)*?>/g,"");
         }
         return _loc1_;
      }
   }
}

