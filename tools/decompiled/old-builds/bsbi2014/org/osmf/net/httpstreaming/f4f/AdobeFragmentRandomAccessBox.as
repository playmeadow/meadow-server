package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class AdobeFragmentRandomAccessBox extends FullBox
   {
      
      private var _timeScale:uint;
      
      private var _localRandomAccessEntries:Vector.<LocalRandomAccessEntry>;
      
      private var _globalRandomAccessEntries:Vector.<GlobalRandomAccessEntry>;
      
      public function AdobeFragmentRandomAccessBox()
      {
         super();
      }
      
      public function get timeScale() : uint
      {
         return this._timeScale;
      }
      
      public function set timeScale(value:uint) : void
      {
         this._timeScale = value;
      }
      
      public function get localRandomAccessEntries() : Vector.<LocalRandomAccessEntry>
      {
         return this._localRandomAccessEntries;
      }
      
      public function set localRandomAccessEntries(value:Vector.<LocalRandomAccessEntry>) : void
      {
         this._localRandomAccessEntries = value;
      }
      
      public function get globalRandomAccessEntries() : Vector.<GlobalRandomAccessEntry>
      {
         return this._globalRandomAccessEntries;
      }
      
      public function set globalRandomAccessEntries(value:Vector.<GlobalRandomAccessEntry>) : void
      {
         this._globalRandomAccessEntries = value;
      }
      
      public function findNearestKeyFrameOffset(seekToTime:Number) : LocalRandomAccessEntry
      {
         var entry:LocalRandomAccessEntry = null;
         var i:int = this._localRandomAccessEntries.length - 1;
         while(i >= 0)
         {
            entry = this._localRandomAccessEntries[i];
            if(entry.time <= seekToTime)
            {
               return entry;
            }
            i--;
         }
         return null;
      }
   }
}

