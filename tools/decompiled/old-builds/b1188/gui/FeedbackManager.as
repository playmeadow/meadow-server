package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBStandardTitlePopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.net.URLRequestMethod;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import loader.FeedbackDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class FeedbackManager
   {
      
      private static var _feedbackDefCache:Array;
      
      private static var _feedbackLocs:Array;
      
      private static var _feedbackDefHelpers:Array;
      
      private static var _tabMediaHelper:MediaHelper;
      
      private static var _tabTemplate:MovieClip;
      
      private static var _popupMediaHelper:MediaHelper;
      
      private static var _popup:MovieClip;
      
      private static var _imageUploader:UserImageUpload;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _worldLayer:DisplayLayer;
      
      private static var _secondaryType:int;
      
      public static const TYPE_ASK_BRADY:int = 1;
      
      public static const TYPE_ITEMS:int = 2;
      
      public static const TYPE_HOWL:int = 3;
      
      public static const TYPE_WORK:int = 4;
      
      public static const TYPE_SERVERS:int = 5;
      
      public static const TYPE_FLAGS:int = 6;
      
      public static const TYPE_PETS:int = 7;
      
      public static const TYPE_PARTIES:int = 8;
      
      public static const TYPE_EPIC_ITEMS:int = 9;
      
      public static const TYPE_ARCADE:int = 10;
      
      public static const TYPE_ASK_TIERNEY:int = 11;
      
      public static const TYPE_DONATION:int = 12;
      
      public static const TYPE_CARNIVAL:int = 13;
      
      public static const TYPE_ARTSTUDIO:int = 14;
      
      public static const TYPE_JAMSESSION:int = 15;
      
      public static const TYPE_DIAMOND:int = 16;
      
      public static const TYPE_ADVENTURE:int = 17;
      
      public static const TYPE_DICTIONARY:int = 18;
      
      private static const TAB_MEDIA_ID:int = 153;
      
      private static const POPUP_MEDIA_ID:int = 457;
      
      private static const TAB_FRAME_LABEL:String = "answer";
      
      public function FeedbackManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:DisplayLayer) : void
      {
         _feedbackDefCache = [];
         _guiLayer = param1;
         _worldLayer = param2;
         _popupMediaHelper = new MediaHelper();
         _tabMediaHelper = new MediaHelper();
         _tabMediaHelper.init(TAB_MEDIA_ID,mediaHelperCallback,true);
         _imageUploader = new UserImageUpload();
         _imageUploader.init();
      }
      
      public static function setUpOrbs(param1:Array, param2:Array) : void
      {
         var _loc4_:Object = null;
         var _loc5_:FeedbackDefHelper = null;
         _feedbackLocs = param2;
         _feedbackDefHelpers = [];
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] == 0)
            {
               DarkenManager.showLoadingSpiral(false);
               throw new Error("Id == 0");
            }
            _loc4_ = _feedbackDefCache[param1[_loc3_]];
            if(!_loc4_)
            {
               _loc5_ = new FeedbackDefHelper();
               _loc5_.init(param1[_loc3_],onDefReceived);
               _feedbackDefHelpers[param1[_loc3_]] = _loc5_;
            }
            else
            {
               setUpOrb(_loc4_);
            }
            _loc3_++;
         }
      }
      
      public static function openFeedbackPopup(param1:int) : void
      {
         var _loc3_:FeedbackDefHelper = null;
         if(param1 == 0)
         {
            DarkenManager.showLoadingSpiral(false);
            throw new Error("Id == 0");
         }
         DarkenManager.showLoadingSpiral(true);
         if(!_feedbackDefHelpers)
         {
            _feedbackDefHelpers = [];
         }
         var _loc2_:Object = _feedbackDefCache[param1];
         if(!_loc2_)
         {
            _loc3_ = new FeedbackDefHelper();
            _loc3_.init(param1,onDefReceived);
            _feedbackDefHelpers[param1] = _loc3_;
         }
         else
         {
            displayFeedbackPopup(_loc2_);
         }
      }
      
      private static function onDefReceived(param1:FeedbackDefHelper) : void
      {
         var _loc2_:Object = param1.def;
         var _loc3_:String = LocalizationManager.translateIdOnly(int(_loc2_.defaultStrRef));
         var _loc4_:RegExp = /\r\n/g;
         _loc3_ = _loc3_.replace(_loc4_,"\n");
         _loc4_ = /\r/g;
         _loc3_ = _loc3_.replace(_loc4_,"\n");
         var _loc5_:Object = {
            "id":int(_loc2_.id),
            "titleTxt":LocalizationManager.translateIdOnly(int(_loc2_.titleStrRef)),
            "defaultTxt":_loc3_,
            "thanksTxt":LocalizationManager.translateIdOnly(int(_loc2_.thankStrRef)),
            "allowImg":Boolean(int(_loc2_.bAcceptImage)),
            "userVarId":int(_loc2_.userVarRef),
            "bitIdx":int(_loc2_.bitIndex)
         };
         _feedbackDefCache[_loc5_.id] = _loc5_;
         _feedbackDefHelpers[_loc5_.id] = null;
         _loc5_.seen = gMainFrame.userInfo.userVarCache.isBitSet(_loc5_.userVarId,_loc5_.bitIdx);
         if(_loc5_.id == TYPE_ASK_BRADY || _loc5_.id == TYPE_ASK_TIERNEY || _loc5_.id == TYPE_HOWL || _loc5_.id == TYPE_WORK || _loc5_.id == TYPE_SERVERS || _loc5_.id == TYPE_DICTIONARY)
         {
            displayFeedbackPopup(_loc5_);
         }
         else
         {
            setUpOrb(_loc5_);
         }
      }
      
      private static function setUpOrb(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         if(_tabTemplate)
         {
            _loc2_ = new _tabTemplate.constructor();
            _loc2_.def = param1;
            _loc3_ = int(_loc2_.id = int(param1.id));
            _loc2_.x = _feedbackLocs[_loc3_].x;
            _loc2_.y = _feedbackLocs[_loc3_].y;
            if(param1.seen)
            {
               _loc2_.gotoAndPlay(TAB_FRAME_LABEL + "Dim");
            }
            else
            {
               _loc2_.gotoAndPlay(TAB_FRAME_LABEL);
            }
            _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,onTabMouseDown,false,0,true);
            _worldLayer.addChild(_loc2_);
         }
      }
      
      private static function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            if(param1.mediaHelper.id == TAB_MEDIA_ID)
            {
               _loc2_ = int(param1.mediaHelper.id);
               _tabTemplate = MovieClip(param1.getChildAt(0));
               _tabMediaHelper.destroy();
               _tabMediaHelper = null;
            }
            else if(param1.mediaHelper.id == POPUP_MEDIA_ID)
            {
               _popup = param1;
               _popupMediaHelper.destroy();
               _popupMediaHelper = null;
               _popup.x = MainFrame.VIEW_WIDTH * 0.5;
               _popup.y = MainFrame.VIEW_HEIGHT * 0.5;
               _popup.parent.x = _popup.x;
               _popup.parent.y = _popup.y;
               displayFeedbackPopup(param1.passback);
            }
         }
      }
      
      private static function onTabMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:MovieClip = MovieClip(param1.currentTarget);
         var _loc3_:Object = _loc2_.def;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/feedback/" + _loc3_.id);
         DarkenManager.showLoadingSpiral(true);
         if(!_loc3_.seen)
         {
            _loc2_.gotoAndPlay(TAB_FRAME_LABEL + "Dim");
         }
         displayFeedbackPopup(_loc3_);
      }
      
      public static function displayFeedbackPopup(param1:Object) : void
      {
         var _loc3_:Array = null;
         var _loc2_:int = int(param1.id);
         if(!_popup)
         {
            _popupMediaHelper.init(POPUP_MEDIA_ID,mediaHelperCallback,param1);
            return;
         }
         if(!param1.seen)
         {
            param1.seen = true;
            AchievementXtCommManager.requestSetUserVar(param1.userVarId,param1.bitIdx);
         }
         _popup.gotoAndStop(frameLabelForType(_loc2_));
         _popup.submitBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
         _popup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
         _popup.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
         _popup.txt.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
         _popup.def = param1;
         if(_popup["descTxt"])
         {
            _loc3_ = param1.defaultTxt.split("|");
            LocalizationManager.updateToFit(_popup.descTxt,_loc3_[0]);
            LocalizationManager.updateToFit(_popup.txt,_loc3_[1]);
         }
         else
         {
            LocalizationManager.updateToFit(_popup.txt,param1.defaultTxt);
         }
         _popup.defaultTxt = _popup.txt.text;
         _popup.titleTxt.text = param1.titleTxt;
         if(param1.allowImg)
         {
            _popup.addFileBtn.visible = true;
            _imageUploader.setUploadBtn(_popup.addFileBtn);
            _popup.removeFileBtn.addEventListener(MouseEvent.MOUSE_DOWN,onRemoveFileBtn,false,0,true);
         }
         else
         {
            if(_popup.addFileBtn)
            {
               _popup.addFileBtn.visible = false;
            }
            if(_popup.removeFileBtn)
            {
               _popup.removeFileBtn.visible = false;
            }
         }
         _popup.txt.maxChars = maxCharsForType(_loc2_);
         if(_loc2_ == TYPE_DICTIONARY)
         {
            _popup.txt.restrict = "^ ";
         }
         else
         {
            _popup.txt.restrict = null;
         }
         _popup.visible = true;
         _popup.clickedTextBox = false;
         KeepAlive.startKATimer(_popup);
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(DisplayObjectContainer(_popup));
         _guiLayer.addChild(DisplayObjectContainer(_popup));
      }
      
      private static function frameLabelForType(param1:int) : int
      {
         switch(param1)
         {
            case TYPE_ASK_BRADY:
               return 1;
            case TYPE_HOWL:
               return 2;
            case TYPE_WORK:
            case TYPE_ITEMS:
            case TYPE_SERVERS:
            case TYPE_FLAGS:
            case TYPE_PETS:
            case TYPE_PARTIES:
            case TYPE_EPIC_ITEMS:
            case TYPE_ARCADE:
            case TYPE_CARNIVAL:
            case TYPE_JAMSESSION:
            case TYPE_DIAMOND:
            case TYPE_ADVENTURE:
               return 3;
            case TYPE_ASK_TIERNEY:
               return 4;
            case TYPE_DICTIONARY:
               return 6;
            default:
               return 1;
         }
      }
      
      private static function maxCharsForType(param1:int) : int
      {
         switch(param1)
         {
            case TYPE_ASK_BRADY:
            case TYPE_ASK_TIERNEY:
               return 150;
            case TYPE_HOWL:
               return 50;
            case TYPE_WORK:
               return 3000;
            case TYPE_ITEMS:
            case TYPE_SERVERS:
            case TYPE_FLAGS:
            case TYPE_PARTIES:
            case TYPE_EPIC_ITEMS:
            case TYPE_ARCADE:
            case TYPE_CARNIVAL:
            case TYPE_JAMSESSION:
            case TYPE_DIAMOND:
            case TYPE_DONATION:
            case TYPE_PETS:
            case TYPE_ARTSTUDIO:
               return 100;
            case TYPE_ADVENTURE:
               return 200;
            case TYPE_DICTIONARY:
               return 25;
            default:
               return 1;
         }
      }
      
      private static function onRemoveFileBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _imageUploader.resetUploader();
         _popup.addFileBtn.visible = true;
      }
      
      private static function onMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:RegExp = null;
         param1.stopPropagation();
         if(param1.currentTarget == _popup)
         {
            return;
         }
         if(param1.currentTarget == _popup.txt)
         {
            if(!_popup.clickedTextBox)
            {
               _popup.txt.text = "";
               _popup.clickedTextBox = true;
               gMainFrame.stage.focus = _popup.txt;
               _popup.txt.setSelection(0,0);
            }
            return;
         }
         if(param1.currentTarget.name == "submitBtn")
         {
            _loc2_ = _popup.txt.text;
            _loc3_ = /\r\n/g;
            _loc2_ = _loc2_.replace(_loc3_,"\n");
            _loc3_ = /\r/g;
            _loc2_ = _loc2_.replace(_loc3_,"\n");
            if(_loc2_.length > 0 && _loc2_ != _popup.defaultTxt || _imageUploader.fileName != "")
            {
               if(_loc2_ == _popup.def.defaultTxt)
               {
                  _loc2_ = _popup.txt.text = "";
               }
               setupRequest(_imageUploader,_loc2_,_popup.def.id,_secondaryType,onSendComplete,onSendError);
            }
         }
         _popup.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         _popup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         _popup.submitBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         _popup.txt.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         if(_popup.def.allowImg)
         {
            _imageUploader.resetUploader();
            _popup.addFileBtn.visible = true;
            _popup.removeFileBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onRemoveFileBtn);
         }
         DarkenManager.unDarken(_popup);
         _popup.visible = false;
         SBTracker.pop();
         if(param1.currentTarget.name != "bx")
         {
            new SBStandardTitlePopup(_guiLayer,_popup.def.thanksTxt);
         }
         KeepAlive.stopKATimer(_popup);
      }
      
      public static function setupRequest(param1:UserImageUpload, param2:String, param3:int, param4:int, param5:Function, param6:Function) : void
      {
         var _loc7_:String = "---------------------------" + Math.floor(Math.random() * 100000000000000);
         var _loc8_:Object = {
            "userName":gMainFrame.userInfo.myUserName,
            "type":param3,
            "message":param2,
            "secondaryType":param4,
            "languageId":LocalizationManager.currentLanguage
         };
         var _loc9_:URLRequest = new URLRequest(gMainFrame.clientInfo.mdUrl + "fb");
         _loc9_.contentType = "multipart/form-data; boundary=" + _loc7_;
         _loc9_.requestHeaders.push(new URLRequestHeader("Cache-Control","no-cache"));
         _loc9_.method = URLRequestMethod.POST;
         _loc9_.data = createPostData(param1.fileName,param1.uploadedImage,_loc7_,_loc8_);
         var _loc10_:URLLoader = new URLLoader();
         _loc10_.dataFormat = URLLoaderDataFormat.BINARY;
         _loc10_.addEventListener(Event.COMPLETE,param5);
         _loc10_.addEventListener(IOErrorEvent.IO_ERROR,param6);
         _loc10_.load(_loc9_);
      }
      
      public static function createPostData(param1:String, param2:ByteArray, param3:String, param4:Object = null) : ByteArray
      {
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc6_:ByteArray = new ByteArray();
         _loc6_.endian = Endian.BIG_ENDIAN;
         if(param4 == null)
         {
            param4 = new Object();
         }
         for(_loc7_ in param4)
         {
            writeBoundary(_loc6_,param3);
            writeLineBreak(_loc6_);
            _loc5_ = "Content-Disposition: form-data; name=\"" + _loc7_ + "\"";
            _loc8_ = 0;
            while(_loc8_ < _loc5_.length)
            {
               _loc6_.writeByte(_loc5_.charCodeAt(_loc8_));
               _loc8_++;
            }
            writeLineBreak(_loc6_);
            writeLineBreak(_loc6_);
            _loc6_.writeUTFBytes(param4[_loc7_]);
            writeLineBreak(_loc6_);
         }
         if(param2)
         {
            writeBoundary(_loc6_,param3);
            writeLineBreak(_loc6_);
            _loc5_ = "Content-Disposition: form-data; name=\"image\"; filename=\"" + param1 + "\"";
            _loc8_ = 0;
            while(_loc8_ < _loc5_.length)
            {
               _loc6_.writeByte(_loc5_.charCodeAt(_loc8_));
               _loc8_++;
            }
            writeLineBreak(_loc6_);
            _loc5_ = "Content-Type: image/jpeg";
            _loc8_ = 0;
            while(_loc8_ < _loc5_.length)
            {
               _loc6_.writeByte(_loc5_.charCodeAt(_loc8_));
               _loc8_++;
            }
            writeLineBreak(_loc6_);
            writeLineBreak(_loc6_);
            _loc6_.writeBytes(param2,0,param2.length);
            writeLineBreak(_loc6_);
         }
         writeBoundary(_loc6_,param3);
         writeDoubleDash(_loc6_);
         writeLineBreak(_loc6_);
         return _loc6_;
      }
      
      private static function writeLineBreak(param1:ByteArray) : void
      {
         param1.writeShort(3338);
      }
      
      private static function writeDoubleDash(param1:ByteArray) : void
      {
         param1.writeShort(11565);
      }
      
      private static function writeBoundary(param1:ByteArray, param2:String) : void
      {
         writeDoubleDash(param1);
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            param1.writeByte(param2.charCodeAt(_loc3_));
            _loc3_++;
         }
      }
      
      private static function onSendComplete(param1:Event) : void
      {
      }
      
      private static function onSendError(param1:Event) : void
      {
      }
   }
}

