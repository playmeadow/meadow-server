package avatar
{
   import com.sbi.graphics.LayerAnim;
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import item.Item;
   
   public class AvatarView extends Sprite
   {
      
      protected var _layerAnim:LayerAnim;
      
      protected var _avatar:Avatar;
      
      public var avTypeChangedCallback:Function;
      
      private var _isOffScreen:Boolean;
      
      private var _holdAnimId:int;
      
      private var _lastAnimToHappen:int;
      
      public function AvatarView()
      {
         super();
      }
      
      public function set lastAnimToHappen(param1:int) : void
      {
         this._lastAnimToHappen = param1;
      }
      
      public function get lastAnimToHappen() : int
      {
         return this._lastAnimToHappen;
      }
      
      public function set holdAnimId(param1:int) : void
      {
         this._holdAnimId = param1;
      }
      
      public function init(param1:Avatar, param2:Function = null) : void
      {
         this._holdAnimId = 0;
         this._avatar = param1;
         this._avatar.addEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged,false,0,true);
         this.avTypeChangedCallback = param2;
         this._layerAnim = LayerAnim.getNew();
         this._layerAnim.avDefId = this._avatar.avTypeId;
         if(this._avatar.colors)
         {
            this._layerAnim.layers = this.setLayerHelper();
         }
         this.addChild(this._layerAnim.bitmap);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         if(param1 && Boolean(this._avatar))
         {
            this._avatar.removeEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged);
            this._avatar.destroy();
            this._avatar = null;
         }
         this.avTypeChangedCallback = null;
         LayerAnim.destroy(this._layerAnim);
         this._layerAnim = null;
      }
      
      public function resetAvatar(param1:Avatar) : void
      {
         if(Boolean(this._avatar) && this._avatar.hasEventListener(AvatarEvent.AVATAR_CHANGED))
         {
            this._avatar.removeEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged);
         }
         this._avatar = param1;
         this._avatar.addEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged,false,0,true);
         if(this._layerAnim)
         {
            this._layerAnim.avDefId = this._avatar.avTypeId;
            if(this._avatar.colors)
            {
               this._layerAnim.layers = this.setLayerHelper();
            }
         }
      }
      
      public function isValid() : Boolean
      {
         return this._layerAnim != null;
      }
      
      public function hideAvatar() : void
      {
         if(this._layerAnim != null)
         {
            this._layerAnim.visible = false;
         }
      }
      
      public function showAvatar() : void
      {
         if(this._layerAnim != null)
         {
            this._layerAnim.visible = true;
         }
      }
      
      public function set isOffScreen(param1:Boolean) : void
      {
         this._isOffScreen = param1;
      }
      
      public function get isOffScreen() : Boolean
      {
         return this._isOffScreen;
      }
      
      public function pauseAnim(param1:Boolean) : void
      {
         this._layerAnim.pause = param1;
      }
      
      public function advanceFrame() : void
      {
         ++this._layerAnim.frame;
      }
      
      public function get frame() : int
      {
         return this._layerAnim.frame;
      }
      
      public function set frame(param1:int) : void
      {
         this._layerAnim.frame = param1;
      }
      
      public function get flip() : Boolean
      {
         return this._layerAnim.hFlip;
      }
      
      public function get animId() : int
      {
         return this._layerAnim.animId;
      }
      
      protected function avatarChanged(param1:AvatarEvent) : void
      {
         if(this._layerAnim)
         {
            if(this._layerAnim.avDefId != this._avatar.avTypeId)
            {
               this._layerAnim.avDefId = this._avatar.avTypeId;
               if(this.avTypeChangedCallback != null)
               {
                  this.avTypeChangedCallback(this);
               }
            }
            this._layerAnim.layers = this.setLayerHelper();
         }
      }
      
      protected function setLayerHelper() : Array
      {
         var _loc2_:AvatarInfo = null;
         var _loc3_:Array = null;
         var _loc1_:Array = null;
         if(Boolean(this._avatar.inventoryBodyMod) && Boolean(this._avatar.inventoryBodyMod.itemArray) && this._avatar.inventoryBodyMod.itemArray.length >= 1)
         {
            _loc1_ = this._avatar.inventoryBodyMod.itemArray.concat(this._avatar.inventoryClothing.itemArray.concat());
         }
         else
         {
            _loc2_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(this._avatar.dbAvId);
            if(_loc2_)
            {
               _loc3_ = _loc2_.getItems(true);
               if(_loc3_)
               {
                  _loc1_ = _loc3_;
               }
            }
         }
         return AvatarUtility.layerArrayForItemsAndColors(_loc1_,this._avatar.colors,this._avatar.dbAvId);
      }
      
      public function playAnim(param1:int, param2:Boolean = false, param3:int = 0, param4:Function = null) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:Object = null;
         var _loc12_:Array = null;
         var _loc13_:uint = 0;
         var _loc14_:Item = null;
         if(Boolean(this._layerAnim) && Boolean(this._layerAnim.visible) && (this._holdAnimId == 0 || param1 == this._holdAnimId))
         {
            if(!this._isOffScreen)
            {
               _loc5_ = false;
               _loc6_ = this._avatar.accShownItems;
               if(!this._layerAnim.layers)
               {
                  _loc5_ = true;
               }
               else if(this._layerAnim.layers.length != _loc6_.length)
               {
                  _loc5_ = true;
               }
               else
               {
                  _loc7_ = int(_loc6_.length);
                  _loc8_ = 0;
                  while(_loc8_ < _loc7_)
                  {
                     if(this._layerAnim.layers.indexOf(_loc6_[_loc8_].accId) == -1)
                     {
                        _loc5_ = true;
                        break;
                     }
                     _loc8_++;
                  }
               }
               if(_loc5_)
               {
                  _loc9_ = [];
                  _loc10_ = _loc6_;
                  _loc12_ = this._avatar.colors;
                  for each(_loc14_ in _loc10_)
                  {
                     if(_loc14_.getInUse(this._avatar.dbAvId))
                     {
                        if(_loc14_.layerId == 1)
                        {
                           _loc13_ = uint(_loc12_[0]);
                        }
                        else if(_loc14_.layerId == 2)
                        {
                           _loc13_ = uint(_loc12_[1]);
                        }
                        else if(_loc14_.layerId == 3)
                        {
                           _loc13_ = uint(_loc12_[2]);
                        }
                        else
                        {
                           _loc13_ = _loc14_.color;
                        }
                        _loc11_ = {
                           "l":_loc14_.accId,
                           "c":_loc13_
                        };
                        _loc9_.push(_loc11_);
                     }
                  }
                  this._layerAnim.layers = _loc9_;
               }
               this._layerAnim.hFlip = param2;
               this._layerAnim.playAnim(param1,param3,param4);
            }
            else
            {
               this._lastAnimToHappen = param1;
            }
         }
      }
      
      public function reloadItemsFromCache() : void
      {
         var _loc1_:Array = gMainFrame.userInfo.getAvatarInfoByDbAvId(this._avatar.dbAvId).getItems(true);
         this._avatar.itemResponseIntegrate(_loc1_);
      }
      
      public function preloadAnims(param1:Array, param2:Function = null) : void
      {
         this._layerAnim.preload(param1,param2);
      }
      
      public function blackOut() : void
      {
         var _loc1_:Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];
         this._layerAnim.bitmap.filters = [new ColorMatrixFilter(_loc1_)];
      }
      
      public function get avatarData() : Avatar
      {
         return this._avatar;
      }
      
      public function get userName() : String
      {
         if(this._avatar != null)
         {
            return this._avatar.userName;
         }
         return "";
      }
      
      public function get userId() : int
      {
         if(this._avatar == null)
         {
            return -1;
         }
         return this._avatar.sfsUserId;
      }
      
      public function get avTypeId() : int
      {
         return this._avatar.avTypeId;
      }
      
      public function get dbAvId() : int
      {
         return this._avatar.dbAvId;
      }
      
      public function get inventoryBodyModItems() : Array
      {
         return this._avatar.inventoryBodyMod.itemArray;
      }
      
      public function get inventoryClothingItems() : Array
      {
         return this._avatar.inventoryClothing.itemArray;
      }
      
      public function setAvtColors(param1:Array) : void
      {
         this._avatar.colors = param1;
      }
      
      public function get avName() : String
      {
         return this._avatar.avName;
      }
   }
}

