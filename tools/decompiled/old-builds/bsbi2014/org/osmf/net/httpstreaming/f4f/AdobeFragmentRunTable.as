package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class AdobeFragmentRunTable extends FullBox
   {
      
      private var _timeScale:uint;
      
      private var _qualitySegmentURLModifiers:Vector.<String>;
      
      private var _fragmentDurationPairs:Vector.<FragmentDurationPair>;
      
      public function AdobeFragmentRunTable()
      {
         super();
         this._fragmentDurationPairs = new Vector.<FragmentDurationPair>();
      }
      
      public function get timeScale() : uint
      {
         return this._timeScale;
      }
      
      public function set timeScale(value:uint) : void
      {
         this._timeScale = value;
      }
      
      public function get qualitySegmentURLModifiers() : Vector.<String>
      {
         return this._qualitySegmentURLModifiers;
      }
      
      public function set qualitySegmentURLModifiers(value:Vector.<String>) : void
      {
         this._qualitySegmentURLModifiers = value;
      }
      
      public function get fragmentDurationPairs() : Vector.<FragmentDurationPair>
      {
         return this._fragmentDurationPairs;
      }
      
      public function addFragmentDurationPair(fdp:FragmentDurationPair) : void
      {
         this._fragmentDurationPairs.push(fdp);
      }
      
      public function findFragmentIdByTime(time:Number, totalDuration:Number, live:Boolean = false) : FragmentAccessInformation
      {
         if(this._fragmentDurationPairs.length <= 0)
         {
            return null;
         }
         var fdp:FragmentDurationPair = null;
         for(var i:uint = 1; i < this._fragmentDurationPairs.length; i++)
         {
            fdp = this._fragmentDurationPairs[i];
            if(fdp.durationAccrued >= time)
            {
               return this.validateFragment(this.calculateFragmentId(this._fragmentDurationPairs[i - 1],time),totalDuration,live);
            }
         }
         return this.validateFragment(this.calculateFragmentId(this._fragmentDurationPairs[this._fragmentDurationPairs.length - 1],time),totalDuration,live);
      }
      
      public function validateFragment(fragId:uint, totalDuration:Number, live:Boolean = false) : FragmentAccessInformation
      {
         var curFdp:FragmentDurationPair = null;
         var nextFdp:FragmentDurationPair = null;
         var timeResidue:Number = NaN;
         var timeDistance:Number = NaN;
         var fragStartTime:Number = NaN;
         var lastFdp:FragmentDurationPair = null;
         var size:uint = this._fragmentDurationPairs.length - 1;
         var fai:FragmentAccessInformation = null;
         for(var i:uint = 0; i < size; i++)
         {
            curFdp = this._fragmentDurationPairs[i];
            nextFdp = this._fragmentDurationPairs[i + 1];
            if(curFdp.firstFragment <= fragId && fragId < nextFdp.firstFragment)
            {
               if(curFdp.duration <= 0)
               {
                  fai = this.getNextValidFragment(i + 1,totalDuration);
               }
               else
               {
                  fai = new FragmentAccessInformation();
                  fai.fragId = fragId;
                  fai.fragDuration = curFdp.duration;
                  fai.fragmentEndTime = curFdp.durationAccrued + curFdp.duration * (fragId - curFdp.firstFragment + 1);
               }
               break;
            }
            if(curFdp.firstFragment <= fragId && this.endOfStreamEntry(nextFdp))
            {
               if(curFdp.duration > 0)
               {
                  timeResidue = totalDuration - curFdp.durationAccrued;
                  timeDistance = (fragId - curFdp.firstFragment + 1) * curFdp.duration;
                  fragStartTime = (fragId - curFdp.firstFragment) * curFdp.duration;
                  if(timeResidue > fragStartTime)
                  {
                     if(!live || fragStartTime + curFdp.duration + curFdp.durationAccrued <= totalDuration)
                     {
                        fai = new FragmentAccessInformation();
                        fai.fragId = fragId;
                        fai.fragDuration = curFdp.duration;
                        if(timeResidue >= timeDistance)
                        {
                           fai.fragmentEndTime = curFdp.durationAccrued + timeDistance;
                        }
                        else
                        {
                           fai.fragmentEndTime = curFdp.durationAccrued + timeResidue;
                        }
                        break;
                     }
                  }
               }
            }
         }
         if(fai == null)
         {
            lastFdp = this._fragmentDurationPairs[size];
            if(lastFdp.duration > 0 && fragId >= lastFdp.firstFragment)
            {
               timeResidue = totalDuration - lastFdp.durationAccrued;
               timeDistance = (fragId - lastFdp.firstFragment + 1) * lastFdp.duration;
               fragStartTime = (fragId - lastFdp.firstFragment) * lastFdp.duration;
               if(timeResidue > fragStartTime)
               {
                  if(!live || fragStartTime + lastFdp.duration + lastFdp.durationAccrued <= totalDuration)
                  {
                     fai = new FragmentAccessInformation();
                     fai.fragId = fragId;
                     fai.fragDuration = lastFdp.duration;
                     if(timeResidue >= timeDistance)
                     {
                        fai.fragmentEndTime = lastFdp.durationAccrued + timeDistance;
                     }
                     else
                     {
                        fai.fragmentEndTime = lastFdp.durationAccrued + timeResidue;
                     }
                  }
               }
            }
         }
         return fai;
      }
      
      private function getNextValidFragment(startIdx:uint, totalDuration:Number) : FragmentAccessInformation
      {
         var fdp:FragmentDurationPair = null;
         var fai:FragmentAccessInformation = null;
         for(var i:uint = startIdx; i < this._fragmentDurationPairs.length; i++)
         {
            fdp = this._fragmentDurationPairs[i];
            if(fdp.duration > 0)
            {
               fai = new FragmentAccessInformation();
               fai.fragId = fdp.firstFragment;
               fai.fragDuration = fdp.duration;
               fai.fragmentEndTime = fdp.durationAccrued + fdp.duration;
               break;
            }
         }
         return fai;
      }
      
      private function endOfStreamEntry(fdp:FragmentDurationPair) : Boolean
      {
         return fdp.duration == 0 && fdp.discontinuityIndicator == 0;
      }
      
      public function fragmentsLeft(fragId:uint, currentMediaTime:Number) : uint
      {
         if(this._fragmentDurationPairs == null || this._fragmentDurationPairs.length == 0)
         {
            return 0;
         }
         var fdp:FragmentDurationPair = this._fragmentDurationPairs[this.fragmentDurationPairs.length - 1] as FragmentDurationPair;
         return uint((currentMediaTime - fdp.durationAccrued) / fdp.duration + fdp.firstFragment - fragId - 1);
      }
      
      public function tableComplete() : Boolean
      {
         if(this._fragmentDurationPairs == null || this._fragmentDurationPairs.length <= 0)
         {
            return false;
         }
         var fdp:FragmentDurationPair = this._fragmentDurationPairs[this.fragmentDurationPairs.length - 1] as FragmentDurationPair;
         return fdp.duration == 0 && fdp.discontinuityIndicator == 0;
      }
      
      public function adjustEndEntryDurationAccrued(value:Number) : void
      {
         var fdp:FragmentDurationPair = this._fragmentDurationPairs[this._fragmentDurationPairs.length - 1];
         if(fdp.duration == 0)
         {
            fdp.durationAccrued = value;
         }
      }
      
      private function findValidFragmentDurationPair(index:uint) : FragmentDurationPair
      {
         var fdp:FragmentDurationPair = null;
         for(var i:uint = index; index < this._fragmentDurationPairs.length; i++)
         {
            fdp = this._fragmentDurationPairs[i];
            if(fdp.duration > 0)
            {
               return fdp;
            }
         }
         return null;
      }
      
      private function calculateFragmentId(fdp:FragmentDurationPair, time:Number) : uint
      {
         if(fdp.duration <= 0)
         {
            return fdp.firstFragment;
         }
         var deltaTime:Number = time - fdp.durationAccrued;
         var count:uint = deltaTime > 0 ? uint(deltaTime / fdp.duration) : 1;
         if(deltaTime % fdp.duration > 0)
         {
            count++;
         }
         return fdp.firstFragment + count - 1;
      }
   }
}

