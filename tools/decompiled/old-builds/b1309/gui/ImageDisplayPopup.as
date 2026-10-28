package gui
{
   import achievement.AchievementXtCommManager;
   import collection.IntItemCollection;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
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
         _closeCallback = param1;
         _guiLayer = GuiManager.guiLayer;
         _userVarIdToCheck = param3;
         _videoGenericListId = param2;
         _popupMediaHelper = new MediaHelper();
         _popupMediaHelper.init(2418,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         DarkenManager.unDarken(_popup);
         _guiLayer.removeChild(_popup);
         if(_popupMediaHelper)
         {
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
         }
         if(_imageMediaHelper)
         {
            _imageMediaHelper.destroy();
            _imageMediaHelper = null;
         }
         if(_loadingSpiral)
         {
            _loadingSpiral.destroy();
            _loadingSpiral = null;
         }
         removeEventListeners();
         _popup = null;
         _closeCallback = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         _popup = param1.getChildAt(0) as MovieClip;
         _popup.info.visible = false;
         _popup.darkBg.visible = false;
         _itemWindow = _popup.greatNatureProject.itemWindow;
         _loadingSpiral = new LoadingSpiral(_itemWindow);
         _imageMediaHelper = new MediaHelper();
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         _popup.greatNatureProject.artistName.autoSize = "right";
         GenericListXtCommManager.requestStreamList(_videoGenericListId,onTutorialGLReceived);
         GenericListXtCommManager.requestGenericList(182,onImagesListReceived);
         addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         _guiLayer.addChild(_popup);
         DarkenManager.darken(_popup);
      }
      
      private function onImagesListReceived(param1:int, param2:Array, param3:Array) : void
      {
         _imageIds = param2;
         _locStrs = param3;
         loadImage(null);
      }
      
      private function onTutorialGLReceived(param1:int, param2:IntItemCollection, param3:IntItemCollection, param4:Array, param5:Array, param6:IntItemCollection, param7:IntItemCollection) : void
      {
         _tutorialStreamId = param2.getIntItem(0);
         _tutorialText = param4[0];
         _tutorialSubtitleId = param7.getIntItem(0);
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(_userVarIdToCheck) < 0)
         {
            onInfo(null);
            AchievementXtCommManager.requestSetUserVar(_userVarIdToCheck,1);
         }
      }
      
      private function loadImage(param1:MouseEvent) : void
      {
         if(_popup)
         {
            _loadingSpiral.visible = true;
            if(param1)
            {
               if(param1.currentTarget == _popup.greatNatureProject.lArrow)
               {
                  if(--_mediaIndex < 0)
                  {
                     _mediaIndex = _imageIds.length - 1;
                  }
               }
               else if(param1.currentTarget == _popup.greatNatureProject.rArrow)
               {
                  if(++_mediaIndex > _imageIds.length - 1)
                  {
                     _mediaIndex = 0;
                  }
               }
            }
            _popup.greatNatureProject.lArrow.activateGrayState(true);
            _popup.greatNatureProject.rArrow.activateGrayState(true);
            LocalizationManager.translateId(_popup.greatNatureProject.artistName,_locStrs[_mediaIndex]);
            _popup.greatNatureProject.photoCredit.x = _popup.greatNatureProject.artistName.x - _popup.greatNatureProject.photoCredit.width - 2;
            _imageMediaHelper.init(_imageIds[_mediaIndex],onImageLoaded);
         }
      }
      
      private function onImageLoaded(param1:MovieClip) : void
      {
         if(_popup)
         {
            while(_itemWindow.numChildren > 0)
            {
               _itemWindow.removeChildAt(0);
            }
            _itemWindow.addChild(param1);
            _loadingSpiral.visible = false;
            _popup.greatNatureProject.lArrow.activateGrayState(false);
            _popup.greatNatureProject.rArrow.activateGrayState(false);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onArrow(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         loadImage(param1);
      }
      
      private function onInfo(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.showLoadingSpiral(true);
         var _loc2_:IntItemCollection = new IntItemCollection();
         _loc2_.pushIntItem(_tutorialStreamId);
         var _loc3_:IntItemCollection = new IntItemCollection();
         _loc3_.pushIntItem(_tutorialSubtitleId);
         GuiManager.initMoviePlayer(39,_loc2_,[_tutorialText],_loc3_,false);
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _popup.info.xBtn)
         {
            _popup.darkBg.visible = false;
            _popup.info.visible = false;
         }
         else if(param1.currentTarget == _popup.greatNatureProject.xBtn)
         {
            if(_closeCallback != null)
            {
               _closeCallback();
            }
            else
            {
               destroy();
            }
         }
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _popup.greatNatureProject.lArrow.addEventListener("mouseDown",onArrow,false,0,true);
         _popup.greatNatureProject.rArrow.addEventListener("mouseDown",onArrow,false,0,true);
         _popup.greatNatureProject.infoBtn.addEventListener("mouseDown",onInfo,false,0,true);
         _popup.greatNatureProject.xBtn.addEventListener("mouseDown",onClose,false,0,true);
         _popup.info.xBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _popup.greatNatureProject.lArrow.removeEventListener("mouseDown",onArrow);
         _popup.greatNatureProject.rArrow.removeEventListener("mouseDown",onArrow);
         _popup.greatNatureProject.infoBtn.removeEventListener("mouseDown",onInfo);
         _popup.greatNatureProject.xBtn.removeEventListener("mouseDown",onClose);
         _popup.info.xBtn.removeEventListener("mouseDown",onClose);
      }
   }
}

