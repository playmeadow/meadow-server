package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class AdobeSegmentRunTable extends FullBox
   {
      
      private var _qualitySegmentURLModifiers:Vector.<String>;
      
      private var _segmentFragmentPairs:Vector.<SegmentFragmentPair>;
      
      public function AdobeSegmentRunTable()
      {
         super();
         this._segmentFragmentPairs = new Vector.<SegmentFragmentPair>();
      }
      
      public function get qualitySegmentURLModifiers() : Vector.<String>
      {
         return this._qualitySegmentURLModifiers;
      }
      
      public function set qualitySegmentURLModifiers(value:Vector.<String>) : void
      {
         this._qualitySegmentURLModifiers = value;
      }
      
      public function get segmentFragmentPairs() : Vector.<SegmentFragmentPair>
      {
         return this._segmentFragmentPairs;
      }
      
      public function addSegmentFragmentPair(sfp:SegmentFragmentPair) : void
      {
         var prevSfp:SegmentFragmentPair = this._segmentFragmentPairs.length <= 0 ? null : this._segmentFragmentPairs[this._segmentFragmentPairs.length - 1];
         var fragmentsAccrued:uint = 0;
         if(prevSfp != null)
         {
            fragmentsAccrued = prevSfp.fragmentsAccrued + (sfp.firstSegment - prevSfp.firstSegment) * prevSfp.fragmentsPerSegment;
         }
         sfp.fragmentsAccrued = fragmentsAccrued;
         this._segmentFragmentPairs.push(sfp);
      }
      
      public function findSegmentIdByFragmentId(fragmentId:uint) : uint
      {
         var curSfp:SegmentFragmentPair = null;
         if(fragmentId < 1)
         {
            return 0;
         }
         for(var i:uint = 1; i < this._segmentFragmentPairs.length; i++)
         {
            curSfp = this._segmentFragmentPairs[i];
            if(curSfp.fragmentsAccrued >= fragmentId)
            {
               return this.calculateSegmentId(this._segmentFragmentPairs[i - 1],fragmentId);
            }
         }
         return this.calculateSegmentId(this._segmentFragmentPairs[this._segmentFragmentPairs.length - 1],fragmentId);
      }
      
      public function get totalFragments() : uint
      {
         return this._segmentFragmentPairs[this._segmentFragmentPairs.length - 1].fragmentsPerSegment + this._segmentFragmentPairs[this._segmentFragmentPairs.length - 1].fragmentsAccrued;
      }
      
      private function calculateSegmentId(sfp:SegmentFragmentPair, fragmentId:uint) : uint
      {
         return sfp.firstSegment + int((fragmentId - sfp.fragmentsAccrued - 1) / sfp.fragmentsPerSegment);
      }
   }
}

