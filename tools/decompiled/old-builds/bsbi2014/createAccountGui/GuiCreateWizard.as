package createAccountGui
{
   import com.sbi.popup.SBWizard;
   import flash.display.MovieClip;
   
   public class GuiCreateWizard extends SBWizard
   {
      
      public const SCREENS_LENGTH:int = 2;
      
      public var playerTagScreen:GuiPlayerTagScreen;
      
      public var emailScreen:GuiEmailScreen;
      
      public var viewAssets:Object;
      
      public var chooseAnimalScreen:GuiChooseAnimal;
      
      public var createANameScreen:GuiCreateAName;
      
      public var createAccountIlAvatar:Object;
      
      public function GuiCreateWizard(view:Object, initCreateAccountIlAvatar:Object)
      {
         super();
         this.viewAssets = view;
         this.createAccountIlAvatar = initCreateAccountIlAvatar;
      }
      
      override public function init(initWizClip:MovieClip, initGuiAvatarAssets:Object, initVisible:Boolean = true, initStep:int = 1, initScreens:Array = null, initEnabled:Boolean = true, useSeparateScreen:Boolean = false, isInWorld:Boolean = true) : void
      {
         var screens:Array = null;
         creationAssets = initGuiAvatarAssets;
         this.chooseAnimalScreen = new GuiChooseAnimal(this.viewAssets,this,isInWorld);
         if(isInWorld)
         {
            this.chooseAnimalScreen.init();
         }
         this.createANameScreen = new GuiCreateAName(this.viewAssets,this,isInWorld);
         this.createANameScreen.init(isInWorld ? this.viewAssets : this.createAccountIlAvatar,isInWorld);
         if(isInWorld)
         {
            screens = new Array(this.chooseAnimalScreen,this.createANameScreen);
         }
         else
         {
            this.playerTagScreen = new GuiPlayerTagScreen(isInWorld ? this.viewAssets : this.createAccountIlAvatar,this);
            this.playerTagScreen.init();
            this.emailScreen = new GuiEmailScreen(isInWorld ? this.viewAssets : this.createAccountIlAvatar,this);
            this.emailScreen.init();
            screens = new Array(this.chooseAnimalScreen,this.createANameScreen,this.playerTagScreen,this.emailScreen);
         }
         super.init(initWizClip,initGuiAvatarAssets,initVisible,initStep,screens,initEnabled,useSeparateScreen,isInWorld);
      }
      
      override public function destroy() : void
      {
         this.chooseAnimalScreen.destroy();
         this.chooseAnimalScreen = null;
         this.createANameScreen.destroy();
         this.createANameScreen = null;
         if(Boolean(this.playerTagScreen))
         {
            this.playerTagScreen.destroy();
            this.playerTagScreen = null;
         }
         if(Boolean(this.emailScreen))
         {
            this.emailScreen.destroy();
            this.emailScreen = null;
         }
         super.destroy();
      }
   }
}

