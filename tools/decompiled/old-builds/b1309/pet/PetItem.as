package pet
{
   import currency.CombinedCurrencyItem;
   import diamond.DiamondItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import inventory.Iitem;
   
   public class PetItem implements Iitem
   {
      
      private var _currPetDef:PetDef;
      
      private var _currGuiPet:GuiPet;
      
      private var _isIconLoaded:Boolean;
      
      private var _imageLoadedCallback:Function;
      
      private var _diamondItem:DiamondItem;
      
      private var _invIdx:int;
      
      private var _isShopItem:Boolean;
      
      private var _endTime:uint;
      
      private var _status:int;
      
      public function PetItem()
      {
         super();
      }
      
      public function init(param1:int, param2:int = 0, param3:Boolean = false, param4:uint = 0, param5:Function = null, param6:DiamondItem = null) : void
      {
         _currPetDef = PetManager.getPetDef(param1);
         _status = param6 ? param6.status : _currPetDef.status;
         _isIconLoaded = false;
         _invIdx = param2;
         _diamondItem = param6;
         _isShopItem = param3;
         _endTime = param4;
         _imageLoadedCallback = param5;
      }
      
      public function ifItemDiffers(param1:Iitem) : Boolean
      {
         var _loc2_:PetItem = param1 as PetItem;
         if(_loc2_)
         {
            if(_currPetDef && _currPetDef.defId == param1.defId)
            {
               if(value != _loc2_.value || isNew != _loc2_.isNew || isOnSale != _loc2_.isOnSale || _endTime != _loc2_._endTime)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get layerId() : int
      {
         throw new Error("PetItem does not contain layerId");
      }
      
      public function get invIdx() : int
      {
         return _invIdx;
      }
      
      public function get name() : String
      {
         return _currPetDef.title;
      }
      
      public function get isMemberOnly() : Boolean
      {
         return _currPetDef.isMember;
      }
      
      public function set isMemberOnly(param1:Boolean) : void
      {
         throw new Error("PetItem does not implement changing member only value");
      }
      
      public function get enviroType() : int
      {
         return PetManager.getEnviroTypeByPetType(_currPetDef.type);
      }
      
      public function get recycleValue() : int
      {
         if(_diamondItem)
         {
            return _diamondItem.value;
         }
         return _currPetDef.cost * gMainFrame.clientInfo.recyclePercentage;
      }
      
      public function get currencyType() : int
      {
         if(_diamondItem)
         {
            return 3;
         }
         return 0;
      }
      
      public function get endTime() : uint
      {
         return _endTime;
      }
      
      public function set endTime(param1:uint) : void
      {
         _endTime = param1;
      }
      
      public function get itemStatus() : int
      {
         return _status;
      }
      
      public function set itemStatus(param1:int) : void
      {
         _status = param1;
      }
      
      public function get value() : *
      {
         if(_diamondItem)
         {
            return _diamondItem.isOnSale ? _diamondItem.value : (isOnSale ? Math.ceil(_diamondItem.value * 0.5) : _diamondItem.value);
         }
         return isOnSale ? Math.ceil(_currPetDef.cost * 0.5) : _currPetDef.cost;
      }
      
      public function get defId() : int
      {
         return _currPetDef.defId;
      }
      
      public function set defId(param1:int) : void
      {
         throw new Error("Should not be changing this defId here");
      }
      
      public function get icon() : Sprite
      {
         var _loc1_:Array = null;
         if(!_currGuiPet)
         {
            _loc1_ = PetManager.packPetBits(PetManager.createRandomPet(defId));
            _currGuiPet = PetManager.getGuiPet(defId,_loc1_[0],_loc1_[1],_loc1_[2],_currPetDef.type,_currPetDef.title,onPetLoaded);
         }
         return _currGuiPet;
      }
      
      public function get largeIcon() : Sprite
      {
         return icon();
      }
      
      public function get isShopItem() : Boolean
      {
         return _isShopItem;
      }
      
      public function get combinedCurrencyItem() : CombinedCurrencyItem
      {
         return null;
      }
      
      public function get isIconLoaded() : Boolean
      {
         return _isIconLoaded;
      }
      
      public function get imageLoadedCallback() : Function
      {
         return _imageLoadedCallback;
      }
      
      public function set imageLoadedCallback(param1:Function) : void
      {
         _imageLoadedCallback = param1;
      }
      
      public function destroy() : void
      {
         _currPetDef = null;
         if(_currGuiPet)
         {
            _currGuiPet.destroy();
            _currGuiPet = null;
         }
      }
      
      public function clone() : Iitem
      {
         var _loc1_:PetItem = new PetItem();
         _loc1_.init(_currPetDef.defId,_invIdx,_diamondItem);
         _loc1_.updateValueWithNewStatus(_status);
         _loc1_.imageLoadedCallback = imageLoadedCallback;
         return _loc1_;
      }
      
      public function get isOnSale() : Boolean
      {
         return itemStatus == 2;
      }
      
      public function get isOnClearance() : Boolean
      {
         return itemStatus == 3;
      }
      
      public function get isRare() : Boolean
      {
         return itemStatus == 4;
      }
      
      public function get isNew() : Boolean
      {
         return itemStatus == 1;
      }
      
      public function get isOcean() : Boolean
      {
         return enviroType == 1;
      }
      
      public function get isLand() : Boolean
      {
         return enviroType == 0;
      }
      
      public function get isDiamond() : Boolean
      {
         return _diamondItem != null;
      }
      
      public function get isRareDiamond() : Boolean
      {
         return isRare && isDiamond;
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _isIconLoaded = true;
         if(_isShopItem)
         {
            param1.scaleX = param1.scaleY = 3;
            param1.y += param1.height * 0.35;
         }
         if(_imageLoadedCallback != null)
         {
            if(_imageLoadedCallback.length == 0)
            {
               _imageLoadedCallback();
            }
            else
            {
               _imageLoadedCallback(param1,param2);
            }
            _imageLoadedCallback = null;
         }
      }
      
      public function get isApproved() : Boolean
      {
         return true;
      }
      
      public function set isApproved(param1:Boolean) : void
      {
      }
      
      public function get isCustom() : Boolean
      {
         return false;
      }
      
      public function updateValueWithNewStatus(param1:int) : void
      {
         if(!isRare)
         {
            itemStatus = param1;
         }
      }
      
      public function get diamondItem() : DiamondItem
      {
         return _diamondItem;
      }
      
      public function set diamondItem(param1:DiamondItem) : void
      {
         _diamondItem = param1;
      }
   }
}

