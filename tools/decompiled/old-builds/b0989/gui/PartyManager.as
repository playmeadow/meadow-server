package gui
{
   import Party.PartyXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.loader.FileServerEvent;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import loader.DefPacksDefHelper;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class PartyManager
   {
      
      private static var _secToStart:Array;
      
      private static var _secToEnd:Array;
      
      private static var _hours:Array;
      
      private static var _mins:Array;
      
      private static var _partyMediaIds:Array;
      
      private static var _partyDefIds:Array;
      
      private static var _idsLocalized:Array;
      
      private static var _partyDefs:Object;
      
      private static var _xPos:int;
      
      private static var _yPos:int;
      
      private static var _timeStampSinceLastRequest:Number;
      
      private static var _initialTime:Number;
      
      private static var _numLocStringsToLoad:int;
      
      private static var _numSecPassed:int;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      private static var _partyPopup:MovieClip;
      
      private static var _partyBarrier:MovieClip;
      
      private static var _scrollButtons:SBScrollbar;
      
      private static var _itemWindows:WindowGenerator;
      
      private static var _listBuilt:Boolean;
      
      private static var _isInitialRequest:Boolean;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _partyHeaderDef:int;
      
      private static var _partyHeaderMediaId:int;
      
      private static var _headerSecToStart:Number;
      
      private static var _headerSecToEnd:Number;
      
      private static var _headerHours:Number;
      
      private static var _headerMins:Number;
      
      private static var _headerWindow:ItemWindowParty;
      
      private static var _useHeaderParty:Boolean;
      
      private static var _headerLoadingSpiral:LoadingSpiral;
      
      private static var _adventureHeaderWindow:ItemWindowParty;
      
      private static var _adventureHeaderMediaId:int;
      
      public static const RESTRICTIONS_NONE:int = 0;
      
      public static const RESTRICTIONS_AVATAR:int = 1;
      
      public static const RESTRICTIONS_MEMBERONLY:int = 2;
      
      public static const RESTRICTIONS_PET:int = 4;
      
      private static const REQUEST_INTERVAL:Number = 10000;
      
      private static const PARTY_BARRIER_MEDIA_ID:int = 1299;
      
      public function PartyManager()
      {
         super();
      }
      
      public static function init(param1:int, param2:int) : void
      {
         _xPos = param1;
         _yPos = param2;
         _hours = [];
         _mins = [];
         _timeStampSinceLastRequest = 0;
         _loadingSpiral = new LoadingSpiral();
         _headerLoadingSpiral = new LoadingSpiral();
         _partyPopup = new (getDefinitionByName("PartiesPopup") as Class)();
         _partyPopup.gotoAndStop("noFrame");
         setupPartiesPopup();
      }
      
      public static function open() : void
      {
         _isInitialRequest = false;
         _partyPopup.visible = true;
         if(_partyDefIds)
         {
            if(shouldRequestNewList())
            {
               _listBuilt = false;
               _numLocStringsToLoad = 0;
               _numSecPassed = 0;
               requestData();
            }
         }
         else
         {
            shouldRequestNewList();
            requestData();
         }
      }
      
      public static function close() : void
      {
         _isInitialRequest = true;
         GuiManager.mainHud.partyBtn.downToUpState();
         _partyPopup.visible = false;
         GuiManager.showPartyBtnGlow(false);
         if(_partyBarrier)
         {
            DarkenManager.unDarken(_partyBarrier);
         }
      }
      
      public static function get visible() : Boolean
      {
         if(_partyPopup)
         {
            return _partyPopup.visible;
         }
         return false;
      }
      
      public static function updateTime() : void
      {
         var _loc1_:Number = NaN;
         if(_listBuilt)
         {
            _loc1_ = getTimer();
            if(_loc1_ - _initialTime >= REQUEST_INTERVAL)
            {
               _initialTime = getTimer();
               onTimer();
            }
         }
      }
      
      public static function canSwitchToAvatar(param1:Avatar, param2:Boolean = false) : Boolean
      {
         var _loc3_:Object = null;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_PARTY)
         {
            _loc3_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc3_ != null && _loc3_.restrictions == RESTRICTIONS_AVATAR)
            {
               if((_loc3_.avatarDefFlags & 1 << param1.avTypeId - 1) == 0)
               {
                  if(param2)
                  {
                     showPartyBarrier(true);
                  }
                  return false;
               }
            }
         }
         return true;
      }
      
      public static function canSwitchPet(param1:Boolean = false) : Boolean
      {
         var _loc2_:Object = null;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_PARTY)
         {
            _loc2_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc2_ != null && _loc2_.restrictions == RESTRICTIONS_PET)
            {
               if(param1)
               {
                  showPartyBarrier(true);
               }
               return false;
            }
         }
         return true;
      }
      
      public static function showPartyBarrier(param1:Boolean = false) : void
      {
         var _loc2_:Object = null;
         if(_partyBarrier)
         {
            _loc2_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc2_ != null)
            {
               if(int(_loc2_.restrictions) == RESTRICTIONS_PET)
               {
                  setupBarrierTextForPets(param1);
               }
               else
               {
                  LocalizationXtCommManager.sendTranslateStringRequest(gMainFrame.userInfo.getAvatarDefByAvType(_loc2_.avatarDefId).titleStrRef,LocalizationXtCommManager.LANG_ENG,onAvatarNameLocalization,param1);
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(PARTY_BARRIER_MEDIA_ID,onMediaItemLoaded,param1);
         }
      }
      
      public static function getPartyDef(param1:int) : Object
      {
         return _partyDefs[param1];
      }
      
      public static function bringToFront() : void
      {
         _partyPopup.parent.setChildIndex(_partyPopup,_partyPopup.parent.numChildren - 1);
      }
      
      private static function setupPartiesPopup() : void
      {
         while(_partyPopup.itemWindow.numChildren > 0)
         {
            _partyPopup.itemWindow.removeChildAt(0);
         }
         if(_useHeaderParty)
         {
            while(_partyPopup.itemWindowHeader.numChildren > 0)
            {
               _partyPopup.itemWindowHeader.removeChildAt(0);
            }
         }
         _partyPopup.x = _xPos;
         _partyPopup.y = _yPos + _partyPopup.height * 0.5;
         if(_useHeaderParty)
         {
            _partyPopup.y -= 64;
         }
         else
         {
            _partyPopup.y -= 32;
         }
         _partyPopup.visible = false;
         _loadingSpiral.setNewParent(_partyPopup.itemWindow,_partyPopup.itemWindow.width * 0.5 + 23.5,_partyPopup.itemWindow.height * 0.5);
         if(_useHeaderParty)
         {
            _headerLoadingSpiral.setNewParent(_partyPopup.itemWindowHeader,_partyPopup.itemWindowHeader.width * 0.5,_partyPopup.itemWindowHeader.height * 0.5);
         }
         if(!GuiManager.guiLayer.contains(_partyPopup))
         {
            GuiManager.guiLayer.addChild(_partyPopup);
         }
         _partyPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
         _partyPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onCloseBtn,false,0,true);
      }
      
      private static function buildPartyWindows() : void
      {
         var _loc2_:Object = null;
         if(_scrollButtons)
         {
            _scrollButtons.destroy();
            _scrollButtons = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_headerWindow)
         {
            _headerWindow.destroy();
            _headerWindow = null;
         }
         if(_useHeaderParty)
         {
            _loc2_ = Utility.calculateTime(_headerSecToStart);
            _headerMins = _loc2_.mins;
            _headerHours = _loc2_.hours;
            _headerWindow = new ItemWindowParty(onHeaderLoaded,null,"",0,headerWinMouseDown,null,null,null,{"mediaRefId":[_partyHeaderMediaId]});
         }
         if(_adventureHeaderWindow)
         {
            _adventureHeaderWindow.destroy();
            _adventureHeaderWindow = null;
         }
         _adventureHeaderWindow = new ItemWindowParty(onHeaderTwoLoaded,null,"",0,adventureHeaderMouseDown,null,null,null,{"mediaRefId":[_adventureHeaderMediaId]});
         calculateTime();
         var _loc1_:int = int(_partyDefIds.length);
         if(_loc1_ <= 0)
         {
            _loadingSpiral.visible = false;
            return;
         }
         _itemWindows = new WindowGenerator();
         _itemWindows.init(1,_loc1_,_loc1_,0,0,0,ItemWindowParty,null,"",{"mouseDown":winMouseDown},{"mediaRefId":_partyMediaIds},onItemWindowsCreated);
      }
      
      private static function onItemWindowsCreated() : void
      {
         var _loc2_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc1_:int = int(_partyDefIds.length);
         _idsLocalized = [];
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_)
         {
            _loc4_ = MovieClip(_itemWindows.bg.getChildAt(_loc3_));
            _loc4_.defId = int(_partyDefs[_partyDefIds[_loc3_]].id);
            _loc4_.setupTextAndAnims(_secToStart[_loc3_],_secToStart[_loc3_] > 0 ? calculatePrintTime(_loc3_) : "");
            _loc2_ = int(_partyDefs[_partyDefIds[_loc3_]].titleStrId);
            if(Boolean(_idsLocalized) && !_idsLocalized[_loc2_])
            {
               _idsLocalized[_partyDefs[_partyDefIds[_loc3_]].titleStrId] = true;
               LocalizationXtCommManager.sendTranslateStringRequest(_partyDefs[_partyDefIds[_loc3_]].titleStrId,LocalizationXtCommManager.LANG_ENG,onTitleTextLoaded);
            }
            _loc3_++;
         }
         _initialTime = getTimer();
         _listBuilt = true;
      }
      
      private static function onHeaderLoaded(param1:MovieClip, param2:int = -1) : void
      {
         _headerWindow.defId = _partyHeaderDef;
         _headerWindow.setupTextAndAnims(_headerSecToStart,_headerSecToStart > 0 ? Utility.calculatePrintTime(_headerMins,_headerHours) : "");
         LocalizationXtCommManager.sendTranslateStringRequest(_partyDefs[_partyHeaderDef].titleStrId,LocalizationXtCommManager.LANG_ENG,onHeaderTitleTextLoaded);
      }
      
      private static function onHeaderTwoLoaded(param1:MovieClip, param2:int = -1) : void
      {
         _adventureHeaderWindow.setupTextAndAnims(0,"");
         _partyPopup.itemWindowHeader.addChild(_adventureHeaderWindow);
      }
      
      private static function onHeaderTitleTextLoaded(param1:int, param2:String) : void
      {
         _headerWindow.titleText = param2;
         _headerLoadingSpiral.visible = false;
         _partyPopup.itemWindowHeader2.addChild(_headerWindow);
      }
      
      private static function onTitleTextLoaded(param1:int, param2:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         _idsLocalized[param1] = param2;
         --_numLocStringsToLoad;
         if(_numLocStringsToLoad == 0)
         {
            _loc3_ = 0;
            while(_loc3_ < _partyDefIds.length)
            {
               _loc4_ = MovieClip(_itemWindows.bg.getChildAt(_loc3_));
               _loc4_.titleText = _idsLocalized[_partyDefs[_partyDefIds[_loc3_]].titleStrId];
               _loc3_++;
            }
            _idsLocalized = null;
            _loadingSpiral.visible = false;
            _partyPopup.itemWindow.addChild(_itemWindows);
            _scrollButtons = new SBScrollbar();
            _scrollButtons.init(_itemWindows,270,160,0,"scrollbar2",53,0,_partyDefIds.length * 53.1);
         }
      }
      
      private static function calculateTime() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < _secToStart.length)
         {
            _loc1_ = Utility.calculateTime(_secToStart[_loc2_]);
            _mins[_loc2_] = _loc1_.mins;
            _hours[_loc2_] = _loc1_.hours;
            _loc2_++;
         }
      }
      
      private static function shouldRequestNewList() : Boolean
      {
         var _loc1_:Number = getTimer();
         if(_loc1_ - _timeStampSinceLastRequest > REQUEST_INTERVAL)
         {
            _timeStampSinceLastRequest = _loc1_;
            return true;
         }
         return false;
      }
      
      private static function calculatePrintTime(param1:int, param2:Boolean = false) : String
      {
         return Utility.calculatePrintTime(_mins[param1],_hours[param1],param2);
      }
      
      private static function winMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(param1.currentTarget.index);
         if(_secToStart[_loc2_] <= 0)
         {
            if(_secToEnd[_loc2_] <= (getTimer() - _initialTime) / 1000)
            {
               new SBOkPopup(GuiManager.guiLayer,"This party is over. See you next time!");
               _partyDefIds.splice(_loc2_,1);
               _partyMediaIds.splice(_loc2_,1);
               _secToStart.splice(_loc2_,1);
               _secToEnd.splice(_loc2_,1);
               _hours.splice(_loc2_,1);
               _mins.splice(_loc2_,1);
               rebuildList();
               return;
            }
            DarkenManager.showLoadingSpiral(true);
            PartyXtCommManager.sendJoinPartyRequest(param1.currentTarget.defId);
            close();
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,"This party starts in " + calculatePrintTime(_loc2_,true) + ".");
         }
      }
      
      private static function headerWinMouseDown(param1:MouseEvent) : void
      {
         if(_headerSecToStart <= 0)
         {
            DarkenManager.showLoadingSpiral(true);
            PartyXtCommManager.sendJoinPartyRequest(param1.currentTarget.defId);
            close();
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,"This party starts in " + Utility.calculatePrintTime(_headerMins,_headerHours,true) + ".");
         }
      }
      
      private static function adventureHeaderMouseDown(param1:MouseEvent) : void
      {
         DarkenManager.showLoadingSpiral(true);
         RoomXtCommManager.sendNonDenRoomJoinRequest("adventures.queststaging_0_360#" + RoomManagerWorld.instance.shardId);
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         close();
      }
      
      private static function onTimer() : void
      {
         var _loc1_:Boolean = false;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc5_:MovieClip = null;
         var _loc6_:Boolean = false;
         _numSecPassed += REQUEST_INTERVAL / 1000;
         var _loc2_:* = 0;
         while(_loc2_ < _secToStart.length)
         {
            _loc3_ = int(_hours[_loc2_]);
            _loc4_ = int(_mins[_loc2_]);
            if(_loc3_ > 0 || _loc4_ > 0)
            {
               _secToStart[_loc2_] -= REQUEST_INTERVAL / 1000;
               if(_secToStart[_loc2_] <= 0)
               {
                  _loc3_ = 0;
                  _loc4_ = 0;
               }
               else if(_numSecPassed == 60)
               {
                  if(_loc3_ > 0 && _loc4_ == 0)
                  {
                     _loc3_--;
                  }
                  if(_loc4_ == 0)
                  {
                     _loc4_ = 59;
                  }
                  else
                  {
                     _loc4_--;
                  }
               }
               _hours[_loc2_] = _loc3_;
               _mins[_loc2_] = _loc4_;
               _loc6_ = Boolean(_itemWindows) && Boolean(_itemWindows.bg) && _itemWindows.bg.numChildren >= _loc2_;
               if(_loc6_)
               {
                  _loc5_ = MovieClip(_itemWindows.bg.getChildAt(_loc2_));
               }
               if(_loc3_ > 0 || _loc4_ > 0)
               {
                  if(_loc6_)
                  {
                     _loc5_.setupTextAndAnims(_secToStart[_loc2_],calculatePrintTime(_loc2_));
                  }
               }
               else
               {
                  if(_loc6_)
                  {
                     _loc5_.setupTextAndAnims(-1,"");
                  }
                  GuiManager.showPartyBtnGlow(true);
               }
            }
            else
            {
               _secToEnd[_loc2_] -= REQUEST_INTERVAL / 1000;
               if(_secToEnd[_loc2_] <= 0)
               {
                  GuiManager.showPartyBtnGlow(false);
                  _loc1_ = true;
                  _partyDefIds.splice(_loc2_,1);
                  _partyMediaIds.splice(_loc2_,1);
                  _secToStart.splice(_loc2_,1);
                  _secToEnd.splice(_loc2_,1);
                  _hours.splice(_loc2_,1);
                  _mins.splice(_loc2_,1);
                  _loc2_--;
               }
            }
            _loc2_++;
         }
         if(_numSecPassed == 60)
         {
            _numSecPassed = 0;
         }
         if(_loc1_)
         {
            _numSecPassed = 0;
            rebuildList();
         }
      }
      
      private static function rebuildList() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Array = [];
         _partyMediaIds = [];
         var _loc3_:int = 0;
         while(_loc3_ < _partyDefIds.length)
         {
            _loc2_ = int(_partyDefs[_partyDefIds[_loc3_]].titleStrId);
            if(!_loc1_[_loc2_])
            {
               ++_numLocStringsToLoad;
               _loc1_[_loc2_] = true;
            }
            _partyMediaIds[_loc3_] = int(_partyDefs[_partyDefIds[_loc3_]].mediaRefId);
            _loc3_++;
         }
         buildPartyWindows();
      }
      
      public static function initialDataRequest() : void
      {
         _isInitialRequest = true;
         _timeStampSinceLastRequest = getTimer();
         requestData();
      }
      
      private static function requestData() : void
      {
         var _loc1_:DefPacksDefHelper = null;
         if(_partyDefs)
         {
            requestPartyList();
         }
         else
         {
            _loc1_ = new DefPacksDefHelper();
            _loc1_.init(DefPacksDefHelper.DEF_PARTY,onPartyDataResponse,null,FileServerEvent.AMF3_TYPE);
            DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PARTY] = _loc1_;
         }
      }
      
      private static function onPartyDataResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PARTY] = null;
         _partyDefs = param1.def;
         requestPartyList();
      }
      
      public static function requestPartyList() : void
      {
         gMainFrame.server.setXtObject_Str("sl",[]);
      }
      
      public static function roomSoireeResponse(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc2_:* = 2;
         if(param1[_loc2_++] == "0")
         {
            _loc3_ = param1[_loc2_++];
            gMainFrame.clientInfo.secondaryDefId = param1[_loc2_++];
            if(_loc3_ == "NM")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,"You need to be a member to join this party.");
            }
            else if(_loc3_ == "NA")
            {
               showPartyBarrier();
            }
            else if(_loc3_ == "NP")
            {
               DarkenManager.showLoadingSpiral(false);
               showPartyBarrier();
            }
         }
      }
      
      private static function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = null;
         if(param1)
         {
            _partyBarrier = MovieClip(param1.getChildAt(0));
            _partyBarrier.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            _partyBarrier.bx.addEventListener(MouseEvent.MOUSE_DOWN,onBarrierClose,false,0,true);
            _partyBarrier.x = MainFrame.VIEW_WIDTH * 0.5;
            _partyBarrier.y = MainFrame.VIEW_HEIGHT * 0.5;
            _partyBarrier.visible = false;
            GuiManager.guiLayer.addChild(_partyBarrier);
            _loc2_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc2_ != null)
            {
               if(int(_loc2_.restrictions) == RESTRICTIONS_PET)
               {
                  setupBarrierTextForPets(param1.passback);
               }
               else
               {
                  LocalizationXtCommManager.sendTranslateStringRequest(gMainFrame.userInfo.getAvatarDefByAvType(_loc2_.avatarDefId).titleStrRef,LocalizationXtCommManager.LANG_ENG,onAvatarNameLocalization,param1.passback);
               }
            }
         }
      }
      
      private static function onBarrierClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_partyBarrier);
         _partyBarrier.visible = false;
      }
      
      private static function onAvatarNameLocalization(param1:int, param2:String, param3:Object = null) : void
      {
         var _loc4_:String = param2;
         if(_partyBarrier.currentFrameLabel != _loc4_)
         {
            _partyBarrier.gotoAndStop(_loc4_);
         }
         _loc4_ = _loc4_.toLowerCase();
         var _loc5_:String = _partyBarrier.titleTxt.text.split(" ")[0].toLowerCase();
         if(param3)
         {
            _partyBarrier.Message_txt.text = "This party is for " + _loc5_ + " only! You must leave the party to switch animals!";
         }
         else
         {
            _partyBarrier.Message_txt.text = "This party is for " + _loc5_ + " only! Become a " + _loc4_ + " and come join the fun!";
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(param3)
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/member/switch");
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/member");
            }
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/nonMember");
         }
         DarkenManager.showLoadingSpiral(false);
         _partyBarrier.parent.setChildIndex(_partyBarrier,_partyBarrier.parent.numChildren - 1);
         DarkenManager.darken(_partyBarrier);
         _partyBarrier.visible = true;
      }
      
      private static function setupBarrierTextForPets(param1:Object = null) : void
      {
         if(_partyBarrier.currentFrameLabel != "Pets")
         {
            _partyBarrier.gotoAndStop("Pets");
         }
         if(param1)
         {
            _partyBarrier.Message_txt.text = "This party is for pets only! You need to keep a pet with you!";
         }
         else if(AvatarManager.roomEnviroType == Utility.ENVIRO_OCEAN)
         {
            _partyBarrier.Message_txt.text = "This party is for pets only! Bring a land pet and come join the fun!";
         }
         else
         {
            _partyBarrier.Message_txt.text = "This party is for pets only! Bring a pet and come join the fun!";
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(param1)
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#petParty/member/switch");
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#petParty/member");
            }
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/barrier/#petParty/nonMember");
         }
         DarkenManager.showLoadingSpiral(false);
         _partyBarrier.parent.setChildIndex(_partyBarrier,_partyBarrier.parent.numChildren - 1);
         DarkenManager.darken(_partyBarrier);
         _partyBarrier.visible = true;
      }
      
      public static function partyListResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         if(_partyPopup)
         {
            _partyDefIds = [];
            _secToStart = [];
            _secToEnd = [];
            _partyMediaIds = [];
            _loc3_ = [];
            _loc4_ = int(param1[3]);
            _loc5_ = 4;
            _partyHeaderDef = int(param1[2]);
            _useHeaderParty = _partyHeaderDef != -1;
            _adventureHeaderMediaId = 2253;
            if(_useHeaderParty)
            {
               _partyPopup.gotoAndStop("twoHeader");
               if(_partyDefs[_partyHeaderDef])
               {
                  _partyHeaderMediaId = _partyDefs[_partyHeaderDef].mediaRefId;
                  _headerSecToStart = 0;
                  _headerSecToEnd = 0;
               }
            }
            else
            {
               _partyPopup.gotoAndStop("header");
            }
            setupPartiesPopup();
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _partyDefIds[_loc6_] = int(param1[_loc5_]);
               if(_partyDefs[int(param1[_loc5_])])
               {
                  _loc2_ = int(_partyDefs[int(param1[_loc5_])].titleStrId);
                  if(!_loc3_[_loc2_])
                  {
                     ++_numLocStringsToLoad;
                     _loc3_[_loc2_] = true;
                  }
                  _partyMediaIds[_loc6_] = int(_partyDefs[int(param1[_loc5_++])].mediaRefId);
                  _secToStart[_loc6_] = Number(param1[_loc5_++]);
                  _secToEnd[_loc6_] = Number(param1[_loc5_++]);
                  if(_secToStart[_loc6_] == 0 && _isInitialRequest)
                  {
                     GuiManager.showPartyBtnGlow(true);
                  }
               }
               _loc6_++;
            }
            _loc3_ = null;
            if(_partyMediaIds.length > 0)
            {
               if(!_isInitialRequest)
               {
                  _partyPopup.visible = true;
               }
               else
               {
                  _isInitialRequest = false;
               }
               buildPartyWindows();
            }
         }
      }
   }
}

