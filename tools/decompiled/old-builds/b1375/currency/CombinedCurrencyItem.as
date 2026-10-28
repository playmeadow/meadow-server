package currency
{
   public class CombinedCurrencyItem
   {
      
      private var _countData:Vector.<Object>;
      
      private var _numCurrenciesInUse:int;
      
      public function CombinedCurrencyItem(param1:String)
      {
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         super();
         _numCurrenciesInUse = 0;
         if(param1 && param1 != "")
         {
            _countData = new Vector.<Object>(11);
            _loc2_ = param1.split(",");
            _loc6_ = 0;
            while(_loc6_ < _loc2_.length)
            {
               _loc5_ = _loc2_[_loc6_].split("x");
               if(_loc5_.length < 2)
               {
                  throw new Error("Unable to parse currency. String=" + _loc2_[_loc6_]);
               }
               _loc3_ = int(_loc5_[1]);
               _loc4_ = int(_loc5_[0]);
               _numCurrenciesInUse = _numCurrenciesInUse + 1;
               _countData[_loc4_] = {
                  "count":_loc3_,
                  "type":_loc4_,
                  "name":typeToName(_loc4_)
               };
               _loc6_++;
            }
         }
      }
      
      public function get countData() : Vector.<Object>
      {
         return _countData;
      }
      
      public function get numCurrenciesInUse() : int
      {
         return _numCurrenciesInUse;
      }
      
      public function getCountDataObjectByType(param1:int) : Object
      {
         if(param1 < 0 || param1 >= _countData.length)
         {
            return null;
         }
         return _countData[param1];
      }
      
      private function typeToName(param1:int) : String
      {
         switch(param1 - 4)
         {
            case 0:
               return "straw";
            case 1:
               return "bamboo";
            case 2:
               return "wood";
            case 3:
               return "stone";
            case 4:
               return "silver";
            case 5:
               return "gold";
            case 6:
               return "gemstone";
            default:
               return "";
         }
      }
   }
}

