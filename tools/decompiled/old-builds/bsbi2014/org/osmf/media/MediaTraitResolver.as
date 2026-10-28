package org.osmf.media
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="change",type="flash.events.Event")]
   [ExcludeClass]
   internal class MediaTraitResolver extends EventDispatcher
   {
      
      private var _type:String;
      
      private var _resolvedTrait:MediaTraitBase;
      
      public function MediaTraitResolver(type:String)
      {
         super();
         if(type == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this._type = type;
      }
      
      final public function get type() : String
      {
         return this._type;
      }
      
      final protected function setResolvedTrait(value:MediaTraitBase) : void
      {
         if(value != this._resolvedTrait)
         {
            if(Boolean(this._resolvedTrait))
            {
               this._resolvedTrait = null;
               dispatchEvent(new Event(Event.CHANGE));
            }
            this._resolvedTrait = value;
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      final public function get resolvedTrait() : MediaTraitBase
      {
         return this._resolvedTrait;
      }
      
      final public function addTrait(instance:MediaTraitBase) : void
      {
         if(instance == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(instance.traitType != this.type)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         this.processAddTrait(instance);
      }
      
      final public function removeTrait(instance:MediaTraitBase) : MediaTraitBase
      {
         if(instance == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(instance.traitType != this.type)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this.processRemoveTrait(instance);
      }
      
      protected function processAddTrait(instance:MediaTraitBase) : void
      {
      }
      
      protected function processRemoveTrait(instance:MediaTraitBase) : MediaTraitBase
      {
         return null;
      }
   }
}

