package org.osmf.net
{
   import org.osmf.traits.TimeTrait;
   
   [ExcludeClass]
   public class ModifiableTimeTrait extends TimeTrait
   {
      
      public function ModifiableTimeTrait(duration:Number = NaN)
      {
         super(duration);
      }
      
      public function set duration(value:Number) : void
      {
         super.setDuration(value);
      }
   }
}

