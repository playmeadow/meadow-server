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
      
      public static function genericListVolumeClicked(glId:int, o:Object = null) : void
      {
         var glTypeId:int = int(gMainFrame.userInfo.getGenericListDefByDefId(glId).typeId);
         switch(glTypeId)
         {
            case DefPacksDefHelper.DEF_ITEM:
            case DefPacksDefHelper.DEF_DEN_ITEM:
            case DefPacksDefHelper.DEF_CURRENCY_EXCHANGE:
            case DefPacksDefHelper.DEF_DIAMOND:
               if(o == null || !o.hasOwnProperty("volName") || QuestManager.onShopClick(o.volName))
               {
                  launchStore(glId,glTypeId);
               }
               break;
            case DefPacksDefHelper.DEF_DEN_ROOM:
               GuiManager.openDenRoomSwitcher(false,null,true,-1,glId);
               break;
            case DefPacksDefHelper.DEF_STREAM:
               DarkenManager.showLoadingSpiral(true);
               GenericListXtCommManager.requestStreamList(glId,launchMovies,o);
               break;
            case DefPacksDefHelper.DEF_LOCALIZATION:
            case DefPacksDefHelper.DEF_MEDIA:
            case DefPacksDefHelper.DEF_FACT:
         }
      }
      
      public static function launchMovies(glId:int, streamIds:Array, thumbIds:Array, baseTitles:Array, indivTitles:Array, statusIds:Array, subtitleIds:Array, helperObject:Object = null) : void
      {
         var shouldRepeat:Boolean = false;
         if(streamIds.length > 1)
         {
            GenericListXtCommManager.filterList(DefPacksDefHelper.DEF_STREAM,streamIds,{
               "thumbIds":thumbIds,
               "baseTitles":baseTitles,
               "indivTitles":indivTitles,
               "statusIds":statusIds,
               "subtitleIds":subtitleIds
            });
            if(Boolean(movieSelector) && Boolean(RoomManagerWorld.instance.theaterWindow))
            {
               DarkenManager.showLoadingSpiral(false);
               movieSelector.toggleVisibility();
            }
            else
            {
               if(Boolean(movieSelector))
               {
                  movieSelector.destroy();
                  movieSelector = null;
               }
               movieSelector = new MovieManager();
               movieSelector.init(GuiManager.guiLayer,RoomManagerWorld.instance.theaterWindow,thumbIds,streamIds,baseTitles,indivTitles,statusIds,subtitleIds,MovieManager.VID_SELECTOR_MEDIA_ID,MovieManager.VID_PLAYER_MEDIA_ID,onMovieSelectorClose);
               if(Boolean(helperObject))
               {
                  movieSelector.setSkinFrame(frameIdForMsg(helperObject.msg));
                  if(helperObject.msg == "bb" || helperObject.msg == "tt")
                  {
                     movieSelector.setQuestionBtn();
                  }
                  if(Boolean(helperObject.titleTxt))
                  {
                     movieSelector.setTitleTxt(helperObject.titleTxt);
                  }
                  if(helperObject.msg.indexOf("autoplay") != -1)
                  {
                     movieSelector.chooseRandom(true,frameIdForMsg(helperObject.msg),helperObject.shouldRepeat != null ? Boolean(helperObject.shouldRepeat) : false);
                  }
                  if(helperObject.shouldRepeat != null)
                  {
                     movieSelector.setShouldRepeat(helperObject.shouldRepeat);
                  }
                  if(Boolean(helperObject.width) && Boolean(helperObject.height))
                  {
                     movieSelector.setDefaultWidthHeight(helperObject.width,helperObject.height);
                  }
               }
            }
         }
         else if(Boolean(helperObject))
         {
            shouldRepeat = true;
            if(helperObject.shouldRepeat != null)
            {
               shouldRepeat = Boolean(helperObject.shouldRepeat);
            }
            if(Boolean(helperObject.width) && Boolean(helperObject.height))
            {
               GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,streamIds,baseTitles,subtitleIds,shouldRepeat,helperObject.width,helperObject.height);
            }
            else
            {
               GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,streamIds,baseTitles,subtitleIds,shouldRepeat);
            }
            if(Boolean(helperObject.msg))
            {
               GuiManager.setVideoPlayerSkin(frameIdForMsg(helperObject.msg));
            }
         }
         else
         {
            GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,streamIds,baseTitles,subtitleIds,false);
         }
      }
      
      public static function onRoomExit() : void
      {
         if(Boolean(movieSelector))
         {
            movieSelector.destroy();
            movieSelector = null;
         }
      }
      
      public static function isWorldShopOpen() : Boolean
      {
         return _shop != null;
      }
      
      private static function frameIdForMsg(msg:String) : int
      {
         msg = msg.toLowerCase();
         if(msg == "bb" || msg == "bb_experiments")
         {
            return MovieManager.BRADY_BARR_SKIN;
         }
         if(msg == "tt" || msg == "tt_autoplay")
         {
            return MovieManager.TIERNEY_THYS_SKIN;
         }
         if(msg == "biggerframe")
         {
            return MovieManager.BIGGER_FRAME;
         }
         return MovieManager.NORMAL_SKIN;
      }
      
      private static function onMovieSelectorClose() : void
      {
         if(Boolean(movieSelector))
         {
            movieSelector.toggleVisibility();
         }
      }
      
      private static function launchStore(glId:int, glTypeId:int) : void
      {
         if(Boolean(_shop))
         {
            _shop.destroy();
         }
         _shop = new Shop();
         _shop.init(glId,glTypeId,AvatarManager.playerAvatar,GuiManager.guiLayer,true,onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private static function onShopClose(itemsPurchased:Boolean) : void
      {
         if(Boolean(_shop))
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

