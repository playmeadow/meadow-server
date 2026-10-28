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
      
      public function SBScreen(initScreenClip:MovieClip, initParentWizard:SBWizard)
      {
         super();
         this.screenClip = initScreenClip;
         this.parentWizard = initParentWizard;
      }
      
      public function destroy() : void
      {
         this.screenClip = null;
         this.parentWizard = null;
      }
   }
}

