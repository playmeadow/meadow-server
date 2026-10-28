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
      
      public static function encrypt(input:String, key:String) : String
      {
         var sha:SHA256 = new SHA256();
         var keyData:ByteArray = sha.hash(Hex.toArray(Hex.fromString(key)));
         var data:ByteArray = Hex.toArray(Hex.fromString(input));
         var pad:IPad = new PKCS5();
         var mode:ICipher = Crypto.getCipher("aes-256-cbc",keyData,pad);
         mode.encrypt(data);
         var ivmode:IVMode = mode as IVMode;
         var combined:ByteArray = ivmode.IV;
         combined.writeBytes(data);
         return Base64.encodeByteArray(combined);
      }
   }
}

