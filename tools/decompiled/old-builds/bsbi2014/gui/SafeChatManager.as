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
      
      public static function init(safeChatSendCallback:Function, safeChatButton:MovieClip, safeChatTreeGui:MovieClip, actBtn:MovieClip, actWindow:Sprite, emoticonBtn:MovieClip, emoticonWindow:Sprite) : void
      {
         if(_safeChatCallback != null)
         {
            throw new Error("ERROR: Singleton SafeChatManager did not expect to be created twice!");
         }
         _safeChatCallback = safeChatSendCallback;
         _safeChatBtn = safeChatButton;
         _safeChatTree = safeChatTreeGui;
         if(Boolean(sctNodes))
         {
            buildSafeChatTree(_safeChatTree);
         }
         _safeChatTree.visible = false;
         _actionBtn = actBtn;
         _actionWindow = actWindow;
         _emoteBtn = emoticonBtn;
         _emoteWindow = emoticonWindow;
      }
      
      public static function reload(reloadLists:Boolean, safeChatButton:MovieClip, safeChatTreeGui:MovieClip, actBtn:MovieClip, actWindow:Sprite, emoticonBtn:MovieClip, emoticonWindow:Sprite) : void
      {
         _safeChatTree = safeChatTreeGui;
         _safeChatBtn = safeChatButton;
         _safeChatTree.visible = false;
         _actionBtn = actBtn;
         _actionWindow = actWindow;
         _emoteBtn = emoticonBtn;
         _emoteWindow = emoticonWindow;
         if(reloadLists)
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
      
      public static function buildSafeChatTree(safeChatTreeGui:MovieClip, definitionName:String = null, type:int = 0, safeChatSendCallback:Function = null, initArray:Array = null) : void
      {
         var sizingNode:MovieClip = null;
         var startingHeight:int = 0;
         var i:uint = 0;
         var n:MovieClip = null;
         _safeChatCallbackFromOtherSystem = safeChatSendCallback;
         if(definitionName == null)
         {
            definitionName = "SafeChatTreeNode";
         }
         SafeChatTreeNode = getDefinitionByName(definitionName) as Class;
         if(initArray != null)
         {
            _treeArray = initArray;
         }
         else if(type == TREE_ECARDTEXT)
         {
            _treeArray = ctNodes;
         }
         else if(type == TREE_PHOTOBOOTH)
         {
            _treeArray = photoBoothNodes;
         }
         else if(type == TREE_ADVENTURE)
         {
            _treeArray = adventureNodes;
         }
         else
         {
            _treeArray = sctNodes;
         }
         if(Boolean(_treeArray))
         {
            sizingNode = new SafeChatTreeNode();
            startingHeight = safeChatTreeGui.height - (_treeArray.length * sizingNode.height - 1);
            _safeChatTreeNodes = new MovieClip();
            for(i = 0; i < _treeArray.length; i++)
            {
               n = new SafeChatTreeNode();
               n.x = 0;
               n.y = startingHeight + i * (n.height - 1);
               _safeChatTreeNodes.addChild(n);
               n["menuNums"] = [i];
               n.addEventListener(MouseEvent.MOUSE_DOWN,sctNodeMouseHandler,false,0,true);
               if(_treeArray[i] is String)
               {
                  LocalizationManager.updateToFit(n.sctNodeTxt,_treeArray[i]);
                  n.sctNodeBG.gotoAndStop(1);
               }
               else
               {
                  if(!(_treeArray[i] is Array))
                  {
                     throw new Error("invalid type in sctNodes...");
                  }
                  _safeTreeNodeHeight = n.height;
                  _lowestNodeYLocation = startingHeight + (_treeArray.length - 1) * (_safeTreeNodeHeight - 1);
                  _nodeYLocation = n.y;
                  LocalizationManager.updateToFit(n.sctNodeTxt,_treeArray[i][0]);
                  n.sctNodeBG.gotoAndStop(3);
                  buildChatTreeSubMenu(_treeArray[i],DisplayObjectContainer(n),0);
               }
            }
            safeChatTreeGui.addChild(_safeChatTreeNodes);
         }
      }
      
      public static function requestSafeChatLists() : void
      {
         GenericListXtCommManager.requestGenericList(BC_LOCALIZATION_ID,onListLoaded);
         GenericListXtCommManager.requestGenericList(JAG_LOCALIZATION_ID,onListLoaded);
         GenericListXtCommManager.requestGenericList(PHOTOBOOTH_LOCALIZATION_ID,onListLoaded);
         GenericListXtCommManager.requestGenericList(ADVENTURE_LOCALIZATION_ID,onListLoaded);
      }
      
      public static function containsInTreeArray(txt:String, type:int = 0) : Boolean
      {
         var currItem:Object = null;
         var found:Boolean = false;
         var treeArray:Array = null;
         var j:int = 0;
         if(type == TREE_ECARDTEXT)
         {
            treeArray = ctNodes;
         }
         else if(type == TREE_PHOTOBOOTH)
         {
            treeArray = photoBoothNodes;
         }
         else if(type == TREE_ADVENTURE)
         {
            treeArray = adventureNodes;
         }
         else
         {
            treeArray = sctNodes;
         }
         for(var i:int = 0; i < treeArray.length; i++)
         {
            currItem = treeArray[i];
            if(currItem is Array)
            {
               for(j = 0; j < currItem.length; j++)
               {
                  if(currItem[j] == txt)
                  {
                     return true;
                  }
               }
            }
            else if(currItem == txt)
            {
               return true;
            }
         }
         return false;
      }
      
      private static function onListLoaded(glId:int, locStrs:Array) : void
      {
         var delim:RegExp = null;
         var splitArray:Array = null;
         if(gMainFrame.server.isBlueboxMode())
         {
            delim = /&#10/g;
         }
         else
         {
            delim = /\r\n|\n|\r/g;
         }
         var tempArray:Array = [];
         for(var i:int = 0; i < locStrs.length; i++)
         {
            splitArray = LocalizationManager.translateIdOnly(locStrs[i]).split(delim);
            if(splitArray.length == 1)
            {
               tempArray.push(splitArray[0]);
            }
            else
            {
               tempArray.push(splitArray);
            }
         }
         if(glId == BC_LOCALIZATION_ID)
         {
            sctNodes = tempArray;
         }
         else if(glId == JAG_LOCALIZATION_ID)
         {
            ctNodes = tempArray;
         }
         else if(glId == PHOTOBOOTH_LOCALIZATION_ID)
         {
            photoBoothNodes = tempArray;
         }
         else if(glId == ADVENTURE_LOCALIZATION_ID)
         {
            adventureNodes = tempArray;
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
      
      private static function buildChatTreeSubMenu(scSubTree:Array, parentNode:DisplayObjectContainer, level:uint) : void
      {
         var sn:MovieClip = null;
         var sil:uint = 0;
         var doc:DisplayObjectContainer = null;
         level++;
         var outOfBoundYLocation:Number = _nodeYLocation + (scSubTree.length - 2) * (_safeTreeNodeHeight - 1);
         if(outOfBoundYLocation > _lowestNodeYLocation)
         {
            _nodeYLocation -= outOfBoundYLocation - _lowestNodeYLocation;
         }
         for(var si:uint = 1; si < scSubTree.length; si++)
         {
            sn = new SafeChatTreeNode();
            sn.x = level * sn.width - parentNode.x;
            sn.y = _nodeYLocation + (si - 1) * (sn.height - 1);
            sil = level;
            doc = parentNode;
            while(sil > 0)
            {
               sn.y -= doc.y;
               doc = doc.parent;
               sil--;
            }
            parentNode.addChild(sn);
            sn.visible = false;
            if(Boolean(sn.parent["menuNums"]))
            {
               sn["menuNums"] = sn.parent["menuNums"].slice();
               sn["menuNums"].push(si);
            }
            else
            {
               sn["menuNums"] = [si];
            }
            sn.addEventListener(MouseEvent.MOUSE_DOWN,sctNodeMouseHandler,false,0,true);
            if(scSubTree[si] is String)
            {
               LocalizationManager.updateToFit(sn.sctNodeTxt,scSubTree[si]);
               sn.sctNodeBG.gotoAndStop(1);
            }
            else
            {
               if(!(scSubTree[si] is Array))
               {
                  throw new Error("invalid type in scSubTree...");
               }
               LocalizationManager.updateToFit(sn.sctNodeTxt,scSubTree[si][0]);
               sn.sctNodeBG.gotoAndStop(3);
               buildChatTreeSubMenu(scSubTree[si],DisplayObjectContainer(sn),level);
            }
         }
      }
      
      public static function destroy(tree:MovieClip = null) : void
      {
         if(tree != null)
         {
            while(tree.numChildren > 1)
            {
               tree.getChildAt(tree.numChildren - 1).removeEventListener(MouseEvent.MOUSE_DOWN,sctNodeMouseHandler);
               tree.removeChildAt(tree.numChildren - 1);
            }
            _safeChatCallbackFromOtherSystem = null;
            tree.visible = false;
            tree = null;
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
      
      public static function traceDisplayList(container:DisplayObjectContainer, indentString:String = "") : void
      {
         var child:DisplayObject = null;
         for(var i:uint = 0; i < container.numChildren; i++)
         {
            child = container.getChildAt(i);
            if(child == null)
            {
               DebugUtility.debugTrace(indentString + "NULL?!");
            }
            else
            {
               DebugUtility.debugTrace(indentString + " " + child + " " + child.name);
            }
            if(child is DisplayObjectContainer)
            {
               traceDisplayList(DisplayObjectContainer(child),indentString + "    ");
            }
         }
      }
      
      public static function resetSafeChatTree(isFromSafeChat:Boolean, tree:MovieClip = null) : void
      {
         var ro:DisplayObject = null;
         var roc:DisplayObjectContainer = null;
         var rr:uint = 0;
         var dr:DisplayObject = null;
         if(isFromSafeChat)
         {
            SafeChatTreeNode = getDefinitionByName("SafeChatTreeNode") as Class;
         }
         var tempTree:MovieClip = MovieClip(_safeChatTree.getChildAt(1));
         if(Boolean(tree))
         {
            tempTree = tree;
         }
         for(var r:uint = 0; r < tempTree.numChildren; r++)
         {
            ro = tempTree.getChildAt(r);
            if(Boolean(ro) && ro is DisplayObjectContainer)
            {
               if(ro is SafeChatTreeNode)
               {
                  if(SafeChatTreeNode(ro).sctNodeBG.currentFrame == 4)
                  {
                     SafeChatTreeNode(ro).sctNodeBG.gotoAndStop(3);
                  }
                  if(SafeChatTreeNode(ro).sctNodeBG.currentFrame == 2)
                  {
                     SafeChatTreeNode(ro).sctNodeBG.gotoAndStop(1);
                  }
               }
               roc = DisplayObjectContainer(ro);
               for(rr = 0; rr < roc.numChildren; rr++)
               {
                  dr = roc.getChildAt(rr);
                  if(Boolean(dr) && dr is SafeChatTreeNode)
                  {
                     dr.visible = false;
                     SafeChatTreeNode(dr).sctNodeBG.gotoAndStop(1);
                  }
               }
            }
         }
      }
      
      public static function showSafeChatInput(flag:Boolean) : void
      {
         _safeChatBtn.visible = flag;
         _safeChatTree.visible = flag;
      }
      
      public static function safeChatCodeForString(msg:String, treeType:int = -1) : String
      {
         var currMenu:Array = null;
         var parentMenuStr:String = null;
         var j:int = 0;
         if(treeType != -1 || _treeArray == null)
         {
            if(treeType == TREE_ECARDTEXT)
            {
               currMenu = ctNodes;
            }
            else if(treeType == TREE_PHOTOBOOTH)
            {
               currMenu = photoBoothNodes;
            }
            else if(treeType == TREE_ADVENTURE)
            {
               currMenu = adventureNodes;
            }
            else
            {
               currMenu = sctNodes;
            }
         }
         else
         {
            currMenu = _treeArray;
         }
         for(var i:int = 0; i < currMenu.length; i++)
         {
            if(currMenu[i] is String)
            {
               if(currMenu[i] == msg)
               {
                  return i + "0";
               }
            }
            else
            {
               parentMenuStr = currMenu[i][0];
               if(msg == parentMenuStr)
               {
                  return String(i);
               }
               for(j = 1; j < currMenu[i].length; j++)
               {
                  if(parentMenuStr.indexOf("...") > -1)
                  {
                     if(msg == parentMenuStr.substr(0,parentMenuStr.length - 3) + " " + currMenu[i][j])
                     {
                        return i + "," + j;
                     }
                  }
                  else if(currMenu[i][j] == msg)
                  {
                     return i + "," + j;
                  }
               }
            }
         }
         return null;
      }
      
      public static function safeChatStringForCode(code:String, treeType:int = -1) : String
      {
         var parentMenuStr:String = null;
         var lookupMenus:Array = code.split(",");
         if(treeType != -1 || _treeArray == null)
         {
            if(treeType == TREE_ECARDTEXT)
            {
               _treeArray = ctNodes;
            }
            else if(treeType == TREE_PHOTOBOOTH)
            {
               _treeArray = photoBoothNodes;
            }
            else if(treeType == TREE_ADVENTURE)
            {
               _treeArray = adventureNodes;
            }
            else
            {
               _treeArray = sctNodes;
            }
         }
         else if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            _treeArray = adventureNodes;
         }
         else
         {
            _treeArray = sctNodes;
         }
         var currMenu:Array = _treeArray;
         for(var msc:uint = 0; msc < lookupMenus.length; msc++)
         {
            if(msc >= lookupMenus.length - 1)
            {
               if(currMenu[lookupMenus[msc]] is String)
               {
                  if(Boolean(parentMenuStr) && Boolean(parentMenuStr.indexOf("...") > 0) && parentMenuStr.indexOf("...") == parentMenuStr.length - 3)
                  {
                     return parentMenuStr.substr(0,parentMenuStr.length - 3) + " " + currMenu[lookupMenus[msc]];
                  }
                  return currMenu[lookupMenus[msc]];
               }
               if(currMenu[lookupMenus[msc]] is Array)
               {
                  return currMenu[lookupMenus[msc]][0];
               }
               return null;
            }
            if(currMenu[lookupMenus[msc]] is String)
            {
               return null;
            }
            if(!(currMenu[lookupMenus[msc]] is Array))
            {
               return null;
            }
            parentMenuStr = currMenu[lookupMenus[msc]][0];
            currMenu = currMenu[lookupMenus[msc]];
         }
         return null;
      }
      
      public static function openSafeChat(isFromSafeChat:Boolean, tree:MovieClip = null) : void
      {
         if(Boolean(tree) && !tree.visible)
         {
            tree.visible = true;
            resetSafeChatTree(isFromSafeChat,MovieClip(tree.getChildAt(1)));
         }
         else if(!_safeChatTree.visible)
         {
            _safeChatTree.visible = true;
            resetSafeChatTree(isFromSafeChat);
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
      
      public static function closeSafeChat(tree:MovieClip = null) : void
      {
         if(Boolean(tree) && tree.visible)
         {
            tree.visible = false;
         }
         else if(Boolean(_safeChatTree) && _safeChatTree.visible)
         {
            _safeChatTree.visible = false;
            _safeChatBtn.downToUpState();
         }
      }
      
      public static function showHide() : void
      {
         _safeChatTree.visible = !_safeChatTree.visible;
      }
      
      public static function sctNodeMouseHandler(mEvt:MouseEvent) : void
      {
         var sctParentStr:String = null;
         mEvt.stopPropagation();
         brightenSafeChat();
         if(!mEvt.currentTarget is SafeChatTreeNode)
         {
            DebugUtility.debugTrace("ERROR: illegal event type in sctNodeMouseHandler!");
            return;
         }
         if(!Utility.canChat())
         {
            return;
         }
         var sctLocalDisplayStr:String = mEvt.currentTarget.sctNodeTxt.text;
         if(sctLocalDisplayStr.indexOf("...") >= 0)
         {
            return;
         }
         if(Boolean(mEvt.currentTarget.parent.sctNodeTxt))
         {
            sctParentStr = mEvt.currentTarget.parent.sctNodeTxt.text;
            if(sctParentStr.indexOf("...") > 0)
            {
               sctLocalDisplayStr = sctParentStr.slice(0,sctParentStr.indexOf("...")) + " " + sctLocalDisplayStr;
            }
         }
         if(_safeChatCallbackFromOtherSystem != null)
         {
            _safeChatCallbackFromOtherSystem(sctLocalDisplayStr,mEvt.currentTarget.menuNums.toString());
         }
         else
         {
            _safeChatCallback(sctLocalDisplayStr,mEvt.currentTarget.menuNums.toString());
         }
      }
   }
}

