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
      
      public function GuiCreateWizard(param1:Object, param2:Object)
      {
         super();
         this.viewAssets = param1;
         this.createAccountIlAvatar = param2;
      }
      
      override public function init(param1:MovieClip, param2:Object, param3:Boolean = true, param4:int = 1, param5:Array = null, param6:Boolean = true, param7:Boolean = false, param8:Boolean = true, param9:Boolean = false) : void
      {
         var _loc10_:Array = null;
         creationAssets = param2;
         this.chooseAnimalScreen = new GuiChooseAnimal(this.viewAssets,this,param8,param9);
         if(param8)
         {
            this.chooseAnimalScreen.init();
         }
         this.createANameScreen = new GuiCreateAName(this.viewAssets,this,param8,param9);
         this.createANameScreen.init(param8 ? this.viewAssets : this.createAccountIlAvatar,param8,param9);
         if(param8)
         {
            _loc10_ = new Array(this.chooseAnimalScreen,this.createANameScreen);
         }
         else
         {
            this.playerTagScreen = new GuiPlayerTagScreen(param8 ? this.viewAssets : this.createAccountIlAvatar,this);
            this.playerTagScreen.init();
            this.emailScreen = new GuiEmailScreen(param8 ? this.viewAssets : this.createAccountIlAvatar,this);
            this.emailScreen.init();
            _loc10_ = new Array(this.chooseAnimalScreen,this.createANameScreen,this.playerTagScreen,this.emailScreen);
         }
         super.init(param1,param2,param3,param4,_loc10_,param6,param7,param8);
      }
      
      override public function destroy() : void
      {
         this.chooseAnimalScreen.destroy();
         this.chooseAnimalScreen = null;
         this.createANameScreen.destroy();
         this.createANameScreen = null;
         if(this.playerTagScreen)
         {
            this.playerTagScreen.destroy();
            this.playerTagScreen = null;
         }
         if(this.emailScreen)
         {
            this.emailScreen.destroy();
            this.emailScreen = null;
         }
         super.destroy();
      }
   }
}

