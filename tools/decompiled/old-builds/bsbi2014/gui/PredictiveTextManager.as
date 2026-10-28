package gui
{
   import com.sbi.loader.FileServerEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   
   public class PredictiveTextManager
   {
      
      private static var _predictiveTreesToFullFill:Array;
      
      private static var _lastRequestedLanguage:int;
      
      private static var _hasRequestedWords:Boolean;
      
      public static const USE_TYPE_ALL:int = 0;
      
      public static const USE_TYPE_ECARD:int = 1;
      
      private const DEFAULT_WORD_VALIDITY:int = -1;
      
      private const DOES_NOT_CONTAIN_WORD:int = 0;
      
      private const CONTAINS_WORD_IS_NOT_A_WORD:int = 1;
      
      private const IS_A_WORD:int = 2;
      
      private const IS_A_SPECIAL_CHARACTER:int = 3;
      
      private var _predictiveTree:PredictiveTextTree;
      
      private var _chatMsgText:TextField;
      
      private var _predictiveTextMC:MovieClip;
      
      private var _chatBar:MovieClip;
      
      private var _sendMsgCallback:Function;
      
      private var _completeSuggestionCallback:Function;
      
      private var _wordValidity:int;
      
      private var _currWordStartIndex:int;
      
      private var _currWordEndIndex:int;
      
      private var _currWordLength:int;
      
      private var _isShiftOn:Boolean;
      
      private var _writtenWordsLength:Array;
      
      private var _wasBackspaced:Boolean;
      
      public function PredictiveTextManager()
      {
         super();
      }
      
      public static function requestAndCreateTextTreeNode() : void
      {
         _hasRequestedWords = true;
         var dpdh:DefPacksDefHelper = new DefPacksDefHelper();
         dpdh.init(uint(DefPacksDefHelper.PREDICTIVE_TEXT_FILE_TO_APPEND_TO + "" + LocalizationManager.currentLanguage),wordListResponse,null,FileServerEvent.PLAIN_TEXT_TYPE);
         DefPacksDefHelper.mediaArray[1] = dpdh;
      }
      
      public static function get findPredictiveTextNodeIfPossible() : PredictiveTextNode
      {
         if(_hasRequestedWords && PredictiveTextTree.defaultRoot != null && _lastRequestedLanguage == LocalizationManager.currentLanguage)
         {
            return PredictiveTextTree.defaultRoot;
         }
         return null;
      }
      
      public static function get lastRequestedPredictiveLanguage() : int
      {
         return _lastRequestedLanguage;
      }
      
      public static function get hasRequestWordsList() : Boolean
      {
         return _hasRequestedWords;
      }
      
      private static function wordListResponse(df:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.PREDICTIVE_TEXT_FILE_TO_APPEND_TO + "" + LocalizationManager.currentLanguage] = null;
         var str:String = df.def.toString().toLowerCase() as String;
         var arr:Array = str.split("\r\n");
         var arrLength:int = int(arr.length);
         PredictiveTextTree.init();
         for(var i:int = 0; i < arrLength; i++)
         {
            PredictiveTextTree.addFromStart(arr[i].split(","));
         }
         PredictiveTextTree.optimizeTree(PredictiveTextTree.defaultRoot);
         if(Boolean(_predictiveTreesToFullFill))
         {
            for(i = 0; i < _predictiveTreesToFullFill.length; i++)
            {
               _predictiveTreesToFullFill[i].predictiveTree.updateRoot(PredictiveTextTree.defaultRoot);
            }
            _predictiveTreesToFullFill = null;
         }
         _lastRequestedLanguage = LocalizationManager.currentLanguage;
      }
      
      public function init(chatMessageText:TextField, initPredictiveTextNode:PredictiveTextNode, useType:int = 0, predictiveText:MovieClip = null, chatBarContainer:MovieClip = null, sendMessageCallback:Function = null, completeSuggestionCallback:Function = null) : void
      {
         this._chatBar = chatBarContainer;
         this._chatMsgText = chatMessageText;
         this._predictiveTextMC = predictiveText;
         this._sendMsgCallback = sendMessageCallback;
         this._completeSuggestionCallback = completeSuggestionCallback;
         if(Boolean(this._predictiveTextMC))
         {
            this._predictiveTextMC.visible = false;
            this._predictiveTextMC["predictTxtTag0"].addEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag,false,0,true);
         }
         this._wordValidity = this.IS_A_WORD;
         this._chatMsgText.restrict = "";
         this._chatMsgText.defaultTextFormat.color = 4531987;
         this._chatMsgText.tabEnabled = false;
         this._writtenWordsLength = [];
         this._predictiveTree = new PredictiveTextTree(initPredictiveTextNode,useType);
         if(initPredictiveTextNode == null)
         {
            if(_predictiveTreesToFullFill == null)
            {
               _predictiveTreesToFullFill = [];
            }
            _predictiveTreesToFullFill.push(this);
         }
      }
      
      public function reload(chatMessageText:TextField, predictiveText:MovieClip = null, chatBarContainer:MovieClip = null) : void
      {
         this._chatBar = chatBarContainer;
         this._chatMsgText = chatMessageText;
         if(Boolean(this._predictiveTextMC))
         {
            this._predictiveTextMC["predictTxtTag0"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag);
         }
         this._predictiveTextMC = predictiveText;
         if(Boolean(this._predictiveTextMC))
         {
            this._predictiveTextMC.visible = false;
            this._predictiveTextMC["predictTxtTag0"].addEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag,false,0,true);
         }
         this._wordValidity = this.IS_A_WORD;
         this._chatMsgText.restrict = "";
         this._chatMsgText.defaultTextFormat.color = 4531987;
         this._chatMsgText.tabEnabled = false;
         this._writtenWordsLength = [];
      }
      
      public function destroy() : void
      {
         if(Boolean(this._predictiveTextMC))
         {
            this._predictiveTextMC["predictTxtTag0"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag);
         }
         this._predictiveTree.destroy();
         this._chatBar = null;
         this._chatMsgText = null;
         this._predictiveTextMC = null;
         this._sendMsgCallback = null;
         this._completeSuggestionCallback = null;
      }
      
      public function get predictiveTree() : PredictiveTextTree
      {
         return this._predictiveTree;
      }
      
      public function get currentRestriction() : String
      {
         return this._predictiveTree.currentRestriction;
      }
      
      public function onTextFieldChanged(evt:Event) : void
      {
         var modifyCurrEndIndexAfterFormatting:Boolean = false;
         if(this._wasBackspaced)
         {
            this._wasBackspaced = false;
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            this._predictiveTree.backspaced();
            AJAudio.playTextType();
            if(this._currWordLength == 0)
            {
               this._currWordLength = this._writtenWordsLength.pop();
            }
            else
            {
               --this._currWordLength;
            }
            if(this._currWordEndIndex - 1 < this._currWordStartIndex)
            {
               if(this._currWordEndIndex > 0)
               {
                  this.findWhereLastWordStarts();
                  modifyCurrEndIndexAfterFormatting = true;
               }
            }
            else if(this._currWordEndIndex > 0)
            {
               --this._currWordEndIndex;
               this.setPredictiveTextField();
            }
            if(this._currWordEndIndex == 0)
            {
               this._writtenWordsLength.splice(0,this._writtenWordsLength.length);
               this._currWordLength = 0;
               this._wordValidity = this.IS_A_WORD;
               if(Boolean(this._predictiveTextMC))
               {
                  this._predictiveTextMC.visible = false;
               }
            }
            else
            {
               this._wordValidity = this._predictiveTree.checkCurrentWordValidity();
            }
            this.setTxtFormat();
            if(modifyCurrEndIndexAfterFormatting)
            {
               --this._currWordEndIndex;
               modifyCurrEndIndexAfterFormatting = false;
            }
            if(Boolean(this._chatBar))
            {
               this._chatBar.chatBGColor.white.visible = true;
            }
            this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
         }
      }
      
      public function onKeyUp(evt:KeyboardEvent) : void
      {
         if(evt.keyCode == Keyboard.SHIFT)
         {
            this._isShiftOn = false;
         }
         if(this._chatMsgText.type != TextFieldType.INPUT)
         {
            this._chatMsgText.type = TextFieldType.INPUT;
            this._chatMsgText.selectable = true;
         }
         if(evt.keyCode > 36 && evt.keyCode < 41)
         {
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         }
      }
      
      public function onKeyDown(evt:KeyboardEvent, textFieldInput:String) : void
      {
         var periodMatch:Array = null;
         var questionMarkMatch:Array = null;
         var format:TextFormat = null;
         this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         var regEx:RegExp = new RegExp("[:)(\'.,?!" + this.currentRestriction + "]","g");
         if(evt.ctrlKey || evt.altKey || evt.keyCode == Keyboard.ALTERNATE)
         {
            if(evt.keyCode == Keyboard.BACKSPACE)
            {
               this._chatMsgText.type = TextFieldType.DYNAMIC;
               this._chatMsgText.selectable = false;
            }
            return;
         }
         if(this._chatMsgText.type != TextFieldType.INPUT)
         {
            this._chatMsgText.type = TextFieldType.INPUT;
            this._chatMsgText.selectable = true;
         }
         var regExpMatch:Array = textFieldInput != null ? textFieldInput.toLowerCase().match(regEx) : null;
         if(evt.keyCode != Keyboard.ENTER && evt.keyCode != Keyboard.BACKSPACE && (this._chatMsgText.maxChars > 0 ? Boolean(this._chatMsgText.length >= this._chatMsgText.maxChars) : Boolean(false)))
         {
            return;
         }
         if(evt.keyCode == Keyboard.TAB)
         {
            AJAudio.playTextType();
            this.onPredictiveTag(null);
            return;
         }
         if(evt.keyCode == Keyboard.ENTER)
         {
            if(this._chatMsgText.text.length > 0 && this._wordValidity >= this.IS_A_WORD)
            {
               if(this._sendMsgCallback != null)
               {
                  this._sendMsgCallback(null);
                  this.resetTreeSearch();
               }
            }
            AJAudio.playTextEnter();
         }
         else
         {
            if(evt.keyCode == Keyboard.BACKSPACE)
            {
               this._wasBackspaced = true;
               return;
            }
            if(evt.keyCode == Keyboard.SHIFT)
            {
               this._isShiftOn = true;
            }
            else if(regExpMatch != null && regExpMatch.length != 0 && regExpMatch.length == textFieldInput.length)
            {
               AJAudio.playTextType();
               periodMatch = textFieldInput.toLowerCase().match(/[\.,]/g);
               questionMarkMatch = textFieldInput.toLowerCase().match(/[?!]/g);
               if(periodMatch != null && periodMatch.length != 0 && periodMatch.length == textFieldInput.length)
               {
                  if(this._wordValidity > 1)
                  {
                     ++this._currWordEndIndex;
                     ++this._currWordLength;
                     this._predictiveTree.onSpecialCharacter();
                     this._wordValidity = this.IS_A_SPECIAL_CHARACTER;
                     this._chatMsgText.appendText(textFieldInput);
                     this.setTxtFormat();
                     this.setPredictiveTextField();
                  }
               }
               else if(questionMarkMatch != null && questionMarkMatch.length != 0 && questionMarkMatch.length == textFieldInput.length)
               {
                  if(this._wordValidity > 1)
                  {
                     if(this._isShiftOn)
                     {
                        ++this._currWordEndIndex;
                        ++this._currWordLength;
                        this._wordValidity = this.IS_A_SPECIAL_CHARACTER;
                        this._predictiveTree.onSpecialCharacter();
                        this._chatMsgText.appendText(textFieldInput);
                        this.setTxtFormat();
                        this.setPredictiveTextField();
                     }
                  }
               }
               else
               {
                  if(!(this._wordValidity != this.DOES_NOT_CONTAIN_WORD && this._wordValidity != this.IS_A_SPECIAL_CHARACTER && evt.charCode > 0))
                  {
                     AJAudio.playLimitedChatErrorSound();
                     if(Boolean(this._chatBar))
                     {
                        this._chatBar.chatBGColor.white.visible = false;
                     }
                     return;
                  }
                  ++this._currWordEndIndex;
                  ++this._currWordLength;
                  this._wordValidity = this._predictiveTree.containsString(textFieldInput.toLowerCase());
                  this._chatMsgText.appendText(textFieldInput);
                  this.setTxtFormat();
                  this.setPredictiveTextField();
               }
               this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            }
            else if(evt.keyCode == Keyboard.SPACE)
            {
               if(this._wordValidity != this.DOES_NOT_CONTAIN_WORD)
               {
                  format = new TextFormat();
                  if(this._wordValidity == this.DEFAULT_WORD_VALIDITY)
                  {
                     this._wordValidity = this._predictiveTree.checkCurrentWordValidity();
                  }
                  if(this._wordValidity > this.CONTAINS_WORD_IS_NOT_A_WORD)
                  {
                     AJAudio.playTextType();
                     format.bold = true;
                     this._chatMsgText.appendText(" ");
                     this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
                     this._predictiveTree.onSpacebar();
                     format.color = 4531987;
                     ++this._currWordEndIndex;
                     this._writtenWordsLength.push(this._currWordLength);
                     this._currWordLength = 0;
                     if(this._currWordStartIndex <= 0)
                     {
                        this._chatMsgText.setTextFormat(format);
                     }
                     else
                     {
                        this._chatMsgText.setTextFormat(format,this._currWordStartIndex,this._currWordEndIndex);
                     }
                     this._currWordStartIndex = this._currWordEndIndex;
                     this._wordValidity = this.IS_A_WORD;
                     if(Boolean(this._predictiveTextMC))
                     {
                        this._predictiveTextMC.visible = false;
                     }
                  }
                  else
                  {
                     this._wordValidity = this.DEFAULT_WORD_VALIDITY;
                     if(this._chatMsgText.text.charAt(this._chatMsgText.length - 1) != " ")
                     {
                        if(Boolean(this._chatBar))
                        {
                           this._chatBar.chatBGColor.white.visible = false;
                        }
                        format.bold = false;
                        format.color = 16711680;
                        if(this._currWordStartIndex <= 0)
                        {
                           this._chatMsgText.setTextFormat(format);
                        }
                        else
                        {
                           this._chatMsgText.setTextFormat(format,this._currWordStartIndex,this._currWordEndIndex);
                        }
                     }
                  }
               }
            }
         }
         this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
      }
      
      public function resetTreeSearch() : void
      {
         this._currWordStartIndex = 0;
         this._currWordEndIndex = 0;
         this._currWordLength = 0;
         this._writtenWordsLength.splice(0,this._writtenWordsLength.length);
         this._wordValidity = this.IS_A_WORD;
         this._isShiftOn = false;
         this._predictiveTree.resetSearchTree();
         if(Boolean(this._predictiveTextMC))
         {
            this._predictiveTextMC.visible = false;
         }
         if(Boolean(this._chatBar))
         {
            this._chatBar.chatBGColor.white.visible = true;
         }
         this.setTxtFormat();
         this._chatMsgText.scrollV = 0;
         this._chatMsgText.text = "";
         this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
      }
      
      public function onSendBtnDown(evt:MouseEvent) : void
      {
         if(this._chatMsgText.text.length > 0 && this._wordValidity >= this.IS_A_WORD)
         {
            if(Boolean(this._chatMsgText.text.match("\r")))
            {
               return;
            }
            if(this._sendMsgCallback != null)
            {
               this._sendMsgCallback(evt);
               this.resetTreeSearch();
            }
         }
      }
      
      public function isWordValid() : Boolean
      {
         return this._wordValidity >= this.IS_A_WORD;
      }
      
      private function onPredictiveTag(evt:MouseEvent) : void
      {
         var txt:String = null;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(Boolean(this._predictiveTextMC) && this._predictiveTextMC.visible)
         {
            txt = this._predictiveTextMC.predictTxtTag0.txt.text;
            txt = txt.substr(this._currWordLength);
            if(this._completeSuggestionCallback != null)
            {
               this._completeSuggestionCallback(txt,false,this.onPredictiveTxtTagWork);
            }
            else
            {
               this.onPredictiveTxtTagWork(txt);
            }
         }
      }
      
      private function onPredictiveTxtTagWork(txt:String, allow:Boolean = true) : void
      {
         var format:TextFormat = null;
         var txtArray:Array = null;
         var i:int = 0;
         if(allow)
         {
            format = new TextFormat();
            if(txt != "")
            {
               txtArray = txt.split("");
               for(i = 0; i < txtArray.length; i++)
               {
                  this._predictiveTree.containsString(txtArray[i]);
               }
               this._currWordEndIndex += txt.length;
               this._currWordLength += txt.length;
               this._chatMsgText.appendText(txt);
            }
            format.bold = true;
            this._chatMsgText.appendText(" ");
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            this._predictiveTree.onSpacebar();
            format.color = 4531987;
            ++this._currWordEndIndex;
            this._writtenWordsLength.push(this._currWordLength);
            this._currWordLength = 0;
            this._chatMsgText.setTextFormat(format,this._currWordStartIndex,this._currWordEndIndex);
            this._currWordStartIndex = this._currWordEndIndex;
            this._wordValidity = this.IS_A_WORD;
            this._predictiveTextMC.visible = false;
            if(this._currWordEndIndex != this._currWordStartIndex)
            {
               this.setTxtFormat();
            }
            this._predictiveTree.clearWordSuggestions();
            this._predictiveTextMC.visible = false;
            gMainFrame.stage.focus = this._chatMsgText;
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
            if(this._completeSuggestionCallback != null)
            {
               this._completeSuggestionCallback("",true);
            }
         }
      }
      
      private function setPredictiveTextField() : void
      {
         var predictiveWord:String = null;
         if(Boolean(this._predictiveTextMC))
         {
            if(this._chatMsgText.length > 0 && (this._wordValidity == this.IS_A_WORD || this._wordValidity == this.CONTAINS_WORD_IS_NOT_A_WORD))
            {
               predictiveWord = this._predictiveTree.showTopWord();
               if(predictiveWord != null)
               {
                  this._predictiveTextMC.visible = true;
                  this._predictiveTextMC.gotoAndStop(1);
                  this._predictiveTextMC["predictTxtTag0"].setText(predictiveWord);
               }
               else
               {
                  this._predictiveTextMC.visible = false;
               }
            }
            else
            {
               this._predictiveTextMC.visible = false;
            }
         }
      }
      
      private function setTxtFormat() : void
      {
         var format:TextFormat = new TextFormat();
         if(this._currWordEndIndex == 0 && this._currWordStartIndex == 0)
         {
            this._wordValidity == this.IS_A_WORD;
         }
         if(this._wordValidity > this.CONTAINS_WORD_IS_NOT_A_WORD)
         {
            this._chatMsgText.textColor = 4531987;
            if(Boolean(this._chatBar))
            {
               this._chatBar.chatBGColor.white.visible = true;
            }
            format.bold = false;
            format.color = 4531987;
            if(this._currWordStartIndex <= 0)
            {
               this._chatMsgText.setTextFormat(format);
            }
            else
            {
               this._chatMsgText.setTextFormat(format,this._currWordStartIndex,this._currWordEndIndex);
            }
         }
         else
         {
            if(this._wordValidity == this.DOES_NOT_CONTAIN_WORD)
            {
               if(Boolean(this._chatBar))
               {
                  this._chatBar.chatBGColor.white.visible = false;
               }
            }
            format.bold = false;
            format.color = 16711680;
            if(this._currWordStartIndex <= 0)
            {
               this._chatMsgText.setTextFormat(format);
            }
            else
            {
               this._chatMsgText.setTextFormat(format,this._currWordStartIndex,this._currWordEndIndex);
            }
         }
      }
      
      private function findWhereLastWordStarts() : void
      {
         var skippedFirstSpace:Boolean = false;
         var i:int = 0;
         if(this._currWordStartIndex - 1 >= 0)
         {
            skippedFirstSpace = false;
            for(i = this._currWordStartIndex - 1; i >= 0; i--)
            {
               if(this._chatMsgText.text.charAt(i) == " ")
               {
                  if(i != this._currWordStartIndex - 1)
                  {
                     this.setPredictiveTextField();
                     this._currWordEndIndex = skippedFirstSpace ? this._currWordStartIndex : int(this._currWordStartIndex - 1);
                     this._currWordStartIndex = i == this._currWordStartIndex - 1 ? i : int(i + 1);
                     break;
                  }
                  skippedFirstSpace = true;
               }
               if(i == 0)
               {
                  this._currWordEndIndex = skippedFirstSpace ? this._currWordStartIndex : int(this._currWordStartIndex - 1);
                  this._currWordStartIndex = i;
               }
            }
         }
      }
   }
}

