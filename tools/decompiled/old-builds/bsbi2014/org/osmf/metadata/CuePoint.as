package org.osmf.metadata
{
   public class CuePoint extends TimelineMarker
   {
      
      public static const EMBEDDED_CUEPOINTS_NAMESPACE:String = "http://www.osmf.org/timeline/embeddedCuePoints/1.0";
      
      public static const DYNAMIC_CUEPOINTS_NAMESPACE:String = "http://www.osmf.org/timeline/dynamicCuePoints/1.0";
      
      private var _name:String;
      
      private var _type:String;
      
      private var _parameters:Object;
      
      public function CuePoint(type:String, time:Number, name:String, parameters:Object, duration:Number = NaN)
      {
         super(time,duration);
         this._type = type;
         this._name = name;
         this._parameters = parameters;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get parameters() : Object
      {
         return this._parameters;
      }
   }
}

