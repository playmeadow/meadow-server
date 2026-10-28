package gui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import loader.MediaHelper;
   
   public class UpsellManager
   {
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _closeCallBack:Function;
      
      private static var _upsellMC:MovieClip;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _mediaHelpers:Array;
      
      private static var _maxPetsFunc:Function;
      
      public static const EXTRA_DIAMONDS_AS_MEMBER:int = -1;
      
      public static const JAG:int = 1;
      
      public static const EMOTES:int = 2;
      
      public static const ANIMALS:int = 3;
      
      public static const ANIMAL_SLOTS:int = 4;
      
      public static const NAMEBARS:int = 5;
      
      public static const DENS:int = 6;
      
      public static const DEN_ITEMS:int = 7;
      
      public static const ACC_COLOR_CHANGES:int = 8;
      
      public static const ACCESSORIES:int = 9;
      
      public static const PETS:int = 10;
      
      public static const DEN_AUDIO:int = 11;
      
      public static const DEN_ITEM_COLORS:int = 12;
      
      public static const OCEAN:int = 13;
      
      public static const EXTRA_DEN_ITEMS:int = 14;
      
      public static const DIAMONDS:int = 15;
      
      public static const ADVENTURES:int = 16;
      
      private static const UPSELL_MEDIA_ID:int = 1114;
      
      private static const EXTRA_DIAMONDS_MEDIA_ID:int = 2216;
      
      public function UpsellManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:Function = null) : void
      {
         _guiLayer = param1;
         _maxPetsFunc = param2;
         _mediaHelpers = [];
      }
      
      public static function destroy() : void
      {
         if(_closeCallBack != null)
         {
            _closeCallBack = null;
         }
      }
      
      public static function displayPopup(param1:int, param2:String, param3:Function = null, param4:String = null, param5:Boolean = false) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/upsell/#" + param2);
         _closeCallBack = param3;
         DarkenManager.showLoadingSpiral(true);
         loadPopup(param1,param5);
      }
      
      private static function loadPopup(param1:int, param2:Boolean = false) : void
      {
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(param1 == EXTRA_DIAMONDS_AS_MEMBER ? uint(EXTRA_DIAMONDS_MEDIA_ID) : uint(UPSELL_MEDIA_ID),onUpsellLoaded,{
            "m":param1,
            "s":param2
         });
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      private static function onUpsellLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_upsellMC)
         {
            onLoadUpsellClose(null);
         }
         if(param1)
         {
            _upsellMC = MovieClip(param1.getChildAt(0));
            _upsellMC.x = MainFrame.VIEW_WIDTH * 0.5;
            _upsellMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            _upsellMC.msgId = param1.passback["m"];
            if(!param1.passback["s"])
            {
               _guiLayer.addChild(_upsellMC);
            }
            else
            {
               gMainFrame.stage.addChild(_upsellMC);
            }
            DarkenManager.darken(_upsellMC);
            if(param1.passback.m != EXTRA_DIAMONDS_AS_MEMBER)
            {
               _upsellMC.gotoAndStop(_upsellMC.msgId);
               _upsellMC.lBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtns,false,0,true);
               _upsellMC.rBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtns,false,0,true);
               _upsellMC.joinClubBtn.addEventListener(MouseEvent.MOUSE_DOWN,onJoin,false,0,true);
            }
            _upsellMC.bx.addEventListener(MouseEvent.MOUSE_DOWN,onLoadUpsellClose,false,0,true);
            _upsellMC.addEventListener(MouseEvent.MOUSE_DOWN,onLoadPopup,false,0,true);
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
         }
      }
      
      private static function onLoadUpsellClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         SBTracker.pop();
         if(_upsellMC.parent)
         {
            _upsellMC.parent.removeChild(_upsellMC);
         }
         DarkenManager.unDarken(_upsellMC);
         if(_upsellMC.msgId != EXTRA_DIAMONDS_AS_MEMBER)
         {
            _upsellMC.lBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtns);
            _upsellMC.rBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtns);
            _upsellMC.joinClubBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onJoin);
         }
         _upsellMC.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onLoadUpsellClose);
         _upsellMC.removeEventListener(MouseEvent.MOUSE_DOWN,onLoadPopup);
         _upsellMC = null;
      }
      
      private static function onLeftRightBtns(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = param1.currentTarget == _upsellMC.lBtn ? -1 : 1;
         if(_upsellMC.currentFrame + _loc2_ <= 0)
         {
            _upsellMC.gotoAndStop(_upsellMC.currentLabels.length);
         }
         else if(_upsellMC.currentFrame + _loc2_ > _upsellMC.currentLabels.length)
         {
            _upsellMC.gotoAndStop(1);
         }
         else
         {
            _upsellMC.gotoAndStop(_upsellMC.currentFrame + _loc2_);
         }
      }
      
      private static function onLoadPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onJoin(param1:MouseEvent) : void
      {
         var url:String;
         var request:URLRequest;
         var e:MouseEvent = param1;
         if(e)
         {
            e.stopPropagation();
         }
         url = gMainFrame.clientInfo.websiteURL + "membership";
         request = new URLRequest(url);
         try
         {
            navigateToURL(request,"_blank");
            if(_upsellMC)
            {
               onLoadUpsellClose(e);
            }
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error with loading URL");
         }
      }
   }
}

