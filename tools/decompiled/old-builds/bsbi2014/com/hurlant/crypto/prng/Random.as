package com.hurlant.crypto.prng
{
   import com.hurlant.util.Memory;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.text.Font;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class Random
   {
      
      private var state:IPRNG;
      
      private var ready:Boolean = false;
      
      private var pool:ByteArray;
      
      private var psize:int;
      
      private var pptr:int;
      
      private var seeded:Boolean = false;
      
      public function Random(prng:Class = null)
      {
         var t:uint = 0;
         super();
         if(prng == null)
         {
            prng = ARC4;
         }
         this.state = new prng() as IPRNG;
         this.psize = this.state.getPoolSize();
         this.pool = new ByteArray();
         this.pptr = 0;
         while(this.pptr < this.psize)
         {
            t = 65536 * Math.random();
            this.pool[this.pptr++] = t >>> 8;
            this.pool[this.pptr++] = t & 0xFF;
         }
         this.pptr = 0;
         this.seed();
      }
      
      public function seed(x:int = 0) : void
      {
         if(x == 0)
         {
            x = new Date().getTime();
         }
         var _temp_3:* = this.pool;
         var _loc2_:Number = this.pptr++;
         _temp_3[_loc2_] ^= x & 0xFF;
         var _temp_6:* = this.pool;
         var _loc3_:Number = this.pptr++;
         _temp_6[_loc3_] ^= x >> 8 & 0xFF;
         var _temp_9:* = this.pool;
         var _loc4_:Number = this.pptr++;
         _temp_9[_loc4_] ^= x >> 16 & 0xFF;
         var _temp_12:* = this.pool;
         var _loc5_:Number = this.pptr++;
         _temp_12[_loc5_] ^= x >> 24 & 0xFF;
         this.pptr %= this.psize;
         this.seeded = true;
      }
      
      public function autoSeed() : void
      {
         var f:Font = null;
         var b:ByteArray = new ByteArray();
         b.writeUnsignedInt(System.totalMemory);
         b.writeUTF(Capabilities.serverString);
         b.writeUnsignedInt(getTimer());
         b.writeUnsignedInt(new Date().getTime());
         var a:Array = Font.enumerateFonts(true);
         for each(f in a)
         {
            b.writeUTF(f.fontName);
            b.writeUTF(f.fontStyle);
            b.writeUTF(f.fontType);
         }
         b.position = 0;
         while(b.bytesAvailable >= 4)
         {
            this.seed(b.readUnsignedInt());
         }
      }
      
      public function nextBytes(buffer:ByteArray, length:int) : void
      {
         while(Boolean(length--))
         {
            buffer.writeByte(this.nextByte());
         }
      }
      
      public function nextByte() : int
      {
         if(!this.ready)
         {
            if(!this.seeded)
            {
               this.autoSeed();
            }
            this.state.init(this.pool);
            this.pool.length = 0;
            this.pptr = 0;
            this.ready = true;
         }
         return this.state.next();
      }
      
      public function dispose() : void
      {
         for(var i:uint = 0; i < this.pool.length; i++)
         {
            this.pool[i] = Math.random() * 256;
         }
         this.pool.length = 0;
         this.pool = null;
         this.state.dispose();
         this.state = null;
         this.psize = 0;
         this.pptr = 0;
         Memory.gc();
      }
      
      public function toString() : String
      {
         return "random-" + this.state.toString();
      }
   }
}

