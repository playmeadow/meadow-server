package movie
{
   import loader.DefPacksDefHelper;
   
   public class MovieXtCommManager
   {
      
      private static var _movieNodeDefs:Object;
      
      private static var _movieTrees:Object = {};
      
      public function MovieXtCommManager()
      {
         super();
      }
      
      public static function movieNodeResponse(dfdh:DefPacksDefHelper) : void
      {
         var movieNodeDef:Object = null;
         var data:Object = null;
         var newDef:Object = dfdh.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_MOVIE_NODE] = null;
         var movieNodeDefs:Object = new Object();
         for each(data in dfdh.def)
         {
            movieNodeDef = {
               "choice1MovieNodeRefId":int(data.choice1MovieNodeRefId),
               "choice2MovieNodeRefId":int(data.choice2MovieNodeRefId),
               "choice3MovieNodeRefId":int(data.choice3MovieNodeRefId),
               "mediaRefId":int(data.mediaRefId),
               "iconMediaRefId":int(data.iconMediaRefId),
               "thumbMediaRefId":int(data.thumbMediaRefId),
               "denItemRefId":int(data.denItemRefId),
               "titleStrRef":int(data.titleStrRef),
               "streamRefId":int(data.streamRefId),
               "streamTitleStrRef":int(data.streamTitleStrRef),
               "userVarRefId":int(data.userVarRefId),
               "userVarBit":int(data.userVarBit),
               "subtitleId":int(data.subtitleRefId),
               "defId":int(data.id),
               "numChoices":0
            };
            movieNodeDef.numChoices = movieNodeDef.choice3MovieNodeRefId > 0 ? 3 : (movieNodeDef.choice2MovieNodeRefId > 0 ? 2 : (movieNodeDef.choice1MovieNodeRefId > 0 ? 1 : 0));
            movieNodeDefs[movieNodeDef.defId] = movieNodeDef;
         }
         _movieNodeDefs = movieNodeDefs;
         getAllContinuingNodes(1);
      }
      
      public static function get movieDefs() : Object
      {
         return _movieNodeDefs;
      }
      
      public static function getMovieDef(id:int) : MovieNode
      {
         return new MovieNode(_movieNodeDefs[id]);
      }
      
      public static function getMovieNodeFromTree(baseNodeId:int, defId:int) : MovieNode
      {
         if(_movieTrees[baseNodeId] != null)
         {
            return _movieTrees[baseNodeId][defId];
         }
         return null;
      }
      
      public static function getAllContinuingNodes(baseNodeId:int) : Array
      {
         var mtd:MovieTreeNode = null;
         if(_movieTrees[baseNodeId] == null)
         {
            _movieTrees[baseNodeId] = new Object();
            _movieTrees[baseNodeId][baseNodeId] = getTreeMovieDef(baseNodeId);
            buildNodeTree(_movieTrees[baseNodeId][baseNodeId],baseNodeId);
         }
         var correctNodes:Array = [];
         for each(mtd in _movieTrees[baseNodeId])
         {
            if(mtd.isCorrectChoice)
            {
               correctNodes.push(mtd);
            }
         }
         return correctNodes;
      }
      
      public static function getAllChapters(baseNodeId:int) : Array
      {
         var mtd:MovieTreeNode = null;
         if(_movieTrees[baseNodeId] == null)
         {
            _movieTrees[baseNodeId] = new Object();
            _movieTrees[baseNodeId][baseNodeId] = getTreeMovieDef(baseNodeId);
            buildNodeTree(_movieTrees[baseNodeId][baseNodeId],baseNodeId);
         }
         var chapterNodes:Array = [];
         for each(mtd in _movieTrees[baseNodeId])
         {
            if(mtd.isChapter)
            {
               chapterNodes.push(mtd);
            }
         }
         return chapterNodes;
      }
      
      public static function resetAllChosenChapters(baseNodeId:int) : void
      {
         var mtd:MovieTreeNode = null;
         for each(mtd in _movieTrees[baseNodeId])
         {
            if(mtd.hasChosenThisChoice)
            {
               mtd.hasChosenThisChoice = false;
            }
         }
      }
      
      private static function getTreeMovieDef(id:int) : MovieTreeNode
      {
         return new MovieTreeNode(_movieNodeDefs[id]);
      }
      
      private static function contains(baseNodeId:int, id:int) : int
      {
         var childLength:int = 0;
         var i:int = 0;
         if(_movieTrees[baseNodeId] != null)
         {
            childLength = int(_movieTrees[baseNodeId].length);
            for(i = 0; i < childLength; i++)
            {
               if(_movieTrees[baseNodeId][i].defId == id)
               {
                  return i;
               }
            }
         }
         return -1;
      }
      
      private static function buildNodeTree(currNode:MovieTreeNode, baseNodeId:int) : void
      {
         var parent:MovieTreeNode = null;
         if(currNode.nodeIndex > 3)
         {
            if(currNode.defId != baseNodeId)
            {
               parent = _movieTrees[baseNodeId][currNode.parentDefId];
               ++parent.nodeIndex;
               buildNodeTree(parent,baseNodeId);
            }
            return;
         }
         if(currNode.getChoiceById(currNode.nodeIndex) == 0)
         {
            if(currNode.defId == baseNodeId)
            {
               ++currNode.nodeIndex;
               buildNodeTree(currNode,baseNodeId);
            }
            else
            {
               if(currNode.userVarId != 0)
               {
                  currNode.isChapter = true;
               }
               if(currNode.denRewardId > 0)
               {
                  if(currNode.isChapter)
                  {
                     currNode.thisChapterHasGift = true;
                  }
                  else if(currNode.parentDefId != 0)
                  {
                     _movieTrees[baseNodeId][currNode.parentDefId].thisChapterHasGift = true;
                  }
               }
               currNode.isCorrectChoice = true;
               parent = _movieTrees[baseNodeId][currNode.parentDefId];
               ++parent.nodeIndex;
               buildNodeTree(parent,baseNodeId);
            }
            return;
         }
         var currChoiceNode:MovieTreeNode = getTreeMovieDef(currNode.getChoiceById(currNode.nodeIndex));
         if(currChoiceNode == null || currChoiceNode.nodeIndex > 3)
         {
            throw new Error("CurrChoiceNode was null or we are past 3rd index");
         }
         if(currChoiceNode.defId == currNode.parentDefId)
         {
            currNode.isChapter = false;
            parent = _movieTrees[baseNodeId][currChoiceNode.defId];
            if(parent.defId != currChoiceNode.defId)
            {
               throw new Error("Parent def id did not match current choices def id");
            }
            ++parent.nodeIndex;
            buildNodeTree(parent,baseNodeId);
         }
         else
         {
            if(currNode.userVarId != 0)
            {
               currNode.isChapter = true;
            }
            if(currNode.denRewardId > 0)
            {
               if(currNode.isChapter)
               {
                  currNode.thisChapterHasGift = true;
               }
               else
               {
                  _movieTrees[baseNodeId][currNode.parentDefId].thisChapterHasGift = true;
               }
            }
            currNode.isCorrectChoice = true;
            _movieTrees[baseNodeId][currChoiceNode.defId] = currChoiceNode;
            currChoiceNode.parentDefId = currNode.defId;
            buildNodeTree(currChoiceNode,baseNodeId);
         }
      }
   }
}

