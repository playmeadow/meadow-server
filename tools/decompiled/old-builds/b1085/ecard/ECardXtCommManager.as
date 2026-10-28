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
      
      public static function sendECardListRequest(param1:Function = null) : void
      {
         if(param1 != null)
         {
            _requestCallback = param1;
         }
         gMainFrame.server.setXtObject_Str("el",[]);
      }
      
      public static function sendECardReadRequest(param1:int, param2:Function = null) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(param2 != null)
            {
               _readResponseCallback = param2;
            }
            DarkenManager.showLoadingSpiral(true);
            gMainFrame.server.setXtObject_Str("er",[param1]);
         }
      }
      
      public static function sendECardSendRequest(param1:String, param2:int, param3:int, param4:int, param5:String, param6:int, param7:int = -1, param8:Function = null) : Boolean
      {
         if(_jaggedPlayers[param1] == null)
         {
            _jaggedPlayers[param1] = 0;
         }
         var _loc9_:int = BuddyManager.isBuddy(param1) ? NUM_JAGS_PER_BUDDY_PER_SESSION : NUM_JAGS_PER_NON_BUDDY_PER_SESSION;
         if(_jaggedPlayers[param1] < _loc9_)
         {
            ++_jaggedPlayers[param1];
            if(param8 != null)
            {
               _sendResponseCallback = param8;
            }
            gMainFrame.server.setXtObject_Str("es",[param1,param2,param3,param4,param5,param6,param7]);
            return true;
         }
         DarkenManager.showLoadingSpiral(false);
         new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14961,param1));
         return false;
      }
      
      public static function sendECardDeleteRequest(param1:int, param2:Function = null) : void
      {
         if(param2 != null)
         {
            _deleteResponseCallback = param2;
         }
         DarkenManager.showLoadingSpiral(true);
         gMainFrame.server.setXtObject_Str("ed",[param1]);
      }
      
      public static function sendECardBuddyRequest(param1:int, param2:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("eb",[param1,param2 ? 1 : 0]);
      }
      
      public static function sendECardAcceptDiscardGiftRequest(param1:int, param2:Boolean, param3:Function) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(param3 != null)
            {
               _giftResponseCallback = param3;
            }
            gMainFrame.server.setXtObject_Str("eg",[param1,param2 ? 1 : 0]);
         }
         else if(param3 != null)
         {
            param3(0,true);
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         DarkenManager.showLoadingSpiral(false);
         switch(_loc2_[0])
         {
            case "el":
               eCardListResponse(_loc2_);
               break;
            case "er":
               eCardReadResponse(_loc2_);
               break;
            case "ed":
               eCardDeleteResponse(_loc2_);
               break;
            case "es":
               eCardSendResponse(_loc2_);
               break;
            case "eg":
               eCardGiftResponse(_loc2_);
               break;
            case "eb":
               eCardBuddyResponse(_loc2_);
               break;
            case "ep":
               eCardPushHandler(_loc2_);
               break;
            case "eu":
               eCardUpdateHandler(_loc2_);
               break;
            default:
               throw new Error("ECardXtCommManager: Received illegal cmd: " + _loc2_[0]);
         }
      }
      
      private static function eCardListResponse(param1:Object) : void
      {
         var _loc6_:ECard = null;
         var _loc2_:int = int(param1[2]);
         var _loc3_:Array = new Array(_loc2_);
         if(_loc2_ == -1)
         {
            _loc2_ = 0;
         }
         var _loc4_:int = 0;
         var _loc5_:* = 3;
         var _loc7_:int = 0;
         while(_loc7_ < _loc2_)
         {
            _loc6_ = new ECard();
            _loc6_.init(int(param1[_loc5_++]),param1[_loc5_++],int(param1[_loc5_++]),int(param1[_loc5_++]),param1[_loc5_++] == "1",param1[_loc5_++],int(param1[_loc5_++]),int(param1[_loc5_++]),uint(param1[_loc5_++]),param1[_loc5_++],int(param1[_loc5_++]),int(param1[_loc5_++]),int(param1[_loc5_++]),int(param1[_loc5_++]),int(param1[_loc5_++]));
            if(_loc6_.msg.match("(^[0-9]{1,2},[0-9]{1,2}$)|(^[0-9]{1,2}$)"))
            {
               _loc6_.msg = SafeChatManager.safeChatStringForCode(_loc6_.msg,SafeChatManager.TREE_ECARDTEXT);
            }
            if(_loc6_.type == ECard.TYPE_GEMS)
            {
               _loc6_.giftName = LocalizationManager.translateIdAndInsertOnly(_loc6_.giftName == "1" ? LocalizationManager.GEM_CAPITALIZED : LocalizationManager.GEMS_CAPITALIZED,Utility.convertNumberToString(int(_loc6_.giftName)));
            }
            else if(_loc6_.type == ECard.TYPE_DIAMOND)
            {
               _loc6_.giftName = LocalizationManager.translateIdAndInsertOnly(_loc6_.giftName == "1" ? LocalizationManager.DIAMOND_CAPITALIZED : LocalizationManager.DIAMONDS_CAPITALIZED,Utility.convertNumberToString(int(_loc6_.giftName)));
            }
            else if(_loc6_.type == ECard.TYPE_DEN_ROOM)
            {
               _loc6_.giftName = LocalizationManager.translateIdAndInsertOnly(15000,LocalizationManager.translateIdOnly(int(_loc6_.giftName)));
            }
            else
            {
               _loc6_.giftName = LocalizationManager.translateIdOnly(int(_loc6_.giftName));
            }
            if(_loc6_.isFromVoice)
            {
               _loc6_.senderUserName = LocalizationManager.translateIdOnly(int(_loc6_.senderUserName));
            }
            _loc3_[_loc7_] = _loc6_;
            if(!_loc6_.isRead && !(_loc6_.isAJHQGift && !gMainFrame.userInfo.isMember))
            {
               _loc4_++;
            }
            _loc7_++;
         }
         ECardManager.processECardList(_loc3_,_loc4_);
         if(_requestCallback != null)
         {
            _requestCallback(_loc3_);
            _requestCallback = null;
         }
      }
      
      private static function eCardReadResponse(param1:Object) : void
      {
         if(_readResponseCallback != null)
         {
            _readResponseCallback(int(param1[2]),param1[3] == "1");
         }
      }
      
      private static function eCardDeleteResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1[2] == "1" ? true : false;
         var _loc3_:int = int(param1[3]);
         var _loc4_:* = 4;
         var _loc5_:Array = new Array(_loc3_);
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_)
         {
            _loc5_[_loc6_] = param1[_loc4_++];
            _loc6_++;
         }
         if(_deleteResponseCallback != null)
         {
            _deleteResponseCallback(_loc5_,_loc2_);
         }
      }
      
      private static function eCardSendResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1[2] == "1" ? true : false;
         if(_sendResponseCallback != null)
         {
            _sendResponseCallback(_loc2_);
         }
      }
      
      private static function eCardGiftResponse(param1:Object) : void
      {
         if(_giftResponseCallback != null)
         {
            _giftResponseCallback(int(param1[2]),param1[3] == "1");
         }
      }
      
      private static function eCardBuddyResponse(param1:Object) : void
      {
         if(param1[2] == -1)
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14692));
         }
      }
      
      private static function eCardPushHandler(param1:Object) : void
      {
         var _loc2_:ECard = new ECard();
         var _loc3_:* = 2;
         _loc2_.init(int(param1[_loc3_++]),param1[_loc3_++],int(param1[_loc3_++]),int(param1[_loc3_++]),param1[_loc3_++] == "1",param1[_loc3_++],int(param1[_loc3_++]),int(param1[_loc3_++]),uint(param1[_loc3_++]),param1[_loc3_++],int(param1[_loc3_++]),int(param1[_loc3_++]),int(param1[_loc3_++]),int(param1[_loc3_++]),int(param1[_loc3_++]));
         if(_loc2_.msg.match("(^[0-9]{1,2},[0-9]{1,2}$)|(^[0-9]{1,2}$)"))
         {
            _loc2_.msg = SafeChatManager.safeChatStringForCode(_loc2_.msg,SafeChatManager.TREE_ECARDTEXT);
         }
         if(_loc2_.type == ECard.TYPE_GEMS)
         {
            _loc2_.giftName = LocalizationManager.translateIdAndInsertOnly(_loc2_.giftName == "1" ? LocalizationManager.GEM_CAPITALIZED : LocalizationManager.GEMS_CAPITALIZED,Utility.convertNumberToString(int(_loc2_.giftName)));
         }
         else if(_loc2_.type == ECard.TYPE_DIAMOND)
         {
            _loc2_.giftName = LocalizationManager.translateIdAndInsertOnly(_loc2_.giftName == "1" ? LocalizationManager.DIAMOND_CAPITALIZED : LocalizationManager.DIAMONDS_CAPITALIZED,Utility.convertNumberToString(int(_loc2_.giftName)));
         }
         else if(_loc2_.type == ECard.TYPE_DEN_ROOM)
         {
            _loc2_.giftName = LocalizationManager.translateIdAndInsertOnly(15000,LocalizationManager.translateIdOnly(int(_loc2_.giftName)));
         }
         else
         {
            _loc2_.giftName = LocalizationManager.translateIdOnly(int(_loc2_.giftName));
         }
         if(_loc2_.isFromVoice)
         {
            _loc2_.senderUserName = LocalizationManager.translateIdOnly(int(_loc2_.senderUserName));
         }
         ECardManager.processECardPush(_loc2_);
      }
      
      private static function eCardUpdateHandler(param1:Object) : void
      {
         ECardManager.processECardUpdate(param1[2],param1[3]);
      }
   }
}

