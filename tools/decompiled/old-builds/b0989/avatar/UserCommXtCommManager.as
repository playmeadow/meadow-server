package avatar
{
   import com.adobe.utils.StringUtil;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.FileServerEvent;
   import com.sbi.popup.*;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextFormat;
   import game.MinigameManager;
   import gui.ActionManager;
   import gui.ChatHistory;
   import gui.EmoticonManager;
   import gui.EmoticonUtility;
   import gui.GuiManager;
   import gui.SafeChatManager;
   import loader.DefPacksDefHelper;
   import loader.JCDefHelper;
   import room.RoomManagerWorld;
   
   public class UserCommXtCommManager
   {
      
      public static var RAW_STR:String;
      
      private static var _mainHud:MovieClip;
      
      private static var _chatHist:ChatHistory;
      
      private static var _emoteMgr:EmoticonManager;
      
      private static var _actionMgr:ActionManager;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _spellingCorrections:Object;
      
      private static var _emoteDefs:Object;
      
      private static var _specialWords:Object;
      
      private static var _replacedWords:Object;
      
      public static const CHAT_TYPE_TYPED:int = 0;
      
      public static const CHAT_TYPE_SAFE:int = 1;
      
      public static const CHAT_TYPE_EMOTE:int = 2;
      
      public static const CHAT_TYPE_ACTION:int = 3;
      
      public static const CHAT_TYPE_ATTACHMENT:int = 4;
      
      public static const CHAT_TYPE_PERM_EMOTE:int = 5;
      
      public static const CHAT_TYPE_SLIDE:int = 6;
      
      public static const CHAT_TYPE_PET_ACTION:int = 7;
      
      public static const CHAT_TYPE_BLEND_COLOR:int = 8;
      
      public static const CHAT_TYPE_LIMITED:int = 9;
      
      public static const CHAT_TYPE_ALPHA_LEVEL:int = 10;
      
      private static var _playerSfsUserId:int = -1;
      
      public function UserCommXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         DebugUtility.debugTrace("UserCommXtCommManager init - initializing");
         _mainHud = GuiManager.mainHud;
         _chatHist = GuiManager.chatHist;
         _emoteMgr = GuiManager.emoteMgr;
         _actionMgr = GuiManager.actionMgr;
         _roomMgr = RoomManagerWorld.instance;
         _playerSfsUserId = AvatarManager.playerSfsUserId;
         RAW_STR = gMainFrame.server.rawProtocolSeparator;
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init(DefPacksDefHelper.DEF_EMOTICON,onEmoticonDefsLoaded,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_EMOTICON] = _loc1_;
         _loc1_ = new DefPacksDefHelper();
         _loc1_.init(DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE,onAutoCorrectListLoaded,null,FileServerEvent.PLAIN_TEXT_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE] = _loc1_;
         _specialWords = {};
         _specialWords["cockroach"] = "roach";
      }
      
      private static function onAutoCorrectListLoaded(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE] = null;
         var _loc2_:String = param1.def.toString().toLowerCase() as String;
         _spellingCorrections = {};
         var _loc3_:Array = _loc2_.split("\r\n");
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc3_[_loc4_] = _loc3_[_loc4_].split(",");
            if(!(_loc3_[_loc4_][0] == null || _loc3_[_loc4_][0].length == 0 || _loc3_[_loc4_][1] == null || _loc3_[_loc4_][1].length == 0))
            {
               _spellingCorrections[StringUtil.trim(_loc3_[_loc4_][0])] = StringUtil.trim(_loc3_[_loc4_][1]);
            }
            _loc4_++;
         }
      }
      
      private static function onEmoticonDefsLoaded(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_EMOTICON] = null;
         var _loc2_:Object = param1.def;
         var _loc3_:Object = new Object();
         for each(_loc4_ in _loc2_)
         {
            _loc3_[_loc4_.id] = int(_loc4_.mediaRef);
         }
         _emoteDefs = _loc3_;
      }
      
      public static function destroy() : void
      {
      }
      
      public static function set playerSfsUserId(param1:int) : void
      {
         _playerSfsUserId = param1;
      }
      
      public static function getEmoticonMediaId(param1:int) : int
      {
         if(!_emoteDefs[param1])
         {
            return 0;
         }
         return _emoteDefs[param1];
      }
      
      public static function getEmoticonDefId(param1:int) : int
      {
         var _loc2_:String = null;
         for(_loc2_ in _emoteDefs)
         {
            if(_emoteDefs[_loc2_] == param1)
            {
               return int(_loc2_);
            }
         }
         return 0;
      }
      
      public static function addChatMessage(param1:String) : void
      {
         _chatHist.addMessage(gMainFrame.userInfo.playerAvatarInfo.avName,param1);
      }
      
      public static function sendAvatarSafeChat(param1:String, param2:String, param3:Boolean = true) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         AvatarManager.addAvatarMessage(param1,_playerSfsUserId,0);
         addChatMessage(param1);
         gMainFrame.server.sendMessage(param2 + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_SAFE);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = _chatHist.chatMsgText;
         }
         if(param3)
         {
            GuiManager.safeChatBtnDownHandler(null);
         }
      }
      
      public static function sendAvatarEmote(param1:Sprite) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         AvatarManager.setAvatarEmote(param1);
         if(!EmoticonUtility.getEmoteString(param1))
         {
            throw new Error("setAvatarEmote: sent invalid emote sprite?!");
         }
         addChatMessage(EmoticonUtility.getEmoteString(param1));
         gMainFrame.server.sendMessage(EmoticonUtility.idForEmote(param1) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_EMOTE);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = _chatHist.chatMsgText;
         }
      }
      
      public static function sendAvatarAction(param1:Sprite) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         AvatarManager.setAvatarAction(param1);
         if(!_actionMgr.getActionString(param1))
         {
            throw new Error("setAvatarAction: sent invalid action sprite?!");
         }
         addChatMessage(_actionMgr.getActionString(param1));
         var _loc2_:AvatarWorldView = AvatarManager.avatarViewList[AvatarManager.playerSfsUserId];
         var _loc3_:int = _loc2_.lastIdleAnim;
         gMainFrame.server.sendMessage(_actionMgr.getActionString(param1) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_ACTION + RAW_STR + _loc3_);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = _chatHist.chatMsgText;
         }
      }
      
      public static function sendAvatarAttachmentEmot(param1:int, param2:String = null) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         if(param2 == null)
         {
            param2 = "";
         }
         gMainFrame.server.sendMessage(param1 + "," + param2 + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_ATTACHMENT);
      }
      
      public static function sendAvatarBlendColor(param1:uint) : void
      {
         gMainFrame.server.sendMessage(int(param1) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_BLEND_COLOR);
      }
      
      public static function sendAvatarAlphaLevel(param1:uint) : void
      {
         gMainFrame.server.sendMessage(int(param1) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_ALPHA_LEVEL);
      }
      
      public static function sendChatMessage(param1:int, param2:String, param3:Boolean) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode) || !Utility.canChat())
         {
            return;
         }
         param2 = fixMispellings(param2);
         param2 = adjustCamelCase(param2);
         AvatarManager.addAvatarMessage(param2,param1,0);
         param2 = adjustSpecialWords(param2);
         var _loc4_:int = gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_FREE ? CHAT_TYPE_TYPED : CHAT_TYPE_LIMITED;
         gMainFrame.server.sendMessage(param2 + RAW_STR + int(param3) + RAW_STR + _loc4_);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = _chatHist.chatMsgText;
         }
      }
      
      private static function adjustSpecialWords(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         _replacedWords = {};
         var _loc2_:Array = param1.split(" ");
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(_loc6_ < _loc2_.length)
         {
            _loc3_ = _loc2_[_loc6_];
            _loc4_ = _loc3_.toLowerCase();
            for(_loc7_ in _specialWords)
            {
               _loc8_ = _loc4_.indexOf(_loc7_);
               if(_loc8_ >= 0)
               {
                  _loc9_ = _loc3_.substr(0,_loc8_);
                  _loc10_ = _loc3_.substr(_loc8_,_loc7_.length);
                  _loc11_ = _loc3_.substr(_loc8_ + _loc7_.length);
                  _loc5_ = getCaseType(_loc10_);
                  _loc10_ = setCaseType(_specialWords[_loc7_],_loc5_);
                  _loc2_[_loc6_] = _loc9_ + _loc10_ + _loc11_;
                  _replacedWords[_loc2_[_loc6_]] = _loc3_;
               }
            }
            _loc6_++;
         }
         return _loc2_.join(" ");
      }
      
      private static function getCaseType(param1:String) : int
      {
         if(param1.toLowerCase() == param1)
         {
            return 0;
         }
         var _loc2_:String = param1.charAt(0);
         var _loc3_:int = int(param1.match(/[A-Z]/g).length);
         if(_loc3_ == param1.length)
         {
            return 1;
         }
         return 2;
      }
      
      private static function setCaseType(param1:String, param2:int) : String
      {
         if(param2 == 0)
         {
            return param1.toLowerCase();
         }
         if(param2 == 1)
         {
            return param1.toUpperCase();
         }
         param1 = param1.toLowerCase();
         var _loc3_:String = param1.charAt(0).toUpperCase();
         return _loc3_ + param1.substr(1);
      }
      
      private static function reverseSpecialWords(param1:String) : String
      {
         var _loc2_:String = null;
         if(_replacedWords == null)
         {
            return param1;
         }
         var _loc3_:Array = param1.split(" ");
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_].toLowerCase();
            if(!(_replacedWords[_loc2_] == null || _loc2_ == "constructor"))
            {
               _loc3_[_loc4_] = _replacedWords[_loc2_];
            }
            _loc4_++;
         }
         _replacedWords = null;
         return _loc3_.join(" ");
      }
      
      private static function adjustCamelCase(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc8_:int = 0;
         var _loc2_:Array = param1.split(" ");
         var _loc7_:int = 0;
         while(_loc7_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc7_];
            _loc5_ = _loc4_.match(/[a-zA-Z]/g).join("");
            _loc6_ = _loc5_.charAt(0);
            _loc3_ = int(_loc5_.match(/[A-Z]/g).length);
            if(_loc3_ > 0 && _loc3_ != _loc5_.length)
            {
               if(_loc6_.match(/[A-z]/g).length == 1)
               {
                  _loc8_ = getIndexOfFirstLetter(_loc4_,_loc5_);
                  _loc2_[_loc7_] = _loc4_.substr(0,_loc8_) + _loc6_ + _loc4_.toLowerCase().substr(_loc8_ + 1,_loc4_.length);
               }
               else
               {
                  _loc2_[_loc7_] = _loc4_.toLowerCase();
               }
            }
            _loc7_++;
         }
         return _loc2_.join(" ");
      }
      
      public static function getFirstLetter(param1:String) : String
      {
         var _loc2_:String = param1.match(/[a-zA-Z]/g).join("");
         if(_loc2_.length > 0)
         {
            return _loc2_.charAt(0);
         }
         return null;
      }
      
      public static function getIndexOfFirstLetter(param1:String, param2:String) : int
      {
         if(param2 == "")
         {
            param2 = param1.match(/[a-zA-Z]/g).join();
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param1.charAt(_loc3_) == param2.charAt(0))
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public static function fixMispellings(param1:String) : String
      {
         var _loc3_:String = null;
         if(!_spellingCorrections)
         {
            return param1;
         }
         var _loc2_:Array = param1.split(" ");
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = _loc2_[_loc4_].toLowerCase();
            _loc3_ = stripPunctuation(_loc3_);
            if(_spellingCorrections[_loc3_] != null)
            {
               _loc3_ = _spellingCorrections[_loc3_];
               _loc2_[_loc4_] = _loc3_;
            }
            _loc4_++;
         }
         return _loc2_.join(" ");
      }
      
      public static function stripPunctuation(param1:String) : String
      {
         return param1.replace(/[^A-Za-z0-9 ]+/g,"");
      }
      
      public static function sendAvatarSlide(param1:String) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         gMainFrame.server.sendMessage(param1 + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_SLIDE);
      }
      
      public static function sendPermEmote(param1:int, param2:Boolean) : void
      {
         gMainFrame.server.sendMessage(param1 + RAW_STR + int(param2) + RAW_STR + CHAT_TYPE_PERM_EMOTE);
      }
      
      public static function sendPetAction(param1:int, param2:int = 0) : void
      {
         gMainFrame.server.sendMessage(param1 + "," + param2 + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_PET_ACTION);
      }
      
      public static function onSendMessage(param1:MouseEvent) : void
      {
         var _loc4_:Sprite = null;
         var _loc5_:String = null;
         if(_playerSfsUserId == -1)
         {
            DebugUtility.debugTrace("WARNING - UserCommXtCommManager.init was never called or the playerAvatarId is bad");
            _playerSfsUserId = AvatarManager.playerSfsUserId;
         }
         var _loc2_:String = _mainHud.chatBar.text01_chat.text;
         _loc2_ = _loc2_.split("\r").join("");
         _loc2_ = _loc2_.split(RAW_STR).join("");
         _loc2_ = StringUtil.trim(_loc2_);
         if(_loc2_.length <= 0)
         {
            return;
         }
         var _loc3_:Object = EmoticonUtility.matchEmoteString(_loc2_);
         if(_loc3_.status)
         {
            if(_loc3_.sprite)
            {
               sendAvatarEmote(_loc3_.sprite);
               AvatarManager.setAvatarEmote(_loc3_.sprite,-2);
            }
            else
            {
               _loc4_ = _actionMgr.matchActionString(_loc2_);
               if(_loc4_)
               {
                  sendAvatarAction(_loc4_);
                  AvatarManager.setAvatarAction(_loc4_,-2);
               }
               else
               {
                  _loc5_ = SafeChatManager.safeChatCodeForString(_loc2_);
                  if(_loc5_)
                  {
                     sendAvatarSafeChat(_loc2_,_loc5_,false);
                     AvatarManager.addAvatarMessage(_loc2_,_playerSfsUserId,0);
                  }
                  else
                  {
                     sendChatMessage(_playerSfsUserId,_loc2_,MinigameManager.inMinigame());
                  }
               }
            }
            return;
         }
         _chatHist.chatMsgText.text = "";
         gMainFrame.stage.focus = _chatHist.chatMsgText;
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "uc":
               userCommChatResponse(_loc2_);
               break;
            case "ua":
               userCommAdminMessageResponse(_loc2_);
               break;
            default:
               throw new Error("UserCommXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function userCommChatResponse(param1:Array) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:Boolean = false;
         var _loc10_:String = null;
         var _loc11_:Sprite = null;
         var _loc12_:Sprite = null;
         var _loc13_:Array = null;
         var _loc14_:int = 0;
         var _loc15_:Avatar = null;
         var _loc2_:int = int(param1[2]);
         var _loc3_:Boolean = Boolean(int(param1[4]));
         var _loc4_:int = int(param1[5]);
         var _loc5_:Boolean = true;
         if(_loc5_)
         {
            if(_loc4_ == CHAT_TYPE_PERM_EMOTE)
            {
               _loc6_ = int(param1[3]);
               if(_loc6_ >= 0)
               {
                  AvatarManager.setAvatarEmote(null,_loc2_,_loc6_);
               }
               else
               {
                  AvatarManager.setChatBalloonReadyForClear(_loc2_);
               }
            }
            else if(_loc4_ == CHAT_TYPE_SLIDE)
            {
               if(_loc2_ != gMainFrame.server.userId)
               {
                  _roomMgr.attachAvatarToSlide(AvatarManager.avatarViewList[_loc2_],param1[3]);
               }
            }
            else if(_loc4_ == CHAT_TYPE_PET_ACTION)
            {
               _loc7_ = param1[3].split(",");
               AvatarManager.setPetAction(_loc2_,_loc7_[0],_loc7_[1]);
            }
            else
            {
               _loc8_ = param1[3];
               _loc9_ = false;
               if(_loc4_ == CHAT_TYPE_SAFE)
               {
                  _loc10_ = SafeChatManager.safeChatStringForCode(_loc8_);
                  if(_loc10_)
                  {
                     _loc8_ = _loc10_;
                  }
                  else
                  {
                     _loc9_ = true;
                  }
               }
               if(!_loc9_)
               {
                  switch(_loc4_)
                  {
                     case CHAT_TYPE_TYPED:
                     case CHAT_TYPE_LIMITED:
                     case CHAT_TYPE_SAFE:
                        _loc8_ = adjustCamelCase(_loc8_);
                        if(_loc2_ == gMainFrame.server.userId)
                        {
                           _loc8_ = reverseSpecialWords(_loc8_);
                        }
                        AvatarManager.addAvatarMessage(_loc8_,_loc2_,int(param1[6]));
                        break;
                     case CHAT_TYPE_EMOTE:
                        _loc11_ = EmoticonUtility.emoteForId(int(_loc8_));
                        if(_loc11_)
                        {
                           AvatarManager.setAvatarEmote(_loc11_,_loc2_);
                        }
                        else
                        {
                           _loc9_ = true;
                        }
                        _loc8_ = EmoticonUtility.stringForId(int(_loc8_));
                        break;
                     case CHAT_TYPE_ACTION:
                        _loc12_ = _actionMgr.matchActionString(_loc8_);
                        if(_loc12_)
                        {
                           AvatarManager.setAvatarAction(_loc12_,_loc2_);
                        }
                        else
                        {
                           _loc9_ = true;
                        }
                        break;
                     case CHAT_TYPE_ATTACHMENT:
                        _loc13_ = _loc8_.split(",");
                        _loc14_ = int(_loc13_[0]);
                        AvatarManager._setAvatarAttachmentEmot(_loc14_,_loc13_[1],_loc2_);
                        break;
                     case CHAT_TYPE_BLEND_COLOR:
                        AvatarManager._setAvatarBlendColor(_loc2_,uint(param1[3]));
                        return;
                     case CHAT_TYPE_ALPHA_LEVEL:
                        AvatarManager._setAvatarAlphaLevel(_loc2_,uint(param1[3]));
                        return;
                     default:
                        _loc9_ = true;
                  }
               }
               if(_loc9_)
               {
                  DebugUtility.debugTrace("WARNING - got bad chat! msg:" + _loc8_ + " chatType:" + _loc4_ + " from userId:" + _loc2_);
                  return;
               }
               if(_loc4_ != CHAT_TYPE_ATTACHMENT)
               {
                  if(gMainFrame.clientInfo.extCallsActive)
                  {
                     _loc15_ = AvatarManager.getAvatarBySfsUserId(_loc2_);
                     DebugUtility.debugTrace("mrc:sending cm command - chattyUserId:" + _loc2_ + " chattyAv:" + _loc15_);
                     ExternalInterface.call("mrc",["cm",_loc15_.userName,_loc8_,int(param1[6])]);
                     DebugUtility.debugTrace("mrc:cm command sent - chattyUserName:" + _loc15_.userName + " msg:" + _loc8_);
                  }
                  if(_loc2_ != gMainFrame.server.userId || _loc2_ == gMainFrame.server.userId && (_loc4_ == CHAT_TYPE_TYPED || _loc4_ == CHAT_TYPE_LIMITED))
                  {
                     _chatHist.addMessageById(_loc2_,_loc8_);
                  }
               }
            }
         }
      }
      
      private static function userCommAdminMessageResponse(param1:Array) : void
      {
         var _loc3_:JCDefHelper = null;
         var _loc4_:Boolean = false;
         var _loc2_:String = param1[1];
         if(_loc2_ == "__ABSU_CBS__")
         {
            _loc3_ = new JCDefHelper();
            _loc3_.deleteIndexFileFromCache();
            _loc3_.destroy();
            _loc3_ = null;
            GuiManager.refreshJammerCentral();
         }
         else
         {
            _loc4_ = param1[2] == null || int(param1[2]) == 1;
            if(!_loc4_)
            {
               gMainFrame.clientInfo.lastBroadcastMessage = _loc2_;
               GuiManager.updateSettingsMessage();
            }
            new SBAJOkPopup(GuiManager.guiLayer,_loc2_);
            _chatHist.addPrivateMessage("Animal Jam HQ",gMainFrame.server.userName,_loc2_);
         }
      }
      
      private static function getSpecialFormat() : TextFormat
      {
         var _loc1_:TextFormat = new TextFormat();
         _loc1_.color = 12845056;
         _loc1_.bold = true;
         return _loc1_;
      }
   }
}

