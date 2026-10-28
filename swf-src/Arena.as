package quest
{
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Rectangle;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   import gui.GuiManager;
   import item.Item;
   import item.ItemXtCommManager;
   import room.RoomManagerWorld;

   // Meadow's arena (lib/arena.js on the server): two against two with the
   // weapons the players own. not in the game: the server speaks to it with
   // "xar" messages (XtReplyDemuxer hands them here), and it answers the
   // same way. what it draws: the deck window before the first round, the
   // card bar with the elixir meter, the score, the countdown and what
   // happened. the swipes and shots are the game's own
   // (QuestManager.swipeMelee, launchProjectile), and whether one reached
   // a player of the other team is worked out here and told to the server,
   // which decides what it does.
   //
   // playing: keys 1 to 4 play that card toward the mouse; or a card is
   // clicked, then a place in the room. walking is as always.
   public class Arena
   {
      public static const DEF_ID:int = 9100;

      private static const CREAM:uint = 0xFFF4DA;
      private static const PAPER:uint = 0xFBE7BE;
      private static const BROWN:uint = 0x6B3E1B;
      private static const DARK:uint = 0x3B2210;
      private static const PURPLE:uint = 0x9D00FF;
      private static const PURPLE_DARK:uint = 0x5C0096;
      private static const TEAM_COLOURS:Array = [0x9D00FF,0xE8711C];
      private static const ELIXIR_MAX:int = 10;
      private static const ELIXIR_EVERY:Number = 1.4;
      private static const MELEE_REACH:Number = 95;
      private static const MELEE_RADIUS:Number = 105;
      private static const SHOT_SPEED:Number = 650;
      private static const SHOT_RANGE:Number = 720;
      private static const SHOT_RADIUS:Number = 45;
      private static const BODY_X:Number = -15;
      private static const BODY_Y:Number = -40;

      private static var _active:Boolean;
      private static var _layer:Sprite;
      private static var _myTeam:int = -1;
      private static var _teams:Object;
      private static var _names:Object;

      // each player's arena level, by id, beside their name in the score bar
      private static var _levels:Object;

      // the score bar as last shown: [round, team 0's wins, team 1's]
      private static var _score:Array = [0,0,0];
      private static var _gone:Object;
      private static var _cards:Array;
      private static var _cardViews:Array;
      private static var _armed:int = -1;
      private static var _elixir:Number = 0;
      private static var _elixirAt:int;
      private static var _fighting:Boolean;
      
      private static var _down:Boolean;
      
      private static var _stake:int;
      
      private static var _level:int;
      private static var _pending:Array;
      private static var _swings:Array;
      private static var _deckWindow:Sprite;
      private static var _deckOffer:Array;
      private static var _deckChosen:Array;
      private static var _deckEnds:int;
      private static var _deckTimeText:TextField;
      private static var _deckSlots:Sprite;
      private static var _bar:Sprite;
      private static var _elixirFill:Shape;
      private static var _elixirText:TextField;
      private static var _scoreText:TextField;
      private static var _bigText:TextField;
      private static var _bigUntil:int;
      private static var _subText:TextField;
      private static var _roundEnds:int;
      private static var _lastFrame:int;

      public function Arena()
      {
         super();
      }

      public static function get active() : Boolean
      {
         return _active;
      }
      
      // no walking: before the fight (the deck, the count) and while down
      public static function get frozen() : Boolean
      {
         return _active && (!_fighting || _down);
      }

      // ---- messages from the server ----

      public static function onMessage(param1:Object) : void
      {
         var _loc2_:Array = [];
         var _loc3_:int = 2;
         while(_loc3_ < param1.length)
         {
            _loc2_.push(param1[_loc3_]);
            _loc3_++;
         }
         var _loc4_:String = String(_loc2_.shift());
         try
         {
            if(_loc4_ == "team")
            {
               onTeams(_loc2_);
            }
            else if(!_active)
            {
               return;
            }
            if(_loc4_ == "spawn")
            {
               onSpawn(int(_loc2_[0]),int(_loc2_[1]));
            }
            else if(_loc4_ == "deck")
            {
               openDeckWindow(int(_loc2_[0]),_loc2_.slice(2));
            }
            else if(_loc4_ == "cards")
            {
               onCards(_loc2_);
            }
            else if(_loc4_ == "round")
            {
               onRound(int(_loc2_[0]),int(_loc2_[1]),int(_loc2_[2]),int(_loc2_[3]));
            }
            else if(_loc4_ == "count")
            {
               big(String(_loc2_[0]),1000);
            }
            else if(_loc4_ == "fight")
            {
               _fighting = true;
               freeKeys();
               _roundEnds = getTimer() + int(_loc2_[0]) * 1000;
               big("Fight!",1200);
            }
            else if(_loc4_ == "elx")
            {
               setElixir(int(_loc2_[0]) / 10);
            }
            else if(_loc4_ == "play")
            {
               onPlay(int(_loc2_[0]),int(_loc2_[1]),int(_loc2_[2]),int(_loc2_[3]));
            }
            else if(_loc4_ == "no")
            {
               _pending = null;
               setElixir(int(_loc2_[1]) / 10);
            }
            else if(_loc4_ == "down")
            {
               _down = true;
               _armed = -1;
               big("Knocked out!",2500);
               sub("Back up next round.",2500);
               drawElixir();
            }
            else if(_loc4_ == "crit")
            {
               sub("Critical hit on " + nameOf(int(_loc2_[0])) + "!",1500);
            }
            else if(_loc4_ == "gone")
            {
               _gone[int(_loc2_[0])] = true;
               sub(nameOf(int(_loc2_[0])) + " left the arena.",2500);
            }
            else if(_loc4_ == "end")
            {
               onEnd(int(_loc2_[0]),int(_loc2_[1]),int(_loc2_[2]),int(_loc2_[3]),int(_loc2_[4]));
            }
            else if(_loc4_ == "level")
            {
               // [arena level, levelled up just now, this match for fun]
               _level = int(_loc2_[0]);
               if(int(_loc2_[1]) == 1)
               {
                  sub("Arena level " + _level + "!",3000);
               }
               if(_loc2_.length > 2 && int(_loc2_[2]) == 1)
               {
                  sub("Your levels are far apart: this match is for fun, with no battle XP.",6000);
               }
            }
            else if(_loc4_ == "levels")
            {
               // [id, arena level for each player]
               _loc3_ = 0;
               while(_loc3_ + 1 < _loc2_.length)
               {
                  _levels[int(_loc2_[_loc3_])] = int(_loc2_[_loc3_ + 1]);
                  _loc3_ += 2;
               }
               showScore(_score[0],_score[1],_score[2]);
            }
            else if(_loc4_ == "stake")
            {
               _stake = int(_loc2_[0]);
               showScore(0,0,0);
            }
         }
         catch(e:Error)
         {
            trace("arena " + _loc4_ + ": " + e.getStackTrace());
         }
      }

      // who is on which team: [mine, then id, team, name for each]
      private static function onTeams(param1:Array) : void
      {
         start();
         _myTeam = int(param1[0]);
         var _loc2_:int = 1;
         while(_loc2_ + 2 < param1.length)
         {
            _teams[int(param1[_loc2_])] = int(param1[_loc2_ + 1]);
            _names[int(param1[_loc2_])] = String(param1[_loc2_ + 2]);
            _loc2_ += 3;
         }
         showScore(0,0,0);
      }

      private static function onSpawn(param1:int, param2:int) : void
      {
         if(RoomManagerWorld.instance)
         {
            RoomManagerWorld.instance.teleportPlayer(param1,param2,true);
         }
      }

      private static function onRound(param1:int, param2:int, param3:int, param4:int) : void
      {
         _fighting = false;
         _down = false;
         _pending = null;
         _armed = -1;
         closeDeckWindow();
         showScore(param1,param2,param3);
         if(param4 < 0)
         {
            setElixir(5);
            big("Round " + param1,1400);
         }
         else
         {
            big(param4 == _myTeam ? "Round won!" : "Round lost",2200);
         }
         drawCards();
      }

      // [winner, score, score, battle XP, Earth Crystals]: both changes
      // with their sign
      private static function onEnd(param1:int, param2:int, param3:int, param4:int, param5:int) : void
      {
         _fighting = false;
         showScore(-1,param2,param3);
         big(param1 == _myTeam ? "Victory!" : "Defeat",8000);
         sub((param4 >= 0 ? "+" : "") + param4 + " battle XP" + (param5 != 0 ? "     " + (param5 > 0 ? "+" : "") + param5 + " Earth Crystals" : "") + (_level > 0 ? "     Arena level " + _level : ""),8000);
      }

      // ---- the arena opened and closed ----

      private static function start() : void
      {
         stop();
         _active = true;
         _teams = {};
         _names = {};
         _levels = {};
         _gone = {};
         _stake = 0;
         _cards = [];
         _swings = [];
         _elixir = 5;
         _elixirAt = getTimer();
         _lastFrame = getTimer();
         _layer = new Sprite();
         GuiManager.guiLayer.addChild(_layer);
         _scoreText = text(18,CREAM,true,"center");
         _scoreText.x = 100;
         _scoreText.y = 66;
         _scoreText.width = 700;
         _layer.addChild(_scoreText);
         _bigText = text(54,CREAM,true,"center");
         _bigText.x = 150;
         _bigText.y = 170;
         _bigText.width = 600;
         _layer.addChild(_bigText);
         _subText = text(18,CREAM,true,"center");
         _subText.x = 150;
         _subText.y = 240;
         _subText.width = 600;
         _layer.addChild(_subText);
         _layer.addEventListener("enterFrame",onFrame,false,0,true);
         gMainFrame.stage.addEventListener("keyDown",onKey,false,0,true);
         gMainFrame.stage.addEventListener("textInput",onTextInput,true,0,true);
      }

      private static function stop() : void
      {
         if(_layer)
         {
            _layer.removeEventListener("enterFrame",onFrame);
            if(_layer.parent)
            {
               _layer.parent.removeChild(_layer);
            }
            gMainFrame.stage.removeEventListener("keyDown",onKey);
            gMainFrame.stage.removeEventListener("textInput",onTextInput,true);
         }
         closeDeckWindow();
         _layer = null;
         _bar = null;
         _active = false;
         _fighting = false;
         _pending = null;
      }

      // how much bigger than usual the room is drawn: the arena's, so its
      // players are larger (RoomManagerWorld multiplies its zoom by this)
      public static function get zoom() : Number
      {
         return inArena() ? 1.35 : 1;
      }
      
      // the arena is over once the game is somewhere else
      private static function inArena() : Boolean
      {
         return gMainFrame.clientInfo.roomType == 7 && gMainFrame.clientInfo.secondaryDefId == DEF_ID;
      }

      private static function onFrame(param1:Event) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:Number = (_loc2_ - _lastFrame) / 1000;
         _lastFrame = _loc2_;
         if(!inArena() && _loc2_ - _elixirAt > 3000)
         {
            stop();
            return;
         }
         if(_fighting && _elixir < ELIXIR_MAX)
         {
            _elixir = Math.min(ELIXIR_MAX,_elixir + _loc3_ / ELIXIR_EVERY);
            drawElixir();
         }
         if(_bigUntil > 0 && _loc2_ > _bigUntil)
         {
            _bigUntil = 0;
            _bigText.text = "";
            _subText.text = "";
         }
         if(_deckWindow && _deckTimeText)
         {
            _deckTimeText.text = Math.max(0,Math.ceil((_deckEnds - _loc2_) / 1000)) + "s";
         }
         moveSwings(_loc3_);
      }

      // the keys back to the game: focus left on something no longer on the
      // stage (the deck window's Ready button, once it has gone) takes
      // every key press with it, cards included.
      private static function freeKeys() : void
      {
         var _loc1_:Object = gMainFrame.stage.focus;
         if(_loc1_ != null && (!(_loc1_ is DisplayObject) || DisplayObject(_loc1_).stage == null || !(_loc1_ is TextField)))
         {
            gMainFrame.stage.focus = null;
         }
      }
      
      // ---- text and shapes, in the game's colours and its own font ----

      private static function text(param1:int, param2:uint, param3:Boolean, param4:String = "left") : TextField
      {
         var _loc5_:TextField = new TextField();
         var _loc6_:Boolean = AJClient.hasGameFont();
         var _loc7_:TextFormat = new TextFormat(_loc6_ ? "CCDigitalDelivery" : "_sans",param1,param2,param3);
         _loc7_.align = param4;
         _loc5_.embedFonts = _loc6_;
         _loc5_.defaultTextFormat = _loc7_;
         _loc5_.selectable = false;
         _loc5_.mouseEnabled = false;
         _loc5_.height = param1 + 10;
         if(param2 == CREAM)
         {
            _loc5_.filters = [new GlowFilter(DARK,1,4,4,8)];
         }
         return _loc5_;
      }

      private static function panel(param1:Number, param2:Number, param3:Number = 18) : Sprite
      {
         var _loc4_:Sprite = new Sprite();
         _loc4_.graphics.lineStyle(4,BROWN);
         _loc4_.graphics.beginFill(CREAM);
         _loc4_.graphics.drawRoundRect(0,0,param1,param2,param3,param3);
         _loc4_.graphics.endFill();
         _loc4_.filters = [new DropShadowFilter(3,90,0,0.45,6,6)];
         return _loc4_;
      }

      private static function big(param1:String, param2:int) : void
      {
         _bigText.text = param1;
         _bigUntil = getTimer() + param2;
      }

      private static function sub(param1:String, param2:int) : void
      {
         _subText.text = param1;
         _bigUntil = Math.max(_bigUntil,getTimer() + param2);
      }

      private static function nameOf(param1:int) : String
      {
         return _names[param1] != null ? _names[param1] : "?";
      }

      private static function teamNames(param1:int) : String
      {
         var _loc2_:Array = [];
         for(var _loc3_:Object in _teams)
         {
            if(_teams[_loc3_] == param1)
            {
               _loc2_.push(_names[_loc3_] + (_levels[_loc3_] != null ? " (Lv " + _levels[_loc3_] + ")" : ""));
            }
         }
         return _loc2_.join(" & ");
      }

      private static function showScore(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:int = _myTeam < 0 ? 0 : _myTeam;
         _score = [param1,param2,param3];
         var _loc5_:String = teamNames(_loc4_) + "   " + (_loc4_ == 0 ? param2 : param3) + " - " + (_loc4_ == 0 ? param3 : param2) + "   " + teamNames(1 - _loc4_);
         _scoreText.text = (param1 > 0 ? "Round " + param1 + "     " : "") + _loc5_ + (_stake > 0 ? "     for " + _stake + " crystals" : "");
      }

      // ---- the deck window ----

      // [seconds, count, then def, cost, damage, heal, ranged for each]
      private static function openDeckWindow(param1:int, param2:Array) : void
      {
         closeDeckWindow();
         _deckOffer = [];
         _deckChosen = [];
         var _loc3_:int = 0;
         while(_loc3_ + 4 < param2.length)
         {
            _deckOffer.push({
               "defId":int(param2[_loc3_]),
               "cost":int(param2[_loc3_ + 1]),
               "damage":int(param2[_loc3_ + 2]),
               "heal":int(param2[_loc3_ + 3]),
               "ranged":int(param2[_loc3_ + 4]) == 1
            });
            _loc3_ += 5;
         }
         _deckOffer.sortOn(["cost","defId"],[Array.NUMERIC,Array.NUMERIC]);
         _deckEnds = getTimer() + param1 * 1000;
         _deckWindow = panel(560,390);
         _deckWindow.x = 170;
         _deckWindow.y = 70;
         var _loc4_:TextField = text(24,BROWN,true,"center");
         _loc4_.text = "Choose your deck";
         _loc4_.width = 560;
         _loc4_.y = 12;
         _deckWindow.addChild(_loc4_);
         var _loc5_:TextField = text(13,DARK,false,"center");
         _loc5_.text = "Pick four of your weapons. Stronger ones cost more elixir.";
         _loc5_.width = 560;
         _loc5_.y = 46;
         _deckWindow.addChild(_loc5_);
         _deckTimeText = text(18,PURPLE,true,"right");
         _deckTimeText.width = 80;
         _deckTimeText.x = 460;
         _deckTimeText.y = 14;
         _deckWindow.addChild(_deckTimeText);
         var _loc6_:Sprite = new Sprite();
         _loc6_.x = 24;
         _loc6_.y = 74;
         var _loc7_:int = 0;
         while(_loc7_ < _deckOffer.length && _loc7_ < 16)
         {
            var _loc8_:Sprite = cardView(_deckOffer[_loc7_],-1,60,72);
            _loc8_.x = _loc7_ % 8 * 64;
            _loc8_.y = int(_loc7_ / 8) * 78;
            _loc8_.name = String(_loc7_);
            _loc8_.buttonMode = true;
            _loc8_.addEventListener("click",onOfferClick,false,0,true);
            _loc6_.addChild(_loc8_);
            _loc7_++;
         }
         _deckWindow.addChild(_loc6_);
         if(_deckOffer.length > 16)
         {
            var _loc9_:TextField = text(11,DARK,false,"center");
            _loc9_.text = "Your 16 cheapest are shown.";
            _loc9_.width = 560;
            _loc9_.y = 230;
            _deckWindow.addChild(_loc9_);
         }
         var _loc10_:TextField = text(14,BROWN,true,"left");
         _loc10_.text = "Your deck";
         _loc10_.x = 24;
         _loc10_.y = 248;
         _deckWindow.addChild(_loc10_);
         _deckSlots = new Sprite();
         _deckSlots.x = 24;
         _deckSlots.y = 272;
         _deckWindow.addChild(_deckSlots);
         drawDeckSlots();
         var _loc11_:Sprite = button("Ready",130,40);
         _loc11_.x = 406;
         _loc11_.y = 300;
         _loc11_.addEventListener("click",onReady,false,0,true);
         _deckWindow.addChild(_loc11_);
         _layer.addChild(_deckWindow);
      }

      private static function closeDeckWindow() : void
      {
         if(_deckWindow && _deckWindow.parent)
         {
            _deckWindow.parent.removeChild(_deckWindow);
            freeKeys();
         }
         _deckWindow = null;
         _deckTimeText = null;
      }

      private static function onOfferClick(param1:MouseEvent) : void
      {
         var _loc2_:Object = _deckOffer[int(param1.currentTarget.name)];
         var _loc3_:int = _deckChosen.indexOf(_loc2_);
         if(_loc3_ >= 0)
         {
            _deckChosen.splice(_loc3_,1);
         }
         else if(_deckChosen.length < 4)
         {
            _deckChosen.push(_loc2_);
         }
         drawDeckSlots();
      }

      private static function drawDeckSlots() : void
      {
         while(_deckSlots.numChildren)
         {
            _deckSlots.removeChildAt(0);
         }
         var _loc1_:int = 0;
         while(_loc1_ < 4)
         {
            var _loc2_:Sprite = _loc1_ < _deckChosen.length ? cardView(_deckChosen[_loc1_],-1,60,72) : emptySlot(60,72);
            _loc2_.x = _loc1_ * 66;
            if(_loc1_ < _deckChosen.length)
            {
               _loc2_.name = String(_loc1_);
               _loc2_.buttonMode = true;
               _loc2_.addEventListener("click",onChosenClick,false,0,true);
            }
            _deckSlots.addChild(_loc2_);
            _loc1_++;
         }
      }

      private static function onChosenClick(param1:MouseEvent) : void
      {
         _deckChosen.splice(int(param1.currentTarget.name),1);
         drawDeckSlots();
      }

      private static function onReady(param1:MouseEvent) : void
      {
         var _loc2_:Array = ["deck"];
         for each(var _loc3_:Object in _deckChosen)
         {
            _loc2_.push(_loc3_.defId);
         }
         gMainFrame.server.setXtObject_Str("xar",_loc2_);
         closeDeckWindow();
         sub("Waiting for the others...",30000);
      }

      private static function button(param1:String, param2:Number, param3:Number) : Sprite
      {
         var _loc4_:Sprite = new Sprite();
         _loc4_.graphics.lineStyle(3,PURPLE_DARK);
         _loc4_.graphics.beginFill(PURPLE);
         _loc4_.graphics.drawRoundRect(0,0,param2,param3,param3,param3);
         _loc4_.graphics.endFill();
         var _loc5_:TextField = text(18,0xFFFFFF,true,"center");
         _loc5_.text = param1;
         _loc5_.width = param2;
         _loc5_.y = (param3 - 26) / 2;
         _loc4_.addChild(_loc5_);
         _loc4_.buttonMode = true;
         _loc4_.mouseChildren = false;
         return _loc4_;
      }

      private static function emptySlot(param1:Number, param2:Number) : Sprite
      {
         var _loc3_:Sprite = new Sprite();
         _loc3_.graphics.lineStyle(2,BROWN,0.5);
         _loc3_.graphics.beginFill(PAPER,0.6);
         _loc3_.graphics.drawRoundRect(0,0,param1,param2,12,12);
         _loc3_.graphics.endFill();
         return _loc3_;
      }

      // a card: the weapon's picture, its cost in a purple drop, and what it
      // does. `key` (0 to 3) is the key that plays it, -1 for none.
      private static function cardView(param1:Object, param2:int, param3:Number, param4:Number) : Sprite
      {
         var _loc5_:Sprite = new Sprite();
         _loc5_.graphics.lineStyle(2,BROWN);
         _loc5_.graphics.beginFill(PAPER);
         _loc5_.graphics.drawRoundRect(0,0,param3,param4,12,12);
         _loc5_.graphics.endFill();
         var _loc6_:Item = new Item();
         _loc6_.init(param1.defId,0,itemColour(param1.defId));
         var _loc7_:Sprite = _loc6_.icon;
         if(_loc7_)
         {
            var _loc12_:Sprite = new Sprite();
            _loc12_.addChild(_loc7_);
            _loc12_.name = "icon";
            _loc5_.addChildAt(_loc12_,0);
            _loc5_.setChildIndex(_loc12_,0);
            fitIcon(_loc12_,param3,param4 - 18);
         }
         var _loc8_:Sprite = new Sprite();
         _loc8_.graphics.lineStyle(2,PURPLE_DARK);
         _loc8_.graphics.beginFill(PURPLE);
         _loc8_.graphics.drawCircle(0,0,11);
         _loc8_.graphics.endFill();
         _loc8_.x = 10;
         _loc8_.y = 10;
         var _loc9_:TextField = text(14,0xFFFFFF,true,"center");
         _loc9_.text = String(param1.cost);
         _loc9_.width = 22;
         _loc9_.x = -11;
         _loc9_.y = -10;
         _loc8_.addChild(_loc9_);
         _loc5_.addChild(_loc8_);
         var _loc10_:TextField = text(11,DARK,true,"center");
         _loc10_.text = param1.heal > 0 ? "+" + param1.heal + " heal" : "-" + param1.damage + (param1.ranged ? " shot" : "");
         _loc10_.width = param3;
         _loc10_.y = param4 - 17;
         _loc5_.addChild(_loc10_);
         if(param2 >= 0)
         {
            var _loc11_:TextField = text(12,BROWN,true,"right");
            _loc11_.text = String(param2 + 1);
            _loc11_.width = param3 - 5;
            _loc11_.y = 1;
            _loc5_.addChild(_loc11_);
         }
         _loc5_.mouseChildren = false;
         return _loc5_;
      }

      // an item's picture comes in a moment later: when it has, it is made
      // to fit the card's middle.
      private static function fitIcon(param1:Sprite, param2:Number, param3:Number) : void
      {
         var holder:Sprite = param1;
         var w:Number = param2;
         var h:Number = param3;
         var tries:int = 0;
         var fit:Function = function(param1:Event):void
         {
            var _loc2_:Rectangle = holder.getChildAt(0).getBounds(holder.getChildAt(0));
            tries++;
            if(_loc2_.width < 2 || _loc2_.height < 2)
            {
               if(tries > 600)
               {
                  holder.removeEventListener("enterFrame",fit);
               }
               return;
            }
            holder.removeEventListener("enterFrame",fit);
            var _loc3_:Number = Math.min(1.2,Math.min((w - 12) / _loc2_.width,(h - 10) / _loc2_.height));
            var _loc4_:DisplayObject = holder.getChildAt(0);
            _loc4_.scaleX = _loc4_.scaleY = _loc3_;
            _loc4_.x = (w - _loc2_.width * _loc3_) / 2 - _loc2_.x * _loc3_;
            _loc4_.y = 4 + (h - _loc2_.height * _loc3_) / 2 - _loc2_.y * _loc3_;
         };
         holder.addEventListener("enterFrame",fit,false,0,true);
      }
      
      // the colour of the player's own one of that item, or its first
      private static function itemColour(param1:int) : uint
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         try
         {
            _loc2_ = AvatarManager.playerAvatar.inventoryClothing.itemCollection;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_.getAccItem(_loc3_).defId == param1)
               {
                  return _loc2_.getAccItem(_loc3_).color;
               }
               _loc3_++;
            }
         }
         catch(e:Error)
         {
         }
         var _loc4_:Object = ItemXtCommManager.getItemDef(param1);
         return _loc4_ && _loc4_.colors && _loc4_.colors.length ? uint(_loc4_.colors[0]) : 0;
      }

      // ---- the card bar ----

      // [def, cost, damage, heal, ranged] for each of the four
      private static function onCards(param1:Array) : void
      {
         _cards = [];
         var _loc2_:int = 0;
         while(_loc2_ + 4 < param1.length)
         {
            _cards.push({
               "defId":int(param1[_loc2_]),
               "cost":int(param1[_loc2_ + 1]),
               "damage":int(param1[_loc2_ + 2]),
               "heal":int(param1[_loc2_ + 3]),
               "ranged":int(param1[_loc2_ + 4]) == 1
            });
            _loc2_ += 5;
         }
         drawCards();
      }

      private static function drawCards() : void
      {
         if(_bar && _bar.parent)
         {
            _bar.parent.removeChild(_bar);
         }
         if(!_cards || _cards.length == 0)
         {
            return;
         }
         _bar = panel(300,112,16);
         _bar.x = 300;
         _bar.y = 376;
         _cardViews = [];
         var _loc1_:int = 0;
         while(_loc1_ < _cards.length)
         {
            var _loc2_:Sprite = cardView(_cards[_loc1_],_loc1_,64,76);
            _loc2_.x = 10 + _loc1_ * 71;
            _loc2_.y = 8;
            _loc2_.name = String(_loc1_);
            _loc2_.buttonMode = true;
            _loc2_.addEventListener("click",onCardClick,false,0,true);
            _bar.addChild(_loc2_);
            _cardViews.push(_loc2_);
            _loc1_++;
         }
         var _loc3_:Shape = new Shape();
         _loc3_.graphics.lineStyle(2,BROWN);
         _loc3_.graphics.beginFill(0x2A1240);
         _loc3_.graphics.drawRoundRect(10,90,280,14,14,14);
         _loc3_.graphics.endFill();
         _bar.addChild(_loc3_);
         _elixirFill = new Shape();
         _bar.addChild(_elixirFill);
         _elixirText = text(12,CREAM,true,"center");
         _elixirText.width = 280;
         _elixirText.x = 10;
         _elixirText.y = 87;
         _bar.addChild(_elixirText);
         _layer.addChildAt(_bar,0);
         drawElixir();
      }

      private static function setElixir(param1:Number) : void
      {
         _elixir = param1;
         _elixirAt = getTimer();
         drawElixir();
      }

      private static function drawElixir() : void
      {
         if(!_elixirFill)
         {
            return;
         }
         _elixirFill.graphics.clear();
         _elixirFill.graphics.beginFill(PURPLE);
         _elixirFill.graphics.drawRoundRect(11,91,Math.max(0,278 * _elixir / ELIXIR_MAX),12,12,12);
         _elixirFill.graphics.endFill();
         _elixirText.text = "Elixir " + Math.floor(_elixir);
         var _loc1_:int = 0;
         while(_cardViews && _loc1_ < _cardViews.length)
         {
            _cardViews[_loc1_].alpha = _elixir >= _cards[_loc1_].cost && _fighting && !_down ? 1 : 0.5;
            _cardViews[_loc1_].y = _loc1_ == _armed ? 0 : 8;
            _loc1_++;
         }
      }

      private static function onCardClick(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.name);
         _armed = _armed == _loc2_ ? -1 : _loc2_;
         drawElixir();
      }

      // ---- playing a card ----

      // the chat box has the keys most of the time: a 1 to 4 typed into it
      // while it is empty plays a card instead (onTextInput keeps the digit
      // out of it). once something is being typed, the keys are the chat's.
      private static function chatBusy() : Boolean
      {
         var _loc1_:TextField = gMainFrame.stage.focus as TextField;
         return _loc1_ != null && _loc1_.text.length > 0;
      }
      
      private static function onTextInput(param1:TextEvent) : void
      {
         if(_active && !chatBusy() && param1.text.length == 1 && "1234".indexOf(param1.text) >= 0)
         {
            param1.preventDefault();
         }
      }
      
      private static function onKey(param1:KeyboardEvent) : void
      {
         if(!_fighting || _down || chatBusy())
         {
            return;
         }
         var _loc2_:int = int(param1.keyCode) - 49;
         if(_loc2_ >= 0 && _loc2_ < 4 && _cards && _loc2_ < _cards.length)
         {
            play(_loc2_,gMainFrame.stage.mouseX,gMainFrame.stage.mouseY);
         }
      }

      // RoomManagerView's mouse down, before anything else has it: with a
      // card picked, the click plays it there instead of walking.
      public static function mouseDown(param1:MouseEvent) : Boolean
      {
         if(frozen)
         {
            return true; // no walking yet: the click is the arena's
         }
         if(!_active || _armed < 0)
         {
            return false;
         }
         var _loc2_:int = _armed;
         _armed = -1;
         play(_loc2_,param1.stageX,param1.stageY);
         drawElixir();
         return true;
      }

      private static function play(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:Object = _cards[param1];
         if(_pending != null || _loc4_ == null || _elixir < _loc4_.cost || !RoomManagerWorld.instance)
         {
            return;
         }
         var _loc5_:AvatarWorldView = AvatarManager.playerAvatarWorldView;
         if(_loc5_ == null)
         {
            return;
         }
         var _loc7_:Point = RoomManagerWorld.instance.convertScreenToWorldSpace(param2,param3);
         _pending = [param1,_loc7_.x,_loc7_.y];
         gMainFrame.server.setXtObject_Str("xar",["play",param1,int(_loc7_.x),int(_loc7_.y)]);
      }

      // [play, slot, weapon, elixir]: the server took the elixir. the swipe
      // or the shot goes off now, toward where was asked.
      private static function onPlay(param1:int, param2:int, param3:int, param4:int) : void
      {
         setElixir(param4 / 10);
         if(_pending == null || _pending[0] != param2)
         {
            return;
         }
         var _loc5_:Object = _cards[param2];
         var _loc6_:Number = _pending[1];
         var _loc7_:Number = _pending[2];
         _pending = null;
         var _loc8_:AvatarWorldView = AvatarManager.playerAvatarWorldView;
         if(_loc8_ == null)
         {
            return;
         }
         var _loc9_:Point = _loc8_.avatarPos;
         _loc8_.faceAnim(_loc6_ - _loc9_.x,_loc7_ - _loc9_.y,false);
         if(_loc5_.heal > 0)
         {
            QuestManager.launchProjectile(param3,itemColour(param3),_loc6_,_loc7_,null,_loc8_);
            return;
         }
         var _loc10_:Number = _loc6_ - _loc9_.x;
         var _loc11_:Number = _loc7_ - _loc9_.y;
         var _loc12_:Number = Math.max(1,Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_));
         if(_loc5_.ranged)
         {
            QuestManager.launchProjectile(param3,itemColour(param3),_loc6_,_loc7_,null,_loc8_);
            _swings.push({
               "play":param1,
               "x":_loc9_.x,
               "y":_loc9_.y,
               "dx":_loc10_ / _loc12_,
               "dy":_loc11_ / _loc12_,
               "travelled":0,
               "hit":{},
               "ranged":true
            });
         }
         else
         {
            QuestManager.swipeMelee(param3,itemColour(param3),_loc6_,_loc7_,null,_loc8_);
            _swings.push({
               "play":param1,
               "x":_loc9_.x + _loc10_ / _loc12_ * MELEE_REACH,
               "y":_loc9_.y + _loc11_ / _loc12_ * MELEE_REACH,
               "wait":0.15,
               "hit":{},
               "ranged":false
            });
         }
      }

      // what the swipes and shots in the air reach
      private static function moveSwings(param1:Number) : void
      {
         var _loc2_:int = _swings.length - 1;
         while(_loc2_ >= 0)
         {
            var _loc3_:Object = _swings[_loc2_];
            var _loc4_:Boolean = false;
            if(_loc3_.ranged)
            {
               var _loc5_:Number = Math.min(SHOT_SPEED * param1,SHOT_RANGE - _loc3_.travelled);
               _loc3_.x += _loc3_.dx * _loc5_;
               _loc3_.y += _loc3_.dy * _loc5_;
               _loc3_.travelled += _loc5_;
               if(reach(_loc3_,SHOT_RADIUS,1) > 0 || _loc3_.travelled >= SHOT_RANGE)
               {
                  _loc4_ = true;
               }
            }
            else
            {
               _loc3_.wait -= param1;
               if(_loc3_.wait <= 0)
               {
                  reach(_loc3_,MELEE_RADIUS,2);
                  _loc4_ = true;
               }
            }
            if(_loc4_)
            {
               _swings.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }

      // the players of the other team within `radius` of the swing, told to
      // the server: at most `most` of them
      private static function reach(param1:Object, param2:Number, param3:int) : int
      {
         var _loc4_:int = 0;
         for(var _loc5_:Object in _teams)
         {
            var _loc6_:int = int(_loc5_);
            if(_teams[_loc6_] == _myTeam || _gone[_loc6_] || param1.hit[_loc6_] || _loc4_ >= param3)
            {
               continue;
            }
            var _loc7_:AvatarWorldView = AvatarManager.avatarViewList[_loc6_];
            if(_loc7_ == null)
            {
               continue;
            }
            var _loc8_:Point = _loc7_.avatarPos;
            var _loc9_:Number = _loc8_.x + BODY_X - param1.x - BODY_X;
            var _loc10_:Number = _loc8_.y + BODY_Y - param1.y - BODY_Y;
            if(_loc9_ * _loc9_ + _loc10_ * _loc10_ < param2 * param2)
            {
               param1.hit[_loc6_] = true;
               _loc4_++;
               gMainFrame.server.setXtObject_Str("xar",["hit",param1.play,_loc6_]);
            }
         }
         return _loc4_;
      }
   }
}
