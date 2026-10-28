package avatar
{
   import com.sbi.analytics.SBTracker;
   import flash.display.MovieClip;
   import gui.DarkenManager;
   import gui.GuiManager;
   
   public class NewWorldAvatar implements INewAvatar
   {
      
      public function NewWorldAvatar()
      {
         super();
      }
      
      public function screenInitCallback(soundBtn:MovieClip) : void
      {
         soundBtn.visible = false;
      }
      
      public function get playSound() : Boolean
      {
         return false;
      }
      
      public function newAvatarData(type:int, avatarName:String, avatarNameIndexes:Array, avNameValidGuiCallback:Function, isShopBuy:Boolean = false) : void
      {
         SBTracker.trackPageview("/game/play/popup/avatarSwitch/buyAnimal");
         var avNameValid:Boolean = Boolean(avatarName && avatarName != "" && RegExp(/a-zA-Z0-9 /)["exec"](avatarName) == null);
         if(avNameValid)
         {
            AvatarSwitch.addNewWorldAvatar(type,avatarName,avatarNameIndexes,isShopBuy);
         }
         if(avNameValidGuiCallback != null && !AvatarSwitch.isAddingSlot)
         {
            avNameValidGuiCallback(avNameValid);
         }
         if(avNameValid)
         {
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      public function hideConnectingMsg() : void
      {
      }
      
      public function nameTypeScreenDone() : void
      {
         GuiManager.closeAvatarCreator();
      }
      
      public function logInForCreateAvatarData() : void
      {
      }
   }
}

