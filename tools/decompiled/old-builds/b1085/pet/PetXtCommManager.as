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
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "pl":
               onPetListResponse(_loc2_);
               break;
            case "pc":
               onPetCreateResponse(_loc2_);
               break;
            case "ps":
               onPetSwitchResponse(_loc2_);
               break;
            case "pi":
               onPetItemsResponse(_loc2_);
               break;
            case "pm":
               onPetMasteryResponse(_loc2_);
               break;
            case "pd":
               onPetDismissResponse(_loc2_);
         }
      }
      
      public static function sendPetListRequest(param1:String, param2:Function = null) : void
      {
         _plCallback = param2;
         gMainFrame.server.setXtObject_Str("pl",[param1]);
      }
      
      public static function sendPetCreateRequest(param1:int, param2:int, param3:uint, param4:int, param5:int, param6:Function = null, param7:Boolean = false) : void
      {
         _pcCallback = param6;
         gMainFrame.server.setXtObject_Str("pc",[param1,param2,param3,param4,param5,param7 ? "1" : "0"]);
      }
      
      public static function sendPetShopBuyRequest(param1:int, param2:int, param3:int, param4:int, param5:uint, param6:int, param7:int, param8:Function = null, param9:Boolean = false) : void
      {
         _pcCallback = param8;
         gMainFrame.server.setXtObject_Str("pb",[param1,param2,GenericListXtCommManager.getAvailListUniqueId(),param3,param4,param5,param6,param7,param9 ? "1" : "0"]);
      }
      
      public static function sendPetDismissRequest(param1:int, param2:Function = null) : void
      {
         _pdCallback = param2;
         gMainFrame.server.setXtObject_Str("pd",[param1]);
      }
      
      public static function sendPetSwitchRequest(param1:int, param2:Function = null) : void
      {
         _psCallback = param2;
         gMainFrame.server.setXtObject_Str("ps",[param1]);
      }
      
      public static function sendPetItemRequest(param1:int, param2:int, param3:int, param4:int, param5:Function) : void
      {
         _piCallback = param5;
         gMainFrame.server.setXtObject_Str("pi",[param1,param2,param3,param4]);
      }
      
      public static function sendPetMasteryRequest(param1:int, param2:int, param3:Function = null) : void
      {
         _pmCallback = param3;
         gMainFrame.server.setXtObject_Str("pm",[param1,param2]);
      }
      
      public static function petDefsResponse(param1:DefPacksDefHelper) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc2_:Object = new Object();
         for each(_loc4_ in param1.def)
         {
            _loc3_ = {
               "defId":int(_loc4_.id),
               "mediaRefId":int(_loc4_.mediaRefId),
               "type":int(_loc4_.type),
               "isGround":PetManager.isGround(_loc4_.type),
               "title":LocalizationManager.translateIdOnly(int(_loc4_.titleStrId)),
               "isMember":_loc4_.isMember == "1",
               "cost":int(_loc4_.cost),
               "status":int(_loc4_.status)
            };
            _loc2_[_loc3_.defId] = _loc3_;
         }
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PET] = null;
         PetManager.petDefs = _loc2_;
         _loc5_ = PetManager.myPetList;
         _loc6_ = 0;
         while(_loc6_ < _loc5_.length)
         {
            if(_loc5_[_loc6_].type == -1)
            {
               _loc5_[_loc6_].type = PetManager.petTypeForDefId(_loc5_[_loc6_].defId);
            }
            _loc6_++;
         }
         if(canLoadPetList)
         {
            sendPetListRequest(gMainFrame.server.userName);
         }
         canLoadPetList = true;
      }
      
      private static function onPetListResponse(param1:Array) : void
      {
         PetManager.onPetListResponse(param1,_plCallback);
         _plCallback = null;
      }
      
      private static function onPetCreateResponse(param1:Array) : void
      {
         PetManager.onPetCreateResponse(param1,_pcCallback);
         _pcCallback = null;
      }
      
      private static function onPetItemsResponse(param1:Array) : void
      {
         PetManager.onPetItemsResponse(param1,_piCallback);
         _piCallback = null;
      }
      
      private static function onPetMasteryResponse(param1:Array) : void
      {
         PetManager.onPetMasteryResponse(param1,_pmCallback);
         _pmCallback = null;
      }
      
      private static function onPetDismissResponse(param1:Array) : void
      {
         PetManager.onPetDismissResponse(param1,_pdCallback);
         _pdCallback = null;
      }
      
      private static function onPetSwitchResponse(param1:Array) : void
      {
         PetManager.onPetSwitchResponse(param1,_psCallback);
         _psCallback = null;
      }
   }
}

