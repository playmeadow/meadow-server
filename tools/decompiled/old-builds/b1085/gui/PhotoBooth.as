package gui
{
   import avatar.Avatar;
   import avatar.AvatarEditorView;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.graphics.JPEGAsyncCompleteEvent;
   import com.sbi.graphics.JpegAsynchEncoder;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class PhotoBooth
   {
      
      private static var _nameSaveIndex:int = 1;
      
      private const IMAGE_WIDTH:int = 626;
      
      private const IMAGE_HEIGHT:int = 470;
      
      private var _mediaHelper:MediaHelper;
      
      private var _currAvtView:AvatarEditorView;
      
      private var _booth:MovieClip;
      
      private var _myPet:GuiPet;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _numBackgroundFrames:int;
      
      private var _currBackgroundFrame:int;
      
      private var _jpgEncoder:JpegAsynchEncoder;
      
      private var _hudAvtView:AvatarView;
      
      private var _startingFrame:int;
      
      private var _petPosIndex:int;
      
      private var _debugAvtIndex:int;
      
      private var _loadingSpiralAvt:LoadingSpiral;
      
      private var _flip:Boolean;
      
      public function PhotoBooth()
      {
         super();
      }
      
      public function init(param1:Function = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._closeCallback = param1;
         this._guiLayer = GuiManager.guiLayer;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(2017,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         SBTracker.trackPageview("/game/play/popup/photobooth/exit");
         KeepAlive.stopKATimer(this._booth);
         SafeChatManager.destroy(this._booth.chatTree);
         this.removeEventListeners();
         DarkenManager.unDarken(this._booth);
         this._guiLayer.removeChild(this._booth);
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            SBTracker.trackPageview("/game/play/popup/photobooth/enter");
            this._booth = MovieClip(param1.getChildAt(0));
            KeepAlive.startKATimer(this._booth);
            this.initializeNeededItems();
            this.positionAndDrawAvatarView(true);
            this.showHudAvt();
            this.loadPetView();
            this.addEventListeners();
            this._booth.x = MainFrame.VIEW_WIDTH * 0.5;
            this._booth.y = MainFrame.VIEW_HEIGHT * 0.5;
            DarkenManager.showLoadingSpiral(false);
            this._guiLayer.addChild(this._booth);
            DarkenManager.darken(this._booth);
         }
      }
      
      private function initializeNeededItems() : void
      {
         this._numBackgroundFrames = this._booth.imageCont.backgroundCont.totalFrames;
         this._currBackgroundFrame = 1;
         this._petPosIndex = -1;
         this._booth.imageCont.msgTxt.filters = [new GlowFilter(16777215)];
         this._booth.imageCont.petLShadow.visible = false;
         this._booth.imageCont.petRShadow.visible = false;
         this._booth.posBtn.activateGrayState(true);
         this._booth.avtBtn.visible = false;
         SafeChatManager.buildSafeChatTree(this._booth.chatTree,"ECardTextTreeNode",SafeChatManager.TREE_PHOTOBOOTH,this.onTextClose,null);
         SafeChatManager.closeSafeChat(this._booth.chatTree);
         this._booth.imageCont.chatBalloon.visible = false;
         this._booth.textBtn.currTxt.text = SafeChatManager.photoBoothNodes[0];
         this._booth.imageCont.msgTxt.text = SafeChatManager.photoBoothNodes[0];
         this._booth.imageCont.chatBalloon.closeChatBtn.visible = false;
         this._booth.bubbleLockToggle.toggleBtn.gotoAndStop("startingOff");
         this._booth.bubbleLockToggle.toggleBtn.toggleKnob.gotoAndStop("up");
         this._booth.bubbleLockToggle.toggleBtn.toggleBG.gotoAndStop("up");
         this._loadingSpiralAvt = new LoadingSpiral(this._booth.imageCont.charBox);
      }
      
      private function positionAndDrawAvatarView(param1:Boolean = false) : void
      {
         var _loc2_:Point = null;
         if(param1)
         {
            if(this._currAvtView)
            {
               this._startingFrame = this._currAvtView.frame;
               if(this._currAvtView.parent)
               {
                  this._booth.imageCont.charBox.removeChild(this._currAvtView);
               }
            }
            this._loadingSpiralAvt.setNewParent(this._booth.imageCont.charBox);
            this._loadingSpiralAvt.visible = true;
            this._currAvtView = new AvatarEditorView();
            this._currAvtView.init(AvatarManager.playerAvatar);
         }
         _loc2_ = AvatarUtility.getAvatarPhotoOffset(this._currAvtView.avTypeId);
         this._currAvtView.x = _loc2_.x;
         this._currAvtView.y = _loc2_.y;
         this._currAvtView.visible = false;
         this._currAvtView.playAnim(LayerAnim.AN_PHOTO,false,LayerAnim.PLAY_LOOP,this.onAvatarLoaded);
         this._currAvtView.scaleX = this.IMAGE_WIDTH / 1024;
         this._currAvtView.scaleY = this.IMAGE_HEIGHT / 768;
         this._booth.imageCont.charBox.addChild(this._currAvtView);
      }
      
      private function loadPetView() : void
      {
         var _loc3_:Object = null;
         var _loc1_:Array = PetManager.myPetList;
         this._myPet = null;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            if(_loc1_[_loc2_].idx == PetManager.myActivePetInvId)
            {
               _loc3_ = _loc1_[_loc2_];
               if(!PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc3_.type))
               {
                  break;
               }
               this._booth.posBtn.activateGrayState(false);
               this._myPet = new GuiPet(_loc3_.idx,_loc3_.lBits,_loc3_.uBits,_loc3_.eBits,_loc3_.type,_loc3_.name,this.onPetLoaded);
               break;
            }
            _loc2_++;
         }
         if(this._myPet == null)
         {
            this._booth.posBtn.activateGrayState(true);
            while(this._booth.imageCont.itemWindowPet2R.numChildren > 0)
            {
               this._booth.imageCont.itemWindowPet2R.removeChildAt(0);
            }
            while(this._booth.imageCont.itemWindowPet1R.numChildren > 0)
            {
               this._booth.imageCont.itemWindowPet1R.removeChildAt(0);
            }
            while(this._booth.imageCont.itemWindowPet2L.numChildren > 0)
            {
               this._booth.imageCont.itemWindowPet2L.removeChildAt(0);
            }
            while(this._booth.imageCont.itemWindowPet1L.numChildren > 0)
            {
               this._booth.imageCont.itemWindowPet1L.removeChildAt(0);
            }
         }
      }
      
      private function addEventListeners() : void
      {
         with(this._booth)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
            leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtn,false,0,true);
            rightBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtn,false,0,true);
            actionPose.addEventListener(MouseEvent.MOUSE_DOWN,onActionPoseBtn,false,0,true);
            actionPose.addEventListener(MouseEvent.ROLL_OVER,onActionPoseOverHandler,false,0,true);
            actionPose.addEventListener(MouseEvent.ROLL_OUT,onOutHandler,false,0,true);
            posBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPetPosBtn,false,0,true);
            posBtn.addEventListener(MouseEvent.ROLL_OVER,onPetPosOverHandler,false,0,true);
            posBtn.addEventListener(MouseEvent.ROLL_OUT,onOutHandler,false,0,true);
            addTextBtn.addEventListener(MouseEvent.MOUSE_DOWN,onTextBtn,false,0,true);
            camBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSaveBtn,false,0,true);
            camBtn.addEventListener(MouseEvent.ROLL_OVER,onSaveOverHandler,false,0,true);
            camBtn.addEventListener(MouseEvent.ROLL_OUT,onOutHandler,false,0,true);
            char.addEventListener(MouseEvent.MOUSE_DOWN,onCustomize,false,0,true);
            char.addEventListener(MouseEvent.ROLL_OVER,charWindowOverHandler,false,0,true);
            char.addEventListener(MouseEvent.ROLL_OUT,charWindowOutHandler,false,0,true);
            bubbleLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,onToggleBtn,false,0,true);
            bubbleLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OVER,onToggleOver,false,0,true);
            bubbleLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OUT,onToggleOut,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         with(this._booth)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            bx.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
            leftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtn);
            rightBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtn);
            actionPose.removeEventListener(MouseEvent.MOUSE_DOWN,onActionPoseBtn);
            actionPose.removeEventListener(MouseEvent.ROLL_OVER,onActionPoseOverHandler);
            actionPose.removeEventListener(MouseEvent.ROLL_OUT,onOutHandler);
            posBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onPetPosBtn);
            posBtn.removeEventListener(MouseEvent.ROLL_OVER,onPetPosOverHandler);
            posBtn.removeEventListener(MouseEvent.ROLL_OUT,onOutHandler);
            addTextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onTextBtn);
            camBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSaveBtn);
            camBtn.removeEventListener(MouseEvent.ROLL_OVER,onSaveOverHandler);
            camBtn.removeEventListener(MouseEvent.ROLL_OUT,onOutHandler);
            char.removeEventListener(MouseEvent.MOUSE_DOWN,onCustomize);
            bubbleLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onToggleBtn);
            bubbleLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OVER,onToggleOver);
            bubbleLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OUT,onToggleOut);
         }
      }
      
      private function onTextClose(param1:String, param2:String) : void
      {
         this._booth.textBtn.currTxt.text = param1;
         this._booth.imageCont.msgTxt.text = param1;
         this.setTextVisibility();
         SafeChatManager.closeSafeChat(this._booth.chatTree);
      }
      
      private function completeSaveAction() : void
      {
         DarkenManager.showLoadingSpiral(true,true);
         var _loc1_:BitmapData = new BitmapData(1024,768);
         var _loc2_:Matrix = new Matrix(1024 / this.IMAGE_WIDTH,0,0,768 / this.IMAGE_HEIGHT,0,0);
         _loc1_.draw(this._booth.imageCont,_loc2_,null,null,null,true);
         this._jpgEncoder = new JpegAsynchEncoder();
         this._jpgEncoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE,this.asyncEncodingComplete,false,0,true);
         this._jpgEncoder.addEventListener(ProgressEvent.PROGRESS,this.onEncodingProgress,false,0,true);
         this._jpgEncoder.PixelsPerIteration = 128;
         this._jpgEncoder.JPEGAsyncEncoder(100);
         this._jpgEncoder.encode(_loc1_);
      }
      
      private function showHudAvt() : void
      {
         var _loc1_:Avatar = AvatarManager.playerAvatar;
         if(this._hudAvtView)
         {
            if(this._hudAvtView.parent == this._booth.char.charLayer)
            {
               this._booth.char.charLayer.removeChild(this._hudAvtView);
            }
            this._hudAvtView.destroy();
         }
         this._hudAvtView = new AvatarView();
         this._hudAvtView.init(_loc1_);
         this._hudAvtView.playAnim(LayerAnim.AN_HUD_AVT,false,LayerAnim.PLAY_ONE_SHOT);
         var _loc2_:Point = AvatarUtility.getAvatarHudPosition(this._hudAvtView.avTypeId);
         this._hudAvtView.x = _loc2_.x;
         this._hudAvtView.y = _loc2_.y;
         this._booth.char.charLayer.addChild(this._hudAvtView);
      }
      
      private function setTextVisibility() : void
      {
         if(this._booth.bubbleLockToggle.toggleBtn.currentFrameLabel == "on" || this._booth.bubbleLockToggle.toggleBtn.currentFrameLabel == "startingOn")
         {
            this._booth.imageCont.msgTxt.visible = false;
         }
         else
         {
            this._booth.imageCont.msgTxt.visible = true;
         }
      }
      
      private function addPetToCorrectSpot(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:Matrix = null;
         if(param1 > 3)
         {
            param1 = 0;
         }
         var _loc4_:int = param1;
         if(param2)
         {
            if(param1 % 2 != 0)
            {
               _loc4_ = param1 - 1;
            }
         }
         switch(_loc4_)
         {
            case 0:
               while(this._booth.imageCont.itemWindowPet2R.numChildren > 0)
               {
                  this._booth.imageCont.itemWindowPet2R.removeChildAt(0);
               }
               while(this._booth.imageCont.itemWindowPet1R.numChildren > 0)
               {
                  this._booth.imageCont.itemWindowPet1R.removeChildAt(0);
               }
               while(this._booth.imageCont.itemWindowPet2L.numChildren > 0)
               {
                  this._booth.imageCont.itemWindowPet2L.removeChildAt(0);
               }
               while(this._booth.imageCont.itemWindowPet1L.numChildren > 0)
               {
                  this._booth.imageCont.itemWindowPet1L.removeChildAt(0);
               }
               if(this._myPet.isGround())
               {
                  this._booth.imageCont.itemWindowPet2L.addChild(this._myPet);
               }
               else
               {
                  this._booth.imageCont.itemWindowPet1L.addChild(this._myPet);
               }
               if(_loc4_ == param1)
               {
                  break;
               }
            case 1:
               _loc3_ = this._myPet.transform.matrix;
               _loc3_.scale(-1,1);
               this._myPet.transform.matrix = _loc3_;
               break;
            case 2:
               while(this._booth.imageCont.itemWindowPet2L.numChildren > 0)
               {
                  this._booth.imageCont.itemWindowPet2L.removeChildAt(0);
               }
               while(this._booth.imageCont.itemWindowPet1L.numChildren > 0)
               {
                  this._booth.imageCont.itemWindowPet1L.removeChildAt(0);
               }
               while(this._booth.imageCont.itemWindowPet2R.numChildren > 0)
               {
                  this._booth.imageCont.itemWindowPet2R.removeChildAt(0);
               }
               while(this._booth.imageCont.itemWindowPet1R.numChildren > 0)
               {
                  this._booth.imageCont.itemWindowPet1R.removeChildAt(0);
               }
               if(this._myPet.isGround())
               {
                  this._booth.imageCont.itemWindowPet2R.addChild(this._myPet);
               }
               else
               {
                  this._booth.imageCont.itemWindowPet1R.addChild(this._myPet);
               }
               if(_loc4_ == param1)
               {
                  break;
               }
            case 3:
               _loc3_ = this._myPet.transform.matrix;
               _loc3_.scale(-1,1);
               this._myPet.transform.matrix = _loc3_;
         }
         this._petPosIndex = param1;
      }
      
      private function loadDebugAvatar(param1:Avatar) : void
      {
         if(this._currAvtView)
         {
            this._startingFrame = this._currAvtView.frame;
            if(this._currAvtView.parent)
            {
               this._booth.imageCont.charBox.removeChild(this._currAvtView);
            }
         }
         this._loadingSpiralAvt.setNewParent(this._booth.imageCont.charBox);
         this._loadingSpiralAvt.visible = true;
         this._currAvtView = new AvatarEditorView();
         this._currAvtView.init(param1);
         var _loc2_:Point = AvatarUtility.getAvatarPhotoOffset(this._currAvtView.avTypeId);
         this._currAvtView.x = _loc2_.x;
         this._currAvtView.y = _loc2_.y;
         this._currAvtView.visible = false;
         this._currAvtView.playAnim(LayerAnim.AN_PHOTO,false,LayerAnim.PLAY_LOOP,this.onAvatarLoaded);
         this._currAvtView.scaleX = this.IMAGE_WIDTH / 1024;
         this._currAvtView.scaleY = this.IMAGE_HEIGHT / 768;
         this._booth.imageCont.charBox.addChild(this._currAvtView);
      }
      
      private function onAvatarLoaded(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Matrix = null;
         this._currAvtView.visible = true;
         this._currAvtView.pauseAnim(true);
         this._currAvtView.frame = this._startingFrame;
         this._loadingSpiralAvt.visible = false;
         if(this._flip)
         {
            _loc3_ = this._currAvtView.transform.matrix;
            _loc3_.scale(-1,1);
            this._currAvtView.transform.matrix = _loc3_;
         }
         else if(this._booth.imageCont.avtShadow.scaleX < 0)
         {
            this._booth.imageCont.avtShadow.scaleX *= -1;
         }
      }
      
      private function onPetLoaded(param1:MovieClip) : void
      {
         var _loc2_:Matrix = null;
         this._myPet.scaleX = this._myPet.scaleY = 2;
         if(this._petPosIndex < 2)
         {
            _loc2_ = this._myPet.transform.matrix;
            _loc2_.scale(-1,1);
            this._myPet.transform.matrix = _loc2_;
         }
         this.addPetToCorrectSpot(this._petPosIndex == -1 ? 0 : this._petPosIndex,true);
      }
      
      private function onAvatarEditorClose() : void
      {
         this.positionAndDrawAvatarView(true);
         this.showHudAvt();
         this.loadPetView();
      }
      
      private function flashComplete() : void
      {
         this.completeSaveAction();
      }
      
      private function onSaveImage(param1:Object) : void
      {
         if(param1.status)
         {
            SBTracker.trackPageview("/game/play/popup/photobooth/imageSaved");
            DarkenManager.showLoadingSpiral(true);
            AvatarXtCommManager.sendAvatarPhotoTake(this.onPhotoGemsSpent);
            ++_nameSaveIndex;
         }
      }
      
      private function onPhotoGemsSpent(param1:Object) : void
      {
         gMainFrame.clientInfo.gemCount = int(param1[2]);
         DarkenManager.showLoadingSpiral(false);
         AJAudio.playShopCachingSound();
      }
      
      private function onSaveForGems(param1:Object) : void
      {
         SBTracker.trackPageview("/game/play/popup/photobooth/saveForGems");
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            AvatarXtCommManager.sendAvatarPhotoTakeCheck(this.onGemsSpent);
         }
      }
      
      private function onGemsSpent(param1:Object) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1[2] >= 0)
         {
            this._booth.flash.playFlash(this.flashComplete);
         }
         else
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14788));
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._closeCallback != null)
         {
            this._closeCallback();
            this._closeCallback = null;
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onLeftRightBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/leftRight");
         if(param1.currentTarget.name == "leftBtn")
         {
            if(this._currBackgroundFrame - 1 < 1)
            {
               this._currBackgroundFrame = this._numBackgroundFrames;
            }
            else
            {
               --this._currBackgroundFrame;
            }
         }
         else if(param1.currentTarget.name == "rightBtn")
         {
            if(this._currBackgroundFrame + 1 > this._numBackgroundFrames)
            {
               this._currBackgroundFrame = 1;
            }
            else
            {
               ++this._currBackgroundFrame;
            }
         }
         if(this._booth.imageCont.backgroundCont.currentLabels[this._currBackgroundFrame - 1].name.indexOf("ocean") >= 0)
         {
            if(!Utility.isOcean(AvatarManager.playerAvatar.enviroTypeFlag))
            {
               this.onLeftRightBtn(param1);
               return;
            }
         }
         else if(!Utility.isLand(AvatarManager.playerAvatar.enviroTypeFlag))
         {
            this.onLeftRightBtn(param1);
            return;
         }
         this._booth.imageCont.backgroundCont.gotoAndStop(this._currBackgroundFrame);
      }
      
      private function onActionPoseBtn(param1:MouseEvent) : void
      {
         var _loc2_:Matrix = null;
         param1.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/poseBtn");
         if(this._currAvtView)
         {
            _loc2_ = this._currAvtView.transform.matrix;
            _loc2_.scale(-1,1);
            this._currAvtView.transform.matrix = _loc2_;
            this._flip = !this._flip;
            this._booth.imageCont.avtShadow.scaleX *= -1;
         }
      }
      
      private function onActionPoseOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14675),param1.currentTarget.x + param1.currentTarget.parent.x,param1.currentTarget.y + param1.currentTarget.parent.y - 27);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onPetPosBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/petPose");
         if(this._myPet)
         {
            this.addPetToCorrectSpot(this._petPosIndex + 1);
         }
      }
      
      private function onPetPosOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14676),param1.currentTarget.x + param1.currentTarget.parent.x,param1.currentTarget.y + param1.currentTarget.parent.y - 27);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onTextBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._booth.chatTree.visible)
         {
            SafeChatManager.openSafeChat(false,this._booth.chatTree);
         }
         else
         {
            SafeChatManager.closeSafeChat(this._booth.chatTree);
         }
      }
      
      private function onSaveBtn(param1:MouseEvent) : void
      {
         SBTracker.trackPageview("/game/play/popup/photobooth/save");
         param1.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14789,50),true,this.onSaveForGems);
      }
      
      private function onSaveOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14677),param1.currentTarget.x + param1.currentTarget.parent.x,param1.currentTarget.y + param1.currentTarget.parent.y - 41);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onEncodingProgress(param1:ProgressEvent) : void
      {
         DarkenManager.updateLoadingSpiralPercentage(Math.round(param1.bytesLoaded / param1.bytesTotal * 100) + "%");
      }
      
      private function asyncEncodingComplete(param1:JPEGAsyncCompleteEvent) : void
      {
         this._jpgEncoder.removeEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE,this.asyncEncodingComplete);
         this._jpgEncoder.removeEventListener(ProgressEvent.PROGRESS,this.onEncodingProgress);
         DarkenManager.showLoadingSpiral(false);
         new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14790),true,this.onSaveImage,{
            "FileReference":true,
            "ImageData":this._jpgEncoder.ImageData,
            "SaveName":"AnimalJam_" + _nameSaveIndex + ".jpg"
         });
      }
      
      private function onCustomize(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openAvatarEditor(this.onAvatarEditorClose);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function charWindowOverHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14673),param1.currentTarget.x + param1.currentTarget.parent.x,param1.currentTarget.y + param1.currentTarget.parent.y - 55);
         GuiManager.toolTip.startTimer(param1);
         param1.currentTarget.gotoAndStop("over");
         AJAudio.playHudBtnRollover();
      }
      
      private function charWindowOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
         param1.currentTarget.gotoAndStop("up");
      }
      
      private function onChatBalloonOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._booth.imageCont.chatBalloon.closeChatBtn.visible = true;
      }
      
      private function onChatBalloonOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._booth.imageCont.chatBalloon.closeChatBtn.visible = false;
      }
      
      private function onCloseBalloon(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._booth.imageCont.chatBalloon.visible = false;
      }
      
      private function onToggleBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/photobooth/toggleText");
         if(param1.currentTarget.currentFrameLabel == "on" || param1.currentTarget.currentFrameLabel == "startingOn")
         {
            param1.currentTarget.gotoAndPlay("off");
            this._booth.imageCont.msgTxt.visible = true;
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
            this._booth.imageCont.msgTxt.visible = false;
         }
      }
      
      private function onToggleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleBG.gotoAndStop("over");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("over");
         }
      }
      
      private function onToggleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleBG.gotoAndStop("up");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("up");
         }
      }
      
      private function onAvtDebugLoadBtn(param1:MouseEvent) : void
      {
         var _loc4_:Avatar = null;
         param1.stopPropagation();
         if(this._loadingSpiralAvt.visible)
         {
            return;
         }
         ++this._debugAvtIndex;
         var _loc2_:Array = AvatarSwitch.avatars;
         if(this._debugAvtIndex >= AvatarUtility.avatarTypes.length)
         {
            this._debugAvtIndex = 0;
         }
         var _loc3_:int = int(AvatarUtility.avatarTypes[this._debugAvtIndex]);
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.length)
         {
            if(_loc2_[_loc5_].avTypeId == _loc3_)
            {
               _loc4_ = _loc2_[_loc5_];
               break;
            }
            _loc5_++;
         }
         if(_loc4_ == null)
         {
            _loc4_ = AvatarUtility.creationAvatars[this._debugAvtIndex];
         }
         if(!Utility.isLand(_loc4_.enviroTypeFlag))
         {
            this.onAvtDebugLoadBtn(param1);
            return;
         }
         this.loadDebugAvatar(_loc4_);
      }
   }
}

