package gui
{
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import buddy.Buddy;
   import com.sbi.client.SFClient;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PlayerSearch
   {
      
      public static const SEARCH_MEDIA_ID:int = 396;
      
      public static const LOADING_SPIRAL_ID:int = 397;
      
      private var _searchPopup:MovieClip;
      
      private var _searchMediaHelper:MediaHelper;
      
      private var _lastSearchedName:String;
      
      public function PlayerSearch()
      {
         super();
      }
      
      public function init() : void
      {
         this._searchMediaHelper = new MediaHelper();
         this._searchMediaHelper.init(SEARCH_MEDIA_ID,this.searchMediaCallback,true);
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         this._searchMediaHelper.destroy();
         GuiManager.guiLayer.removeChild(this._searchPopup);
         DarkenManager.unDarken(this._searchPopup);
         this._searchPopup = null;
      }
      
      private function searchMediaCallback(param1:MovieClip) : void
      {
         this._searchPopup = MovieClip(param1.getChildAt(0));
         this._searchPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._searchPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         GuiManager.guiLayer.addChild(this._searchPopup);
         this.addListeners();
         this.setInitialConditions();
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(this._searchPopup);
         this._searchMediaHelper = new MediaHelper();
         this._searchMediaHelper.init(LOADING_SPIRAL_ID,this.loadingSpiralCallback,true);
      }
      
      private function loadingSpiralCallback(param1:MovieClip) : void
      {
         if(this._searchPopup)
         {
            this._searchPopup.itemBlock.addChild(param1);
            this._searchPopup.itemBlock.visible = false;
         }
      }
      
      private function setInitialConditions() : void
      {
         this._searchPopup.userNameTxt.text = "";
         this._searchPopup.userNameTxt.restrict = "A-Za-z0-9";
         this._searchPopup.userNameTxt.maxChars = 32;
         gMainFrame.stage.focus = this._searchPopup.userNameTxt;
         this._searchPopup.notFoundTab.visible = false;
      }
      
      private function popupCloseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.destroy();
      }
      
      private function onSearchBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.performSearch();
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         if(param1.keyCode == 13)
         {
            this.performSearch();
         }
      }
      
      private function performSearch() : void
      {
         var _loc3_:Buddy = null;
         this._searchPopup.notFoundTab.visible = true;
         LocalizationManager.translateId(this._searchPopup.notFoundTab.getChildAt(1),11369);
         var _loc1_:String = this._searchPopup.userNameTxt.text;
         if(gMainFrame.userInfo.myUserName.toLowerCase() == _loc1_.toLowerCase())
         {
            LocalizationManager.translateId(this._searchPopup.notFoundTab.getChildAt(1),11370);
            gMainFrame.stage.focus = this._searchPopup.userNameTxt;
            return;
         }
         var _loc2_:String = _loc1_.toLowerCase();
         if(this._lastSearchedName != _loc2_)
         {
            this._lastSearchedName = _loc2_;
            _loc3_ = BuddyManager.getBuddyByUserName(_loc2_);
            if(_loc3_)
            {
               this._searchPopup.notFoundTab.visible = false;
               BuddyCard.showBuddyCard({
                  "userName":_loc3_.userName,
                  "onlineStatus":_loc3_.onlineStatus
               });
               this.destroy();
            }
            else
            {
               this._searchPopup.notFoundTab.visible = false;
               this._searchPopup.itemBlock.visible = true;
               AvatarXtCommManager.requestAvatarGet(_loc1_,this.onUserLookUpReceived,true);
            }
         }
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc4_:UserInfo = null;
         if(this._searchPopup)
         {
            this._searchPopup.itemBlock.visible = false;
            _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(param1);
            if(param2)
            {
               if(_loc4_)
               {
                  if(_loc4_.userNameModeratedFlag > 0 && param1.toLowerCase() == this._searchPopup.userNameTxt.text.toLowerCase())
                  {
                     BuddyCard.showBuddyCard({
                        "userName":param1,
                        "onlineStatus":param3
                     });
                     this.destroy();
                  }
                  else
                  {
                     this._searchPopup.notFoundTab.visible = true;
                     gMainFrame.stage.focus = this._searchPopup.userNameTxt;
                  }
               }
               else
               {
                  BuddyCard.showBuddyCard({
                     "userName":param1,
                     "onlineStatus":param3
                  });
                  this.destroy();
               }
            }
            else if(param3 == SFClient.STATUS_DIFFERENT_VERSION)
            {
               this.destroy();
            }
            else
            {
               this._searchPopup.notFoundTab.visible = true;
               gMainFrame.stage.focus = this._searchPopup.userNameTxt;
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addListeners() : void
      {
         this._searchPopup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.popupCloseHandler,false,0,true);
         this._searchPopup.searchBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSearchBtnHandler,false,0,true);
         this._searchPopup.userNameTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
         this._searchPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
      }
      
      private function removeListeners() : void
      {
         this._searchPopup["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.popupCloseHandler);
         this._searchPopup.searchBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSearchBtnHandler);
         this._searchPopup.userNameTxt.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
         this._searchPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
      }
   }
}

