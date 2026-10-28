package pet
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import loader.MediaHelper;
   
   public class PetBase extends Sprite
   {
      
      public static const DEF_ID_CAT:int = 1;
      
      public static const DEF_ID_FROG:int = 2;
      
      public static const DEF_ID_DUCK:int = 3;
      
      public static const DEF_ID_DOG:int = 4;
      
      public static const DEF_ID_BFLY:int = 5;
      
      public static const DEF_ID_HAMS:int = 6;
      
      public static const DEF_ID_BAT:int = 7;
      
      public static const DEF_ID_SEAHORSE:int = 8;
      
      public static const DEF_ID_ANGLER:int = 9;
      
      public static const DEF_ID_REINDEER:int = 10;
      
      public static const DEF_ID_SNAKE:int = 11;
      
      public static const DEF_ID_JELLYFISH:int = 12;
      
      public static const DEF_ID_BUNNY:int = 13;
      
      public static const DEF_ID_HUMMINGBIRD:int = 14;
      
      public static const DEF_ID_TURTLE:int = 15;
      
      public static const DEF_ID_MONKEY:int = 16;
      
      public static const DEF_ID_TARANTUAL:int = 17;
      
      public static const DEF_ID_FOX:int = 18;
      
      public static const DEF_ID_OWL:int = 19;
      
      public static const DEF_ID_TIGER:int = 20;
      
      public static const DEF_ID_ARCTIC_WOLF:int = 21;
      
      public static const DEF_ID_RACCOON:int = 22;
      
      public static const DEF_ID_JOEY:int = 23;
      
      public static const TYPE_LAND_GROUND:int = 0;
      
      public static const TYPE_LAND_AIR:int = 1;
      
      public static const TYPE_OCEAN_GROUND:int = 2;
      
      public static const TYPE_OCEAN_AIR:int = 3;
      
      public static const TYPE_AMPHIB_GROUND:int = 4;
      
      public static const TYPE_AMPHIB_AIR:int = 5;
      
      protected var _type:int;
      
      protected var _defId:int;
      
      protected var _lBits:uint;
      
      protected var _uBits:uint;
      
      protected var _eBits:uint;
      
      protected var _content:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _onPetLoadedCallback:Function;
      
      public function PetBase(param1:uint, param2:uint, param3:uint, param4:Function)
      {
         super();
         this._lBits = param1;
         this._uBits = param2;
         this._eBits = param3;
         this._onPetLoadedCallback = param4;
         this._defId = param1 & 0xFF;
         this._type = PetManager.petTypeForDefId(this._defId);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this.mediaIdForDefId(this._defId),this.onMediaLoaded,true);
      }
      
      public function destroy() : void
      {
      }
      
      public function isGround() : Boolean
      {
         return PetManager.isGround(this._type);
      }
      
      public function getType() : int
      {
         return this._type;
      }
      
      public function getDefID() : int
      {
         return this._defId;
      }
      
      public function canGoInOcean() : Boolean
      {
         if(this._type == PetManager.TYPE_OCEAN_LOW || this._type == PetManager.TYPE_OCEAN_HIGH || this._type == PetManager.TYPE_AMPHIB_LOW || this._type == PetManager.TYPE_AMPHIB_HIGH)
         {
            return true;
         }
         return false;
      }
      
      public function canGoOnLand() : Boolean
      {
         if(this._type == PetManager.TYPE_LAND_LOW || this._type == PetManager.TYPE_LAND_HIGH || this._type == PetManager.TYPE_AMPHIB_LOW || this._type == PetManager.TYPE_AMPHIB_HIGH)
         {
            return true;
         }
         return false;
      }
      
      public function getLBits() : uint
      {
         return this._lBits;
      }
      
      public function getUBits() : uint
      {
         return this._uBits;
      }
      
      public function getEBits() : uint
      {
         return this._eBits;
      }
      
      public function getContent() : MovieClip
      {
         return this._content;
      }
      
      public function colorMyItem(param1:int, param2:MovieClip, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int) : void
      {
         if(this._content)
         {
            this._content.colorMe(param1,param2,param3,param4,param5,param6,param7,param8);
         }
      }
      
      public function updateAllBits(param1:uint, param2:uint, param3:uint) : void
      {
         if(this._content)
         {
            this._lBits = param1;
            this._uBits = param2;
            this._eBits = param3;
            PetManager.setPetState(this._content,this._lBits,this._uBits,this._eBits);
         }
      }
      
      public function updateUBits(param1:uint) : void
      {
         this._uBits = param1;
         PetManager.setPetState(this._content,this._lBits,this._uBits,this._eBits);
      }
      
      protected function setSparkle(param1:int) : void
      {
         if(this._content)
         {
            this._content.pet.setSparkle(param1);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._content = param1;
            this.addChild(this._content);
            this._mediaHelper.destroy();
            delete this._content.mediaHelper;
            delete this._content.passback;
            PetManager.setPetState(this._content,this._lBits,this._uBits,this._eBits);
            if(this._onPetLoadedCallback != null)
            {
               this._onPetLoadedCallback(this._content);
            }
            this._content.pet.setAnim(0);
         }
      }
      
      private function mediaIdForDefId(param1:int) : int
      {
         var _loc2_:Object = PetManager.getPetDef(param1);
         if(_loc2_)
         {
            return _loc2_.mediaRefId;
         }
         return -1;
      }
   }
}

