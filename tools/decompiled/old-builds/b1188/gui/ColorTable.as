package gui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class ColorTable extends MovieClip
   {
      
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
      
      private var _numRows:int;
      
      private var _numCols:int;
      
      private var _cellWidth:int;
      
      private var _cellHeight:int;
      
      private var _colorChangeCallback:Function;
      
      public function ColorTable()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:int, param4:int, param5:int, param6:Array, param7:Array, param8:int, param9:Function, param10:int = -1) : void
      {
         this._id = param1;
         this._width = param2;
         this._height = param3;
         this._colorValues = param6;
         this._colorIndexes = param7;
         this._numCols = param4;
         this._numRows = param5;
         this._cellWidth = this._width / this._numCols;
         this._cellHeight = this._height / this._numRows;
         this._colorChangeCallback = param9;
         this._secretColorIdx = param10;
         this._bmd = new BitmapData(this._width,this._height,false,0);
         this.fillColorTable();
         this._currColor = param8;
         this.setCurrentColorSwatch(this._currColor);
         addEventListener(MouseEvent.MOUSE_DOWN,this.colorTableClickHandler,false,0,true);
      }
      
      public function destroy() : void
      {
         if(this._bm)
         {
            this.removeChild(this._bm);
            this._bm = null;
         }
         if(this._bmd)
         {
            this._bmd = null;
         }
         this._colorIndexes = null;
         this._colorValues = null;
         removeEventListener(MouseEvent.MOUSE_DOWN,this.colorTableClickHandler);
      }
      
      private function fillColorTable() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:Rectangle = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._colorIndexes.length)
         {
            _loc1_ = _loc3_ % this._numCols * (this._width / this._numCols);
            _loc2_ = Math.floor(_loc3_ / this._numCols) * (this._height / this._numRows);
            _loc4_ = new Rectangle(_loc1_,_loc2_,this._width / this._numCols,this._height / this._numRows);
            this._bmd.fillRect(_loc4_,this._colorValues[this._colorIndexes[_loc3_]]);
            _loc3_++;
         }
         this._bm = new Bitmap(this._bmd);
         this.addChild(this._bm);
      }
      
      private function setCurrentColorSwatch(param1:int) : void
      {
         var x:int = 0;
         var y:int = 0;
         var color:int = param1;
         var idxInPalette:int = -1;
         var i:int = 0;
         while(i < this._colorIndexes.length)
         {
            if(this._colorIndexes[i] == color)
            {
               idxInPalette = i;
               break;
            }
            i++;
         }
         if(this._currColorSwatch)
         {
            this.removeChild(this._currColorSwatch);
            this._currColorSwatch = null;
         }
         if(idxInPalette >= 0)
         {
            x = idxInPalette % this._numCols * this._cellWidth;
            y = Math.floor(idxInPalette / this._numCols) * this._cellHeight;
            this._currColorSwatch = new Sprite();
            with(this._currColorSwatch.graphics)
            {
               
               beginFill(0);
               drawRect(x,y,_cellWidth,5);
               drawRect(x,y + _cellHeight - 5,_cellWidth,5);
               drawRect(x,y,5,_cellHeight);
               drawRect(x + _cellWidth - 5,y,5,_cellHeight);
            }
            this.addChild(this._currColorSwatch);
         }
      }
      
      private function colorTableClickHandler(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Point = new Point(param1.localX,param1.localY);
         var _loc3_:int = -1;
         if(_loc2_.x == this._width)
         {
            if(this._secretColorIdx == -1)
            {
               _loc2_.x = this._width - 1;
            }
            else if(_loc2_.y < this._cellHeight * (this._numRows - 1))
            {
               _loc2_.x = this._width - 1;
            }
            else
            {
               _loc3_ = this._secretColorIdx;
            }
         }
         if(_loc3_ < 0)
         {
            _loc4_ = Math.floor(_loc2_.x / this._cellWidth) + Math.floor(_loc2_.y / this._cellHeight) * this._numCols;
            _loc3_ = int(this._colorIndexes[_loc4_]);
         }
         if(this._currColor != _loc3_)
         {
            this._currColor = _loc3_;
            this.setCurrentColorSwatch(_loc3_);
            if(this._colorChangeCallback != null)
            {
               this._colorChangeCallback(this._id,_loc3_);
            }
         }
      }
   }
}

