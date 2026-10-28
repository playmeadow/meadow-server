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
      
      public static const DEF_ID_EAGLET:int = 24;
      
      public static const DEF_ID_CHEETAH:int = 25;
      
      public static const DEF_ID_RHINO:int = 26;
      
      public static const DEF_ID_GIRAFFE:int = 27;
      
      public static const DEF_ID_SUGAR_GLIDER:int = 28;
      
      public static const DEF_ID_LION_CUB:int = 29;
      
      public static const DEF_ID_PANDA:int = 30;
      
      public static const DEF_ID_POLAR_BEAR_CUB:int = 31;
      
      public static const DEF_ID_GECKO:int = 32;
      
      public static const DEF_ID_PONY:int = 34;
      
      public static const DEF_ID_PIGLET:int = 35;
      
      public static const DEF_ID_FERRET:int = 36;
      
      public static const DEF_ID_ELEPHANT:int = 37;
      
      public static const DEF_ID_ARMADILLO:int = 38;
      
      public static const DEF_ID_PEACOCK:int = 39;
      
      public static const DEF_ID_BEE:int = 40;
      
      public static const DEF_ID_SKUNK:int = 42;
      
      public static const DEF_ID_TURKEY:int = 43;
      
      public static const DEF_ID_PENGUIN:int = 44;
      
      public static const DEF_ID_SNOW_LEOPARD:int = 45;
      
      public static const DEF_ID_MANITS:int = 46;
      
      public static const DEF_ID_LADYBUG:int = 47;
      
      public static const DEF_ID_CRICKET:int = 48;
      
      public static const DEF_ID_SQUIRREL:int = 49;
      
      public static const DEF_ID_MOUSE:int = 50;
      
      public static const DEF_ID_FIREFLY:int = 51;
      
      public static const DEF_ID_LEMUR:int = 52;
      
      public static const DEF_ID_HIPPO:int = 53;
      
      public static const DEF_ID_GOAT:int = 54;
      
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
         _lBits = param1;
         _uBits = param2;
         _eBits = param3;
         _onPetLoadedCallback = param4;
         _defId = param1 & 0xFF;
         _type = PetManager.petTypeForDefId(_defId);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(mediaIdForDefId(_defId),onMediaLoaded,true);
      }
      
      public function destroy() : void
      {
      }
      
      public function isGround() : Boolean
      {
         return PetManager.isGround(_type);
      }
      
      public function getType() : int
      {
         return _type;
      }
      
      public function getDefID() : int
      {
         return _defId;
      }
      
      public function canGoInOcean() : Boolean
      {
         if(_type == 2 || _type == 3 || _type == 4 || _type == 5)
         {
            return true;
         }
         return false;
      }
      
      public function canGoOnLand() : Boolean
      {
         if(_type == 0 || _type == 1 || _type == 4 || _type == 5)
         {
            return true;
         }
         return false;
      }
      
      public function getLBits() : uint
      {
         return _lBits;
      }
      
      public function getUBits() : uint
      {
         return _uBits;
      }
      
      public function getEBits() : uint
      {
         return _eBits;
      }
      
      public function getContent() : MovieClip
      {
         return _content;
      }
      
      public function colorMyItem(param1:int, param2:MovieClip, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int) : void
      {
         if(_content)
         {
            _content.colorMe(param1,param2,param3,param4,param5,param6,param7,param8);
         }
      }
      
      public function updateAllBits(param1:uint, param2:uint, param3:uint) : void
      {
         if(_content)
         {
            _lBits = param1;
            _uBits = param2;
            _eBits = param3;
            PetManager.setPetState(_content,_lBits,_uBits,_eBits);
         }
      }
      
      public function updateUBits(param1:uint) : void
      {
         _uBits = param1;
         PetManager.setPetState(_content,_lBits,_uBits,_eBits);
      }
      
      public function animatePet(param1:Boolean) : void
      {
         if(_content && "willItAnimate" in _content.pet)
         {
            _content.pet.willItAnimate(param1);
         }
      }
      
      protected function setSparkle(param1:int) : void
      {
         if(_content)
         {
            _content.pet.setSparkle(param1);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _content = param1;
            this.addChild(_content);
            _mediaHelper.destroy();
            delete _content.mediaHelper;
            delete _content.passback;
            PetManager.setPetState(_content,_lBits,_uBits,_eBits);
            if(_onPetLoadedCallback != null)
            {
               _onPetLoadedCallback(_content);
            }
            _content.pet.setAnim(0);
         }
      }
      
      private function mediaIdForDefId(param1:int) : int
      {
         var _loc2_:PetDef = PetManager.getPetDef(param1);
         if(_loc2_)
         {
            return _loc2_.mediaRefId;
         }
         return -1;
      }
   }
}

