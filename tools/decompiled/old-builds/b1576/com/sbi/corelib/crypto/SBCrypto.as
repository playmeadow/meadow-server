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
         var _loc8_:SHA256 = new SHA256();
         var _loc5_:ByteArray = _loc8_.hash(Hex.toArray(Hex.fromString(param2)));
         var _loc6_:ByteArray = Hex.toArray(Hex.fromString(param1));
         var _loc4_:IPad = new PKCS5();
         var _loc3_:ICipher = Crypto.getCipher("aes-256-cbc",_loc5_,_loc4_);
         _loc3_.encrypt(_loc6_);
         var _loc9_:IVMode = _loc3_ as IVMode;
         var _loc7_:ByteArray = _loc9_.IV;
         _loc7_.writeBytes(_loc6_);
         return Base64.encodeByteArray(_loc7_);
      }
   }
}

