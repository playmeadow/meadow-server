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
      
      private var _id:Object;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      private var _passback:Object;
      
      private var _loadImage:Boolean;
      
      private var _loader:Loader;
      
      public function JCDefHelper()
      {
         super();
      }
      
      public function get id() : Object
      {
         return _id;
      }
      
      public function get def() : Object
      {
         return _def;
      }
      
      public function init(param1:Object, param2:Function = null, param3:Boolean = false, param4:Object = null) : void
      {
         _id = param1;
         _callback = param2;
         _passback = param4;
         _loadImage = param3;
         _loader = new Loader();
         JCFileServer.instance.addEventListener("OnNewData",handleData,false,0,true);
         if(param3)
         {
            JCFileServer.instance.requestFileWithExtension(_id,false,0,"images/");
         }
         else if(param1 == LocalizationManager.currentLanguage)
         {
            _id += ".json";
            JCFileServer.instance.requestFileWithExtension(_id,false,0,"index/");
         }
         else
         {
            _id += ".json";
            JCFileServer.instance.requestFileWithExtension(_id,false,0,"json/");
         }
      }
      
      public function destroy() : void
      {
         JCFileServer.instance.removeEventListener("OnNewData",handleData);
         _callback = null;
         _passback = null;
         _loader = null;
      }
      
      public function deleteIndexFileFromCache() : void
      {
         JCFileServer.instance.clearFromCache("index/",1);
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         if(param1.id == _id && param1.success)
         {
            JCFileServer.instance.removeEventListener("OnNewData",handleData);
            if(!_loadImage)
            {
               if(param1.contentType == 0)
               {
                  param1.data.position = 0;
                  _def = JSON.parse(param1.data);
               }
               else if(param1.contentType == 2)
               {
                  param1.data.position = 0;
                  _def = param1.data.readObject();
               }
               else
               {
                  _def = param1.data;
               }
               onComplete();
            }
            else
            {
               _loader.contentLoaderInfo.addEventListener("complete",onBytesLoaded);
               _loader.loadBytes(param1.data);
            }
         }
      }
      
      private function onBytesLoaded(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _def = new MovieClip();
         _def.addChild(_loc2_.content);
         if(_def.hasOwnProperty("__rslPreloader") && _def.__rslPreloader)
         {
            _def.addEventListener("enterFrame",onFrame);
         }
         else
         {
            onComplete();
         }
      }
      
      private function onFrame(param1:Event) : void
      {
         if(_def.__rslPreloader == null)
         {
            _def.removeEventListener("enterFrame",onFrame);
            onComplete();
         }
      }
      
      private function onComplete() : void
      {
         if(_passback != null)
         {
            _def.defHelper = this;
            _def.passback = _passback;
         }
         if(_callback != null)
         {
            _callback(_def);
            _callback = null;
         }
      }
   }
}

