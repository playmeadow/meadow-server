package gui
{
   import avatar.AvatarEditorView;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;

   public class ColorTable extends MovieClip
   {

      private static const HEX_ROW_HEIGHT:int = 24;

      private static const EXPANDED_COLS:int = 20;

      private static var _pending:Array = [];

      private var _bm:Bitmap;

      private var _bmd:BitmapData;

      private var _id:int;

      private var _currColor:int;

      private var _currColorSwatch:Sprite;

      private var _secretColorIdx:int;

      private var _colorValues:Array;

      private var _colorIndexes:Array;

      private var _width:int;

      private var _height:int;

      private var _gridHeight:int;

      private var _numRows:int;

      private var _numCols:int;

      private var _cellWidth:Number;

      private var _cellHeight:Number;

      private var _expanded:Boolean;

      private var _hexInput:TextField;

      private var _hexStatus:TextField;

      private var _colorChangeCallback:Function;

      // ---- the colour picker (a square of saturation and brightness, a
      // bar of hues, the hex) and the dropper, which takes a colour from
      // anywhere on the screen where the page around the game can (the
      // client's screen picker, a browser's EyeDropper: ajPickScreenColour),
      // or else from anywhere in the game. what either gives goes into the
      // picker, and only its Set makes the colour: each new colour is one
      // of the few a player may make in a day.
      private static const SV_SIZE:int = 230;

      private static const HUE_WIDTH:int = 26;

      private static const NEW_SWATCH_HEIGHT:int = 44;

      private static const PANEL_LINE:uint = 0x7F5A33;

      private static const PANEL_TEXT:uint = 0x5C3A1E;

      // the table whose picker is open: where a colour from the page goes
      private static var _active:ColorTable;

      private var _picker:Sprite;

      // the window's content (ReportRulesPopupContent), where its parts are
      private var _pickerBody:DisplayObjectContainer;

      private var _svBmd:BitmapData;

      private var _svMarker:Shape;

      private var _hueMarker:Shape;

      private var _newSwatch:Shape;

      private var _oldSwatch:Shape;

      private var _pickHex:TextField;

      private var _pickNote:TextField;

      private var _hue:Number = 0;

      private var _sat:Number = 0;

      private var _val:Number = 0;

      private var _startRgb:uint;

      private var _dragging:String;

      private var _dropper:Sprite;

      private var _snapshot:BitmapData;

      private var _dropSwatch:Shape;

      // the page's pick from the screen, not answered in this long: the
      // picker is back (a client that never answers would leave it hidden)
      private static const SCREEN_PICK_MS:int = 90000;

      private var _screenPickTimer:uint;

      public function ColorTable()
      {
         super();
      }

      private static function compareSwatches(param1:Object, param2:Object) : int
      {
         if(param1.g != param2.g)
         {
            return param1.g < param2.g ? -1 : 1;
         }
         if(param1.h != param2.h)
         {
            return param1.h < param2.h ? -1 : 1;
         }
         if(param1.v != param2.v)
         {
            return param1.v < param2.v ? -1 : 1;
         }
         return 0;
      }

      private static function allPaletteIndexes(param1:Array) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:Object = {};
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Array = [];
         while(_loc4_ < param1.length && _loc4_ < 256)
         {
            _loc5_ = uint(param1[_loc4_]) & 0xFFFFFF;
            if(_loc3_[_loc5_] == null)
            {
               _loc3_[_loc5_] = true;
               _loc6_ = _loc5_ >> 16 & 0xFF;
               _loc7_ = _loc5_ >> 8 & 0xFF;
               _loc8_ = _loc5_ & 0xFF;
               _loc9_ = Math.max(_loc6_,_loc7_,_loc8_);
               _loc10_ = Math.min(_loc6_,_loc7_,_loc8_);
               _loc11_ = 0;
               if(_loc9_ != _loc10_)
               {
                  if(_loc9_ == _loc6_)
                  {
                     _loc11_ = ((_loc7_ - _loc8_) / (_loc9_ - _loc10_) + 6) % 6;
                  }
                  else if(_loc9_ == _loc7_)
                  {
                     _loc11_ = (_loc8_ - _loc6_) / (_loc9_ - _loc10_) + 2;
                  }
                  else
                  {
                     _loc11_ = (_loc6_ - _loc7_) / (_loc9_ - _loc10_) + 4;
                  }
               }
               _loc2_.push({
                  "i":_loc4_,
                  "g":(_loc9_ - _loc10_ < 24 ? 0 : 1),
                  "h":(_loc9_ - _loc10_ < 24 ? 0 : Math.floor(_loc11_ * 4)),
                  "v":_loc6_ + _loc7_ + _loc8_
               });
            }
            _loc4_++;
         }
         _loc2_.sort(compareSwatches);
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc12_.push(_loc2_[_loc4_].i);
            _loc4_++;
         }
         return _loc12_;
      }

      private static function onCustomRegistered(param1:uint, param2:Array) : void
      {
         var _loc3_:String = param2.join(",");
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         while(_loc4_ < _pending.length)
         {
            _loc5_ = _pending[_loc4_];
            if(_loc5_.key == _loc3_)
            {
               _pending.splice(_loc4_,1);
               ColorTable(_loc5_.table).applyCustom(int(_loc5_.u),param1);
            }
            else
            {
               _loc4_++;
            }
         }
      }

      public function init(param1:int, param2:int, param3:int, param4:int, param5:int, param6:Array, param7:Array, param8:int, param9:Function, param10:int = -1) : void
      {
         _id = param1;
         _width = param2;
         _height = param3;
         _gridHeight = param3;
         _colorValues = param6;
         _colorIndexes = param7;
         _numCols = param4;
         _numRows = param5;
         _colorChangeCallback = param9;
         _secretColorIdx = param10;
         _expanded = param6 != null && param6 == PaletteHelper.gamePalette && (param7 == PaletteHelper.avatarPalette1 || param7 == PaletteHelper.avatarPalette2);
         if(_expanded)
         {
            _colorIndexes = allPaletteIndexes(param6);
            _numCols = EXPANDED_COLS;
            _numRows = Math.ceil(_colorIndexes.length / EXPANDED_COLS);
            _gridHeight = _height - HEX_ROW_HEIGHT;
            _secretColorIdx = -1;
         }
         _cellWidth = _width / _numCols;
         _cellHeight = _gridHeight / _numRows;
         _bmd = new BitmapData(_width,_gridHeight,false,0);
         fillColorTable();
         _currColor = param8;
         setCurrentColorSwatch(_currColor);
         if(_expanded)
         {
            buildHexRow();
            showHex(_currColor);
         }
         addEventListener("mouseDown",colorTableClickHandler,false,0,true);
      }

      public function destroy() : void
      {
         if(_bm)
         {
            this.removeChild(_bm);
            _bm = null;
         }
         if(_bmd)
         {
            _bmd = null;
         }
         _colorIndexes = null;
         _colorValues = null;
         _colorChangeCallback = null;
         removeEventListener("mouseDown",colorTableClickHandler);
         stopGameDropper();
         closePicker();
      }

      private function fillColorTable() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         while(_loc1_ < _colorIndexes.length)
         {
            _loc2_ = _loc1_ % _numCols * _cellWidth;
            _loc3_ = Math.floor(_loc1_ / _numCols) * _cellHeight;
            _bmd.fillRect(new Rectangle(Math.round(_loc2_),Math.round(_loc3_),Math.ceil(_cellWidth),Math.ceil(_cellHeight)),uint(_colorValues[_colorIndexes[_loc1_]]) & 0xFFFFFF);
            _loc1_++;
         }
         _bm = new Bitmap(_bmd);
         this.addChild(_bm);
      }

      private function setCurrentColorSwatch(param1:int) : void
      {
         var _loc2_:int = -1;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = _expanded ? 2 : 5;
         while(_loc3_ < _colorIndexes.length)
         {
            if(_colorIndexes[_loc3_] == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
            _loc3_++;
         }
         if(_currColorSwatch)
         {
            this.removeChild(_currColorSwatch);
            _currColorSwatch = null;
         }
         if(_loc2_ >= 0)
         {
            _loc4_ = Math.round(_loc2_ % _numCols * _cellWidth);
            _loc5_ = Math.round(Math.floor(_loc2_ / _numCols) * _cellHeight);
            _currColorSwatch = new Sprite();
            _currColorSwatch.mouseEnabled = false;
            _currColorSwatch.graphics.beginFill(0);
            _currColorSwatch.graphics.drawRect(_loc4_,_loc5_,_cellWidth,_loc6_);
            _currColorSwatch.graphics.drawRect(_loc4_,_loc5_ + _cellHeight - _loc6_,_cellWidth,_loc6_);
            _currColorSwatch.graphics.drawRect(_loc4_,_loc5_,_loc6_,_cellHeight);
            _currColorSwatch.graphics.drawRect(_loc4_ + _cellWidth - _loc6_,_loc5_,_loc6_,_cellHeight);
            _currColorSwatch.graphics.endFill();
            this.addChild(_currColorSwatch);
         }
      }

      private function buildHexRow() : void
      {
         var _loc1_:Sprite = new Sprite();
         var _loc2_:TextField = new TextField();
         var _loc3_:TextFormat = new TextFormat("_sans",11,16777215,true);
         _hexInput = new TextField();
         _hexInput.defaultTextFormat = new TextFormat("_sans",12,2302234);
         _hexInput.type = "input";
         _hexInput.border = true;
         _hexInput.borderColor = PANEL_LINE;
         _hexInput.background = true;
         _hexInput.backgroundColor = 16777215;
         _hexInput.restrict = "0-9a-fA-F#";
         _hexInput.maxChars = 7;
         _hexInput.x = 0;
         _hexInput.y = _gridHeight + 3;
         _hexInput.width = 62;
         _hexInput.height = 19;
         _hexInput.addEventListener("keyDown",onHexKey);
         _hexInput.addEventListener("keyUp",onHexKeyUp);
         addChild(_hexInput);
         // the game's own buttons: its green tick, the shop's colour change
         // button for the picker, and a blue one with the dropper on it
         _loc1_ = assetButton("okCheckCont","",19 / 40,onHexSetClick);
         _loc1_.x = 66;
         _loc1_.y = _gridHeight + 3;
         addChild(_loc1_);
         var _loc4_:Sprite = assetButton("colorChange_btnCont","",19 / 38,onPickerClick);
         _loc4_.x = 89;
         _loc4_.y = _gridHeight + 3;
         addChild(_loc4_);
         var _loc5_:Sprite = assetButton("introBtnCont","",19 / 34,onDropperClick,dropperIcon,30);
         _loc5_.x = 127;
         _loc5_.y = _gridHeight + 3;
         addChild(_loc5_);
         _hexStatus = new TextField();
         _hexStatus.defaultTextFormat = new TextFormat("_sans",10,PANEL_TEXT);
         _hexStatus.selectable = false;
         _hexStatus.mouseEnabled = false;
         _hexStatus.x = 161;
         _hexStatus.y = _gridHeight + 5;
         _hexStatus.width = _width - 161;
         _hexStatus.height = 18;
         _hexStatus.text = "or pick one";
         addChild(_hexStatus);
      }

      // ---- the game's own window and buttons (HUDAssets, as the Item
      // Giver's in AJClient)

      // the game's button `param1` with `param2` on it ("" for none), at
      // `param3` of its size (`param6` wide instead, when given), its top
      // left at 0,0; `param4` on a click; `param5` draws on it
      private function assetButton(param1:String, param2:String, param3:Number, param4:Function, param5:Function = null, param6:Number = 0) : Sprite
      {
         var _loc7_:Sprite = new Sprite();
         var _loc8_:MovieClip = GETDEFINITIONBYNAME(param1);
         var _loc9_:Rectangle = null;
         labelButton(_loc8_,param2);
         _loc8_.scaleX = _loc8_.scaleY = param3;
         if(param6 > 0)
         {
            _loc8_.scaleX = param6 / _loc8_.getBounds(_loc8_).width;
         }
         _loc9_ = _loc8_.getBounds(_loc7_);
         _loc8_.x = -_loc9_.x;
         _loc8_.y = -_loc9_.y;
         _loc7_.addChild(_loc8_);
         if(param5 != null)
         {
            param5(_loc7_);
         }
         _loc7_.buttonMode = true;
         _loc7_.addEventListener("click",param4);
         return _loc7_;
      }

      // the words on each of a game button's states (AJClient.finderButtonText)
      private static function labelButton(param1:MovieClip, param2:String) : void
      {
         var _loc3_:Array = [param1.getChildByName("gray"),param1.getChildByName("down")];
         var _loc4_:MovieClip = param1.getChildByName("mouse") as MovieClip;
         var _loc5_:MovieClip = null;
         var _loc6_:TextField = null;
         var _loc7_:int = 0;
         if(_loc4_ != null)
         {
            _loc3_.push(_loc4_.getChildByName("up"));
            _loc3_.push(_loc4_.getChildByName("mouse"));
            while(_loc7_ < _loc4_.numChildren)
            {
               _loc3_.push(_loc4_.getChildAt(_loc7_));
               _loc7_++;
            }
         }
         _loc7_ = 0;
         while(_loc7_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc7_] as MovieClip;
            _loc6_ = _loc5_ == null ? null : _loc5_.getChildByName("txt") as TextField;
            if(_loc6_ != null)
            {
               _loc6_.text = param2;
            }
            _loc7_++;
         }
      }

      // text in the game's font where it has it, with an outline in `param5` (or none)
      private static function gameText(param1:String, param2:int, param3:uint, param4:Boolean = true, param5:int = -1) : TextField
      {
         var _loc6_:TextField = new TextField();
         var _loc7_:Boolean = AJClient.hasGameFont();
         _loc6_.embedFonts = _loc7_;
         _loc6_.defaultTextFormat = new TextFormat(_loc7_ ? "CCDigitalDelivery" : "_sans",param2,param3,param4);
         _loc6_.selectable = false;
         _loc6_.mouseEnabled = false;
         _loc6_.autoSize = "left";
         _loc6_.text = param1;
         if(param5 >= 0)
         {
            _loc6_.filters = [new GlowFilter(param5,1,3,3,6,2)];
         }
         return _loc6_;
      }

      // the dropper's picture, color-picker.png on this server, at 14 x 14
      private function dropperIcon(param1:Sprite) : void
      {
         var _loc2_:Loader = new Loader();
         _loc2_.contentLoaderInfo.addEventListener("complete",onDropperIconLoaded,false,0,true);
         _loc2_.contentLoaderInfo.addEventListener("ioError",onDropperIconFailed,false,0,true);
         _loc2_.load(new URLRequest(gMainFrame.clientInfo.websiteURL + "color-picker.png"));
         // on the small button in the hex row, or before the word on a big one
         _loc2_.x = param1.height > 22 ? 10 : 3;
         _loc2_.y = int((param1.height - 14) / 2);
         param1.addChild(_loc2_);
      }

      private function onDropperIconLoaded(param1:Event) : void
      {
         var _loc2_:Loader = param1.target.loader;
         _loc2_.width = 14;
         _loc2_.height = 14;
         if(_loc2_.content is Bitmap)
         {
            Bitmap(_loc2_.content).smoothing = true;
         }
      }

      private function onDropperIconFailed(param1:Event) : void
      {
      }

      private function onPickerClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         openPicker(hexInRow());
      }

      private function onDropperClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         openPicker(hexInRow());
         startDropper();
      }

      // the colour in the hex box, or the colour now on the animal's part
      private function hexInRow() : uint
      {
         var _loc1_:String = _hexInput == null ? "" : _hexInput.text.split("#").join("");
         return _loc1_.length == 6 ? uint(parseInt(_loc1_,16)) & 0xFFFFFF : 0x808080;
      }

      private function get theStage() : Stage
      {
         return stage != null ? stage : gMainFrame.stage;
      }

      private function text(param1:String, param2:int, param3:uint, param4:Boolean = false) : TextField
      {
         return gameText(param1,param2,param3,param4);
      }

      // a frame of the window's brown round a part of it
      private static function frame(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         param1.graphics.lineStyle(3,PANEL_LINE,1,true,"normal","none","miter");
         param1.graphics.drawRect(param2 - 1.5,param3 - 1.5,param4 + 3,param5 + 3);
         param1.graphics.lineStyle();
      }

      // one of the window's text fields, moved to x, y, its words `param4`
      private static function placeText(param1:TextField, param2:Number, param3:Number, param4:String, param5:Number = 180) : TextField
      {
         param1.visible = true;
         param1.wordWrap = false;
         param1.x = param2;
         param1.y = param3;
         param1.width = param5;
         param1.height = 24;
         param1.text = param4;
         return param1;
      }

      // the game's window (ReportRulesPopupSkin, as the Item Giver's) with
      // the square, the hue bar, the new and old colours, the hex, the
      // dropper and the game's buttons in it
      private function openPicker(param1:uint) : void
      {
         var _loc2_:Stage = theStage;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:BitmapData = null;
         var _loc6_:Sprite = null;
         var _loc7_:int = 0;
         var _loc8_:Sprite = null;
         var _loc9_:TextField = null;
         var _loc10_:int = 52;
         var _loc11_:int = 180;
         if(_loc2_ == null)
         {
            return;
         }
         closePicker();
         _active = this;
         _startRgb = param1;
         _picker = new Sprite();
         // the rest of the game is dimmed, and takes no clicks
         _picker.graphics.beginFill(0,0.45);
         _picker.graphics.drawRect(0,0,Math.max(900,_loc2_.stageWidth),Math.max(550,_loc2_.stageHeight));
         _picker.graphics.endFill();
         _picker.addEventListener("mouseDown",stopEvent);
         _loc6_ = new Sprite();
         _loc6_.x = 450;
         _loc6_.y = 275;
         _picker.addChild(_loc6_);
         _loc3_ = GETDEFINITIONBYNAME("ReportRulesPopupSkin");
         _loc4_ = GETDEFINITIONBYNAME("ReportRulesPopupContent");
         _loc6_.addChild(_loc3_);
         _loc4_.x = _loc3_.c.x;
         _loc4_.y = _loc3_.c.y;
         _loc6_.addChild(_loc4_);
         _pickerBody = _loc4_;
         _loc3_.bx.addEventListener("mouseDown",onPickerCancel);
         _loc7_ = 1;
         while(_loc7_ <= 5)
         {
            _loc4_["ruleTxt" + _loc7_].visible = false;
            _loc4_["ruleBodyTxt" + _loc7_].visible = false;
            _loc7_++;
         }
         _loc4_.titleTxt.text = "Pick a Color";
         // saturation along, brightness up
         _svBmd = new BitmapData(SV_SIZE,SV_SIZE,false,0);
         _loc8_ = new Sprite();
         _loc8_.addChild(new Bitmap(_svBmd));
         _loc8_.x = -235;
         _loc8_.y = -135;
         _loc8_.name = "sv";
         _loc8_.addEventListener("mouseDown",onPickerDown);
         frame(_loc4_,_loc8_.x,_loc8_.y,SV_SIZE,SV_SIZE);
         _loc4_.addChild(_loc8_);
         _svMarker = new Shape();
         _svMarker.graphics.lineStyle(2,0xFFFFFF);
         _svMarker.graphics.drawCircle(0,0,6);
         _svMarker.graphics.lineStyle(1,0);
         _svMarker.graphics.drawCircle(0,0,7.5);
         _loc8_.addChild(_svMarker);
         // every hue, top to bottom
         _loc5_ = new BitmapData(HUE_WIDTH,SV_SIZE,false,0);
         _loc7_ = 0;
         while(_loc7_ < SV_SIZE)
         {
            _loc5_.fillRect(new Rectangle(0,_loc7_,HUE_WIDTH,1),hsvToRgb(_loc7_ / SV_SIZE * 360,1,1));
            _loc7_++;
         }
         _loc8_ = new Sprite();
         _loc8_.addChild(new Bitmap(_loc5_));
         _loc8_.x = 7;
         _loc8_.y = -135;
         _loc8_.name = "hue";
         _loc8_.addEventListener("mouseDown",onPickerDown);
         frame(_loc4_,_loc8_.x,_loc8_.y,HUE_WIDTH,SV_SIZE);
         _loc4_.addChild(_loc8_);
         _hueMarker = new Shape();
         _hueMarker.graphics.lineStyle(2,0xFFFFFF);
         _hueMarker.graphics.drawRect(-2,-3,HUE_WIDTH + 4,6);
         _hueMarker.graphics.lineStyle(1,0);
         _hueMarker.graphics.drawRect(-3,-4,HUE_WIDTH + 6,8);
         _loc8_.addChild(_hueMarker);
         // the new colour over the one it started with (a click on that
         // goes back to it), in the window's own headings
         placeText(_loc4_.ruleTxt1,_loc10_,-142,"New",_loc11_);
         _newSwatch = new Shape();
         _newSwatch.x = _loc10_;
         _newSwatch.y = -116;
         frame(_loc4_,_loc10_,-116,_loc11_,NEW_SWATCH_HEIGHT);
         _loc4_.addChild(_newSwatch);
         placeText(_loc4_.ruleTxt2,_loc10_,-66,"Before",_loc11_);
         _oldSwatch = new Shape();
         _oldSwatch.graphics.beginFill(_startRgb);
         _oldSwatch.graphics.drawRect(0,0,_loc11_,36);
         _oldSwatch.graphics.endFill();
         _loc8_ = new Sprite();
         _loc8_.addChild(_oldSwatch);
         _loc8_.x = _loc10_;
         _loc8_.y = -40;
         _loc8_.buttonMode = true;
         _loc8_.addEventListener("click",onOldSwatchClick);
         frame(_loc4_,_loc10_,-40,_loc11_,36);
         _loc4_.addChild(_loc8_);
         // the hex, in the window's own body text
         _loc9_ = _loc4_.ruleBodyTxt2;
         _pickHex = new TextField();
         _pickHex.embedFonts = _loc9_.embedFonts;
         _pickHex.defaultTextFormat = _loc9_.getTextFormat();
         _pickHex.type = "input";
         _pickHex.border = true;
         _pickHex.borderColor = PANEL_LINE;
         _pickHex.background = true;
         _pickHex.backgroundColor = 0xFFFFFF;
         _pickHex.restrict = "0-9a-fA-F#";
         _pickHex.maxChars = 7;
         _pickHex.x = _loc10_;
         _pickHex.y = 8;
         _pickHex.width = _loc11_;
         _pickHex.height = 24;
         _pickHex.addEventListener("keyDown",onPickHexKey);
         _pickHex.addEventListener("keyUp",stopEvent);
         _pickHex.addEventListener("change",onPickHexChange);
         _loc4_.addChild(_pickHex);
         _loc8_ = assetButton("introBtnCont","    Pick",1,onPickerDropperClick,dropperIcon);
         _loc8_.x = _loc10_ + int((_loc11_ - _loc8_.width) / 2);
         _loc8_.y = 44;
         _loc4_.addChild(_loc8_);
         _pickNote = placeText(_loc4_.ruleBodyTxt1,-235,108,"",230);
         _pickNote.wordWrap = true;
         _pickNote.height = 44;
         _loc8_ = assetButton("cancelBtnCont","Cancel",1,onPickerCancel);
         _loc8_.x = -2;
         _loc8_.y = 136;
         _loc4_.addChild(_loc8_);
         // the green box with a tick, the Item Giver's Give
         _loc8_ = assetButton("buyBtnCont","Set",1,onPickerSet);
         _loc8_.x = 116;
         _loc8_.y = 136;
         _loc4_.addChild(_loc8_);
         _loc2_.addChild(_picker);
         _loc2_.addEventListener("mouseMove",onPickerMove);
         _loc2_.addEventListener("mouseUp",onPickerUp);
         _loc2_.addEventListener("keyDown",onPickerKey,true,100);
         setRgb(param1);
      }

      private function closePicker() : void
      {
         var _loc1_:Stage = theStage;
         if(_loc1_ != null)
         {
            _loc1_.removeEventListener("mouseMove",onPickerMove);
            _loc1_.removeEventListener("mouseUp",onPickerUp);
            _loc1_.removeEventListener("keyDown",onPickerKey,true);
         }
         if(_picker != null && _picker.parent != null)
         {
            _picker.parent.removeChild(_picker);
         }
         if(_svBmd != null)
         {
            _svBmd.dispose();
         }
         _picker = null;
         _pickerBody = null;
         _svBmd = null;
         _dragging = null;
         if(_active == this)
         {
            _active = null;
         }
      }

      private function stopEvent(param1:Event) : void
      {
         param1.stopPropagation();
      }

      // ---- the picker's colour, kept as hue (0-360), saturation and value (0-1)

      private static function hsvToRgb(param1:Number, param2:Number, param3:Number) : uint
      {
         var _loc4_:Number = param1 % 360 / 60;
         var _loc5_:int = Math.floor(_loc4_);
         var _loc6_:Number = _loc4_ - _loc5_;
         var _loc7_:Number = param3 * (1 - param2);
         var _loc8_:Number = param3 * (1 - param2 * _loc6_);
         var _loc9_:Number = param3 * (1 - param2 * (1 - _loc6_));
         var _loc10_:Array = [[param3,_loc9_,_loc7_],[_loc8_,param3,_loc7_],[_loc7_,param3,_loc9_],[_loc7_,_loc8_,param3],[_loc9_,_loc7_,param3],[param3,_loc7_,_loc8_]][_loc5_ % 6];
         return uint(Math.round(_loc10_[0] * 255)) << 16 | uint(Math.round(_loc10_[1] * 255)) << 8 | uint(Math.round(_loc10_[2] * 255));
      }

      private function setRgb(param1:uint) : void
      {
         var _loc2_:Number = (param1 >> 16 & 0xFF) / 255;
         var _loc3_:Number = (param1 >> 8 & 0xFF) / 255;
         var _loc4_:Number = (param1 & 0xFF) / 255;
         var _loc5_:Number = Math.max(_loc2_,_loc3_,_loc4_);
         var _loc6_:Number = _loc5_ - Math.min(_loc2_,_loc3_,_loc4_);
         var _loc7_:Number = _hue;
         if(_loc6_ > 0)
         {
            if(_loc5_ == _loc2_)
            {
               _loc7_ = 60 * ((_loc3_ - _loc4_) / _loc6_ % 6);
            }
            else if(_loc5_ == _loc3_)
            {
               _loc7_ = 60 * ((_loc4_ - _loc2_) / _loc6_ + 2);
            }
            else
            {
               _loc7_ = 60 * ((_loc2_ - _loc3_) / _loc6_ + 4);
            }
         }
         _hue = (_loc7_ + 360) % 360;
         _sat = _loc5_ == 0 ? 0 : _loc6_ / _loc5_;
         _val = _loc5_;
         drawSquare();
         showPicked(true);
      }

      private function pickedRgb() : uint
      {
         return hsvToRgb(_hue,_sat,_val);
      }

      private function drawSquare() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(_svBmd == null)
         {
            return;
         }
         _svBmd.lock();
         while(_loc2_ < SV_SIZE)
         {
            _loc1_ = 0;
            while(_loc1_ < SV_SIZE)
            {
               _svBmd.setPixel(_loc1_,_loc2_,hsvToRgb(_hue,_loc1_ / (SV_SIZE - 1),1 - _loc2_ / (SV_SIZE - 1)));
               _loc1_++;
            }
            _loc2_++;
         }
         _svBmd.unlock();
      }

      // the markers, the new swatch and (unless it is being typed) the hex
      private function showPicked(param1:Boolean) : void
      {
         var _loc2_:uint = pickedRgb();
         var _loc3_:String = _loc2_.toString(16).toUpperCase();
         if(_picker == null)
         {
            return;
         }
         _svMarker.x = _sat * (SV_SIZE - 1);
         _svMarker.y = (1 - _val) * (SV_SIZE - 1);
         _hueMarker.y = _hue / 360 * SV_SIZE;
         _newSwatch.graphics.clear();
         _newSwatch.graphics.beginFill(_loc2_);
         _newSwatch.graphics.drawRect(0,0,_pickHex.width,NEW_SWATCH_HEIGHT);
         _newSwatch.graphics.endFill();
         if(param1)
         {
            while(_loc3_.length < 6)
            {
               _loc3_ = "0" + _loc3_;
            }
            _pickHex.text = "#" + _loc3_;
         }
      }

      private function onPickerDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _dragging = Sprite(param1.currentTarget).name;
         dragTo(Sprite(param1.currentTarget));
      }

      private function onPickerMove(param1:MouseEvent) : void
      {
         var _loc2_:Sprite = null;
         if(_dragging == null || _picker == null)
         {
            return;
         }
         _loc2_ = Sprite(_pickerBody.getChildByName(_dragging));
         dragTo(_loc2_);
      }

      private function onPickerUp(param1:MouseEvent) : void
      {
         _dragging = null;
      }

      private function dragTo(param1:Sprite) : void
      {
         var _loc2_:Number = Math.max(0,Math.min(SV_SIZE - 1,param1.mouseX));
         var _loc3_:Number = Math.max(0,Math.min(SV_SIZE - 1,param1.mouseY));
         if(param1.name == "sv")
         {
            _sat = _loc2_ / (SV_SIZE - 1);
            _val = 1 - _loc3_ / (SV_SIZE - 1);
         }
         else
         {
            _hue = _loc3_ / SV_SIZE * 360;
            drawSquare();
         }
         _pickNote.text = "";
         showPicked(true);
      }

      private function onPickHexKey(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         if(param1.keyCode == 13)
         {
            onPickerSet(null);
         }
      }

      // a whole hex typed: the picker goes to it
      private function onPickHexChange(param1:Event) : void
      {
         var _loc2_:String = _pickHex.text.split("#").join("");
         if(_loc2_.length == 6)
         {
            setRgbKeepingText(uint(parseInt(_loc2_,16)) & 0xFFFFFF);
         }
      }

      private function setRgbKeepingText(param1:uint) : void
      {
         var _loc2_:String = _pickHex.text;
         setRgb(param1);
         _pickHex.text = _loc2_;
      }

      private function onOldSwatchClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         setRgb(_startRgb);
      }

      private function onPickerKey(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 27)
         {
            param1.stopImmediatePropagation();
            if(_dropper != null)
            {
               stopGameDropper();
               showPickerAgain();
            }
            else
            {
               closePicker();
            }
         }
      }

      private function onPickerCancel(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         closePicker();
      }

      private function onPickerSet(param1:MouseEvent) : void
      {
         var _loc2_:uint = pickedRgb();
         var _loc3_:String = _loc2_.toString(16).toUpperCase();
         if(param1 != null)
         {
            param1.stopPropagation();
         }
         while(_loc3_.length < 6)
         {
            _loc3_ = "0" + _loc3_;
         }
         closePicker();
         if(_hexInput != null)
         {
            _hexInput.text = "#" + _loc3_;
         }
         applyRgb(_loc2_);
      }

      private function onPickerDropperClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         startDropper();
      }

      // ---- the dropper

      private function startDropper() : void
      {
         var _loc1_:Boolean = false;
         if(_picker == null)
         {
            return;
         }
         _picker.visible = false;
         try
         {
            if(ExternalInterface.available)
            {
               _loc1_ = ExternalInterface.call("ajPickScreenColour") == true;
            }
         }
         catch(e:Error)
         {
            _loc1_ = false;
         }
         if(!_loc1_)
         {
            startGameDropper();
         }
         else
         {
            clearTimeout(_screenPickTimer);
            _screenPickTimer = setTimeout(showPickerAgain,SCREEN_PICK_MS);
         }
      }

      // the page's answer (AJClient's ajScreenColour): "#RRGGBB", "" when
      // the player let it be, or "!" when it could not pick after all
      public static function screenColour(param1:String) : void
      {
         if(_active != null)
         {
            _active.onScreenColour(String(param1));
         }
      }

      private function onScreenColour(param1:String) : void
      {
         var _loc2_:String = param1.split("#").join("");
         if(_picker == null)
         {
            return;
         }
         if(param1 == "!")
         {
            startGameDropper();
            return;
         }
         showPickerAgain();
         if(/^[0-9a-fA-F]{6}$/.test(_loc2_))
         {
            setRgb(uint(parseInt(_loc2_,16)));
            _pickNote.text = "From the screen. Set to use it.";
         }
      }

      private function showPickerAgain() : void
      {
         clearTimeout(_screenPickTimer);
         if(_picker != null)
         {
            _picker.visible = true;
         }
      }

      // in the game only: a picture of it now, and the colour under the
      // mouse in it, until a click takes one (or Esc)
      private function startGameDropper() : void
      {
         var _loc1_:Stage = theStage;
         var _loc2_:TextField = null;
         stopGameDropper();
         try
         {
            _snapshot = new BitmapData(900,550,false,0);
            _snapshot.draw(_loc1_);
         }
         catch(e:Error)
         {
            _snapshot = null;
            showPickerAgain();
            _pickNote.text = "The game cannot be picked from here.";
            return;
         }
         _dropper = new Sprite();
         _dropper.graphics.beginFill(0,0);
         _dropper.graphics.drawRect(0,0,Math.max(900,_loc1_.stageWidth),Math.max(550,_loc1_.stageHeight));
         _dropper.graphics.endFill();
         _loc2_ = text("Click anywhere to take its colour. Esc to stop.",13,0xFFFFFF,true);
         _loc2_.background = true;
         _loc2_.backgroundColor = 0x2A1A0E;
         _loc2_.x = int((900 - _loc2_.width) / 2);
         _loc2_.y = 10;
         _dropper.addChild(_loc2_);
         _dropSwatch = new Shape();
         _dropper.addChild(_dropSwatch);
         _dropper.addEventListener("mouseMove",onDropperMove);
         _dropper.addEventListener("mouseDown",onDropperDown);
         _loc1_.addChild(_dropper);
         onDropperMove(null);
      }

      private function stopGameDropper() : void
      {
         if(_dropper != null && _dropper.parent != null)
         {
            _dropper.parent.removeChild(_dropper);
         }
         if(_snapshot != null)
         {
            _snapshot.dispose();
         }
         _dropper = null;
         _snapshot = null;
         _dropSwatch = null;
      }

      private function colourUnderMouse() : uint
      {
         var _loc1_:Stage = theStage;
         return _snapshot == null ? 0 : _snapshot.getPixel(Math.max(0,Math.min(899,int(_loc1_.mouseX))),Math.max(0,Math.min(549,int(_loc1_.mouseY))));
      }

      // a swatch of the colour beside the mouse
      private function onDropperMove(param1:MouseEvent) : void
      {
         var _loc2_:Stage = theStage;
         if(_dropSwatch == null)
         {
            return;
         }
         _dropSwatch.graphics.clear();
         _dropSwatch.graphics.lineStyle(2,0xFFFFFF);
         _dropSwatch.graphics.beginFill(colourUnderMouse());
         _dropSwatch.graphics.drawRect(0,0,34,34);
         _dropSwatch.graphics.endFill();
         _dropSwatch.graphics.lineStyle(1,0);
         _dropSwatch.graphics.drawRect(-1.5,-1.5,37,37);
         _dropSwatch.x = Math.min(900 - 40,_loc2_.mouseX + 14);
         _dropSwatch.y = Math.min(550 - 40,_loc2_.mouseY + 14);
      }

      private function onDropperDown(param1:MouseEvent) : void
      {
         var _loc2_:uint = colourUnderMouse();
         param1.stopPropagation();
         stopGameDropper();
         showPickerAgain();
         setRgb(_loc2_);
         _pickNote.text = "From the game. Set to use it.";
      }

      private function showHex(param1:int) : void
      {
         var _loc2_:String = null;
         if(_hexInput == null || param1 < 0 || param1 >= _colorValues.length)
         {
            return;
         }
         _loc2_ = (uint(_colorValues[param1]) & 0xFFFFFF).toString(16).toUpperCase();
         while(_loc2_.length < 6)
         {
            _loc2_ = "0" + _loc2_;
         }
         _hexInput.text = "#" + _loc2_;
      }

      private function onHexKey(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         if(param1.keyCode == 13)
         {
            applyHex();
         }
      }

      private function onHexKeyUp(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
      }

      private function onHexSetClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         applyHex();
      }

      private function applyHex() : void
      {
         var _loc1_:String = _hexInput.text.split("#").join("");
         if(_loc1_.length != 6)
         {
            _hexStatus.text = "use 6 hex digits";
            return;
         }
         applyRgb(uint(parseInt(_loc1_,16)) & 0xFFFFFF);
      }

      private function colorSlot() : int
      {
         return _id == 0 || _id == 1 ? 0 : (_id == 2 ? 2 : 1);
      }

      private function findView() : AvatarEditorView
      {
         var _loc1_:DisplayObjectContainer = parent;
         var _loc2_:DisplayObjectContainer = null;
         var _loc3_:int = 0;
         var _loc4_:AvatarEditorView = null;
         while(_loc1_ != null)
         {
            _loc2_ = _loc1_.getChildByName("charBox") as DisplayObjectContainer;
            if(_loc2_ != null)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.numChildren)
               {
                  _loc4_ = _loc2_.getChildAt(_loc3_) as AvatarEditorView;
                  if(_loc4_ != null)
                  {
                     return _loc4_;
                  }
                  _loc3_++;
               }
            }
            _loc1_ = _loc1_.parent;
         }
         return null;
      }

      private function applyRgb(param1:uint) : void
      {
         var _loc2_:AvatarEditorView = findView();
         var _loc3_:Array = null;
         if(_loc2_ == null || _loc2_.colors == null)
         {
            if(_hexStatus != null)
            {
               _hexStatus.text = "not available here";
            }
            return;
         }
         _loc3_ = PaletteHelper.resolve(uint(_loc2_.colors[colorSlot()]));
         _loc3_[_id == 1 ? 1 : 0] = param1;
         _pending.push({
            "key":_loc3_.join(","),
            "table":this,
            "u":colorSlot()
         });
         PaletteHelper.onCustomRegistered = onCustomRegistered;
         if(_hexStatus != null)
         {
            _hexStatus.text = "setting...";
         }
         gMainFrame.server.setXtObject_Str("xcc",_loc3_);
      }

      public function applyCustom(param1:int, param2:uint) : void
      {
         var _loc3_:AvatarEditorView = findView();
         var _loc4_:Array = null;
         if(_loc3_ == null || _loc3_.colors == null)
         {
            return;
         }
         _loc4_ = _loc3_.colors.concat();
         _loc4_[param1] = param2;
         _loc3_.colors = _loc4_;
         _currColor = -1;
         setCurrentColorSwatch(-1);
         if(_hexStatus != null)
         {
            _hexStatus.text = "set";
         }
      }

      private function colorTableClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = mouseX;
         var _loc3_:Number = mouseY;
         var _loc4_:int = -1;
         var _loc5_:int = 0;
         var _loc6_:AvatarEditorView = null;
         if(_loc3_ < 0 || _loc3_ >= _gridHeight || _loc2_ < 0)
         {
            return;
         }
         if(_loc2_ >= _width)
         {
            if(_secretColorIdx == -1 || _loc3_ < _cellHeight * (_numRows - 1))
            {
               _loc2_ = _width - 1;
            }
            else
            {
               _loc4_ = _secretColorIdx;
            }
         }
         if(_loc4_ < 0)
         {
            _loc5_ = Math.floor(_loc2_ / _cellWidth) + Math.floor(_loc3_ / _cellHeight) * _numCols;
            if(_loc5_ < 0 || _loc5_ >= _colorIndexes.length)
            {
               return;
            }
            _loc4_ = int(_colorIndexes[_loc5_]);
         }
         if(_expanded)
         {
            showHex(_loc4_);
            _loc6_ = findView();
            if(_loc6_ != null && _loc6_.colors != null && PaletteHelper.isCustom(uint(_loc6_.colors[colorSlot()])))
            {
               _currColor = _loc4_;
               applyRgb(uint(_colorValues[_loc4_]) & 0xFFFFFF);
               return;
            }
         }
         if(_currColor != _loc4_)
         {
            _currColor = _loc4_;
            setCurrentColorSwatch(_loc4_);
            if(_colorChangeCallback != null)
            {
               _colorChangeCallback(_id,_loc4_);
            }
         }
      }
   }
}
