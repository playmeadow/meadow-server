package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.containers.IMediaContainer;
   
   public class ContainerChangeEvent extends Event
   {
      
      public static const CONTAINER_CHANGE:String = "containerChange";
      
      private var _oldContainer:IMediaContainer;
      
      private var _newContainer:IMediaContainer;
      
      public function ContainerChangeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, oldContainer:IMediaContainer = null, newContainer:IMediaContainer = null)
      {
         super(type,bubbles,cancelable);
         this._oldContainer = oldContainer;
         this._newContainer = newContainer;
      }
      
      public function get oldContainer() : IMediaContainer
      {
         return this._oldContainer;
      }
      
      public function get newContainer() : IMediaContainer
      {
         return this._newContainer;
      }
      
      override public function clone() : Event
      {
         return new ContainerChangeEvent(type,bubbles,cancelable,this._oldContainer,this._newContainer);
      }
   }
}

