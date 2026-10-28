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
      
      public function init(id:int, width:int, height:int, numCols:int, numRows:int, colorValues:Array, colorIndexes:Array, defColor:int, colorChangeCallback:Function, secretColor:int = -1) : void
      {
         this._id = id;
         this._width = width;
         this._height = height;
         this._colorValues = colorValues;
         this._colorIndexes = colorIndexes;
         this._numCols = numCols;
         this._numRows = numRows;
         this._cellWidth = this._width / this._numCols;
         this._cellHeight = this._height / this._numRows;
         this._colorChangeCallback = colorChangeCallback;
         this._secretColorIdx = secretColor;
         this._bmd = new BitmapData(this._width,this._height,false,0);
         this.fillColorTable();
         this._currColor = defColor;
         this.setCurrentColorSwatch(this._currColor);
         addEventListener(MouseEvent.MOUSE_DOWN,this.colorTableClickHandler,false,0,true);
      }
      
      public function destroy() : void
      {
         if(Boolean(this._bm))
         {
            this.removeChild(this._bm);
            this._bm = null;
         }
         if(Boolean(this._bmd))
         {
            this._bmd = null;
         }
         this._colorIndexes = null;
         this._colorValues = null;
         removeEventListener(MouseEvent.MOUSE_DOWN,this.colorTableClickHandler);
      }
      
      private function fillColorTable() : void
      {
         var x:int = 0;
         var y:int = 0;
         var rect:Rectangle = null;
         for(var i:int = 0; i < this._colorIndexes.length; i++)
         {
            x = i % this._numCols * (this._width / this._numCols);
            y = Math.floor(i / this._numCols) * (this._height / this._numRows);
            rect = new Rectangle(x,y,this._width / this._numCols,this._height / this._numRows);
            this._bmd.fillRect(rect,this._colorValues[this._colorIndexes[i]]);
         }
         this._bm = new Bitmap(this._bmd);
         this.addChild(this._bm);
      }
      
      private function setCurrentColorSwatch(color:int) : void
      {
         var i:int;
         var x:int = 0;
         var y:int = 0;
         var idxInPalette:int = -1;
         for(i = 0; i < this._colorIndexes.length; i++)
         {
            if(this._colorIndexes[i] == color)
            {
               idxInPalette = i;
               break;
            }
         }
         if(Boolean(this._currColorSwatch))
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
      
      private function colorTableClickHandler(evt:MouseEvent) : void
      {
         var idxInColorArray:int = 0;
         var clickPt:Point = new Point(evt.localX,evt.localY);
         var newColor:int = -1;
         if(clickPt.x == this._width)
         {
            if(this._secretColorIdx == -1)
            {
               clickPt.x = this._width - 1;
            }
            else if(clickPt.y < this._cellHeight * (this._numRows - 1))
            {
               clickPt.x = this._width - 1;
            }
            else
            {
               newColor = this._secretColorIdx;
            }
         }
         if(newColor < 0)
         {
            idxInColorArray = Math.floor(clickPt.x / this._cellWidth) + Math.floor(clickPt.y / this._cellHeight) * this._numCols;
            newColor = int(this._colorIndexes[idxInColorArray]);
         }
         if(this._currColor != newColor)
         {
            this._currColor = newColor;
            this.setCurrentColorSwatch(newColor);
            if(this._colorChangeCallback != null)
            {
               this._colorChangeCallback(this._id,newColor);
            }
         }
      }
   }
}

