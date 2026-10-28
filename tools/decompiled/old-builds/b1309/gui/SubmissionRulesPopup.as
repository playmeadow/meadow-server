package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import loader.MediaHelper;
   
   public class SubmissionRulesPopup
   {
      
      private const POPUP_MEDIA_ID:uint = 4812;
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _submissionRulesPopup:MovieClip;
      
      private var _guiLayer:DisplayObjectContainer;
      
      private var _cancelBtn:MovieClip;
      
      private var _buyBtn:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _diamondCostText:TextField;
      
      private var _itemCost:int;
      
      public function SubmissionRulesPopup(param1:int, param2:DisplayObjectContainer, param3:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _itemCost = param1;
         _closeCallback = param3;
         _guiLayer = param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4812,onPopupLoaded);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         var _loc2_:Function = null;
         if(_closeCallback != null)
         {
            _loc2_ = _closeCallback;
            _closeCallback = null;
            _loc2_(param1);
            return;
         }
         DarkenManager.unDarken(_submissionRulesPopup);
         _guiLayer.removeChild(_submissionRulesPopup);
         removeEventListeners();
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         _submissionRulesPopup = _closeBtn = _cancelBtn = _buyBtn = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _submissionRulesPopup = param1.getChildAt(0) as MovieClip;
         _diamondCostText = _submissionRulesPopup.diamondTxt;
         _closeBtn = _submissionRulesPopup.bx;
         _cancelBtn = _submissionRulesPopup.cancelBtn;
         _buyBtn = _submissionRulesPopup.buyBtn;
         _diamondCostText.text = "x " + _itemCost;
         _submissionRulesPopup.x = 900 * 0.5;
         _submissionRulesPopup.y = 550 * 0.5;
         _guiLayer.addChild(_submissionRulesPopup);
         DarkenManager.darken(_submissionRulesPopup);
         addEventListeners();
      }
      
      private function addEventListeners() : void
      {
         _submissionRulesPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         _cancelBtn.addEventListener("mouseDown",onBuyCancel,false,0,true);
         _buyBtn.addEventListener("mouseDown",onBuyCancel,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _submissionRulesPopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onClose);
         _cancelBtn.removeEventListener("mouseDown",onBuyCancel);
         _buyBtn.removeEventListener("mouseDown",onBuyCancel);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy(false);
      }
      
      private function onBuyCancel(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _cancelBtn)
         {
            destroy(false);
         }
         else if(param1.currentTarget == _buyBtn)
         {
            destroy(true);
         }
      }
   }
}

