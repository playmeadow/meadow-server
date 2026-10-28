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
      
      public static function sendBuddyListRequest(param1:Function = null) : void
      {
         _requestCallback = param1;
         gMainFrame.server.setXtObject_Str("bl",[]);
      }
      
      public static function sendBuddyAddRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("ba",[param1]);
      }
      
      public static function sendBuddyConfirmRequest(param1:String, param2:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("bc",[param1,param2 ? "1" : "0"]);
      }
      
      public static function sendBuddyDeleteRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("bd",[param1]);
      }
      
      public static function sendBuddyRoomRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("br",[param1],true,false,false);
      }
      
      public static function sendBuddyBlockRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("bb",[param1]);
      }
      
      public static function sendBuddyUnblockRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("bu",[param1]);
      }
      
      public static function sendBuddyBlockInfoRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("bi",[param1]);
      }
      
      public static function sendSearchRequest(param1:String, param2:Function) : void
      {
         _searchCallback = param2;
         userSearchResponse([false,-1]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "bl":
               buddyListblockedListResponse(_loc2_);
               break;
            case "ba":
               buddyAddRequestResponse(int(_loc2_[2]),_loc2_[3]);
               break;
            case "bs":
               buddyStatusResponse(_loc2_);
               break;
            case "bd":
               buddyDeleteResponse(_loc2_[2]);
               break;
            case "br":
               buddyRoomResponse(_loc2_);
               break;
            case "bb":
               buddyBlockResponse(_loc2_);
               break;
            case "bu":
               buddyUnblockResponse(_loc2_);
               break;
            case "bi":
               buddyIsBlockingMeResponse(_loc2_);
               break;
            default:
               throw new Error("BuddyXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function buddyListblockedListResponse(param1:Object) : void
      {
         if(param1[2] == "0")
         {
            BuddyManager.buddyListResponseHandler(param1);
         }
         else
         {
            BuddyManager.blockedListResponseHandler(param1);
         }
         if(_requestCallback != null)
         {
            _requestCallback();
            _requestCallback = null;
         }
      }
      
      private static function buddyAddRequestResponse(param1:int, param2:String) : void
      {
         BuddyManager.buddyAddRequestResponseHandler(param1,param2);
      }
      
      private static function buddyStatusResponse(param1:Object) : void
      {
         if(param1[2] == "1")
         {
            BuddyManager.buddyStatusResponseHandler(param1[3],param1[4] == "1",int(param1[5]),int(param1[6]),null,param1[7],int(param1[8]));
         }
         else
         {
            BuddyManager.buddyStatusResponseHandler(param1[3],param1[4] == "1",int(param1[5]),int(param1[6]),param1[7]);
         }
      }
      
      private static function buddyDeleteResponse(param1:String) : void
      {
         BuddyManager.buddyDeleteResponseHandler(param1);
      }
      
      private static function buddyRoomResponse(param1:Object) : void
      {
         BuddyCard.buddyRoomResponseHandler(param1[2],param1[3],param1[4] == "1",int(param1[5]));
      }
      
      private static function buddyBlockResponse(param1:Object) : void
      {
         BuddyManager.buddyBlockResponseHandler(param1[2],param1[3] == "1");
      }
      
      private static function buddyUnblockResponse(param1:Object) : void
      {
         BuddyManager.buddyUnblockResponseHandler(param1[2],param1[3] == "1");
      }
      
      private static function userSearchResponse(param1:Object) : void
      {
         _searchCallback(param1[0],param1[1]);
      }
      
      private static function buddyIsBlockingMeResponse(param1:Object) : void
      {
         BuddyCard.buddyBlockInfoResponseHandler(param1[2],param1[3] == "1");
      }
   }
}

