package com.hurlant.crypto.rsa
{
   import com.hurlant.crypto.prng.Random;
   import com.hurlant.math.BigInteger;
   import com.hurlant.util.Memory;
   import flash.utils.ByteArray;
   
   public class RSAKey
   {
      
      public var e:int;
      
      public var n:BigInteger;
      
      public var d:BigInteger;
      
      public var p:BigInteger;
      
      public var q:BigInteger;
      
      public var dmp1:BigInteger;
      
      public var dmq1:BigInteger;
      
      public var coeff:BigInteger;
      
      protected var canDecrypt:Boolean;
      
      protected var canEncrypt:Boolean;
      
      public function RSAKey(N:BigInteger, E:int, D:BigInteger = null, P:BigInteger = null, Q:BigInteger = null, DP:BigInteger = null, DQ:BigInteger = null, C:BigInteger = null)
      {
         super();
         this.n = N;
         this.e = E;
         this.d = D;
         this.p = P;
         this.q = Q;
         this.dmp1 = DP;
         this.dmq1 = DQ;
         this.coeff = C;
         this.canEncrypt = this.n != null && this.e != 0;
         this.canDecrypt = this.canEncrypt && this.d != null;
      }
      
      public static function parsePublicKey(N:String, E:String) : RSAKey
      {
         return new RSAKey(new BigInteger(N,16),parseInt(E,16));
      }
      
      public static function parsePrivateKey(N:String, E:String, D:String, P:String = null, Q:String = null, DMP1:String = null, DMQ1:String = null, IQMP:String = null) : RSAKey
      {
         if(P == null)
         {
            return new RSAKey(new BigInteger(N,16),parseInt(E,16),new BigInteger(D,16));
         }
         return new RSAKey(new BigInteger(N,16),parseInt(E,16),new BigInteger(D,16),new BigInteger(P,16),new BigInteger(Q,16),new BigInteger(DMP1,16),new BigInteger(DMQ1),new BigInteger(IQMP));
      }
      
      public static function generate(B:uint, E:String) : RSAKey
      {
         var p1:BigInteger = null;
         var q1:BigInteger = null;
         var phi:BigInteger = null;
         var t:BigInteger = null;
         var rng:Random = new Random();
         var qs:uint = uint(B >> 1);
         var key:RSAKey = new RSAKey(null,0,null);
         key.e = parseInt(E,16);
         for(var ee:BigInteger = new BigInteger(E,16); true; )
         {
            while(true)
            {
               key.p = bigRandom(B - qs,rng);
               if(key.p.subtract(BigInteger.ONE).gcd(ee).compareTo(BigInteger.ONE) == 0 && key.p.isProbablePrime(10))
               {
                  break;
               }
            }
            while(true)
            {
               key.q = bigRandom(qs,rng);
               if(key.q.subtract(BigInteger.ONE).gcd(ee).compareTo(BigInteger.ONE) == 0 && key.q.isProbablePrime(10))
               {
                  break;
               }
            }
            if(key.p.compareTo(key.q) <= 0)
            {
               t = key.p;
               key.p = key.q;
               key.q = t;
            }
            p1 = key.p.subtract(BigInteger.ONE);
            q1 = key.q.subtract(BigInteger.ONE);
            phi = p1.multiply(q1);
            if(phi.gcd(ee).compareTo(BigInteger.ONE) == 0)
            {
               key.n = key.p.multiply(key.q);
               key.d = ee.modInverse(phi);
               key.dmp1 = key.d.mod(p1);
               key.dmq1 = key.d.mod(q1);
               key.coeff = key.q.modInverse(key.p);
               break;
            }
         }
         return key;
      }
      
      protected static function bigRandom(bits:int, rnd:Random) : BigInteger
      {
         if(bits < 2)
         {
            return BigInteger.nbv(1);
         }
         var x:ByteArray = new ByteArray();
         rnd.nextBytes(x,bits >> 3);
         x.position = 0;
         var b:BigInteger = new BigInteger(x);
         b.primify(bits,1);
         return b;
      }
      
      public function getBlockSize() : uint
      {
         return (this.n.bitLength() + 7) / 8;
      }
      
      public function dispose() : void
      {
         this.e = 0;
         this.n.dispose();
         this.n = null;
         Memory.gc();
      }
      
      public function encrypt(src:ByteArray, dst:ByteArray, length:uint, pad:Function = null) : void
      {
         this._encrypt(this.doPublic,src,dst,length,pad,2);
      }
      
      public function decrypt(src:ByteArray, dst:ByteArray, length:uint, pad:Function = null) : void
      {
         this._decrypt(this.doPrivate2,src,dst,length,pad,2);
      }
      
      public function sign(src:ByteArray, dst:ByteArray, length:uint, pad:Function = null) : void
      {
         this._encrypt(this.doPrivate2,src,dst,length,pad,1);
      }
      
      public function verify(src:ByteArray, dst:ByteArray, length:uint, pad:Function = null) : void
      {
         this._decrypt(this.doPublic,src,dst,length,pad,1);
      }
      
      private function _encrypt(op:Function, src:ByteArray, dst:ByteArray, length:uint, pad:Function, padType:int) : void
      {
         var block:BigInteger = null;
         var chunk:BigInteger = null;
         if(pad == null)
         {
            pad = this.pkcs1pad;
         }
         if(src.position >= src.length)
         {
            src.position = 0;
         }
         var bl:uint = this.getBlockSize();
         var end:int = src.position + length;
         while(src.position < end)
         {
            block = new BigInteger(pad(src,end,bl,padType),bl);
            chunk = op(block);
            chunk.toArray(dst);
         }
      }
      
      private function _decrypt(op:Function, src:ByteArray, dst:ByteArray, length:uint, pad:Function, padType:int) : void
      {
         var block:BigInteger = null;
         var chunk:BigInteger = null;
         var b:ByteArray = null;
         if(pad == null)
         {
            pad = this.pkcs1unpad;
         }
         if(src.position >= src.length)
         {
            src.position = 0;
         }
         var bl:uint = this.getBlockSize();
         var end:int = src.position + length;
         while(src.position < end)
         {
            block = new BigInteger(src,length);
            chunk = op(block);
            b = pad(chunk,bl);
            dst.writeBytes(b);
         }
      }
      
      private function pkcs1pad(src:ByteArray, end:int, n:uint, type:uint = 2) : ByteArray
      {
         var x:int = 0;
         var out:ByteArray = new ByteArray();
         var p:int = int(src.position);
         end = Math.min(end,src.length,p + n - 11);
         src.position = end;
         var i:int = end - 1;
         while(i >= p && n > 11)
         {
            out[--n] = src[i--];
         }
         out[--n] = 0;
         var rng:Random = new Random();
         while(n > 2)
         {
            for(x = 0; x == 0; )
            {
               x = type == 2 ? rng.nextByte() : 255;
            }
            out[--n] = x;
         }
         out[--n] = type;
         out[--n] = 0;
         return out;
      }
      
      private function pkcs1unpad(src:BigInteger, n:uint, type:uint = 2) : ByteArray
      {
         var b:ByteArray = src.toByteArray();
         var out:ByteArray = new ByteArray();
         var i:int = 0;
         while(i < b.length && b[i] == 0)
         {
            i++;
         }
         if(b.length - i != n - 1 || b[i] > 2)
         {
            trace("PKCS#1 unpad: i=" + i + ", expected b[i]==[0,1,2], got b[i]=" + b[i].toString(16));
            return null;
         }
         i++;
         while(b[i] != 0)
         {
            if(++i >= b.length)
            {
               trace("PKCS#1 unpad: i=" + i + ", b[i-1]!=0 (=" + b[i - 1].toString(16) + ")");
               return null;
            }
         }
         while(++i < b.length)
         {
            out.writeByte(b[i]);
         }
         out.position = 0;
         return out;
      }
      
      private function rawpad(src:ByteArray, end:int, n:uint) : ByteArray
      {
         return src;
      }
      
      public function toString() : String
      {
         return "rsa";
      }
      
      public function dump() : String
      {
         var s:String = "N=" + this.n.toString(16) + "\n" + "E=" + this.e.toString(16) + "\n";
         if(this.canDecrypt)
         {
            s += "D=" + this.d.toString(16) + "\n";
            if(this.p != null && this.q != null)
            {
               s += "P=" + this.p.toString(16) + "\n";
               s += "Q=" + this.q.toString(16) + "\n";
               s += "DMP1=" + this.dmp1.toString(16) + "\n";
               s += "DMQ1=" + this.dmq1.toString(16) + "\n";
               s += "IQMP=" + this.coeff.toString(16) + "\n";
            }
         }
         return s;
      }
      
      protected function doPublic(x:BigInteger) : BigInteger
      {
         return x.modPowInt(this.e,this.n);
      }
      
      protected function doPrivate2(x:BigInteger) : BigInteger
      {
         if(this.p == null && this.q == null)
         {
            return x.modPow(this.d,this.n);
         }
         var xp:BigInteger = x.mod(this.p).modPow(this.dmp1,this.p);
         var xq:BigInteger = x.mod(this.q).modPow(this.dmq1,this.q);
         while(xp.compareTo(xq) < 0)
         {
            xp = xp.add(this.p);
         }
         return xp.subtract(xq).multiply(this.coeff).mod(this.p).multiply(this.q).add(xq);
      }
      
      protected function doPrivate(x:BigInteger) : BigInteger
      {
         if(this.p == null || this.q == null)
         {
            return x.modPow(this.d,this.n);
         }
         var xp:BigInteger = x.mod(this.p).modPow(this.dmp1,this.p);
         var xq:BigInteger = x.mod(this.q).modPow(this.dmq1,this.q);
         while(xp.compareTo(xq) < 0)
         {
            xp = xp.add(this.p);
         }
         return xp.subtract(xq).multiply(this.coeff).mod(this.p).multiply(this.q).add(xq);
      }
   }
}

