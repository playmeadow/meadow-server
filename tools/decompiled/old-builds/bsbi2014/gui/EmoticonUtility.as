package gui
{
   import avmplus.getQualifiedClassName;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
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
      
      public static function setupEmotes(emoteWindow:MovieClip, useMemberOnlyEmotes:Boolean, emoteDown:Function, emoteOver:Function, emoteOut:Function) : MovieClip
      {
         var b:Sprite = null;
         var EMOTES_NON_MEMBER_OFFSET_INDEX:int = useMemberOnlyEmotes ? 0 : int(EMOTES_ROW_MAX * MEMBER_EMOTES_ROWS);
         var allEmotes:MovieClip = new MovieClip();
         for(var i:uint = 0; i < displaySprites.length; i++)
         {
            b = GETDEFINITIONBYNAME(displaySprites[i]);
            if(i < EMOTES_ROW_MAX * MEMBER_EMOTES_ROWS)
            {
               if(!useMemberOnlyEmotes)
               {
                  continue;
               }
               b.x = EMOTES_MARGIN_LEFT + i % EMOTES_ROW_MAX * EMOTES_STEP_H + EMOTES_WINDOW_OFFSET_X;
               b.y = EMOTES_MARGIN_TOP + Math.floor(i / EMOTES_ROW_MAX) * EMOTES_STEP_V + MEMBER_EMOTES_WINDOW_OFFSET_Y;
            }
            else
            {
               b.x = EMOTES_MARGIN_LEFT + i % EMOTES_ROW_MAX * EMOTES_STEP_H + EMOTES_WINDOW_OFFSET_X;
               b.y = EMOTES_MARGIN_TOP + Math.floor((i - EMOTES_NON_MEMBER_OFFSET_INDEX) / EMOTES_ROW_MAX) * EMOTES_STEP_V + EMOTES_WINDOW_OFFSET_Y;
            }
            allEmotes.addChild(b);
            b.addChild(GETDEFINITIONBYNAME("emo_place_holder"));
            b.buttonMode = true;
            b.useHandCursor = true;
            b.mouseChildren = false;
            b.tabEnabled = true;
            b.tabChildren = false;
            b.addEventListener(MouseEvent.CLICK,emoteDown,false,0,true);
            b.addEventListener(MouseEvent.ROLL_OVER,emoteOver,false,0,true);
            b.addEventListener(MouseEvent.ROLL_OUT,emoteOver,false,0,true);
         }
         return allEmotes;
      }
      
      public static function getEmoteString(emote:Sprite) : String
      {
         if(Boolean(_emoteStrings[getQualifiedClassName(emote)]))
         {
            return _emoteStrings[getQualifiedClassName(emote)][0];
         }
         return null;
      }
      
      public static function matchEmoteString(emoteStr:String) : Object
      {
         var obj:Object = null;
         var ec:String = null;
         for each(ec in emoteSprites)
         {
            if(_emoteStrings[ec].indexOf(emoteStr) != -1)
            {
               if(ec.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember)
               {
                  UpsellManager.displayPopup(UpsellManager.EMOTES,"useLockedEmote");
                  return {
                     "sprite":null,
                     "status":false
                  };
               }
               return {
                  "sprite":GETDEFINITIONBYNAME(ec),
                  "status":true
               };
            }
         }
         return {
            "sprite":null,
            "status":true
         };
      }
      
      public static function doesStringMatchAnEmote(emoteStr:String) : Boolean
      {
         var ec:String = null;
         for each(ec in emoteSprites)
         {
            if(_emoteStrings[ec].indexOf(emoteStr) != -1)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function emoteForId(emoteId:int) : Sprite
      {
         if(emoteId >= 0 && emoteId < emoteSprites.length)
         {
            return GETDEFINITIONBYNAME(emoteSprites[emoteId]);
         }
         return null;
      }
      
      public static function idForEmote(emote:Sprite) : int
      {
         return emoteSprites.indexOf(getQualifiedClassName(emote));
      }
      
      public static function stringForId(emoteId:int) : String
      {
         if(emoteId >= 0 && emoteId < emoteSprites.length)
         {
            return _emoteStrings[emoteSprites[emoteId]][0];
         }
         return null;
      }
      
      public static function handleSmileyClick(target:Object, setEmoteCallback:Function) : void
      {
         var index:int = displaySprites.indexOf(getQualifiedClassName(target));
         if(index != -1 && index < NUM_MEMBER_EMOTES && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup(UpsellManager.EMOTES,"useLockedEmote");
         }
         else
         {
            setEmoteCallback(GETDEFINITIONBYNAME(emoteSprites[index]));
         }
      }
      
      public static function formatStringForSmiley(str:String, stringIndex:int, smileyArray:Array, allowMultiples:Boolean) : Object
      {
         var emoteArray:Array = null;
         var s:String = null;
         var hasFoundEmote:Boolean = false;
         var hasRemoved:Boolean = false;
         var currString:String = null;
         var i:int = 0;
         var strArray:Array = null;
         var smiley:String = null;
         var emoteString:String = null;
         var smileyMC:MovieClip = null;
         var smileySpacer:String = null;
         var smileyTempString:String = null;
         var emoteTempString:String = null;
         var emoteBuildString:String = null;
         var emoteIndex:int = 0;
         var counter:Array = null;
         var addAdditionalSpace:Boolean = false;
         var splitString:Array = [];
         for each(emoteArray in _emoteChatStrings)
         {
            for each(s in emoteArray)
            {
               splitString = str.split(s);
               if(allowMultiples)
               {
                  str = splitString.join("|*|" + s);
               }
               else if(splitString.length > 1)
               {
                  str = "";
                  for(i = 0; i < splitString.length; i++)
                  {
                     currString = splitString[i];
                     if(i == 0 && currString != " ")
                     {
                        str += currString;
                     }
                     else if(!hasFoundEmote)
                     {
                        if(currString != "" && currString != " ")
                        {
                           str += "|*|" + s + currString;
                        }
                        else
                        {
                           str += "|*|" + s;
                        }
                        hasFoundEmote = true;
                     }
                     else if(currString != "" && currString != " ")
                     {
                        str += currString;
                     }
                  }
               }
            }
         }
         strArray = str.split("|*|");
         if(strArray[0] == "")
         {
            strArray.shift();
         }
         var smileystart:String = "false";
         for(s in strArray)
         {
            if(s == "0" && strArray[s] == "")
            {
               smileystart = "true";
            }
            for(emoteString in _emoteChatStrings)
            {
               for each(smiley in _emoteChatStrings[emoteString])
               {
                  emoteTempString = strArray[s];
                  if(emoteTempString == "" || emoteTempString.charAt() == " ")
                  {
                     break;
                  }
                  smileyTempString = smiley;
                  emoteIndex = emoteTempString.indexOf(smileyTempString);
                  if(emoteIndex != -1)
                  {
                     emoteBuildString = "";
                     for(i = 0; i < smiley.length; i++)
                     {
                        emoteBuildString += emoteTempString.charAt(emoteIndex + i);
                     }
                  }
                  if(emoteBuildString == smileyTempString)
                  {
                     if(emoteString.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember)
                     {
                        break;
                     }
                     smileyMC = GETDEFINITIONBYNAME(emoteString + "_sml");
                     smileyMC.y -= 3;
                     if(smileystart == "false" && strArray[s].charAt(strArray[s].length - 1) != "")
                     {
                        addAdditionalSpace = true;
                     }
                     if(smileyMC.width <= 20)
                     {
                        smileySpacer = " .";
                     }
                     else if(smileyMC.width <= 22)
                     {
                        smileySpacer = " . ";
                     }
                     else if(smileyMC.width <= 25)
                     {
                        smileySpacer = " .   ";
                     }
                     else
                     {
                        smileySpacer = "  .     ";
                     }
                     strArray[s] = smileySpacer + (addAdditionalSpace == true ? " " : "") + strArray[s].substr(smiley.length,strArray[s].length);
                     smileyArray.push({
                        "strindex":stringIndex,
                        "emoticon":smileyMC,
                        "added":false,
                        "smileystart":smileystart
                     });
                     break;
                  }
               }
            }
            counter = strArray[s].split("");
            stringIndex += counter.length;
         }
         return {
            "str":strArray.join(""),
            "smileyArray":smileyArray,
            "stringIndex":stringIndex
         };
      }
      
      public static function getSmallSmileyMCForEmoteString(emoteStr:String) : MovieClip
      {
         var s:String = null;
         var smiley:String = null;
         loop0:
         for(s in _emoteStrings)
         {
            var _loc6_:int = 0;
            var _loc7_:* = _emoteStrings[s];
            do
            {
               for each(smiley in _loc7_)
               {
               }
               continue loop0;
            }
            while(smiley != emoteStr);
            if(s.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember)
            {
               return null;
            }
            return GETDEFINITIONBYNAME(s + "_sml");
         }
         return null;
      }
   }
}

