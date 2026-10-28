package gameRedemption
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   
   public class CaptchaPopup
   {
      
      private const POPUP_MEDIA_ID:int = 4821;
      
      private var _closeCallback:Function;
      
      private var _guiLayer:DisplayLayer;
      
      private var _mediaHelper:MediaHelper;
      
      private var _captchaPopup:MovieClip;
      
      private var _itemWindow0:MovieClip;
      
      private var _itemWindow1:MovieClip;
      
      private var _itemWindow2:MovieClip;
      
      private var _itemWindow3:MovieClip;
      
      private var _itemLayer:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _options:Array;
      
      private var _question:String;
      
      private var _chosenAnswer:String;
      
      public function CaptchaPopup()
      {
         super();
      }
      
      public function init(param1:String, param2:Array, param3:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _question = param1;
         _options = param2;
         _closeCallback = param3;
         _guiLayer = GuiManager.guiLayer;
         _chosenAnswer = "";
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4821,onRedemptionPopupLoaded);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         var _loc2_:Function = null;
         if(_closeCallback != null)
         {
            _loc2_ = _closeCallback;
            _closeCallback = null;
            if(_chosenAnswer != null && _chosenAnswer != "")
            {
               _chosenAnswer = _chosenAnswer.match(/.*images\/\s*([^\n\r]*)/)[1];
               _question = _question.match(/.*images\/\s*([^\n\r]*)/)[1];
            }
            _loc2_(param1,_question,_chosenAnswer);
            _loc2_ = null;
            return;
         }
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         if(_captchaPopup)
         {
            removeEventListeners();
            DarkenManager.unDarken(_captchaPopup);
            _guiLayer.removeChild(_captchaPopup);
         }
         _guiLayer = null;
         _captchaPopup = null;
      }
      
      private function onRedemptionPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _captchaPopup = param1.getChildAt(0) as MovieClip;
         _captchaPopup.x = 900 * 0.5;
         _captchaPopup.y = 550 * 0.5;
         _guiLayer.addChild(_captchaPopup);
         DarkenManager.darken(_captchaPopup);
         _itemWindow0 = _captchaPopup.iw0;
         _itemWindow1 = _captchaPopup.iw1;
         _itemWindow2 = _captchaPopup.iw2;
         _itemWindow3 = _captchaPopup.iw3;
         _itemLayer = _captchaPopup.itemBlock;
         _closeBtn = _captchaPopup.bx;
         setupQuestionAndAnswers();
         addEventListeners();
      }
      
      private function setupQuestionAndAnswers() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Loader = new Loader();
         _loc1_.contentLoaderInfo.addEventListener("init",onLoaderInit);
         var _loc2_:URLRequest = new URLRequest(_question);
         _loc1_.load(_loc2_);
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            _loc1_ = new Loader();
            _loc1_.contentLoaderInfo.addEventListener("init",onLoaderInit);
            _loc2_ = new URLRequest(_options[_loc3_]);
            _loc1_.load(_loc2_);
            _loc3_++;
         }
      }
      
      private function addEventListeners() : void
      {
         _captchaPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _itemWindow0.addEventListener("mouseDown",startDragging,true,0,true);
         _itemWindow1.addEventListener("mouseDown",startDragging,true,0,true);
         _itemWindow2.addEventListener("mouseDown",startDragging,true,0,true);
         _itemWindow3.addEventListener("mouseDown",startDragging,true,0,true);
         _itemWindow0.addEventListener("mouseUp",stopDragging,true,0,true);
         _itemWindow1.addEventListener("mouseUp",stopDragging,true,0,true);
         _itemWindow2.addEventListener("mouseUp",stopDragging,true,0,true);
         _itemWindow3.addEventListener("mouseUp",stopDragging,true,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _captchaPopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onCloseBtn);
         _itemWindow0.removeEventListener("mouseDown",startDragging);
         _itemWindow1.removeEventListener("mouseDown",startDragging);
         _itemWindow2.removeEventListener("mouseDown",startDragging);
         _itemWindow3.removeEventListener("mouseDown",startDragging);
         _itemWindow0.removeEventListener("mouseUp",stopDragging);
         _itemWindow1.removeEventListener("mouseUp",stopDragging);
         _itemWindow2.removeEventListener("mouseUp",stopDragging);
         _itemWindow3.removeEventListener("mouseUp",stopDragging);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy(true);
      }
      
      private function startDragging(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.startX)
         {
            param1.currentTarget.startX = param1.currentTarget.x;
            param1.currentTarget.startY = param1.currentTarget.y;
         }
         param1.currentTarget.startDrag();
      }
      
      private function stopDragging(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         (param1.currentTarget as MovieClip).stopDrag();
         if((param1.currentTarget as MovieClip).hitTestObject(_itemLayer))
         {
            _chosenAnswer = _options[(param1.currentTarget.name as String).substring(2)];
            destroy();
         }
         else if(param1.currentTarget.startX)
         {
            param1.currentTarget.x = param1.currentTarget.startX;
            param1.currentTarget.y = param1.currentTarget.startY;
         }
      }
      
      private function onLoaderInit(param1:Event) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc3_:Sprite = null;
         var _loc5_:int = 0;
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         try
         {
            _loc4_ = _loc2_.loader.content;
         }
         catch(err:SecurityError)
         {
            _loc3_ = new Sprite();
            _loc3_.addChild(_loc2_.loader);
            _loc4_ = _loc3_ as DisplayObject;
         }
         if(_loc2_.url == _question)
         {
            _loc4_.x -= _itemLayer.width * 0.5;
            _loc4_.y -= _itemLayer.height * 0.5;
            _itemLayer.addChild(_loc4_);
         }
         else
         {
            _loc5_ = 0;
            while(_loc5_ < _options.length)
            {
               if(_loc2_.url == _options[_loc5_])
               {
                  _loc4_.x -= this["_itemWindow" + _loc5_].width * 0.5;
                  _loc4_.y -= this["_itemWindow" + _loc5_].height * 0.5;
                  this["_itemWindow" + _loc5_].addChild(_loc4_);
               }
               _loc5_++;
            }
         }
      }
   }
}

