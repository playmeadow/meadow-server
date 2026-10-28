package gui
{
   public class PredictiveTextTree
   {
      
      private static var _defaultRoot:PredictiveTextNode;
      
      private static var _lastKnowWordNode:PredictiveTextNode;
      
      private static var _weightOfWord:int;
      
      private static var _useType:int;
      
      private static var _optimizationString:String = "";
      
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
         this._root = param1;
         this._currSearchNode = this._root;
         this._useType = param2;
      }
      
      public static function init() : void
      {
         _defaultRoot = new PredictiveTextNode("",0,new Vector.<PredictiveTextNode>());
      }
      
      public static function addFromStart(param1:Array) : void
      {
         _weightOfWord = param1[1];
         _useType = param1[2] == "" ? PredictiveTextManager.USE_TYPE_ALL : int(param1[2]);
         add(param1[0].split(""),0,_defaultRoot);
      }
      
      public static function get defaultRoot() : PredictiveTextNode
      {
         return _defaultRoot;
      }
      
      public static function optimizeTree(param1:PredictiveTextNode) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1.children)
         {
            _loc2_ = int(param1.children.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               optimizeTree(param1.children[_loc3_]);
               if(param1.weight > 0 || param1 == _defaultRoot || _loc2_ > 1)
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
                  _loc4_ = _lastKnowWordNode.weight;
                  _lastKnowWordNode = param1;
                  _lastKnowWordNode.weight = _loc4_;
                  _optimizationString += param1.char;
               }
               _loc3_++;
            }
            if(param1.weight > 0)
            {
               if(_lastKnowWordNode == null || param1.weight > _lastKnowWordNode.weight)
               {
                  _savedChildren = param1.children;
                  _lastKnowWordNode = param1;
                  _optimizationString += param1.char;
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
               param3.children.push(new PredictiveTextNode(param1[param2],0,new Vector.<PredictiveTextNode>(),false,_useType));
               add(param1,param2 + 1,param3.children[param3.children.length - 1]);
            }
         }
      }
      
      private static function reverseString(param1:String) : String
      {
         var _loc2_:String = "";
         var _loc3_:* = int(param1.length - 1);
         while(_loc3_ >= 0)
         {
            _loc2_ += param1.charAt(_loc3_);
            _loc3_--;
         }
         return _loc2_;
      }
      
      public function destroy() : void
      {
         if(_lastKnowWordNode)
         {
            _lastKnowWordNode.destroy();
            _lastKnowWordNode = null;
         }
         this._searchChildren = null;
         this._similarWords = null;
         _savedChildren = null;
      }
      
      public function updateRoot(param1:PredictiveTextNode) : void
      {
         this._root = param1;
         this.clearWordSuggestions();
         this.resetSearchTree();
      }
      
      public function containsString(param1:String) : int
      {
         var _loc2_:int = 0;
         _loc2_ = this.checkMyself(param1);
         if(_loc2_ > 0)
         {
            return _loc2_;
         }
         if(_loc2_ == -1)
         {
            return 0;
         }
         _loc2_ = this.checkMyChildren(param1);
         if(_loc2_ > 0)
         {
            return _loc2_;
         }
         return 0;
      }
      
      public function checkCurrentWordValidity() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         if(this._searchChildren.length > 0)
         {
            _loc2_ = this._searchChildren[this._searchChildren.length - 1];
            if(_loc2_.node)
            {
               if(this._currSearchNode)
               {
                  if(this._currSearchNode.isSpecialCharacter)
                  {
                     _loc1_ = 3;
                  }
                  else if(this._currSearchNode.char.length > 1)
                  {
                     if(this._charSearchIndex == _loc2_.node.char.length)
                     {
                        this._charSearchIndex = 0;
                        if(_loc2_.node.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == _loc2_.node.useType)
                        {
                           _loc1_ = this._currSearchNode.weight > 0 ? 1 : 0;
                        }
                        else
                        {
                           _loc1_ = this._currSearchNode.weight > 0 ? 2 : 1;
                        }
                     }
                     else
                     {
                        _loc1_ = 1;
                     }
                  }
                  else if(this._currSearchNode.char.charAt(this._charSearchIndex) == _loc2_.node.char)
                  {
                     if(_loc2_.node.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == _loc2_.node.useType)
                     {
                        _loc1_ = this._currSearchNode.weight > 0 ? 1 : 0;
                     }
                     else
                     {
                        _loc1_ = this._currSearchNode.weight > 0 ? 2 : 1;
                     }
                  }
                  else
                  {
                     _loc1_ = 1;
                  }
               }
            }
            else
            {
               _loc1_ = 2;
            }
         }
         return _loc1_;
      }
      
      public function showTopWord() : String
      {
         this.clearWordSuggestions();
         this.findAllSimilarWords();
         this._similarWords.sort(this.compare);
         return this._similarWords.length > 0 ? this._similarWords[0].word : null;
      }
      
      public function resetSearchTree() : void
      {
         this._searchChildren = new Vector.<Object>();
         this._currSearchNode = this._root;
      }
      
      public function clearWordSuggestions() : void
      {
         this._similarWords.splice(0,this._similarWords.length);
         this._similarWordsIndex = 0;
      }
      
      public function backspaced() : void
      {
         var _loc1_:Object = null;
         if(this._searchChildren.length > 0)
         {
            this._hasCompletedCheckingMyself = false;
            this._searchChildren.pop();
            if(this._searchChildren.length == 0)
            {
               this._currSearchNode = this._root;
               this._charSearchIndex = 0;
            }
            else
            {
               _loc1_ = this._searchChildren[this._searchChildren.length - 1];
               this._currSearchNode = _loc1_.node == null ? this._root : _loc1_.node;
               this._charSearchIndex = _loc1_.wordIndex;
            }
         }
         this.clearWordSuggestions();
      }
      
      public function onSpecialCharacter() : void
      {
         var _loc1_:PredictiveTextNode = new PredictiveTextNode(this._currSearchNode.char,this._currSearchNode.weight,this._currSearchNode.children,true);
         this._searchChildren.push({
            "node":_loc1_,
            "wordIndex":0
         });
         this._hasCompletedCheckingMyself = false;
      }
      
      public function onSpacebar() : void
      {
         this._searchChildren.push({
            "node":null,
            "wordIndex":0
         });
         this._currSearchNode = this._root;
         this._charSearchIndex = 0;
         this._hasCompletedCheckingMyself = false;
      }
      
      public function get nodeCount() : Number
      {
         return this._nodeCount;
      }
      
      public function get nodeCountAfter() : Number
      {
         return this._nodeCountAfter;
      }
      
      public function get theRoot() : PredictiveTextNode
      {
         return this._root;
      }
      
      public function get numWords() : Number
      {
         return this._numWordsPrinted;
      }
      
      public function get currentRestriction() : String
      {
         var _loc2_:Vector.<PredictiveTextNode> = null;
         var _loc3_:int = 0;
         var _loc1_:String = "";
         if(this._currSearchNode)
         {
            _loc1_ += this._currSearchNode.char;
            _loc2_ = this._currSearchNode.children;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_[_loc3_].char.charAt(0) == "-")
               {
                  _loc1_ += "\\-";
               }
               else
               {
                  _loc1_ += _loc2_[_loc3_].char.charAt(0);
               }
               _loc3_++;
            }
         }
         return _loc1_;
      }
      
      private function checkMyself(param1:String) : int
      {
         if(this._currSearchNode)
         {
            if(this._currSearchNode.isSpecialCharacter)
            {
               return -1;
            }
            if(this._currSearchNode.char.length > 1 && !this._hasCompletedCheckingMyself)
            {
               if(this._currSearchNode.char.charAt(this._charSearchIndex) == param1)
               {
                  ++this._charSearchIndex;
                  if(this._charSearchIndex == this._currSearchNode.char.length)
                  {
                     this._searchChildren.push({
                        "node":this._currSearchNode,
                        "wordIndex":this._charSearchIndex
                     });
                     this._charSearchIndex = 0;
                     this._hasCompletedCheckingMyself = true;
                     if(this._currSearchNode.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == this._currSearchNode.useType)
                     {
                        return this._currSearchNode.weight > 0 || this._currSearchNode.children.length > 0 ? 1 : 0;
                     }
                     return this._currSearchNode.weight > 0 ? 2 : 1;
                  }
                  this._searchChildren.push({
                     "node":this._currSearchNode,
                     "wordIndex":this._charSearchIndex
                  });
                  if(this._currSearchNode.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == this._currSearchNode.useType)
                  {
                     return 0;
                  }
                  return 1;
               }
               this._searchChildren.push({
                  "node":this._currSearchNode,
                  "wordIndex":this._charSearchIndex
               });
               return -1;
            }
            return 0;
         }
         return 0;
      }
      
      private function checkMyChildren(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:PredictiveTextNode = null;
         if(this._currSearchNode)
         {
            _loc2_ = int(this._currSearchNode.children.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               this._hasCompletedCheckingMyself = false;
               _loc4_ = this._currSearchNode.children[_loc3_];
               if(_loc4_.isSpecialCharacter)
               {
                  return 0;
               }
               if(_loc4_.char == param1)
               {
                  this._searchChildren.push({
                     "node":_loc4_,
                     "wordIndex":0
                  });
                  this._currSearchNode = _loc4_;
                  if(_loc4_.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == _loc4_.useType)
                  {
                     return this._currSearchNode.weight > 0 || _loc4_.children.length > 0 ? 1 : 0;
                  }
                  return this._currSearchNode.weight > 0 ? 2 : 1;
               }
               if(_loc4_.char.length > 1)
               {
                  if(_loc4_.char.charAt(this._charSearchIndex) == param1)
                  {
                     ++this._charSearchIndex;
                     if(this._charSearchIndex == _loc4_.char.length)
                     {
                        this._searchChildren.push({
                           "node":_loc4_,
                           "wordIndex":this._charSearchIndex
                        });
                        this._currSearchNode = _loc4_;
                        this._charSearchIndex = 0;
                     }
                     else
                     {
                        this._searchChildren.push({
                           "node":_loc4_,
                           "wordIndex":this._charSearchIndex
                        });
                        this._currSearchNode = _loc4_;
                     }
                     if(_loc4_.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == _loc4_.useType)
                     {
                        return (this._currSearchNode.weight > 0 || _loc4_.children.length > 0) && this._charSearchIndex == 0 ? 1 : 0;
                     }
                     return this._currSearchNode.weight > 0 && this._charSearchIndex == 0 ? 2 : 1;
                  }
               }
               _loc3_++;
            }
         }
         this._searchChildren.push({
            "node":this._currSearchNode,
            "wordIndex":this._charSearchIndex
         });
         return 0;
      }
      
      private function findAllSimilarWords(param1:PredictiveTextNode = null, param2:String = "", param3:PredictiveTextNode = null) : Vector.<Object>
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:PredictiveTextNode = param1 != null ? param1 : this._currSearchNode;
         if(_loc4_ == this._root)
         {
            return this._similarWords;
         }
         if(param3 == null)
         {
            param3 = this._currSearchNode;
         }
         if(_loc4_)
         {
            _loc5_ = int(this._searchChildren[this._searchChildren.length - 1].wordIndex);
            if(_loc4_ == this._currSearchNode && this._currSearchNode.char.length > 1 && this._currSearchNode.weight > 0 && _loc5_ < this._currSearchNode.char.length)
            {
               if(!(_loc4_.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == _loc4_.useType))
               {
                  this._similarWords.push({
                     "word":this.appendCompletionString(""),
                     "weight":this._currSearchNode.weight,
                     "index":_loc5_
                  });
                  ++this._similarWordsIndex;
               }
            }
            _loc6_ = 0;
            while(_loc6_ < _loc4_.children.length)
            {
               if(this._similarWords.length <= this._similarWordsIndex)
               {
                  if(!(_loc4_.children[_loc6_].useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == _loc4_.children[_loc6_].useType))
                  {
                     this._similarWords.push({
                        "word":param2,
                        "weight":_loc4_.children[_loc6_].weight
                     });
                     this._similarWords[this._similarWordsIndex].word += _loc4_.children[_loc6_].char;
                     this._similarWords[this._similarWordsIndex].weight = _loc4_.children[_loc6_].weight;
                  }
               }
               else
               {
                  this._similarWords[this._similarWordsIndex].word += _loc4_.children[_loc6_].char;
                  this._similarWords[this._similarWordsIndex].weight = _loc4_.children[_loc6_].weight;
               }
               if(_loc4_.children[_loc6_].weight > 0 && this._similarWords.length > this._similarWordsIndex)
               {
                  this._similarWords[this._similarWordsIndex].word = this.appendCompletionString(this._similarWords[this._similarWordsIndex].word);
                  this._similarWords[this._similarWordsIndex].weight = _loc4_.children[_loc6_].weight;
                  if(_loc4_ != this._currSearchNode)
                  {
                     return this._similarWords;
                  }
                  ++this._similarWordsIndex;
               }
               else
               {
                  if(_loc4_ != param3)
                  {
                     param2 += _loc4_.char;
                     param3 = _loc4_;
                  }
                  this.findAllSimilarWords(_loc4_.children[_loc6_],param2);
                  ++this._similarWordsIndex;
               }
               _loc6_++;
            }
            if(param1 == null && _loc4_.children.length == 0)
            {
               if(!(_loc4_.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == _loc4_.useType))
               {
                  this._similarWords.push({
                     "word":this.appendCompletionString(""),
                     "weight":_loc4_.weight
                  });
               }
            }
            --this._similarWordsIndex;
         }
         return this._similarWords;
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
         var _loc3_:PredictiveTextNode = null;
         var _loc4_:* = 0;
         var _loc2_:String = "";
         if(this._searchChildren)
         {
            _loc4_ = int(this._searchChildren.length - 1);
            for(; _loc4_ >= 0; _loc4_--)
            {
               if(!this._searchChildren[_loc4_].node)
               {
                  break;
               }
               if(_loc3_)
               {
                  if(_loc3_ == this._searchChildren[_loc4_].node)
                  {
                     continue;
                  }
                  if(this._searchChildren[_loc4_].node.char.length > 1)
                  {
                     _loc2_ += reverseString(this._searchChildren[_loc4_].node.char);
                  }
                  else
                  {
                     _loc2_ += this._searchChildren[_loc4_].node.char;
                  }
                  _loc3_ = this._searchChildren[_loc4_].node;
               }
               else
               {
                  if(this._searchChildren[_loc4_].node.char.length > 1)
                  {
                     _loc2_ += reverseString(this._searchChildren[_loc4_].node.char);
                  }
                  else
                  {
                     _loc2_ += this._searchChildren[_loc4_].node.char;
                  }
                  _loc3_ = this._searchChildren[_loc4_].node;
               }
            }
         }
         return reverseString(_loc2_) + param1;
      }
      
      private function countNodes(param1:PredictiveTextNode) : void
      {
         ++this._nodeCount;
         var _loc2_:int = 0;
         while(_loc2_ < param1.children.length)
         {
            this.countNodes(param1.children[_loc2_]);
            _loc2_++;
         }
      }
      
      private function countNodesAfter(param1:PredictiveTextNode) : void
      {
         ++this._nodeCountAfter;
         var _loc2_:int = 0;
         while(_loc2_ < param1.children.length)
         {
            this.countNodesAfter(param1.children[_loc2_]);
            _loc2_++;
         }
      }
      
      private function drawTree(param1:PredictiveTextNode, param2:String) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(param1.children)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.children.length)
            {
               if(_loc3_ == _loc4_)
               {
                  param2 += param1.char;
               }
               _loc3_ = _loc4_;
               this.drawTree(param1.children[_loc4_],param2);
               _loc4_++;
            }
            if(param1.children.length == 0)
            {
               param2 += param1.char;
            }
            if(param1.weight > 0)
            {
               ++this._numWordsPrinted;
            }
         }
      }
   }
}

