package org.osmf.net
{
   import flash.events.EventDispatcher;
   
   public class NetStreamSwitchManagerBase extends EventDispatcher
   {
      
      private var _autoSwitch:Boolean;
      
      private var _maxAllowedIndex:int;
      
      public function NetStreamSwitchManagerBase()
      {
         super();
         this._autoSwitch = true;
         this._maxAllowedIndex = int.MAX_VALUE;
      }
      
      public function get autoSwitch() : Boolean
      {
         return this._autoSwitch;
      }
      
      public function set autoSwitch(value:Boolean) : void
      {
         this._autoSwitch = value;
      }
      
      public function get currentIndex() : uint
      {
         return 0;
      }
      
      public function get maxAllowedIndex() : int
      {
         return this._maxAllowedIndex;
      }
      
      public function set maxAllowedIndex(value:int) : void
      {
         this._maxAllowedIndex = value;
      }
      
      public function switchTo(index:int) : void
      {
      }
   }
}

