package org.osmf.media
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   internal class MediaTraitResolver extends EventDispatcher
   {
      
      private var _type:String;
      
      private var _resolvedTrait:MediaTraitBase;
      
      public function MediaTraitResolver(param1:String)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this._type = param1;
      }
      
      final public function get type() : String
      {
         return this._type;
      }
      
      final protected function setResolvedTrait(param1:MediaTraitBase) : void
      {
         if(param1 != this._resolvedTrait)
         {
            if(this._resolvedTrait)
            {
               this._resolvedTrait = null;
               dispatchEvent(new Event(Event.CHANGE));
            }
            this._resolvedTrait = param1;
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      final public function get resolvedTrait() : MediaTraitBase
      {
         return this._resolvedTrait;
      }
      
      final public function addTrait(param1:MediaTraitBase) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(param1.traitType != this.type)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         this.processAddTrait(param1);
      }
      
      final public function removeTrait(param1:MediaTraitBase) : MediaTraitBase
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(param1.traitType != this.type)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this.processRemoveTrait(param1);
      }
      
      protected function processAddTrait(param1:MediaTraitBase) : void
      {
      }
      
      protected function processRemoveTrait(param1:MediaTraitBase) : MediaTraitBase
      {
         return null;
      }
   }
}

