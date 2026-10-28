package com.sbi.popup
{
   import flash.filters.*;
   
   public class SBPopupManager
   {
      
      public static var _selected:SBPopup;
      
      public static var _modalSBPopup:SBPopup;
      
      public static var _prevModalSBPopup:SBPopup;
      
      public static var darken:Function;
      
      public static var lighten:Function;
      
      public static var popups:Array = [];
      
      public static var nonSBPopups:Array = [];
      
      public static var enabled:Boolean = true;
      
      public function SBPopupManager()
      {
         super();
      }
      
      public static function get selected() : SBPopup
      {
         return _selected;
      }
      
      public static function set selected(select:SBPopup) : void
      {
         if(select.selected)
         {
            return;
         }
         select.selected = true;
         _selected = select;
      }
      
      public static function get modalSBPopup() : SBPopup
      {
         return _modalSBPopup;
      }
      
      public static function set modalSBPopup(newModal:SBPopup) : void
      {
         var p:SBPopup = null;
         var tempPrev:SBPopup = null;
         for each(p in popups)
         {
            if(p != newModal)
            {
               p.enabled = newModal == null;
            }
         }
         tempPrev = _prevModalSBPopup;
         if(Boolean(newModal) && Boolean(_modalSBPopup) && newModal != _modalSBPopup)
         {
            _prevModalSBPopup = _modalSBPopup;
         }
         _modalSBPopup = newModal;
         if(_modalSBPopup == null && Boolean(tempPrev))
         {
            _modalSBPopup = tempPrev;
            _prevModalSBPopup = null;
         }
      }
      
      public static function checkModalSBPopup(toCheck:SBPopup, down:Boolean) : Boolean
      {
         if(_modalSBPopup == null)
         {
            return true;
         }
         if(_modalSBPopup != toCheck)
         {
            if(down)
            {
               _modalSBPopup.alpha = 0.5;
            }
            else
            {
               _modalSBPopup.alpha = 1;
            }
            return false;
         }
         return true;
      }
      
      public static function getBlurFilter(blurAmountX:Number = 2, blurAmountY:Number = 2, blurQuality:int = 3) : BlurFilter
      {
         var blurFilter:BlurFilter = new BlurFilter();
         blurFilter.blurX = blurAmountX;
         blurFilter.blurY = blurAmountY;
         blurFilter.quality = blurQuality;
         return blurFilter;
      }
      
      public static function getColorFilter(a:Number = 1, r:Number = 1, g:Number = 1, b:Number = 1) : ColorMatrixFilter
      {
         var colorMatrix:Array = new Array();
         colorMatrix = colorMatrix.concat([r,0,0,0,0]);
         colorMatrix = colorMatrix.concat([0,g,0,0,0]);
         colorMatrix = colorMatrix.concat([0,0,b,0,0]);
         colorMatrix = colorMatrix.concat([0,0,0,a,0]);
         return new ColorMatrixFilter(colorMatrix);
      }
      
      public static function setAllPopupEffects(popupFilters:Array = null) : void
      {
         var p:SBPopup = null;
         for each(p in popups)
         {
            p.setFilters(popupFilters);
         }
      }
      
      public static function setAllModalPopupEffects(popupFilters:Array = null) : void
      {
         var p:SBPopup = null;
         for each(p in popups)
         {
            if(p.modal)
            {
               p.setFilters(popupFilters);
            }
         }
      }
      
      public static function closeAll() : void
      {
         var p:SBPopup = null;
         modalSBPopup = null;
         for each(p in popups)
         {
            if(p.visible)
            {
               p.close();
            }
         }
      }
      
      public static function destroyAll() : void
      {
         var p:SBPopup = null;
         modalSBPopup = null;
         for each(p in popups)
         {
            p.destroy();
         }
         while(popups.length > 0)
         {
            popups.pop();
         }
      }
      
      public static function destroyNonSBPopups() : void
      {
         var p:Object = null;
         for each(p in nonSBPopups)
         {
            p.destroy();
         }
         while(nonSBPopups.length > 0)
         {
            nonSBPopups.pop();
         }
      }
      
      public static function destroySpecificNonSBPopup(o:Object) : void
      {
         for(var i:int = 0; i < nonSBPopups.length; i++)
         {
            if(nonSBPopups[i] == o)
            {
               nonSBPopups.splice(i,1);
               break;
            }
         }
      }
   }
}

