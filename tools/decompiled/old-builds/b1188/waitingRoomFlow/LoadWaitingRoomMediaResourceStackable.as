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
      
      public function LoadWaitingRoomMediaResourceStackable(param1:Function)
      {
         super();
         this._setWaitingRoomClipCallback = param1;
      }
      
      override public function init(param1:Function) : void
      {
         var callback:Function = param1;
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
      
      private function handleWaitingRoomMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._setWaitingRoomClipCallback(param1);
         }
         super._resourceDoneLoadingCallback(this);
      }
   }
}

