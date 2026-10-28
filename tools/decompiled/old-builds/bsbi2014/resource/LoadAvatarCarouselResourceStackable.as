package resource
{
   import com.sbi.loader.IResourceStackable;
   import flash.display.MovieClip;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class LoadAvatarCarouselResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      
      private var _mediaHelper:MediaHelper;
      
      public function LoadAvatarCarouselResourceStackable()
      {
         super();
      }
      
      override public function init(callback:Function) : void
      {
         super.init(callback);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(1808,this.onAvatarCarouselLoaded);
      }
      
      private function onAvatarCarouselLoaded(mc:MovieClip) : void
      {
         MainFrame.avatarCreationLogin = MovieClip(mc.getChildAt(0));
         this._mediaHelper = new MediaHelper();
         var mediaId:int = 2696;
         switch(LocalizationManager.currentLanguage)
         {
            case LocalizationManager.LANG_ENG:
               mediaId = 2696;
               break;
            case LocalizationManager.LANG_FRE:
               mediaId = 2695;
               break;
            case LocalizationManager.LANG_POR:
               mediaId = 2737;
               break;
            case LocalizationManager.LANG_DE:
               mediaId = 2757;
               break;
            case LocalizationManager.LANG_SPA:
               mediaId = 2912;
               break;
            default:
               mediaId = 2696;
         }
         this._mediaHelper.init(mediaId,this.onCreationVOLoaded);
      }
      
      private function onCreationVOLoaded(mc:MovieClip) : void
      {
         MainFrame.avatarCreationVO = mc;
         this._mediaHelper.destroy();
         this._mediaHelper = null;
         super._resourceDoneLoadingCallback(this);
      }
   }
}

