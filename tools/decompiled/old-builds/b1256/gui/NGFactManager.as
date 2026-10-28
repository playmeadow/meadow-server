package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.describeType;
   import loader.MediaHelper;
   import loader.NGFactDefHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import room.RoomManagerWorld;
   
   public class NGFactManager
   {
      
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
         _tabFrameLabelLookup[0] = "mineral";
         _tabFrameLabelLookup[1] = "plant";
         _tabFrameLabelLookup[2] = "animal";
         _tabFrameLabelLookup[3] = "animal";
         _tabFrameLabelLookup[4] = "animal";
         _tabFrameLabelLookup[5] = "animal";
         _tabFrameLabelLookup[6] = "animal";
         _tabFrameLabelLookup[7] = "insect";
         _tabFrameLabelLookup[8] = "weather";
         _tabFrameLabelLookup[9] = "holiday";
         _tabFrameLabelLookup[12] = "animal";
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
         _tabMediaHelper.init(153,mediaHelperHandler,true);
      }
      
      private static function mediaHelperHandler(param1:MovieClip) : void
      {
         var _loc2_:int = int(param1.mediaHelper.id);
         if(_loc2_ == 153)
         {
            _tabTemplate = MovieClip(param1.getChildAt(0));
            _tabMediaHelper.destroy();
            _tabMediaHelper = null;
            _roomMgr.onNormalFactPopupsReady();
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            if(_loc2_ == 1544)
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
            _popupMediaHelper.init(87,mediaHelperHandler,{
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
         var _loc5_:int = 0;
         var _loc4_:Object = null;
         var _loc3_:NGFactDefHelper = null;
         _factLocs = param2;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_ = _factDefCache[param1[_loc5_]];
            if(!_loc4_)
            {
               _loc3_ = new NGFactDefHelper();
               _loc3_.init(param1[_loc5_],onFactDefReceived);
               _factDefHelpers[param1[_loc5_]] = _loc3_;
            }
            else if(_loc4_.type == 18 || _loc4_.type == 12 || _loc4_.type == 17 || _loc4_.type == 9)
            {
               displayNormalNonTabFact(_loc4_);
            }
            else
            {
               setupNormalFact(_loc4_);
            }
            _loc5_++;
         }
      }
      
      public static function onFactDefReceived(param1:NGFactDefHelper) : void
      {
         var _loc3_:Object = param1.def;
         var _loc2_:Object = {
            "id":int(_loc3_.id),
            "media":int(_loc3_.mediaRef),
            "userVarId":int(_loc3_.userVarRef),
            "bitIdx":int(_loc3_.bitIndex),
            "type":int(_loc3_.type),
            "description":int(_loc3_.descStrRef),
            "title":int(_loc3_.titleStrRef)
         };
         _factDefCache[_loc2_.id] = _loc2_;
         _factDefHelpers[_loc2_.id] = null;
         if(_loc3_.type == 10 || _loc3_.type == 14)
         {
            if(_loc3_.passback)
            {
               _loc3_.passback.c(_loc2_,_loc3_.passback.pg);
            }
            else
            {
               displayJourneyBookFact(_loc2_);
            }
         }
         else if(_loc3_.type == 11)
         {
            displayTierneyBookFact(_loc2_);
         }
         else if(_loc3_.type == 15)
         {
            displayBradyFactPopup(_loc2_);
         }
         else if(_loc3_.type == 13)
         {
            displayMuseumEngangermentPopup(_loc2_);
         }
         else if(_loc3_.type == 18 || _loc3_.type == 12 || _loc3_.type == 17 || _loc3_.type == 9)
         {
            displayNormalNonTabFact(_loc2_);
         }
         else
         {
            setupNormalFact(_loc2_);
         }
      }
      
      public static function updateFactDefCache(param1:Object) : void
      {
         _factDefCache[param1.id] = param1;
      }
      
      public static function requestJourneyBookFactDef(param1:int, param2:Function = null, param3:int = 0) : void
      {
         var _loc4_:NGFactDefHelper = null;
         if(param2 == null)
         {
            DarkenManager.showLoadingSpiral(true);
         }
         var _loc5_:Object = _factDefCache[param1];
         if(!_loc5_)
         {
            _loc4_ = new NGFactDefHelper();
            _loc4_.init(param1,onFactDefReceived,{
               "c":param2,
               "pg":param3
            });
            _factDefHelpers[param1] = _loc4_;
         }
         else if(param2 != null)
         {
            param2(_loc5_,param3);
         }
         else
         {
            displayJourneyBookFact(_loc5_);
         }
      }
      
      public static function requestMuseumFactInfo(param1:Array) : void
      {
         var _loc2_:Object = null;
         DarkenManager.showLoadingSpiral(true);
         if(!_museumFactDefList || _museumFactDefList[param1[2]] == null)
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
         var _loc2_:NGFactDefHelper = null;
         DarkenManager.showLoadingSpiral(true);
         var _loc3_:Object = _factDefCache[param1];
         if(!_loc3_)
         {
            _loc2_ = new NGFactDefHelper();
            _loc2_.init(param1,onFactDefReceived,true);
            _factDefHelpers[param1] = _loc2_;
         }
         else
         {
            displayBradyFactPopup(_loc3_);
         }
      }
      
      public static function showTierneyFact(param1:int) : void
      {
         var _loc2_:NGFactDefHelper = null;
         DarkenManager.showLoadingSpiral(true);
         var _loc3_:Object = _factDefCache[param1];
         if(!_loc3_)
         {
            _loc2_ = new NGFactDefHelper();
            _loc2_.init(param1,onFactDefReceived,true);
            _factDefHelpers[param1] = _loc2_;
         }
         else
         {
            displayTierneyBookFact(_loc3_);
         }
      }
      
      public static function showJourneyBookFact(param1:int) : void
      {
         requestJourneyBookFactDef(param1);
      }
      
      private static function displayJourneyBookFact(param1:Object) : void
      {
         var _loc7_:TextField = null;
         if(!_hasPopupBeenLoaded || !AJAudio.hasLoadedJourneyBookWorldSfx)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(1331,JBSoundMediaHelperHandler,{
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
         var _loc4_:MovieClip = new _popupTemplate.constructor();
         _guiLayer.addChild(_loc4_);
         _loc4_.gotoAndStop(_popupFrameLabelLookup[_loc2_]);
         if(_loc2_ == 14)
         {
            _loc4_ = _loc4_.jbBig_anim.jb_content;
         }
         else
         {
            _loc4_ = _loc4_.jb_anim.jb_content;
         }
         if(_loc4_ == null || !_loc4_.hasOwnProperty("addToBtn") || !_loc4_.hasOwnProperty("imgBlock") || !_loc4_.hasOwnProperty("titleTxt") || !_loc4_.hasOwnProperty("bx"))
         {
            throw new Error("invalid journey book popup asset!");
         }
         var _loc5_:Boolean = Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,param1.bitIdx));
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + param1.title + "/id_" + param1.id,-1,1);
         _loc4_.titleTxt.gridFitType = "subpixel";
         _loc4_.titleTxt.text = "";
         if(_loc4_.hasOwnProperty("descTxtCont"))
         {
            _loc7_ = _loc4_.descTxtCont.descTxt;
         }
         else
         {
            _loc7_ = _loc4_.descTxt;
         }
         _loc7_.gridFitType = "subpixel";
         _loc7_.text = "";
         if(!_loc5_)
         {
            AchievementXtCommManager.requestSetUserVar(param1.userVarId,param1.bitIdx,onJBVarSet);
            _loc4_["bx"].visible = false;
            _loc4_.hasSetVar = false;
            _loc4_.addToBtn.addEventListener("mouseDown",addToJourneyBookDownHandler,false,0,true);
         }
         else
         {
            _loc4_.addToBtn.visible = false;
            _loc4_.hasSetVar = true;
            _loc4_["bx"].addEventListener("mouseDown",factCloseHandler,false,0,true);
         }
         _loc4_.parent.parent.x = 900 * 0.5;
         _loc4_.parent.parent.y = 550 * 0.5;
         MovieClip(_loc4_.parent).gotoAndPlay("on");
         LocalizationManager.translateId(_loc4_.titleTxt,param1.title);
         LocalizationManager.translateId(_loc7_,param1.description);
         var _loc3_:MediaHelper = new MediaHelper();
         var _loc6_:uint = uint(param1.media);
         _loc3_.init(_loc6_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc6_,
            "pop":_loc4_,
            "mediaHelper":_loc3_
         });
         _factMediaLoadingSpiral.setNewParent(_loc4_.imgBlock);
         _loc4_.addEventListener("mouseDown",factMouseDownHandler,false,0,true);
         if(_loc5_)
         {
            AJAudio.playJBBookFactOpen();
         }
         else
         {
            AJAudio.playJBWorldFactOpen();
         }
         _factPopup = MovieClip(_loc4_.parent);
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
            _popupMediaHelper.init(87,mediaHelperHandler,{
               "displayFunction":displayTierneyBookFact,
               "factInfo":param1
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc3_:MovieClip = new _popupTemplate.constructor();
         if(_loc3_ == null || !_loc3_.hasOwnProperty("imgBlock") || !_loc3_.hasOwnProperty("titleTxt") || !_loc3_.hasOwnProperty("bx"))
         {
            throw new Error("invalid NGFact popup asset!");
         }
         _guiLayer.addChild(_loc3_);
         _loc3_.gotoAndStop(_popupFrameLabelLookup[param1.type]);
         _loc3_.addToBookBtn.visible = false;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc3_.titleTxt.text + "/id_" + param1.id,-1,1);
         _loc3_["bx"].addEventListener("mouseDown",factCloseHandler,false,0,true);
         _loc3_.x = 900 * 0.5;
         _loc3_.y = 550 * 0.5;
         _loc3_.descTxt.text = "";
         _loc3_.titleTxt.text = "";
         LocalizationManager.translateId(_loc3_.titleTxt,param1.title);
         LocalizationManager.translateId(_loc3_.descTxt,param1.description);
         var _loc2_:MediaHelper = new MediaHelper();
         var _loc4_:uint = uint(param1.media);
         _loc2_.init(_loc4_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc4_,
            "pop":_loc3_,
            "mediaHelper":_loc2_
         });
         _factMediaLoadingSpiral.setNewParent(_loc3_.imgBlock);
         _loc3_.addEventListener("mouseDown",factMouseDownHandler,false,0,true);
         _factPopup = _loc3_;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      public static function displayMuseumEngangermentPopup(param1:Object) : void
      {
         var _loc5_:Array = null;
         var _loc6_:TextField = null;
         _roomMgr.forceStopMovement();
         if(!_hasMuseumPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(1544,mediaHelperHandler,{
               "displayFunction":displayMuseumEngangermentPopup,
               "factInfo":param1
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc3_:MovieClip = new _museumPopupTemplate.constructor();
         if(_loc3_ == null || !_loc3_.hasOwnProperty("bioTxt") || !_loc3_.hasOwnProperty("imgBlock") || !_loc3_.hasOwnProperty("titleTxt") || !_loc3_.hasOwnProperty("bx"))
         {
            throw new Error("invalid Museum popup asset!");
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc3_.titleTxt.text + "/id_" + param1.id,-1,1);
         _guiLayer.addChild(_loc3_);
         _loc3_["bx"].addEventListener("mouseDown",factCloseHandler,false,0,true);
         _loc3_.x = 900 * 0.5;
         _loc3_.y = 550 * 0.5;
         _loc3_.index = param1.index;
         _loc3_.bitIdx = param1.bitIdx;
         _loc3_.titleTxt.text = "";
         if(_loc3_["bioTxt"] != null)
         {
            _loc3_.bioTxt.text = "";
            _loc5_ = LocalizationManager.translateIdOnly(param1.title).split("|");
            if(_loc5_[2] != null)
            {
               _loc3_.gotoAndStop(_loc5_[2]);
            }
            if(_loc5_[1] != null)
            {
               LocalizationManager.updateToFit(_loc3_.bioTxt,_loc5_[1]);
            }
            LocalizationManager.updateToFit(_loc3_.titleTxt,_loc5_[0]);
         }
         else
         {
            LocalizationManager.translateId(_loc3_.titleTxt,param1.title);
         }
         if(_loc3_.hasOwnProperty("descTxtCont"))
         {
            _loc6_ = _loc3_.descTxtCont.descTxt;
         }
         else
         {
            _loc6_ = _loc3_.descTxt;
         }
         if(_loc6_ != null)
         {
            LocalizationManager.translateId(_loc6_,param1.description);
         }
         var _loc2_:MediaHelper = new MediaHelper();
         var _loc4_:uint = uint(param1.media);
         _loc2_.init(_loc4_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc4_,
            "pop":_loc3_,
            "mediaHelper":_loc2_
         });
         _factMediaLoadingSpiral.setNewParent(_loc3_.imgBlock);
         _loc3_.addEventListener("mouseDown",factMouseDownHandler,false,0,true);
         _loc3_.leftBtn.addEventListener("mouseDown",onLeftBtn,false,0,true);
         _loc3_.rightBtn.addEventListener("mouseDown",onRightBtn,false,0,true);
         if(_loc3_.videosBtn)
         {
            _loc3_.videosBtn.addEventListener("mouseDown",onPlayMovieDown,false,0,true);
         }
         _factPopup = _loc3_;
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
            _popupMediaHelper.init(87,mediaHelperHandler,{
               "displayFunction":displayBradyFactPopup,
               "factInfo":param1
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc3_:MovieClip = new _popupTemplate.constructor();
         if(_loc3_ == null || !_loc3_.hasOwnProperty("descTxt") || !_loc3_.hasOwnProperty("imgBlock") || !_loc3_.hasOwnProperty("titleTxt") || !_loc3_.hasOwnProperty("bx"))
         {
            throw new Error("invalid NGFact popup asset!");
         }
         _guiLayer.addChild(_loc3_);
         _loc3_.gotoAndStop(_popupFrameLabelLookup[param1.type]);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc3_.titleTxt.text + "/id_" + param1.id,-1,1);
         _loc3_["bx"].addEventListener("mouseDown",factCloseHandler,false,0,true);
         _loc3_.x = 900 * 0.5;
         _loc3_.y = 550 * 0.5;
         _loc3_.index = param1.index;
         _loc3_.bitIdx = param1.bitIdx;
         LocalizationManager.translateId(_loc3_.titleTxt,param1.title);
         LocalizationManager.translateId(_loc3_.bradyCont.descTxt,param1.description);
         var _loc2_:MediaHelper = new MediaHelper();
         var _loc4_:uint = uint(param1.media);
         _loc2_.init(_loc4_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc4_,
            "pop":_loc3_.bradyCont,
            "mediaHelper":_loc2_
         });
         _factMediaLoadingSpiral.setNewParent(_loc3_.bradyCont.imgBlock);
         _loc3_.addEventListener("mouseDown",factMouseDownHandler,false,0,true);
         _factPopup = _loc3_;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      private static function onPlayMovieDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestStreamList(_factPopup.bitIdx,onVideoGLReceived);
      }
      
      private static function onVideoGLReceived(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array, param7:Array) : void
      {
         GuiManager.initMoviePlayer(39,param2,param4,param7,false);
      }
      
      private static function reloadMuseumPopup(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc5_:Array = null;
         _factPopup.index = param1.index;
         _factPopup.bitIdx = param1.bitIdx;
         while(_factPopup.imgBlock.numChildren > 0)
         {
            _factPopup.imgBlock.removeChildAt(0);
         }
         if(_factPopup.hasOwnProperty("bioTxt"))
         {
            _loc2_ = LocalizationManager.translateIdOnly(param1.title);
            _loc5_ = _loc2_.split("|");
            if(_loc5_[1] != null)
            {
               LocalizationManager.updateToFit(_factPopup.bioTxt,_loc5_[1]);
            }
            LocalizationManager.updateToFit(_factPopup.titleTxt,_loc5_[0]);
         }
         else
         {
            LocalizationManager.translateId(_factPopup.titleTxt,param1.title);
         }
         if(_factPopup.descTxt)
         {
            LocalizationManager.translateId(_factPopup.descTxt,param1.description);
         }
         _factMediaLoadingSpiral.setNewParent(_factPopup.imgBlock);
         var _loc3_:MediaHelper = new MediaHelper();
         var _loc4_:uint = uint(param1.media);
         _loc3_.init(_loc4_,factPopupMediaCallback,true);
         _factMediaRequests.push({
            "id":_loc4_,
            "pop":_factPopup,
            "mediaHelper":_loc3_
         });
      }
      
      public static function setupNormalFact(param1:Object, param2:Boolean = false, param3:MovieClip = null) : void
      {
         var _loc7_:* = null;
         var _loc6_:int = 0;
         if(param1 == null || !param1.hasOwnProperty("id") || !param1.hasOwnProperty("type") || !param1.hasOwnProperty("media") || !param1.hasOwnProperty("title") || !param1.hasOwnProperty("description"))
         {
            throw new Error("invalid NGFact tabInfo!");
         }
         var _loc9_:MovieClip = null;
         var _loc4_:int = int(param1.id);
         var _loc5_:int = int(param1.type);
         if(_loc5_ < 0 || _loc5_ > 12 && _loc5_ < 18)
         {
            throw new Error("invalid NGFact type:" + _loc5_ + "?!");
         }
         if(param3 != null)
         {
            _loc9_ = param3;
         }
         else
         {
            _loc9_ = new _tabTemplate.constructor();
         }
         var _loc8_:Boolean = param1.userVarId == 0 ? true : Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,param1.bitIdx));
         if(_loc9_)
         {
            _worldLayer.addChild(_loc9_);
            if(_loc5_ != 16 || _loc5_ != 17)
            {
               if(_loc8_)
               {
                  _loc9_.gotoAndStop(_tabFrameLabelLookup[_loc5_] + "Dim");
               }
               else
               {
                  _loc9_.gotoAndStop(_tabFrameLabelLookup[_loc5_]);
               }
            }
            else
            {
               param2 = true;
            }
            _loc6_ = int(_loc9_.id = int(param1.id));
            if(_factLocs)
            {
               _loc9_.x = _factLocs[_loc6_].x;
               _loc9_.y = _factLocs[_loc6_].y;
            }
            _loc9_.title = param1.title;
            _loc9_.description = param1.description;
            _loc9_.media = param1.media;
            _loc9_.popup = _loc7_;
            _loc9_.factSeen = _loc8_;
            _loc9_.factInfo = param1;
            _loc9_.type = _loc5_;
            if(!_loc8_)
            {
               _loc9_.userVarId = param1.userVarId;
               _loc9_.bitIdx = param1.bitIdx;
            }
            _loc9_.addEventListener("mouseDown",tabMouseDownHandler,false,0,true);
         }
         if(param2)
         {
            _loc9_.dispatchEvent(new MouseEvent("mouseDown"));
         }
      }
      
      public static function displayNormalNonTabFact(param1:Object) : void
      {
         var _loc5_:TextField = null;
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(87,mediaHelperHandler,{
               "displayFunction":displayNormalNonTabFact,
               "factInfo":param1
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc3_:MovieClip = new _popupTemplate.constructor();
         if(param1 == null || !param1.hasOwnProperty("id") || !param1.hasOwnProperty("type") || !param1.hasOwnProperty("media") || !param1.hasOwnProperty("title") || !param1.hasOwnProperty("description"))
         {
            throw new Error("invalid NGFact tabInfo!");
         }
         _guiLayer.addChild(_loc3_);
         _loc3_.gotoAndStop(_popupFrameLabelLookup[param1.type]);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc3_.titleTxt.text + "/id_" + param1.id,-1,1);
         _loc3_["bx"].addEventListener("mouseDown",factCloseHandler,false,0,true);
         _loc3_.x = 900 * 0.5;
         _loc3_.y = 550 * 0.5;
         _loc3_.index = param1.index;
         _loc3_.bitIdx = param1.bitIdx;
         if(_loc3_.hasOwnProperty("descTxtCont") && _loc3_.descTxtCont != null)
         {
            _loc5_ = _loc3_.descTxtCont.descTxt;
         }
         else
         {
            _loc5_ = _loc3_.descTxt;
         }
         LocalizationManager.translateId(_loc3_.titleTxt,param1.title);
         LocalizationManager.translateId(_loc5_,param1.description);
         var _loc2_:MediaHelper = new MediaHelper();
         var _loc4_:uint = uint(param1.media);
         if(_loc4_ != 0 && _loc3_.imgBlock)
         {
            _loc2_.init(_loc4_,factPopupMediaCallback,true);
            _factMediaRequests.push({
               "id":_loc4_,
               "pop":_loc3_,
               "mediaHelper":_loc2_
            });
            _factMediaLoadingSpiral.setNewParent(_loc3_.imgBlock);
         }
         var _loc7_:XMLList = describeType(_loc3_).variable;
         for each(var _loc6_:XML in _loc7_)
         {
            if(String(_loc6_.@name).indexOf("petBtn_") != -1)
            {
               if(_loc3_[_loc6_.@name])
               {
                  _loc3_[_loc6_.@name].addEventListener("mouseDown",onPetCreateBtn,false,0,true);
               }
            }
         }
         _loc3_.addEventListener("mouseDown",factMouseDownHandler,false,0,true);
         _factPopup = _loc3_;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
      }
      
      private static function onMuseumFactListLoaded(param1:Array) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = null;
         var _loc4_:int = 0;
         _museumFactDefList = [];
         _museumFactDefIndexList = [];
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = param1[_loc4_];
            _loc2_ = {
               "id":int(_loc3_.id),
               "media":int(_loc3_.media),
               "userVarId":int(_loc3_.userVarId),
               "bitIdx":int(_loc3_.bitIdx),
               "type":int(_loc3_.type),
               "description":int(_loc3_.description),
               "title":int(_loc3_.title),
               "index":_loc4_
            };
            _museumFactDefList[_loc2_.id] = _loc2_;
            _museumFactDefIndexList[_loc4_] = _loc2_.id;
            _loc4_++;
         }
         displayMuseumEngangermentPopup(_museumFactDefList[_museumRequest]);
      }
      
      private static function factPopupMediaCallback(param1:MovieClip) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = null;
         var _loc5_:int = int(param1.mediaHelper.id);
         var _loc6_:Array = [];
         for each(var _loc4_:Object in _factMediaRequests)
         {
            if(_loc4_.id == _loc5_)
            {
               param1.x = -param1.width * 0.5;
               param1.y = -param1.height * 0.5;
               _loc4_.pop.imgBlock.addChild(param1);
               if(_factPopup.currentFrame == 17)
               {
                  _loc3_ = _factPopup.bradyCont.descTxt.text;
                  if(param1.width > param1.height)
                  {
                     _factPopup.bradyCont.gotoAndStop("hor");
                  }
                  else
                  {
                     _factPopup.bradyCont.gotoAndStop("ver");
                  }
                  _factPopup.bradyCont.descTxt.text = _loc3_;
               }
               if(_loc4_.pop.imgBlock.contains(_factMediaLoadingSpiral))
               {
                  _loc4_.pop.imgBlock.removeChild(_factMediaLoadingSpiral);
               }
               _loc6_.push(_loc4_);
               break;
            }
         }
         while(_loc6_.length > 0)
         {
            _loc2_ = _loc6_.pop();
            _factMediaRequests.splice(_factMediaRequests.indexOf(_loc2_),1);
         }
         param1.mediaHelper.destroy();
         delete param1.mediaHelper;
      }
      
      private static function tabMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc6_:TextField = null;
         var _loc2_:MediaHelper = null;
         var _loc5_:* = 0;
         param1.stopPropagation();
         _roomMgr.forceStopMovement();
         if(!_hasPopupBeenLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(87,mediaHelperHandler,{
               "displayFunction":setupNormalFact,
               "factInfo":param1.currentTarget.factInfo,
               "tab":param1.currentTarget
            });
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         var _loc3_:MovieClip = param1.currentTarget.popup;
         var _loc4_:MovieClip = MovieClip(param1.currentTarget);
         if(param1.currentTarget.popup == null)
         {
            _loc3_ = new _popupTemplate.constructor();
            if(_loc3_ == null || !_loc3_.hasOwnProperty("imgBlock") || !_loc3_.hasOwnProperty("titleTxt") || !_loc3_.hasOwnProperty("bx"))
            {
               throw new Error("invalid NGFact popup asset!");
            }
            _loc4_.popup = _loc3_;
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/fact/#" + _loc3_.titleTxt.text + "/id_" + param1.currentTarget.id,-1,1);
         if(_loc4_.popup.parent)
         {
            _loc4_.popup.parent.addChild(_loc4_.popup);
         }
         else
         {
            _guiLayer.addChild(_loc3_);
            _loc3_.gotoAndStop(_popupFrameLabelLookup[param1.currentTarget.type]);
            _loc3_["bx"].addEventListener("mouseDown",factCloseHandler,false,0,true);
            _loc3_.x = 900 * 0.5;
            _loc3_.y = 550 * 0.5;
            if(_loc3_.hasOwnProperty("addToBookBtn") && _loc3_.addToBookBtn)
            {
               _loc3_.addToBookBtn.visible = false;
            }
            if(_loc3_.hasOwnProperty("donateBtn") && _loc3_.donateBtn)
            {
               _loc3_.donateBtn.visible = false;
            }
            if(_loc3_.hasOwnProperty("descTxtCont") && _loc3_.descTxtCont != null)
            {
               _loc6_ = _loc3_.descTxtCont.descTxt;
            }
            else
            {
               _loc6_ = _loc3_.descTxt;
            }
            LocalizationManager.translateId(_loc3_.titleTxt,_loc4_.title);
            LocalizationManager.translateId(_loc6_,_loc4_.description);
            _loc2_ = new MediaHelper();
            _loc5_ = uint(_loc4_.media);
            _loc2_.init(_loc5_,factPopupMediaCallback,true);
            _factMediaRequests.push({
               "id":_loc5_,
               "pop":_loc3_,
               "mediaHelper":_loc2_
            });
            _loc3_.visible = false;
            _factMediaLoadingSpiral.setNewParent(_loc3_.imgBlock);
            _loc3_.addEventListener("mouseDown",factMouseDownHandler,false,0,true);
         }
         _factPopup = param1.currentTarget.popup;
         KeepAlive.startKATimer(_factPopup);
         DarkenManager.darken(_factPopup);
         param1.currentTarget.popup.visible = true;
         if(!_loc4_.factSeen)
         {
            AchievementXtCommManager.requestSetUserVar(_loc4_.userVarId,_loc4_.bitIdx);
            AchievementXtCommManager.requestSetUserVar(uvForType(_loc4_.type),1);
            _loc4_.factSeen = true;
            _loc4_.gotoAndStop(_tabFrameLabelLookup[_loc4_.type] + "Dim");
         }
      }
      
      private static function uvForType(param1:int) : int
      {
         switch(param1)
         {
            case 0:
               return 148;
            case 1:
               return 149;
            case 2:
               return 150;
            case 3:
               return 151;
            case 4:
               return 152;
            case 5:
               return 153;
            case 6:
               return 154;
            case 7:
               return 155;
            case 8:
               return 156;
            case 9:
               return 296;
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
         trace("clicked the button to donate");
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
               JBManager.numUnclaimedGifts++;
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
            if(_factPopup.hasOwnProperty("closePopup") && param1)
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
      
      private static function onPetCreateBtn(param1:MouseEvent) : void
      {
         var _loc2_:Array = param1.currentTarget.name.split("_");
         if(_loc2_.length > 1)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId(_loc2_[1]),null,false,null,null,0,0,true);
         }
      }
      
      public static function closeFact() : void
      {
         factCloseHandler(null);
      }
   }
}

