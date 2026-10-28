package org.osmf.net.drm
{
   import flash.errors.IllegalOperationError;
   import flash.events.DRMAuthenticationCompleteEvent;
   import flash.events.DRMAuthenticationErrorEvent;
   import flash.events.DRMErrorEvent;
   import flash.events.DRMStatusEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.StatusEvent;
   import flash.net.drm.DRMContentData;
   import flash.net.drm.DRMManager;
   import flash.net.drm.DRMVoucher;
   import flash.net.drm.LoadVoucherSetting;
   import flash.system.SystemUpdater;
   import flash.system.SystemUpdaterType;
   import flash.utils.ByteArray;
   import org.osmf.events.DRMEvent;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.traits.DRMState;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="drmStateChange",type="org.osmf.events.DRMEvent")]
   [ExcludeClass]
   internal class DRMServices extends EventDispatcher
   {
      
      private static var updater:SystemUpdater;
      
      private static const DRM_AUTHENTICATION_FAILED:int = 3301;
      
      private static const DRM_NEEDS_AUTHENTICATION:int = 3330;
      
      private static const DRM_CONTENT_NOT_YET_VALID:int = 3331;
      
      private var _drmState:String = "uninitialized";
      
      private var lastToken:ByteArray;
      
      private var drmContentData:DRMContentData;
      
      private var voucher:DRMVoucher;
      
      private var drmManager:DRMManager;
      
      public function DRMServices()
      {
         super();
         this.drmManager = DRMManager.getDRMManager();
      }
      
      public function get drmState() : String
      {
         return this._drmState;
      }
      
      public function set drmMetadata(value:Object) : void
      {
         var onComplete:Function = null;
         this.lastToken = null;
         if(value is DRMContentData)
         {
            this.drmContentData = value as DRMContentData;
            this.retrieveVoucher();
         }
         else
         {
            try
            {
               this.drmContentData = new DRMContentData(value as ByteArray);
               this.retrieveVoucher();
            }
            catch(argError:ArgumentError)
            {
               updateDRMState(DRMState.AUTHENTICATION_ERROR,new MediaError(argError.errorID,"DRMContentData invalid"));
            }
            catch(error:IllegalOperationError)
            {
               onComplete = function(event:Event):void
               {
                  updater.removeEventListener(Event.COMPLETE,onComplete);
                  drmMetadata = value;
               };
               update(SystemUpdaterType.DRM);
               updater.addEventListener(Event.COMPLETE,onComplete);
            }
         }
      }
      
      public function get drmMetadata() : Object
      {
         return this.drmContentData;
      }
      
      public function authenticate(username:String = null, password:String = null) : void
      {
         if(this.drmContentData == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DRM_METADATA_NOT_SET));
         }
         this.drmManager.addEventListener(DRMAuthenticationErrorEvent.AUTHENTICATION_ERROR,this.authError);
         this.drmManager.addEventListener(DRMAuthenticationCompleteEvent.AUTHENTICATION_COMPLETE,this.authComplete);
         if(password == null && username == null)
         {
            this.retrieveVoucher();
         }
         else
         {
            this.drmManager.authenticate(this.drmContentData.serverURL,this.drmContentData.domain,username,password);
         }
      }
      
      public function authenticateWithToken(token:Object) : void
      {
         if(this.drmContentData == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DRM_METADATA_NOT_SET));
         }
         this.drmManager.setAuthenticationToken(this.drmContentData.serverURL,this.drmContentData.domain,token as ByteArray);
         this.retrieveVoucher();
      }
      
      public function get startDate() : Date
      {
         if(this.voucher != null)
         {
            return Boolean(this.voucher.playbackTimeWindow) ? this.voucher.playbackTimeWindow.startDate : this.voucher.voucherStartDate;
         }
         return null;
      }
      
      public function get endDate() : Date
      {
         if(this.voucher != null)
         {
            return Boolean(this.voucher.playbackTimeWindow) ? this.voucher.playbackTimeWindow.endDate : this.voucher.voucherEndDate;
         }
         return null;
      }
      
      public function get period() : Number
      {
         if(this.voucher != null)
         {
            return Boolean(this.voucher.playbackTimeWindow) ? this.voucher.playbackTimeWindow.period : (Boolean(this.voucher.voucherEndDate) && Boolean(this.voucher.voucherStartDate) ? (this.voucher.voucherEndDate.time - this.voucher.voucherStartDate.time) / 1000 : 0);
         }
         return NaN;
      }
      
      public function inlineDRMFailed(error:MediaError) : void
      {
         this.updateDRMState(DRMState.AUTHENTICATION_ERROR,error);
      }
      
      public function inlineOnVoucher(event:DRMStatusEvent) : void
      {
         this.drmContentData = event.contentData;
         this.onVoucherLoaded(event);
      }
      
      public function update(type:String) : SystemUpdater
      {
         this.updateDRMState(DRMState.DRM_SYSTEM_UPDATING);
         if(updater == null)
         {
            updater = new SystemUpdater();
            this.toggleErrorListeners(updater,true);
            updater.update(type);
         }
         else
         {
            this.toggleErrorListeners(updater,true);
         }
         return updater;
      }
      
      private function retrieveVoucher() : void
      {
         this.updateDRMState(DRMState.AUTHENTICATING);
         this.drmManager.addEventListener(DRMErrorEvent.DRM_ERROR,this.onDRMError);
         this.drmManager.addEventListener(DRMStatusEvent.DRM_STATUS,this.onVoucherLoaded);
         this.drmManager.loadVoucher(this.drmContentData,LoadVoucherSetting.ALLOW_SERVER);
      }
      
      private function onVoucherLoaded(event:DRMStatusEvent) : void
      {
         var now:Date = null;
         if(event.contentData == this.drmContentData)
         {
            now = new Date();
            if(Boolean(event.voucher) && ((event.voucher.voucherEndDate == null || event.voucher.voucherEndDate.time >= now.time) && (event.voucher.voucherStartDate == null || event.voucher.voucherStartDate.time <= now.time)))
            {
               this.voucher = event.voucher;
               this.removeEventListeners();
               if(this.voucher.playbackTimeWindow == null)
               {
                  this.updateDRMState(DRMState.AUTHENTICATION_COMPLETE,null,this.voucher.voucherStartDate,this.voucher.voucherEndDate,this.period,this.lastToken);
               }
               else
               {
                  this.updateDRMState(DRMState.AUTHENTICATION_COMPLETE,null,this.voucher.playbackTimeWindow.startDate,this.voucher.playbackTimeWindow.endDate,this.voucher.playbackTimeWindow.period,this.lastToken);
               }
            }
            else
            {
               this.forceRefreshVoucher();
            }
         }
      }
      
      private function forceRefreshVoucher() : void
      {
         this.drmManager.loadVoucher(this.drmContentData,LoadVoucherSetting.FORCE_REFRESH);
      }
      
      private function onDRMError(event:DRMErrorEvent) : void
      {
         if(event.contentData == this.drmContentData)
         {
            switch(event.errorID)
            {
               case DRM_CONTENT_NOT_YET_VALID:
                  this.forceRefreshVoucher();
                  break;
               case DRM_NEEDS_AUTHENTICATION:
                  this.updateDRMState(DRMState.AUTHENTICATION_NEEDED,null,null,null,0,null,event.contentData.serverURL);
                  break;
               default:
                  this.removeEventListeners();
                  this.updateDRMState(DRMState.AUTHENTICATION_ERROR,new MediaError(event.errorID,event.text));
            }
         }
      }
      
      private function removeEventListeners() : void
      {
         this.drmManager.removeEventListener(DRMErrorEvent.DRM_ERROR,this.onDRMError);
         this.drmManager.removeEventListener(DRMStatusEvent.DRM_STATUS,this.onVoucherLoaded);
      }
      
      private function authComplete(event:DRMAuthenticationCompleteEvent) : void
      {
         this.drmManager.removeEventListener(DRMAuthenticationErrorEvent.AUTHENTICATION_ERROR,this.authError);
         this.drmManager.removeEventListener(DRMAuthenticationCompleteEvent.AUTHENTICATION_COMPLETE,this.authComplete);
         this.lastToken = event.token;
         this.retrieveVoucher();
      }
      
      private function authError(event:DRMAuthenticationErrorEvent) : void
      {
         this.drmManager.removeEventListener(DRMAuthenticationErrorEvent.AUTHENTICATION_ERROR,this.authError);
         this.drmManager.removeEventListener(DRMAuthenticationCompleteEvent.AUTHENTICATION_COMPLETE,this.authComplete);
         this.updateDRMState(DRMState.AUTHENTICATION_ERROR,new MediaError(event.errorID,event.toString()));
      }
      
      private function toggleErrorListeners(updater:SystemUpdater, on:Boolean) : void
      {
         if(on)
         {
            updater.addEventListener(Event.COMPLETE,this.onUpdateComplete);
            updater.addEventListener(Event.CANCEL,this.onUpdateComplete);
            updater.addEventListener(IOErrorEvent.IO_ERROR,this.onUpdateError);
            updater.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onUpdateError);
            updater.addEventListener(StatusEvent.STATUS,this.onUpdateError);
         }
         else
         {
            updater.removeEventListener(Event.COMPLETE,this.onUpdateComplete);
            updater.removeEventListener(Event.CANCEL,this.onUpdateComplete);
            updater.removeEventListener(IOErrorEvent.IO_ERROR,this.onUpdateError);
            updater.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onUpdateError);
            updater.removeEventListener(StatusEvent.STATUS,this.onUpdateError);
         }
      }
      
      private function onUpdateComplete(event:Event) : void
      {
         this.toggleErrorListeners(updater,false);
      }
      
      private function onUpdateError(event:Event) : void
      {
         this.toggleErrorListeners(updater,false);
         this.updateDRMState(DRMState.AUTHENTICATION_ERROR,new MediaError(MediaErrorCodes.DRM_SYSTEM_UPDATE_ERROR,event.toString()));
      }
      
      private function updateDRMState(newState:String, error:MediaError = null, start:Date = null, end:Date = null, period:Number = 0, token:Object = null, prompt:String = null) : void
      {
         this._drmState = newState;
         dispatchEvent(new DRMEvent(DRMEvent.DRM_STATE_CHANGE,newState,false,false,start,end,period,prompt,token,error));
      }
   }
}

