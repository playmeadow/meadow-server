package gui
{
   import com.sbi.loader.FileServerEvent;
   import flash.display.MovieClip;
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
      
      public function PredictiveTextManager()
      {
         super();
      }
      
      public static function requestAndCreateTextTreeNode() : void
      {
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init(uint(DefPacksDefHelper.PREDICTIVE_TEXT_FILE_TO_APPEND_TO + "" + LocalizationManager.currentLanguage),wordListResponse,null,FileServerEvent.PLAIN_TEXT_TYPE);
         DefPacksDefHelper.mediaArray[1] = _loc1_;
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
            PredictiveTextTree.addFromStart(_loc3_[_loc5_].split(","));
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
      }
      
      public function init(param1:TextField, param2:PredictiveTextNode, param3:int = 0, param4:MovieClip = null, param5:MovieClip = null, param6:Function = null, param7:Function = null) : void
      {
         this._chatBar = param5;
         this._chatMsgText = param1;
         this._predictiveTextMC = param4;
         this._sendMsgCallback = param6;
         this._completeSuggestionCallback = param7;
         if(this._predictiveTextMC)
         {
            this._predictiveTextMC.visible = false;
            this._predictiveTextMC["predictTxtTag0"].addEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag,false,0,true);
         }
         this._wordValidity = this.IS_A_WORD;
         this._chatMsgText.restrict = "";
         this._chatMsgText.defaultTextFormat.color = 4531987;
         this._chatMsgText.tabEnabled = false;
         this._writtenWordsLength = [];
         this._predictiveTree = new PredictiveTextTree(param2,param3);
         if(param2 == null)
         {
            if(_predictiveTreesToFullFill == null)
            {
               _predictiveTreesToFullFill = [];
            }
            _predictiveTreesToFullFill.push(this);
         }
      }
      
      public function reload(param1:TextField, param2:MovieClip = null, param3:MovieClip = null) : void
      {
         this._chatBar = param3;
         this._chatMsgText = param1;
         if(this._predictiveTextMC)
         {
            this._predictiveTextMC["predictTxtTag0"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onPredictiveTag);
         }
         this._predictiveTextMC = param2;
         if(this._predictiveTextMC)
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
         if(this._predictiveTextMC)
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
         var _loc4_:Boolean = false;
         var _loc5_:TextFormat = null;
         this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         var _loc3_:RegExp = new RegExp("[:)(\'.,?!" + this.currentRestriction + "]","g");
         if(param1.ctrlKey || param1.altKey)
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
         else if(param1.keyCode == Keyboard.BACKSPACE)
         {
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
                  _loc4_ = true;
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
            if(_loc4_)
            {
               --this._currWordEndIndex;
               _loc4_ = false;
            }
            if(this._chatBar)
            {
               this._chatBar.chatBGColor.white.visible = true;
            }
         }
         else if(param1.keyCode == Keyboard.SHIFT)
         {
            this._isShiftOn = true;
         }
         else if(param2.toLowerCase().match(_loc3_) != null && param2.toLowerCase().match(_loc3_).length != 0)
         {
            AJAudio.playTextType();
            if(param2.toLowerCase().match(/[\.,]/g) != null && param2.toLowerCase().match(/[\.,]/g).length != 0)
            {
               if(this._wordValidity > 1)
               {
                  ++this._currWordEndIndex;
                  ++this._currWordLength;
                  this._predictiveTree.onSpecialCharacter();
                  this._wordValidity = this.IS_A_SPECIAL_CHARACTER;
                  this._chatMsgText.appendText(param2);
                  this.setTxtFormat();
                  this.setPredictiveTextField();
               }
            }
            else if(param2.toLowerCase().match(/[?!]/g) != null && param2.toLowerCase().match(/[?!]/g).length != 0)
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
               this.setTxtFormat();
               this.setPredictiveTextField();
            }
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         }
         else if(param1.keyCode == Keyboard.SPACE)
         {
            if(this._wordValidity != this.DOES_NOT_CONTAIN_WORD)
            {
               _loc5_ = new TextFormat();
               if(this._wordValidity == this.DEFAULT_WORD_VALIDITY)
               {
                  this._wordValidity = this._predictiveTree.checkCurrentWordValidity();
               }
               if(this._wordValidity > this.CONTAINS_WORD_IS_NOT_A_WORD)
               {
                  AJAudio.playTextType();
                  _loc5_.bold = true;
                  this._chatMsgText.appendText(" ");
                  this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
                  this._predictiveTree.onSpacebar();
                  _loc5_.color = 4531987;
                  ++this._currWordEndIndex;
                  this._writtenWordsLength.push(this._currWordLength);
                  this._currWordLength = 0;
                  if(this._currWordStartIndex <= 0)
                  {
                     this._chatMsgText.setTextFormat(_loc5_);
                  }
                  else
                  {
                     this._chatMsgText.setTextFormat(_loc5_,this._currWordStartIndex,this._currWordEndIndex);
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
                     _loc5_.bold = false;
                     _loc5_.color = 16711680;
                     if(this._currWordStartIndex <= 0)
                     {
                        this._chatMsgText.setTextFormat(_loc5_);
                     }
                     else
                     {
                        this._chatMsgText.setTextFormat(_loc5_,this._currWordStartIndex,this._currWordEndIndex);
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
         if(this._predictiveTextMC)
         {
            this._predictiveTextMC.visible = false;
         }
         if(this._chatBar)
         {
            this._chatBar.chatBGColor.white.visible = true;
         }
         this.setTxtFormat();
         this._chatMsgText.scrollV = 0;
         this._chatMsgText.text = "";
         this._chatMsgText.restrict = this._predictiveTree.currentRestriction;
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
               this._chatMsgText.appendText(param1);
            }
            _loc3_.bold = true;
            this._chatMsgText.appendText(" ");
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
            this._predictiveTree.onSpacebar();
            _loc3_.color = 4531987;
            ++this._currWordEndIndex;
            this._writtenWordsLength.push(this._currWordLength);
            this._currWordLength = 0;
            this._chatMsgText.setTextFormat(_loc3_,this._currWordStartIndex,this._currWordEndIndex);
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
         var _loc1_:TextFormat = new TextFormat();
         if(this._currWordEndIndex == 0 && this._currWordStartIndex == 0)
         {
            this._wordValidity == this.IS_A_WORD;
         }
         if(this._wordValidity > this.CONTAINS_WORD_IS_NOT_A_WORD)
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
                     this._currWordEndIndex = _loc1_ ? this._currWordStartIndex : int(this._currWordStartIndex - 1);
                     this._currWordStartIndex = _loc2_ == this._currWordStartIndex - 1 ? int(_loc2_) : int(_loc2_ + 1);
                     break;
                  }
                  _loc1_ = true;
               }
               if(_loc2_ == 0)
               {
                  this._currWordEndIndex = _loc1_ ? this._currWordStartIndex : int(this._currWordStartIndex - 1);
                  this._currWordStartIndex = _loc2_;
               }
               _loc2_--;
            }
         }
      }
   }
}

