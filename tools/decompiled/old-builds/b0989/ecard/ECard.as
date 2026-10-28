package ecard
{
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import gui.ECardInbox;
   import loader.MediaHelper;
   
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
      
      private var _cardImg:MovieClip;
      
      private var _cardImgHelper:MediaHelper;
      
      private var _stampImg:MovieClip;
      
      private var _stampImgHelper:MediaHelper;
      
      private var _acceptBtn:MovieClip;
      
      private var _rejectBtn:MovieClip;
      
      private var _buddyButtonsLoadedCallback:Function;
      
      public function ECard()
      {
         super();
      }
      
      public function init(param1:int, param2:String, param3:int, param4:int, param5:Boolean, param6:String, param7:int, param8:int, param9:uint, param10:String, param11:int, param12:int, param13:int, param14:int) : void
      {
         this._msgId = param1;
         this._senderUserName = param2;
         this._cardMediaId = param3;
         this._stampMediaId = param4;
         this._isRead = param5;
         this._msg = param6;
         this._giftId = param8;
         this._giftColor = param9;
         this._giftName = param10;
         this._senderSGAccountType = param11;
         this._senderNameBarData = param12;
         this._secondaryType = param13;
         this._senderType = param14;
         if(param7 == TYPE_DEN_ACC)
         {
            if(DenXtCommManager.getDenItemDef(this._giftId).sortCat == DenItem.SORT_AUDIO)
            {
               this._type = TYPE_DEN_AUDIO;
            }
            else
            {
               this._type = param7;
            }
         }
         else
         {
            this._type = param7;
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
      
      public function set isRead(param1:Boolean) : void
      {
         this._isRead = param1;
      }
      
      public function get msg() : String
      {
         return this._msg;
      }
      
      public function set msg(param1:String) : void
      {
         this._msg = param1;
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
      
      public function get isSenderMember() : Boolean
      {
         return this._senderSGAccountType >= Utility.PREMIUM_MEMBER;
      }
      
      public function get isSenderArchived() : Boolean
      {
         return this._senderSGAccountType == Utility.ACCOUNT_TYPE_ARCHIVED;
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
      
      public function get isAJHQGift() : Boolean
      {
         return this.isFromVoice && this._giftId > 0;
      }
      
      public function get type() : int
      {
         return this._type;
      }
      
      public function set type(param1:int) : void
      {
         this._type = param1;
      }
      
      public function get secondaryType() : int
      {
         return this._secondaryType;
      }
      
      public function get nameBarData() : int
      {
         return this._senderNameBarData;
      }
      
      public function set nameBarData(param1:int) : void
      {
         this._senderNameBarData = param1;
      }
      
      public function get cardImg() : MovieClip
      {
         if(this._cardImg.numChildren == 0)
         {
            ECardInbox.loadingSpiral.visible = true;
            this._cardImgHelper = new MediaHelper();
            this._cardImgHelper.init(this._cardMediaId,this.cardImgReceived);
         }
         else if(ECardInbox.loadingSpiral)
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
      
      public function setBuddyButtonsLoadedCallback(param1:Function) : void
      {
         if(this._type == TYPE_BUDDY)
         {
            this._buddyButtonsLoadedCallback = param1;
         }
      }
      
      private function cardImgReceived(param1:MovieClip) : void
      {
         this._cardImg.addChild(param1);
         if(param1.userNameTxt)
         {
            param1.userNameTxt.text = this._senderUserName;
         }
         if(this._type == TYPE_BUDDY)
         {
            if(param1.acceptBtn)
            {
               this._acceptBtn = param1.acceptBtn;
            }
            if(param1.rejectBtn)
            {
               this._rejectBtn = param1.rejectBtn;
            }
            if(this._buddyButtonsLoadedCallback != null)
            {
               this._buddyButtonsLoadedCallback();
            }
         }
         if(ECardInbox.loadingSpiral)
         {
            ECardInbox.loadingSpiral.visible = false;
         }
      }
      
      private function stampImgReceived(param1:MovieClip) : void
      {
         this._stampImg.addChild(param1);
      }
   }
}

