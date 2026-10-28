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
      
      public static function init(initGuiLayer:DisplayLayer, initECardBtn:MovieClip, rebuild:Boolean = false) : void
      {
         _guiLayer = initGuiLayer;
         _hudECardBtn = initECardBtn;
         _hudECardBtn.glow.visible = false;
         _hudECardBtn.addEventListener(MouseEvent.MOUSE_DOWN,eCardBtnDownHandler,false,0,true);
         if(!rebuild)
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
      
      public static function processECardList(paramList:Array, unreadECardsCount:int) : void
      {
         _inbox = paramList.concat();
         unreadCount = unreadECardsCount;
         if(Boolean(_eCardInbox))
         {
            _eCardInbox.reloadInbox(_inbox);
         }
      }
      
      public static function processECardPush(msg:ECard) : void
      {
         if(msg.isAJHQGift && !gMainFrame.userInfo.isMember)
         {
            return;
         }
         inbox.push(msg);
         if(!msg.isRead)
         {
            ++unreadCount;
         }
      }
      
      public static function processECardUpdate(msgId:int, newMsg:String) : void
      {
         var tempECard:ECard = null;
         for(var j:int = 0; j < _inbox.length; j++)
         {
            tempECard = _inbox[j];
            if(tempECard != null && tempECard.msgId == msgId)
            {
               tempECard.msg = newMsg;
               if(Boolean(_eCardInbox))
               {
                  _eCardInbox.reloadInbox(_inbox);
               }
               break;
            }
         }
      }
      
      public static function get inbox() : Array
      {
         return _inbox;
      }
      
      public static function onCardsLoaded(glId:int, mediaIds:Array, locStrs:Array) : void
      {
         _cardMediaIds = mediaIds;
      }
      
      public static function onStampsLoaded(glId:int, mediaIds:Array, locStrs:Array) : void
      {
         _stampMediaIds = mediaIds;
      }
      
      private static function eCardBtnDownHandler(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.isGray)
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
         if(Boolean(_eCardCreation))
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
         }
         if(Boolean(_eCardInbox))
         {
            _eCardInbox.destroy();
            _eCardInbox = null;
         }
      }
      
      public static function eCardVisibility() : Boolean
      {
         if(Boolean(_eCardInbox))
         {
            return _eCardInbox.visibility || _eCardCreation.visibility;
         }
         return false;
      }
      
      public static function closeECard() : void
      {
         onECardInboxClose();
      }
      
      public static function createCard(toUserName:String, moderatedToUserName:String, currUserAccountType:int, backBtnEnabled:Boolean = true) : void
      {
         if(Boolean(_eCardCreation))
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
         }
         else if(_eCardInboxAndCreation != null)
         {
            if(Boolean(_eCardInbox))
            {
               _eCardInbox.showHide(true);
            }
            _eCardCreation = new ECardCreation();
            if(backBtnEnabled)
            {
               _eCardCreation.init(_guiLayer,toUserName,moderatedToUserName,currUserAccountType,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onCreateCardClose);
            }
            else
            {
               _eCardCreation.init(_guiLayer,toUserName,moderatedToUserName,currUserAccountType,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onCreateCardClose,true);
            }
         }
         else
         {
            createInboxAndCreationPopup("create",{
               "toUserName":toUserName,
               "moderatedToUserName":moderatedToUserName,
               "toAccountType":currUserAccountType,
               "backBtnEnabled":backBtnEnabled
            });
         }
      }
      
      private static function createInboxAndCreationPopup(type:String, vars:Object = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(ECARD_INBOX_CREATION_MEDIA_ID,onMediaItemLoaded,{
            "type":type,
            "vars":vars
         });
      }
      
      private static function onMediaItemLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            DarkenManager.showLoadingSpiral(false);
            _eCardInboxAndCreation = MovieClip(img.getChildAt(0));
            _eCardInboxAndCreation.x = MainFrame.VIEW_WIDTH * 0.5;
            _eCardInboxAndCreation.y = MainFrame.VIEW_HEIGHT * 0.5;
            _guiLayer.addChild(_eCardInboxAndCreation);
            DarkenManager.darken(_eCardInboxAndCreation);
            if(img.passback.type == "inbox")
            {
               _eCardInbox = new ECardInbox();
               _eCardInbox.init(_guiLayer,_inbox,createCard,onECardInboxClose);
            }
            else
            {
               _eCardCreation = new ECardCreation();
               if(Boolean(img.passback.vars.backBtnEnabled))
               {
                  _eCardCreation.init(_guiLayer,img.passback.vars.toUserName,img.passback.vars.moderatedToUserName,img.passback.vars.toAccountType,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onCreateCardClose);
               }
               else
               {
                  _eCardCreation.init(_guiLayer,img.passback.vars.toUserName,img.passback.vars.moderatedToUserName,img.passback.vars.toAccountType,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onCreateCardClose,true);
               }
            }
         }
      }
      
      private static function onCreateCardBackBtn(destroyInbox:Boolean) : void
      {
         if(Boolean(_eCardCreation))
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
            if(Boolean(_eCardInbox))
            {
               if(destroyInbox)
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
         if(Boolean(_eCardCreation))
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
         }
         if(Boolean(_eCardInbox))
         {
            _hudECardBtn.downToUpState();
            _eCardInbox.destroy();
            _eCardInbox = null;
         }
      }
      
      public static function onDeleteResponse(msgIds:Array, status:Boolean) : void
      {
         var tempECard:ECard = null;
         var i:int = 0;
         var j:int = 0;
         var unreadCount:int = 0;
         var k:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(_eCardInbox))
         {
            _eCardInbox.onDeleteResponse(msgIds,status);
         }
         else if(status)
         {
            for(i = 0; i < msgIds.length; i++)
            {
               for(j = 0; j < _inbox.length; j++)
               {
                  tempECard = _inbox[j];
                  if(tempECard != null && tempECard.msgId == msgIds[i])
                  {
                     _inbox.splice(j,1);
                     break;
                  }
               }
            }
         }
         if(status)
         {
            for(k = 0; k < _inbox.length; k++)
            {
               tempECard = _inbox[k];
               if(Boolean(tempECard) && !tempECard.isRead)
               {
                  unreadCount++;
               }
            }
            _unreadCount = unreadCount;
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
      
      private static function glowTimerHandler(te:TimerEvent) : void
      {
         _glowTimer.stop();
         if(Boolean(_hudECardBtn))
         {
            _hudECardBtn.glow.visible = false;
         }
      }
      
      public static function get unreadCount() : int
      {
         return _unreadCount;
      }
      
      public static function set unreadCount(value:int) : void
      {
         if(value > _unreadCount)
         {
            if(_glowTimer.running)
            {
               _glowTimer.stop();
            }
            if(!_eCardCreation)
            {
               _glowTimer.start();
               if(Boolean(_hudECardBtn))
               {
                  _hudECardBtn.glow.visible = true;
               }
               AJAudio.playMailReceivedSound();
               if(Boolean(_eCardInbox))
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
         _unreadCount = value;
         if(Boolean(_hudECardBtn))
         {
            if(_unreadCount > 0)
            {
               _hudECardBtn.newEcardCount.eCardCountTxt.text = value;
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
      
      public static function set isFirstTime(value:Boolean) : void
      {
         _isFirstTime = value;
      }
   }
}

