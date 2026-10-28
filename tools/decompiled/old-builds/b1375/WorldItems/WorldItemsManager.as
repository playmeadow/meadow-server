package WorldItems
{
   import Enums.WorldItemDef;
   import collection.WorldItemCollection;
   import com.sbi.bit.BitUtility;
   import com.sbi.popup.SBMysteryMessagePopup;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenItem;
   import flash.display.MovieClip;
   import gui.DarkenManager;
   import gui.GiftPopup;
   import gui.GuiManager;
   import inventory.Iitem;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class WorldItemsManager
   {
      
      private static const USER_VAR_ID_1:int = 439;
      
      private static const IN_WORLD_LIST_ID:int = 583;
      
      private static var _worldItems:WorldItemCollection;
      
      private static var _currRoomWorldItems:Array;
      
      private static var _usableWorldItems:WorldItemCollection;
      
      private static var _giftPopup:GiftPopup;
      
      private static var _currItemDown:WorldItemDef;
      
      private static var _currGift:Iitem;
      
      private static var _giftIconMediaHelper:MediaHelper;
      
      public function WorldItemsManager()
      {
         super();
      }
      
      public static function requestWorldItemDefs(param1:Array) : void
      {
         var _loc2_:DefPacksDefHelper = null;
         _currRoomWorldItems = param1;
         if(!_worldItems)
         {
            _loc2_ = new DefPacksDefHelper();
            _loc2_.init(1064,onDefsLoaded,null,2);
            DefPacksDefHelper.mediaArray[1064] = _loc2_;
         }
         else
         {
            GenericListXtCommManager.requestGenericList(583);
         }
      }
      
      public static function getWorldItemDef(param1:int) : WorldItemDef
      {
         if(_worldItems)
         {
            return _worldItems.getWorldDefItem(param1);
         }
         return null;
      }
      
      public static function handleWorldItemsResponse(param1:WorldItemCollection) : void
      {
         _usableWorldItems = param1;
         setupWorldItemVisibility();
      }
      
      public static function onItemDown(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         _currGift = null;
         _currItemDown = null;
         _loc3_ = 1;
         while(_loc3_ < _currRoomWorldItems.length)
         {
            if(_currRoomWorldItems[_loc3_].s.content == param1)
            {
               _loc2_ = 0;
               while(_loc2_ < _usableWorldItems.length)
               {
                  if(_usableWorldItems.getWorldDefItem(_loc2_).position == _loc3_)
                  {
                     _currItemDown = _usableWorldItems.getWorldDefItem(_loc2_);
                     break;
                  }
                  _loc2_++;
               }
               if(_currItemDown)
               {
                  new SBMysteryMessagePopup(GuiManager.guiLayer,_currItemDown.popupType,_currItemDown.descText,!hasReceivedGift(_currItemDown),onGiftDown);
               }
               break;
            }
            _loc3_++;
         }
      }
      
      private static function onDefsLoaded(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[1064] = null;
         _worldItems = new WorldItemCollection();
         for each(var _loc2_:Object in param1.def)
         {
            _worldItems.setWorldDefItem(_loc2_.id,new WorldItemDef(_loc2_.id,_loc2_.mediaRefId,LocalizationManager.translateIdOnly(_loc2_.titleStrId),_loc2_.giftType,_loc2_.giftRefId,_loc2_.amount,_loc2_.position,_loc2_.userVarRefId,_loc2_.uvIndex,_loc2_.popupType));
         }
         GenericListXtCommManager.requestGenericList(583);
      }
      
      private static function setupWorldItemVisibility() : void
      {
         var _loc2_:WorldItemDef = null;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         _loc3_ = 1;
         while(_loc3_ < _currRoomWorldItems.length)
         {
            _loc2_ = null;
            _loc1_ = 0;
            while(_loc1_ < _usableWorldItems.length)
            {
               if(_usableWorldItems.getWorldDefItem(_loc1_).position == _loc3_)
               {
                  _loc2_ = _usableWorldItems.getWorldDefItem(_loc1_);
                  break;
               }
               _loc1_++;
            }
            if(_loc2_ == null)
            {
               _currRoomWorldItems[_loc3_].s.content.gotoAndPlay("turnOff");
            }
            else if(hasReceivedGift(_loc2_))
            {
               _currRoomWorldItems[_loc3_].s.content.gotoAndPlay("empty");
            }
            else
            {
               _currRoomWorldItems[_loc3_].s.content.gotoAndPlay("turnOn");
            }
            _loc3_++;
         }
      }
      
      private static function hasReceivedGift(param1:WorldItemDef) : Boolean
      {
         return BitUtility.isBitSetForNumber(param1.userVarIndex,gMainFrame.userInfo.userVarCache.getUserVarValueById(param1.userVarRefId));
      }
      
      private static function onGiftDown() : void
      {
         var _loc1_:Object = null;
         switch(_currItemDown.giftType)
         {
            case 0:
               _currGift = new DenItem();
               (_currGift as DenItem).initShopItem(_currItemDown.giftRefId,0,true);
               break;
            case 1:
               _giftIconMediaHelper = new MediaHelper();
               _giftIconMediaHelper.init(1086,onGiftIconLoaded);
               break;
            case 2:
               _giftIconMediaHelper = new MediaHelper();
               _giftIconMediaHelper.init(2221,onGiftIconLoaded);
               break;
            case 3:
               _loc1_ = ItemXtCommManager.getItemDef(_currItemDown.giftRefId);
               if(_loc1_)
               {
                  _currGift = new Item();
                  (_currGift as Item).init(_currItemDown.giftRefId,0,_loc1_.colors[(_loc1_.colors.length - 1) * Math.random()],0,0,true);
               }
         }
         if(_currGift)
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(GuiManager.guiLayer,_currGift.largeIcon,_currGift.name,_currGift.defId,2,2,onKeepGift,null,onGiftClose);
         }
      }
      
      private static function onGiftIconLoaded(param1:MovieClip) : void
      {
         var _loc2_:String = null;
         _giftIconMediaHelper.destroy();
         _giftIconMediaHelper = null;
         switch(_currItemDown.giftType - 1)
         {
            case 0:
               _loc2_ = LocalizationManager.translateIdAndInsertOnly(_currItemDown.giftAmount == 1 ? 11114 : 11097,_currItemDown.giftAmount);
               break;
            case 1:
               _loc2_ = LocalizationManager.translateIdAndInsertOnly(_currItemDown.giftAmount == 1 ? 11116 : 11103,_currItemDown.giftAmount);
         }
         _giftPopup = new GiftPopup();
         _giftPopup.init(GuiManager.guiLayer,param1,_loc2_,_currItemDown.giftAmount,2,2,onKeepGift,null,onGiftClose);
      }
      
      private static function onKeepGift() : void
      {
         DarkenManager.showLoadingSpiral(true);
         WorldItemsXtCommManager.sendAcceptGift(_currItemDown.defId,GenericListXtCommManager.getAvailListUniqueId(),_currGift && _currGift is DenItem ? (_currGift as DenItem).version : 0,_currGift && _currGift is Item ? (_currGift as Item).color : 0,onGiftResponse);
      }
      
      private static function onGiftResponse(param1:String, param2:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         onGiftClose(true);
         if(param1 == "1")
         {
            if(param2 >= 0)
            {
               switch(_currItemDown.giftType - 1)
               {
                  case 0:
                     UserCurrency.setCurrency(param2,0);
                     break;
                  case 1:
                     UserCurrency.setCurrency(param2,3);
               }
            }
            _currRoomWorldItems[_currItemDown.position].s.content.gotoAndPlay("empty");
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(28159));
         }
         _currGift = null;
         _currItemDown = null;
      }
      
      private static function onGiftClose(param1:Boolean = false) : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         if(!param1)
         {
            _currGift = null;
            _currItemDown = null;
         }
      }
   }
}

