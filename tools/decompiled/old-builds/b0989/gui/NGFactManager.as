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
      
      public static function init(param1:DisplayLayer, param2:DisplayLayer) : void
      {
         _guiLayer = param1;
         _worldLayer = param2;
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
         _tabMediaHelper = new MediaHelper();
         _tabMediaHelper.init(NGFACTS_MEDIA_ID_TAB,mediaHelperHandler,true);
      }
      
      private static function mediaHelperHandler(param1:MovieClip) : void
      {
         var _loc2_:int = int(param1.mediaHelper.id);
         if(_loc2_ == NGFACTS_MEDIA_ID_TAB)
         {
            _tabTemplate = MovieClip(param1.getChildAt(0));
            _tabMediaHelper.destroy();
            _tabMediaHelper = null;
            _roomMgr.onNormalFactPopupsReady();
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            if(_loc2_ == MUSEUM_MEDIA_ID_POPUP)
            {
               _hasMuseumPopupBeenLoaded = true;
               _museumPopupTemplate = MovieClip(param1.getChildAt(0));
            }
            else
            {
               _hasPopupBeenLoaded = true;
               _popupTemplate = MovieClip(param1.getChildAt(0));
            }
            if(param1.passback.tab != null)
            {
               param1.passback.displayFunction(param1.passback.factInfo,true,param1.passback.tab);
            }
            else
            {
               param1.passback.displayFunction(param1.passback.factInfo);
            }
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
         }
      }
      
      private static function JBSoundMediaHelperHandler(param1:MovieClip) : void
      {
         var _loc2_:ApplicationDomain = null;
         if(param1)
         {
            if(!AJAudio.hasLoadedJourneyBookWorldSfx)
            {
               _loc2_ = param1.loaderInfo.applicationDomain;
               AJAudio.loadSfx("JBPrizeEarned",_loc2_.getDefinition("JBPrizeEarned") as Class,1);
               AJAudio.loadSfx("JBWorldFactClose",_loc2_.getDefinition("JBWorldFactClose") as Class,0.6);
               AJAudio.loadSfx("JBWorldFactOpen",_loc2_.getDefinition("JBWorldFactOpen") as Class,0.6);
               AJAudio.hasLoadedJourneyBookWorldSfx = true;
            }
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":param1.passback.displayFunction,
               "factInfo":param1.passback.factInfo
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
      
      public static function requestFactInfo(param1:Array, param2:Array = null) : void
      {
         var _loc4_:Object = null;
         var _loc5_:NGFactDefHelper = null;
         _factLocs = param2;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = _factDefCache[param1[_loc3_]];
            if(!_loc4_)
            {
               _loc5_ = new NGFactDefHelper();
               _loc5_.init(param1[_loc3_],onFactDefReceived);
               _factDefHelpers[param1[_loc3_]] = _loc5_;
            }
            else
            {
               setupNormalFact(_loc4_);
            }
            _loc3_++;
         }
      }
      
      public static function onFactDefReceived(param1:NGFactDefHelper) : void
      {
         var _loc2_:Object = param1.def;
         var _loc3_:Object = {
            "id":int(_loc2_.id),
            "media":int(_loc2_.mediaRef),
            "userVarId":int(_loc2_.userVarRef),
            "bitIdx":int(_loc2_.bitIndex),
            "type":int(_loc2_.type),
            "description":int(_loc2_.descStrRef),
            "title":int(_loc2_.titleStrRef)
         };
         _factDefCache[_loc3_.id] = _loc3_;
         _factDefHelpers[_loc3_.id] = null;
         if(_loc2_.type == TYPE_JOURNEY_BOOK || _loc2_.type == TYPE_JOURNEY_BOOK_BIG)
         {
            if(_loc2_.passback)
            {
               _loc2_.passback.c(_loc3_,_loc2_.passback.pg);
            }
            else
            {
               displayJourneyBookFact(_loc3_);
            }
         }
         else if(_loc2_.type == TYPE_AQUARIUM)
         {
            displayTierneyBookFact(_loc3_);
         }
         else if(_loc2_.type == TYPE_BRADY)
         {
            displayBradyFactPopup(_loc3_);
         }
         else if(_loc2_.type == TYPE_MUSEUM)
         {
            displayMuseumEngangermentPopup(_loc3_);
         }
         else
         {
            setupNormalFact(_loc3_);
         }
      }
      
      public static function updateFactDefCache(param1:Object) : void
      {
         _factDefCache[param1.id] = param1;
      }
      
      public static function requestJourneyBookFactDef(param1:int, param2:Function = null, param3:int = 0) : void
      {
         var _loc5_:NGFactDefHelper = null;
         if(param2 == null)
         {
            DarkenManager.showLoadingSpiral(true);
         }
         var _loc4_:Object = _factDefCache[param1];
         if(!_loc4_)
         {
            _loc5_ = new NGFactDefHelper();
            _loc5_.init(param1,onFactDefReceived,{
               "c":param2,
               "pg":param3
            });
            _factDefHelpers[param1] = _loc5_;
         }
         else if(param2 != null)
         {
            param2(_loc4_,param3);
         }
         else
         {
            displayJourneyBookFact(_loc4_);
         }
      }
      
      public static function requestMuseumFactInfo(param1:Array) : void
      {
         var _loc2_:Object = null;
         DarkenManager.showLoadingSpiral(true);
         if(!_museumFactDefList)
         {
            _museumRequest = param1[2];
            GenericListXtCommManager.requestGenericList(param1[1],onMuseumFactListLoaded);
         }
         else
         {
            _loc2_ = _museumFactDefList[param1[2]];
            displayMuseumEngangermentPopup(_loc2_);
         }
      }
      
      public static function showBradyFact(param1:int) : void
      {
         var _loc3_:NGFactDefHelper = null;
         DarkenManager.showLoadingSpiral(true);
         var _loc2_:Object = _factDefCache[param1];
         if(!_loc2_)
         {
            _loc3_ = new NGFactDefHelper();
            _loc3_.init(param1,onFactDefReceived,true);
            _factDefHelpers[param1] = _loc3_;
         }
         else
         {
            displayBradyFactPopup(_loc2_);
         }
      }
      
      public static function showTierneyFact(param1:int) : void
      {
         var _loc3_:NGFactDefHelper = null;
         DarkenManager.showLoadingSpiral(true);
         var _loc2_:Object = _factDefCache[param1];
         if(!_loc2_)
         {
            _loc3_ = new NGFactDefHelper();
            _loc3_.init(param1,onFactDefReceived,true);
            _factDefHelpers[param1] = _loc3_;
         }
         else
         {
            displayTierneyBookFact(_loc2_);
         }
      }
      
      public static function showJourneyBookFact(param1:int) : void
      {
         requestJourneyBookFactDef(param1);
      }
      
      private static function displayJourneyBookFact(param1:Object) : void
      {
         if(!_hasPopupBeenLoaded || !AJAudio.hasLoadedJourneyBookWorldSfx)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(JB_WORLDSOUNDS_MEDIA_ID,JBSoundMediaHelperHandler,{
               "displayFunction":displayJourneyBookFact,
               "factInfo":param1
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         if(param1 == null || !param1.hasOwnProperty("id") || !param1.hasOwnProperty("type") || !param1.hasOwnProperty("media") || !param1.hasOwnProperty("title") || !param1.hasOwnProperty("description"))
         {
            throw new Error("invalid journey book info!");
         }
         var _loc2_:int = int(param1.type);
         var _loc3_:MovieClip = new _popupTemplate.constructor();
         _loc3_.gotoAndStop(_popupFrameLabelLookup[_loc2_]);
         if(_loc2_ == TYPE_JOURNEY_BOOK_BIG)
         {
            _loc3_ = _loc3_.jbBig_anim.jb_content;
         }
         else
         {
            _loc3_ = _loc3_.jb_anim.jb_content;
         }
         if(_loc3_ == null || !_loc3_.hasOwnProperty("addToBtn") || !_loc3_.hasOwnProperty("descTxt") || !_loc3_.hasOwnProperty("imgBlock") || !_loc3_.hasOwnProperty("titleTxt") || !_loc3_.hasOwnProperty("bx"))
         {
            throw new Error("invalid journey book popup asset!");
         }
         var _loc4_:Boolean = Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,param1.bitIdx));
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + param1.title + "/id_" + param1.id);
         _loc3_.titleTxt.gridFitType = GridFitType.SUBPIXEL;
         _loc3_.descTxt.gridFitType = GridFitType.SUBPIXEL;
         _loc3_.descTxt.text = "";
         _loc3_.titleTxt.text = "";
         if(!_loc4_)
         {
            AchievementXtCommManager.requestSetUserVar(param1.userVarId,param1.bitIdx,onJBVarSet);
            _loc3_["bx"].visible = false;
            _loc3_.hasSetVar = false;
            _loc3_.addToBtn.addEventListener(MouseEvent.MOUSE_DOWN,addToJourneyBookDownHandler,false,0,true);
         }
         else
         {
            _loc3_.addToBtn.visible = false;
            _loc3_.hasSetVar = true;
            _loc3_["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         }
         _loc3_.parent.x = MainFrame.VIEW_WIDTH * 0.5;
         _loc3_.parent.y = MainFrame.VIEW_HEIGHT * 0.5;
         LocalizationXtCommManager.sendTranslateStringRequest(param1.title,LocalizationXtCommManager.LANG_ENG,factPopupTextTitleCallback,_loc3_);
         LocalizationXtCommManager.sendTranslateStringRequest(param1.description,LocalizationXtCommManager.LANG_ENG,factPopupTextDescriptionCallback,_loc3_);
         var _loc5_:MediaHelper = new MediaHelper();
         var _loc6_:uint = uint(param1.media);
         _loc5_.init(_loc6_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc6_,
            "pop":_loc3_,
            "mediaHelper":_loc5_
         });
         _factMediaLoadingSpiral.setNewParent(_loc3_.imgBlock);
         _loc3_.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         if(_loc4_)
         {
            AJAudio.playJBBookFactOpen();
         }
         else
         {
            AJAudio.playJBWorldFactOpen();
         }
         _guiLayer.addChild(_loc3_.parent);
         _factPopup = MovieClip(_loc3_.parent);
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      public static function displayTierneyBookFact(param1:Object) : void
      {
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":displayTierneyBookFact,
               "factInfo":param1
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:MovieClip = new _popupTemplate.constructor();
         if(_loc2_ == null || !_loc2_.hasOwnProperty("descTxt") || !_loc2_.hasOwnProperty("imgBlock") || !_loc2_.hasOwnProperty("titleTxt") || !_loc2_.hasOwnProperty("bx"))
         {
            throw new Error("invalid NGFact popup asset!");
         }
         _loc2_.gotoAndStop(_popupFrameLabelLookup[param1.type]);
         _loc2_.addToBookBtn.visible = false;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc2_.titleTxt.text + "/id_" + param1.id);
         _loc2_["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         _loc2_.x = MainFrame.VIEW_WIDTH * 0.5;
         _loc2_.y = MainFrame.VIEW_HEIGHT * 0.5;
         _loc2_.descTxt.text = "";
         _loc2_.titleTxt.text = "";
         LocalizationXtCommManager.sendTranslateStringRequest(param1.title,LocalizationXtCommManager.LANG_ENG,factPopupTextTitleCallback,_loc2_);
         LocalizationXtCommManager.sendTranslateStringRequest(param1.description,LocalizationXtCommManager.LANG_ENG,factPopupTextDescriptionCallback,_loc2_);
         var _loc3_:MediaHelper = new MediaHelper();
         var _loc4_:uint = uint(param1.media);
         _loc3_.init(_loc4_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc4_,
            "pop":_loc2_,
            "mediaHelper":_loc3_
         });
         _factMediaLoadingSpiral.setNewParent(_loc2_.imgBlock);
         _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         _guiLayer.addChild(_loc2_);
         _factPopup = _loc2_;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      public static function displayMuseumEngangermentPopup(param1:Object) : void
      {
         _roomMgr.forceStopMovement();
         if(!_hasMuseumPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(MUSEUM_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":displayMuseumEngangermentPopup,
               "factInfo":param1
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:MovieClip = new _museumPopupTemplate.constructor();
         if(_loc2_ == null || !_loc2_.hasOwnProperty("bioTxt") || !_loc2_.hasOwnProperty("descTxt") || !_loc2_.hasOwnProperty("imgBlock") || !_loc2_.hasOwnProperty("titleTxt") || !_loc2_.hasOwnProperty("bx"))
         {
            throw new Error("invalid Museum popup asset!");
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc2_.titleTxt.text + "/id_" + param1.id);
         _loc2_["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         _loc2_.x = MainFrame.VIEW_WIDTH * 0.5;
         _loc2_.y = MainFrame.VIEW_HEIGHT * 0.5;
         _loc2_.index = param1.index;
         _loc2_.bitIdx = param1.bitIdx;
         _loc2_.descTxt.text = "";
         _loc2_.titleTxt.text = "";
         _loc2_.bioTxt.text = "";
         LocalizationXtCommManager.sendTranslateStringRequest(param1.title,LocalizationXtCommManager.LANG_ENG,factPopupTextTitleCallback,_loc2_);
         LocalizationXtCommManager.sendTranslateStringRequest(param1.description,LocalizationXtCommManager.LANG_ENG,factPopupTextDescriptionCallback,_loc2_);
         var _loc3_:MediaHelper = new MediaHelper();
         var _loc4_:uint = uint(param1.media);
         _loc3_.init(_loc4_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc4_,
            "pop":_loc2_,
            "mediaHelper":_loc3_
         });
         _factMediaLoadingSpiral.setNewParent(_loc2_.imgBlock);
         _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         _loc2_.leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftBtn,false,0,true);
         _loc2_.rightBtn.addEventListener(MouseEvent.MOUSE_DOWN,onRightBtn,false,0,true);
         _loc2_.videosBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPlayMovieDown,false,0,true);
         _guiLayer.addChild(_loc2_);
         _factPopup = _loc2_;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      private static function displayBradyFactPopup(param1:Object) : void
      {
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":displayBradyFactPopup,
               "factInfo":param1
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:MovieClip = new _popupTemplate.constructor();
         if(_loc2_ == null || !_loc2_.hasOwnProperty("descTxt") || !_loc2_.hasOwnProperty("imgBlock") || !_loc2_.hasOwnProperty("titleTxt") || !_loc2_.hasOwnProperty("bx"))
         {
            throw new Error("invalid NGFact popup asset!");
         }
         _loc2_.gotoAndStop(_popupFrameLabelLookup[param1.type]);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc2_.titleTxt.text + "/id_" + param1.id);
         _loc2_["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
         _loc2_.x = MainFrame.VIEW_WIDTH * 0.5;
         _loc2_.y = MainFrame.VIEW_HEIGHT * 0.5;
         _loc2_.index = param1.index;
         _loc2_.bitIdx = param1.bitIdx;
         _loc2_.titleTxt.text = "";
         _loc2_.bradyCont.descTxt.text = "";
         LocalizationXtCommManager.sendTranslateStringRequest(param1.title,LocalizationXtCommManager.LANG_ENG,factPopupTextTitleCallback,_loc2_);
         LocalizationXtCommManager.sendTranslateStringRequest(param1.description,LocalizationXtCommManager.LANG_ENG,factPopupTextDescriptionCallback,_loc2_.bradyCont);
         var _loc3_:MediaHelper = new MediaHelper();
         var _loc4_:uint = uint(param1.media);
         _loc3_.init(_loc4_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc4_,
            "pop":_loc2_.bradyCont,
            "mediaHelper":_loc3_
         });
         _factMediaLoadingSpiral.setNewParent(_loc2_.bradyCont.imgBlock);
         _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
         _guiLayer.addChild(_loc2_);
         _factPopup = _loc2_;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      private static function onPlayMovieDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestStreamList(_factPopup.bitIdx,onVideoGLReceived);
      }
      
      private static function onVideoGLReceived(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array) : void
      {
         GuiManager.initMoviePlayer(MovieManager.VID_PLAYER_MEDIA_ID,param2,param4,false);
      }
      
      private static function reloadMuseumPopup(param1:Object) : void
      {
         _factPopup.index = param1.index;
         _factPopup.bitIdx = param1.bitIdx;
         while(_factPopup.imgBlock.numChildren > 0)
         {
            _factPopup.imgBlock.removeChildAt(0);
         }
         LocalizationXtCommManager.sendTranslateStringRequest(param1.title,LocalizationXtCommManager.LANG_ENG,factPopupTextTitleCallback,_factPopup);
         LocalizationXtCommManager.sendTranslateStringRequest(param1.description,LocalizationXtCommManager.LANG_ENG,factPopupTextDescriptionCallback,_factPopup);
         _factMediaLoadingSpiral.setNewParent(_factPopup.imgBlock);
         var _loc2_:MediaHelper = new MediaHelper();
         var _loc3_:uint = uint(param1.media);
         _loc2_.init(_loc3_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc3_,
            "pop":_factPopup,
            "mediaHelper":_loc2_
         });
      }
      
      public static function setupNormalFact(param1:Object, param2:Boolean = false, param3:MovieClip = null) : void
      {
         var _loc5_:MovieClip = null;
         var _loc9_:int = 0;
         if(param1 == null || !param1.hasOwnProperty("id") || !param1.hasOwnProperty("type") || !param1.hasOwnProperty("media") || !param1.hasOwnProperty("title") || !param1.hasOwnProperty("description"))
         {
            throw new Error("invalid NGFact tabInfo!");
         }
         var _loc4_:MovieClip = null;
         var _loc6_:int = int(param1.id);
         var _loc7_:int = int(param1.type);
         if(_loc7_ < TYPE_MINERAL || _loc7_ > TYPE_ENDANGERED && _loc7_ < TYPE_MILLIONS)
         {
            throw new Error("invalid NGFact type:" + _loc7_ + "?!");
         }
         if(param3 != null)
         {
            _loc4_ = param3;
         }
         else
         {
            _loc4_ = new _tabTemplate.constructor();
         }
         if(_hasPopupBeenLoaded)
         {
            _loc5_ = new _popupTemplate.constructor();
            if(_loc5_ == null || !_loc5_.hasOwnProperty("descTxt") || !_loc5_.hasOwnProperty("imgBlock") || !_loc5_.hasOwnProperty("titleTxt") || !_loc5_.hasOwnProperty("bx"))
            {
               throw new Error("invalid NGFact popup asset!");
            }
            _loc5_.gotoAndStop(_popupFrameLabelLookup[_loc7_]);
         }
         var _loc8_:Boolean = param1.userVarId == 0 ? true : Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,param1.bitIdx));
         if(_loc4_)
         {
            if(_loc7_ < TYPE_MILLIONS)
            {
               if(_loc8_)
               {
                  _loc4_.gotoAndStop(_tabFrameLabelLookup[_loc7_] + "Dim");
               }
               else
               {
                  _loc4_.gotoAndStop(_tabFrameLabelLookup[_loc7_]);
               }
            }
            else
            {
               param2 = true;
            }
            _loc9_ = int(_loc4_.id = int(param1.id));
            if(_factLocs)
            {
               _loc4_.x = _factLocs[_loc9_].x;
               _loc4_.y = _factLocs[_loc9_].y;
            }
            _loc4_.title = param1.title;
            _loc4_.description = param1.description;
            _loc4_.media = param1.media;
            _loc4_.popup = _loc5_;
            _loc4_.factSeen = _loc8_;
            _loc4_.factInfo = param1;
            _loc4_.type = _loc7_;
            if(!_loc8_)
            {
               _loc4_.userVarId = param1.userVarId;
               _loc4_.bitIdx = param1.bitIdx;
            }
            _loc4_.addEventListener(MouseEvent.MOUSE_DOWN,tabMouseDownHandler,false,0,true);
            _worldLayer.addChild(_loc4_);
         }
         if(param2)
         {
            _loc4_.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
         }
      }
      
      private static function onMuseumFactListLoaded(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         _museumFactDefList = [];
         _museumFactDefIndexList = [];
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = param1[_loc4_];
            _loc3_ = {
               "id":int(_loc2_.id),
               "media":int(_loc2_.media),
               "userVarId":int(_loc2_.userVarId),
               "bitIdx":int(_loc2_.bitIdx),
               "type":int(_loc2_.type),
               "description":int(_loc2_.description),
               "title":int(_loc2_.title),
               "index":_loc4_
            };
            _museumFactDefList[_loc3_.id] = _loc3_;
            _museumFactDefIndexList[_loc4_] = _loc3_.id;
            _loc4_++;
         }
         displayMuseumEngangermentPopup(_museumFactDefList[_museumRequest]);
      }
      
      private static function factPopupTextTitleCallback(param1:int, param2:String, param3:Object) : void
      {
         var _loc5_:Array = null;
         var _loc4_:MovieClip = MovieClip(param3);
         if(_loc4_.hasOwnProperty("bioTxt"))
         {
            _loc5_ = param2.split("|");
            if(_loc5_[1] != null)
            {
               _loc4_.bioTxt.text = _loc5_[1];
            }
            _loc4_.titleTxt.text = _loc5_[0];
         }
         else
         {
            _loc4_.titleTxt.text = param2;
         }
      }
      
      private static function factPopupTextDescriptionCallback(param1:int, param2:String, param3:Object) : void
      {
         var _loc4_:MovieClip = MovieClip(param3);
         _loc4_.descTxt.text = param2;
      }
      
      private static function factPopupMediaCallback(param1:MovieClip) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc2_:int = int(param1.mediaHelper.id);
         var _loc3_:Array = [];
         for each(_loc4_ in _factMediaRequests)
         {
            if(_loc4_.id == _loc2_)
            {
               param1.x = -param1.width * 0.5;
               param1.y = -param1.height * 0.5;
               if(_factPopup.currentFrame == 17)
               {
                  _loc5_ = _factPopup.bradyCont.descTxt.text;
                  if(param1.width > param1.height)
                  {
                     _factPopup.bradyCont.gotoAndStop("hor");
                  }
                  else
                  {
                     _factPopup.bradyCont.gotoAndStop("ver");
                  }
                  _factPopup.bradyCont.descTxt.text = _loc5_;
               }
               _loc4_.pop.imgBlock.addChild(param1);
               if(_loc4_.pop.imgBlock.contains(_factMediaLoadingSpiral))
               {
                  _loc4_.pop.imgBlock.removeChild(_factMediaLoadingSpiral);
               }
               _loc3_.push(_loc4_);
               break;
            }
         }
         while(_loc3_.length > 0)
         {
            _loc6_ = _loc3_.pop();
            _factMediaRequests.splice(_factMediaRequests.indexOf(_loc6_),1);
         }
         param1.mediaHelper.destroy();
         delete param1.mediaHelper;
      }
      
      private static function tabMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc4_:MediaHelper = null;
         var _loc5_:uint = 0;
         param1.stopPropagation();
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(NGFACTS_MEDIA_ID_POPUP,mediaHelperHandler,{
               "displayFunction":setupNormalFact,
               "factInfo":param1.currentTarget.factInfo,
               "tab":param1.currentTarget
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:MovieClip = param1.currentTarget.popup;
         var _loc3_:MovieClip = MovieClip(param1.currentTarget);
         if(param1.currentTarget.popup == null)
         {
            _loc2_ = new _popupTemplate.constructor();
            if(_loc2_ == null || !_loc2_.hasOwnProperty("descTxt") || !_loc2_.hasOwnProperty("imgBlock") || !_loc2_.hasOwnProperty("titleTxt") || !_loc2_.hasOwnProperty("bx"))
            {
               throw new Error("invalid NGFact popup asset!");
            }
            _loc2_.gotoAndStop(_popupFrameLabelLookup[param1.currentTarget.type]);
            _loc3_.popup = _loc2_;
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc2_.titleTxt.text + "/id_" + param1.currentTarget.id);
         if(_loc3_.popup.parent)
         {
            _loc3_.popup.parent.addChild(_loc3_.popup);
         }
         else
         {
            _loc2_["bx"].addEventListener(MouseEvent.MOUSE_DOWN,factCloseHandler,false,0,true);
            _loc2_.x = MainFrame.VIEW_WIDTH * 0.5;
            _loc2_.y = MainFrame.VIEW_HEIGHT * 0.5;
            _loc2_.descTxt.text = "";
            _loc2_.titleTxt.text = "";
            if(_loc2_.hasOwnProperty("addToBookBtn") && Boolean(_loc2_.addToBookBtn))
            {
               _loc2_.addToBookBtn.visible = false;
            }
            if(_loc2_.hasOwnProperty("donateBtn") && Boolean(_loc2_.donateBtn))
            {
               _loc2_.donateBtn.visible = false;
            }
            LocalizationXtCommManager.sendTranslateStringRequest(_loc3_.title,LocalizationXtCommManager.LANG_ENG,factPopupTextTitleCallback,_loc2_);
            LocalizationXtCommManager.sendTranslateStringRequest(_loc3_.description,LocalizationXtCommManager.LANG_ENG,factPopupTextDescriptionCallback,_loc2_);
            _loc4_ = new MediaHelper();
            _loc5_ = uint(_loc3_.media);
            _loc4_.init(_loc5_,factPopupMediaCallback,true);
            _factMediaRequests.push({
               "id":_loc5_,
               "pop":_loc2_,
               "mediaHelper":_loc4_
            });
            _loc2_.visible = false;
            _factMediaLoadingSpiral.setNewParent(_loc2_.imgBlock);
            _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,factMouseDownHandler,false,0,true);
            _guiLayer.addChild(_loc2_);
         }
         _factPopup = param1.currentTarget.popup;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
         param1.currentTarget.popup.visible = true;
         if(!_loc3_.factSeen)
         {
            AchievementXtCommManager.requestSetUserVar(_loc3_.userVarId,_loc3_.bitIdx);
            AchievementXtCommManager.requestSetUserVar(uvForType(_loc3_.type),1);
            _loc3_.factSeen = true;
            _loc3_.gotoAndStop(_tabFrameLabelLookup[_loc3_.type] + "Dim");
         }
      }
      
      private static function uvForType(param1:int) : int
      {
         switch(param1)
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
      
      private static function factMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onLeftBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_factPopup)
         {
            if(param1.currentTarget.parent.index - 1 < 0)
            {
               reloadMuseumPopup(_museumFactDefList[_museumFactDefIndexList[_museumFactDefIndexList.length - 1]]);
            }
            else
            {
               reloadMuseumPopup(_museumFactDefList[_museumFactDefIndexList[param1.currentTarget.parent.index - 1]]);
            }
         }
      }
      
      private static function onRightBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_factPopup)
         {
            if(param1.currentTarget.parent.index + 1 >= _museumFactDefIndexList.length)
            {
               reloadMuseumPopup(_museumFactDefList[_museumFactDefIndexList[0]]);
            }
            else
            {
               reloadMuseumPopup(_museumFactDefList[_museumFactDefIndexList[param1.currentTarget.parent.index + 1]]);
            }
         }
      }
      
      private static function donateDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onJBVarSet(param1:int, param2:int) : void
      {
         if(_factPopup)
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
      
      private static function addToJourneyBookDownHandler(param1:MouseEvent) : void
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
         factCloseHandler(param1);
      }
      
      private static function onAddToJBBookAnim() : void
      {
         if(_factPopup.jb_content.hasSetVar)
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
      
      private static function factCloseHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_factPopup)
         {
            if(_factPopup.hasOwnProperty("closePopup") && Boolean(param1))
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

