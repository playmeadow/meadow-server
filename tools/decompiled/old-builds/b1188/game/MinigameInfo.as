package game
{
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class MinigameInfo
   {
      
      public var gameDefId:uint;
      
      public var titleStrId:uint;
      
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
      
      private var _gameCardScreen:MovieClip;
      
      private var _hasLoadedScreen:Boolean;
      
      public function MinigameInfo()
      {
         super();
      }
      
      public function init(param1:uint, param2:uint, param3:String, param4:String, param5:uint, param6:uint, param7:uint, param8:uint, param9:uint, param10:uint, param11:uint, param12:uint, param13:uint, param14:Number, param15:MovieClip, param16:int, param17:int, param18:int) : void
      {
         this.gameDefId = param1;
         this.titleStrId = param2;
         this.extName = param3;
         this.swfName = param4;
         this.minPlayers = param5;
         this.maxPlayers = param6;
         this.maxSpectators = param7;
         this.type = param8;
         this.gameCardMediaId = param9;
         this.gameCountUserVarRef = param10;
         this.custom1UserVarRef = param11;
         this.custom2UserVarRef = param12;
         this.readyForPVP = param13 != 0;
         this.gemMultiplier = param14;
         this.gameCardScreen = param15;
         this.petDefId = param16;
         this.proModeUserVarRefId = param17;
         this.lbUseVarRef = param18;
      }
      
      public function get isInRoomGame() : Boolean
      {
         return this.type == 0;
      }
      
      public function get gameCardScreen() : MovieClip
      {
         var _loc1_:MediaHelper = null;
         if(this._hasLoadedScreen)
         {
            return this._gameCardScreen;
         }
         this._gameCardScreen = new MovieClip();
         _loc1_ = new MediaHelper();
         _loc1_.init(this.gameCardMediaId,this.onScreenLoaded);
         return this._gameCardScreen;
      }
      
      public function set gameCardScreen(param1:MovieClip) : void
      {
         if(param1 != null)
         {
            this._hasLoadedScreen = true;
         }
         this._gameCardScreen = param1;
      }
      
      private function onScreenLoaded(param1:MovieClip) : void
      {
         this._gameCardScreen.addChild(param1);
      }
   }
}

