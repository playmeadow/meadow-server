package org.osmf.media
{
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   [ExcludeClass]
   public class DefaultTraitResolver extends MediaTraitResolver
   {
      
      private var defaultTrait:MediaTraitBase;
      
      private var trait:MediaTraitBase;
      
      public function DefaultTraitResolver(type:String, defaultTrait:MediaTraitBase)
      {
         super(type);
         if(defaultTrait == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(defaultTrait.traitType != type)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         this.defaultTrait = defaultTrait;
         setResolvedTrait(defaultTrait);
      }
      
      override protected function processAddTrait(instance:MediaTraitBase) : void
      {
         if(this.trait == null)
         {
            setResolvedTrait(this.trait = instance);
         }
      }
      
      override protected function processRemoveTrait(instance:MediaTraitBase) : MediaTraitBase
      {
         var result:MediaTraitBase = null;
         if(Boolean(instance) && instance == this.trait)
         {
            result = this.trait;
            this.trait = null;
            setResolvedTrait(this.defaultTrait);
         }
         return result;
      }
   }
}

