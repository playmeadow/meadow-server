package pet
{
   import com.sbi.client.SFEvent;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   
   public class PetXtCommManager
   {
      
      public static var canLoadPetList:Boolean;
      
      private static var _plCallback:Function;
      
      private static var _pdCallback:Function;
      
      private static var _psCallback:Function;
      
      private static var _pcCallback:Function;
      
      private static var _piCallback:Function;
      
      private static var _pmCallback:Function;
      
      public function PetXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
      }
      
      public static function destroy() : void
      {
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Array = evt.obj;
         switch(data[0])
         {
            case "pl":
               onPetListResponse(data);
               break;
            case "pc":
               onPetCreateResponse(data);
               break;
            case "ps":
               onPetSwitchResponse(data);
               break;
            case "pi":
               onPetItemsResponse(data);
               break;
            case "pm":
               onPetMasteryResponse(data);
               break;
            case "pd":
               onPetDismissResponse(data);
         }
      }
      
      public static function sendPetListRequest(userName:String, callback:Function = null) : void
      {
         _plCallback = callback;
         gMainFrame.server.setXtObject_Str("pl",[userName]);
      }
      
      public static function sendPetCreateRequest(lBits:int, uBits:int, eBits:uint, nameIdx1:int, nameIdx2:int, callback:Function = null, isFromRedemption:Boolean = false) : void
      {
         _pcCallback = callback;
         gMainFrame.server.setXtObject_Str("pc",[lBits,uBits,eBits,nameIdx1,nameIdx2,isFromRedemption ? "1" : "0"]);
      }
      
      public static function sendPetShopBuyRequest(storeId:int, itemDefId:int, lBits:int, uBits:int, eBits:uint, nameIdx1:int, nameIdx2:int, callback:Function = null, isFromRedemption:Boolean = false) : void
      {
         _pcCallback = callback;
         gMainFrame.server.setXtObject_Str("pb",[storeId,itemDefId,GenericListXtCommManager.getAvailListUniqueId(),lBits,uBits,eBits,nameIdx1,nameIdx2,isFromRedemption ? "1" : "0"]);
      }
      
      public static function sendPetDismissRequest(invId:int, callback:Function = null) : void
      {
         _pdCallback = callback;
         gMainFrame.server.setXtObject_Str("pd",[invId]);
      }
      
      public static function sendPetSwitchRequest(invId:int, callback:Function = null) : void
      {
         _psCallback = callback;
         gMainFrame.server.setXtObject_Str("ps",[invId]);
      }
      
      public static function sendPetItemRequest(cat9:int, cat10:int, cat11:int, environment:int, callback:Function) : void
      {
         _piCallback = callback;
         gMainFrame.server.setXtObject_Str("pi",[cat9,cat10,cat11,environment]);
      }
      
      public static function sendPetMasteryRequest(cat8:int, petInvId:int, callback:Function = null) : void
      {
         _pmCallback = callback;
         gMainFrame.server.setXtObject_Str("pm",[cat8,petInvId]);
      }
      
      public static function petDefsResponse(dfdh:DefPacksDefHelper) : void
      {
         var petDef:Object = null;
         var data:Object = null;
         var myPetList:Array = null;
         var i:int = 0;
         var petDefs:Object = new Object();
         for each(data in dfdh.def)
         {
            petDef = {
               "defId":int(data.id),
               "mediaRefId":int(data.mediaRefId),
               "type":int(data.type),
               "isGround":PetManager.isGround(data.type),
               "title":LocalizationManager.translateIdOnly(int(data.titleStrId)),
               "titleStrId":int(data.titleStrId),
               "isMember":data.isMember == "1",
               "cost":int(data.cost),
               "status":int(data.status)
            };
            petDefs[petDef.defId] = petDef;
         }
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PET] = null;
         PetManager.petDefs = petDefs;
         myPetList = PetManager.myPetList;
         for(i = 0; i < myPetList.length; i++)
         {
            if(myPetList[i].type == -1)
            {
               myPetList[i].type = PetManager.petTypeForDefId(myPetList[i].defId);
            }
         }
         if(canLoadPetList)
         {
            sendPetListRequest(gMainFrame.server.userName);
         }
         canLoadPetList = true;
      }
      
      private static function onPetListResponse(data:Array) : void
      {
         PetManager.onPetListResponse(data,_plCallback);
         _plCallback = null;
      }
      
      private static function onPetCreateResponse(data:Array) : void
      {
         PetManager.onPetCreateResponse(data,_pcCallback);
         _pcCallback = null;
      }
      
      private static function onPetItemsResponse(data:Array) : void
      {
         PetManager.onPetItemsResponse(data,_piCallback);
         _piCallback = null;
      }
      
      private static function onPetMasteryResponse(data:Array) : void
      {
         PetManager.onPetMasteryResponse(data,_pmCallback);
         _pmCallback = null;
      }
      
      private static function onPetDismissResponse(data:Array) : void
      {
         PetManager.onPetDismissResponse(data,_pdCallback);
         _pdCallback = null;
      }
      
      private static function onPetSwitchResponse(data:Array) : void
      {
         PetManager.onPetSwitchResponse(data,_psCallback);
         _psCallback = null;
      }
   }
}

