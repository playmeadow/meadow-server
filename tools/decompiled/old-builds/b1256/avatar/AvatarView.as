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
         _lastAnimToHappen = param1;
      }
      
      public function get lastAnimToHappen() : int
      {
         return _lastAnimToHappen;
      }
      
      public function set holdAnimId(param1:int) : void
      {
         _holdAnimId = param1;
      }
      
      public function init(param1:Avatar, param2:Function = null) : void
      {
         _holdAnimId = 0;
         _avatar = param1;
         _avatar.addEventListener("OnAvatarChanged",avatarChanged,false,0,true);
         avTypeChangedCallback = param2;
         _layerAnim = LayerAnim.getNew();
         _layerAnim.avDefId = _avatar.avTypeId;
         if(_avatar.colors)
         {
            _layerAnim.layers = setLayerHelper();
         }
         this.addChild(_layerAnim.bitmap);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         if(param1 && _avatar)
         {
            _avatar.removeEventListener("OnAvatarChanged",avatarChanged);
            _avatar.destroy();
            _avatar = null;
         }
         avTypeChangedCallback = null;
         LayerAnim.destroy(_layerAnim);
         _layerAnim = null;
      }
      
      public function resetAvatar(param1:Avatar) : void
      {
         if(_avatar && _avatar.hasEventListener("OnAvatarChanged"))
         {
            _avatar.removeEventListener("OnAvatarChanged",avatarChanged);
         }
         _avatar = param1;
         _avatar.addEventListener("OnAvatarChanged",avatarChanged,false,0,true);
         if(_layerAnim)
         {
            _layerAnim.avDefId = _avatar.avTypeId;
            if(_avatar.colors)
            {
               _layerAnim.layers = setLayerHelper();
            }
         }
      }
      
      public function isValid() : Boolean
      {
         return _layerAnim != null;
      }
      
      public function hideAvatar() : void
      {
         if(_layerAnim != null)
         {
            _layerAnim.visible = false;
         }
      }
      
      public function showAvatar() : void
      {
         if(_layerAnim != null)
         {
            _layerAnim.visible = true;
         }
      }
      
      public function set isOffScreen(param1:Boolean) : void
      {
         _isOffScreen = param1;
      }
      
      public function get isOffScreen() : Boolean
      {
         return _isOffScreen;
      }
      
      public function pauseAnim(param1:Boolean) : void
      {
         _layerAnim.pause = param1;
      }
      
      public function advanceFrame() : void
      {
         _layerAnim.frame++;
      }
      
      public function get frame() : int
      {
         return _layerAnim.frame;
      }
      
      public function set frame(param1:int) : void
      {
         _layerAnim.frame = param1;
      }
      
      public function get flip() : Boolean
      {
         return _layerAnim.hFlip;
      }
      
      public function get animId() : int
      {
         return _layerAnim.animId;
      }
      
      protected function avatarChanged(param1:AvatarEvent) : void
      {
         if(_layerAnim)
         {
            if(_layerAnim.avDefId != _avatar.avTypeId)
            {
               _layerAnim.avDefId = _avatar.avTypeId;
               if(avTypeChangedCallback != null)
               {
                  avTypeChangedCallback(this);
               }
            }
            _layerAnim.layers = setLayerHelper();
         }
      }
      
      protected function setLayerHelper() : Array
      {
         var _loc3_:AvatarInfo = null;
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         if(_avatar.inventoryBodyMod && _avatar.inventoryBodyMod.itemArray && _avatar.inventoryBodyMod.itemArray.length >= 1)
         {
            _loc2_ = _avatar.inventoryBodyMod.itemArray.concat(_avatar.inventoryClothing.itemArray.concat());
         }
         else
         {
            _loc3_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_avatar.userName,_avatar.perUserAvId);
            if(_loc3_)
            {
               _loc1_ = _loc3_.getItems(true);
               if(_loc1_)
               {
                  _loc2_ = _loc1_;
               }
            }
         }
         return AvatarUtility.layerArrayForItemsAndColors(_loc2_,_avatar.colors,_avatar.perUserAvId);
      }
      
      public function playAnim(param1:int, param2:Boolean = false, param3:int = 0, param4:Function = null) : void
      {
         var _loc12_:Boolean = false;
         var _loc14_:Array = null;
         var _loc11_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:Array = null;
         var _loc5_:Array = null;
         var _loc13_:Object = null;
         var _loc7_:Array = null;
         var _loc10_:* = 0;
         if(_layerAnim && _layerAnim.visible && (_holdAnimId == 0 || param1 == _holdAnimId))
         {
            if(!_isOffScreen)
            {
               _loc12_ = false;
               _loc14_ = _avatar.accShownItems;
               if(!_layerAnim.layers)
               {
                  _loc12_ = true;
               }
               else if(_layerAnim.layers.length != _loc14_.length)
               {
                  _loc12_ = true;
               }
               else
               {
                  _loc11_ = int(_loc14_.length);
                  _loc9_ = 0;
                  while(_loc9_ < _loc11_)
                  {
                     if(_layerAnim.layers.indexOf(_loc14_[_loc9_].accId) == -1)
                     {
                        _loc12_ = true;
                        break;
                     }
                     _loc9_++;
                  }
               }
               if(_loc12_)
               {
                  _loc8_ = [];
                  _loc5_ = _loc14_;
                  _loc7_ = _avatar.colors;
                  for each(var _loc6_:Item in _loc5_)
                  {
                     if(_loc6_.getInUse(_avatar.perUserAvId))
                     {
                        if(_loc6_.layerId == 1)
                        {
                           _loc10_ = uint(_loc7_[0]);
                        }
                        else if(_loc6_.layerId == 2)
                        {
                           _loc10_ = uint(_loc7_[1]);
                        }
                        else if(_loc6_.layerId == 3)
                        {
                           _loc10_ = uint(_loc7_[2]);
                        }
                        else
                        {
                           _loc10_ = _loc6_.color;
                        }
                        _loc13_ = {
                           "l":_loc6_.accId,
                           "c":_loc10_
                        };
                        _loc8_.push(_loc13_);
                     }
                  }
                  _layerAnim.layers = _loc8_;
               }
               _layerAnim.hFlip = param2;
               _layerAnim.playAnim(param1,param3,param4);
            }
            else
            {
               _lastAnimToHappen = param1;
            }
         }
      }
      
      public function reloadItemsFromCache() : void
      {
         var _loc1_:Array = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_avatar.userName,_avatar.perUserAvId).getItems(true);
         _avatar.itemResponseIntegrate(_loc1_);
      }
      
      public function preloadAnims(param1:Array, param2:Function = null) : void
      {
         _layerAnim.preload(param1,param2);
      }
      
      public function blackOut() : void
      {
         var _loc1_:Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];
         _layerAnim.bitmap.filters = [new ColorMatrixFilter(_loc1_)];
      }
      
      public function get avatarData() : Avatar
      {
         return _avatar;
      }
      
      public function get userName() : String
      {
         if(_avatar != null)
         {
            return _avatar.userName;
         }
         return null;
      }
      
      public function get userId() : int
      {
         if(_avatar == null)
         {
            return -1;
         }
         return _avatar.sfsUserId;
      }
      
      public function get avTypeId() : int
      {
         return _avatar.avTypeId;
      }
      
      public function get customAvId() : int
      {
         return _avatar.customAvId;
      }
      
      public function get perUserAvId() : int
      {
         return _avatar.perUserAvId;
      }
      
      public function get inventoryBodyModItems() : Array
      {
         return _avatar.inventoryBodyMod.itemArray;
      }
      
      public function get inventoryClothingItems() : Array
      {
         return _avatar.inventoryClothing.itemArray;
      }
      
      public function setAvtColors(param1:Array) : void
      {
         _avatar.colors = param1;
      }
      
      public function get avName() : String
      {
         return _avatar.avName;
      }
   }
}

