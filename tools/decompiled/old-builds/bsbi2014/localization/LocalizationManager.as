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
      
      public static function setLocalizations(value:Object, guiManagerRebuildFunction:Function) : void
      {
         _staticLocalizations = value;
         _hasLocalizations = true;
         if(guiManagerRebuildFunction != null)
         {
            guiManagerRebuildFunction();
         }
      }
      
      public static function setPreferredLocalizations(value:Object) : void
      {
         _preferredLocalizations = value;
      }
      
      public static function getLanguageIdForLocale(locale:String) : int
      {
         var langStr:String = locale;
         if(locale.indexOf("-") != -1)
         {
            langStr = locale.substr(0,locale.indexOf("-"));
         }
         switch(langStr)
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
               DebugUtility.debugTrace("WARNING - Unknown locale:" + locale + " - returning -1");
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
      
      public static function set hasLocalizations(value:Boolean) : void
      {
         _hasLocalizations = value;
      }
      
      public static function get currentLanguage() : int
      {
         return _currentLanguage;
      }
      
      public static function set currentLanguage(value:int) : void
      {
         _currentLanguage = value;
      }
      
      public static function numberOfWordsInString() : int
      {
         var str:String = null;
         var splitString:Array = null;
         var i:int = 0;
         var count:int = 0;
         for each(str in _staticLocalizations)
         {
            splitString = str.split(" ");
            for(i = 0; i < splitString.length; i++)
            {
               if(splitString[i] != "" && splitString[i] != " " && splitString[i] != "\n" && splitString[i] != "\r" && splitString[i] != "\r\n")
               {
                  count++;
               }
            }
         }
         return count;
      }
      
      public static function onLocalizationEvent(evt:Event) : void
      {
         evt.stopPropagation();
         findAllTextfields(evt.target);
      }
      
      public static function translateIdOnly(id:int) : String
      {
         if(Boolean(_staticLocalizations[id]))
         {
            return _staticLocalizations[id];
         }
         return "";
      }
      
      public static function translatePreferredIdOnly(id:int) : String
      {
         if(Boolean(_preferredLocalizations[id]))
         {
            return _preferredLocalizations[id];
         }
         return "";
      }
      
      public static function translateId(tf:TextField, id:int, setHtmlText:Boolean = false) : void
      {
         var translatedString:String = translateIdOnly(id);
         if(translatedString != "")
         {
            updateToFit(tf,translatedString,setHtmlText);
            return;
         }
         throw new Error("Error translating string with id = " + id);
      }
      
      public static function translateIdAndInsertOnly(id:int, ... args) : String
      {
         var splitTranslation:Array = null;
         var concatString:String = null;
         var i:int = 0;
         var translatedString:String = translateIdOnly(id);
         if(translatedString != "" && args.length > 0)
         {
            splitTranslation = translatedString.split("%s");
            if(splitTranslation.length - 1 != args.length)
            {
               throw new Error("Num splits does not match num args. Id = " + id + " Num splits in translation = " + (splitTranslation.length - 1) + " and args length = " + args.length);
            }
            concatString = "";
            for(i = 0; i < splitTranslation.length; i++)
            {
               if(i < args.length)
               {
                  concatString += splitTranslation[i] + args[i];
               }
               else
               {
                  concatString += splitTranslation[i];
               }
            }
            return concatString;
         }
         throw new Error("Error translating string with id = " + id + " and args length = " + args.length);
      }
      
      public static function translateIdAndInsert(tf:TextField, id:int, ... args) : void
      {
         var splitTranslation:Array = null;
         var concatString:String = null;
         var i:int = 0;
         var translatedString:String = translateIdOnly(id);
         if(translatedString != "" && args.length > 0)
         {
            splitTranslation = translatedString.split("%s");
            if(splitTranslation.length - 1 != args.length)
            {
               throw new Error("Num splits does not match num args. Id = " + id + " Num splits in translation = " + (splitTranslation.length - 1) + " and args length = " + args.length);
            }
            concatString = "";
            for(i = 0; i < splitTranslation.length; i++)
            {
               if(i < args.length)
               {
                  concatString += splitTranslation[i] + args[i];
               }
               else
               {
                  concatString += splitTranslation[i];
               }
            }
            updateToFit(tf,concatString);
            return;
         }
         throw new Error("Error translating string with id = " + id + " and args length = " + args.length);
      }
      
      public static function updateToFit(tf:TextField, locText:String, setHtmlText:Boolean = false, adjustYLocation:Boolean = true) : void
      {
         var url:String = null;
         var text:String = null;
         var originalYLocation:Number = NaN;
         var originalTextHeight:int = 0;
         var originalSize:int = 0;
         var smallestSizeIfMultilineAvail:int = 0;
         var myFullText:String = null;
         var currChar:String = null;
         var adjustedLines:Array = null;
         var currLine:int = 0;
         var lastStopIndex:int = 0;
         var lastEndOfWordIndex:int = 0;
         var lastWordIndexThisLine:int = 0;
         var sizingTf:TextField = null;
         var i:int = 0;
         var currString:String = null;
         var previousChar:String = null;
         var savedRotation:int = 0;
         var parentHeight:Number = NaN;
         var tfY:Number = NaN;
         var amountToChange:Number = NaN;
         if(setHtmlText)
         {
            url = locText.match(/<a href='.*'>/g)[0];
            text = locText.match(/(?<=<u>).*?(?=<\/u>)/g)[0];
            tf.text = text != null ? text : locText;
            tf.htmlText = locText;
         }
         else
         {
            tf.text = locText;
         }
         var updateDueToSingleWordWrapping:Boolean = tf.multiline && locText.split(/\s/g).length < 2;
         if(updateDueToSingleWordWrapping)
         {
            tf.multiline = false;
            tf.wordWrap = false;
         }
         var format:TextFormat = tf.getTextFormat();
         if(tf.text.charAt(0) == "#" || tf.name == "text01_chatHistory")
         {
            adjustYLocation = false;
         }
         if(adjustYLocation)
         {
            if(tf.borderColor != 0 && !tf.border)
            {
               if(tf.borderColor > 16711680)
               {
                  tf.y = 0 - ((2147483647 - tf.borderColor & 0xFFFF) + 1);
               }
               else
               {
                  tf.y = tf.borderColor;
               }
               if(tf.y == 1)
               {
                  tf.y = 0;
               }
            }
            originalYLocation = tf.y;
            tf.borderColor = originalYLocation != 0 ? uint(originalYLocation) : uint(originalYLocation + 1);
         }
         if(tf.backgroundColor != 16777215)
         {
            format.size = tf.backgroundColor;
         }
         else if(format.size != null)
         {
            tf.backgroundColor = uint(format.size);
         }
         tf.setTextFormat(format);
         var previousRotation:Number = tf.rotation;
         if(previousRotation != 0)
         {
            tf.rotation = 0;
         }
         var multiLineTF:TextField = tf.parent[tf.name + "Multiline"];
         var resizeDueToBrokenWord:Boolean = hasBrokenWord(tf,locText);
         if(adjustYLocation && (tf.textWidth >= tf.width - 4 && tf.maxScrollV <= tf.scrollV || tf.textHeight > tf.height - 4 || resizeDueToBrokenWord))
         {
            originalTextHeight = tf.textHeight;
            originalSize = int(format.size);
            if(!tf.multiline)
            {
               if(Boolean(multiLineTF))
               {
                  smallestSizeIfMultilineAvail = originalSize * 0.8;
               }
               while(int(format.size) > 5 && tf.textWidth > tf.width - 4)
               {
                  format.size = int(format.size) - 1;
                  tf.setTextFormat(format);
                  if(Boolean(multiLineTF) && int(format.size) < smallestSizeIfMultilineAvail)
                  {
                     updateToFit(multiLineTF,locText,setHtmlText,adjustYLocation);
                     tf.visible = false;
                     return;
                  }
               }
            }
            else if(tf.multiline)
            {
               locText = locText.replace(/\r\n|\r/gm,"\n");
               while(int(format.size) > 5 && (tf.textWidth > tf.width || tf.textHeight > tf.height - 4 || sizingTf != null && sizingTf.numLines > 1 && !isLastLetterAReturn(sizingTf.text) || resizeDueToBrokenWord))
               {
                  myFullText = locText;
                  adjustedLines = [];
                  currLine = 0;
                  lastStopIndex = 0;
                  lastEndOfWordIndex = 0;
                  lastWordIndexThisLine = 0;
                  sizingTf = new TextField();
                  sizingTf.defaultTextFormat = tf.defaultTextFormat;
                  sizingTf.width = tf.width;
                  sizingTf.height = tf.height;
                  sizingTf.setTextFormat(format);
                  sizingTf.antiAliasType = tf.antiAliasType;
                  sizingTf.embedFonts = tf.embedFonts;
                  sizingTf.gridFitType = tf.gridFitType;
                  sizingTf.maxChars = tf.maxChars;
                  sizingTf.wordWrap = tf.wordWrap;
                  sizingTf.multiline = tf.multiline;
                  for(i = 0; i < myFullText.length; i++)
                  {
                     currChar = myFullText.charAt(i);
                     if(i + 1 == myFullText.length)
                     {
                        sizingTf.appendText(currChar);
                        sizingTf.setTextFormat(format);
                        adjustedLines[currLine] = sizingTf.text;
                     }
                     else if(sizingTf.textWidth > sizingTf.width || sizingTf.textHeight > sizingTf.height - 4 || sizingTf.numLines > 1 && !isLastLetterAReturn(sizingTf.text))
                     {
                        if(currChar == " " || currChar == "\n" || currChar == "\r")
                        {
                           sizingTf.appendText(currChar);
                           adjustedLines[currLine] = sizingTf.text;
                           lastStopIndex = i + 1;
                           lastEndOfWordIndex = lastStopIndex;
                           currLine++;
                           sizingTf.text = "";
                           sizingTf.setTextFormat(format);
                        }
                        else
                        {
                           if(lastStopIndex == lastEndOfWordIndex)
                           {
                              break;
                           }
                           currString = sizingTf.text.substring(0,lastWordIndexThisLine);
                           if(shouldAddSpace(currString))
                           {
                              adjustedLines[currLine] = currString + " ";
                           }
                           else
                           {
                              adjustedLines[currLine] = currString;
                           }
                           lastStopIndex = lastEndOfWordIndex;
                           currLine++;
                           sizingTf.text = "";
                           sizingTf.setTextFormat(format);
                           i = lastEndOfWordIndex - 1;
                        }
                     }
                     else if(currChar == " ")
                     {
                        sizingTf.appendText(currChar);
                        lastEndOfWordIndex = i + 1;
                        lastWordIndexThisLine = sizingTf.length;
                        sizingTf.setTextFormat(format);
                     }
                     else if(currChar == "\n" || currChar == "\r")
                     {
                        previousChar = myFullText.charAt(i - 1);
                        if(i == 0 || previousChar == "." || previousChar == "!" || previousChar == "?" || previousChar == "\n" || previousChar == "\r")
                        {
                           sizingTf.appendText(currChar);
                           sizingTf.setTextFormat(format);
                        }
                        else
                        {
                           sizingTf.appendText(" ");
                           sizingTf.setTextFormat(format);
                        }
                        lastEndOfWordIndex = i + 1;
                        lastWordIndexThisLine = sizingTf.length;
                     }
                     else
                     {
                        sizingTf.appendText(currChar);
                        sizingTf.setTextFormat(format);
                     }
                  }
                  if(i == myFullText.length)
                  {
                     if(setHtmlText)
                     {
                        tf.text = adjustedLines.join("");
                        tf.htmlText = url + "<u>" + adjustedLines.join("") + "</u></a>";
                     }
                     else
                     {
                        tf.text = adjustedLines.join("");
                     }
                  }
                  format.size = int(format.size) - 1;
                  tf.setTextFormat(format);
                  resizeDueToBrokenWord = hasBrokenWord(tf,locText);
               }
            }
            tf.sharpness = int(format.size);
            if(previousRotation != 0)
            {
               tf.rotation = previousRotation;
            }
            if(!tf.multiline && adjustYLocation)
            {
               if(tf.rotation == 0)
               {
                  tf.y += (originalTextHeight - tf.textHeight) * 0.5;
               }
               else
               {
                  savedRotation = tf.rotation;
                  tf.rotation = 0;
                  tf.y += Math.round((originalTextHeight - tf.textHeight) * 0.5);
                  tf.rotation = savedRotation;
               }
            }
         }
         if(Boolean(multiLineTF) && tf.name != multiLineTF.name)
         {
            multiLineTF.visible = false;
         }
         if(updateDueToSingleWordWrapping)
         {
            tf.multiline = true;
            tf.wordWrap = true;
         }
         if(tf.multiline && adjustYLocation)
         {
            if(tf.parent.scaleY != 1)
            {
               parentHeight = tf.parent.height / tf.parent.scaleY;
            }
            else
            {
               parentHeight = tf.parent.height;
            }
            if(tf.y < 0)
            {
               tfY = tf.y + parentHeight * 0.5;
            }
            else
            {
               tfY = tf.y;
            }
            amountToChange = (tf.height - tf.textHeight) * 0.5;
            if(tfY + tf.textHeight + amountToChange > parentHeight)
            {
               tf.y += parentHeight - (tfY + tf.textHeight);
            }
            else
            {
               tf.y += amountToChange;
            }
         }
         if(previousRotation != 0)
         {
            tf.rotation = previousRotation;
         }
      }
      
      private static function hasBrokenWord(tf:TextField, str:String) : Boolean
      {
         var lcChar:String = null;
         var char:String = null;
         var lineIndex:Number = NaN;
         var liIndex:Number = 0;
         for(var ci:int = 0; ci < str.length; ci++)
         {
            char = str.charAt(ci);
            lineIndex = tf.getLineIndexOfChar(ci);
            if(lineIndex != liIndex)
            {
               if(lcChar != " " && lcChar != "\r" && lcChar != "\n" && lcChar != "\r\n")
               {
                  return true;
               }
            }
            liIndex = lineIndex;
            lcChar = char;
         }
         return false;
      }
      
      private static function isLastLetterAReturn(txt:String) : Boolean
      {
         var lastLetter:String = txt.substr(-1);
         if(lastLetter == "\n" || lastLetter == "\r")
         {
            return true;
         }
         return false;
      }
      
      private static function shouldAddSpace(txt:String) : Boolean
      {
         var lastLetter:String = txt.substr(-1);
         if(lastLetter == " " || lastLetter == "\n" || lastLetter == "\r")
         {
            return false;
         }
         return true;
      }
      
      private static function translateLocalizedIdAndUpdateSize(tf:TextField) : void
      {
         var localizedTextObj:Object = translateLocalizedId(tf.text);
         if(tf.text != localizedTextObj.text || tf.sharpness != -1 && tf.sharpness != tf.defaultTextFormat.size)
         {
            if(Boolean(localizedTextObj.isHtml))
            {
               updateToFit(tf,"<a " + localizedTextObj.htmlRefText + "><u>" + localizedTextObj.text + "</u></a>",true);
            }
            else
            {
               updateToFit(tf,localizedTextObj.text,false);
            }
         }
      }
      
      private static function translateLocalizedId(id:String) : Object
      {
         var split:Array = null;
         var text:String = null;
         if(Boolean(_staticLocalizations))
         {
            split = id.split("#");
            if(split.length > 1)
            {
               text = _staticLocalizations[int(removeCarriageReturn(split[1]))] as String;
               if(text != null && text != "")
               {
                  if(split.length == 3)
                  {
                     return {
                        "text":text,
                        "isHtml":true,
                        "htmlRefText":split[2]
                     };
                  }
                  return {
                     "text":text,
                     "isHtml":false
                  };
               }
               return {
                  "text":id,
                  "isHtml":false
               };
            }
            return {
               "text":removeCarriageReturn(id),
               "isHtml":false
            };
         }
         return {
            "text":removeCarriageReturn(id),
            "isHtml":false
         };
      }
      
      private static function removeCarriageReturn(str:String) : String
      {
         var carriageReturn:String = str.charAt(str.length - 1);
         if(carriageReturn == "\r" || carriageReturn == "\n" || carriageReturn == "\r\n")
         {
            return str.substr(0,str.length - 1);
         }
         return str;
      }
      
      public static function findAllTextfields(root:Object) : void
      {
         var i:int = 0;
         var child:Object = null;
         if(root is TextField)
         {
            translateLocalizedIdAndUpdateSize(TextField(root));
            return;
         }
         if(root.hasOwnProperty("numChildren"))
         {
            for(i = 0; i < root.numChildren; i++)
            {
               child = root.getChildAt(i);
               if(Boolean(child))
               {
                  if(child is TextField)
                  {
                     translateLocalizedIdAndUpdateSize(TextField(child));
                  }
                  if(child.name == "bakedLogo")
                  {
                     child.gotoAndStop(currentLanguage + 1);
                  }
                  if(child.hasOwnProperty("numChildren") && child.numChildren > 0)
                  {
                     findAllTextfields(child);
                  }
               }
            }
         }
      }
      
      public static function translateAvatarName(avNameByIds:String) : String
      {
         var firstPartOfName:Array = null;
         var secondPartOfName:Array = null;
         var lastPartOfName:String = null;
         var splitName:Array = avNameByIds.split("|");
         if(splitName.length > 1)
         {
            if(isCurrLanguageReversed())
            {
               firstPartOfName = LocalizationManager.translateIdOnly(splitName[2]).split("$");
               secondPartOfName = LocalizationManager.translateIdOnly(splitName[1]).split("$");
               if(firstPartOfName.length == 1 || firstPartOfName[1] == "m")
               {
                  lastPartOfName = secondPartOfName[0].toLowerCase();
               }
               else if(secondPartOfName.length == 1)
               {
                  lastPartOfName = secondPartOfName[0].toLowerCase();
               }
               else
               {
                  lastPartOfName = secondPartOfName[1].toLowerCase();
               }
               return translateIdOnly(splitName[0]) + " " + firstPartOfName[0] + lastPartOfName;
            }
            return translateIdOnly(splitName[0]) + " " + translateIdOnly(splitName[1]) + translateIdOnly(splitName[2]).toLowerCase();
         }
         return avNameByIds;
      }
      
      public static function translatePetName(petNameByIds:String) : String
      {
         var firstPartOfName:Array = null;
         var secondPartOfName:Array = null;
         var lastPartOfName:String = null;
         var splitName:Array = petNameByIds.split("|");
         if(splitName.length > 1)
         {
            if(isCurrLanguageReversed())
            {
               firstPartOfName = LocalizationManager.translateIdOnly(splitName[1]).split("$");
               secondPartOfName = LocalizationManager.translateIdOnly(splitName[0]).split("$");
               if(firstPartOfName.length == 1 || firstPartOfName[1] == "m")
               {
                  lastPartOfName = secondPartOfName[0].toLowerCase();
               }
               else if(secondPartOfName.length == 1)
               {
                  lastPartOfName = secondPartOfName[0].toLowerCase();
               }
               else
               {
                  lastPartOfName = secondPartOfName[1].toLowerCase();
               }
               return firstPartOfName[0] + lastPartOfName;
            }
            return translateIdOnly(splitName[0]) + translateIdOnly(splitName[1]).toLowerCase();
         }
         return petNameByIds;
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

