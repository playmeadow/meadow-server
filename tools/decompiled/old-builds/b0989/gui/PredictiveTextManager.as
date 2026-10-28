package gui
{
   import com.sbi.loader.FileServerEvent;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import loader.DefPacksDefHelper;
   
   public class PredictiveTextManager
   {
      
      public static const USE_TYPE_ALL:int = 0;
      
      public static const USE_TYPE_ECARD:int = 1;
      
      private static var _predictiveTreesToFullFill:Array = new Array();
      
      private const KEYCODES:Object = {
         27:27,
         96:192,
         49:49,
         50:50,
         51:51,
         52:52,
         53:53,
         54:54,
         55:55,
         56:56,
         57:57,
         48:48,
         45:189,
         61:187,
         8:8,
         9:9,
         113:81,
         119:87,
         101:69,
         114:82,
         116:84,
         121:89,
         117:85,
         105:73,
         111:79,
         112:80,
         91:219,
         93:221,
         92:220,
         97:65,
         115:83,
         100:68,
         102:70,
         103:71,
         104:72,
         106:74,
         107:75,
         108:76,
         58:186,
         59:186,
         39:222,
         13:13,
         122:90,
         120:88,
         99:67,
         118:86,
         98:66,
         110:78,
         109:77,
         44:188,
         46:190,
         47:191,
         32:32,
         127:46,
         126:192,
         33:49,
         64:50,
         35:51,
         36:52,
         37:53,
         94:54,
         38:55,
         42:56,
         40:57,
         41:48,
         95:189,
         43:187,
         81:81,
         87:87,
         69:69,
         82:82,
         84:84,
         89:89,
         85:85,
         73:73,
         79:79,
         80:80,
         123:219,
         125:221,
         124:220,
         65:65,
         83:83,
         68:68,
         70:70,
         71:71,
         72:72,
         74:74,
         75:75,
         76:76,
         58:186,
         34:222,
         90:90,
         88:88,
         67:67,
         86:86,
         66:66,
         78:78,
         77:77,
         60:188,
         62:190,
         63:191
      };
      
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
         _loc1_.init(DefPacksDefHelper.PREDICTIVE_TEXT_FILE,wordListResponse,null,FileServerEvent.PLAIN_TEXT_TYPE);
         DefPacksDefHelper.mediaArray[1] = _loc1_;
      }
      
      private static function wordListResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.PREDICTIVE_TEXT_FILE] = null;
         var _loc2_:String = param1.def.toString().toLowerCase() as String;
         var _loc3_:Array = _loc2_.split("\r");
         var _loc4_:int = int(_loc3_.length);
         PredictiveTextTree.init();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            PredictiveTextTree.addFromStart(_loc3_[_loc5_].split(","));
            _loc5_++;
         }
         PredictiveTextTree.optimizeTree(PredictiveTextTree.defaultRoot);
         _loc5_ = 0;
         while(_loc5_ < _predictiveTreesToFullFill.length)
         {
            _predictiveTreesToFullFill[_loc5_].predictiveTree.updateRoot(PredictiveTextTree.defaultRoot);
            _loc5_++;
         }
         _predictiveTreesToFullFill = null;
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
      
      public function addWordToPredictiveText(param1:String, param2:Function = null, param3:Function = null) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc4_:uint = 0;
         if(param1 != null)
         {
            _loc6_ = 0;
            while(_loc6_ < param1.length)
            {
               _loc4_ = this.keyCodeOf(param1.charCodeAt(_loc6_));
               if(_loc4_ == 186 || _loc4_ == 49 || _loc4_ == 191)
               {
                  if(!_loc5_)
                  {
                     _loc5_ = true;
                     if(param2 != null)
                     {
                        param2(new KeyboardEvent("shift",true,false,0,16));
                     }
                     else
                     {
                        this.onKeyDown(new KeyboardEvent("shift",true,false,0,16));
                     }
                  }
               }
               else if(_loc5_)
               {
                  if(param3 != null)
                  {
                     param3(new KeyboardEvent("shift",true,false,0,16));
                  }
                  else
                  {
                     this.onKeyUp(new KeyboardEvent("shift",true,false,0,16));
                  }
                  _loc5_ = false;
               }
               if(param2 != null)
               {
                  param2(new KeyboardEvent(param1.charAt(_loc6_),true,false,param1.charCodeAt(_loc6_),_loc4_));
               }
               else
               {
                  this.onKeyDown(new KeyboardEvent(param1.charAt(_loc6_),true,false,param1.charCodeAt(_loc6_),_loc4_));
               }
               _loc6_++;
            }
         }
      }
      
      public function get predictiveTree() : PredictiveTextTree
      {
         return this._predictiveTree;
      }
      
      public function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 16)
         {
            this._isShiftOn = false;
         }
         if(param1.keyCode > 36 && param1.keyCode < 41)
         {
            this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         }
      }
      
      public function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:TextFormat = null;
         this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
         if(param1.ctrlKey || param1.altKey)
         {
            if(param1.keyCode == 8)
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
         if(param1.keyCode != 13 && param1.keyCode != 8 && (this._chatMsgText.maxChars > 0 ? Boolean(this._chatMsgText.length >= this._chatMsgText.maxChars) : Boolean(false)))
         {
            return;
         }
         if(param1.keyCode == 9)
         {
            AJAudio.playTextType();
            this.onPredictiveTag(null);
            return;
         }
         if(param1.keyCode == 13)
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
         else if(param1.keyCode == 8)
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
                  _loc3_ = true;
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
            if(_loc3_)
            {
               --this._currWordEndIndex;
               _loc3_ = false;
            }
            if(this._chatBar)
            {
               this._chatBar.chatBGColor.white.visible = true;
            }
         }
         else if(param1.keyCode > 64 && param1.keyCode < 91 || param1.keyCode == 186 || param1.keyCode == 48 || param1.keyCode == 57 || param1.keyCode == 222)
         {
            if(this._wordValidity != this.DOES_NOT_CONTAIN_WORD && this._wordValidity != this.IS_A_SPECIAL_CHARACTER && param1.charCode > 0)
            {
               AJAudio.playTextType();
               ++this._currWordEndIndex;
               ++this._currWordLength;
               if(this._isShiftOn)
               {
                  if(param1.keyCode == 186)
                  {
                     this._chatMsgText.appendText(":");
                  }
                  else if(param1.keyCode == 48)
                  {
                     this._chatMsgText.appendText(")");
                  }
                  else if(param1.keyCode == 57)
                  {
                     this._chatMsgText.appendText("(");
                  }
                  else if(param1.keyCode == 222)
                  {
                     this._chatMsgText.appendText("\'");
                  }
                  else
                  {
                     this._chatMsgText.appendText(String.fromCharCode(param1.charCode).toUpperCase());
                  }
               }
               else
               {
                  this._chatMsgText.appendText(String.fromCharCode(param1.charCode));
               }
               this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
               this._wordValidity = this._predictiveTree.containsString(String.fromCharCode(param1.charCode).toLowerCase());
               this.setTxtFormat();
               this.setPredictiveTextField();
            }
            else
            {
               AJAudio.playLimitedChatErrorSound();
               if(this._chatBar)
               {
                  this._chatBar.chatBGColor.white.visible = false;
               }
            }
         }
         else if(param1.keyCode == 190 || param1.keyCode == 188)
         {
            if(this._wordValidity > 1)
            {
               AJAudio.playTextType();
               ++this._currWordEndIndex;
               ++this._currWordLength;
               if(param1.keyCode == 190)
               {
                  this._chatMsgText.appendText(".");
               }
               else if(param1.keyCode == 188)
               {
                  this._chatMsgText.appendText(",");
               }
               this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
               this._predictiveTree.onSpecialCharacter();
               this._wordValidity = this.IS_A_SPECIAL_CHARACTER;
               this.setTxtFormat();
               this.setPredictiveTextField();
            }
         }
         else if(param1.keyCode == 191 || param1.keyCode == 49)
         {
            if(this._wordValidity > 1)
            {
               if(this._isShiftOn)
               {
                  AJAudio.playTextType();
                  if(param1.keyCode == 191)
                  {
                     this._chatMsgText.appendText("?");
                  }
                  else if(param1.keyCode == 49)
                  {
                     this._chatMsgText.appendText("!");
                  }
                  ++this._currWordEndIndex;
                  ++this._currWordLength;
                  this._wordValidity = this.IS_A_SPECIAL_CHARACTER;
                  this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
                  this._predictiveTree.onSpecialCharacter();
                  this.setTxtFormat();
                  this.setPredictiveTextField();
               }
            }
         }
         else if(param1.keyCode == 16)
         {
            this._isShiftOn = true;
         }
         else if(param1.keyCode == 32)
         {
            if(this._wordValidity != this.DOES_NOT_CONTAIN_WORD)
            {
               _loc4_ = new TextFormat();
               if(this._wordValidity == this.DEFAULT_WORD_VALIDITY)
               {
                  this._wordValidity = this._predictiveTree.checkCurrentWordValidity();
               }
               if(this._wordValidity > this.CONTAINS_WORD_IS_NOT_A_WORD)
               {
                  AJAudio.playTextType();
                  _loc4_.bold = true;
                  this._chatMsgText.appendText(" ");
                  this._chatMsgText.setSelection(this._chatMsgText.length,this._chatMsgText.length);
                  this._predictiveTree.onSpacebar();
                  _loc4_.color = 4531987;
                  ++this._currWordEndIndex;
                  this._writtenWordsLength.push(this._currWordLength);
                  this._currWordLength = 0;
                  if(this._currWordStartIndex <= 0)
                  {
                     this._chatMsgText.setTextFormat(_loc4_);
                  }
                  else
                  {
                     this._chatMsgText.setTextFormat(_loc4_,this._currWordStartIndex,this._currWordEndIndex);
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
                     _loc4_.bold = false;
                     _loc4_.color = 16711680;
                     if(this._currWordStartIndex <= 0)
                     {
                        this._chatMsgText.setTextFormat(_loc4_);
                     }
                     else
                     {
                        this._chatMsgText.setTextFormat(_loc4_,this._currWordStartIndex,this._currWordEndIndex);
                     }
                  }
               }
            }
         }
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
      
      private function keyCodeOf(param1:*) : Number
      {
         var _loc2_:Number = NaN;
         if(param1 is String)
         {
            _loc2_ = (param1 as String).charCodeAt();
         }
         else
         {
            _loc2_ = param1;
         }
         return this.KEYCODES[_loc2_] ? Number(this.KEYCODES[_loc2_]) : -1;
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

