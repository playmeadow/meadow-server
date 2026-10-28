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
         namedColorMap = new Dictionary();
         namedColorMap["transparent"] = 0;
         namedColorMap["black"] = 0;
         namedColorMap["silver"] = 12632256;
         namedColorMap["gray"] = 8421504;
         namedColorMap["white"] = 16777215;
         namedColorMap["maroon"] = 8388608;
         namedColorMap["red"] = 16711680;
         namedColorMap["purple"] = 8388736;
         namedColorMap["fuchsia"] = 16711935;
         namedColorMap["magenta"] = 16711935;
         namedColorMap["green"] = 32768;
         namedColorMap["lime"] = 65280;
         namedColorMap["olive"] = 8421376;
         namedColorMap["yellow"] = 16776960;
         namedColorMap["navy"] = 128;
         namedColorMap["blue"] = 255;
         namedColorMap["teal"] = 32896;
         namedColorMap["aqua"] = 65535;
         namedColorMap["cyan"] = 65535;
      }
      
      public function parse(param1:String) : CaptioningDocument
      {
         var _loc6_:XML = null;
         var _loc2_:CaptioningDocument = new CaptioningDocument();
         var _loc3_:Boolean = Boolean(XML.ignoreWhitespace);
         var _loc5_:Boolean = Boolean(XML.prettyPrinting);
         var _loc4_:String = param1.replace(/\s+$/,"");
         _loc4_ = _loc4_.replace(/>\s+</g,"><");
         XML.ignoreWhitespace = false;
         XML.prettyPrinting = false;
         try
         {
            _loc6_ = new XML(_loc4_);
         }
         catch(e:Error)
         {
            debugLog("Unhandled exception in DFXPParser : " + e.message);
            throw e;
         }
         finally
         {
            XML.ignoreWhitespace = _loc3_;
            XML.prettyPrinting = _loc5_;
         }
         rootNamespace = _loc6_.namespace();
         ns = _loc6_.namespace();
         ttm = _loc6_.namespace("ttm");
         tts = _loc6_.namespace("tts");
         try
         {
            parseHead(_loc2_,_loc6_);
            parseBody(_loc2_,_loc6_);
         }
         catch(err:Error)
         {
            debugLog("Unhandled exception in DFXPParser : " + err.message);
            throw err;
         }
         return _loc2_;
      }
      
      private function parseHead(param1:CaptioningDocument, param2:XML) : void
      {
         var _loc3_:XMLList = null;
         var _loc7_:* = 0;
         var _loc5_:XML = null;
         var _loc4_:CaptionStyle = null;
         try
         {
            param1.title = param2..ttm::title.text();
            param1.description = param2..ttm::desc.text();
            param1.copyright = param2..ttm::copyright.text();
         }
         catch(err:Error)
         {
            if(err.errorID != 1080)
            {
               throw err;
            }
         }
         var _loc6_:XMLList = param2..ns::styling;
         if(_loc6_.length())
         {
            _loc3_ = _loc6_.children();
            _loc7_ = 0;
            while(_loc7_ < _loc3_.length())
            {
               _loc5_ = _loc3_[_loc7_];
               _loc4_ = createStyleObject(_loc5_);
               param1.addStyle(_loc4_);
               _loc7_++;
            }
         }
      }
      
      private function createStyleObject(param1:XML) : CaptionStyle
      {
         var _loc4_:Object = null;
         var _loc2_:String = param1.@id;
         var _loc6_:CaptionStyle = new CaptionStyle(_loc2_);
         var _loc3_:String = param1.tts::@backgroundColor;
         if(_loc3_ != "")
         {
            _loc4_ = parseColor(_loc3_);
            _loc6_.backgroundColor = _loc4_.color;
            _loc6_.backgroundColorAlpha = _loc4_.alpha;
         }
         _loc6_.textAlign = param1.tts::@textAlign;
         _loc3_ = param1.tts::@color;
         if(_loc3_ != "")
         {
            _loc4_ = parseColor(_loc3_);
            _loc6_.textColor = _loc4_.color;
            _loc6_.textColorAlpha = _loc4_.alpha;
         }
         _loc6_.fontFamily = parseFontFamily(param1.tts::@fontFamily);
         var _loc5_:String = parseFontSize(param1.tts::@fontSize);
         _loc6_.fontSize = parseInt(_loc5_);
         _loc6_.fontStyle = param1.tts::@fontStyle;
         _loc6_.fontWeight = param1.tts::@fontWeight;
         _loc6_.wrapOption = String(param1.tts::@wrapOption).toLowerCase() == "nowrap" ? false : true;
         return _loc6_;
      }
      
      private function parseColor(param1:String) : Object
      {
         var _loc5_:Object = null;
         var _loc4_:Object = null;
         var _loc3_:RegExp = /^\s*#([\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f])([\dA-Fa-f][\dA-Fa-f])?\s*$/;
         var _loc2_:Array = param1.match(_loc3_);
         if(_loc2_ != null)
         {
            _loc5_ = parseInt(_loc2_[1],16);
            if(_loc2_.length == 3)
            {
               _loc4_ = parseInt(_loc2_[2]) / 255;
            }
         }
         else
         {
            _loc3_ = /^\s*rgb(a)?\((\d+),(\d+),(\d+)(\)|(,(\d+)\)))\s*$/i;
            _loc2_ = param1.match(_loc3_);
            if(_loc2_ != null && _loc2_.length >= 5)
            {
               _loc5_ = (parseInt(_loc2_[2]) << 16) + (parseInt(_loc2_[3]) << 8) + parseInt(_loc2_[4]);
               if(_loc2_.length == 8 && _loc2_[7] != undefined)
               {
                  _loc4_ = parseInt(_loc2_[7]) / 255;
               }
            }
            else
            {
               _loc5_ = namedColorMap[param1.toLowerCase()];
               if(_loc5_ == null)
               {
                  _loc5_ = parseInt(param1);
                  if(isNaN(int(_loc5_)))
                  {
                     _loc5_ = null;
                     debugLog("Invalid DFXP document: invalid color value of " + param1);
                  }
               }
            }
         }
         return {
            "color":_loc5_,
            "alpha":_loc4_
         };
      }
      
      private function parseFontSize(param1:String) : String
      {
         var _loc8_:RegExp = null;
         var _loc7_:Object = null;
         var _loc4_:RegExp = null;
         var _loc2_:Object = null;
         if(!param1 || param1 == "")
         {
            return "";
         }
         var _loc6_:String = "";
         var _loc5_:RegExp = new RegExp(/^\s*\d+%.*$/);
         var _loc3_:Object = _loc5_.exec(param1);
         if(_loc3_)
         {
            debugLog("Invalid DFXP document: percentages are not supported for font size.");
            _loc6_ = "";
         }
         else
         {
            _loc8_ = new RegExp(/^\s*[\+\-]\d.*/);
            _loc7_ = _loc8_.exec(param1);
            if(_loc7_)
            {
               debugLog("Invalid DFXP document: increment values are not supported for font size.");
               _loc6_ = "";
            }
            else
            {
               _loc4_ = new RegExp(/^\s*(\d+).*$/);
               _loc2_ = _loc4_.exec(param1);
               if(_loc2_ && _loc2_[1] != undefined)
               {
                  _loc6_ = _loc2_[1];
               }
            }
         }
         return _loc6_;
      }
      
      private function parseFontFamily(param1:String) : String
      {
         var _loc2_:Object = null;
         if(!param1 || param1 == "")
         {
            return "";
         }
         var _loc5_:String = "";
         var _loc3_:RegExp = new RegExp(/^\s*([^,\s]+)\s*((,\s*([^,\s]+)\s*)*)$/);
         var _loc4_:Boolean = false;
         do
         {
            _loc2_ = _loc3_.exec(param1);
            if(!_loc2_)
            {
               _loc4_ = true;
            }
            else
            {
               if(_loc5_.length > 0)
               {
                  _loc5_ += ",";
               }
               switch(_loc2_[1])
               {
                  case "default":
                  case "serif":
                  case "proportionalSerif":
                     _loc5_ += "_serif";
                     break;
                  case "monospace":
                  case "monospaceSansSerif":
                  case "monospaceSerif":
                     _loc5_ += "_typewriter";
                     break;
                  case "sansSerif":
                  case "proportionalSansSerif":
                     _loc5_ += "_sans";
                     break;
                  default:
                     _loc5_ += _loc2_[1];
               }
               if(_loc2_[2] != undefined && _loc2_[2] != "")
               {
                  param1 = _loc2_[2].slice(1);
               }
               else
               {
                  _loc4_ = true;
               }
            }
         }
         while(!_loc4_);
         return _loc5_;
      }
      
      private function parseBody(param1:CaptioningDocument, param2:XML) : void
      {
         var _loc5_:XMLList = null;
         var _loc4_:XMLList = null;
         var _loc7_:* = 0;
         var _loc6_:XML = null;
         var _loc3_:XMLList = param2..ns::body;
         if(_loc3_.length() <= 0)
         {
            debugLog("Invalid DFXP document: <body> tag is required.");
         }
         else
         {
            _loc5_ = param2..ns::div;
            _loc4_ = _loc5_.length() ? _loc5_.children() : (_loc3_.length() ? _loc3_.children() : new XMLList());
            _loc7_ = 0;
            while(_loc7_ < _loc4_.length())
            {
               _loc6_ = _loc4_[_loc7_];
               if(rootNamespace == _loc6_.namespace())
               {
                  parsePTag(param1,_loc6_,_loc7_);
               }
               else
               {
                  debugLog("Ignoring this tag, foreign namespaces not supported: \"" + _loc6_ + "\"");
               }
               _loc7_++;
            }
         }
      }
      
      private function parsePTag(param1:CaptioningDocument, param2:XML, param3:uint) : void
      {
         var _loc14_:* = 0;
         var _loc15_:XML = null;
         var _loc12_:* = 0;
         var _loc6_:* = null;
         var _loc20_:Array = null;
         var _loc7_:* = 0;
         var _loc16_:CaptionFormat = null;
         var _loc11_:CaptionFormat = null;
         var _loc13_:String = param2.@begin;
         var _loc22_:String = param2.@end;
         var _loc17_:String = param2.@dur;
         if(_loc13_ == "")
         {
            _loc13_ = "0s";
         }
         var _loc21_:Number = TimeUtil.parseTime(_loc13_);
         var _loc4_:Number = 0;
         if(_loc22_ != "")
         {
            _loc4_ = TimeUtil.parseTime(_loc22_);
         }
         else if(_loc17_ != "")
         {
            _loc4_ = _loc21_ + TimeUtil.parseTime(_loc17_);
         }
         var _loc10_:Array = [];
         var _loc5_:String = new String("<p>");
         var _loc8_:XMLList = param2.children();
         _loc14_ = 0;
         while(_loc14_ < _loc8_.length())
         {
            switch((_loc15_ = _loc8_[_loc14_]).nodeKind())
            {
               case "text":
                  _loc5_ += formatCCText(_loc15_.toString());
                  break;
               case "element":
                  switch(_loc15_.localName())
                  {
                     case "set":
                     case "metadata":
                        break;
                     case "span":
                        _loc12_ = uint(calcClearTextLength(_loc5_));
                        _loc20_ = [];
                        _loc5_ += parseSpanTag(param1,_loc15_,_loc20_);
                        _loc7_ = uint(calcClearTextLength(_loc5_));
                        for each(var _loc19_:CaptionStyle in _loc20_)
                        {
                           _loc16_ = new CaptionFormat(_loc19_,_loc12_,_loc7_);
                           _loc10_.push(_loc16_);
                        }
                        break;
                     case "br":
                        _loc5_ += "<br />";
                        break;
                     default:
                        _loc5_ += formatCCText(_loc15_.toString());
                  }
            }
            _loc14_++;
         }
         _loc5_ += "</p>";
         var _loc18_:Caption = new Caption(param3,_loc21_,_loc4_,_loc5_);
         var _loc9_:CaptionStyle = parseStyleAttrib(param1,param2);
         if(_loc9_)
         {
            _loc11_ = new CaptionFormat(_loc9_);
            _loc18_.addCaptionFormat(_loc11_);
         }
         _loc14_ = 0;
         while(_loc14_ < _loc10_.length)
         {
            _loc18_.addCaptionFormat(_loc10_[_loc14_]);
            _loc14_++;
         }
         param1.addCaption(_loc18_);
      }
      
      private function parseStyleAttrib(param1:CaptioningDocument, param2:XML) : CaptionStyle
      {
         var _loc8_:* = 0;
         var _loc6_:XMLList = null;
         var _loc7_:XML = null;
         var _loc4_:String = null;
         var _loc3_:String = param2.@style;
         var _loc5_:CaptionStyle = null;
         if(_loc3_ != "")
         {
            while(_loc8_ < param1.numStyles)
            {
               if(param1.getStyleAt(_loc8_).id == _loc3_)
               {
                  _loc5_ = param1.getStyleAt(_loc8_);
               }
               _loc8_++;
            }
         }
         else
         {
            try
            {
               _loc6_ = param2.tts::@*;
            }
            catch(err:Error)
            {
               if(err.errorID != 1080)
               {
                  throw err;
               }
            }
            _loc8_ = 0;
            while(_loc6_ != null && _loc8_ < _loc6_.length())
            {
               _loc7_ = _loc6_[_loc8_];
               _loc4_ = _loc7_.localName();
               if(_loc4_ != "inherit")
               {
                  _loc5_ = createStyleObject(param2);
               }
               _loc8_++;
            }
         }
         return _loc5_;
      }
      
      private function parseSpanTag(param1:CaptioningDocument, param2:XML, param3:Array) : String
      {
         var _loc8_:* = 0;
         var _loc4_:XML = null;
         var _loc6_:CaptionStyle = parseStyleAttrib(param1,param2);
         if(_loc6_ != null)
         {
            param3.push(_loc6_);
         }
         var _loc7_:String = new String();
         var _loc5_:XMLList = param2.children();
         _loc8_ = 0;
         while(_loc8_ < _loc5_.length())
         {
            switch((_loc4_ = _loc5_[_loc8_]).nodeKind())
            {
               case "text":
                  _loc7_ += formatCCText(_loc4_.toString());
                  break;
               case "element":
                  switch(_loc4_.localName())
                  {
                     case "set":
                     case "metadata":
                        break;
                     case "br":
                        _loc7_ += "<br/>";
                        break;
                     default:
                        _loc7_ += _loc4_.toString();
                  }
            }
            _loc8_++;
         }
         return _loc7_;
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

