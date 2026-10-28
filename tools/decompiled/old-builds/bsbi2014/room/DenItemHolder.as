package room
{
   import avatar.AvatarManager;
   import com.sbi.graphics.SortLayer;
   import den.DenItem;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import game.MinigameManager;
   import gui.BuddyList;
   import gui.GuiManager;
   import loader.DenItemHelper;
   
   public class DenItemHolder extends EventDispatcher
   {
      
      private const MOUSE_DOWN_TYPE:int = 0;
      
      private const MOUSE_OVER_TYPE:int = 1;
      
      private const MOUSE_OUT_TYPE:int = 2;
      
      private var _currItems:Array;
      
      private var _itemsInit:Array;
      
      private var _savedDenItemHelpers:Array;
      
      private var _layerManager:LayerManager;
      
      private var _dragItem:Object;
      
      private var _itemFilter:Object;
      
      private var _dragPoint:Point;
      
      private var _closeBtn:MovieClip;
      
      private var _flipBtn:MovieClip;
      
      private var _linkBtn:MovieClip;
      
      private var _themePos:Point;
      
      private var _isWaitingToSetItemsForFirstTime:Boolean;
      
      private var _roomMode:int;
      
      private var _lastPortalInvId:int;
      
      private var _portalToEnterInvId:int;
      
      private var _portalRadiusBmpData:BitmapData;
      
      public function DenItemHolder(lm:LayerManager)
      {
         super();
         this._themePos = new Point();
         this._dragPoint = new Point();
         this._layerManager = lm;
         this._closeBtn = GETDEFINITIONBYNAME("closeBtn");
         this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
         this._flipBtn = GETDEFINITIONBYNAME("itemRotateBtnCont");
         this._flipBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onFlipBtn,false,0,true);
         this._linkBtn = GETDEFINITIONBYNAME("portalLinkBtnCont");
         this._linkBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onLinkBtn,false,0,true);
         this.release();
         this._lastPortalInvId = -1;
      }
      
      public function release() : void
      {
         var o:Object = null;
         this._isWaitingToSetItemsForFirstTime = true;
         if(Boolean(this._currItems))
         {
            for each(o in this._currItems)
            {
               if(Boolean(o.di))
               {
                  o.di.destroy();
               }
            }
         }
         this._currItems = [];
         this._itemsInit = [];
         this._savedDenItemHelpers = [];
         this._dragItem = null;
         this.updateCloseBtn();
      }
      
      public function clearDen() : void
      {
         this.release();
         this.setItem(DenItem.DEF_AUDIO_INVIDX,DenItem.DEF_AUDIO_PACKED_ID,0,0,0,DenItem.PLACE_CAT_ICONL,DenItem.SORT_AUDIO,0,0,0,DenItem.DEF_AUDIO_VOL,0,DenItem.DEF_AUDIO_STRMNAME,DenItem.REF_ID_DEN_ITEM,false,0,"");
      }
      
      public function get numberOfInitItems() : int
      {
         return this._itemsInit.length;
      }
      
      public function get numberOfInUseItems() : int
      {
         return this._currItems.length;
      }
      
      public function get isDragging() : Boolean
      {
         return this._dragItem != null;
      }
      
      public function reloadItems() : void
      {
         var i:int = 0;
         if(Boolean(this._savedDenItemHelpers))
         {
            for(i = 0; i < this._savedDenItemHelpers.length; i++)
            {
               this.itemLoaded(this._savedDenItemHelpers[i],true);
            }
         }
      }
      
      public function setItems(items:Array, bUserAction:Boolean = false) : void
      {
         var o:Object = null;
         var o1:Object = null;
         var itemFound:Boolean = false;
         var audioFound:Boolean = false;
         var x:Number = NaN;
         var y:Number = NaN;
         if(this._isWaitingToSetItemsForFirstTime && bUserAction)
         {
            this._isWaitingToSetItemsForFirstTime = false;
         }
         for(var j:int = 0; j < items.length; j++)
         {
            o = items[j];
            if(o)
            {
               if(o.c > 0)
               {
                  itemFound = false;
                  for each(o1 in this._currItems)
                  {
                     if(o.r == o1.r && o.i == o1.i)
                     {
                        o1.f = o.f;
                        x = Number(o.x) + Number(o1.offX);
                        y = Number(o.y) + Number(o1.offY);
                        this.setItemMatrix(o1,x,y,o1.f);
                        if(o1.s == DenItem.SORT_PET && Boolean(o1.di))
                        {
                           o1.di.setVersion(o.v,o.v2,o.v3);
                        }
                        if(o1.specialType == DenItem.SPECIAL_TYPE_PORTAL)
                        {
                           o1.userNameLink = o.userNameLink;
                           if(Boolean(o1.di) && Boolean(o1.di.content) && Boolean(o1.di.content.hasOwnProperty("active")))
                           {
                              if(o1.userNameLink != "")
                              {
                                 o1.di.content.active(true);
                              }
                              else
                              {
                                 o1.di.content.active(false);
                              }
                           }
                           BuddyList.destroyInWorldBuddyList();
                        }
                        itemFound = true;
                        break;
                     }
                  }
                  if(!itemFound)
                  {
                     this.setItem(o.i,o.p,o.x,o.y,o.l,o.c,o.s,o.f,o.mg,o.v,o.v2,o.v3,o.strmName,o.r,bUserAction,o.specialType,o.userNameLink);
                  }
               }
               else
               {
                  for each(o1 in this._currItems)
                  {
                     if(o.r == o1.r && o.i == o1.i)
                     {
                        this.releaseItem(o1,bUserAction);
                        break;
                     }
                  }
               }
            }
         }
         for each(o in this._currItems)
         {
            if(o.s == DenItem.SORT_AUDIO)
            {
               audioFound = true;
               break;
            }
         }
         if(!audioFound)
         {
            this.setItem(DenItem.DEF_AUDIO_INVIDX,DenItem.DEF_AUDIO_PACKED_ID,0,0,0,DenItem.PLACE_CAT_ICONL,DenItem.SORT_AUDIO,0,0,0,DenItem.DEF_AUDIO_VOL,0,DenItem.DEF_AUDIO_STRMNAME,DenItem.REF_ID_DEN_ITEM,bUserAction,0,"");
         }
         if(this._isWaitingToSetItemsForFirstTime)
         {
            this._isWaitingToSetItemsForFirstTime = false;
         }
      }
      
      public function removeItem(invId:int, refId:int) : void
      {
         var o:Object = null;
         for each(o in this._currItems)
         {
            if(o.r == refId && o.i == invId)
            {
               this.releaseItem(o);
               break;
            }
         }
      }
      
      public function saveState() : void
      {
         var init:Object = null;
         var curr:Object = null;
         var bFound:Boolean = false;
         var e:DenItemHolderEvent = null;
         var a:Array = null;
         var o:Object = null;
         var o1:Object = null;
         var x:int = 0;
         var y:int = 0;
         var itemChanges:Array = [];
         for each(init in this._itemsInit)
         {
            bFound = false;
            for each(curr in this._currItems)
            {
               if(curr.r == init.r && curr.i == init.i)
               {
                  bFound = true;
                  if(curr.s != DenItem.SORT_AUDIO && (curr.x != init.x || curr.y != init.y || curr.f != init.f || curr.userNameLink != init.userNameLink))
                  {
                     itemChanges.push({
                        "di":curr.di,
                        "f":curr.f,
                        "i":curr.i,
                        "x":curr.x,
                        "s":curr.s,
                        "y":curr.y,
                        "offX":curr.offX,
                        "offY":curr.offY,
                        "r":curr.r,
                        "userNameLink":curr.userNameLink
                     });
                  }
                  break;
               }
            }
            if(!bFound)
            {
               itemChanges.push({
                  "f":0,
                  "i":init.i,
                  "s":init.s,
                  "x":0,
                  "y":0,
                  "d":0,
                  "r":init.r,
                  "userNameLink":""
               });
            }
         }
         for each(curr in this._currItems)
         {
            bFound = false;
            for each(init in this._itemsInit)
            {
               if(init.r == curr.r && init.i == curr.i)
               {
                  bFound = true;
                  break;
               }
            }
            if(!bFound)
            {
               itemChanges.push({
                  "f":curr.f,
                  "di":curr.di,
                  "i":curr.i,
                  "s":curr.s,
                  "x":curr.x,
                  "y":curr.y,
                  "offX":curr.offX,
                  "offY":curr.offY,
                  "r":curr.r,
                  "userNameLink":curr.userNameLink
               });
            }
         }
         if(itemChanges.length > 0)
         {
            this.updateInitialState();
            e = new DenItemHolderEvent(DenItemHolderEvent.SAVE_STATE);
            a = new Array();
            for each(o in itemChanges)
            {
               if(o.i != -1)
               {
                  if(Boolean(o.di))
                  {
                     x = int(o.x - o.offX);
                     y = int(o.y - o.offY);
                     o1 = {
                        "i":o.i,
                        "s":o.s,
                        "d":1,
                        "x":x,
                        "y":y,
                        "f":o.f,
                        "r":o.r,
                        "userNameLink":o.userNameLink
                     };
                  }
                  else
                  {
                     o1 = {
                        "i":o.i,
                        "s":o.s,
                        "d":0,
                        "x":0,
                        "y":0,
                        "f":0,
                        "r":o.r,
                        "userNameLink":o.userNameLink
                     };
                  }
                  a.push(o1);
               }
            }
            e.array = a;
            dispatchEvent(e);
         }
      }
      
      public function removeHighlightState() : void
      {
         if(Boolean(this._closeBtn.parent))
         {
            this._closeBtn.parent.removeChild(this._closeBtn);
         }
         if(Boolean(this._flipBtn.parent))
         {
            this._flipBtn.parent.removeChild(this._flipBtn);
         }
         if(Boolean(this._linkBtn.parent))
         {
            this._linkBtn.parent.removeChild(this._linkBtn);
         }
         if(Boolean(this._itemFilter))
         {
            if(Boolean(this._itemFilter.di.displayObject))
            {
               this._itemFilter.di.displayObject.filters = [];
            }
            this._itemFilter = null;
         }
      }
      
      private function updateInitialState() : void
      {
         var curr:Object = null;
         this._itemsInit = [];
         for each(curr in this._currItems)
         {
            this._itemsInit.push({
               "c":curr.c,
               "di":curr.di,
               "l":curr.l,
               "i":curr.i,
               "f":curr.f,
               "s":curr.x,
               "x":curr.x,
               "y":curr.y,
               "offX":curr.offX,
               "offY":curr.offY,
               "r":curr.r,
               "userNameLink":curr.userNameLink
            });
         }
      }
      
      public function handleMouse(x:Number, y:Number, bDown:Boolean) : void
      {
         var xp:Number = NaN;
         var yp:Number = NaN;
         var newDragItem:Object = null;
         if(bDown)
         {
            if(Boolean(this._dragItem))
            {
               xp = this._dragItem.x + x - this._dragPoint.x;
               yp = this._dragItem.y + y - this._dragPoint.y;
               this.setItemMatrix(this._dragItem,xp,yp,this._dragItem.f);
               this.setBtnPos(xp + this._dragItem.di.displayObject.width - 30,yp);
               this._dragPoint.x = x;
               this._dragPoint.y = y;
            }
         }
         else
         {
            if(Boolean(this._dragItem) && this._dragItem.specialType == DenItem.SPECIAL_TYPE_PORTAL)
            {
               newDragItem = this.hitTest(x,y);
               if(!BuddyList.isOverWorldBuddyList(x,y) && newDragItem != this._dragItem)
               {
                  BuddyList.closeWorldBuddyList();
                  this._dragItem = newDragItem;
               }
            }
            else
            {
               this._dragItem = this.hitTest(x,y);
            }
            if(Boolean(this._dragItem))
            {
               this._dragPoint.x = x;
               this._dragPoint.y = y;
            }
            this.updateCloseBtn();
         }
      }
      
      public function setThemePosition(x:int, y:int) : void
      {
         this._themePos = new Point(x,y);
      }
      
      public function setRoomMode(mode:int) : void
      {
         this._roomMode = mode;
         this.stopListenersOnPets(this._roomMode == RoomManagerWorld.ROOM_MODE_DEN);
         this.stopMouseOnNonMouseItems(this._roomMode == RoomManagerWorld.ROOM_MODE_DEN);
      }
      
      public function stopListenersOnPets(inEditMode:Boolean) : void
      {
         var di:Object = null;
         for each(di in this._currItems)
         {
            if(Boolean(di.di) && Boolean(di.di.content) && Boolean(di.di.content.hasOwnProperty("listenToMouse")))
            {
               di.di.content.listenToMouse = !inEditMode;
            }
         }
      }
      
      public function stopMouseOnNonMouseItems(inEditMode:Boolean) : void
      {
         var di:Object = null;
         for each(di in this._currItems)
         {
            if(Boolean(di.di) && Boolean(di.di.content) && Boolean(di.di.content.hasOwnProperty("ignoreMouseCompletely")) && Boolean(di.di.displayObject))
            {
               Sprite(di.di.displayObject).mouseEnabled = !inEditMode;
               Sprite(di.di.displayObject).mouseChildren = !inEditMode;
            }
         }
      }
      
      public function shouldStopMovement(mouse:Point) : Boolean
      {
         var o:Object = null;
         var doc:MovieClip = null;
         var j:int = 0;
         var total:int = int(this._currItems.length);
         if(total > 0)
         {
            for(j = 0; j < total; j++)
            {
               o = this._currItems[j];
               if(!this.isTheme(o.s) && o.s != DenItem.SORT_AUDIO)
               {
                  if(o.di.displayObject.numChildren > 0)
                  {
                     doc = o.di.displayObject.getChildAt(0).content;
                     if(doc.parent.name == "moveToDisabled")
                     {
                        if(doc.hitTestPoint(mouse.x,mouse.y,true))
                        {
                           return true;
                        }
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public function portalItemTest(newMouseDown:Boolean, mousePos:Point) : void
      {
         var o:Object = null;
         var j:int = 0;
         var radiusObject:Sprite = null;
         var obj:Object = null;
         var total:int = int(this._currItems.length);
         if(total > 0)
         {
            for(j = 0; j < total; j++)
            {
               o = this._currItems[j];
               if(o.specialType == DenItem.SPECIAL_TYPE_PORTAL && o.userNameLink != "")
               {
                  if(Boolean(o.di.content))
                  {
                     if(newMouseDown)
                     {
                        if(Boolean(o.di.displayObject.getChildAt(0).content.clickObject.hitTestPoint(mousePos.x,mousePos.y,true)))
                        {
                           radiusObject = Sprite(o.di.displayObject.getChildAt(0).content.radiusObject);
                           this._portalToEnterInvId = o.i;
                           this._portalRadiusBmpData = new BitmapData(radiusObject.width,radiusObject.height);
                           this._portalRadiusBmpData.draw(radiusObject);
                        }
                        else
                        {
                           this._portalToEnterInvId = -1;
                           if(Boolean(this._portalRadiusBmpData))
                           {
                              this._portalRadiusBmpData.dispose();
                              this._portalRadiusBmpData = null;
                           }
                        }
                        this._lastPortalInvId = -1;
                     }
                     if(this._portalToEnterInvId == o.i)
                     {
                        obj = o.di.content.getRadiusObject();
                        if(!AvatarManager.playerAvatarWorldView.bmpDataHitTest(this._portalRadiusBmpData,new Point(o.x + obj.x,o.y + obj.y)))
                        {
                           return;
                        }
                        if(this._lastPortalInvId == o.i)
                        {
                           return;
                        }
                        if(this._lastPortalInvId == -1)
                        {
                           RoomXtCommManager.sendRoomJoinRequest("den" + o.userNameLink,o.i);
                           this._lastPortalInvId = o.i;
                           return;
                        }
                     }
                  }
               }
            }
         }
         this._lastPortalInvId = -1;
      }
      
      private function isTheme(catId:int) : Boolean
      {
         return catId > 1 && catId < 4;
      }
      
      private function setItem(invId:int, packedId:int, x:int, y:int, l:int, c:int, s:int, f:int, mg:int, v:int, v2:int, v3:int, strmName:String, refId:int, bUserAction:Boolean, specialType:int, userNameLink:String) : void
      {
         var so:Object = null;
         var ne:DenItemHolderEvent = null;
         var ao:Object = null;
         var nae:DenItemHolderEvent = null;
         var version2:int = s == DenItem.SORT_PET ? v2 : 0;
         var version3:int = s == DenItem.SORT_PET ? v3 : 0;
         var di:DenItemHelper = new DenItemHelper();
         if(this.isTheme(s))
         {
            for each(so in this._currItems)
            {
               if(so.s == s)
               {
                  this.releaseItem(so);
                  ne = new DenItemHolderEvent(DenItemHolderEvent.ITEM_REMOVED);
                  ne.id = so.i;
                  ne.refId = so.r;
                  ne.array = [so];
                  dispatchEvent(ne);
                  break;
               }
            }
         }
         else if(s == DenItem.SORT_AUDIO)
         {
            for each(ao in this._currItems)
            {
               if(ao.s == s)
               {
                  this.releaseItem(ao);
                  nae = new DenItemHolderEvent(DenItemHolderEvent.ITEM_REMOVED);
                  nae.id = ao.i;
                  nae.refId = ao.r;
                  nae.array = [ao];
                  dispatchEvent(nae);
                  break;
               }
            }
            RoomManagerWorld.instance.playMusic(strmName + ".mp3",v2 / 100);
         }
         var obj:Object = {
            "c":c,
            "s":s,
            "di":di,
            "f":f,
            "i":invId,
            "l":l,
            "x":x,
            "y":y,
            "r":refId,
            "bNewPlaced":bUserAction,
            "specialType":specialType,
            "userNameLink":userNameLink
         };
         this._currItems.push(obj);
         di.init(packedId,this.itemLoaded,v,mg,version2,version3);
         if(this._roomMode == RoomManagerWorld.ROOM_MODE_DEN)
         {
            if(Boolean(obj.di) && Boolean(obj.di.content) && Boolean(obj.di.content.hasOwnProperty("listenToMouse")))
            {
               obj.di.content.listenToMouse = false;
            }
         }
         else if(Boolean(obj.di) && Boolean(obj.di.displayObject) && Boolean(obj.di.content) && Boolean(obj.di.content.hasOwnProperty("ignoreMouseCompletely")))
         {
            Sprite(obj.di.displayObject).mouseEnabled = false;
            Sprite(obj.di.displayObject).mouseChildren = false;
         }
         if(Boolean(obj.di) && Boolean(obj.di.content) && Boolean(obj.di.content.hasOwnProperty("active")))
         {
            if(obj.userNameLink != "")
            {
               obj.di.content.active(true);
            }
            else
            {
               obj.di.content.active(false);
            }
         }
         if(mg > 0)
         {
            this.addListenersToItem(di,obj);
         }
         else if(specialType == DenItem.SPECIAL_TYPE_PORTAL)
         {
            this.addPortalListenersToItem(di,obj);
         }
         else if(specialType == DenItem.SPECIAL_TYPE_EMOTE)
         {
            di.setupItemWithEmotes(obj);
         }
         if(this._isWaitingToSetItemsForFirstTime || !bUserAction)
         {
            this._itemsInit.push({
               "c":obj.c,
               "s":obj.s,
               "di":obj.di,
               "f":obj.f,
               "i":obj.i,
               "l":obj.l,
               "x":obj.x,
               "y":obj.y,
               "r":refId,
               "bNewPlaced":obj.bNewPlaced,
               "specialType":specialType,
               "userNameLink":userNameLink
            });
         }
      }
      
      private function updateCloseBtn() : void
      {
         var d:Sprite = null;
         if(Boolean(this._dragItem))
         {
            d = this._dragItem.di.displayObject;
            if(this._closeBtn.parent != d)
            {
               this.setBtnPos(this._dragItem.x + d.width - 30,this._dragItem.y);
               this._layerManager.room_chat.addChild(this._closeBtn);
               this._layerManager.room_chat.addChild(this._flipBtn);
               if(this._dragItem.specialType == DenItem.SPECIAL_TYPE_PORTAL)
               {
                  this._layerManager.room_chat.addChild(this._linkBtn);
               }
               else if(Boolean(this._linkBtn.parent))
               {
                  this._linkBtn.parent.removeChild(this._linkBtn);
                  BuddyList.closeWorldBuddyList();
               }
            }
            if(this._itemFilter != this._dragItem)
            {
               if(Boolean(this._itemFilter))
               {
                  this._itemFilter.di.displayObject.filters = [];
               }
               this._itemFilter = this._dragItem;
               this._itemFilter.di.displayObject.filters = [new GlowFilter(16777215,1,8,8,8)];
            }
         }
         else
         {
            if(Boolean(this._closeBtn.parent))
            {
               this._closeBtn.parent.removeChild(this._closeBtn);
            }
            if(Boolean(this._flipBtn.parent))
            {
               this._flipBtn.parent.removeChild(this._flipBtn);
            }
            if(Boolean(this._linkBtn.parent))
            {
               this._linkBtn.parent.removeChild(this._linkBtn);
               BuddyList.closeWorldBuddyList();
            }
            if(Boolean(this._itemFilter))
            {
               if(Boolean(this._itemFilter.di.displayObject))
               {
                  this._itemFilter.di.displayObject.filters = [];
               }
               this._itemFilter = null;
            }
         }
      }
      
      private function setBtnPos(x:Number, y:Number) : void
      {
         this._closeBtn.x = x;
         this._closeBtn.y = y;
         this._flipBtn.x = x + 15;
         this._flipBtn.y = y + 55;
         this._linkBtn.x = x + 15;
         this._linkBtn.y = y + 90;
         BuddyList.updateWorldBuddyListPosition(this._linkBtn);
      }
      
      private function onCloseBtn(e:Event) : void
      {
         var ne:DenItemHolderEvent = null;
         e.stopPropagation();
         if(Boolean(this._dragItem))
         {
            ne = new DenItemHolderEvent(DenItemHolderEvent.ITEM_REMOVED);
            ne.id = this._dragItem.i;
            ne.refId = this._dragItem.r;
            ne.array = [this._dragItem];
            this.releaseItem(this._dragItem);
            this._dragItem = null;
            this.updateCloseBtn();
            dispatchEvent(ne);
         }
      }
      
      private function onFlipBtn(e:Event) : void
      {
         e.stopPropagation();
         if(Boolean(this._dragItem))
         {
            this._dragItem.f = this._dragItem.f == 0 ? 1 : 0;
            this.setItemMatrix(this._dragItem,this._dragItem.x,this._dragItem.y,this._dragItem.f);
         }
      }
      
      private function onLinkBtn(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(Boolean(this._dragItem))
         {
            BuddyList.buildInWorldBuddyList(this._linkBtn,this._dragItem,this.onSelectUserToLink,this._dragItem.userNameLink);
         }
      }
      
      private function onSelectUserToLink(userName:String) : void
      {
         if(Boolean(this._dragItem))
         {
            this._dragItem.userNameLink = userName;
            if(Boolean(this._dragItem.di) && Boolean(this._dragItem.di.content) && Boolean(this._dragItem.di.content.hasOwnProperty("active")))
            {
               if(userName != "")
               {
                  this._dragItem.di.content.active(true);
               }
               else
               {
                  this._dragItem.di.content.active(false);
               }
            }
         }
      }
      
      private function isInInitList(inv:int, refId:int) : Boolean
      {
         for(var i:int = 0; i < this._itemsInit.length; i++)
         {
            if(this._itemsInit[i].refId == refId && this._itemsInit[i].i == inv)
            {
               return true;
            }
         }
         return false;
      }
      
      private function releaseItem(o:Object, bUserAction:Boolean = true) : void
      {
         var i:int = this._currItems.indexOf(o);
         if(i >= 0)
         {
            this._currItems.splice(i,1);
            if(Boolean(o.di))
            {
               if(Boolean(o.di.displayObject.parent))
               {
                  o.di.displayObject.parent.removeChild(o.di.displayObject);
               }
               if(o.di.minigameDefId > 0)
               {
                  this.removeListenersFromItem(o.di);
               }
               if(o.specialType == DenItem.SPECIAL_TYPE_PORTAL)
               {
                  this.removePortalListenersFromItem(o.di);
                  this._lastPortalInvId = -1;
                  this._portalToEnterInvId = -1;
                  if(Boolean(this._portalRadiusBmpData))
                  {
                     this._portalRadiusBmpData.dispose();
                     this._portalRadiusBmpData = null;
                  }
               }
            }
         }
         if(!bUserAction)
         {
            for(i = 0; i < this._itemsInit.length; i++)
            {
               if(this._itemsInit[i].i == o.i)
               {
                  this._itemsInit.splice(i,1);
                  break;
               }
            }
         }
      }
      
      private function setItemMatrix(o:Object, x:Number, y:Number, hFlip:int = 0) : void
      {
         var sp:Sprite = null;
         var l:Loader = null;
         var mc:MovieClip = null;
         var sx:Number = NaN;
         var sy:Number = NaN;
         var d:DisplayObject = o.di.displayObject;
         o.x = x;
         o.y = y;
         var matrix:Matrix = d.transform.matrix;
         matrix.identity();
         var tx:Number = x;
         var ty:Number = y;
         if(Boolean(o.di.bFlipLabel))
         {
            sp = d as Sprite;
            l = sp.getChildAt(0) as Loader;
            mc = l.content as MovieClip;
            mc.gotoAndStop(Boolean(hFlip) ? "flip" : 1);
         }
         else if(Boolean(hFlip))
         {
            sx = 1;
            sy = 1;
            sx *= -1;
            tx += d.width;
            matrix.scale(sx,sy);
         }
         matrix.translate(tx,ty);
         d.transform.matrix = matrix;
      }
      
      private function hitTest(x:int, y:int) : Object
      {
         var ret:Object = null;
         var i:int = 0;
         var so:Object = null;
         var d:DisplayObject = null;
         var r:Rectangle = null;
         var bottomOff:Number = NaN;
         var lastY:Number = -999999999;
         var layer:int = 99999999;
         for(var len:int = int(this._currItems.length); i < len; )
         {
            so = this._currItems[i];
            if(!this.isTheme(so.s))
            {
               d = so.di.displayObject;
               r = d.getBounds(this._layerManager.room_avatars);
               bottomOff = r.bottom - Number(d.name);
               if(x > r.left && x < r.right && y > r.top && y < r.bottom)
               {
                  if(so.l <= layer)
                  {
                     if(so.l == 1 || bottomOff > lastY)
                     {
                        layer = int(so.l);
                        lastY = bottomOff;
                        ret = so;
                        if(layer == 1)
                        {
                           lastY = -999999999;
                        }
                     }
                  }
               }
            }
            i++;
         }
         return ret;
      }
      
      private function itemLoaded(di:DenItemHelper, isAddingManually:Boolean = false) : void
      {
         var o:Object = null;
         var so:Object = null;
         var d:DisplayObject = null;
         var x:Number = NaN;
         var y:Number = NaN;
         var isNewlyPlaced:Boolean = false;
         var sortOffset:int = 0;
         var l:int = 0;
         var o1:Object = null;
         var layer:SortLayer = null;
         if(!isAddingManually)
         {
            this._savedDenItemHelpers.push(di);
         }
         for each(so in this._currItems)
         {
            if(so.di == di)
            {
               o = so;
               break;
            }
         }
         if(Boolean(o) && o.s != DenItem.SORT_AUDIO)
         {
            d = di.displayObject;
            o.offX = -(d.width * 0.5);
            o.offY = -d.height;
            if(isAddingManually)
            {
               o.x -= o.offX;
               o.y -= o.offY;
            }
            x = o.x + o.offX;
            y = o.y + o.offY;
            isNewlyPlaced = Boolean(o.bNewPlaced);
            if(Boolean(o.bNewPlaced))
            {
               y += d.height * 0.5;
               o.bNewPlaced = false;
            }
            if(this._roomMode == RoomManagerWorld.ROOM_MODE_DEN)
            {
               if(Boolean(o.di) && Boolean(o.di.content) && Boolean(o.di.content.hasOwnProperty("listenToMouse")))
               {
                  o.di.content.listenToMouse = false;
               }
            }
            else if(Boolean(d) && Boolean(o.di) && Boolean(o.di.content) && Boolean(o.di.content.hasOwnProperty("ignoreMouseCompletely")))
            {
               Sprite(d).mouseEnabled = false;
               Sprite(d).mouseChildren = false;
            }
            if(Boolean(o.di) && Boolean(o.di.content) && Boolean(o.di.content.hasOwnProperty("active")))
            {
               if(o.userNameLink != "")
               {
                  o.di.content.active(true);
               }
               else
               {
                  o.di.content.active(false);
               }
            }
            l = int(o.l);
            this.setItemMatrix(o,x,y,o.f);
            if(this.isTheme(o.s))
            {
               l = 100;
               d.x = 0;
               d.y = 0;
               this.setItemMatrix(o,0,0);
            }
            if(!isNewlyPlaced)
            {
               for each(o1 in this._itemsInit)
               {
                  if(o.r == o1.r && o.i == o1.i)
                  {
                     if(o.x != o1.x || o.y != o1.y)
                     {
                        o1.x = o.x;
                        o1.y = o.y;
                        o1.offX = o.offX;
                        o1.offY = o.offY;
                        break;
                     }
                  }
               }
            }
            switch(l)
            {
               default:
                  sortOffset = di.sortOffset;
                  layer = this._layerManager.room_avatars;
                  if(Boolean(sortOffset))
                  {
                     d.name = String(sortOffset);
                  }
                  layer.addChild(d);
                  break;
               case 1:
                  this._layerManager.room_bkg_main.addChild(d);
                  break;
               case 100:
                  this._layerManager.room_bkg_main.addChildAt(d,0);
            }
         }
      }
      
      private function addListenersToItem(dih:DenItemHelper, obj:Object) : void
      {
         dih.addMouseListeners(obj,this.onItemDown,this.onItemOver,this.onItemOut);
      }
      
      private function addPortalListenersToItem(dih:DenItemHelper, obj:Object) : void
      {
         dih.addPortalListeners(obj,this.onPortalItemDown,this.onPortalItemOver,this.onPortalItemOut);
      }
      
      private function removeListenersFromItem(dih:DenItemHelper) : void
      {
         dih.removeMouseListeners();
      }
      
      private function removePortalListenersFromItem(dih:DenItemHelper) : void
      {
         dih.removePortalListeners();
      }
      
      private function onItemDown(evt:MouseEvent, gameDefId:int) : void
      {
         if(this._roomMode != RoomManagerWorld.ROOM_MODE_AVATAR)
         {
            return;
         }
         evt.stopPropagation();
         this.sendMouseEvent(evt);
         var gameObj:Object = {"typeDefId":gameDefId};
         MinigameManager.handleGameClick(gameObj,null);
      }
      
      private function onPortalItemDown(evt:MouseEvent, defId:int) : void
      {
      }
      
      private function onItemOver(evt:MouseEvent, passback:Object, gameDefId:int) : void
      {
         if(this._roomMode != RoomManagerWorld.ROOM_MODE_AVATAR)
         {
            return;
         }
         evt.stopPropagation();
         this.sendMouseEvent(evt);
         var sp:Sprite = Sprite(evt.currentTarget);
         GuiManager.toolTip.init(this._layerManager.room_orbs,MinigameManager.getGameName(gameDefId),passback.x + sp.width * 0.5,passback.y + sp.height - 75);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onPortalItemOver(evt:MouseEvent, _passback:Object, defId:int) : void
      {
         if(this._roomMode != RoomManagerWorld.ROOM_MODE_AVATAR)
         {
            return;
         }
         evt.stopPropagation();
         if(_passback.userNameLink != "")
         {
            this.sendMouseEvent(evt,true);
         }
      }
      
      private function onItemOut(evt:MouseEvent) : void
      {
         if(this._roomMode != RoomManagerWorld.ROOM_MODE_AVATAR)
         {
            return;
         }
         evt.stopPropagation();
         this.sendMouseEvent(evt);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onPortalItemOut(evt:MouseEvent) : void
      {
         if(this._roomMode != RoomManagerWorld.ROOM_MODE_AVATAR)
         {
            return;
         }
         evt.stopPropagation();
         this.sendMouseEvent(evt,true);
      }
      
      private function sendMouseEvent(evt:MouseEvent, isPortal:Boolean = false) : void
      {
         var sp:Sprite = null;
         var l:Loader = null;
         var mc:MovieClip = null;
         var type:int = -1;
         switch(evt.type)
         {
            case MouseEvent.MOUSE_DOWN:
               type = this.MOUSE_DOWN_TYPE;
               break;
            case MouseEvent.MOUSE_OVER:
               type = this.MOUSE_OVER_TYPE;
               break;
            case MouseEvent.MOUSE_OUT:
               type = this.MOUSE_OUT_TYPE;
         }
         if(type >= 0)
         {
            if(isPortal)
            {
               sp = Sprite(evt.currentTarget.parent);
            }
            else
            {
               sp = Sprite(evt.currentTarget);
            }
            if(Boolean(sp.parent))
            {
               l = Loader(sp.getChildAt(0));
               if(Boolean(l))
               {
                  mc = MovieClip(l.content);
                  if(Boolean(mc))
                  {
                     if(mc.hasOwnProperty("handleMouse"))
                     {
                        mc.handleMouse(type);
                     }
                  }
               }
            }
         }
      }
   }
}

