package ru.etcs.utils
{
   import flash.display.LoaderInfo;
   import flash.utils.ByteArray;
   
   public function getDefinitionNames(data:Object, extended:Boolean = false, linkedOnly:Boolean = false) : Array
   {
      var bytes:ByteArray = null;
      if(data is LoaderInfo)
      {
         bytes = (data as LoaderInfo).bytes;
      }
      else
      {
         if(!(data is ByteArray))
         {
            throw new ArgumentError("Error #1001: The specified data is invalid");
         }
         bytes = data as ByteArray;
      }
      var position:uint = bytes.position;
      var finder:Finder = new Finder(bytes);
      bytes.position = position;
      return finder.getDefinitionNames(extended,linkedOnly);
   }
}

import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Endian;

class Finder
{
   
   private var _data:SWFByteArray;
   
   private var _stringTable:Array;
   
   private var _namespaceTable:Array;
   
   private var _multinameTable:Array;
   
   public function Finder(bytes:ByteArray)
   {
      super();
      this._data = new SWFByteArray(bytes);
   }
   
   public function getDefinitionNames(extended:Boolean, linkedOnly:Boolean) : Array
   {
      var tag:uint = 0;
      var id:uint = 0;
      var length:uint = 0;
      var minorVersion:uint = 0;
      var majorVersion:uint = 0;
      var position:uint = 0;
      var name:String = null;
      var index:int = 0;
      var count:uint = 0;
      var definitions:Array = new Array();
      for(; Boolean(this._data.bytesAvailable); this._data.position = position + length)
      {
         tag = uint(this._data.readUnsignedShort());
         id = uint(tag >> 6);
         length = uint(tag & 0x3F);
         length = length == 63 ? uint(this._data.readUnsignedInt()) : length;
         position = uint(this._data.position);
         if(linkedOnly)
         {
            if(id == 76)
            {
               count = uint(this._data.readUnsignedShort());
               while(Boolean(count--))
               {
                  this._data.readUnsignedShort();
                  name = this._data.readString();
                  index = name.lastIndexOf(".");
                  if(index >= 0)
                  {
                     name = name.substr(0,index) + "::" + name.substr(index + 1);
                  }
                  definitions.push(name);
               }
            }
            continue;
         }
         switch(id)
         {
            case 72:
            case 82:
               if(id == 82)
               {
                  this._data.position += 4;
                  this._data.readString();
               }
               minorVersion = uint(this._data.readUnsignedShort());
               majorVersion = uint(this._data.readUnsignedShort());
               if(minorVersion == 16 && majorVersion == 46)
               {
                  definitions.push.apply(definitions,this.getDefinitionNamesInTag(extended));
               }
         }
      }
      return definitions;
   }
   
   private function getDefinitionNamesInTag(extended:Boolean) : Array
   {
      var count:int = 0;
      var kind:uint = 0;
      var id:uint = 0;
      var flags:uint = 0;
      var counter:uint = 0;
      var ns:uint = 0;
      var name:String = null;
      var isInterface:Boolean = false;
      var traits:Array = null;
      var multinameID:uint = 0;
      var params:uint = 0;
      var paramID:uint = 0;
      var paramsCount:int = 0;
      var classesOnly:Boolean = !extended;
      var names:Array = new Array();
      this._stringTable = new Array();
      this._namespaceTable = new Array();
      this._multinameTable = new Array();
      count = this._data.readASInt() - 1;
      while(count > 0 && Boolean(count--))
      {
         this._data.readASInt();
      }
      count = this._data.readASInt() - 1;
      while(count > 0 && Boolean(count--))
      {
         this._data.readASInt();
      }
      count = this._data.readASInt() - 1;
      while(count > 0 && Boolean(count--))
      {
         this._data.readDouble();
      }
      count = this._data.readASInt() - 1;
      id = 1;
      while(count > 0 && Boolean(count--))
      {
         this._stringTable[id] = this._data.readUTFBytes(this._data.readASInt());
         id++;
      }
      count = this._data.readASInt() - 1;
      id = 1;
      while(count > 0 && Boolean(count--))
      {
         kind = uint(this._data.readUnsignedByte());
         ns = uint(this._data.readASInt());
         if(kind == 22)
         {
            this._namespaceTable[id] = ns;
         }
         id++;
      }
      count = this._data.readASInt() - 1;
      while(count > 0 && Boolean(count--))
      {
         for(counter = uint(this._data.readUnsignedByte()); Boolean(counter--); )
         {
            this._data.readASInt();
         }
      }
      count = this._data.readASInt() - 1;
      id = 1;
      while(count > 0 && Boolean(count--))
      {
         kind = uint(this._data.readASInt());
         switch(kind)
         {
            case 7:
            case 13:
               ns = uint(this._data.readASInt());
               this._multinameTable[id] = [ns,this._data.readASInt()];
               break;
            case 15:
            case 16:
               this._multinameTable[id] = [0,this._stringTable[this._data.readASInt()]];
               break;
            case 17:
            case 18:
               break;
            case 9:
            case 14:
               this._multinameTable[id] = [0,this._stringTable[this._data.readASInt()]];
               this._data.readASInt();
               break;
            case 27:
            case 28:
               this._data.readASInt();
               break;
            case 29:
               if(extended)
               {
                  multinameID = uint(this._data.readASInt());
                  params = uint(this._data.readASInt());
                  name = this.getName(multinameID);
                  while(Boolean(params--))
                  {
                     paramID = uint(this._data.readASInt());
                     if(Boolean(name))
                     {
                        name = name + ".<" + this.getName(paramID) + ">";
                        names.push(name);
                     }
                  }
                  this._multinameTable[id] = [0,name];
               }
               else
               {
                  this._data.readASInt();
                  this._data.readASInt();
                  this._data.readASInt();
               }
         }
         id++;
      }
      count = int(this._data.readASInt());
      while(count > 0 && Boolean(count--))
      {
         paramsCount = int(this._data.readASInt());
         counter = uint(paramsCount);
         for(this._data.readASInt(); Boolean(counter--); )
         {
            this._data.readASInt();
         }
         this._data.readASInt();
         flags = uint(this._data.readUnsignedByte());
         if(Boolean(flags & 8))
         {
            counter = uint(this._data.readASInt());
            while(Boolean(counter--))
            {
               this._data.readASInt();
               this._data.readASInt();
            }
         }
         if(Boolean(flags & 0x80))
         {
            for(counter = uint(paramsCount); Boolean(counter--); )
            {
               this._data.readASInt();
            }
         }
      }
      count = int(this._data.readASInt());
      while(count > 0 && Boolean(count--))
      {
         this._data.readASInt();
         counter = uint(this._data.readASInt());
         while(Boolean(counter--))
         {
            this._data.readASInt();
            this._data.readASInt();
         }
      }
      count = int(this._data.readASInt());
      var classCount:uint = uint(count);
      while(count > 0 && Boolean(count--))
      {
         id = uint(this._data.readASInt());
         this._data.readASInt();
         flags = uint(this._data.readUnsignedByte());
         if(Boolean(flags & 8))
         {
            ns = uint(this._data.readASInt());
         }
         isInterface = Boolean(flags & 4);
         for(counter = uint(this._data.readASInt()); Boolean(counter--); )
         {
            this._data.readASInt();
         }
         this._data.readASInt();
         this.readTraits();
         if(classesOnly && !isInterface)
         {
            name = this.getName(id);
            if(Boolean(name))
            {
               names.push(name);
            }
         }
      }
      if(classesOnly)
      {
         return names;
      }
      count = int(classCount);
      while(Boolean(count) && Boolean(count--))
      {
         this._data.readASInt();
         this.readTraits();
      }
      count = int(this._data.readASInt());
      while(Boolean(count) && Boolean(count--))
      {
         this._data.readASInt();
         traits = this.readTraits(true);
         if(Boolean(traits.length))
         {
            names.push.apply(names,traits);
         }
      }
      return names;
   }
   
   private function readTraits(buildNames:Boolean = false) : Array
   {
      var kind:uint = 0;
      var counter:uint = 0;
      var ns:uint = 0;
      var id:uint = 0;
      var names:Array = null;
      var name:String = null;
      var upperBits:uint = 0;
      var lowerBits:uint = 0;
      var traitCount:uint = uint(this._data.readASInt());
      if(buildNames)
      {
         names = [];
      }
      while(Boolean(traitCount--))
      {
         id = uint(this._data.readASInt());
         kind = uint(this._data.readUnsignedByte());
         upperBits = uint(kind >> 4);
         lowerBits = uint(kind & 0x0F);
         this._data.readASInt();
         this._data.readASInt();
         switch(lowerBits)
         {
            case 0:
            case 6:
               if(Boolean(this._data.readASInt()))
               {
                  this._data.readASInt();
               }
         }
         if(buildNames)
         {
            name = this.getName(id);
            if(Boolean(name))
            {
               names.push(name);
            }
         }
         if(Boolean(upperBits & 4))
         {
            for(counter = uint(this._data.readASInt()); Boolean(counter--); )
            {
               this._data.readASInt();
            }
         }
      }
      return names;
   }
   
   private function getName(id:uint) : String
   {
      if(!(id in this._multinameTable))
      {
         return null;
      }
      var mn:Array = this._multinameTable[id] as Array;
      var ns:uint = mn[0] as uint;
      var nsName:String = this._stringTable[this._namespaceTable[ns] as uint] as String;
      var name:String = mn[1] is String ? mn[1] : this._stringTable[mn[1] as uint] as String;
      if(Boolean(nsName) && nsName.indexOf("__AS3__") < 0)
      {
         name = nsName + "::" + name;
      }
      return name;
   }
}

class SWFByteArray extends ByteArray
{
   
   private static const TAG_SWF:String = "FWS";
   
   private static const TAG_SWF_COMPRESSED:String = "CWS";
   
   private var _bitIndex:uint;
   
   private var _version:uint;
   
   private var _frameRate:Number;
   
   private var _rect:Rectangle;
   
   public function SWFByteArray(data:ByteArray = null)
   {
      var endian:String = null;
      var tag:String = null;
      super();
      super.endian = Endian.LITTLE_ENDIAN;
      if(Boolean(data))
      {
         endian = data.endian;
         data.endian = Endian.LITTLE_ENDIAN;
         if(data.bytesAvailable > 26)
         {
            tag = data.readUTFBytes(3);
            if(!(tag == SWFByteArray.TAG_SWF || tag == SWFByteArray.TAG_SWF_COMPRESSED))
            {
               throw new ArgumentError("Error #2124: Loaded file is an unknown type.");
            }
            this._version = data.readUnsignedByte();
            data.readUnsignedInt();
            data.readBytes(this);
            if(tag == SWFByteArray.TAG_SWF_COMPRESSED)
            {
               super.uncompress();
            }
            this.readHeader();
         }
         data.endian = endian;
      }
   }
   
   public function get version() : uint
   {
      return this._version;
   }
   
   public function get frameRate() : Number
   {
      return this._frameRate;
   }
   
   public function get rect() : Rectangle
   {
      return this._rect;
   }
   
   public function writeBytesFromString(bytesHexString:String) : void
   {
      var hexByte:String = null;
      var byte:uint = 0;
      var length:uint = uint(bytesHexString.length);
      for(var i:uint = 0; i < length; i += 2)
      {
         hexByte = bytesHexString.substr(i,2);
         byte = parseInt(hexByte,16);
         writeByte(byte);
      }
   }
   
   public function readRect() : Rectangle
   {
      var pos:uint = uint(super.position);
      var byte:uint = uint(this[pos]);
      var bits:uint = uint(byte >> 3);
      var xMin:Number = this.readBits(bits,5) / 20;
      var xMax:Number = this.readBits(bits) / 20;
      var yMin:Number = this.readBits(bits) / 20;
      var yMax:Number = this.readBits(bits) / 20;
      super.position = pos + Math.ceil((bits * 4 - 3) / 8) + 1;
      return new Rectangle(xMin,yMin,xMax - xMin,yMax - yMin);
   }
   
   public function readBits(length:uint, start:int = -1) : Number
   {
      if(start < 0)
      {
         start = int(this._bitIndex);
      }
      this._bitIndex = start;
      var byte:uint = uint(this[super.position]);
      var out:Number = 0;
      var shift:Number = 0;
      var currentByteBitsLeft:uint = 8 - start;
      var bitsLeft:Number = length - currentByteBitsLeft;
      if(bitsLeft > 0)
      {
         var _loc8_:SWFByteArray = this;
         var _loc9_:Number = _loc8_.super.position + 1;
         _loc8_.super.position = _loc9_;
         out = this.readBits(bitsLeft,0) | (byte & (1 << currentByteBitsLeft) - 1) << bitsLeft;
      }
      else
      {
         out = byte >> 8 - length - start & (1 << length) - 1;
         this._bitIndex = (start + length) % 8;
         if(start + length > 7)
         {
            _loc8_ = this;
            _loc9_ = _loc8_.super.position + 1;
            _loc8_.super.position = _loc9_;
         }
      }
      return out;
   }
   
   public function readASInt() : int
   {
      var byte:uint = 0;
      var result:uint = 0;
      var i:uint = 0;
      do
      {
         byte = super.readUnsignedByte();
         result |= (byte & 0x7F) << i * 7;
         i += 1;
      }
      while(Boolean(byte & 1 << 7));
      return result;
   }
   
   public function readString() : String
   {
      var i:uint = uint(super.position);
      while(true)
      {
         i = i + 1;
         if(!(Boolean(this[i]) && (Boolean(i))))
         {
            break;
         }
      }
      var str:String = super.readUTFBytes(i - super.position);
      super.position = i + 1;
      return str;
   }
   
   public function traceArray(array:ByteArray) : String
   {
      var str:String = null;
      var out:String = "";
      var pos:uint = array.position;
      var i:uint = 0;
      array.position = 0;
      while(Boolean(array.bytesAvailable))
      {
         str = array.readUnsignedByte().toString(16).toUpperCase();
         str = str.length < 2 ? "0" + str : str;
         out += str + " ";
      }
      array.position = pos;
      return out;
   }
   
   private function readFrameRate() : void
   {
      var fixed:Number = NaN;
      if(this._version < 8)
      {
         this._frameRate = super.readUnsignedShort();
      }
      else
      {
         fixed = super.readUnsignedByte() / 255;
         this._frameRate = super.readUnsignedByte() + fixed;
      }
   }
   
   private function readHeader() : void
   {
      this._rect = this.readRect();
      this.readFrameRate();
      super.readShort();
   }
}
