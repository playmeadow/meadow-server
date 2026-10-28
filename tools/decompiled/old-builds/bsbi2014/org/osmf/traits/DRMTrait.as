package org.osmf.traits
{
   [Event(name="drmStateChange",type="org.osmf.events.DRMEvent")]
   public class DRMTrait extends MediaTraitBase
   {
      
      private var _drmState:String = "uninitialized";
      
      private var _period:Number = 0;
      
      private var _endDate:Date;
      
      private var _startDate:Date;
      
      public function DRMTrait()
      {
         super(MediaTraitType.DRM);
      }
      
      public function authenticate(username:String = null, password:String = null) : void
      {
      }
      
      public function authenticateWithToken(token:Object) : void
      {
      }
      
      public function get drmState() : String
      {
         return this._drmState;
      }
      
      public function get startDate() : Date
      {
         return this._startDate;
      }
      
      public function get endDate() : Date
      {
         return this._endDate;
      }
      
      public function get period() : Number
      {
         return this._period;
      }
      
      final protected function setPeriod(value:Number) : void
      {
         this._period = value;
      }
      
      final protected function setStartDate(value:Date) : void
      {
         this._startDate = value;
      }
      
      final protected function setEndDate(value:Date) : void
      {
         this._endDate = value;
      }
      
      final protected function setDrmState(value:String) : void
      {
         this._drmState = value;
      }
   }
}

