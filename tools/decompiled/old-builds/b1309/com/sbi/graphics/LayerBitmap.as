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
         _layers = [];
         _anchorPoint = new Point();
         _bmin = new Point();
         _bmax = new Point();
      }
      
      public function get length() : int
      {
         var _loc1_:Object = _layers[0];
         if(!_loc1_)
         {
            _loc1_ = _layers[1];
         }
         if(!_loc1_)
         {
            return 0;
         }
         return _loc1_.o.f.length;
      }
      
      public function release() : void
      {
         _layers.splice(0,_layers.length);
         _lastFrame = -1;
         _bColorChanged = false;
      }
      
      public function invalidate() : void
      {
         _lastFrame = -1;
      }
      
      public function setLayer(param1:int, param2:Object, param3:uint) : void
      {
         if(param1 < 0 || param1 > 10)
         {
            return;
         }
         if(param2)
         {
            if(_layers[param1] == null)
            {
               _layers[param1] = {
                  "c":-1,
                  "lastColor":-1,
                  "blendColor":0
               };
            }
            _layers[param1].o = param2;
         }
         else
         {
            _layers[param1] = null;
         }
         setLayerColor(param1,param3);
         _lastFrame = -1;
      }
      
      public function setLayerColor(param1:int, param2:uint) : void
      {
         var _loc3_:Object = _layers[param1];
         if(_loc3_ && param2 != _loc3_.c)
         {
            _loc3_.c = param2;
            _bColorChanged = true;
         }
      }
      
      public function updateAllLayerColor(param1:uint) : void
      {
         for each(var _loc2_:Object in _layers)
         {
            _loc2_.c = param1;
            _bColorChanged = true;
         }
      }
      
      public function setBlendColor(param1:uint) : void
      {
         if(_blendColor != param1)
         {
            _blendColor = param1;
            _bColorChanged = true;
         }
      }
      
      public function get anchorPoint() : Point
      {
         return _anchorPoint;
      }
      
      private function refreshLayerPalette(param1:int) : void
      {
         var _loc5_:* = 0;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:Object = _layers[param1];
         if(_loc8_ && (_loc8_.lastColor != _loc8_.c || _loc8_.blendColor != _blendColor))
         {
            _loc5_ = uint(_loc8_.c);
            _loc6_ = PaletteHelper.gamePalette;
            _loc7_ = _loc5_ >> 24 & 0xFF;
            _loc9_ = _loc5_ >> 16 & 0xFF;
            _loc2_ = _loc5_ >> 8 & 0xFF;
            _loc3_ = _loc5_ & 0xFF;
            if(!_loc8_.pal)
            {
               _loc8_.pal = [];
            }
            PaletteHelper.BuildAnimalPalette(_loc8_.pal,_loc6_[_loc7_],_loc6_[_loc9_],_loc6_[_loc2_],_loc6_[_loc3_]);
            _loc4_ = _blendColor >> 24 & 0xFF;
            if(param1 != 3)
            {
               if(_loc4_ > 0)
               {
                  PaletteHelper.adjustPaletteColor(_loc8_.pal,_blendColor);
               }
               _loc8_.blendColor = _blendColor;
            }
            _loc8_.lastColor = _loc5_;
            _lastFrame = -1;
         }
      }
      
      private function refreshAllPalettes() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 1;
         while(_loc1_ <= 10)
         {
            refreshLayerPalette(_loc1_);
            _loc1_++;
         }
         _bColorChanged = false;
      }
      
      private function calcBounds(param1:int) : void
      {
         var _loc7_:int = 0;
         var _loc4_:Object = null;
         var _loc10_:Object = null;
         var _loc3_:int = 0;
         var _loc8_:Object = null;
         var _loc2_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         _bmin.x = 1000;
         _bmin.y = 1000;
         _bmax.x = 0;
         _bmax.y = 0;
         _loc7_ = 1;
         while(_loc7_ < _layers.length)
         {
            _loc4_ = _layers[_loc7_];
            if(_loc4_ != null)
            {
               _loc10_ = _loc4_.o;
               if(_loc10_.v != 117967104)
               {
                  return;
               }
               _loc3_ = int(_loc10_.f.length);
               if(param1 < _loc3_)
               {
                  _loc8_ = _loc10_.f[param1];
                  if(_loc8_)
                  {
                     _loc2_ = int(_loc8_.x);
                     _loc9_ = int(_loc8_.y);
                     _loc5_ = int(_loc8_.w);
                     _loc6_ = int(_loc8_.h);
                     if(_loc2_ < _bmin.x)
                     {
                        _bmin.x = _loc2_;
                     }
                     if(_loc9_ < _bmin.y)
                     {
                        _bmin.y = _loc9_;
                     }
                     if(_loc2_ + _loc5_ > _bmax.x)
                     {
                        _bmax.x = _loc2_ + _loc5_;
                     }
                     if(_loc9_ + _loc6_ > _bmax.y)
                     {
                        _bmax.y = _loc9_ + _loc6_;
                     }
                  }
               }
            }
            _loc7_++;
         }
         if(_bmin.x == 1000 || _bmin.y == 1000)
         {
            if(this.bitmapData)
            {
               trace("WARNING: making new empty 1x1 bitmap data (parent.name:" + parent.name + ") - is index:" + param1 + " valid?");
               this.bitmapData = new BitmapData(1,1,true,0);
            }
            return;
         }
         resizeBitmap(1 + _bmax.x - _bmin.x,1 + _bmax.y - _bmin.y,true);
         _anchorPoint.x = _bmin.x;
         _anchorPoint.y = _bmin.y;
      }
      
      public function paint(param1:int, param2:Boolean = false, param3:Boolean = true) : Boolean
      {
         var _loc6_:Object = null;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         if(param3 && _layers[0] != null)
         {
            _loc6_ = _layers[0];
            param1 = int(_loc6_.o.f[param1]);
         }
         if(param1 != _lastFrame || param2 != _lastHFlip || _bColorChanged)
         {
            if(_bColorChanged)
            {
               refreshAllPalettes();
            }
            _lastFrame = param1;
            _lastHFlip = param2;
            calcBounds(param1);
            _loc5_ = 1;
            while(_loc5_ < _layers.length)
            {
               _loc6_ = _layers[_loc5_];
               if(_loc6_ != null)
               {
                  paintFrame(_loc6_.o,param1,_loc6_.pal,param2);
               }
               _loc5_++;
            }
            _loc4_ = true;
            if(param2)
            {
               _anchorPoint.x = 500 - _bmax.x;
            }
         }
         return _loc4_;
      }
      
      private function paintFrame(param1:Object, param2:int, param3:Array, param4:Boolean) : void
      {
         var _loc25_:int = 0;
         var _loc18_:int = 0;
         var _loc13_:* = 0;
         var _loc15_:* = 0;
         var _loc31_:int = 0;
         var _loc20_:int = 0;
         var _loc8_:int = 0;
         var _loc26_:int = 0;
         var _loc5_:int = 0;
         var _loc21_:int = 0;
         var _loc10_:int = 0;
         var _loc27_:int = 0;
         var _loc9_:int = 0;
         var _loc14_:Number = NaN;
         var _loc23_:* = 0;
         var _loc12_:int = 0;
         if(param2 >= param1.f.length)
         {
            return;
         }
         var _loc24_:Object = param1.f[param2];
         if(!_loc24_)
         {
            return;
         }
         var _loc6_:BitmapData = this.bitmapData;
         var _loc22_:ByteArray = _loc24_.b;
         var _loc11_:int = int(_loc24_.x);
         var _loc7_:int = int(_loc24_.y);
         var _loc28_:int = int(_loc24_.w);
         var _loc17_:int = int(_loc24_.h);
         _loc11_ -= _bmin.x;
         _loc7_ -= _bmin.y;
         _loc28_ += _loc11_;
         _loc22_.position = 0;
         var _loc16_:int = int(_loc22_.length);
         var _loc29_:int = _loc11_;
         var _loc30_:int = _loc7_;
         this.bitmapData.lock();
         var _loc19_:int = _loc28_ - _loc11_;
         if(!param4)
         {
            while(_loc22_.position < _loc16_)
            {
               _loc25_ = int(_loc22_.readUnsignedByte());
               _loc18_ = 1;
               if((_loc25_ & 0x80) == 128)
               {
                  _loc25_ &= 127;
                  _loc18_ = _loc22_.readUnsignedByte() + 1;
               }
               if(_loc25_ == 0)
               {
                  _loc29_ += _loc18_;
                  if(_loc29_ >= _loc28_)
                  {
                     _loc18_ = _loc29_ - _loc28_;
                     _loc29_ = _loc11_ + _loc18_ % _loc19_;
                     _loc30_ += _loc18_ / _loc19_ + 1;
                  }
               }
               else
               {
                  _loc13_ = uint(param3[_loc25_]);
                  if(_loc13_ >= 4278190080)
                  {
                     if(_loc29_ + _loc18_ < _loc28_)
                     {
                        while(--_loc18_ > -1)
                        {
                           _loc6_.setPixel32(_loc29_++,_loc30_,_loc13_);
                        }
                     }
                     else
                     {
                        while(--_loc18_ > -1)
                        {
                           _loc6_.setPixel32(_loc29_++,_loc30_,_loc13_);
                           if(_loc29_ == _loc28_)
                           {
                              _loc29_ = _loc11_;
                              _loc30_++;
                           }
                        }
                     }
                  }
                  else
                  {
                     while(--_loc18_ > -1)
                     {
                        _loc15_ = _loc6_.getPixel32(_loc29_,_loc30_);
                        if(_loc15_ != 0)
                        {
                           _loc26_ = _loc13_ >> 24 & 0xFF;
                           _loc31_ = _loc13_ >> 16 & 0xFF;
                           _loc20_ = _loc13_ >> 8 & 0xFF;
                           _loc8_ = _loc13_ & 0xFF;
                           _loc27_ = _loc15_ >> 24 & 0xFF;
                           _loc5_ = _loc15_ >> 16 & 0xFF;
                           _loc21_ = _loc15_ >> 8 & 0xFF;
                           _loc10_ = _loc15_ & 0xFF;
                           if(_loc26_ == 192)
                           {
                              _loc31_ = (_loc31_ + _loc31_ + _loc31_ + _loc5_) * 0.25;
                              _loc20_ = (_loc20_ + _loc20_ + _loc20_ + _loc21_) * 0.25;
                              _loc8_ = (_loc8_ + _loc8_ + _loc8_ + _loc10_) * 0.25;
                           }
                           else if(_loc26_ == 128)
                           {
                              _loc31_ = (_loc31_ + _loc5_) * 0.5;
                              _loc20_ = (_loc20_ + _loc21_) * 0.5;
                              _loc8_ = (_loc8_ + _loc10_) * 0.5;
                           }
                           else
                           {
                              _loc31_ = (_loc31_ + _loc5_ + _loc5_ + _loc5_) * 0.25;
                              _loc20_ = (_loc20_ + _loc21_ + _loc21_ + _loc21_) * 0.25;
                              _loc8_ = (_loc8_ + _loc10_ + _loc10_ + _loc10_) * 0.25;
                           }
                           if(_loc27_ > _loc26_)
                           {
                              _loc26_ = _loc27_;
                           }
                           _loc13_ = uint(_loc26_ << 24 | _loc31_ << 16 | _loc20_ << 8 | _loc8_);
                        }
                        _loc6_.setPixel32(_loc29_++,_loc30_,_loc13_);
                        if(_loc29_ == _loc28_)
                        {
                           _loc29_ = _loc11_;
                           _loc30_++;
                        }
                     }
                  }
               }
            }
         }
         else
         {
            _loc9_ = _bmax.x - _bmin.x;
            while(_loc22_.position < _loc16_)
            {
               _loc25_ = int(_loc22_.readUnsignedByte());
               _loc18_ = 1;
               if((_loc25_ & 0x80) == 128)
               {
                  _loc25_ &= 127;
                  _loc18_ = _loc22_.readUnsignedByte() + 1;
               }
               if(_loc25_ == 0)
               {
                  _loc29_ += _loc18_;
                  if(_loc29_ >= _loc28_)
                  {
                     _loc18_ = _loc29_ - _loc28_;
                     _loc29_ = _loc11_ + _loc18_ % _loc19_;
                     _loc30_ += _loc18_ / _loc19_ + 1;
                  }
               }
               else
               {
                  _loc13_ = uint(param3[_loc25_]);
                  if(_loc13_ >= 4278190080)
                  {
                     if(_loc29_ + _loc18_ < _loc28_)
                     {
                        while(--_loc18_ > -1)
                        {
                           _loc6_.setPixel32(_loc9_ - _loc29_++,_loc30_,_loc13_);
                        }
                     }
                     else
                     {
                        while(--_loc18_ > -1)
                        {
                           _loc6_.setPixel32(_loc9_ - _loc29_++,_loc30_,_loc13_);
                           if(_loc29_ == _loc28_)
                           {
                              _loc29_ = _loc11_;
                              _loc30_++;
                           }
                        }
                     }
                  }
                  else
                  {
                     while(--_loc18_ > -1)
                     {
                        _loc15_ = _loc6_.getPixel32(_loc9_ - _loc29_,_loc30_);
                        if(_loc15_ != 0)
                        {
                           _loc26_ = _loc13_ >> 24 & 0xFF;
                           _loc31_ = _loc13_ >> 16 & 0xFF;
                           _loc20_ = _loc13_ >> 8 & 0xFF;
                           _loc8_ = _loc13_ & 0xFF;
                           _loc27_ = _loc15_ >> 24 & 0xFF;
                           _loc5_ = _loc15_ >> 16 & 0xFF;
                           _loc21_ = _loc15_ >> 8 & 0xFF;
                           _loc10_ = _loc15_ & 0xFF;
                           switch(_loc26_)
                           {
                              case 192:
                                 _loc31_ = (_loc31_ + _loc31_ + _loc31_ + _loc5_) * 0.25;
                                 _loc20_ = (_loc20_ + _loc20_ + _loc20_ + _loc21_) * 0.25;
                                 _loc8_ = (_loc8_ + _loc8_ + _loc8_ + _loc10_) * 0.25;
                                 break;
                              case 128:
                                 _loc31_ = (_loc31_ + _loc5_) * 0.5;
                                 _loc20_ = (_loc20_ + _loc21_) * 0.5;
                                 _loc8_ = (_loc8_ + _loc10_) * 0.5;
                                 break;
                              case 64:
                                 _loc31_ = (_loc31_ + _loc5_ + _loc5_ + _loc5_) * 0.25;
                                 _loc20_ = (_loc20_ + _loc21_ + _loc21_ + _loc21_) * 0.25;
                                 _loc8_ = (_loc8_ + _loc10_ + _loc10_ + _loc10_) * 0.25;
                           }
                           if(_loc27_ > _loc26_)
                           {
                              _loc26_ = _loc27_;
                           }
                           _loc13_ = uint(_loc26_ << 24 | _loc31_ << 16 | _loc20_ << 8 | _loc8_);
                        }
                        _loc6_.setPixel32(_loc9_ - _loc29_++,_loc30_,_loc13_);
                        if(_loc29_ == _loc28_)
                        {
                           _loc29_ = _loc11_;
                           _loc30_++;
                        }
                     }
                  }
               }
            }
         }
         if(_loc24_.hasOwnProperty("s"))
         {
            _loc12_ = int(_loc24_.sm);
            _loc22_ = _loc24_.s;
            _loc16_ = int(_loc22_.length);
            _loc22_.position = 0;
            _loc29_ = _loc11_;
            _loc30_ = _loc7_;
            if(!param4)
            {
               while(_loc22_.position < _loc16_)
               {
                  _loc25_ = int(_loc22_.readUnsignedByte());
                  _loc18_ = 1;
                  if((_loc25_ & 0x80) == 128)
                  {
                     _loc25_ &= 127;
                     _loc18_ = _loc22_.readUnsignedByte() + 1;
                  }
                  if(_loc25_ == 0)
                  {
                     _loc29_ += _loc18_;
                     if(_loc29_ >= _loc28_)
                     {
                        _loc18_ = _loc29_ - _loc28_;
                        _loc29_ = _loc11_ + _loc18_ % _loc19_;
                        _loc30_ += _loc18_ / _loc19_ + 1;
                     }
                  }
                  else
                  {
                     _loc13_ = uint(_loc25_ << _loc12_);
                     _loc13_ = uint(_loc13_ + 24);
                     if(_loc13_ > 255)
                     {
                        _loc14_ = 1;
                     }
                     else
                     {
                        _loc14_ = _loc13_ / 255;
                     }
                     while(--_loc18_ > -1)
                     {
                        _loc15_ = _loc6_.getPixel32(_loc29_,_loc30_);
                        if(_loc15_ != 0)
                        {
                           _loc26_ = _loc15_ >> 24 & 0xFF;
                           _loc31_ = (_loc15_ >> 16 & 0xFF) * _loc14_;
                           _loc20_ = (_loc15_ >> 8 & 0xFF) * _loc14_;
                           _loc8_ = (_loc15_ & 0xFF) * _loc14_;
                           _loc23_ = uint(_loc26_ << 24 | _loc31_ << 16 | _loc20_ << 8 | _loc8_);
                           _loc6_.setPixel32(_loc29_,_loc30_,_loc23_);
                        }
                        if(++_loc29_ == _loc28_)
                        {
                           _loc29_ = _loc11_;
                           _loc30_++;
                        }
                     }
                  }
               }
            }
            else
            {
               _loc9_ = _bmax.x - _bmin.x;
               while(_loc22_.position < _loc16_)
               {
                  _loc25_ = int(_loc22_.readUnsignedByte());
                  _loc18_ = 1;
                  if((_loc25_ & 0x80) == 128)
                  {
                     _loc25_ &= 127;
                     _loc18_ = _loc22_.readUnsignedByte() + 1;
                  }
                  if(_loc25_ == 0)
                  {
                     _loc29_ += _loc18_;
                     if(_loc29_ >= _loc28_)
                     {
                        _loc18_ = _loc29_ - _loc28_;
                        _loc29_ = _loc11_ + _loc18_ % _loc19_;
                        _loc30_ += _loc18_ / _loc19_ + 1;
                     }
                  }
                  else
                  {
                     _loc13_ = uint(_loc25_ << _loc12_);
                     _loc13_ = uint(_loc13_ + 24);
                     if(_loc13_ > 255)
                     {
                        _loc14_ = 1;
                     }
                     else
                     {
                        _loc14_ = _loc13_ / 255;
                     }
                     while(--_loc18_ > -1)
                     {
                        _loc15_ = _loc6_.getPixel32(_loc9_ - _loc29_,_loc30_);
                        if(_loc15_ != 0)
                        {
                           _loc26_ = _loc15_ >> 24 & 0xFF;
                           _loc31_ = (_loc15_ >> 16 & 0xFF) * _loc14_;
                           _loc20_ = (_loc15_ >> 8 & 0xFF) * _loc14_;
                           _loc8_ = (_loc15_ & 0xFF) * _loc14_;
                           _loc23_ = uint(_loc26_ << 24 | _loc31_ << 16 | _loc20_ << 8 | _loc8_);
                           _loc6_.setPixel32(_loc9_ - _loc29_,_loc30_,_loc23_);
                        }
                        if(++_loc29_ == _loc28_)
                        {
                           _loc29_ = _loc11_;
                           _loc30_++;
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
         var _loc5_:int = param1;
         var _loc6_:int = param2;
         if(!this.bitmapData)
         {
            param3 = true;
         }
         var _loc4_:Rectangle = new Rectangle(0,0,_loc5_,_loc6_);
         var _loc7_:ByteArray = null;
         if(!param3)
         {
            _loc7_ = this.bitmapData.getPixels(_loc4_);
         }
         if(this.bitmapData)
         {
            this.bitmapData.dispose();
         }
         this.bitmapData = new BitmapData(param1,param2,true,0);
         if(!param3)
         {
            this.bitmapData.setPixels(_loc4_,_loc7_);
         }
      }
   }
}

