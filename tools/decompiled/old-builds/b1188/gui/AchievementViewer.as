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
      
      public function init(param1:int, param2:int, param3:int = -1, param4:Boolean = false) : void
      {
         this._achievements = new Array();
         this._xPos = param1;
         this._yPos = param2;
         if(!gMainFrame.userInfo.playerUserInfo.achievements)
         {
            AchievementXtCommManager.requestAchievements(gMainFrame.userInfo.playerUserInfo.userName,this.achievementListCallback);
            if(this._loadingSpiral)
            {
               this._loadingSpiral.visible = true;
            }
         }
         else
         {
            this._achievements = gMainFrame.userInfo.playerUserInfo.achievements;
         }
         if(param3 != -1 && this._achievementPopupContent == null)
         {
            this._achievementMediaHelper = new MediaHelper();
            this._achievementMediaHelper.init(param3,this.mediaHelperCallback,param4);
         }
         else
         {
            this._achievementPopupContent.x = this._xPos;
            this._achievementPopupContent.y = this._yPos + this._achievementPopupContent.height * 0.5;
         }
         if(this._achievementPopupContent)
         {
            this._achievementPopupContent.parent.setChildIndex(this._achievementPopupContent,this._achievementPopupContent.parent.numChildren - 1);
            this._achievementPopupContent.visible = true;
            this._achievementPopupContent.counterTxt.text = this._achievements.length;
            this.createWindows();
            this._hasBeenInited = true;
         }
      }
      
      public function destroy() : void
      {
         if(this._achievementMediaHelper)
         {
            this._achievementMediaHelper.destroy();
         }
         if(this._scrollButtons)
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(this._itemWindows)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         if(this._achievements)
         {
            this._achievements = null;
         }
         if(this._achievementPopupContent)
         {
            this.removeEventListeners();
            GuiManager.guiLayer.removeChild(this._achievementPopupContent);
            this._achievementPopupContent.visible = false;
            this._achievementPopupContent = null;
         }
         this._hasBeenInited = false;
         GuiManager.mainHud.awardsBtn.downToUpState();
      }
      
      public function loadMedia(param1:int = -1) : void
      {
         if(param1 != -1)
         {
            this._achievementMediaHelper = new MediaHelper();
            this._achievementMediaHelper.init(param1,this.initMediaCallback);
         }
      }
      
      public function open() : void
      {
         if(this._numAchievementsLastDrawn < this._achievements.length)
         {
            this.createWindows();
            this._achievementPopupContent.counterTxt.text = this._achievements.length;
         }
         this._achievementPopupContent.parent.setChildIndex(this._achievementPopupContent,this._achievementPopupContent.parent.numChildren - 1);
         this._achievementPopupContent.visible = true;
      }
      
      public function close() : void
      {
         GuiManager.mainHud.awardsBtn.downToUpState();
         this._achievementPopupContent.visible = false;
      }
      
      public function get visible() : Boolean
      {
         if(this._achievementPopupContent)
         {
            return this._achievementPopupContent.visible;
         }
         return false;
      }
      
      public function get hasBeenInited() : Boolean
      {
         return this._hasBeenInited;
      }
      
      private function addAchievementCallback(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this._achievements[_loc2_] = param1[_loc2_].image;
            _loc2_++;
         }
      }
      
      private function initMediaCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            this._achievementPopupContent = MovieClip(param1.getChildAt(0));
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
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            this._achievementPopupContent = MovieClip(param1.getChildAt(0));
            this._achievementPopupContent.x = this._xPos;
            this._achievementPopupContent.y = this._yPos + this._achievementPopupContent.height * 0.5;
            this._achievementPopupContent.counterTxt.text = "";
            GuiManager.guiLayer.addChild(this._achievementPopupContent);
            this.addEventListeners();
            this._loadingSpiral = new LoadingSpiral(this._achievementPopupContent.itemBlock,this._achievementPopupContent.itemBlock.width * 0.5,this._achievementPopupContent.itemBlock.height * 0.5);
            this._loadingSpiral.visible = false;
            if(param1.passback)
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
      
      private function achievementListCallback(param1:Array) : void
      {
         if(param1)
         {
            this._achievements = param1;
            if(this._achievementPopupContent)
            {
               this._achievementPopupContent.counterTxt.text = this._achievements.length;
               this.createWindows(true);
            }
         }
      }
      
      private function createWindows(param1:Boolean = false) : void
      {
         if(this._scrollButtons)
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(this._itemWindows)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         var _loc2_:int = this._numAchievementsLastDrawn = this._achievements.length;
         var _loc3_:int = Math.min(_loc2_,5);
         var _loc4_:int = Math.ceil(_loc3_ / 5);
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(_loc3_,_loc4_,Math.ceil(_loc2_ / _loc3_) * _loc3_,0,0,0,ItemWindowBase,this._achievements,"image",{
            "mouseOver":this.winMouseOver,
            "mouseOut":this.winMouseOut
         },{"itemClassName":"awardCont"});
         this._achievementPopupContent.itemBlock.addChild(this._itemWindows);
         if(param1)
         {
            this._loadingSpiral.visible = false;
         }
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(this._itemWindows,328,213,0,"scrollbar2",71);
         if(this._loadingSpiral)
         {
            this._loadingSpiral.visible = false;
         }
      }
      
      private function onPopupDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.close();
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.index);
         var _loc3_:Achievement = this._achievements[_loc2_];
         GuiManager.toolTip.init(this._achievementPopupContent.itemBlock,_loc3_.name,0,0);
         GuiManager.toolTip.startTimer(param1);
         var _loc4_:int = param1.currentTarget.y + this._itemWindows.y;
         if(_loc3_.baseImageMediaId == Achievement.BASE_RIBBON_ID)
         {
            _loc4_ += 42;
         }
         else if(_loc3_.baseImageMediaId == Achievement.BASE_MEDAL_ID)
         {
            _loc4_ += 56;
         }
         else
         {
            _loc4_ += 57;
         }
         var _loc5_:int = param1.currentTarget.x + param1.currentTarget.width * 0.5;
         var _loc6_:Number = GuiManager.toolTip.width * 0.5 - _loc5_;
         if(_loc6_ > 15)
         {
            _loc5_ += _loc6_ - 15;
         }
         GuiManager.toolTip.setPos(_loc5_,_loc4_);
      }
      
      private function winMouseOut(param1:MouseEvent) : void
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

