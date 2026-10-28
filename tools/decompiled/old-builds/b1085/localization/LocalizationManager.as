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
      
      public static const ADVENTURE_CONFIRMEXIT:int = 10683;
      
      public static const NEW_JAMMER_USERNAME:int = 11098;
      
      public static const GEM_CAPITALIZED:int = 11114;
      
      public static const GEM_EXCLAMATION:int = 11433;
      
      public static const TICKET_CAPITALIZED:int = 11115;
      
      public static const DIAMOND_CAPITALIZED:int = 11116;
      
      public static const ORB_CAPITALIZED:int = 11104;
      
      public static const GEMS_CAPITALIZED:int = 11097;
      
      public static const GEMS_EXCLAMATION:int = 11432;
      
      public static const TICKETS_CAPITALIZED:int = 11102;
      
      public static const DIAMONDS_CAPITALIZED:int = 11103;
      
      public static const ORBS_CAPITALIZED:int = 11117;
      
      public static const MEMBERS:int = 11376;
      
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
         findAllTextfields(param1.target.parent);
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
      
      public static function updateToFit(param1:TextField, param2:String, param3:Boolean = false, param4:Boolean = true) : void
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:Array = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:TextField = null;
         var _loc21_:int = 0;
         var _loc22_:String = null;
         var _loc23_:String = null;
         var _loc24_:int = 0;
         if(param3)
         {
            _loc7_ = param2.match(/<a href='.*'>/g)[0];
            _loc8_ = param2.match(/(?<=<u>).*?(?=<\/u>)/g)[0];
            param1.text = _loc8_;
            param1.htmlText = param2;
         }
         else
         {
            param1.text = param2;
         }
         var _loc5_:Boolean = param1.multiline && param2.split(/\s/g).length < 2;
         if(_loc5_)
         {
            param1.multiline = false;
            param1.wordWrap = false;
         }
         var _loc6_:TextFormat = param1.getTextFormat();
         if(param4)
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
            }
            _loc9_ = param1.y;
            param1.borderColor = _loc9_;
         }
         if(param1.backgroundColor != 16777215)
         {
            _loc6_.size = param1.backgroundColor;
         }
         else
         {
            param1.backgroundColor = uint(_loc6_.size);
         }
         if(param1.textWidth > param1.width - 4 && param1.maxScrollV <= param1.scrollV || param1.textHeight > param1.height - 4)
         {
            _loc10_ = param1.textHeight;
            _loc11_ = int(_loc6_.size);
            _loc12_ = param1.rotation;
            if(_loc12_ != 0)
            {
               param1.rotation = 0;
            }
            if(!param1.multiline)
            {
               while(param1.textWidth > param1.width - 4 || param1.textHeight > param1.height - 4)
               {
                  if(int(_loc6_.size) < 5)
                  {
                     break;
                  }
                  _loc6_.size = int(_loc6_.size) - 1;
                  param1.setTextFormat(_loc6_);
               }
            }
            if(param1.multiline)
            {
               while(param1.textWidth > param1.width - 4 || param1.textHeight > param1.height - 4)
               {
                  _loc13_ = param2;
                  _loc15_ = [];
                  _loc16_ = 0;
                  _loc17_ = 0;
                  _loc18_ = 0;
                  _loc19_ = 0;
                  _loc20_ = new TextField();
                  _loc20_.width = param1.width;
                  _loc20_.height = param1.height;
                  _loc20_.setTextFormat(_loc6_);
                  _loc20_.antiAliasType = param1.antiAliasType;
                  _loc20_.embedFonts = param1.embedFonts;
                  _loc20_.gridFitType = param1.gridFitType;
                  _loc20_.maxChars = param1.maxChars;
                  _loc20_.wordWrap = param1.wordWrap;
                  _loc20_.multiline = param1.multiline;
                  _loc21_ = 0;
                  while(_loc21_ < _loc13_.length)
                  {
                     _loc14_ = _loc13_.charAt(_loc21_);
                     if(_loc21_ + 1 == _loc13_.length)
                     {
                        _loc20_.appendText(_loc14_);
                        _loc20_.setTextFormat(_loc6_);
                        _loc15_[_loc16_] = _loc20_.text;
                     }
                     else if(_loc20_.textWidth >= _loc20_.width - 8 || _loc20_.textHeight >= _loc20_.height - 8)
                     {
                        if(_loc14_ == " " || _loc14_ == "\n" || _loc14_ == "\r" || _loc14_ == "\r\n")
                        {
                           _loc15_[_loc16_] = _loc20_.text + "\n";
                           _loc18_ = _loc17_ = _loc21_ + 1;
                           _loc16_++;
                           _loc20_.text = "";
                           _loc20_.setTextFormat(_loc6_);
                        }
                        else
                        {
                           if(_loc17_ == _loc18_)
                           {
                              break;
                           }
                           _loc22_ = _loc20_.text.substring(0,_loc19_);
                           _loc14_ = _loc22_.charAt(_loc22_.length - 1);
                           _loc15_[_loc16_] = _loc22_ + "\n";
                           _loc17_ = _loc18_;
                           _loc16_++;
                           _loc20_.text = "";
                           _loc20_.setTextFormat(_loc6_);
                           _loc21_ = _loc18_ - 1;
                        }
                     }
                     else if(_loc14_ == " ")
                     {
                        _loc20_.appendText(_loc14_);
                        _loc18_ = _loc21_ + 1;
                        _loc19_ = _loc20_.length;
                        _loc20_.setTextFormat(_loc6_);
                     }
                     else if(_loc14_ == "\n" || _loc14_ == "\r" || _loc14_ == "\r\n")
                     {
                        _loc23_ = _loc13_.charAt(_loc21_ - 1);
                        if(_loc21_ == 0 || _loc23_ == "." || _loc23_ == "!" || _loc23_ == "?" || _loc23_ == "\n" || _loc23_ == "\r" || _loc23_ == "\r\n")
                        {
                           _loc20_.appendText(_loc14_);
                           _loc20_.setTextFormat(_loc6_);
                        }
                        _loc18_ = _loc21_ + 1;
                        _loc19_ = _loc20_.length;
                     }
                     else
                     {
                        _loc20_.appendText(_loc14_);
                        _loc20_.setTextFormat(_loc6_);
                     }
                     _loc21_++;
                  }
                  if(_loc21_ == _loc13_.length)
                  {
                     if(param3)
                     {
                        param1.text = _loc15_.join("");
                        param1.htmlText = _loc7_ + "<u>" + _loc15_.join("") + "</u></a>";
                     }
                     else
                     {
                        param1.text = _loc15_.join("");
                     }
                  }
                  _loc6_.size = int(_loc6_.size) - 1;
                  param1.setTextFormat(_loc6_);
               }
            }
            if(_loc12_ != 0)
            {
               param1.rotation = _loc12_;
            }
            if(!param1.multiline && param4)
            {
               if(param1.rotation == 0)
               {
                  param1.y += (_loc10_ - param1.textHeight) * 0.5;
               }
               else
               {
                  _loc24_ = param1.rotation;
                  param1.rotation = 0;
                  param1.y += Math.round((_loc10_ - param1.textHeight) * 0.5);
                  param1.rotation = _loc24_;
               }
            }
         }
         if(_loc5_)
         {
            param1.multiline = true;
            param1.wordWrap = true;
         }
      }
      
      private static function translateLocalizedIdAndUpdateSize(param1:TextField) : void
      {
         var _loc2_:Object = translateLocalizedId(param1.text);
         if(param1.text != _loc2_.text)
         {
            if(_loc2_.isHtml)
            {
               updateToFit(param1,"<a " + _loc2_.htmlRefText + "><u>" + _loc2_.text + "</u></a>",true);
            }
            else
            {
               updateToFit(param1,_loc2_.text,false);
            }
         }
      }
      
      private static function translateLocalizedId(param1:String) : Object
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(_staticLocalizations)
         {
            _loc2_ = param1.split("#");
            if(_loc2_.length > 1)
            {
               _loc3_ = _loc2_[1];
               _loc4_ = _loc3_.charAt(_loc3_.length - 1);
               if(_loc4_ == "\r" || _loc4_ == "\n" || _loc4_ == "\r\n")
               {
                  _loc3_ = _loc3_.substr(0,_loc3_.length - 1);
               }
               _loc5_ = _staticLocalizations[int(_loc3_)] as String;
               if(_loc5_ != null && _loc5_ != "")
               {
                  if(_loc2_.length == 3)
                  {
                     return {
                        "text":_loc5_,
                        "isHtml":true,
                        "htmlRefText":_loc2_[2]
                     };
                  }
                  return {
                     "text":_loc5_,
                     "isHtml":false
                  };
               }
               return {
                  "text":param1,
                  "isHtml":false
               };
            }
            return {
               "text":param1,
               "isHtml":false
            };
         }
         return {
            "text":param1,
            "isHtml":false
         };
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
         var _loc2_:Array = param1.split("|");
         if(_loc2_.length > 1)
         {
            if(isCurrLanguageReversed())
            {
               _loc3_ = LocalizationManager.translateIdOnly(_loc2_[2]).split("$");
               _loc4_ = LocalizationManager.translateIdOnly(_loc2_[1]).split("$");
               return translateIdOnly(_loc2_[0]) + " " + _loc3_[0] + (_loc3_[1] == "m" ? _loc4_[0].toLowerCase() : _loc4_[1].toLowerCase());
            }
            return translateIdOnly(_loc2_[0]) + " " + translateIdOnly(_loc2_[1]) + translateIdOnly(_loc2_[2]).toLowerCase();
         }
         return param1;
      }
      
      public static function translatePetName(param1:String) : String
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc2_:Array = param1.split("|");
         if(_loc2_.length > 1)
         {
            if(isCurrLanguageReversed())
            {
               _loc3_ = LocalizationManager.translateIdOnly(_loc2_[1]).split("$");
               _loc4_ = LocalizationManager.translateIdOnly(_loc2_[0]).split("$");
               return _loc3_[0] + (_loc3_[1] == "m" ? _loc4_[0].toLowerCase() : _loc4_[1].toLowerCase());
            }
            return translateIdOnly(_loc2_[0]) + translateIdOnly(_loc2_[1]).toLowerCase();
         }
         return param1;
      }
      
      public static function isCurrLanguageReversed() : Boolean
      {
         if(currentLanguage == LANG_FRE || currentLanguage == LANG_POR)
         {
            return true;
         }
         return false;
      }
   }
}

