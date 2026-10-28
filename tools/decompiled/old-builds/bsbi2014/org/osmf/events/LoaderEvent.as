package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   public class LoaderEvent extends Event
   {
      
      public static const LOAD_STATE_CHANGE:String = "loadStateChange";
      
      private var _loader:LoaderBase;
      
      private var _loadTrait:LoadTrait;
      
      private var _oldState:String;
      
      private var _newState:String;
      
      public function LoaderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, loader:LoaderBase = null, loadTrait:LoadTrait = null, oldState:String = null, newState:String = null)
      {
         super(type,bubbles,cancelable);
         this._loader = loader;
         this._loadTrait = loadTrait;
         this._oldState = oldState;
         this._newState = newState;
      }
      
      public function get loader() : LoaderBase
      {
         return this._loader;
      }
      
      public function get loadTrait() : LoadTrait
      {
         return this._loadTrait;
      }
      
      public function get oldState() : String
      {
         return this._oldState;
      }
      
      public function get newState() : String
      {
         return this._newState;
      }
      
      override public function clone() : Event
      {
         return new LoaderEvent(type,bubbles,cancelable,this.loader,this.loadTrait,this.oldState,this.newState);
      }
   }
}

