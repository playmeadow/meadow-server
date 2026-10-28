package gameRedemption
{
   import avatar.AvatarManager;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import flash.geom.Point;
   import gui.GuiManager;
   
   public class GameRedemptionXtCommManager
   {
      
      private static var _grcCallback:Function;
      
      public static const RESPONSE_REDEEM_SUCCESS:String = "1";
      
      public static const RESPONSE_CODE_NOT_VALID:String = "-1";
      
      public static const RESPONSE_CODE_WRONG_GAME:String = "-2";
      
      public static const RESPONSE_ACCOUNT_NOT_VERIFIED:String = "-3";
      
      public static const RESPONSE_CAPTCHA_GET_LIMIT_EXCEEDED:String = "-4";
      
      public static const RESPONSE_CAPTCHA_INCORRECT_ANSWER:String = "-5";
      
      public static const RESPONSE_CAPTCHA_POST_SHOW_NOW:String = "-6";
      
      public static const RESPONSE_CAPTCHA_POST_SHOW_ON_NEXT_REDEEM:String = "-7";
      
      private static var _captchaToShow:Object;
      
      public function GameRedemptionXtCommManager()
      {
         super();
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function requestRedeemCode(param1:String, param2:String, param3:String, param4:Function) : void
      {
         _grcCallback = param4;
         if(param2 == null || param3 == null)
         {
            param2 = param3 = "";
         }
         gMainFrame.server.setXtObject_Str("grc",[param1,param2,param3],gMainFrame.server.isWorldZone);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: GameRedemptionXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "grc":
               handleRedeemCodeResponse(_loc2_);
               break;
            case "grm":
               handleRedeemMembershipResponse(_loc2_);
               break;
            default:
               throw new Error("GameRedemptionXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      public static function get captchaToShowData() : Object
      {
         return _captchaToShow;
      }
      
      public static function set captchaToShowData(param1:Object) : void
      {
         _captchaToShow = param1;
      }
      
      private static function handleRedeemCodeResponse(param1:Object) : void
      {
         var _loc3_:String = param1[2];
         var _loc2_:Object = param1[3] != null && param1[3] != "" ? JSON.parse(param1[3] as String) : null;
         if(_grcCallback != null)
         {
            _grcCallback(_loc3_,_loc2_);
            _grcCallback = null;
         }
         if(_loc3_ == "1")
         {
            GuiManager.setupInGameRedemptions();
         }
      }
      
      private static function handleRedeemMembershipResponse(param1:Object) : void
      {
         var _loc2_:Point = null;
         var _loc3_:int = int(param1[2]);
         if(_loc3_ == 1)
         {
            GuiManager.rebuildMainHud();
            _loc2_ = new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
            gMainFrame.clientInfo.accountType = param1[3];
            gMainFrame.clientInfo.accountTypeChanged = true;
            gMainFrame.userInfo.isMember = Utility.isMember(gMainFrame.clientInfo.accountType);
            gMainFrame.clientInfo.numDaysLeftOnSubscription = param1[4];
            gMainFrame.userInfo.clearPlayerAvatarInfoType();
            AvatarManager.loadSelfAssets(null,_loc2_.x,_loc2_.y);
         }
      }
   }
}

