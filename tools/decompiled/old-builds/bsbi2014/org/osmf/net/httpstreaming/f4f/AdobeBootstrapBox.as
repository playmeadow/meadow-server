package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   public class AdobeBootstrapBox extends FullBox
   {
      
      private var _bootstrapVersion:uint;
      
      private var _profile:uint;
      
      private var _live:Boolean;
      
      private var _update:Boolean;
      
      private var _timeScale:uint;
      
      private var _currentMediaTime:Number;
      
      private var _smpteTimeCodeOffset:Number;
      
      private var _movieIdentifier:String;
      
      private var _serverEntryCount:uint;
      
      private var _serverBaseURLs:Vector.<String>;
      
      private var _qualitySegmentURLModifiers:Vector.<String>;
      
      private var _drmData:String;
      
      private var _metadata:String;
      
      private var _segmentRunTables:Vector.<AdobeSegmentRunTable>;
      
      private var _fragmentRunTables:Vector.<AdobeFragmentRunTable>;
      
      public function AdobeBootstrapBox()
      {
         super();
      }
      
      public function get bootstrapVersion() : uint
      {
         return this._bootstrapVersion;
      }
      
      public function set bootstrapVersion(value:uint) : void
      {
         this._bootstrapVersion = value;
      }
      
      public function get profile() : uint
      {
         return this._profile;
      }
      
      public function set profile(value:uint) : void
      {
         this._profile = value;
      }
      
      public function get live() : Boolean
      {
         return this._live;
      }
      
      public function set live(value:Boolean) : void
      {
         this._live = value;
      }
      
      public function get update() : Boolean
      {
         return this._update;
      }
      
      public function set update(value:Boolean) : void
      {
         this._update = value;
      }
      
      public function get timeScale() : uint
      {
         return this._timeScale;
      }
      
      public function set timeScale(value:uint) : void
      {
         this._timeScale = value;
      }
      
      public function get currentMediaTime() : Number
      {
         return this._currentMediaTime;
      }
      
      public function set currentMediaTime(value:Number) : void
      {
         this._currentMediaTime = value;
      }
      
      public function get smpteTimeCodeOffset() : Number
      {
         return this._smpteTimeCodeOffset;
      }
      
      public function set smpteTimeCodeOffset(value:Number) : void
      {
         this._smpteTimeCodeOffset = value;
      }
      
      public function get movieIdentifier() : String
      {
         return this._movieIdentifier;
      }
      
      public function set movieIdentifier(value:String) : void
      {
         this._movieIdentifier = value;
      }
      
      public function get serverBaseURLs() : Vector.<String>
      {
         return this._serverBaseURLs;
      }
      
      public function set serverBaseURLs(value:Vector.<String>) : void
      {
         this._serverBaseURLs = value;
      }
      
      public function get qualitySegmentURLModifiers() : Vector.<String>
      {
         return this._qualitySegmentURLModifiers;
      }
      
      public function set qualitySegmentURLModifiers(value:Vector.<String>) : void
      {
         this._qualitySegmentURLModifiers = value;
      }
      
      public function get drmData() : String
      {
         return this._drmData;
      }
      
      public function set drmData(value:String) : void
      {
         this._drmData = value;
      }
      
      public function get metadata() : String
      {
         return this._metadata;
      }
      
      public function set metadata(value:String) : void
      {
         this._metadata = value;
      }
      
      public function get segmentRunTables() : Vector.<AdobeSegmentRunTable>
      {
         return this._segmentRunTables;
      }
      
      public function set segmentRunTables(value:Vector.<AdobeSegmentRunTable>) : void
      {
         this._segmentRunTables = value;
      }
      
      public function get fragmentRunTables() : Vector.<AdobeFragmentRunTable>
      {
         return this._fragmentRunTables;
      }
      
      public function set fragmentRunTables(value:Vector.<AdobeFragmentRunTable>) : void
      {
         var frt:AdobeFragmentRunTable = null;
         this._fragmentRunTables = value;
         if(value != null && value.length > 0)
         {
            frt = value[value.length - 1];
            frt.adjustEndEntryDurationAccrued(this._currentMediaTime);
         }
      }
      
      public function findSegmentId(fragmentId:uint) : uint
      {
         return this._segmentRunTables[0].findSegmentIdByFragmentId(fragmentId);
      }
      
      public function get totalFragments() : uint
      {
         var afrt:AdobeFragmentRunTable = this._fragmentRunTables[this._fragmentRunTables.length - 1];
         var fdps:Vector.<FragmentDurationPair> = afrt.fragmentDurationPairs;
         var lastValidFdp:FragmentDurationPair = fdps[fdps.length - 1];
         if(lastValidFdp.duration == 0)
         {
            lastValidFdp = fdps[fdps.length - 2];
         }
         var deltaTime:Number = this._currentMediaTime - lastValidFdp.durationAccrued;
         var fragCount:uint = deltaTime <= 0 ? 0 : uint(deltaTime / lastValidFdp.duration);
         return lastValidFdp.firstFragment + fragCount - 1;
      }
      
      public function get totalDuration() : uint
      {
         if(this._fragmentRunTables == null || this._fragmentRunTables.length < 1)
         {
            return 0;
         }
         var frt:AdobeFragmentRunTable = this._fragmentRunTables[0];
         return this._currentMediaTime - frt.fragmentDurationPairs[0].durationAccrued;
      }
      
      public function contentComplete() : Boolean
      {
         var frt:AdobeFragmentRunTable = this._fragmentRunTables[this._fragmentRunTables.length - 1];
         return frt.tableComplete();
      }
   }
}

