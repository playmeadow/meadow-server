package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.GridFitType;
   import loader.MediaHelper;
   import loader.NGFactDefHelper;
   import localization.LocalizationManager;
   import movie.MovieManager;
   import room.RoomManagerWorld;
   
   public class NGFactManager
   {
      
      private static var _popupTemplate:MovieClip;
      
      private static var _museumPopupTemplate:MovieClip;
      
      private static var _tabTemplate:MovieClip;
      
      private static var _factPopup:MovieClip;
      
      private static var _popupMediaHelper:MediaHelper;
      
      private static var _tabMediaHelper:MediaHelper;
      
      private static var _factMediaRequests:Array;
      
      private static var _tabFrameLabelLookup:Array;
      
      private static var _popupFrameLabelLookup:Array;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _worldLayer:DisplayLayer;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _factMediaLoadingSpiral:LoadingSpiral;
      
      private static var _factLocs:Array;
      
      private static var _factDefHelpers:Array;
      
      private static var _factDefCache:Array;
      
      private static var _hasPopupBeenLoaded:Boolean;
      
      private static var _hasMuseumPopupBeenLoaded:Boolean;
      
      private static var _museumFactDefList:Array;
      
      private static var _museumFactDefIndexList:Array;
      
      private static var _museumRequest:int;
      
      public static const TYPE_MINERAL:int = 0;
      
      public static const TYPE_PLANT:int = 1;
      
      public static const TYPE_ANIMAL:int = 2;
      
      public static const TYPE_TIKI:int = 3;
      
      public static const TYPE_GECKO:int = 4;
      
      public static const TYPE_BAT:int = 5;
      
      public static const TYPE_CAT:int = 6;
      
      public static const TYPE_INSECT:int = 7;
      
      public static const TYPE_WEATHER:int = 8;
      
      public static const TYPE_HOLIDAY:int = 9;
      
      public static const TYPE_JOURNEY_BOOK:int = 10;
      
      public static const TYPE_AQUARIUM:int = 11;
      
      public static const TYPE_ENDANGERED:int = 12;
      
      public static const TYPE_MUSEUM:int = 13;
      
      public static const TYPE_JOURNEY_BOOK_BIG:int = 14;
      
      public static const TYPE_BRADY:int = 15;
      
      public static const TYPE_MILLIONS:int = 16;
      
      public static const TYPE_EARTHDAY:int = 17;
      
      public static const TYPE_MIGRATION:int = 18;
      
      public static const UV_VIEWED_MINERAL:int = 148;
      
      public static const UV_VIEWED_PLANT:int = 149;
      
      public static const UV_VIEWED_ANIMAL:int = 150;
      
      public static const UV_VIEWED_TIKI:int = 151;
      
      public static const UV_VIEWED_GECKO:int = 152;
      
      public static const UV_VIEWED_BAT:int = 153;
      
      public static const UV_VIEWED_CAT:int = 154;
      
      public static const UV_VIEWED_INSECT:int = 155;
      
      public static const UV_VIEWED_WEATHER:int = 156;
      
      public static const UV_VIEWED_HOLIDAY:int = 296;
      
      public static const UV_VIEWED_ENDANGERED:int = 319;
      
      public static const NGFACTS_MEDIA_ID_POPUP:int = 87;
      
      public static const NGFACTS_MEDIA_ID_TAB:int = 153;
      
      public static const MUSEUM_MEDIA_ID_POPUP:int = 1544;
      
      public static const JB_WORLDSOUNDS_MEDIA_ID:int = 1331;
      
      public function NGFactManager()
      {
         super();
      }
      
      public static function init(initGuiLayer:DisplayLayer, initWorldLayer:DisplayLayer) : void
      {
         _guiLayer = initGuiLayer;
         _worldLayer = initWorldLayer;
         _roomMgr = RoomManagerWorld.instance;
         _factDefHelpers = [];
         _factMediaRequests = [];
         _factDefCache = [];
         _factMediaLoadingSpiral = new LoadingSpiral();
         _tabFrameLabelLookup = [];
         _tabFrameLabelLookup[TYPE_MINERAL] = "mineral";
         _tabFrameLabelLookup[TYPE_PLANT] = "plant";
         _tabFrameLabelLookup[TYPE_ANIMAL] = "animal";
         _tabFrameLabelLookup[TYPE_TIKI] = "animal";
         _tabFrameLabelLookup[TYPE_GECKO] = "animal";
         _tabFrameLabelLookup[TYPE_BAT] = "animal";
         _tabFrameLabelLookup[TYPE_CAT] = "animal";
         _tabFrameLabelLookup[TYPE_INSECT] = "insect";
         _tabFrameLabelLookup[TYPE_WEATHER] = "weather";
         _tabFrameLabelLookup[TYPE_HOLIDAY] = "holiday";
         _tabFrameLabelLookup[TYPE_ENDANGERED] = "animal";
         _popupFrameLabelLookup = [];
         _popupFrameLabelLookup[0] = "mineral";
         _popupFrameLabelLookup[1] = "plant";
         _popupFrameLabelLookup[2] = "animal";
         _popupFrameLabelLookup[3] = "tiki";
         _popupFrameLabelLookup[4] = "gecko";
         _popupFrameLabelLookup[5] = "bat";
         _popupFrameLabelLookup[6] = "cat";
         _popupFrameLabelLookup[7] = "insect";
         _popupFrameLabelLookup[8] = "weather";
         _popupFrameLabelLookup[9] = "holiday";
         _popupFrameLabelLookup[10] = "journeybook";
         _popupFrameLabelLookup[11] = "aquarium";
         _popupFrameLabelLookup[12] = "endangered";
         _popupFrameLabelLookup[14] = "journeybookBig";
         _popupFrameLabelLookup[15] = "bradyBarr";
         _popupFrameLabelLookup[16] = "10Million";
         _popupFrameLabelLookup[17] = "earthDay";
         _popupFrameLabelLookup[18] = "migration";
         _tabMediaHelper = new MediaHelper();
         _tabMediaHelper.init(NGFACTS_MEDIA_ID_TAB,mediaHelperHandler,true);
      }
      
      private static function mediaHelperHandler(mc:MovieClip) : void
      {
         var fid:int = int(mc.mediaHelper.id);
         if(fid == NGFACTS_MEDIA_ID_TAB)
         {
            _tabTemplate = MovieClip(mc.getChildAt(0));
            _tabMediaHelper.destroy();
            _tabMediaHelper = null;
            _roomMgr.onNormalFactPopupsReady();
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            if(fid == MUSEUM_MEDIA_ID_POPUP)
            {
               _hasMuseumPopupBeenLoaded = true;
               _museumPopupTemplate = MovieClip(mc.getChildAt(0));
            }
            else
            {
               _hasPopupBeenLoaded = true;
               _popupTemplate = MovieClip(mc.getChildAt(0));
            }
            if(mc.passback.tab != null)
            {
               mc.passback.displayFunction(mc.passback.factInfo,true,mc.passback.tab);
            }
            else
            {
               mc.passback.displayFunction(mc.passback.factInfo);
            }
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
         }
      }
      
      private static function JBSoundMediaHelperHandler(img:MovieClip) : void
      {
         var currLoaderAppDomain:ApplicationDomain = null;
         if(Boolean(img))
         {
            if(!AJAudio.hasLoadedJourneyBookWorldSfx)
            {
               currLoaderAppDomain = img.loaderInfo.applicationDomain;
               AJAudio.loadSfx("JBPrizeEarned",currLoaderAppDomain.getDefinition("JBPrizeEarned") as Class,1);
               AJAudio.loadSfx("JBWorldFactClose",currLoaderAppDomain.getDefinition("JBWorldFactClose") as Class,0.6);
               AJAudio.loadSfx("JBWorldFactOpen",currLoaderAppDomain.getDefinition("JBWorldFactOpen") as Class,0.6);
               AJAudio.hasLoadedJourneyBookWorldSfx = true;
            }
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":img.passback.displayFunction,
               "factInfo":img.passback.factInfo
            });
         }
      }
      
      public static function destroy() : void
      {
         _factMediaRequests = null;
         _tabMediaHelper = null;
         _popupMediaHelper = null;
         _tabTemplate = null;
         _popupTemplate = null;
      }
      
      public static function requestFactInfo(factIds:Array, factLocs:Array = null) : void
      {
         var def:Object = null;
         var fdh:NGFactDefHelper = null;
         _factLocs = factLocs;
         for(var i:int = 0; i < factIds.length; i++)
         {
            def = _factDefCache[factIds[i]];
            if(!def)
            {
               fdh = new NGFactDefHelper();
               fdh.init(factIds[i],onFactDefReceived);
               _factDefHelpers[factIds[i]] = fdh;
            }
            else if(def.type == TYPE_MIGRATION || def.type == TYPE_ENDANGERED || def.type == TYPE_EARTHDAY)
            {
               displayNormalNonTabFact(def);
            }
            else
            {
               setupNormalFact(def);
            }
         }
      }
      
      public static function onFactDefReceived(fdh:NGFactDefHelper) : void
      {
         var o:Object = fdh.def;
         var def:Object = {
            "id":int(o.id),
            "media":int(o.mediaRef),
            "userVarId":int(o.userVarRef),
            "bitIdx":int(o.bitIndex),
            "type":int(o.type),
            "description":int(o.descStrRef),
            "title":int(o.titleStrRef)
         };
         _factDefCache[def.id] = def;
         _factDefHelpers[def.id] = null;
         if(o.type == TYPE_JOURNEY_BOOK || o.type == TYPE_JOURNEY_BOOK_BIG)
         {
            if(Boolean(o.passback))
            {
               o.passback.c(def,o.passback.pg);
            }
            else
            {
               displayJourneyBookFact(def);
            }
         }
         else if(o.type == TYPE_AQUARIUM)
         {
            displayTierneyBookFact(def);
         }
         else if(o.type == TYPE_BRADY)
         {
            displayBradyFactPopup(def);
         }
         else if(o.type == TYPE_MUSEUM)
         {
            displayMuseumEngangermentPopup(def);
         }
         else if(o.type == TYPE_MIGRATION || o.type == TYPE_ENDANGERED || o.type == TYPE_EARTHDAY)
         {
            displayNormalNonTabFact(def);
         }
         else
         {
            setupNormalFact(def);
         }
      }
      
      public static function updateFactDefCache(def:Object) : void
      {
         _factDefCache[def.id] = def;
      }
      
      public static function requestJourneyBookFactDef(factId:int, callback:Function = null, pageNum:int = 0) : void
      {
         var fdh:NGFactDefHelper = null;
         if(callback == null)
         {
            DarkenManager.showLoadingSpiral(true);
         }
         var def:Object = _factDefCache[factId];
         if(!def)
         {
            fdh = new NGFactDefHelper();
            fdh.init(factId,onFactDefReceived,{
               "c":callback,
               "pg":pageNum
            });
            _factDefHelpers[factId] = fdh;
         }
         else if(callback != null)
         {
            callback(def,pageNum);
         }
         else
         {
            displayJourneyBookFact(def);
         }
      }
      
      public static function requestMuseumFactInfo(factListId:Array) : void
      {
         var def:Object = null;
         DarkenManager.showLoadingSpiral(true);
         if(!_museumFactDefList || _museumFactDefList[factListId[2]] == null)
         {
            _museumRequest = factListId[2];
            GenericListXtCommManager.requestGenericList(factListId[1],onMuseumFactListLoaded);
         }
         else
         {
            def = _museumFactDefList[factListId[2]];
            displayMuseumEngangermentPopup(def);
         }
      }
      
      public static function showBradyFact(factId:int) : void
      {
         var fdh:NGFactDefHelper = null;
         DarkenManager.showLoadingSpiral(true);
         var def:Object = _factDefCache[factId];
         if(!def)
         {
            fdh = new NGFactDefHelper();
            fdh.init(factId,onFactDefReceived,true);
            _factDefHelpers[factId] = fdh;
         }
         else
         {
            displayBradyFactPopup(def);
         }
      }
      
      public static function showTierneyFact(factId:int) : void
      {
         var fdh:NGFactDefHelper = null;
         DarkenManager.showLoadingSpiral(true);
         var def:Object = _factDefCache[factId];
         if(!def)
         {
            fdh = new NGFactDefHelper();
            fdh.init(factId,onFactDefReceived,true);
            _factDefHelpers[factId] = fdh;
         }
         else
         {
            displayTierneyBookFact(def);
         }
      }
      
      public static function showJourneyBookFact(factId:int) : void
      {
         requestJourneyBookFactDef(factId);
      }
      
      private static function displayJourneyBookFact(factInfo:Object) : void
      {
         var factSeen:Boolean = false;
         if(!_hasPopupBeenLoaded || !AJAudio.hasLoadedJourneyBookWorldSfx)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(JB_WORLDSOUNDS_MEDIA_ID,JBSoundMediaHelperHandler,{
               "displayFunction":displayJourneyBookFact,
               "factInfo":factInfo
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         if(factInfo == null || !factInfo.hasOwnProperty("id") || !factInfo.hasOwnProperty("type") || !factInfo.hasOwnProperty("media") || !factInfo.hasOwnProperty("title") || !factInfo.hasOwnProperty("description"))
         {
            throw new Error("invalid journey book info!");
         }
         var fit:int = int(factInfo.type);
         var popup:MovieClip = new _popupTemplate.constructor();
         _guiLayer.addChild(popup);
         popup.gotoAndStop(_popupFrameLabelLookup[fit]);
         if(fit == TYPE_JOURNEY_BOOK_BIG)
         {
            popup = popup.jbBig_anim.jb_content;
         }
         else
         {
            popup = popup.jb_anim.jb_content;
         }
         if(popup == null || !popup.hasOwnProperty("addToBtn") || !popup.hasOwnProperty("descTxt") || !popup.hasOwnProperty("imgBlock") || !popup.hasOwnProperty("titleTxt") || !popup.hasOwnProperty("bx"))
         {
            throw new Error("invalid journey book popup asset!");
         }
         factSeen = Boolean(gMainFrame.userInfo.userVarCache.isBitSet(factInfo.userVarId,factInfo.bitIdx));
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + factInfo.title + "/id_" + factInfo.id,-1,SBTracker.TYPE_EVENT);
         popup.titleTxt.gridFitType = GridFitType.SUBPIXEL;
         popup.descTxt.gridFitType = GridFitType.SUBPIXEL;
         popup.descTxt.text = "";
         popup.titleTxt.text = "";
         if(!factSeen)
         {
            AchievementXtCommManager.requestSetUserVar(factInfo.userVarId,factInfo.bitIdx,onJBVarSet);
            popup["bx"].visible = false;
            popup.hasSetVar = false;
            popup.addToBtn.addEventListener(MouseEvent.MOUSE_DOWN,addToJourneyBookDownHandler,false,0,true);
         }
         else
         {
            popup.addToBtn.visible = false;
            popup.hasSetVar = true;
            popup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         }
         popup.parent.parent.x = MainFrame.VIEW_WIDTH * 0.5;
         popup.parent.parent.y = MainFrame.VIEW_HEIGHT * 0.5;
         MovieClip(popup.parent).gotoAndPlay("on");
         LocalizationManager.translateId(popup.titleTxt,factInfo.title);
         LocalizationManager.translateId(popup.descTxt,factInfo.description);
         var fmmh:MediaHelper = new MediaHelper();
         var fim:uint = uint(factInfo.media);
         fmmh.init(fim,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":fim,
            "pop":popup,
            "mediaHelper":fmmh
         });
         _factMediaLoadingSpiral.setNewParent(popup.imgBlock);
         popup.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         if(factSeen)
         {
            AJAudio.playJBBookFactOpen();
         }
         else
         {
            AJAudio.playJBWorldFactOpen();
         }
         _factPopup = MovieClip(popup.parent);
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      public static function displayTierneyBookFact(factInfo:Object) : void
      {
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":displayTierneyBookFact,
               "factInfo":factInfo
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var popup:MovieClip = new _popupTemplate.constructor();
         if(popup == null || !popup.hasOwnProperty("descTxt") || !popup.hasOwnProperty("imgBlock") || !popup.hasOwnProperty("titleTxt") || !popup.hasOwnProperty("bx"))
         {
            throw new Error("invalid NGFact popup asset!");
         }
         _guiLayer.addChild(popup);
         popup.gotoAndStop(_popupFrameLabelLookup[factInfo.type]);
         popup.addToBookBtn.visible = false;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + popup.titleTxt.text + "/id_" + factInfo.id,-1,SBTracker.TYPE_EVENT);
         popup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         popup.x = MainFrame.VIEW_WIDTH * 0.5;
         popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         popup.descTxt.text = "";
         popup.titleTxt.text = "";
         LocalizationManager.translateId(popup.titleTxt,factInfo.title);
         LocalizationManager.translateId(popup.descTxt,factInfo.description);
         var fmmh:MediaHelper = new MediaHelper();
         var fim:uint = uint(factInfo.media);
         fmmh.init(fim,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":fim,
            "pop":popup,
            "mediaHelper":fmmh
         });
         _factMediaLoadingSpiral.setNewParent(popup.imgBlock);
         popup.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         _factPopup = popup;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      public static function displayMuseumEngangermentPopup(factInfo:Object) : void
      {
         var splitTxt:Array = null;
         _roomMgr.forceStopMovement();
         if(!_hasMuseumPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(MUSEUM_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":displayMuseumEngangermentPopup,
               "factInfo":factInfo
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var popup:MovieClip = new _museumPopupTemplate.constructor();
         if(popup == null || !popup.hasOwnProperty("bioTxt") || !popup.hasOwnProperty("descTxt") || !popup.hasOwnProperty("imgBlock") || !popup.hasOwnProperty("titleTxt") || !popup.hasOwnProperty("bx"))
         {
            throw new Error("invalid Museum popup asset!");
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + popup.titleTxt.text + "/id_" + factInfo.id,-1,SBTracker.TYPE_EVENT);
         _guiLayer.addChild(popup);
         popup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         popup.x = MainFrame.VIEW_WIDTH * 0.5;
         popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         popup.index = factInfo.index;
         popup.bitIdx = factInfo.bitIdx;
         popup.titleTxt.text = "";
         if(popup["bioTxt"] != null)
         {
            popup.bioTxt.text = "";
            splitTxt = LocalizationManager.translateIdOnly(factInfo.title).split("|");
            if(splitTxt[2] != null)
            {
               popup.gotoAndStop(splitTxt[2]);
            }
            if(splitTxt[1] != null)
            {
               LocalizationManager.updateToFit(popup.bioTxt,splitTxt[1]);
            }
            LocalizationManager.updateToFit(popup.titleTxt,splitTxt[0]);
         }
         else
         {
            LocalizationManager.translateId(popup.titleTxt,factInfo.title);
         }
         if(popup["descTxt"] != null)
         {
            LocalizationManager.translateId(popup.descTxt,factInfo.description);
         }
         var fmmh:MediaHelper = new MediaHelper();
         var fim:uint = uint(factInfo.media);
         fmmh.init(fim,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":fim,
            "pop":popup,
            "mediaHelper":fmmh
         });
         _factMediaLoadingSpiral.setNewParent(popup.imgBlock);
         popup.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         popup.leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftBtn,false,0,true);
         popup.rightBtn.addEventListener(MouseEvent.MOUSE_DOWN,onRightBtn,false,0,true);
         if(Boolean(popup.videosBtn))
         {
            popup.videosBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPlayMovieDown,false,0,true);
         }
         _factPopup = popup;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      private static function displayBradyFactPopup(factInfo:Object) : void
      {
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":displayBradyFactPopup,
               "factInfo":factInfo
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var popup:MovieClip = new _popupTemplate.constructor();
         if(popup == null || !popup.hasOwnProperty("descTxt") || !popup.hasOwnProperty("imgBlock") || !popup.hasOwnProperty("titleTxt") || !popup.hasOwnProperty("bx"))
         {
            throw new Error("invalid NGFact popup asset!");
         }
         _guiLayer.addChild(popup);
         popup.gotoAndStop(_popupFrameLabelLookup[factInfo.type]);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + popup.titleTxt.text + "/id_" + factInfo.id,-1,SBTracker.TYPE_EVENT);
         popup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         popup.x = MainFrame.VIEW_WIDTH * 0.5;
         popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         popup.index = factInfo.index;
         popup.bitIdx = factInfo.bitIdx;
         LocalizationManager.translateId(popup.titleTxt,factInfo.title);
         LocalizationManager.translateId(popup.bradyCont.descTxt,factInfo.description);
         var fmmh:MediaHelper = new MediaHelper();
         var fim:uint = uint(factInfo.media);
         fmmh.init(fim,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":fim,
            "pop":popup.bradyCont,
            "mediaHelper":fmmh
         });
         _factMediaLoadingSpiral.setNewParent(popup.bradyCont.imgBlock);
         popup.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         _factPopup = popup;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      private static function onPlayMovieDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestStreamList(_factPopup.bitIdx,onVideoGLReceived);
      }
      
      private static function onVideoGLReceived(glId:int, streamIds:Array, thumbIds:Array, baseTitles:Array, indivTitles:Array, statusIds:Array, baseSubtitles:Array) : void
      {
         GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,streamIds,baseTitles,baseSubtitles,false);
      }
      
      private static function reloadMuseumPopup(factInfo:Object) : void
      {
         var text:String = null;
         var splitTxt:Array = null;
         _factPopup.index = factInfo.index;
         _factPopup.bitIdx = factInfo.bitIdx;
         while(_factPopup.imgBlock.numChildren > 0)
         {
            _factPopup.imgBlock.removeChildAt(0);
         }
         if(_factPopup.hasOwnProperty("bioTxt"))
         {
            text = LocalizationManager.translateIdOnly(factInfo.title);
            splitTxt = text.split("|");
            if(splitTxt[1] != null)
            {
               LocalizationManager.updateToFit(_factPopup.bioTxt,splitTxt[1]);
            }
            LocalizationManager.updateToFit(_factPopup.titleTxt,splitTxt[0]);
         }
         else
         {
            LocalizationManager.translateId(_factPopup.titleTxt,factInfo.title);
         }
         if(Boolean(_factPopup.descTxt))
         {
            LocalizationManager.translateId(_factPopup.descTxt,factInfo.description);
         }
         _factMediaLoadingSpiral.setNewParent(_factPopup.imgBlock);
         var fmmh:MediaHelper = new MediaHelper();
         var fim:uint = uint(factInfo.media);
         fmmh.init(fim,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":fim,
            "pop":_factPopup,
            "mediaHelper":fmmh
         });
      }
      
      public static function setupNormalFact(factInfo:Object, autoDisplay:Boolean = false, currTab:MovieClip = null) : void
      {
         var popup:MovieClip = null;
         var defId:int = 0;
         if(factInfo == null || !factInfo.hasOwnProperty("id") || !factInfo.hasOwnProperty("type") || !factInfo.hasOwnProperty("media") || !factInfo.hasOwnProperty("title") || !factInfo.hasOwnProperty("description"))
         {
            throw new Error("invalid NGFact tabInfo!");
         }
         var tab:MovieClip = null;
         var fid:int = int(factInfo.id);
         var fit:int = int(factInfo.type);
         if(fit < TYPE_MINERAL || fit > TYPE_ENDANGERED && fit < TYPE_MIGRATION)
         {
            throw new Error("invalid NGFact type:" + fit + "?!");
         }
         if(currTab != null)
         {
            tab = currTab;
         }
         else
         {
            tab = new _tabTemplate.constructor();
         }
         var factSeen:Boolean = factInfo.userVarId == 0 ? true : Boolean(gMainFrame.userInfo.userVarCache.isBitSet(factInfo.userVarId,factInfo.bitIdx));
         if(Boolean(tab))
         {
            _worldLayer.addChild(tab);
            if(fit != TYPE_MILLIONS || fit != TYPE_EARTHDAY)
            {
               if(factSeen)
               {
                  tab.gotoAndStop(_tabFrameLabelLookup[fit] + "Dim");
               }
               else
               {
                  tab.gotoAndStop(_tabFrameLabelLookup[fit]);
               }
            }
            else
            {
               autoDisplay = true;
            }
            defId = int(tab.id = int(factInfo.id));
            if(Boolean(_factLocs))
            {
               tab.x = _factLocs[defId].x;
               tab.y = _factLocs[defId].y;
            }
            tab.title = factInfo.title;
            tab.description = factInfo.description;
            tab.media = factInfo.media;
            tab.popup = popup;
            tab.factSeen = factSeen;
            tab.factInfo = factInfo;
            tab.type = fit;
            if(!factSeen)
            {
               tab.userVarId = factInfo.userVarId;
               tab.bitIdx = factInfo.bitIdx;
            }
            tab.addEventListener(MouseEvent.MOUSE_DOWN,tabMouseDownHandler,false,0,true);
         }
         if(autoDisplay)
         {
            tab.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
         }
      }
      
      public static function displayNormalNonTabFact(factInfo:Object) : void
      {
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":displayNormalNonTabFact,
               "factInfo":factInfo
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var popup:MovieClip = new _popupTemplate.constructor();
         if(factInfo == null || !factInfo.hasOwnProperty("id") || !factInfo.hasOwnProperty("type") || !factInfo.hasOwnProperty("media") || !factInfo.hasOwnProperty("title") || !factInfo.hasOwnProperty("description"))
         {
            throw new Error("invalid NGFact tabInfo!");
         }
         _guiLayer.addChild(popup);
         popup.gotoAndStop(_popupFrameLabelLookup[factInfo.type]);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + popup.titleTxt.text + "/id_" + factInfo.id,-1,SBTracker.TYPE_EVENT);
         popup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         popup.x = MainFrame.VIEW_WIDTH * 0.5;
         popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         popup.index = factInfo.index;
         popup.bitIdx = factInfo.bitIdx;
         LocalizationManager.translateId(popup.titleTxt,factInfo.title);
         LocalizationManager.translateId(popup.descTxt,factInfo.description);
         var fmmh:MediaHelper = new MediaHelper();
         var fim:uint = uint(factInfo.media);
         fmmh.init(fim,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":fim,
            "pop":popup,
            "mediaHelper":fmmh
         });
         _factMediaLoadingSpiral.setNewParent(popup.imgBlock);
         popup.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         _factPopup = popup;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      private static function onMuseumFactListLoaded(mediaIds:Array) : void
      {
         var o:Object = null;
         var def:Object = null;
         _museumFactDefList = [];
         _museumFactDefIndexList = [];
         for(var i:int = 0; i < mediaIds.length; i++)
         {
            o = mediaIds[i];
            def = {
               "id":int(o.id),
               "media":int(o.media),
               "userVarId":int(o.userVarId),
               "bitIdx":int(o.bitIdx),
               "type":int(o.type),
               "description":int(o.description),
               "title":int(o.title),
               "index":i
            };
            _museumFactDefList[def.id] = def;
            _museumFactDefIndexList[i] = def.id;
         }
         displayMuseumEngangermentPopup(_museumFactDefList[_museumRequest]);
      }
      
      private static function factPopupMediaCallback(mhmc:MovieClip) : void
      {
         var fmr:Object = null;
         var desc:String = null;
         var fmp:Object = null;
         var fmId:int = int(mhmc.mediaHelper.id);
         var fmsl:Array = [];
         for each(fmr in _factMediaRequests)
         {
            if(fmr.id == fmId)
            {
               mhmc.x = -mhmc.width * 0.5;
               mhmc.y = -mhmc.height * 0.5;
               fmr.pop.imgBlock.addChild(mhmc);
               if(_factPopup.currentFrame == 17)
               {
                  desc = _factPopup.bradyCont.descTxt.text;
                  if(mhmc.width > mhmc.height)
                  {
                     _factPopup.bradyCont.gotoAndStop("hor");
                  }
                  else
                  {
                     _factPopup.bradyCont.gotoAndStop("ver");
                  }
                  _factPopup.bradyCont.descTxt.text = desc;
               }
               if(Boolean(fmr.pop.imgBlock.contains(_factMediaLoadingSpiral)))
               {
                  fmr.pop.imgBlock.removeChild(_factMediaLoadingSpiral);
               }
               fmsl.push(fmr);
               break;
            }
         }
         while(fmsl.length > 0)
         {
            fmp = fmsl.pop();
            _factMediaRequests.splice(_factMediaRequests.indexOf(fmp),1);
         }
         mhmc.mediaHelper.destroy();
         delete mhmc.mediaHelper;
      }
      
      private static function tabMouseDownHandler(m:MouseEvent) : void
      {
         var fmmh:MediaHelper = null;
         var fim:uint = 0;
         m.stopPropagation();
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":setupNormalFact,
               "factInfo":m.currentTarget.factInfo,
               "tab":m.currentTarget
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var popup:MovieClip = m.currentTarget.popup;
         var tab:MovieClip = MovieClip(m.currentTarget);
         if(m.currentTarget.popup == null)
         {
            popup = new _popupTemplate.constructor();
            if(popup == null || !popup.hasOwnProperty("descTxt") || !popup.hasOwnProperty("imgBlock") || !popup.hasOwnProperty("titleTxt") || !popup.hasOwnProperty("bx"))
            {
               throw new Error("invalid NGFact popup asset!");
            }
            tab.popup = popup;
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + popup.titleTxt.text + "/id_" + m.currentTarget.id,-1,SBTracker.TYPE_EVENT);
         if(Boolean(tab.popup.parent))
         {
            tab.popup.parent.addChild(tab.popup);
         }
         else
         {
            _guiLayer.addChild(popup);
            popup.gotoAndStop(_popupFrameLabelLookup[m.currentTarget.type]);
            popup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
            popup.x = MainFrame.VIEW_WIDTH * 0.5;
            popup.y = MainFrame.VIEW_HEIGHT * 0.5;
            if(popup.hasOwnProperty("addToBookBtn") && Boolean(popup.addToBookBtn))
            {
               popup.addToBookBtn.visible = false;
            }
            if(popup.hasOwnProperty("donateBtn") && Boolean(popup.donateBtn))
            {
               popup.donateBtn.visible = false;
            }
            LocalizationManager.translateId(popup.titleTxt,tab.title);
            LocalizationManager.translateId(popup.descTxt,tab.description);
            fmmh = new MediaHelper();
            fim = uint(tab.media);
            fmmh.init(fim,factPopupMediaCallback,true);
            _factMediaRequests.push({
               "id":fim,
               "pop":popup,
               "mediaHelper":fmmh
            });
            popup.visible = false;
            _factMediaLoadingSpiral.setNewParent(popup.imgBlock);
            popup.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         }
         _factPopup = m.currentTarget.popup;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
         m.currentTarget.popup.visible = true;
         if(!tab.factSeen)
         {
            AchievementXtCommManager.requestSetUserVar(tab.userVarId,tab.bitIdx);
            AchievementXtCommManager.requestSetUserVar(uvForType(tab.type),1);
            tab.factSeen = true;
            tab.gotoAndStop(_tabFrameLabelLookup[tab.type] + "Dim");
         }
      }
      
      private static function uvForType(type:int) : int
      {
         switch(type)
         {
            case TYPE_MINERAL:
               return UV_VIEWED_MINERAL;
            case TYPE_PLANT:
               return UV_VIEWED_PLANT;
            case TYPE_ANIMAL:
               return UV_VIEWED_ANIMAL;
            case TYPE_TIKI:
               return UV_VIEWED_TIKI;
            case TYPE_GECKO:
               return UV_VIEWED_GECKO;
            case TYPE_BAT:
               return UV_VIEWED_BAT;
            case TYPE_CAT:
               return UV_VIEWED_CAT;
            case TYPE_INSECT:
               return UV_VIEWED_INSECT;
            case TYPE_WEATHER:
               return UV_VIEWED_WEATHER;
            case TYPE_HOLIDAY:
               return UV_VIEWED_HOLIDAY;
            default:
               return -1;
         }
      }
      
      private static function factMouseDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
      }
      
      private static function onLeftBtn(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(Boolean(_factPopup))
         {
            if(m.currentTarget.parent.index - 1 < 0)
            {
               reloadMuseumPopup(_museumFactDefList[_museumFactDefIndexList[_museumFactDefIndexList.length - 1]]);
            }
            else
            {
               reloadMuseumPopup(_museumFactDefList[_museumFactDefIndexList[m.currentTarget.parent.index - 1]]);
            }
         }
      }
      
      private static function onRightBtn(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(Boolean(_factPopup))
         {
            if(m.currentTarget.parent.index + 1 >= _museumFactDefIndexList.length)
            {
               reloadMuseumPopup(_museumFactDefList[_museumFactDefIndexList[0]]);
            }
            else
            {
               reloadMuseumPopup(_museumFactDefList[_museumFactDefIndexList[m.currentTarget.parent.index + 1]]);
            }
         }
      }
      
      private static function donateDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         trace("clicked the button to donate");
      }
      
      private static function onJBVarSet(varId:int, value:int) : void
      {
         if(Boolean(_factPopup))
         {
            _factPopup.jb_content.hasSetVar = true;
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            if(RoomManagerWorld.instance.getNumJBItemsLeftInWorld() <= 0)
            {
               AJAudio.playJBPrizeEarned();
               GuiManager.openJourneyBook();
            }
         }
      }
      
      private static function addToJourneyBookDownHandler(m:MouseEvent) : void
      {
         if(_factPopup.hasOwnProperty("addToBook"))
         {
            AJAudio.playJBWorldFactClose();
            _factPopup.addToBook(onAddToJBBookAnim);
            return;
         }
         if(RoomManagerWorld.instance.getNumJBItemsLeftInWorld() <= 0)
         {
            AJAudio.playJBPrizeEarned();
            GuiManager.openJourneyBook();
         }
         factCloseHandler(m);
      }
      
      private static function onAddToJBBookAnim() : void
      {
         if(Boolean(_factPopup.jb_content.hasSetVar))
         {
            if(RoomManagerWorld.instance.getNumJBItemsLeftInWorld() <= 0)
            {
               ++JBManager.numUnclaimedGifts;
               GuiManager.updateJBIcon();
               AJAudio.playJBPrizeEarned();
               GuiManager.openJourneyBook();
            }
            else
            {
               GuiManager.showJBGlow(true);
            }
         }
         factCloseHandler(null);
      }
      
      private static function factCloseHandler(m:MouseEvent) : void
      {
         if(Boolean(m))
         {
            m.stopPropagation();
         }
         if(Boolean(_factPopup))
         {
            if(_factPopup.hasOwnProperty("closePopup") && Boolean(m))
            {
               AJAudio.playJBWorldFactClose();
               _factPopup.closePopup(onJBPopupHideAnim);
               return;
            }
            SBTracker.pop();
            if(gMainFrame.server.isConnected)
            {
               KeepAlive.stopKATimer(_factPopup);
            }
            DarkenManager.unDarken(_factPopup);
            _factPopup.visible = false;
            if(_factPopup.hasOwnProperty("jb_content") && !_factPopup.jb_content.hasSetVar)
            {
               DarkenManager.showLoadingSpiral(true);
            }
            _factPopup = null;
            GuiManager.showPrizePopupIfAny();
         }
      }
      
      private static function onJBPopupHideAnim() : void
      {
         SBTracker.pop();
         KeepAlive.stopKATimer(_factPopup);
         DarkenManager.unDarken(_factPopup);
         _factPopup.visible = false;
         _factPopup = null;
      }
      
      public static function closeFact() : void
      {
         factCloseHandler(null);
      }
   }
}

