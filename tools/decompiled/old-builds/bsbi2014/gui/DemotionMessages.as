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
      
      private var _startingIndex:int;
      
      public function DemotionMessages()
      {
         super();
      }
      
      public function init(initCloseCallback:Function = null) : void
      {
         this._demotionMessage = new MediaHelper();
         this._demotionMessage.init(156,this.demotionCallback);
         this._closeCallBack = initCloseCallback;
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         DarkenManager.unDarken(this._newMemberPopup);
         if(Boolean(this._demotionMessage))
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
         if(Boolean(this._currSoundChannel))
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
      
      public function set hasChosen(value:Boolean) : void
      {
         this._hasChosen = value;
      }
      
      private function demotionCallback(img:MovieClip) : void
      {
         this._newMemberPopup = img;
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
         switch(LocalizationManager.currentLanguage)
         {
            case LocalizationManager.LANG_ENG:
               this._startingIndex = 67;
               break;
            case LocalizationManager.LANG_SPA:
               this._startingIndex = 676;
               break;
            case LocalizationManager.LANG_POR:
               this._startingIndex = 631;
               break;
            case LocalizationManager.LANG_FRE:
               this._startingIndex = 626;
               break;
            case LocalizationManager.LANG_DE:
               this._startingIndex = 621;
               break;
            default:
               this._startingIndex = 67;
         }
         this._idx = 1;
         this._gaIdx = 2;
         this._currSound = new Sound();
         this._currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (this._startingIndex + this._idx) + ".mp3"));
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
      
      private function nextBtnHandler(m:MouseEvent) : void
      {
         var avatars:Array = null;
         var avatarsChosen:Array = null;
         var slot1:int = 0;
         var slot2:int = 0;
         var shouldAdd:Boolean = false;
         var numNonMemberAvatars:int = 0;
         var i:int = 0;
         if(Boolean(m))
         {
            m.stopPropagation();
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/#page" + this._gaIdx);
         var shouldChoose:Boolean = AvatarSwitch.shouldChoose();
         ++this._gaIdx;
         ++this._idx;
         if(!this._hasChosen && !shouldChoose && this._idx > 2)
         {
            ++this._idx;
            avatars = AvatarSwitch.avatars;
            avatarsChosen = new Array();
            numNonMemberAvatars = AvatarSwitch.numNonMemberAvatars;
            for(i = 0; i < avatars.length; i++)
            {
               if(Boolean(avatars[i]))
               {
                  if(!AvatarSwitch.isMemberOnlyAvatar(i))
                  {
                     shouldAdd = true;
                  }
               }
               else if(i >= numNonMemberAvatars - 1)
               {
                  shouldAdd = true;
               }
               if(shouldAdd)
               {
                  shouldAdd = false;
                  if(avatarsChosen[0] == null && Boolean(avatars[i]))
                  {
                     avatarsChosen[0] = slot1 = i;
                  }
                  else
                  {
                     avatarsChosen[1] = slot2 = i;
                  }
                  if(avatarsChosen[0] != null && avatarsChosen[1] != null)
                  {
                     break;
                  }
               }
            }
            if(avatarsChosen[1] != null && Boolean(avatars[slot2]))
            {
               AvatarSwitch.availSlotFlags = 1 << AvatarXtCommManager.avSlotInfo[avatars[slot1].perUserAvId].avInvId | 1 << AvatarXtCommManager.avSlotInfo[avatars[slot2].perUserAvId].avInvId;
            }
            else
            {
               AvatarSwitch.availSlotFlags = 1 << AvatarXtCommManager.avSlotInfo[avatars[slot1].perUserAvId].avInvId;
            }
            DarkenManager.showLoadingSpiral(true);
            this._content.nextBtn.visible = false;
            AvatarSwitch.chooseTwo(avatarsChosen,this.onAvatarChooseCallback);
            return;
         }
         if(this._idx == 3)
         {
            this._content.renewBtn.visible = false;
            this._content.nextBtn.visible = false;
            this._content.chooseBtn.visible = true;
         }
         if(this._idx == 4 && shouldChoose)
         {
            this._content.chooseBtn.visible = false;
            this._content.nextBtn.visible = false;
            this._content.noThanksBtn.visible = true;
         }
         if(Boolean(this._currSoundChannel))
         {
            this._currSoundChannel.stop();
         }
         this._currSound = new Sound();
         this._currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (this._startingIndex + this._idx) + ".mp3"));
         this._currSoundChannel = this._currSound.play();
         this._content.gotoAndStop("p" + this._idx);
      }
      
      private function onAvatarChooseCallback(success:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(this._currSoundChannel))
         {
            this._currSoundChannel.stop();
         }
         if(success)
         {
            this._content.chooseBtn.visible = false;
            this._content.nextBtn.visible = false;
            this._content.noThanksBtn.visible = true;
            this._currSound = new Sound();
            this._currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (this._startingIndex + this._idx) + ".mp3"));
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
      
      private function joinBtnHandler(m:MouseEvent) : void
      {
         var url:String;
         var request:URLRequest;
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
      
      private function chooseBtnHandler(m:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/avatarChoose");
         m.stopPropagation();
         if(Boolean(this._currSoundChannel))
         {
            this._currSoundChannel.stop();
         }
         GuiManager.openAvatarChoose();
         this._content.chooseBtn.visible = false;
         this._content.renewBtn.visible = true;
         this._content.noThanksBtn.visible = true;
      }
      
      private function soundBtnHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(Boolean(this._currSoundChannel))
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = this._currSound.play();
         }
         else
         {
            this._currSoundChannel = this._currSound.play();
         }
      }
      
      private function demotionMouseDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
      }
      
      private function demotionCloseHandler(m:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/page4_noThanks");
         if(Boolean(this._currSoundChannel))
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
         m.stopPropagation();
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

