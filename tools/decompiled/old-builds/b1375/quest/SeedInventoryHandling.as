package quest
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import gui.GuiManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowSatchel;
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
      
      private var _satchelCont:MovieClip;
      
      private var _combinedCurrencyWindow:WindowAndScrollbarGenerator;
      
      public function SeedInventoryHandling()
      {
         super();
      }
      
      public function init(param1:Dictionary) : void
      {
         _mediaItems = [];
         _seedsInventory = param1;
         setupInventoryWindows();
      }
      
      public function destroy() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         if(_draggedSeed && _draggedSeed.parent == GuiManager.guiLayer)
         {
            GuiManager.guiLayer.removeChild(_draggedSeed);
         }
         _draggedSeed = null;
         _loc2_ = 0;
         while(_loc2_ < 5)
         {
            _loc1_ = GuiManager.mainHud["inventoriesWindow" + _loc2_];
            if(_loc1_)
            {
               _loc1_.removeEventListener("mouseDown",onSeedsClickStart);
            }
            _loc2_++;
         }
         if(_satchelCont)
         {
            if(_satchelCont.parent && _satchelCont.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_satchelCont);
            }
            _satchelCont = null;
         }
         if(_combinedCurrencyWindow)
         {
            _combinedCurrencyWindow.destroy();
            _combinedCurrencyWindow = null;
         }
         _seedsInventory = null;
      }
      
      public function updateCombinedCurrency() : void
      {
         if(_combinedCurrencyWindow)
         {
            _combinedCurrencyWindow.callUpdateInWindow();
         }
      }
      
      public function rebuildInventory(param1:Dictionary) : void
      {
         _seedsInventory = param1;
         setupInventoryWindows();
      }
      
      public function removeLastDraggedSeed() : void
      {
         if(_draggedSeed)
         {
            _draggedSeed.removeEventListener("mouseDown",onSeedsDragDown);
            _draggedSeed.removeEventListener("mouseUp",onSeedsClickStartUp);
            _draggedSeed.removeEventListener("mouseMove",onSeedMove);
            _draggedSeed.stopDrag();
            if(_draggedSeed.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_draggedSeed);
            }
            _draggedSeed = null;
         }
      }
      
      private function setupInventoryWindows() : void
      {
         var _loc1_:Object = null;
         var _loc8_:int = 0;
         var _loc7_:MovieClip = null;
         var _loc9_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Object = null;
         var _loc5_:Array = null;
         _mediaItems = [];
         for(var _loc2_:String in _seedsInventory)
         {
            _loc1_ = QuestManager.getNPCDef(int(_loc2_));
            if(_loc1_)
            {
               _loc8_ = int(_loc1_.mediaRefId);
               _loc7_ = GuiManager.mainHud["inventoriesWindow" + _loc9_];
               if(_loc7_ != null && _loc7_.numChildren > 0)
               {
                  _loc6_ = _loc7_.getChildAt(0);
                  if(_loc6_.hasOwnProperty("txt"))
                  {
                     _loc4_ = int(_seedsInventory[_loc2_].count);
                     _loc3_ = int(_seedsInventory[_loc2_].max);
                     _loc6_.txt.text = _loc4_ + "/" + _loc3_;
                     if(_loc4_ == 0)
                     {
                        _loc5_ = [];
                        _loc5_ = _loc5_.concat([0.33,0.33,0.33,0,0]);
                        _loc5_ = _loc5_.concat([0.33,0.33,0.33,0,0]);
                        _loc5_ = _loc5_.concat([0.33,0.33,0.33,0,0]);
                        _loc5_ = _loc5_.concat([0,0,0,1,0]);
                        _loc6_.filters = [new ColorMatrixFilter(_loc5_)];
                        _loc7_.mouseEnabled = false;
                        _loc7_.mouseChildren = false;
                     }
                     else
                     {
                        if(_loc4_ >= _loc3_)
                        {
                           _loc6_.gotoAndPlay("on");
                        }
                        _loc6_.filters = null;
                        _loc7_.mouseEnabled = true;
                        _loc7_.mouseChildren = true;
                     }
                     _loc9_++;
                     continue;
                  }
               }
               if(_loc8_ != 0)
               {
                  _mediaHelper = new MediaHelper();
                  _mediaHelper.init(_loc8_,onSeedLoaded,{
                     "index":_loc9_,
                     "contIcon":true,
                     "defId":int(_loc2_)
                  });
                  _mediaItems[_loc9_] = _mediaHelper;
                  _mediaHelper = new MediaHelper();
                  _mediaHelper.init(_loc8_,onSeedLoaded,{
                     "index":_loc9_,
                     "contIcon":false,
                     "defId":int(_loc2_)
                  });
                  _mediaItems[_loc9_ + 1] = _mediaHelper;
                  _loc9_++;
               }
            }
         }
         while(_loc9_ < 5)
         {
            _loc7_ = GuiManager.mainHud["inventoriesWindow" + _loc9_];
            if(_loc7_ != null)
            {
               _loc7_.mouseEnabled = false;
               _loc7_.mouseChildren = false;
               _loc7_.visible = false;
            }
            _loc9_++;
         }
      }
      
      private function onSeedLoaded(param1:MovieClip) : void
      {
         var _loc5_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:Array = null;
         if(param1)
         {
            if(param1.hasOwnProperty("setAsIcon"))
            {
               param1.setAsIcon();
            }
            if(param1.passback.contIcon)
            {
               if(param1.hasOwnProperty("getNPC"))
               {
                  _loc5_ = GETDEFINITIONBYNAME("vftCont");
               }
               else
               {
                  _loc5_ = GETDEFINITIONBYNAME("vftCont_noCount");
               }
               _loc6_ = GuiManager.mainHud["inventoriesWindow" + param1.passback.index];
               _loc3_ = int(_seedsInventory[param1.passback.defId].count);
               _loc2_ = int(_seedsInventory[param1.passback.defId].max);
               if(param1.hasOwnProperty("getNPC"))
               {
                  _loc5_.itemWindow.addChild(param1.getNPC());
                  _loc5_.txt.text = _loc3_ + "/" + _loc2_;
                  _loc5_.txt.visible = true;
                  _loc6_.dragable = true;
                  if(_loc3_ == 0)
                  {
                     _loc4_ = [];
                     _loc4_ = _loc4_.concat([0.33,0.33,0.33,0,0]);
                     _loc4_ = _loc4_.concat([0.33,0.33,0.33,0,0]);
                     _loc4_ = _loc4_.concat([0.33,0.33,0.33,0,0]);
                     _loc4_ = _loc4_.concat([0,0,0,1,0]);
                     _loc5_.filters = [new ColorMatrixFilter(_loc4_)];
                     if(_loc6_ != null)
                     {
                        _loc6_.mouseEnabled = false;
                        _loc6_.mouseChildren = false;
                     }
                  }
                  else
                  {
                     if(_loc3_ >= _loc2_)
                     {
                        _loc5_.gotoAndPlay("on");
                     }
                     _loc5_.filters = null;
                     if(_loc6_ != null)
                     {
                        _loc6_.mouseEnabled = true;
                        _loc6_.mouseChildren = true;
                     }
                  }
               }
               else
               {
                  _loc5_.itemWindow.addChild(param1);
                  _loc6_.mouseEnabled = true;
                  _loc6_.mouseChildren = true;
                  _loc6_.dragable = false;
               }
               if(_loc6_ != null)
               {
                  while(_loc6_.numChildren > 0)
                  {
                     _loc6_.removeChildAt(0);
                  }
                  _loc6_.addChild(_loc5_);
                  _loc6_.addEventListener("mouseDown",onSeedsClickStart,false,0,true);
                  _loc6_.visible = true;
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
         _clickStartX = param1.stageX;
         _clickStartY = param1.stageY;
         if(param1.currentTarget.dragable)
         {
            if(_draggedSeed == null || _draggedSeed.windowName != param1.currentTarget.name)
            {
               if(_draggedSeed && _draggedSeed.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_draggedSeed);
               }
               _draggedSeed = param1.currentTarget.dragIcon.getNPC();
               _draggedSeed.custom = {
                  "prevPositionX":0,
                  "prevPositionY":0,
                  "xOut":false,
                  "currWindow":param1.currentTarget
               };
               _draggedSeed.addEventListener("mouseUp",onSeedsClickStartUp,false,0,true);
               _draggedSeed.addEventListener("mouseMove",onSeedMove,false,0,true);
               _draggedSeed.addEventListener("mouseDown",onSeedsDragDown,false,0,true);
               _draggedSeed.x = param1.currentTarget.x;
               _draggedSeed.y = param1.currentTarget.y;
               _draggedSeed.custom.prevPositionX = 0;
               _draggedSeed.custom.prevPositionY = 0;
               _draggedSeed.custom.xOut = false;
               param1.currentTarget.dragIcon.setAsIcon();
               _draggedSeed.passback = param1.currentTarget.dragIcon.passback;
               GuiManager.guiLayer.addChild(_draggedSeed);
            }
            _draggedSeed.startDrag(true);
            QuestManager.playSound("ajq_boomSeedSelect");
         }
         else
         {
            if(!_satchelCont)
            {
               _satchelCont = GETDEFINITIONBYNAME("craftSatchelCont");
            }
            if(!_combinedCurrencyWindow)
            {
               _combinedCurrencyWindow = new WindowAndScrollbarGenerator();
               _combinedCurrencyWindow.init(_satchelCont.itemWindow.width,_satchelCont.itemWindow.height,-25,0,1,7,0,0,3,0,1.5,ItemWindowSatchel,[4143,4138,4144,4142,4141,4140,4139],"",0,null,{
                  "scale":0.7,
                  "frame":"adv"
               });
               _satchelCont.itemWindow.addChild(_combinedCurrencyWindow);
               _satchelCont.x = param1.currentTarget.x - param1.currentTarget.width * 0.5;
               _satchelCont.y = param1.currentTarget.y + param1.currentTarget.height * 0.25 - 5;
               GuiManager.guiLayer.addChildAt(_satchelCont,GuiManager.guiLayer.getChildIndex(param1.currentTarget.parent as MovieClip));
            }
            else if(_satchelCont.visible)
            {
               _satchelCont.visible = false;
            }
            else
            {
               _combinedCurrencyWindow.callUpdateInWindow();
               _satchelCont.visible = true;
            }
         }
      }
      
      private function onSeedsDragDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onSeedsClickStartUp(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(Math.abs(_clickStartX - param1.stageX) > 2 || Math.abs(_clickStartY - param1.stageY) > 2)
         {
            onSeedsClickEnd(param1);
         }
         else if(_draggedSeed != null)
         {
            _clickStartX = -99999;
            _clickStartY = -99999;
         }
      }
      
      private function onSeedMove(param1:MouseEvent) : void
      {
         var _loc3_:Point = null;
         param1.stopPropagation();
         if(Math.abs(_clickStartX - param1.stageX) > 2 || Math.abs(_clickStartY - param1.stageY) > 2)
         {
            _clickStartX = -99999;
            _clickStartY = -99999;
         }
         var _loc4_:Number = param1.stageX - _draggedSeed.custom.prevPositionX;
         var _loc5_:Number = param1.stageY - _draggedSeed.custom.prevPositionY;
         var _loc2_:Number = _loc4_ * _loc4_ + _loc5_ * _loc5_;
         if(_loc2_ > 9)
         {
            _draggedSeed.custom.prevPositionX = param1.stageX;
            _draggedSeed.custom.prevPositionY = param1.stageY;
            _loc3_ = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            if(QuestManager.validatePlantSeedLocation(_loc3_) == false)
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
         if(_draggedSeed)
         {
            _loc2_ = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            _loc3_ = _draggedSeed.hitTestObject(_draggedSeed.custom.currWindow);
            if(!_loc3_)
            {
               if(QuestManager.validatePlantSeedLocation(_loc2_))
               {
                  QuestXtCommManager.sendPlantSeed(_draggedSeed.passback.defId,_loc2_.x,_loc2_.y);
                  return;
               }
            }
            removeLastDraggedSeed();
         }
      }
   }
}

