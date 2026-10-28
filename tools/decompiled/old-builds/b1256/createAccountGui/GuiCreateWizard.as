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
         viewAssets = param1;
         createAccountIlAvatar = param2;
      }
      
      override public function init(param1:MovieClip, param2:Object, param3:Boolean = true, param4:int = 1, param5:Array = null, param6:Boolean = true, param7:Boolean = false, param8:Boolean = true, param9:Boolean = false) : void
      {
         var _loc10_:Array = null;
         creationAssets = param2;
         chooseAnimalScreen = new GuiChooseAnimal(viewAssets,this,param8,param9);
         if(param8)
         {
            chooseAnimalScreen.init();
         }
         createANameScreen = new GuiCreateAName(viewAssets,this,param8,param9);
         createANameScreen.init(param8 ? viewAssets : createAccountIlAvatar,param8,param9);
         if(param8)
         {
            _loc10_ = new Array(chooseAnimalScreen,createANameScreen);
         }
         else
         {
            playerTagScreen = new GuiPlayerTagScreen(param8 ? viewAssets : createAccountIlAvatar,this);
            playerTagScreen.init();
            emailScreen = new GuiEmailScreen(param8 ? viewAssets : createAccountIlAvatar,this);
            emailScreen.init();
            _loc10_ = new Array(chooseAnimalScreen,createANameScreen,playerTagScreen,emailScreen);
         }
         super.init(param1,param2,param3,param4,_loc10_,param6,param7,param8);
      }
      
      override public function destroy() : void
      {
         chooseAnimalScreen.destroy();
         chooseAnimalScreen = null;
         createANameScreen.destroy();
         createANameScreen = null;
         if(playerTagScreen)
         {
            playerTagScreen.destroy();
            playerTagScreen = null;
         }
         if(emailScreen)
         {
            emailScreen.destroy();
            emailScreen = null;
         }
         super.destroy();
      }
   }
}

