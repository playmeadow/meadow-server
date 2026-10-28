package createAccountFlow
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import localization.LocalizationManager;
   
   public class CreateAccountXtCommManager
   {
      
      public static var logIn:CreateAccount;
      
      private static var _laReturnType:int;
      
      public static const LOGINAVAILABLE_TYPE_USERNAME:int = 0;
      
      public static const LOGINAVAILABLE_TYPE_AVATARNAME:int = 1;
      
      public static const LOGINAVAILABLE_TYPE_SUGGESTIONS:int = 2;
      
      public function CreateAccountXtCommManager()
      {
         super();
      }
      
      public static function init(initLogIn:CreateAccount) : void
      {
         logIn = initLogIn;
         _laReturnType = -1;
         XtReplyDemuxer.addModule(handleXtReply,"l");
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function sendLoginAvailableRequest(laType:int, userName:String, avNameIndex0:int, avNameIndex1:int, avNameIndex2:int) : void
      {
         _laReturnType = laType;
         gMainFrame.server.setXtObject_Str("la",[laType,userName,avNameIndex0,LocalizationManager.isCurrLanguageReversed() ? avNameIndex2 : avNameIndex1,LocalizationManager.isCurrLanguageReversed() ? avNameIndex1 : avNameIndex2,LocalizationManager.currentLanguage],false);
      }
      
      public static function sendLoginMXLookup(domainName:String) : void
      {
         gMainFrame.server.setXtObject_Str("le",[domainName],false);
      }
      
      public static function sendLoginCreateRequest(lcData:Array, lnData:Array) : void
      {
         var lcdi:int = 0;
         var lndi:int = 2;
         var createRa:Array = [lcData[lcdi++],lcData[lcdi++],lcData[lcdi++],lcData[lcdi++],lcData[lcdi++],lcData[lcdi++],lcData[lcdi++],lnData[lndi++],lnData[lndi++],lnData[lndi++],lnData[lndi++],LocalizationManager.accountLanguage,gMainFrame.clientInfo.countryCode];
         lndi += 4;
         if(lcdi != lcData.length)
         {
            throw new Error("Expected end of loginCreate data array lcdi:" + lcdi + " did not match length:" + lcData.length + "!");
         }
         if(lndi != lnData.length)
         {
            throw new Error("Expected end of loginNew data array lndi:" + lndi + " did not match length:" + lnData.length + "!");
         }
         gMainFrame.server.setXtObject_Str("lc",createRa,gMainFrame.server.isWorldZone);
      }
      
      public static function sendLoginNewRequest(lnData:Array) : void
      {
         var lndi:int = 0;
         var lnra:Array = [lnData[lndi++],lnData[lndi++],lnData[lndi++],lnData[lndi++],lnData[lndi++],lnData[lndi++]];
         var newAvItems:Array = lnData[lndi++];
         if(lndi != lnData.length)
         {
            throw new Error("Expected end of loginNew data array lndi:" + lndi + " did not match length:" + lnData.length + "!");
         }
         loginNewAvatarHelper(newAvItems,lnra);
         gMainFrame.server.setXtObject_Str("ln",lnra,gMainFrame.server.isWorldZone);
      }
      
      private static function loginNewAvatarHelper(newAvItems:Array, sendData:Array) : void
      {
         var newAvItemsLength:int = int(newAvItems.length);
         sendData.push(newAvItemsLength);
         for(var naii:int = 0; naii < newAvItemsLength; naii++)
         {
            sendData.push(newAvItems[naii].defId);
         }
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Array = evt.obj;
         DebugUtility.debugTrace("data:" + data);
         switch(data[0])
         {
            case "la":
               logIn.handleLoginAvailable(data,_laReturnType);
               break;
            case "lc":
               logIn.handleLoginCreate(data);
               break;
            case "le":
               logIn.handleLoginEmail(data);
               break;
            default:
               throw new Error("LogIn illegal data:" + data[0]);
         }
      }
   }
}

