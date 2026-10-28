package trade
{
   import com.sbi.popup.SBPopupManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class TradeConfirmPopup
   {
      
      public static const TYPE_NORMAL:int = 0;
      
      public static const TYPE_RARE:int = 1;
      
      public static const TYPE_RARES:int = 2;
      
      public static const TYPE_DIAMOND:int = 3;
      
      public static const TYPE_DIAMONDS:int = 4;
      
      public static const TYPE_RARE_DIAMOND:int = 5;
      
      private static const TRADE_POPUP_MEDIA_ID:int = 3891;
      
      private var _mediaHelper:MediaHelper;
      
      private var _parentLayer:DisplayObjectContainer;
      
      private var _type:int;
      
      private var _confirmCallback:Function;
      
      private var _passback:Object;
      
      private var _confirmPopup:MovieClip;
      
      private var _frameName:String;
      
      public function TradeConfirmPopup(param1:DisplayObjectContainer, param2:int, param3:Function = null, param4:Object = null)
      {
         super();
         SBPopupManager.nonSBPopups.push(this);
         DarkenManager.showLoadingSpiral(true);
         this._parentLayer = param1;
         this._type = param2;
         switch(this._type)
         {
            case TYPE_RARE:
            case TYPE_RARES:
               this._frameName = "rare";
               break;
            case TYPE_DIAMOND:
            case TYPE_DIAMONDS:
               this._frameName = "diamond";
               break;
            case TYPE_RARE_DIAMOND:
               this._frameName = "rareDiamond";
               break;
            default:
               this._frameName = "reg";
         }
         this._confirmCallback = param3;
         this._passback = param4;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(TRADE_POPUP_MEDIA_ID,this.onPopupLoaded);
      }
      
      public function destroy() : void
      {
         SBPopupManager.destroySpecificNonSBPopup(this);
         this.removeEventListeners();
         DarkenManager.unDarken(this._confirmPopup);
         this._parentLayer.removeChild(this._confirmPopup);
         this._confirmPopup = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         this._confirmPopup = MovieClip(param1.getChildAt(0));
         this._confirmPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._confirmPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         this._parentLayer.addChild(this._confirmPopup);
         DarkenManager.darken(this._confirmPopup);
         this._confirmPopup.gotoAndStop(this._frameName);
         if(this._type == TYPE_RARES)
         {
            LocalizationManager.translateId(this._confirmPopup.popupTxt,21881,true);
         }
         else if(this._type == TYPE_DIAMONDS)
         {
            LocalizationManager.translateId(this._confirmPopup.popupTxt,21882,true);
         }
         this.addEventListeners();
      }
      
      private function addEventListeners() : void
      {
         if(this._confirmPopup)
         {
            this._confirmPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            this._confirmPopup.yesBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onConfirm,false,0,true);
            this._confirmPopup.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onConfirm,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         if(this._confirmPopup)
         {
            this._confirmPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._confirmPopup.yesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onConfirm);
            this._confirmPopup.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onConfirm);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onConfirm(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._confirmCallback != null)
         {
            if(this._passback != null)
            {
               this._confirmCallback(param1.currentTarget == this._confirmPopup.yesBtn,this._passback);
               this._passback = null;
            }
            else
            {
               this._confirmCallback(param1.currentTarget == this._confirmPopup.yesBtn);
            }
            this._confirmCallback = null;
         }
         else
         {
            this.destroy();
         }
      }
   }
}

