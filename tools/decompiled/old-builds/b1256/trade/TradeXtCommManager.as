package trade
{
   import com.sbi.client.SFEvent;
   import gui.TradeManager;
   
   public class TradeXtCommManager
   {
      
      public function TradeXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
      }
      
      public static function sendTradeListRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("tl",[param1]);
      }
      
      public static function sendTradeBusyRequest(param1:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("tb",[param1 ? "1" : "0"]);
      }
      
      public static function sendTradeItemsRequest(param1:String, param2:int, param3:Boolean, param4:Array, param5:Array, param6:int) : void
      {
         var _loc9_:int = int(param4.length);
         var _loc7_:int = param5.length - param6;
         var _loc8_:Array = [0,param1,param3 ? "0" : "1",param2,_loc9_,_loc7_,param6];
         if(_loc9_ > 0)
         {
            _loc8_ = _loc8_.concat(param4);
         }
         if(_loc7_ + param6 > 0)
         {
            _loc8_ = _loc8_.concat(param5.concat());
         }
         gMainFrame.server.setXtObject_Str("ti",_loc8_);
      }
      
      public static function sendTradeSetRequest(param1:Array, param2:Array) : void
      {
         var _loc7_:int = 0;
         var _loc4_:int = int(param1.length);
         var _loc3_:int = int(param2.length);
         var _loc5_:Array = new Array(2 + (_loc4_ + _loc3_) * 2);
         var _loc6_:int = 0;
         _loc5_[_loc6_++] = _loc3_;
         _loc7_ = 0;
         while(_loc7_ < _loc3_)
         {
            _loc5_[_loc6_++] = param2[_loc7_].type;
            _loc5_[_loc6_++] = param2[_loc7_].invIdx;
            _loc7_++;
         }
         _loc5_[_loc6_++] = _loc4_;
         _loc7_ = 0;
         while(_loc7_ < _loc4_)
         {
            _loc5_[_loc6_++] = param1[_loc7_].type;
            _loc5_[_loc6_++] = param1[_loc7_].invIdx;
            _loc7_++;
         }
         gMainFrame.server.setXtObject_Str("ts",_loc5_);
      }
      
      public static function sendTradeItemAcceptOrReject(param1:int) : void
      {
         gMainFrame.server.setXtObject_Str("ti",[1,param1]);
      }
      
      public static function sendTradeItemCancel() : void
      {
         gMainFrame.server.setXtObject_Str("ti",[2]);
      }
      
      public static function sendConfirmTrade(param1:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("ti",[3,param1 ? 1 : 0]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "tl":
               TradeManager.onTradeListReceived(_loc2_);
               break;
            case "ti":
               TradeManager.onTradeItemsResponse(_loc2_);
               break;
            default:
               throw new Error("ECardXtCommManager: Received illegal cmd: " + _loc2_[0]);
         }
      }
   }
}

