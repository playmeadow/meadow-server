package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ImagePoll
   {
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _mediaHelper:MediaHelper;
      
      private static var _imgPopup:MovieClip;
      
      private static var _pollTab:MovieClip;
      
      private static var _closeCallback:Function;
      
      private static var _spirals:Array;
      
      private static var _mediaIds:Array;
      
      private static var _randOptionLookup:Array;
      
      private static var _locStrings:Array;
      
      private static var _mediaHolder:Array;
      
      private static var _checkedItems:Array;
      
      private static var _itemImages:Array;
      
      private static var _numAllowedVotes:int;
      
      private static var _pollUserVardId:int;
      
      private static var _numImageWindow:int;
      
      private static var _pollPopupMediaId:int;
      
      public static const TSHIRT_VAR_ID:int = 312;
      
      public static const DEN_ITEM_VOTING_VAR_ID:int = 374;
      
      public static const TSHIRT_IMAGES_MEDIA_ID:int = 76;
      
      public static const POLL_MEDIA_ID:int = 1355;
      
      public static const DEN_POLL_MEDIA_ID:int = 2926;
      
      public function ImagePoll()
      {
         super();
      }
      
      public static function displayPoll(pollUserVarId:int, pollPopupMediaId:int, pollMediaListId:int, numImageWindows:int, numAllowedVotes:int, pollTab:MovieClip = null, closeCallback:Function = null) : void
      {
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(pollUserVarId) < 0)
         {
            DarkenManager.showLoadingSpiral(true);
            _spirals = [];
            _checkedItems = [];
            _guiLayer = GuiManager.guiLayer;
            _pollPopupMediaId = pollPopupMediaId;
            _numImageWindow = numImageWindows;
            _numAllowedVotes = numAllowedVotes;
            _pollUserVardId = pollUserVarId;
            _pollTab = pollTab;
            _closeCallback = closeCallback;
            if(pollMediaListId != 0)
            {
               GenericListXtCommManager.requestGenericList(pollMediaListId,onMediaListReceived);
            }
            else
            {
               onMediaListReceived(0,null,null);
            }
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18821));
         }
      }
      
      public static function destroy(isDueToAVote:Boolean) : void
      {
         for(var i:int = 0; i < _mediaHolder.length; i++)
         {
            if(Boolean(_mediaHolder[i]))
            {
               _mediaHolder[i].destroy();
            }
            if(Boolean(_spirals[i]))
            {
               _spirals[i].destroy();
            }
         }
         removeListeners();
         DarkenManager.unDarken(_imgPopup);
         _guiLayer.removeChild(_imgPopup);
         if(isDueToAVote)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18821));
         }
      }
      
      private static function onMediaListReceived(glId:int, mediaIds:Array, locStrs:Array) : void
      {
         if(Boolean(_mediaIds))
         {
            _mediaIds = mediaIds;
            _randOptionLookup = [0,1,2,3,4,5,6,7,8,9];
            _locStrings = locStrs;
            _mediaIds = shuffleArray(_mediaIds);
         }
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_pollPopupMediaId,onMediaReceived,true);
      }
      
      private static function onMediaReceived(mc:MovieClip) : void
      {
         var currItem:Object = null;
         var i:int = 0;
         var currImage:Object = null;
         if(Boolean(mc))
         {
            if(mc.mediaHelper.id == _pollPopupMediaId)
            {
               DarkenManager.showLoadingSpiral(false);
               _imgPopup = MovieClip(mc.getChildAt(0));
               _imgPopup.x = MainFrame.VIEW_WIDTH * 0.5;
               _imgPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
               _imgPopup.imageViewerPopup.visible = false;
               _imgPopup.scrim.visible = false;
               if(Boolean(_imgPopup.doneBtn.hasGrayState))
               {
                  _imgPopup.doneBtn.activateGrayState(true);
               }
               _mediaHelper.destroy();
               _mediaHelper = null;
               _mediaHolder = [];
               _itemImages = [];
               for(i = 0; i < _numImageWindow; i++)
               {
                  currItem = _imgPopup["pollItem" + i];
                  currItem.index = i;
                  currItem.ItemHL.itemSelectedHL.visible = false;
                  currItem.ItemHL.mouseOverHL.gotoAndStop("out");
                  currItem.checkbox.checkmark.visible = false;
                  currItem.checkbox.mouse.visible = false;
                  if(Boolean(_mediaIds))
                  {
                     _spirals[i] = new LoadingSpiral(currItem.itemBlock);
                     _mediaHelper = new MediaHelper();
                     _mediaHelper.init(_mediaIds[i],onMediaReceived,i);
                     _mediaHolder.push(_mediaHelper);
                     _mediaHelper = new MediaHelper();
                     _mediaHelper.init(_mediaIds[i],onMediaReceived,i + 10);
                     _mediaHolder.push(_mediaHelper);
                  }
               }
               _guiLayer.addChild(_imgPopup);
               DarkenManager.darken(_imgPopup);
               addListeners();
            }
            else
            {
               currImage = mc.getChildAt(0);
               _itemImages[mc.passback] = currImage;
               if(mc.passback < _numImageWindow)
               {
                  _spirals[mc.passback].destroy();
                  _imgPopup["pollItem" + mc.passback].itemBlock.addChild(currImage);
               }
            }
         }
      }
      
      private static function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function onClose(evt:MouseEvent) : void
      {
         var bitsSet:int = 0;
         var i:int = 0;
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            if(evt.currentTarget.name == "doneBtn")
            {
               for(i = 0; i < _checkedItems.length; i++)
               {
                  if(_checkedItems[i] != null)
                  {
                     if(Boolean(_randOptionLookup))
                     {
                        bitsSet |= 1 << _randOptionLookup[_checkedItems[i]];
                     }
                     else
                     {
                        bitsSet |= 1 << _checkedItems[i];
                     }
                  }
               }
               AchievementXtCommManager.requestSetUserVar(_pollUserVardId,bitsSet);
               if(_closeCallback != null)
               {
                  _closeCallback(_pollTab);
                  _closeCallback = null;
               }
            }
            else if(_closeCallback != null)
            {
               SBTracker.pop();
            }
            destroy(evt.currentTarget.name == "doneBtn");
         }
      }
      
      private static function onItemOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.ItemHL.mouseOverHL.currentFrameLabel != "out")
         {
            evt.currentTarget.ItemHL.mouseOverHL.gotoAndStop("out");
         }
      }
      
      private static function onItemOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.ItemHL.mouseOverHL.currentFrameLabel != "over")
         {
            evt.currentTarget.ItemHL.mouseOverHL.gotoAndStop("over");
         }
      }
      
      private static function onCheckOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.mouse.visible = !evt.currentTarget.mouse.visible;
      }
      
      private static function onCheckOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.mouse.visible = !evt.currentTarget.mouse.visible;
      }
      
      private static function onCheckOrVote(evt:MouseEvent) : void
      {
         var currIndex:int = 0;
         var addCheckBox:Boolean = false;
         var unselectIndex:int = 0;
         evt.stopPropagation();
         if(evt.currentTarget.name == "checkbox")
         {
            evt.currentTarget.checkmark.visible = addCheckBox = !evt.currentTarget.checkmark.visible;
            currIndex = int(evt.currentTarget.parent.index);
         }
         else
         {
            currIndex = int(evt.currentTarget.parent.currPollIndex);
            _imgPopup["pollItem" + currIndex].checkbox.checkmark.visible = addCheckBox = !_imgPopup["pollItem" + currIndex].checkbox.checkmark.visible;
         }
         if(addCheckBox)
         {
            _checkedItems.push(currIndex);
            if(_checkedItems.length > _numAllowedVotes)
            {
               unselectIndex = int(_checkedItems[0]);
               _checkedItems.shift();
               _imgPopup["pollItem" + unselectIndex].checkbox.checkmark.visible = false;
               _imgPopup["pollItem" + unselectIndex].ItemHL.itemSelectedHL.visible = false;
            }
            if(_checkedItems.length > 0)
            {
               if(Boolean(_imgPopup.doneBtn.hasGrayState) && Boolean(_imgPopup.doneBtn.isGray))
               {
                  _imgPopup.doneBtn.activateGrayState(false);
               }
            }
         }
         else
         {
            _checkedItems.splice(_checkedItems.indexOf(currIndex),1);
            if(Boolean(_imgPopup.doneBtn.hasGrayState) && Boolean(!_imgPopup.doneBtn.isGray) && _checkedItems.length == 0)
            {
               _imgPopup.doneBtn.activateGrayState(true);
            }
         }
         _imgPopup["pollItem" + currIndex].ItemHL.itemSelectedHL.visible = addCheckBox;
         if(evt.currentTarget.name != "checkbox")
         {
            _imgPopup.imageViewerPopup.visible = false;
            _imgPopup.scrim.visible = false;
         }
      }
      
      private static function onItemZoom(evt:MouseEvent) : void
      {
         var imgToAdd:MovieClip = null;
         evt.stopPropagation();
         _imgPopup.imageViewerPopup.visible = true;
         _imgPopup.scrim.visible = true;
         if(_imgPopup.imageViewerPopup.currentLabels.length < 1)
         {
            while(_imgPopup.imageViewerPopup.itemBlock.numChildren > 0)
            {
               _imgPopup.imageViewerPopup.itemBlock.removeChildAt(0);
            }
         }
         var currIndex:int = evt.currentTarget.name == "zoomBtn" ? int(evt.currentTarget.parent.index) : int(evt.currentTarget.index);
         if(Boolean(_itemImages))
         {
            imgToAdd = _itemImages[currIndex + 10];
            if(imgToAdd != null)
            {
               imgToAdd.gotoAndStop("large");
               _imgPopup.imageViewerPopup.itemBlock.addChild(imgToAdd);
            }
         }
         if(Boolean(_locStrings))
         {
            _imgPopup.imageViewerPopup.titleTxt.text = _locStrings[_randOptionLookup[currIndex]];
         }
         if(_imgPopup.imageViewerPopup.currentLabels.length > 1)
         {
            _imgPopup.imageViewerPopup.gotoAndStop("pollItem" + currIndex);
            _imgPopup.imageViewerPopup.titleTxt.text = _imgPopup["pollItem" + currIndex].titleTxt.text;
         }
         _imgPopup.imageViewerPopup.currPollIndex = currIndex;
      }
      
      private static function onCloseViewer(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         _imgPopup.imageViewerPopup.visible = false;
         _imgPopup.scrim.visible = false;
      }
      
      private static function shuffleArray(a:Array) : Array
      {
         var element:String = null;
         var i:int = 0;
         var rand:int = 0;
         var save:int = 0;
         var length:int = int(a.length);
         var shuffled:Array = a.slice();
         while(i < length)
         {
            element = shuffled[i];
            rand = Math.floor(Math.random() * length);
            if(i != rand)
            {
               shuffled[i] = shuffled[rand];
               shuffled[rand] = element;
               save = int(_randOptionLookup[i]);
               _randOptionLookup[i] = _randOptionLookup[rand];
               _randOptionLookup[rand] = save;
            }
            i++;
         }
         return shuffled;
      }
      
      private static function addListeners() : void
      {
         var currItem:Object = null;
         _imgPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
         _imgPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
         _imgPopup.doneBtn.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
         for(var i:int = 0; i < _numImageWindow; i++)
         {
            currItem = _imgPopup["pollItem" + i];
            currItem.addEventListener(MouseEvent.MOUSE_OUT,onItemOut,false,0,true);
            currItem.addEventListener(MouseEvent.MOUSE_OVER,onItemOver,false,0,true);
            currItem.addEventListener(MouseEvent.MOUSE_DOWN,onItemZoom,false,0,true);
            currItem.zoomBtn.addEventListener(MouseEvent.MOUSE_DOWN,onItemZoom,false,0,true);
            currItem.checkbox.addEventListener(MouseEvent.ROLL_OVER,onCheckOver,false,0,true);
            currItem.checkbox.addEventListener(MouseEvent.ROLL_OUT,onCheckOut,false,0,true);
            currItem.checkbox.addEventListener(MouseEvent.MOUSE_DOWN,onCheckOrVote,false,0,true);
         }
         _imgPopup.imageViewerPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onCloseViewer,false,0,true);
         _imgPopup.imageViewerPopup.voteBtn.addEventListener(MouseEvent.MOUSE_DOWN,onCheckOrVote,false,0,true);
      }
      
      private static function removeListeners() : void
      {
         var currItem:Object = null;
         _imgPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
         _imgPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
         _imgPopup.doneBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
         for(var i:int = 0; i < _numImageWindow; i++)
         {
            currItem = _imgPopup["pollItem" + i];
            currItem.removeEventListener(MouseEvent.MOUSE_OUT,onItemOut);
            currItem.removeEventListener(MouseEvent.MOUSE_OVER,onItemOver);
            currItem.removeEventListener(MouseEvent.MOUSE_DOWN,onItemZoom);
            currItem.zoomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onItemZoom);
            currItem.checkbox.removeEventListener(MouseEvent.ROLL_OVER,onCheckOver);
            currItem.checkbox.removeEventListener(MouseEvent.ROLL_OUT,onCheckOut);
            currItem.checkbox.removeEventListener(MouseEvent.MOUSE_DOWN,onCheckOrVote);
         }
         _imgPopup.imageViewerPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onCloseViewer);
         _imgPopup.imageViewerPopup.voteBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onCheckOrVote);
      }
   }
}

