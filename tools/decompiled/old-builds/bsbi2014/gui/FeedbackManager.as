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
      
      public static function init(initGuiLayer:DisplayLayer, initWorldLayer:DisplayLayer) : void
      {
         _feedbackDefCache = [];
         _guiLayer = initGuiLayer;
         _worldLayer = initWorldLayer;
         _popupMediaHelper = new MediaHelper();
         _tabMediaHelper = new MediaHelper();
         _tabMediaHelper.init(TAB_MEDIA_ID,mediaHelperCallback,true);
         _imageUploader = new UserImageUpload();
         _imageUploader.init();
      }
      
      public static function setUpOrbs(feedbackDefIds:Array, feedbackLocs:Array) : void
      {
         var def:Object = null;
         var fdh:FeedbackDefHelper = null;
         _feedbackLocs = feedbackLocs;
         _feedbackDefHelpers = [];
         for(var i:int = 0; i < feedbackDefIds.length; i++)
         {
            if(feedbackDefIds[i] == 0)
            {
               DarkenManager.showLoadingSpiral(false);
               throw new Error("Id == 0");
            }
            def = _feedbackDefCache[feedbackDefIds[i]];
            if(!def)
            {
               fdh = new FeedbackDefHelper();
               fdh.init(feedbackDefIds[i],onDefReceived);
               _feedbackDefHelpers[feedbackDefIds[i]] = fdh;
            }
            else
            {
               setUpOrb(def);
            }
         }
      }
      
      public static function openFeedbackPopup(defId:int) : void
      {
         var fdh:FeedbackDefHelper = null;
         if(defId == 0)
         {
            DarkenManager.showLoadingSpiral(false);
            throw new Error("Id == 0");
         }
         DarkenManager.showLoadingSpiral(true);
         if(!_feedbackDefHelpers)
         {
            _feedbackDefHelpers = [];
         }
         var def:Object = _feedbackDefCache[defId];
         if(!def)
         {
            fdh = new FeedbackDefHelper();
            fdh.init(defId,onDefReceived);
            _feedbackDefHelpers[defId] = fdh;
         }
         else
         {
            displayFeedbackPopup(def);
         }
      }
      
      private static function onDefReceived(fdh:FeedbackDefHelper) : void
      {
         var o:Object = fdh.def;
         var defTxt:String = LocalizationManager.translateIdOnly(int(o.defaultStrRef));
         var patt:RegExp = /\r\n/g;
         defTxt = defTxt.replace(patt,"\n");
         patt = /\r/g;
         defTxt = defTxt.replace(patt,"\n");
         var def:Object = {
            "id":int(o.id),
            "titleTxt":LocalizationManager.translateIdOnly(int(o.titleStrRef)),
            "defaultTxt":defTxt,
            "thanksTxt":LocalizationManager.translateIdOnly(int(o.thankStrRef)),
            "allowImg":Boolean(int(o.bAcceptImage)),
            "userVarId":int(o.userVarRef),
            "bitIdx":int(o.bitIndex)
         };
         _feedbackDefCache[def.id] = def;
         _feedbackDefHelpers[def.id] = null;
         def.seen = gMainFrame.userInfo.userVarCache.isBitSet(def.userVarId,def.bitIdx);
         if(def.id == TYPE_ASK_BRADY || def.id == TYPE_ASK_TIERNEY || def.id == TYPE_HOWL || def.id == TYPE_WORK || def.id == TYPE_SERVERS || def.id == TYPE_DICTIONARY)
         {
            displayFeedbackPopup(def);
         }
         else
         {
            setUpOrb(def);
         }
      }
      
      private static function setUpOrb(def:Object) : void
      {
         var tab:MovieClip = null;
         var defId:int = 0;
         if(Boolean(_tabTemplate))
         {
            tab = new _tabTemplate.constructor();
            tab.def = def;
            defId = int(tab.id = int(def.id));
            tab.x = _feedbackLocs[defId].x;
            tab.y = _feedbackLocs[defId].y;
            if(Boolean(def.seen))
            {
               tab.gotoAndPlay(TAB_FRAME_LABEL + "Dim");
            }
            else
            {
               tab.gotoAndPlay(TAB_FRAME_LABEL);
            }
            tab.addEventListener(MouseEvent.MOUSE_DOWN,onTabMouseDown,false,0,true);
            _worldLayer.addChild(tab);
         }
      }
      
      private static function mediaHelperCallback(img:MovieClip) : void
      {
         var pid:int = 0;
         if(Boolean(img))
         {
            if(img.mediaHelper.id == TAB_MEDIA_ID)
            {
               pid = int(img.mediaHelper.id);
               _tabTemplate = MovieClip(img.getChildAt(0));
               _tabMediaHelper.destroy();
               _tabMediaHelper = null;
            }
            else if(img.mediaHelper.id == POPUP_MEDIA_ID)
            {
               _popup = img;
               _popupMediaHelper.destroy();
               _popupMediaHelper = null;
               _popup.x = MainFrame.VIEW_WIDTH * 0.5;
               _popup.y = MainFrame.VIEW_HEIGHT * 0.5;
               _popup.parent.x = _popup.x;
               _popup.parent.y = _popup.y;
               displayFeedbackPopup(img.passback);
            }
         }
      }
      
      private static function onTabMouseDown(m:MouseEvent) : void
      {
         m.stopPropagation();
         var tab:MovieClip = MovieClip(m.currentTarget);
         var def:Object = tab.def;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/feedback/" + def.id);
         DarkenManager.showLoadingSpiral(true);
         if(!def.seen)
         {
            tab.gotoAndPlay(TAB_FRAME_LABEL + "Dim");
         }
         displayFeedbackPopup(def);
      }
      
      public static function displayFeedbackPopup(def:Object) : void
      {
         var splitTxt:Array = null;
         var type:int = int(def.id);
         if(!_popup)
         {
            _popupMediaHelper.init(POPUP_MEDIA_ID,mediaHelperCallback,def);
            return;
         }
         if(!def.seen)
         {
            def.seen = true;
            AchievementXtCommManager.requestSetUserVar(def.userVarId,def.bitIdx);
         }
         _popup.gotoAndStop(frameLabelForType(type));
         _popup.submitBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
         _popup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
         _popup.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
         _popup.txt.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
         _popup.def = def;
         if(Boolean(_popup["descTxt"]))
         {
            splitTxt = def.defaultTxt.split("|");
            LocalizationManager.updateToFit(_popup.descTxt,splitTxt[0]);
            LocalizationManager.updateToFit(_popup.txt,splitTxt[1]);
         }
         else
         {
            LocalizationManager.updateToFit(_popup.txt,def.defaultTxt);
         }
         _popup.defaultTxt = _popup.txt.text;
         _popup.titleTxt.text = def.titleTxt;
         if(Boolean(def.allowImg))
         {
            _popup.addFileBtn.visible = true;
            _imageUploader.setUploadBtn(_popup.addFileBtn);
            _popup.removeFileBtn.addEventListener(MouseEvent.MOUSE_DOWN,onRemoveFileBtn,false,0,true);
         }
         else
         {
            if(Boolean(_popup.addFileBtn))
            {
               _popup.addFileBtn.visible = false;
            }
            if(Boolean(_popup.removeFileBtn))
            {
               _popup.removeFileBtn.visible = false;
            }
         }
         _popup.txt.maxChars = maxCharsForType(type);
         if(type == TYPE_DICTIONARY)
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
      
      private static function frameLabelForType(type:int) : int
      {
         switch(type)
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
      
      private static function maxCharsForType(type:int) : int
      {
         switch(type)
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
      
      private static function onRemoveFileBtn(m:MouseEvent) : void
      {
         m.stopPropagation();
         _imageUploader.resetUploader();
         _popup.addFileBtn.visible = true;
      }
      
      private static function onMouseDown(m:MouseEvent) : void
      {
         var popupTxt:String = null;
         var patt:RegExp = null;
         m.stopPropagation();
         if(m.currentTarget == _popup)
         {
            return;
         }
         if(m.currentTarget == _popup.txt)
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
         if(m.currentTarget.name == "submitBtn")
         {
            popupTxt = _popup.txt.text;
            patt = /\r\n/g;
            popupTxt = popupTxt.replace(patt,"\n");
            patt = /\r/g;
            popupTxt = popupTxt.replace(patt,"\n");
            if(popupTxt.length > 0 && popupTxt != _popup.defaultTxt || _imageUploader.fileName != "")
            {
               if(popupTxt == _popup.def.defaultTxt)
               {
                  popupTxt = _popup.txt.text = "";
               }
               setupRequest(_imageUploader,popupTxt,_popup.def.id,_secondaryType,onSendComplete,onSendError);
            }
         }
         _popup.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         _popup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         _popup.submitBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         _popup.txt.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         if(Boolean(_popup.def.allowImg))
         {
            _imageUploader.resetUploader();
            _popup.addFileBtn.visible = true;
            _popup.removeFileBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onRemoveFileBtn);
         }
         DarkenManager.unDarken(_popup);
         _popup.visible = false;
         SBTracker.pop();
         if(m.currentTarget.name != "bx")
         {
            new SBStandardTitlePopup(_guiLayer,_popup.def.thanksTxt);
         }
         KeepAlive.stopKATimer(_popup);
      }
      
      public static function setupRequest(imageUploaded:UserImageUpload, message:String, typeDefId:int, secondaryType:int, initOnSendComplete:Function, initOnSendError:Function) : void
      {
         var boundary:String = "---------------------------" + Math.floor(Math.random() * 100000000000000);
         var formData:Object = {
            "userName":gMainFrame.userInfo.myUserName,
            "type":typeDefId,
            "message":message,
            "secondaryType":secondaryType,
            "languageId":LocalizationManager.currentLanguage
         };
         var request:URLRequest = new URLRequest(gMainFrame.clientInfo.mdUrl + "fb");
         request.contentType = "multipart/form-data; boundary=" + boundary;
         request.requestHeaders.push(new URLRequestHeader("Cache-Control","no-cache"));
         request.method = URLRequestMethod.POST;
         request.data = createPostData(imageUploaded.fileName,imageUploaded.uploadedImage,boundary,formData);
         var urlLoader:URLLoader = new URLLoader();
         urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
         urlLoader.addEventListener(Event.COMPLETE,initOnSendComplete);
         urlLoader.addEventListener(IOErrorEvent.IO_ERROR,initOnSendError);
         urlLoader.load(request);
      }
      
      public static function createPostData(fileName:String, image:ByteArray, boundary:String, formData:Object = null) : ByteArray
      {
         var stringToAppend:String = null;
         var name:String = null;
         var i:int = 0;
         var postData:ByteArray = new ByteArray();
         postData.endian = Endian.BIG_ENDIAN;
         if(formData == null)
         {
            formData = new Object();
         }
         for(name in formData)
         {
            writeBoundary(postData,boundary);
            writeLineBreak(postData);
            stringToAppend = "Content-Disposition: form-data; name=\"" + name + "\"";
            for(i = 0; i < stringToAppend.length; i++)
            {
               postData.writeByte(stringToAppend.charCodeAt(i));
            }
            writeLineBreak(postData);
            writeLineBreak(postData);
            postData.writeUTFBytes(formData[name]);
            writeLineBreak(postData);
         }
         if(Boolean(image))
         {
            writeBoundary(postData,boundary);
            writeLineBreak(postData);
            stringToAppend = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + "\"";
            for(i = 0; i < stringToAppend.length; i++)
            {
               postData.writeByte(stringToAppend.charCodeAt(i));
            }
            writeLineBreak(postData);
            stringToAppend = "Content-Type: image/jpeg";
            for(i = 0; i < stringToAppend.length; i++)
            {
               postData.writeByte(stringToAppend.charCodeAt(i));
            }
            writeLineBreak(postData);
            writeLineBreak(postData);
            postData.writeBytes(image,0,image.length);
            writeLineBreak(postData);
         }
         writeBoundary(postData,boundary);
         writeDoubleDash(postData);
         writeLineBreak(postData);
         return postData;
      }
      
      private static function writeLineBreak(postData:ByteArray) : void
      {
         postData.writeShort(3338);
      }
      
      private static function writeDoubleDash(postData:ByteArray) : void
      {
         postData.writeShort(11565);
      }
      
      private static function writeBoundary(postData:ByteArray, boundary:String) : void
      {
         writeDoubleDash(postData);
         for(var i:int = 0; i < boundary.length; i++)
         {
            postData.writeByte(boundary.charCodeAt(i));
         }
      }
      
      private static function onSendComplete(evt:Event) : void
      {
         trace("w00t!");
      }
      
      private static function onSendError(evt:Event) : void
      {
         trace("Argh! Error sending....");
      }
   }
}

