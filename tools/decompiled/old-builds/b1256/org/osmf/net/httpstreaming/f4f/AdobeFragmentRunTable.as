package org.osmf.net.httpstreaming.f4f
{
   internal class AdobeFragmentRunTable extends FullBox
   {
      
      private var _timeScale:uint;
      
      private var _qualitySegmentURLModifiers:Vector.<String>;
      
      private var _fragmentDurationPairs:Vector.<FragmentDurationPair>;
      
      public function AdobeFragmentRunTable()
      {
         super();
         _fragmentDurationPairs = new Vector.<FragmentDurationPair>();
      }
      
      public function get timeScale() : uint
      {
         return _timeScale;
      }
      
      public function set timeScale(param1:uint) : void
      {
         _timeScale = param1;
      }
      
      public function get qualitySegmentURLModifiers() : Vector.<String>
      {
         return _qualitySegmentURLModifiers;
      }
      
      public function set qualitySegmentURLModifiers(param1:Vector.<String>) : void
      {
         _qualitySegmentURLModifiers = param1;
      }
      
      public function get fragmentDurationPairs() : Vector.<FragmentDurationPair>
      {
         return _fragmentDurationPairs;
      }
      
      public function addFragmentDurationPair(param1:FragmentDurationPair) : void
      {
         _fragmentDurationPairs.push(param1);
      }
      
      public function findFragmentIdByTime(param1:Number, param2:Number, param3:Boolean = false) : FragmentAccessInformation
      {
         var _loc5_:* = 0;
         if(_fragmentDurationPairs.length <= 0)
         {
            return null;
         }
         var _loc4_:FragmentDurationPair = null;
         _loc5_ = 1;
         while(_loc5_ < _fragmentDurationPairs.length)
         {
            _loc4_ = _fragmentDurationPairs[_loc5_];
            if(_loc4_.durationAccrued >= param1)
            {
               return validateFragment(calculateFragmentId(_fragmentDurationPairs[_loc5_ - 1],param1),param2,param3);
            }
            _loc5_++;
         }
         return validateFragment(calculateFragmentId(_fragmentDurationPairs[_fragmentDurationPairs.length - 1],param1),param2,param3);
      }
      
      public function validateFragment(param1:uint, param2:Number, param3:Boolean = false) : FragmentAccessInformation
      {
         var _loc11_:* = 0;
         var _loc8_:FragmentDurationPair = null;
         var _loc9_:FragmentDurationPair = null;
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc5_:FragmentDurationPair = null;
         var _loc12_:uint = _fragmentDurationPairs.length - 1;
         var _loc4_:FragmentAccessInformation = null;
         _loc11_ = 0;
         while(_loc11_ < _loc12_)
         {
            _loc8_ = _fragmentDurationPairs[_loc11_];
            _loc9_ = _fragmentDurationPairs[_loc11_ + 1];
            if(_loc8_.firstFragment <= param1 && param1 < _loc9_.firstFragment)
            {
               if(_loc8_.duration <= 0)
               {
                  _loc4_ = getNextValidFragment(_loc11_ + 1,param2);
               }
               else
               {
                  _loc4_ = new FragmentAccessInformation();
                  _loc4_.fragId = param1;
                  _loc4_.fragDuration = _loc8_.duration;
                  _loc4_.fragmentEndTime = _loc8_.durationAccrued + _loc8_.duration * (param1 - _loc8_.firstFragment + 1);
               }
               break;
            }
            if(_loc8_.firstFragment <= param1 && endOfStreamEntry(_loc9_))
            {
               if(_loc8_.duration > 0)
               {
                  _loc7_ = param2 - _loc8_.durationAccrued;
                  _loc6_ = (param1 - _loc8_.firstFragment + 1) * _loc8_.duration;
                  _loc10_ = (param1 - _loc8_.firstFragment) * _loc8_.duration;
                  if(_loc7_ > _loc10_)
                  {
                     if(!param3 || _loc10_ + _loc8_.duration + _loc8_.durationAccrued <= param2)
                     {
                        _loc4_ = new FragmentAccessInformation();
                        _loc4_.fragId = param1;
                        _loc4_.fragDuration = _loc8_.duration;
                        if(_loc7_ >= _loc6_)
                        {
                           _loc4_.fragmentEndTime = _loc8_.durationAccrued + _loc6_;
                        }
                        else
                        {
                           _loc4_.fragmentEndTime = _loc8_.durationAccrued + _loc7_;
                        }
                        break;
                     }
                  }
               }
            }
            _loc11_++;
         }
         if(_loc4_ == null)
         {
            _loc5_ = _fragmentDurationPairs[_loc12_];
            if(_loc5_.duration > 0 && param1 >= _loc5_.firstFragment)
            {
               _loc7_ = param2 - _loc5_.durationAccrued;
               _loc6_ = (param1 - _loc5_.firstFragment + 1) * _loc5_.duration;
               _loc10_ = (param1 - _loc5_.firstFragment) * _loc5_.duration;
               if(_loc7_ > _loc10_)
               {
                  if(!param3 || _loc10_ + _loc5_.duration + _loc5_.durationAccrued <= param2)
                  {
                     _loc4_ = new FragmentAccessInformation();
                     _loc4_.fragId = param1;
                     _loc4_.fragDuration = _loc5_.duration;
                     if(_loc7_ >= _loc6_)
                     {
                        _loc4_.fragmentEndTime = _loc5_.durationAccrued + _loc6_;
                     }
                     else
                     {
                        _loc4_.fragmentEndTime = _loc5_.durationAccrued + _loc7_;
                     }
                  }
               }
            }
         }
         return _loc4_;
      }
      
      private function getNextValidFragment(param1:uint, param2:Number) : FragmentAccessInformation
      {
         var _loc5_:* = 0;
         var _loc4_:FragmentDurationPair = null;
         var _loc3_:FragmentAccessInformation = null;
         _loc5_ = param1;
         while(_loc5_ < _fragmentDurationPairs.length)
         {
            _loc4_ = _fragmentDurationPairs[_loc5_];
            if(_loc4_.duration > 0)
            {
               _loc3_ = new FragmentAccessInformation();
               _loc3_.fragId = _loc4_.firstFragment;
               _loc3_.fragDuration = _loc4_.duration;
               _loc3_.fragmentEndTime = _loc4_.durationAccrued + _loc4_.duration;
               break;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      private function endOfStreamEntry(param1:FragmentDurationPair) : Boolean
      {
         return param1.duration == 0 && param1.discontinuityIndicator == 0;
      }
      
      public function fragmentsLeft(param1:uint, param2:Number) : uint
      {
         if(_fragmentDurationPairs == null || _fragmentDurationPairs.length == 0)
         {
            return 0;
         }
         var _loc4_:FragmentDurationPair = _fragmentDurationPairs[fragmentDurationPairs.length - 1] as FragmentDurationPair;
         return uint((param2 - _loc4_.durationAccrued) / _loc4_.duration + _loc4_.firstFragment - param1 - 1);
      }
      
      public function tableComplete() : Boolean
      {
         if(_fragmentDurationPairs == null || _fragmentDurationPairs.length <= 0)
         {
            return false;
         }
         var _loc1_:FragmentDurationPair = _fragmentDurationPairs[fragmentDurationPairs.length - 1] as FragmentDurationPair;
         return _loc1_.duration == 0 && _loc1_.discontinuityIndicator == 0;
      }
      
      public function adjustEndEntryDurationAccrued(param1:Number) : void
      {
         var _loc2_:FragmentDurationPair = _fragmentDurationPairs[_fragmentDurationPairs.length - 1];
         if(_loc2_.duration == 0)
         {
            _loc2_.durationAccrued = param1;
         }
      }
      
      private function findValidFragmentDurationPair(param1:uint) : FragmentDurationPair
      {
         var _loc3_:* = 0;
         var _loc2_:FragmentDurationPair = null;
         _loc3_ = param1;
         while(param1 < _fragmentDurationPairs.length)
         {
            _loc2_ = _fragmentDurationPairs[_loc3_];
            if(_loc2_.duration > 0)
            {
               return _loc2_;
            }
            _loc3_++;
         }
         return null;
      }
      
      private function calculateFragmentId(param1:FragmentDurationPair, param2:Number) : uint
      {
         if(param1.duration <= 0)
         {
            return param1.firstFragment;
         }
         var _loc4_:Number = param2 - param1.durationAccrued;
         var _loc3_:uint = _loc4_ > 0 ? _loc4_ / param1.duration : 1;
         if(_loc4_ % param1.duration > 0)
         {
            _loc3_++;
         }
         return param1.firstFragment + _loc3_ - 1;
      }
   }
}

