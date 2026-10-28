package loader
{
   import com.sbi.loader.FileServerEvent;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import localization.LocalizationManager;
   
   public class JCDefHelper
   {
      
      private var _id:uint;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      private var _passback:Object;
      
      private var _loadImage:Boolean;
      
      private var _loader:Loader;
      
      public function JCDefHelper()
      {
         super();
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get def() : Object
      {
         return this._def;
      }
      
      public function init(param1:uint, param2:Function = null, param3:Boolean = false, param4:Object = null) : void
      {
         this._id = param1;
         this._callback = param2;
         this._passback = param4;
         this._loadImage = param3;
         this._loader = new Loader();
         JCFileServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleData,false,0,true);
         if(param3)
         {
            JCFileServer.instance.requestFileWithExtension(this._id,false,FileServerEvent.JSON_TYPE,"images/");
         }
         else if(param1 == LocalizationManager.currentLanguage)
         {
            JCFileServer.instance.requestFileWithExtension(this._id,false,FileServerEvent.AMF3_TYPE,"index/");
         }
         else
         {
            JCFileServer.instance.requestFileWithExtension(this._id,false,FileServerEvent.AMF3_TYPE,"amf/");
         }
      }
      
      public function destroy() : void
      {
         JCFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
         this._callback = null;
         this._passback = null;
         this._loader = null;
      }
      
      public function deleteIndexFileFromCache() : void
      {
         JCFileServer.instance.clearFromCache("index/",1);
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         if(param1.id == this._id && param1.success)
         {
            JCFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
            if(!this._loadImage)
            {
               param1.data.position = 0;
               this._def = param1.data.readObject();
               this.onComplete();
            }
            else
            {
               this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onBytesLoaded);
               this._loader.loadBytes(param1.data);
            }
         }
      }
      
      private function onBytesLoaded(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         this._def = new MovieClip();
         this._def.addChild(_loc2_.content);
         if(this._def.hasOwnProperty("__rslPreloader") && Boolean(this._def.__rslPreloader))
         {
            this._def.addEventListener(Event.ENTER_FRAME,this.onFrame);
         }
         else
         {
            this.onComplete();
         }
      }
      
      private function onFrame(param1:Event) : void
      {
         if(this._def.__rslPreloader == null)
         {
            this._def.removeEventListener(Event.ENTER_FRAME,this.onFrame);
            this.onComplete();
         }
      }
      
      private function onComplete() : void
      {
         if(this._passback != null)
         {
            this._def.defHelper = this;
            this._def.passback = this._passback;
         }
         if(this._callback != null)
         {
            this._callback(this._def);
            this._callback = null;
         }
      }
   }
}

