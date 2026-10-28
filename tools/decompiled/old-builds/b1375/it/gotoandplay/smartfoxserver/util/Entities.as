package it.gotoandplay.smartfoxserver.util
{
   public class Entities
   {
      
      private static var ascTab:Array = [];
      
      ascTab[">"] = "&gt;";
      ascTab["<"] = "&lt;";
      ascTab["&"] = "&amp;";
      ascTab["\'"] = "&apos;";
      ascTab["\""] = "&quot;";
      
      private static var ascTabRev:Array = [];
      
      ascTabRev["&gt;"] = ">";
      ascTabRev["&lt;"] = "<";
      ascTabRev["&amp;"] = "&";
      ascTabRev["&apos;"] = "\'";
      ascTabRev["&quot;"] = "\"";
      
      private static var hexTable:Array = [];
      
      hexTable["0"] = 0;
      hexTable["1"] = 1;
      hexTable["2"] = 2;
      hexTable["3"] = 3;
      hexTable["4"] = 4;
      hexTable["5"] = 5;
      hexTable["6"] = 6;
      hexTable["7"] = 7;
      hexTable["8"] = 8;
      hexTable["9"] = 9;
      hexTable["A"] = 10;
      hexTable["B"] = 11;
      hexTable["C"] = 12;
      hexTable["D"] = 13;
      hexTable["E"] = 14;
      hexTable["F"] = 15;
      
      public function Entities()
      {
         super();
      }
      
      public static function encodeEntities(param1:String) : String
      {
         var _loc5_:int = 0;
         var _loc4_:String = null;
         var _loc2_:int = 0;
         var _loc3_:String = "";
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_ = param1.charAt(_loc5_);
            _loc2_ = param1.charCodeAt(_loc5_);
            if(_loc2_ == 9 || _loc2_ == 10 || _loc2_ == 13)
            {
               _loc3_ += _loc4_;
            }
            else if(_loc2_ >= 32 && _loc2_ <= 126)
            {
               if(ascTab[_loc4_] != null)
               {
                  _loc3_ += ascTab[_loc4_];
               }
               else
               {
                  _loc3_ += _loc4_;
               }
            }
            else
            {
               _loc3_ += _loc4_;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public static function decodeEntities(param1:String) : String
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc7_:int = 0;
         _loc4_ = "";
         while(_loc7_ < param1.length)
         {
            _loc5_ = param1.charAt(_loc7_);
            if(_loc5_ == "&")
            {
               _loc6_ = _loc5_;
               do
               {
                  _loc7_++;
                  _loc2_ = param1.charAt(_loc7_);
                  _loc6_ += _loc2_;
               }
               while(_loc2_ != ";" && _loc7_ < param1.length);
               _loc3_ = ascTabRev[_loc6_];
               if(_loc3_ != null)
               {
                  _loc4_ += _loc3_;
               }
               else
               {
                  _loc4_ += String.fromCharCode(getCharCode(_loc6_));
               }
            }
            else
            {
               _loc4_ += _loc5_;
            }
            _loc7_++;
         }
         return _loc4_;
      }
      
      public static function getCharCode(param1:String) : Number
      {
         var _loc2_:String = param1.substr(3,param1.length);
         _loc2_ = _loc2_.substr(0,_loc2_.length - 1);
         return Number("0x" + _loc2_);
      }
   }
}

