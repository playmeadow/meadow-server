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
      
      public function VolumeSelctor(guiLayer:DisplayLayer) : void
      {
         this._displayLayer = new DisplayLayer();
         this._debugLayer = new Shape();
         this._guiLayer = guiLayer;
         guiLayer.addChild(this._displayLayer);
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
      
      public function enable(inEnable:Boolean, btn_mc:MovieClip = null, btn2_mc:MovieClip = null, help_mc:MovieClip = null) : void
      {
         if(inEnable)
         {
            this._help_mc = help_mc;
            this._mcBtn = btn_mc;
            this._mcBtn.addEventListener(MouseEvent.CLICK,this.onMapButtonDown,false,0,true);
            this._zoneBtn = btn2_mc;
            this._zoneBtn.addEventListener(MouseEvent.CLICK,this.onMapButtonDown,false,0,true);
         }
         else
         {
            this._help_mc = null;
            if(Boolean(this._mcBtn))
            {
               this._mcBtn.removeEventListener(MouseEvent.CLICK,this.onMapButtonDown);
               this._mcBtn = null;
            }
            if(Boolean(this._zoneBtn))
            {
               this._zoneBtn.removeEventListener(MouseEvent.CLICK,this.onMapButtonDown);
               this._zoneBtn = null;
            }
         }
      }
      
      public function loadAssets(callback:Function) : void
      {
         this._worldMapload_callback = callback;
         this.loadWorldMapRoom();
      }
      
      public function loadDangerAssets() : void
      {
         this.loadDangerMapRoom();
      }
      
      public function destroy() : void
      {
         if(Boolean(this._mapUpdateTimer))
         {
            this._mapUpdateTimer.reset();
            this._mapUpdateTimer.removeEventListener(TimerEvent.TIMER,this.mapUpdateTimer);
            this._mapUpdateTimer = null;
         }
         if(Boolean(this._epicDenWindows))
         {
            this._epicDenWindows.destroy();
            this._epicDenWindows = null;
         }
         if(Boolean(this._adventureWindows))
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
      
      public function show(bShow:Boolean, type:int) : void
      {
         var parent:DisplayObjectContainer = null;
         this._currType = type;
         if(bShow)
         {
            SBTracker.push();
            if(type == WORLD_MAP)
            {
               this.setDisplayLayer(WORLD_MAP);
               SBTracker.trackPageview("/game/play/popup/worldmap");
            }
            else if(type == DANGER_MAP)
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
         this._bShow = bShow;
         this._displayLayer.visible = bShow;
         if(bShow)
         {
            parent = this._displayLayer.parent;
            parent.setChildIndex(this._displayLayer,int(parent.numChildren - 1));
            if(type == WORLD_MAP)
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
            if(Boolean(this._sortIcons))
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
         this._bCheckVolume = false;
         this._bMouseDown = false;
      }
      
      private function onEnterFrame(e:Event) : void
      {
         var volume:Object = null;
         var msg:String = null;
         if(this._bShow && this._bCheckVolume)
         {
            volume = this._volumeManager.testMouseVolumes(this._mousePos,this._bMouseDown,this.checkSortOptions);
            if(volume != null && volume.message != null)
            {
               if(volume.message.length > 0)
               {
                  msg = volume.message.toLowerCase();
                  if(this._currType == WORLD_MAP)
                  {
                     if(msg == "home")
                     {
                        this.gotoHome();
                     }
                     else if(msg != "close")
                     {
                        this.gotoRoom(volume.message);
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
                     if(msg == "close")
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
      
      private function checkSortOptions(volumeName:String) : Boolean
      {
         var i:int = 0;
         var volumes:Array = volumeName.split("%");
         volumeName = volumes[1];
         if(volumeName != null)
         {
            for(i = 0; i < volumes.length; i++)
            {
               volumeName = volumes[i];
               if(volumeName != null && volumeName != "")
               {
                  if(volumeName == this._sortIcons.cinemaIcons.name.toLowerCase() && Boolean(this._sortIcons.cinemaIcons.visible))
                  {
                     return false;
                  }
                  if(volumeName == this._sortIcons.petShopIcons.name.toLowerCase() && Boolean(this._sortIcons.petShopIcons.visible))
                  {
                     return false;
                  }
                  if(volumeName == this._sortIcons.shopIcons.name.toLowerCase() && Boolean(this._sortIcons.shopIcons.visible))
                  {
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      private function gotoRoom(roomName:String) : void
      {
         if(roomName == null || roomName == "")
         {
            throw new Error("ERROR: Invalid room name:" + roomName);
         }
         roomName = roomName.toLowerCase() + "#" + this._roomMgr.shardId;
         if(roomName != gMainFrame.server.getCurrentRoomName())
         {
            DarkenManager.showLoadingSpiral(true);
            RoomXtCommManager.sendRoomJoinRequest(roomName);
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
      
      private function onMapButtonDown(e:MouseEvent) : void
      {
         var roomName:String = null;
         var userName:String = null;
         var bud:Buddy = null;
         if(!e.currentTarget.isGray)
         {
            if(!MinigameManager.inMinigame())
            {
               if(this._worldMapScene.isValid)
               {
                  roomName = gMainFrame.server.getCurrentRoomName();
                  if(e.currentTarget == this._zoneBtn && roomName.indexOf("den") == 0)
                  {
                     userName = roomName.substr(3,roomName.length);
                     if(userName != gMainFrame.userInfo.myUserName)
                     {
                        if(!BuddyList.listRequested)
                        {
                           this._buddyUserName = userName;
                           BuddyXtCommManager.sendBuddyListRequest(this.onBuddyListLoaded);
                           return;
                        }
                        bud = BuddyManager.getBuddyByUserName(userName);
                        if(Boolean(bud))
                        {
                           BuddyCard.showBuddyCard({
                              "userName":bud.userName,
                              "onlineStatus":bud.onlineStatus
                           });
                           return;
                        }
                        AvatarXtCommManager.requestAvatarGet(userName,this.onUserLookUpReceived,true);
                        return;
                     }
                  }
                  if(Boolean(this._help_mc))
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
      
      private function onUserLookUpReceived(userName:String, status:Boolean, onlineStatus:int) : void
      {
         if(status)
         {
            BuddyCard.showBuddyCard({
               "userName":userName,
               "onlineStatus":onlineStatus
            });
         }
      }
      
      private function onBuddyListLoaded() : void
      {
         var bud:Buddy = null;
         if(this._buddyUserName != gMainFrame.userInfo.myUserName)
         {
            bud = BuddyManager.getBuddyByUserName(this._buddyUserName);
            if(Boolean(bud))
            {
               BuddyCard.showBuddyCard({
                  "userName":bud.userName,
                  "onlineStatus":bud.onlineStatus
               });
               return;
            }
            AvatarXtCommManager.requestAvatarGet(this._buddyUserName,this.onUserLookUpReceived,true);
            return;
         }
      }
      
      private function onMouseMove(e:MouseEvent) : void
      {
         this._mousePos.x = e.stageX;
         this._mousePos.y = e.stageY;
         this._bCheckVolume = true;
      }
      
      private function onMouseDown(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._mousePos.x = e.stageX;
         this._mousePos.y = e.stageY;
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
         var scene:Object = LoadProgress.entry.data;
         if(this._worldMapScene == null)
         {
            throw "error loading world map";
         }
         this._worldMapScene.setScene(scene);
         this._worldMapScene.addEventListener(Event.COMPLETE,this.sceneAssetsLoaded);
      }
      
      private function onDangerMapRoomLoaded() : void
      {
         var scene:Object = LoadProgress.entry.data;
         if(this._dangerMapScene == null)
         {
            throw "error loading danger map";
         }
         this._dangerMapScene.setScene(scene);
         this._dangerMapScene.addEventListener(Event.COMPLETE,this.sceneAssetsLoaded);
      }
      
      private function sceneAssetsLoaded(e:Event) : void
      {
         var i:int = 0;
         var j:int = 0;
         var o:Object = null;
         var scene:SceneLoader = null;
         var volumes:Array = null;
         var g:Graphics = null;
         var pt:Object = null;
         var listLength:int = 0;
         var l:int = 0;
         var k:int = 0;
         var currIcon:MovieClip = null;
         scene = SceneLoader(e.currentTarget);
         scene.removeEventListener(Event.COMPLETE,this.sceneAssetsLoaded);
         var layers:Array = scene.getActorList("ActorLayer");
         while(this._displayLayer.numChildren > 0)
         {
            this._displayLayer.removeChildAt(0);
         }
         this._displayLayer.x = 0;
         this._displayLayer.y = 0;
         var offset:Point = scene.getOffset(this._displayLayer);
         offset.x = MAP_X - offset.x;
         offset.y = MAP_Y - offset.y;
         this._displayLayer.x = offset.x;
         this._displayLayer.y = offset.y;
         for(i = 0; i < layers.length; i++)
         {
            o = layers[i];
            this._displayLayer.addChild(o.s);
            if(Boolean(o.s.content))
            {
               LocalizationManager.findAllTextfields(o.s.content);
            }
         }
         this._displayLayer.addChild(this._debugLayer);
         offset.x = -offset.x;
         offset.y = -offset.y;
         this._volumeManager.setScene(scene,offset);
         if(Boolean(0))
         {
            volumes = scene.getActorList("ActorVolume");
            g = this._debugLayer.graphics;
            g.clear();
            g.lineStyle(2,255);
            for(i = 0; i < volumes.length; i++)
            {
               o = volumes[i];
               for(j = 0; j < o.points.length; j++)
               {
                  pt = o.points[j];
                  if(j == 0)
                  {
                     g.moveTo(pt.x,pt.y);
                  }
                  else
                  {
                     g.lineTo(pt.x,pt.y);
                  }
               }
            }
         }
         this.zeroOutRoomCount();
         this._sortOptions = scene.getLayer("sortOptions");
         this._sortIcons = scene.getLayer("sortIcons");
         if(Boolean(this._sortOptions))
         {
            this._sortOptions = this._sortOptions.loader.content.getChildAt(0);
            this._sortOptions.sortBtnCinema.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortOptions,false,0,true);
            this._sortOptions.sortBtnPetShop.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortOptions,false,0,true);
            this._sortOptions.sortBtnShop.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortOptions,false,0,true);
         }
         if(Boolean(this._sortIcons))
         {
            this._sortIcons = this._sortIcons.loader.content.getChildAt(0);
            this._sortIcons.cinemaIcons.visible = false;
            this._sortIcons.petShopIcons.visible = false;
            this._sortIcons.shopIcons.visible = false;
            listLength = this._sortIcons.cinemaIcons.numChildren + this._sortIcons.petShopIcons.numChildren + this._sortIcons.shopIcons.numChildren;
            j = 0;
            for(i = 0; i < listLength; i++)
            {
               currIcon = null;
               if(i < this._sortIcons.cinemaIcons.numChildren)
               {
                  currIcon = MovieClip(this._sortIcons.cinemaIcons.getChildAt(i));
                  l++;
               }
               else if(i < l + this._sortIcons.petShopIcons.numChildren)
               {
                  currIcon = MovieClip(this._sortIcons.petShopIcons.getChildAt(j));
                  j++;
               }
               else
               {
                  currIcon = MovieClip(this._sortIcons.shopIcons.getChildAt(k));
                  k++;
               }
               if(Boolean(currIcon))
               {
                  currIcon.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortIcon,false,0,true);
                  currIcon.addEventListener(MouseEvent.MOUSE_OVER,this.onSortIconOver,false,0,true);
                  currIcon.addEventListener(MouseEvent.MOUSE_OUT,this.onSortIconOut,false,0,true);
               }
            }
         }
         var worldMapFrame:Object = scene.getLayer("worldMapFrame");
         if(Boolean(worldMapFrame))
         {
            this._worldMapFrame = MovieClip(worldMapFrame.loader.content.getChildAt(0));
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
      
      private function setDisplayLayer(type:int) : void
      {
         var o:Object = null;
         var layers:Array = null;
         var offset:Point = null;
         var scene:SceneLoader = null;
         while(this._displayLayer.numChildren > 0)
         {
            this._displayLayer.removeChildAt(0);
         }
         this._displayLayer.x = 0;
         this._displayLayer.y = 0;
         if(type == WORLD_MAP)
         {
            scene = this._worldMapScene;
         }
         else if(type == DANGER_MAP)
         {
            scene = this._dangerMapScene;
         }
         layers = scene.getActorList("ActorLayer");
         offset = scene.getOffset(this._displayLayer);
         offset.x = MAP_X - offset.x;
         offset.y = MAP_Y - offset.y;
         this._displayLayer.x = offset.x;
         this._displayLayer.y = offset.y;
         for(var i:int = 0; i < layers.length; i++)
         {
            o = layers[i];
            this._displayLayer.addChild(o.s);
            if(Boolean(o.s.content))
            {
               LocalizationManager.findAllTextfields(o.s.content);
            }
         }
         offset.x = -offset.x;
         offset.y = -offset.y;
         this._volumeManager.setScene(scene,offset);
      }
      
      private function createDenWindows(denList:Array) : void
      {
         var numItemsInCurrentArray:int = 0;
         if(Boolean(this._scrollBar))
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         if(Boolean(this._epicDenWindows))
         {
            this._epicDenWindows.destroy();
            this._epicDenWindows = null;
         }
         if(Boolean(denList))
         {
            numItemsInCurrentArray = Math.min(denList.length,20);
            this._epicDenWindows = new WindowGenerator();
            this._epicDenWindows.init(1,numItemsInCurrentArray,numItemsInCurrentArray,0,3,0,ItemWindowTextBar,denList,"",{"mouseDown":this.winMouseDown},null,null,false,false);
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
         var scriptIds:Array = null;
         var numItemsInCurrentArray:int = 0;
         if(Boolean(this._adventureWindows))
         {
            while(this._worldMapFrame.advWindowTab.itemWindow.numChildren > 2)
            {
               this._worldMapFrame.advWindowTab.itemWindow.removeChildAt(this._worldMapFrame.advWindowTab.itemWindow.numChildren - 1);
            }
            this._worldMapFrame.advWindowTab.itemWindow.addChild(this._adventureWindows);
            if(Boolean(this._scrollBar))
            {
               this._scrollBar.destroy();
            }
            this._scrollBar = new SBScrollbar();
            this._scrollBar.init(this._adventureWindows,267,390,3,"scrollbar2",54);
         }
         else
         {
            this._densLoadingSpiral.visible = true;
            scriptIds = QuestManager.getAvailableScriptDefs(this.createAdventureWindows);
            if(scriptIds != null)
            {
               if(Boolean(this._scrollBar))
               {
                  this._scrollBar.destroy();
                  this._scrollBar = null;
               }
               if(Boolean(this._adventureWindows))
               {
                  this._adventureWindows.destroy();
                  this._adventureWindows = null;
               }
               numItemsInCurrentArray = Math.min(scriptIds.length,20);
               this._adventureWindows = new WindowGenerator();
               this._adventureWindows.init(1,numItemsInCurrentArray,numItemsInCurrentArray,0,3,0,ItemWindowAdventure,null,"",{"mouseDown":this.adventureMouseDown},{"scriptIds":scriptIds},this.onAdventureWindowsLoaded,false,false);
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
         if(Boolean(this._scrollBar))
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         if(Boolean(this._epicDenWindows))
         {
            this._epicDenWindows.destroy();
            this._epicDenWindows = null;
         }
         if(Boolean(this._adventureWindows))
         {
            this._adventureWindows.destroy();
            this._adventureWindows = null;
         }
         if(Boolean(this._worldMapFrame))
         {
            while(this._worldMapFrame.advWindowTab.itemWindow.numChildren > 2)
            {
               this._worldMapFrame.advWindowTab.itemWindow.removeChildAt(this._worldMapFrame.advWindowTab.itemWindow.numChildren - 1);
            }
            this._worldMapFrame.advWindowTab.gotoAndStop("off");
         }
      }
      
      private function winMouseDown(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(gMainFrame.server.getCurrentRoomName(false) != "den" + e.currentTarget.txt.text)
         {
            DenXtCommManager.requestDenJoinFull("den" + e.currentTarget.txt.text);
         }
         this.show(false,WORLD_MAP);
      }
      
      private function adventureMouseDown(e:MouseEvent) : void
      {
         e.stopPropagation();
         var funcObject:Object = e.currentTarget.performContinueChecks();
         if(funcObject != null)
         {
            this._worldMapFrame.advWindowTab.gotoAndPlay("close");
            this.destroyDenAndAdventureWindows();
            funcObject.func(funcObject.defId);
            funcObject = null;
            this._bShow = true;
         }
      }
      
      private function onEpicDenTab(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(this._worldMapFrame.advWindowTab.currentFrameLabel == "off")
         {
            this._worldMapFrame.advWindowTab.gotoAndPlay("open");
            this._worldMapFrame.advWindowTab.epicDenTab.visible = true;
            LocalizationManager.translateId(this._worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,8700);
            this.checkAndLoadEpicDenWindows();
         }
         else if(this._worldMapFrame.advWindowTab.currentFrameLabel == "on")
         {
            if(Boolean(this._worldMapFrame.advWindowTab.advTab.visible))
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
      
      private function onEpicDenTabOver(e:MouseEvent) : void
      {
         e.stopPropagation();
         GuiManager.toolTip.init(MovieClip(e.currentTarget.parent.parent),LocalizationManager.translateIdOnly(15072),e.currentTarget.width * 0.5 + e.currentTarget.parent.x + e.currentTarget.x,e.currentTarget.parent.y + e.currentTarget.y);
         GuiManager.toolTip.startTimer(e);
      }
      
      private function checkAndLoadEpicDenWindows() : void
      {
         var now:Number = new Date().getTime();
         if(now - this._milliSecSinceLastListRequest > TIME_BETWEEN_REQUESTS || this._epicDenWindows == null)
         {
            this._densLoadingSpiral.visible = true;
            this._milliSecSinceLastListRequest = now;
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
            if(Boolean(this._scrollBar))
            {
               this._scrollBar.destroy();
            }
            this._scrollBar = new SBScrollbar();
            this._scrollBar.init(this._epicDenWindows,267,396,3,"scrollbar2",36);
         }
      }
      
      private function onPullOutPopup(e:MouseEvent) : void
      {
         e.stopPropagation();
      }
      
      private function onPullOutPopupOver(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._volumeManager.clearHold(false);
         this._bShow = false;
      }
      
      private function onPullOutPopupOut(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._bShow = true;
      }
      
      private function onAdvTab(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(!e.currentTarget.isGray)
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
               if(Boolean(this._worldMapFrame.advWindowTab.epicDenTab.visible))
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
      
      private function onAdvTabOver(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(!e.currentTarget.isGray)
         {
            GuiManager.toolTip.init(MovieClip(e.currentTarget.parent.parent),LocalizationManager.translateIdOnly(15036),e.currentTarget.width * 0.5 + e.currentTarget.parent.x + e.currentTarget.x,e.currentTarget.parent.y + e.currentTarget.y);
            GuiManager.toolTip.startTimer(e);
         }
      }
      
      private function onTabOut(e:MouseEvent) : void
      {
         e.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onSortOptions(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(e.currentTarget.name == "sortBtnShop")
         {
            this._sortIcons.cinemaIcons.visible = false;
            this._sortIcons.petShopIcons.visible = false;
            this._sortIcons.shopIcons.visible = !this._sortIcons.shopIcons.visible;
            if(Boolean(this._sortIcons.shopIcons.visible))
            {
               e.currentTarget.mouse.visible = false;
               e.currentTarget.down.visible = true;
            }
            else
            {
               e.currentTarget.mouse.visible = true;
               e.currentTarget.down.visible = false;
            }
            this._sortOptions.sortBtnCinema.mouse.visible = true;
            this._sortOptions.sortBtnCinema.down.visible = false;
            this._sortOptions.sortBtnCinema.btnOutHandler(null);
            this._sortOptions.sortBtnPetShop.mouse.visible = true;
            this._sortOptions.sortBtnPetShop.down.visible = false;
            this._sortOptions.sortBtnPetShop.btnOutHandler(null);
         }
         else if(e.currentTarget.name == "sortBtnCinema")
         {
            this._sortIcons.cinemaIcons.visible = !this._sortIcons.cinemaIcons.visible;
            this._sortIcons.petShopIcons.visible = false;
            this._sortIcons.shopIcons.visible = false;
            if(Boolean(this._sortIcons.cinemaIcons.visible))
            {
               e.currentTarget.mouse.visible = false;
               e.currentTarget.down.visible = true;
            }
            else
            {
               e.currentTarget.mouse.visible = true;
               e.currentTarget.down.visible = false;
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
            if(Boolean(this._sortIcons.petShopIcons.visible))
            {
               e.currentTarget.mouse.visible = false;
               e.currentTarget.down.visible = true;
            }
            else
            {
               e.currentTarget.mouse.visible = true;
               e.currentTarget.down.visible = false;
            }
            this._sortOptions.sortBtnCinema.mouse.visible = true;
            this._sortOptions.sortBtnCinema.down.visible = false;
            this._sortOptions.sortBtnCinema.btnOutHandler(null);
            this._sortOptions.sortBtnShop.mouse.visible = true;
            this._sortOptions.sortBtnShop.down.visible = false;
            this._sortOptions.sortBtnShop.btnOutHandler(null);
         }
      }
      
      private function onSortIcon(e:MouseEvent) : void
      {
         e.stopPropagation();
         var roomName:String = e.currentTarget.name.replace("$",".");
         var roomAndSpawn:Array = roomName.split("$");
         if(roomName != gMainFrame.server.getCurrentRoomName())
         {
            if(roomAndSpawn.length == 2)
            {
               RoomManagerWorld.instance.setGotoSpawnPoint(roomAndSpawn[1].toLowerCase());
            }
            this.gotoRoom(roomAndSpawn[0]);
         }
      }
      
      private function onSortIconOver(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._volumeManager.clearHold(false);
         this._bShow = false;
      }
      
      private function onSortIconOut(e:MouseEvent) : void
      {
         if(this.visible)
         {
            this._bShow = true;
         }
      }
      
      private function mapUpdateTimer(te:TimerEvent) : void
      {
         this.updateRoomCount();
      }
      
      private function updateRoomCount() : void
      {
         var bud:Buddy = null;
         var onlineNames:Array = [];
         var bMoreThanZeroBuddies:Boolean = false;
         var buddyList:Dictionary = BuddyManager.buddyList;
         for each(bud in buddyList)
         {
            bMoreThanZeroBuddies = true;
            if(bud.isOnline)
            {
               onlineNames.push(bud.userName);
            }
         }
         if(bMoreThanZeroBuddies)
         {
            RoomXtCommManager.sendRoomCountRequest(onlineNames);
         }
      }
      
      private function handleRoomCountResponse(data:Object) : void
      {
         var roomName:String = null;
         var shardId:int = 0;
         var splitRoomName:Array = null;
         var layer:Object = null;
         var name:String = null;
         var rooms:Dictionary = new Dictionary(true);
         var numBuddies:int = int(data[2]);
         for(var i:int = 3; i < numBuddies + 3; i++)
         {
            roomName = data[i];
            if(roomName != "")
            {
               shardId = int(roomName.slice(roomName.indexOf("#") + 1,roomName.length));
               if(shardId == RoomManagerWorld.instance.shardId)
               {
                  splitRoomName = roomName.split(".");
                  if(splitRoomName[0] == "oceans")
                  {
                     roomName = splitRoomName[1].slice(0,splitRoomName[1].indexOf("#"));
                  }
                  else
                  {
                     roomName = splitRoomName[0];
                  }
                  if(Boolean(rooms[roomName]))
                  {
                     ++rooms[roomName];
                  }
                  else
                  {
                     rooms[roomName] = 1;
                  }
               }
            }
         }
         this.zeroOutRoomCount();
         for(name in rooms)
         {
            layer = this._worldMapScene.getLayer(name);
            if(Boolean(layer))
            {
               layer.loader.content.buddy.buddyText.text = rooms[name];
            }
         }
      }
      
      private function zeroOutRoomCount() : void
      {
         var layer:Object = null;
         if(this._worldMapScene.isValid)
         {
            layer = this._worldMapScene.getLayer("lost_temple_of_zios");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("jamaa_township");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("sarepia");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("crystal_sands");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("coral_canyons");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("mountains_of_shivveer");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("appondale");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("crystal_reef");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("bahari_bay");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("deep_sea");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("pirate_ship");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
            layer = this._worldMapScene.getLayer("aussie");
            if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
            {
               layer.loader.content.buddy.buddyText.text = 0;
            }
         }
      }
      
      private function setStar() : void
      {
         var layer:Object = null;
         layer = this._worldMapScene.getLayer("jamaa_township");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("lost_temple_of_zios");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("sarepia");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("crystal_sands");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("coral_canyons");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("mountains_of_shivveer");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("appondale");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("crystal_reef");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("bahari_bay");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("deep_sea");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("pirate_ship");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer("aussie");
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = false;
         }
         layer = this._worldMapScene.getLayer(gMainFrame.userInfo.worldMapRoomName);
         if(Boolean(layer) && Boolean(layer.loader) && Boolean(layer.loader.content))
         {
            layer.loader.content.star.visible = true;
         }
      }
   }
}

