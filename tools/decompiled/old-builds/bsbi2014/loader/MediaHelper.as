package loader
{
   import com.sbi.loader.FileServerEvent;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import localization.LocalizationManager;
   
   public class MediaHelper
   {
      
      private var _id:uint;
      
      private var _callback:Function;
      
      private var _passback:Object;
      
      private var _loader:Loader;
      
      private var _mc:MovieClip;
      
      public function MediaHelper()
      {
         super();
      }
      
      public function init(id:uint, callback:Function = null, passback:Object = null) : void
      {
         if(id == 0)
         {
            throw new Error("Media id is 0");
         }
         this._id = id;
         this._callback = callback;
         this._passback = passback;
         this._loader = new Loader();
         MediaFileServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleMediaData);
         MediaFileServer.instance.requestFile(this._id);
      }
      
      public function destroy() : void
      {
         MediaFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleMediaData);
         this._mc = null;
         this._passback = null;
         this._loader = null;
         this._callback = null;
      }
      
      public function get id() : int
      {
         if(this._loader == null)
         {
            throw new Error("attempt to get id of an uninitialized MediaHelper instance!");
         }
         return this._id;
      }
      
      private function handleMediaData(fse:FileServerEvent) : void
      {
         if(fse.id != this._id)
         {
            return;
         }
         if(fse.success)
         {
            MediaFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleMediaData);
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onBytesLoaded);
            this._loader.loadBytes(fse.data);
         }
      }
      
      private function onBytesLoaded(evt:Event) : void
      {
         var l:LoaderInfo = evt.target as LoaderInfo;
         this._mc = MovieClip(l.content);
         LocalizationManager.findAllTextfields(this._mc);
         if(this._passback != null)
         {
            this._mc.mediaHelper = this;
            this._mc.passback = this._passback;
         }
         if(this._mc.hasOwnProperty("__rslPreloader") && Boolean(this._mc.__rslPreloader))
         {
            this._mc.addEventListener(Event.ENTER_FRAME,this.onFrame);
         }
         else if(this._callback != null)
         {
            this._callback(this._mc);
            this._callback = null;
         }
      }
      
      private function onFrame(e:Event) : void
      {
         if(this._mc.__rslPreloader == null)
         {
            this._mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
            if(this._callback != null)
            {
               this._callback(this._mc);
               this._callback = null;
            }
         }
      }
   }
}

