package pet
{
   import localization.LocalizationManager;
   
   public class GuiPet extends PetBase
   {
      
      public var idx:int;
      
      private var _petName:String;
      
      public function GuiPet(param1:int, param2:uint, param3:uint, param4:uint, param5:int, param6:String, param7:Function)
      {
         super(param2,param3,param4,param7);
         this.idx = param1;
         this._petName = param6;
      }
      
      public function get petName() : String
      {
         return LocalizationManager.translatePetName(this._petName);
      }
   }
}

