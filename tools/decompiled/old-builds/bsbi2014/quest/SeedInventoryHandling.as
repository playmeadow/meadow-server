package quest
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import gui.GuiManager;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   
   public class SeedInventoryHandling
   {
      
      public const MAX_NUM_SEEDS:int = 5;
      
      private var _seedsInventory:Dictionary;
      
      private var _draggedSeed:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _mediaItems:Array;
      
      private var _clickStartX:Number;
      
      private var _clickStartY:Number;
      
      public function SeedInventoryHandling()
      {
         super();
      }
      
      public function init(seedsInventory:Dictionary) : void
      {
         this._mediaItems = [];
         this._seedsInventory = seedsInventory;
         this.setupInventoryWindows();
      }
      
      public function destroy() : void
      {
         var currWindow:MovieClip = null;
         if(Boolean(this._draggedSeed) && this._draggedSeed.parent == GuiManager.guiLayer)
         {
            GuiManager.guiLayer.removeChild(this._draggedSeed);
         }
         this._draggedSeed = null;
         for(var i:int = 0; i < this.MAX_NUM_SEEDS; i++)
         {
            currWindow = GuiManager.mainHud["inventoriesWindow" + i];
            if(Boolean(currWindow))
            {
               currWindow.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSeedsClickStart);
            }
         }
         this._seedsInventory = null;
      }
      
      public function rebuildInventory(seedsInventory:Dictionary) : void
      {
         this._seedsInventory = seedsInventory;
         this.setupInventoryWindows();
      }
      
      public function removeLastDraggedSeed() : void
      {
         if(Boolean(this._draggedSeed))
         {
            this._draggedSeed.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSeedsDragDown);
            this._draggedSeed.removeEventListener(MouseEvent.MOUSE_UP,this.onSeedsClickStartUp);
            this._draggedSeed.removeEventListener(MouseEvent.MOUSE_MOVE,this.onSeedMove);
            this._draggedSeed.stopDrag();
            if(this._draggedSeed.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(this._draggedSeed);
            }
            this._draggedSeed = null;
         }
      }
      
      private function setupInventoryWindows() : void
      {
         var npcDef:Object = null;
         var seedMediaId:int = 0;
         var currWindow:MovieClip = null;
         var i:int = 0;
         var count:int = 0;
         var max:int = 0;
         var seedDef:String = null;
         var currChild:Object = null;
         var matrix:Array = null;
         this._mediaItems = [];
         for(seedDef in this._seedsInventory)
         {
            npcDef = QuestManager.getNPCDef(int(seedDef));
            if(Boolean(npcDef))
            {
               seedMediaId = int(npcDef.mediaRefId);
               currWindow = GuiManager.mainHud["inventoriesWindow" + i];
               if(currWindow != null && currWindow.numChildren > 0)
               {
                  currChild = currWindow.getChildAt(0);
                  if(currChild.hasOwnProperty("txt"))
                  {
                     count = int(this._seedsInventory[seedDef].count);
                     max = int(this._seedsInventory[seedDef].max);
                     currChild.txt.text = count + "/" + max;
                     if(count == 0)
                     {
                        matrix = new Array();
                        matrix = matrix.concat([0.33,0.33,0.33,0,0]);
                        matrix = matrix.concat([0.33,0.33,0.33,0,0]);
                        matrix = matrix.concat([0.33,0.33,0.33,0,0]);
                        matrix = matrix.concat([0,0,0,1,0]);
                        currChild.filters = [new ColorMatrixFilter(matrix)];
                        currWindow.mouseEnabled = false;
                        currWindow.mouseChildren = false;
                     }
                     else
                     {
                        if(count >= max)
                        {
                           currChild.gotoAndPlay("on");
                        }
                        currChild.filters = null;
                        currWindow.mouseEnabled = true;
                        currWindow.mouseChildren = true;
                     }
                     i++;
                     continue;
                  }
               }
               if(seedMediaId != 0)
               {
                  this._mediaHelper = new MediaHelper();
                  this._mediaHelper.init(seedMediaId,this.onSeedLoaded,{
                     "index":i,
                     "contIcon":true,
                     "defId":int(seedDef)
                  });
                  this._mediaItems[i] = this._mediaHelper;
                  this._mediaHelper = new MediaHelper();
                  this._mediaHelper.init(seedMediaId,this.onSeedLoaded,{
                     "index":i,
                     "contIcon":false,
                     "defId":int(seedDef)
                  });
                  this._mediaItems[i + 1] = this._mediaHelper;
                  i++;
               }
            }
         }
         while(i < this.MAX_NUM_SEEDS)
         {
            currWindow = GuiManager.mainHud["inventoriesWindow" + i];
            if(currWindow != null)
            {
               currWindow.mouseEnabled = false;
               currWindow.mouseChildren = false;
               currWindow.visible = false;
            }
            i++;
         }
      }
      
      private function onSeedLoaded(img:MovieClip) : void
      {
         var seedCont:MovieClip = null;
         var currWindow:MovieClip = null;
         var count:int = 0;
         var max:int = 0;
         var matrix:Array = null;
         if(Boolean(img))
         {
            img.setAsIcon();
            if(Boolean(img.passback.contIcon))
            {
               seedCont = GETDEFINITIONBYNAME("vftCont");
               currWindow = GuiManager.mainHud["inventoriesWindow" + img.passback.index];
               count = int(this._seedsInventory[img.passback.defId].count);
               max = int(this._seedsInventory[img.passback.defId].max);
               seedCont.itemWindow.addChild(img.getNPC());
               seedCont.txt.text = count + "/" + max;
               if(count == 0)
               {
                  matrix = new Array();
                  matrix = matrix.concat([0.33,0.33,0.33,0,0]);
                  matrix = matrix.concat([0.33,0.33,0.33,0,0]);
                  matrix = matrix.concat([0.33,0.33,0.33,0,0]);
                  matrix = matrix.concat([0,0,0,1,0]);
                  seedCont.filters = [new ColorMatrixFilter(matrix)];
                  if(currWindow != null)
                  {
                     currWindow.mouseEnabled = false;
                     currWindow.mouseChildren = false;
                  }
               }
               else
               {
                  if(count >= max)
                  {
                     seedCont.gotoAndPlay("on");
                  }
                  seedCont.filters = null;
                  if(currWindow != null)
                  {
                     currWindow.mouseEnabled = true;
                     currWindow.mouseChildren = true;
                  }
               }
               if(currWindow != null)
               {
                  while(currWindow.numChildren > 0)
                  {
                     currWindow.removeChildAt(0);
                  }
                  currWindow.addChild(seedCont);
                  currWindow.addEventListener(MouseEvent.MOUSE_DOWN,this.onSeedsClickStart,false,0,true);
                  currWindow.visible = true;
               }
            }
            else if(GuiManager.mainHud["inventoriesWindow" + img.passback.index] != null)
            {
               GuiManager.mainHud["inventoriesWindow" + img.passback.index].dragIcon = img;
            }
         }
      }
      
      private function onSeedsClickStart(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._clickStartX = evt.stageX;
         this._clickStartY = evt.stageY;
         if(this._draggedSeed == null || this._draggedSeed.windowName != evt.currentTarget.name)
         {
            if(Boolean(this._draggedSeed) && this._draggedSeed.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(this._draggedSeed);
            }
            this._draggedSeed = evt.currentTarget.dragIcon.getNPC();
            this._draggedSeed.custom = {
               "prevPositionX":0,
               "prevPositionY":0,
               "xOut":false,
               "currWindow":evt.currentTarget
            };
            this._draggedSeed.addEventListener(MouseEvent.MOUSE_UP,this.onSeedsClickStartUp,false,0,true);
            this._draggedSeed.addEventListener(MouseEvent.MOUSE_MOVE,this.onSeedMove,false,0,true);
            this._draggedSeed.addEventListener(MouseEvent.MOUSE_DOWN,this.onSeedsDragDown,false,0,true);
            this._draggedSeed.x = evt.currentTarget.x;
            this._draggedSeed.y = evt.currentTarget.y;
            this._draggedSeed.custom.prevPositionX = 0;
            this._draggedSeed.custom.prevPositionY = 0;
            this._draggedSeed.custom.xOut = false;
            evt.currentTarget.dragIcon.setAsIcon();
            this._draggedSeed.passback = evt.currentTarget.dragIcon.passback;
            GuiManager.guiLayer.addChild(this._draggedSeed);
         }
         this._draggedSeed.startDrag(true);
         QuestManager.playSound("ajq_boomSeedSelect");
      }
      
      private function onSeedsDragDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onSeedsClickStartUp(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Math.abs(this._clickStartX - evt.stageX) > 2 || Math.abs(this._clickStartY - evt.stageY) > 2)
         {
            this.onSeedsClickEnd(evt);
         }
         else if(this._draggedSeed != null)
         {
            this._clickStartX = -99999;
            this._clickStartY = -99999;
         }
      }
      
      private function onSeedMove(evt:MouseEvent) : void
      {
         var worldAim:Point = null;
         evt.stopPropagation();
         if(Math.abs(this._clickStartX - evt.stageX) > 2 || Math.abs(this._clickStartY - evt.stageY) > 2)
         {
            this._clickStartX = -99999;
            this._clickStartY = -99999;
         }
         var deltaX:Number = evt.stageX - this._draggedSeed.custom.prevPositionX;
         var deltaY:Number = evt.stageY - this._draggedSeed.custom.prevPositionY;
         var deltaSquared:Number = deltaX * deltaX + deltaY * deltaY;
         if(deltaSquared > 9)
         {
            this._draggedSeed.custom.prevPositionX = evt.stageX;
            this._draggedSeed.custom.prevPositionY = evt.stageY;
            worldAim = RoomManagerWorld.instance.convertScreenToWorldSpace(evt.stageX,evt.stageY);
            if(QuestManager.validatePlantSeedLocation(worldAim) == false)
            {
               if(!evt.currentTarget.custom.xOut)
               {
                  evt.currentTarget.custom.currWindow.dragIcon.setAsIconX();
                  evt.currentTarget.custom.xOut = true;
               }
            }
            else if(Boolean(evt.currentTarget.custom.xOut))
            {
               evt.currentTarget.custom.currWindow.dragIcon.setAsIcon();
               evt.currentTarget.custom.xOut = false;
            }
         }
      }
      
      private function onSeedsClickEnd(evt:MouseEvent) : void
      {
         var worldAim:Point = null;
         var isHit:Boolean = false;
         evt.stopPropagation();
         if(Boolean(this._draggedSeed))
         {
            worldAim = RoomManagerWorld.instance.convertScreenToWorldSpace(evt.stageX,evt.stageY);
            isHit = this._draggedSeed.hitTestObject(this._draggedSeed.custom.currWindow);
            if(!isHit)
            {
               if(QuestManager.validatePlantSeedLocation(worldAim))
               {
                  QuestXtCommManager.sendPlantSeed(this._draggedSeed.passback.defId,worldAim.x,worldAim.y);
                  return;
               }
            }
            this.removeLastDraggedSeed();
         }
      }
   }
}

