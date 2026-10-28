package adoptAPet
{
   import Enums.AdoptAPetDef;
   import collection.AdoptAPetDataCollection;
   import collection.AdoptAPetDefCollection;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   
   public class AdoptAPetManager
   {
      
      private static const ADOPT_A_PET_FIRST_POPUP_ID:int = 4771;
      
      private static var _adoptAPetDefs:AdoptAPetDefCollection;
      
      private static var _usableAdoptAPetData:AdoptAPetDataCollection;
      
      private static var _adoptAPetDefsNonIndexedSortedByName:AdoptAPetDefCollection;
      
      private static var _shouldShowFirstAdoptAPetPopup:Boolean;
      
      private static var _mediaHelper:MediaHelper;
      
      private static var _firstTimeAdoptAPetPopup:MovieClip;
      
      private static const TIERED_GIFT_COUNTS:Array = [5,10,15,20,25,30,35,40,50,65,80,96];
      
      public function AdoptAPetManager()
      {
         super();
      }
      
      public static function setAdoptAPetDefs(param1:AdoptAPetDefCollection) : void
      {
         _adoptAPetDefs = param1;
      }
      
      public static function setAdoptAPetDefsNonIndexed(param1:AdoptAPetDefCollection) : void
      {
         _adoptAPetDefsNonIndexedSortedByName = param1;
         _adoptAPetDefsNonIndexedSortedByName.getCoreArray().sort(sortOnPrice);
      }
      
      public static function setUsableAdoptAPetData(param1:AdoptAPetDataCollection) : void
      {
         _usableAdoptAPetData = param1;
      }
      
      public static function getAdoptAPetDef(param1:int) : AdoptAPetDef
      {
         return _adoptAPetDefs.getAdoptAPetItem(param1);
      }
      
      public static function get allAdoptAPetDefs() : AdoptAPetDefCollection
      {
         return _adoptAPetDefs;
      }
      
      public static function get allAdoptAPetDefsNonIndexedSortedByName() : AdoptAPetDefCollection
      {
         return _adoptAPetDefsNonIndexedSortedByName;
      }
      
      public static function get totalAdoptAPetDefs() : int
      {
         return _adoptAPetDefs.length - 1;
      }
      
      public static function get usableAdoptAPetDataCopy() : AdoptAPetDataCollection
      {
         return new AdoptAPetDataCollection(_usableAdoptAPetData.concatCollection(null));
      }
      
      public static function get hasAtLeastOneUsableAdoptAPet() : Boolean
      {
         return _usableAdoptAPetData != null && _usableAdoptAPetData.length > 0;
      }
      
      public static function set shouldShowFirstAdoptAPetPopup(param1:Boolean) : void
      {
         _shouldShowFirstAdoptAPetPopup = param1;
      }
      
      public static function get shouldShowFirstAdoptAPetPopup() : Boolean
      {
         return _shouldShowFirstAdoptAPetPopup;
      }
      
      public static function get hasUnseenPetData() : Boolean
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _usableAdoptAPetData.length)
         {
            if(_usableAdoptAPetData.getAdoptAPetDataItem(_loc1_) && !_usableAdoptAPetData.getAdoptAPetDataItem(_loc1_).hasBeenSeen)
            {
               return true;
            }
            _loc1_++;
         }
         return false;
      }
      
      public static function get numTieredGiftCount() : int
      {
         var _loc1_:int = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(426));
         if(_loc1_ == -1)
         {
            return 0;
         }
         return _loc1_;
      }
      
      public static function get currTierGiftCountAmount() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = numTieredGiftCount;
         if(_loc2_ != -1)
         {
            _loc1_ = 0;
            while(_loc1_ < TIERED_GIFT_COUNTS.length)
            {
               if(_loc2_ < TIERED_GIFT_COUNTS[_loc1_])
               {
                  return TIERED_GIFT_COUNTS[_loc1_];
               }
               _loc1_++;
            }
            return TIERED_GIFT_COUNTS[_loc1_ - 1];
         }
         return TIERED_GIFT_COUNTS[0];
      }
      
      public static function isAdoptAPetDefUsable(param1:int) : Boolean
      {
         return _usableAdoptAPetData.getAdoptAPetDataItem(param1) != null;
      }
      
      public static function setUsableAdoptAPetDef(param1:int) : void
      {
         return _usableAdoptAPetData.setAdoptAPetDataItem(param1,new AdoptAPetData(param1));
      }
      
      public static function setUsableAdoptAPetDefAsSeen(param1:int) : void
      {
         if(_usableAdoptAPetData.getAdoptAPetDataItem(param1))
         {
            _usableAdoptAPetData.getAdoptAPetDataItem(param1).hasBeenSeen = true;
         }
      }
      
      private static function sortOnPrice(param1:AdoptAPetDef, param2:AdoptAPetDef) : int
      {
         var _loc5_:Array = param1.name.split("-");
         var _loc8_:int = int(_loc5_[1]);
         _loc5_ = (_loc5_[0] as String).split(" ");
         var _loc6_:int = int(_loc5_[_loc5_.length - 1]);
         var _loc4_:Array = param2.name.split("-");
         var _loc7_:int = int(_loc4_[1]);
         _loc4_ = (_loc4_[0] as String).split(" ");
         var _loc3_:int = int(_loc4_[_loc4_.length - 1]);
         if(_loc6_ > _loc3_)
         {
            return 1;
         }
         if(_loc6_ < _loc3_)
         {
            return -1;
         }
         if(_loc8_ > _loc7_)
         {
            return 1;
         }
         if(_loc8_ < _loc7_)
         {
            return -1;
         }
         return 0;
      }
      
      public static function showFirstAdoptAPetPopup(param1:Function) : void
      {
         _shouldShowFirstAdoptAPetPopup = false;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4771,onFirstAdoptAPetPopupLoaded,param1);
      }
      
      private static function onFirstAdoptAPetPopupLoaded(param1:MovieClip) : void
      {
         _firstTimeAdoptAPetPopup = param1.getChildAt(0) as MovieClip;
         _firstTimeAdoptAPetPopup.callback = param1.passback;
         _firstTimeAdoptAPetPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         _firstTimeAdoptAPetPopup.bx.addEventListener("mouseDown",onFirstTimeAdoptAPetClose,false,0,true);
         _firstTimeAdoptAPetPopup.goNowBtn.addEventListener("mouseDown",onGoNowBtn,false,0,true);
         _firstTimeAdoptAPetPopup.x = 900 * 0.5;
         _firstTimeAdoptAPetPopup.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_firstTimeAdoptAPetPopup);
         DarkenManager.darken(_firstTimeAdoptAPetPopup);
      }
      
      private static function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onFirstTimeAdoptAPetClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _firstTimeAdoptAPetPopup.removeEventListener("mouseDown",onPopupDown);
         _firstTimeAdoptAPetPopup.bx.removeEventListener("mouseDown",onFirstTimeAdoptAPetClose);
         _firstTimeAdoptAPetPopup.goNowBtn.removeEventListener("mouseDown",onGoNowBtn);
         DarkenManager.unDarken(_firstTimeAdoptAPetPopup);
         GuiManager.guiLayer.removeChild(_firstTimeAdoptAPetPopup);
         if(_firstTimeAdoptAPetPopup.callback != null)
         {
            _firstTimeAdoptAPetPopup.callback();
         }
         _firstTimeAdoptAPetPopup = null;
      }
      
      private static function onGoNowBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openAvatarEditor(null,true);
         onFirstTimeAdoptAPetClose(param1);
      }
   }
}

