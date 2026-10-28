package pet
{
   public class GuiPet extends PetBase
   {
      
      public var idx:int;
      
      public var petName:String;
      
      public function GuiPet(param1:int, param2:uint, param3:uint, param4:uint, param5:int, param6:String, param7:Function)
      {
         super(param2,param3,param4,param7);
         this.idx = param1;
         this.petName = param6;
      }
   }
}

