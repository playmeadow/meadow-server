package game.pillBugs
{
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.net.*;
   import flash.text.*;
   import flash.utils.*;
   
   public class PillBugsLevelConverter
   {
      
      public var _outFile:FileReference;
      
      public var _myFile:FileReference;
      
      public var _outputReadyState:int;
      
      public var _output:Array;
      
      public var _outputString:String;
      
      public function PillBugsLevelConverter()
      {
         super();
      }
      
      public function convertFile() : void
      {
         _outputReadyState = 0;
         _myFile = new FileReference();
         _myFile.addEventListener("select",selectHandler);
         _myFile.addEventListener("ioError",onFileLoadError);
         _myFile.addEventListener("progress",onProgress);
         var _loc2_:Array = [];
         var _loc1_:FileFilter = new FileFilter("Comma Separated Files (*.csv)","*.csv");
         _loc2_.push(_loc1_);
         _myFile.browse(_loc2_);
      }
      
      private function selectHandler(param1:Event) : void
      {
         _myFile.removeEventListener("select",selectHandler);
         _myFile.addEventListener("complete",onFileLoaded);
         _myFile.load();
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         var _loc2_:Number = param1.bytesLoaded / param1.bytesTotal * 100;
         trace("loaded: " + _loc2_ + "%");
      }
      
      private function onFileLoadError(param1:Event) : void
      {
         _myFile.removeEventListener("complete",onFileLoaded);
         _myFile.removeEventListener("ioError",onFileLoadError);
         _myFile.removeEventListener("progress",onProgress);
         trace("File load error");
      }
      
      public function onFileLoaded(param1:Event) : void
      {
         var _loc8_:int = 0;
         var _loc11_:String = null;
         var _loc4_:String = null;
         var _loc12_:int = 0;
         var _loc2_:Boolean = false;
         var _loc5_:String = null;
         var _loc14_:int = 0;
         var _loc13_:int = 0;
         _myFile.removeEventListener("complete",onFileLoaded);
         _myFile.removeEventListener("ioError",onFileLoadError);
         _myFile.removeEventListener("progress",onProgress);
         var _loc10_:int = 0;
         var _loc7_:FileReference = param1.target as FileReference;
         var _loc6_:ByteArray = _loc7_["data"];
         var _loc3_:String = _loc6_.toString();
         _output = [];
         _output["level"] = 1;
         _output["x"] = 10;
         _output["y"] = 10;
         _output["gameboard"] = [];
         _output["pegs"] = 10;
         _output["easy"] = 20;
         _output["medium"] = 18;
         _output["hard"] = 16;
         _loc10_ = _loc3_.indexOf("easy=",0);
         if(_loc10_ != -1)
         {
            _loc10_ = _loc3_.indexOf("=",_loc10_);
            _loc10_++;
            _loc8_ = _loc3_.indexOf(",",_loc10_);
            _loc11_ = _loc3_.substring(_loc10_,_loc8_);
            _output["easy"] = int(_loc11_);
         }
         _loc10_ = _loc3_.indexOf("medium=",0);
         if(_loc10_ != -1)
         {
            _loc10_ = _loc3_.indexOf("=",_loc10_);
            _loc10_++;
            _loc8_ = _loc3_.indexOf(",",_loc10_);
            _loc11_ = _loc3_.substring(_loc10_,_loc8_);
            _output["medium"] = int(_loc11_);
         }
         _loc10_ = _loc3_.indexOf("hard=",0);
         if(_loc10_ != -1)
         {
            _loc10_ = _loc3_.indexOf("=",_loc10_);
            _loc10_++;
            _loc8_ = _loc3_.indexOf(",",_loc10_);
            _loc11_ = _loc3_.substring(_loc10_,_loc8_);
            _output["hard"] = int(_loc11_);
         }
         _loc10_ = _loc3_.indexOf("level=",0);
         if(_loc10_ != -1)
         {
            _loc10_ = _loc3_.indexOf("=",_loc10_);
            _loc10_++;
            _loc8_ = _loc3_.indexOf(",",_loc10_);
            _loc11_ = _loc3_.substring(_loc10_,_loc8_);
            _output["level"] = int(_loc11_);
         }
         _loc10_ = _loc3_.indexOf("x=",0);
         if(_loc10_ != -1)
         {
            _loc10_ = _loc3_.indexOf("=",_loc10_);
            _loc10_++;
            _loc8_ = _loc3_.indexOf(",",_loc10_);
            _loc11_ = _loc3_.substring(_loc10_,_loc8_);
            _output["x"] = int(_loc11_);
         }
         _loc10_ = _loc3_.indexOf("y=",0);
         if(_loc10_ != -1)
         {
            _loc10_ = _loc3_.indexOf("=",_loc10_);
            _loc10_++;
            _loc8_ = _loc3_.indexOf(",",_loc10_);
            _loc11_ = _loc3_.substring(_loc10_,_loc8_);
            _output["y"] = int(_loc11_);
         }
         _loc10_ = _loc3_.indexOf("pegs=",0);
         if(_loc10_ != -1)
         {
            _loc10_ = _loc3_.indexOf("=",_loc10_);
            _loc10_++;
            _loc8_ = _loc3_.indexOf(",",_loc10_);
            _loc11_ = _loc3_.substring(_loc10_,_loc8_);
            _output["pegs"] = int(_loc11_);
         }
         var _loc9_:int = 1;
         while(_loc10_ < _loc3_.length)
         {
            _loc4_ = _loc9_ + ",";
            _loc10_ = _loc3_.indexOf(_loc4_,_loc10_);
            if(_loc10_ != -1)
            {
               _loc10_ += _loc4_.length;
               if(_loc10_ < _loc3_.length)
               {
                  _output["gameboard"][_loc9_ - 1] = [];
                  _loc12_ = 0;
                  _loc2_ = true;
                  while(_loc3_.charAt(_loc10_) == "," || _loc3_.charAt(_loc10_) == "1" || _loc3_.charAt(_loc10_) == "2" || _loc3_.charAt(_loc10_) == "3" || _loc3_.charAt(_loc10_) == "4" || _loc3_.charAt(_loc10_) == "5" || _loc3_.charAt(_loc10_) == "a" || _loc3_.charAt(_loc10_) == "A" || _loc3_.charAt(_loc10_) == "b" || _loc3_.charAt(_loc10_) == "B" || _loc3_.charAt(_loc10_) == "c" || _loc3_.charAt(_loc10_) == "C" || _loc3_.charAt(_loc10_) == "d" || _loc3_.charAt(_loc10_) == "D" || _loc3_.charAt(_loc10_) == "e" || _loc3_.charAt(_loc10_) == "E")
                  {
                     _loc5_ = _loc3_.charAt(_loc10_);
                     switch(_loc3_.charAt(_loc10_))
                     {
                        case "1":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 1;
                           _loc2_ = false;
                           break;
                        case "2":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 2;
                           _loc2_ = false;
                           break;
                        case "3":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 3;
                           _loc2_ = false;
                           break;
                        case "4":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 4;
                           _loc2_ = false;
                           break;
                        case "5":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 5;
                           _loc2_ = false;
                           break;
                        case "a":
                        case "A":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 101;
                           _loc2_ = false;
                           break;
                        case "b":
                        case "B":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 102;
                           _loc2_ = false;
                           break;
                        case "c":
                        case "C":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 103;
                           _loc2_ = false;
                           break;
                        case "d":
                        case "D":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 104;
                           _loc2_ = false;
                           break;
                        case "e":
                        case "E":
                           _output["gameboard"][_loc9_ - 1][_loc12_] = 105;
                           _loc2_ = false;
                           break;
                        case ",":
                           if(_loc2_)
                           {
                              _output["gameboard"][_loc9_ - 1][_loc12_] = 0;
                           }
                           _loc2_ = true;
                           _loc12_++;
                     }
                     _loc10_++;
                  }
                  if(_loc2_)
                  {
                     _output["gameboard"][_loc9_ - 1][_loc12_] = 0;
                  }
                  _loc9_++;
                  continue;
               }
            }
            break;
         }
         _outputString = new String();
         _outputString += "[\r\n";
         _outputString += "\t{\r\n\t level:" + _output["level"] + ",\r\n\t sizeX:" + _output["x"] + ",\r\n\t sizeY:" + _output["y"] + ",\r\n\t pegs:" + _output["pegs"] + ",\r\n\t easy:" + _output["easy"] + ",\r\n\t medium:" + _output["medium"] + ",\r\n\t hard:" + _output["hard"] + ",\r\n";
         _outputString += "\t gameboard:\r\n\t\t[\r\n";
         _loc13_ = 0;
         while(_loc13_ < _output["gameboard"].length)
         {
            _outputString += "\t\t\t[";
            _loc14_ = 0;
            while(_loc14_ < _output["gameboard"][_loc13_].length)
            {
               if(_loc14_ != 0)
               {
                  _outputString += ",";
               }
               _outputString += _output["gameboard"][_loc13_][_loc14_];
               _loc14_++;
            }
            if(_loc13_ < _output["gameboard"].length - 1)
            {
               _outputString += "],\r\n";
            }
            else
            {
               _outputString += "]\r\n";
            }
            _loc13_++;
         }
         _outputString += "\t\t]\r\n\t}\r\n]\r\n";
         _outputReadyState = 1;
      }
      
      public function saveFile() : void
      {
         _outFile = new FileReference();
         if(_outputReadyState != 0)
         {
            _outFile.save(_outputString,"level.txt");
         }
      }
   }
}

