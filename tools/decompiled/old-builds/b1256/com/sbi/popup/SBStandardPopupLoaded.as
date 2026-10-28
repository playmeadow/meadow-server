package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import gui.DarkenManager;
   import loader.MediaHelper;
   
   public dynamic class SBStandardPopupLoaded
   {
      
      private var _popupMediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _top:MovieClip;
      
      private var _bot:MovieClip;
      
      private var _mid:MovieClip;
      
      public function SBStandardPopupLoaded(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:Boolean = true)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _popupMediaHelper = new MediaHelper();
         _popupMediaHelper.init(param4 ? 4151 : 4150,onMediaLoaded,{
            "parent":param1,
            "message":param2,
            "darken":param3
         });
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _popup = param1.getChildAt(0) as MovieClip;
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
            _popup.x = 900 * 0.5;
            _popup.y = 550 * 0.5;
            if(param1.passback.message)
            {
               _popup.txt.autoSize = "center";
               _popup.txt.text = param1.passback.message;
            }
            _top = _popup.t;
            _mid = _popup.m;
            _bot = _popup.b;
            resize();
            param1.passback.parent.addChild(_popup);
            if(param1.passback.darken)
            {
               DarkenManager.darken(_popup);
            }
         }
      }
      
      private function resize() : void
      {
         _mid.height = Math.floor(_popup.txt.height);
         _top.y = _mid.y - _top.height;
         _bot.y = _mid.y + _mid.height;
         _popup.txt.y = _mid.y;
      }
   }
}

