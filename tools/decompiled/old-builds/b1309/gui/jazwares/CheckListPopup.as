package gui.jazwares
{
   import Enums.AdoptAPetDef;
   import adoptAPet.AdoptAPetData;
   import adoptAPet.AdoptAPetManager;
   import adoptAPet.AdoptAPetXtCommManager;
   import collection.AdoptAPetDataCollection;
   import collection.AdoptAPetDefCollection;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowLargeIcon;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class CheckListPopup
   {
      
      private const CHECKLIST_MEDIA_ID:int = 4622;
      
      private var _mediaHelper:MediaHelper;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _checkListPopup:MovieClip;
      
      private var _infoBtn:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _itemWindow:MovieClip;
      
      private var _infoPopup:AdoptAPetInfoPopup;
      
      private var _checkListWindows:WindowAndScrollbarGenerator;
      
      private var _userName:String;
      
      private var _giftCountTxt:TextField;
      
      private var _usableAdoptAPetData:AdoptAPetDataCollection;
      
      public function CheckListPopup()
      {
         super();
      }
      
      public function init(param1:Function, param2:String = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _guiLayer = GuiManager.guiLayer;
         _userName = param2 == null ? gMainFrame.userInfo.myUserName : param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4622,onChecklistMediaLoded);
      }
      
      public function destroy() : void
      {
         var _loc2_:Function = null;
         var _loc1_:Array = null;
         var _loc4_:Array = null;
         var _loc3_:int = 0;
         if(_closeCallback != null)
         {
            _loc2_ = _closeCallback;
            _closeCallback = null;
            _loc2_();
            _loc2_ = null;
            return;
         }
         if(_checkListWindows)
         {
            if(_userName == gMainFrame.userInfo.myUserName)
            {
               _loc1_ = _checkListWindows.mediaWindows;
               _loc4_ = [];
               while(_loc3_ < _loc1_.length)
               {
                  if((_loc1_[_loc3_] as ItemWindowLargeIcon).defIdSeenUpdated != 0)
                  {
                     _loc4_.push((_loc1_[_loc3_] as ItemWindowLargeIcon).defIdSeenUpdated);
                  }
                  _loc3_++;
               }
               _loc1_ = null;
               if(_loc4_.length > 0)
               {
                  AdoptAPetXtCommManager.requestPetAdoptUsableSeenSet(_loc4_);
                  _loc4_ = null;
               }
            }
            _checkListWindows.destroy();
            _checkListWindows = null;
         }
         removeEventListeners();
         _mediaHelper.destroy();
         _mediaHelper = null;
         DarkenManager.unDarken(_checkListPopup);
         _guiLayer.removeChild(_checkListPopup);
         _guiLayer = null;
         _checkListPopup = null;
      }
      
      private function onChecklistMediaLoded(param1:MovieClip) : void
      {
         _checkListPopup = param1.getChildAt(0) as MovieClip;
         _checkListPopup.x = 900 * 0.5;
         _checkListPopup.y = 550 * 0.5;
         _guiLayer.addChild(_checkListPopup);
         DarkenManager.darken(_checkListPopup);
         _closeBtn = _checkListPopup.bx;
         _infoBtn = _checkListPopup.infoBtn;
         _itemWindow = _checkListPopup.itemWindow;
         _giftCountTxt = _checkListPopup.giftBarCont.countTxt;
         _giftCountTxt.text = "0/0";
         addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         if(_userName == gMainFrame.userInfo.myUserName)
         {
            _usableAdoptAPetData = AdoptAPetManager.usableAdoptAPetDataCopy;
            setupCheckListWindows(true);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            AdoptAPetXtCommManager.requestPetAdoptUsableData(_userName,onOtherUserUsableAdoptAPetData);
         }
      }
      
      private function setupCheckListWindows(param1:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc2_:AdoptAPetData = null;
         var _loc4_:AdoptAPetDefCollection = null;
         var _loc3_:AdoptAPetDef = null;
         var _loc5_:int = 0;
         _usableAdoptAPetData.getCoreArray().sortOn("invId",0x10 | 2);
         var _loc7_:Array = [];
         if(param1)
         {
            _loc4_ = new AdoptAPetDefCollection(AdoptAPetManager.allAdoptAPetDefsNonIndexedSortedByName.concatCollection(null));
            _loc6_ = 0;
            while(_loc6_ < _usableAdoptAPetData.length)
            {
               _loc2_ = _usableAdoptAPetData.getAdoptAPetDataItem(_loc6_);
               if(_loc2_)
               {
                  _loc7_.push(_loc2_);
                  _loc5_ = 0;
                  while(_loc5_ < _loc4_.length)
                  {
                     _loc3_ = _loc4_.getAdoptAPetItem(_loc5_);
                     if(_loc3_ && _loc2_.defId == _loc3_.defId)
                     {
                        _loc4_.getCoreArray().splice(_loc5_,1);
                        break;
                     }
                     _loc5_++;
                  }
               }
               _loc6_++;
            }
            _loc7_ = _loc7_.concat(_loc4_.getCoreArray());
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < _usableAdoptAPetData.length)
            {
               _loc2_ = _usableAdoptAPetData.getAdoptAPetDataItem(_loc6_);
               if(_loc2_)
               {
                  _loc7_.push(_loc2_);
               }
               _loc6_++;
            }
         }
         _checkListWindows = new WindowAndScrollbarGenerator();
         _checkListWindows.init(_itemWindow.width,_itemWindow.height,5,0,6,4,0,-3,0,5,2,ItemWindowLargeIcon,_loc7_,"",0,null,{"isForMyself":param1},null,true,false,false,false,false);
         _giftCountTxt.text = AdoptAPetManager.numTieredGiftCount + "/" + AdoptAPetManager.currTierGiftCountAmount;
         _itemWindow.addChild(_checkListWindows);
      }
      
      private function addEventListeners() : void
      {
         _checkListPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _infoBtn.addEventListener("mouseDown",onInfoBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _checkListPopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onCloseBtn);
         _infoBtn.removeEventListener("mouseDown",onInfoBtn);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_infoPopup)
         {
            onInfoPopupClose();
         }
         _infoPopup = new AdoptAPetInfoPopup();
         _infoPopup.init(onInfoPopupClose);
      }
      
      private function onInfoPopupClose() : void
      {
         _infoPopup.destroy();
         _infoPopup = null;
      }
      
      private function onOtherUserUsableAdoptAPetData(param1:Boolean, param2:Object) : void
      {
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _usableAdoptAPetData = new AdoptAPetDataCollection();
            _loc7_ = int(param2[3]);
            _loc4_ = 4;
            _loc6_ = 0;
            while(_loc6_ < _loc7_)
            {
               _loc3_ = int(param2[_loc4_++]);
               _loc5_ = int(param2[_loc4_++]);
               _usableAdoptAPetData.setAdoptAPetDataItem(_loc3_,new AdoptAPetData(AdoptAPetData.defaultAdoptAPetData(_loc3_,_loc5_)));
               _loc6_++;
            }
            setupCheckListWindows(false);
         }
         else
         {
            destroy();
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(11149));
         }
      }
   }
}

