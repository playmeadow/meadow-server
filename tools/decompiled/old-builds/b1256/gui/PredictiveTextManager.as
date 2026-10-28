package gui
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   
   public class PredictiveTextManager
   {
      
      public static const USE_TYPE_ALL:int = 0;
      
      public static const USE_TYPE_ECARD:int = 1;
      
      public static const USE_TYPE_PLAYER_WALL:int = 2;
      
      private static var _predictiveTreesToFullFill:Array;
      
      private static var _lastRequestedLanguage:int;
      
      private static var _hasRequestedWords:Boolean;
      
      private const DEFAULT_WORD_VALIDITY:int = -1;
      
      private const DOES_NOT_CONTAIN_WORD:int = 0;
      
      private const CONTAINS_WORD_IS_NOT_A_WORD:int = 1;
      
      private const IS_A_WORD:int = 2;
      
      private const IS_A_SPECIAL_CHARACTER:int = 3;
      
      private const IS_AN_EMOTE_CHARACTER:int = 4;
      
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
      
      private var _specialCharStartPositionX:int;
      
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
         _loc1_.init(uint("10" + LocalizationManager.currentLanguage),wordListResponse,null,1);
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
         var _loc3_:String = null;
         var _loc6_:int = 0;
         DefPacksDefHelper.mediaArray["10" + LocalizationManager.currentLanguage] = null;
         var _loc4_:String = param1.def.toString() as String;
         var _loc5_:Array = _loc4_.split("\r\n");
         var _loc2_:int = int(_loc5_.length);
         PredictiveTextTree.init();
         _loc6_ = 0;
         while(_loc6_ < _loc2_)
         {
            _loc3_ = _loc5_[_loc6_];
            if(_loc6_ < 2 && LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
            {
               if(_loc6_ == 0)
               {
                  PredictiveTextTree.setupSpecialCharsRegEx(_loc3_.toLowerCase());
               }
               else if(_loc6_ == 1)
               {
                  PredictiveTextTree.setupConversionChars(_loc3_.toLowerCase());
               }
            }
            else
            {
               if(_loc3_.charAt(0) != ":")
               {
                  _loc3_ = _loc3_.toLowerCase();
               }
               PredictiveTextTree.addFromStart(_loc3_.split(","));
            }
            _loc6_++;
         }
         PredictiveTextTree.optimizeTree(PredictiveTextTree.defaultRoot);
         if(_predictiveTreesToFullFill)
         {
            _loc6_ = 0;
            while(_loc6_ < _predictiveTreesToFullFill.length)
            {
               _predictiveTreesToFullFill[_loc6_].predictiveTree.updateRoot(PredictiveTextTree.defaultRoot);
               _loc6_++;
            }
            _predictiveTreesToFullFill = null;
         }
         _lastRequestedLanguage = LocalizationManager.currentLanguage;
      }
      
      public function init(param1:TextField, param2:PredictiveTextNode, param3:int = 0, param4:MovieClip = null, param5:MovieClip = null, param6:int = 0, param7:MovieClip = null, param8:Function = null, param9:Function = null) : void
      {
         _chatBar = param7;
         _chatMsgText = param1;
         _predictiveTextMC = param4;
         _specialCharTextMC = param5;
         _sendMsgCallback = param8;
         _completeSuggestionCallback = param9;
         _specialCharStartPositionX = param6;
         if(_predictiveTextMC)
         {
            _predictiveTextMC.visible = false;
            _predictiveTextMC["predictTxtTag0"].addEventListener("mouseDown",onPredictiveTag,false,0,true);
            if(!("originalYLoc" in _predictiveTextMC))
            {
               _predictiveTextOriginalYLoc = _predictiveTextMC.y;
               _predictiveTextMC.originalYLoc = _predictiveTextOriginalYLoc;
            }
            else
            {
               _predictiveTextOriginalYLoc = _predictiveTextMC.originalYLoc;
            }
         }
         if(_specialCharTextMC)
         {
            _specialCharTextMC.visible = false;
         }
         _chatMsgText.defaultTextFormat.color = 4531987;
         _chatMsgText.tabEnabled = false;
         _writtenWordsLength = [];
         _wordCapitalizationProperties = [];
         _predictiveTree = new PredictiveTextTree(param2,param3);
         if(param2 == null)
         {
            if(_predictiveTreesToFullFill == null)
            {
               _predictiveTreesToFullFill = [];
            }
            _predictiveTreesToFullFill.push(this);
         }
         resetTreeSearch();
      }
      
      public function reload(param1:TextField, param2:MovieClip = null, param3:MovieClip = null, param4:MovieClip = null) : void
      {
         _chatBar = param4;
         _chatMsgText = param1;
         _currMsgText = _chatMsgText.text;
         if(_predictiveTextMC)
         {
            _predictiveTextMC["predictTxtTag0"].removeEventListener("mouseDown",onPredictiveTag);
         }
         _predictiveTextMC = param2;
         _specialCharTextMC = param3;
         if(_predictiveTextMC)
         {
            _predictiveTextMC.visible = false;
            _predictiveTextMC["predictTxtTag0"].addEventListener("mouseDown",onPredictiveTag,false,0,true);
         }
         if(_specialCharTextMC)
         {
            _specialCharTextMC.visible = false;
         }
         _chatMsgText.defaultTextFormat.color = 4531987;
         _chatMsgText.tabEnabled = false;
         _writtenWordsLength = [];
         _wordCapitalizationProperties = [];
         resetTreeSearch();
      }
      
      public function destroy() : void
      {
         if(_predictiveTextMC)
         {
            _predictiveTextMC["predictTxtTag0"].removeEventListener("mouseDown",onPredictiveTag);
         }
         _predictiveTree.destroy();
         _chatBar = null;
         _chatMsgText = null;
         _currMsgText = "";
         _predictiveTextMC = null;
         _specialCharTextMC = null;
         _sendMsgCallback = null;
         _completeSuggestionCallback = null;
      }
      
      public function addWordToPredictiveText(param1:String) : Boolean
      {
         var _loc4_:int = 0;
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc6_:int = 0;
         var _loc5_:TextFormat = new TextFormat();
         if(param1 != "" && (_wordValidity == 2 || _wordValidity == 4))
         {
            _loc2_ = param1.split("");
            _loc6_ = 0;
            while(_loc6_ < _loc2_.length)
            {
               _loc3_ = _loc2_[_loc6_];
               _loc4_ = _predictiveTree.containsString(_loc3_);
               if(_loc4_ == 0)
               {
                  return false;
               }
               _currWordEndIndex += 1;
               _currWordLength += 1;
               if(shouldCapitalizeString(_loc3_))
               {
                  _loc3_ = _loc3_.toUpperCase();
               }
               _chatMsgText.appendText(_loc3_);
               _currMsgText += _loc3_;
               _loc6_++;
            }
            _loc5_.bold = true;
            _chatMsgText.appendText(" ");
            _currMsgText += " ";
            _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
            _predictiveTree.onSpacebar();
            _loc5_.color = 4531987;
            _currWordEndIndex = _currWordEndIndex + 1;
            _writtenWordsLength.push(_currWordLength);
            _currWordLength = 0;
            _chatMsgText.setTextFormat(_loc5_,_currWordStartIndex,_currWordEndIndex);
            _wordCapitalizationProperties.push({
               "firstLetterWasCapital":_firstLetterWasCapital,
               "secondLetterWasCapital":_secondLetterWasCapital
            });
            _currWordStartIndex = _currWordEndIndex;
            if(EmoticonUtility.doesStringMatchAnEmote(param1))
            {
               _wordValidity = 4;
            }
            else
            {
               _wordValidity = 2;
            }
            _predictiveTextMC.visible = false;
            if(_specialCharTextMC)
            {
               _specialCharTextMC.visible = false;
            }
            if(_currWordEndIndex != _currWordStartIndex)
            {
               setTxtFormat();
            }
            _predictiveTree.clearWordSuggestions();
            _predictiveTextMC.visible = false;
            if(_specialCharTextMC)
            {
               _specialCharTextMC.visible = false;
            }
            gMainFrame.stage.focus = _chatMsgText;
            _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
            _chatMsgText.restrict = _predictiveTree.currentRestriction;
            if(_completeSuggestionCallback != null)
            {
               _completeSuggestionCallback("",true);
            }
            return true;
         }
         return false;
      }
      
      public function get predictiveTree() : PredictiveTextTree
      {
         return _predictiveTree;
      }
      
      public function onTextFieldChanged(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         if(_wasBackspaced)
         {
            _wasBackspaced = false;
            _predictiveTree.backspaced();
            AJAudio.playTextType();
            if(_currWordLength == 0)
            {
               _currWordLength = _writtenWordsLength.pop();
               _loc3_ = _wordCapitalizationProperties.pop();
               if(_loc3_)
               {
                  _firstLetterWasCapital = _loc3_.firstLetterWasCapital;
                  _secondLetterWasCapital = _loc3_.secondLetterWasCapital;
               }
               else
               {
                  _firstLetterWasCapital = false;
                  _secondLetterWasCapital = false;
               }
            }
            else
            {
               _currWordLength = _currWordLength - 1;
            }
            if(_currWordEndIndex - 2 < _currWordStartIndex)
            {
               if(_currWordEndIndex > 0)
               {
                  findWhereLastWordStarts();
                  _loc2_ = true;
                  setPredictiveTextField();
               }
            }
            else if(_currWordEndIndex > 0)
            {
               _currWordEndIndex = _currWordEndIndex - 1;
               setPredictiveTextField();
            }
            if(_loc2_)
            {
               _currWordEndIndex = _currWordEndIndex - 1;
               if(_currWordEndIndex == _currWordStartIndex)
               {
                  _currWordStartIndex = _currWordStartIndex - 1;
               }
               _loc2_ = false;
            }
            if(_currWordEndIndex == 0)
            {
               _writtenWordsLength.splice(0,_writtenWordsLength.length);
               _wordCapitalizationProperties = [];
               _currWordLength = 0;
               _currWordStartIndex = 0;
               _firstLetterWasCapital = false;
               _secondLetterWasCapital = false;
               _wordValidity = 2;
               if(_predictiveTextMC)
               {
                  _predictiveTextMC.visible = false;
               }
            }
            else
            {
               _wordValidity = _predictiveTree.checkCurrentWordValidity();
            }
            setTxtFormat();
            _chatMsgText.setSelection(_chatMsgText.length - 1,_chatMsgText.length - 1);
            setSpecialCharMC(_chatMsgText.text.charAt(_chatMsgText.text.length - 1));
            _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
            if(_chatBar && _chatBar.chatBGColor)
            {
               _chatBar.chatBGColor.white.visible = true;
            }
            _chatMsgText.restrict = _predictiveTree.currentRestriction;
            _currMsgText = _chatMsgText.text;
         }
         else
         {
            _chatMsgText.text = _currMsgText;
            setTxtFormat();
            _chatMsgText.setSelection(_chatMsgText.length - 1,_chatMsgText.length - 1);
            setSpecialCharMC(_chatMsgText.text.charAt(_chatMsgText.text.length - 1));
            _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
            _chatMsgText.restrict = _predictiveTree.currentRestriction;
         }
      }
      
      public function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 16)
         {
            _isShiftOn = false;
         }
         if(_chatMsgText.type != "input")
         {
            _chatMsgText.type = "input";
            _chatMsgText.selectable = true;
         }
         if(param1.keyCode > 36 && param1.keyCode < 41)
         {
            _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
         }
      }
      
      public function onKeyDown(param1:KeyboardEvent, param2:String) : void
      {
         var _loc3_:Array = null;
         var _loc6_:TextFormat = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
         var _loc8_:RegExp = new RegExp("[|:|)|(|\'|.|,|?|!|" + currentRestriction + "|]","g");
         if(param1.ctrlKey || param1.altKey || param1.keyCode == 18)
         {
            if(param1.keyCode == 8)
            {
               _chatMsgText.type = "dynamic";
               _chatMsgText.selectable = false;
            }
            return;
         }
         if(_chatMsgText.type != "input")
         {
            _chatMsgText.type = "input";
            _chatMsgText.selectable = true;
         }
         var _loc7_:Array = null;
         if(param2 != null)
         {
            if(_currWordLength == 0)
            {
               _loc7_ = param2.toLowerCase().match(_loc8_);
               if(_loc7_ != null && _loc7_.length != 0 && _loc7_.length == param2.length)
               {
                  _loc3_ = param2.toLowerCase().match(/\[|;|\)|\(|'|\.|,|\?|!/g);
                  if(_loc3_ == null || _loc3_ != null && _loc3_.length == 0)
                  {
                     _firstLetterWasCapital = param2 == param2.toUpperCase();
                  }
                  else
                  {
                     _firstLetterWasCapital = false;
                  }
               }
            }
            else if(_currWordLength == 1)
            {
               if(_firstLetterWasCapital)
               {
                  _loc7_ = param2.toLowerCase().match(_loc8_);
               }
               else
               {
                  param2 = param2.toLowerCase();
                  _loc7_ = param2.match(_loc8_);
               }
               if(_loc7_ != null && _loc7_.length != 0 && _loc7_.length == param2.length)
               {
                  _loc3_ = param2.toLowerCase().match(/\[|;|\)|\(|'|\.|,|\?|!/g);
                  if(_loc3_ == null || _loc3_ != null && _loc3_.length == 0)
                  {
                     _secondLetterWasCapital = param2 == param2.toUpperCase();
                  }
                  else if(Keyboard.capsLock || _isShiftOn)
                  {
                     _secondLetterWasCapital = true;
                  }
                  else
                  {
                     _secondLetterWasCapital = false;
                  }
               }
            }
            else if(_currWordLength >= 2)
            {
               if(_secondLetterWasCapital)
               {
                  param2 = param2.toUpperCase();
                  _loc7_ = param2.toLowerCase().match(_loc8_);
               }
               else
               {
                  param2 = param2.toLowerCase();
                  _loc7_ = param2.match(_loc8_);
               }
            }
         }
         if(param1.keyCode != 13 && param1.keyCode != 8 && (_chatMsgText.maxChars > 0 ? _chatMsgText.length >= _chatMsgText.maxChars : false))
         {
            return;
         }
         if(param1.keyCode == 9)
         {
            AJAudio.playTextType();
            onPredictiveTag(null);
            return;
         }
         if(param1.keyCode == 13)
         {
            if(_chatMsgText.text.length > 0 && _wordValidity >= 2)
            {
               if(_sendMsgCallback != null)
               {
                  _sendMsgCallback(null);
                  resetTreeSearch();
               }
            }
            AJAudio.playTextEnter();
         }
         else
         {
            if(param1.keyCode == 8)
            {
               _wasBackspaced = true;
               return;
            }
            if(param1.keyCode == 16)
            {
               _isShiftOn = true;
            }
            else if(param1.keyCode == 32)
            {
               if(_wordValidity != 0 && _wordValidity != 4)
               {
                  _loc6_ = new TextFormat();
                  if(_wordValidity == -1)
                  {
                     _wordValidity = _predictiveTree.checkCurrentWordValidity();
                  }
                  if(_wordValidity > 1)
                  {
                     AJAudio.playTextType();
                     _loc6_.bold = true;
                     _chatMsgText.appendText(" ");
                     _currMsgText += " ";
                     _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
                     _predictiveTree.onSpacebar();
                     _loc6_.color = 4531987;
                     _currWordEndIndex = _currWordEndIndex + 1;
                     _writtenWordsLength.push(_currWordLength);
                     _wordCapitalizationProperties.push({
                        "firstLetterWasCapital":_firstLetterWasCapital,
                        "secondLetterWasCapital":_secondLetterWasCapital
                     });
                     _currWordLength = 0;
                     _firstLetterWasCapital = false;
                     _secondLetterWasCapital = false;
                     if(_currWordStartIndex <= 0)
                     {
                        _chatMsgText.setTextFormat(_loc6_);
                     }
                     else
                     {
                        _chatMsgText.setTextFormat(_loc6_,_currWordStartIndex,_currWordEndIndex);
                     }
                     _currWordStartIndex = _currWordEndIndex;
                     _wordValidity = 2;
                     if(_predictiveTextMC)
                     {
                        _predictiveTextMC.visible = false;
                     }
                  }
                  else
                  {
                     _wordValidity = -1;
                     if(_chatMsgText.text.charAt(_chatMsgText.length - 1) != " ")
                     {
                        if(_chatBar && _chatBar.chatBGColor)
                        {
                           _chatBar.chatBGColor.white.visible = false;
                        }
                        _loc6_.bold = false;
                        _loc6_.color = 16711680;
                        if(_currWordStartIndex <= 0)
                        {
                           _chatMsgText.setTextFormat(_loc6_);
                        }
                        else
                        {
                           _chatMsgText.setTextFormat(_loc6_,_currWordStartIndex,_currWordEndIndex);
                        }
                     }
                  }
               }
            }
            else if(_loc7_ != null && _loc7_.length != 0 && _loc7_.length == param2.length)
            {
               AJAudio.playTextType();
               _loc4_ = param2.toLowerCase().match(/[\.,]/g);
               _loc5_ = param2.toLowerCase().match(/[?!]/g);
               if(_loc4_ != null && _loc4_.length != 0 && _loc4_.length == param2.length)
               {
                  if(_wordValidity > 1)
                  {
                     _currWordEndIndex = _currWordEndIndex + 1;
                     _currWordLength = _currWordLength + 1;
                     _predictiveTree.onSpecialCharacter();
                     _wordValidity = 3;
                     _chatMsgText.appendText(param2);
                     _currMsgText += param2;
                     setTxtFormat();
                     setPredictiveTextField();
                     setSpecialCharMC(param2);
                  }
               }
               else if(_loc5_ != null && _loc5_.length != 0 && _loc5_.length == param2.length)
               {
                  if(_wordValidity > 1)
                  {
                     if(_isShiftOn)
                     {
                        _currWordEndIndex = _currWordEndIndex + 1;
                        _currWordLength = _currWordLength + 1;
                        _wordValidity = 3;
                        _predictiveTree.onSpecialCharacter();
                        _chatMsgText.appendText(param2);
                        _currMsgText += param2;
                        setTxtFormat();
                        setPredictiveTextField();
                     }
                  }
               }
               else
               {
                  if(!(_wordValidity != 0 && _wordValidity != 3 && _wordValidity != 4 && param1.charCode > 0))
                  {
                     AJAudio.playLimitedChatErrorSound();
                     if(_chatBar && _chatBar.chatBGColor)
                     {
                        _chatBar.chatBGColor.white.visible = false;
                     }
                     return;
                  }
                  _currWordEndIndex = _currWordEndIndex + 1;
                  _currWordLength = _currWordLength + 1;
                  _wordValidity = _predictiveTree.containsString(param2.toLowerCase());
                  _chatMsgText.appendText(param2);
                  _currMsgText += param2;
                  setTxtFormat();
                  setPredictiveTextField();
                  setSpecialCharMC(param2);
               }
               _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
            }
         }
         _chatMsgText.restrict = _predictiveTree.currentRestriction;
      }
      
      public function resetTreeSearch() : void
      {
         _currWordStartIndex = 0;
         _currWordEndIndex = 0;
         _currWordLength = 0;
         _writtenWordsLength.splice(0,_writtenWordsLength.length);
         _wordCapitalizationProperties = [];
         _wordValidity = 2;
         _isShiftOn = false;
         if(_predictiveTree)
         {
            _predictiveTree.resetSearchTree();
            _chatMsgText.restrict = _predictiveTree.currentRestriction;
            setTxtFormat();
         }
         if(_specialCharTextMC)
         {
            _specialCharTextMC.visible = false;
         }
         if(_predictiveTextMC)
         {
            _predictiveTextMC.y = _predictiveTextOriginalYLoc;
            _predictiveTextMC.visible = false;
         }
         if(_chatBar && _chatBar.chatBGColor)
         {
            _chatBar.chatBGColor.white.visible = true;
         }
         if(_specialCharTextMC)
         {
            while(_specialCharTextMC.itemWindow.numChildren > 1)
            {
               _specialCharTextMC.itemWindow.removeChildAt(_specialCharTextMC.itemWindow.numChildren - 1);
            }
            _specialCharTextMC.x = _specialCharStartPositionX;
         }
         _chatMsgText.scrollV = 0;
         _chatMsgText.text = "";
         _currMsgText = "";
         _firstLetterWasCapital = false;
         _secondLetterWasCapital = false;
      }
      
      public function onSendBtnDown(param1:MouseEvent) : void
      {
         if(_chatMsgText.text.length > 0 && _wordValidity >= 2)
         {
            if(_chatMsgText.text.match("\r"))
            {
               return;
            }
            if(_sendMsgCallback != null)
            {
               _sendMsgCallback(param1);
               resetTreeSearch();
            }
         }
      }
      
      public function isWordValid() : Boolean
      {
         return _wordValidity >= 2;
      }
      
      private function get currentRestriction() : String
      {
         return _predictiveTree.currentRestriction;
      }
      
      private function shouldCapitalizeString(param1:String) : Boolean
      {
         if(_currWordLength == 0)
         {
            return param1 == param1.toUpperCase();
         }
         if(_currWordLength == 1)
         {
            if(!_firstLetterWasCapital)
            {
               return false;
            }
            return param1 == param1.toUpperCase();
         }
         if(_currWordLength >= 2)
         {
            if(_secondLetterWasCapital)
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
         if(_predictiveTextMC && _predictiveTextMC.visible)
         {
            _loc2_ = _predictiveTextMC.predictTxtTag0.txt.text;
            _loc2_ = _loc2_.substr(_currWordLength);
            if(_completeSuggestionCallback != null)
            {
               _completeSuggestionCallback(_loc2_,false,onPredictiveTxtTagWork);
            }
            else
            {
               onPredictiveTxtTagWork(_loc2_);
            }
         }
      }
      
      private function onPredictiveTxtTagWork(param1:String, param2:Boolean = true) : void
      {
         var _loc4_:TextFormat = null;
         var _loc3_:Array = null;
         var _loc5_:int = 0;
         if(param2)
         {
            _loc4_ = new TextFormat();
            if(param1 != "")
            {
               _loc3_ = param1.split("");
               _loc5_ = 0;
               while(_loc5_ < _loc3_.length)
               {
                  _predictiveTree.containsString(_loc3_[_loc5_]);
                  _loc5_++;
               }
               _currWordEndIndex += param1.length;
               _currWordLength += param1.length;
               if(shouldCapitalizeString(param1))
               {
                  param1 = param1.toUpperCase();
               }
               _chatMsgText.appendText(param1);
               _currMsgText += param1;
            }
            _loc4_.bold = true;
            _chatMsgText.appendText(" ");
            _currMsgText += " ";
            _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
            _predictiveTree.onSpacebar();
            _loc4_.color = 4531987;
            _currWordEndIndex = _currWordEndIndex + 1;
            _writtenWordsLength.push(_currWordLength);
            _currWordLength = 0;
            _chatMsgText.setTextFormat(_loc4_,_currWordStartIndex,_currWordEndIndex);
            _wordCapitalizationProperties.push({
               "firstLetterWasCapital":_firstLetterWasCapital,
               "secondLetterWasCapital":_secondLetterWasCapital
            });
            _currWordStartIndex = _currWordEndIndex;
            _wordValidity = 2;
            _predictiveTextMC.visible = false;
            if(_specialCharTextMC)
            {
               _specialCharTextMC.visible = false;
            }
            if(_currWordEndIndex != _currWordStartIndex)
            {
               setTxtFormat();
            }
            _predictiveTree.clearWordSuggestions();
            _predictiveTextMC.visible = false;
            if(_specialCharTextMC)
            {
               _specialCharTextMC.visible = false;
            }
            gMainFrame.stage.focus = _chatMsgText;
            _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
            _chatMsgText.restrict = _predictiveTree.currentRestriction;
            if(_completeSuggestionCallback != null)
            {
               _completeSuggestionCallback("",true);
            }
         }
      }
      
      private function setPredictiveTextField() : void
      {
         var _loc1_:String = null;
         if(_predictiveTextMC)
         {
            if(_chatMsgText.length > 0 && (_wordValidity == 2 || _wordValidity == 1))
            {
               _loc1_ = _predictiveTree.showTopWord();
               if(_loc1_ != null && _loc1_ != " ")
               {
                  _predictiveTextMC.visible = true;
                  _predictiveTextMC.gotoAndStop(1);
                  _predictiveTextMC["predictTxtTag0"].setText(_loc1_);
                  _predictiveTextMC.y = _predictiveTextOriginalYLoc;
               }
               else
               {
                  _predictiveTextMC.visible = false;
               }
            }
            else
            {
               _predictiveTextMC.visible = false;
            }
         }
      }
      
      private function setSpecialCharMC(param1:String) : void
      {
         var _loc5_:Array = null;
         var _loc2_:int = 0;
         var _loc4_:Rectangle = null;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         if(_specialCharTextMC)
         {
            _loc5_ = _predictiveTree.findAllLanguageSpecialChars(param1);
            if(_specialCharWindow && _specialCharWindow.parent == _specialCharTextMC.itemWindow)
            {
               _specialCharTextMC.itemWindow.removeChild(_specialCharWindow);
            }
            if(_loc5_ && _loc5_.length > 0)
            {
               _specialCharTextMC.visible = true;
               if(_specialCharWindow)
               {
                  _specialCharWindow.destroy();
               }
               _specialCharWindow = new WindowGenerator();
               _specialCharWindow.init(_loc5_.length,1,_loc5_.length,0,0,0,ItemWindowSpecialText,_loc5_,"",{"mouseDown":onSpecialCharMouseDown},null,null,true);
               _specialCharTextMC.itemWindow.itemWindowInside.width = _specialCharWindow.boxWidth * _loc5_.length;
               _specialCharTextMC.m.width = _specialCharTextMC.itemWindow.width;
               _specialCharTextMC.b.x = _specialCharTextMC.m.x + _specialCharTextMC.m.width;
               _specialCharTextMC.itemWindow.addChild(_specialCharWindow);
               _loc2_ = _chatMsgText.caretIndex;
               _loc4_ = _chatMsgText.getCharBoundaries(_loc2_);
               if(_loc4_ != null)
               {
                  _loc6_ = _loc4_.x + 5;
                  if(_loc4_.x > _chatMsgText.width)
                  {
                     _loc3_ = _chatBar ? 69 : 65;
                     _loc6_ = _loc4_.x + 5 - _loc3_ * Math.floor((_loc4_.x - _chatMsgText.width) / _loc3_ + 1);
                  }
               }
               _specialCharTextMC.x = _specialCharStartPositionX + _loc6_;
               if(_predictiveTextMC.visible && _specialCharTextMC.x < _predictiveTextMC.x + _predictiveTextMC.width * 0.5)
               {
                  _predictiveTextMC.y = _predictiveTextOriginalYLoc - _specialCharTextMC.height;
               }
            }
            else
            {
               _specialCharTextMC.visible = false;
            }
         }
      }
      
      private function onSpecialCharMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.txt.text;
         if(_loc2_ != "")
         {
            _chatMsgText.text = _chatMsgText.text.slice(0,-1);
            _currMsgText = _chatMsgText.text;
            _predictiveTree.backspaced();
            _wordValidity = _predictiveTree.containsString(_loc2_);
            if(shouldCapitalizeString(_loc2_))
            {
               _loc2_ = _loc2_.toUpperCase();
            }
            _chatMsgText.appendText(_loc2_);
            _currMsgText += _loc2_;
         }
         _specialCharTextMC.visible = false;
         setTxtFormat();
         setPredictiveTextField();
         gMainFrame.stage.focus = _chatMsgText;
         _chatMsgText.setSelection(_chatMsgText.length,_chatMsgText.length);
         _chatMsgText.restrict = _predictiveTree.currentRestriction;
         if(_completeSuggestionCallback != null)
         {
            _completeSuggestionCallback("",true);
         }
      }
      
      private function setTxtFormat() : void
      {
         var _loc1_:TextFormat = new TextFormat();
         if(_currWordEndIndex == 0 && _currWordStartIndex == 0)
         {
            _wordValidity == 2;
            _chatMsgText.textColor = 4531987;
         }
         else if(_wordValidity > 1)
         {
            _chatMsgText.textColor = 4531987;
            if(_chatBar && _chatBar.chatBGColor)
            {
               _chatBar.chatBGColor.white.visible = true;
            }
            _loc1_.bold = false;
            _loc1_.color = 4531987;
            if(_currWordStartIndex <= 0)
            {
               _chatMsgText.setTextFormat(_loc1_);
            }
            else if(_currWordStartIndex != _currWordEndIndex)
            {
               _chatMsgText.setTextFormat(_loc1_,_currWordStartIndex,_currWordEndIndex);
            }
         }
         else
         {
            if(_wordValidity == 0)
            {
               if(_chatBar && _chatBar.chatBGColor)
               {
                  _chatBar.chatBGColor.white.visible = false;
               }
            }
            else if(_chatBar && _chatBar.chatBGColor)
            {
               _chatBar.chatBGColor.white.visible = true;
            }
            _loc1_.bold = false;
            _loc1_.color = 16711680;
            if(_currWordStartIndex <= 0)
            {
               _chatMsgText.setTextFormat(_loc1_);
            }
            else if(_currWordStartIndex != _currWordEndIndex)
            {
               _chatMsgText.setTextFormat(_loc1_,_currWordStartIndex,_currWordEndIndex);
            }
         }
      }
      
      private function findWhereLastWordStarts() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:int = 0;
         if(_currWordStartIndex - 1 >= 0)
         {
            _loc1_ = false;
            _loc2_ = _currWordStartIndex - 1;
            while(_loc2_ >= 0)
            {
               if(_chatMsgText.text.charAt(_loc2_) == " ")
               {
                  if(_loc2_ != _currWordStartIndex - 1)
                  {
                     setPredictiveTextField();
                     _currWordEndIndex = _loc1_ ? _currWordStartIndex + 1 : _currWordStartIndex;
                     _currWordStartIndex = _loc2_ == _currWordStartIndex - 1 ? _loc2_ : _loc2_ + 1;
                     break;
                  }
                  _loc1_ = true;
               }
               if(_loc2_ == 0)
               {
                  _currWordEndIndex = _loc1_ ? _currWordStartIndex + 1 : _currWordStartIndex;
                  _currWordStartIndex = _loc2_;
               }
               _loc2_--;
            }
         }
      }
   }
}

