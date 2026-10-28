package org.osmf.metadata
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.events.MetadataEvent;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="valueChange",type="org.osmf.events.MetadataEvent")]
   [Event(name="valueRemove",type="org.osmf.events.MetadataEvent")]
   [Event(name="valueAdd",type="org.osmf.events.MetadataEvent")]
   public class Metadata extends EventDispatcher
   {
      
      private var data:Dictionary;
      
      public function Metadata()
      {
         super();
      }
      
      public function getValue(key:String) : *
      {
         if(key == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         return this.data != null ? this.data[key] : null;
      }
      
      public function addValue(key:String, value:Object) : void
      {
         var event:Event = null;
         if(key == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(this.data == null)
         {
            this.data = new Dictionary();
         }
         var oldValue:* = this.data[key];
         this.data[key] = value;
         if(oldValue != value)
         {
            event = oldValue === undefined ? new MetadataEvent(MetadataEvent.VALUE_ADD,false,false,key,value) : new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,key,value,oldValue);
            dispatchEvent(event);
         }
      }
      
      public function removeValue(key:String) : *
      {
         if(key == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         var value:* = this.data[key];
         if(value !== undefined)
         {
            delete this.data[key];
            dispatchEvent(new MetadataEvent(MetadataEvent.VALUE_REMOVE,false,false,key,value));
         }
         return value;
      }
      
      public function get keys() : Vector.<String>
      {
         var key:Object = null;
         var allKeys:Vector.<String> = new Vector.<String>();
         if(this.data != null)
         {
            for(key in this.data)
            {
               allKeys.push(key);
            }
         }
         return allKeys;
      }
      
      public function get synthesizer() : MetadataSynthesizer
      {
         return null;
      }
   }
}

