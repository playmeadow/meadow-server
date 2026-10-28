package createAccountGui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import loader.MediaHelper;
   
   public class GuiAvatarCreationAssets extends Sprite
   {
      
      public var creationWiz:GuiCreateWizard;
      
      public var notifyPopup:MovieClip;
      
      public var tipsPopup:MovieClip;
      
      private var nextBtn:MovieClip;
      
      private var backBtn:MovieClip;
      
      private var playBtn:MovieClip;
      
      private var buyBtnRed:MovieClip;
      
      private var buyBtnGreen:MovieClip;
      
      private var closeBtn:MovieClip;
      
      private var _avatarAssets:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _createAccountIlAvatar:Object;
      
      public function GuiAvatarCreationAssets()
      {
         super();
      }
      
      public function initFromWorld(isChoosingOceanAvatars:Boolean, isChoosing:Boolean, avatarTypeToShow:int = -1, skipToNameScreen:Boolean = false, currencyType:int = 0, specialValue:int = -1) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._createAccountIlAvatar = null;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(1892,this.onAvatarCarouselLoaded,{
            "isChoosingOceanAvatars":isChoosingOceanAvatars,
            "isChoosing":isChoosing,
            "avatarTypeToShow":avatarTypeToShow,
            "skipToNameScreen":skipToNameScreen,
            "currencyType":currencyType,
            "specialValue":specialValue
         });
      }
      
      public function initFromAccountCreation(assetMC:MovieClip, createAccountIlAvatar:Object) : void
      {
         this._avatarAssets = assetMC;
         this._createAccountIlAvatar = createAccountIlAvatar;
         this.init(false,null);
      }
      
      public function destroy() : void
      {
         this.creationWiz.destroy();
         this.creationWiz = null;
         removeChild(this._avatarAssets);
         this._avatarAssets = null;
      }
      
      public function get currAvatar() : MovieClip
      {
         return this.creationWiz.chooseAnimalScreen.currAvatar;
      }
      
      public function get currBG() : String
      {
         return this.creationWiz.chooseAnimalScreen.currBG;
      }
      
      public function get currType() : int
      {
         return this.creationWiz.chooseAnimalScreen.currType;
      }
      
      public function get hasEnoughGems() : Boolean
      {
         return this.creationWiz.chooseAnimalScreen.hasEnoughGems;
      }
      
      public function get currAvatarCost() : int
      {
         return this.creationWiz.chooseAnimalScreen.currAvatarCost;
      }
      
      public function get currAvatarName() : String
      {
         return this.creationWiz.chooseAnimalScreen.currAvatarName;
      }
      
      public function get isCreatingWithoutChoosing() : Boolean
      {
         return this.creationWiz.chooseAnimalScreen.isCreatingWithoutChoosing;
      }
      
      public function get currencyType() : int
      {
         return this.creationWiz.chooseAnimalScreen.currencyType;
      }
      
      public function get currEmailAddress() : String
      {
         return this.creationWiz.emailScreen.currEmail;
      }
      
      public function get emailValidationCallback() : Function
      {
         return this.creationWiz.emailScreen.emailValidCallback;
      }
      
      public function get currEmailSoFar() : String
      {
         return this.creationWiz.emailScreen.currEmail;
      }
      
      public function destroyReloadedItems() : void
      {
         this.creationWiz.chooseAnimalScreen.destroyReloadedItems();
      }
      
      public function loadNameLists() : void
      {
         this.creationWiz.createANameScreen.loadNameLists();
      }
      
      private function onAvatarCarouselLoaded(mc:MovieClip) : void
      {
         this._avatarAssets = MovieClip(mc.getChildAt(0));
         this.init(true,mc.passback);
      }
      
      private function init(isInWorld:Boolean, requiredParams:Object) : void
      {
         var tipsPPLinkTxt:TextField = null;
         addChild(this._avatarAssets);
         this._avatarAssets.addEventListener("Localization",this.onFrameCompleteEvent,false,0,true);
         this.notifyPopup = this._avatarAssets.oopsPopup;
         this.notifyPopup.notifyTxt = this._avatarAssets.oopsPopup.bodyTxtOops.oops_txt;
         this.notifyPopup.titleTxt = this._avatarAssets.oopsPopup.oops_title_txt;
         this.notifyPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.notifyPopupBxHandler,false,0,true);
         this.notifyPopup.visible = false;
         if(!isInWorld)
         {
            this.tipsPopup = this._avatarAssets.tipsPopup;
            this.tipsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.tipsPopupBxHandler,false,0,true);
            tipsPPLinkTxt = this.tipsPopup.tips_pp_txt;
            tipsPPLinkTxt.htmlText = tipsPPLinkTxt.text.replace("Privacy Policy","<a href=\'http://www.animaljam.com/privacy\' target=\'_blank\'><u>Privacy Policy</u></a>");
            this.playBtn = this._avatarAssets.play_btn;
            this.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
         }
         else
         {
            this.buyBtnRed = this._avatarAssets.buy_btn_red;
            this.buyBtnRed.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBtn,false,0,true);
            this.buyBtnGreen = this._avatarAssets.buy_btn_green;
            this.buyBtnGreen.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBtn,false,0,true);
            this.closeBtn = this._avatarAssets.bx;
            this.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         this.nextBtn = this._avatarAssets.next_btn;
         this.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onNextBtn,false,0,true);
         this.backBtn = this._avatarAssets.back_btn;
         this.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBackBtn,false,0,true);
         this._avatarAssets.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
         this.creationWiz = new GuiCreateWizard(this._avatarAssets,this._createAccountIlAvatar);
         this.creationWiz.init(this._avatarAssets,this,false,1,null,true,false,isInWorld);
         if(isInWorld)
         {
            this.creationWiz.step = 1;
            this.creationWiz.chooseAnimalScreen.setup(requiredParams.isChoosingOceanAvatars,requiredParams.isChoosing,requiredParams.avatarTypeToShow,requiredParams.skipToNameScreen,requiredParams.currencyType,requiredParams.specialValue);
         }
      }
      
      private function onFrameCompleteEvent(evt:Event = null) : void
      {
         if(Boolean(this.creationWiz))
         {
            this.creationWiz.updateCurrScreen();
         }
      }
      
      private function notifyPopupBxHandler(m:MouseEvent) : void
      {
         this.notifyPopup.visible = false;
      }
      
      private function tipsPopupBxHandler(m:MouseEvent) : void
      {
         this.tipsPopup.visible = false;
      }
      
      private function onNextBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.creationWiz.next();
      }
      
      private function onBackBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.creationWiz.prev();
      }
      
      private function onPlayBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.creationWiz.onPlay();
      }
      
      private function onBuyBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.creationWiz.onPlay();
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.creationWiz.onClose();
      }
      
      private function onPopupDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
   }
}

