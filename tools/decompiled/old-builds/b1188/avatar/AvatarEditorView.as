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
      
      override public function init(param1:Avatar, param2:Function = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _avatar = new Avatar();
         _avatar.init(param1.perUserAvId,"editorAvatar",param1.avTypeId,param1.colors,param1.customAvId,null,"",-1,0,param1.rangedAttack,param1.meleeAttack,param1.fierceAttack,param1.healingPower,param1.defense);
         if(param1.inventoryClothing.itemArray)
         {
            _avatar.inventoryClothing.itemArray = param1.inventoryClothing.itemArray.concat();
            _loc3_ = 0;
            while(_loc3_ < _avatar.inventoryClothing.itemArray.length)
            {
               _avatar.inventoryClothing.itemArray[_loc3_].makeSmallIcon();
               _loc3_++;
            }
         }
         if(param1.inventoryBodyMod.itemArray)
         {
            _avatar.inventoryBodyMod.itemArray = param1.inventoryBodyMod.itemArray.concat();
            _loc4_ = 0;
            while(_loc4_ < _avatar.inventoryBodyMod.itemArray.length)
            {
               _avatar.inventoryBodyMod.itemArray[_loc4_].makeSmallIcon();
               _loc4_++;
            }
         }
         _avatar.matchShownAcc(param1.accState);
         _avatar.addEventListener(AvatarEvent.AVATAR_CHANGED,avatarChanged,false,0,true);
         _layerAnim = LayerAnim.getNew();
         _layerAnim.avDefId = _avatar.avTypeId;
         _layerAnim.layers = AvatarUtility.layerArrayForItemsAndColors(param1.inventoryClothing.itemArray.concat(param1.inventoryBodyMod.itemArray.concat()),param1.colors,param1.perUserAvId);
         this.addChild(_layerAnim.bitmap);
      }
      
      override public function destroy(param1:Boolean = true) : void
      {
         if(param1 && Boolean(_avatar))
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
      
      public function set colors(param1:Array) : void
      {
         _avatar.colors = param1;
      }
      
      public function get accState() : AccessoryState
      {
         return _avatar.accState;
      }
      
      public function showAccessory(param1:Item, param2:Function = null) : void
      {
         _avatar.accStateShowAccessory(param1,param2);
      }
      
      public function hideAccessory(param1:Item) : void
      {
         _avatar.accStateHideAccessory(param1);
      }
      
      public function get viewAvatar() : Avatar
      {
         return _avatar;
      }
   }
}

