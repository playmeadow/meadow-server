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
      
      protected var _thisChapterHasGift:Boolean;
      
      protected var _isChapter:Boolean;
      
      public function MovieNode(param1:Object)
      {
         super();
         this._defId = param1.defId;
         this._titleId = param1.titleStrRef;
         this._streamId = param1.streamRefId;
         this._streamTitleId = param1.streamTitleStrRef;
         this._mediaId = param1.mediaRefId;
         this._iconMediaId = param1.iconMediaRefId;
         this._thumbMediaId = param1.thumbMediaRefId;
         this._choices = {
            "choice1Id":param1.choice1MovieNodeRefId,
            "choice2Id":param1.choice2MovieNodeRefId,
            "choice3Id":param1.choice3MovieNodeRefId
         };
         this._denRewardId = param1.denItemRefId;
         this._userVarId = param1.userVarRefId;
         this._bitIndex = param1.userVarBit;
         this._numChoices = param1.numChoices;
         param1 = null;
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
      
      public function getChoiceById(param1:int) : int
      {
         return this._choices["choice" + param1 + "Id"];
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
      
      public function set thisChapterHasGift(param1:Boolean) : void
      {
         this._thisChapterHasGift = param1;
      }
      
      public function get thisChapterHasGift() : Boolean
      {
         return this._thisChapterHasGift;
      }
      
      public function get isChapter() : Boolean
      {
         return this._isChapter;
      }
      
      public function set isChapter(param1:Boolean) : void
      {
         this._isChapter = param1;
      }
      
      public function get hasChosenThisChoice() : Boolean
      {
         return this._hasChosenThisChoice;
      }
      
      public function set hasChosenThisChoice(param1:Boolean) : void
      {
         this._hasChosenThisChoice = param1;
      }
   }
}

