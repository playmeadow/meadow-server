package gui
{
   import flash.utils.Dictionary;
   
   public class PredictiveTextTree
   {
      
      private static var _defaultRoot:PredictiveTextNode;
      
      private static var _lastKnowWordNode:PredictiveTextNode;
      
      private static var _optimizationString:String = "";
      
      private static var _weightOfWord:int;
      
      private static var _useType:int;
      
      private static var _specialCharsRegEx:RegExp;
      
      private static var _specialCharsMap:Dictionary;
      
      private static var _savedChildren:Vector.<PredictiveTextNode> = new Vector.<PredictiveTextNode>();
      
      private var _root:PredictiveTextNode;
      
      private var _currSearchNode:PredictiveTextNode;
      
      private var _nodeCount:int = 0;
      
      private var _nodeCountAfter:int = 0;
      
      private var _numWordsPrinted:int = 0;
      
      private var _charSearchIndex:int = 0;
      
      private var _similarWordsIndex:int = 0;
      
      private var _useType:int;
      
      private var _isLastNode:Boolean;
      
      private var _hasCompletedCheckingMyself:Boolean;
      
      private var _searchChildren:Vector.<Object> = new Vector.<Object>();
      
      private var _similarWords:Vector.<Object> = new Vector.<Object>();
      
      public function PredictiveTextTree(param1:PredictiveTextNode, param2:int)
      {
         super();
         _root = param1;
         _currSearchNode = _root;
         _useType = param2;
      }
      
      public static function init() : void
      {
         _defaultRoot = new PredictiveTextNode("",0,new Vector.<PredictiveTextNode>());
      }
      
      public static function setupSpecialCharsRegEx(param1:String) : void
      {
         _specialCharsRegEx = new RegExp("[" + param1 + "]","ig");
      }
      
      public static function setupConversionChars(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc4_:int = 0;
         var _loc3_:Array = param1.split(",");
         _specialCharsMap = new Dictionary();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_].split("|");
            _specialCharsMap[_loc2_[0]] = _loc2_[1];
            _loc4_++;
         }
      }
      
      public static function addFromStart(param1:Array) : void
      {
         _weightOfWord = param1[1];
         _useType = param1[2] == "" ? 0 : param1[2];
         add(param1[0].split(""),0,_defaultRoot);
      }
      
      public static function get defaultRoot() : PredictiveTextNode
      {
         return _defaultRoot;
      }
      
      public static function optimizeTree(param1:PredictiveTextNode) : void
      {
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         var _loc5_:Boolean = false;
         if(param1.children)
         {
            _loc4_ = int(param1.children.length);
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               optimizeTree(param1.children[_loc6_]);
               if(param1.weight > 0 || param1 == _defaultRoot || _loc4_ > 1)
               {
                  if(_lastKnowWordNode)
                  {
                     _lastKnowWordNode.children = _savedChildren;
                     _lastKnowWordNode.weight = Math.max(1,_lastKnowWordNode.weight);
                     _lastKnowWordNode.char = reverseString(_optimizationString);
                     _lastKnowWordNode = null;
                     _savedChildren = null;
                     _optimizationString = "";
                  }
               }
               else if(_lastKnowWordNode)
               {
                  _loc3_ = _lastKnowWordNode.weight;
                  _loc2_ = _lastKnowWordNode.isSpecialLangChar;
                  _loc5_ = _lastKnowWordNode.isSpecialCharacter;
                  _lastKnowWordNode = param1;
                  _lastKnowWordNode.weight = _loc3_;
                  _optimizationString += param1.char;
                  if(_loc2_)
                  {
                     _lastKnowWordNode.isSpecialLangChar = _loc2_;
                  }
                  if(_loc5_)
                  {
                     _lastKnowWordNode.isSpecialCharacter = _loc5_;
                  }
               }
               _loc6_++;
            }
            if(param1.weight > 0)
            {
               if(_lastKnowWordNode == null || param1.weight > _lastKnowWordNode.weight)
               {
                  _savedChildren = param1.children;
                  _lastKnowWordNode = param1;
                  _optimizationString += param1.char;
                  if(!_lastKnowWordNode.isSpecialLangChar)
                  {
                     _lastKnowWordNode.isSpecialLangChar = param1.isSpecialLangChar;
                  }
                  if(!_lastKnowWordNode.isSpecialCharacter)
                  {
                     _lastKnowWordNode.isSpecialCharacter = param1.isSpecialCharacter;
                  }
               }
            }
         }
      }
      
      private static function add(param1:Array, param2:int, param3:PredictiveTextNode) : void
      {
         var _loc4_:int = 0;
         if(param2 == param1.length)
         {
            param3.weight = Math.max(1,_weightOfWord);
            param3.useType = _useType;
         }
         else
         {
            _loc4_ = param3.contains(param1[param2]);
            if(_loc4_ != -1)
            {
               add(param1,param2 + 1,param3.children[_loc4_]);
            }
            else
            {
               param3.children.push(new PredictiveTextNode(param1[param2],0,new Vector.<PredictiveTextNode>(),false,_useType,isSpecialLangCharacter(param1[param2])));
               add(param1,param2 + 1,param3.children[param3.children.length - 1]);
            }
         }
      }
      
      private static function reverseString(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc2_:String = "";
         _loc3_ = param1.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ += param1.charAt(_loc3_);
            _loc3_--;
         }
         return _loc2_;
      }
      
      private static function isSpecialLangCharacter(param1:String) : Boolean
      {
         if(_specialCharsRegEx)
         {
            return param1.match(_specialCharsRegEx).length > 0;
         }
         return false;
      }
      
      public function destroy() : void
      {
         if(_lastKnowWordNode)
         {
            _lastKnowWordNode.destroy();
            _lastKnowWordNode = null;
         }
         _searchChildren = null;
         _similarWords = null;
         _savedChildren = null;
      }
      
      public function updateRoot(param1:PredictiveTextNode) : void
      {
         _root = param1;
         clearWordSuggestions();
         resetSearchTree();
      }
      
      public function containsString(param1:String) : int
      {
         var _loc2_:int = 0;
         _loc2_ = checkMyself(param1);
         if(_loc2_ > 0)
         {
            return _loc2_;
         }
         if(_loc2_ == -1)
         {
            return 0;
         }
         _loc2_ = checkMyChildren(param1);
         if(_loc2_ > 0)
         {
            return _loc2_;
         }
         return 0;
      }
      
      public function checkCurrentWordValidity() : int
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         if(_searchChildren.length > 0)
         {
            _loc1_ = _searchChildren[_searchChildren.length - 1];
            if(_loc1_.node)
            {
               if(_currSearchNode)
               {
                  if(_currSearchNode.isSpecialCharacter)
                  {
                     _loc2_ = 3;
                  }
                  else if(_currSearchNode.char.length > 1)
                  {
                     if(_charSearchIndex == _loc1_.node.char.length)
                     {
                        _loc2_ = canThisTypeUseThisWord(_loc1_.node);
                     }
                     else
                     {
                        _loc2_ = 1;
                     }
                  }
                  else if(_currSearchNode.char.charAt(_charSearchIndex) == _loc1_.node.char)
                  {
                     _loc2_ = canThisTypeUseThisWord(_loc1_.node);
                  }
                  else
                  {
                     _loc2_ = 1;
                  }
               }
            }
            else
            {
               _loc2_ = 2;
            }
         }
         return _loc2_;
      }
      
      public function showTopWord() : String
      {
         clearWordSuggestions();
         findAllSimilarWords();
         _similarWords.sort(compare);
         return _similarWords.length > 0 ? _similarWords[0].word : null;
      }
      
      public function resetSearchTree() : void
      {
         _searchChildren = new Vector.<Object>();
         _currSearchNode = _root;
      }
      
      public function clearWordSuggestions() : void
      {
         _similarWords.splice(0,_similarWords.length);
         _similarWordsIndex = 0;
      }
      
      public function backspaced() : void
      {
         var _loc1_:Object = null;
         if(_searchChildren.length > 0)
         {
            _searchChildren.pop();
            if(_searchChildren.length == 0)
            {
               _currSearchNode = _root;
               _charSearchIndex = 0;
               _hasCompletedCheckingMyself = false;
            }
            else
            {
               _loc1_ = _searchChildren[_searchChildren.length - 1];
               _currSearchNode = _loc1_.node == null ? _root : _loc1_.node;
               _charSearchIndex = _loc1_.wordIndex;
               _hasCompletedCheckingMyself = _charSearchIndex >= _currSearchNode.char.length;
            }
         }
         clearWordSuggestions();
      }
      
      public function onSpecialCharacter() : void
      {
         var _loc1_:PredictiveTextNode = new PredictiveTextNode(_currSearchNode.char,_currSearchNode.weight,_currSearchNode.children,true);
         _searchChildren.push({
            "node":_loc1_,
            "wordIndex":0
         });
         _hasCompletedCheckingMyself = false;
      }
      
      public function onSpacebar() : void
      {
         _searchChildren.push({
            "node":null,
            "wordIndex":0
         });
         _currSearchNode = _root;
         _charSearchIndex = 0;
         _hasCompletedCheckingMyself = false;
      }
      
      public function get nodeCount() : Number
      {
         return _nodeCount;
      }
      
      public function get nodeCountAfter() : Number
      {
         return _nodeCountAfter;
      }
      
      public function get theRoot() : PredictiveTextNode
      {
         return _root;
      }
      
      public function get numWords() : Number
      {
         return _numWordsPrinted;
      }
      
      public function get currentRestriction() : String
      {
         var _loc4_:int = 0;
         var _loc1_:String = null;
         var _loc3_:* = undefined;
         var _loc2_:String = "";
         if(_currSearchNode)
         {
            _loc4_ = 0;
            while(_loc4_ < _currSearchNode.char.length)
            {
               _loc1_ = _currSearchNode.char.charAt(_loc4_);
               if(_loc1_ == "-")
               {
                  _loc2_ += "|\\-";
               }
               else
               {
                  if(_specialCharsMap && _specialCharsMap[_loc1_])
                  {
                     _loc2_ += "|" + _specialCharsMap[_loc1_];
                  }
                  _loc2_ += "|" + _loc1_;
               }
               _loc4_++;
            }
            _loc3_ = _currSearchNode.children;
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc1_ = _loc3_[_loc4_].char.charAt(0);
               if(_loc1_ == "-")
               {
                  _loc2_ += "|\\-";
               }
               else
               {
                  if(_specialCharsMap && _specialCharsMap[_loc1_])
                  {
                     _loc2_ += "|" + _specialCharsMap[_loc1_];
                  }
                  _loc2_ += "|" + _loc1_;
               }
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      private function checkMyself(param1:String) : int
      {
         var _loc2_:int = 0;
         if(_currSearchNode)
         {
            if(_currSearchNode.isSpecialCharacter)
            {
               return -1;
            }
            if(_currSearchNode.char.length > 1 && !_hasCompletedCheckingMyself)
            {
               if(_currSearchNode.char.charAt(_charSearchIndex) == param1)
               {
                  _charSearchIndex = _charSearchIndex + 1;
                  if(_charSearchIndex == _currSearchNode.char.length)
                  {
                     _searchChildren.push({
                        "node":_currSearchNode,
                        "wordIndex":_charSearchIndex
                     });
                     _charSearchIndex = 0;
                     _hasCompletedCheckingMyself = true;
                     return canThisTypeUseThisWord(_currSearchNode);
                  }
                  _searchChildren.push({
                     "node":_currSearchNode,
                     "wordIndex":_charSearchIndex
                  });
                  _loc2_ = canThisTypeUseThisWord(_currSearchNode,false,false) - 1;
                  if(_loc2_ == 0 && _currSearchNode.children.length == 0)
                  {
                     return -1;
                  }
                  return _loc2_;
               }
               _searchChildren.push({
                  "node":_currSearchNode,
                  "wordIndex":_charSearchIndex
               });
               return -1;
            }
            return 0;
         }
         return 0;
      }
      
      private function checkMyChildren(param1:String) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:PredictiveTextNode = null;
         if(_currSearchNode)
         {
            _loc3_ = int(_currSearchNode.children.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _hasCompletedCheckingMyself = false;
               _loc2_ = _currSearchNode.children[_loc4_];
               if(_loc2_.isSpecialCharacter)
               {
                  return 0;
               }
               if(_loc2_.char == param1)
               {
                  _searchChildren.push({
                     "node":_loc2_,
                     "wordIndex":0
                  });
                  _currSearchNode = _loc2_;
                  return canThisTypeUseThisWord(_loc2_);
               }
               if(_loc2_.char.length > 1)
               {
                  if(_loc2_.char.charAt(_charSearchIndex) == param1)
                  {
                     _charSearchIndex = _charSearchIndex + 1;
                     if(_charSearchIndex == _loc2_.char.length)
                     {
                        _searchChildren.push({
                           "node":_loc2_,
                           "wordIndex":_charSearchIndex
                        });
                        _currSearchNode = _loc2_;
                        _charSearchIndex = 0;
                     }
                     else
                     {
                        _searchChildren.push({
                           "node":_loc2_,
                           "wordIndex":_charSearchIndex
                        });
                        _currSearchNode = _loc2_;
                     }
                     return canThisTypeUseThisWord(_loc2_,true);
                  }
               }
               _loc4_++;
            }
         }
         _searchChildren.push({
            "node":_currSearchNode,
            "wordIndex":_charSearchIndex
         });
         return 0;
      }
      
      private function findAllSimilarWords(param1:PredictiveTextNode = null, param2:String = "", param3:PredictiveTextNode = null) : Vector.<Object>
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:PredictiveTextNode = param1 != null ? param1 : _currSearchNode;
         if(_loc4_ == _root)
         {
            return _similarWords;
         }
         if(param3 == null)
         {
            param3 = _currSearchNode;
         }
         if(_loc4_)
         {
            _loc5_ = int(_searchChildren[_searchChildren.length - 1].wordIndex);
            if(_loc4_ == _currSearchNode && _currSearchNode.char.length > 1 && _currSearchNode.weight > 0 && _loc5_ < _currSearchNode.char.length)
            {
               if(canThisTypeUseThisWord(_loc4_,false,false) == 2)
               {
                  _similarWords.push({
                     "word":appendCompletionString(""),
                     "weight":_currSearchNode.weight,
                     "index":_loc5_
                  });
                  _similarWordsIndex = _similarWordsIndex + 1;
               }
            }
            _loc6_ = 0;
            while(_loc6_ < _loc4_.children.length)
            {
               if(_loc4_ != param3)
               {
                  param2 += _loc4_.char;
                  param3 = _loc4_;
               }
               if(_similarWords.length <= _similarWordsIndex)
               {
                  if(canThisTypeUseThisWord(_loc4_.children[_loc6_],false,false) == 2)
                  {
                     _similarWords.push({
                        "word":param2,
                        "weight":_loc4_.children[_loc6_].weight
                     });
                     _similarWords[_similarWordsIndex].word += _loc4_.children[_loc6_].char;
                     _similarWords[_similarWordsIndex].weight = _loc4_.children[_loc6_].weight;
                  }
               }
               else
               {
                  _similarWords[_similarWordsIndex].word += _loc4_.children[_loc6_].char;
                  _similarWords[_similarWordsIndex].weight = _loc4_.children[_loc6_].weight;
               }
               if(_loc4_.children[_loc6_].weight > 0 && _similarWords.length > _similarWordsIndex)
               {
                  _similarWords[_similarWordsIndex].word = appendCompletionString(_similarWords[_similarWordsIndex].word);
                  _similarWords[_similarWordsIndex].weight = _loc4_.children[_loc6_].weight;
                  if(_loc4_ != _currSearchNode)
                  {
                     return _similarWords;
                  }
                  _similarWordsIndex = _similarWordsIndex + 1;
               }
               else
               {
                  findAllSimilarWords(_loc4_.children[_loc6_],param2);
                  _similarWordsIndex = _similarWordsIndex + 1;
               }
               _loc6_++;
            }
            if(param1 == null && _loc4_.children.length == 0)
            {
               if(canThisTypeUseThisWord(_loc4_,false,false) == 2)
               {
                  _similarWords.push({
                     "word":appendCompletionString(""),
                     "weight":_loc4_.weight
                  });
               }
            }
            _similarWordsIndex = _similarWordsIndex - 1;
         }
         return _similarWords;
      }
      
      public function findAllLanguageSpecialChars(param1:String) : Array
      {
         var _loc5_:int = 0;
         var _loc4_:PredictiveTextNode = null;
         var _loc2_:String = null;
         var _loc3_:Array = [];
         if(_searchChildren.length > 0)
         {
            if(_searchChildren.length == 1 || _searchChildren[_searchChildren.length - 2].node == null)
            {
               _loc4_ = theRoot;
            }
            else
            {
               _loc4_ = _searchChildren[_searchChildren.length - 2].node;
            }
            if(_loc4_.char.length > 1 && _loc4_.isSpecialLangChar)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_.char.length)
               {
                  _loc2_ = _loc4_.char.charAt(_loc5_);
                  if(_specialCharsMap[_loc2_] == param1)
                  {
                     _loc3_.push(_loc4_.char.charAt(_loc5_));
                  }
                  _loc5_++;
               }
            }
            _loc5_ = 0;
            while(_loc5_ < _loc4_.children.length)
            {
               if(_loc4_.children[_loc5_].isSpecialLangChar)
               {
                  _loc2_ = _loc4_.children[_loc5_].char.charAt(0);
                  if(_specialCharsMap[_loc2_] == param1)
                  {
                     _loc3_.push(_loc4_.children[_loc5_].char.charAt(0));
                  }
               }
               _loc5_++;
            }
         }
         return _loc3_;
      }
      
      private function compare(param1:Object, param2:Object) : int
      {
         if(param1.weight > param2.weight)
         {
            return -1;
         }
         if(param1.weight < param2.weight)
         {
            return 1;
         }
         return 0;
      }
      
      private function appendCompletionString(param1:String) : String
      {
         var _loc2_:PredictiveTextNode = null;
         var _loc3_:int = 0;
         var _loc4_:String = "";
         if(_searchChildren)
         {
            _loc3_ = _searchChildren.length - 1;
            for(; _loc3_ >= 0; _loc3_--)
            {
               if(!(_searchChildren[_loc3_].node && !_searchChildren[_loc3_].node.isSpecialCharacter))
               {
                  break;
               }
               if(_loc2_)
               {
                  if(_loc2_ == _searchChildren[_loc3_].node)
                  {
                     continue;
                  }
                  if(_searchChildren[_loc3_].node.char.length > 1)
                  {
                     _loc4_ += reverseString(_searchChildren[_loc3_].node.char);
                  }
                  else
                  {
                     _loc4_ += _searchChildren[_loc3_].node.char;
                  }
                  _loc2_ = _searchChildren[_loc3_].node;
               }
               else
               {
                  if(_searchChildren[_loc3_].node.char.length > 1)
                  {
                     _loc4_ += reverseString(_searchChildren[_loc3_].node.char);
                  }
                  else
                  {
                     _loc4_ += _searchChildren[_loc3_].node.char;
                  }
                  _loc2_ = _searchChildren[_loc3_].node;
               }
            }
         }
         return reverseString(_loc4_) + param1;
      }
      
      private function canThisTypeUseThisWord(param1:Object, param2:Boolean = false, param3:Boolean = true) : int
      {
         if(param1.useType == 0)
         {
            return (param3 ? _currSearchNode.weight > 0 && (param2 ? _charSearchIndex == 0 : true) : true) ? 2 : 1;
         }
         if(param1.useType > 0)
         {
            if((_useType & param1.useType) > 0)
            {
               return (param3 ? _currSearchNode.weight > 0 || param1.children.length > 0 : true) && (param2 ? _charSearchIndex != 0 : true) ? 1 : 0;
            }
            return (param3 ? _currSearchNode.weight > 0 && (param2 ? _charSearchIndex == 0 : true) : true) ? 2 : 1;
         }
         if((_useType & param1.useType * -1) > 0)
         {
            return (param3 ? _currSearchNode.weight > 0 && (param2 ? _charSearchIndex == 0 : true) : true) ? 2 : 1;
         }
         return (param3 ? _currSearchNode.weight > 0 || param1.children.length > 0 : true) && (param2 ? _charSearchIndex != 0 : true) ? 1 : 0;
      }
   }
}

