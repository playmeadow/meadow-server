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
      
      public function parse(param1:String) : CaptioningDocument
      {
         var xml:XML = null;
         var rawData:String = param1;
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
      
      private function parseHead(param1:CaptioningDocument, param2:XML) : void
      {
         var styling:XMLList;
         var styles:XMLList = null;
         var i:uint = 0;
         var styleNode:XML = null;
         var styleObj:CaptionStyle = null;
         var doc:CaptioningDocument = param1;
         var xml:XML = param2;
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
         if(styling.length())
         {
            styles = styling.children();
            i = 0;
            while(i < styles.length())
            {
               styleNode = styles[i];
               styleObj = this.createStyleObject(styleNode);
               doc.addStyle(styleObj);
               i++;
            }
         }
      }
      
      private function createStyleObject(param1:XML) : CaptionStyle
      {
         var _loc4_:Object = null;
         var _loc2_:String = param1.@id;
         var _loc3_:CaptionStyle = new CaptionStyle(_loc2_);
         var _loc5_:String = param1.this.tts::@backgroundColor;
         if(_loc5_ != "")
         {
            _loc4_ = this.parseColor(_loc5_);
            _loc3_.backgroundColor = _loc4_.color;
            _loc3_.backgroundColorAlpha = _loc4_.alpha;
         }
         _loc3_.textAlign = param1.this.tts::@textAlign;
         _loc5_ = param1.this.tts::@color;
         if(_loc5_ != "")
         {
            _loc4_ = this.parseColor(_loc5_);
            _loc3_.textColor = _loc4_.color;
            _loc3_.textColorAlpha = _loc4_.alpha;
         }
         _loc3_.fontFamily = this.parseFontFamily(param1.this.tts::@fontFamily);
         var _loc6_:String = this.parseFontSize(param1.this.tts::@fontSize);
         _loc3_.fontSize = parseInt(_loc6_);
         _loc3_.fontStyle = param1.this.tts::@fontStyle;
         _loc3_.fontWeight = param1.this.tts::@fontWeight;
         _loc3_.wrapOption = String(param1.this.tts::@wrapOption).toLowerCase() == "nowrap" ? false : true;
         return _loc3_;
      }
      
      private function parseColor(param1:String) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:RegExp = /^\s*#([\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f])([\dA-Fa-f][\dA-Fa-f])?\s*$/;
         var _loc5_:Array = param1.match(_loc4_);
         if(_loc5_ != null)
         {
            _loc2_ = parseInt(_loc5_[1],16);
            if(_loc5_.length == 3)
            {
               _loc3_ = Number(parseInt(_loc5_[2]) / 255);
            }
         }
         else
         {
            _loc4_ = /^\s*rgb(a)?\((\d+),(\d+),(\d+)(\)|(,(\d+)\)))\s*$/i;
            _loc5_ = param1.match(_loc4_);
            if(_loc5_ != null && _loc5_.length >= 5)
            {
               _loc2_ = (parseInt(_loc5_[2]) << 16) + (parseInt(_loc5_[3]) << 8) + parseInt(_loc5_[4]);
               if(_loc5_.length == 8 && _loc5_[7] != undefined)
               {
                  _loc3_ = Number(parseInt(_loc5_[7]) / 255);
               }
            }
            else
            {
               _loc2_ = this.namedColorMap[param1.toLowerCase()];
               if(_loc2_ == null)
               {
                  _loc2_ = parseInt(param1);
                  if(isNaN(int(_loc2_)))
                  {
                     _loc2_ = null;
                     this.debugLog("Invalid DFXP document: invalid color value of " + param1);
                  }
               }
            }
         }
         return {
            "color":_loc2_,
            "alpha":_loc3_
         };
      }
      
      private function parseFontSize(param1:String) : String
      {
         var _loc5_:RegExp = null;
         var _loc6_:Object = null;
         var _loc7_:RegExp = null;
         var _loc8_:Object = null;
         if(!param1 || param1 == "")
         {
            return "";
         }
         var _loc2_:String = "";
         var _loc3_:RegExp = new RegExp(/^\s*\d+%.*$/);
         var _loc4_:Object = _loc3_.exec(param1);
         if(_loc4_)
         {
            this.debugLog("Invalid DFXP document: percentages are not supported for font size.");
            _loc2_ = "";
         }
         else
         {
            _loc5_ = new RegExp(/^\s*[\+\-]\d.*/);
            _loc6_ = _loc5_.exec(param1);
            if(_loc6_)
            {
               this.debugLog("Invalid DFXP document: increment values are not supported for font size.");
               _loc2_ = "";
            }
            else
            {
               _loc7_ = new RegExp(/^\s*(\d+).*$/);
               _loc8_ = _loc7_.exec(param1);
               if((Boolean(_loc8_)) && _loc8_[1] != undefined)
               {
                  _loc2_ = _loc8_[1];
               }
            }
         }
         return _loc2_;
      }
      
      private function parseFontFamily(param1:String) : String
      {
         var _loc5_:Object = null;
         if(!param1 || param1 == "")
         {
            return "";
         }
         var _loc2_:String = "";
         var _loc3_:RegExp = new RegExp(/^\s*([^,\s]+)\s*((,\s*([^,\s]+)\s*)*)$/);
         var _loc4_:Boolean = false;
         do
         {
            _loc5_ = _loc3_.exec(param1);
            if(!_loc5_)
            {
               _loc4_ = true;
            }
            else
            {
               if(_loc2_.length > 0)
               {
                  _loc2_ += ",";
               }
               switch(_loc5_[1])
               {
                  case "default":
                  case "serif":
                  case "proportionalSerif":
                     _loc2_ += "_serif";
                     break;
                  case "monospace":
                  case "monospaceSansSerif":
                  case "monospaceSerif":
                     _loc2_ += "_typewriter";
                     break;
                  case "sansSerif":
                  case "proportionalSansSerif":
                     _loc2_ += "_sans";
                     break;
                  default:
                     _loc2_ += _loc5_[1];
               }
               if(_loc5_[2] != undefined && _loc5_[2] != "")
               {
                  param1 = _loc5_[2].slice(1);
               }
               else
               {
                  _loc4_ = true;
               }
            }
         }
         while(!_loc4_);
         return _loc2_;
      }
      
      private function parseBody(param1:CaptioningDocument, param2:XML) : void
      {
         var _loc4_:XMLList = null;
         var _loc5_:XMLList = null;
         var _loc6_:uint = 0;
         var _loc7_:XML = null;
         var _loc3_:XMLList = param2..this.ns::body;
         if(_loc3_.length() <= 0)
         {
            this.debugLog("Invalid DFXP document: <body> tag is required.");
         }
         else
         {
            _loc4_ = param2..this.ns::div;
            _loc5_ = _loc4_.length() ? _loc4_.children() : (_loc3_.length() ? _loc3_.children() : new XMLList());
            _loc6_ = 0;
            while(_loc6_ < _loc5_.length())
            {
               _loc7_ = _loc5_[_loc6_];
               if(this.rootNamespace == _loc7_.namespace())
               {
                  this.parsePTag(param1,_loc7_,_loc6_);
               }
               else
               {
                  this.debugLog("Ignoring this tag, foreign namespaces not supported: \"" + _loc7_ + "\"");
               }
               _loc6_++;
            }
         }
      }
      
      private function parsePTag(param1:CaptioningDocument, param2:XML, param3:uint) : void
      {
         var _loc10_:String = null;
         var _loc15_:XML = null;
         var _loc16_:uint = 0;
         var _loc17_:String = null;
         var _loc18_:Array = null;
         var _loc19_:uint = 0;
         var _loc20_:CaptionStyle = null;
         var _loc21_:CaptionFormat = null;
         var _loc22_:CaptionFormat = null;
         var _loc4_:String = param2.@begin;
         var _loc5_:String = param2.@end;
         var _loc6_:String = param2.@dur;
         if(_loc4_ == "")
         {
            _loc4_ = "0s";
         }
         var _loc7_:Number = TimeUtil.parseTime(_loc4_);
         var _loc8_:Number = 0;
         if(_loc5_ != "")
         {
            _loc8_ = TimeUtil.parseTime(_loc5_);
         }
         else if(_loc6_ != "")
         {
            _loc8_ = _loc7_ + TimeUtil.parseTime(_loc6_);
         }
         var _loc9_:Array = new Array();
         _loc10_ = new String("<p>");
         var _loc11_:XMLList = param2.children();
         var _loc12_:uint = 0;
         while(_loc12_ < _loc11_.length())
         {
            _loc15_ = _loc11_[_loc12_];
            switch(_loc15_.nodeKind())
            {
               case "text":
                  _loc10_ += this.formatCCText(_loc15_.toString());
                  break;
               case "element":
                  switch(_loc15_.localName())
                  {
                     case "set":
                     case "metadata":
                        break;
                     case "span":
                        _loc16_ = uint(this.calcClearTextLength(_loc10_));
                        _loc18_ = new Array();
                        _loc10_ += this.parseSpanTag(param1,_loc15_,_loc18_);
                        _loc19_ = uint(this.calcClearTextLength(_loc10_));
                        for each(_loc20_ in _loc18_)
                        {
                           _loc21_ = new CaptionFormat(_loc20_,_loc16_,_loc19_);
                           _loc9_.push(_loc21_);
                        }
                        break;
                     case "br":
                        _loc10_ += "<br />";
                        break;
                     default:
                        _loc10_ += this.formatCCText(_loc15_.toString());
                  }
            }
            _loc12_++;
         }
         _loc10_ += "</p>";
         var _loc13_:Caption = new Caption(param3,_loc7_,_loc8_,_loc10_);
         var _loc14_:CaptionStyle = this.parseStyleAttrib(param1,param2);
         if(_loc14_)
         {
            _loc22_ = new CaptionFormat(_loc14_);
            _loc13_.addCaptionFormat(_loc22_);
         }
         _loc12_ = 0;
         while(_loc12_ < _loc9_.length)
         {
            _loc13_.addCaptionFormat(_loc9_[_loc12_]);
            _loc12_++;
         }
         param1.addCaption(_loc13_);
      }
      
      private function parseStyleAttrib(param1:CaptioningDocument, param2:XML) : CaptionStyle
      {
         var i:uint = 0;
         var attributes:XMLList = null;
         var attrib:XML = null;
         var localName:String = null;
         var doc:CaptioningDocument = param1;
         var node:XML = param2;
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
      
      private function parseSpanTag(param1:CaptioningDocument, param2:XML, param3:Array) : String
      {
         var _loc8_:XML = null;
         var _loc4_:CaptionStyle = this.parseStyleAttrib(param1,param2);
         if(_loc4_ != null)
         {
            param3.push(_loc4_);
         }
         var _loc5_:String = new String();
         var _loc6_:XMLList = param2.children();
         var _loc7_:uint = 0;
         while(_loc7_ < _loc6_.length())
         {
            _loc8_ = _loc6_[_loc7_];
            switch(_loc8_.nodeKind())
            {
               case "text":
                  _loc5_ += this.formatCCText(_loc8_.toString());
                  break;
               case "element":
                  switch(_loc8_.localName())
                  {
                     case "set":
                     case "metadata":
                        break;
                     case "br":
                        _loc5_ += "<br/>";
                        break;
                     default:
                        _loc5_ += _loc8_.toString();
                  }
            }
            _loc7_++;
         }
         return _loc5_;
      }
      
      private function formatCCText(param1:String) : String
      {
         return param1.replace(/\s+/g," ");
      }
      
      private function calcClearTextLength(param1:String) : int
      {
         var _loc2_:String = param1.replace(/<(.|\n)*?>/g,"");
         return _loc2_.length;
      }
      
      private function debugLog(param1:String) : void
      {
      }
   }
}

