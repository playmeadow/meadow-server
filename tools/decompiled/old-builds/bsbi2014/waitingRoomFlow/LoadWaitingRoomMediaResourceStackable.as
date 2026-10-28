package waitingRoomFlow
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.IResourceStackable;
   import flash.display.MovieClip;
   import loader.MediaHelper;
   import resource.BaseResourceStackable;
   
   public class LoadWaitingRoomMediaResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      
      private const WAITING_ROOM_MEDIA_ID:int = 1678;
      
      public var waitingRoom:MovieClip;
      
      private var _setWaitingRoomClipCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      public function LoadWaitingRoomMediaResourceStackable(initSetClipCallback:Function)
      {
         super();
         this._setWaitingRoomClipCallback = initSetClipCallback;
      }
      
      override public function init(callback:Function) : void
      {
         super.init(callback);
         try
         {
            this._mediaHelper = new MediaHelper();
            this._mediaHelper.init(this.WAITING_ROOM_MEDIA_ID,this.handleWaitingRoomMediaLoaded);
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error loading waitingRoom media:" + e.getStackTrace());
            LoadProgress.show(true,"Error loading waiting room - please try again later");
            return;
         }
      }
      
      private function handleWaitingRoomMediaLoaded(mc:MovieClip) : void
      {
         if(Boolean(mc))
         {
            this._setWaitingRoomClipCallback(mc);
         }
         super._resourceDoneLoadingCallback(this);
      }
   }
}

