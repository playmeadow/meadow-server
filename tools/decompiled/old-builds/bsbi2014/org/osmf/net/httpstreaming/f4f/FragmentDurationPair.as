package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class FragmentDurationPair
   {
      
      private var _firstFragment:uint;
      
      private var _duration:uint;
      
      private var _durationAccrued:Number;
      
      private var _discontinuityIndicator:uint = 0;
      
      public function FragmentDurationPair()
      {
         super();
      }
      
      public function get firstFragment() : uint
      {
         return this._firstFragment;
      }
      
      public function set firstFragment(value:uint) : void
      {
         this._firstFragment = value;
      }
      
      public function get duration() : uint
      {
         return this._duration;
      }
      
      public function set duration(value:uint) : void
      {
         this._duration = value;
      }
      
      public function get durationAccrued() : Number
      {
         return this._durationAccrued;
      }
      
      public function set durationAccrued(value:Number) : void
      {
         this._durationAccrued = value;
      }
      
      public function get discontinuityIndicator() : uint
      {
         return this._discontinuityIndicator;
      }
      
      public function set discontinuityIndicator(value:uint) : void
      {
         this._discontinuityIndicator = value;
      }
   }
}

