package gui
{
   import avatar.AvatarManager;
   import loader.DefPacksDefHelper;
   import movie.MovieManager;
   import room.RoomManagerWorld;
   
   public class GenericListGuiManager
   {
      
      public static var movieSelector:MovieManager;
      
      private static var _shop:Shop;
      
      public function GenericListGuiManager()
      {
         super();
      }
      
      public static function genericListVolumeClicked(param1:int, param2:Object = null) : void
      {
         var _loc3_:int = int(gMainFrame.userInfo.getGenericListDefByDefId(param1).typeId);
         switch(_loc3_)
         {
            case DefPacksDefHelper.DEF_ITEM:
            case DefPacksDefHelper.DEF_DEN_ITEM:
            case DefPacksDefHelper.DEF_CURRENCY_EXCHANGE:
            case DefPacksDefHelper.DEF_DIAMOND:
               launchStore(param1,_loc3_);
               break;
            case DefPacksDefHelper.DEF_DEN_ROOM:
               GuiManager.openDenRoomSwitcher(false,null,true);
            case DefPacksDefHelper.DEF_STREAM:
               DarkenManager.showLoadingSpiral(true);
               GenericListXtCommManager.requestStreamList(param1,launchMovies,param2);
               break;
            case DefPacksDefHelper.DEF_LOCALIZATION:
            case DefPacksDefHelper.DEF_MEDIA:
            case DefPacksDefHelper.DEF_FACT:
         }
      }
      
      public static function launchMovies(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array, param7:Object = null) : void
      {
         if(param2.length > 1)
         {
            GenericListXtCommManager.filterList(DefPacksDefHelper.DEF_STREAM,param2,{
               "thumbIds":param3,
               "baseTitles":param4,
               "indivTitles":param5,
               "statusIds":param6
            });
            if(Boolean(movieSelector) && Boolean(RoomManagerWorld.instance.theaterWindow))
            {
               DarkenManager.showLoadingSpiral(false);
               movieSelector.toggleVisibility();
            }
            else
            {
               if(movieSelector)
               {
                  movieSelector.destroy();
                  movieSelector = null;
               }
               movieSelector = new MovieManager();
               movieSelector.init(GuiManager.guiLayer,RoomManagerWorld.instance.theaterWindow,param3,param2,param4,param5,param6,MovieManager.VID_SELECTOR_MEDIA_ID,MovieManager.VID_PLAYER_MEDIA_ID,onMovieSelectorClose);
               if(param7)
               {
                  movieSelector.setSkinFrame(frameIdForMsg(param7.msg));
                  if(param7.msg == "bb" || param7.msg == "tt")
                  {
                     movieSelector.setQuestionBtn();
                  }
                  if(param7.titleTxt)
                  {
                     movieSelector.setTitleTxt(param7.titleTxt);
                  }
                  if(param7.msg == "autoplay")
                  {
                     movieSelector.chooseRandom(true);
                  }
               }
            }
         }
         else
         {
            GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,param2,param4,param7 ? false : true);
            if(Boolean(param7) && Boolean(param7.msg))
            {
               GuiManager.setVideoPlayerSkin(frameIdForMsg(param7.msg));
            }
         }
      }
      
      public static function onRoomExit() : void
      {
         if(movieSelector)
         {
            movieSelector.destroy();
            movieSelector = null;
         }
      }
      
      private static function frameIdForMsg(param1:String) : int
      {
         if(param1 == "bb")
         {
            return MovieManager.BRADY_BARR_SKIN;
         }
         if(param1 == "tt")
         {
            return MovieManager.TIERNEY_THYS_SKIN;
         }
         return MovieManager.NORMAL_SKIN;
      }
      
      private static function onMovieSelectorClose() : void
      {
         if(movieSelector)
         {
            movieSelector.toggleVisibility();
         }
      }
      
      private static function launchStore(param1:int, param2:int) : void
      {
         if(_shop)
         {
            _shop.destroy();
         }
         _shop = new Shop();
         _shop.init(param1,param2,AvatarManager.playerAvatar,GuiManager.guiLayer,true,onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private static function onShopClose(param1:Boolean) : void
      {
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
      }
      
      public function init() : void
      {
      }
   }
}

