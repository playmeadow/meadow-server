package gui
{
   import com.sbi.loader.FileServerEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
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
      
      private var _currMsgText:String;
      
      private var _predictiveTextMC:MovieClip;
      
      private var _specialCharTextMC:MovieClip;
      
      private var _chatBar:MovieClip;
      
      private var _sendMsgCallback:Function;
      
      private var _completeSuggestionCallback:Function;
      
      private var _wordValidity:int;
      
      private var _currWordStartIndex:int;
      
      private var _currWordEndIndex:int;
      
      private var _currWordLength:int;
      
      private var _isShiftOn:Boolean;
      
      private var _writtenWordsLength:Array;
      
      private var _wordCapitalizationProperties:Array;
      
      private var _specialCharWindow:WindowGenerator;
      
      private var _wasBackspaced:Boolean;
      
      private var _predictiveTextOriginalYLoc:Number;
      
      private var _firstLetterWasCapital:Boolean;
      
      private var _secondLetterWasCapital:Boolean;
      
      public function PredictiveTextManager()
      {
         super();
      }
      
      public static function requestAndCreateTextTreeNode() : void
      {
         _hasRequestedWords = true;
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init(uint(DefPacksDefHelper.PREDICTIVE_TEXT_FILE_TO_APPEND_TO + "" + LocalizationManager.currentLanguage),wordListResponse,null,FileServerEvent.PLAIN_TEXT_TYPE);
         DefPacksDefHelper.mediaArray[1] = _loc1_;
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
      
      private static function wordListResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.PREDICTIVE_TEXT_FILE_TO_APPEND_TO + "" + LocalizationManager.currentLanguage] = null;
         var _loc2_:String = param1.def.toString().toLowerCase() as String;
         var _loc3_:Array = _loc2_.split("\r\n");
         var _loc4_:int = int(_loc3_.length);
         PredictiveTextTree.init();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(_loc5_ < 2 && LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
            {
               if(_loc5_ == 0)
               {
                  PredictiveTextTree.setupSpecialCharsRegEx(_loc3_[_loc5_]);
               }
               else if(_loc5_ == 1)
               {
                  PredictiveTextTree.setupConversionChars(_loc3_[_loc5_]);
               }
            }
            else
            {
               PredictiveTextTree.addFromStart(_loc3_[_loc5_].split(","));
            }
            _loc5_++;
         }
         PredictiveTextTree.optimizeTree(PredictiveTextTree.defaultRoot);
         if(_predictiveTreesToFullFill)
         {
            _loc5_ = 0;
            while(_loc5_ < _predictiveTreesToFullFill.length)
            {
               _predictiveTreesToFullFill[_loc5_].predictiveTree.updateRoot(PredictiveTextTree.defaultRoot);
               _loc5_++;
            }
            _predictiveTreesToFullFill = null;
         }
         _lastRequestedLanguage = LocalizationManager.currentLanguage;
      }
      
      public function init(param1:TextField, param2:PredictiveTextNode, param3:int = 0, param4:MovieClip = null, param5:MovieClip = null, param6:MovieClip = null, param7:Function = null, param8:Function = null) : void
      {
         this._chatBar = param6;
         this._chatMsgText = param1;
         this._predictiveTextMC = param4;
         this._specialCharTextMC = param5;
         this._sendMsgCallback = param7;
         this._completeSuggestionCallback = param8;
         if(this._predictiveTextMC)
         {
            this._predictiveTextMC.visible = false;
            this._predictiveTextMC["predictTxtTag0"].addEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag,false,0,true);
            this._predictiveTextOriginalYLoc = this._predictiveTextMC.y;
         }
         if(this._specialCharTextMC)
         {
            this._specialCharTextMC.visible = false;
         }
         this._chatMsgText.defaultTextFormat.color = 4531987;
         this._chatMsgText.tabEnabled = false;
         this._writtenWordsLength = [];
         this._wordCapitalizationProperties = [];
         this._predictiveTree = new PredictiveTextTree(param2,param3);
         if(param2 == null)
         {
            if(_predictiveTreesToFullFill == null)
            {
               _predictiveTreesToFullFill = [];
            }
            _predictiveTreesToFullFill.push(this);
         }
         this.resetTreeSearch();
      }
      
      public function reload(param1:TextField, param2:MovieClip = null, param3:MovieClip = null, param4:MovieClip = null) : void
      {
         this._chatBar = param4;
         this._chatMsgText = param1;
         this._currMsgText = this._chatMsgText.text;
         if(this._predictiveTextMC)
         {
            this._predictiveTextMC["predictTxtTag0"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag);
         }
         this._predictiveTextMC = param2;
         this._specialCharTextMC = param3;
         if(this._predictiveTextMC)
         {
            this._predictiveTextMC.visible = false;
            this._predictiveTextMC["predictTxtTag0"].addEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag,false,0,true);
            this._predictiveTextOriginalYLoc = this._predictiveTextMC.y;
         }
         if(this._specialCharTextMC)
         {
            this._specialCharTextMC.visible = false;
         }
         this._chatMsgText.defaultTextFormat.color = 4531987;
         this._chatMsgText.tabEnabled = false;
         this._writtenWordsLength = [];
         this._wordCapitalizationProperties = [];
         this.resetTreeSearch();
      }
      
      public function destroy() : void
      {
         if(this._predictiveTextMC)
         {
            this._predictiveTextMC["predictTxtTag0"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag);
         }
         this._predictiveTree.destroy();
         this._chatBar = null;
         this._chatMsgText = null;
         this._currMsgText = "";
         this._predictiveTextMC = null;
         this._specialCharTextMC = null;
         this._sendMsgCallback = null;
         this._completeSuggestionCallback = null;
      }
      
      public function addWordToPredictiveText(param1:String) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc2_:TextFormat = new TextFormat();
         if(param1 != "")
         {
            _loc3_ = param1.split("");
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               this._predictiveTree.containsString(_loc3_[_loc4_]);
               _loc4_++;
            }
            this._currWordEndIndex += param1.length;
            this._currWordLength += param1.length;
            if(this.shouldCapitalizeString(param1))
            {
               param1 = param1.toUpperCase();
            }
            this._chatMsgText.appendText(param1);
            this._currMsgText += param1;
         }
         _loc2_.bold = true;
         this._chatMsgText.appendText(" ");
         this._currMsgText += " ";
         this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         this._predictiveTree.onSpacebar();
         _loc2_.color = 4531987;
         ++this._currWordEndIndex;
         this._writtenWordsLength.push(this._currWordLength);
         this._currWordLength = 0;
         this._chatMsgText.setTextFormat(_loc2_,this._currWordStartIndex,this._currWordEndIndex);
         this._wordCapitalizationProperties.push({
            "firstLetterWasCapital":this._firstLetterWasCapital,
            "secondLetterWasCapital":this._secondLetterWasCapital
         });
         this._currWordStartIndex = this._currWordEndIndex;
         this._wordValidity = this.IS_A_WORD;
         this._predictiveTextMC.visible = false;
         if(this._specialCharTextMC)
         {
            this._specialCharTextMC.visible = false;
         }
         if(this._currWordEndIndex != this._currWordStartIndex)
         {
            this.setTxtFormat();
         }
         this._predictiveTree.clearWordSuggestions();
         this._predictiveTextMC.visible = false;
         if(this._specialCharTextMC)
         {
            this._specialCharTextMC.visible = false;
         }
         gMainFrame.stage.focus = this._chatMsgText;
         this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
         if(this._completeSuggestionCallback != null)
         {
            this._completeSuggestionCallback("",true);
         }
      }
      
      public function get predictiveTree() : PredictiveTextTree
      {
         return this._predictiveTree;
      }
      
      public function onTextFieldChanged(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         if(this._wasBackspaced)
         {
            this._wasBackspaced = false;
            this._predictiveTree.backspaced();
            AJAudio.playTextType();
            if(this._currWordLength == 0)
            {
               this._currWordLength = this._writtenWordsLength.pop();
               _loc3_ = this._wordCapitalizationProperties.pop();
               if(_loc3_)
               {
                  this._firstLetterWasCapital = _loc3_.firstLetterWasCapital;
                  this._secondLetterWasCapital = _loc3_.secondLetterWasCapital;
               }
               else
               {
                  this._firstLetterWasCapital = false;
                  this._secondLetterWasCapital = false;
               }
            }
            else
            {
               --this._currWordLength;
            }
            if(this._currWordEndIndex - 2 < this._currWordStartIndex)
            {
               if(this._currWordEndIndex > 0)
               {
                  this.findWhereLastWordStarts();
                  _loc2_ = true;
               }
            }
            else if(this._currWordEndIndex > 0)
            {
               --this._currWordEndIndex;
               this.setPredictiveTextField();
            }
            if(_loc2_)
            {
               --this._currWordEndIndex;
               _loc2_ = false;
            }
            if(this._currWordEndIndex == 0)
            {
               this._writtenWordsLength.splice(0,this._writtenWordsLength.length);
               this._wordCapitalizationProperties = [];
               this._currWordLength = 0;
               this._firstLetterWasCapital = false;
               this._secondLetterWasCapital = false;
               this._wordValidity = this.IS_A_WORD;
               if(this._predictiveTextMC)
               {
                  this._predictiveTextMC.visible = false;
               }
            }
            else
            {
               this._wordValidity = this._predictiveTree.checkCurrentWordValidity();
            }
            this.setTxtFormat();
            this._chatMsgText.setSelection(this._chatMsgText.length - 1,this._chatMsgText.length - 1);
            this.setSpecialCharMC(this._chatMsgText.text.charAt(this._chatMsgText.text.length - 1));
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            if(this._chatBar)
            {
               this._chatBar.chatBGColor.white.visible = true;
            }
            this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
            this._currMsgText = this._chatMsgText.text;
         }
         else
         {
            this._chatMsgText.text = this._currMsgText;
            this.setTxtFormat();
            this._chatMsgText.setSelection(this._chatMsgText.length - 1,this._chatMsgText.length - 1);
            this.setSpecialCharMC(this._chatMsgText.text.charAt(this._chatMsgText.text.length - 1));
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
         }
      }
      
      public function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.SHIFT)
         {
            this._isShiftOn = false;
         }
         if(this._chatMsgText.type != TextFieldType.INPUT)
         {
            this._chatMsgText.type = TextFieldType.INPUT;
            this._chatMsgText.selectable = true;
         }
         if(param1.keyCode > 36 && param1.keyCode < 41)
         {
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         }
      }
      
      public function onKeyDown(param1:KeyboardEvent, param2:String) : void
      {
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:TextFormat = null;
         this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         var _loc3_:RegExp = new RegExp("[|:|)|(|\'|.|,|?|!|" + this.currentRestriction + "|]","g");
         if(param1.ctrlKey || param1.altKey || param1.keyCode == Keyboard.ALTERNATE)
         {
            if(param1.keyCode == Keyboard.BACKSPACE)
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
         var _loc4_:Array = null;
         if(param2 != null)
         {
            if(this._currWordLength == 0)
            {
               _loc4_ = param2.toLowerCase().match(_loc3_);
               if(_loc4_ != null && _loc4_.length != 0 && _loc4_.length == param2.length)
               {
                  _loc5_ = param2.toLowerCase().match(/\[|;|\)|\(|'|\.|,|\?|!/g);
                  if(_loc5_ == null || _loc5_ != null && _loc5_.length == 0)
                  {
                     this._firstLetterWasCapital = param2 == param2.toUpperCase();
                  }
                  else
                  {
                     this._firstLetterWasCapital = false;
                  }
               }
            }
            else if(this._currWordLength == 1)
            {
               if(this._firstLetterWasCapital)
               {
                  _loc4_ = param2.toLowerCase().match(_loc3_);
               }
               else
               {
                  param2 = param2.toLowerCase();
                  _loc4_ = param2.match(_loc3_);
               }
               if(_loc4_ != null && _loc4_.length != 0 && _loc4_.length == param2.length)
               {
                  _loc5_ = param2.toLowerCase().match(/\[|;|\)|\(|'|\.|,|\?|!/g);
                  if(_loc5_ == null || _loc5_ != null && _loc5_.length == 0)
                  {
                     this._secondLetterWasCapital = param2 == param2.toUpperCase();
                  }
                  else if(Keyboard.capsLock || this._isShiftOn)
                  {
                     this._secondLetterWasCapital = true;
                  }
                  else
                  {
                     this._secondLetterWasCapital = false;
                  }
               }
            }
            else if(this._currWordLength >= 2)
            {
               if(this._secondLetterWasCapital)
               {
                  param2 = param2.toUpperCase();
                  _loc4_ = param2.toLowerCase().match(_loc3_);
               }
               else
               {
                  param2 = param2.toLowerCase();
                  _loc4_ = param2.match(_loc3_);
               }
            }
         }
         if(param1.keyCode != Keyboard.ENTER && param1.keyCode != Keyboard.BACKSPACE && (this._chatMsgText.maxChars > 0 ? Boolean(this._chatMsgText.length >= this._chatMsgText.maxChars) : Boolean(false)))
         {
            return;
         }
         if(param1.keyCode == Keyboard.TAB)
         {
            AJAudio.playTextType();
            this.onPredictiveTag(null);
            return;
         }
         if(param1.keyCode == Keyboard.ENTER)
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
            if(param1.keyCode == Keyboard.BACKSPACE)
            {
               this._wasBackspaced = true;
               return;
            }
            if(param1.keyCode == Keyboard.SHIFT)
            {
               this._isShiftOn = true;
            }
            else if(_loc4_ != null && _loc4_.length != 0 && _loc4_.length == param2.length)
            {
               AJAudio.playTextType();
               _loc6_ = param2.toLowerCase().match(/[\.,]/g);
               _loc7_ = param2.toLowerCase().match(/[?!]/g);
               if(_loc6_ != null && _loc6_.length != 0 && _loc6_.length == param2.length)
               {
                  if(this._wordValidity > 1)
                  {
                     ++this._currWordEndIndex;
                     ++this._currWordLength;
                     this._predictiveTree.onSpecialCharacter();
                     this._wordValidity = this.IS_A_SPECIAL_CHARACTER;
                     this._chatMsgText.appendText(param2);
                     this._currMsgText += param2;
                     this.setTxtFormat();
                     this.setPredictiveTextField();
                     this.setSpecialCharMC(param2);
                  }
               }
               else if(_loc7_ != null && _loc7_.length != 0 && _loc7_.length == param2.length)
               {
                  if(this._wordValidity > 1)
                  {
                     if(this._isShiftOn)
                     {
                        ++this._currWordEndIndex;
                        ++this._currWordLength;
                        this._wordValidity = this.IS_A_SPECIAL_CHARACTER;
                        this._predictiveTree.onSpecialCharacter();
                        this._chatMsgText.appendText(param2);
                        this._currMsgText += param2;
                        this.setTxtFormat();
                        this.setPredictiveTextField();
                     }
                  }
               }
               else
               {
                  if(!(this._wordValidity != this.DOES_NOT_CONTAIN_WORD && this._wordValidity != this.IS_A_SPECIAL_CHARACTER && param1.charCode > 0))
                  {
                     AJAudio.playLimitedChatErrorSound();
                     if(this._chatBar)
                     {
                        this._chatBar.chatBGColor.white.visible = false;
                     }
                     return;
                  }
                  ++this._currWordEndIndex;
                  ++this._currWordLength;
                  this._wordValidity = this._predictiveTree.containsString(param2.toLowerCase());
                  this._chatMsgText.appendText(param2);
                  this._currMsgText += param2;
                  this.setTxtFormat();
                  this.setPredictiveTextField();
                  this.setSpecialCharMC(param2);
               }
               this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            }
            else if(param1.keyCode == Keyboard.SPACE)
            {
               if(this._wordValidity != this.DOES_NOT_CONTAIN_WORD)
               {
                  _loc8_ = new TextFormat();
                  if(this._wordValidity == this.DEFAULT_WORD_VALIDITY)
                  {
                     this._wordValidity = this._predictiveTree.checkCurrentWordValidity();
                  }
                  if(this._wordValidity > this.CONTAINS_WORD_IS_NOT_A_WORD)
                  {
                     AJAudio.playTextType();
                     _loc8_.bold = true;
                     this._chatMsgText.appendText(" ");
                     this._currMsgText += " ";
                     this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
                     this._predictiveTree.onSpacebar();
                     _loc8_.color = 4531987;
                     ++this._currWordEndIndex;
                     this._writtenWordsLength.push(this._currWordLength);
                     this._wordCapitalizationProperties.push({
                        "firstLetterWasCapital":this._firstLetterWasCapital,
                        "secondLetterWasCapital":this._secondLetterWasCapital
                     });
                     this._currWordLength = 0;
                     this._firstLetterWasCapital = false;
                     this._secondLetterWasCapital = false;
                     if(this._currWordStartIndex <= 0)
                     {
                        this._chatMsgText.setTextFormat(_loc8_);
                     }
                     else
                     {
                        this._chatMsgText.setTextFormat(_loc8_,this._currWordStartIndex,this._currWordEndIndex);
                     }
                     this._currWordStartIndex = this._currWordEndIndex;
                     this._wordValidity = this.IS_A_WORD;
                     if(this._predictiveTextMC)
                     {
                        this._predictiveTextMC.visible = false;
                     }
                  }
                  else
                  {
                     this._wordValidity = this.DEFAULT_WORD_VALIDITY;
                     if(this._chatMsgText.text.charAt(this._chatMsgText.length - 1) != " ")
                     {
                        if(this._chatBar)
                        {
                           this._chatBar.chatBGColor.white.visible = false;
                        }
                        _loc8_.bold = false;
                        _loc8_.color = 16711680;
                        if(this._currWordStartIndex <= 0)
                        {
                           this._chatMsgText.setTextFormat(_loc8_);
                        }
                        else
                        {
                           this._chatMsgText.setTextFormat(_loc8_,this._currWordStartIndex,this._currWordEndIndex);
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
         this._wordCapitalizationProperties = [];
         this._wordValidity = this.IS_A_WORD;
         this._isShiftOn = false;
         if(this._predictiveTree)
         {
            this._predictiveTree.resetSearchTree();
            this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
            this.setTxtFormat();
         }
         if(this._specialCharTextMC)
         {
            this._specialCharTextMC.visible = false;
         }
         if(this._predictiveTextMC)
         {
            this._predictiveTextMC.visible = false;
         }
         if(this._chatBar)
         {
            this._chatBar.chatBGColor.white.visible = true;
         }
         this._chatMsgText.scrollV = 0;
         this._chatMsgText.text = "";
         this._currMsgText = "";
         this._firstLetterWasCapital = false;
         this._secondLetterWasCapital = false;
      }
      
      public function onSendBtnDown(param1:MouseEvent) : void
      {
         if(this._chatMsgText.text.length > 0 && this._wordValidity >= this.IS_A_WORD)
         {
            if(this._chatMsgText.text.match("\r"))
            {
               return;
            }
            if(this._sendMsgCallback != null)
            {
               this._sendMsgCallback(param1);
               this.resetTreeSearch();
            }
         }
      }
      
      public function isWordValid() : Boolean
      {
         return this._wordValidity >= this.IS_A_WORD;
      }
      
      private function get currentRestriction() : String
      {
         return this._predictiveTree.currentRestriction;
      }
      
      private function shouldCapitalizeString(param1:String) : Boolean
      {
         if(this._currWordLength == 0)
         {
            return param1 == param1.toUpperCase();
         }
         if(this._currWordLength == 1)
         {
            if(!this._firstLetterWasCapital)
            {
               return false;
            }
            return param1 == param1.toUpperCase();
         }
         if(this._currWordLength >= 2)
         {
            if(this._secondLetterWasCapital)
            {
               return true;
            }
            return false;
         }
         return false;
      }
      
      private function onPredictiveTag(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(Boolean(this._predictiveTextMC) && this._predictiveTextMC.visible)
         {
            _loc2_ = this._predictiveTextMC.predictTxtTag0.txt.text;
            _loc2_ = _loc2_.substr(this._currWordLength);
            if(this._completeSuggestionCallback != null)
            {
               this._completeSuggestionCallback(_loc2_,false,this.onPredictiveTxtTagWork);
            }
            else
            {
               this.onPredictiveTxtTagWork(_loc2_);
            }
         }
      }
      
      private function onPredictiveTxtTagWork(param1:String, param2:Boolean = true) : void
      {
         var _loc3_:TextFormat = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         if(param2)
         {
            _loc3_ = new TextFormat();
            if(param1 != "")
            {
               _loc4_ = param1.split("");
               _loc5_ = 0;
               while(_loc5_ < _loc4_.length)
               {
                  this._predictiveTree.containsString(_loc4_[_loc5_]);
                  _loc5_++;
               }
               this._currWordEndIndex += param1.length;
               this._currWordLength += param1.length;
               if(this.shouldCapitalizeString(param1))
               {
                  param1 = param1.toUpperCase();
               }
               this._chatMsgText.appendText(param1);
               this._currMsgText += param1;
            }
            _loc3_.bold = true;
            this._chatMsgText.appendText(" ");
            this._currMsgText += " ";
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            this._predictiveTree.onSpacebar();
            _loc3_.color = 4531987;
            ++this._currWordEndIndex;
            this._writtenWordsLength.push(this._currWordLength);
            this._currWordLength = 0;
            this._chatMsgText.setTextFormat(_loc3_,this._currWordStartIndex,this._currWordEndIndex);
            this._wordCapitalizationProperties.push({
               "firstLetterWasCapital":this._firstLetterWasCapital,
               "secondLetterWasCapital":this._secondLetterWasCapital
            });
            this._currWordStartIndex = this._currWordEndIndex;
            this._wordValidity = this.IS_A_WORD;
            this._predictiveTextMC.visible = false;
            if(this._specialCharTextMC)
            {
               this._specialCharTextMC.visible = false;
            }
            if(this._currWordEndIndex != this._currWordStartIndex)
            {
               this.setTxtFormat();
            }
            this._predictiveTree.clearWordSuggestions();
            this._predictiveTextMC.visible = false;
            if(this._specialCharTextMC)
            {
               this._specialCharTextMC.visible = false;
            }
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
         var _loc1_:String = null;
         if(this._predictiveTextMC)
         {
            if(this._chatMsgText.length > 0 && (this._wordValidity == this.IS_A_WORD || this._wordValidity == this.CONTAINS_WORD_IS_NOT_A_WORD))
            {
               _loc1_ = this._predictiveTree.showTopWord();
               if(_loc1_ != null)
               {
                  this._predictiveTextMC.visible = true;
                  this._predictiveTextMC.gotoAndStop(1);
                  this._predictiveTextMC["predictTxtTag0"].setText(_loc1_);
                  this._predictiveTextMC.y = this._predictiveTextOriginalYLoc;
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
      
      private function setSpecialCharMC(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Rectangle = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(this._specialCharTextMC)
         {
            _loc2_ = this._predictiveTree.findAllLanguageSpecialChars(param1);
            if(Boolean(this._specialCharWindow) && this._specialCharWindow.parent == this._specialCharTextMC.itemWindow)
            {
               this._specialCharTextMC.itemWindow.removeChild(this._specialCharWindow);
            }
            if(Boolean(_loc2_) && _loc2_.length > 0)
            {
               this._specialCharTextMC.visible = true;
               if(this._specialCharWindow)
               {
                  this._specialCharWindow.destroy();
               }
               this._specialCharWindow = new WindowGenerator();
               this._specialCharWindow.init(_loc2_.length,1,_loc2_.length,0,0,0,ItemWindowSpecialText,_loc2_,"",{"mouseDown":this.onSpecialCharMouseDown},null,null,true);
               this._specialCharTextMC.itemWindow.itemWindowInside.width = this._specialCharWindow.boxWidth * _loc2_.length;
               this._specialCharTextMC.m.width = this._specialCharTextMC.itemWindow.width;
               this._specialCharTextMC.b.x = this._specialCharTextMC.m.x + this._specialCharTextMC.m.width;
               this._specialCharTextMC.itemWindow.addChild(this._specialCharWindow);
               _loc3_ = this._chatMsgText.caretIndex;
               _loc4_ = this._chatMsgText.getCharBoundaries(_loc3_);
               if(_loc4_ != null)
               {
                  _loc5_ = _loc4_.x + 5;
                  if(_loc4_.x > this._chatMsgText.width)
                  {
                     _loc6_ = this._chatBar ? 69 : 65;
                     _loc5_ = _loc4_.x + 5 - _loc6_ * Math.floor((_loc4_.x - this._chatMsgText.width) / _loc6_ + 1);
                  }
               }
               if(this._chatBar)
               {
                  this._specialCharTextMC.x = 343 + _loc5_;
               }
               else
               {
                  this._specialCharTextMC.x = -162 + _loc5_;
               }
               if(this._predictiveTextMC.visible && this._specialCharTextMC.x < this._predictiveTextMC.x + this._predictiveTextMC.width * 0.5)
               {
                  this._predictiveTextMC.y = this._predictiveTextOriginalYLoc - this._specialCharTextMC.height;
               }
            }
            else
            {
               this._specialCharTextMC.visible = false;
            }
         }
      }
      
      private function onSpecialCharMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.txt.text;
         if(_loc2_ != "")
         {
            this._chatMsgText.text = this._chatMsgText.text.slice(0,-1);
            this._currMsgText = this._chatMsgText.text;
            this._predictiveTree.backspaced();
            this._wordValidity = this._predictiveTree.containsString(_loc2_);
            if(this.shouldCapitalizeString(_loc2_))
            {
               _loc2_ = _loc2_.toUpperCase();
            }
            this._chatMsgText.appendText(_loc2_);
            this._currMsgText += _loc2_;
         }
         this._specialCharTextMC.visible = false;
         this.setTxtFormat();
         this.setPredictiveTextField();
         gMainFrame.stage.focus = this._chatMsgText;
         this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
         if(this._completeSuggestionCallback != null)
         {
            this._completeSuggestionCallback("",true);
         }
      }
      
      private function setTxtFormat() : void
      {
         var _loc1_:TextFormat = new TextFormat();
         if(this._currWordEndIndex == 0 && this._currWordStartIndex == 0)
         {
            this._wordValidity == this.IS_A_WORD;
            this._chatMsgText.textColor = 4531987;
         }
         else if(this._wordValidity > this.CONTAINS_WORD_IS_NOT_A_WORD)
         {
            this._chatMsgText.textColor = 4531987;
            if(this._chatBar)
            {
               this._chatBar.chatBGColor.white.visible = true;
            }
            _loc1_.bold = false;
            _loc1_.color = 4531987;
            if(this._currWordStartIndex <= 0)
            {
               this._chatMsgText.setTextFormat(_loc1_);
            }
            else
            {
               this._chatMsgText.setTextFormat(_loc1_,this._currWordStartIndex,this._currWordEndIndex);
            }
         }
         else
         {
            if(this._wordValidity == this.DOES_NOT_CONTAIN_WORD)
            {
               if(this._chatBar)
               {
                  this._chatBar.chatBGColor.white.visible = false;
               }
            }
            else if(this._chatBar)
            {
               this._chatBar.chatBGColor.white.visible = true;
            }
            _loc1_.bold = false;
            _loc1_.color = 16711680;
            if(this._currWordStartIndex <= 0)
            {
               this._chatMsgText.setTextFormat(_loc1_);
            }
            else
            {
               this._chatMsgText.setTextFormat(_loc1_,this._currWordStartIndex,this._currWordEndIndex);
            }
         }
      }
      
      private function findWhereLastWordStarts() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:* = 0;
         if(this._currWordStartIndex - 1 >= 0)
         {
            _loc1_ = false;
            _loc2_ = int(this._currWordStartIndex - 1);
            while(_loc2_ >= 0)
            {
               if(this._chatMsgText.text.charAt(_loc2_) == " ")
               {
                  if(_loc2_ != this._currWordStartIndex - 1)
                  {
                     this.setPredictiveTextField();
                     this._currWordEndIndex = _loc1_ ? int(this._currWordStartIndex + 1) : this._currWordStartIndex;
                     this._currWordStartIndex = _loc2_ == this._currWordStartIndex - 1 ? int(_loc2_) : int(_loc2_ + 1);
                     break;
                  }
                  _loc1_ = true;
               }
               if(_loc2_ == 0)
               {
                  this._currWordEndIndex = _loc1_ ? int(this._currWordStartIndex + 1) : this._currWordStartIndex;
                  this._currWordStartIndex = _loc2_;
               }
               _loc2_--;
            }
         }
      }
   }
}

