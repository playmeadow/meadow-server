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
      
      public function GameCardPopup(parent:DisplayObjectContainer, gameCard:Sprite, onStartClicked:Function, onInstrClicked:Function, onXClicked:Function, onLeaderBoardClicked:Function, onLeaderBoardSelected:Function, showProModeBtn:Boolean, proModeValue:int, isMultiplayer:Boolean)
      {
         LocalizationManager.translateId(this._thePopup.msg.msgTxt,11279);
         if(this._thePopup.hasOwnProperty("gameTitle") && gameCard != null)
         {
            this._thePopup.gameTitle.addChild(gameCard);
         }
         this._onStartClicked = onStartClicked;
         this._onInstructionsClicked = onInstrClicked;
         this._onLeaderBoardClicked = onLeaderBoardClicked;
         this._onLeaderBoardSelected = onLeaderBoardSelected;
         this._thePopup.startBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAnyStartClicked,false,0,true);
         this._thePopup.proStartBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAnyStartClicked,false,0,true);
         this._thePopup.instrBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onInstructionsClicked,false,0,true);
         if(isMultiplayer && !Utility.canMultiplayer())
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
         if(showProModeBtn)
         {
            this._thePopup.gotoAndPlay("pro");
            if(proModeValue <= 0)
            {
               this._thePopup.proStartBtn.activateGrayState(true);
            }
         }
         this._theSkin = GETDEFINITIONBYNAME("JoinGameSkin");
         this._theSkin.bx.addEventListener(MouseEvent.CLICK,onXClicked,false,0,true);
         this._originalBX = this._theSkin.bx.y;
         super(parent,this._theSkin,this._thePopup,true,true,false,false,true);
      }
      
      public function getVisibleLeaderBoard() : int
      {
         if(Boolean(this._thePopup.leaderboards_popup.thisWeekUp.visible))
         {
            return LEADERBOARD_TYPE_THISWEEK;
         }
         if(Boolean(this._thePopup.leaderboards_popup.allTimeUp.visible))
         {
            return LEADERBOARD_TYPE_ALLTIME;
         }
         return LEADERBOARD_TYPE_BUDDY;
      }
      
      private function thisWeekClicked(e:MouseEvent) : void
      {
         this._thePopup.leaderboards_popup.thisWeekUp.visible = true;
         this._thePopup.leaderboards_popup.allTimeUp.visible = false;
         this._thePopup.leaderboards_popup.buddiesUp.visible = false;
         if(this._onLeaderBoardSelected != null)
         {
            this._onLeaderBoardSelected();
         }
      }
      
      private function buddiesClicked(e:MouseEvent) : void
      {
         this._thePopup.leaderboards_popup.thisWeekUp.visible = false;
         this._thePopup.leaderboards_popup.allTimeUp.visible = false;
         this._thePopup.leaderboards_popup.buddiesUp.visible = true;
         if(this._onLeaderBoardSelected != null)
         {
            this._onLeaderBoardSelected();
         }
      }
      
      private function allTimeClicked(e:MouseEvent) : void
      {
         this._thePopup.leaderboards_popup.thisWeekUp.visible = false;
         this._thePopup.leaderboards_popup.allTimeUp.visible = true;
         this._thePopup.leaderboards_popup.buddiesUp.visible = false;
         if(this._onLeaderBoardSelected != null)
         {
            this._onLeaderBoardSelected();
         }
      }
      
      private function leaderBoardClicked(e:MouseEvent) : void
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
      
      private function leaderBoardBXClicked(e:MouseEvent) : void
      {
         this._thePopup.leaderboardsButton.gotoAndPlay("on");
         this._thePopup.gotoAndPlay("normal_l_close");
         this._thePopup.gotoAndPlay("pro_l_close");
         this._theSkin.bx.y = this._originalBX;
      }
      
      public function populateLeaderBoard(leaderBoardData:Array) : void
      {
         var i:int = 0;
         if(leaderBoardData != null && leaderBoardData.length > 0)
         {
            if(leaderBoardData[0]._score != -1)
            {
               this._thePopup.leaderboards_popup["p11"].text = leaderBoardData[0]._name;
               this._thePopup.leaderboards_popup["s11"].text = leaderBoardData[0]._score;
            }
            else
            {
               this._thePopup.leaderboards_popup["p11"].text = "";
               this._thePopup.leaderboards_popup["s11"].text = "";
            }
            for(i = 1; i < 11; i++)
            {
               if(i < leaderBoardData.length)
               {
                  this._thePopup.leaderboards_popup["p" + i].text = leaderBoardData[i]._name;
                  this._thePopup.leaderboards_popup["s" + i].text = leaderBoardData[i]._score;
                  if(leaderBoardData[i]._name == leaderBoardData[0]._name)
                  {
                     this._thePopup.leaderboards_popup["p" + i].textColor = 26265;
                     this._thePopup.leaderboards_popup["s" + i].textColor = 26265;
                  }
                  else
                  {
                     this._thePopup.leaderboards_popup["p" + i].textColor = 4137240;
                     this._thePopup.leaderboards_popup["s" + i].textColor = 4137240;
                  }
               }
               else
               {
                  this._thePopup.leaderboards_popup["p" + i].text = "";
                  this._thePopup.leaderboards_popup["s" + i].text = "";
               }
            }
         }
         else
         {
            for(i = 1; i <= 11; i++)
            {
               this._thePopup.leaderboards_popup["p" + i].text = "";
               this._thePopup.leaderboards_popup["s" + i].text = "";
            }
         }
      }
      
      private function onAnyStartClicked(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(evt.currentTarget.isGray))
         {
            return;
         }
         if(evt.currentTarget.name == "startBtn")
         {
            this._onStartClicked(0);
         }
         else if(evt.currentTarget.name == "proStartBtn")
         {
            this._onStartClicked(1);
         }
      }
      
      private function onInstructionsClicked(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._onInstructionsClicked != null)
         {
            this._onInstructionsClicked();
         }
      }
   }
}

