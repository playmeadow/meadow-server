package avatar
{
   import com.sbi.graphics.LayerAnim;
   import item.Item;
   
   public class AvatarEditorView extends AvatarView
   {
      
      public function AvatarEditorView()
      {
         super();
      }
      
      override public function init(worldAvatar:Avatar, avTypeCallback:Function = null) : void
      {
         var i:int = 0;
         var j:int = 0;
         _avatar = new Avatar();
         _avatar.init(worldAvatar.perUserAvId,"editorAvatar",worldAvatar.avTypeId,worldAvatar.colors,null,"",-1,0,worldAvatar.rangedAttack,worldAvatar.meleeAttack,worldAvatar.fierceAttack,worldAvatar.healingPower,worldAvatar.defense);
         if(Boolean(worldAvatar.inventoryClothing.itemArray))
         {
            _avatar.inventoryClothing.itemArray = worldAvatar.inventoryClothing.itemArray.concat();
            for(i = 0; i < _avatar.inventoryClothing.itemArray.length; i++)
            {
               _avatar.inventoryClothing.itemArray[i].makeSmallIcon();
            }
         }
         if(Boolean(worldAvatar.inventoryBodyMod.itemArray))
         {
            _avatar.inventoryBodyMod.itemArray = worldAvatar.inventoryBodyMod.itemArray.concat();
            for(j = 0; j < _avatar.inventoryBodyMod.itemArray.length; j++)
            {
               _avatar.inventoryBodyMod.itemArray[j].makeSmallIcon();
            }
         }
         _avatar.matchShownAcc(worldAvatar.accState);
         _avatar.addEventListener(AvatarEvent.AVATAR_CHANGED,avatarChanged,false,0,true);
         _layerAnim = LayerAnim.getNew();
         _layerAnim.avDefId = _avatar.avTypeId;
         _layerAnim.layers = AvatarUtility.layerArrayForItemsAndColors(worldAvatar.inventoryClothing.itemArray.concat(worldAvatar.inventoryBodyMod.itemArray.concat()),worldAvatar.colors,worldAvatar.perUserAvId);
         this.addChild(_layerAnim.bitmap);
      }
      
      override public function destroy(destroyAvatar:Boolean = true) : void
      {
         if(destroyAvatar && Boolean(_avatar))
         {
            _avatar.removeEventListener(AvatarEvent.AVATAR_CHANGED,avatarChanged);
            _avatar.destroy();
            _avatar = null;
         }
         avTypeChangedCallback = null;
         LayerAnim.destroy(_layerAnim);
         _layerAnim = null;
      }
      
      public function get colors() : Array
      {
         return _avatar.colors;
      }
      
      public function set colors(colors:Array) : void
      {
         _avatar.colors = colors;
      }
      
      public function get accState() : AccessoryState
      {
         return _avatar.accState;
      }
      
      public function showAccessory(showItem:Item, callback:Function = null) : void
      {
         _avatar.accStateShowAccessory(showItem,callback);
      }
      
      public function hideAccessory(hideItem:Item) : void
      {
         _avatar.accStateHideAccessory(hideItem);
      }
      
      public function get viewAvatar() : Avatar
      {
         return _avatar;
      }
   }
}

