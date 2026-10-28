package game.artStudioPrint
{
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundChannel;
   import flash.printing.PrintJob;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import loader.MediaHelper;
   
   public class ArtStudioPrint extends GameBase implements IMinigame
   {
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public var _soundMan:SoundManager;
      
      public var messageServer:Function;
      
      public var leaveMinigame:Function;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _printMediaHelper:MediaHelper;
      
      private var _exitConfirmationActive:Boolean;
      
      private var _printImage:MovieClip;
      
      private var _imageToPrint:MovieClip;
      
      private var _activeImageIndex:int;
      
      private var _imageIDs:Array;
      
      private var _printIDs:Array;
      
      private var _printOffsets:Array;
      
      private var _loadingImage:Boolean;
      
      private var _printBackground:Object;
      
      public var _layerBackground:Sprite;
      
      public var _layerForeground:Sprite;
      
      public var _SFX_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function ArtStudioPrint()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
      }
      
      public function start(param1:uint, param2:Array, param3:Function, param4:Function) : void
      {
         myId = param1;
         _pIDs = param2;
         messageServer = param3;
         leaveMinigame = param4;
         init();
      }
      
      public function end(param1:Array) : void
      {
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",keyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         removeLayer(_layerForeground);
         removeLayer(_layerBackground);
         removeLayer(_guiLayer);
         _layerForeground = null;
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
            _layerForeground = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerBackground);
            addChild(_layerForeground);
            addChild(_guiLayer);
            loadScene("ArtStudioPrint/room_main.xroom");
            _bInit = true;
            _exitConfirmationActive = false;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc6_:Object = null;
         var _loc2_:* = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         var _loc4_:String = "template";
         var _loc5_:Boolean = true;
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            switch(MinigameManager.minigameInfoCache.currMinigameId - 89)
            {
               case 0:
                  _loc4_ = "notemplate";
                  _loc5_ = false;
            }
         }
         _printBackground = _scene.getLayer(_loc4_);
         _printBackground.loader.x = 10000;
         _printBackground.loader.y = 10000;
         _loc6_ = _scene.getLayer("closeButton");
         addBtn("CloseButton",_loc6_.x,_loc6_.y,onCloseButton);
         _layerBackground.addChild(_scene.getLayer("background").loader);
         if(_loc5_)
         {
            _loc6_ = _scene.getLayer("buttonLeft");
            addBtn("arrowPrintL_button",_loc6_.x,_loc6_.y,onButtonLeft);
            _loc6_ = _scene.getLayer("buttonRight");
            addBtn("arrowPrintR_button",_loc6_.x,_loc6_.y,onButtonRight);
         }
         _loc6_ = _scene.getLayer("buttonCreate");
         addBtn("createPrint_button",_loc6_.x,_loc6_.y,onButtonPrint);
         _loc6_ = _scene.getLayer("buttonPrint");
         _exitConfirmationActive = false;
         _sceneLoaded = true;
         stage.addEventListener("keyDown",keyDown);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         startGame();
         _layerForeground.addChild(_scene.getLayer("topLayer1").loader);
         super.sceneLoaded(param1);
      }
      
      public function message(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1[0] != "ml")
         {
            if(param1[0] == "ms")
            {
               _dbIDs = [];
               _loc2_ = 0;
               while(_loc2_ < _pIDs.length)
               {
                  _dbIDs[_loc2_] = param1[_loc2_ + 1];
                  _loc2_++;
               }
            }
            else if(param1[0] == "mm")
            {
            }
         }
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
            _activeImageIndex = 0;
            _imageIDs = new Array(434,422,394,67,68,88,89,90,2379,2381);
            _printIDs = new Array(435,423,395,112,113,114,115,116,2380,2382);
            _printOffsets = new Array(new Point(20,20),new Point(20,20),new Point(20,20),new Point(20,-50),new Point(20,-50),new Point(20,20),new Point(20,20),new Point(20,-50),new Point(20,20),new Point(20,20));
            if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               switch(MinigameManager.minigameInfoCache.currMinigameId - 89)
               {
                  case 0:
                     _imageIDs = new Array(1958,1958,1958);
                     _printIDs = new Array(1957,1957,1957);
                     _printOffsets = new Array(new Point(-67,-69));
               }
            }
            loadImage(0);
         }
      }
      
      private function loadPrintImage() : void
      {
         _loadingImage = true;
         _printMediaHelper = new MediaHelper();
         _printMediaHelper.init(_printIDs[_activeImageIndex],printImageMediaHandler);
      }
      
      private function printImageMediaHandler(param1:MovieClip) : void
      {
         _imageToPrint = param1;
         _loadingImage = false;
         printOnePerPage();
      }
      
      private function loadImage(param1:int) : void
      {
         if(!_loadingImage)
         {
            if(param1 > 0)
            {
               _activeImageIndex = _activeImageIndex + 1;
               if(_activeImageIndex >= _imageIDs.length)
               {
                  _activeImageIndex = 0;
               }
            }
            else if(param1 < 0)
            {
               _activeImageIndex = _activeImageIndex - 1;
               if(_activeImageIndex < 0)
               {
                  _activeImageIndex = _imageIDs.length - 1;
               }
            }
            _loadingImage = true;
            _printMediaHelper = new MediaHelper();
            _printMediaHelper.init(_imageIDs[_activeImageIndex],printMediaHandler);
         }
      }
      
      private function printMediaHandler(param1:MovieClip) : void
      {
         if(_printImage != null)
         {
            _printImage.parent.removeChild(_printImage);
         }
         param1.x = 114;
         param1.y = 104;
         _printImage = param1;
         _layerBackground.addChild(_printImage);
         _layerBackground.addChild(_printBackground.loader);
         _loadingImage = false;
      }
      
      private function keyDown(param1:KeyboardEvent) : void
      {
         if(!_loadingImage)
         {
            switch(param1.keyCode)
            {
               case 13:
               case 32:
                  onButtonPrint();
                  break;
               case 39:
                  onButtonRight();
                  break;
               case 37:
                  onButtonLeft();
            }
         }
      }
      
      private function onButtonLeft() : void
      {
         if(!_exitConfirmationActive)
         {
            loadImage(-1);
         }
      }
      
      private function onButtonRight() : void
      {
         if(!_exitConfirmationActive)
         {
            loadImage(1);
         }
      }
      
      private function onButtonPrint() : void
      {
         if(!_exitConfirmationActive && !_loadingImage)
         {
            loadPrintImage();
         }
      }
      
      private function onCloseButton() : void
      {
         var _loc1_:MovieClip = null;
         if(!_exitConfirmationActive)
         {
            _exitConfirmationActive = true;
            _loc1_ = showDlg("ArtStudioPrint_ExitDlg",[{
               "name":"button_yes",
               "f":onExit_Yes
            },{
               "name":"button_no",
               "f":onExit_No
            }]);
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         _exitConfirmationActive = false;
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
         _exitConfirmationActive = false;
      }
      
      private function printOnePerPage() : void
      {
         var _loc7_:PrintJob = null;
         var _loc5_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc3_:Sprite = null;
         var _loc8_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc9_:BitmapData = null;
         var _loc12_:Bitmap = null;
         var _loc10_:Sprite = null;
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         if(_imageToPrint)
         {
            stage.removeEventListener("keyDown",keyDown);
            _loc7_ = new PrintJob();
            if(_loc7_.start())
            {
               _loc5_ = Number(_printBackground.loader.content.scaleX);
               _loc1_ = Number(_printBackground.loader.content.scaleY);
               _loc3_ = new Sprite();
               _imageToPrint.scaleX = 4;
               _imageToPrint.scaleY = 4;
               _printBackground.loader.content.scaleX = 4;
               _printBackground.loader.content.scaleY = 4;
               _loc3_.addChild(_printBackground.loader.content);
               _loc3_.addChild(_imageToPrint);
               _imageToPrint.x = _printOffsets[_activeImageIndex].x;
               _imageToPrint.y = _printOffsets[_activeImageIndex].y;
               _loc8_ = _loc3_.width;
               _loc11_ = _loc3_.height;
               _loc2_ = 0;
               _loc9_ = new BitmapData(_loc3_.width + 20,_loc3_.height + 20);
               _loc9_.draw(_loc3_);
               _loc12_ = new Bitmap(_loc9_);
               _loc10_ = new Sprite();
               _loc10_.addChild(_loc12_);
               _loc12_.x = 0;
               _loc12_.y = 0;
               _loc12_.scaleX = 0.999;
               _loc12_.scaleY = 0.999;
               _loc10_.x = 0;
               _loc10_.y = 0;
               if(_loc7_.orientation != "landscape")
               {
                  _loc10_.rotation = 90;
                  _loc10_.x = _loc10_.width;
                  _loc6_ = _loc7_.pageWidth / _loc11_;
                  _loc4_ = _loc7_.pageHeight / _loc8_;
               }
               else
               {
                  _loc6_ = _loc7_.pageWidth / _loc8_;
                  _loc4_ = _loc7_.pageHeight / _loc11_;
               }
               _loc10_.scaleX = _loc10_.scaleY = Math.min(_loc6_,_loc4_);
               _loc10_.visible = false;
               gMainFrame.stage.addChild(_loc10_);
               try
               {
                  _loc7_.addPage(_loc10_,new Rectangle(0,0,_loc8_,_loc11_));
                  _loc2_++;
               }
               catch(e:Error)
               {
                  trace(e);
               }
               gMainFrame.stage.removeChild(_loc10_);
               _loc10_.visible = true;
               _loc10_.scaleX = _loc10_.scaleY = 1;
               _loc10_.rotation = 0;
               _loc3_.removeChild(_imageToPrint);
               _printBackground.loader.content.scaleX = _loc5_;
               _printBackground.loader.content.scaleY = _loc1_;
               if(_loc2_ > 0)
               {
                  _loc7_.send();
               }
            }
            stage.addEventListener("keyDown",keyDown);
         }
      }
   }
}

