package localization
{
   import com.sbi.debug.DebugUtility;
   import flash.events.Event;
   import flash.globalization.LocaleID;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class LocalizationManager
   {
      
      public static var accountLanguage:int;
      
      private static var _staticLocalizations:Object;
      
      private static var _preferredLocalizations:Object;
      
      private static var _currentLanguage:int;
      
      private static var _hasLocalizations:Boolean;
      
      public static var LANG_ENG:int = 0;
      
      public static var LANG_SPA:int = 1;
      
      public static var LANG_POR:int = 2;
      
      public static var LANG_FRE:int = 3;
      
      public static var LANG_DE:int = 4;
      
      public static var LANG_BLANK:int = 5;
      
      public static const ADVENTURE_CONFIRMEXIT:int = 10683;
      
      public static const NEW_JAMMER_USERNAME:int = 11098;
      
      public static const GEM_CAPITALIZED:int = 11114;
      
      public static const GEM_EXCLAMATION:int = 11433;
      
      public static const TICKET_CAPITALIZED:int = 11115;
      
      public static const DIAMOND_CAPITALIZED:int = 11116;
      
      public static const CRYSTAL_CAPITALIZED:int = 11104;
      
      public static const GEMS_CAPITALIZED:int = 11097;
      
      public static const GEMS_EXCLAMATION:int = 11432;
      
      public static const TICKETS_CAPITALIZED:int = 11102;
      
      public static const DIAMONDS_CAPITALIZED:int = 11103;
      
      public static const CRYSTALS_CAPITALIZED:int = 11117;
      
      public static const MEMBERS:int = 11376;
      
      public static const UNUSABLE_PASSWORDS:int = 21913;
      
      public function LocalizationManager()
      {
         super();
      }
      
      public static function setLocalizations(param1:Object, param2:Function) : void
      {
         _staticLocalizations = param1;
         _hasLocalizations = true;
         if(param2 != null)
         {
            param2();
         }
      }
      
      public static function setPreferredLocalizations(param1:Object) : void
      {
         _preferredLocalizations = param1;
      }
      
      public static function getLanguageIdForLocale(param1:String) : int
      {
         var _loc2_:String = param1;
         if(param1.indexOf("-") != -1)
         {
            _loc2_ = param1.substr(0,param1.indexOf("-"));
         }
         switch(_loc2_)
         {
            case "en":
            case "eng":
               return LANG_ENG;
            case "es":
            case "spa":
               return LANG_SPA;
            case "pt":
            case "por":
               return LANG_POR;
            case "fr":
            case "fra":
            case "fre":
               return LANG_FRE;
            case "de":
            case "deu":
            case "ger":
               return LANG_DE;
            default:
               DebugUtility.debugTrace("WARNING - Unknown locale:" + param1 + " - returning -1");
               return -1;
         }
      }
      
      public static function get localeForSorting() : String
      {
         switch(_currentLanguage)
         {
            case LANG_ENG:
               return "en-US";
            case LANG_DE:
               return "de-DE@collation=phonebook";
            case LANG_FRE:
               return "fr-FR";
            case LANG_POR:
               return "pt-BR";
            case LANG_SPA:
               return "es-ES";
            default:
               return LocaleID.DEFAULT;
         }
      }
      
      public static function get localeForNumberFormatting() : String
      {
         switch(_currentLanguage)
         {
            case LANG_ENG:
               return "en-US";
            case LANG_DE:
               return "de-DE";
            case LANG_FRE:
               return "fr-FR";
            case LANG_POR:
               return "pt-BR";
            case LANG_SPA:
               return "es-ES";
            default:
               return LocaleID.DEFAULT;
         }
      }
      
      public static function get hasLocalizations() : Boolean
      {
         return _hasLocalizations;
      }
      
      public static function set hasLocalizations(param1:Boolean) : void
      {
         _hasLocalizations = param1;
      }
      
      public static function get currentLanguage() : int
      {
         return _currentLanguage;
      }
      
      public static function set currentLanguage(param1:int) : void
      {
         _currentLanguage = param1;
      }
      
      public static function numberOfWordsInString() : int
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         for each(_loc2_ in _staticLocalizations)
         {
            _loc3_ = _loc2_.split(" ");
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               if(_loc3_[_loc4_] != "" && _loc3_[_loc4_] != " " && _loc3_[_loc4_] != "\n" && _loc3_[_loc4_] != "\r" && _loc3_[_loc4_] != "\r\n")
               {
                  _loc1_++;
               }
               _loc4_++;
            }
         }
         return _loc1_;
      }
      
      public static function onLocalizationEvent(param1:Event) : void
      {
         param1.stopPropagation();
         findAllTextfields(param1.target);
      }
      
      public static function translateIdOnly(param1:int) : String
      {
         if(_staticLocalizations[param1])
         {
            return _staticLocalizations[param1];
         }
         return "";
      }
      
      public static function translatePreferredIdOnly(param1:int) : String
      {
         if(_preferredLocalizations[param1])
         {
            return _preferredLocalizations[param1];
         }
         return "";
      }
      
      public static function translateId(param1:TextField, param2:int, param3:Boolean = false) : void
      {
         var _loc4_:String = translateIdOnly(param2);
         if(_loc4_ != "")
         {
            updateToFit(param1,_loc4_,param3);
            return;
         }
         throw new Error("Error translating string with id = " + param2);
      }
      
      public static function translateIdAndInsertOnly(param1:int, ... rest) : String
      {
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc3_:String = translateIdOnly(param1);
         if(_loc3_ != "" && rest.length > 0)
         {
            _loc4_ = _loc3_.split("%s");
            if(_loc4_.length - 1 != rest.length)
            {
               throw new Error("Num splits does not match num args. Id = " + param1 + " Num splits in translation = " + (_loc4_.length - 1) + " and args length = " + rest.length);
            }
            _loc5_ = "";
            _loc6_ = 0;
            while(_loc6_ < _loc4_.length)
            {
               if(_loc6_ < rest.length)
               {
                  _loc5_ += _loc4_[_loc6_] + rest[_loc6_];
               }
               else
               {
                  _loc5_ += _loc4_[_loc6_];
               }
               _loc6_++;
            }
            return _loc5_;
         }
         throw new Error("Error translating string with id = " + param1 + " and args length = " + rest.length);
      }
      
      public static function translateIdAndInsert(param1:TextField, param2:int, ... rest) : void
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc4_:String = translateIdOnly(param2);
         if(_loc4_ != "" && rest.length > 0)
         {
            _loc5_ = _loc4_.split("%s");
            if(_loc5_.length - 1 != rest.length)
            {
               throw new Error("Num splits does not match num args. Id = " + param2 + " Num splits in translation = " + (_loc5_.length - 1) + " and args length = " + rest.length);
            }
            _loc6_ = "";
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               if(_loc7_ < rest.length)
               {
                  _loc6_ += _loc5_[_loc7_] + rest[_loc7_];
               }
               else
               {
                  _loc6_ += _loc5_[_loc7_];
               }
               _loc7_++;
            }
            updateToFit(param1,_loc6_);
            return;
         }
         throw new Error("Error translating string with id = " + param2 + " and args length = " + rest.length);
      }
      
      public static function updateToFit(param1:TextField, param2:String, param3:Boolean = false, param4:Boolean = false, param5:Boolean = true) : void
      {
         var _loc6_:Array = null;
         var _loc10_:TextFormat = null;
         var _loc11_:int = 0;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:Object = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:int = 0;
         var _loc21_:String = null;
         var _loc22_:String = null;
         var _loc23_:Array = null;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc27_:int = 0;
         var _loc28_:TextField = null;
         var _loc29_:int = 0;
         var _loc30_:String = null;
         var _loc31_:String = null;
         var _loc32_:int = 0;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         if(param4)
         {
            _loc14_ = param2.match(/<a href='.*'>/g)[0];
            _loc15_ = param2.match(/(?<=<u>).*?(?=<\/u>)/g)[0];
            param1.text = _loc15_ != null ? _loc15_ : param2;
            param1.htmlText = param2;
         }
         else if(param3)
         {
            _loc16_ = new Object();
            _loc16_.array = _loc6_;
            _loc16_.text = param2;
            findSpecialTagPositions(_loc16_);
            _loc6_ = _loc16_.array;
            param2 = _loc16_.text;
            param1.text = param2;
         }
         else
         {
            param1.text = param2;
         }
         var _loc7_:Boolean = param1.multiline && param2.split(/\s/g).length < 2;
         if(_loc7_)
         {
            param1.multiline = false;
            param1.wordWrap = false;
         }
         var _loc8_:TextFormat = param1.getTextFormat();
         if(param1.text.charAt(0) == "#" || param1.name == "text01_chatHistory")
         {
            param5 = false;
         }
         if(param5)
         {
            if(param1.borderColor != 0 && !param1.border)
            {
               if(param1.borderColor > 16711680)
               {
                  param1.y = 0 - ((2147483647 - param1.borderColor & 0xFFFF) + 1);
               }
               else
               {
                  param1.y = param1.borderColor;
               }
               if(param1.y == 1)
               {
                  param1.y = 0;
               }
            }
            _loc17_ = param1.y;
            param1.borderColor = _loc17_ != 0 ? uint(_loc17_) : uint(_loc17_ + 1);
         }
         if(param1.backgroundColor != 16777215)
         {
            _loc8_.size = param1.backgroundColor;
         }
         else if(_loc8_.size != null)
         {
            param1.backgroundColor = uint(_loc8_.size);
         }
         param1.setTextFormat(_loc8_);
         var _loc9_:Number = param1.rotation;
         if(_loc9_ != 0)
         {
            param1.rotation = 0;
         }
         if(param3 && _loc6_ != null)
         {
            _loc10_ = new TextFormat("CCDigitalDelivery",_loc8_.size + 2,_loc8_.color,true);
            _loc11_ = 0;
            while(_loc11_ < _loc6_.length)
            {
               param1.setTextFormat(_loc10_,_loc6_[_loc11_].startIndex,_loc6_[_loc11_].endIndex);
               _loc11_++;
            }
         }
         var _loc12_:TextField = param1.parent[param1.name + "Multiline"];
         var _loc13_:Boolean = hasBrokenWord(param1,param2);
         if(param5 && (param1.textWidth >= param1.width - 4 && param1.maxScrollV <= param1.scrollV || param1.textHeight > param1.height - 4 || _loc13_))
         {
            _loc18_ = param1.textHeight;
            _loc19_ = Number(_loc8_.size);
            if(!param1.multiline)
            {
               if(_loc12_)
               {
                  _loc20_ = _loc19_ * 0.8;
               }
               while(Number(_loc8_.size) > 5 && param1.textWidth > param1.width - 4)
               {
                  _loc8_.size = Number(_loc8_.size) - 1;
                  param1.setTextFormat(_loc8_);
                  if(Boolean(_loc12_) && Number(_loc8_.size) < _loc20_)
                  {
                     updateToFit(_loc12_,param2,param3,param4,param5);
                     param1.visible = false;
                     return;
                  }
               }
            }
            else if(param1.multiline)
            {
               param2 = param2.replace(/\r\n|\r/gm,"\n");
               while(Number(_loc8_.size) > 5 && (param1.textWidth > param1.width && !isDifference99PercentOrGreater(param1.width,param1.textWidth,_loc6_ != null) || param1.textHeight > param1.height - 4 && !isDifference99PercentOrGreater(param1.height - 4,param1.textHeight,_loc6_ != null) || _loc28_ != null && _loc28_.numLines > 1 && !isLastLetterAReturn(_loc28_.text) || _loc13_))
               {
                  _loc21_ = param2;
                  _loc23_ = [];
                  _loc24_ = 0;
                  _loc25_ = 0;
                  _loc26_ = 0;
                  _loc27_ = 0;
                  _loc28_ = new TextField();
                  _loc28_.defaultTextFormat = param1.defaultTextFormat;
                  _loc28_.width = param1.width;
                  _loc28_.height = param1.height;
                  _loc28_.setTextFormat(_loc8_);
                  _loc28_.antiAliasType = param1.antiAliasType;
                  _loc28_.embedFonts = param1.embedFonts;
                  _loc28_.gridFitType = param1.gridFitType;
                  _loc28_.maxChars = param1.maxChars;
                  _loc28_.wordWrap = param1.wordWrap;
                  _loc28_.multiline = param1.multiline;
                  _loc29_ = 0;
                  while(_loc29_ < _loc21_.length)
                  {
                     _loc22_ = _loc21_.charAt(_loc29_);
                     if(_loc29_ + 1 == _loc21_.length)
                     {
                        _loc28_.appendText(_loc22_);
                        _loc28_.setTextFormat(_loc8_);
                        _loc23_[_loc24_] = _loc28_.text;
                     }
                     else if(_loc28_.textWidth > _loc28_.width && !isDifference99PercentOrGreater(_loc28_.width,_loc28_.textWidth,_loc6_ != null) || _loc28_.textHeight > _loc28_.height - 4 && !isDifference99PercentOrGreater(_loc28_.height - 4,_loc28_.textHeight,_loc6_ != null) || _loc28_.numLines > 1 && !isLastLetterAReturn(_loc28_.text))
                     {
                        if(_loc22_ == " " || _loc22_ == "\n" || _loc22_ == "\r")
                        {
                           _loc28_.appendText(_loc22_);
                           _loc23_[_loc24_] = _loc28_.text;
                           _loc26_ = _loc25_ = _loc29_ + 1;
                           _loc24_++;
                           _loc28_.text = "";
                           _loc28_.setTextFormat(_loc8_);
                        }
                        else
                        {
                           if(_loc25_ == _loc26_)
                           {
                              break;
                           }
                           _loc30_ = _loc28_.text.substring(0,_loc27_);
                           if(shouldAddSpace(_loc30_))
                           {
                              _loc23_[_loc24_] = _loc30_ + " ";
                           }
                           else
                           {
                              _loc23_[_loc24_] = _loc30_;
                           }
                           _loc25_ = _loc26_;
                           _loc24_++;
                           _loc28_.text = "";
                           _loc28_.setTextFormat(_loc8_);
                           _loc29_ = _loc26_ - 1;
                        }
                     }
                     else if(_loc22_ == " " || _loc22_ == "-")
                     {
                        _loc28_.appendText(_loc22_);
                        _loc26_ = _loc29_ + 1;
                        _loc27_ = _loc28_.length;
                        _loc28_.setTextFormat(_loc8_);
                     }
                     else if(_loc22_ == "\n" || _loc22_ == "\r")
                     {
                        _loc31_ = _loc21_.charAt(_loc29_ - 1);
                        if(_loc29_ == 0 || _loc31_ == "." || _loc31_ == "!" || _loc31_ == "?" || _loc31_ == "\n" || _loc31_ == "\r")
                        {
                           _loc28_.appendText(_loc22_);
                           _loc28_.setTextFormat(_loc8_);
                        }
                        else
                        {
                           _loc28_.appendText(" ");
                           _loc28_.setTextFormat(_loc8_);
                        }
                        _loc26_ = _loc29_ + 1;
                        _loc27_ = _loc28_.length;
                     }
                     else
                     {
                        _loc28_.appendText(_loc22_);
                        _loc28_.setTextFormat(_loc8_);
                     }
                     _loc29_++;
                  }
                  if(_loc29_ == _loc21_.length)
                  {
                     if(param4)
                     {
                        param1.text = _loc23_.join("");
                        param1.htmlText = _loc14_ + "<u>" + _loc23_.join("") + "</u></a>";
                     }
                     else
                     {
                        param1.text = _loc23_.join("");
                     }
                  }
                  _loc8_.size = Number(_loc8_.size) - 1;
                  param1.setTextFormat(_loc8_);
                  if(param3 && _loc6_ != null)
                  {
                     _loc10_ = new TextFormat("CCDigitalDelivery",_loc8_.size + 2,_loc8_.color,true);
                     _loc11_ = 0;
                     while(_loc11_ < _loc6_.length)
                     {
                        param1.setTextFormat(_loc10_,_loc6_[_loc11_].startIndex,_loc6_[_loc11_].endIndex);
                        _loc11_++;
                     }
                  }
                  _loc13_ = hasBrokenWord(param1,param2);
               }
            }
            param1.sharpness = Number(_loc8_.size);
            if(_loc9_ != 0)
            {
               param1.rotation = _loc9_;
            }
            if(!param1.multiline && param5)
            {
               if(param1.rotation == 0)
               {
                  param1.y += (_loc18_ - param1.textHeight) * 0.5;
               }
               else
               {
                  _loc32_ = param1.rotation;
                  param1.rotation = 0;
                  param1.y += Math.round((_loc18_ - param1.textHeight) * 0.5);
                  param1.rotation = _loc32_;
               }
            }
         }
         if(Boolean(_loc12_) && param1.name != _loc12_.name)
         {
            _loc12_.visible = false;
         }
         if(_loc7_)
         {
            param1.multiline = true;
            param1.wordWrap = true;
         }
         if(param1.multiline && param5)
         {
            if(param1.parent.scaleY != 1)
            {
               _loc33_ = param1.parent.height / param1.parent.scaleY;
            }
            else
            {
               _loc33_ = param1.parent.height;
            }
            if(param1.y < 0)
            {
               _loc34_ = param1.y + _loc33_ * 0.5;
            }
            else
            {
               _loc34_ = param1.y;
            }
            _loc35_ = (param1.height - param1.textHeight) * 0.5;
            if(_loc34_ + param1.textHeight + _loc35_ > _loc33_)
            {
               param1.y += _loc33_ - (_loc34_ + param1.textHeight);
            }
            else
            {
               param1.y += _loc35_;
            }
         }
         if(_loc9_ != 0)
         {
            param1.rotation = _loc9_;
         }
      }
      
      private static function findSpecialTagPositions(param1:Object) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:String = param1.text;
         var _loc4_:String = "";
         var _loc10_:int = 0;
         while(_loc10_ < _loc3_.length)
         {
            if(_loc3_.charAt(_loc10_) == "<")
            {
               _loc9_++;
               _loc10_++;
               if(_loc3_.charAt(_loc10_) == "/")
               {
                  _loc6_ = true;
               }
               else
               {
                  _loc5_ = true;
               }
               while(_loc3_.charAt(_loc10_) != ">")
               {
                  _loc10_++;
                  _loc9_++;
               }
               if(_loc3_.charAt(_loc10_) == ">")
               {
                  _loc9_++;
               }
               if(_loc5_)
               {
                  _loc7_ = _loc10_ - _loc9_;
                  _loc5_ = false;
               }
               else
               {
                  _loc8_ = _loc10_ + 1 - _loc9_;
                  _loc6_ = false;
                  _loc2_.push({
                     "startIndex":_loc7_,
                     "endIndex":_loc8_
                  });
               }
            }
            else
            {
               _loc4_ += _loc3_.charAt(_loc10_);
            }
            _loc10_++;
         }
         param1.array = _loc2_;
         param1.text = _loc4_;
      }
      
      private static function isDifference99PercentOrGreater(param1:Number, param2:Number, param3:Boolean) : Boolean
      {
         return param1 / param2 >= (param3 ? 0.999 : 0.996);
      }
      
      private static function hasBrokenWord(param1:TextField, param2:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc3_:Number = 0;
         var _loc5_:int = 0;
         while(_loc5_ < param2.length)
         {
            _loc6_ = param2.charAt(_loc5_);
            _loc7_ = param1.getLineIndexOfChar(_loc5_);
            if(_loc7_ != _loc3_)
            {
               if(_loc4_ != " " && _loc4_ != "\r" && _loc4_ != "\n" && _loc4_ != "\r\n" && _loc4_ != "-")
               {
                  return true;
               }
            }
            _loc3_ = _loc7_;
            _loc4_ = _loc6_;
            _loc5_++;
         }
         return false;
      }
      
      private static function isLastLetterAReturn(param1:String) : Boolean
      {
         var _loc2_:String = param1.substr(-1);
         if(_loc2_ == "\n" || _loc2_ == "\r")
         {
            return true;
         }
         return false;
      }
      
      private static function shouldAddSpace(param1:String) : Boolean
      {
         var _loc2_:String = param1.substr(-1);
         if(_loc2_ == " " || _loc2_ == "\n" || _loc2_ == "\r")
         {
            return false;
         }
         return true;
      }
      
      private static function translateLocalizedIdAndUpdateSize(param1:TextField) : void
      {
         var _loc2_:Object = translateLocalizedId(param1.text);
         if(param1.text != _loc2_.text || param1.sharpness != -1 && param1.sharpness != param1.defaultTextFormat.size)
         {
            if(_loc2_.isHtmlClick)
            {
               updateToFit(param1,"<a " + _loc2_.htmlRefText + "><u>" + _loc2_.text + "</u></a>",false,true);
            }
            else
            {
               updateToFit(param1,_loc2_.text,_loc2_.isHtmlNormal);
            }
         }
      }
      
      private static function translateLocalizedId(param1:String) : Object
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         if(_staticLocalizations)
         {
            _loc2_ = param1.split("#");
            if(_loc2_.length > 1)
            {
               _loc3_ = _staticLocalizations[int(removeCarriageReturn(_loc2_[1]))] as String;
               if(_loc3_ != null && _loc3_ != "")
               {
                  if(_loc2_.length == 4)
                  {
                     return {
                        "text":_loc3_,
                        "isHtmlNormal":false,
                        "isHtmlClick":true,
                        "htmlRefText":_loc2_[3]
                     };
                  }
                  if(_loc2_.length == 3)
                  {
                     return {
                        "text":_loc3_,
                        "isHtmlNormal":true,
                        "isHtmlClick":false
                     };
                  }
                  return {
                     "text":_loc3_,
                     "isHtmlNormal":false,
                     "isHtmlClick":false
                  };
               }
               return {
                  "text":param1,
                  "isHtmlNormal":false,
                  "isHtmlClick":false
               };
            }
            return {
               "text":removeCarriageReturn(param1),
               "isHtmlNormal":false,
               "isHtmlClick":false
            };
         }
         return {
            "text":removeCarriageReturn(param1),
            "isHtmlNormal":false,
            "isHtmlClick":false
         };
      }
      
      private static function removeCarriageReturn(param1:String) : String
      {
         var _loc2_:String = param1.charAt(param1.length - 1);
         if(_loc2_ == "\r" || _loc2_ == "\n" || _loc2_ == "\r\n")
         {
            return param1.substr(0,param1.length - 1);
         }
         return param1;
      }
      
      public static function findAllTextfields(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1 is TextField)
         {
            translateLocalizedIdAndUpdateSize(TextField(param1));
            return;
         }
         if(param1.hasOwnProperty("numChildren"))
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               _loc3_ = param1.getChildAt(_loc2_);
               if(_loc3_)
               {
                  if(_loc3_ is TextField)
                  {
                     translateLocalizedIdAndUpdateSize(TextField(_loc3_));
                  }
                  if(_loc3_.name == "bakedLogo")
                  {
                     _loc3_.gotoAndStop(currentLanguage + 1);
                  }
                  if(_loc3_.hasOwnProperty("numChildren") && _loc3_.numChildren > 0)
                  {
                     findAllTextfields(_loc3_);
                  }
               }
               _loc2_++;
            }
         }
      }
      
      public static function translateAvatarName(param1:String) : String
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc2_:Array = param1.split("|");
         if(_loc2_.length > 1)
         {
            if(isCurrLanguageReversed())
            {
               _loc3_ = LocalizationManager.translateIdOnly(_loc2_[2]).split("$");
               _loc4_ = LocalizationManager.translateIdOnly(_loc2_[1]).split("$");
               if(_loc3_.length == 1 || _loc3_[1] == "m")
               {
                  _loc5_ = _loc4_[0].toLowerCase();
               }
               else if(_loc4_.length == 1)
               {
                  _loc5_ = _loc4_[0].toLowerCase();
               }
               else
               {
                  _loc5_ = _loc4_[1].toLowerCase();
               }
               return translateIdOnly(_loc2_[0]) + " " + _loc3_[0] + _loc5_;
            }
            return translateIdOnly(_loc2_[0]) + " " + translateIdOnly(_loc2_[1]) + translateIdOnly(_loc2_[2]).toLowerCase();
         }
         return param1;
      }
      
      public static function translatePetName(param1:String) : String
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc2_:Array = param1.split("|");
         if(_loc2_.length > 1)
         {
            if(isCurrLanguageReversed())
            {
               _loc3_ = LocalizationManager.translateIdOnly(_loc2_[1]).split("$");
               _loc4_ = LocalizationManager.translateIdOnly(_loc2_[0]).split("$");
               if(_loc3_.length == 1 || _loc3_[1] == "m")
               {
                  _loc5_ = _loc4_[0].toLowerCase();
               }
               else if(_loc4_.length == 1)
               {
                  _loc5_ = _loc4_[0].toLowerCase();
               }
               else
               {
                  _loc5_ = _loc4_[1].toLowerCase();
               }
               return _loc3_[0] + _loc5_;
            }
            return translateIdOnly(_loc2_[0]) + translateIdOnly(_loc2_[1]).toLowerCase();
         }
         return param1;
      }
      
      public static function isCurrLanguageReversed() : Boolean
      {
         if(currentLanguage == LANG_FRE || currentLanguage == LANG_POR || currentLanguage == LANG_SPA)
         {
            return true;
         }
         return false;
      }
   }
}

