package gui
{
   import com.sbi.corelib.input.SBTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ItemWindowPost extends ItemWindowBase
   {
      
      private var _iconMediaHelper:MediaHelper;
      
      private var _onReportDown:Function;
      
      private var _onDeleteDown:Function;
      
      private var _smileyText:SBTextField;
      
      private var _isMyPost:Boolean;
      
      public function ItemWindowPost(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._onReportDown = param9.reportMsgBtnMouseDown;
         this._onDeleteDown = param9.deleteMsgBtnMouseDown;
         this._isMyPost = param9.isMyPost;
         tabEnabled = false;
         super(1501,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get msgId() : String
      {
         return _currItem.msgId;
      }
      
      override public function destroy() : void
      {
         this.removeEventListeners();
         if(this._iconMediaHelper)
         {
            this._iconMediaHelper.destroy();
            this._iconMediaHelper = null;
         }
         this._onReportDown = null;
         this._onDeleteDown = null;
         if(this._smileyText)
         {
            this._smileyText.destroy();
            this._smileyText = null;
         }
         _window = null;
         _windowLoadedCallback = null;
         _currItem = null;
         _mouseDown = null;
         _mouseOver = null;
         _mouseOut = null;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(Boolean(_currItem) && !_isCurrItemLoaded)
         {
            if(!_spiral)
            {
               _spiral = new LoadingSpiral(_window.iconLayer);
            }
            else
            {
               _spiral.setNewParent(_window.iconLayer);
            }
            this._smileyText = new SBTextField(null,_window.messageTxt,_window.textItemHolder,true);
            this._smileyText.text = _currItem.message;
            this._smileyText.mouseChildren = false;
            this._smileyText.mouseEnabled = false;
            this._smileyText.selectable = false;
            _window.deleteMessageBtn.parent.setChildIndex(_window.deleteMessageBtn,_window.deleteMessageBtn.parent.numChildren - 1);
            _window.reportMessageBtn.parent.setChildIndex(_window.reportMessageBtn,_window.reportMessageBtn.parent.numChildren - 1);
            if(!this._isMyPost)
            {
               _window.reportMessageBtn.x += _window.reportMessageBtn.width;
            }
            _isCurrItemLoaded = true;
            this._iconMediaHelper = new MediaHelper();
            this._iconMediaHelper.init(_currItem.iconId,this.onIconLoaded);
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:Object = null;
         if(_currItem)
         {
            _window.reportMessageBtn.visible = false;
            _window.deleteMessageBtn.visible = false;
            _window.pattern.gotoAndStop("pattern" + _currItem.patternId);
            _window.gotoAndStop(_currItem.color);
            _window.messageTxt.text = "";
            _window.messageTxt.selectable = false;
            _window.nameTxt.text = _currItem.senderUserName;
            _window.timeTxt.autoSize = TextFieldAutoSize.RIGHT;
            _loc1_ = Utility.calculateTime((new Date().valueOf() - _currItem.postTime) / 1000);
            LocalizationManager.translateIdAndInsert(_window.timeTxt,11360,Utility.calculatePrintTime(_loc1_.mins,_loc1_.hours,false,_loc1_.days));
            if(_currItem.isBuddy)
            {
               _window.friendIcon.visible = true;
               _window.nameTxt.x += _window.friendIcon.width;
            }
            else
            {
               _window.friendIcon.visible = false;
            }
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(this._isMyPost)
         {
            _window.deleteMessageBtn.addEventListener(MouseEvent.MOUSE_DOWN,this._onDeleteDown,false,0,true);
         }
         _window.reportMessageBtn.addEventListener(MouseEvent.MOUSE_DOWN,this._onReportDown,false,0,true);
         addEventListener(MouseEvent.ROLL_OVER,this.onPostDown,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onPostDown,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         if(this._isMyPost)
         {
            _window.deleteMessageBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this._onDeleteDown);
         }
         _window.reportMessageBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this._onReportDown);
         removeEventListener(MouseEvent.ROLL_OVER,this.onPostDown);
         removeEventListener(MouseEvent.ROLL_OUT,this.onPostDown);
      }
      
      private function onPostDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_window)
         {
            if(_window.messageHighlight.currentFrameLabel != "on")
            {
               _window.messageHighlight.gotoAndStop("on");
               _window.reportMessageBtn.visible = true;
               if(this._isMyPost)
               {
                  _window.deleteMessageBtn.visible = true;
               }
            }
            else
            {
               _window.messageHighlight.gotoAndStop("off");
               _window.reportMessageBtn.visible = false;
               if(this._isMyPost)
               {
                  _window.deleteMessageBtn.visible = false;
               }
            }
         }
      }
      
      private function onIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _spiral.destroy();
            _spiral = null;
            _window.itemWindow.addChild(param1);
         }
      }
   }
}

