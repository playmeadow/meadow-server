package ecard
{
   import com.sbi.client.SFEvent;
   import com.sbi.popup.SBOkPopup;
   import gui.BuddyManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.SafeChatManager;
   import localization.LocalizationManager;
   
   public class ECardXtCommManager
   {
      
      private static var _requestCallback:Function;
      
      private static var _readResponseCallback:Function;
      
      private static var _sendResponseCallback:Function;
      
      public static var _deleteResponseCallback:Function;
      
      public static var _giftResponseCallback:Function;
      
      private static var _jaggedPlayers:Object;
      
      private static var NUM_JAGS_PER_NON_BUDDY_PER_SESSION:int = 5;
      
      private static var NUM_JAGS_PER_BUDDY_PER_SESSION:int = 25;
      
      public function ECardXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _jaggedPlayers = new Object();
      }
      
      public static function sendECardListRequest(requestCallback:Function = null) : void
      {
         var includeRedemptions:int = 0;
         if(requestCallback != null)
         {
            includeRedemptions = 1;
            _requestCallback = requestCallback;
         }
         gMainFrame.server.setXtObject_Str("el",[includeRedemptions]);
      }
      
      public static function sendECardReadRequest(msgId:int, responseCallback:Function = null) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(responseCallback != null)
            {
               _readResponseCallback = responseCallback;
            }
            DarkenManager.showLoadingSpiral(true);
            gMainFrame.server.setXtObject_Str("er",[msgId]);
         }
      }
      
      public static function sendECardSendRequest(toUserName:String, cardTypeId:int, stampTypeId:int, messageType:int, msg:String, type:int, giftItemIdx:int = -1, responseCallback:Function = null) : Boolean
      {
         if(_jaggedPlayers[toUserName] == null)
         {
            _jaggedPlayers[toUserName] = 0;
         }
         var limit:int = BuddyManager.isBuddy(toUserName) ? NUM_JAGS_PER_BUDDY_PER_SESSION : NUM_JAGS_PER_NON_BUDDY_PER_SESSION;
         if(_jaggedPlayers[toUserName] < limit)
         {
            ++_jaggedPlayers[toUserName];
            if(responseCallback != null)
            {
               _sendResponseCallback = responseCallback;
            }
            gMainFrame.server.setXtObject_Str("es",[toUserName,cardTypeId,stampTypeId,messageType,msg,type,giftItemIdx]);
            return true;
         }
         DarkenManager.showLoadingSpiral(false);
         new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14961,toUserName));
         return false;
      }
      
      public static function sendECardDeleteRequest(msgId:int, responseCallback:Function = null) : void
      {
         if(responseCallback != null)
         {
            _deleteResponseCallback = responseCallback;
         }
         DarkenManager.showLoadingSpiral(true);
         gMainFrame.server.setXtObject_Str("ed",[msgId]);
      }
      
      public static function sendECardBuddyRequest(msgId:int, acceptBuddyRequest:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("eb",[msgId,acceptBuddyRequest ? 1 : 0]);
      }
      
      public static function sendECardAcceptDiscardGiftRequest(msgId:int, acceptGift:Boolean, responseCallback:Function) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(responseCallback != null)
            {
               _giftResponseCallback = responseCallback;
            }
            gMainFrame.server.setXtObject_Str("eg",[msgId,acceptGift ? 1 : 0]);
         }
         else if(responseCallback != null)
         {
            responseCallback(0,true);
         }
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         DarkenManager.showLoadingSpiral(false);
         switch(data[0])
         {
            case "el":
               eCardListResponse(data);
               break;
            case "er":
               eCardReadResponse(data);
               break;
            case "ed":
               eCardDeleteResponse(data);
               break;
            case "es":
               eCardSendResponse(data);
               break;
            case "eg":
               eCardGiftResponse(data);
               break;
            case "eb":
               eCardBuddyResponse(data);
               break;
            case "ep":
               eCardPushHandler(data);
               break;
            case "eu":
               eCardUpdateHandler(data);
               break;
            default:
               throw new Error("ECardXtCommManager: Received illegal cmd: " + data[0]);
         }
      }
      
      private static function eCardListResponse(data:Object) : void
      {
         var eCard:ECard = null;
         var numECards:int = int(data[2]);
         var eCards:Array = new Array(numECards);
         if(numECards == -1)
         {
            numECards = 0;
         }
         var unreadCount:int = 0;
         var j:int = 3;
         for(var i:int = 0; i < numECards; i++)
         {
            eCard = new ECard();
            eCard.init(int(data[j++]),data[j++],int(data[j++]),int(data[j++]),data[j++] == "1",data[j++],int(data[j++]),int(data[j++]),uint(data[j++]),data[j++],int(data[j++]),int(data[j++]),int(data[j++]),int(data[j++]),int(data[j++]));
            if(Boolean(eCard.msg.match("(^[0-9]{1,2},[0-9]{1,2}$)|(^[0-9]{1,2}$)")))
            {
               eCard.msg = SafeChatManager.safeChatStringForCode(eCard.msg,SafeChatManager.TREE_ECARDTEXT);
            }
            if(eCard.type == ECard.TYPE_GEMS)
            {
               eCard.giftName = LocalizationManager.translateIdAndInsertOnly(eCard.giftName == "1" ? LocalizationManager.GEM_CAPITALIZED : LocalizationManager.GEMS_CAPITALIZED,Utility.convertNumberToString(int(eCard.giftName)));
            }
            else if(eCard.type == ECard.TYPE_DIAMOND)
            {
               eCard.giftName = LocalizationManager.translateIdAndInsertOnly(eCard.giftName == "1" ? LocalizationManager.DIAMOND_CAPITALIZED : LocalizationManager.DIAMONDS_CAPITALIZED,Utility.convertNumberToString(int(eCard.giftName)));
            }
            else if(eCard.type == ECard.TYPE_DEN_ROOM)
            {
               eCard.giftName = LocalizationManager.translateIdAndInsertOnly(15000,LocalizationManager.translateIdOnly(int(eCard.giftName)));
            }
            else
            {
               eCard.giftName = LocalizationManager.translateIdOnly(int(eCard.giftName));
            }
            if(eCard.isFromVoice)
            {
               eCard.senderUserName = LocalizationManager.translateIdOnly(int(eCard.senderUserName));
            }
            eCards[i] = eCard;
            if(!eCard.isRead && !(eCard.isAJHQGift && !gMainFrame.userInfo.isMember))
            {
               unreadCount++;
            }
         }
         ECardManager.processECardList(eCards,unreadCount);
         if(_requestCallback != null)
         {
            _requestCallback(eCards);
            _requestCallback = null;
         }
      }
      
      private static function eCardReadResponse(data:Object) : void
      {
         if(_readResponseCallback != null)
         {
            _readResponseCallback(int(data[2]),data[3] == "1");
         }
      }
      
      private static function eCardDeleteResponse(data:Object) : void
      {
         var status:Boolean = data[2] == "1" ? true : false;
         var numDeleted:int = int(data[3]);
         var j:int = 4;
         var items:Array = new Array(numDeleted);
         for(var i:int = 0; i < numDeleted; i++)
         {
            items[i] = data[j++];
         }
         if(_deleteResponseCallback != null)
         {
            _deleteResponseCallback(items,status);
         }
      }
      
      private static function eCardSendResponse(data:Object) : void
      {
         var status:Boolean = data[2] == "1" ? true : false;
         if(_sendResponseCallback != null)
         {
            _sendResponseCallback(status);
         }
      }
      
      private static function eCardGiftResponse(data:Object) : void
      {
         if(_giftResponseCallback != null)
         {
            _giftResponseCallback(int(data[2]),data[3] == "1");
         }
      }
      
      private static function eCardBuddyResponse(data:Object) : void
      {
         if(data[2] == -1)
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14692));
         }
      }
      
      private static function eCardPushHandler(data:Object) : void
      {
         var eCard:ECard = new ECard();
         var j:int = 2;
         eCard.init(int(data[j++]),data[j++],int(data[j++]),int(data[j++]),data[j++] == "1",data[j++],int(data[j++]),int(data[j++]),uint(data[j++]),data[j++],int(data[j++]),int(data[j++]),int(data[j++]),int(data[j++]),int(data[j++]));
         if(Boolean(eCard.msg.match("(^[0-9]{1,2},[0-9]{1,2}$)|(^[0-9]{1,2}$)")))
         {
            eCard.msg = SafeChatManager.safeChatStringForCode(eCard.msg,SafeChatManager.TREE_ECARDTEXT);
         }
         if(eCard.type == ECard.TYPE_GEMS)
         {
            eCard.giftName = LocalizationManager.translateIdAndInsertOnly(eCard.giftName == "1" ? LocalizationManager.GEM_CAPITALIZED : LocalizationManager.GEMS_CAPITALIZED,Utility.convertNumberToString(int(eCard.giftName)));
         }
         else if(eCard.type == ECard.TYPE_DIAMOND)
         {
            eCard.giftName = LocalizationManager.translateIdAndInsertOnly(eCard.giftName == "1" ? LocalizationManager.DIAMOND_CAPITALIZED : LocalizationManager.DIAMONDS_CAPITALIZED,Utility.convertNumberToString(int(eCard.giftName)));
         }
         else if(eCard.type == ECard.TYPE_DEN_ROOM)
         {
            eCard.giftName = LocalizationManager.translateIdAndInsertOnly(15000,LocalizationManager.translateIdOnly(int(eCard.giftName)));
         }
         else
         {
            eCard.giftName = LocalizationManager.translateIdOnly(int(eCard.giftName));
         }
         if(eCard.isFromVoice)
         {
            eCard.senderUserName = LocalizationManager.translateIdOnly(int(eCard.senderUserName));
         }
         ECardManager.processECardPush(eCard);
      }
      
      private static function eCardUpdateHandler(data:Object) : void
      {
         ECardManager.processECardUpdate(data[2],data[3]);
      }
   }
}

