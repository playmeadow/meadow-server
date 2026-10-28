package org.osmf.captioning.parsers
{
   import flash.utils.Dictionary;
   import org.osmf.captioning.model.Caption;
   import org.osmf.captioning.model.CaptionFormat;
   import org.osmf.captioning.model.CaptionStyle;
   import org.osmf.captioning.model.CaptioningDocument;
   import org.osmf.utils.TimeUtil;
   
   public class DFXPParser implements ICaptioningParser
   {
      
      private var ns:Namespace;
      
      private var ttm:Namespace;
      
      private var tts:Namespace;
      
      private var rootNamespace:Namespace;
      
      private var namedColorMap:Dictionary;
      
      public function DFXPParser()
      {
         super();
         this.namedColorMap = new Dictionary();
         this.namedColorMap["transparent"] = 0;
         this.namedColorMap["black"] = 0;
         this.namedColorMap["silver"] = 12632256;
         this.namedColorMap["gray"] = 8421504;
         this.namedColorMap["white"] = 16777215;
         this.namedColorMap["maroon"] = 8388608;
         this.namedColorMap["red"] = 16711680;
         this.namedColorMap["purple"] = 8388736;
         this.namedColorMap["fuchsia"] = 16711935;
         this.namedColorMap["magenta"] = 16711935;
         this.namedColorMap["green"] = 32768;
         this.namedColorMap["lime"] = 65280;
         this.namedColorMap["olive"] = 8421376;
         this.namedColorMap["yellow"] = 16776960;
         this.namedColorMap["navy"] = 128;
         this.namedColorMap["blue"] = 255;
         this.namedColorMap["teal"] = 32896;
         this.namedColorMap["aqua"] = 65535;
         this.namedColorMap["cyan"] = 65535;
      }
      
      public function parse(rawData:String) : CaptioningDocument
      {
         var xml:XML = null;
         var document:CaptioningDocument = new CaptioningDocument();
         var saveXMLIgnoreWhitespace:Boolean = Boolean(XML.ignoreWhitespace);
         var saveXMLPrettyPrinting:Boolean = Boolean(XML.prettyPrinting);
         var xmlStr:String = rawData.replace(/\s+$/,"");
         xmlStr = xmlStr.replace(/>\s+</g,"><");
         XML.ignoreWhitespace = false;
         XML.prettyPrinting = false;
         try
         {
            xml = new XML(xmlStr);
         }
         catch(e:Error)
         {
            debugLog("Unhandled exception in DFXPParser : " + e.message);
            throw e;
         }
         finally
         {
            XML.ignoreWhitespace = saveXMLIgnoreWhitespace;
            XML.prettyPrinting = saveXMLPrettyPrinting;
         }
         this.rootNamespace = xml.namespace();
         this.ns = xml.namespace();
         this.ttm = xml.namespace("ttm");
         this.tts = xml.namespace("tts");
         try
         {
            this.parseHead(document,xml);
            this.parseBody(document,xml);
         }
         catch(err:Error)
         {
            debugLog("Unhandled exception in DFXPParser : " + err.message);
            throw err;
         }
         return document;
      }
      
      private function parseHead(doc:CaptioningDocument, xml:XML) : void
      {
         var styling:XMLList;
         var styles:XMLList = null;
         var i:uint = 0;
         var styleNode:XML = null;
         var styleObj:CaptionStyle = null;
         try
         {
            doc.title = xml..this.ttm::title.text();
            doc.description = xml..this.ttm::desc.text();
            doc.copyright = xml..this.ttm::copyright.text();
         }
         catch(err:Error)
         {
            if(err.errorID != 1080)
            {
               throw err;
            }
         }
         styling = xml..this.ns::styling;
         if(Boolean(styling.length()))
         {
            styles = styling.children();
            for(i = 0; i < styles.length(); i++)
            {
               styleNode = styles[i];
               styleObj = this.createStyleObject(styleNode);
               doc.addStyle(styleObj);
            }
         }
      }
      
      private function createStyleObject(styleNode:XML) : CaptionStyle
      {
         var colorValue:Object = null;
         var id:String = styleNode.@id;
         var styleObj:CaptionStyle = new CaptionStyle(id);
         var color:String = styleNode.this.tts::@backgroundColor;
         if(color != "")
         {
            colorValue = this.parseColor(color);
            styleObj.backgroundColor = colorValue.color;
            styleObj.backgroundColorAlpha = colorValue.alpha;
         }
         styleObj.textAlign = styleNode.this.tts::@textAlign;
         color = styleNode.this.tts::@color;
         if(color != "")
         {
            colorValue = this.parseColor(color);
            styleObj.textColor = colorValue.color;
            styleObj.textColorAlpha = colorValue.alpha;
         }
         styleObj.fontFamily = this.parseFontFamily(styleNode.this.tts::@fontFamily);
         var fontSize:String = this.parseFontSize(styleNode.this.tts::@fontSize);
         styleObj.fontSize = parseInt(fontSize);
         styleObj.fontStyle = styleNode.this.tts::@fontStyle;
         styleObj.fontWeight = styleNode.this.tts::@fontWeight;
         styleObj.wrapOption = String(styleNode.this.tts::@wrapOption).toLowerCase() == "nowrap" ? false : true;
         return styleObj;
      }
      
      private function parseColor(colorStr:String) : Object
      {
         var colorValue:Object = null;
         var alphaValue:Object = null;
         var pattern:RegExp = /^\s*#([\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f])([\dA-Fa-f][\dA-Fa-f])?\s*$/;
         var result:Array = colorStr.match(pattern);
         if(result != null)
         {
            colorValue = parseInt(result[1],16);
            if(result.length == 3)
            {
               alphaValue = Number(parseInt(result[2]) / 255);
            }
         }
         else
         {
            pattern = /^\s*rgb(a)?\((\d+),(\d+),(\d+)(\)|(,(\d+)\)))\s*$/i;
            result = colorStr.match(pattern);
            if(result != null && result.length >= 5)
            {
               colorValue = (parseInt(result[2]) << 16) + (parseInt(result[3]) << 8) + parseInt(result[4]);
               if(result.length == 8 && result[7] != undefined)
               {
                  alphaValue = Number(parseInt(result[7]) / 255);
               }
            }
            else
            {
               colorValue = this.namedColorMap[colorStr.toLowerCase()];
               if(colorValue == null)
               {
                  colorValue = parseInt(colorStr);
                  if(isNaN(int(colorValue)))
                  {
                     colorValue = null;
                     this.debugLog("Invalid DFXP document: invalid color value of " + colorStr);
                  }
               }
            }
         }
         return {
            "color":colorValue,
            "alpha":alphaValue
         };
      }
      
      private function parseFontSize(rawFontSize:String) : String
      {
         var incRegExp:RegExp = null;
         var incResult:Object = null;
         var regExp:RegExp = null;
         var result:Object = null;
         if(!rawFontSize || rawFontSize == "")
         {
            return "";
         }
         var returnValue:String = "";
         var perRegExp:RegExp = new RegExp(/^\s*\d+%.*$/);
         var perResult:Object = perRegExp.exec(rawFontSize);
         if(Boolean(perResult))
         {
            this.debugLog("Invalid DFXP document: percentages are not supported for font size.");
            returnValue = "";
         }
         else
         {
            incRegExp = new RegExp(/^\s*[\+\-]\d.*/);
            incResult = incRegExp.exec(rawFontSize);
            if(Boolean(incResult))
            {
               this.debugLog("Invalid DFXP document: increment values are not supported for font size.");
               returnValue = "";
            }
            else
            {
               regExp = new RegExp(/^\s*(\d+).*$/);
               result = regExp.exec(rawFontSize);
               if(Boolean(result) && result[1] != undefined)
               {
                  returnValue = result[1];
               }
            }
         }
         return returnValue;
      }
      
      private function parseFontFamily(rawFontFamily:String) : String
      {
         var result:Object = null;
         if(!rawFontFamily || rawFontFamily == "")
         {
            return "";
         }
         var retVal:String = "";
         var regExp:RegExp = new RegExp(/^\s*([^,\s]+)\s*((,\s*([^,\s]+)\s*)*)$/);
         var done:Boolean = false;
         do
         {
            result = regExp.exec(rawFontFamily);
            if(!result)
            {
               done = true;
            }
            else
            {
               if(retVal.length > 0)
               {
                  retVal += ",";
               }
               switch(result[1])
               {
                  case "default":
                  case "serif":
                  case "proportionalSerif":
                     retVal += "_serif";
                     break;
                  case "monospace":
                  case "monospaceSansSerif":
                  case "monospaceSerif":
                     retVal += "_typewriter";
                     break;
                  case "sansSerif":
                  case "proportionalSansSerif":
                     retVal += "_sans";
                     break;
                  default:
                     retVal += result[1];
               }
               if(result[2] != undefined && result[2] != "")
               {
                  rawFontFamily = result[2].slice(1);
               }
               else
               {
                  done = true;
               }
            }
         }
         while(!done);
         return retVal;
      }
      
      private function parseBody(doc:CaptioningDocument, xml:XML) : void
      {
         var div:XMLList = null;
         var p:XMLList = null;
         var i:uint = 0;
         var pNode:XML = null;
         var body:XMLList = xml..this.ns::body;
         if(body.length() <= 0)
         {
            this.debugLog("Invalid DFXP document: <body> tag is required.");
         }
         else
         {
            div = xml..this.ns::div;
            p = Boolean(div.length()) ? div.children() : (Boolean(body.length()) ? body.children() : new XMLList());
            for(i = 0; i < p.length(); i++)
            {
               pNode = p[i];
               if(this.rootNamespace == pNode.namespace())
               {
                  this.parsePTag(doc,pNode,i);
               }
               else
               {
                  this.debugLog("Ignoring this tag, foreign namespaces not supported: \"" + pNode + "\"");
               }
            }
         }
      }
      
      private function parsePTag(doc:CaptioningDocument, pNode:XML, index:uint) : void
      {
         var text:String = null;
         var child:XML = null;
         var styleStartIndex:uint = 0;
         var spanText:String = null;
         var stylesList:Array = null;
         var styleEndIndex:uint = 0;
         var styleObject:CaptionStyle = null;
         var fmtObj:CaptionFormat = null;
         var formatObj:CaptionFormat = null;
         var begin:String = pNode.@begin;
         var end:String = pNode.@end;
         var dur:String = pNode.@dur;
         if(begin == "")
         {
            begin = "0s";
         }
         var beginSecs:Number = TimeUtil.parseTime(begin);
         var endSecs:Number = 0;
         if(end != "")
         {
            endSecs = TimeUtil.parseTime(end);
         }
         else if(dur != "")
         {
            endSecs = beginSecs + TimeUtil.parseTime(dur);
         }
         var captionFormatList:Array = new Array();
         text = new String("<p>");
         var children:XMLList = pNode.children();
         for(var i:uint = 0; i < children.length(); i++)
         {
            child = children[i];
            switch(child.nodeKind())
            {
               case "text":
                  text += this.formatCCText(child.toString());
                  break;
               case "element":
                  switch(child.localName())
                  {
                     case "set":
                     case "metadata":
                        break;
                     case "span":
                        styleStartIndex = uint(this.calcClearTextLength(text));
                        stylesList = new Array();
                        text += this.parseSpanTag(doc,child,stylesList);
                        styleEndIndex = uint(this.calcClearTextLength(text));
                        for each(styleObject in stylesList)
                        {
                           fmtObj = new CaptionFormat(styleObject,styleStartIndex,styleEndIndex);
                           captionFormatList.push(fmtObj);
                        }
                        break;
                     case "br":
                        text += "<br />";
                        break;
                     default:
                        text += this.formatCCText(child.toString());
                  }
            }
         }
         text += "</p>";
         var captionItem:Caption = new Caption(index,beginSecs,endSecs,text);
         var styleObj:CaptionStyle = this.parseStyleAttrib(doc,pNode);
         if(Boolean(styleObj))
         {
            formatObj = new CaptionFormat(styleObj);
            captionItem.addCaptionFormat(formatObj);
         }
         for(i = 0; i < captionFormatList.length; i++)
         {
            captionItem.addCaptionFormat(captionFormatList[i]);
         }
         doc.addCaption(captionItem);
      }
      
      private function parseStyleAttrib(doc:CaptioningDocument, node:XML) : CaptionStyle
      {
         var i:uint = 0;
         var attributes:XMLList = null;
         var attrib:XML = null;
         var localName:String = null;
         var styleId:String = node.@style;
         var captionStyle:CaptionStyle = null;
         if(styleId != "")
         {
            while(i < doc.numStyles)
            {
               if(doc.getStyleAt(i).id == styleId)
               {
                  captionStyle = doc.getStyleAt(i);
               }
               i++;
            }
         }
         else
         {
            try
            {
               attributes = node.this.tts::@*;
            }
            catch(err:Error)
            {
               if(err.errorID != 1080)
               {
                  throw err;
               }
            }
            i = 0;
            while(attributes != null && i < attributes.length())
            {
               attrib = attributes[i];
               localName = attrib.localName();
               if(localName != "inherit")
               {
                  captionStyle = this.createStyleObject(node);
               }
               i++;
            }
         }
         return captionStyle;
      }
      
      private function parseSpanTag(doc:CaptioningDocument, spanNode:XML, styles:Array) : String
      {
         var child:XML = null;
         var styleObj:CaptionStyle = this.parseStyleAttrib(doc,spanNode);
         if(styleObj != null)
         {
            styles.push(styleObj);
         }
         var ccText:String = new String();
         var children:XMLList = spanNode.children();
         for(var i:uint = 0; i < children.length(); i++)
         {
            child = children[i];
            switch(child.nodeKind())
            {
               case "text":
                  ccText += this.formatCCText(child.toString());
                  break;
               case "element":
                  switch(child.localName())
                  {
                     case "set":
                     case "metadata":
                        break;
                     case "br":
                        ccText += "<br/>";
                        break;
                     default:
                        ccText += child.toString();
                  }
            }
         }
         return ccText;
      }
      
      private function formatCCText(txt:String) : String
      {
         return txt.replace(/\s+/g," ");
      }
      
      private function calcClearTextLength(txt:String) : int
      {
         var clrTxt:String = txt.replace(/<(.|\n)*?>/g,"");
         return clrTxt.length;
      }
      
      private function debugLog(msg:String) : void
      {
      }
   }
}

