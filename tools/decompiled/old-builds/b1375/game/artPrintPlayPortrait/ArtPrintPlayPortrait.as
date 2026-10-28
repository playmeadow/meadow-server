package game.artPrintPlayPortrait
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.printing.PrintJob;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   
   public class ArtPrintPlayPortrait extends GameBase implements IMinigame
   {
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public var leaveMinigame:Function;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _printMediaHelper:MediaHelper;
      
      private var _activeImageIndex:int;
      
      private var _imageIDs:Array;
      
      private var _loadedImages:Array;
      
      private var _loadedPrintImages:Array;
      
      private var _printOffsets:Array;
      
      private var _theGame:MovieClip;
      
      private var _activeImage1:MovieClip;
      
      private var _activeImage2:MovieClip;
      
      private var _activeImage3:MovieClip;
      
      private var _loadingSpiral1:LoadingSpiral;
      
      private var _loadingSpiral2:LoadingSpiral;
      
      private var _loadingSpiral3:LoadingSpiral;
      
      public var _layerBackground:Sprite;
      
      public function ArtPrintPlayPortrait()
      {
         super();
         init();
      }
      
      public function start(param1:uint, param2:Array, param3:Function, param4:Function) : void
      {
         leaveMinigame = param4;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_loadingSpiral1)
         {
            _loadingSpiral1.destroy();
         }
         if(_loadingSpiral2)
         {
            _loadingSpiral2.destroy();
         }
         if(_loadingSpiral3)
         {
            _loadingSpiral3.destroy();
         }
         releaseBase();
         stage.removeEventListener("keyDown",keyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         removeLayer(_layerBackground);
         removeLayer(_guiLayer);
         _layerBackground = null;
         _guiLayer = null;
         if(leaveMinigame != null)
         {
            leaveMinigame(false);
         }
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerBackground = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerBackground);
            addChild(_guiLayer);
            loadScene("ArtPrintPlayPortrait/room_main.xroom");
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc3_:* = null;
         var _loc2_:* = null;
         _sceneLoaded = true;
         stage.addEventListener("keyDown",keyDown);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         startGame();
         super.sceneLoaded(param1);
      }
      
      public function message(param1:Array) : void
      {
      }
      
      public function heartbeat(param1:Event) : void
      {
         if(_sceneLoaded)
         {
         }
      }
      
      public function startGame() : void
      {
         if(_sceneLoaded)
         {
            _theGame = showDlg("museumPrint_GUI",[{
               "name":"page0",
               "f":onPage0
            },{
               "name":"page1",
               "f":onPage1
            },{
               "name":"page2",
               "f":onPage2
            },{
               "name":"arrowL_btn",
               "f":onArrowLeft
            },{
               "name":"arrowR_btn",
               "f":onArrowRight
            },{
               "name":"x_btn",
               "f":onExit
            }]);
            if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               switch(MinigameManager.minigameInfoCache.currMinigameId - 122)
               {
                  case 0:
                     _theGame.arrowR_btn.visible = false;
                     _theGame.arrowL_btn.visible = false;
                     _theGame.Deleted_Symbol.visible = false;
                     _theGame.Deleted_Symbol_1.visible = false;
                     _theGame.covers.y = 157.05;
               }
            }
            _loadingSpiral1 = new LoadingSpiral(_theGame.page0,0,0);
            _loadingSpiral2 = new LoadingSpiral(_theGame.page1,0,0);
            _loadingSpiral3 = new LoadingSpiral(_theGame.page2,0,0);
            _activeImageIndex = 0;
            _imageIDs = new Array(2290,2289,2291);
            if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               switch(MinigameManager.minigameInfoCache.currMinigameId)
               {
                  case 76:
                     _imageIDs = new Array(1591,1592,1593);
                     break;
                  case 86:
                     _imageIDs = new Array(1679,1680,1681);
                     break;
                  case 87:
                     _imageIDs = new Array(1735,1736,1737);
                     break;
                  case 95:
                     _imageIDs = new Array(2839,2840,2841,2842);
                     break;
                  case 122:
                     _imageIDs = new Array(4504,4504,4504);
                     break;
                  case 124:
                     _imageIDs = new Array(4594,4595,4596,4597);
                     break;
                  case 135:
                     _imageIDs = new Array(4743,4744,4745,4746);
                     break;
                  case 136:
                     _imageIDs = new Array(4885,4886,4887);
                     break;
                  case 137:
                     _imageIDs = new Array(4987,4988,4989,4990);
               }
            }
            _printOffsets = new Array(new Point(0,0),new Point(0,0),new Point(0,0),new Point(0,0));
            _loadedImages = [];
            _loadedPrintImages = [];
            loadImage(_imageIDs[0]);
         }
      }
      
      private function loadImage(param1:int) : void
      {
         _printMediaHelper = new MediaHelper();
         _printMediaHelper.init(param1,ImageLoadedHandler);
      }
      
      private function updateButtonImages() : void
      {
         var _loc1_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc2_:int = _activeImageIndex;
         if(_loc2_ < _loadedPrintImages.length)
         {
            _loc1_ = _loadedImages[_loc2_];
         }
         if(++_loc2_ >= _imageIDs.length)
         {
            _loc2_ = 0;
         }
         if(_loc2_ < _loadedPrintImages.length)
         {
            _loc3_ = _loadedImages[_loc2_];
         }
         if(++_loc2_ >= _imageIDs.length)
         {
            _loc2_ = 0;
         }
         if(_loc2_ < _loadedPrintImages.length)
         {
            _loc4_ = _loadedImages[_loc2_];
         }
         if(_activeImage1 != null && (_activeImage1 != _loc1_ && _activeImage1 != _loc3_ && _activeImage1 != _loc4_))
         {
            if(_activeImage1.parent != null)
            {
               _activeImage1.parent.removeChild(_activeImage1);
            }
            _activeImage1 = null;
         }
         if(_activeImage2 != null && (_activeImage2 != _loc1_ && _activeImage2 != _loc3_ && _activeImage2 != _loc4_))
         {
            if(_activeImage2.parent != null)
            {
               _activeImage2.parent.removeChild(_activeImage2);
            }
            _activeImage2 = null;
         }
         if(_activeImage3 != null && (_activeImage3 != _loc1_ && _activeImage3 != _loc3_ && _activeImage3 != _loc4_))
         {
            if(_activeImage3.parent != null)
            {
               _activeImage3.parent.removeChild(_activeImage3);
            }
            _activeImage3 = null;
         }
         if(_loc1_)
         {
            _theGame.page0.imageContainer.addChild(_loc1_);
            _activeImage1 = _loc1_;
            _loadingSpiral1.visible = false;
         }
         else
         {
            _loadingSpiral1.visible = true;
         }
         if(_loc3_)
         {
            _theGame.page1.imageContainer.addChild(_loc3_);
            _activeImage2 = _loc3_;
            _loadingSpiral2.visible = false;
         }
         else
         {
            _loadingSpiral2.visible = true;
         }
         if(_loc4_)
         {
            _theGame.page2.imageContainer.addChild(_loc4_);
            _activeImage3 = _loc4_;
            _loadingSpiral3.visible = false;
         }
         else
         {
            _loadingSpiral3.visible = true;
         }
      }
      
      private function ImageLoadedHandler(param1:MovieClip) : void
      {
         if(_loadedImages.length == _loadedPrintImages.length)
         {
            _loadedImages.push(param1);
            loadImage(_imageIDs[_loadedImages.length - 1]);
         }
         else
         {
            _loadedPrintImages.push(param1);
            if(_loadedPrintImages.length < _imageIDs.length)
            {
               loadImage(_imageIDs[_loadedPrintImages.length]);
            }
            updateButtonImages();
         }
      }
      
      private function keyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onPage1();
               break;
            case 39:
               onArrowRight();
               break;
            case 37:
               onArrowLeft();
         }
      }
      
      private function onPage0() : void
      {
         if(_activeImageIndex < _loadedPrintImages.length)
         {
            printOnePerPage(_activeImageIndex);
         }
      }
      
      private function onPage1() : void
      {
         var _loc1_:int = _activeImageIndex + 1;
         if(_loc1_ >= _imageIDs.length)
         {
            _loc1_ = 0;
         }
         if(_loc1_ < _loadedPrintImages.length)
         {
            printOnePerPage(_loc1_);
         }
      }
      
      private function onPage2() : void
      {
         var _loc1_:int = _activeImageIndex + 2;
         if(_loc1_ == _imageIDs.length)
         {
            _loc1_ = 0;
         }
         else if(_loc1_ >= _imageIDs.length)
         {
            _loc1_ = 1;
         }
         if(_loc1_ < _loadedPrintImages.length)
         {
            printOnePerPage(_loc1_);
         }
      }
      
      private function onArrowLeft() : void
      {
         _activeImageIndex = _activeImageIndex - 1;
         if(_activeImageIndex < 0)
         {
            _activeImageIndex = _imageIDs.length - 1;
         }
         updateButtonImages();
      }
      
      private function onArrowRight() : void
      {
         _activeImageIndex = _activeImageIndex + 1;
         if(_activeImageIndex >= _imageIDs.length)
         {
            _activeImageIndex = 0;
         }
         updateButtonImages();
      }
      
      private function onExit() : void
      {
         hideDlg();
         end(null);
      }
      
      private function printOnePerPage(param1:int) : void
      {
         var _loc9_:PrintJob = null;
         var _loc3_:Sprite = null;
         var _loc6_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc10_:BitmapData = null;
         var _loc8_:Bitmap = null;
         var _loc4_:Sprite = null;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         if(param1 < _loadedPrintImages.length)
         {
            stage.removeEventListener("keyDown",keyDown);
            _loc9_ = new PrintJob();
            if(_loc9_.start())
            {
               _loc3_ = new Sprite();
               _loadedPrintImages[param1].scaleX = 4;
               _loadedPrintImages[param1].scaleY = 4;
               _loc3_.addChild(_loadedPrintImages[param1]);
               _loadedPrintImages[param1].x = 1;
               _loadedPrintImages[param1].y = 1;
               _loc6_ = _loc3_.width;
               _loc11_ = _loc3_.height;
               _loc2_ = 0;
               _loc10_ = new BitmapData(_loc3_.width,_loc3_.height,false,4294967295);
               _loc10_.draw(_loc3_);
               _loc8_ = new Bitmap(_loc10_);
               _loc4_ = new Sprite();
               _loc4_.addChild(_loc8_);
               _loc8_.x = 0;
               _loc8_.y = 0;
               _loc8_.scaleX = 0.999;
               _loc8_.scaleY = 0.999;
               _loc4_.x = 0;
               _loc4_.y = 0;
               if(_loc9_.orientation != "portrait")
               {
                  _loc4_.rotation = 90;
                  _loc4_.x = _loc4_.width;
                  _loc7_ = _loc9_.pageWidth / _loc11_;
                  _loc5_ = _loc9_.pageHeight / _loc6_;
               }
               else
               {
                  _loc7_ = _loc9_.pageWidth / _loc6_;
                  _loc5_ = _loc9_.pageHeight / _loc11_;
               }
               _loc4_.scaleX = _loc4_.scaleY = Math.min(_loc7_,_loc5_);
               _loc4_.visible = false;
               gMainFrame.stage.addChild(_loc4_);
               try
               {
                  _loc9_.addPage(_loc4_,new Rectangle(0,0,_loc6_ + 2,_loc11_ + 2));
                  _loc2_++;
               }
               catch(e:Error)
               {
                  trace(e);
               }
               gMainFrame.stage.removeChild(_loc4_);
               _loc4_.visible = true;
               _loc4_.scaleX = _loc4_.scaleY = 1;
               _loc4_.rotation = 0;
               _loc3_.removeChild(_loadedPrintImages[param1]);
               if(_loc2_ > 0)
               {
                  _loc9_.send();
               }
            }
            stage.addEventListener("keyDown",keyDown);
         }
      }
   }
}

