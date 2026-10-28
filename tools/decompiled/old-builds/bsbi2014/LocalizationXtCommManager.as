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
      
      public static function sendLocalizationShardRequest(shardId:int) : void
      {
         RoomXtCommManager.waitForLangPack = true;
         AvatarManager.waitForLangPack = true;
         gMainFrame.server.setXtObject_Str("ls",[shardId]);
      }
      
      public static function sendLocalizationShardsRequest(shardIds:Array) : void
      {
         RoomXtCommManager.waitForLangPack = true;
         AvatarManager.waitForLangPack = true;
         gMainFrame.server.setXtObject_Str("ls",shardIds);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         switch(data[0])
         {
            case "ls":
               handleLocalizationShardResponse(data);
               return;
            default:
               throw new Error("LocalizationXtCommManager: Received illegal cmd: " + data[0]);
         }
      }
      
      private static function handleLocalizationShardResponse(data:Object) : void
      {
         var langIdResponseMsg:String = data[2];
         onLocalizationShardResponse(langIdResponseMsg);
      }
      
      public static function onLocalizationShardResponse(langIdResponseMsg:String) : void
      {
         var langIdResponse:String = null;
         var langIdResponseParsed:Array = null;
         var shardId:int = 0;
         var langId:int = 0;
         var langIdResponses:Array = langIdResponseMsg.split(",");
         var _loc7_:int = 0;
         var _loc8_:* = langIdResponses;
         for each(langIdResponse in _loc8_)
         {
            langIdResponseParsed = langIdResponse.split(":");
            shardId = int(langIdResponseParsed[0]);
            langId = int(langIdResponseParsed[1]);
            requestLocalizationPack(langId);
         }
      }
      
      public static function requestLocalizationPack(languageId:int) : void
      {
         var dpdh:DefPacksDefHelper = new DefPacksDefHelper();
         LocalizationManager.currentLanguage = languageId;
         LocalizationManager.hasLocalizations = false;
         RoomXtCommManager.waitForLangPack = true;
         AvatarManager.waitForLangPack = true;
         dpdh.init(uint(DefPacksDefHelper.DEF_LOCALIZATION + "" + languageId),onLocalizationListResponse,RoomXtCommManager.startRoomLoadIfReady,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LOCALIZATION + "" + languageId] = dpdh;
      }
      
      public static function onLocalizationListResponse(dfdh:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LOCALIZATION + "." + LocalizationManager.currentLanguage] = null;
         LocalizationManager.setLocalizations(dfdh.def,GuiManager.mainHud != null ? GuiManager.rebuildMainHud : null);
         if(Boolean(dfdh.passback))
         {
            dfdh.passback();
         }
      }
      
      public static function onPreferredLocalizationListResponse(dfdh:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PREFERRED_LOCALIZATION + "." + LocalizationManager.accountLanguage] = null;
         LocalizationManager.setPreferredLocalizations(dfdh.def);
      }
   }
}

