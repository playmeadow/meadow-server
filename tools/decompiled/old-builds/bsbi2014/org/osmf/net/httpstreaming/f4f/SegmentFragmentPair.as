package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class SegmentFragmentPair
   {
      
      private var _firstSegment:uint;
      
      private var _fragmentsPerSegment:uint;
      
      private var _fragmentsAccrued:uint;
      
      public function SegmentFragmentPair(firstSegment:uint, fragmentsPerSegment:uint)
      {
         super();
         this._firstSegment = firstSegment;
         this._fragmentsPerSegment = fragmentsPerSegment;
      }
      
      public function get firstSegment() : uint
      {
         return this._firstSegment;
      }
      
      public function get fragmentsPerSegment() : uint
      {
         return this._fragmentsPerSegment;
      }
      
      public function set fragmentsAccrued(v:uint) : void
      {
         this._fragmentsAccrued = v;
      }
      
      public function get fragmentsAccrued() : uint
      {
         return this._fragmentsAccrued;
      }
   }
}

