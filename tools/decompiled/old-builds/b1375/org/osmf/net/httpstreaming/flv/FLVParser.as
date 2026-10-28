package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   public class FLVParser
   {
      
      private var state:String;
      
      private var savedBytes:ByteArray;
      
      private var currentTag:FLVTag = null;
      
      private var flvHeader:FLVHeader;
      
      public function FLVParser(param1:Boolean)
      {
         super();
         savedBytes = new ByteArray();
         if(param1)
         {
            state = "fileHeader";
         }
         else
         {
            state = "type";
         }
      }
      
      public function flush(param1:IDataOutput) : void
      {
         param1.writeBytes(savedBytes);
      }
      
      public function parse(param1:IDataInput, param2:Boolean, param3:Function) : void
      {
         var _loc4_:IDataInput = null;
         var _loc6_:int = 0;
         var _loc5_:Boolean = true;
         while(_loc5_)
         {
            switch(state)
            {
               case "fileHeader":
                  _loc4_ = byteSource(param1,9);
                  if(_loc4_ != null)
                  {
                     flvHeader = new FLVHeader();
                     flvHeader.readHeader(_loc4_);
                     state = "fileHeaderRest";
                  }
                  else
                  {
                     _loc5_ = false;
                  }
                  break;
               case "fileHeaderRest":
                  _loc4_ = byteSource(param1,flvHeader.restBytesNeeded);
                  if(_loc4_ != null)
                  {
                     flvHeader.readRest(_loc4_);
                     state = "type";
                  }
                  else
                  {
                     _loc5_ = false;
                  }
                  break;
               case "type":
                  _loc4_ = byteSource(param1,1);
                  if(_loc4_ != null)
                  {
                     switch(_loc6_ = _loc4_.readByte())
                     {
                        case 8:
                        case 40:
                           currentTag = new FLVTagAudio(_loc6_);
                           break;
                        case 9:
                        case 41:
                           currentTag = new FLVTagVideo(_loc6_);
                           break;
                        case 18:
                        case 50:
                           currentTag = new FLVTagScriptDataObject(_loc6_);
                           break;
                        default:
                           currentTag = new FLVTag(_loc6_);
                     }
                     state = "header";
                  }
                  else
                  {
                     _loc5_ = false;
                  }
                  break;
               case "header":
                  _loc4_ = byteSource(param1,11 - 1);
                  if(_loc4_ != null)
                  {
                     currentTag.readRemainingHeader(_loc4_);
                     if(currentTag.dataSize)
                     {
                        state = "data";
                     }
                     else
                     {
                        state = "prevTag";
                     }
                  }
                  else
                  {
                     _loc5_ = false;
                  }
                  break;
               case "data":
                  _loc4_ = byteSource(param1,currentTag.dataSize);
                  if(_loc4_ != null)
                  {
                     currentTag.readData(_loc4_);
                     state = "prevTag";
                  }
                  else
                  {
                     _loc5_ = false;
                  }
                  break;
               case "prevTag":
                  _loc4_ = byteSource(param1,4);
                  if(_loc4_ != null)
                  {
                     currentTag.readPrevTag(_loc4_);
                     state = "type";
                     _loc5_ = param3(currentTag);
                  }
                  else
                  {
                     _loc5_ = false;
                  }
                  break;
               default:
                  throw new Error("FLVParser state machine in unknown state");
            }
         }
         if(param2)
         {
            param1.readBytes(savedBytes,savedBytes.length);
         }
      }
      
      private function byteSource(param1:IDataInput, param2:int) : IDataInput
      {
         var _loc3_:int = 0;
         if(savedBytes.bytesAvailable + param1.bytesAvailable < param2)
         {
            return null;
         }
         if(savedBytes.bytesAvailable)
         {
            _loc3_ = param2 - savedBytes.bytesAvailable;
            if(_loc3_ > 0)
            {
               param1.readBytes(savedBytes,savedBytes.length,_loc3_);
            }
            return savedBytes;
         }
         savedBytes.length = 0;
         return param1;
      }
   }
}

