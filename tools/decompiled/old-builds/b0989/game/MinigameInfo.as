package game
{
   import flash.display.MovieClip;
   
   public class MinigameInfo
   {
      
      public var gameDefId:uint;
      
      public var titleStrId:uint;
      
      public var title:String;
      
      public var extName:String;
      
      public var swfName:String;
      
      public var minPlayers:uint;
      
      public var maxPlayers:uint;
      
      public var maxSpectators:uint;
      
      public var type:uint;
      
      public var gameCardMediaId:uint;
      
      public var gameCountUserVarRef:uint;
      
      public var custom1UserVarRef:uint;
      
      public var custom2UserVarRef:uint;
      
      public var readyForPVP:Boolean;
      
      public var gemMultiplier:Number;
      
      public var petDefId:int;
      
      public var proModeUserVarRefId:int;
      
      public var lbUseVarRef:int;
      
      public var gameCardScreen:MovieClip;
      
      public function MinigameInfo()
      {
         super();
      }
      
      public function init(param1:uint, param2:uint, param3:String, param4:String, param5:String, param6:uint, param7:uint, param8:uint, param9:uint, param10:uint, param11:uint, param12:uint, param13:uint, param14:uint, param15:Number, param16:MovieClip, param17:int, param18:int, param19:int) : void
      {
         this.gameDefId = param1;
         this.titleStrId = param2;
         this.title = param3;
         this.extName = param4;
         this.swfName = param5;
         this.minPlayers = param6;
         this.maxPlayers = param7;
         this.maxSpectators = param8;
         this.type = param9;
         this.gameCardMediaId = param10;
         this.gameCountUserVarRef = param11;
         this.custom1UserVarRef = param12;
         this.custom2UserVarRef = param13;
         this.readyForPVP = param14 != 0;
         this.gemMultiplier = param15;
         this.gameCardScreen = param16;
         this.petDefId = param17;
         this.proModeUserVarRefId = param18;
         this.lbUseVarRef = param19;
      }
      
      public function get isInRoomGame() : Boolean
      {
         return this.type == 0;
      }
   }
}

