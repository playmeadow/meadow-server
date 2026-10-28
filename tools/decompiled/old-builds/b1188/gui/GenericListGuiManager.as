package gui
{
   import avatar.AvatarManager;
   import loader.DefPacksDefHelper;
   import movie.MovieManager;
   import quest.QuestManager;
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
               if(param2 == null || !param2.hasOwnProperty("volName") || QuestManager.onShopClick(param2.volName))
               {
                  launchStore(param1,_loc3_);
               }
               break;
            case DefPacksDefHelper.DEF_DEN_ROOM:
               GuiManager.openDenRoomSwitcher(false,null,true,-1,param1);
               break;
            case DefPacksDefHelper.DEF_STREAM:
               DarkenManager.showLoadingSpiral(true);
               GenericListXtCommManager.requestStreamList(param1,launchMovies,param2);
               break;
            case DefPacksDefHelper.DEF_LOCALIZATION:
            case DefPacksDefHelper.DEF_MEDIA:
            case DefPacksDefHelper.DEF_FACT:
         }
      }
      
      public static function launchMovies(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array, param7:Array, param8:Object = null) : void
      {
         var _loc9_:Boolean = false;
         var _loc10_:Array = null;
         if(param2.length > 1)
         {
            GenericListXtCommManager.filterList(DefPacksDefHelper.DEF_STREAM,param2,{
               "thumbIds":param3,
               "baseTitles":param4,
               "indivTitles":param5,
               "statusIds":param6,
               "subtitleIds":param7
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
               movieSelector.init(GuiManager.guiLayer,RoomManagerWorld.instance.theaterWindow,param3,param2,param4,param5,param6,param7,MovieManager.VID_SELECTOR_MEDIA_ID,MovieManager.VID_PLAYER_MEDIA_ID,onMovieSelectorClose);
               if(param8)
               {
                  movieSelector.setSkinFrame(frameIdForMsg(param8.msg));
                  if(param8.msg == "bb" || param8.msg == "tt")
                  {
                     movieSelector.setQuestionBtn();
                  }
                  if(param8.titleTxt)
                  {
                     movieSelector.setTitleTxt(param8.titleTxt);
                  }
                  if(param8.msg.indexOf("autoplay") != -1)
                  {
                     movieSelector.chooseRandom(true,frameIdForMsg(param8.msg),param8.shouldRepeat != null ? Boolean(param8.shouldRepeat) : false);
                  }
                  if(param8.shouldRepeat != null)
                  {
                     movieSelector.setShouldRepeat(param8.shouldRepeat);
                  }
                  if(Boolean(param8.width) && Boolean(param8.height))
                  {
                     movieSelector.setDefaultWidthHeight(param8.width,param8.height);
                  }
               }
            }
         }
         else if(param8)
         {
            if(param8.msg)
            {
               _loc10_ = param8.msg.split("%");
               if(_loc10_.length > 1)
               {
                  param8.shouldRepeat = _loc10_[1] == "true";
                  param8.width = int(_loc10_[2]);
                  param8.height = int(_loc10_[3]);
               }
            }
            _loc9_ = true;
            if(param8.shouldRepeat != null)
            {
               _loc9_ = Boolean(param8.shouldRepeat);
            }
            if(Boolean(param8.width) && Boolean(param8.height))
            {
               GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,param2,param4,param7,_loc9_,param8.width,param8.height);
            }
            else
            {
               GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,param2,param4,param7,_loc9_);
            }
            if(_loc10_)
            {
               GuiManager.setVideoPlayerSkin(frameIdForMsg(_loc10_[0]));
            }
         }
         else
         {
            GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,param2,param4,param7,false);
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
      
      public static function isWorldShopOpen() : Boolean
      {
         return _shop != null;
      }
      
      private static function frameIdForMsg(param1:String) : int
      {
         param1 = param1.toLowerCase();
         if(param1 == "bb" || param1 == "bb_experiments")
         {
            return MovieManager.BRADY_BARR_SKIN;
         }
         if(param1 == "tt" || param1 == "tt_autoplay")
         {
            return MovieManager.TIERNEY_THYS_SKIN;
         }
         if(param1 == "biggerframe")
         {
            return MovieManager.BIGGER_FRAME;
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

