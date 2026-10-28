package gui
{
   import com.sbi.popup.SBPopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   
   public class GameCardPopup extends SBPopup
   {
      
      public static const LEADERBOARD_TYPE_ALLTIME:int = 1;
      
      public static const LEADERBOARD_TYPE_THISWEEK:int = 2;
      
      public static const LEADERBOARD_TYPE_BUDDY:int = 3;
      
      private var _onStartClicked:Function;
      
      private var _onInstructionsClicked:Function;
      
      private var _onLeaderBoardClicked:Function;
      
      private var _onLeaderBoardSelected:Function;
      
      private var _thePopup:MovieClip = GETDEFINITIONBYNAME("JoinGameContent");
      
      private var _theSkin:MovieClip;
      
      private var _originalBX:int;
      
      public function GameCardPopup(param1:DisplayObjectContainer, param2:Sprite, param3:Function, param4:Function, param5:Function, param6:Function, param7:Function, param8:Boolean, param9:int, param10:Boolean)
      {
         LocalizationManager.translateId(this._thePopup.msg.msgTxt,11279);
         if(this._thePopup.hasOwnProperty("gameTitle") && param2 != null)
         {
            this._thePopup.gameTitle.addChild(param2);
         }
         this._onStartClicked = param3;
         this._onInstructionsClicked = param4;
         this._onLeaderBoardClicked = param6;
         this._onLeaderBoardSelected = param7;
         this._thePopup.startBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAnyStartClicked,false,0,true);
         this._thePopup.proStartBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAnyStartClicked,false,0,true);
         this._thePopup.instrBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onInstructionsClicked,false,0,true);
         if(param10 && !Utility.canMultiplayer())
         {
            this._thePopup.startBtn.activateGrayState(true);
            this._thePopup.proStartBtn.activateGrayState(true);
         }
         if(this._onLeaderBoardClicked != null)
         {
            this._thePopup.leaderboardsButton.gotoAndStop("active");
            this._thePopup.leaderboards_popup.thisWeekDown.addEventListener(MouseEvent.CLICK,this.thisWeekClicked);
            this._thePopup.leaderboards_popup.buddiesDown.addEventListener(MouseEvent.CLICK,this.buddiesClicked);
            this._thePopup.leaderboards_popup.allTimeDown.addEventListener(MouseEvent.CLICK,this.allTimeClicked);
            this._thePopup.leaderboards_popup.bx.addEventListener(MouseEvent.CLICK,this.leaderBoardBXClicked);
            this._thePopup.leaderboardsButton.btn.addEventListener(MouseEvent.CLICK,this.leaderBoardClicked,false,0,true);
         }
         if(param8)
         {
            this._thePopup.gotoAndPlay("pro");
            if(param9 <= 0)
            {
               this._thePopup.proStartBtn.activateGrayState(true);
            }
         }
         this._theSkin = GETDEFINITIONBYNAME("JoinGameSkin");
         this._theSkin.bx.addEventListener(MouseEvent.CLICK,param5,false,0,true);
         this._originalBX = this._theSkin.bx.y;
         super(param1,this._theSkin,this._thePopup,true,true,false,false,true);
      }
      
      public function getVisibleLeaderBoard() : int
      {
         if(this._thePopup.leaderboards_popup.thisWeekUp.visible)
         {
            return LEADERBOARD_TYPE_THISWEEK;
         }
         if(this._thePopup.leaderboards_popup.allTimeUp.visible)
         {
            return LEADERBOARD_TYPE_ALLTIME;
         }
         return LEADERBOARD_TYPE_BUDDY;
      }
      
      private function thisWeekClicked(param1:MouseEvent) : void
      {
         this._thePopup.leaderboards_popup.thisWeekUp.visible = true;
         this._thePopup.leaderboards_popup.allTimeUp.visible = false;
         this._thePopup.leaderboards_popup.buddiesUp.visible = false;
         if(this._onLeaderBoardSelected != null)
         {
            this._onLeaderBoardSelected();
         }
      }
      
      private function buddiesClicked(param1:MouseEvent) : void
      {
         this._thePopup.leaderboards_popup.thisWeekUp.visible = false;
         this._thePopup.leaderboards_popup.allTimeUp.visible = false;
         this._thePopup.leaderboards_popup.buddiesUp.visible = true;
         if(this._onLeaderBoardSelected != null)
         {
            this._onLeaderBoardSelected();
         }
      }
      
      private function allTimeClicked(param1:MouseEvent) : void
      {
         this._thePopup.leaderboards_popup.thisWeekUp.visible = false;
         this._thePopup.leaderboards_popup.allTimeUp.visible = true;
         this._thePopup.leaderboards_popup.buddiesUp.visible = false;
         if(this._onLeaderBoardSelected != null)
         {
            this._onLeaderBoardSelected();
         }
      }
      
      private function leaderBoardClicked(param1:MouseEvent) : void
      {
         this._thePopup.leaderboardsButton.gotoAndPlay("off");
         this._thePopup.gotoAndPlay("normal_l");
         this._thePopup.gotoAndPlay("pro_l");
         this._theSkin.bx.y = -1000;
         if(this._onLeaderBoardClicked != null)
         {
            this._onLeaderBoardClicked();
         }
      }
      
      private function leaderBoardBXClicked(param1:MouseEvent) : void
      {
         this._thePopup.leaderboardsButton.gotoAndPlay("on");
         this._thePopup.gotoAndPlay("normal_l_close");
         this._thePopup.gotoAndPlay("pro_l_close");
         this._theSkin.bx.y = this._originalBX;
      }
      
      public function populateLeaderBoard(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1 != null && param1.length > 0)
         {
            if(param1[0]._score != -1)
            {
               this._thePopup.leaderboards_popup["p11"].text = param1[0]._name;
               this._thePopup.leaderboards_popup["s11"].text = param1[0]._score;
            }
            else
            {
               this._thePopup.leaderboards_popup["p11"].text = "";
               this._thePopup.leaderboards_popup["s11"].text = "";
            }
            _loc2_ = 1;
            while(_loc2_ < 11)
            {
               if(_loc2_ < param1.length)
               {
                  this._thePopup.leaderboards_popup["p" + _loc2_].text = param1[_loc2_]._name;
                  this._thePopup.leaderboards_popup["s" + _loc2_].text = param1[_loc2_]._score;
                  if(param1[_loc2_]._name == param1[0]._name)
                  {
                     this._thePopup.leaderboards_popup["p" + _loc2_].textColor = 26265;
                     this._thePopup.leaderboards_popup["s" + _loc2_].textColor = 26265;
                  }
                  else
                  {
                     this._thePopup.leaderboards_popup["p" + _loc2_].textColor = 4137240;
                     this._thePopup.leaderboards_popup["s" + _loc2_].textColor = 4137240;
                  }
               }
               else
               {
                  this._thePopup.leaderboards_popup["p" + _loc2_].text = "";
                  this._thePopup.leaderboards_popup["s" + _loc2_].text = "";
               }
               _loc2_++;
            }
         }
         else
         {
            _loc2_ = 1;
            while(_loc2_ <= 11)
            {
               this._thePopup.leaderboards_popup["p" + _loc2_].text = "";
               this._thePopup.leaderboards_popup["s" + _loc2_].text = "";
               _loc2_++;
            }
         }
      }
      
      private function onAnyStartClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         if(param1.currentTarget.name == "startBtn")
         {
            this._onStartClicked(0);
         }
         else if(param1.currentTarget.name == "proStartBtn")
         {
            this._onStartClicked(1);
         }
      }
      
      private function onInstructionsClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._onInstructionsClicked != null)
         {
            this._onInstructionsClicked();
         }
      }
   }
}

