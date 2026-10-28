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
      
      public function SBScreen(param1:MovieClip, param2:SBWizard)
      {
         super();
         this.screenClip = param1;
         this.parentWizard = param2;
      }
      
      public function destroy() : void
      {
         this.screenClip = null;
         this.parentWizard = null;
      }
   }
}

