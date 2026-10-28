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
         var _loc3_:SHA256 = new SHA256();
         var _loc4_:ByteArray = _loc3_.hash(Hex.toArray(Hex.fromString(param2)));
         var _loc5_:ByteArray = Hex.toArray(Hex.fromString(param1));
         var _loc6_:IPad = new PKCS5();
         var _loc7_:ICipher = Crypto.getCipher("aes-256-cbc",_loc4_,_loc6_);
         _loc7_.encrypt(_loc5_);
         var _loc8_:IVMode = _loc7_ as IVMode;
         var _loc9_:ByteArray = _loc8_.IV;
         _loc9_.writeBytes(_loc5_);
         return Base64.encodeByteArray(_loc9_);
      }
   }
}

