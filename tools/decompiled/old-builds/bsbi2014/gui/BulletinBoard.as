package gui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.display.StageQuality;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   import game.MinigameManager;
   import loader.JCDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import movie.MovieManager;
   
   public class BulletinBoard
   {
      
      private static const BBOARD_MEDIA_ID:int = 563;
      
      private static const CAL_MEDIA_ID:int = 564;
      
      private static const GALLERY_MEDIA_ID:int = 565;
      
      private static const COSTUME_MEDIA_ID:int = 1634;
      
      private static const TUT_STREAM_GL_ID:int = 8;
      
      private static const ART_MEDIA_GL_ID:int = 23;
      
      private static const EVT_LOC_ID:int = 670;
      
      private static const DESC_TXT_Y_POS:Number = 201.35;
      
      private var _bulletinBoardPopup:MovieClip;
      
      private var _calendarPopup:MovieClip;
      
      private var _costumePopup:MovieClip;
      
      private var _tutorialMediaId:int;
      
      private var _tutorialStreamId:int;
      
      private var _tutorialText:String;
      
      private var _tutorialSubtitleId:int;
      
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
      
      public function init(guiLayer:DisplayLayer, initCloseCallback:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._guiLayer = guiLayer;
         this._closeCallback = initCloseCallback;
         this._mediaHelpers = [];
         this._artObjects = new Object();
         this._tutorialSpiral = new LoadingSpiral();
         this._artSpiral = new LoadingSpiral();
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(BBOARD_MEDIA_ID,this.onMediaItemLoaded,true);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         if(Boolean(this._bulletinBoardPopup))
         {
            this.removeBoardListeners();
            this._guiLayer.removeChild(this._bulletinBoardPopup);
            DarkenManager.unDarken(this._bulletinBoardPopup);
            KeepAlive.stopKATimer(this._bulletinBoardPopup);
            this._bulletinBoardPopup = null;
         }
         if(Boolean(this._artGalleryPopup))
         {
            this.removeGalleryListeners();
            if(Boolean(this._artGalleryPopup.parent) && this._artGalleryPopup.parent == this._guiLayer)
            {
               this._guiLayer.removeChild(this._artGalleryPopup);
            }
            DarkenManager.unDarken(this._artGalleryPopup);
            this._artGalleryPopup = null;
         }
         if(Boolean(this._calendarPopup))
         {
            if(Boolean(this._calendarPopup.parent) && this._calendarPopup.parent == this._guiLayer)
            {
               this._guiLayer.removeChild(this._calendarPopup);
            }
            this._calendarPopup = null;
         }
         if(Boolean(this._costumePopup))
         {
            if(Boolean(this._costumePopup.parent) && this._costumePopup.parent == this._guiLayer)
            {
               this._guiLayer.removeChild(this._costumePopup);
            }
            this._costumePopup = null;
         }
         if(Boolean(this._loadingMediaHelper))
         {
            this._loadingMediaHelper.destroy();
            this._loadingMediaHelper = null;
         }
         if(Boolean(this._tutorialSpiral))
         {
            this._tutorialSpiral.destroy();
            this._tutorialSpiral = null;
         }
         if(Boolean(this._artSpiral))
         {
            this._artSpiral.destroy();
            this._artSpiral = null;
         }
         if(Boolean(this._intro))
         {
            this._intro.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown);
            this._intro = null;
         }
         if(Boolean(this._introCloseBtn))
         {
            this._introCloseBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onIntroClose);
            this._introCloseBtn = null;
         }
         if(Boolean(this._howlTimer))
         {
            this._howlTimer.reset();
            this._howlTimer = null;
         }
         this._artObjects = null;
         this._artMediaIds = null;
         this._mediaHelpers = null;
      }
      
      public function refresh() : void
      {
         if(Boolean(this._bulletinBoardPopup))
         {
            if(Boolean(this._artGalleryPopup) && this._artGalleryPopup.visible)
            {
               this.removeGalleryListeners();
               if(Boolean(this._artGalleryPopup.parent) && this._artGalleryPopup.parent == this._guiLayer)
               {
                  this._guiLayer.removeChild(this._artGalleryPopup);
               }
               DarkenManager.unDarken(this._artGalleryPopup);
               this._artGalleryPopup = null;
            }
            this._artSpiral.setNewParent(this._bulletinBoardPopup.artItemWindow,this._bulletinBoardPopup.artItemWindow.width * 0.5,this._bulletinBoardPopup.artItemWindow.height * 0.5);
            this._artSpiral.visible = true;
            this._jcLoader = new JCDefHelper();
            this._jcLoader.init(1,this.onArtGLReceived);
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14712));
         }
      }
      
      private function onMediaItemLoaded(img:MovieClip) : void
      {
         var i:int = 0;
         var scale:Number = NaN;
         if(Boolean(img))
         {
            for(i = 0; i < this._mediaHelpers.length; i++)
            {
               if(this._mediaHelpers[i] == img.mediaHelper)
               {
                  switch(img.mediaHelper.id)
                  {
                     case BBOARD_MEDIA_ID:
                        DarkenManager.showLoadingSpiral(false);
                        this._bulletinBoardPopup = MovieClip(img.getChildAt(0));
                        this._howlTextField = this._bulletinBoardPopup.howlTxt;
                        this._bulletinBoardPopup.x = MainFrame.VIEW_WIDTH * 0.5;
                        this._bulletinBoardPopup.y = MainFrame.VIEW_HEIGHT;
                        this._artSpiral.setNewParent(this._bulletinBoardPopup.artItemWindow,this._bulletinBoardPopup.artItemWindow.width * 0.5,this._bulletinBoardPopup.artItemWindow.height * 0.5);
                        this._tutorialSpiral.setNewParent(this._bulletinBoardPopup.videoItemWindow);
                        this._bulletinBoardPopup.playMovBtn.visible = false;
                        this._guiLayer.addChild(this._bulletinBoardPopup);
                        DarkenManager.darken(this._bulletinBoardPopup);
                        KeepAlive.startKATimer(this._bulletinBoardPopup);
                        this.addBoardListeners();
                        if(this._tutorialMediaId > 0)
                        {
                           this._loadingMediaHelper = new MediaHelper();
                           this._loadingMediaHelper.init(this._tutorialMediaId,this.onMediaItemLoaded,true);
                           this._mediaHelpers.push(this._loadingMediaHelper);
                        }
                        this._jcLoader = new JCDefHelper();
                        this._jcLoader.init(LocalizationManager.currentLanguage,this.onArtGLReceived);
                        GenericListXtCommManager.requestStreamList(TUT_STREAM_GL_ID,this.onTutorialGLReceived);
                        LocalizationManager.translateId(this._bulletinBoardPopup.eventsTxt,EVT_LOC_ID);
                        break;
                     case this._tutorialMediaId:
                        scale = this._bulletinBoardPopup.videoItemWindow.width / img.width;
                        img.scaleX = scale;
                        img.scaleY = scale;
                        this._bulletinBoardPopup.videoItemWindow.addChild(img);
                        this._bulletinBoardPopup.playMovBtn.visible = true;
                        this._tutorialSpiral.destroy();
                        break;
                     case this._introCloseId:
                        this._introCloseBtn = MovieClip(img.getChildAt(0));
                        this._guiLayer.addChild(this._introCloseBtn);
                        this._introCloseBtn.x = 855;
                        this._introCloseBtn.y = 10;
                        this._introCloseBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onIntroClose,false,0,true);
                        break;
                     case GALLERY_MEDIA_ID:
                        DarkenManager.showLoadingSpiral(false);
                        this._artGalleryPopup = MovieClip(img.getChildAt(0));
                        this.onGalleryLeftRightDown(null);
                        this.addGalleryListeners();
                        this._guiLayer.addChild(this._artGalleryPopup);
                        this._artGalleryPopup.x = MainFrame.VIEW_WIDTH * 0.5;
                        this._artGalleryPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
                        DarkenManager.darken(this._artGalleryPopup);
                        break;
                     case CAL_MEDIA_ID:
                        DarkenManager.showLoadingSpiral(false);
                        this._calendarPopup = MovieClip(img.getChildAt(0));
                        this._calendarPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
                        this._calendarPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupClose,false,0,true);
                        this._guiLayer.addChild(this._calendarPopup);
                        this._calendarPopup.x = MainFrame.VIEW_WIDTH * 0.5;
                        this._calendarPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
                        DarkenManager.darken(this._calendarPopup);
                        break;
                     case COSTUME_MEDIA_ID:
                        DarkenManager.showLoadingSpiral(false);
                        this._costumePopup = MovieClip(img.getChildAt(0));
                        this._costumePopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
                        this._costumePopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupClose,false,0,true);
                        this._guiLayer.addChild(this._costumePopup);
                        this._costumePopup.x = MainFrame.VIEW_WIDTH * 0.5;
                        this._costumePopup.y = MainFrame.VIEW_HEIGHT * 0.5;
                        DarkenManager.darken(this._costumePopup);
                  }
                  img.mediaHelper.destroy();
                  delete img.mediaHelper;
                  this._mediaHelpers.splice(i,1);
                  break;
               }
            }
         }
      }
      
      private function displayText(imageId:int) : void
      {
         if(Boolean(this._artGalleryPopup))
         {
            this._artGalleryPopup.descTxt.text = this._artObjects[imageId].desc;
            this._artGalleryPopup.descTxt.y = DESC_TXT_Y_POS;
            if(this._artGalleryPopup.descTxt.numLines == 1)
            {
               this._artGalleryPopup.descTxt.y += 11;
            }
            this._artGalleryPopup.titleTxt.text = this._artObjects[imageId].title;
         }
      }
      
      private function onArtDataLoaded(data:Object) : void
      {
         var delim:int = 0;
         var text:String = null;
         var title:String = null;
         var desc:String = null;
         if(Boolean(data) && Boolean(this._bulletinBoardPopup))
         {
            text = data.data.text;
            delim = text.indexOf("|");
            title = text.substr(0,delim);
            desc = text.substr(delim + 1,text.length);
            desc = LocalizationManager.translateAvatarName(desc);
            this._artObjects[data.data.imageId] = {
               "img":null,
               "title":LocalizationManager.translateIdOnly(int(title)),
               "desc":desc.toUpperCase()
            };
            this.displayText(data.data.imageId);
            this._jcLoader.destroy();
            this._jcLoader = null;
            this._jcLoader = new JCDefHelper();
            this._jcLoader.init(this._artMediaIds[this._artPageNum],this.onArtLoaded,true,true);
         }
      }
      
      private function onArtLoaded(img:MovieClip) : void
      {
         var k:Number = NaN;
         var obj:Object = null;
         if(Boolean(img) && Boolean(this._bulletinBoardPopup))
         {
            if(Boolean(this._artGalleryPopup) && this._artGalleryPopup.visible)
            {
               obj = this._artObjects[img.defHelper.id];
               k = this._artGalleryPopup.itemWindow.height / this._artGalleryPopup.itemWindow.width;
               if(img.width * k > img.height)
               {
                  k = this._artGalleryPopup.itemWindow.width / img.width;
               }
               else
               {
                  k = this._artGalleryPopup.itemWindow.height / img.height;
               }
               img.width *= k;
               img.height *= k;
               img.y = (this._artGalleryPopup.itemWindow.height - img.height) * 0.5;
               img.x = (this._artGalleryPopup.itemWindow.width - img.width) * 0.5;
               obj.img = img;
               while(this._artGalleryPopup.itemWindow.numChildren > 1)
               {
                  this._artGalleryPopup.itemWindow.removeChildAt(this._artGalleryPopup.itemWindow.numChildren - 1);
               }
               this._artSpiral.visible = false;
               this._artGalleryPopup.itemWindow.addChild(img);
               this._artGalleryPopup.descTxt.text = obj.desc;
               this._artGalleryPopup.titleTxt.text = obj.title;
            }
            else
            {
               k = this._bulletinBoardPopup.artItemWindow.height / this._bulletinBoardPopup.artItemWindow.width;
               if(img.width * k > img.height)
               {
                  k = this._bulletinBoardPopup.artItemWindow.width / img.width;
               }
               else
               {
                  k = this._bulletinBoardPopup.artItemWindow.height / img.height;
               }
               img.width *= k;
               img.height *= k;
               img.y = (this._bulletinBoardPopup.artItemWindow.height - img.height) * 0.5;
               img.x = (this._bulletinBoardPopup.artItemWindow.width - img.width) * 0.5;
               while(this._bulletinBoardPopup.artItemWindow.numChildren > 1)
               {
                  this._bulletinBoardPopup.artItemWindow.removeChildAt(this._bulletinBoardPopup.artItemWindow.numChildren - 1);
               }
               this._bulletinBoardPopup.artItemWindow.addChild(img);
               this._artSpiral.visible = false;
            }
            img.defHelper.destroy();
            delete img.defHelper;
         }
      }
      
      private function onIntroLoaded(mc:MovieClip) : void
      {
         gMainFrame.stage.quality = StageQuality.HIGH;
         DarkenManager.showLoadingSpiral(false);
         if(!SBAudio.isMusicMuted || !SBAudio.areSoundsMuted)
         {
            SBAudio.muteMusic(false);
            SBAudio.muteSounds();
            this._musicMutedByPlayer = true;
         }
         this._intro = mc;
         this._intro.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
         this._guiLayer.addChild(this._intro);
         DarkenManager.darken(this._intro);
         this._intro.playMovie(this.onIntroClose);
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this._introCloseId,this.onMediaItemLoaded,true);
         this._mediaHelpers.push(this._loadingMediaHelper);
         this._introMediaHelper.destroy();
         this._introMediaHelper = null;
      }
      
      private function onIntroClose(evt:MouseEvent = null) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(this._intro.parent == this._guiLayer)
         {
            this._guiLayer.removeChild(this._intro);
         }
         if(Boolean(this._intro))
         {
            this._intro.stopMovie();
            DarkenManager.unDarken(this._intro);
         }
         if(Boolean(this._introCloseBtn) && this._introCloseBtn.parent == this._guiLayer)
         {
            this._guiLayer.removeChild(this._introCloseBtn);
         }
         if(this._musicMutedByPlayer)
         {
            this._musicMutedByPlayer = false;
            SBAudio.unmuteMusic(false);
            SBAudio.unmuteSounds();
         }
         gMainFrame.stage.quality = StageQuality.MEDIUM;
      }
      
      private function onTutorialGLReceived(glId:int, streamIds:Array, thumbIds:Array, baseTitles:Array, indivTitles:Array, statusIds:Array, subtitleIds:Array) : void
      {
         this._tutorialStreamId = streamIds[0];
         this._introCloseId = 178;
         LocalizationManager.translateId(this._bulletinBoardPopup.videoTitleTxt,baseTitles[0]);
         this._tutorialText = baseTitles[0];
         this._tutorialMediaId = thumbIds[0];
         this._tutorialSubtitleId = subtitleIds[0];
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this._tutorialMediaId,this.onMediaItemLoaded,true);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      private function onArtGLReceived(data:Object) : void
      {
         var tempArray:Array = null;
         var j:int = 0;
         var nameSplit:Array = null;
         var i:int = 0;
         if(Boolean(this._bulletinBoardPopup))
         {
            this._artMediaIds = data.data.jammerCentralGallery;
            tempArray = data.data.jammerCentralHowls.split(/\"\|/g);
            j = 0;
            this.shuffle(tempArray);
            this._howlsTextArray = [];
            for(i = 0; i < tempArray.length; i++)
            {
               if(this._howlsTextArray[j] == null)
               {
                  this._howlsTextArray[j] = new String();
               }
               else if(this._howlsTextArray[j].length > 1700)
               {
                  i--;
                  j++;
                  continue;
               }
               nameSplit = tempArray[i].split(":");
               nameSplit[0] = LocalizationManager.translateAvatarName(nameSplit[0]).toUpperCase();
               tempArray[i] = nameSplit.join(":");
               tempArray[i] = tempArray[i].replace(/\n/g,"");
               this._howlsTextArray[j] += tempArray[i] + "\"  -  ";
            }
            this._howlIndex = 0;
            this.setUpHowls();
            this._artPageNum = 0;
            this._jcLoader = new JCDefHelper();
            this._jcLoader.init(this._artMediaIds[this._artPageNum],this.onArtDataLoaded);
         }
      }
      
      private function shuffle(target:Array) : void
      {
         var tmp:String = null;
         var randomNum:int = 0;
         for(var i:int = 0; i < target.length; i++)
         {
            tmp = target[i];
            randomNum = Math.floor(Math.random() * target.length);
            target[i] = target[randomNum];
            target[randomNum] = tmp;
         }
      }
      
      private function onPopupDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onPopupClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.pop();
         switch(evt.currentTarget.parent)
         {
            case this._calendarPopup:
               this._guiLayer.removeChild(this._calendarPopup);
               DarkenManager.unDarken(this._calendarPopup);
               break;
            case this._artGalleryPopup:
               this._guiLayer.removeChild(this._artGalleryPopup);
               DarkenManager.unDarken(this._artGalleryPopup);
               this._artGalleryPopup.visible = false;
               this._artSpiral.visible = false;
               break;
            case this._bulletinBoardPopup:
               if(this._closeCallback != null)
               {
                  this._closeCallback();
               }
               else
               {
                  this.destroy();
               }
               break;
            case this._costumePopup:
               this._guiLayer.removeChild(this._costumePopup);
               DarkenManager.unDarken(this._costumePopup);
         }
      }
      
      private function onPlayMovieDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,[this._tutorialStreamId],[this._tutorialText],[this._tutorialSubtitleId],false,768,432);
         GuiManager.setVideoPlayerSkin(MovieManager.BIGGER_FRAME);
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(this._gameLaunchObj,null,false);
      }
      
      private function onCostumeBtnDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/costumeCorner",-1,SBTracker.TYPE_EVENT);
         if(Boolean(this._costumePopup))
         {
            this._guiLayer.addChild(this._costumePopup);
            DarkenManager.darken(this._costumePopup);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            this._loadingMediaHelper = new MediaHelper();
            this._loadingMediaHelper.init(COSTUME_MEDIA_ID,this.onMediaItemLoaded,true);
            this._mediaHelpers.push(this._loadingMediaHelper);
         }
      }
      
      private function onCalendarBtnDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/calendar",-1,SBTracker.TYPE_EVENT);
         if(Boolean(this._calendarPopup))
         {
            this._guiLayer.addChild(this._calendarPopup);
            DarkenManager.darken(this._calendarPopup);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            this._loadingMediaHelper = new MediaHelper();
            this._loadingMediaHelper.init(CAL_MEDIA_ID,this.onMediaItemLoaded,true);
            this._mediaHelpers.push(this._loadingMediaHelper);
         }
      }
      
      private function onSubmitHowlDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/submit/howl",-1,SBTracker.TYPE_EVENT);
         DarkenManager.showLoadingSpiral(true);
         FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_HOWL);
      }
      
      private function onSubmitWorkDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/submit/art",-1,SBTracker.TYPE_EVENT);
         DarkenManager.showLoadingSpiral(true);
         FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_WORK);
      }
      
      private function onArtGalleryDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._artSpiral) && this._artSpiral.visible)
         {
            return;
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/artGallery/#page1",-1,SBTracker.TYPE_EVENT);
         if(Boolean(this._artGalleryPopup))
         {
            this._guiLayer.addChild(this._artGalleryPopup);
            DarkenManager.darken(this._artGalleryPopup);
            this._artGalleryPopup.visible = true;
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            this._loadingMediaHelper = new MediaHelper();
            this._loadingMediaHelper.init(GALLERY_MEDIA_ID,this.onMediaItemLoaded,true);
            this._mediaHelpers.push(this._loadingMediaHelper);
         }
      }
      
      private function onGalleryLeftRightDown(evt:MouseEvent) : void
      {
         var id:int = 0;
         var obj:Object = null;
         if(!this._artSpiral.visible)
         {
            if(Boolean(evt))
            {
               evt.stopPropagation();
               if(evt.currentTarget.name == "lBtn")
               {
                  if(this._artPageNum - 1 < 0)
                  {
                     this._artPageNum = this._artMediaIds.length - 1;
                  }
                  else
                  {
                     --this._artPageNum;
                  }
               }
               else if(this._artPageNum + 1 >= this._artMediaIds.length)
               {
                  this._artPageNum = 0;
               }
               else
               {
                  ++this._artPageNum;
               }
               SBTracker.trackPageview("/game/play/popup/jammerCentral/artGallery/#page" + (this._artPageNum + 1),-1,SBTracker.TYPE_EVENT);
            }
            id = int(this._artMediaIds[this._artPageNum]);
            obj = this._artObjects[id];
            if(Boolean(obj) && obj.img != null)
            {
               while(this._artGalleryPopup.itemWindow.numChildren > 1)
               {
                  this._artGalleryPopup.itemWindow.removeChildAt(1);
               }
               this._artGalleryPopup.itemWindow.addChild(obj.img);
               this.displayText(id);
            }
            else
            {
               this._artSpiral.setNewParent(this._artGalleryPopup.itemWindow,this._artGalleryPopup.itemWindow.width * 0.5,this._artGalleryPopup.itemWindow.height * 0.5);
               this._artSpiral.visible = true;
               this._jcLoader = new JCDefHelper();
               this._jcLoader.init(this._artMediaIds[this._artPageNum],this.onArtDataLoaded);
            }
         }
      }
      
      private function setUpHowls() : void
      {
         this._howlTextField.cacheAsBitmap = true;
         this._howlTextField.autoSize = TextFieldAutoSize.LEFT;
         this._howlTextField.antiAliasType = AntiAliasType.ADVANCED;
         this._howlTextField.text = this._howlsTextArray[this._howlIndex];
         this._howlTextField.scrollRect = new Rectangle(0,0,564,18);
         this._scrollRect = this._howlTextField.scrollRect;
         this._scrollRect.x = -564;
         this._howlTextField.scrollRect = this._scrollRect;
         if(Boolean(this._howlTimer))
         {
            this._howlTimer.reset();
            this._howlTimer.start();
         }
         else
         {
            this._howlTimer = new Timer(1000 / 24);
            this._howlTimer.addEventListener(TimerEvent.TIMER,this.onTimerEvent,false,0,true);
            this._howlTimer.start();
         }
      }
      
      private function onTimerEvent(t:TimerEvent) : void
      {
         if(this._scrollRect.x >= this._howlTextField.textWidth)
         {
            this._scrollRect.x = -564;
            if(this._howlIndex < this._howlsTextArray.length - 1)
            {
               ++this._howlIndex;
            }
            else
            {
               this._howlIndex = 0;
            }
            this._howlTextField.text = this._howlsTextArray[this._howlIndex];
         }
         else
         {
            this._scrollRect.x += 1;
         }
         this._howlTextField.scrollRect = this._scrollRect;
         t.updateAfterEvent();
      }
      
      private function addGalleryListeners() : void
      {
         this._artGalleryPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
         this._artGalleryPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupClose,false,0,true);
         this._artGalleryPopup.lBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onGalleryLeftRightDown,false,0,true);
         this._artGalleryPopup.rBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onGalleryLeftRightDown,false,0,true);
      }
      
      private function removeGalleryListeners() : void
      {
         this._artGalleryPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown);
         this._artGalleryPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupClose);
         this._artGalleryPopup.lBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onGalleryLeftRightDown);
         this._artGalleryPopup.rBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onGalleryLeftRightDown);
      }
      
      private function addBoardListeners() : void
      {
         this._bulletinBoardPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
         this._bulletinBoardPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupClose,false,0,true);
         this._bulletinBoardPopup.playMovBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayMovieDown,false,0,true);
         this._bulletinBoardPopup.seeCalBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCalendarBtnDown,false,0,true);
         this._bulletinBoardPopup.submitHowlBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSubmitHowlDown,false,0,true);
         this._bulletinBoardPopup.submitWorkBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSubmitWorkDown,false,0,true);
         this._bulletinBoardPopup.artBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onArtGalleryDown,false,0,true);
      }
      
      private function removeBoardListeners() : void
      {
         this._bulletinBoardPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown);
         this._bulletinBoardPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupClose);
         this._bulletinBoardPopup.playMovBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayMovieDown);
         this._bulletinBoardPopup.seeCalBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCalendarBtnDown);
         this._bulletinBoardPopup.submitHowlBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSubmitHowlDown);
         this._bulletinBoardPopup.submitWorkBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSubmitWorkDown);
         this._bulletinBoardPopup.artBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onArtGalleryDown);
      }
   }
}

