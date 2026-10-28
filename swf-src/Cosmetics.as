package avatar
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import loader.MediaHelper;

   // Meadow's cosmetics, bought with Earth Crystals (lib/cosmetics.js on the
   // server): what is drawn round a player's animal, and behind it on their
   // player card. the server says what each animal wears ("xcs" [who,
   // outline 0 none / 1 a colour / 2 rainbow, its colour, glow colour or -1])
   // whenever the animal is shown; this keeps it, and puts it on the animal
   // when it is drawn (AvatarWorldView) and at once if it is drawn already.
   // the game's own thin outline stays the first of the animal's filters
   // (AvatarWorldView.setBlendColor colours it); these go after it.
   public class Cosmetics
   {
      private static const OUTLINE_COLOUR:int = 1;
      private static const OUTLINE_RAINBOW:int = 2;
      // the wallpaper's right side is all pattern (its middle has the
      // wall's post area): that strip, 240 of its 881 pixels, is the card's
      private static const STRIP_X:Number = 641;
      private static const STRIP_W:Number = 240;

      private static var _looks:Object = {};
      private static var _rainbow:Shape;
      private static var _hue:Number = 0;
      private static var _cardWaiting:Object = {};

      public function Cosmetics()
      {
         super();
      }

      // "xcs" [.., .., who, outline, colour, glow]
      public static function onLook(param1:Object) : void
      {
         var _loc2_:int = int(param1[2]);
         _looks[_loc2_] = {
            "outline":int(param1[3]),
            "colour":uint(param1[4]),
            "glow":int(param1[5])
         };
         var _loc3_:AvatarWorldView = AvatarManager.avatarViewList[_loc2_] as AvatarWorldView;
         if(_loc3_)
         {
            applyTo(_loc3_);
         }
         watchRainbow();
      }

      // the filters an animal wears, after the game's own outline
      public static function filtersFor(param1:int) : Array
      {
         var _loc2_:Object = _looks[param1];
         var _loc3_:Array = [];
         if(_loc2_ == null)
         {
            return _loc3_;
         }
         if(_loc2_.outline == OUTLINE_COLOUR)
         {
            _loc3_.push(new GlowFilter(_loc2_.colour,1,4,4,12,1));
         }
         else if(_loc2_.outline == OUTLINE_RAINBOW)
         {
            _loc3_.push(new GlowFilter(hueColour(_hue + param1 * 37),1,4,4,12,1));
         }
         if(_loc2_.glow >= 0)
         {
            _loc3_.push(new GlowFilter(uint(_loc2_.glow),0.9,22,22,2.4,2));
         }
         return _loc3_;
      }

      public static function applyTo(param1:AvatarWorldView) : void
      {
         if(param1 != null)
         {
            param1.wearCosmetics(filtersFor(param1.userId));
         }
      }

      // rainbow outlines turn through the colours, a few times a second
      private static function watchRainbow() : void
      {
         var _loc1_:Boolean = false;
         for each(var _loc2_:Object in _looks)
         {
            if(_loc2_.outline == OUTLINE_RAINBOW)
            {
               _loc1_ = true;
            }
         }
         if(_loc1_ && _rainbow == null)
         {
            _rainbow = new Shape();
            _rainbow.addEventListener("enterFrame",onRainbow,false,0,true);
         }
         else if(!_loc1_ && _rainbow != null)
         {
            _rainbow.removeEventListener("enterFrame",onRainbow);
            _rainbow = null;
         }
      }

      private static function onRainbow(param1:Event) : void
      {
         _hue = (_hue + 4) % 360;
         for(var _loc2_:Object in _looks)
         {
            if(_looks[_loc2_].outline == OUTLINE_RAINBOW)
            {
               applyTo(AvatarManager.avatarViewList[int(_loc2_)] as AvatarWorldView);
            }
         }
      }

      // a fully bright colour at this hue (degrees)
      private static function hueColour(param1:Number) : uint
      {
         var _loc2_:Number = (param1 % 360 + 360) % 360 / 60;
         var _loc3_:Number = 1 - Math.abs(_loc2_ % 2 - 1);
         var _loc4_:Array = _loc2_ < 1 ? [1,_loc3_,0] : (_loc2_ < 2 ? [_loc3_,1,0] : (_loc2_ < 3 ? [0,1,_loc3_] : (_loc2_ < 4 ? [0,_loc3_,1] : (_loc2_ < 5 ? [_loc3_,0,1] : [1,0,_loc3_]))));
         return uint(_loc4_[0] * 255) << 16 | uint(_loc4_[1] * 255) << 8 | uint(_loc4_[2] * 255);
      }

      // ---- the player card's background ----

      // asks the server what is behind `param1`'s animal on their card;
      // `param2(clip)` gets the wallpaper's strip, ready to go behind it, or
      // nothing is called when they have none.
      public static function cardBackground(param1:String, param2:Function) : void
      {
         _cardWaiting[param1.toLowerCase()] = param2;
         gMainFrame.server.setXtObject_Str("xcb",[param1]);
      }

      // "xcb" [.., .., username, media]
      public static function onCard(param1:Object) : void
      {
         var key:String = String(param1[2]).toLowerCase();
         var media:int = int(param1[3]);
         var done:Function = _cardWaiting[key];
         delete _cardWaiting[key];
         if(done == null || media <= 0)
         {
            return;
         }
         var helper:MediaHelper = new MediaHelper();
         helper.init(media,function(param1:MovieClip):void
         {
            var _loc2_:DisplayObject = null;
            var _loc3_:int = 0;
            if(param1 == null)
            {
               return;
            }
            // the wallpaper: its pattern is its first part; the wall's
            // photo frame, post area and the like go
            var _loc4_:MovieClip = param1.numChildren > 0 && param1.getChildAt(0) is MovieClip ? MovieClip(param1.getChildAt(0)) : param1;
            _loc3_ = _loc4_.numChildren - 1;
            while(_loc3_ >= 1)
            {
               _loc4_.getChildAt(_loc3_).visible = false;
               _loc3_--;
            }
            done(_loc4_);
         });
      }

      // puts `param2` (from cardBackground) into `param1`'s box, the box's
      // own art underneath, filling it with the wallpaper's pattern strip
      public static function fillCardBox(param1:MovieClip, param2:MovieClip, param3:Rectangle) : Sprite
      {
         var _loc4_:Sprite = new Sprite();
         var _loc5_:Number = Math.max(param3.height / 507,param3.width / STRIP_W);
         param2.scaleX = param2.scaleY = _loc5_;
         param2.x = param3.x - STRIP_X * _loc5_;
         param2.y = param3.y + (param3.height - 507 * _loc5_) / 2;
         _loc4_.addChild(param2);
         var _loc6_:Shape = new Shape();
         _loc6_.graphics.beginFill(0);
         _loc6_.graphics.drawRoundRect(param3.x,param3.y,param3.width,param3.height,24,24);
         _loc6_.graphics.endFill();
         _loc4_.addChild(_loc6_);
         param2.mask = _loc6_;
         _loc4_.mouseEnabled = _loc4_.mouseChildren = false;
         return _loc4_;
      }
   }
}
