package movie
{
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.printing.PrintJob;
   import flash.printing.PrintJobOrientation;
   import gui.DarkenManager;
   import gui.FeedbackManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class MovieManager
   {
      
      public static const NORMAL_SKIN:int = 1;
      
      public static const BRADY_BARR_SKIN:int = 2;
      
      public static const TIERNEY_THYS_SKIN:int = 3;
      
      public static const BIGGER_FRAME:int = 5;
      
      public static const VID_PLAYER_MEDIA_ID:int = 39;
      
      public static const VID_SELECTOR_MEDIA_ID:int = 202;
      
      private const MOVIES_PER_SCREEN:int = 4;
      
      private var _popupLayer:DisplayLayer;
      
      private var _movieSelector:MovieClip;
      
      private var _movieSelectorPopup:MovieClip;
      
      private var _closeCallback:Function;
      
      private var _pageNumber:int;
      
      private var _mediaItems:Array;
      
      private var _previewImages:Array;
      
      private var _videoArray:Array;
      
      private var _videoPlayer:VideoPlayerOSMF;
      
      private var _spirals:Array;
      
      private var _movieMediaHelper:MediaHelper;
      
      private var _printMediaHelper:MediaHelper;
      
      private var _previewArray:Array;
      
      private var _baseTitles:Array;
      
      private var _indivTitles:Array;
      
      private var _videoPlayerId:int;
      
      private var _theaterScreen:Object;
      
      private var _isFromTheater:Boolean;
      
      private var _isAsking:Boolean;
      
      private var _titleTxt:String;
      
      private var _statusIds:Array;
      
      private var _subtitleIds:Array;
      
      private var _chooseRandom:Boolean;
      
      private var _printMediaHolder:Array;
      
      private var _numPrintItemsToLoad:int;
      
      private var _numPrintItemsLoaded:int;
      
      private var _loadedImages:Array;
      
      private var _randomPlayerSkinId:int;
      
      private var _shouldRepeat:Boolean;
      
      private var _defaultWidth:int = 512;
      
      private var _defaultHeight:int = 288;
      
      private var _skinFrameId:int = 1;
      
      private var _closeBtn:MovieClip;
      
      private var _leftArrow:MovieClip;
      
      private var _rightArrow:MovieClip;
      
      private var _mw0:MovieClip;
      
      private var _mw1:MovieClip;
      
      private var _mw2:MovieClip;
      
      private var _mw3:MovieClip;
      
      private var _playMovBtn0:MovieClip;
      
      private var _playMovBtn1:MovieClip;
      
      private var _playMovBtn2:MovieClip;
      
      private var _playMovBtn3:MovieClip;
      
      public function MovieManager()
      {
         super();
      }
      
      public function init(guiLayer:DisplayLayer, initTheaterScreen:Object, initPreviews:Array, initVideos:Array, initBaseTitles:Array, initIndivTitles:Array, initStatusIds:Array, initSubtitleIds:Array, initMediaId:int = 202, initVideoPlayerId:int = 39, initCloseCallback:Function = null) : void
      {
         this._popupLayer = guiLayer;
         if(initMediaId > 0)
         {
            this._movieMediaHelper = new MediaHelper();
            this._movieMediaHelper.init(initMediaId,this.movieHelperCallback);
         }
         this._closeCallback = initCloseCallback;
         if(Boolean(initTheaterScreen))
         {
            if(initTheaterScreen is MovieClip)
            {
               this._theaterScreen = initTheaterScreen;
            }
            else if(initTheaterScreen.hasOwnProperty("loader"))
            {
               this._theaterScreen = initTheaterScreen.loader.content;
            }
         }
         this._videoPlayer = new VideoPlayerOSMF();
         if(Boolean(this._theaterScreen))
         {
            MovieClip(this._theaterScreen).addChild(this._videoPlayer);
            this._isFromTheater = true;
         }
         else
         {
            guiLayer.addChild(this._videoPlayer);
            this._isFromTheater = false;
         }
         this._pageNumber = 0;
         this._videoPlayerId = initVideoPlayerId;
         this._spirals = new Array();
         this._previewImages = new Array();
         this._mediaItems = new Array();
         this._videoArray = initVideos;
         this._previewArray = initPreviews;
         this._baseTitles = initBaseTitles;
         this._indivTitles = initIndivTitles;
         this._statusIds = initStatusIds;
         this._subtitleIds = initSubtitleIds;
      }
      
      public function get videoPlayer() : VideoPlayerOSMF
      {
         return this._videoPlayer;
      }
      
      public function destroy() : void
      {
         var i:int = 0;
         this.removeListeners();
         KeepAlive.stopKATimer(this._movieSelectorPopup);
         this._popupLayer.removeChild(this._movieSelectorPopup);
         DarkenManager.unDarken(this._movieSelectorPopup);
         this._movieSelectorPopup = null;
         this._movieSelector = null;
         this._isFromTheater = false;
         this._isAsking = false;
         this._theaterScreen = null;
         this._titleTxt = null;
         this._movieMediaHelper.destroy();
         this._movieMediaHelper = null;
         if(Boolean(this._printMediaHelper))
         {
            this._printMediaHelper.destroy();
            this._printMediaHelper = null;
         }
         if(Boolean(this._mediaItems))
         {
            for(i = 0; i < this._mediaItems.length; i++)
            {
               this._mediaItems[0].destroy();
            }
            this._mediaItems.splice(0,this._mediaItems.length);
            this._mediaItems = null;
         }
         for(var j:int = 0; j < this._spirals.length; j++)
         {
            this._spirals[j].destroy();
         }
         if(Boolean(this._videoPlayer))
         {
            this._videoPlayer.destroy();
         }
         this._spirals = null;
         this._previewImages = null;
         this._mediaItems = null;
         this._videoArray = null;
         this._previewArray = null;
         this._baseTitles = null;
         this._indivTitles = null;
         this._statusIds = null;
         this._closeBtn = null;
         this._leftArrow = null;
         this._rightArrow = null;
         this._mw0 = null;
         this._mw1 = null;
         this._mw2 = null;
         this._mw3 = null;
         this._playMovBtn0 = null;
         this._playMovBtn1 = null;
         this._playMovBtn2 = null;
         this._playMovBtn3 = null;
         this._closeCallback = null;
      }
      
      public function toggleVisibility() : void
      {
         if(Boolean(this._movieSelectorPopup))
         {
            if(this._movieSelectorPopup.visible)
            {
               DarkenManager.unDarken(this._movieSelectorPopup);
            }
            else
            {
               DarkenManager.darken(this._movieSelectorPopup);
            }
            this._movieSelectorPopup.visible = !this._movieSelectorPopup.visible;
         }
      }
      
      public function setSkinFrame(frameId:int) : void
      {
         this._skinFrameId = frameId;
         if(Boolean(this._movieSelector) && this._movieSelector.currentFrame != frameId)
         {
            this._movieSelector.gotoAndPlay(frameId);
         }
      }
      
      public function setQuestionBtn() : void
      {
         if(Boolean(this._movieSelector) && Boolean(this._movieSelector.askTab))
         {
            if(Boolean(this._movieSelector.askTab.hasOwnProperty("askBradyBtn")))
            {
               this._movieSelector.askTab.askBradyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn,false,0,true);
            }
            else
            {
               this._movieSelector.askTab.askTierneyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn,false,0,true);
            }
         }
         else
         {
            this._isAsking = true;
         }
      }
      
      public function setTitleTxt(text:String) : void
      {
         if(Boolean(this._movieSelector))
         {
            LocalizationManager.translateId(this._movieSelector.titleTxt,int(text));
         }
         else
         {
            this._titleTxt = text;
         }
      }
      
      public function chooseRandom(isRandom:Boolean, videoPlayerSkinId:int = 1, shouldRepeat:Boolean = false, width:int = 530, height:int = 298) : void
      {
         this._chooseRandom = isRandom;
         this._randomPlayerSkinId = videoPlayerSkinId;
         if(Boolean(this._movieSelector) && this._chooseRandom)
         {
            this._videoPlayer.init(this._videoArray,this._subtitleIds,this._indivTitles,this._videoPlayerId,-1,shouldRepeat,width,height,this.onVideoPlayerClose);
            this._videoPlayer.setSkinFrame(videoPlayerSkinId);
            this.toggleVisibility();
         }
      }
      
      public function setShouldRepeat(value:Boolean) : void
      {
         this._shouldRepeat = value;
      }
      
      public function setDefaultWidthHeight(width:int, height:int) : void
      {
         this._defaultWidth = width;
         this._defaultHeight = height;
      }
      
      private function movieHelperCallback(img:MovieClip) : void
      {
         var i:int = 0;
         var j:int = 0;
         var movieMediaHelper:MediaHelper = null;
         if(Boolean(img))
         {
            DarkenManager.showLoadingSpiral(false);
            this._movieSelectorPopup = img;
            KeepAlive.startKATimer(this._movieSelectorPopup);
            this._movieSelectorPopup.visible = false;
            this._popupLayer.addChild(this._movieSelectorPopup);
            this._movieSelector = MovieClip(this._movieSelectorPopup.getChildAt(0));
            if(this._movieSelector.currentFrame != this._skinFrameId)
            {
               this._movieSelector.gotoAndPlay(this._skinFrameId);
            }
            for(i = 1; i < Math.min(5,this._previewArray.length + 1); i++)
            {
               this._spirals[i - 1] = new LoadingSpiral(this._movieSelector["mw" + i].itemLayer);
            }
            for(j = 0; j < this._previewArray.length; j++)
            {
               movieMediaHelper = new MediaHelper();
               movieMediaHelper.init(this._previewArray[j],this.previewHelperCallback,true);
               this._mediaItems[j] = movieMediaHelper;
            }
            this._movieSelectorPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._movieSelectorPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._closeBtn = MovieClip(this._movieSelectorPopup.getChildAt(0)["bx"]);
            this._leftArrow = this._movieSelector["arrowLBtn"];
            this._rightArrow = this._movieSelector["arrowRBtn"];
            this._mw0 = this._movieSelector["mw1"];
            this._mw1 = this._movieSelector["mw2"];
            this._mw2 = this._movieSelector["mw3"];
            this._mw3 = this._movieSelector["mw4"];
            this._playMovBtn0 = this._mw0["playMovBtn"];
            this._playMovBtn1 = this._mw1["playMovBtn"];
            this._playMovBtn2 = this._mw2["playMovBtn"];
            this._playMovBtn3 = this._mw3["playMovBtn"];
            this._playMovBtn0.visible = false;
            this._playMovBtn1.visible = false;
            this._playMovBtn2.visible = false;
            this._playMovBtn3.visible = false;
            this._mw0.movieDescTxt.visible = false;
            this._mw1.movieDescTxt.visible = false;
            this._mw2.movieDescTxt.visible = false;
            this._mw3.movieDescTxt.visible = false;
            this._mw0.newTag.visible = false;
            this._mw1.newTag.visible = false;
            this._mw2.newTag.visible = false;
            this._mw3.newTag.visible = false;
            if(this._videoArray.length <= 4)
            {
               this._leftArrow.activateGrayState(true);
               this._rightArrow.activateGrayState(true);
            }
            if(!this._isAsking)
            {
               if(Boolean(this._movieSelector.askTab))
               {
                  this._movieSelector.askTab.visible = false;
               }
            }
            if(Boolean(this._titleTxt))
            {
               LocalizationManager.translateId(this._movieSelector.titleTxt,int(this._titleTxt));
            }
            this.addListeners();
            if(!this._theaterScreen)
            {
               this.toggleVisibility();
            }
            if(Boolean(this._theaterScreen))
            {
               this._videoPlayer.init(this._videoArray,this._subtitleIds,this._indivTitles,-1,-1);
            }
            if(this._chooseRandom)
            {
               this._videoPlayer.init(this._videoArray,this._subtitleIds,this._indivTitles,this._videoPlayerId,-1,this._shouldRepeat,512,288,this.onVideoPlayerClose);
               this._videoPlayer.setSkinFrame(this._randomPlayerSkinId);
               this.toggleVisibility();
            }
         }
      }
      
      private function onVideoPlayerClose() : void
      {
         this.onClose(null);
      }
      
      private function addListeners() : void
      {
         this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._playMovBtn0.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay,false,0,true);
         this._playMovBtn1.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay,false,0,true);
         this._playMovBtn2.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay,false,0,true);
         this._playMovBtn3.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay,false,0,true);
         this._leftArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.onSideBtn,false,0,true);
         this._rightArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.onSideBtn,false,0,true);
         this._movieSelectorPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onMoviePopup,false,0,true);
         if(this._isAsking)
         {
            if(Boolean(this._movieSelector.askTab))
            {
               if(Boolean(this._movieSelector.askTab.hasOwnProperty("askBradyBtn")))
               {
                  this._movieSelector.askTab.askBradyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn,false,0,true);
               }
               else
               {
                  this._movieSelector.askTab.askTierneyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn,false,0,true);
               }
            }
         }
      }
      
      private function removeListeners() : void
      {
         this._closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._playMovBtn0.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
         this._playMovBtn1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
         this._playMovBtn2.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
         this._playMovBtn3.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
         this._leftArrow.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSideBtn);
         this._rightArrow.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSideBtn);
         this._movieSelectorPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMoviePopup);
         if(this._isAsking)
         {
            if(Boolean(this._movieSelector.askTab))
            {
               if(Boolean(this._movieSelector.askTab.hasOwnProperty("askBradyBtn")))
               {
                  this._movieSelector.askTab.askBradyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn);
               }
               else
               {
                  this._movieSelector.askTab.askTierneyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn);
               }
            }
         }
      }
      
      private function onMoviePopup(e:MouseEvent) : void
      {
         e.stopPropagation();
      }
      
      private function onClose(e:MouseEvent) : void
      {
         if(Boolean(e))
         {
            e.stopPropagation();
         }
         if(this._closeCallback != null)
         {
            if(!this._chooseRandom)
            {
               this._closeCallback();
            }
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onAskBtn(e:MouseEvent) : void
      {
         e.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         if(e.currentTarget.name == "askBradyBtn")
         {
            FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_ASK_BRADY);
         }
         else
         {
            FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_ASK_TIERNEY);
         }
      }
      
      private function previewHelperCallback(img:MovieClip) : void
      {
         var currPage:MovieClip = null;
         var i:int = 0;
         var image:Object = null;
         for(var j:int = 0; j < this._mediaItems.length; j++)
         {
            if(this._mediaItems[j] == img.mediaHelper)
            {
               this._previewImages[j] = img;
               if(j < 4)
               {
                  currPage = this["_mw" + j];
                  this._spirals[j].destroy();
                  currPage.movieDescTxt.visible = true;
                  currPage.playMovBtn.visible = true;
                  currPage.itemLayer.addChild(img);
                  LocalizationManager.translateId(currPage.movieDescTxt,this._baseTitles[j]);
                  currPage.newTag.visible = this._statusIds[j] == 1;
                  image = img.getChildAt(0);
                  for(i = 0; i < image.numChildren; i++)
                  {
                     if(image.getChildAt(i).name.indexOf("beakerBtn") >= 0)
                     {
                        image.getChildAt(i).addEventListener(MouseEvent.MOUSE_DOWN,this.onBeakerDown,false,0,true);
                     }
                  }
               }
               break;
            }
         }
         if(this._mediaItems.length < 4)
         {
            for(i = int(this._mediaItems.length); i < 4; i++)
            {
               this["_mw" + i].visible = false;
            }
         }
      }
      
      private function reloadPreviews() : void
      {
         var i:int = 0;
         var currPage:MovieClip = null;
         var image:Object = null;
         for(i = 1; i < 5; i++)
         {
            while(this._movieSelector["mw" + i].itemLayer.numChildren > 0)
            {
               this._movieSelector["mw" + i].itemLayer.removeChildAt(0);
            }
         }
         for(var j:int = this._pageNumber; j < this._pageNumber + 4; j++)
         {
            currPage = this["_mw" + (j - this._pageNumber)];
            if(j < this._previewImages.length)
            {
               currPage.visible = true;
               currPage.itemLayer.addChild(this._previewImages[j]);
               currPage.playMovBtn.visible = true;
               LocalizationManager.translateId(currPage.movieDescTxt,this._baseTitles[j]);
               currPage.newTag.visible = this._statusIds[j] == 1;
               image = this._previewImages[j].getChildAt(0);
               for(i = 0; i < image.numChildren; i++)
               {
                  if(image.getChildAt(i).name.indexOf("beakerBtn") > 0)
                  {
                     image.getChildAt(i).addEventListener(MouseEvent.MOUSE_DOWN,this.onBeakerDown,false,0,true);
                  }
               }
            }
            else
            {
               currPage.visible = false;
            }
         }
      }
      
      private function onPlay(e:MouseEvent) : void
      {
         var increment:int = 0;
         e.stopPropagation();
         switch(e.currentTarget.parent.name)
         {
            case "mw1":
               break;
            case "mw2":
               increment = 1;
               break;
            case "mw3":
               increment = 2;
               break;
            case "mw4":
               increment = 3;
         }
         if(this._videoArray.length > increment + this._pageNumber)
         {
            if(this._chooseRandom || this._isFromTheater)
            {
               this._videoPlayer.playVideoIdx(this._pageNumber + increment);
               this.onClose(e);
            }
            else
            {
               this._videoPlayer.init(this._videoArray,this._subtitleIds,this._indivTitles,this._videoPlayerId,this._pageNumber + increment,this._shouldRepeat,this._defaultWidth,this._defaultHeight);
               this._videoPlayer.setSkinFrame(this._skinFrameId);
            }
         }
      }
      
      private function onSideBtn(e:MouseEvent) : void
      {
         var modNum:int = 0;
         e.stopPropagation();
         switch(e.currentTarget.name)
         {
            case "arrowLBtn":
               if(this._pageNumber - 4 >= 0)
               {
                  this._pageNumber -= 4;
                  this.reloadPreviews();
               }
               else if(this._videoArray.length > 4)
               {
                  modNum = this._videoArray.length % 4;
                  this._pageNumber = this._videoArray.length;
                  this._pageNumber -= modNum == 0 ? 4 : modNum;
                  this.reloadPreviews();
               }
               break;
            default:
               if(this._pageNumber + 4 < this._videoArray.length)
               {
                  this._pageNumber += 4;
                  this.reloadPreviews();
               }
               else
               {
                  this._pageNumber = 0;
                  this.reloadPreviews();
               }
         }
      }
      
      private function onBeakerDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdOnly(14808),true,this.onConfirmPrint,evt.currentTarget.name.split("_"));
      }
      
      private function onConfirmPrint(o:Object) : void
      {
         var i:int = 0;
         if(Boolean(o.status))
         {
            DarkenManager.showLoadingSpiral(true);
            this._numPrintItemsToLoad = o.passback.length - 1;
            this._numPrintItemsLoaded = 0;
            this._printMediaHolder = [];
            this._loadedImages = [];
            for(i = 1; i < o.passback.length; i++)
            {
               this._printMediaHelper = new MediaHelper();
               this._printMediaHelper.init(o.passback[i],this.onPrintMediaLoaded,i);
               this._printMediaHolder.push(this._printMediaHelper);
            }
         }
      }
      
      private function onPrintMediaLoaded(img:MovieClip) : void
      {
         var printJob:PrintJob = null;
         var i:int = 0;
         var printSprites:Array = null;
         var o:Object = null;
         this._loadedImages[img.passback - 1] = img;
         ++this._numPrintItemsLoaded;
         if(this._numPrintItemsLoaded == this._numPrintItemsToLoad)
         {
            DarkenManager.showLoadingSpiral(false);
            printJob = new PrintJob();
            if(printJob.start())
            {
               printSprites = [];
               for(i = 0; i < this._loadedImages.length; i++)
               {
                  o = this.setupPrintSprite(this._loadedImages[i],printJob);
                  printSprites.push(o.spriteToPrint);
                  this._printMediaHolder[i].destroy();
                  try
                  {
                     printJob.addPage(o.spriteToPrint,new Rectangle(0,0,o.realW + 2,o.realH + 2));
                  }
                  catch(e:Error)
                  {
                  }
               }
               o = null;
            }
            this._loadedImages = null;
            this._printMediaHolder = null;
            printJob.send();
            if(Boolean(printSprites))
            {
               for(i = 0; i < printSprites.length; i++)
               {
                  if(Boolean(printSprites[i].parent))
                  {
                     gMainFrame.stage.removeChild(printSprites[i]);
                  }
               }
            }
            printSprites = null;
         }
      }
      
      private function setupPrintSprite(img:MovieClip, printJob:PrintJob) : Object
      {
         var cscaleX:Number = NaN;
         var cscaleY:Number = NaN;
         var imageToPrint:Sprite = new Sprite();
         img.scaleX = img.scaleY = 4;
         imageToPrint.addChild(img);
         img.x = img.y = 1;
         var realW:Number = imageToPrint.width;
         var realH:Number = imageToPrint.height;
         var jpgSource:BitmapData = new BitmapData(imageToPrint.width,imageToPrint.height,false,4294967295);
         jpgSource.draw(imageToPrint);
         var theBitMap:Bitmap = new Bitmap(jpgSource);
         var spriteToPrint:Sprite = new Sprite();
         spriteToPrint.addChild(theBitMap);
         theBitMap.x = 0;
         theBitMap.y = 0;
         theBitMap.scaleX = 0.999;
         theBitMap.scaleY = 0.999;
         spriteToPrint.x = 0;
         spriteToPrint.y = 0;
         gMainFrame.stage.addChild(spriteToPrint);
         spriteToPrint.visible = false;
         if(printJob.orientation != PrintJobOrientation.PORTRAIT)
         {
            spriteToPrint.rotation = 90;
            spriteToPrint.x = spriteToPrint.width;
            cscaleX = printJob.pageWidth / realH;
            cscaleY = printJob.pageHeight / realW;
         }
         else
         {
            cscaleX = printJob.pageWidth / realW;
            cscaleY = printJob.pageHeight / realH;
         }
         spriteToPrint.scaleX = spriteToPrint.scaleY = Math.min(cscaleX,cscaleY);
         return {
            "spriteToPrint":spriteToPrint,
            "realW":realW,
            "realH":realH
         };
      }
   }
}

