package org.osmf.net
{
   import org.osmf.utils.OSMFStrings;
   
   public class DynamicStreamingResource extends StreamingURLResource
   {
      
      private var _streamItems:Vector.<DynamicStreamingItem>;
      
      private var _initialIndex:int;
      
      public function DynamicStreamingResource(host:String, streamType:String = null)
      {
         super(host,streamType);
         this._initialIndex = 0;
      }
      
      public function get host() : String
      {
         return url;
      }
      
      public function get streamItems() : Vector.<DynamicStreamingItem>
      {
         if(this._streamItems == null)
         {
            this._streamItems = new Vector.<DynamicStreamingItem>();
         }
         return this._streamItems;
      }
      
      public function set streamItems(value:Vector.<DynamicStreamingItem>) : void
      {
         this._streamItems = value;
         if(value != null)
         {
            value.sort(this.compareStreamItems);
         }
      }
      
      public function get initialIndex() : int
      {
         return this._initialIndex;
      }
      
      public function set initialIndex(value:int) : void
      {
         if(this._streamItems == null || value >= this._streamItems.length)
         {
            throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         this._initialIndex = value;
      }
      
      internal function indexFromName(name:String) : int
      {
         for(var i:int = 0; i < this._streamItems.length; i++)
         {
            if(this._streamItems[i].streamName.indexOf(name) == 0 || this._streamItems[i].streamName.indexOf("mp4:" + name) == 0)
            {
               return i;
            }
         }
         return -1;
      }
      
      private function compareStreamItems(a:DynamicStreamingItem, b:DynamicStreamingItem) : Number
      {
         var result:Number = -1;
         if(a.bitrate == b.bitrate)
         {
            result = 0;
         }
         else if(a.bitrate > b.bitrate)
         {
            result = 1;
         }
         return result;
      }
   }
}

