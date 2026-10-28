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
      
      public var rulesScreen:GuiRulesScreen;
      
      public function GuiCreateWizard(param1:Object)
      {
         super();
         this.viewAssets = param1;
      }
      
      override public function init(param1:MovieClip, param2:Boolean = true, param3:int = 0, param4:Array = null, param5:Boolean = true, param6:Boolean = false, param7:Boolean = true) : void
      {
         var _loc8_:Array = null;
         this.chooseAnimalScreen = new GuiChooseAnimal(this.viewAssets,this,param7);
         this.createANameScreen = new GuiCreateAName(this.viewAssets,this,param7);
         this.createANameScreen.init(this.viewAssets,param7);
         if(param7)
         {
            _loc8_ = new Array(this.chooseAnimalScreen,this.createANameScreen);
         }
         else
         {
            this.playerTagScreen = new GuiPlayerTagScreen(this.viewAssets,this);
            this.playerTagScreen.init();
            this.emailScreen = new GuiEmailScreen(this.viewAssets,this);
            this.emailScreen.init();
            this.rulesScreen = new GuiRulesScreen(this.viewAssets,this);
            this.rulesScreen.init();
            _loc8_ = new Array(this.chooseAnimalScreen,this.createANameScreen,this.playerTagScreen,this.emailScreen,this.rulesScreen);
         }
         super.init(param1,param2,param3,_loc8_,param5,param6,param7);
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
         if(this.rulesScreen)
         {
            this.rulesScreen.destroy();
            this.rulesScreen = null;
         }
         super.destroy();
      }
   }
}

