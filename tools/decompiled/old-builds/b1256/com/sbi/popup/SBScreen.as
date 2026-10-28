package com.sbi.popup
{
   import flash.display.MovieClip;
   
   public class SBScreen
   {
      
      public var screenClip:MovieClip;
      
      public var parentWizard:SBWizard;
      
      public var onEnterFromPrev:Function;
      
      public var onEnterFromNext:Function;
      
      public var onLeaveToPrev:Function;
      
      public var onLeaveToNext:Function;
      
      public var onPlay:Function;
      
      public var onClose:Function;
      
      public var updateScreen:Function;
      
      public function SBScreen(param1:MovieClip, param2:SBWizard)
      {
         super();
         screenClip = param1;
         parentWizard = param2;
      }
      
      public function destroy() : void
      {
         screenClip = null;
         parentWizard = null;
      }
   }
}

