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
      
      public function init(param1:Dictionary) : void
      {
         this._mediaItems = [];
         this._seedsInventory = param1;
         this.setupInventoryWindows();
      }
      
      public function destroy() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(this._draggedSeed) && this._draggedSeed.parent == GuiManager.guiLayer)
         {
            GuiManager.guiLayer.removeChild(this._draggedSeed);
         }
         this._draggedSeed = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.MAX_NUM_SEEDS)
         {
            _loc1_ = GuiManager.mainHud["inventoriesWindow" + _loc2_];
            if(_loc1_)
            {
               _loc1_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSeedsClickStart);
            }
            _loc2_++;
         }
         this._seedsInventory = null;
      }
      
      public function rebuildInventory(param1:Dictionary) : void
      {
         this._seedsInventory = param1;
         this.setupInventoryWindows();
      }
      
      public function removeLastDraggedSeed() : void
      {
         if(this._draggedSeed)
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
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc9_:Array = null;
         this._mediaItems = [];
         for(_loc7_ in this._seedsInventory)
         {
            _loc1_ = QuestManager.getNPCDef(int(_loc7_));
            if(_loc1_)
            {
               _loc2_ = int(_loc1_.mediaRefId);
               _loc3_ = GuiManager.mainHud["inventoriesWindow" + _loc4_];
               if(_loc3_ != null && _loc3_.numChildren > 0)
               {
                  _loc8_ = _loc3_.getChildAt(0);
                  if(_loc8_.hasOwnProperty("txt"))
                  {
                     _loc5_ = int(this._seedsInventory[_loc7_].count);
                     _loc6_ = int(this._seedsInventory[_loc7_].max);
                     _loc8_.txt.text = _loc5_ + "/" + _loc6_;
                     if(_loc5_ == 0)
                     {
                        _loc9_ = new Array();
                        _loc9_ = _loc9_.concat([0.33,0.33,0.33,0,0]);
                        _loc9_ = _loc9_.concat([0.33,0.33,0.33,0,0]);
                        _loc9_ = _loc9_.concat([0.33,0.33,0.33,0,0]);
                        _loc9_ = _loc9_.concat([0,0,0,1,0]);
                        _loc8_.filters = [new ColorMatrixFilter(_loc9_)];
                        _loc3_.mouseEnabled = false;
                        _loc3_.mouseChildren = false;
                     }
                     else
                     {
                        if(_loc5_ >= _loc6_)
                        {
                           _loc8_.gotoAndPlay("on");
                        }
                        _loc8_.filters = null;
                        _loc3_.mouseEnabled = true;
                        _loc3_.mouseChildren = true;
                     }
                     _loc4_++;
                     continue;
                  }
               }
               if(_loc2_ != 0)
               {
                  this._mediaHelper = new MediaHelper();
                  this._mediaHelper.init(_loc2_,this.onSeedLoaded,{
                     "index":_loc4_,
                     "contIcon":true,
                     "defId":int(_loc7_)
                  });
                  this._mediaItems[_loc4_] = this._mediaHelper;
                  this._mediaHelper = new MediaHelper();
                  this._mediaHelper.init(_loc2_,this.onSeedLoaded,{
                     "index":_loc4_,
                     "contIcon":false,
                     "defId":int(_loc7_)
                  });
                  this._mediaItems[_loc4_ + 1] = this._mediaHelper;
                  _loc4_++;
               }
            }
         }
         while(_loc4_ < this.MAX_NUM_SEEDS)
         {
            _loc3_ = GuiManager.mainHud["inventoriesWindow" + _loc4_];
            if(_loc3_ != null)
            {
               _loc3_.mouseEnabled = false;
               _loc3_.mouseChildren = false;
               _loc3_.visible = false;
            }
            _loc4_++;
         }
      }
      
      private function onSeedLoaded(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         if(param1)
         {
            param1.setAsIcon();
            if(param1.passback.contIcon)
            {
               _loc2_ = GETDEFINITIONBYNAME("vftCont");
               _loc3_ = GuiManager.mainHud["inventoriesWindow" + param1.passback.index];
               _loc4_ = int(this._seedsInventory[param1.passback.defId].count);
               _loc5_ = int(this._seedsInventory[param1.passback.defId].max);
               _loc2_.itemWindow.addChild(param1.getNPC());
               _loc2_.txt.text = _loc4_ + "/" + _loc5_;
               if(_loc4_ == 0)
               {
                  _loc6_ = new Array();
                  _loc6_ = _loc6_.concat([0.33,0.33,0.33,0,0]);
                  _loc6_ = _loc6_.concat([0.33,0.33,0.33,0,0]);
                  _loc6_ = _loc6_.concat([0.33,0.33,0.33,0,0]);
                  _loc6_ = _loc6_.concat([0,0,0,1,0]);
                  _loc2_.filters = [new ColorMatrixFilter(_loc6_)];
                  if(_loc3_ != null)
                  {
                     _loc3_.mouseEnabled = false;
                     _loc3_.mouseChildren = false;
                  }
               }
               else
               {
                  if(_loc4_ >= _loc5_)
                  {
                     _loc2_.gotoAndPlay("on");
                  }
                  _loc2_.filters = null;
                  if(_loc3_ != null)
                  {
                     _loc3_.mouseEnabled = true;
                     _loc3_.mouseChildren = true;
                  }
               }
               if(_loc3_ != null)
               {
                  while(_loc3_.numChildren > 0)
                  {
                     _loc3_.removeChildAt(0);
                  }
                  _loc3_.addChild(_loc2_);
                  _loc3_.addEventListener(MouseEvent.MOUSE_DOWN,this.onSeedsClickStart,false,0,true);
                  _loc3_.visible = true;
               }
            }
            else if(GuiManager.mainHud["inventoriesWindow" + param1.passback.index] != null)
            {
               GuiManager.mainHud["inventoriesWindow" + param1.passback.index].dragIcon = param1;
            }
         }
      }
      
      private function onSeedsClickStart(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._clickStartX = param1.stageX;
         this._clickStartY = param1.stageY;
         if(this._draggedSeed == null || this._draggedSeed.windowName != param1.currentTarget.name)
         {
            if(Boolean(this._draggedSeed) && this._draggedSeed.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(this._draggedSeed);
            }
            this._draggedSeed = param1.currentTarget.dragIcon.getNPC();
            this._draggedSeed.custom = {
               "prevPositionX":0,
               "prevPositionY":0,
               "xOut":false,
               "currWindow":param1.currentTarget
            };
            this._draggedSeed.addEventListener(MouseEvent.MOUSE_UP,this.onSeedsClickStartUp,false,0,true);
            this._draggedSeed.addEventListener(MouseEvent.MOUSE_MOVE,this.onSeedMove,false,0,true);
            this._draggedSeed.addEventListener(MouseEvent.MOUSE_DOWN,this.onSeedsDragDown,false,0,true);
            this._draggedSeed.x = param1.currentTarget.x;
            this._draggedSeed.y = param1.currentTarget.y;
            this._draggedSeed.custom.prevPositionX = 0;
            this._draggedSeed.custom.prevPositionY = 0;
            this._draggedSeed.custom.xOut = false;
            param1.currentTarget.dragIcon.setAsIcon();
            this._draggedSeed.passback = param1.currentTarget.dragIcon.passback;
            GuiManager.guiLayer.addChild(this._draggedSeed);
         }
         this._draggedSeed.startDrag(true);
         QuestManager.playSound("ajq_boomSeedSelect");
      }
      
      private function onSeedsDragDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onSeedsClickStartUp(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(Math.abs(this._clickStartX - param1.stageX) > 2 || Math.abs(this._clickStartY - param1.stageY) > 2)
         {
            this.onSeedsClickEnd(param1);
         }
         else if(this._draggedSeed != null)
         {
            this._clickStartX = -99999;
            this._clickStartY = -99999;
         }
      }
      
      private function onSeedMove(param1:MouseEvent) : void
      {
         var _loc5_:Point = null;
         param1.stopPropagation();
         if(Math.abs(this._clickStartX - param1.stageX) > 2 || Math.abs(this._clickStartY - param1.stageY) > 2)
         {
            this._clickStartX = -99999;
            this._clickStartY = -99999;
         }
         var _loc2_:Number = param1.stageX - this._draggedSeed.custom.prevPositionX;
         var _loc3_:Number = param1.stageY - this._draggedSeed.custom.prevPositionY;
         var _loc4_:Number = _loc2_ * _loc2_ + _loc3_ * _loc3_;
         if(_loc4_ > 9)
         {
            this._draggedSeed.custom.prevPositionX = param1.stageX;
            this._draggedSeed.custom.prevPositionY = param1.stageY;
            _loc5_ = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            if(QuestManager.validatePlantSeedLocation(_loc5_) == false)
            {
               if(!param1.currentTarget.custom.xOut)
               {
                  param1.currentTarget.custom.currWindow.dragIcon.setAsIconX();
                  param1.currentTarget.custom.xOut = true;
               }
            }
            else if(param1.currentTarget.custom.xOut)
            {
               param1.currentTarget.custom.currWindow.dragIcon.setAsIcon();
               param1.currentTarget.custom.xOut = false;
            }
         }
      }
      
      private function onSeedsClickEnd(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Boolean = false;
         param1.stopPropagation();
         if(this._draggedSeed)
         {
            _loc2_ = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            _loc3_ = this._draggedSeed.hitTestObject(this._draggedSeed.custom.currWindow);
            if(!_loc3_)
            {
               if(QuestManager.validatePlantSeedLocation(_loc2_))
               {
                  QuestXtCommManager.sendPlantSeed(this._draggedSeed.passback.defId,_loc2_.x,_loc2_.y);
                  return;
               }
            }
            this.removeLastDraggedSeed();
         }
      }
   }
}

