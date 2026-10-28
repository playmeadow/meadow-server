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
      
      public function set lastAnimToHappen(lastAnimId:int) : void
      {
         this._lastAnimToHappen = lastAnimId;
      }
      
      public function get lastAnimToHappen() : int
      {
         return this._lastAnimToHappen;
      }
      
      public function set holdAnimId(inAnimId:int) : void
      {
         this._holdAnimId = inAnimId;
      }
      
      public function init(avatar:Avatar, avTypeCallback:Function = null) : void
      {
         this._holdAnimId = 0;
         this._avatar = avatar;
         this._avatar.addEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged,false,0,true);
         this.avTypeChangedCallback = avTypeCallback;
         this._layerAnim = LayerAnim.getNew();
         this._layerAnim.avDefId = this._avatar.avTypeId;
         if(Boolean(this._avatar.colors))
         {
            this._layerAnim.layers = this.setLayerHelper();
         }
         this.addChild(this._layerAnim.bitmap);
      }
      
      public function destroy(destroyAvatar:Boolean = false) : void
      {
         if(destroyAvatar && Boolean(this._avatar))
         {
            this._avatar.removeEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged);
            this._avatar.destroy();
            this._avatar = null;
         }
         this.avTypeChangedCallback = null;
         LayerAnim.destroy(this._layerAnim);
         this._layerAnim = null;
      }
      
      public function resetAvatar(rAv:Avatar) : void
      {
         if(Boolean(this._avatar) && this._avatar.hasEventListener(AvatarEvent.AVATAR_CHANGED))
         {
            this._avatar.removeEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged);
         }
         this._avatar = rAv;
         this._avatar.addEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged,false,0,true);
         if(Boolean(this._layerAnim))
         {
            this._layerAnim.avDefId = this._avatar.avTypeId;
            if(Boolean(this._avatar.colors))
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
      
      public function set isOffScreen(value:Boolean) : void
      {
         this._isOffScreen = value;
      }
      
      public function get isOffScreen() : Boolean
      {
         return this._isOffScreen;
      }
      
      public function pauseAnim(b:Boolean) : void
      {
         this._layerAnim.pause = b;
      }
      
      public function advanceFrame() : void
      {
         ++this._layerAnim.frame;
      }
      
      public function get frame() : int
      {
         return this._layerAnim.frame;
      }
      
      public function set frame(f:int) : void
      {
         this._layerAnim.frame = f;
      }
      
      public function get flip() : Boolean
      {
         return this._layerAnim.hFlip;
      }
      
      public function get animId() : int
      {
         return this._layerAnim.animId;
      }
      
      protected function avatarChanged(evt:AvatarEvent) : void
      {
         if(Boolean(this._layerAnim))
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
         var avInfo:AvatarInfo = null;
         var tempItems:Array = null;
         var items:Array = null;
         if(Boolean(this._avatar.inventoryBodyMod) && Boolean(this._avatar.inventoryBodyMod.itemArray) && this._avatar.inventoryBodyMod.itemArray.length >= 1)
         {
            items = this._avatar.inventoryBodyMod.itemArray.concat(this._avatar.inventoryClothing.itemArray.concat());
         }
         else
         {
            avInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(this._avatar.userName,this._avatar.perUserAvId);
            if(Boolean(avInfo))
            {
               tempItems = avInfo.getItems(true);
               if(Boolean(tempItems))
               {
                  items = tempItems;
               }
            }
         }
         return AvatarUtility.layerArrayForItemsAndColors(items,this._avatar.colors,this._avatar.perUserAvId);
      }
      
      public function playAnim(animId:int, hFlip:Boolean = false, mode:int = 0, callback:Function = null) : void
      {
         var needToChangeLayers:Boolean = false;
         var accItems:Array = null;
         var accItemsLength:int = 0;
         var ntci:int = 0;
         var layerArray:Array = null;
         var shownItems:Array = null;
         var obj:Object = null;
         var colors:Array = null;
         var color:uint = 0;
         var showItem:Item = null;
         if(Boolean(this._layerAnim) && Boolean(this._layerAnim.visible) && (this._holdAnimId == 0 || animId == this._holdAnimId))
         {
            if(!this._isOffScreen)
            {
               needToChangeLayers = false;
               accItems = this._avatar.accShownItems;
               if(!this._layerAnim.layers)
               {
                  needToChangeLayers = true;
               }
               else if(this._layerAnim.layers.length != accItems.length)
               {
                  needToChangeLayers = true;
               }
               else
               {
                  accItemsLength = int(accItems.length);
                  for(ntci = 0; ntci < accItemsLength; ntci++)
                  {
                     if(this._layerAnim.layers.indexOf(accItems[ntci].accId) == -1)
                     {
                        needToChangeLayers = true;
                        break;
                     }
                  }
               }
               if(needToChangeLayers)
               {
                  layerArray = [];
                  shownItems = accItems;
                  colors = this._avatar.colors;
                  for each(showItem in shownItems)
                  {
                     if(showItem.getInUse(this._avatar.perUserAvId))
                     {
                        if(showItem.layerId == 1)
                        {
                           color = uint(colors[0]);
                        }
                        else if(showItem.layerId == 2)
                        {
                           color = uint(colors[1]);
                        }
                        else if(showItem.layerId == 3)
                        {
                           color = uint(colors[2]);
                        }
                        else
                        {
                           color = showItem.color;
                        }
                        obj = {
                           "l":showItem.accId,
                           "c":color
                        };
                        layerArray.push(obj);
                     }
                  }
                  this._layerAnim.layers = layerArray;
               }
               this._layerAnim.hFlip = hFlip;
               this._layerAnim.playAnim(animId,mode,callback);
            }
            else
            {
               this._lastAnimToHappen = animId;
            }
         }
      }
      
      public function reloadItemsFromCache() : void
      {
         var allItems:Array = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(this._avatar.userName,this._avatar.perUserAvId).getItems(true);
         this._avatar.itemResponseIntegrate(allItems);
      }
      
      public function preloadAnims(anims:Array, callback:Function = null) : void
      {
         this._layerAnim.preload(anims,callback);
      }
      
      public function blackOut() : void
      {
         var matrix:Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];
         this._layerAnim.bitmap.filters = [new ColorMatrixFilter(matrix)];
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
      
      public function get perUserAvId() : int
      {
         return this._avatar.perUserAvId;
      }
      
      public function get inventoryBodyModItems() : Array
      {
         return this._avatar.inventoryBodyMod.itemArray;
      }
      
      public function get inventoryClothingItems() : Array
      {
         return this._avatar.inventoryClothing.itemArray;
      }
      
      public function setAvtColors(colors:Array) : void
      {
         this._avatar.colors = colors;
      }
      
      public function get avName() : String
      {
         return this._avatar.avName;
      }
   }
}

