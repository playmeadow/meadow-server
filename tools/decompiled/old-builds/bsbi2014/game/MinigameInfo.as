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
      
      public function init(initGameDefId:uint, initTitleStrId:uint, initExtName:String, initSwfName:String, initMinPlayers:uint, initMaxPlayers:uint, initMaxSpectators:uint, initType:uint, initGameCardMediaId:uint, initGameCountUserVarRef:uint, initCustom1UserVarRef:uint, initCustom2UserVarRef:uint, initReadyForPVP:uint, initGemMultiplier:Number, initGameCardScreen:MovieClip, initPetDefId:int, initProModeUserVarRefId:int, initLeaderboardUserVarRef:int) : void
      {
         this.gameDefId = initGameDefId;
         this.titleStrId = initTitleStrId;
         this.extName = initExtName;
         this.swfName = initSwfName;
         this.minPlayers = initMinPlayers;
         this.maxPlayers = initMaxPlayers;
         this.maxSpectators = initMaxSpectators;
         this.type = initType;
         this.gameCardMediaId = initGameCardMediaId;
         this.gameCountUserVarRef = initGameCountUserVarRef;
         this.custom1UserVarRef = initCustom1UserVarRef;
         this.custom2UserVarRef = initCustom2UserVarRef;
         this.readyForPVP = initReadyForPVP != 0;
         this.gemMultiplier = initGemMultiplier;
         this.gameCardScreen = initGameCardScreen;
         this.petDefId = initPetDefId;
         this.proModeUserVarRefId = initProModeUserVarRefId;
         this.lbUseVarRef = initLeaderboardUserVarRef;
      }
      
      public function get isInRoomGame() : Boolean
      {
         return this.type == 0;
      }
      
      public function get gameCardScreen() : MovieClip
      {
         var screenMediaHelper:MediaHelper = null;
         if(this._hasLoadedScreen)
         {
            return this._gameCardScreen;
         }
         this._gameCardScreen = new MovieClip();
         screenMediaHelper = new MediaHelper();
         screenMediaHelper.init(this.gameCardMediaId,this.onScreenLoaded);
         return this._gameCardScreen;
      }
      
      public function set gameCardScreen(screen:MovieClip) : void
      {
         if(screen != null)
         {
            this._hasLoadedScreen = true;
         }
         this._gameCardScreen = screen;
      }
      
      private function onScreenLoaded(img:MovieClip) : void
      {
         this._gameCardScreen.addChild(img);
      }
   }
}

