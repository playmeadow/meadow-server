package gui
{
   import avmplus.getQualifiedClassName;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class EmoticonUtility
   {
      
      private static var displaySprites:Array = ["emoMO_angry_sml","emoMO_combat_sml","emoMO_confused_sml","emoMO_laugh_sml","emoMO_phantom_sml","emoMO_sad_sml","emoMO_sleep_sml","emoMO_heartbreak_sml","emoMO_lovesick_sml","emoMO_ninja_sml","emoMO_sick_sml","emoMO_smiley_sml","emoMO_sunglasses_sml","emoMO_vampire_sml","emo_peace_sml","emo_angry_sml","emo_blush_sml","emo_confused_sml","emo_cool_sml","emo_cry_sml","emo_evil_sml","emo_grin_sml","emo_happy_sml","emo_laugh_sml","emo_love_sml","emo_rainy_sml","emo_sick_sml","emo_sleep_sml","emo_sneaky_sml","emo_surprise_sml","emo_think_sml","emo_tongue_sml","emo_wink_sml","emo_game_sml","emo_hearts_sml","emo_brokenHeart_sml","emo_burger_sml","emo_icecream_sml","emo_sword_sml","emo_star1_sml","emo_star2_sml","emo_star3_sml"];
      
      private static var emoteSprites:Array = ["emoMO_angry","emoMO_combat","emoMO_confused","emoMO_laugh","emoMO_phantom","emoMO_sad","emoMO_sleep","emoMO_heartbreak","emoMO_lovesick","emoMO_ninja","emoMO_sick","emoMO_smiley","emoMO_sunglasses","emoMO_vampire","emo_peace","emo_angry","emo_blush","emo_confused","emo_cool","emo_cry","emo_evil","emo_grin","emo_happy","emo_laugh","emo_love","emo_rainy","emo_sick","emo_sleep","emo_sneaky","emo_surprise","emo_think","emo_tongue","emo_wink","emo_game","emo_hearts","emo_brokenHeart","emo_burger","emo_icecream","emo_sword","emo_star1","emo_star2","emo_star3"];
      
      private static var _emoteStrings:Object = new Object();
      
      private static var _emoteChatStrings:Object = new Object();
      
      private static const MEMBER_EMOTES_WINDOW_OFFSET_Y:Number = -70;
      
      private static const MEMBER_EMOTES_ROWS:int = 2;
      
      private static const EMOTES_MARGIN_TOP:int = 14;
      
      private static const EMOTES_MARGIN_LEFT:int = 11;
      
      private static const EMOTES_STEP_V:int = 23;
      
      private static const EMOTES_STEP_H:int = 33;
      
      private static const EMOTES_ROW_MAX:uint = 7;
      
      private static const EMOTES_WINDOW_OFFSET_X:Number = -109;
      
      private static const EMOTES_WINDOW_OFFSET_Y:Number = -55;
      
      private static const NUM_MEMBER_EMOTES:int = 14;
      
      _emoteStrings["emoMO_angry"] = [":mad:"];
      _emoteStrings["emoMO_combat"] = [":scuffle:"];
      _emoteStrings["emoMO_confused"] = [":puzzle:"];
      _emoteStrings["emoMO_laugh"] = [":joy:"];
      _emoteStrings["emoMO_phantom"] = [":phantom:"];
      _emoteStrings["emoMO_sad"] = [":sad:"];
      _emoteStrings["emoMO_sleep"] = [":sleepy:"];
      _emoteStrings["emoMO_heartbreak"] = [":breakingheart:"];
      _emoteStrings["emoMO_lovesick"] = [":lovesick:"];
      _emoteStrings["emoMO_ninja"] = [":ninja:"];
      _emoteStrings["emoMO_sick"] = [":queasy:"];
      _emoteStrings["emoMO_smiley"] = [":smiley:"];
      _emoteStrings["emoMO_sunglasses"] = [":sunglasses:"];
      _emoteStrings["emoMO_vampire"] = [":vampire:"];
      _emoteStrings["emo_peace"] = [":peace:"];
      _emoteStrings["emo_angry"] = [":angry:","X(","X-("];
      _emoteStrings["emo_blush"] = [":blush:"];
      _emoteStrings["emo_brokenHeart"] = [":brokenheart:"];
      _emoteStrings["emo_burger"] = [":burger:"];
      _emoteStrings["emo_confused"] = [":confused:",":/"];
      _emoteStrings["emo_cool"] = [":cool:"];
      _emoteStrings["emo_cry"] = [":cry:"];
      _emoteStrings["emo_evil"] = [":evil:"];
      _emoteStrings["emo_game"] = [":game:"];
      _emoteStrings["emo_grin"] = [":D",":grin:"];
      _emoteStrings["emo_happy"] = [":)",":happy:"];
      _emoteStrings["emo_hearts"] = [":hearts:","<3<3<3"];
      _emoteStrings["emo_icecream"] = [":icecream:"];
      _emoteStrings["emo_laugh"] = [":laugh:",":))"];
      _emoteStrings["emo_love"] = [":love:","(l)","(L)","(^_^)<3"];
      _emoteStrings["emo_rainy"] = [":rainy:"];
      _emoteStrings["emo_sick"] = [":sick:"];
      _emoteStrings["emo_sleep"] = [":tired:","|)","|-)",":zzz:","-_-","-_-zzz","--_"];
      _emoteStrings["emo_sneaky"] = [":sneaky:"];
      _emoteStrings["emo_surprise"] = [":surprise:",":O",":-O"];
      _emoteStrings["emo_sword"] = [":sword:"];
      _emoteStrings["emo_think"] = [":think:",":?"];
      _emoteStrings["emo_tongue"] = [":P",":p",":tongue:"];
      _emoteStrings["emo_wink"] = [":wink:",";)",";-)"];
      _emoteStrings["emo_star1"] = [":singlestar:"];
      _emoteStrings["emo_star2"] = [":doublestar:"];
      _emoteStrings["emo_star3"] = [":triplestar:"];
      _emoteChatStrings["emo_happy"] = [":happy:"];
      
      public function EmoticonUtility()
      {
         super();
      }
      
      public static function setupEmotes(param1:MovieClip, param2:Boolean, param3:Function, param4:Function, param5:Function) : MovieClip
      {
         var _loc9_:Sprite = null;
         var _loc6_:int = param2 ? 0 : int(EMOTES_ROW_MAX * MEMBER_EMOTES_ROWS);
         var _loc7_:MovieClip = new MovieClip();
         var _loc8_:uint = 0;
         for(; _loc8_ < displaySprites.length; _loc8_++)
         {
            _loc9_ = new (getDefinitionByName(displaySprites[_loc8_]) as Class)();
            if(_loc8_ < EMOTES_ROW_MAX * MEMBER_EMOTES_ROWS)
            {
               if(!param2)
               {
                  continue;
               }
               _loc9_.x = EMOTES_MARGIN_LEFT + _loc8_ % EMOTES_ROW_MAX * EMOTES_STEP_H + EMOTES_WINDOW_OFFSET_X;
               _loc9_.y = EMOTES_MARGIN_TOP + Math.floor(_loc8_ / EMOTES_ROW_MAX) * EMOTES_STEP_V + MEMBER_EMOTES_WINDOW_OFFSET_Y;
            }
            else
            {
               _loc9_.x = EMOTES_MARGIN_LEFT + _loc8_ % EMOTES_ROW_MAX * EMOTES_STEP_H + EMOTES_WINDOW_OFFSET_X;
               _loc9_.y = EMOTES_MARGIN_TOP + Math.floor((_loc8_ - _loc6_) / EMOTES_ROW_MAX) * EMOTES_STEP_V + EMOTES_WINDOW_OFFSET_Y;
            }
            _loc7_.addChild(_loc9_);
            _loc9_.addChild(new (getDefinitionByName("emo_place_holder") as Class)());
            _loc9_.buttonMode = true;
            _loc9_.useHandCursor = true;
            _loc9_.mouseChildren = false;
            _loc9_.tabEnabled = true;
            _loc9_.tabChildren = false;
            _loc9_.addEventListener(MouseEvent.CLICK,param3,false,0,true);
            _loc9_.addEventListener(MouseEvent.ROLL_OVER,param4,false,0,true);
            _loc9_.addEventListener(MouseEvent.ROLL_OUT,param4,false,0,true);
         }
         return _loc7_;
      }
      
      public static function getEmoteString(param1:Sprite) : String
      {
         if(_emoteStrings[getQualifiedClassName(param1)])
         {
            return _emoteStrings[getQualifiedClassName(param1)][0];
         }
         return null;
      }
      
      public static function matchEmoteString(param1:String) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         for each(_loc3_ in emoteSprites)
         {
            if(_emoteStrings[_loc3_].indexOf(param1) != -1)
            {
               if(_loc3_.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember)
               {
                  UpsellManager.displayPopup(UpsellManager.EMOTES,"useLockedEmote");
                  return {
                     "sprite":null,
                     "status":false
                  };
               }
               return {
                  "sprite":new (getDefinitionByName(_loc3_) as Class)(),
                  "status":true
               };
            }
         }
         return {
            "sprite":null,
            "status":true
         };
      }
      
      public static function emoteForId(param1:int) : Sprite
      {
         if(param1 >= 0 && param1 < emoteSprites.length)
         {
            return new (getDefinitionByName(emoteSprites[param1]) as Class)();
         }
         return null;
      }
      
      public static function idForEmote(param1:Sprite) : int
      {
         return emoteSprites.indexOf(getQualifiedClassName(param1));
      }
      
      public static function stringForId(param1:int) : String
      {
         if(param1 >= 0 && param1 < emoteSprites.length)
         {
            return _emoteStrings[emoteSprites[param1]][0];
         }
         return null;
      }
      
      public static function handleSmileyClick(param1:Object, param2:Function) : void
      {
         var _loc3_:int = displaySprites.indexOf(getQualifiedClassName(param1));
         if(_loc3_ != -1 && _loc3_ < NUM_MEMBER_EMOTES && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup(UpsellManager.EMOTES,"useLockedEmote");
         }
         else
         {
            param2(new (getDefinitionByName(emoteSprites[_loc3_]) as Class)());
         }
      }
      
      public static function formatStringForSmiley(param1:String, param2:int, param3:Array, param4:Boolean) : Object
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:Array = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:MovieClip = null;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc19_:String = null;
         var _loc20_:String = null;
         var _loc21_:int = 0;
         var _loc22_:Array = null;
         var _loc23_:Boolean = false;
         var _loc7_:Array = [];
         for each(_loc5_ in _emoteChatStrings)
         {
            for each(_loc6_ in _loc5_)
            {
               _loc7_ = param1.split(_loc6_);
               if(param4)
               {
                  param1 = _loc7_.join("|*|" + _loc6_);
               }
               else if(_loc7_.length > 1)
               {
                  param1 = "";
                  _loc11_ = 0;
                  while(_loc11_ < _loc7_.length)
                  {
                     _loc10_ = _loc7_[_loc11_];
                     if(_loc11_ == 0 && _loc10_ != " ")
                     {
                        param1 += _loc10_;
                     }
                     else if(!_loc8_)
                     {
                        if(_loc10_ != "" && _loc10_ != " ")
                        {
                           param1 += "|*|" + _loc6_ + _loc10_;
                        }
                        else
                        {
                           param1 += "|*|" + _loc6_;
                        }
                        _loc8_ = true;
                     }
                     else if(_loc10_ != "" && _loc10_ != " ")
                     {
                        param1 += _loc10_;
                     }
                     _loc11_++;
                  }
               }
            }
         }
         _loc12_ = param1.split("|*|");
         if(_loc12_[0] == "")
         {
            _loc12_.shift();
         }
         var _loc13_:String = "false";
         for(_loc6_ in _loc12_)
         {
            if(_loc6_ == "0" && _loc12_[_loc6_] == "")
            {
               _loc13_ = "true";
            }
            for(_loc15_ in _emoteChatStrings)
            {
               for each(_loc14_ in _emoteChatStrings[_loc15_])
               {
                  _loc19_ = _loc12_[_loc6_];
                  if(_loc19_ == "" || _loc19_.charAt() == " ")
                  {
                     break;
                  }
                  _loc18_ = _loc14_;
                  _loc21_ = _loc19_.indexOf(_loc18_);
                  if(_loc21_ != -1)
                  {
                     _loc20_ = "";
                     _loc11_ = 0;
                     while(_loc11_ < _loc14_.length)
                     {
                        _loc20_ += _loc19_.charAt(_loc21_ + _loc11_);
                        _loc11_++;
                     }
                  }
                  if(_loc20_ == _loc18_)
                  {
                     if(_loc15_.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember)
                     {
                        break;
                     }
                     _loc16_ = new (getDefinitionByName(_loc15_ + "_sml") as Class)();
                     _loc16_.y -= 3;
                     if(_loc13_ == "false" && _loc12_[_loc6_].charAt(_loc12_[_loc6_].length - 1) != "")
                     {
                        _loc23_ = true;
                     }
                     if(_loc16_.width <= 20)
                     {
                        _loc17_ = " .";
                     }
                     else if(_loc16_.width <= 22)
                     {
                        _loc17_ = " . ";
                     }
                     else if(_loc16_.width <= 25)
                     {
                        _loc17_ = " .   ";
                     }
                     else
                     {
                        _loc17_ = "  .     ";
                     }
                     _loc12_[_loc6_] = _loc17_ + (_loc23_ == true ? " " : "") + _loc12_[_loc6_].substr(_loc14_.length,_loc12_[_loc6_].length);
                     param3.push({
                        "strindex":param2,
                        "emoticon":_loc16_,
                        "added":false,
                        "smileystart":_loc13_
                     });
                     break;
                  }
               }
            }
            _loc22_ = _loc12_[_loc6_].split("");
            param2 += _loc22_.length;
         }
         return {
            "str":_loc12_.join(""),
            "smileyArray":param3,
            "stringIndex":param2
         };
      }
      
      public static function getSmallSmileyMCForEmoteString(param1:String) : MovieClip
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         loop0:
         for(_loc2_ in _emoteStrings)
         {
            var _loc6_:int = 0;
            var _loc7_:* = _emoteStrings[_loc2_];
            do
            {
               for each(_loc3_ in _loc7_)
               {
               }
               continue loop0;
            }
            while(_loc3_ != param1);
            if(_loc2_.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember)
            {
               return null;
            }
            return new (getDefinitionByName(_loc2_ + "_sml") as Class)();
         }
         return null;
      }
   }
}

