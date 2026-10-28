package ecard
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import gui.ECardCreation;
   import gui.ECardInbox;
   import loader.MediaHelper;
   
   public class ECardManager
   {
      
      private static var _inbox:Array;
      
      private static var _cardMediaIds:Array;
      
      private static var _stampMediaIds:Array;
      
      private static var _cardIdObjects:Array;
      
      private static var _eCardInbox:ECardInbox;
      
      private static var _eCardCreation:ECardCreation;
      
      private static var _glowTimer:Timer;
      
      private static var _hudECardBtn:MovieClip;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _eCardInboxAndCreation:MovieClip;
      
      private static var _unreadCount:int;
      
      private static var _isFirstTime:Boolean;
      
      private static var _mediaHelper:MediaHelper;
      
      private static const ECARD_INBOX_CREATION_MEDIA_ID:int = 1353;
      
      public function ECardManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:MovieClip, param3:Boolean = false) : void
      {
         _guiLayer = param1;
         _hudECardBtn = param2;
         _hudECardBtn.glow.visible = false;
         _hudECardBtn.addEventListener(MouseEvent.MOUSE_DOWN,eCardBtnDownHandler,false,0,true);
         if(!param3)
         {
            _glowTimer = new Timer(5000);
            _glowTimer.addEventListener(TimerEvent.TIMER,glowTimerHandler,false,0,true);
            _inbox = new Array();
            _isFirstTime = true;
            _unreadCount = 0;
            _hudECardBtn.newEcardCount.visible = false;
            _hudECardBtn.newEcardCount.eCardCountTxt.text = "";
            ECardXtCommManager._deleteResponseCallback = onDeleteResponse;
         }
         else
         {
            _hudECardBtn.newEcardCount.visible = _unreadCount > 0;
            _hudECardBtn.newEcardCount.eCardCountTxt.text = _unreadCount;
         }
      }
      
      public static function destroy() : void
      {
         ECardXtCommManager._deleteResponseCallback = null;
      }
      
      public static function processECardList(param1:Array, param2:int) : void
      {
         _inbox = param1.concat();
         unreadCount = param2;
         if(_eCardInbox)
         {
            _eCardInbox.reloadInbox(_inbox);
         }
      }
      
      public static function processECardPush(param1:ECard) : void
      {
         if(param1.isAJHQGift && !gMainFrame.userInfo.isMember)
         {
            return;
         }
         inbox.push(param1);
         if(!param1.isRead)
         {
            ++unreadCount;
         }
      }
      
      public static function processECardUpdate(param1:int, param2:String) : void
      {
         var _loc3_:ECard = null;
         var _loc4_:int = 0;
         while(_loc4_ < _inbox.length)
         {
            _loc3_ = _inbox[_loc4_];
            if(_loc3_ != null && _loc3_.msgId == param1)
            {
               _loc3_.msg = param2;
               if(_eCardInbox)
               {
                  _eCardInbox.reloadInbox(_inbox);
               }
               break;
            }
            _loc4_++;
         }
      }
      
      public static function get inbox() : Array
      {
         return _inbox;
      }
      
      public static function onCardsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _cardMediaIds = param2;
      }
      
      public static function onStampsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _stampMediaIds = param2;
      }
      
      private static function eCardBtnDownHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(!_eCardInboxAndCreation)
            {
               createInboxAndCreationPopup("inbox");
            }
            else
            {
               _eCardInbox = new ECardInbox();
               _eCardInbox.init(_guiLayer,_inbox,createCard,onECardInboxClose);
            }
         }
      }
      
      private static function onECardInboxClose() : void
      {
         _hudECardBtn.downToUpState();
         if(_eCardCreation)
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
         }
         if(_eCardInbox)
         {
            _eCardInbox.destroy();
            _eCardInbox = null;
         }
      }
      
      public static function eCardVisibility() : Boolean
      {
         if(_eCardInbox)
         {
            return _eCardInbox.visibility || _eCardCreation.visibility;
         }
         return false;
      }
      
      public static function closeECard() : void
      {
         onECardInboxClose();
      }
      
      public static function createCard(param1:String, param2:String, param3:Boolean = true) : void
      {
         if(_eCardCreation)
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
         }
         else if(_eCardInboxAndCreation != null)
         {
            if(_eCardInbox)
            {
               _eCardInbox.showHide(true);
            }
            _eCardCreation = new ECardCreation();
            if(param3)
            {
               _eCardCreation.init(_guiLayer,param1,param2,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onCreateCardClose);
            }
            else
            {
               _eCardCreation.init(_guiLayer,param1,param2,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onCreateCardClose,true);
            }
         }
         else
         {
            createInboxAndCreationPopup("create",{
               "toUserName":param1,
               "moderatedToUserName":param2,
               "backBtnEnabled":param3
            });
         }
      }
      
      private static function createInboxAndCreationPopup(param1:String, param2:Object = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(ECARD_INBOX_CREATION_MEDIA_ID,onMediaItemLoaded,{
            "type":param1,
            "vars":param2
         });
      }
      
      private static function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _eCardInboxAndCreation = MovieClip(param1.getChildAt(0));
            _eCardInboxAndCreation.x = MainFrame.VIEW_WIDTH * 0.5;
            _eCardInboxAndCreation.y = MainFrame.VIEW_HEIGHT * 0.5;
            _guiLayer.addChild(_eCardInboxAndCreation);
            DarkenManager.darken(_eCardInboxAndCreation);
            if(param1.passback.type == "inbox")
            {
               _eCardInbox = new ECardInbox();
               _eCardInbox.init(_guiLayer,_inbox,createCard,onECardInboxClose);
            }
            else
            {
               _eCardCreation = new ECardCreation();
               if(param1.passback.vars.backBtnEnabled)
               {
                  _eCardCreation.init(_guiLayer,param1.passback.vars.toUserName,param1.passback.vars.moderatedToUserName,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onCreateCardClose);
               }
               else
               {
                  _eCardCreation.init(_guiLayer,param1.passback.vars.toUserName,param1.passback.vars.moderatedToUserName,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onCreateCardClose,true);
               }
            }
         }
      }
      
      private static function onCreateCardBackBtn(param1:Boolean) : void
      {
         if(_eCardCreation)
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
            if(_eCardInbox)
            {
               if(param1)
               {
                  _hudECardBtn.downToUpState();
                  _eCardInbox.destroy();
                  _eCardInbox = null;
               }
               else
               {
                  _eCardInbox.showHide(false);
               }
            }
         }
      }
      
      private static function onCreateCardClose() : void
      {
         if(_eCardCreation)
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
         }
         if(_eCardInbox)
         {
            _hudECardBtn.downToUpState();
            _eCardInbox.destroy();
            _eCardInbox = null;
         }
      }
      
      public static function onDeleteResponse(param1:Array, param2:Boolean) : void
      {
         var _loc3_:ECard = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(_eCardInbox)
         {
            _eCardInbox.onDeleteResponse(param1,param2);
         }
         else if(param2)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc5_ = 0;
               while(_loc5_ < _inbox.length)
               {
                  _loc3_ = _inbox[_loc5_];
                  if(_loc3_ != null && _loc3_.msgId == param1[_loc4_])
                  {
                     _inbox.splice(_loc5_,1);
                     break;
                  }
                  _loc5_++;
               }
               _loc4_++;
            }
         }
         if(param2)
         {
            _loc7_ = 0;
            while(_loc7_ < _inbox.length)
            {
               _loc3_ = _inbox[_loc7_];
               if(Boolean(_loc3_) && !_loc3_.isRead)
               {
                  _loc6_++;
               }
               _loc7_++;
            }
            _unreadCount = _loc6_;
            if(_unreadCount > 0)
            {
               _hudECardBtn.newEcardCount.eCardCountTxt.text = _unreadCount;
               _hudECardBtn.newEcardCount.visible = true;
            }
            else
            {
               _hudECardBtn.newEcardCount.visible = false;
               _hudECardBtn.newEcardCount.eCardCountTxt.text = "";
            }
         }
      }
      
      private static function glowTimerHandler(param1:TimerEvent) : void
      {
         _glowTimer.stop();
         if(_hudECardBtn)
         {
            _hudECardBtn.glow.visible = false;
         }
      }
      
      public static function get unreadCount() : int
      {
         return _unreadCount;
      }
      
      public static function set unreadCount(param1:int) : void
      {
         if(param1 > _unreadCount)
         {
            if(_glowTimer.running)
            {
               _glowTimer.stop();
            }
            if(!_eCardCreation)
            {
               _glowTimer.start();
               if(_hudECardBtn)
               {
                  _hudECardBtn.glow.visible = true;
               }
               AJAudio.playMailReceivedSound();
               if(_eCardInbox)
               {
                  if(_inbox.length == 1)
                  {
                     _eCardInbox.reloadInbox(inbox);
                  }
                  else
                  {
                     _eCardInbox.reloadInbox();
                  }
               }
            }
         }
         _unreadCount = param1;
         if(_hudECardBtn)
         {
            if(_unreadCount > 0)
            {
               _hudECardBtn.newEcardCount.eCardCountTxt.text = param1;
               _hudECardBtn.newEcardCount.visible = true;
            }
            else
            {
               _hudECardBtn.newEcardCount.visible = false;
               _hudECardBtn.newEcardCount.eCardCountTxt.text = "";
            }
         }
      }
      
      public static function get eCardInboxAndCreation() : MovieClip
      {
         return _eCardInboxAndCreation;
      }
      
      public static function get isFirstTime() : Boolean
      {
         return _isFirstTime;
      }
      
      public static function set isFirstTime(param1:Boolean) : void
      {
         _isFirstTime = param1;
      }
   }
}

