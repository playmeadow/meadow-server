package localization
{
   import com.sbi.debug.DebugUtility;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class LocalizationManager
   {
      
      public static var LANG_ENG:int = 0;
      
      public static var LANG_SPA:int = 1;
      
      public static var LANG_POR:int = 2;
      
      public static var LANG_FRE:int = 3;
      
      public static var LANG_DE:int = 4;
      
      public static var LANG_BLANK:int = 5;
      
      public static var accountLanguage:int;
      
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
      
      private static var _staticLocalizations:Object;
      
      private static var _preferredLocalizations:Object;
      
      private static var _currentLanguage:int;
      
      private static var _hasLocalizations:Boolean;
      
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
               break;
            case "de":
            case "deu":
            case "ger":
               return LANG_DE;
            default:
               DebugUtility.debugTrace("WARNING - Unknown locale:" + param1 + " - returning -1");
               return -1;
         }
         return LANG_FRE;
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
               return "i-default";
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
               return "i-default";
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
         var _loc1_:Array = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         for each(var _loc2_:String in _staticLocalizations)
         {
            _loc1_ = _loc2_.split(" ");
            _loc4_ = 0;
            while(_loc4_ < _loc1_.length)
            {
               if(_loc1_[_loc4_] != "" && _loc1_[_loc4_] != " " && _loc1_[_loc4_] != "\n" && _loc1_[_loc4_] != "\r" && _loc1_[_loc4_] != "\r\n")
               {
                  _loc3_++;
               }
               _loc4_++;
            }
         }
         return _loc3_;
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
      
      public static function translateId(param1:TextField, param2:int, param3:Boolean = false, param4:Boolean = true) : void
      {
         var _loc5_:String = translateIdOnly(param2);
         if(_loc5_ != "")
         {
            updateToFit(param1,_loc5_,param3,false,param4);
            return;
         }
         throw new Error("Error translating string with id = " + param2);
      }
      
      public static function translateIdAndInsertOnly(param1:int, ... rest) : String
      {
         var _loc3_:Array = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc4_:String = translateIdOnly(param1);
         if(_loc4_ != "" && rest.length > 0)
         {
            _loc3_ = _loc4_.split("%s");
            if(_loc3_.length - 1 != rest.length)
            {
               throw new Error("Num splits does not match num args. Id = " + param1 + " Num splits in translation = " + (_loc3_.length - 1) + " and args length = " + rest.length);
            }
            _loc5_ = "";
            _loc6_ = 0;
            while(_loc6_ < _loc3_.length)
            {
               if(_loc6_ < rest.length)
               {
                  _loc5_ += _loc3_[_loc6_] + rest[_loc6_];
               }
               else
               {
                  _loc5_ += _loc3_[_loc6_];
               }
               _loc6_++;
            }
            return _loc5_;
         }
         throw new Error("Error translating string with id = " + param1 + " and args length = " + rest.length);
      }
      
      public static function translateIdAndInsert(param1:TextField, param2:int, ... rest) : void
      {
         var _loc4_:Array = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc5_:String = translateIdOnly(param2);
         if(_loc5_ != "" && rest.length > 0)
         {
            _loc4_ = _loc5_.split("%s");
            if(_loc4_.length - 1 != rest.length)
            {
               throw new Error("Num splits does not match num args. Id = " + param2 + " Num splits in translation = " + (_loc4_.length - 1) + " and args length = " + rest.length);
            }
            _loc6_ = "";
            _loc7_ = 0;
            while(_loc7_ < _loc4_.length)
            {
               if(_loc7_ < rest.length)
               {
                  _loc6_ += _loc4_[_loc7_] + rest[_loc7_];
               }
               else
               {
                  _loc6_ += _loc4_[_loc7_];
               }
               _loc7_++;
            }
            updateToFit(param1,_loc6_);
            return;
         }
         throw new Error("Error translating string with id = " + param2 + " and args length = " + rest.length);
      }
      
      public static function updateToFit(param1:TextField, param2:String, param3:Boolean = false, param4:Boolean = false, param5:Boolean = true, param6:Boolean = false) : void
      {
         var _loc25_:Array = null;
         var _loc31_:String = null;
         var _loc17_:String = null;
         var _loc21_:Object = null;
         var _loc38_:Number = NaN;
         var _loc22_:TextFormat = null;
         var _loc35_:int = 0;
         var _loc24_:Boolean = false;
         var _loc10_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc9_:int = 0;
         var _loc33_:String = null;
         var _loc13_:String = null;
         var _loc30_:Array = null;
         var _loc11_:int = 0;
         var _loc20_:int = 0;
         var _loc34_:int = 0;
         var _loc8_:int = 0;
         var _loc23_:TextField = null;
         var _loc32_:int = 0;
         var _loc37_:String = null;
         var _loc19_:String = null;
         var _loc26_:String = null;
         var _loc15_:int = 0;
         var _loc16_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc29_:Number = NaN;
         if(param4)
         {
            _loc31_ = param2.match(/<a href='.*'>/g)[0];
            _loc17_ = param2.match(/(?<=<u>).*?(?=<\/u>)/g)[0];
            param1.text = _loc17_ != null ? _loc17_ : param2;
            param1.htmlText = param2;
         }
         else if(param3)
         {
            _loc21_ = {};
            _loc21_.array = _loc25_;
            _loc21_.text = param2;
            findSpecialTagPositions(_loc21_);
            _loc25_ = _loc21_.array;
            param2 = _loc21_.text;
            param1.text = param2;
         }
         else
         {
            param1.text = param2;
         }
         var _loc14_:Boolean = param1.multiline && param2.split(/\s/g).length < 2;
         if(_loc14_)
         {
            param1.multiline = false;
            param1.wordWrap = false;
         }
         var _loc27_:TextFormat = param1.getTextFormat();
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
            _loc38_ = param1.y;
            param1.borderColor = _loc38_ != 0 ? _loc38_ : _loc38_ + 1;
         }
         if(param1.backgroundColor != 16777215)
         {
            _loc27_.size = param1.backgroundColor;
         }
         else if(_loc27_.size != null)
         {
            param1.backgroundColor = uint(_loc27_.size);
         }
         param1.setTextFormat(_loc27_);
         var _loc7_:Number = param1.rotation;
         if(_loc7_ != 0)
         {
            param1.rotation = 0;
         }
         if(param3 && _loc25_ != null)
         {
            _loc22_ = new TextFormat("CCDigitalDelivery",_loc27_.size + 2,_loc27_.color,true);
            _loc35_ = 0;
            while(_loc35_ < _loc25_.length)
            {
               param1.setTextFormat(_loc22_,_loc25_[_loc35_].startIndex,_loc25_[_loc35_].endIndex);
               _loc35_++;
            }
         }
         var _loc28_:TextField = param1.parent[param1.name + "Multiline"];
         var _loc18_:Boolean = hasBrokenWord(param1,param2);
         if(param1.textWidth >= param1.width - 4 && param1.maxScrollV <= param1.scrollV || param1.textHeight > param1.height - 4 || _loc18_)
         {
            _loc10_ = param1.textHeight;
            _loc12_ = Number(_loc27_.size);
            if(!param1.multiline)
            {
               if(_loc28_)
               {
                  _loc9_ = _loc12_ * 0.8;
               }
               while(Number(_loc27_.size) > 5 && param1.textWidth > param1.width - 4)
               {
                  _loc27_.size = Number(_loc27_.size) - 1;
                  param1.setTextFormat(_loc27_);
                  if(_loc28_ && Number(_loc27_.size) < _loc9_)
                  {
                     updateToFit(_loc28_,param2,param3,param4,param5);
                     param1.visible = false;
                     return;
                  }
               }
            }
            else if(param1.multiline)
            {
               param2 = param2.replace(/\r\n|\r/gm,"\n");
               while(Number(_loc27_.size) > 5 && (param1.textWidth > param1.width && !isDifference99PercentOrGreater(param1.width,param1.textWidth,_loc25_ != null) || param1.textHeight > param1.height - 4 && !isDifference99PercentOrGreater(param1.height - 4,param1.textHeight,_loc25_ != null) || _loc23_ != null && _loc23_.numLines > 1 && !isLastLetterAReturn(_loc23_.text) || _loc18_))
               {
                  _loc33_ = param2;
                  _loc30_ = [];
                  _loc11_ = 0;
                  _loc20_ = 0;
                  _loc34_ = 0;
                  _loc8_ = 0;
                  _loc23_ = new TextField();
                  _loc23_.defaultTextFormat = param1.defaultTextFormat;
                  _loc23_.width = param1.width;
                  _loc23_.height = param1.height;
                  _loc23_.setTextFormat(_loc27_);
                  _loc23_.antiAliasType = param1.antiAliasType;
                  _loc23_.embedFonts = param1.embedFonts;
                  _loc23_.gridFitType = param1.gridFitType;
                  _loc23_.maxChars = param1.maxChars;
                  _loc23_.wordWrap = param1.wordWrap;
                  _loc23_.multiline = param1.multiline;
                  _loc32_ = 0;
                  while(_loc32_ < _loc33_.length)
                  {
                     _loc13_ = _loc33_.charAt(_loc32_);
                     if(_loc32_ + 1 == _loc33_.length)
                     {
                        _loc23_.appendText(_loc13_);
                        _loc23_.setTextFormat(_loc27_);
                        _loc30_[_loc11_] = _loc23_.text;
                     }
                     else if(_loc23_.textWidth > _loc23_.width && !isDifference99PercentOrGreater(_loc23_.width,_loc23_.textWidth,_loc25_ != null) || _loc23_.textHeight > _loc23_.height - 4 && !isDifference99PercentOrGreater(_loc23_.height - 4,_loc23_.textHeight,_loc25_ != null) || _loc23_.numLines > 1 && !isLastLetterAReturn(_loc23_.text))
                     {
                        if(_loc13_ == " " || _loc13_ == "\n" || _loc13_ == "\r")
                        {
                           _loc23_.appendText(_loc13_);
                           _loc30_[_loc11_] = _loc23_.text;
                           _loc34_ = _loc20_ = _loc32_ + 1;
                           _loc11_++;
                           _loc23_.text = "";
                           _loc23_.setTextFormat(_loc27_);
                        }
                        else
                        {
                           if(_loc20_ == _loc34_)
                           {
                              break;
                           }
                           _loc37_ = _loc23_.text.substring(0,_loc8_);
                           if(shouldAddSpace(_loc37_))
                           {
                              _loc30_[_loc11_] = _loc37_ + " ";
                           }
                           else
                           {
                              _loc30_[_loc11_] = _loc37_;
                           }
                           _loc20_ = _loc34_;
                           _loc11_++;
                           _loc23_.text = "";
                           _loc23_.setTextFormat(_loc27_);
                           _loc32_ = _loc34_ - 1;
                        }
                     }
                     else if(_loc13_ == " " || _loc13_ == "-")
                     {
                        _loc23_.appendText(_loc13_);
                        _loc34_ = _loc32_ + 1;
                        _loc8_ = _loc23_.length;
                        _loc23_.setTextFormat(_loc27_);
                     }
                     else if(_loc13_ == "\n" || _loc13_ == "\r")
                     {
                        _loc19_ = _loc33_.charAt(_loc32_ - 1);
                        if(_loc32_ == 0 || _loc19_ == "." || _loc19_ == "!" || _loc19_ == "?" || _loc19_ == "\n" || _loc19_ == "\r")
                        {
                           _loc23_.appendText(_loc13_);
                           _loc23_.setTextFormat(_loc27_);
                        }
                        else
                        {
                           _loc23_.appendText(" ");
                           _loc23_.setTextFormat(_loc27_);
                        }
                        _loc34_ = _loc32_ + 1;
                        _loc8_ = _loc23_.length;
                     }
                     else
                     {
                        _loc23_.appendText(_loc13_);
                        _loc23_.setTextFormat(_loc27_);
                     }
                     _loc32_++;
                  }
                  if(param6 && _loc27_.size < _loc12_ * 0.5)
                  {
                     _loc26_ = _loc30_[_loc30_.length - 2];
                     _loc30_[_loc30_.length - 2] = _loc26_.substr(0,_loc26_.length - 4) + "...";
                     _loc30_.pop();
                     _loc24_ = true;
                  }
                  if(_loc32_ == _loc33_.length)
                  {
                     if(param4)
                     {
                        param1.text = _loc30_.join("");
                        param1.htmlText = _loc31_ + "<u>" + _loc30_.join("") + "</u></a>";
                     }
                     else
                     {
                        param1.text = _loc30_.join("");
                     }
                  }
                  _loc27_.size = Number(_loc27_.size) - 1;
                  param1.setTextFormat(_loc27_);
                  if(param3 && _loc25_ != null)
                  {
                     _loc22_ = new TextFormat("CCDigitalDelivery",_loc27_.size + 2,_loc27_.color,true);
                     _loc35_ = 0;
                     while(_loc35_ < _loc25_.length)
                     {
                        param1.setTextFormat(_loc22_,_loc25_[_loc35_].startIndex,_loc25_[_loc35_].endIndex);
                        _loc35_++;
                     }
                  }
                  if(_loc24_)
                  {
                     break;
                  }
                  _loc18_ = hasBrokenWord(param1,param2);
               }
            }
            param1.sharpness = Number(_loc27_.size);
            if(_loc7_ != 0)
            {
               param1.rotation = _loc7_;
            }
            if(!param1.multiline && param5)
            {
               if(param1.rotation == 0)
               {
                  param1.y += (_loc10_ - param1.textHeight) * 0.5;
               }
               else
               {
                  _loc15_ = param1.rotation;
                  param1.rotation = 0;
                  param1.y += Math.round((_loc10_ - param1.textHeight) * 0.5);
                  param1.rotation = _loc15_;
               }
            }
         }
         if(_loc28_ && param1.name != _loc28_.name)
         {
            _loc28_.visible = false;
         }
         if(_loc14_)
         {
            param1.multiline = true;
            param1.wordWrap = true;
         }
         if(param1.multiline && param5 && param1.text != "")
         {
            if(param1.parent.scaleY != 1)
            {
               _loc16_ = param1.parent.height / param1.parent.scaleY;
            }
            else
            {
               _loc16_ = param1.parent.height;
            }
            if(param1.y < 0)
            {
               _loc36_ = param1.y + _loc16_ * 0.5;
            }
            else
            {
               _loc36_ = param1.y;
            }
            _loc29_ = (param1.height - param1.textHeight) * 0.5;
            if(_loc36_ + param1.textHeight + _loc29_ > _loc16_)
            {
               param1.y += _loc16_ - (_loc36_ + param1.textHeight);
            }
            else
            {
               param1.y += _loc29_;
            }
         }
         if(_loc7_ != 0)
         {
            param1.rotation = _loc7_;
         }
      }
      
      private static function findSpecialTagPositions(param1:Object) : void
      {
         var _loc6_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc2_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:Array = [];
         var _loc4_:String = param1.text;
         var _loc5_:String = "";
         _loc10_ = 0;
         while(_loc10_ < _loc4_.length)
         {
            if(_loc4_.charAt(_loc10_) == "<")
            {
               _loc9_++;
               _loc10_++;
               if(_loc4_.charAt(_loc10_) == "/")
               {
                  _loc3_ = true;
               }
               else
               {
                  _loc6_ = true;
               }
               while(_loc4_.charAt(_loc10_) != ">")
               {
                  _loc10_++;
                  _loc9_++;
               }
               if(_loc4_.charAt(_loc10_) == ">")
               {
                  _loc9_++;
               }
               if(_loc6_)
               {
                  _loc2_ = _loc10_ - _loc9_;
                  _loc6_ = false;
               }
               else
               {
                  _loc8_ = _loc10_ + 1 - _loc9_;
                  _loc3_ = false;
                  _loc7_.push({
                     "startIndex":_loc2_,
                     "endIndex":_loc8_
                  });
               }
            }
            else
            {
               _loc5_ += _loc4_.charAt(_loc10_);
            }
            _loc10_++;
         }
         param1.array = _loc7_;
         param1.text = _loc5_;
      }
      
      private static function isDifference99PercentOrGreater(param1:Number, param2:Number, param3:Boolean) : Boolean
      {
         return param1 / param2 >= (param3 ? 0.999 : 0.996);
      }
      
      private static function hasBrokenWord(param1:TextField, param2:String) : Boolean
      {
         var _loc3_:* = null;
         var _loc6_:int = 0;
         var _loc5_:String = null;
         var _loc7_:Number = NaN;
         var _loc4_:Number = 0;
         _loc6_ = 0;
         while(_loc6_ < param2.length)
         {
            _loc5_ = param2.charAt(_loc6_);
            _loc7_ = param1.getLineIndexOfChar(_loc6_);
            if(_loc7_ != _loc4_)
            {
               if(_loc3_ != " " && _loc3_ != "\r" && _loc3_ != "\n" && _loc3_ != "\r\n" && _loc3_ != "-")
               {
                  return true;
               }
            }
            _loc4_ = _loc7_;
            _loc3_ = _loc5_;
            _loc6_++;
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
         var _loc3_:Array = null;
         var _loc2_:String = null;
         if(_staticLocalizations)
         {
            _loc3_ = param1.split("#");
            if(_loc3_.length > 1)
            {
               _loc2_ = _staticLocalizations[int(removeCarriageReturn(_loc3_[1]))] as String;
               if(_loc2_ != null && _loc2_ != "")
               {
                  if(_loc3_.length == 4)
                  {
                     return {
                        "text":_loc2_,
                        "isHtmlNormal":false,
                        "isHtmlClick":true,
                        "htmlRefText":_loc3_[3]
                     };
                  }
                  if(_loc3_.length == 3)
                  {
                     return {
                        "text":_loc2_,
                        "isHtmlNormal":true,
                        "isHtmlClick":false
                     };
                  }
                  return {
                     "text":_loc2_,
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
         var _loc3_:int = 0;
         var _loc2_:Object = null;
         if(param1 is TextField)
         {
            translateLocalizedIdAndUpdateSize(TextField(param1));
            return;
         }
         if(param1.hasOwnProperty("numChildren"))
         {
            _loc3_ = 0;
            while(_loc3_ < param1.numChildren)
            {
               _loc2_ = param1.getChildAt(_loc3_);
               if(_loc2_)
               {
                  if(_loc2_ is TextField)
                  {
                     translateLocalizedIdAndUpdateSize(TextField(_loc2_));
                  }
                  if(_loc2_.name == "bakedLogo")
                  {
                     _loc2_.gotoAndStop(currentLanguage + 1);
                  }
                  if(_loc2_.hasOwnProperty("numChildren") && _loc2_.numChildren > 0)
                  {
                     findAllTextfields(_loc2_);
                  }
               }
               _loc3_++;
            }
         }
      }
      
      public static function translateAvatarName(param1:String) : String
      {
         var _loc4_:Array = null;
         var _loc3_:Array = null;
         var _loc5_:String = null;
         var _loc2_:Array = param1.split("|");
         if(_loc2_.length > 1)
         {
            if(isCurrLanguageReversed())
            {
               _loc4_ = LocalizationManager.translateIdOnly(_loc2_[2]).split("$");
               _loc3_ = LocalizationManager.translateIdOnly(_loc2_[1]).split("$");
               if(_loc4_.length == 1 || _loc4_[1] == "m")
               {
                  _loc5_ = _loc3_[0].toLowerCase();
               }
               else if(_loc3_.length == 1)
               {
                  _loc5_ = _loc3_[0].toLowerCase();
               }
               else
               {
                  _loc5_ = _loc3_[1].toLowerCase();
               }
               return translateIdOnly(_loc2_[0]) + " " + _loc4_[0] + _loc5_;
            }
            return translateIdOnly(_loc2_[0]) + " " + translateIdOnly(_loc2_[1]) + translateIdOnly(_loc2_[2]).toLowerCase();
         }
         return param1;
      }
      
      public static function translatePetName(param1:String) : String
      {
         var _loc4_:Array = null;
         var _loc3_:Array = null;
         var _loc5_:String = null;
         var _loc2_:Array = param1.split("|");
         if(_loc2_.length > 1)
         {
            if(isCurrLanguageReversed())
            {
               _loc4_ = LocalizationManager.translateIdOnly(_loc2_[1]).split("$");
               _loc3_ = LocalizationManager.translateIdOnly(_loc2_[0]).split("$");
               if(_loc4_.length == 1 || _loc4_[1] == "m")
               {
                  _loc5_ = _loc3_[0].toLowerCase();
               }
               else if(_loc3_.length == 1)
               {
                  _loc5_ = _loc3_[0].toLowerCase();
               }
               else
               {
                  _loc5_ = _loc3_[1].toLowerCase();
               }
               return _loc4_[0] + _loc5_;
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

