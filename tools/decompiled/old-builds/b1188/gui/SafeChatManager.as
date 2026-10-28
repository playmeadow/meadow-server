package gui
{
   import com.sbi.debug.DebugUtility;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import localization.LocalizationManager;
   
   public class SafeChatManager
   {
      
      public static var sctNodes:Array;
      
      public static var ctNodes:Array;
      
      public static var photoBoothNodes:Array;
      
      public static var adventureNodes:Array;
      
      private static var SafeChatTreeNode:Class;
      
      private static var _safeChatCallback:Function;
      
      private static var _safeChatCallbackFromOtherSystem:Function;
      
      private static var _safeChatBtn:MovieClip;
      
      private static var _safeChatTree:MovieClip;
      
      private static var _actionBtn:MovieClip;
      
      private static var _actionWindow:Sprite;
      
      private static var _emoteBtn:MovieClip;
      
      private static var _emoteWindow:Sprite;
      
      private static var _treeArray:Array;
      
      private static var _nodeYLocation:Number;
      
      private static var _lowestNodeYLocation:Number;
      
      private static var _safeTreeNodeHeight:Number;
      
      private static var _safeChatTreeNodes:MovieClip;
      
      public static const TREE_SAFECHAT:int = 0;
      
      public static const TREE_ECARDTEXT:int = 1;
      
      public static const TREE_REPORTREASON:int = 2;
      
      public static const TREE_PHOTOBOOTH:int = 3;
      
      public static const TREE_ADVENTURE:int = 4;
      
      private static const SCT_DIM_ALPHA:Number = 0.5;
      
      private static const SCT_BRIGHT_ALPHA:Number = 1;
      
      private static const JAG_LOCALIZATION_ID:int = 66;
      
      private static const BC_LOCALIZATION_ID:int = 47;
      
      private static const PHOTOBOOTH_LOCALIZATION_ID:int = 158;
      
      private static const ADVENTURE_LOCALIZATION_ID:int = 170;
      
      public function SafeChatManager()
      {
         super();
      }
      
      public static function init(param1:Function, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:Sprite, param6:MovieClip, param7:Sprite) : void
      {
         if(_safeChatCallback != null)
         {
            throw new Error("ERROR: Singleton SafeChatManager did not expect to be created twice!");
         }
         _safeChatCallback = param1;
         _safeChatBtn = param2;
         _safeChatTree = param3;
         if(sctNodes)
         {
            buildSafeChatTree(_safeChatTree);
         }
         _safeChatTree.visible = false;
         _actionBtn = param4;
         _actionWindow = param5;
         _emoteBtn = param6;
         _emoteWindow = param7;
      }
      
      public static function reload(param1:Boolean, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:Sprite, param6:MovieClip, param7:Sprite) : void
      {
         _safeChatTree = param3;
         _safeChatBtn = param2;
         _safeChatTree.visible = false;
         _actionBtn = param4;
         _actionWindow = param5;
         _emoteBtn = param6;
         _emoteWindow = param7;
         if(param1)
         {
            while(_safeChatTree.numChildren > 1)
            {
               _safeChatTree.removeChildAt(_safeChatTree.numChildren - 1);
            }
            ctNodes = sctNodes = photoBoothNodes = adventureNodes = null;
            requestSafeChatLists();
         }
         else if(_safeChatTree.numChildren < 2)
         {
            _safeChatTree.addChild(_safeChatTreeNodes);
         }
         _safeChatBtn.downToUpState();
      }
      
      public static function buildSafeChatTree(param1:MovieClip, param2:String = null, param3:int = 0, param4:Function = null, param5:Array = null) : void
      {
         var _loc6_:MovieClip = null;
         var _loc7_:int = 0;
         var _loc8_:uint = 0;
         var _loc9_:MovieClip = null;
         _safeChatCallbackFromOtherSystem = param4;
         if(param2 == null)
         {
            param2 = "SafeChatTreeNode";
         }
         SafeChatTreeNode = getDefinitionByName(param2) as Class;
         if(param5 != null)
         {
            _treeArray = param5;
         }
         else if(param3 == TREE_ECARDTEXT)
         {
            _treeArray = ctNodes;
         }
         else if(param3 == TREE_PHOTOBOOTH)
         {
            _treeArray = photoBoothNodes;
         }
         else if(param3 == TREE_ADVENTURE)
         {
            _treeArray = adventureNodes;
         }
         else
         {
            _treeArray = sctNodes;
         }
         if(_treeArray)
         {
            _loc6_ = new SafeChatTreeNode();
            _loc7_ = param1.height - (_treeArray.length * _loc6_.height - 1);
            _safeChatTreeNodes = new MovieClip();
            _loc8_ = 0;
            while(_loc8_ < _treeArray.length)
            {
               _loc9_ = new SafeChatTreeNode();
               _loc9_.x = 0;
               _loc9_.y = _loc7_ + _loc8_ * (_loc9_.height - 1);
               _safeChatTreeNodes.addChild(_loc9_);
               _loc9_["menuNums"] = [_loc8_];
               _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,sctNodeMouseHandler,false,0,true);
               if(_treeArray[_loc8_] is String)
               {
                  LocalizationManager.updateToFit(_loc9_.sctNodeTxt,_treeArray[_loc8_]);
                  _loc9_.sctNodeBG.gotoAndStop(1);
               }
               else
               {
                  if(!(_treeArray[_loc8_] is Array))
                  {
                     throw new Error("invalid type in sctNodes...");
                  }
                  _safeTreeNodeHeight = _loc9_.height;
                  _lowestNodeYLocation = _loc7_ + (_treeArray.length - 1) * (_safeTreeNodeHeight - 1);
                  _nodeYLocation = _loc9_.y;
                  LocalizationManager.updateToFit(_loc9_.sctNodeTxt,_treeArray[_loc8_][0]);
                  _loc9_.sctNodeBG.gotoAndStop(3);
                  buildChatTreeSubMenu(_treeArray[_loc8_],DisplayObjectContainer(_loc9_),0);
               }
               _loc8_++;
            }
            param1.addChild(_safeChatTreeNodes);
         }
      }
      
      public static function requestSafeChatLists() : void
      {
         GenericListXtCommManager.requestGenericList(BC_LOCALIZATION_ID,onListLoaded);
         GenericListXtCommManager.requestGenericList(JAG_LOCALIZATION_ID,onListLoaded);
         GenericListXtCommManager.requestGenericList(PHOTOBOOTH_LOCALIZATION_ID,onListLoaded);
         GenericListXtCommManager.requestGenericList(ADVENTURE_LOCALIZATION_ID,onListLoaded);
      }
      
      public static function containsInTreeArray(param1:String, param2:int = 0) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:Boolean = false;
         var _loc5_:Array = null;
         var _loc7_:int = 0;
         if(param2 == TREE_ECARDTEXT)
         {
            _loc5_ = ctNodes;
         }
         else if(param2 == TREE_PHOTOBOOTH)
         {
            _loc5_ = photoBoothNodes;
         }
         else if(param2 == TREE_ADVENTURE)
         {
            _loc5_ = adventureNodes;
         }
         else
         {
            _loc5_ = sctNodes;
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.length)
         {
            _loc3_ = _loc5_[_loc6_];
            if(_loc3_ is Array)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc3_.length)
               {
                  if(_loc3_[_loc7_] == param1)
                  {
                     return true;
                  }
                  _loc7_++;
               }
            }
            else if(_loc3_ == param1)
            {
               return true;
            }
            _loc6_++;
         }
         return false;
      }
      
      private static function onListLoaded(param1:int, param2:Array) : void
      {
         var _loc3_:RegExp = null;
         var _loc5_:Array = null;
         if(gMainFrame.server.isBlueboxMode())
         {
            _loc3_ = /&#10/g;
         }
         else
         {
            _loc3_ = /\r\n|\n|\r/g;
         }
         var _loc4_:Array = [];
         var _loc6_:int = 0;
         while(_loc6_ < param2.length)
         {
            _loc5_ = LocalizationManager.translateIdOnly(param2[_loc6_]).split(_loc3_);
            if(_loc5_.length == 1)
            {
               _loc4_.push(_loc5_[0]);
            }
            else
            {
               _loc4_.push(_loc5_);
            }
            _loc6_++;
         }
         if(param1 == BC_LOCALIZATION_ID)
         {
            sctNodes = _loc4_;
         }
         else if(param1 == JAG_LOCALIZATION_ID)
         {
            ctNodes = _loc4_;
         }
         else if(param1 == PHOTOBOOTH_LOCALIZATION_ID)
         {
            photoBoothNodes = _loc4_;
         }
         else if(param1 == ADVENTURE_LOCALIZATION_ID)
         {
            adventureNodes = _loc4_;
         }
         else
         {
            DebugUtility.debugTrace("Loaded safe chat list that doesn\'t match!");
         }
         if(Boolean(ctNodes) && Boolean(sctNodes) && Boolean(photoBoothNodes) && Boolean(adventureNodes))
         {
            buildSafeChatTree(_safeChatTree);
         }
      }
      
      private static function buildChatTreeSubMenu(param1:Array, param2:DisplayObjectContainer, param3:uint) : void
      {
         var _loc6_:MovieClip = null;
         var _loc7_:uint = 0;
         var _loc8_:DisplayObjectContainer = null;
         param3++;
         var _loc4_:Number = _nodeYLocation + (param1.length - 2) * (_safeTreeNodeHeight - 1);
         if(_loc4_ > _lowestNodeYLocation)
         {
            _nodeYLocation -= _loc4_ - _lowestNodeYLocation;
         }
         var _loc5_:uint = 1;
         while(_loc5_ < param1.length)
         {
            _loc6_ = new SafeChatTreeNode();
            _loc6_.x = param3 * _loc6_.width - param2.x;
            _loc6_.y = _nodeYLocation + (_loc5_ - 1) * (_loc6_.height - 1);
            _loc7_ = param3;
            _loc8_ = param2;
            while(_loc7_ > 0)
            {
               _loc6_.y -= _loc8_.y;
               _loc8_ = _loc8_.parent;
               _loc7_--;
            }
            param2.addChild(_loc6_);
            _loc6_.visible = false;
            if(_loc6_.parent["menuNums"])
            {
               _loc6_["menuNums"] = _loc6_.parent["menuNums"].slice();
               _loc6_["menuNums"].push(_loc5_);
            }
            else
            {
               _loc6_["menuNums"] = [_loc5_];
            }
            _loc6_.addEventListener(MouseEvent.MOUSE_DOWN,sctNodeMouseHandler,false,0,true);
            if(param1[_loc5_] is String)
            {
               LocalizationManager.updateToFit(_loc6_.sctNodeTxt,param1[_loc5_]);
               _loc6_.sctNodeBG.gotoAndStop(1);
            }
            else
            {
               if(!(param1[_loc5_] is Array))
               {
                  throw new Error("invalid type in scSubTree...");
               }
               LocalizationManager.updateToFit(_loc6_.sctNodeTxt,param1[_loc5_][0]);
               _loc6_.sctNodeBG.gotoAndStop(3);
               buildChatTreeSubMenu(param1[_loc5_],DisplayObjectContainer(_loc6_),param3);
            }
            _loc5_++;
         }
      }
      
      public static function destroy(param1:MovieClip = null) : void
      {
         if(param1 != null)
         {
            while(param1.numChildren > 1)
            {
               param1.getChildAt(param1.numChildren - 1).removeEventListener(MouseEvent.MOUSE_DOWN,sctNodeMouseHandler);
               param1.removeChildAt(param1.numChildren - 1);
            }
            _safeChatCallbackFromOtherSystem = null;
            param1.visible = false;
            param1 = null;
         }
         else
         {
            while(_safeChatTree.numChildren > 0)
            {
               _safeChatTree.getChildAt(0).removeEventListener(MouseEvent.MOUSE_DOWN,sctNodeMouseHandler);
               _safeChatTree.removeChildAt(0);
            }
            _safeChatBtn = null;
            _safeChatTree.visible = false;
            _safeChatTree = null;
            _actionBtn = null;
            _actionWindow = null;
            _emoteBtn = null;
            _emoteWindow = null;
         }
      }
      
      public static function traceDisplayList(param1:DisplayObjectContainer, param2:String = "") : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:uint = 0;
         while(_loc4_ < param1.numChildren)
         {
            _loc3_ = param1.getChildAt(_loc4_);
            if(_loc3_ == null)
            {
               DebugUtility.debugTrace(param2 + "NULL?!");
            }
            else
            {
               DebugUtility.debugTrace(param2 + " " + _loc3_ + " " + _loc3_.name);
            }
            if(_loc3_ is DisplayObjectContainer)
            {
               traceDisplayList(DisplayObjectContainer(_loc3_),param2 + "    ");
            }
            _loc4_++;
         }
      }
      
      public static function resetSafeChatTree(param1:Boolean, param2:MovieClip = null) : void
      {
         var _loc5_:DisplayObject = null;
         var _loc6_:DisplayObjectContainer = null;
         var _loc7_:uint = 0;
         var _loc8_:DisplayObject = null;
         if(param1)
         {
            SafeChatTreeNode = getDefinitionByName("SafeChatTreeNode") as Class;
         }
         var _loc3_:MovieClip = MovieClip(_safeChatTree.getChildAt(1));
         if(param2)
         {
            _loc3_ = param2;
         }
         var _loc4_:uint = 0;
         while(_loc4_ < _loc3_.numChildren)
         {
            _loc5_ = _loc3_.getChildAt(_loc4_);
            if((Boolean(_loc5_)) && _loc5_ is DisplayObjectContainer)
            {
               if(_loc5_ is SafeChatTreeNode)
               {
                  if(SafeChatTreeNode(_loc5_).sctNodeBG.currentFrame == 4)
                  {
                     SafeChatTreeNode(_loc5_).sctNodeBG.gotoAndStop(3);
                  }
                  if(SafeChatTreeNode(_loc5_).sctNodeBG.currentFrame == 2)
                  {
                     SafeChatTreeNode(_loc5_).sctNodeBG.gotoAndStop(1);
                  }
               }
               _loc6_ = DisplayObjectContainer(_loc5_);
               _loc7_ = 0;
               while(_loc7_ < _loc6_.numChildren)
               {
                  _loc8_ = _loc6_.getChildAt(_loc7_);
                  if((Boolean(_loc8_)) && _loc8_ is SafeChatTreeNode)
                  {
                     _loc8_.visible = false;
                     SafeChatTreeNode(_loc8_).sctNodeBG.gotoAndStop(1);
                  }
                  _loc7_++;
               }
            }
            _loc4_++;
         }
      }
      
      public static function showSafeChatInput(param1:Boolean) : void
      {
         _safeChatBtn.visible = param1;
         _safeChatTree.visible = param1;
      }
      
      public static function safeChatCodeForString(param1:String, param2:int = -1) : String
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc6_:int = 0;
         if(param2 != -1 || _treeArray == null)
         {
            if(param2 == TREE_ECARDTEXT)
            {
               _loc3_ = ctNodes;
            }
            else if(param2 == TREE_PHOTOBOOTH)
            {
               _loc3_ = photoBoothNodes;
            }
            else if(param2 == TREE_ADVENTURE)
            {
               _loc3_ = adventureNodes;
            }
            else
            {
               _loc3_ = sctNodes;
            }
         }
         else
         {
            _loc3_ = _treeArray;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            if(_loc3_[_loc5_] is String)
            {
               if(_loc3_[_loc5_] == param1)
               {
                  return _loc5_ + "0";
               }
            }
            else
            {
               _loc4_ = _loc3_[_loc5_][0];
               if(param1 == _loc4_)
               {
                  return String(_loc5_);
               }
               _loc6_ = 1;
               while(_loc6_ < _loc3_[_loc5_].length)
               {
                  if(_loc4_.indexOf("...") > -1)
                  {
                     if(param1 == _loc4_.substr(0,_loc4_.length - 3) + " " + _loc3_[_loc5_][_loc6_])
                     {
                        return _loc5_ + "," + _loc6_;
                     }
                  }
                  else if(_loc3_[_loc5_][_loc6_] == param1)
                  {
                     return _loc5_ + "," + _loc6_;
                  }
                  _loc6_++;
               }
            }
            _loc5_++;
         }
         return null;
      }
      
      public static function safeChatStringForCode(param1:String, param2:int = -1) : String
      {
         var _loc5_:String = null;
         var _loc3_:Array = param1.split(",");
         if(param2 != -1 || _treeArray == null)
         {
            if(param2 == TREE_ECARDTEXT)
            {
               _treeArray = ctNodes;
            }
            else if(param2 == TREE_PHOTOBOOTH)
            {
               _treeArray = photoBoothNodes;
            }
            else if(param2 == TREE_ADVENTURE)
            {
               _treeArray = adventureNodes;
            }
            else
            {
               _treeArray = sctNodes;
            }
         }
         else if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST)
         {
            _treeArray = adventureNodes;
         }
         else
         {
            _treeArray = sctNodes;
         }
         var _loc4_:Array = _treeArray;
         var _loc6_:uint = 0;
         while(_loc6_ < _loc3_.length)
         {
            if(_loc6_ >= _loc3_.length - 1)
            {
               if(_loc4_[_loc3_[_loc6_]] is String)
               {
                  if(Boolean(_loc5_) && Boolean(_loc5_.indexOf("...") > 0) && _loc5_.indexOf("...") == _loc5_.length - 3)
                  {
                     return _loc5_.substr(0,_loc5_.length - 3) + " " + _loc4_[_loc3_[_loc6_]];
                  }
                  return _loc4_[_loc3_[_loc6_]];
               }
               if(_loc4_[_loc3_[_loc6_]] is Array)
               {
                  return _loc4_[_loc3_[_loc6_]][0];
               }
               return null;
            }
            if(_loc4_[_loc3_[_loc6_]] is String)
            {
               return null;
            }
            if(!(_loc4_[_loc3_[_loc6_]] is Array))
            {
               return null;
            }
            _loc5_ = _loc4_[_loc3_[_loc6_]][0];
            _loc4_ = _loc4_[_loc3_[_loc6_]];
            _loc6_++;
         }
         return null;
      }
      
      public static function openSafeChat(param1:Boolean, param2:MovieClip = null) : void
      {
         if(Boolean(param2) && !param2.visible)
         {
            param2.visible = true;
            resetSafeChatTree(param1,MovieClip(param2.getChildAt(1)));
         }
         else if(!_safeChatTree.visible)
         {
            _safeChatTree.visible = true;
            resetSafeChatTree(param1);
            brightenSafeChat();
         }
      }
      
      public static function dimSafeChat() : void
      {
         if(_safeChatTree.visible && _safeChatTree.alpha != SCT_DIM_ALPHA)
         {
            _safeChatTree.alpha = SCT_DIM_ALPHA;
         }
      }
      
      public static function brightenSafeChat() : void
      {
         if(_safeChatTree.alpha != SCT_BRIGHT_ALPHA)
         {
            _safeChatTree.alpha = SCT_BRIGHT_ALPHA;
         }
      }
      
      public static function closeSafeChat(param1:MovieClip = null) : void
      {
         if(Boolean(param1) && param1.visible)
         {
            param1.visible = false;
         }
         if(_safeChatTree)
         {
            if(_safeChatTree.visible)
            {
               _safeChatTree.visible = false;
            }
            _safeChatBtn.downToUpState();
         }
      }
      
      public static function showHide() : void
      {
         _safeChatTree.visible = !_safeChatTree.visible;
      }
      
      public static function sctNodeMouseHandler(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         param1.stopPropagation();
         brightenSafeChat();
         if(!param1.currentTarget is SafeChatTreeNode)
         {
            DebugUtility.debugTrace("ERROR: illegal event type in sctNodeMouseHandler!");
            return;
         }
         if(!Utility.canChat())
         {
            return;
         }
         var _loc2_:String = param1.currentTarget.sctNodeTxt.text;
         if(_loc2_.indexOf("...") >= 0)
         {
            return;
         }
         if(param1.currentTarget.parent.sctNodeTxt)
         {
            _loc3_ = param1.currentTarget.parent.sctNodeTxt.text;
            if(_loc3_.indexOf("...") > 0)
            {
               _loc2_ = _loc3_.slice(0,_loc3_.indexOf("...")) + " " + _loc2_;
            }
         }
         if(_safeChatCallbackFromOtherSystem != null)
         {
            _safeChatCallbackFromOtherSystem(_loc2_,param1.currentTarget.menuNums.toString());
         }
         else
         {
            _safeChatCallback(_loc2_,param1.currentTarget.menuNums.toString());
         }
      }
   }
}

