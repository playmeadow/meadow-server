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
      
      public function init(closecallback:Function = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._closeCallback = closecallback;
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
      
      private function onMediaLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(img))
         {
            SBTracker.trackPageview("/game/play/popup/photobooth/enter");
            this._booth = MovieClip(img.getChildAt(0));
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
      
      private function positionAndDrawAvatarView(reInitView:Boolean = false) : void
      {
         var offset:Point = null;
         if(reInitView)
         {
            if(Boolean(this._currAvtView))
            {
               this._startingFrame = this._currAvtView.frame;
               if(Boolean(this._currAvtView.parent))
               {
                  this._booth.imageCont.charBox.removeChild(this._currAvtView);
               }
            }
            this._loadingSpiralAvt.setNewParent(this._booth.imageCont.charBox);
            this._loadingSpiralAvt.visible = true;
            this._currAvtView = new AvatarEditorView();
            this._currAvtView.init(AvatarManager.playerAvatar);
         }
         offset = AvatarUtility.getAvatarPhotoOffset(this._currAvtView.avTypeId);
         this._currAvtView.x = offset.x;
         this._currAvtView.y = offset.y;
         this._currAvtView.visible = false;
         this._currAvtView.playAnim(LayerAnim.AN_PHOTO,false,LayerAnim.PLAY_LOOP,this.onAvatarLoaded);
         this._currAvtView.scaleX = this.IMAGE_WIDTH / 1024;
         this._currAvtView.scaleY = this.IMAGE_HEIGHT / 768;
         this._booth.imageCont.charBox.addChild(this._currAvtView);
      }
      
      private function loadPetView() : void
      {
         var myPet:Object = null;
         var myPetList:Array = PetManager.myPetList;
         this._myPet = null;
         for(var i:int = 0; i < myPetList.length; i++)
         {
            if(myPetList[i].idx == PetManager.myActivePetInvId)
            {
               myPet = myPetList[i];
               if(!PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,myPet.type))
               {
                  break;
               }
               this._booth.posBtn.activateGrayState(false);
               this._myPet = new GuiPet(myPet.idx,myPet.lBits,myPet.uBits,myPet.eBits,myPet.type,myPet.name,this.onPetLoaded);
               break;
            }
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
      
      private function onTextClose(msg:String, code:String) : void
      {
         this._booth.textBtn.currTxt.text = msg;
         this._booth.imageCont.msgTxt.text = msg;
         this.setTextVisibility();
         SafeChatManager.closeSafeChat(this._booth.chatTree);
      }
      
      private function completeSaveAction() : void
      {
         DarkenManager.showLoadingSpiral(true,true);
         var bd:BitmapData = new BitmapData(1024,768);
         var scaleMatrix:Matrix = new Matrix(1024 / this.IMAGE_WIDTH,0,0,768 / this.IMAGE_HEIGHT,0,0);
         bd.draw(this._booth.imageCont,scaleMatrix,null,null,null,true);
         this._jpgEncoder = new JpegAsynchEncoder();
         this._jpgEncoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE,this.asyncEncodingComplete,false,0,true);
         this._jpgEncoder.addEventListener(ProgressEvent.PROGRESS,this.onEncodingProgress,false,0,true);
         this._jpgEncoder.PixelsPerIteration = 128;
         this._jpgEncoder.JPEGAsyncEncoder(100);
         this._jpgEncoder.encode(bd);
      }
      
      private function showHudAvt() : void
      {
         var avt:Avatar = AvatarManager.playerAvatar;
         if(Boolean(this._hudAvtView))
         {
            if(this._hudAvtView.parent == this._booth.char.charLayer)
            {
               this._booth.char.charLayer.removeChild(this._hudAvtView);
            }
            this._hudAvtView.destroy();
         }
         this._hudAvtView = new AvatarView();
         this._hudAvtView.init(avt);
         this._hudAvtView.playAnim(LayerAnim.AN_HUD_AVT,false,LayerAnim.PLAY_ONE_SHOT);
         var avatarOffset:Point = AvatarUtility.getAvatarHudPosition(this._hudAvtView.avTypeId);
         this._hudAvtView.x = avatarOffset.x;
         this._hudAvtView.y = avatarOffset.y;
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
      
      private function addPetToCorrectSpot(newIndex:int, isNewPet:Boolean = false) : void
      {
         var matrix:Matrix = null;
         if(newIndex > 3)
         {
            newIndex = 0;
         }
         var tempIndex:int = newIndex;
         if(isNewPet)
         {
            if(newIndex % 2 != 0)
            {
               tempIndex = newIndex - 1;
            }
         }
         switch(tempIndex)
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
               if(tempIndex == newIndex)
               {
                  break;
               }
            case 1:
               matrix = this._myPet.transform.matrix;
               matrix.scale(-1,1);
               this._myPet.transform.matrix = matrix;
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
               if(tempIndex == newIndex)
               {
                  break;
               }
            case 3:
               matrix = this._myPet.transform.matrix;
               matrix.scale(-1,1);
               this._myPet.transform.matrix = matrix;
         }
         this._petPosIndex = newIndex;
      }
      
      private function loadDebugAvatar(avt:Avatar) : void
      {
         if(Boolean(this._currAvtView))
         {
            this._startingFrame = this._currAvtView.frame;
            if(Boolean(this._currAvtView.parent))
            {
               this._booth.imageCont.charBox.removeChild(this._currAvtView);
            }
         }
         this._loadingSpiralAvt.setNewParent(this._booth.imageCont.charBox);
         this._loadingSpiralAvt.visible = true;
         this._currAvtView = new AvatarEditorView();
         this._currAvtView.init(avt);
         var offset:Point = AvatarUtility.getAvatarPhotoOffset(this._currAvtView.avTypeId);
         this._currAvtView.x = offset.x;
         this._currAvtView.y = offset.y;
         this._currAvtView.visible = false;
         this._currAvtView.playAnim(LayerAnim.AN_PHOTO,false,LayerAnim.PLAY_LOOP,this.onAvatarLoaded);
         this._currAvtView.scaleX = this.IMAGE_WIDTH / 1024;
         this._currAvtView.scaleY = this.IMAGE_HEIGHT / 768;
         this._booth.imageCont.charBox.addChild(this._currAvtView);
      }
      
      private function onAvatarLoaded(l:LayerAnim, id:int) : void
      {
         var matrix:Matrix = null;
         this._currAvtView.visible = true;
         this._currAvtView.pauseAnim(true);
         this._currAvtView.frame = this._startingFrame;
         this._loadingSpiralAvt.visible = false;
         if(this._flip)
         {
            matrix = this._currAvtView.transform.matrix;
            matrix.scale(-1,1);
            this._currAvtView.transform.matrix = matrix;
         }
         else if(this._booth.imageCont.avtShadow.scaleX < 0)
         {
            this._booth.imageCont.avtShadow.scaleX *= -1;
         }
      }
      
      private function onPetLoaded(content:MovieClip, guiPet:GuiPet) : void
      {
         var matrix:Matrix = null;
         this._myPet.scaleX = this._myPet.scaleY = 2;
         if(this._petPosIndex < 2)
         {
            matrix = this._myPet.transform.matrix;
            matrix.scale(-1,1);
            this._myPet.transform.matrix = matrix;
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
      
      private function onSaveImage(o:Object) : void
      {
         if(Boolean(o.status))
         {
            SBTracker.trackPageview("/game/play/popup/photobooth/imageSaved");
            DarkenManager.showLoadingSpiral(true);
            AvatarXtCommManager.sendAvatarPhotoTake(this.onPhotoGemsSpent);
            ++_nameSaveIndex;
         }
      }
      
      private function onPhotoGemsSpent(data:Object) : void
      {
         gMainFrame.clientInfo.gemCount = int(data[2]);
         DarkenManager.showLoadingSpiral(false);
         AJAudio.playShopCachingSound();
      }
      
      private function onSaveForGems(o:Object) : void
      {
         SBTracker.trackPageview("/game/play/popup/photobooth/saveForGems");
         if(Boolean(o.status))
         {
            DarkenManager.showLoadingSpiral(true);
            AvatarXtCommManager.sendAvatarPhotoTakeCheck(this.onGemsSpent);
         }
      }
      
      private function onGemsSpent(data:Object) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(data[2] >= 0)
         {
            this._booth.flash.playFlash(this.flashComplete);
         }
         else
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14788));
         }
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
      
      private function onLeftRightBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/leftRight");
         if(evt.currentTarget.name == "leftBtn")
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
         else if(evt.currentTarget.name == "rightBtn")
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
               this.onLeftRightBtn(evt);
               return;
            }
         }
         else if(!Utility.isLand(AvatarManager.playerAvatar.enviroTypeFlag))
         {
            this.onLeftRightBtn(evt);
            return;
         }
         this._booth.imageCont.backgroundCont.gotoAndStop(this._currBackgroundFrame);
      }
      
      private function onActionPoseBtn(evt:MouseEvent) : void
      {
         var matrix:Matrix = null;
         evt.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/poseBtn");
         if(Boolean(this._currAvtView))
         {
            matrix = this._currAvtView.transform.matrix;
            matrix.scale(-1,1);
            this._currAvtView.transform.matrix = matrix;
            this._flip = !this._flip;
            this._booth.imageCont.avtShadow.scaleX *= -1;
         }
      }
      
      private function onActionPoseOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14675),evt.currentTarget.x + evt.currentTarget.parent.x,evt.currentTarget.y + evt.currentTarget.parent.y - 27);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onPetPosBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/petPose");
         if(Boolean(this._myPet))
         {
            this.addPetToCorrectSpot(this._petPosIndex + 1);
         }
      }
      
      private function onPetPosOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14676),evt.currentTarget.x + evt.currentTarget.parent.x,evt.currentTarget.y + evt.currentTarget.parent.y - 27);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function onTextBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!this._booth.chatTree.visible)
         {
            SafeChatManager.openSafeChat(false,this._booth.chatTree);
         }
         else
         {
            SafeChatManager.closeSafeChat(this._booth.chatTree);
         }
      }
      
      private function onSaveBtn(evt:MouseEvent) : void
      {
         SBTracker.trackPageview("/game/play/popup/photobooth/save");
         evt.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14789,50),true,this.onSaveForGems);
      }
      
      private function onSaveOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14677),evt.currentTarget.x + evt.currentTarget.parent.x,evt.currentTarget.y + evt.currentTarget.parent.y - 41);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onOutHandler(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onEncodingProgress(event:ProgressEvent) : void
      {
         DarkenManager.updateLoadingSpiralPercentage(Math.round(event.bytesLoaded / event.bytesTotal * 100) + "%");
      }
      
      private function asyncEncodingComplete(event:JPEGAsyncCompleteEvent) : void
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
      
      private function onCustomize(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.openAvatarEditor(this.onAvatarEditorClose);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function charWindowOverHandler(evt:MouseEvent) : void
      {
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14673),evt.currentTarget.x + evt.currentTarget.parent.x,evt.currentTarget.y + evt.currentTarget.parent.y - 55);
         GuiManager.toolTip.startTimer(evt);
         evt.currentTarget.gotoAndStop("over");
         AJAudio.playHudBtnRollover();
      }
      
      private function charWindowOutHandler(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
         evt.currentTarget.gotoAndStop("up");
      }
      
      private function onChatBalloonOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._booth.imageCont.chatBalloon.closeChatBtn.visible = true;
      }
      
      private function onChatBalloonOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._booth.imageCont.chatBalloon.closeChatBtn.visible = false;
      }
      
      private function onCloseBalloon(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._booth.imageCont.chatBalloon.visible = false;
      }
      
      private function onToggleBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/photobooth/toggleText");
         if(evt.currentTarget.currentFrameLabel == "on" || evt.currentTarget.currentFrameLabel == "startingOn")
         {
            evt.currentTarget.gotoAndPlay("off");
            this._booth.imageCont.msgTxt.visible = true;
         }
         else
         {
            evt.currentTarget.gotoAndPlay("on");
            this._booth.imageCont.msgTxt.visible = false;
         }
      }
      
      private function onToggleOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.toggleBG.currentFrameLabel != "over")
         {
            evt.currentTarget.toggleBG.gotoAndStop("over");
         }
         if(evt.currentTarget.toggleKnob.currentFrameLabel != "over")
         {
            evt.currentTarget.toggleKnob.gotoAndStop("over");
         }
      }
      
      private function onToggleOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.toggleBG.currentFrameLabel != "up")
         {
            evt.currentTarget.toggleBG.gotoAndStop("up");
         }
         if(evt.currentTarget.toggleKnob.currentFrameLabel != "up")
         {
            evt.currentTarget.toggleKnob.gotoAndStop("up");
         }
      }
      
      private function onAvtDebugLoadBtn(evt:MouseEvent) : void
      {
         var avatarToLoad:Avatar = null;
         evt.stopPropagation();
         if(this._loadingSpiralAvt.visible)
         {
            return;
         }
         ++this._debugAvtIndex;
         var myAvatar:Array = AvatarSwitch.avatars;
         if(this._debugAvtIndex >= AvatarUtility.avatarTypes.length)
         {
            this._debugAvtIndex = 0;
         }
         var currAvTypeId:int = int(AvatarUtility.avatarTypes[this._debugAvtIndex]);
         for(var i:int = 0; i < myAvatar.length; i++)
         {
            if(myAvatar[i].avTypeId == currAvTypeId)
            {
               avatarToLoad = myAvatar[i];
               break;
            }
         }
         if(avatarToLoad == null)
         {
            avatarToLoad = AvatarUtility.creationAvatars[this._debugAvtIndex];
         }
         if(!Utility.isLand(avatarToLoad.enviroTypeFlag))
         {
            this.onAvtDebugLoadBtn(evt);
            return;
         }
         this.loadDebugAvatar(avatarToLoad);
      }
   }
}

