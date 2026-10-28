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
         _createAccountIlAvatar = null;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1892,onAvatarCarouselLoaded,{
            "isChoosingOceanAvatars":param1,
            "isChoosing":param2,
            "avatarTypeToShow":param3,
            "skipToNameScreen":param4,
            "isFastPass":param5
         });
      }
      
      public function initFromAccountCreation(param1:MovieClip, param2:Object) : void
      {
         _avatarAssets = param1;
         _createAccountIlAvatar = param2;
         init(false,null);
      }
      
      public function destroy() : void
      {
         creationWiz.destroy();
         creationWiz = null;
         removeChild(_avatarAssets);
         _avatarAssets = null;
      }
      
      public function get currAvatarImage() : MovieClip
      {
         return creationWiz.chooseAnimalScreen.currAvatarImage;
      }
      
      public function get currAvatar() : Avatar
      {
         return creationWiz.chooseAnimalScreen.currAvatar;
      }
      
      public function get currBG() : String
      {
         return creationWiz.chooseAnimalScreen.currBG;
      }
      
      public function get currType() : int
      {
         return creationWiz.chooseAnimalScreen.currType;
      }
      
      public function get currCustomAvId() : int
      {
         return creationWiz.chooseAnimalScreen.currCustomAvId;
      }
      
      public function get hasEnoughGems() : Boolean
      {
         return creationWiz.chooseAnimalScreen.hasEnoughGems;
      }
      
      public function get currAvatarCost() : int
      {
         return creationWiz.chooseAnimalScreen.currAvatarCost;
      }
      
      public function get currAvatarName() : String
      {
         return creationWiz.chooseAnimalScreen.currAvatarName;
      }
      
      public function get isCreatingWithoutChoosing() : Boolean
      {
         return creationWiz.chooseAnimalScreen.isCreatingWithoutChoosing;
      }
      
      public function get isDiamondAvatar() : Boolean
      {
         return creationWiz.chooseAnimalScreen.isDiamondAvatar;
      }
      
      public function get avatarDiamondDefId() : int
      {
         return creationWiz.chooseAnimalScreen.avatarDiamondDefId;
      }
      
      public function get currencyType() : int
      {
         return creationWiz.chooseAnimalScreen.currencyType;
      }
      
      public function get currEmailAddress() : String
      {
         return creationWiz.emailScreen.currEmail;
      }
      
      public function get emailValidationCallback() : Function
      {
         return creationWiz.emailScreen.emailValidCallback;
      }
      
      public function get currEmailSoFar() : String
      {
         return creationWiz.emailScreen.currEmail;
      }
      
      public function destroyReloadedItems() : void
      {
         creationWiz.chooseAnimalScreen.destroyReloadedItems();
      }
      
      public function loadNameLists() : void
      {
         creationWiz.createANameScreen.loadNameLists();
      }
      
      private function onAvatarCarouselLoaded(param1:MovieClip) : void
      {
         _avatarAssets = MovieClip(param1.getChildAt(0));
         if(param1.passback.isFastPass)
         {
            LoadProgress.show(false);
            if(CreateAccountGui.vo1Sound == null)
            {
               CreateAccountGui.loadCreationVoSounds(init,{
                  "isInWorld":true,
                  "requiredParams":param1.passback
               });
            }
         }
         else
         {
            init(true,param1.passback);
         }
      }
      
      private function init(param1:Boolean, param2:Object) : void
      {
         var _loc3_:TextField = null;
         addChild(_avatarAssets);
         creationWiz = new GuiCreateWizard(_avatarAssets,_createAccountIlAvatar);
         creationWiz.init(_avatarAssets,this,false,1,null,true,false,param1,param2 ? param2.isFastPass : null);
         _avatarAssets.addEventListener("Localization",onFrameCompleteEvent,false,0,true);
         notifyPopup = _avatarAssets.oopsPopup;
         notifyPopup.notifyTxt = _avatarAssets.oopsPopup.bodyTxtOops.oops_txt;
         notifyPopup.titleTxt = _avatarAssets.oopsPopup.oops_title_txt;
         notifyPopup.bx.addEventListener("mouseDown",notifyPopupBxHandler,false,0,true);
         notifyPopup.visible = false;
         if(!param1)
         {
            tipsPopup = _avatarAssets.tipsPopup;
            tipsPopup.bx.addEventListener("mouseDown",tipsPopupBxHandler,false,0,true);
            _loc3_ = tipsPopup.tips_pp_txt;
            _loc3_.htmlText = _loc3_.text.replace("Privacy Policy","<a href=\'http://www.animaljam.com/privacy\' target=\'_blank\'><u>Privacy Policy</u></a>");
            playBtn = _avatarAssets.play_btn;
            playBtn.addEventListener("mouseDown",onPlayBtn,false,0,true);
         }
         else
         {
            buyBtnRed = _avatarAssets.buy_btn_red;
            buyBtnRed.addEventListener("mouseDown",onBuyBtn,false,0,true);
            buyBtnGreen = _avatarAssets.buy_btn_green;
            buyBtnGreen.addEventListener("mouseDown",onBuyBtn,false,0,true);
            buyBtnDiamondRed = _avatarAssets.diamond_buy_btn_red;
            buyBtnDiamondRed.addEventListener("mouseDown",onBuyBtn,false,0,true);
            buyBtnDiamondGreen = _avatarAssets.diamond_buy_btn_green;
            buyBtnDiamondGreen.addEventListener("mouseDown",onBuyBtn,false,0,true);
            closeBtn = _avatarAssets.bx;
            playBtn = _avatarAssets.play_btn;
            if(param2.isFastPass)
            {
               playBtn.addEventListener("mouseDown",onPlayBtn,false,0,true);
               closeBtn.visible = false;
            }
            else
            {
               closeBtn.addEventListener("mouseDown",onClose,false,0,true);
               playBtn.visible = false;
            }
         }
         nextBtn = _avatarAssets.next_btn;
         nextBtn.addEventListener("mouseDown",onNextBtn,false,0,true);
         backBtn = _avatarAssets.back_btn;
         backBtn.addEventListener("mouseDown",onBackBtn,false,0,true);
         _avatarAssets.addEventListener("mouseDown",onPopupDown,false,0,true);
         if(param1)
         {
            creationWiz.step = 1;
            creationWiz.chooseAnimalScreen.setup(param2.isChoosingOceanAvatars,param2.isChoosing,param2.avatarTypeToShow,param2.skipToNameScreen,param2.isFastPass);
         }
      }
      
      private function onFrameCompleteEvent(param1:Event = null) : void
      {
         if(creationWiz)
         {
            creationWiz.updateCurrScreen();
         }
      }
      
      private function notifyPopupBxHandler(param1:MouseEvent) : void
      {
         notifyPopup.visible = false;
      }
      
      private function tipsPopupBxHandler(param1:MouseEvent) : void
      {
         tipsPopup.visible = false;
      }
      
      private function onNextBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         creationWiz.next();
      }
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         creationWiz.prev();
      }
      
      private function onPlayBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         creationWiz.onPlay();
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         creationWiz.onPlay();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         creationWiz.onClose();
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

