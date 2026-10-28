package ecard
{
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import gui.ECardInbox;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ECard
   {
      
      public static const TYPE_STANDARD:int = 0;
      
      public static const TYPE_CLOTHING:int = 1;
      
      public static const TYPE_BUDDY:int = 2;
      
      public static const TYPE_DEN_ACC:int = 3;
      
      public static const TYPE_GEMS:int = 4;
      
      public static const TYPE_DEN_ROOM:int = 5;
      
      public static const TYPE_AVT:int = 6;
      
      public static const TYPE_SUBSCRIPTION:int = 7;
      
      public static const TYPE_PET:int = 8;
      
      public static const TYPE_DIAMOND:int = 9;
      
      public static const TYPE_DEN_AUDIO:int = 99;
      
      public static const MESSAGE_TYPE_BUBBLECHAT:int = 1;
      
      public static const MESSAGE_TYPE_LIMITEDCHAT:int = 2;
      
      public static const SENDER_USER:int = 0;
      
      public static const SENDER_VOICE:int = 1;
      
      public static const SENDER_REDEM:int = 2;
      
      private var _msgId:int;
      
      private var _senderUserName:String;
      
      private var _cardMediaId:int;
      
      private var _stampMediaId:int;
      
      private var _isRead:Boolean;
      
      private var _msg:String;
      
      private var _type:int;
      
      private var _secondaryType:int;
      
      private var _giftId:int;
      
      private var _giftColor:uint;
      
      private var _giftName:String;
      
      private var _senderType:int;
      
      private var _senderSGAccountType:int;
      
      private var _senderNameBarData:int;
      
      private var _userNameModerationFlag:int;
      
      private var _cardImg:MovieClip;
      
      private var _cardImgHelper:MediaHelper;
      
      private var _stampImg:MovieClip;
      
      private var _stampImgHelper:MediaHelper;
      
      private var _acceptBtn:MovieClip;
      
      private var _rejectBtn:MovieClip;
      
      private var _memberNameBar:MovieClip;
      
      private var _nonMemberNameBar:MovieClip;
      
      private var _nonMemberUserName:TextField;
      
      private var _charBox:MovieClip;
      
      private var _buddyButtonsLoadedCallback:Function;
      
      public function ECard()
      {
         super();
      }
      
      public function init(msgId:int, senderUserName:String, cardMediaId:int, stampMediaId:int, isRead:Boolean, msg:String, type:int, giftId:int, giftColor:uint, giftName:String, senderAcctType:int, senderNameBarData:int, secondaryType:int, senderType:int, userNameModerationFlag:int) : void
      {
         this._msgId = msgId;
         this._senderUserName = senderUserName;
         this._cardMediaId = cardMediaId;
         this._stampMediaId = stampMediaId;
         this._isRead = isRead;
         this._msg = msg;
         this._giftId = giftId;
         this._giftColor = giftColor;
         this._giftName = giftName;
         this._senderSGAccountType = senderAcctType;
         this._senderNameBarData = senderNameBarData;
         this._secondaryType = secondaryType;
         this._senderType = senderType;
         this._userNameModerationFlag = userNameModerationFlag;
         if(type == TYPE_DEN_ACC)
         {
            if(DenXtCommManager.getDenItemDef(this._giftId).sortCat == DenItem.SORT_AUDIO)
            {
               this._type = TYPE_DEN_AUDIO;
            }
            else
            {
               this._type = type;
            }
         }
         else
         {
            this._type = type;
         }
         this._stampImg = new MovieClip();
         this._cardImg = new MovieClip();
      }
      
      public function get msgId() : int
      {
         return this._msgId;
      }
      
      public function get senderUserName() : String
      {
         return this._senderUserName;
      }
      
      public function set senderUserName(value:String) : void
      {
         this._senderUserName = value;
      }
      
      public function get senderModeratedUserName() : String
      {
         if(this._userNameModerationFlag > 0)
         {
            return this._senderUserName;
         }
         return LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
      }
      
      public function get cardMediaId() : int
      {
         return this._cardMediaId;
      }
      
      public function get stampMediaId() : int
      {
         return this._stampMediaId;
      }
      
      public function get isRead() : Boolean
      {
         return this._isRead;
      }
      
      public function set isRead(value:Boolean) : void
      {
         this._isRead = value;
      }
      
      public function get msg() : String
      {
         return this._msg;
      }
      
      public function set msg(newMsg:String) : void
      {
         this._msg = newMsg;
      }
      
      public function get isBuddy() : Boolean
      {
         return this._type == TYPE_BUDDY;
      }
      
      public function get isGift() : Boolean
      {
         return this._type == TYPE_CLOTHING || this._type >= TYPE_DEN_ACC;
      }
      
      public function get giftId() : int
      {
         return this._giftId;
      }
      
      public function get giftColor() : uint
      {
         return this._giftColor;
      }
      
      public function get giftName() : String
      {
         return this._giftName;
      }
      
      public function set giftName(value:String) : void
      {
         this._giftName = value;
      }
      
      public function get isSenderMember() : Boolean
      {
         return this._senderSGAccountType >= Utility.PREMIUM_MEMBER;
      }
      
      public function get isSenderArchived() : Boolean
      {
         return this._senderSGAccountType == Utility.ACCOUNT_TYPE_ARCHIVED;
      }
      
      public function get senderSGAccountType() : int
      {
         return this._senderSGAccountType;
      }
      
      public function get isFromUser() : Boolean
      {
         return this._senderType == SENDER_USER;
      }
      
      public function get isFromVoice() : Boolean
      {
         return this._senderType == SENDER_VOICE;
      }
      
      public function get isStartupJAG() : Boolean
      {
         return this._senderType == SENDER_REDEM || !gMainFrame.userInfo.isMember && this.isAJHQGift;
      }
      
      public function get isRedemptionJAG() : Boolean
      {
         if(this.isStartupJAG && (this.giftId > 0 || this.type == ECard.TYPE_GEMS || this.type == ECard.TYPE_SUBSCRIPTION || this.type == ECard.TYPE_DIAMOND))
         {
            return true;
         }
         return false;
      }
      
      public function get isAJHQGift() : Boolean
      {
         return this.isFromVoice && this._giftId > 0;
      }
      
      public function get type() : int
      {
         return this._type;
      }
      
      public function set type(value:int) : void
      {
         this._type = value;
      }
      
      public function get secondaryType() : int
      {
         return this._secondaryType;
      }
      
      public function get nameBarData() : int
      {
         return this._senderNameBarData;
      }
      
      public function set nameBarData(value:int) : void
      {
         this._senderNameBarData = value;
      }
      
      public function get cardImg() : MovieClip
      {
         if(this._cardImg.numChildren == 0)
         {
            ECardInbox.loadingSpiral.visible = true;
            this._cardImgHelper = new MediaHelper();
            this._cardImgHelper.init(this._cardMediaId,this.cardImgReceived);
         }
         else if(Boolean(ECardInbox.loadingSpiral))
         {
            ECardInbox.loadingSpiral.visible = false;
         }
         return this._cardImg;
      }
      
      public function get stampImg() : MovieClip
      {
         if(this._type != TYPE_BUDDY && !this.isFromVoice)
         {
            if(this._stampImg.numChildren == 0)
            {
               this._stampImgHelper = new MediaHelper();
               this._stampImgHelper.init(this._stampMediaId,this.stampImgReceived);
            }
         }
         return this._stampImg;
      }
      
      public function get acceptBtn() : MovieClip
      {
         return this._acceptBtn;
      }
      
      public function get rejectBtn() : MovieClip
      {
         return this._rejectBtn;
      }
      
      public function get memberNameBar() : MovieClip
      {
         return this._memberNameBar;
      }
      
      public function get nonMemberNameBar() : MovieClip
      {
         return this._nonMemberNameBar;
      }
      
      public function get nonMemberUserName() : TextField
      {
         return this._nonMemberUserName;
      }
      
      public function get charBox() : MovieClip
      {
         return this._charBox;
      }
      
      public function setBuddyButtonsLoadedCallback(callback:Function) : void
      {
         if(this._type == TYPE_BUDDY)
         {
            this._buddyButtonsLoadedCallback = callback;
         }
      }
      
      private function cardImgReceived(cardImg:MovieClip) : void
      {
         this._cardImg.addChild(cardImg);
         if(Boolean(cardImg.userNameTxt))
         {
            cardImg.userNameTxt.text = this._senderUserName;
         }
         if(this._type == TYPE_BUDDY)
         {
            if(Boolean(cardImg.okBtn))
            {
               this._acceptBtn = cardImg.okBtn;
            }
            if(Boolean(cardImg.cancelBtn))
            {
               this._rejectBtn = cardImg.cancelBtn;
            }
            if(Boolean(cardImg.member))
            {
               this._memberNameBar = cardImg.member;
            }
            if(Boolean(cardImg.nonmember))
            {
               this._nonMemberNameBar = cardImg.nonmember;
            }
            if(Boolean(cardImg.userName_txt))
            {
               this._nonMemberUserName = cardImg.userName_txt;
            }
            if(Boolean(cardImg.charBox))
            {
               this._charBox = cardImg.charBox;
            }
            if(this._buddyButtonsLoadedCallback != null)
            {
               this._buddyButtonsLoadedCallback();
            }
         }
         if(Boolean(ECardInbox.loadingSpiral))
         {
            ECardInbox.loadingSpiral.visible = false;
         }
      }
      
      private function stampImgReceived(stampImg:MovieClip) : void
      {
         this._stampImg.addChild(stampImg);
      }
   }
}

