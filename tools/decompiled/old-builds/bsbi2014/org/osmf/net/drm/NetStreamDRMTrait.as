package org.osmf.net.drm
{
   import flash.events.DRMStatusEvent;
   import flash.system.SystemUpdater;
   import org.osmf.events.DRMEvent;
   import org.osmf.events.MediaError;
   import org.osmf.traits.DRMTrait;
   
   [ExcludeClass]
   public class NetStreamDRMTrait extends DRMTrait
   {
      
      private var drmServices:DRMServices = new DRMServices();
      
      public function NetStreamDRMTrait()
      {
         super();
         this.drmServices.addEventListener(DRMEvent.DRM_STATE_CHANGE,this.onStateChange);
      }
      
      public function set drmMetadata(value:Object) : void
      {
         if(value != this.drmServices.drmMetadata)
         {
            this.drmServices.drmMetadata = value;
         }
      }
      
      public function get drmMetadata() : Object
      {
         return this.drmServices.drmMetadata;
      }
      
      public function update(type:String) : SystemUpdater
      {
         return this.drmServices.update(type);
      }
      
      override public function authenticate(username:String = null, password:String = null) : void
      {
         this.drmServices.authenticate(username,password);
      }
      
      override public function authenticateWithToken(token:Object) : void
      {
         this.drmServices.authenticateWithToken(token);
      }
      
      public function inlineDRMFailed(error:MediaError) : void
      {
         this.drmServices.inlineDRMFailed(error);
      }
      
      public function inlineOnVoucher(event:DRMStatusEvent) : void
      {
         this.drmServices.inlineOnVoucher(event);
      }
      
      private function onStateChange(event:DRMEvent) : void
      {
         setPeriod(event.period);
         setStartDate(event.startDate);
         setEndDate(event.endDate);
         setDrmState(event.drmState);
         dispatchEvent(new DRMEvent(DRMEvent.DRM_STATE_CHANGE,drmState,false,false,startDate,endDate,period,event.serverURL,event.token,event.mediaError));
      }
   }
}

