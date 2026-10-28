package gui
{
   import Enums.StreamDef;
   import collection.StreamDefCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Timer;
   import game.MinigameManager;
   import loader.JCDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class BulletinBoard
   {
      
      private static const BBOARD_MEDIA_ID:int = 563;
      
      private static const WHATS_NEW_MEDIA_ID:int = 4428;
      
      private static const GALLERY_MEDIA_ID:int = 565;
      
      private static const COSTUME_MEDIA_ID:int = 1634;
      
      private static const TUT_STREAM_GL_ID:int = 8;
      
      private static const ART_MEDIA_GL_ID:int = 23;
      
      private static const WHAT_NEW_IMAGES_ID:int = 369;
      
      private static const WHATS_NEW_VIDEOS_ID:int = 389;
      
      private static const EVT_LOC_ID:int = 670;
      
      private static const DESC_TXT_Y_POS:Number = 181.35;
      
      private var _bulletinBoardPopup:MovieClip;
      
      private var _whatsNewPopup:MovieClip;
      
      private var _whatsNewImageIds:Array;
      
      private var _whatsNewImageIndex:int;
      
      private var _whatsNewImageLoadingSpiral:LoadingSpiral;
      
      private var _whatsNewVideoLoadingSpiral:LoadingSpiral;
      
      private var _costumePopup:MovieClip;
      
      private var _currTutorialStreamDef:StreamDef;
      
      private var _currWhatsNewStreamDef:StreamDef;
      
      private var _artGalleryPopup:MovieClip;
      
      private var _artMediaIds:Array;
      
      private var _artObjects:Object;
      
      private var _artPageNum:int;
      
      private var _jcLoader:JCDefHelper;
      
      private var _howlTextField:TextField;
      
      private var _howlsTextArray:Array;
      
      private var _howlTimer:Timer;
      
      private var _scrollRect:Rectangle;
      
      private var _howlIndex:int;
      
      private var _guiLayer:DisplayLayer;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _mediaHelpers:Array;
      
      private var _tutorialSpiral:LoadingSpiral;
      
      private var _artSpiral:LoadingSpiral;
      
      private var _closeCallback:Function;
      
      private var _gameLaunchObj:Object;
      
      private var _introMediaHelper:MediaHelper;
      
      private var _introCloseId:int;
      
      private var _intro:MovieClip;
      
      private var _introCloseBtn:MovieClip;
      
      private var _musicMutedByPlayer:Boolean;
      
      public function BulletinBoard()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _guiLayer = param1;
         _closeCallback = param2;
         _mediaHelpers = [];
         _artObjects = {};
         _tutorialSpiral = new LoadingSpiral();
         _artSpiral = new LoadingSpiral();
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(563,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         if(_bulletinBoardPopup)
         {
            removeBoardListeners();
            _guiLayer.removeChild(_bulletinBoardPopup);
            DarkenManager.unDarken(_bulletinBoardPopup);
            KeepAlive.stopKATimer(_bulletinBoardPopup);
            _bulletinBoardPopup = null;
         }
         if(_artGalleryPopup)
         {
            removeGalleryListeners();
            if(_artGalleryPopup.parent && _artGalleryPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_artGalleryPopup);
            }
            DarkenManager.unDarken(_artGalleryPopup);
            _artGalleryPopup = null;
         }
         if(_whatsNewPopup)
         {
            removeWhatsNewListeners();
            _whatsNewVideoLoadingSpiral.destroy();
            _whatsNewVideoLoadingSpiral = null;
            _whatsNewImageLoadingSpiral.destroy();
            _whatsNewImageLoadingSpiral = null;
            if(_whatsNewPopup.parent && _whatsNewPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_whatsNewPopup);
            }
            DarkenManager.unDarken(_whatsNewPopup);
            _whatsNewPopup = null;
         }
         if(_costumePopup)
         {
            if(_costumePopup.parent && _costumePopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_costumePopup);
            }
            _costumePopup = null;
         }
         if(_loadingMediaHelper)
         {
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
         }
         if(_tutorialSpiral)
         {
            _tutorialSpiral.destroy();
            _tutorialSpiral = null;
         }
         if(_artSpiral)
         {
            _artSpiral.destroy();
            _artSpiral = null;
         }
         if(_intro)
         {
            _intro.removeEventListener("mouseDown",onPopupDown);
            _intro = null;
         }
         if(_introCloseBtn)
         {
            _introCloseBtn.removeEventListener("mouseDown",onIntroClose);
            _introCloseBtn = null;
         }
         if(_howlTimer)
         {
            _howlTimer.reset();
            _howlTimer = null;
         }
         _artObjects = null;
         _artMediaIds = null;
         _mediaHelpers = null;
      }
      
      public function refresh() : void
      {
         if(_bulletinBoardPopup)
         {
            if(_artGalleryPopup && _artGalleryPopup.visible)
            {
               removeGalleryListeners();
               if(_artGalleryPopup.parent && _artGalleryPopup.parent == _guiLayer)
               {
                  _guiLayer.removeChild(_artGalleryPopup);
               }
               DarkenManager.unDarken(_artGalleryPopup);
               _artGalleryPopup = null;
            }
            _artSpiral.setNewParent(_bulletinBoardPopup.artItemWindow,_bulletinBoardPopup.artItemWindow.width * 0.5,_bulletinBoardPopup.artItemWindow.height * 0.5);
            _artSpiral.visible = true;
            _jcLoader = new JCDefHelper();
            _jcLoader.init(1,onArtGLReceived);
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14712));
         }
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc4_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc2_:Number = NaN;
         if(param1)
         {
            _loc4_ = 0;
            while(true)
            {
               if(_loc4_ < _mediaHelpers.length)
               {
                  if(_mediaHelpers[_loc4_] == param1.mediaHelper)
                  {
                     break;
                  }
                  _loc4_++;
                  continue;
               }
            }
            var _loc5_:* = param1.mediaHelper.id;
            if(563 !== _loc5_)
            {
               loop1:
               while(true)
               {
                  if((_currTutorialStreamDef && _currTutorialStreamDef.thumbnailId) !== _loc5_)
                  {
                     switch(_loc5_)
                     {
                        case _currWhatsNewStreamDef && _currWhatsNewStreamDef.thumbnailId:
                        case _introCloseId:
                           _introCloseBtn = MovieClip(param1.getChildAt(0));
                           _guiLayer.addChild(_introCloseBtn);
                           _introCloseBtn.x = 855;
                           _introCloseBtn.y = 10;
                           _introCloseBtn.addEventListener("mouseDown",onIntroClose,false,0,true);
                           break loop1;
                        case 565:
                           DarkenManager.showLoadingSpiral(false);
                           _artGalleryPopup = MovieClip(param1.getChildAt(0));
                           onGalleryLeftRightDown(null);
                           addGalleryListeners();
                           _guiLayer.addChild(_artGalleryPopup);
                           _artGalleryPopup.x = 900 * 0.5;
                           _artGalleryPopup.y = 550 * 0.5;
                           DarkenManager.darken(_artGalleryPopup);
                           break loop1;
                        case 4428:
                           DarkenManager.showLoadingSpiral(false);
                           _whatsNewPopup = MovieClip(param1.getChildAt(0));
                           _whatsNewImageLoadingSpiral = new LoadingSpiral(_whatsNewPopup.photoItemWindow,_whatsNewPopup.photoItemWindow.width * 0.5,_whatsNewPopup.photoItemWindow.height * 0.5);
                           _whatsNewVideoLoadingSpiral = new LoadingSpiral(_whatsNewPopup.videoItemWindow,_whatsNewPopup.videoItemWindow.width * 0.5,_whatsNewPopup.videoItemWindow.height * 0.5);
                           _whatsNewPopup.playMovBtn.visible = false;
                           addWhatsNewListeners();
                           _guiLayer.addChild(_whatsNewPopup);
                           _whatsNewPopup.x = 900 * 0.5;
                           _whatsNewPopup.y = 550 * 0.5;
                           DarkenManager.darken(_whatsNewPopup);
                           GenericListXtCommManager.requestGenericList(369,onWhatsNewImagesListLoaded);
                           GenericListXtCommManager.requestStreamList(389,onWhatsNewVideosLoaded);
                           break loop1;
                        case 1634:
                           DarkenManager.showLoadingSpiral(false);
                           _costumePopup = MovieClip(param1.getChildAt(0));
                           _costumePopup.addEventListener("mouseDown",onPopupDown,false,0,true);
                           _costumePopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
                           _guiLayer.addChild(_costumePopup);
                           _costumePopup.x = 900 * 0.5;
                           _costumePopup.y = 550 * 0.5;
                           DarkenManager.darken(_costumePopup);
                           break loop1;
                        default:
                           break loop1;
                     }
                  }
                  if(param1.mediaHelper.id == _currTutorialStreamDef.thumbnailId)
                  {
                     _loc3_ = _bulletinBoardPopup;
                     _tutorialSpiral.destroy();
                  }
                  else
                  {
                     _loc3_ = _whatsNewPopup;
                     _whatsNewVideoLoadingSpiral.visible = false;
                  }
                  if(_loc3_)
                  {
                     _loc2_ = _loc3_.videoItemWindow.width / param1.width;
                     param1.scaleX = _loc2_;
                     param1.scaleY = _loc2_;
                     _loc3_.videoItemWindow.addChild(param1);
                     _loc3_.playMovBtn.visible = true;
                  }
                  break;
               }
            }
            else
            {
               DarkenManager.showLoadingSpiral(false);
               _bulletinBoardPopup = MovieClip(param1.getChildAt(0));
               _howlTextField = _bulletinBoardPopup.howlTxt;
               _bulletinBoardPopup.x = 900 * 0.5;
               _bulletinBoardPopup.y = 550;
               _artSpiral.setNewParent(_bulletinBoardPopup.artItemWindow,_bulletinBoardPopup.artItemWindow.width * 0.5,_bulletinBoardPopup.artItemWindow.height * 0.5);
               _tutorialSpiral.setNewParent(_bulletinBoardPopup.videoItemWindow);
               _bulletinBoardPopup.playMovBtn.visible = false;
               _guiLayer.addChild(_bulletinBoardPopup);
               DarkenManager.darken(_bulletinBoardPopup);
               KeepAlive.startKATimer(_bulletinBoardPopup);
               addBoardListeners();
               if(_currTutorialStreamDef != null && _currTutorialStreamDef.thumbnailId > 0)
               {
                  _loadingMediaHelper = new MediaHelper();
                  _loadingMediaHelper.init(_currTutorialStreamDef.thumbnailId,onMediaItemLoaded,true);
                  _mediaHelpers.push(_loadingMediaHelper);
               }
               _jcLoader = new JCDefHelper();
               _jcLoader.init(LocalizationManager.currentLanguage,onArtGLReceived);
               GenericListXtCommManager.requestStreamList(8,onTutorialGLReceived);
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            _mediaHelpers.splice(_loc4_,1);
         }
      }
      
      private function displayText(param1:int) : void
      {
         if(_artGalleryPopup)
         {
            _artGalleryPopup.descTxt.text = _artObjects[param1].desc;
            _artGalleryPopup.descTxt.y = 181.35;
            if(_artGalleryPopup.descTxt.numLines == 1)
            {
               _artGalleryPopup.descTxt.y += 11;
            }
         }
      }
      
      private function onArtDataLoaded(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1 && _bulletinBoardPopup)
         {
            _loc2_ = param1.text;
            _loc4_ = _loc2_.indexOf("|");
            _loc3_ = _loc2_.substr(_loc4_ + 1,_loc2_.length);
            _loc3_ = LocalizationManager.translateAvatarName(_loc3_);
            _artObjects[param1.imageId] = {
               "img":null,
               "desc":_loc3_.toUpperCase()
            };
            displayText(param1.imageId);
            _jcLoader.destroy();
            _jcLoader = null;
            _jcLoader = new JCDefHelper();
            _jcLoader.init(_artMediaIds[_artPageNum],onArtLoaded,true,true);
         }
      }
      
      private function onArtLoaded(param1:MovieClip) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Object = null;
         if(param1 && _bulletinBoardPopup)
         {
            if(_artGalleryPopup && _artGalleryPopup.visible)
            {
               _loc2_ = _artObjects[param1.defHelper.id];
               _loc3_ = _artGalleryPopup.itemWindow.height / _artGalleryPopup.itemWindow.width;
               if(param1.width * _loc3_ > param1.height)
               {
                  _loc3_ = _artGalleryPopup.itemWindow.width / param1.width;
               }
               else
               {
                  _loc3_ = _artGalleryPopup.itemWindow.height / param1.height;
               }
               param1.width *= _loc3_;
               param1.height *= _loc3_;
               param1.y = (_artGalleryPopup.itemWindow.height - param1.height) * 0.5;
               param1.x = (_artGalleryPopup.itemWindow.width - param1.width) * 0.5;
               _loc2_.img = param1;
               while(_artGalleryPopup.itemWindow.numChildren > 1)
               {
                  _artGalleryPopup.itemWindow.removeChildAt(_artGalleryPopup.itemWindow.numChildren - 1);
               }
               _artSpiral.visible = false;
               _artGalleryPopup.itemWindow.addChild(param1);
               _artGalleryPopup.descTxt.text = _loc2_.desc;
            }
            else
            {
               _loc3_ = _bulletinBoardPopup.artItemWindow.height / _bulletinBoardPopup.artItemWindow.width;
               if(param1.width * _loc3_ > param1.height)
               {
                  _loc3_ = _bulletinBoardPopup.artItemWindow.width / param1.width;
               }
               else
               {
                  _loc3_ = _bulletinBoardPopup.artItemWindow.height / param1.height;
               }
               param1.width *= _loc3_;
               param1.height *= _loc3_;
               param1.y = (_bulletinBoardPopup.artItemWindow.height - param1.height) * 0.5;
               param1.x = (_bulletinBoardPopup.artItemWindow.width - param1.width) * 0.5;
               while(_bulletinBoardPopup.artItemWindow.numChildren > 1)
               {
                  _bulletinBoardPopup.artItemWindow.removeChildAt(_bulletinBoardPopup.artItemWindow.numChildren - 1);
               }
               _bulletinBoardPopup.artItemWindow.addChild(param1);
               _artSpiral.visible = false;
            }
            param1.defHelper.destroy();
            delete param1.defHelper;
         }
      }
      
      private function onIntroLoaded(param1:MovieClip) : void
      {
         gMainFrame.stage.quality = "high";
         DarkenManager.showLoadingSpiral(false);
         if(!SBAudio.isMusicMuted || !SBAudio.areSoundsMuted)
         {
            SBAudio.muteMusic(false);
            SBAudio.muteSounds();
            _musicMutedByPlayer = true;
         }
         _intro = param1;
         _intro.addEventListener("mouseDown",onPopupDown,false,0,true);
         _guiLayer.addChild(_intro);
         DarkenManager.darken(_intro);
         _intro.playMovie(onIntroClose);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(_introCloseId,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
         _introMediaHelper.destroy();
         _introMediaHelper = null;
      }
      
      private function onIntroClose(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_intro.parent == _guiLayer)
         {
            _guiLayer.removeChild(_intro);
         }
         if(_intro)
         {
            _intro.stopMovie();
            DarkenManager.unDarken(_intro);
         }
         if(_introCloseBtn && _introCloseBtn.parent == _guiLayer)
         {
            _guiLayer.removeChild(_introCloseBtn);
         }
         if(_musicMutedByPlayer)
         {
            _musicMutedByPlayer = false;
            SBAudio.unmuteMusic(false);
            SBAudio.unmuteSounds();
         }
         gMainFrame.stage.quality = "medium";
      }
      
      private function onTutorialGLReceived(param1:int, param2:StreamDefCollection) : void
      {
         _currTutorialStreamDef = param2.getStreamDefItem(0);
         _introCloseId = 178;
         LocalizationManager.translateId(_bulletinBoardPopup.videoTitleTxt,_currTutorialStreamDef.baseTitleId);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(_currTutorialStreamDef.thumbnailId,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      private function onArtGLReceived(param1:Object) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         if(_bulletinBoardPopup)
         {
            _artMediaIds = param1.jammerCentralGallery;
            _loc2_ = param1.jammerCentralHowls.split(/\"\|/g);
            _loc3_ = 0;
            shuffle(_loc2_);
            _howlsTextArray = [];
            _loc5_ = 0;
            for(; _loc5_ < _loc2_.length; _loc5_++)
            {
               if(_howlsTextArray[_loc3_] == null)
               {
                  _howlsTextArray[_loc3_] = new String();
               }
               else if(_howlsTextArray[_loc3_].length > 1700)
               {
                  _loc5_--;
                  _loc3_++;
                  continue;
               }
               _loc4_ = _loc2_[_loc5_].split(":");
               _loc4_[0] = LocalizationManager.translateAvatarName(_loc4_[0]).toUpperCase();
               _loc2_[_loc5_] = _loc4_.join(":");
               _loc2_[_loc5_] = _loc2_[_loc5_].replace(/\n/g,"");
               _howlsTextArray[_loc3_] += _loc2_[_loc5_] + "\"  -  ";
            }
            _howlIndex = 0;
            setUpHowls();
            _artPageNum = 0;
            _jcLoader = new JCDefHelper();
            _jcLoader.init(_artMediaIds[_artPageNum],onArtDataLoaded);
         }
      }
      
      private function onWhatsNewImagesListLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _whatsNewImageIds = param2;
         _whatsNewImageIndex = 0;
         loadWhatsNewImage();
      }
      
      private function onWhatsNewVideosLoaded(param1:int, param2:StreamDefCollection) : void
      {
         _currWhatsNewStreamDef = param2.getStreamDefItem(0);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(_currWhatsNewStreamDef.thumbnailId,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      private function loadWhatsNewImage() : void
      {
         _whatsNewImageLoadingSpiral.visible = true;
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(_whatsNewImageIds[_whatsNewImageIndex],onWhatsNewImagesLoaded);
      }
      
      private function onWhatsNewImagesLoaded(param1:MovieClip) : void
      {
         _whatsNewImageLoadingSpiral.visible = false;
         while(_whatsNewPopup.photoItemWindow.numChildren > 1)
         {
            _whatsNewPopup.photoItemWindow.removeChildAt(_whatsNewPopup.photoItemWindow.numChildren - 1);
         }
         _whatsNewPopup.photoItemWindow.addChild(param1);
      }
      
      private function shuffle(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc2_:String = null;
         var _loc3_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = param1[_loc4_];
            _loc3_ = Math.floor(Math.random() * param1.length);
            param1[_loc4_] = param1[_loc3_];
            param1[_loc3_] = _loc2_;
            _loc4_++;
         }
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.pop();
         switch(param1.currentTarget.parent)
         {
            case _whatsNewPopup:
               _guiLayer.removeChild(_whatsNewPopup);
               DarkenManager.unDarken(_whatsNewPopup);
               break;
            case _artGalleryPopup:
               _guiLayer.removeChild(_artGalleryPopup);
               DarkenManager.unDarken(_artGalleryPopup);
               _artGalleryPopup.visible = false;
               _artSpiral.visible = false;
               break;
            case _bulletinBoardPopup:
               if(_closeCallback != null)
               {
                  _closeCallback();
               }
               else
               {
                  destroy();
               }
               break;
            case _costumePopup:
               _guiLayer.removeChild(_costumePopup);
               DarkenManager.unDarken(_costumePopup);
         }
      }
      
      private function onPlayMovieDown(param1:MouseEvent) : void
      {
         var _loc3_:StreamDefCollection = null;
         var _loc2_:StreamDef = null;
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         _loc3_ = new StreamDefCollection();
         if(_bulletinBoardPopup && param1.currentTarget == _bulletinBoardPopup.playMovBtn)
         {
            _loc2_ = _currTutorialStreamDef;
         }
         else if(_whatsNewPopup && param1.currentTarget == _whatsNewPopup.playMovBtn)
         {
            _loc2_ = _currWhatsNewStreamDef;
         }
         _loc3_.pushStreamDefItem(_loc2_);
         GuiManager.initMoviePlayer(39,_loc3_,false,768,432);
         GuiManager.setVideoPlayerSkin(5);
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(_gameLaunchObj,null,false);
      }
      
      private function onCostumeBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/costumeCorner",-1,1);
         if(_costumePopup)
         {
            _guiLayer.addChild(_costumePopup);
            DarkenManager.darken(_costumePopup);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(1634,onMediaItemLoaded,true);
            _mediaHelpers.push(_loadingMediaHelper);
         }
      }
      
      private function onWhatsNewBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/whatNew",-1,1);
         if(_whatsNewPopup)
         {
            _guiLayer.addChild(_whatsNewPopup);
            DarkenManager.darken(_whatsNewPopup);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(4428,onMediaItemLoaded,true);
            _mediaHelpers.push(_loadingMediaHelper);
         }
      }
      
      private function onSubmitHowlDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/submit/howl",-1,1);
         DarkenManager.showLoadingSpiral(true);
         FeedbackManager.openFeedbackPopup(3);
      }
      
      private function onSubmitWorkDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/submit/art",-1,1);
         DarkenManager.showLoadingSpiral(true);
         FeedbackManager.openFeedbackPopup(4);
      }
      
      private function onArtGalleryDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_artSpiral && _artSpiral.visible)
         {
            return;
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/artGallery/#page1",-1,1);
         if(_artGalleryPopup)
         {
            _guiLayer.addChild(_artGalleryPopup);
            DarkenManager.darken(_artGalleryPopup);
            _artGalleryPopup.visible = true;
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(565,onMediaItemLoaded,true);
            _mediaHelpers.push(_loadingMediaHelper);
         }
      }
      
      private function onGalleryLeftRightDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(!_artSpiral.visible)
         {
            if(param1)
            {
               param1.stopPropagation();
               if(param1.currentTarget.name == "lBtn")
               {
                  if(_artPageNum - 1 < 0)
                  {
                     _artPageNum = _artMediaIds.length - 1;
                  }
                  else
                  {
                     _artPageNum = _artPageNum - 1;
                  }
               }
               else if(_artPageNum + 1 >= _artMediaIds.length)
               {
                  _artPageNum = 0;
               }
               else
               {
                  _artPageNum = _artPageNum + 1;
               }
               SBTracker.trackPageview("/game/play/popup/jammerCentral/artGallery/#page" + (_artPageNum + 1),-1,1);
            }
            _loc2_ = int(_artMediaIds[_artPageNum]);
            _loc3_ = _artObjects[_loc2_];
            if(_loc3_ && _loc3_.img != null)
            {
               while(_artGalleryPopup.itemWindow.numChildren > 1)
               {
                  _artGalleryPopup.itemWindow.removeChildAt(1);
               }
               _artGalleryPopup.itemWindow.addChild(_loc3_.img);
               displayText(_loc2_);
            }
            else
            {
               _artSpiral.setNewParent(_artGalleryPopup.itemWindow,_artGalleryPopup.itemWindow.width * 0.5,_artGalleryPopup.itemWindow.height * 0.5);
               _artSpiral.visible = true;
               _jcLoader = new JCDefHelper();
               _jcLoader.init(_artMediaIds[_artPageNum],onArtDataLoaded);
            }
         }
      }
      
      private function onLeftRightWhatsNew(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _whatsNewPopup.leftBtn)
         {
            _whatsNewImageIndex = _whatsNewImageIndex - 1;
            if(_whatsNewImageIndex < 0)
            {
               _whatsNewImageIndex = _whatsNewImageIds.length - 1;
            }
         }
         else
         {
            _whatsNewImageIndex = _whatsNewImageIndex + 1;
            if(_whatsNewImageIndex > _whatsNewImageIds.length - 1)
            {
               _whatsNewImageIndex = 0;
            }
         }
         loadWhatsNewImage();
      }
      
      private function setUpHowls() : void
      {
         _howlTextField.cacheAsBitmap = true;
         _howlTextField.autoSize = "left";
         _howlTextField.antiAliasType = "advanced";
         _howlTextField.text = _howlsTextArray[_howlIndex];
         _howlTextField.scrollRect = new Rectangle(0,0,564,18);
         _scrollRect = _howlTextField.scrollRect;
         _scrollRect.x = -564;
         _howlTextField.scrollRect = _scrollRect;
         if(_howlTimer)
         {
            _howlTimer.reset();
            _howlTimer.start();
         }
         else
         {
            _howlTimer = new Timer(41.666666666666664);
            _howlTimer.addEventListener("timer",onTimerEvent,false,0,true);
            _howlTimer.start();
         }
      }
      
      private function onTimerEvent(param1:TimerEvent) : void
      {
         if(_scrollRect.x >= _howlTextField.textWidth)
         {
            _scrollRect.x = -564;
            if(_howlIndex < _howlsTextArray.length - 1)
            {
               _howlIndex = _howlIndex + 1;
            }
            else
            {
               _howlIndex = 0;
            }
            _howlTextField.text = _howlsTextArray[_howlIndex];
         }
         else
         {
            _scrollRect.x += 1;
         }
         _howlTextField.scrollRect = _scrollRect;
         param1.updateAfterEvent();
      }
      
      private function addGalleryListeners() : void
      {
         _artGalleryPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         _artGalleryPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
         _artGalleryPopup.lBtn.addEventListener("mouseDown",onGalleryLeftRightDown,false,0,true);
         _artGalleryPopup.rBtn.addEventListener("mouseDown",onGalleryLeftRightDown,false,0,true);
      }
      
      private function removeGalleryListeners() : void
      {
         _artGalleryPopup.removeEventListener("mouseDown",onPopupDown);
         _artGalleryPopup.bx.removeEventListener("mouseDown",onPopupClose);
         _artGalleryPopup.lBtn.removeEventListener("mouseDown",onGalleryLeftRightDown);
         _artGalleryPopup.rBtn.removeEventListener("mouseDown",onGalleryLeftRightDown);
      }
      
      private function addWhatsNewListeners() : void
      {
         _whatsNewPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         _whatsNewPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
         _whatsNewPopup.leftBtn.addEventListener("mouseDown",onLeftRightWhatsNew,false,0,true);
         _whatsNewPopup.rightBtn.addEventListener("mouseDown",onLeftRightWhatsNew,false,0,true);
         _whatsNewPopup.playMovBtn.addEventListener("mouseDown",onPlayMovieDown,false,0,true);
      }
      
      private function removeWhatsNewListeners() : void
      {
         _whatsNewPopup.removeEventListener("mouseDown",onPopupDown);
         _whatsNewPopup.bx.removeEventListener("mouseDown",onPopupClose);
         _whatsNewPopup.leftBtn.removeEventListener("mouseDown",onLeftRightWhatsNew);
         _whatsNewPopup.rightBtn.removeEventListener("mouseDown",onLeftRightWhatsNew);
         _whatsNewPopup.playMovBtn.removeEventListener("mouseDown",onPlayMovieDown);
      }
      
      private function addBoardListeners() : void
      {
         _bulletinBoardPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         _bulletinBoardPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
         _bulletinBoardPopup.playMovBtn.addEventListener("mouseDown",onPlayMovieDown,false,0,true);
         _bulletinBoardPopup.whatsNewBtn.addEventListener("mouseDown",onWhatsNewBtnDown,false,0,true);
         _bulletinBoardPopup.submitHowlBtn.addEventListener("mouseDown",onSubmitHowlDown,false,0,true);
         _bulletinBoardPopup.submitWorkBtn.addEventListener("mouseDown",onSubmitWorkDown,false,0,true);
         _bulletinBoardPopup.artBtn.addEventListener("mouseDown",onArtGalleryDown,false,0,true);
      }
      
      private function removeBoardListeners() : void
      {
         _bulletinBoardPopup.removeEventListener("mouseDown",onPopupDown);
         _bulletinBoardPopup.bx.removeEventListener("mouseDown",onPopupClose);
         _bulletinBoardPopup.playMovBtn.removeEventListener("mouseDown",onPlayMovieDown);
         _bulletinBoardPopup.whatsNewBtn.removeEventListener("mouseDown",onWhatsNewBtnDown);
         _bulletinBoardPopup.submitHowlBtn.removeEventListener("mouseDown",onSubmitHowlDown);
         _bulletinBoardPopup.submitWorkBtn.removeEventListener("mouseDown",onSubmitWorkDown);
         _bulletinBoardPopup.artBtn.removeEventListener("mouseDown",onArtGalleryDown);
      }
   }
}

