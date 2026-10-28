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
   import flash.utils.getTimer;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import loader.DefPacksDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import quest.QuestXtCommManager;
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
      
      private static var _numSecPassed:int;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      private static var _partyPopup:MovieClip;
      
      private static var _partyBarrier:MovieClip;
      
      private static var _scrollButtons:SBScrollbar;
      
      private static var _itemWindows:WindowGenerator;
      
      private static var _listBuilt:Boolean;
      
      private static var _isInitialRequest:Boolean;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _headerWindow:ItemWindowParty;
      
      private static var _headerWindow2:ItemWindowParty;
      
      private static var _headerLoadingSpiral:LoadingSpiral;
      
      private static var _adventureHeaderWindow:ItemWindowParty;
      
      private static var _adventureHeaderMediaId:int;
      
      private static var _timeOffset:int;
      
      private static var _requestedOnClick:Boolean;
      
      private static var _hasCreatedPartyPopup:Boolean;
      
      private static var _additionalScriptDefs:Object;
      
      private static var _additionalHeaderData:Array;
      
      public static const RESTRICTIONS_NONE:int = 0;
      
      public static const RESTRICTIONS_AVATAR:int = 1;
      
      public static const RESTRICTIONS_MEMBERONLY:int = 2;
      
      public static const RESTRICTIONS_PET:int = 4;
      
      public static const RESTRICTIONS_BEYOURPET:int = 8;
      
      private static const REQUEST_INTERVAL:Number = 10000;
      
      private static const PARTY_BARRIER_MEDIA_ID:int = 1299;
      
      private static const ADDITIONAL_ADVENTURE_SCRIPT_ID:int = 283;
      
      public function PartyManager()
      {
         super();
      }
      
      public static function init(param1:int, param2:int) : void
      {
         _xPos = param1;
         _yPos = param2;
         _additionalHeaderData = [];
         _hours = [];
         _mins = [];
         _timeOffset = Math.abs(RoomManagerWorld.instance.shardId) * 10 % 60;
         _timeStampSinceLastRequest = 0;
         _loadingSpiral = new LoadingSpiral();
         _headerLoadingSpiral = new LoadingSpiral();
         _partyPopup = GETDEFINITIONBYNAME("PartiesPopup");
         _partyPopup.gotoAndStop("noFrame");
         _requestedOnClick = false;
      }
      
      public static function reload() : void
      {
         close();
         _hasCreatedPartyPopup = false;
         _timeOffset = Math.abs(RoomManagerWorld.instance.shardId) * 10 % 60;
         _timeStampSinceLastRequest = 0;
         _partyPopup = GETDEFINITIONBYNAME("PartiesPopup");
         _partyPopup.gotoAndStop("noFrame");
         _requestedOnClick = false;
         initialDataRequest();
      }
      
      public static function open() : void
      {
         _isInitialRequest = false;
         GuiManager.showPartyBtnGlow(false);
         if(!_hasCreatedPartyPopup)
         {
            setupPartiesPopup();
         }
         else
         {
            _partyPopup.parent.setChildIndex(_partyPopup,_partyPopup.parent.numChildren - 1);
            _partyPopup.visible = true;
            DarkenManager.darken(_partyPopup);
         }
         if(_partyDefIds)
         {
            if(shouldRequestNewList())
            {
               _listBuilt = false;
               _numSecPassed = 0;
               requestData();
            }
            else
            {
               buildPartyWindows();
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
         if(GuiManager.mainHud.partyBtn)
         {
            GuiManager.mainHud.partyBtn.downToUpState();
         }
         _partyPopup.visible = false;
         DarkenManager.unDarken(_partyPopup);
         destroyPartyWindows();
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
      
      public static function isBeYourPetParty() : Boolean
      {
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_PARTY)
         {
            _loc1_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc1_ != null && _loc1_.restrictions == RESTRICTIONS_BEYOURPET)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function canSwitchToAvatar(param1:Avatar, param2:Boolean = false) : Boolean
      {
         var _loc3_:Object = null;
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_PARTY)
         {
            _loc3_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc3_ != null)
            {
               if(_loc3_.restrictions == RESTRICTIONS_AVATAR)
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
               else if(_loc3_.restrictions == RESTRICTIONS_PET)
               {
                  if(!PetManager.checkIfHasPet(param1.enviroTypeFlag))
                  {
                     if(param2)
                     {
                        showPartyBarrier(true,true);
                     }
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      public static function canSwitchPet(param1:Boolean = false) : Boolean
      {
         var _loc2_:Object = null;
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_PARTY)
         {
            _loc2_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc2_ != null && (_loc2_.restrictions == RESTRICTIONS_PET || _loc2_.restrictions == RESTRICTIONS_BEYOURPET))
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
      
      public static function showPartyBarrier(param1:Boolean = false, param2:Boolean = false, param3:int = -1) : void
      {
         var _loc4_:Object = null;
         if(param3 == -1)
         {
            param3 = int(gMainFrame.clientInfo.secondaryDefId);
         }
         if(_partyBarrier)
         {
            _loc4_ = _partyDefs[param3];
            if(_loc4_ != null)
            {
               if(int(_loc4_.restrictions) == RESTRICTIONS_PET || int(_loc4_.restrictions) == RESTRICTIONS_BEYOURPET)
               {
                  setupBarrierTextForPets({
                     "isTryingToSwitch":param1,
                     "doesNotHaveRequiredPet":param2
                  });
               }
               else
               {
                  onAvatarNameLocalization(_loc4_.avatarDefFlags,param1);
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(PARTY_BARRIER_MEDIA_ID,onMediaItemLoaded,{
               "isTryingToSwitch":param1,
               "doesNotHaveRequiredPet":param2,
               "secondaryDefId":param3
            });
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
         while(_partyPopup.itemWindow.numChildren > 1)
         {
            _partyPopup.itemWindow.removeChildAt(0);
         }
         if(_additionalHeaderData.length > 0)
         {
            while(_partyPopup.itemWindowHeader.numChildren > 1)
            {
               _partyPopup.itemWindowHeader.removeChildAt(0);
            }
            if(_partyPopup.itemWindowHeader2)
            {
               while(_partyPopup.itemWindowHeader2.numChildren > 1)
               {
                  _partyPopup.itemWindowHeader2.removeChildAt(0);
               }
            }
            if(_partyPopup.itemWindowHeader3)
            {
               while(_partyPopup.itemWindowHeader3.numChildren > 1)
               {
                  _partyPopup.itemWindowHeader3.removeChildAt(0);
               }
            }
         }
         _partyPopup.x = _xPos;
         _partyPopup.y = _yPos + 304 * 0.5;
         if(_additionalHeaderData.length == 0)
         {
            _partyPopup.y -= 32;
         }
         else if(_additionalHeaderData.length == 1)
         {
            _partyPopup.y -= 64;
         }
         else if(_additionalHeaderData.length == 2)
         {
            _partyPopup.y -= 96;
         }
         _loadingSpiral.setNewParent(_partyPopup.itemWindow,_partyPopup.itemWindow.width * 0.5 + 23.5,_partyPopup.itemWindow.height * 0.5);
         if(_additionalHeaderData.length > 0)
         {
            _headerLoadingSpiral.setNewParent(_partyPopup.itemWindowHeader,_partyPopup.itemWindowHeader.width * 0.5,_partyPopup.itemWindowHeader.height * 0.5);
         }
         if(!GuiManager.guiLayer.contains(_partyPopup))
         {
            GuiManager.guiLayer.addChild(_partyPopup);
         }
         DarkenManager.darken(_partyPopup);
         _partyPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
         _partyPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onCloseBtn,false,0,true);
         _partyPopup.visible = true;
         _hasCreatedPartyPopup = true;
      }
      
      private static function buildPartyWindows() : void
      {
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
         if(_headerWindow2)
         {
            _headerWindow2.destroy();
            _headerWindow2 = null;
         }
         if(_additionalHeaderData.length > 0)
         {
            _headerWindow = new ItemWindowParty(onHeaderTwoLoaded,null,"",0,headerWinMouseDown,null,null,null,{
               "mediaRefId":[_additionalHeaderData[0].mediaId],
               "additionalIndex":0
            });
            if(_additionalHeaderData.length == 2)
            {
               _headerWindow2 = new ItemWindowParty(onHeaderThreeLoaded,null,"",0,headerWinMouseDown,null,null,null,{
                  "mediaRefId":[_additionalHeaderData[1].mediaId],
                  "additionalIndex":1
               });
            }
         }
         if(_adventureHeaderWindow)
         {
            _adventureHeaderWindow.destroy();
            _adventureHeaderWindow = null;
         }
         _adventureHeaderWindow = new ItemWindowParty(onHeaderLoaded,null,"",0,adventureHeaderMouseDown,null,null,null,{"mediaRefId":[_adventureHeaderMediaId]});
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
      
      private static function destroyPartyWindows() : void
      {
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
         if(_adventureHeaderWindow)
         {
            _adventureHeaderWindow.destroy();
            _adventureHeaderWindow = null;
         }
      }
      
      private static function onItemWindowsCreated() : void
      {
         var _loc3_:MovieClip = null;
         var _loc1_:int = int(_partyDefIds.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = MovieClip(_itemWindows.bg.getChildAt(_loc2_));
            _loc3_.defId = int(_partyDefs[_partyDefIds[_loc2_]].id);
            _loc3_.isGame = _partyDefs[_partyDefIds[_loc2_]].isGame == "1";
            _loc3_.setupTextAndAnims(_secToStart[_loc2_],_secToStart[_loc2_] > 0 ? calculatePrintTime(_loc2_) : "");
            _loc3_.titleText = _partyDefs[_partyDefIds[_loc2_]].titleStrId;
            _loc2_++;
         }
         _loadingSpiral.visible = false;
         _partyPopup.itemWindow.addChild(_itemWindows);
         _scrollButtons = new SBScrollbar();
         _scrollButtons.init(_itemWindows,270,160,0,"scrollbar2",53,0,_partyDefIds.length * 53.1);
         _initialTime = getTimer();
         _listBuilt = true;
      }
      
      private static function onHeaderLoaded(param1:MovieClip, param2:int = -1) : void
      {
         _adventureHeaderWindow.setupTextAndAnims(0,"");
         _partyPopup.itemWindowHeader.addChild(_adventureHeaderWindow);
      }
      
      private static function onHeaderTwoLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var _loc3_:Object = _additionalHeaderData[0];
         _headerWindow.defId = _loc3_.defId;
         _headerWindow.setupTextAndAnims(_loc3_.secToStart,_loc3_.secToStart > 0 ? Utility.calculatePrintTime(_loc3_.headerTime.mins,_loc3_.headerTime.hours) : "");
         if(_loc3_.isParty)
         {
            _headerWindow.titleText = _partyDefs[_loc3_.defId].titleStrId;
         }
         _headerLoadingSpiral.visible = false;
         _partyPopup.itemWindowHeader2.addChild(_headerWindow);
      }
      
      private static function onHeaderThreeLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var _loc3_:Object = _additionalHeaderData[1];
         _headerWindow2.defId = _loc3_.defId;
         _headerWindow2.setupTextAndAnims(_loc3_.secToStart,_loc3_.secToStart > 0 ? Utility.calculatePrintTime(_loc3_.headerTime.mins,_loc3_.headerTime.hours) : "");
         if(_loc3_.isParty)
         {
            _headerWindow2.titleText = _partyDefs[_loc3_.defId].titleStrId;
         }
         _headerLoadingSpiral.visible = false;
         _partyPopup.itemWindowHeader3.addChild(_headerWindow2);
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
         if(_secToStart[_loc2_] - _timeOffset <= 0)
         {
            if(_secToEnd[_loc2_] <= (getTimer() - _initialTime) / 1000)
            {
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14777));
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
            if(param1.currentTarget.isGame)
            {
               if(MinigameManager.minigameInfoCache.getMinigameInfo(102) == null)
               {
                  MinigameXtCommManager.sendMinigameInfoRequest([102],false,onMinigameInfoResponse);
               }
               else
               {
                  MinigameManager.handleGameClick({"typeDefId":102},null,true);
               }
            }
            else
            {
               PartyXtCommManager.sendJoinPartyRequest(param1.currentTarget.defId);
            }
            close();
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14778,calculatePrintTime(_loc2_,true)));
         }
      }
      
      private static function headerWinMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = _additionalHeaderData[param1.currentTarget.additionalIndex];
         if(_loc2_)
         {
            if(_loc2_.isParty)
            {
               if(_loc2_.secToStart <= 0)
               {
                  DarkenManager.showLoadingSpiral(true);
                  PartyXtCommManager.sendJoinPartyRequest(param1.currentTarget.defId);
                  close();
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14778,Utility.calculatePrintTime(_loc2_.headerTime.mins,_loc2_.headerTime.hours,true)));
               }
            }
            else
            {
               DarkenManager.showLoadingSpiral(true);
               QuestXtCommManager.sendQuestCreateJoinPublic(param1.currentTarget.defId);
               close();
            }
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
      }
      
      private static function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick({"typeDefId":102},null,true);
      }
      
      public static function requestPartyList() : void
      {
         _requestedOnClick = true;
         gMainFrame.server.setXtObject_Str("sl",[]);
      }
      
      public static function roomSoireeResponse(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc2_:* = 2;
         if(param1[_loc2_++] == "0")
         {
            _loc3_ = param1[_loc2_++];
            RoomXtCommManager.loadingNewRoom = false;
            if(_loc3_ == "NM")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14779));
            }
            else if(_loc3_ == "NA")
            {
               showPartyBarrier(false,false,param1[_loc2_++]);
            }
            else if(_loc3_ == "NP")
            {
               DarkenManager.showLoadingSpiral(false);
               showPartyBarrier(false,false,param1[_loc2_++]);
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
            _loc2_ = _partyDefs[param1.passback.secondaryDefId];
            if(_loc2_ != null)
            {
               if(int(_loc2_.restrictions) == RESTRICTIONS_PET || int(_loc2_.restrictions) == RESTRICTIONS_BEYOURPET)
               {
                  setupBarrierTextForPets(param1.passback);
               }
               else
               {
                  onAvatarNameLocalization(_loc2_.avatarDefFlags,param1.passback.isTryingToSwitch);
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
      
      private static function onAvatarNameLocalization(param1:Number, param2:Object = null) : void
      {
         var _loc3_:String = param1.toString(2);
         var _loc4_:* = int(_loc3_.length - 1);
         while(_loc4_ >= 0)
         {
            if(_loc3_.charAt(_loc4_) == "1")
            {
               _loc4_ = int(_loc3_.length - 1 - _loc4_ + 1);
               break;
            }
            _loc4_--;
         }
         var _loc5_:String = "Avatar" + _loc4_;
         if(_partyBarrier.currentFrameLabel != _loc5_)
         {
            _partyBarrier.gotoAndStop(_loc5_);
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(param2)
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc5_ + "/member/switch");
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc5_ + "/member");
            }
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc5_ + "/nonMember");
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
            if(param1.doesNotHaveRequiredPet)
            {
               LocalizationManager.translateId(_partyBarrier.Message_txt,18790);
            }
            else
            {
               LocalizationManager.translateId(_partyBarrier.Message_txt,11407);
            }
         }
         else if(AvatarManager.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
         {
            LocalizationManager.translateId(_partyBarrier.Message_txt,11366);
         }
         else
         {
            LocalizationManager.translateId(_partyBarrier.Message_txt,11367);
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
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         if(_partyPopup)
         {
            _partyDefIds = [];
            _secToStart = [];
            _secToEnd = [];
            _partyMediaIds = [];
            _additionalHeaderData = [];
            _loc3_ = [];
            _loc4_ = int(param1[3]);
            _loc5_ = 4;
            if(_additionalScriptDefs == null)
            {
               GenericListXtCommManager.requestGenericList(ADDITIONAL_ADVENTURE_SCRIPT_ID,OnAddionalAdventureScriptDefLoaded,param1);
               return;
            }
            _loc6_ = int(param1[2]);
            if(_loc6_ != -1)
            {
               _additionalHeaderData.push({
                  "isParty":true,
                  "defId":_loc6_,
                  "mediaId":int(_partyDefs[_loc6_].mediaRefId),
                  "secToStart":0,
                  "secToEnd":0,
                  "headerTime":Utility.calculateTime(0)
               });
            }
            if(_additionalScriptDefs.length > 0)
            {
               _loc8_ = QuestXtCommManager.getScriptDef(_additionalScriptDefs[0]);
               if(_loc8_)
               {
                  _additionalHeaderData.push({
                     "isParty":false,
                     "defId":_loc8_.defId,
                     "mediaId":_loc8_.bannerMediaRefId,
                     "secToStart":0,
                     "secToEnd":0,
                     "headerTime":Utility.calculateTime(0)
                  });
               }
            }
            switch(_additionalHeaderData.length)
            {
               case 0:
                  _partyPopup.gotoAndStop("header");
                  break;
               case 1:
                  _partyPopup.gotoAndStop("twoHeader");
                  break;
               case 2:
                  _partyPopup.gotoAndStop("threeHeader");
            }
            _adventureHeaderMediaId = 2253;
            _loc7_ = 0;
            while(_loc7_ < _loc4_)
            {
               _partyDefIds[_loc7_] = int(param1[_loc5_]);
               if(_partyDefs[int(param1[_loc5_])])
               {
                  _loc2_ = int(_partyDefs[int(param1[_loc5_])].titleStrId);
                  if(!_loc3_[_loc2_])
                  {
                     _loc3_[_loc2_] = true;
                  }
                  _partyMediaIds[_loc7_] = int(_partyDefs[int(param1[_loc5_++])].mediaRefId);
                  _secToStart[_loc7_] = Number(param1[_loc5_++]);
                  if(_secToStart[_loc7_] != 0)
                  {
                     _secToStart[_loc7_] += _timeOffset;
                  }
                  _secToEnd[_loc7_] = Number(param1[_loc5_++]);
                  if(_secToStart[_loc7_] == 0 && _isInitialRequest)
                  {
                     GuiManager.showPartyBtnGlow(true);
                  }
               }
               _loc7_++;
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
               if(_requestedOnClick)
               {
                  buildPartyWindows();
               }
            }
         }
         _requestedOnClick = false;
      }
      
      private static function OnAddionalAdventureScriptDefLoaded(param1:int, param2:Array, param3:Object) : void
      {
         _additionalScriptDefs = param2;
         partyListResponse(param3);
      }
   }
}

