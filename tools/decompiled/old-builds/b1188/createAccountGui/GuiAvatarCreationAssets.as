package createAccountGui
{
   import avatar.Avatar;
   import createAccountFlow.CreateAccountGui;
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
      
      private var buyBtnDiamondRed:MovieClip;
      
      private var buyBtnDiamondGreen:MovieClip;
      
      private var closeBtn:MovieClip;
      
      private var _avatarAssets:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _createAccountIlAvatar:Object;
      
      public function GuiAvatarCreationAssets()
      {
         super();
      }
      
      public function initFromWorld(param1:Boolean, param2:Boolean, param3:int = -1, param4:Boolean = false, param5:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._createAccountIlAvatar = null;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(1892,this.onAvatarCarouselLoaded,{
            "isChoosingOceanAvatars":param1,
            "isChoosing":param2,
            "avatarTypeToShow":param3,
            "skipToNameScreen":param4,
            "isFastPass":param5
         });
      }
      
      public function initFromAccountCreation(param1:MovieClip, param2:Object) : void
      {
         this._avatarAssets = param1;
         this._createAccountIlAvatar = param2;
         this.init(false,null);
      }
      
      public function destroy() : void
      {
         this.creationWiz.destroy();
         this.creationWiz = null;
         removeChild(this._avatarAssets);
         this._avatarAssets = null;
      }
      
      public function get currAvatarImage() : MovieClip
      {
         return this.creationWiz.chooseAnimalScreen.currAvatarImage;
      }
      
      public function get currAvatar() : Avatar
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
      
      public function get currCustomAvId() : int
      {
         return this.creationWiz.chooseAnimalScreen.currCustomAvId;
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
      
      public function get isDiamondAvatar() : Boolean
      {
         return this.creationWiz.chooseAnimalScreen.isDiamondAvatar;
      }
      
      public function get avatarDiamondDefId() : int
      {
         return this.creationWiz.chooseAnimalScreen.avatarDiamondDefId;
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
      
      private function onAvatarCarouselLoaded(param1:MovieClip) : void
      {
         this._avatarAssets = MovieClip(param1.getChildAt(0));
         if(param1.passback.isFastPass)
         {
            LoadProgress.show(false);
            if(CreateAccountGui.vo1Sound == null)
            {
               CreateAccountGui.loadCreationVoSounds(this.init,{
                  "isInWorld":true,
                  "requiredParams":param1.passback
               });
            }
         }
         else
         {
            this.init(true,param1.passback);
         }
      }
      
      private function init(param1:Boolean, param2:Object) : void
      {
         var _loc3_:TextField = null;
         addChild(this._avatarAssets);
         this.creationWiz = new GuiCreateWizard(this._avatarAssets,this._createAccountIlAvatar);
         this.creationWiz.init(this._avatarAssets,this,false,1,null,true,false,param1,param2 ? Boolean(param2.isFastPass) : Boolean(null));
         this._avatarAssets.addEventListener("Localization",this.onFrameCompleteEvent,false,0,true);
         this.notifyPopup = this._avatarAssets.oopsPopup;
         this.notifyPopup.notifyTxt = this._avatarAssets.oopsPopup.bodyTxtOops.oops_txt;
         this.notifyPopup.titleTxt = this._avatarAssets.oopsPopup.oops_title_txt;
         this.notifyPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.notifyPopupBxHandler,false,0,true);
         this.notifyPopup.visible = false;
         if(!param1)
         {
            this.tipsPopup = this._avatarAssets.tipsPopup;
            this.tipsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.tipsPopupBxHandler,false,0,true);
            _loc3_ = this.tipsPopup.tips_pp_txt;
            _loc3_.htmlText = _loc3_.text.replace("Privacy Policy","<a href=\'http://www.animaljam.com/privacy\' target=\'_blank\'><u>Privacy Policy</u></a>");
            this.playBtn = this._avatarAssets.play_btn;
            this.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
         }
         else
         {
            this.buyBtnRed = this._avatarAssets.buy_btn_red;
            this.buyBtnRed.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBtn,false,0,true);
            this.buyBtnGreen = this._avatarAssets.buy_btn_green;
            this.buyBtnGreen.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBtn,false,0,true);
            this.buyBtnDiamondRed = this._avatarAssets.diamond_buy_btn_red;
            this.buyBtnDiamondRed.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBtn,false,0,true);
            this.buyBtnDiamondGreen = this._avatarAssets.diamond_buy_btn_green;
            this.buyBtnDiamondGreen.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBtn,false,0,true);
            this.closeBtn = this._avatarAssets.bx;
            this.playBtn = this._avatarAssets.play_btn;
            if(param2.isFastPass)
            {
               this.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
               this.closeBtn.visible = false;
            }
            else
            {
               this.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
               this.playBtn.visible = false;
            }
         }
         this.nextBtn = this._avatarAssets.next_btn;
         this.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onNextBtn,false,0,true);
         this.backBtn = this._avatarAssets.back_btn;
         this.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBackBtn,false,0,true);
         this._avatarAssets.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
         if(param1)
         {
            this.creationWiz.step = 1;
            this.creationWiz.chooseAnimalScreen.setup(param2.isChoosingOceanAvatars,param2.isChoosing,param2.avatarTypeToShow,param2.skipToNameScreen,param2.isFastPass);
         }
      }
      
      private function onFrameCompleteEvent(param1:Event = null) : void
      {
         if(this.creationWiz)
         {
            this.creationWiz.updateCurrScreen();
         }
      }
      
      private function notifyPopupBxHandler(param1:MouseEvent) : void
      {
         this.notifyPopup.visible = false;
      }
      
      private function tipsPopupBxHandler(param1:MouseEvent) : void
      {
         this.tipsPopup.visible = false;
      }
      
      private function onNextBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.next();
      }
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.prev();
      }
      
      private function onPlayBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.onPlay();
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.onPlay();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.onClose();
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

