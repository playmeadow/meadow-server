package org.osmf.captioning.model
{
   import flash.errors.IllegalOperationError;
   import org.osmf.utils.OSMFStrings;
   
   public class CaptioningDocument
   {
      
      private var _title:String;
      
      private var _desc:String;
      
      private var _copyright:String;
      
      private var _captions:Vector.<Caption>;
      
      private var _styles:Vector.<CaptionStyle>;
      
      public function CaptioningDocument()
      {
         super();
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function set title(value:String) : void
      {
         this._title = value;
      }
      
      public function get description() : String
      {
         return this._desc;
      }
      
      public function set description(value:String) : void
      {
         this._desc = value;
      }
      
      public function get copyright() : String
      {
         return this._copyright;
      }
      
      public function set copyright(value:String) : void
      {
         this._copyright = value;
      }
      
      public function addStyle(style:CaptionStyle) : void
      {
         if(this._styles == null)
         {
            this._styles = new Vector.<CaptionStyle>();
         }
         this._styles.push(style);
      }
      
      public function get numStyles() : int
      {
         var num:int = 0;
         if(this._styles != null)
         {
            num = int(this._styles.length);
         }
         return num;
      }
      
      public function getStyleAt(index:int) : CaptionStyle
      {
         if(this._styles == null || index >= this._styles.length)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this._styles[index];
      }
      
      public function addCaption(caption:Caption) : void
      {
         if(this._captions == null)
         {
            this._captions = new Vector.<Caption>();
         }
         this._captions.push(caption);
      }
      
      public function get numCaptions() : int
      {
         var num:int = 0;
         if(this._captions != null)
         {
            num = int(this._captions.length);
         }
         return num;
      }
      
      public function getCaptionAt(index:int) : Caption
      {
         if(this._captions == null || index >= this._captions.length)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this._captions[index];
      }
   }
}

