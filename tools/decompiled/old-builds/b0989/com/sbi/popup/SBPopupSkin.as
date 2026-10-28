package com.sbi.popup
{
   import flash.display.MovieClip;
   
   public dynamic class SBPopupSkin
   {
      
      public var s:MovieClip;
      
      public function SBPopupSkin(param1:MovieClip)
      {
         super();
         this.s = param1;
         if(!(Boolean(this.s["c"]) && Boolean(this.s["ba"])))
         {
            throw new Error("skin " + this.s.name + " is missing parts!");
         }
      }
   }
}

