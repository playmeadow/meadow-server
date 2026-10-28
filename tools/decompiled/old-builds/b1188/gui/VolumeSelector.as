package gui
{
   import avatar.AvatarXtCommManager;
   import buddy.Buddy;
   import buddy.BuddyXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.loader.SceneLoader;
   import den.DenXtCommManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import game.MinigameManager;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import room.VolumeManager;
   
   public class VolumeSelector
   {
      
      public static const WORLD_MAP:int = 0;
      
      public static const DANGER_MAP:int = 1;
      
      private static const MAP_X:int = -309;
      
      private static const MAP_Y:int = 0;
      
      private static const TIME_BETWEEN_REQUESTS:int = 600000;
      
      private var _displayLayer:DisplayLayer;
      
      private var _guiLayer:DisplayObject;
      
      private var _worldMapScene:SceneLoader;
      
      private var _dangerMapScene:SceneLoader;
      
      private var _bShow:Boolean;
      
      private var _bIsLoaded:Boolean;
      
      private var _bDangerIsLoaded:Boolean;
      
      private var _volumeManager:VolumeManager;
      
      private var _debugLayer:Shape;
      
      private var _help_mc:MovieClip;
      
      private var _mcBtn:MovieClip;
      
      private var _zoneBtn:MovieClip;
      
      private var _currType:int;
      
      private var _buddyUserName:String;
      
      private var _worldMapFrame:MovieClip;
      
      private var _densLoadingSpiral:LoadingSpiral;
      
      private var _sortOptions:Object;
      
      private var _sortIcons:Object;
      
      private var _scrollBar:SBScrollbar;
      
      private var _epicDenWindows:WindowGenerator;
      
      private var _adventureWindows:WindowGenerator;
      
      private var _mousePos:Point;
      
      private var _bMouseDown:Boolean;
      
      private var _bCheckVolume:Boolean;
      
      private var _milliSecSinceLastListRequest:Number;
      
      private var _mapUpdateTimer:Timer;
      
      private var _worldMapload_callback:Function;
      
      private var _roomMgr:RoomManagerWorld;
      
      public function VolumeSelector()
      {
         super();
      }
      
      public function VolumeSelctor(param1:DisplayLayer) : void
      {
         this._displayLayer = new DisplayLayer();
         this._debugLayer = new Shape();
         this._guiLayer = param1;
         param1.addChild(this._displayLayer);
         this._worldMapScene = new SceneLoader();
         this._dangerMapScene = new SceneLoader();
         this._volumeManager = new VolumeManager();
         this._mousePos = new Point();
         this._milliSecSinceLastListRequest = 0;
         this._roomMgr = RoomManagerWorld.instance;
         this._mapUpdateTimer = new Timer(2000);
         this._mapUpdateTimer.addEventListener(TimerEvent.TIMER,this.mapUpdateTimer,false,0,true);
         RoomXtCommManager.roomCountResponseCallback = this.handleRoomCountResponse;
         this._displayLayer.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         this._displayLayer.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this._displayLayer.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.show(false,WORLD_MAP);
      }
      
      public function enable(param1:Boolean, param2:MovieClip = null, param3:MovieClip = null, param4:MovieClip = null) : void
      {
         if(param1)
         {
            this._help_mc = param4;
            this._mcBtn = param2;
            this._mcBtn.addEventListener(MouseEvent.CLICK,this.onMapButtonDown,false,0,true);
            this._zoneBtn = param3;
            this._zoneBtn.addEventListener(MouseEvent.CLICK,this.onMapButtonDown,false,0,true);
         }
         else
         {
            this._help_mc = null;
            if(this._mcBtn)
            {
               this._mcBtn.removeEventListener(MouseEvent.CLICK,this.onMapButtonDown);
               this._mcBtn = null;
            }
            if(this._zoneBtn)
            {
               this._zoneBtn.removeEventListener(MouseEvent.CLICK,this.onMapButtonDown);
               this._zoneBtn = null;
            }
         }
      }
      
      public function loadAssets(param1:Function) : void
      {
         this._worldMapload_callback = param1;
         this.loadWorldMapRoom();
      }
      
      public function loadDangerAssets() : void
      {
         this.loadDangerMapRoom();
      }
      
      public function destroy() : void
      {
         if(this._mapUpdateTimer)
         {
            this._mapUpdateTimer.reset();
            this._mapUpdateTimer.removeEventListener(TimerEvent.TIMER,this.mapUpdateTimer);
            this._mapUpdateTimer = null;
         }
         if(this._epicDenWindows)
         {
            this._epicDenWindows.destroy();
            this._epicDenWindows = null;
         }
         if(this._adventureWindows)
         {
            this._adventureWindows.destroy();
            this._adventureWindows = null;
         }
         RoomXtCommManager.roomCountResponseCallback = null;
      }
      
      public function get visible() : Boolean
      {
         return this._displayLayer.visible;
      }
      
      public function show(param1:Boolean, param2:int) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         this._currType = param2;
         if(param1)
         {
            SBTracker.push();
            if(param2 == WORLD_MAP)
            {
               this.setDisplayLayer(WORLD_MAP);
               SBTracker.trackPageview("/game/play/popup/worldmap");
            }
            else if(param2 == DANGER_MAP)
            {
               if(!this._bDangerIsLoaded)
               {
                  this.loadDangerMapRoom();
               }
               else
               {
                  this.setDisplayLayer(DANGER_MAP);
               }
               SBTracker.trackPageview("/game/play/popup/dangermap");
            }
         }
         this._bShow = param1;
         this._displayLayer.visible = param1;
         if(param1)
         {
            _loc3_ = this._displayLayer.parent;
            _loc3_.setChildIndex(this._displayLayer,int(_loc3_.numChildren - 1));
            if(param2 == WORLD_MAP)
            {
               this.updateRoomCount();
               this._mapUpdateTimer.start();
               this.setStar();
               this._worldMapFrame.advWindowTab.epicDenTab.visible = false;
               this._worldMapFrame.advWindowTab.advTab.visible = false;
            }
         }
         else
         {
            this._volumeManager.clearHold();
            this._mapUpdateTimer.reset();
            this.destroyDenAndAdventureWindows();
            if(this._sortIcons)
            {
               this._sortIcons.cinemaIcons.visible = false;
               this._sortIcons.petShopIcons.visible = false;
               this._sortIcons.shopIcons.visible = false;
               this._sortOptions.sortBtnCinema.mouse.visible = true;
               this._sortOptions.sortBtnCinema.down.visible = false;
               this._sortOptions.sortBtnCinema.btnOutHandler(null);
               this._sortOptions.sortBtnPetShop.mouse.visible = true;
               this._sortOptions.sortBtnPetShop.down.visible = false;
               this._sortOptions.sortBtnPetShop.btnOutHandler(null);
               this._sortOptions.sortBtnShop.mouse.visible = true;
               this._sortOptions.sortBtnShop.down.visible = false;
               this._sortOptions.sortBtnShop.btnOutHandler(null);
            }
         }
         if(Boolean(param2 == WORLD_MAP) && Boolean(this._sortIcons) && this._bShow)
         {
            this._sortIcons.denBtn.visible = gMainFrame.server.getCurrentRoomName().slice(3) != gMainFrame.server.userName;
         }
         this._bCheckVolume = false;
         this._bMouseDown = false;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(this._bShow && this._bCheckVolume)
         {
            _loc2_ = this._volumeManager.testMouseVolumes(this._mousePos,this._bMouseDown,this.checkSortOptions);
            if(_loc2_ != null && _loc2_.message != null)
            {
               if(_loc2_.message.length > 0)
               {
                  _loc3_ = _loc2_.message.toLowerCase();
                  if(this._currType == WORLD_MAP)
                  {
                     if(_loc3_ == "home")
                     {
                        this.gotoHome();
                     }
                     else if(_loc3_ != "close")
                     {
                        this.gotoRoom(_loc2_.message);
                     }
                     else
                     {
                        SBTracker.pop();
                     }
                     if(!GuiManager.mainHud.swapBtn.isGray || QuestManager.isInPrivateAdventureState)
                     {
                        this.show(false,WORLD_MAP);
                     }
                  }
                  else if(this._currType == DANGER_MAP)
                  {
                     if(_loc3_ == "close")
                     {
                        this.show(false,DANGER_MAP);
                     }
                     else
                     {
                        GenericListXtCommManager.requestGenericList(17);
                     }
                  }
               }
            }
            this._bMouseDown = false;
            this._bCheckVolume = false;
         }
      }
      
      private function checkSortOptions(param1:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Array = param1.split("%");
         param1 = _loc2_[1];
         if(param1 != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               param1 = _loc2_[_loc3_];
               if(param1 != null && param1 != "")
               {
                  if(param1 == this._sortIcons.cinemaIcons.name.toLowerCase() && Boolean(this._sortIcons.cinemaIcons.visible))
                  {
                     return false;
                  }
                  if(param1 == this._sortIcons.petShopIcons.name.toLowerCase() && Boolean(this._sortIcons.petShopIcons.visible))
                  {
                     return false;
                  }
                  if(param1 == this._sortIcons.shopIcons.name.toLowerCase() && Boolean(this._sortIcons.shopIcons.visible))
                  {
                     return false;
                  }
               }
               _loc3_++;
            }
         }
         return true;
      }
      
      private function gotoRoom(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            throw new Error("ERROR: Invalid room name:" + param1);
         }
         param1 = param1.toLowerCase() + "#" + this._roomMgr.shardId;
         if(param1 != gMainFrame.server.getCurrentRoomName())
         {
            DarkenManager.showLoadingSpiral(true);
            RoomXtCommManager.sendRoomJoinRequest(param1);
         }
      }
      
      private function gotoHome() : void
      {
         if(gMainFrame.server.getCurrentRoomName().slice(3) == gMainFrame.server.userName)
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         DenXtCommManager.requestDenJoinFull("den" + gMainFrame.userInfo.myUserName);
      }
      
      private function onMapButtonDown(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Buddy = null;
         if(!param1.currentTarget.isGray)
         {
            if(!MinigameManager.inMinigame())
            {
               if(this._worldMapScene.isValid)
               {
                  _loc2_ = gMainFrame.server.getCurrentRoomName();
                  if(param1.currentTarget == this._zoneBtn && _loc2_.indexOf("den") == 0)
                  {
                     _loc3_ = _loc2_.substr(3,_loc2_.length);
                     if(_loc3_ != gMainFrame.userInfo.myUserName)
                     {
                        if(!BuddyList.listRequested)
                        {
                           this._buddyUserName = _loc3_;
                           BuddyXtCommManager.sendBuddyListRequest(this.onBuddyListLoaded);
                           return;
                        }
                        _loc4_ = BuddyManager.getBuddyByUserName(_loc3_);
                        if(_loc4_)
                        {
                           BuddyCard.showBuddyCard({
                              "userName":_loc4_.userName,
                              "onlineStatus":_loc4_.onlineStatus
                           });
                           return;
                        }
                        AvatarXtCommManager.requestAvatarGet(_loc3_,this.onUserLookUpReceived,true);
                        return;
                     }
                  }
                  if(this._help_mc)
                  {
                     this._help_mc.visible = false;
                  }
                  this.show(!this._bShow,WORLD_MAP);
               }
               else if(this._dangerMapScene.isValid)
               {
                  this.show(!this._bShow,DANGER_MAP);
               }
            }
         }
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         if(param2)
         {
            BuddyCard.showBuddyCard({
               "userName":param1,
               "onlineStatus":param3
            });
         }
      }
      
      private function onBuddyListLoaded() : void
      {
         var _loc1_:Buddy = null;
         if(this._buddyUserName != gMainFrame.userInfo.myUserName)
         {
            _loc1_ = BuddyManager.getBuddyByUserName(this._buddyUserName);
            if(_loc1_)
            {
               BuddyCard.showBuddyCard({
                  "userName":_loc1_.userName,
                  "onlineStatus":_loc1_.onlineStatus
               });
               return;
            }
            AvatarXtCommManager.requestAvatarGet(this._buddyUserName,this.onUserLookUpReceived,true);
            return;
         }
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         this._mousePos.x = param1.stageX;
         this._mousePos.y = param1.stageY;
         this._bCheckVolume = true;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._mousePos.x = param1.stageX;
         this._mousePos.y = param1.stageY;
         this._bCheckVolume = true;
         this._bMouseDown = true;
      }
      
      private function loadWorldMapRoom() : void
      {
         if(!this._bIsLoaded)
         {
            this._bIsLoaded = true;
            LoadProgress.load(gMainFrame.clientInfo.worldMapRoom,LoadProgress.LOADING_WORLDMAP,this.onWorldMapRoomLoaded);
         }
         else if(this._worldMapload_callback != null)
         {
            this._worldMapload_callback();
         }
      }
      
      private function loadDangerMapRoom() : void
      {
         if(!this._bDangerIsLoaded)
         {
            this._bDangerIsLoaded = true;
            LoadProgress.load(gMainFrame.clientInfo.dangerMapRoom,1,this.onDangerMapRoomLoaded);
         }
      }
      
      private function onWorldMapRoomLoaded() : void
      {
         var _loc1_:Object = LoadProgress.entry.data;
         if(this._worldMapScene == null)
         {
            throw "error loading world map";
         }
         this._worldMapScene.setScene(_loc1_);
         this._worldMapScene.addEventListener(Event.COMPLETE,this.sceneAssetsLoaded);
      }
      
      private function onDangerMapRoomLoaded() : void
      {
         var _loc1_:Object = LoadProgress.entry.data;
         if(this._dangerMapScene == null)
         {
            throw "error loading danger map";
         }
         this._dangerMapScene.setScene(_loc1_);
         this._dangerMapScene.addEventListener(Event.COMPLETE,this.sceneAssetsLoaded);
      }
      
      private function sceneAssetsLoaded(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:SceneLoader = null;
         var _loc9_:Array = null;
         var _loc10_:Graphics = null;
         var _loc11_:Object = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:MovieClip = null;
         _loc5_ = SceneLoader(param1.currentTarget);
         _loc5_.removeEventListener(Event.COMPLETE,this.sceneAssetsLoaded);
         var _loc6_:Array = _loc5_.getActorList("ActorLayer");
         while(this._displayLayer.numChildren > 0)
         {
            this._displayLayer.removeChildAt(0);
         }
         this._displayLayer.x = 0;
         this._displayLayer.y = 0;
         var _loc7_:Point = _loc5_.getOffset(this._displayLayer);
         _loc7_.x = MAP_X - _loc7_.x;
         _loc7_.y = MAP_Y - _loc7_.y;
         this._displayLayer.x = _loc7_.x;
         this._displayLayer.y = _loc7_.y;
         _loc2_ = 0;
         while(_loc2_ < _loc6_.length)
         {
            _loc4_ = _loc6_[_loc2_];
            this._displayLayer.addChild(_loc4_.s);
            if(_loc4_.s.content)
            {
               LocalizationManager.findAllTextfields(_loc4_.s.content);
            }
            _loc2_++;
         }
         this._displayLayer.addChild(this._debugLayer);
         _loc7_.x = -_loc7_.x;
         _loc7_.y = -_loc7_.y;
         this._volumeManager.setScene(_loc5_,_loc7_);
         if(0)
         {
            _loc9_ = _loc5_.getActorList("ActorVolume");
            _loc10_ = this._debugLayer.graphics;
            _loc10_.clear();
            _loc10_.lineStyle(2,255);
            _loc2_ = 0;
            while(_loc2_ < _loc9_.length)
            {
               _loc4_ = _loc9_[_loc2_];
               _loc3_ = 0;
               while(_loc3_ < _loc4_.points.length)
               {
                  _loc11_ = _loc4_.points[_loc3_];
                  if(_loc3_ == 0)
                  {
                     _loc10_.moveTo(_loc11_.x,_loc11_.y);
                  }
                  else
                  {
                     _loc10_.lineTo(_loc11_.x,_loc11_.y);
                  }
                  _loc3_++;
               }
               _loc2_++;
            }
         }
         this.zeroOutRoomCount();
         this._sortOptions = _loc5_.getLayer("sortOptions");
         this._sortIcons = _loc5_.getLayer("sortIcons");
         if(this._sortOptions)
         {
            this._sortOptions = this._sortOptions.loader.content.getChildAt(0);
            this._sortOptions.sortBtnCinema.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortOptions,false,0,true);
            this._sortOptions.sortBtnPetShop.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortOptions,false,0,true);
            this._sortOptions.sortBtnShop.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortOptions,false,0,true);
         }
         if(this._sortIcons)
         {
            this._sortIcons = this._sortIcons.loader.content.getChildAt(0);
            this._sortIcons.denBtn = this._sortIcons.parent.denBtn;
            this._sortIcons.denBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDenBtn,false,0,true);
            this._sortIcons.cinemaIcons.visible = false;
            this._sortIcons.petShopIcons.visible = false;
            this._sortIcons.shopIcons.visible = false;
            _loc12_ = this._sortIcons.cinemaIcons.numChildren + this._sortIcons.petShopIcons.numChildren + this._sortIcons.shopIcons.numChildren;
            _loc3_ = 0;
            _loc2_ = 0;
            while(_loc2_ < _loc12_)
            {
               _loc15_ = null;
               if(_loc2_ < this._sortIcons.cinemaIcons.numChildren)
               {
                  _loc15_ = MovieClip(this._sortIcons.cinemaIcons.getChildAt(_loc2_));
                  _loc13_++;
               }
               else if(_loc2_ < _loc13_ + this._sortIcons.petShopIcons.numChildren)
               {
                  _loc15_ = MovieClip(this._sortIcons.petShopIcons.getChildAt(_loc3_));
                  _loc3_++;
               }
               else
               {
                  _loc15_ = MovieClip(this._sortIcons.shopIcons.getChildAt(_loc14_));
                  _loc14_++;
               }
               if(_loc15_)
               {
                  _loc15_.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortIcon,false,0,true);
                  _loc15_.addEventListener(MouseEvent.MOUSE_OVER,this.onSortIconOver,false,0,true);
                  _loc15_.addEventListener(MouseEvent.MOUSE_OUT,this.onSortIconOut,false,0,true);
               }
               _loc2_++;
            }
         }
         var _loc8_:Object = _loc5_.getLayer("worldMapFrame");
         if(_loc8_)
         {
            this._worldMapFrame = MovieClip(_loc8_.loader.content.getChildAt(0));
            this._worldMapFrame.addEventListener(MouseEvent.MOUSE_DOWN,this.onPullOutPopup,false,0,true);
            this._worldMapFrame.addEventListener(MouseEvent.MOUSE_OVER,this.onPullOutPopupOver,false,0,true);
            this._worldMapFrame.addEventListener(MouseEvent.MOUSE_OUT,this.onPullOutPopupOut,false,0,true);
            this._worldMapFrame.advWindowTab.advTab.addEventListener(MouseEvent.MOUSE_DOWN,this.onAdvTab,false,0,true);
            this._worldMapFrame.advWindowTab.advTab.addEventListener(MouseEvent.MOUSE_OVER,this.onAdvTabOver,false,0,true);
            this._worldMapFrame.advWindowTab.advTab.addEventListener(MouseEvent.MOUSE_OUT,this.onTabOut,false,0,true);
            this._worldMapFrame.advWindowTab.advTab.visible = false;
            this._worldMapFrame.advWindowTab.downAdvTab.addEventListener(MouseEvent.MOUSE_DOWN,this.onAdvTab,false,0,true);
            this._worldMapFrame.advWindowTab.downAdvTab.addEventListener(MouseEvent.MOUSE_OVER,this.onAdvTabOver,false,0,true);
            this._worldMapFrame.advWindowTab.downAdvTab.addEventListener(MouseEvent.MOUSE_OUT,this.onTabOut,false,0,true);
            this._worldMapFrame.advWindowTab.epicDenTab.addEventListener(MouseEvent.MOUSE_DOWN,this.onEpicDenTab,false,0,true);
            this._worldMapFrame.advWindowTab.epicDenTab.addEventListener(MouseEvent.MOUSE_OVER,this.onEpicDenTabOver,false,0,true);
            this._worldMapFrame.advWindowTab.epicDenTab.addEventListener(MouseEvent.MOUSE_OUT,this.onTabOut,false,0,true);
            this._worldMapFrame.advWindowTab.epicDenTab.visible = false;
            this._worldMapFrame.advWindowTab.downEpicDenTab.addEventListener(MouseEvent.MOUSE_DOWN,this.onEpicDenTab,false,0,true);
            this._worldMapFrame.advWindowTab.downEpicDenTab.addEventListener(MouseEvent.MOUSE_OVER,this.onEpicDenTabOver,false,0,true);
            this._worldMapFrame.advWindowTab.downEpicDenTab.addEventListener(MouseEvent.MOUSE_OUT,this.onTabOut,false,0,true);
            this._densLoadingSpiral = new LoadingSpiral(this._worldMapFrame.advWindowTab.itemWindow,this._worldMapFrame.advWindowTab.itemWindow.width * 0.5,this._worldMapFrame.advWindowTab.itemWindow.height * 0.5);
         }
         if(this._worldMapload_callback != null)
         {
            this._worldMapload_callback();
            this._worldMapload_callback = null;
         }
         else
         {
            LoadProgress.show(false);
         }
      }
      
      private function setDisplayLayer(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         var _loc4_:Point = null;
         var _loc5_:SceneLoader = null;
         while(this._displayLayer.numChildren > 0)
         {
            this._displayLayer.removeChildAt(0);
         }
         this._displayLayer.x = 0;
         this._displayLayer.y = 0;
         if(param1 == WORLD_MAP)
         {
            _loc5_ = this._worldMapScene;
         }
         else if(param1 == DANGER_MAP)
         {
            _loc5_ = this._dangerMapScene;
         }
         _loc3_ = _loc5_.getActorList("ActorLayer");
         _loc4_ = _loc5_.getOffset(this._displayLayer);
         _loc4_.x = MAP_X - _loc4_.x;
         _loc4_.y = MAP_Y - _loc4_.y;
         this._displayLayer.x = _loc4_.x;
         this._displayLayer.y = _loc4_.y;
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc6_];
            this._displayLayer.addChild(_loc2_.s);
            if(_loc2_.s.content)
            {
               LocalizationManager.findAllTextfields(_loc2_.s.content);
            }
            _loc6_++;
         }
         _loc4_.x = -_loc4_.x;
         _loc4_.y = -_loc4_.y;
         this._volumeManager.setScene(_loc5_,_loc4_);
      }
      
      private function createDenWindows(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(this._scrollBar)
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         if(this._epicDenWindows)
         {
            this._epicDenWindows.destroy();
            this._epicDenWindows = null;
         }
         if(param1)
         {
            _loc2_ = Math.min(param1.length,20);
            this._epicDenWindows = new WindowGenerator();
            this._epicDenWindows.init(1,_loc2_,_loc2_,0,3,0,ItemWindowTextBar,param1,"",{"mouseDown":this.winMouseDown},null,null,false,false);
            this._densLoadingSpiral.visible = false;
            while(this._worldMapFrame.advWindowTab.itemWindow.numChildren > 2)
            {
               this._worldMapFrame.advWindowTab.itemWindow.removeChildAt(this._worldMapFrame.advWindowTab.itemWindow.numChildren - 1);
            }
            this._worldMapFrame.advWindowTab.itemWindow.addChild(this._epicDenWindows);
            this._scrollBar = new SBScrollbar();
            this._scrollBar.init(this._epicDenWindows,267,396,3,"scrollbar2",36);
         }
      }
      
      private function createAdventureWindows() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(this._adventureWindows)
         {
            while(this._worldMapFrame.advWindowTab.itemWindow.numChildren > 2)
            {
               this._worldMapFrame.advWindowTab.itemWindow.removeChildAt(this._worldMapFrame.advWindowTab.itemWindow.numChildren - 1);
            }
            this._worldMapFrame.advWindowTab.itemWindow.addChild(this._adventureWindows);
            if(this._scrollBar)
            {
               this._scrollBar.destroy();
            }
            this._scrollBar = new SBScrollbar();
            this._scrollBar.init(this._adventureWindows,267,390,3,"scrollbar2",54);
         }
         else
         {
            this._densLoadingSpiral.visible = true;
            _loc1_ = QuestManager.getAvailableScriptDefs(this.createAdventureWindows);
            if(_loc1_ != null)
            {
               if(this._scrollBar)
               {
                  this._scrollBar.destroy();
                  this._scrollBar = null;
               }
               if(this._adventureWindows)
               {
                  this._adventureWindows.destroy();
                  this._adventureWindows = null;
               }
               _loc2_ = Math.min(_loc1_.length,20);
               this._adventureWindows = new WindowGenerator();
               this._adventureWindows.init(1,_loc2_,_loc2_,0,3,0,ItemWindowAdventure,null,"",{"mouseDown":this.adventureMouseDown},{"scriptIds":_loc1_},this.onAdventureWindowsLoaded,false,false);
            }
         }
      }
      
      private function onAdventureWindowsLoaded() : void
      {
         this._densLoadingSpiral.visible = false;
         while(this._worldMapFrame.advWindowTab.itemWindow.numChildren > 2)
         {
            this._worldMapFrame.advWindowTab.itemWindow.removeChildAt(this._worldMapFrame.advWindowTab.itemWindow.numChildren - 1);
         }
         this._worldMapFrame.advWindowTab.itemWindow.addChild(this._adventureWindows);
         this._scrollBar = new SBScrollbar();
         this._scrollBar.init(this._adventureWindows,267,393,3,"scrollbar2",55.5);
      }
      
      private function destroyDenAndAdventureWindows() : void
      {
         if(this._scrollBar)
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         if(this._epicDenWindows)
         {
            this._epicDenWindows.destroy();
            this._epicDenWindows = null;
         }
         if(this._adventureWindows)
         {
            this._adventureWindows.destroy();
            this._adventureWindows = null;
         }
         if(this._worldMapFrame)
         {
            while(this._worldMapFrame.advWindowTab.itemWindow.numChildren > 2)
            {
               this._worldMapFrame.advWindowTab.itemWindow.removeChildAt(this._worldMapFrame.advWindowTab.itemWindow.numChildren - 1);
            }
            this._worldMapFrame.advWindowTab.gotoAndStop("off");
         }
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(gMainFrame.server.getCurrentRoomName(false) != "den" + param1.currentTarget.txt.text)
         {
            DenXtCommManager.requestDenJoinFull("den" + param1.currentTarget.txt.text);
         }
         this.show(false,WORLD_MAP);
      }
      
      private function adventureMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Object = param1.currentTarget.performContinueChecks();
         if(_loc2_ != null)
         {
            this._worldMapFrame.advWindowTab.gotoAndPlay("close");
            this.destroyDenAndAdventureWindows();
            _loc2_.func(_loc2_.defId);
            _loc2_ = null;
            this._bShow = true;
         }
      }
      
      private function onEpicDenTab(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._worldMapFrame.advWindowTab.currentFrameLabel == "off")
         {
            this._worldMapFrame.advWindowTab.gotoAndPlay("open");
            this._worldMapFrame.advWindowTab.epicDenTab.visible = true;
            LocalizationManager.translateId(this._worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,8700);
            this.checkAndLoadEpicDenWindows();
         }
         else if(this._worldMapFrame.advWindowTab.currentFrameLabel == "on")
         {
            if(this._worldMapFrame.advWindowTab.advTab.visible)
            {
               this._worldMapFrame.advWindowTab.advTab.visible = false;
               this._worldMapFrame.advWindowTab.epicDenTab.visible = true;
               LocalizationManager.translateId(this._worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,8700);
               this.checkAndLoadEpicDenWindows();
            }
            else
            {
               this._worldMapFrame.advWindowTab.gotoAndPlay("close");
               this._worldMapFrame.advWindowTab.epicDenTab.visible = false;
            }
         }
      }
      
      private function onEpicDenTabOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(MovieClip(param1.currentTarget.parent.parent),LocalizationManager.translateIdOnly(15072),param1.currentTarget.width * 0.5 + param1.currentTarget.parent.x + param1.currentTarget.x,param1.currentTarget.parent.y + param1.currentTarget.y);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function checkAndLoadEpicDenWindows() : void
      {
         var _loc1_:Number = new Date().getTime();
         if(_loc1_ - this._milliSecSinceLastListRequest > TIME_BETWEEN_REQUESTS || this._epicDenWindows == null)
         {
            this._densLoadingSpiral.visible = true;
            this._milliSecSinceLastListRequest = _loc1_;
            DenXtCommManager.denHighestCallback = this.createDenWindows;
            DenXtCommManager.requestDenHighest();
         }
         else
         {
            while(this._worldMapFrame.advWindowTab.itemWindow.numChildren > 2)
            {
               this._worldMapFrame.advWindowTab.itemWindow.removeChildAt(this._worldMapFrame.advWindowTab.itemWindow.numChildren - 1);
            }
            this._worldMapFrame.advWindowTab.itemWindow.addChild(this._epicDenWindows);
            if(this._scrollBar)
            {
               this._scrollBar.destroy();
            }
            this._scrollBar = new SBScrollbar();
            this._scrollBar.init(this._epicDenWindows,267,396,3,"scrollbar2",36);
         }
      }
      
      private function onPullOutPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPullOutPopupOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._volumeManager.clearHold(false);
         this._bShow = false;
      }
      
      private function onPullOutPopupOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._bShow = true;
      }
      
      private function onAdvTab(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(this._worldMapFrame.advWindowTab.currentFrameLabel == "off")
            {
               this._worldMapFrame.advWindowTab.gotoAndPlay("open");
               this._worldMapFrame.advWindowTab.advTab.visible = true;
               LocalizationManager.translateId(this._worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,9797);
               this.createAdventureWindows();
            }
            else if(this._worldMapFrame.advWindowTab.currentFrameLabel == "on")
            {
               if(this._worldMapFrame.advWindowTab.epicDenTab.visible)
               {
                  this._worldMapFrame.advWindowTab.advTab.visible = true;
                  this._worldMapFrame.advWindowTab.epicDenTab.visible = false;
                  LocalizationManager.translateId(this._worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,9797);
                  this.createAdventureWindows();
               }
               else
               {
                  this._worldMapFrame.advWindowTab.gotoAndPlay("close");
                  this._worldMapFrame.advWindowTab.advTab.visible = false;
               }
            }
         }
      }
      
      private function onAdvTabOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(MovieClip(param1.currentTarget.parent.parent),LocalizationManager.translateIdOnly(15036),param1.currentTarget.width * 0.5 + param1.currentTarget.parent.x + param1.currentTarget.x,param1.currentTarget.parent.y + param1.currentTarget.y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onTabOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onSortOptions(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == "sortBtnShop")
         {
            this._sortIcons.cinemaIcons.visible = false;
            this._sortIcons.petShopIcons.visible = false;
            this._sortIcons.shopIcons.visible = !this._sortIcons.shopIcons.visible;
            if(this._sortIcons.shopIcons.visible)
            {
               param1.currentTarget.mouse.visible = false;
               param1.currentTarget.down.visible = true;
            }
            else
            {
               param1.currentTarget.mouse.visible = true;
               param1.currentTarget.down.visible = false;
            }
            this._sortOptions.sortBtnCinema.mouse.visible = true;
            this._sortOptions.sortBtnCinema.down.visible = false;
            this._sortOptions.sortBtnCinema.btnOutHandler(null);
            this._sortOptions.sortBtnPetShop.mouse.visible = true;
            this._sortOptions.sortBtnPetShop.down.visible = false;
            this._sortOptions.sortBtnPetShop.btnOutHandler(null);
         }
         else if(param1.currentTarget.name == "sortBtnCinema")
         {
            this._sortIcons.cinemaIcons.visible = !this._sortIcons.cinemaIcons.visible;
            this._sortIcons.petShopIcons.visible = false;
            this._sortIcons.shopIcons.visible = false;
            if(this._sortIcons.cinemaIcons.visible)
            {
               param1.currentTarget.mouse.visible = false;
               param1.currentTarget.down.visible = true;
            }
            else
            {
               param1.currentTarget.mouse.visible = true;
               param1.currentTarget.down.visible = false;
            }
            this._sortOptions.sortBtnPetShop.mouse.visible = true;
            this._sortOptions.sortBtnPetShop.down.visible = false;
            this._sortOptions.sortBtnPetShop.btnOutHandler(null);
            this._sortOptions.sortBtnShop.mouse.visible = true;
            this._sortOptions.sortBtnShop.down.visible = false;
            this._sortOptions.sortBtnShop.btnOutHandler(null);
         }
         else
         {
            this._sortIcons.cinemaIcons.visible = false;
            this._sortIcons.petShopIcons.visible = !this._sortIcons.petShopIcons.visible;
            this._sortIcons.shopIcons.visible = false;
            if(this._sortIcons.petShopIcons.visible)
            {
               param1.currentTarget.mouse.visible = false;
               param1.currentTarget.down.visible = true;
            }
            else
            {
               param1.currentTarget.mouse.visible = true;
               param1.currentTarget.down.visible = false;
            }
            this._sortOptions.sortBtnCinema.mouse.visible = true;
            this._sortOptions.sortBtnCinema.down.visible = false;
            this._sortOptions.sortBtnCinema.btnOutHandler(null);
            this._sortOptions.sortBtnShop.mouse.visible = true;
            this._sortOptions.sortBtnShop.down.visible = false;
            this._sortOptions.sortBtnShop.btnOutHandler(null);
         }
      }
      
      private function onSortIcon(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:String = param1.currentTarget.name.replace("$",".");
         var _loc3_:Array = _loc2_.split("$");
         if(_loc2_ != gMainFrame.server.getCurrentRoomName())
         {
            if(_loc3_.length == 2)
            {
               RoomManagerWorld.instance.setGotoSpawnPoint(_loc3_[1].toLowerCase());
            }
            this.gotoRoom(_loc3_[0]);
         }
      }
      
      private function onSortIconOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._volumeManager.clearHold(false);
         this._bShow = false;
      }
      
      private function onSortIconOut(param1:MouseEvent) : void
      {
         if(this.visible)
         {
            this._bShow = true;
         }
      }
      
      private function onDenBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.gotoHome();
      }
      
      private function mapUpdateTimer(param1:TimerEvent) : void
      {
         this.updateRoomCount();
      }
      
      private function updateRoomCount() : void
      {
         var _loc4_:Buddy = null;
         var _loc1_:Array = [];
         var _loc2_:Boolean = false;
         var _loc3_:Dictionary = BuddyManager.buddyList;
         for each(_loc4_ in _loc3_)
         {
            _loc2_ = true;
            if(_loc4_.isOnline)
            {
               _loc1_.push(_loc4_.userName);
            }
         }
         if(_loc2_)
         {
            RoomXtCommManager.sendRoomCountRequest(_loc1_);
         }
      }
      
      private function handleRoomCountResponse(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc2_:Dictionary = new Dictionary(true);
         var _loc3_:int = int(param1[2]);
         var _loc7_:int = 3;
         while(_loc7_ < _loc3_ + 3)
         {
            _loc4_ = param1[_loc7_];
            if(_loc4_ != "")
            {
               _loc5_ = int(_loc4_.slice(_loc4_.indexOf("#") + 1,_loc4_.length));
               if(_loc5_ == RoomManagerWorld.instance.shardId)
               {
                  _loc6_ = _loc4_.split(".");
                  if(_loc6_[0] == "oceans")
                  {
                     _loc4_ = _loc6_[1].slice(0,_loc6_[1].indexOf("#"));
                  }
                  else
                  {
                     _loc4_ = _loc6_[0];
                  }
                  if(_loc2_[_loc4_])
                  {
                     ++_loc2_[_loc4_];
                  }
                  else
                  {
                     _loc2_[_loc4_] = 1;
                  }
               }
            }
            _loc7_++;
         }
         this.zeroOutRoomCount();
         for(_loc9_ in _loc2_)
         {
            _loc8_ = this._worldMapScene.getLayer(_loc9_);
            if(_loc8_)
            {
               _loc8_.loader.content.buddy.buddyText.text = _loc2_[_loc9_];
            }
         }
      }
      
      private function zeroOutRoomCount() : void
      {
         var _loc1_:Object = null;
         if(this._worldMapScene.isValid)
         {
            _loc1_ = this._worldMapScene.getLayer("lost_temple_of_zios");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("jamaa_township");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("sarepia");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("crystal_sands");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("coral_canyons");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("mountains_of_shivveer");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("appondale");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("crystal_reef");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("bahari_bay");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("deep_sea");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("pirate_ship");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
            _loc1_ = this._worldMapScene.getLayer("aussie");
            if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
            {
               _loc1_.loader.content.buddy.buddyText.text = 0;
            }
         }
      }
      
      private function setStar() : void
      {
         var _loc1_:Object = null;
         _loc1_ = this._worldMapScene.getLayer("jamaa_township");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("lost_temple_of_zios");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("sarepia");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("crystal_sands");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("coral_canyons");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("mountains_of_shivveer");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("appondale");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("crystal_reef");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("bahari_bay");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("deep_sea");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("pirate_ship");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer("aussie");
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = false;
         }
         _loc1_ = this._worldMapScene.getLayer(gMainFrame.userInfo.worldMapRoomName);
         if(Boolean(_loc1_) && Boolean(_loc1_.loader) && Boolean(_loc1_.loader.content))
         {
            _loc1_.loader.content.star.visible = true;
         }
      }
   }
}

