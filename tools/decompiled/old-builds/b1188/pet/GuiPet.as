package pet
{
   import flash.display.MovieClip;
   import localization.LocalizationManager;
   
   public class GuiPet extends PetBase
   {
      
      public var idx:int;
      
      private var _petName:String;
      
      private var _onPetLoadedCallback:Function;
      
      public function GuiPet(param1:int, param2:uint, param3:uint, param4:uint, param5:int, param6:String, param7:Function)
      {
         this._onPetLoadedCallback = param7;
         super(param2,param3,param4,this.onPetLoaded);
         this.idx = param1;
         this._petName = param6;
      }
      
      public function get petName() : String
      {
         return LocalizationManager.translatePetName(this._petName);
      }
      
      private function onPetLoaded(param1:MovieClip) : void
      {
         if(this._onPetLoadedCallback != null)
         {
            this._onPetLoadedCallback(param1,this);
         }
      }
   }
}

