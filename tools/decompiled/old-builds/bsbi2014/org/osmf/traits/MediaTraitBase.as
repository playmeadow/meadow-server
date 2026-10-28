package org.osmf.traits
{
   import flash.events.EventDispatcher;
   
   public class MediaTraitBase extends EventDispatcher
   {
      
      private var _traitType:String;
      
      public function MediaTraitBase(traitType:String)
      {
         super();
         this._traitType = traitType;
      }
      
      public function get traitType() : String
      {
         return this._traitType;
      }
      
      public function dispose() : void
      {
      }
   }
}

