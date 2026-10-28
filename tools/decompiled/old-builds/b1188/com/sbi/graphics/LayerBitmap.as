package com.sbi.graphics
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class LayerBitmap extends Bitmap
   {
      
      private const _backgroundColor:uint = 0;
      
      private var _anchorPoint:Point;
      
      private var _layers:Array;
      
      private var _bmin:Point;
      
      private var _bmax:Point;
      
      private var _lastFrame:int;
      
      private var _lastHFlip:Boolean;
      
      private var _blendColor:uint;
      
      private var _bColorChanged:Boolean;
      
      public function LayerBitmap()
      {
         super();
         this._layers = new Array();
         this._anchorPoint = new Point();
         this._bmin = new Point();
         this._bmax = new Point();
      }
      
      public function get length() : int
      {
         var _loc1_:Object = this._layers[0];
         if(!_loc1_)
         {
            _loc1_ = this._layers[1];
         }
         if(!_loc1_)
         {
            return 0;
         }
         return _loc1_.o.f.length;
      }
      
      public function release() : void
      {
         this._layers.splice(0,this._layers.length);
         this._lastFrame = -1;
         this._bColorChanged = false;
      }
      
      public function invalidate() : void
      {
         this._lastFrame = -1;
      }
      
      public function setLayer(param1:int, param2:Object, param3:uint) : void
      {
         if(param1 < 0 || param1 > 10)
         {
            return;
         }
         if(param2)
         {
            if(this._layers[param1] == null)
            {
               this._layers[param1] = {
                  "c":-1,
                  "lastColor":-1,
                  "blendColor":0
               };
            }
            this._layers[param1].o = param2;
         }
         else
         {
            this._layers[param1] = null;
         }
         this.setLayerColor(param1,param3);
         this._lastFrame = -1;
      }
      
      public function setLayerColor(param1:int, param2:uint) : void
      {
         var _loc3_:Object = this._layers[param1];
         if(Boolean(_loc3_) && param2 != _loc3_.c)
         {
            _loc3_.c = param2;
            this._bColorChanged = true;
         }
      }
      
      public function setBlendColor(param1:uint) : void
      {
         if(this._blendColor != param1)
         {
            this._blendColor = param1;
            this._bColorChanged = true;
         }
      }
      
      public function get anchorPoint() : Point
      {
         return this._anchorPoint;
      }
      
      private function refreshLayerPalette(param1:int) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:Object = this._layers[param1];
         if(Boolean(_loc2_) && (_loc2_.lastColor != _loc2_.c || _loc2_.blendColor != this._blendColor))
         {
            _loc3_ = uint(_loc2_.c);
            _loc4_ = PaletteHelper.gamePalette;
            _loc5_ = _loc3_ >> 24 & 0xFF;
            _loc6_ = _loc3_ >> 16 & 0xFF;
            _loc7_ = _loc3_ >> 8 & 0xFF;
            _loc8_ = _loc3_ & 0xFF;
            if(!_loc2_.pal)
            {
               _loc2_.pal = [];
            }
            PaletteHelper.BuildAnimalPalette(_loc2_.pal,_loc4_[_loc5_],_loc4_[_loc6_],_loc4_[_loc7_],_loc4_[_loc8_]);
            _loc9_ = this._blendColor >> 24 & 0xFF;
            if(param1 != 3)
            {
               if(_loc9_ > 0)
               {
                  PaletteHelper.adjustPaletteColor(_loc2_.pal,this._blendColor);
               }
               _loc2_.blendColor = this._blendColor;
            }
            _loc2_.lastColor = _loc3_;
            this._lastFrame = -1;
         }
      }
      
      private function refreshAllPalettes() : void
      {
         var _loc1_:int = 1;
         while(_loc1_ <= 10)
         {
            this.refreshLayerPalette(_loc1_);
            _loc1_++;
         }
         this._bColorChanged = false;
      }
      
      private function calcBounds(param1:int) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         this._bmin.x = 1000;
         this._bmin.y = 1000;
         this._bmax.x = 0;
         this._bmax.y = 0;
         var _loc2_:int = 1;
         while(_loc2_ < this._layers.length)
         {
            _loc3_ = this._layers[_loc2_];
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_.o;
               if(_loc4_.v != ImageArray.VERSION)
               {
                  return;
               }
               _loc5_ = int(_loc4_.f.length);
               if(param1 < _loc5_)
               {
                  _loc6_ = _loc4_.f[param1];
                  if(_loc6_)
                  {
                     _loc7_ = int(_loc6_.x);
                     _loc8_ = int(_loc6_.y);
                     _loc9_ = int(_loc6_.w);
                     _loc10_ = int(_loc6_.h);
                     if(_loc7_ < this._bmin.x)
                     {
                        this._bmin.x = _loc7_;
                     }
                     if(_loc8_ < this._bmin.y)
                     {
                        this._bmin.y = _loc8_;
                     }
                     if(_loc7_ + _loc9_ > this._bmax.x)
                     {
                        this._bmax.x = _loc7_ + _loc9_;
                     }
                     if(_loc8_ + _loc10_ > this._bmax.y)
                     {
                        this._bmax.y = _loc8_ + _loc10_;
                     }
                  }
               }
            }
            _loc2_++;
         }
         if(this._bmin.x == 1000 || this._bmin.y == 1000)
         {
            if(this.bitmapData)
            {
               this.bitmapData = new BitmapData(1,1,true,this._backgroundColor);
            }
            return;
         }
         this.resizeBitmap(1 + this._bmax.x - this._bmin.x,1 + this._bmax.y - this._bmin.y,true);
         this._anchorPoint.x = this._bmin.x;
         this._anchorPoint.y = this._bmin.y;
      }
      
      public function paint(param1:int, param2:Boolean = false, param3:Boolean = true) : Boolean
      {
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         if(param3 && this._layers[0] != null)
         {
            _loc4_ = this._layers[0];
            param1 = int(_loc4_.o.f[param1]);
         }
         if(param1 != this._lastFrame || param2 != this._lastHFlip || this._bColorChanged)
         {
            if(this._bColorChanged)
            {
               this.refreshAllPalettes();
            }
            this._lastFrame = param1;
            this._lastHFlip = param2;
            this.calcBounds(param1);
            _loc6_ = 1;
            while(_loc6_ < this._layers.length)
            {
               _loc4_ = this._layers[_loc6_];
               if(_loc4_ != null)
               {
                  this.paintFrame(_loc4_.o,param1,_loc4_.pal,param2);
               }
               _loc6_++;
            }
            _loc5_ = true;
            if(param2)
            {
               this._anchorPoint.x = 500 - this._bmax.x;
            }
         }
         return _loc5_;
      }
      
      private function paintFrame(param1:Object, param2:int, param3:Array, param4:Boolean) : void
      {
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:uint = 0;
         var _loc18_:uint = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc28_:int = 0;
         var _loc29_:Number = NaN;
         var _loc30_:uint = 0;
         var _loc31_:int = 0;
         if(param2 >= param1.f.length)
         {
            return;
         }
         var _loc5_:Object = param1.f[param2];
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:BitmapData = this.bitmapData;
         var _loc7_:ByteArray = _loc5_.b;
         var _loc8_:int = int(_loc5_.x);
         var _loc9_:int = int(_loc5_.y);
         var _loc10_:int = int(_loc5_.w);
         var _loc11_:int = int(_loc5_.h);
         _loc8_ -= this._bmin.x;
         _loc9_ -= this._bmin.y;
         _loc10_ += _loc8_;
         _loc7_.position = 0;
         var _loc12_:int = int(_loc7_.length);
         var _loc13_:* = _loc8_;
         var _loc14_:int = _loc9_;
         this.bitmapData.lock();
         var _loc27_:int = _loc10_ - _loc8_;
         if(!param4)
         {
            while(_loc7_.position < _loc12_)
            {
               _loc15_ = int(_loc7_.readUnsignedByte());
               _loc16_ = 1;
               if((_loc15_ & 0x80) == 128)
               {
                  _loc15_ &= 127;
                  _loc16_ = _loc7_.readUnsignedByte() + 1;
               }
               if(_loc15_ == 0)
               {
                  _loc13_ += _loc16_;
                  if(_loc13_ >= _loc10_)
                  {
                     _loc16_ = _loc13_ - _loc10_;
                     _loc13_ = int(_loc8_ + _loc16_ % _loc27_);
                     _loc14_ += _loc16_ / _loc27_ + 1;
                  }
               }
               else
               {
                  _loc17_ = uint(param3[_loc15_]);
                  if(_loc17_ >= 4278190080)
                  {
                     if(_loc13_ + _loc16_ < _loc10_)
                     {
                        while(--_loc16_ > -1)
                        {
                           _loc6_.setPixel32(_loc13_++,_loc14_,_loc17_);
                        }
                     }
                     else
                     {
                        while(--_loc16_ > -1)
                        {
                           _loc6_.setPixel32(_loc13_++,_loc14_,_loc17_);
                           if(_loc13_ == _loc10_)
                           {
                              _loc13_ = _loc8_;
                              _loc14_++;
                           }
                        }
                     }
                  }
                  else
                  {
                     while(--_loc16_ > -1)
                     {
                        _loc18_ = _loc6_.getPixel32(_loc13_,_loc14_);
                        if(_loc18_ != this._backgroundColor)
                        {
                           _loc19_ = _loc17_ >> 24 & 0xFF;
                           _loc20_ = _loc17_ >> 16 & 0xFF;
                           _loc21_ = _loc17_ >> 8 & 0xFF;
                           _loc22_ = _loc17_ & 0xFF;
                           _loc23_ = _loc18_ >> 24 & 0xFF;
                           _loc24_ = _loc18_ >> 16 & 0xFF;
                           _loc25_ = _loc18_ >> 8 & 0xFF;
                           _loc26_ = _loc18_ & 0xFF;
                           if(_loc19_ == 192)
                           {
                              _loc20_ = (_loc20_ + _loc20_ + _loc20_ + _loc24_) * 0.25;
                              _loc21_ = (_loc21_ + _loc21_ + _loc21_ + _loc25_) * 0.25;
                              _loc22_ = (_loc22_ + _loc22_ + _loc22_ + _loc26_) * 0.25;
                           }
                           else if(_loc19_ == 128)
                           {
                              _loc20_ = (_loc20_ + _loc24_) * 0.5;
                              _loc21_ = (_loc21_ + _loc25_) * 0.5;
                              _loc22_ = (_loc22_ + _loc26_) * 0.5;
                           }
                           else
                           {
                              _loc20_ = (_loc20_ + _loc24_ + _loc24_ + _loc24_) * 0.25;
                              _loc21_ = (_loc21_ + _loc25_ + _loc25_ + _loc25_) * 0.25;
                              _loc22_ = (_loc22_ + _loc26_ + _loc26_ + _loc26_) * 0.25;
                           }
                           if(_loc23_ > _loc19_)
                           {
                              _loc19_ = _loc23_;
                           }
                           _loc17_ = uint(_loc19_ << 24 | _loc20_ << 16 | _loc21_ << 8 | _loc22_);
                        }
                        _loc6_.setPixel32(_loc13_++,_loc14_,_loc17_);
                        if(_loc13_ == _loc10_)
                        {
                           _loc13_ = _loc8_;
                           _loc14_++;
                        }
                     }
                  }
               }
            }
         }
         else
         {
            _loc28_ = this._bmax.x - this._bmin.x;
            while(_loc7_.position < _loc12_)
            {
               _loc15_ = int(_loc7_.readUnsignedByte());
               _loc16_ = 1;
               if((_loc15_ & 0x80) == 128)
               {
                  _loc15_ &= 127;
                  _loc16_ = _loc7_.readUnsignedByte() + 1;
               }
               if(_loc15_ == 0)
               {
                  _loc13_ += _loc16_;
                  if(_loc13_ >= _loc10_)
                  {
                     _loc16_ = _loc13_ - _loc10_;
                     _loc13_ = int(_loc8_ + _loc16_ % _loc27_);
                     _loc14_ += _loc16_ / _loc27_ + 1;
                  }
               }
               else
               {
                  _loc17_ = uint(param3[_loc15_]);
                  if(_loc17_ >= 4278190080)
                  {
                     if(_loc13_ + _loc16_ < _loc10_)
                     {
                        while(--_loc16_ > -1)
                        {
                           _loc6_.setPixel32(_loc28_ - _loc13_++,_loc14_,_loc17_);
                        }
                     }
                     else
                     {
                        while(--_loc16_ > -1)
                        {
                           _loc6_.setPixel32(_loc28_ - _loc13_++,_loc14_,_loc17_);
                           if(_loc13_ == _loc10_)
                           {
                              _loc13_ = _loc8_;
                              _loc14_++;
                           }
                        }
                     }
                  }
                  else
                  {
                     while(--_loc16_ > -1)
                     {
                        _loc18_ = _loc6_.getPixel32(_loc28_ - _loc13_,_loc14_);
                        if(_loc18_ != this._backgroundColor)
                        {
                           _loc19_ = _loc17_ >> 24 & 0xFF;
                           _loc20_ = _loc17_ >> 16 & 0xFF;
                           _loc21_ = _loc17_ >> 8 & 0xFF;
                           _loc22_ = _loc17_ & 0xFF;
                           _loc23_ = _loc18_ >> 24 & 0xFF;
                           _loc24_ = _loc18_ >> 16 & 0xFF;
                           _loc25_ = _loc18_ >> 8 & 0xFF;
                           _loc26_ = _loc18_ & 0xFF;
                           switch(_loc19_)
                           {
                              case 192:
                                 _loc20_ = (_loc20_ + _loc20_ + _loc20_ + _loc24_) * 0.25;
                                 _loc21_ = (_loc21_ + _loc21_ + _loc21_ + _loc25_) * 0.25;
                                 _loc22_ = (_loc22_ + _loc22_ + _loc22_ + _loc26_) * 0.25;
                                 break;
                              case 128:
                                 _loc20_ = (_loc20_ + _loc24_) * 0.5;
                                 _loc21_ = (_loc21_ + _loc25_) * 0.5;
                                 _loc22_ = (_loc22_ + _loc26_) * 0.5;
                                 break;
                              case 64:
                                 _loc20_ = (_loc20_ + _loc24_ + _loc24_ + _loc24_) * 0.25;
                                 _loc21_ = (_loc21_ + _loc25_ + _loc25_ + _loc25_) * 0.25;
                                 _loc22_ = (_loc22_ + _loc26_ + _loc26_ + _loc26_) * 0.25;
                           }
                           if(_loc23_ > _loc19_)
                           {
                              _loc19_ = _loc23_;
                           }
                           _loc17_ = uint(_loc19_ << 24 | _loc20_ << 16 | _loc21_ << 8 | _loc22_);
                        }
                        _loc6_.setPixel32(_loc28_ - _loc13_++,_loc14_,_loc17_);
                        if(_loc13_ == _loc10_)
                        {
                           _loc13_ = _loc8_;
                           _loc14_++;
                        }
                     }
                  }
               }
            }
         }
         if(_loc5_.hasOwnProperty("s"))
         {
            _loc31_ = int(_loc5_.sm);
            _loc7_ = _loc5_.s;
            _loc12_ = int(_loc7_.length);
            _loc7_.position = 0;
            _loc13_ = _loc8_;
            _loc14_ = _loc9_;
            if(!param4)
            {
               while(_loc7_.position < _loc12_)
               {
                  _loc15_ = int(_loc7_.readUnsignedByte());
                  _loc16_ = 1;
                  if((_loc15_ & 0x80) == 128)
                  {
                     _loc15_ &= 127;
                     _loc16_ = _loc7_.readUnsignedByte() + 1;
                  }
                  if(_loc15_ == 0)
                  {
                     _loc13_ += _loc16_;
                     if(_loc13_ >= _loc10_)
                     {
                        _loc16_ = _loc13_ - _loc10_;
                        _loc13_ = int(_loc8_ + _loc16_ % _loc27_);
                        _loc14_ += _loc16_ / _loc27_ + 1;
                     }
                  }
                  else
                  {
                     _loc17_ = uint(_loc15_ << _loc31_);
                     _loc17_ = _loc17_ + 24;
                     if(_loc17_ > 255)
                     {
                        _loc29_ = 1;
                     }
                     else
                     {
                        _loc29_ = _loc17_ / 255;
                     }
                     while(--_loc16_ > -1)
                     {
                        _loc18_ = _loc6_.getPixel32(_loc13_,_loc14_);
                        if(_loc18_ != this._backgroundColor)
                        {
                           _loc19_ = _loc18_ >> 24 & 0xFF;
                           _loc20_ = (_loc18_ >> 16 & 0xFF) * _loc29_;
                           _loc21_ = (_loc18_ >> 8 & 0xFF) * _loc29_;
                           _loc22_ = (_loc18_ & 0xFF) * _loc29_;
                           _loc30_ = uint(_loc19_ << 24 | _loc20_ << 16 | _loc21_ << 8 | _loc22_);
                           _loc6_.setPixel32(_loc13_,_loc14_,_loc30_);
                        }
                        if(++_loc13_ == _loc10_)
                        {
                           _loc13_ = _loc8_;
                           _loc14_++;
                        }
                     }
                  }
               }
            }
            else
            {
               _loc28_ = this._bmax.x - this._bmin.x;
               while(_loc7_.position < _loc12_)
               {
                  _loc15_ = int(_loc7_.readUnsignedByte());
                  _loc16_ = 1;
                  if((_loc15_ & 0x80) == 128)
                  {
                     _loc15_ &= 127;
                     _loc16_ = _loc7_.readUnsignedByte() + 1;
                  }
                  if(_loc15_ == 0)
                  {
                     _loc13_ += _loc16_;
                     if(_loc13_ >= _loc10_)
                     {
                        _loc16_ = _loc13_ - _loc10_;
                        _loc13_ = int(_loc8_ + _loc16_ % _loc27_);
                        _loc14_ += _loc16_ / _loc27_ + 1;
                     }
                  }
                  else
                  {
                     _loc17_ = uint(_loc15_ << _loc31_);
                     _loc17_ = _loc17_ + 24;
                     if(_loc17_ > 255)
                     {
                        _loc29_ = 1;
                     }
                     else
                     {
                        _loc29_ = _loc17_ / 255;
                     }
                     while(--_loc16_ > -1)
                     {
                        _loc18_ = _loc6_.getPixel32(_loc28_ - _loc13_,_loc14_);
                        if(_loc18_ != this._backgroundColor)
                        {
                           _loc19_ = _loc18_ >> 24 & 0xFF;
                           _loc20_ = (_loc18_ >> 16 & 0xFF) * _loc29_;
                           _loc21_ = (_loc18_ >> 8 & 0xFF) * _loc29_;
                           _loc22_ = (_loc18_ & 0xFF) * _loc29_;
                           _loc30_ = uint(_loc19_ << 24 | _loc20_ << 16 | _loc21_ << 8 | _loc22_);
                           _loc6_.setPixel32(_loc28_ - _loc13_,_loc14_,_loc30_);
                        }
                        if(++_loc13_ == _loc10_)
                        {
                           _loc13_ = _loc8_;
                           _loc14_++;
                        }
                     }
                  }
               }
            }
         }
         _loc6_.unlock();
      }
      
      private function resizeBitmap(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:int = param1;
         var _loc5_:int = param2;
         if(!this.bitmapData)
         {
            param3 = true;
         }
         var _loc6_:Rectangle = new Rectangle(0,0,_loc4_,_loc5_);
         var _loc7_:ByteArray = null;
         if(!param3)
         {
            _loc7_ = this.bitmapData.getPixels(_loc6_);
         }
         if(this.bitmapData)
         {
            this.bitmapData.dispose();
         }
         this.bitmapData = new BitmapData(param1,param2,true,this._backgroundColor);
         if(!param3)
         {
            this.bitmapData.setPixels(_loc6_,_loc7_);
         }
      }
   }
}

