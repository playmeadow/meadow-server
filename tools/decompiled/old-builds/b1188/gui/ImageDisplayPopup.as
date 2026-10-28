package gui
{
   import achievement.AchievementXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import movie.MovieManager;
   
   public class ImageDisplayPopup
   {
      
      private const POPUP_MEDIA_ID:int = 2418;
      
      private const IMAGES_LIST_ID:int = 182;
      
      private var _guiLayer:DisplayLayer;
      
      private var _popupMediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _imageIds:Array;
      
      private var _mediaIndex:int;
      
      private var _imageMediaHelper:MediaHelper;
      
      private var _itemWindow:MovieClip;
      
      private var _locStrs:Array;
      
      private var _closeCallback:Function;
      
      private var _tutorialStreamId:int;
      
      private var _tutorialSubtitleId:int;
      
      private var _tutorialText:String;
      
      private var _userVarIdToCheck:int;
      
      private var _videoGenericListId:int;
      
      public function ImageDisplayPopup(param1:Function, param2:int, param3:int)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         this._closeCallback = param1;
         this._guiLayer = GuiManager.guiLayer;
         this._userVarIdToCheck = param3;
         this._videoGenericListId = param2;
         this._popupMediaHelper = new MediaHelper();
         this._popupMediaHelper.init(this.POPUP_MEDIA_ID,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         DarkenManager.unDarken(this._popup);
         this._guiLayer.removeChild(this._popup);
         if(this._popupMediaHelper)
         {
            this._popupMediaHelper.destroy();
            this._popupMediaHelper = null;
         }
         if(this._imageMediaHelper)
         {
            this._imageMediaHelper.destroy();
            this._imageMediaHelper = null;
         }
         if(this._loadingSpiral)
         {
            this._loadingSpiral.destroy();
            this._loadingSpiral = null;
         }
         this.removeEventListeners();
         this._popup = null;
         this._closeCallback = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         this._popup = param1.getChildAt(0) as MovieClip;
         this._popup.info.visible = false;
         this._popup.darkBg.visible = false;
         this._itemWindow = this._popup.greatNatureProject.itemWindow;
         this._loadingSpiral = new LoadingSpiral(this._itemWindow);
         this._imageMediaHelper = new MediaHelper();
         this._popup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         this._popup.greatNatureProject.artistName.autoSize = TextFieldAutoSize.RIGHT;
         GenericListXtCommManager.requestStreamList(this._videoGenericListId,this.onTutorialGLReceived);
         GenericListXtCommManager.requestGenericList(this.IMAGES_LIST_ID,this.onImagesListReceived);
         this.addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         this._guiLayer.addChild(this._popup);
         DarkenManager.darken(this._popup);
      }
      
      private function onImagesListReceived(param1:int, param2:Array, param3:Array) : void
      {
         this._imageIds = param2;
         this._locStrs = param3;
         this.loadImage(null);
      }
      
      private function onTutorialGLReceived(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array, param7:Array) : void
      {
         this._tutorialStreamId = param2[0];
         this._tutorialText = param4[0];
         this._tutorialSubtitleId = param7[0];
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(this._userVarIdToCheck) < 0)
         {
            this.onInfo(null);
            AchievementXtCommManager.requestSetUserVar(this._userVarIdToCheck,1);
         }
      }
      
      private function loadImage(param1:MouseEvent) : void
      {
         if(this._popup)
         {
            this._loadingSpiral.visible = true;
            if(param1)
            {
               if(param1.currentTarget == this._popup.greatNatureProject.lArrow)
               {
                  if(--this._mediaIndex < 0)
                  {
                     this._mediaIndex = this._imageIds.length - 1;
                  }
               }
               else if(param1.currentTarget == this._popup.greatNatureProject.rArrow)
               {
                  if(++this._mediaIndex > this._imageIds.length - 1)
                  {
                     this._mediaIndex = 0;
                  }
               }
            }
            this._popup.greatNatureProject.lArrow.activateGrayState(true);
            this._popup.greatNatureProject.rArrow.activateGrayState(true);
            LocalizationManager.translateId(this._popup.greatNatureProject.artistName,this._locStrs[this._mediaIndex]);
            this._popup.greatNatureProject.photoCredit.x = this._popup.greatNatureProject.artistName.x - this._popup.greatNatureProject.photoCredit.width - 2;
            this._imageMediaHelper.init(this._imageIds[this._mediaIndex],this.onImageLoaded);
         }
      }
      
      private function onImageLoaded(param1:MovieClip) : void
      {
         if(this._popup)
         {
            while(this._itemWindow.numChildren > 0)
            {
               this._itemWindow.removeChildAt(0);
            }
            this._itemWindow.addChild(param1);
            this._loadingSpiral.visible = false;
            this._popup.greatNatureProject.lArrow.activateGrayState(false);
            this._popup.greatNatureProject.rArrow.activateGrayState(false);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onArrow(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.loadImage(param1);
      }
      
      private function onInfo(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.showLoadingSpiral(true);
         GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,[this._tutorialStreamId],[this._tutorialText],[this._tutorialSubtitleId],false);
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == this._popup.info.xBtn)
         {
            this._popup.darkBg.visible = false;
            this._popup.info.visible = false;
         }
         else if(param1.currentTarget == this._popup.greatNatureProject.xBtn)
         {
            if(this._closeCallback != null)
            {
               this._closeCallback();
            }
            else
            {
               this.destroy();
            }
         }
      }
      
      private function addEventListeners() : void
      {
         this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._popup.greatNatureProject.lArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.onArrow,false,0,true);
         this._popup.greatNatureProject.rArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.onArrow,false,0,true);
         this._popup.greatNatureProject.infoBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onInfo,false,0,true);
         this._popup.greatNatureProject.xBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._popup.info.xBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._popup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._popup.greatNatureProject.lArrow.removeEventListener(MouseEvent.MOUSE_DOWN,this.onArrow);
         this._popup.greatNatureProject.rArrow.removeEventListener(MouseEvent.MOUSE_DOWN,this.onArrow);
         this._popup.greatNatureProject.infoBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onInfo);
         this._popup.greatNatureProject.xBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._popup.info.xBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
      }
   }
}

