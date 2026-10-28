package avatar
{
   import com.sbi.analytics.SBTracker;
   import flash.display.MovieClip;
   import gui.DarkenManager;
   
   public class NewWorldAvatar implements INewAvatar
   {
      
      public function NewWorldAvatar()
      {
         super();
      }
      
      public function screenInitCallback(param1:MovieClip) : void
      {
         param1.visible = false;
      }
      
      public function get playSound() : Boolean
      {
         return false;
      }
      
      public function newAvatarData(param1:int, param2:String, param3:Array, param4:Function, param5:Boolean = false) : void
      {
         SBTracker.trackPageview("/game/play/popup/avatarSwitch/buyAnimal");
         var _loc6_:Boolean = Boolean(param2 && param2 != "" && RegExp(/a-zA-Z0-9 /)["exec"](param2) == null);
         if(_loc6_)
         {
            AvatarSwitch.addNewWorldAvatar(param1,param2,param3,param5);
         }
         if(param4 != null && !AvatarSwitch.isAddingSlot)
         {
            param4(_loc6_);
         }
         if(_loc6_)
         {
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      public function hideConnectingMsg() : void
      {
      }
      
      public function nameTypeScreenDone() : void
      {
         AvatarUtility.creationAssets.visible = false;
         AvatarUtility.creationAssets.destroyReloadedItems();
      }
      
      public function logInForCreateAvatarData() : void
      {
      }
   }
}

