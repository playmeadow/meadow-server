package resource
{
   import com.sbi.loader.IResourceStackable;
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class LoadAvatarCarouselResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      
      private var _mediaHelper:MediaHelper;
      
      public function LoadAvatarCarouselResourceStackable()
      {
         super();
      }
      
      override public function init(param1:Function) : void
      {
         super.init(param1);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(gMainFrame.clientInfo.isCreateAccount ? 1808 : 1892,this.onAvatarCarouselLoaded);
      }
      
      private function onAvatarCarouselLoaded(param1:MovieClip) : void
      {
         if(Boolean(gMainFrame.clientInfo.isCreateAccount) && MainFrame.avatarCreationLogin == null)
         {
            MainFrame.avatarCreationLogin = MovieClip(param1.getChildAt(0));
            this._mediaHelper.destroy();
            this._mediaHelper = null;
            super._resourceDoneLoadingCallback(this);
            return;
         }
         MainFrame.avatarCreationWorld = MovieClip(param1.getChildAt(0));
         this._mediaHelper.destroy();
         this._mediaHelper = null;
         super._resourceDoneLoadingCallback(this);
      }
   }
}

