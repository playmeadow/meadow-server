package
{
   import avatar.AvatarManager;
   import com.sbi.client.SFEvent;
   import com.sbi.loader.FileServerEvent;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import room.RoomXtCommManager;
   
   public class LocalizationXtCommManager
   {
      
      public function LocalizationXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         XtReplyDemuxer.addModule(handleXtReply,"l");
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function sendLocalizationShardRequest(param1:int) : void
      {
         RoomXtCommManager.waitForLangPack = true;
         AvatarManager.waitForLangPack = true;
         gMainFrame.server.setXtObject_Str("ls",[param1]);
      }
      
      public static function sendLocalizationShardsRequest(param1:Array) : void
      {
         RoomXtCommManager.waitForLangPack = true;
         AvatarManager.waitForLangPack = true;
         gMainFrame.server.setXtObject_Str("ls",param1);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "ls":
               handleLocalizationShardResponse(_loc2_);
               return;
            default:
               throw new Error("LocalizationXtCommManager: Received illegal cmd: " + _loc2_[0]);
         }
      }
      
      private static function handleLocalizationShardResponse(param1:Object) : void
      {
         var _loc2_:String = param1[2];
         onLocalizationShardResponse(_loc2_);
      }
      
      public static function onLocalizationShardResponse(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:Array = param1.split(",");
         var _loc7_:int = 0;
         var _loc8_:* = _loc2_;
         for each(_loc3_ in _loc8_)
         {
            _loc4_ = _loc3_.split(":");
            _loc5_ = int(_loc4_[0]);
            _loc6_ = int(_loc4_[1]);
            requestLocalizationPack(_loc6_);
         }
      }
      
      public static function requestLocalizationPack(param1:int) : void
      {
         var _loc2_:DefPacksDefHelper = new DefPacksDefHelper();
         LocalizationManager.currentLanguage = param1;
         LocalizationManager.hasLocalizations = false;
         RoomXtCommManager.waitForLangPack = true;
         AvatarManager.waitForLangPack = true;
         _loc2_.init(uint(DefPacksDefHelper.DEF_LOCALIZATION + "" + param1),onLocalizationListResponse,RoomXtCommManager.startRoomLoadIfReady,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LOCALIZATION + "" + param1] = _loc2_;
      }
      
      public static function onLocalizationListResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LOCALIZATION + "." + LocalizationManager.currentLanguage] = null;
         LocalizationManager.setLocalizations(param1.def,GuiManager.mainHud != null ? GuiManager.rebuildMainHud : null);
         if(param1.passback)
         {
            param1.passback();
         }
      }
      
      public static function onPreferredLocalizationListResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PREFERRED_LOCALIZATION + "." + LocalizationManager.accountLanguage] = null;
         LocalizationManager.setPreferredLocalizations(param1.def);
      }
   }
}

