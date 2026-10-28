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
      
      public static function sendTradeListRequest(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("tl",[userName]);
      }
      
      public static function sendTradeBusyRequest(busy:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("tb",[busy ? "1" : "0"]);
      }
      
      public static function sendTradeItemsRequest(userName:String, itemIdx:int, isClothingItem:Boolean, clothingItemInvIds:Array, denItemInvIds:Array, numAudioItems:int) : void
      {
         var numClothingItems:int = int(clothingItemInvIds.length);
         var numDenItems:int = denItemInvIds.length - numAudioItems;
         var params:Array = [0,userName,isClothingItem ? "0" : "1",itemIdx,numClothingItems,numDenItems,numAudioItems];
         if(numClothingItems > 0)
         {
            params = params.concat(clothingItemInvIds);
         }
         if(numDenItems + numAudioItems > 0)
         {
            params = params.concat(denItemInvIds.concat());
         }
         gMainFrame.server.setXtObject_Str("ti",params);
      }
      
      public static function sendTradeSetRequest(itemsIn:Array, itemsOut:Array) : void
      {
         var i:int = 0;
         var numIn:int = int(itemsIn.length);
         var numOut:int = int(itemsOut.length);
         var params:Array = new Array(2 + (numIn + numOut) * 2);
         var j:int = 0;
         params[j++] = numOut;
         for(i = 0; i < numOut; i++)
         {
            params[j++] = itemsOut[i].type;
            params[j++] = itemsOut[i].invIdx;
         }
         params[j++] = numIn;
         for(i = 0; i < numIn; i++)
         {
            params[j++] = itemsIn[i].type;
            params[j++] = itemsIn[i].invIdx;
         }
         gMainFrame.server.setXtObject_Str("ts",params);
      }
      
      public static function sendTradeItemAcceptOrReject(tradeFlag:int) : void
      {
         gMainFrame.server.setXtObject_Str("ti",[1,tradeFlag]);
      }
      
      public static function sendTradeItemCancel() : void
      {
         gMainFrame.server.setXtObject_Str("ti",[2]);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         switch(data[0])
         {
            case "tl":
               TradeManager.onTradeListReceived(data);
               break;
            case "ti":
               TradeManager.onTradeItemsResponse(data);
               break;
            default:
               throw new Error("ECardXtCommManager: Received illegal cmd: " + data[0]);
         }
      }
   }
}

