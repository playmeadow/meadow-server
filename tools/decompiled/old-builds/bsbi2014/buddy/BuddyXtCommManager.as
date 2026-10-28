package buddy
{
   import com.sbi.client.SFEvent;
   import gui.BuddyCard;
   import gui.BuddyManager;
   
   public class BuddyXtCommManager
   {
      
      private static var _searchCallback:Function;
      
      private static var _requestCallback:Function;
      
      public function BuddyXtCommManager()
      {
         super();
      }
      
      public static function sendBuddyListRequest(callback:Function = null) : void
      {
         _requestCallback = callback;
         gMainFrame.server.setXtObject_Str("bl",[]);
      }
      
      public static function sendBuddyAddRequest(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("ba",[userName]);
      }
      
      public static function sendBuddyConfirmRequest(userName:String, acceptedRequest:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("bc",[userName,acceptedRequest ? "1" : "0"]);
      }
      
      public static function sendBuddyDeleteRequest(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("bd",[userName]);
      }
      
      public static function sendBuddyRoomRequest(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("br",[userName],true,false,false);
      }
      
      public static function sendBuddyBlockRequest(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("bb",[userName]);
      }
      
      public static function sendBuddyUnblockRequest(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("bu",[userName]);
      }
      
      public static function sendBuddyBlockInfoRequest(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("bi",[userName]);
      }
      
      public static function sendSearchRequest(userName:String, callback:Function) : void
      {
         _searchCallback = callback;
         userSearchResponse([false,-1]);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Array = evt.obj;
         switch(data[0])
         {
            case "bl":
               buddyListblockedListResponse(data);
               break;
            case "ba":
               buddyAddRequestResponse(int(data[2]),data[3],data[4]);
               break;
            case "bs":
               buddyStatusResponse(data);
               break;
            case "bd":
               buddyDeleteResponse(data[2]);
               break;
            case "br":
               buddyRoomResponse(data);
               break;
            case "bb":
               buddyBlockResponse(data);
               break;
            case "bu":
               buddyUnblockResponse(data);
               break;
            case "bi":
               buddyIsBlockingMeResponse(data);
               break;
            default:
               throw new Error("BuddyXtCommManager illegal data:" + data[0]);
         }
      }
      
      private static function buddyListblockedListResponse(data:Object) : void
      {
         if(data[2] == "0")
         {
            BuddyManager.buddyListResponseHandler(data);
         }
         else
         {
            BuddyManager.blockedListResponseHandler(data);
         }
         if(_requestCallback != null)
         {
            _requestCallback();
            _requestCallback = null;
         }
      }
      
      private static function buddyAddRequestResponse(flag:int, userName:String, userNameModerationFlag:int) : void
      {
         BuddyManager.buddyAddRequestResponseHandler(flag,userName,userNameModerationFlag);
      }
      
      private static function buddyStatusResponse(data:Object) : void
      {
         if(data[2] == "1")
         {
            BuddyManager.buddyStatusResponseHandler(data[3],data[4],data[5] == "1",int(data[6]),int(data[7]),null,data[8],data[9]);
         }
         else
         {
            BuddyManager.buddyStatusResponseHandler(data[3],data[4],data[5] == "1",int(data[6]),int(data[7]),data[8]);
         }
      }
      
      private static function buddyDeleteResponse(userName:String) : void
      {
         BuddyManager.buddyDeleteResponseHandler(userName);
      }
      
      private static function buddyRoomResponse(data:Object) : void
      {
         BuddyCard.buddyRoomResponseHandler(data[2],data[3],data[4],data[5] == "1",int(data[6]));
      }
      
      private static function buddyBlockResponse(data:Object) : void
      {
         BuddyManager.buddyBlockResponseHandler(data[2],data[3] == "1");
      }
      
      private static function buddyUnblockResponse(data:Object) : void
      {
         BuddyManager.buddyUnblockResponseHandler(data[2],data[3] == "1");
      }
      
      private static function userSearchResponse(data:Object) : void
      {
         _searchCallback(data[0],data[1]);
      }
      
      private static function buddyIsBlockingMeResponse(data:Object) : void
      {
         BuddyCard.buddyBlockInfoResponseHandler(data[2],data[3] == "1");
      }
   }
}

