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
      
      public static function init(guiLayer:DisplayLayer, maxPetsFunc:Function = null) : void
      {
         _guiLayer = guiLayer;
         _maxPetsFunc = maxPetsFunc;
         _mediaHelpers = [];
      }
      
      public static function destroy() : void
      {
         if(_closeCallBack != null)
         {
            _closeCallBack = null;
         }
      }
      
      public static function displayPopup(msgId:int, gaName:String, callBack:Function = null, roomName:String = null, autoStartShowOnStage:Boolean = false) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/upsell/#" + gaName);
         _closeCallBack = callBack;
         DarkenManager.showLoadingSpiral(true);
         loadPopup(msgId,autoStartShowOnStage);
      }
      
      private static function loadPopup(msgId:int, autoStartShowOnStage:Boolean = false) : void
      {
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(msgId == EXTRA_DIAMONDS_AS_MEMBER ? uint(EXTRA_DIAMONDS_MEDIA_ID) : uint(UPSELL_MEDIA_ID),onUpsellLoaded,{
            "m":msgId,
            "s":autoStartShowOnStage
         });
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      private static function onUpsellLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(_upsellMC))
         {
            onLoadUpsellClose(null);
         }
         if(Boolean(img))
         {
            _upsellMC = MovieClip(img.getChildAt(0));
            _upsellMC.x = MainFrame.VIEW_WIDTH * 0.5;
            _upsellMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            _upsellMC.msgId = img.passback["m"];
            if(!img.passback["s"])
            {
               _guiLayer.addChild(_upsellMC);
            }
            else
            {
               gMainFrame.stage.addChild(_upsellMC);
            }
            DarkenManager.darken(_upsellMC);
            if(img.passback.m != EXTRA_DIAMONDS_AS_MEMBER)
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
      
      private static function onLoadUpsellClose(e:MouseEvent) : void
      {
         if(Boolean(e))
         {
            e.stopPropagation();
         }
         SBTracker.pop();
         if(Boolean(_upsellMC.parent))
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
      
      private static function onLeftRightBtns(e:MouseEvent) : void
      {
         e.stopPropagation();
         var changeValue:int = e.currentTarget == _upsellMC.lBtn ? -1 : 1;
         if(_upsellMC.currentFrame + changeValue <= 0)
         {
            _upsellMC.gotoAndStop(_upsellMC.currentLabels.length);
         }
         else if(_upsellMC.currentFrame + changeValue > _upsellMC.currentLabels.length)
         {
            _upsellMC.gotoAndStop(1);
         }
         else
         {
            _upsellMC.gotoAndStop(_upsellMC.currentFrame + changeValue);
         }
      }
      
      private static function onLoadPopup(e:MouseEvent) : void
      {
         e.stopPropagation();
      }
      
      private static function onJoin(e:MouseEvent) : void
      {
         var url:String;
         var request:URLRequest;
         if(Boolean(e))
         {
            e.stopPropagation();
         }
         url = gMainFrame.clientInfo.websiteURL + "membership";
         request = new URLRequest(url);
         try
         {
            navigateToURL(request,"_blank");
            if(Boolean(_upsellMC))
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

