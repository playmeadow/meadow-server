package gui
{
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import buddy.Buddy;
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
      
      private function searchMediaCallback(img:MovieClip) : void
      {
         this._searchPopup = MovieClip(img.getChildAt(0));
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
      
      private function loadingSpiralCallback(img:MovieClip) : void
      {
         if(Boolean(this._searchPopup))
         {
            this._searchPopup.itemBlock.addChild(img);
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
      
      private function popupCloseHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         this.destroy();
      }
      
      private function onSearchBtnHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         this.performSearch();
      }
      
      private function keyDownListener(k:KeyboardEvent) : void
      {
         k.stopPropagation();
         if(k.keyCode == 13)
         {
            this.performSearch();
         }
      }
      
      private function performSearch() : void
      {
         var bud:Buddy = null;
         this._searchPopup.notFoundTab.visible = true;
         LocalizationManager.translateId(this._searchPopup.notFoundTab.getChildAt(1),11369);
         var userName:String = this._searchPopup.userNameTxt.text;
         if(gMainFrame.userInfo.myUserName.toLowerCase() == userName.toLowerCase())
         {
            LocalizationManager.translateId(this._searchPopup.notFoundTab.getChildAt(1),11370);
            gMainFrame.stage.focus = this._searchPopup.userNameTxt;
            return;
         }
         var lcUserName:String = userName.toLowerCase();
         if(this._lastSearchedName != lcUserName)
         {
            this._lastSearchedName = lcUserName;
            bud = BuddyManager.getBuddyByUserName(lcUserName);
            if(Boolean(bud))
            {
               this._searchPopup.notFoundTab.visible = false;
               BuddyCard.showBuddyCard({
                  "userName":bud.userName,
                  "onlineStatus":bud.onlineStatus
               });
               this.destroy();
            }
            else
            {
               this._searchPopup.notFoundTab.visible = false;
               this._searchPopup.itemBlock.visible = true;
               AvatarXtCommManager.requestAvatarGet(userName,this.onUserLookUpReceived,true);
            }
         }
      }
      
      private function onUserLookUpReceived(userName:String, status:Boolean, onlineStatus:int) : void
      {
         var ui:UserInfo = null;
         if(Boolean(this._searchPopup))
         {
            this._searchPopup.itemBlock.visible = false;
            ui = gMainFrame.userInfo.getUserInfoByUserName(userName);
            if(status)
            {
               if(Boolean(ui))
               {
                  if(ui.userNameModeratedFlag > 0 && userName.toLowerCase() == this._searchPopup.userNameTxt.text.toLowerCase())
                  {
                     BuddyCard.showBuddyCard({
                        "userName":userName,
                        "onlineStatus":onlineStatus
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
                     "userName":userName,
                     "onlineStatus":onlineStatus
                  });
                  this.destroy();
               }
            }
            else
            {
               this._searchPopup.notFoundTab.visible = true;
               gMainFrame.stage.focus = this._searchPopup.userNameTxt;
            }
         }
      }
      
      private function onPopup(e:MouseEvent) : void
      {
         e.stopPropagation();
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

