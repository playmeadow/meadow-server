package com.sbi.prediction
{
   import flash.utils.ByteArray;
   
   public class Predictions
   {
      
      private const CACHE_SIZE:int = 255;
      
      private const VARIANT_FORM_MULTIPLIER:Number = 0.99;
      
      private const PUNCTUATION_INSERTION_MULTIPLIER:Number = 0.95;
      
      private const NEARBY_KEY_REPLACEMENT_MULTIPLIER:Number = 1;
      
      private const TRANSPOSITION_MULTIPLIER:Number = 0.3;
      
      private const INSERTION_MULTIPLIER:Number = 0.3;
      
      private const SUBSTITUTION_MULTIPLIER:Number = 0.3;
      
      private const DELETION_MULTIPLIER:Number = 0.3;
      
      private const ZERO_CORRECTION_PREFIX_MULTIPLIER:Number = 10;
      
      private const NO_FREQUENCY_INPUT_MATCH_WEIGHT:Number = 30;
      
      private const EXACT_WORD_MATCH_WEIGHT:Number = 15;
      
      private const WORD_EXTENSION_MULTIPLIER:Number = 0.9;
      
      private const CANDIDATES_PER_BATCH:Number = 100;
      
      private const _rootToAccentedForm:Object = {
         "a":"ÁáĂăǍǎÂâÄäȦȧẠạȀȁÀàẢảȂȃĀāĄąÅåḀḁȺⱥÃãǼǽǢǣÆæ",
         "b":"ḂḃḄḅƁɓḆḇɃƀƂƃ",
         "c":"ĆćČčÇçĈĉĊċƇƈȻȼ",
         "d":"ĎďḐḑḒḓḊḋḌḍƊɗḎḏĐđƋƌð",
         "e":"ÉéĔĕĚěȨȩÊêḘḙËëĖėẸẹȄȅÈèẺẻȆȇĒēĘę",
         "f":"ḞḟƑƒ",
         "g":"ǴǵĞğǦǧĢģĜĝĠġƓɠḠḡǤǥ",
         "h":"ḪḫȞȟḨḩĤĥⱧⱨḦḧḢḣḤḥĦħ",
         "i":"ÍíĬĭǏǐÎîÏïỊịȈȉÌìỈỉȊȋĪīĮįƗɨĨĩḬḭı",
         "j":"ĴĵɈɉ",
         "k":"ḰḱǨǩĶķⱩⱪꝂꝃḲḳƘƙḴḵꝀꝁ",
         "l":"ĹĺȽƚĽľĻļḼḽḶḷⱠⱡꝈꝉḺḻĿŀⱢɫŁł",
         "m":"ḾḿṀṁṂṃⱮɱ",
         "n":"ŃńŇňŅņṊṋṄṅṆṇǸǹƝɲṈṉȠƞÑñ",
         "o":"ÓóŎŏǑǒÔôÖöȮȯỌọŐőȌȍÒòỎỏƠơȎȏꝊꝋꝌꝍŌōǪǫØøÕõŒœ",
         "p":"ṔṕṖṗꝒꝓƤƥⱣᵽꝐꝑ",
         "q":"Ꝗꝗ",
         "r":"ŔŕŘřŖŗṘṙṚṛȐȑȒȓṞṟɌɍⱤɽ",
         "s":"ŚśŠšŞşŜŝȘșṠṡṢṣß",
         "t":"ŤťŢţṰṱȚțȾⱦṪṫṬṭƬƭṮṯƮʈŦŧ",
         "u":"ÚúŬŭǓǔÛûṶṷÜüṲṳỤụŰűȔȕÙùỦủƯưȖȗŪūŲųŮůŨũṴṵ",
         "v":"ṾṿƲʋṼṽ",
         "w":"ẂẃŴŵẄẅẆẇẈẉẀẁⱲⱳ",
         "x":"ẌẍẊẋ",
         "y":"ÝýŶŷŸÿẎẏỴỵỲỳƳƴỶỷỾỿȲȳɎɏỸỹ",
         "z":"ŹźŽžẐẑⱫⱬŻżẒẓȤȥẔẕƵƶ",
         "α":"άΆ",
         "ε":"έΈ",
         "η":"ήΉ",
         "ι":"ίϊΐΊΪ",
         "ο":"όΌ",
         "υ":"ύϋΰΎΫ",
         "ω":"ώΏ",
         "$":"$"
      };
      
      private const SMALLEST_WEIGHT:Number = 0.5;
      
      private var _tree:Array;
      
      private var _maxWordLength:int;
      
      private var _characterTable:Array = [];
      
      private var _variants:Array = [];
      
      private var _rootform:Array = [];
      
      private var _nearbyKeys:Array;
      
      private var _cache:LRUCache;
      
      private var _validChars:SetDictionary = null;
      
      private var _useType:int;
      
      private var _isFromAutoCorrect:Boolean;
      
      private var _candidates:BoundedPriorityQueue;
      
      private var _suggestions:BoundedPriorityQueue;
      
      private var _capitalize:Boolean;
      
      private var _status:Object;
      
      private var _cacheKey:String;
      
      private var _input:String;
      
      private var _maxSuggestions:Number;
      
      private var _maxCorrections:Number;
      
      private var _autoCorrections:SetDictionary;
      
      private var _badWords:SetDictionary;
      
      public function Predictions()
      {
         super();
      }
      
      public function setDictionary(param1:ByteArray) : void
      {
         var _loc11_:int = 0;
         var _loc21_:int = 0;
         var _loc9_:int = 0;
         var _loc12_:int = 0;
         var _loc14_:String = null;
         var _loc22_:int = 0;
         var _loc7_:int = 0;
         var _loc19_:String = null;
         var _loc23_:int = 0;
         var _loc10_:int = 0;
         var _loc16_:Array = null;
         var _loc18_:int = 0;
         var _loc20_:String = null;
         var _loc13_:String = null;
         var _loc2_:String = null;
         var _loc4_:String = null;
         _cache = new LRUCache(255);
         var _loc17_:ByteArray = param1;
         if(uint32(_loc17_,0) !== 1182289747 || uint32(_loc17_,4) !== 1145652052)
         {
            throw new Error("Invalid dictionary file");
         }
         if(uint32(_loc17_,8) !== 1)
         {
            throw new Error("Unknown dictionary version");
         }
         _maxWordLength = _loc17_[12] + 1;
         var _loc8_:int = uint16(_loc17_,13);
         _loc11_ = 0;
         while(_loc11_ < _loc8_)
         {
            _loc21_ = 15 + _loc11_ * 6;
            _characterTable[uint16(_loc17_,_loc21_)] = uint32(_loc17_,_loc21_ + 2);
            _loc11_++;
         }
         _autoCorrections = new SetDictionary();
         var _loc6_:int = uint16(_loc17_,15 + _loc8_ * 6);
         _loc21_ = 15 + _loc8_ * 6 + 2;
         _loc11_ = 0;
         while(_loc11_ < _loc6_)
         {
            _loc12_ = int(_loc17_[_loc21_++]);
            _loc14_ = "";
            _loc9_ = 0;
            while(_loc9_ < _loc12_)
            {
               _loc22_ = uint16(_loc17_,_loc21_);
               _loc14_ += String.fromCharCode(_loc22_);
               _loc21_ += 2;
               _loc9_++;
            }
            _loc7_ = int(_loc17_[_loc21_++]);
            _loc9_ = 0;
            while(_loc9_ < _loc7_)
            {
               _loc19_ = "";
               _loc23_ = int(_loc17_[_loc21_++]);
               _loc10_ = 0;
               while(_loc10_ < _loc23_)
               {
                  _loc22_ = uint16(_loc17_,_loc21_);
                  _loc19_ += String.fromCharCode(_loc22_);
                  _loc21_ += 2;
                  _loc10_++;
               }
               _autoCorrections.insertKey(_loc19_,_loc14_);
               _loc9_++;
            }
            _loc11_++;
         }
         _tree = [];
         _loc11_ = _loc21_;
         while(_loc11_ < param1.length)
         {
            _tree.push(param1[_loc11_]);
            _loc11_++;
         }
         var _loc3_:Object = {};
         for(var _loc5_:String in _rootToAccentedForm)
         {
            _loc16_ = _rootToAccentedForm[_loc5_].split("");
            _loc18_ = int(_loc16_.length);
            _loc11_ = 0;
            while(_loc11_ < _loc18_)
            {
               _loc3_[_loc16_[_loc11_]] = _loc5_;
               _loc11_++;
            }
         }
         for(var _loc15_:String in _characterTable)
         {
            _variants[_loc15_] = "";
            _loc20_ = String.fromCharCode(_loc15_);
            _loc13_ = _loc20_.toUpperCase();
            _loc2_ = _loc20_.toLowerCase();
            if(_loc13_ !== _loc20_)
            {
               var _loc25_:String = _loc15_;
               var _loc24_:String = _variants[_loc25_] + _loc13_;
               _variants[_loc25_] = _loc24_;
               _rootform[_loc15_] = _loc15_;
            }
            if(_loc2_ !== _loc20_)
            {
               _loc24_ = _loc15_;
               _loc25_ = _variants[_loc24_] + _loc2_;
               _variants[_loc24_] = _loc25_;
               _rootform[_loc15_] = _loc2_.charCodeAt(0);
            }
            if(_loc3_[_loc20_])
            {
               _loc4_ = _loc3_[_loc20_];
               _rootform[_loc15_] = _loc4_.charCodeAt(0);
               _variants[_loc15_] += _loc4_ + _loc4_.toUpperCase();
            }
            _badWords = new SetDictionary();
            _badWords.insertArray(["anal","ass","asses","asshole","assholes","aswhole","beastiality","bitch","blowjob","blowjobs","boner","boners","brewski","brewskis","chaturbate","clit","clits","clitoris","cock","cocked","cocking","cocks","cumshot","cunnilingus","douche","ejaculate","ejaculated","ejaculates","ejaculating","erection","erections","faggot","faggots","fecken","fellatio","fellation","fuck","fucked","fucker","fuckers","fucking","fucks","masturbate","masturbates","masturbating","masturbation","masturbator","masturbators","nigga","niggas","nigger","niggers","orgasm","orgasms","penis","porn","porno","pornographic","pornography","pussy","pussies","rape","raped","rapes","raping","sex","vagina","virgin","virginity","virgins","password","dick","dicks","passwords","bitches","accounts","douches","vaginas","cum","cums","cumming","fuk","fuks","fuking","fuked","sexy","douchebag","douchebags","drug","drugs","beer","beers","shit","shits","shitting","address","email","emails","emailing","emailed","addresses"
            ,"cell","motherfucker","motherfucking","motherfuck","motherfucks","motherfucked"]);
         }
         generateValidChars();
      }
      
      public function getRootFormOfChar(param1:int) : int
      {
         return _rootform[param1];
      }
      
      private function setNearbyKeys(param1:*) : void
      {
         _cache = new LRUCache(255);
         _nearbyKeys = param1;
      }
      
      private function generateValidChars() : void
      {
         var _loc1_:Array = null;
         var _loc3_:int = 0;
         _validChars = new SetDictionary();
         for(var _loc6_:int in _variants)
         {
            _validChars.insertKeyValue(String.fromCharCode(_loc6_));
            _loc1_ = _variants[_loc6_].split("");
            for each(var _loc5_:String in _loc1_)
            {
               _validChars.insertKeyValue(_loc5_);
            }
            _loc3_ = int(_rootform[_loc6_]);
            if(_loc3_ && _nearbyKeys && _nearbyKeys[_loc3_])
            {
               for each(var _loc2_:String in _nearbyKeys)
               {
                  _validChars.insertKeyValue(String.fromCharCode(_loc2_));
                  if(_variants[_loc2_])
                  {
                     for each(var _loc4_:String in _variants[_loc2_])
                     {
                        _validChars.insertKeyValue(_loc4_);
                     }
                  }
               }
            }
         }
      }
      
      public function predict(param1:String, param2:Number, param3:Number, param4:Number, param5:int) : Array
      {
         var input:String = param1;
         var maxSuggestions:Number = param2;
         var maxCandidates:Number = param3;
         var maxCorrections:Number = param4;
         var useType:int = param5;
         if(!_tree)
         {
            throw Error("not initialized");
         }
         _input = input;
         _maxSuggestions = maxSuggestions;
         _maxCorrections = maxCorrections;
         _useType = useType;
         _candidates = new BoundedPriorityQueue(maxCandidates);
         _suggestions = new BoundedPriorityQueue(maxSuggestions);
         _capitalize = input.charAt(0) === input.charAt(0).toUpperCase();
         _status = {
            "state":"predicting",
            "abort":function():void
            {
               if(this.state !== "done" && this.state !== "aborted")
               {
                  this.state = "aborting";
               }
            }
         };
         _cacheKey = input + "," + maxSuggestions + "," + maxCandidates + "," + maxCorrections;
         _isFromAutoCorrect = false;
         if(input.length > 0 && !_badWords.containsKey(input))
         {
            if(_autoCorrections.containsKey(input))
            {
               _input = String(_autoCorrections.getValue(input));
               _isFromAutoCorrect = true;
            }
            return getSuggestions();
         }
         _status.state = "done";
         _status.suggestions = [];
         return _status.suggestions;
      }
      
      private function getSuggestions() : Array
      {
         var _loc1_:Array = null;
         var _loc4_:int = 0;
         var _loc3_:Object = _cache.getData(_cacheKey);
         if(_loc3_)
         {
            _status.state = "done";
            _status.suggestions = _loc3_;
            return _status.suggestions;
         }
         var _loc2_:Boolean = false;
         if(_input.length > _maxWordLength)
         {
            _loc2_ = true;
         }
         else
         {
            _loc1_ = _input.split("");
            _loc4_ = 0;
            while(_loc4_ < _loc1_.length)
            {
               if(!_validChars.containsKey(_loc1_[_loc4_]))
               {
                  _loc2_ = true;
                  break;
               }
               _loc4_++;
            }
         }
         if(_loc2_)
         {
            _status.state = "done";
            _status.suggestions = [];
            return _status.suggestions;
         }
         addCandidate(0,_input,"",1,1,0);
         return processCandidates();
      }
      
      private function addCandidate(param1:*, param2:*, param3:*, param4:*, param5:*, param6:*) : void
      {
         var _loc7_:Number = param5 * param4;
         if(param6 === 0 && param4 > 0.9 * 0.9)
         {
            _loc7_ += 100;
         }
         else if(param6 === 0)
         {
            _loc7_ += param5 / 32 * 10;
         }
         if(_loc7_ < 0.5)
         {
            return;
         }
         if(_loc7_ <= _suggestions.threshold)
         {
            return;
         }
         _candidates.add({
            "pointer":param1,
            "input":param2,
            "output":param3,
            "multiplier":param4,
            "weight":_loc7_,
            "corrections":param6
         },_loc7_);
      }
      
      private function addSuggestion(param1:String, param2:Number, param3:int) : void
      {
         var _loc5_:int = 0;
         if(_capitalize)
         {
            param1 = param1.charAt(0).toUpperCase() + param1.substring(1);
         }
         var _loc4_:int = int(_suggestions.items.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if(_suggestions.items[_loc5_][0] === param1)
            {
               if(_suggestions.priorities[_loc5_] >= param2)
               {
                  return;
               }
               _suggestions.removeItemAt(_loc5_);
               break;
            }
            _loc5_++;
         }
         _suggestions.add([param1,param2,param3,_isFromAutoCorrect],param2);
      }
      
      private function processCandidates() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(aborted())
         {
            return _status.suggestions;
         }
         _loc1_ = 0;
         while(_loc1_ < 100)
         {
            _loc2_ = _candidates.remove();
            if(!_loc2_ || _loc2_.weight <= _suggestions.threshold)
            {
               _status.state = "done";
               _status.suggestions = _suggestions.items;
               _cache.insertKeyInCache(_cacheKey,_status.suggestions);
               return _status.suggestions;
            }
            process(_loc2_);
            _loc1_++;
         }
         return processCandidates();
      }
      
      private function process(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc15_:String = null;
         var _loc2_:Boolean = false;
         var _loc8_:int = 0;
         var _loc11_:int = 0;
         var _loc13_:int = 0;
         var _loc17_:int = 0;
         var _loc12_:Number = NaN;
         var _loc10_:String = param1.input;
         var _loc18_:String = param1.output;
         var _loc7_:Number = Number(param1.multiplier);
         var _loc16_:Number = Number(param1.corrections);
         var _loc9_:Object = {};
         if(_loc10_.length > 0)
         {
            _loc4_ = _loc10_.charAt(0);
            _loc5_ = _loc10_.charCodeAt(0);
         }
         _loc14_ = Number(param1.pointer);
         while(_loc14_ !== -1)
         {
            readNode(_loc14_,_loc9_);
            _loc6_ = Number(_loc9_.freq);
            _loc3_ = _loc6_ * _loc7_;
            if(_loc16_ > 0 && (_loc3_ <= _candidates.threshold || _loc3_ < 0.5))
            {
               break;
            }
            _loc15_ = _loc18_ + String.fromCharCode(_loc9_.ch);
            if(_loc10_.length === 0)
            {
               if(_loc9_.ch === 0 && canUseWithType(_loc9_.useType,_loc9_.specificType))
               {
                  if(_input.length == _loc18_.length)
                  {
                     if(_input.toUpperCase() === _loc18_.toUpperCase())
                     {
                        _loc2_ = true;
                     }
                     else
                     {
                        _loc8_ = 0;
                        while(_loc8_ < _loc18_.length)
                        {
                           if(_rootform[_loc18_.charCodeAt(_loc8_)] != _input.charCodeAt(_loc8_))
                           {
                              _loc2_ = false;
                              break;
                           }
                           _loc2_ = true;
                           _loc8_++;
                        }
                     }
                  }
                  if(_loc2_)
                  {
                     addSuggestion(_loc18_,_loc9_.freq === 1 ? 30 : _loc3_ + 15,_loc9_.useType);
                  }
                  else
                  {
                     addSuggestion(_loc18_,_loc3_,_loc9_.useType);
                  }
               }
               else
               {
                  addCandidate(_loc9_.center,_loc10_,_loc15_,_loc7_ * 0.9,_loc6_,_loc16_);
               }
            }
            else if(_loc9_.ch === 0)
            {
               if(_loc10_.length === 1)
               {
                  addCandidate(_loc14_,"",_loc18_,_loc7_ * 0.3,_loc6_,_loc16_ + 1);
               }
            }
            else
            {
               if(_loc9_.ch === _loc5_)
               {
                  addCandidate(_loc9_.center,_loc10_.substring(1),_loc15_,_loc7_,_loc6_,_loc16_);
               }
               else if(_variants[_loc9_.ch].indexOf(_loc4_) !== -1)
               {
                  addCandidate(_loc9_.center,_loc10_.substring(1),_loc15_,_loc7_ * 0.99,_loc6_,_loc16_);
               }
               else if(_loc16_ < _maxCorrections)
               {
                  _loc11_ = int(_rootform[_loc9_.ch]);
                  _loc13_ = int(_rootform[_loc5_]);
                  _loc17_ = 0;
                  if(_loc17_)
                  {
                     _loc12_ = Math.max(_loc17_ * 1,0.3);
                     addCandidate(_loc9_.center,_loc10_.substring(1),_loc15_,_loc7_ * _loc12_,_loc6_,_loc16_ + 1);
                  }
                  else if(_loc18_.length > 0)
                  {
                     addCandidate(_loc9_.center,_loc10_.substring(1),_loc15_,_loc7_ * 0.3,_loc6_,_loc16_ + 1);
                  }
               }
               if(!_variants[_loc9_.ch])
               {
                  addCandidate(_loc9_.center,_loc10_,_loc15_,_loc7_ * 0.95,_loc6_,_loc16_);
               }
               else if(_loc16_ < _maxCorrections && _loc18_.length > 0)
               {
                  addCandidate(_loc9_.center,_loc10_,_loc15_,_loc7_ * 0.3,_loc6_,_loc16_ + 1);
               }
               if(_loc16_ < _maxCorrections && _loc10_.length > 1 && _loc18_.length > 0 && (_loc9_.ch === _loc10_.charCodeAt(1) || _variants[_loc9_.ch].indexOf(_loc10_.charAt(1)) !== -1))
               {
                  addCandidate(_loc9_.center,_loc10_.charAt(0) + _loc10_.substring(2),_loc15_,_loc7_ * 0.3,_loc6_,_loc16_ + 1);
                  addCandidate(_loc9_.center,_loc10_.substring(2),_loc15_,_loc7_ * 0.3,_loc6_,_loc16_ + 1);
               }
            }
            _loc14_ = Number(_loc9_.next);
         }
      }
      
      private function canUseWithType(param1:int, param2:Boolean) : Boolean
      {
         if(_useType == 0)
         {
            return true;
         }
         if(param2)
         {
            return (param1 & _useType) > 0;
         }
         if(param1 == 0)
         {
            return true;
         }
         if((param1 & _useType) == 0)
         {
            return true;
         }
         return false;
      }
      
      private function readNode(param1:Number, param2:Object) : void
      {
         var _loc7_:Boolean = false;
         if(param1 === -1)
         {
            throw Error("Assertion error: followed invalid pointer");
         }
         var _loc5_:Number = Number(_tree[param1++]);
         var _loc8_:Number = _loc5_ & 0x80;
         var _loc4_:Number = _loc5_ & 0x40;
         var _loc3_:Number = _loc5_ & 0x20;
         param2.freq = (_loc5_ & 0x1F) + 1;
         var _loc6_:Number = 0;
         param2.specificType = false;
         if(_loc8_)
         {
            param2.ch = _tree[param1++];
            if(_loc4_)
            {
               param2.ch = (param2.ch << 8) + _tree[param1++];
            }
         }
         else
         {
            param2.ch = 0;
            _loc6_ = Number(_tree[param1++]);
            _loc7_ = _loc6_ >> 7 > 0;
            if(_loc7_)
            {
               param2.specificType = true;
               _loc6_ = _loc6_ * -1 & 0xFF;
            }
         }
         param2.useType = _loc6_;
         if(_loc3_)
         {
            param2.next = (_tree[param1++] << 16) + (_tree[param1++] << 8) + _tree[param1++];
         }
         else
         {
            param2.next = -1;
         }
         if(_loc8_)
         {
            param2.center = param1;
         }
         else
         {
            param2.center = -1;
         }
      }
      
      private function aborted() : Boolean
      {
         if(_status.state === "aborting")
         {
            _status.state = "aborted";
            return true;
         }
         return false;
      }
      
      private function uint32(param1:ByteArray, param2:Number) : int
      {
         return (param1[param2] << 24) + (param1[param2 + 1] << 16) + (param1[param2 + 2] << 8) + param1[param2 + 3];
      }
      
      private function uint16(param1:ByteArray, param2:Number) : int
      {
         return (param1[param2] << 8) + param1[param2 + 1];
      }
   }
}

