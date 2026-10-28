package com.sbi.corelib.crypto
{
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.hash.SHA256;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.crypto.symmetric.IPad;
   import com.hurlant.crypto.symmetric.IVMode;
   import com.hurlant.crypto.symmetric.PKCS5;
   import com.hurlant.util.Base64;
   import com.hurlant.util.Hex;
   import flash.utils.ByteArray;
   
   public class SBCrypto
   {
      
      public function SBCrypto()
      {
         super();
      }
      
      public static function encrypt(param1:String, param2:String) : String
      {
         var _loc4_:SHA256 = new SHA256();
         var _loc6_:ByteArray = _loc4_.hash(Hex.toArray(Hex.fromString(param2)));
         var _loc5_:ByteArray = Hex.toArray(Hex.fromString(param1));
         var _loc3_:IPad = new PKCS5();
         var _loc9_:ICipher = Crypto.getCipher("aes-256-cbc",_loc6_,_loc3_);
         _loc9_.encrypt(_loc5_);
         var _loc7_:IVMode = _loc9_ as IVMode;
         var _loc8_:ByteArray = _loc7_.IV;
         _loc8_.writeBytes(_loc5_);
         return Base64.encodeByteArray(_loc8_);
      }
   }
}

