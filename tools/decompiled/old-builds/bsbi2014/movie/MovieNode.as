package movie
{
   public class MovieNode
   {
      
      private var _titleId:int;
      
      private var _streamId:int;
      
      private var _streamTitleId:int;
      
      private var _mediaId:int;
      
      private var _iconMediaId:int;
      
      private var _thumbMediaId:int;
      
      private var _choices:Object;
      
      private var _denRewardId:int;
      
      private var _userVarId:int;
      
      private var _bitIndex:int;
      
      private var _defId:int;
      
      private var _numChoices:int;
      
      private var _hasChosenThisChoice:Boolean;
      
      private var _subtitleId:int;
      
      protected var _thisChapterHasGift:Boolean;
      
      protected var _isChapter:Boolean;
      
      public function MovieNode(node:Object)
      {
         super();
         this._defId = node.defId;
         this._titleId = node.titleStrRef;
         this._streamId = node.streamRefId;
         this._streamTitleId = node.streamTitleStrRef;
         this._mediaId = node.mediaRefId;
         this._iconMediaId = node.iconMediaRefId;
         this._thumbMediaId = node.thumbMediaRefId;
         this._choices = {
            "choice1Id":node.choice1MovieNodeRefId,
            "choice2Id":node.choice2MovieNodeRefId,
            "choice3Id":node.choice3MovieNodeRefId
         };
         this._denRewardId = node.denItemRefId;
         this._userVarId = node.userVarRefId;
         this._bitIndex = node.userVarBit;
         this._numChoices = node.numChoices;
         this._subtitleId = node.subtitleId;
         node = null;
      }
      
      public function get defId() : int
      {
         return this._defId;
      }
      
      public function get titleId() : int
      {
         return this._titleId;
      }
      
      public function get streamId() : int
      {
         return this._streamId;
      }
      
      public function get streamTitleId() : int
      {
         return this._streamTitleId;
      }
      
      public function get mediaId() : int
      {
         return this._mediaId;
      }
      
      public function get iconMediaId() : int
      {
         return this._iconMediaId;
      }
      
      public function get thumbMediaId() : int
      {
         return this._thumbMediaId;
      }
      
      public function getChoiceById(id:int) : int
      {
         return this._choices["choice" + id + "Id"];
      }
      
      public function get choice1Id() : int
      {
         return this._choices.choice1Id;
      }
      
      public function get choice2Id() : int
      {
         return this._choices.choice2Id;
      }
      
      public function get choice3Id() : int
      {
         return this._choices.choice3Id;
      }
      
      public function get denRewardId() : int
      {
         return this._denRewardId;
      }
      
      public function get userVarId() : int
      {
         return this._userVarId;
      }
      
      public function get bitIndex() : int
      {
         return this._bitIndex;
      }
      
      public function get numChoices() : int
      {
         return this._numChoices;
      }
      
      public function set thisChapterHasGift(value:Boolean) : void
      {
         this._thisChapterHasGift = value;
      }
      
      public function get thisChapterHasGift() : Boolean
      {
         return this._thisChapterHasGift;
      }
      
      public function get isChapter() : Boolean
      {
         return this._isChapter;
      }
      
      public function set isChapter(value:Boolean) : void
      {
         this._isChapter = value;
      }
      
      public function get hasChosenThisChoice() : Boolean
      {
         return this._hasChosenThisChoice;
      }
      
      public function set hasChosenThisChoice(value:Boolean) : void
      {
         this._hasChosenThisChoice = value;
      }
      
      public function get subtitleId() : int
      {
         return this._subtitleId;
      }
      
      public function set subtitleId(id:int) : void
      {
         this._subtitleId = id;
      }
   }
}

