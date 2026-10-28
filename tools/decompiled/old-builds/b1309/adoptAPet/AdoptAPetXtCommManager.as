package adoptAPet
{
   import Enums.AdoptAPetDef;
   import collection.AdoptAPetDefCollection;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import loader.DefPacksDefHelper;
   
   public class AdoptAPetXtCommManager
   {
      
      private static var _padCallback:Function;
      
      private static var _padcCallback:Function;
      
      public function AdoptAPetXtCommManager()
      {
         super();
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function onAdoptAPetDefsResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:AdoptAPetDef = null;
         var _loc4_:AdoptAPetDefCollection = new AdoptAPetDefCollection();
         var _loc5_:AdoptAPetDefCollection = new AdoptAPetDefCollection();
         for each(var _loc3_:Object in param1.def)
         {
            _loc2_ = new AdoptAPetDef(int(_loc3_.id),int(_loc3_.titleStrId),int(_loc3_.mediaRefId),int(_loc3_.type));
            _loc4_.setAdoptAPetItem(_loc2_.defId,_loc2_);
            _loc5_.pushAdoptAPetItem(_loc2_);
         }
         DefPacksDefHelper.mediaArray[1061] = null;
         AdoptAPetManager.setAdoptAPetDefs(_loc4_);
         AdoptAPetManager.setAdoptAPetDefsNonIndexed(_loc5_);
      }
      
      public static function requestPetAdoptUsableData(param1:String, param2:Function) : void
      {
         _padCallback = param2;
         gMainFrame.server.setXtObject_Str("pad",[param1],gMainFrame.server.isWorldZone);
      }
      
      public static function requestPetAdoptUsableCount(param1:String, param2:Function) : void
      {
         _padcCallback = param2;
         gMainFrame.server.setXtObject_Str("padc",[param1],gMainFrame.server.isWorldZone);
      }
      
      public static function requestPetAdoptUsableSeenSet(param1:Array) : void
      {
         gMainFrame.server.setXtObject_Str("pads",param1,gMainFrame.server.isWorldZone);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: AdoptAPetXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "pad":
               handlePetAdoptData(_loc2_);
               break;
            case "padc":
               handlePetAdoptDataCount(_loc2_);
               break;
            default:
               throw new Error("AdoptAPetXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function handlePetAdoptData(param1:Object) : void
      {
         var _loc2_:int = int(param1[2]);
         if(_padCallback != null)
         {
            _padCallback(_loc2_,param1);
            _padCallback = null;
         }
      }
      
      private static function handlePetAdoptDataCount(param1:Object) : void
      {
         if(_padcCallback != null)
         {
            _padcCallback(param1[2]);
            _padcCallback = null;
         }
      }
      
      public function init() : void
      {
      }
   }
}

