package org.osmf.media
{
   import org.osmf.utils.OSMFStrings;
   
   public class MediaFactoryItem
   {
      
      private var _id:String;
      
      private var _canHandleResourceFunction:Function;
      
      private var _mediaElementCreationFunction:Function;
      
      private var _type:String;
      
      public function MediaFactoryItem(id:String, canHandleResourceFunction:Function, mediaElementCreationFunction:Function, type:String = null)
      {
         super();
         if(id == null || canHandleResourceFunction == null || mediaElementCreationFunction == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         type ||= MediaFactoryItemType.STANDARD;
         this._id = id;
         this._canHandleResourceFunction = canHandleResourceFunction;
         this._mediaElementCreationFunction = mediaElementCreationFunction;
         this._type = type;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get canHandleResourceFunction() : Function
      {
         return this._canHandleResourceFunction;
      }
      
      public function get mediaElementCreationFunction() : Function
      {
         return this._mediaElementCreationFunction;
      }
      
      public function get type() : String
      {
         return this._type;
      }
   }
}

