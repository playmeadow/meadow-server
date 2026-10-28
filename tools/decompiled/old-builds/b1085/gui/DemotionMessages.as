package gui
{
   import avatar.AvatarSwitch;
   import avatar.AvatarXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.LoaderCache;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class DemotionMessages
   {
      
      private var _demotionMessage:MediaHelper;
      
      private var _newMemberPopup:MovieClip;
      
      private var _content:MovieClip;
      
      private var _idx:int;
      
      private var _gaIdx:int;
      
      private var _choose:SwitchManager;
      
      private var _currSound:Sound;
      
      private var _currSoundChannel:SoundChannel;
      
      private var _closeCallBack:Function;
      
      private var _roomVolume:Number;
      
      private var _hasChosen:Boolean;
      
      private var _wasMusicMuted:Boolean;
      
      public function DemotionMessages()
      {
         super();
      }
      
      public function init(param1:Function = null) : void
      {
         this._demotionMessage = new MediaHelper();
         this._demotionMessage.init(156,this.demotionCallback);
         this._closeCallBack = param1;
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         DarkenManager.unDarken(this._newMemberPopup);
         if(this._demotionMessage)
         {
            this._demotionMessage.destroy();
         }
         this._newMemberPopup.visible = false;
         this._newMemberPopup = null;
         this._content.visible = false;
         this._content = null;
         if(this._closeCallBack != null)
         {
            this._closeCallBack();
         }
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = null;
         }
         this._closeCallBack = null;
      }
      
      public function goToNextPage() : void
      {
         this.nextBtnHandler(null);
      }
      
      public function set hasChosen(param1:Boolean) : void
      {
         this._hasChosen = param1;
      }
      
      private function demotionCallback(param1:MovieClip) : void
      {
         this._newMemberPopup = param1;
         this._newMemberPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._newMemberPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         this._newMemberPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.demotionMouseDownHandler,false,0,true);
         GuiManager.guiLayer.addChild(this._newMemberPopup);
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(this._newMemberPopup);
         this._content = this._newMemberPopup.getChildAt(1)["c"];
         this._content.soundBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.soundBtnHandler,false,0,true);
         this._content.chooseBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.chooseBtnHandler,false,0,true);
         this._content.renewBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.joinBtnHandler,false,0,true);
         this._content.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.nextBtnHandler,false,0,true);
         this._content.noThanksBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.demotionCloseHandler,false,0,true);
         this._content.chooseBtn.visible = false;
         this._content.noThanksBtn.visible = false;
         this._idx = 1;
         this._gaIdx = 2;
         this._currSound = new Sound();
         this._currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (67 + this._idx) + ".mp3"));
         this.playSoundCallback();
      }
      
      private function playSoundCallback() : void
      {
         this._wasMusicMuted = SBAudio.isMusicMuted;
         if(!this._wasMusicMuted)
         {
            SBAudio.muteMusic();
         }
         this._currSoundChannel = this._currSound.play();
      }
      
      private function nextBtnHandler(param1:MouseEvent) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/#page" + this._gaIdx);
         var _loc2_:Boolean = AvatarSwitch.shouldChoose();
         ++this._gaIdx;
         ++this._idx;
         if(!this._hasChosen && !_loc2_ && this._idx > 2)
         {
            ++this._idx;
            _loc3_ = AvatarSwitch.avatars;
            _loc4_ = new Array();
            _loc8_ = AvatarSwitch.numNonMemberAvatars;
            _loc9_ = 0;
            while(_loc9_ < _loc3_.length)
            {
               if(_loc3_[_loc9_])
               {
                  if(!AvatarSwitch.isMemberOnlyAvatar(_loc9_))
                  {
                     _loc7_ = true;
                  }
               }
               else if(_loc9_ >= _loc8_ - 1)
               {
                  _loc7_ = true;
               }
               if(_loc7_)
               {
                  _loc7_ = false;
                  if(_loc4_[0] == null && Boolean(_loc3_[_loc9_]))
                  {
                     _loc4_[0] = _loc5_ = _loc9_;
                  }
                  else
                  {
                     _loc4_[1] = _loc6_ = _loc9_;
                  }
                  if(_loc4_[0] != null && _loc4_[1] != null)
                  {
                     break;
                  }
               }
               _loc9_++;
            }
            if(_loc4_[1] != null && Boolean(_loc3_[_loc6_]))
            {
               AvatarSwitch.availSlotFlags = 1 << AvatarXtCommManager.avSlotInfo[_loc3_[_loc5_].dbAvId].avInvId | 1 << AvatarXtCommManager.avSlotInfo[_loc3_[_loc6_].dbAvId].avInvId;
            }
            else
            {
               AvatarSwitch.availSlotFlags = 1 << AvatarXtCommManager.avSlotInfo[_loc3_[_loc5_].dbAvId].avInvId;
            }
            DarkenManager.showLoadingSpiral(true);
            this._content.nextBtn.visible = false;
            AvatarSwitch.chooseTwo(_loc4_,this.onAvatarChooseCallback);
            return;
         }
         if(this._idx == 3)
         {
            this._content.renewBtn.visible = false;
            this._content.nextBtn.visible = false;
            this._content.chooseBtn.visible = true;
         }
         if(this._idx == 4 && _loc2_)
         {
            this._content.chooseBtn.visible = false;
            this._content.nextBtn.visible = false;
            this._content.noThanksBtn.visible = true;
         }
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
         }
         this._currSound = new Sound();
         this._currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (67 + this._idx) + ".mp3"));
         this._currSoundChannel = this._currSound.play();
         this._content.gotoAndStop("p" + this._idx);
      }
      
      private function onAvatarChooseCallback(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
         }
         if(param1)
         {
            this._content.chooseBtn.visible = false;
            this._content.nextBtn.visible = false;
            this._content.noThanksBtn.visible = true;
            this._currSound = new Sound();
            this._currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (67 + this._idx) + ".mp3"));
            this._currSoundChannel = this._currSound.play();
            this._content.gotoAndStop("p" + this._idx);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(11233));
            this._content.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.nextBtnHandler);
            this._content.nextBtn.visible = true;
         }
      }
      
      private function joinBtnHandler(param1:MouseEvent) : void
      {
         var url:String;
         var request:URLRequest;
         var m:MouseEvent = param1;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/renew");
         m.stopPropagation();
         url = gMainFrame.clientInfo.websiteURL + "membership";
         request = new URLRequest(url);
         try
         {
            navigateToURL(request,"_blank");
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error with loading URL");
         }
      }
      
      private function chooseBtnHandler(param1:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/avatarChoose");
         param1.stopPropagation();
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
         }
         GuiManager.openAvatarChoose();
         this._content.chooseBtn.visible = false;
         this._content.renewBtn.visible = true;
         this._content.noThanksBtn.visible = true;
      }
      
      private function soundBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = this._currSound.play();
         }
         else
         {
            this._currSoundChannel = this._currSound.play();
         }
      }
      
      private function demotionMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function demotionCloseHandler(param1:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/page4_noThanks");
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = this._currSound.play();
         }
         else
         {
            this._currSoundChannel = this._currSound.play();
         }
         if(!this._wasMusicMuted)
         {
            SBAudio.unmuteMusic();
         }
         param1.stopPropagation();
         this.destroy();
      }
      
      private function removeListeners() : void
      {
         this._content.chooseBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.chooseBtnHandler);
         this._content.renewBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.joinBtnHandler);
         this._content.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.nextBtnHandler);
         this._content.noThanksBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.demotionCloseHandler);
         this._newMemberPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.demotionMouseDownHandler);
      }
   }
}

