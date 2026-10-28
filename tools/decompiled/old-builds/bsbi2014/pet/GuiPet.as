package pet
{
   import flash.display.MovieClip;
   import localization.LocalizationManager;
   
   public class GuiPet extends PetBase
   {
      
      public var idx:int;
      
      private var _petName:String;
      
      private var _onPetLoadedCallback:Function;
      
      public function GuiPet(idx:int, lBits:uint, uBits:uint, eBits:uint, type:int, name:String, onPetLoadedCallback:Function)
      {
         this._onPetLoadedCallback = onPetLoadedCallback;
         super(lBits,uBits,eBits,this.onPetLoaded);
         this.idx = idx;
         this._petName = name;
      }
      
      public function get petName() : String
      {
         return LocalizationManager.translatePetName(this._petName);
      }
      
      private function onPetLoaded(content:MovieClip) : void
      {
         if(this._onPetLoadedCallback != null)
         {
            this._onPetLoadedCallback(content,this);
         }
      }
   }
}

