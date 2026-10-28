package org.osmf.traits
{
   import flash.display.DisplayObject;
   import org.osmf.events.DisplayObjectEvent;
   
   [Event(name="mediaSizeChange",type="org.osmf.events.DisplayObjectEvent")]
   [Event(name="displayObjectChange",type="org.osmf.events.DisplayObjectEvent")]
   public class DisplayObjectTrait extends MediaTraitBase
   {
      
      private var _displayObject:DisplayObject;
      
      private var _mediaWidth:Number = 0;
      
      private var _mediaHeight:Number = 0;
      
      public function DisplayObjectTrait(displayObject:DisplayObject, mediaWidth:Number = 0, mediaHeight:Number = 0)
      {
         super(MediaTraitType.DISPLAY_OBJECT);
         this._displayObject = displayObject;
         this._mediaWidth = mediaWidth;
         this._mediaHeight = mediaHeight;
      }
      
      public function get displayObject() : DisplayObject
      {
         return this._displayObject;
      }
      
      public function get mediaWidth() : Number
      {
         return this._mediaWidth;
      }
      
      public function get mediaHeight() : Number
      {
         return this._mediaHeight;
      }
      
      final protected function setDisplayObject(value:DisplayObject) : void
      {
         var oldDisplayObject:DisplayObject = null;
         if(this._displayObject != value)
         {
            this.displayObjectChangeStart(value);
            oldDisplayObject = this._displayObject;
            this._displayObject = value;
            this.displayObjectChangeEnd(oldDisplayObject);
         }
      }
      
      final protected function setMediaSize(mediaWidth:Number, mediaHeight:Number) : void
      {
         var oldMediaWidth:Number = NaN;
         var oldMediaHeight:Number = NaN;
         if(mediaWidth != this._mediaWidth || mediaHeight != this._mediaHeight)
         {
            this.mediaSizeChangeStart(mediaWidth,mediaHeight);
            oldMediaWidth = this._mediaWidth;
            oldMediaHeight = this._mediaHeight;
            this._mediaWidth = mediaWidth;
            this._mediaHeight = mediaHeight;
            this.mediaSizeChangeEnd(oldMediaWidth,oldMediaHeight);
         }
      }
      
      protected function displayObjectChangeStart(newView:DisplayObject) : void
      {
      }
      
      protected function displayObjectChangeEnd(oldDisplayObject:DisplayObject) : void
      {
         dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE,false,false,oldDisplayObject,this._displayObject));
      }
      
      protected function mediaSizeChangeStart(newMediaWidth:Number, newMediaHeight:Number) : void
      {
      }
      
      protected function mediaSizeChangeEnd(oldMediaWidth:Number, oldMediaHeight:Number) : void
      {
         dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.MEDIA_SIZE_CHANGE,false,false,null,null,oldMediaWidth,oldMediaHeight,this._mediaWidth,this._mediaHeight));
      }
   }
}

