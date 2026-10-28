package org.osmf.net.httpstreaming.f4f
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   
   [ExcludeClass]
   internal class BoxParser extends EventDispatcher
   {
      
      private static const FULL_BOX_FIELD_FLAGS_LENGTH:uint = 3;
      
      private static const AFRA_MASK_LONG_ID:uint = 128;
      
      private static const AFRA_MASK_LONG_OFFSET:uint = 64;
      
      private static const AFRA_MASK_GLOBAL_ENTRIES:uint = 32;
      
      private var _ba:ByteArray;
      
      public function BoxParser()
      {
         super();
         this._ba = null;
      }
      
      public function init(ba:ByteArray) : void
      {
         this._ba = ba;
         this._ba.position = 0;
      }
      
      public function getNextBoxInfo() : BoxInfo
      {
         if(this._ba == null || this._ba.bytesAvailable < F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH)
         {
            return null;
         }
         var size:Number = this._ba.readUnsignedInt();
         var type:String = this._ba.readUTFBytes(F4FConstants.FIELD_TYPE_LENGTH);
         return new BoxInfo(size,type);
      }
      
      public function getBoxes() : Vector.<Box>
      {
         var abst:AdobeBootstrapBox = null;
         var afra:AdobeFragmentRandomAccessBox = null;
         var mdat:MediaDataBox = null;
         var boxes:Vector.<Box> = new Vector.<Box>();
         var bi:BoxInfo = this.getNextBoxInfo();
         while(bi != null)
         {
            if(bi.type == F4FConstants.BOX_TYPE_ABST)
            {
               abst = new AdobeBootstrapBox();
               this.parseAdobeBootstrapBox(bi,abst);
               boxes.push(abst);
            }
            else if(bi.type == F4FConstants.BOX_TYPE_AFRA)
            {
               afra = new AdobeFragmentRandomAccessBox();
               this.parseAdobeFragmentRandomAccessBox(bi,afra);
               boxes.push(afra);
            }
            else if(bi.type == F4FConstants.BOX_TYPE_MDAT)
            {
               mdat = new MediaDataBox();
               this.parseMediaDataBox(bi,mdat);
               boxes.push(mdat);
            }
            else
            {
               this._ba.position = this._ba.position + bi.size - (F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH);
            }
            bi = this.getNextBoxInfo();
            if(bi != null && bi.size <= 0)
            {
               break;
            }
         }
         return boxes;
      }
      
      public function readFragmentRandomAccessBox(bi:BoxInfo) : AdobeFragmentRandomAccessBox
      {
         var afra:AdobeFragmentRandomAccessBox = new AdobeFragmentRandomAccessBox();
         this.parseAdobeFragmentRandomAccessBox(bi,afra);
         return afra;
      }
      
      public function readAdobeBootstrapBox(bi:BoxInfo) : AdobeBootstrapBox
      {
         var abst:AdobeBootstrapBox = new AdobeBootstrapBox();
         this.parseAdobeBootstrapBox(bi,abst);
         return abst;
      }
      
      internal function readLongUIntToNumber() : Number
      {
         if(this._ba == null || this._ba.bytesAvailable < 8)
         {
            throw new IllegalOperationError("not enough length for readLongUIntToNumer");
         }
         var result:Number = this._ba.readUnsignedInt();
         result *= 4294967296;
         return result + this._ba.readUnsignedInt();
      }
      
      private function readUnsignedInt() : uint
      {
         if(this._ba == null || this._ba.bytesAvailable < 4)
         {
            throw new IllegalOperationError("not enough length for readUnsignedInt");
         }
         return this._ba.readUnsignedInt();
      }
      
      private function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0) : void
      {
         if(this._ba == null || this._ba.bytesAvailable < length)
         {
            throw new IllegalOperationError("not enough length for readBytes: " + length);
         }
         return this._ba.readBytes(bytes,offset,length);
      }
      
      private function readUnsignedByte() : uint
      {
         if(this._ba == null || this._ba.bytesAvailable < 1)
         {
            throw new IllegalOperationError("not enough length for readUnsingedByte");
         }
         return this._ba.readUnsignedByte();
      }
      
      private function readBytesToUint(length:uint) : uint
      {
         var byte:uint = 0;
         if(this._ba == null || this._ba.bytesAvailable < length)
         {
            throw new IllegalOperationError("not enough length for readUnsingedByte");
         }
         if(length > 4)
         {
            throw new IllegalOperationError("number of bytes to read must be equal or less than 4");
         }
         var result:uint = 0;
         for(var i:uint = 0; i < length; i++)
         {
            result <<= 8;
            byte = this._ba.readUnsignedByte();
            result += byte;
         }
         return result;
      }
      
      private function readString() : String
      {
         var c:uint = 0;
         var pos:uint = this._ba.position;
         while(this._ba.position < this._ba.length)
         {
            c = uint(this._ba.readByte());
            if(c == 0)
            {
               break;
            }
         }
         var length:uint = this._ba.position - pos;
         this._ba.position = pos;
         return this._ba.readUTFBytes(length);
      }
      
      private function parseBox(boxInfo:BoxInfo, box:Box) : void
      {
         var extendedType:ByteArray = null;
         var size:Number = boxInfo.size;
         var boxLength:uint = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH;
         if(boxInfo.size == F4FConstants.FLAG_USE_LARGE_SIZE)
         {
            size = this.readLongUIntToNumber();
            boxLength += F4FConstants.FIELD_LARGE_SIZE_LENGTH;
         }
         if(boxInfo.type == F4FConstants.EXTENDED_TYPE)
         {
            extendedType = new ByteArray();
            this.readBytes(extendedType,0,F4FConstants.FIELD_EXTENDED_TYPE_LENGTH);
            boxLength += F4FConstants.FIELD_EXTENDED_TYPE_LENGTH;
         }
         box.size = size;
         box.type = boxInfo.type;
         box.boxLength = boxLength;
      }
      
      private function parseFullBox(boxInfo:BoxInfo, fullBox:FullBox) : void
      {
         this.parseBox(boxInfo,fullBox);
         fullBox.version = this.readUnsignedByte();
         fullBox.flags = this.readBytesToUint(FULL_BOX_FIELD_FLAGS_LENGTH);
      }
      
      private function parseAdobeBootstrapBox(boxInfo:BoxInfo, abst:AdobeBootstrapBox) : void
      {
         var asrt:AdobeSegmentRunTable = null;
         var afrt:AdobeFragmentRunTable = null;
         this.parseFullBox(boxInfo,abst);
         abst.bootstrapVersion = this.readUnsignedInt();
         var temp:uint = this.readUnsignedByte();
         abst.profile = temp >> 6;
         abst.live = (temp & 0x20) == 32;
         abst.update = (temp & 1) == 1;
         abst.timeScale = this.readUnsignedInt();
         abst.currentMediaTime = this.readLongUIntToNumber();
         abst.smpteTimeCodeOffset = this.readLongUIntToNumber();
         abst.movieIdentifier = this.readString();
         var serverEntryCount:uint = this.readUnsignedByte();
         var serverBaseURLs:Vector.<String> = new Vector.<String>();
         for(var i:int = 0; i < serverEntryCount; i++)
         {
            serverBaseURLs.push(this.readString());
         }
         abst.serverBaseURLs = serverBaseURLs;
         var qualityEntryCount:uint = this.readUnsignedByte();
         var qualitySegmentURLModifiers:Vector.<String> = new Vector.<String>();
         for(i = 0; i < qualityEntryCount; i++)
         {
            qualitySegmentURLModifiers.push(this.readString());
         }
         abst.qualitySegmentURLModifiers = qualitySegmentURLModifiers;
         abst.drmData = this.readString();
         abst.metadata = this.readString();
         var segmentRunTableCount:uint = this.readUnsignedByte();
         var segmentRunTables:Vector.<AdobeSegmentRunTable> = new Vector.<AdobeSegmentRunTable>();
         for(i = 0; i < segmentRunTableCount; i++)
         {
            boxInfo = this.getNextBoxInfo();
            if(boxInfo.type != F4FConstants.BOX_TYPE_ASRT)
            {
               throw new IllegalOperationError("Unexpected data structure: " + boxInfo.type);
            }
            asrt = new AdobeSegmentRunTable();
            this.parseAdobeSegmentRunTable(boxInfo,asrt);
            segmentRunTables.push(asrt);
         }
         abst.segmentRunTables = segmentRunTables;
         var fragmentRunTableCount:uint = this.readUnsignedByte();
         var fragmentRunTables:Vector.<AdobeFragmentRunTable> = new Vector.<AdobeFragmentRunTable>();
         for(i = 0; i < fragmentRunTableCount; i++)
         {
            boxInfo = this.getNextBoxInfo();
            if(boxInfo.type != F4FConstants.BOX_TYPE_AFRT)
            {
               throw new IllegalOperationError("Unexpected data structure: " + boxInfo.type);
            }
            afrt = new AdobeFragmentRunTable();
            this.parseAdobeFragmentRunTable(boxInfo,afrt);
            fragmentRunTables.push(afrt);
         }
         abst.fragmentRunTables = fragmentRunTables;
      }
      
      private function parseAdobeSegmentRunTable(boxInfo:BoxInfo, asrt:AdobeSegmentRunTable) : void
      {
         this.parseFullBox(boxInfo,asrt);
         var qualityEntryCount:uint = this.readUnsignedByte();
         var qualitySegmentURLModifiers:Vector.<String> = new Vector.<String>();
         for(var i:uint = 0; i < qualityEntryCount; i++)
         {
            qualitySegmentURLModifiers.push(this.readString());
         }
         asrt.qualitySegmentURLModifiers = qualitySegmentURLModifiers;
         var entryCount:uint = this.readUnsignedInt();
         for(i = 0; i < entryCount; i++)
         {
            asrt.addSegmentFragmentPair(new SegmentFragmentPair(this.readUnsignedInt(),this.readUnsignedInt()));
         }
      }
      
      private function parseAdobeFragmentRunTable(boxInfo:BoxInfo, afrt:AdobeFragmentRunTable) : void
      {
         var fdp:FragmentDurationPair = null;
         this.parseFullBox(boxInfo,afrt);
         afrt.timeScale = this.readUnsignedInt();
         var qualityEntryCount:uint = this.readUnsignedByte();
         var qualitySegmentURLModifiers:Vector.<String> = new Vector.<String>();
         for(var i:uint = 0; i < qualityEntryCount; i++)
         {
            qualitySegmentURLModifiers.push(this.readString());
         }
         afrt.qualitySegmentURLModifiers = qualitySegmentURLModifiers;
         var entryCount:uint = this.readUnsignedInt();
         for(i = 0; i < entryCount; i++)
         {
            fdp = new FragmentDurationPair();
            this.parseFragmentDurationPair(fdp);
            afrt.addFragmentDurationPair(fdp);
         }
      }
      
      private function parseFragmentDurationPair(fdp:FragmentDurationPair) : void
      {
         fdp.firstFragment = this.readUnsignedInt();
         fdp.durationAccrued = this.readLongUIntToNumber();
         fdp.duration = this.readUnsignedInt();
         if(fdp.duration == 0)
         {
            fdp.discontinuityIndicator = this.readUnsignedByte();
         }
      }
      
      private function parseAdobeFragmentRandomAccessBox(boxInfo:BoxInfo, afra:AdobeFragmentRandomAccessBox) : void
      {
         var lrae:LocalRandomAccessEntry = null;
         var grae:GlobalRandomAccessEntry = null;
         this.parseFullBox(boxInfo,afra);
         var sizes:uint = this.readBytesToUint(1);
         var longIdFields:Boolean = (sizes & AFRA_MASK_LONG_ID) > 0;
         var longOffsetFields:Boolean = (sizes & AFRA_MASK_LONG_OFFSET) > 0;
         var globalEntries:Boolean = (sizes & AFRA_MASK_GLOBAL_ENTRIES) > 0;
         afra.timeScale = this.readUnsignedInt();
         var entryCount:uint = this.readUnsignedInt();
         var localRandomAccessEntries:Vector.<LocalRandomAccessEntry> = new Vector.<LocalRandomAccessEntry>();
         for(var i:uint = 0; i < entryCount; i++)
         {
            lrae = new LocalRandomAccessEntry();
            this.parseLocalRandomAccessEntry(lrae,longOffsetFields);
            localRandomAccessEntries.push(lrae);
         }
         afra.localRandomAccessEntries = localRandomAccessEntries;
         var globalRandomAccessEntries:Vector.<GlobalRandomAccessEntry> = new Vector.<GlobalRandomAccessEntry>();
         if(globalEntries)
         {
            entryCount = this.readUnsignedInt();
            for(i = 0; i < entryCount; i++)
            {
               grae = new GlobalRandomAccessEntry();
               this.parseGlobalRandomAccessEntry(grae,longIdFields,longOffsetFields);
               globalRandomAccessEntries.push(grae);
            }
         }
         afra.globalRandomAccessEntries = globalRandomAccessEntries;
      }
      
      private function parseLocalRandomAccessEntry(lrae:LocalRandomAccessEntry, longOffsetFields:Boolean) : void
      {
         lrae.time = this.readLongUIntToNumber();
         if(longOffsetFields)
         {
            lrae.offset = this.readLongUIntToNumber();
         }
         else
         {
            lrae.offset = this.readUnsignedInt();
         }
      }
      
      private function parseGlobalRandomAccessEntry(grae:GlobalRandomAccessEntry, longIdFields:Boolean, longOffsetFields:Boolean) : void
      {
         grae.time = this.readLongUIntToNumber();
         if(longIdFields)
         {
            grae.segment = this.readUnsignedInt();
            grae.fragment = this.readUnsignedInt();
         }
         else
         {
            grae.segment = this.readBytesToUint(2);
            grae.fragment = this.readBytesToUint(2);
         }
         if(longOffsetFields)
         {
            grae.afraOffset = this.readLongUIntToNumber();
            grae.offsetFromAfra = this.readLongUIntToNumber();
         }
         else
         {
            grae.afraOffset = this.readUnsignedInt();
            grae.offsetFromAfra = this.readUnsignedInt();
         }
      }
      
      private function parseMediaDataBox(boxInfo:BoxInfo, mdat:MediaDataBox) : void
      {
         this.parseBox(boxInfo,mdat);
         var data:ByteArray = new ByteArray();
         this.readBytes(data,0,mdat.size - mdat.boxLength);
         mdat.data = data;
      }
   }
}

