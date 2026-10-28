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
   import loader.DefPacksDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
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
      
      private static var _timeOffset:int;
      
      private static var _requestedOnClick:Boolean;
      
      private static var _hasCreatedPartyPopup:Boolean;
      
      public static const RESTRICTIONS_NONE:int = 0;
      
      public static const RESTRICTIONS_AVATAR:int = 1;
      
      public static const RESTRICTIONS_MEMBERONLY:int = 2;
      
      public static const RESTRICTIONS_PET:int = 4;
      
      public static const RESTRICTIONS_BEYOURPET:int = 8;
      
      private static const REQUEST_INTERVAL:Number = 10000;
      
      private static const PARTY_BARRIER_MEDIA_ID:int = 1299;
      
      public function PartyManager()
      {
         super();
      }
      
      public static function init(initXPos:int, initYPos:int) : void
      {
         _xPos = initXPos;
         _yPos = initYPos;
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
            _partyPopup.visible = true;
         }
         if(Boolean(_partyDefIds))
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
         if(Boolean(GuiManager.mainHud.partyBtn))
         {
            GuiManager.mainHud.partyBtn.downToUpState();
         }
         _partyPopup.visible = false;
         destroyPartyWindows();
         if(Boolean(_partyBarrier))
         {
            DarkenManager.unDarken(_partyBarrier);
         }
      }
      
      public static function get visible() : Boolean
      {
         if(Boolean(_partyPopup))
         {
            return _partyPopup.visible;
         }
         return false;
      }
      
      public static function updateTime() : void
      {
         var now:Number = NaN;
         if(_listBuilt)
         {
            now = getTimer();
            if(now - _initialTime >= REQUEST_INTERVAL)
            {
               _initialTime = getTimer();
               onTimer();
            }
         }
      }
      
      public static function isBeYourPetParty() : Boolean
      {
         var currPartyDef:Object = null;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_PARTY)
         {
            currPartyDef = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(currPartyDef != null && currPartyDef.restrictions == RESTRICTIONS_BEYOURPET)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function canSwitchToAvatar(avt:Avatar, displayBarrier:Boolean = false) : Boolean
      {
         var currPartyDef:Object = null;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_PARTY)
         {
            currPartyDef = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(currPartyDef != null)
            {
               if(currPartyDef.restrictions == RESTRICTIONS_AVATAR)
               {
                  if((currPartyDef.avatarDefFlags & 1 << avt.avTypeId - 1) == 0)
                  {
                     if(displayBarrier)
                     {
                        showPartyBarrier(true);
                     }
                     return false;
                  }
               }
               else if(currPartyDef.restrictions == RESTRICTIONS_PET)
               {
                  if(!PetManager.checkIfHasPet(avt.enviroTypeFlag))
                  {
                     if(displayBarrier)
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
      
      public static function canSwitchPet(displayBarrier:Boolean = false) : Boolean
      {
         var currPartyDef:Object = null;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_PARTY)
         {
            currPartyDef = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(currPartyDef != null && (currPartyDef.restrictions == RESTRICTIONS_PET || currPartyDef.restrictions == RESTRICTIONS_BEYOURPET))
            {
               if(displayBarrier)
               {
                  showPartyBarrier(true);
               }
               return false;
            }
         }
         return true;
      }
      
      public static function showPartyBarrier(isTryingToSwitch:Boolean = false, doesNotHaveRequiredPet:Boolean = false, secondaryDefId:int = -1) : void
      {
         var currPartyDef:Object = null;
         if(secondaryDefId == -1)
         {
            secondaryDefId = int(gMainFrame.clientInfo.secondaryDefId);
         }
         if(Boolean(_partyBarrier))
         {
            currPartyDef = _partyDefs[secondaryDefId];
            if(currPartyDef != null)
            {
               if(int(currPartyDef.restrictions) == RESTRICTIONS_PET || int(currPartyDef.restrictions) == RESTRICTIONS_BEYOURPET)
               {
                  setupBarrierTextForPets({
                     "isTryingToSwitch":isTryingToSwitch,
                     "doesNotHaveRequiredPet":doesNotHaveRequiredPet
                  });
               }
               else
               {
                  onAvatarNameLocalization(currPartyDef.avatarDefId,isTryingToSwitch);
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(PARTY_BARRIER_MEDIA_ID,onMediaItemLoaded,{
               "isTryingToSwitch":isTryingToSwitch,
               "doesNotHaveRequiredPet":doesNotHaveRequiredPet,
               "secondaryDefId":secondaryDefId
            });
         }
      }
      
      public static function getPartyDef(partyDefId:int) : Object
      {
         return _partyDefs[partyDefId];
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
         if(_useHeaderParty)
         {
            while(_partyPopup.itemWindowHeader.numChildren > 1)
            {
               _partyPopup.itemWindowHeader.removeChildAt(0);
            }
            while(_partyPopup.itemWindowHeader2.numChildren > 1)
            {
               _partyPopup.itemWindowHeader2.removeChildAt(0);
            }
         }
         _partyPopup.x = _xPos;
         _partyPopup.y = _yPos + 304 * 0.5;
         if(_useHeaderParty)
         {
            _partyPopup.y -= 64;
         }
         else
         {
            _partyPopup.y -= 32;
         }
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
         _partyPopup.visible = true;
         _hasCreatedPartyPopup = true;
      }
      
      private static function buildPartyWindows() : void
      {
         var headerTime:Object = null;
         if(Boolean(_scrollButtons))
         {
            _scrollButtons.destroy();
            _scrollButtons = null;
         }
         if(Boolean(_itemWindows))
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(Boolean(_headerWindow))
         {
            _headerWindow.destroy();
            _headerWindow = null;
         }
         if(_useHeaderParty)
         {
            headerTime = Utility.calculateTime(_headerSecToStart);
            _headerMins = headerTime.mins;
            _headerHours = headerTime.hours;
            _headerWindow = new ItemWindowParty(onHeaderLoaded,null,"",0,headerWinMouseDown,null,null,null,{"mediaRefId":[_partyHeaderMediaId]});
         }
         if(Boolean(_adventureHeaderWindow))
         {
            _adventureHeaderWindow.destroy();
            _adventureHeaderWindow = null;
         }
         _adventureHeaderWindow = new ItemWindowParty(onHeaderTwoLoaded,null,"",0,adventureHeaderMouseDown,null,null,null,{"mediaRefId":[_adventureHeaderMediaId]});
         calculateTime();
         var numItemsInCurrentArray:int = int(_partyDefIds.length);
         if(numItemsInCurrentArray <= 0)
         {
            _loadingSpiral.visible = false;
            return;
         }
         _itemWindows = new WindowGenerator();
         _itemWindows.init(1,numItemsInCurrentArray,numItemsInCurrentArray,0,0,0,ItemWindowParty,null,"",{"mouseDown":winMouseDown},{"mediaRefId":_partyMediaIds},onItemWindowsCreated);
      }
      
      private static function destroyPartyWindows() : void
      {
         if(Boolean(_scrollButtons))
         {
            _scrollButtons.destroy();
            _scrollButtons = null;
         }
         if(Boolean(_itemWindows))
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(Boolean(_headerWindow))
         {
            _headerWindow.destroy();
            _headerWindow = null;
         }
         if(Boolean(_adventureHeaderWindow))
         {
            _adventureHeaderWindow.destroy();
            _adventureHeaderWindow = null;
         }
      }
      
      private static function onItemWindowsCreated() : void
      {
         var mc:MovieClip = null;
         var numItemsInCurrentArray:int = int(_partyDefIds.length);
         for(var i:int = 0; i < numItemsInCurrentArray; i++)
         {
            mc = MovieClip(_itemWindows.bg.getChildAt(i));
            mc.defId = int(_partyDefs[_partyDefIds[i]].id);
            mc.setupTextAndAnims(_secToStart[i],_secToStart[i] > 0 ? calculatePrintTime(i) : "");
            mc.titleText = _partyDefs[_partyDefIds[i]].titleStrId;
         }
         _loadingSpiral.visible = false;
         _partyPopup.itemWindow.addChild(_itemWindows);
         _scrollButtons = new SBScrollbar();
         _scrollButtons.init(_itemWindows,270,160,0,"scrollbar2",53,0,_partyDefIds.length * 53.1);
         _initialTime = getTimer();
         _listBuilt = true;
      }
      
      private static function onHeaderLoaded(window:MovieClip, index:int = -1) : void
      {
         _headerWindow.defId = _partyHeaderDef;
         _headerWindow.setupTextAndAnims(_headerSecToStart,_headerSecToStart > 0 ? Utility.calculatePrintTime(_headerMins,_headerHours) : "");
         _headerWindow.titleText = _partyDefs[_partyHeaderDef].titleStrId;
         _headerLoadingSpiral.visible = false;
         _partyPopup.itemWindowHeader2.addChild(_headerWindow);
      }
      
      private static function onHeaderTwoLoaded(window:MovieClip, index:int = -1) : void
      {
         _adventureHeaderWindow.setupTextAndAnims(0,"");
         _partyPopup.itemWindowHeader.addChild(_adventureHeaderWindow);
      }
      
      private static function calculateTime() : void
      {
         var time:Object = null;
         for(var i:int = 0; i < _secToStart.length; i++)
         {
            time = Utility.calculateTime(_secToStart[i]);
            _mins[i] = time.mins;
            _hours[i] = time.hours;
         }
      }
      
      private static function shouldRequestNewList() : Boolean
      {
         var now:Number = getTimer();
         if(now - _timeStampSinceLastRequest > REQUEST_INTERVAL)
         {
            _timeStampSinceLastRequest = now;
            return true;
         }
         return false;
      }
      
      private static function calculatePrintTime(index:int, showFullWords:Boolean = false) : String
      {
         return Utility.calculatePrintTime(_mins[index],_hours[index],showFullWords);
      }
      
      private static function winMouseDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var index:int = int(evt.currentTarget.index);
         if(_secToStart[index] - _timeOffset <= 0)
         {
            if(_secToEnd[index] <= (getTimer() - _initialTime) / 1000)
            {
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14777));
               _partyDefIds.splice(index,1);
               _partyMediaIds.splice(index,1);
               _secToStart.splice(index,1);
               _secToEnd.splice(index,1);
               _hours.splice(index,1);
               _mins.splice(index,1);
               rebuildList();
               return;
            }
            DarkenManager.showLoadingSpiral(true);
            PartyXtCommManager.sendJoinPartyRequest(evt.currentTarget.defId);
            close();
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14778,calculatePrintTime(index,true)));
         }
      }
      
      private static function headerWinMouseDown(evt:MouseEvent) : void
      {
         if(_headerSecToStart <= 0)
         {
            DarkenManager.showLoadingSpiral(true);
            PartyXtCommManager.sendJoinPartyRequest(evt.currentTarget.defId);
            close();
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14778,Utility.calculatePrintTime(_headerMins,_headerHours,true)));
         }
      }
      
      private static function adventureHeaderMouseDown(evt:MouseEvent) : void
      {
         DarkenManager.showLoadingSpiral(true);
         RoomXtCommManager.sendNonDenRoomJoinRequest("adventures.queststaging_0_360#" + RoomManagerWorld.instance.shardId);
      }
      
      private static function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function onCloseBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         close();
      }
      
      private static function onTimer() : void
      {
         var shouldRebuildList:Boolean = false;
         var currHours:int = 0;
         var currMins:int = 0;
         var mc:MovieClip = null;
         var windowAlive:Boolean = false;
         _numSecPassed += REQUEST_INTERVAL / 1000;
         for(var i:int = 0; i < _secToStart.length; i++)
         {
            currHours = int(_hours[i]);
            currMins = int(_mins[i]);
            if(currHours > 0 || currMins > 0)
            {
               _secToStart[i] -= REQUEST_INTERVAL / 1000;
               if(_secToStart[i] <= 0)
               {
                  currHours = 0;
                  currMins = 0;
               }
               else if(_numSecPassed == 60)
               {
                  if(currHours > 0 && currMins == 0)
                  {
                     currHours--;
                  }
                  if(currMins == 0)
                  {
                     currMins = 59;
                  }
                  else
                  {
                     currMins--;
                  }
               }
               _hours[i] = currHours;
               _mins[i] = currMins;
               windowAlive = Boolean(_itemWindows) && Boolean(_itemWindows.bg) && _itemWindows.bg.numChildren >= i;
               if(windowAlive)
               {
                  mc = MovieClip(_itemWindows.bg.getChildAt(i));
               }
               if(currHours > 0 || currMins > 0)
               {
                  if(windowAlive)
                  {
                     mc.setupTextAndAnims(_secToStart[i],calculatePrintTime(i));
                  }
               }
               else
               {
                  if(windowAlive)
                  {
                     mc.setupTextAndAnims(-1,"");
                  }
                  GuiManager.showPartyBtnGlow(true);
               }
            }
            else
            {
               _secToEnd[i] -= REQUEST_INTERVAL / 1000;
               if(_secToEnd[i] <= 0)
               {
                  GuiManager.showPartyBtnGlow(false);
                  shouldRebuildList = true;
                  _partyDefIds.splice(i,1);
                  _partyMediaIds.splice(i,1);
                  _secToStart.splice(i,1);
                  _secToEnd.splice(i,1);
                  _hours.splice(i,1);
                  _mins.splice(i,1);
                  i--;
               }
            }
         }
         if(_numSecPassed == 60)
         {
            _numSecPassed = 0;
         }
         if(shouldRebuildList)
         {
            _numSecPassed = 0;
            rebuildList();
         }
      }
      
      private static function rebuildList() : void
      {
         var titleStrId:int = 0;
         var uniqueTitleStrs:Array = [];
         _partyMediaIds = [];
         for(var i:int = 0; i < _partyDefIds.length; i++)
         {
            titleStrId = int(_partyDefs[_partyDefIds[i]].titleStrId);
            if(!uniqueTitleStrs[titleStrId])
            {
               uniqueTitleStrs[titleStrId] = true;
            }
            _partyMediaIds[i] = int(_partyDefs[_partyDefIds[i]].mediaRefId);
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
         var dpdh:DefPacksDefHelper = null;
         if(Boolean(_partyDefs))
         {
            requestPartyList();
         }
         else
         {
            dpdh = new DefPacksDefHelper();
            dpdh.init(DefPacksDefHelper.DEF_PARTY,onPartyDataResponse,null,FileServerEvent.AMF3_TYPE);
            DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PARTY] = dpdh;
         }
      }
      
      private static function onPartyDataResponse(dfdh:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PARTY] = null;
         _partyDefs = dfdh.def;
      }
      
      public static function requestPartyList() : void
      {
         _requestedOnClick = true;
         gMainFrame.server.setXtObject_Str("sl",[]);
      }
      
      public static function roomSoireeResponse(data:Object) : void
      {
         var msg:String = null;
         var i:int = 2;
         if(data[i++] == "0")
         {
            msg = data[i++];
            if(msg == "NM")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14779));
            }
            else if(msg == "NA")
            {
               showPartyBarrier(false,false,data[i++]);
            }
            else if(msg == "NP")
            {
               DarkenManager.showLoadingSpiral(false);
               showPartyBarrier(false,false,data[i++]);
            }
         }
      }
      
      private static function onMediaItemLoaded(img:MovieClip) : void
      {
         var currPartyDef:Object = null;
         if(Boolean(img))
         {
            _partyBarrier = MovieClip(img.getChildAt(0));
            _partyBarrier.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            _partyBarrier.bx.addEventListener(MouseEvent.MOUSE_DOWN,onBarrierClose,false,0,true);
            _partyBarrier.x = MainFrame.VIEW_WIDTH * 0.5;
            _partyBarrier.y = MainFrame.VIEW_HEIGHT * 0.5;
            _partyBarrier.visible = false;
            GuiManager.guiLayer.addChild(_partyBarrier);
            currPartyDef = _partyDefs[img.passback.secondaryDefId];
            if(currPartyDef != null)
            {
               if(int(currPartyDef.restrictions) == RESTRICTIONS_PET || int(currPartyDef.restrictions) == RESTRICTIONS_BEYOURPET)
               {
                  setupBarrierTextForPets(img.passback);
               }
               else
               {
                  onAvatarNameLocalization(currPartyDef.avatarDefId,img.passback.isTryingToSwitch);
               }
            }
         }
      }
      
      private static function onBarrierClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(_partyBarrier);
         _partyBarrier.visible = false;
      }
      
      private static function onAvatarNameLocalization(avatarDefId:int, passback:Object = null) : void
      {
         var frameName:String = "Avatar" + avatarDefId;
         var localizedAvatarName:String = LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(avatarDefId).titleStrRef);
         if(_partyBarrier.currentFrameLabel != frameName)
         {
            _partyBarrier.gotoAndStop(frameName);
         }
         localizedAvatarName = localizedAvatarName.toLowerCase();
         var currPluralAvName:String = _partyBarrier.titleTxt.text.split(" ")[0].toLowerCase();
         if(Boolean(passback))
         {
            LocalizationManager.translateIdAndInsert(_partyBarrier.Message_txt,11139,currPluralAvName);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_partyBarrier.Message_txt,11365,currPluralAvName,localizedAvatarName);
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(Boolean(passback))
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + frameName + "/member/switch");
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + frameName + "/member");
            }
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/barrier/#" + frameName + "/nonMember");
         }
         DarkenManager.showLoadingSpiral(false);
         _partyBarrier.parent.setChildIndex(_partyBarrier,_partyBarrier.parent.numChildren - 1);
         DarkenManager.darken(_partyBarrier);
         _partyBarrier.visible = true;
      }
      
      private static function setupBarrierTextForPets(passback:Object = null) : void
      {
         if(_partyBarrier.currentFrameLabel != "Pets")
         {
            _partyBarrier.gotoAndStop("Pets");
         }
         if(Boolean(passback))
         {
            if(Boolean(passback.doesNotHaveRequiredPet))
            {
               LocalizationManager.translateId(_partyBarrier.Message_txt,18790);
            }
            else
            {
               LocalizationManager.translateId(_partyBarrier.Message_txt,11407);
            }
         }
         else if(AvatarManager.roomEnviroType == Utility.ENVIRO_OCEAN)
         {
            LocalizationManager.translateId(_partyBarrier.Message_txt,11366);
         }
         else
         {
            LocalizationManager.translateId(_partyBarrier.Message_txt,11367);
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(Boolean(passback))
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
      
      public static function partyListResponse(data:Object) : void
      {
         var titleStrId:int = 0;
         var uniqueTitleStrs:Array = null;
         var numParties:int = 0;
         var j:int = 0;
         var i:int = 0;
         if(Boolean(_partyPopup))
         {
            _partyDefIds = [];
            _secToStart = [];
            _secToEnd = [];
            _partyMediaIds = [];
            uniqueTitleStrs = [];
            numParties = int(data[3]);
            j = 4;
            _partyHeaderDef = int(data[2]);
            _adventureHeaderMediaId = 2253;
            if(_useHeaderParty)
            {
               _partyPopup.gotoAndStop("twoHeader");
               if(Boolean(_partyDefs[_partyHeaderDef]))
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
            for(i = 0; i < numParties; i++)
            {
               _partyDefIds[i] = int(data[j]);
               if(Boolean(_partyDefs[int(data[j])]))
               {
                  titleStrId = int(_partyDefs[int(data[j])].titleStrId);
                  if(!uniqueTitleStrs[titleStrId])
                  {
                     uniqueTitleStrs[titleStrId] = true;
                  }
                  _partyMediaIds[i] = int(_partyDefs[int(data[j++])].mediaRefId);
                  _secToStart[i] = Number(data[j++]);
                  if(_secToStart[i] != 0)
                  {
                     _secToStart[i] += _timeOffset;
                  }
                  _secToEnd[i] = Number(data[j++]);
                  if(_secToStart[i] == 0 && _isInitialRequest)
                  {
                     GuiManager.showPartyBtnGlow(true);
                  }
               }
            }
            uniqueTitleStrs = null;
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
   }
}

