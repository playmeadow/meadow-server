package org.osmf.layout
{
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.NonSynthesizingMetadata;
   
   internal class BoxAttributesMetadata extends NonSynthesizingMetadata
   {
      
      public static const RELATIVE_SUM:String = "relativeSum";
      
      public static const ABSOLUTE_SUM:String = "absoluteSum";
      
      private var _relativeSum:Number;
      
      private var _absoluteSum:Number;
      
      public function BoxAttributesMetadata()
      {
         super();
         this._relativeSum = 0;
         this._absoluteSum = 0;
      }
      
      override public function getValue(key:String) : *
      {
         if(key == null)
         {
            return undefined;
         }
         if(key == RELATIVE_SUM)
         {
            return this.relativeSum;
         }
         if(key == ABSOLUTE_SUM)
         {
            return this.absoluteSum;
         }
         return undefined;
      }
      
      public function get relativeSum() : Number
      {
         return this._relativeSum;
      }
      
      public function set relativeSum(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._relativeSum != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,RELATIVE_SUM,value,this._relativeSum);
            this._relativeSum = value;
            dispatchEvent(event);
         }
      }
      
      public function get absoluteSum() : Number
      {
         return this._absoluteSum;
      }
      
      public function set absoluteSum(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._absoluteSum != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,ABSOLUTE_SUM,value,this._absoluteSum);
            this._absoluteSum = value;
            dispatchEvent(event);
         }
      }
   }
}

