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
      
      public function set title(param1:String) : void
      {
         this._title = param1;
      }
      
      public function get description() : String
      {
         return this._desc;
      }
      
      public function set description(param1:String) : void
      {
         this._desc = param1;
      }
      
      public function get copyright() : String
      {
         return this._copyright;
      }
      
      public function set copyright(param1:String) : void
      {
         this._copyright = param1;
      }
      
      public function addStyle(param1:CaptionStyle) : void
      {
         if(this._styles == null)
         {
            this._styles = new Vector.<CaptionStyle>();
         }
         this._styles.push(param1);
      }
      
      public function get numStyles() : int
      {
         var _loc1_:int = 0;
         if(this._styles != null)
         {
            _loc1_ = int(this._styles.length);
         }
         return _loc1_;
      }
      
      public function getStyleAt(param1:int) : CaptionStyle
      {
         if(this._styles == null || param1 >= this._styles.length)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this._styles[param1];
      }
      
      public function addCaption(param1:Caption) : void
      {
         if(this._captions == null)
         {
            this._captions = new Vector.<Caption>();
         }
         this._captions.push(param1);
      }
      
      public function get numCaptions() : int
      {
         var _loc1_:int = 0;
         if(this._captions != null)
         {
            _loc1_ = int(this._captions.length);
         }
         return _loc1_;
      }
      
      public function getCaptionAt(param1:int) : Caption
      {
         if(this._captions == null || param1 >= this._captions.length)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this._captions[param1];
      }
   }
}

