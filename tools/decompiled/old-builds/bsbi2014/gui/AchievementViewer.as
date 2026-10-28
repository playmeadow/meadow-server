package gui
{
   import achievement.Achievement;
   import achievement.AchievementXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   
   public class AchievementViewer
   {
      
      private var _achievementMediaHelper:MediaHelper;
      
      private var _achievementPopupContent:MovieClip;
      
      private var _itemWindows:WindowGenerator;
      
      private var _scrollButtons:MovieClip;
      
      private var _achievements:Array;
      
      private var _xPos:int;
      
      private var _yPos:int;
      
      private var _numAchievementsLastDrawn:int;
      
      private var _hasBeenInited:Boolean;
      
      private var _loadingSpiral:LoadingSpiral;
      
      public function AchievementViewer()
      {
         super();
      }
      
      public function init(initXPos:int, initYPos:int, initMediaId:int = -1, rebuild:Boolean = false) : void
      {
         this._achievements = new Array();
         this._xPos = initXPos;
         this._yPos = initYPos;
         if(!gMainFrame.userInfo.playerUserInfo.achievements)
         {
            AchievementXtCommManager.requestAchievements(gMainFrame.userInfo.playerUserInfo.userName,this.achievementListCallback);
            if(Boolean(this._loadingSpiral))
            {
               this._loadingSpiral.visible = true;
            }
         }
         else
         {
            this._achievements = gMainFrame.userInfo.playerUserInfo.achievements;
         }
         if(initMediaId != -1 && this._achievementPopupContent == null)
         {
            this._achievementMediaHelper = new MediaHelper();
            this._achievementMediaHelper.init(initMediaId,this.mediaHelperCallback,rebuild);
         }
         else
         {
            this._achievementPopupContent.x = this._xPos;
            this._achievementPopupContent.y = this._yPos + this._achievementPopupContent.height * 0.5;
         }
         if(Boolean(this._achievementPopupContent))
         {
            this._achievementPopupContent.visible = true;
            this._achievementPopupContent.counterTxt.text = this._achievements.length;
            this.createWindows();
            this._hasBeenInited = true;
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._achievementMediaHelper))
         {
            this._achievementMediaHelper.destroy();
         }
         if(Boolean(this._scrollButtons))
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(Boolean(this._itemWindows))
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         if(Boolean(this._achievements))
         {
            this._achievements = null;
         }
         if(Boolean(this._achievementPopupContent))
         {
            this.removeEventListeners();
            GuiManager.guiLayer.removeChild(this._achievementPopupContent);
            this._achievementPopupContent.visible = false;
            this._achievementPopupContent = null;
         }
         this._hasBeenInited = false;
         GuiManager.mainHud.awardsBtn.downToUpState();
      }
      
      public function loadMedia(id:int = -1) : void
      {
         if(id != -1)
         {
            this._achievementMediaHelper = new MediaHelper();
            this._achievementMediaHelper.init(id,this.initMediaCallback);
         }
      }
      
      public function open() : void
      {
         if(this._numAchievementsLastDrawn < this._achievements.length)
         {
            this.createWindows();
            this._achievementPopupContent.counterTxt.text = this._achievements.length;
         }
         this._achievementPopupContent.visible = true;
      }
      
      public function close() : void
      {
         GuiManager.mainHud.awardsBtn.downToUpState();
         this._achievementPopupContent.visible = false;
      }
      
      public function get visible() : Boolean
      {
         if(Boolean(this._achievementPopupContent))
         {
            return this._achievementPopupContent.visible;
         }
         return false;
      }
      
      public function get hasBeenInited() : Boolean
      {
         return this._hasBeenInited;
      }
      
      private function addAchievementCallback(aList:Array) : void
      {
         for(var i:int = 0; i < aList.length; i++)
         {
            this._achievements[i] = aList[i].image;
         }
      }
      
      private function initMediaCallback(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._achievementPopupContent = MovieClip(img.getChildAt(0));
            this._achievementPopupContent.counterTxt.text = "";
            GuiManager.guiLayer.addChild(this._achievementPopupContent);
            this.addEventListeners();
            this._achievementPopupContent.visible = false;
            this._loadingSpiral = new LoadingSpiral(this._achievementPopupContent.itemBlock,this._achievementPopupContent.itemBlock.width * 0.5,this._achievementPopupContent.itemBlock.height * 0.5);
            this._loadingSpiral.visible = false;
            this._achievementMediaHelper.destroy();
            this._achievementMediaHelper = null;
         }
      }
      
      private function mediaHelperCallback(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._achievementPopupContent = MovieClip(img.getChildAt(0));
            this._achievementPopupContent.x = this._xPos;
            this._achievementPopupContent.y = this._yPos + this._achievementPopupContent.height * 0.5;
            this._achievementPopupContent.counterTxt.text = "";
            GuiManager.guiLayer.addChild(this._achievementPopupContent);
            this.addEventListeners();
            this._loadingSpiral = new LoadingSpiral(this._achievementPopupContent.itemBlock,this._achievementPopupContent.itemBlock.width * 0.5,this._achievementPopupContent.itemBlock.height * 0.5);
            this._loadingSpiral.visible = false;
            if(Boolean(img.passback))
            {
               this._achievementPopupContent.visible = false;
            }
            else
            {
               this._achievementPopupContent.counterTxt.text = this._achievements.length;
               this.createWindows();
               this._hasBeenInited = true;
            }
         }
      }
      
      private function achievementListCallback(aList:Array) : void
      {
         if(Boolean(aList))
         {
            this._achievements = aList;
            if(Boolean(this._achievementPopupContent))
            {
               this._achievementPopupContent.counterTxt.text = this._achievements.length;
               this.createWindows(true);
            }
         }
      }
      
      private function createWindows(isFromCallback:Boolean = false) : void
      {
         if(Boolean(this._scrollButtons))
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(Boolean(this._itemWindows) && this._itemWindows.numChildren > 0)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         var numItemsInCurrentArray:int = this._numAchievementsLastDrawn = this._achievements.length;
         var xCount:int = Math.min(numItemsInCurrentArray,5);
         var yCount:int = Math.ceil(xCount / 5);
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(xCount,yCount,Math.ceil(numItemsInCurrentArray / xCount) * xCount,0,0,0,ItemWindowBase,this._achievements,"image",{
            "mouseOver":this.winMouseOver,
            "mouseOut":this.winMouseOut
         },{"itemClassName":"awardCont"});
         this._achievementPopupContent.itemBlock.addChild(this._itemWindows);
         if(isFromCallback)
         {
            this._loadingSpiral.visible = false;
         }
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(this._itemWindows,328,213,0,"scrollbar2",71);
         if(Boolean(this._loadingSpiral))
         {
            this._loadingSpiral.visible = false;
         }
      }
      
      private function onPopupDownHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.close();
      }
      
      private function winMouseOver(evt:MouseEvent) : void
      {
         var id:int = int(evt.currentTarget.index);
         var a:Achievement = this._achievements[id];
         GuiManager.toolTip.init(this._achievementPopupContent.itemBlock,a.name,0,0);
         GuiManager.toolTip.startTimer(evt);
         var yPos:int = evt.currentTarget.y + this._itemWindows.y;
         if(a.baseImageMediaId == Achievement.BASE_RIBBON_ID)
         {
            yPos += 42;
         }
         else if(a.baseImageMediaId == Achievement.BASE_MEDAL_ID)
         {
            yPos += 56;
         }
         else
         {
            yPos += 57;
         }
         var xPos:int = evt.currentTarget.x + evt.currentTarget.width * 0.5;
         var diff:Number = GuiManager.toolTip.width * 0.5 - xPos;
         if(diff > 15)
         {
            xPos += diff - 15;
         }
         GuiManager.toolTip.setPos(xPos,yPos);
      }
      
      private function winMouseOut(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function addEventListeners() : void
      {
         this._achievementPopupContent.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDownHandler,false,0,true);
         this._achievementPopupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._achievementPopupContent.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDownHandler);
         this._achievementPopupContent.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
      }
   }
}

