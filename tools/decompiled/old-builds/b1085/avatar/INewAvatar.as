package avatar
{
   import flash.display.MovieClip;
   
   public interface INewAvatar
   {
      
      function screenInitCallback(param1:MovieClip) : void;
      
      function get playSound() : Boolean;
      
      function newAvatarData(param1:int, param2:String, param3:Array, param4:Function, param5:Boolean = false) : void;
      
      function hideConnectingMsg() : void;
      
      function logInForCreateAvatarData() : void;
      
      function nameTypeScreenDone() : void;
   }
}

