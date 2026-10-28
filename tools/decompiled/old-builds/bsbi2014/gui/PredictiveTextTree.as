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
      
      public function PredictiveTextTree(textNode:PredictiveTextNode, useType:int)
      {
         super();
         this._root = textNode;
         this._currSearchNode = this._root;
         this._useType = useType;
      }
      
      public static function init() : void
      {
         _defaultRoot = new PredictiveTextNode("",0,new Vector.<PredictiveTextNode>());
      }
      
      public static function addFromStart(s:Array) : void
      {
         _weightOfWord = s[1];
         _useType = s[2] == "" ? PredictiveTextManager.USE_TYPE_ALL : int(s[2]);
         add(s[0].split(""),0,_defaultRoot);
      }
      
      public static function get defaultRoot() : PredictiveTextNode
      {
         return _defaultRoot;
      }
      
      public static function optimizeTree(n:PredictiveTextNode) : void
      {
         var childLength:int = 0;
         var i:int = 0;
         var weight:int = 0;
         if(Boolean(n.children))
         {
            childLength = int(n.children.length);
            for(i = 0; i < childLength; i++)
            {
               optimizeTree(n.children[i]);
               if(n.weight > 0 || n == _defaultRoot || childLength > 1)
               {
                  if(Boolean(_lastKnowWordNode))
                  {
                     _lastKnowWordNode.children = _savedChildren;
                     _lastKnowWordNode.weight = Math.max(1,_lastKnowWordNode.weight);
                     _lastKnowWordNode.char = reverseString(_optimizationString);
                     _lastKnowWordNode = null;
                     _savedChildren = null;
                     _optimizationString = "";
                  }
               }
               else if(Boolean(_lastKnowWordNode))
               {
                  weight = _lastKnowWordNode.weight;
                  _lastKnowWordNode = n;
                  _lastKnowWordNode.weight = weight;
                  _optimizationString += n.char;
               }
            }
            if(n.weight > 0)
            {
               if(_lastKnowWordNode == null || n.weight > _lastKnowWordNode.weight)
               {
                  _savedChildren = n.children;
                  _lastKnowWordNode = n;
                  _optimizationString += n.char;
               }
            }
         }
      }
      
      private static function add(s:Array, index:int, newNode:PredictiveTextNode) : void
      {
         var nextNodeIndex:int = 0;
         if(index == s.length)
         {
            newNode.weight = Math.max(1,_weightOfWord);
            newNode.useType = _useType;
         }
         else
         {
            nextNodeIndex = newNode.contains(s[index]);
            if(nextNodeIndex != -1)
            {
               add(s,index + 1,newNode.children[nextNodeIndex]);
            }
            else
            {
               newNode.children.push(new PredictiveTextNode(s[index],0,new Vector.<PredictiveTextNode>(),false,_useType));
               add(s,index + 1,newNode.children[newNode.children.length - 1]);
            }
         }
      }
      
      private static function reverseString(s:String) : String
      {
         var temp:String = "";
         for(var i:int = s.length - 1; i >= 0; i--)
         {
            temp += s.charAt(i);
         }
         return temp;
      }
      
      public function destroy() : void
      {
         if(Boolean(_lastKnowWordNode))
         {
            _lastKnowWordNode.destroy();
            _lastKnowWordNode = null;
         }
         this._searchChildren = null;
         this._similarWords = null;
         _savedChildren = null;
      }
      
      public function updateRoot(textNode:PredictiveTextNode) : void
      {
         this._root = textNode;
         this.clearWordSuggestions();
         this.resetSearchTree();
      }
      
      public function containsString(s:String) : int
      {
         var answer:int = 0;
         answer = this.checkMyself(s);
         if(answer > 0)
         {
            return answer;
         }
         if(answer == -1)
         {
            return 0;
         }
         answer = this.checkMyChildren(s);
         if(answer > 0)
         {
            return answer;
         }
         return 0;
      }
      
      public function checkCurrentWordValidity() : int
      {
         var nodeToCheck:Object = null;
         var retValue:int = 0;
         if(this._searchChildren.length > 0)
         {
            nodeToCheck = this._searchChildren[this._searchChildren.length - 1];
            if(Boolean(nodeToCheck.node))
            {
               if(Boolean(this._currSearchNode))
               {
                  if(this._currSearchNode.isSpecialCharacter)
                  {
                     retValue = 3;
                  }
                  else if(this._currSearchNode.char.length > 1)
                  {
                     if(this._charSearchIndex == nodeToCheck.node.char.length)
                     {
                        this._charSearchIndex = 0;
                        if(nodeToCheck.node.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == nodeToCheck.node.useType)
                        {
                           retValue = this._currSearchNode.weight > 0 ? 1 : 0;
                        }
                        else
                        {
                           retValue = this._currSearchNode.weight > 0 ? 2 : 1;
                        }
                     }
                     else
                     {
                        retValue = 1;
                     }
                  }
                  else if(this._currSearchNode.char.charAt(this._charSearchIndex) == nodeToCheck.node.char)
                  {
                     if(nodeToCheck.node.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == nodeToCheck.node.useType)
                     {
                        retValue = this._currSearchNode.weight > 0 ? 1 : 0;
                     }
                     else
                     {
                        retValue = this._currSearchNode.weight > 0 ? 2 : 1;
                     }
                  }
                  else
                  {
                     retValue = 1;
                  }
               }
            }
            else
            {
               retValue = 2;
            }
         }
         return retValue;
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
         var obj:Object = null;
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
               obj = this._searchChildren[this._searchChildren.length - 1];
               this._currSearchNode = obj.node == null ? this._root : obj.node;
               this._charSearchIndex = obj.wordIndex;
            }
         }
         this.clearWordSuggestions();
      }
      
      public function onSpecialCharacter() : void
      {
         var tempNode:PredictiveTextNode = new PredictiveTextNode(this._currSearchNode.char,this._currSearchNode.weight,this._currSearchNode.children,true);
         this._searchChildren.push({
            "node":tempNode,
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
         var children:Vector.<PredictiveTextNode> = null;
         var i:int = 0;
         var restriction:String = "";
         if(Boolean(this._currSearchNode))
         {
            restriction += this._currSearchNode.char;
            children = this._currSearchNode.children;
            for(i = 0; i < children.length; i++)
            {
               if(children[i].char.charAt(0) == "-")
               {
                  restriction += "\\-";
               }
               else
               {
                  restriction += children[i].char.charAt(0);
               }
            }
         }
         return restriction;
      }
      
      private function checkMyself(s:String) : int
      {
         if(Boolean(this._currSearchNode))
         {
            if(this._currSearchNode.isSpecialCharacter)
            {
               return -1;
            }
            if(this._currSearchNode.char.length > 1 && !this._hasCompletedCheckingMyself)
            {
               if(this._currSearchNode.char.charAt(this._charSearchIndex) == s)
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
      
      private function checkMyChildren(s:String) : int
      {
         var currNodeChildLength:int = 0;
         var i:int = 0;
         var currSearchNodeChild:PredictiveTextNode = null;
         if(Boolean(this._currSearchNode))
         {
            currNodeChildLength = int(this._currSearchNode.children.length);
            for(i = 0; i < currNodeChildLength; i++)
            {
               this._hasCompletedCheckingMyself = false;
               currSearchNodeChild = this._currSearchNode.children[i];
               if(currSearchNodeChild.isSpecialCharacter)
               {
                  return 0;
               }
               if(currSearchNodeChild.char == s)
               {
                  this._searchChildren.push({
                     "node":currSearchNodeChild,
                     "wordIndex":0
                  });
                  this._currSearchNode = currSearchNodeChild;
                  if(currSearchNodeChild.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == currSearchNodeChild.useType)
                  {
                     return this._currSearchNode.weight > 0 || currSearchNodeChild.children.length > 0 ? 1 : 0;
                  }
                  return this._currSearchNode.weight > 0 ? 2 : 1;
               }
               if(currSearchNodeChild.char.length > 1)
               {
                  if(currSearchNodeChild.char.charAt(this._charSearchIndex) == s)
                  {
                     ++this._charSearchIndex;
                     if(this._charSearchIndex == currSearchNodeChild.char.length)
                     {
                        this._searchChildren.push({
                           "node":currSearchNodeChild,
                           "wordIndex":this._charSearchIndex
                        });
                        this._currSearchNode = currSearchNodeChild;
                        this._charSearchIndex = 0;
                     }
                     else
                     {
                        this._searchChildren.push({
                           "node":currSearchNodeChild,
                           "wordIndex":this._charSearchIndex
                        });
                        this._currSearchNode = currSearchNodeChild;
                     }
                     if(currSearchNodeChild.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == currSearchNodeChild.useType)
                     {
                        return (this._currSearchNode.weight > 0 || currSearchNodeChild.children.length > 0) && this._charSearchIndex == 0 ? 1 : 0;
                     }
                     return this._currSearchNode.weight > 0 && this._charSearchIndex == 0 ? 2 : 1;
                  }
               }
            }
         }
         this._searchChildren.push({
            "node":this._currSearchNode,
            "wordIndex":this._charSearchIndex
         });
         return 0;
      }
      
      private function findAllSimilarWords(nextNode:PredictiveTextNode = null, appendString:String = "", levelNode:PredictiveTextNode = null) : Vector.<Object>
      {
         var wordIndex:int = 0;
         var i:int = 0;
         var searchNode:PredictiveTextNode = nextNode != null ? nextNode : this._currSearchNode;
         if(searchNode == this._root)
         {
            return this._similarWords;
         }
         if(levelNode == null)
         {
            levelNode = this._currSearchNode;
         }
         if(Boolean(searchNode))
         {
            wordIndex = int(this._searchChildren[this._searchChildren.length - 1].wordIndex);
            if(searchNode == this._currSearchNode && this._currSearchNode.char.length > 1 && this._currSearchNode.weight > 0 && wordIndex < this._currSearchNode.char.length)
            {
               if(!(searchNode.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == searchNode.useType))
               {
                  this._similarWords.push({
                     "word":this.appendCompletionString(""),
                     "weight":this._currSearchNode.weight,
                     "index":wordIndex
                  });
                  ++this._similarWordsIndex;
               }
            }
            for(i = 0; i < searchNode.children.length; i++)
            {
               if(this._similarWords.length <= this._similarWordsIndex)
               {
                  if(!(searchNode.children[i].useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == searchNode.children[i].useType))
                  {
                     this._similarWords.push({
                        "word":appendString,
                        "weight":searchNode.children[i].weight
                     });
                     this._similarWords[this._similarWordsIndex].word += searchNode.children[i].char;
                     this._similarWords[this._similarWordsIndex].weight = searchNode.children[i].weight;
                  }
               }
               else
               {
                  this._similarWords[this._similarWordsIndex].word += searchNode.children[i].char;
                  this._similarWords[this._similarWordsIndex].weight = searchNode.children[i].weight;
               }
               if(searchNode.children[i].weight > 0 && this._similarWords.length > this._similarWordsIndex)
               {
                  this._similarWords[this._similarWordsIndex].word = this.appendCompletionString(this._similarWords[this._similarWordsIndex].word);
                  this._similarWords[this._similarWordsIndex].weight = searchNode.children[i].weight;
                  if(searchNode != this._currSearchNode)
                  {
                     return this._similarWords;
                  }
                  ++this._similarWordsIndex;
               }
               else
               {
                  if(searchNode != levelNode)
                  {
                     appendString += searchNode.char;
                     levelNode = searchNode;
                  }
                  this.findAllSimilarWords(searchNode.children[i],appendString);
                  ++this._similarWordsIndex;
               }
            }
            if(nextNode == null && searchNode.children.length == 0)
            {
               if(!(searchNode.useType > PredictiveTextManager.USE_TYPE_ALL && this._useType == searchNode.useType))
               {
                  this._similarWords.push({
                     "word":this.appendCompletionString(""),
                     "weight":searchNode.weight
                  });
               }
            }
            --this._similarWordsIndex;
         }
         return this._similarWords;
      }
      
      private function compare(x:Object, y:Object) : int
      {
         if(x.weight > y.weight)
         {
            return -1;
         }
         if(x.weight < y.weight)
         {
            return 1;
         }
         return 0;
      }
      
      private function appendCompletionString(s:String) : String
      {
         var lastGoodChild:PredictiveTextNode = null;
         var i:int = 0;
         var completionString:String = "";
         if(Boolean(this._searchChildren))
         {
            for(i = this._searchChildren.length - 1; i >= 0; i--)
            {
               if(!Boolean(this._searchChildren[i].node))
               {
                  break;
               }
               if(Boolean(lastGoodChild))
               {
                  if(lastGoodChild == this._searchChildren[i].node)
                  {
                     continue;
                  }
                  if(this._searchChildren[i].node.char.length > 1)
                  {
                     completionString += reverseString(this._searchChildren[i].node.char);
                  }
                  else
                  {
                     completionString += this._searchChildren[i].node.char;
                  }
                  lastGoodChild = this._searchChildren[i].node;
               }
               else
               {
                  if(this._searchChildren[i].node.char.length > 1)
                  {
                     completionString += reverseString(this._searchChildren[i].node.char);
                  }
                  else
                  {
                     completionString += this._searchChildren[i].node.char;
                  }
                  lastGoodChild = this._searchChildren[i].node;
               }
            }
         }
         return reverseString(completionString) + s;
      }
      
      private function countNodes(n:PredictiveTextNode) : void
      {
         ++this._nodeCount;
         for(var i:int = 0; i < n.children.length; i++)
         {
            this.countNodes(n.children[i]);
         }
      }
      
      private function countNodesAfter(n:PredictiveTextNode) : void
      {
         ++this._nodeCountAfter;
         for(var i:int = 0; i < n.children.length; i++)
         {
            this.countNodesAfter(n.children[i]);
         }
      }
      
      private function drawTree(n:PredictiveTextNode, appendString:String) : void
      {
         var i:int = 0;
         var initialI:int = 0;
         if(Boolean(n.children))
         {
            for(i = 0; i < n.children.length; i++)
            {
               if(initialI == i)
               {
                  appendString += n.char;
               }
               initialI = i;
               this.drawTree(n.children[i],appendString);
            }
            if(n.children.length == 0)
            {
               appendString += n.char;
            }
            if(n.weight > 0)
            {
               ++this._numWordsPrinted;
            }
         }
      }
   }
}

