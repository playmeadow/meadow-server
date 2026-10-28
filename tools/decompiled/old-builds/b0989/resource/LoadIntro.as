package resource
{
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class LoadIntro
   {
      
      private var _mediaHelper:MediaHelper;
      
      private var _callback:Function;
      
      public function LoadIntro()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         this._callback = param1;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(1904,this.onIntroLoaded);
      }
      
      private function onIntroLoaded(param1:MovieClip) : void
      {
         param1.stopMovie();
         param1.visible = false;
         this._mediaHelper.destroy();
         this._mediaHelper = null;
         this._callback(param1);
         this._callback = null;
      }
   }
}

