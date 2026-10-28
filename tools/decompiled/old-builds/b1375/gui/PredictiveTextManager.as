package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.prediction.Predictions;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import loader.DefPacksDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PredictiveTextManager
   {
      
      public static const USE_TYPE_ALL:int = 0;
      
      public static const USE_TYPE_ECARD:int = 1;
      
      public static const USE_TYPE_PLAYER_WALL:int = 2;
      
      private static var _lastRequestedLanguage:int;
      
      private static var _hasRequestedDictionaryBlob:Boolean;
      
      private static var _dictionaryBlob:ByteArray;
      
      private var _chatMsgText:TextField;
      
      private var _predictiveTextMC:MovieClip;
      
      private var _specialCharTextMC:MovieClip;
      
      private var _chatBar:MovieClip;
      
      private var _sendMsgCallback:Function;
      
      private var _completeSuggestionCallback:Function;
      
      private var _specialCharWindow:WindowGenerator;
      
      private var _predictiveTextOriginalYLoc:Number;
      
      private var _specialCharStartPositionX:int;
      
      private var _useType:int;
      
      private var _predictions:Predictions;
      
      private var _currSuggestions:Array;
      
      private var _unapprovedChatPopup:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      public function PredictiveTextManager()
      {
         super();
      }
      
      public static function get lastRequestedPredictiveLanguage() : int
      {
         return _lastRequestedLanguage;
      }
      
      public static function get hasRequestDictionaryBlob() : Boolean
      {
         return _hasRequestedDictionaryBlob;
      }
      
      public static function resetDictionaryBlob() : void
      {
         _dictionaryBlob = null;
         _hasRequestedDictionaryBlob = false;
      }
      
      public function init(param1:TextField, param2:int = 0, param3:MovieClip = null, param4:MovieClip = null, param5:int = 0, param6:MovieClip = null, param7:Function = null, param8:Function = null) : void
      {
         _chatBar = param6;
         _chatMsgText = param1;
         _predictiveTextMC = param3;
         _specialCharTextMC = param4;
         _sendMsgCallback = param7;
         _completeSuggestionCallback = param8;
         _specialCharStartPositionX = param5;
         _useType = param2;
         _chatMsgText.restrict = LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG ? "A-Za-z0-9!\'.,():?\\- " : "A-Za-z0-9À-ÖØ-öø-ÿ!\'.,():?\\- ";
         if(_predictiveTextMC)
         {
            _predictiveTextMC.gotoAndStop(3);
            _predictiveTextMC.visible = false;
            _predictiveTextMC["predictTxtTag0"].addEventListener("mouseDown",onPredictiveTag,false,0,true);
            _predictiveTextMC["predictTxtTag1"].addEventListener("mouseDown",onPredictiveTag,false,0,true);
            _predictiveTextMC["predictTxtTag2"].addEventListener("mouseDown",onPredictiveTag,false,0,true);
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
         if(_dictionaryBlob == null)
         {
            loadDictionaryBlob();
         }
         else
         {
            _predictions = new Predictions();
            _predictions.setDictionary(_dictionaryBlob);
            resetTreeSearch();
         }
      }
      
      public function isAllowedFreeChat() : Boolean
      {
         return _useType == 0 && (gMainFrame.userInfo.sgChatType == 1 && LocalizationManager.currentLanguage == LocalizationManager.accountLanguage && LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG);
      }
      
      public function loadDictionaryBlob() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _hasRequestedDictionaryBlob = true;
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init("10" + LocalizationManager.currentLanguage + ".dict",wordListResponse,null,1);
         DefPacksDefHelper.mediaArray["10" + LocalizationManager.currentLanguage] = _loc1_;
      }
      
      public function reload(param1:TextField, param2:MovieClip = null, param3:MovieClip = null, param4:MovieClip = null) : void
      {
         _chatBar = param4;
         _chatMsgText = param1;
         if(_predictiveTextMC)
         {
            _predictiveTextMC["predictTxtTag0"].removeEventListener("mouseDown",onPredictiveTag);
            _predictiveTextMC["predictTxtTag1"].removeEventListener("mouseDown",onPredictiveTag);
            _predictiveTextMC["predictTxtTag2"].removeEventListener("mouseDown",onPredictiveTag);
         }
         _predictiveTextMC = param2;
         _specialCharTextMC = param3;
         if(_predictiveTextMC)
         {
            _predictiveTextMC.visible = false;
            _predictiveTextMC["predictTxtTag0"].addEventListener("mouseDown",onPredictiveTag,false,0,true);
            _predictiveTextMC["predictTxtTag1"].addEventListener("mouseDown",onPredictiveTag,false,0,true);
            _predictiveTextMC["predictTxtTag2"].addEventListener("mouseDown",onPredictiveTag,false,0,true);
         }
         if(_specialCharTextMC)
         {
            _specialCharTextMC.visible = false;
         }
         _chatMsgText.defaultTextFormat.color = 4531987;
         _chatMsgText.tabEnabled = false;
         if(_dictionaryBlob == null)
         {
            loadDictionaryBlob();
         }
         else
         {
            resetTreeSearch();
         }
      }
      
      public function destroy() : void
      {
         if(_predictiveTextMC)
         {
            _predictiveTextMC["predictTxtTag0"].removeEventListener("mouseDown",onPredictiveTag);
            _predictiveTextMC["predictTxtTag1"].removeEventListener("mouseDown",onPredictiveTag);
            _predictiveTextMC["predictTxtTag2"].removeEventListener("mouseDown",onPredictiveTag);
         }
         _chatBar = null;
         _chatMsgText = null;
         _predictiveTextMC = null;
         _specialCharTextMC = null;
         _sendMsgCallback = null;
         _completeSuggestionCallback = null;
      }
      
      public function addWordToPredictiveText(param1:String) : void
      {
         if(_predictiveTextMC)
         {
            if(_completeSuggestionCallback != null)
            {
               _completeSuggestionCallback(param1,false,false,onPredictiveTxtTagWork);
            }
            else
            {
               onPredictiveTxtTagWork(param1,false);
            }
         }
      }
      
      public function onTextClick() : void
      {
         predictWordAndHandleResults(getCurrentWord());
         setPredictiveTextField();
      }
      
      public function onTextFieldChanged(param1:Event, param2:Boolean = false) : void
      {
         var _loc3_:Array = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc4_:String = null;
         var _loc7_:String = null;
         if(_chatMsgText.text == "")
         {
            resetTreeSearch();
         }
         else
         {
            if(!param2 && _chatMsgText.text.length > 0 && _chatMsgText.multiline)
            {
               _loc3_ = _chatMsgText.text.split(/\r|\n|\r\r/gim);
               if(_loc3_.length > 1)
               {
                  _chatMsgText.text = _loc3_.join("");
                  _chatMsgText.setSelection(_chatMsgText.caretIndex - 1,_chatMsgText.caretIndex - 1);
               }
            }
            if(!param2)
            {
               setTimeout(onTextFieldChanged,1,param1,true);
               return;
            }
            _loc5_ = _chatMsgText.text.charAt(_chatMsgText.caretIndex - 1);
            _loc6_ = String.fromCharCode(_predictions.getRootFormOfChar(_chatMsgText.text.charCodeAt(_chatMsgText.caretIndex - 1)));
            if(_loc6_ != null && _loc6_ != "" && _loc6_ != _loc5_)
            {
               if(_loc6_ == _chatMsgText.text.charAt(_chatMsgText.caretIndex - 2))
               {
                  _chatMsgText.text = _chatMsgText.text.substring(0,_chatMsgText.caretIndex - 2) + _loc5_ + _chatMsgText.text.substring(_chatMsgText.caretIndex);
               }
            }
            _loc4_ = String.fromCharCode(_loc6_);
            _loc7_ = getCurrentWord();
            if(_loc7_.length != 0)
            {
               updateWordCapitalizations(_loc7_);
               predictWordAndHandleResults(_loc7_);
            }
            else
            {
               checkEveryWordAndSetFormat();
            }
            setPredictiveTextField();
         }
      }
      
      private function predictWordAndHandleResults(param1:String) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         if(_dictionaryBlob == null)
         {
            loadDictionaryBlob();
            return;
         }
         _currSuggestions = _predictions.predict(param1,3,50,100,_useType);
         if(_currSuggestions.length > 0)
         {
            _loc2_ = shouldCapitalizeCurrWord(param1);
            if(_loc2_)
            {
               _loc3_ = 0;
               while(_loc3_ < _currSuggestions.length)
               {
                  _currSuggestions[_loc3_][0] = _currSuggestions[_loc3_][0].toUpperCase();
                  _loc3_++;
               }
            }
         }
         checkEveryWordAndSetFormat();
      }
      
      public function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode != 13 && param1.keyCode != 8 && _chatMsgText.length >= _chatMsgText.maxChars)
         {
            AJAudio.playLimitedChatErrorSound();
            return;
         }
         if(param1.keyCode == 9 || param1.keyCode == 32)
         {
            onPredictiveTag(null,param1.keyCode == 32);
            return;
         }
         if(param1.keyCode == 13)
         {
            onSendBtnDown(null,_chatMsgText.text);
            AJAudio.playTextEnter();
         }
         else if(param1.keyCode > 36 && param1.keyCode < 41)
         {
            onTextFieldChanged(null);
         }
         else
         {
            AJAudio.playTextType();
         }
      }
      
      public function resetTreeSearch() : void
      {
         var _loc1_:TextFormat = _chatMsgText.defaultTextFormat;
         _chatMsgText.setTextFormat(_loc1_);
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
         _currSuggestions = [];
         if(_chatBar.predictTxt_popup.currentFrameLabel != "close")
         {
            _chatBar.predictTxt_popup.gotoAndStop("close");
         }
         _chatMsgText.setSelection(0,0);
      }
      
      public function onSendBtnDown(param1:MouseEvent, param2:String = null) : void
      {
         if(_chatMsgText.text.length > 0 && _chatMsgText.text.match(/\S/g).length > 0)
         {
            if(isValid())
            {
               if(_sendMsgCallback != null)
               {
                  if(param2 && _sendMsgCallback.length > 1)
                  {
                     _sendMsgCallback(param1,param2);
                  }
                  else
                  {
                     _sendMsgCallback(param1);
                  }
                  resetTreeSearch();
               }
            }
            else
            {
               showUnapprovedChatPopup();
            }
         }
      }
      
      private function wordListResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray["10" + LocalizationManager.currentLanguage + ".dict"] = null;
         _dictionaryBlob = ByteArray(param1.def);
         _lastRequestedLanguage = LocalizationManager.currentLanguage;
         _predictions = new Predictions();
         _predictions.setDictionary(_dictionaryBlob);
         resetTreeSearch();
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function showPredictiveChatBaloons() : Boolean
      {
         if(gMainFrame.userInfo.sgChatType == 1)
         {
            if(!Utility.hasChatSettingBeenSet())
            {
               return false;
            }
         }
         return Utility.isSettingOn(MySettings.SETTINGS_CHAT_PREDICTION);
      }
      
      private function onPredictiveTag(param1:MouseEvent, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         if(param1)
         {
            param1.stopPropagation();
            _loc3_ = param1.currentTarget.down.txt.text;
         }
         else if(_currSuggestions && _currSuggestions[0] && _currSuggestions[0][3] == true)
         {
            _loc3_ = _currSuggestions[0][0];
         }
         else
         {
            _loc3_ = "";
         }
         _currSuggestions = [];
         if(_predictiveTextMC && _predictiveTextMC.visible)
         {
            if(_loc3_.length > 0)
            {
               if(_completeSuggestionCallback != null)
               {
                  _completeSuggestionCallback(_loc3_,false,param2,onPredictiveTxtTagWork);
               }
               else
               {
                  onPredictiveTxtTagWork(_loc3_,param2);
               }
            }
            else
            {
               checkEveryWordAndSetFormat();
               if(_predictiveTextMC)
               {
                  _predictiveTextMC.visible = false;
               }
            }
         }
      }
      
      private function onPredictiveTxtTagWork(param1:String, param2:Boolean = false, param3:Boolean = true) : void
      {
         if(param1.length > 0)
         {
            AJAudio.playTextType();
            if(param3)
            {
               if(!param2)
               {
                  param1 += " ";
               }
               findStartOfWordAndReplaceOrUpdate(param1,true,true,param2);
            }
            checkEveryWordAndSetFormat();
            if(_predictiveTextMC)
            {
               _predictiveTextMC.visible = false;
            }
            if(_completeSuggestionCallback != null)
            {
               _completeSuggestionCallback("",true);
            }
         }
      }
      
      private function setPredictiveTextField() : void
      {
         var _loc2_:int = 0;
         var _loc1_:String = null;
         if(_predictiveTextMC)
         {
            if(showPredictiveChatBaloons() && _chatMsgText.length > 0 && _currSuggestions.length > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < 3)
               {
                  if(_currSuggestions[_loc2_])
                  {
                     _loc1_ = _currSuggestions[_loc2_][0];
                     if(_loc1_ != null && _loc1_ != " ")
                     {
                        GuiSoundBtnSubMenu(_predictiveTextMC["predictTxtTag" + _loc2_]).setTextInLayer(_loc1_,"txt",{"adjustYLocation":false});
                        _predictiveTextMC["predictTxtTag" + _loc2_].visible = true;
                     }
                  }
                  else
                  {
                     _predictiveTextMC["predictTxtTag" + _loc2_].visible = false;
                  }
                  _loc2_++;
               }
               _predictiveTextMC.visible = true;
               _predictiveTextMC.y = _predictiveTextOriginalYLoc;
            }
            else
            {
               _predictiveTextMC.visible = false;
            }
         }
      }
      
      private function findStartOfWordAndReplaceOrUpdate(param1:String, param2:Boolean = true, param3:Boolean = false, param4:Boolean = false) : void
      {
         var _loc5_:String = null;
         var _loc9_:String = null;
         var _loc8_:Object = getCurrentWordStartAndEnd();
         var _loc6_:int = int(_loc8_.startOfWord);
         var _loc7_:int = int(param4 || _loc8_.punctuationSkipped > 0 ? _loc8_.endOfWord + 1 : _loc8_.endOfWord);
         if(param3 && !param4)
         {
            if(_chatMsgText.caretIndex < _loc8_.endOfWord || _loc8_.punctuationSkipped > 0)
            {
               if(param1.charAt(param1.length - 1) == " ")
               {
                  param1 = param1.substring(0,param1.length - 1);
               }
            }
         }
         if(param1 != null)
         {
            if(_loc6_ == 0 && _loc7_ == _chatMsgText.text.length)
            {
               _chatMsgText.text = param1;
            }
            else
            {
               _loc5_ = "";
               if(_loc6_ != 0)
               {
                  _loc5_ = _chatMsgText.text.substring(0,_loc6_);
                  if(_loc5_.charAt(_loc5_.length - 1).match(SbiConstants.TEXT_PUNCTUATION).length > 0)
                  {
                     _loc5_ += " ";
                     _loc8_.startOfWord++;
                     param3 = true;
                  }
               }
               _loc9_ = _chatMsgText.text.substring(_loc7_);
               _chatMsgText.text = _loc5_ + param1 + _loc9_;
            }
            _loc7_ = Math.max(0,_loc8_.startOfWord + _loc8_.punctuationSkipped) + param1.length;
            if(param3)
            {
               _chatMsgText.setSelection(_loc7_,_loc7_);
            }
         }
         setFormatOfWord(_loc6_,_loc7_,param2);
      }
      
      private function checkEveryWordAndSetFormat() : Boolean
      {
         var _loc6_:int = 0;
         var _loc4_:Boolean = false;
         var _loc10_:String = null;
         var _loc14_:String = null;
         var _loc1_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc5_:* = 0;
         var _loc7_:Boolean = false;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc13_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc11_:int = 0;
         if(isAllowedFreeChat())
         {
            return true;
         }
         _loc10_ = _chatMsgText.text;
         _loc14_ = "";
         _loc5_ = -1;
         _loc7_ = true;
         _loc11_ = 0;
         while(_loc11_ < _loc10_.length)
         {
            _loc9_ = _loc10_.charAt(_loc11_);
            if(_loc9_ != " ")
            {
               _loc13_ = _loc9_.match(SbiConstants.TEXT_PUNCTUATION).length > 0;
            }
            if(_loc2_ && _loc13_)
            {
               _loc3_ = true;
            }
            if(_loc4_ && (_loc9_ == " " || _loc11_ + 1 == _loc10_.length))
            {
               if(_loc11_ + 1 == _loc10_.length && _loc9_ != " ")
               {
                  if(!_loc13_)
                  {
                     if(_loc3_)
                     {
                        _loc12_ = true;
                     }
                     _loc14_ += _loc9_;
                  }
               }
               if(!_loc12_)
               {
                  if(_loc13_ && !_loc2_)
                  {
                     _loc1_ = true;
                  }
                  else
                  {
                     _loc8_ = _predictions.predict(_loc14_,3,50,100,_useType);
                     _loc1_ = false;
                     if(_loc8_.length > 0)
                     {
                        _loc6_ = 0;
                        while(_loc6_ < _loc8_.length)
                        {
                           if(_loc8_[_loc6_][0].toLowerCase() == _loc14_.toLowerCase())
                           {
                              _loc1_ = true;
                              break;
                           }
                           _loc6_++;
                        }
                     }
                  }
               }
               else
               {
                  _loc1_ = false;
               }
               if(_loc7_ && !_loc1_)
               {
                  _loc7_ = false;
               }
               setFormatOfWord(_loc5_,_loc11_ + 1,_loc1_);
               if(_loc9_ == " ")
               {
                  setFormatOfWord(_loc11_,_loc11_ + 1,true);
               }
               _loc5_ = -1;
               _loc14_ = "";
               _loc4_ = false;
               _loc13_ = false;
               _loc3_ = false;
               _loc12_ = false;
               _loc2_ = false;
            }
            else if(_loc9_ == " ")
            {
               setFormatOfWord(_loc11_,_loc11_ + 1,true);
            }
            else
            {
               if(_loc5_ == -1)
               {
                  _loc5_ = _loc11_;
               }
               _loc4_ = true;
               if(_loc11_ + 1 == _loc10_.length)
               {
                  if(!_loc13_)
                  {
                     if(_loc3_)
                     {
                        _loc12_ = true;
                     }
                     _loc14_ += _loc9_;
                  }
                  if(!_loc12_)
                  {
                     if(_loc13_ && !_loc2_)
                     {
                        _loc1_ = true;
                     }
                     else
                     {
                        _loc8_ = _predictions.predict(_loc14_,3,50,100,_useType);
                        _loc1_ = false;
                        if(_loc8_.length > 0)
                        {
                           _loc6_ = 0;
                           while(_loc6_ < _loc8_.length)
                           {
                              if(_loc8_[_loc6_][0].toLowerCase() == _loc14_.toLowerCase())
                              {
                                 _loc1_ = true;
                                 break;
                              }
                              _loc6_++;
                           }
                        }
                     }
                  }
                  else
                  {
                     _loc1_ = false;
                  }
                  if(_loc7_ && !_loc1_)
                  {
                     _loc7_ = false;
                  }
                  setFormatOfWord(_loc5_,_loc11_ + 1,_loc1_);
               }
               else if(!_loc13_)
               {
                  if(_loc3_)
                  {
                     _loc12_ = true;
                  }
                  _loc2_ = true;
                  _loc14_ += _loc9_;
               }
            }
            _loc11_++;
         }
         gMainFrame.stage.focus = null;
         gMainFrame.stage.focus = _chatMsgText;
         if(_chatBar.predictTxt_popup.currentFrameLabel != "close")
         {
            if(_loc7_ == true)
            {
               _chatBar.predictTxt_popup.gotoAndStop("close");
            }
            else if(_currSuggestions.length > 0 && showPredictiveChatBaloons())
            {
               if(_chatBar.predictTxt_popup.currentFrameLabel != "open")
               {
                  _chatBar.predictTxt_popup.gotoAndStop("open");
                  LocalizationManager.translateId(_chatBar.predictTxt_popup.predictTxtBG.txt,29117,true);
               }
            }
            else if(_chatBar.predictTxt_popup.currentFrameLabel != "partial")
            {
               _chatBar.predictTxt_popup.gotoAndStop("partial");
               LocalizationManager.translateId(_chatBar.predictTxt_popup.predictTxtBG.txt,29117,true);
            }
         }
         return _loc7_;
      }
      
      private function setFormatOfWord(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:TextFormat = null;
         if(!isAllowedFreeChat())
         {
            _loc4_ = _chatMsgText.defaultTextFormat;
            if(!param3)
            {
               _loc4_.underline = true;
               _loc4_.color = 16711680;
            }
            else
            {
               _loc4_.underline = false;
               _loc4_.color = 4531987;
            }
            if(_chatMsgText.length > 0 && param2 != param1)
            {
               if(param2 > 0)
               {
                  _chatMsgText.setTextFormat(_loc4_,param1,param2);
               }
               else
               {
                  _chatMsgText.setTextFormat(_loc4_,param1);
               }
            }
         }
      }
      
      private function getCurrentWordStartAndEnd() : Object
      {
         var _loc1_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:int = _chatMsgText.caretIndex;
         var _loc4_:int = 0;
         var _loc3_:* = -1;
         if(_chatMsgText.text.charAt(_loc2_ - 1) == " ")
         {
            _loc4_ = _loc2_;
         }
         else
         {
            _loc6_ = 1;
            while(_loc6_ <= _loc2_)
            {
               if(_chatMsgText.text.charAt(_loc2_ - _loc6_) == " ")
               {
                  _loc4_ = _loc2_ - (_loc6_ - 1);
                  break;
               }
               if(_chatMsgText.text.charAt(_loc2_ - _loc6_).match(SbiConstants.TEXT_PUNCTUATION).length > 0)
               {
                  if(_loc3_ != -1)
                  {
                     _loc4_ = _loc2_ - (_loc6_ - 1);
                     break;
                  }
               }
               else
               {
                  _loc3_ = _loc6_;
               }
               _loc6_++;
            }
         }
         var _loc5_:* = -1;
         if(_loc4_ != -1)
         {
            _loc6_ = _loc4_ + 1;
            while(_loc6_ < _chatMsgText.text.length)
            {
               if(_chatMsgText.text.charAt(_loc6_) == " ")
               {
                  if(_loc5_ == -1)
                  {
                     _loc5_ = _loc6_;
                  }
                  break;
               }
               if(_chatMsgText.text.charAt(_loc6_).match(SbiConstants.TEXT_PUNCTUATION).length > 0)
               {
                  if(_loc5_ == -1)
                  {
                     _loc5_ = int(_loc6_ - 1);
                  }
                  _loc1_++;
               }
               _loc6_++;
            }
         }
         if(_loc5_ == -1)
         {
            _loc5_ = _chatMsgText.text.length;
         }
         return {
            "startOfWord":_loc4_,
            "endOfWord":_loc5_,
            "punctuationSkipped":_loc1_
         };
      }
      
      private function getCurrentWord() : String
      {
         var _loc1_:Object = getCurrentWordStartAndEnd();
         if(_loc1_.startOfWord < 0)
         {
            return _chatMsgText.text.substring(0,_loc1_.endOfWord < 0 ? _chatMsgText.text.length : _loc1_.endOfWord);
         }
         return _chatMsgText.text.substring(_loc1_.startOfWord,_loc1_.endOfWord < 0 ? _chatMsgText.text.length : _loc1_.endOfWord + (_loc1_.punctuationSkipped > 0 ? 1 : 0));
      }
      
      private function updateWordCapitalizations(param1:String, param2:int = 0, param3:Boolean = true, param4:int = -1) : void
      {
         if(param1.length > 1)
         {
            if(param1.length <= param2)
            {
               findStartOfWordAndReplaceOrUpdate(param1,true);
               return;
            }
            if(param1.charAt(param2).match(SbiConstants.TEXT_IGNORE_FOR_CAPITALIZATION).length > 0)
            {
               param2++;
               updateWordCapitalizations(param1,param2,param3,param4);
            }
            else if(param3)
            {
               if(param1.charAt(param2) == param1.charAt(param2).toLowerCase())
               {
                  param1 = param1.toLowerCase();
                  param2 = param1.length;
               }
               else
               {
                  param4 = param2;
               }
               updateWordCapitalizations(param1,++param2,false,param4);
            }
            else
            {
               if(param1.charAt(param2) == param1.charAt(param2).toUpperCase())
               {
                  param1 = param1.toUpperCase();
               }
               else
               {
                  param1 = param1.substring(0,param4 + 1) + param1.substring(param4 + 1).toLowerCase();
               }
               param2 = param1.length;
               updateWordCapitalizations(param1,param2,param3,param4);
            }
         }
      }
      
      private function shouldCapitalizeCurrWord(param1:String, param2:int = 0, param3:Boolean = true) : Boolean
      {
         if(param1.length > 1)
         {
            if(param1.length > param2)
            {
               if(param1.charAt(param2).match(SbiConstants.TEXT_IGNORE_FOR_CAPITALIZATION).length > 0)
               {
                  return shouldCapitalizeCurrWord(param1,++param2,param3);
               }
               if(param3)
               {
                  if(param1.charAt(param2) == param1.charAt(param2).toLowerCase())
                  {
                     return false;
                  }
                  return shouldCapitalizeCurrWord(param1,++param2,false);
               }
               if(param1.charAt(param2) == param1.charAt(param2).toUpperCase())
               {
                  return true;
               }
               return false;
            }
         }
         return false;
      }
      
      public function isValid() : Boolean
      {
         if(_chatMsgText.length == 0)
         {
            return false;
         }
         if(_chatMsgText.text.match("\r"))
         {
            return false;
         }
         return checkEveryWordAndSetFormat();
      }
      
      public function showUnapprovedChatPopup() : void
      {
         if(_currSuggestions.length > 0 && showPredictiveChatBaloons())
         {
            if(_chatBar.predictTxt_popup.currentFrameLabel != "open")
            {
               _chatBar.predictTxt_popup.gotoAndStop("open");
               LocalizationManager.translateId(_chatBar.predictTxt_popup.predictTxtBG.txt,29117,true);
            }
         }
         else if(_chatBar.predictTxt_popup.currentFrameLabel != "partial")
         {
            _chatBar.predictTxt_popup.gotoAndStop("partial");
            LocalizationManager.translateId(_chatBar.predictTxt_popup.predictTxtBG.txt,29117,true);
         }
         var _loc1_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(442));
         if(_loc1_ < 1)
         {
            AchievementXtCommManager.requestSetUserVar(442,1);
            if(_mediaHelper == null)
            {
               DarkenManager.showLoadingSpiral(true);
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(5736,onUnapprovedPopupLoaded);
            }
         }
      }
      
      private function onUnapprovedPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _unapprovedChatPopup = MovieClip(param1.getChildAt(0));
         _unapprovedChatPopup.okBtn.addEventListener("mouseDown",onUnapprovedOkBtn,false,0,true);
         _unapprovedChatPopup.x = 900 * 0.5;
         _unapprovedChatPopup.y = 550 * 0.5;
         _unapprovedChatPopup.startAnimation();
         GuiManager.guiLayer.addChild(_unapprovedChatPopup);
         DarkenManager.darken(_unapprovedChatPopup);
         _mediaHelper.destroy();
         _mediaHelper = null;
      }
      
      private function onUnapprovedOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_unapprovedChatPopup);
         GuiManager.guiLayer.removeChild(_unapprovedChatPopup);
         _unapprovedChatPopup.okBtn.removeEventListener("mouseDown",onUnapprovedOkBtn);
         _unapprovedChatPopup.visible = false;
         _unapprovedChatPopup = null;
      }
   }
}

