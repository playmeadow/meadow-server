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
   import flash.utils.setTimeout;
   import game.MinigameInfo;
   import game.MinigameManager;
   import gui.ActionManager;
   import gui.ChatHistory;
   import gui.EmoticonManager;
   import gui.EmoticonUtility;
   import gui.GuiManager;
   import gui.SafeChatManager;
   import loader.DefPacksDefHelper;
   import loader.JCDefHelper;
   import localization.LocalizationManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   
   public class UserCommXtCommManager
   {
      
      public static var RAW_STR:String;
      
      private static var _drainPopupDelay:Number;
      
      private static var _mainHud:MovieClip;
      
      private static var _chatHist:ChatHistory;
      
      private static var _emoteMgr:EmoticonManager;
      
      private static var _actionMgr:ActionManager;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _spellingCorrections:Object;
      
      private static var _emoteDefs:Object;
      
      private static var _specialWords:Object;
      
      private static var _replacedWords:Object;
      
      private static var _customPVPMessageCallback:Object;
      
      private static var _customPVPPassback:Object;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_FULL_DEPLOY_IN_ONE_MINUTE:int = 22367;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_FULL_DEPLOY_IN_N_MINUTES:int = 22368;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_HOTFIX_IN_ONE_MINUTE:int = 22369;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_HOTFIX_IN_N_MINUTES:int = 22370;
      
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
         _drainPopupDelay = Math.random() * 10 * 60 * 1000;
         if(_drainPopupDelay < 5 * 60 * 1000)
         {
            _drainPopupDelay = Math.random() * 10 * 60 * 1000;
         }
         _playerSfsUserId = AvatarManager.playerSfsUserId;
         RAW_STR = gMainFrame.server.rawProtocolSeparator;
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init(DefPacksDefHelper.DEF_EMOTICON,onEmoticonDefsLoaded,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_EMOTICON] = _loc1_;
         _loc1_ = new DefPacksDefHelper();
         _loc1_.init(uint(DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE_TO_APPEND_TO + "" + 0),onAutoCorrectListLoaded,null,FileServerEvent.PLAIN_TEXT_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE_TO_APPEND_TO + "" + 0] = _loc1_;
         _specialWords = {};
         _specialWords[LocalizationManager.translateIdOnly(14855)] = LocalizationManager.translateIdOnly(11142);
      }
      
      private static function onAutoCorrectListLoaded(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE_TO_APPEND_TO + "" + 0] = null;
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
         _chatHist.addMessage(gMainFrame.userInfo.playerAvatarInfo.avName,gMainFrame.userInfo.playerAvatarInfo.userName,param1);
      }
      
      public static function sendAvatarSafeChat(param1:String, param2:String, param3:Boolean = true) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         AvatarManager.addAvatarMessage(param1,_playerSfsUserId,0);
         addChatMessage(param1);
         gMainFrame.server.sendMessage(param2 + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + SbiConstants.CHAT_TYPE_SAFE);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
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
         gMainFrame.server.sendMessage(EmoticonUtility.idForEmote(param1) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + SbiConstants.CHAT_TYPE_EMOTE);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
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
         gMainFrame.server.sendMessage(_actionMgr.getActionString(param1) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + SbiConstants.CHAT_TYPE_ACTION + RAW_STR + _loc3_);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
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
         gMainFrame.server.sendMessage(param1 + "," + param2 + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + SbiConstants.CHAT_TYPE_ATTACHMENT);
      }
      
      public static function sendAvatarBlendColor(param1:uint) : void
      {
         gMainFrame.server.sendMessage(int(param1) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + SbiConstants.CHAT_TYPE_BLEND_COLOR);
      }
      
      public static function sendAvatarAlphaLevel(param1:uint) : void
      {
         gMainFrame.server.sendMessage(int(param1) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + SbiConstants.CHAT_TYPE_ALPHA_LEVEL);
      }
      
      public static function sendChatMessage(param1:int, param2:String, param3:Boolean) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode) || !Utility.canChat())
         {
            return;
         }
         param2 = fixMispellings(param2);
         param2 = adjustCamelCase(param2);
         AvatarManager.addAvatarMessage("...",param1,0);
         param2 = adjustSpecialWords(param2);
         var _loc4_:int = gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_FREE ? SbiConstants.CHAT_TYPE_TYPED : SbiConstants.CHAT_TYPE_LIMITED;
         gMainFrame.server.sendMessage(param2 + RAW_STR + int(param3) + RAW_STR + _loc4_);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = _chatHist.chatMsgText;
         }
      }
      
      public static function adjustSpecialWords(param1:String) : String
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
      
      public static function reverseSpecialWords(param1:String) : String
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
      
      public static function adjustCamelCase(param1:String) : String
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
         if(!_spellingCorrections || LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
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
         return param1.replace(/[^A-Za-z0-9 ']+/g,"");
      }
      
      public static function sendAvatarSlide(param1:String) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         gMainFrame.server.sendMessage(param1 + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + SbiConstants.CHAT_TYPE_SLIDE);
      }
      
      public static function sendPermEmote(param1:int, param2:Boolean) : void
      {
         gMainFrame.server.sendMessage(param1 + RAW_STR + int(param2) + RAW_STR + SbiConstants.CHAT_TYPE_PERM_EMOTE);
      }
      
      public static function sendPetAction(param1:int, param2:int = 0) : void
      {
         gMainFrame.server.sendMessage(param1 + "," + param2 + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + SbiConstants.CHAT_TYPE_PET_ACTION);
      }
      
      public static function sendCustomAdventureMessage(param1:Boolean) : void
      {
         gMainFrame.server.sendMessage((param1 ? "on" : "off") + RAW_STR + 0 + RAW_STR + SbiConstants.CHAT_TYPE_CUST_ADVENTURE);
      }
      
      public static function sendCustomPVPMessage(param1:Boolean, param2:int, param3:Function = null, param4:Object = null) : void
      {
         _customPVPMessageCallback = param3;
         _customPVPPassback = param4;
         gMainFrame.server.sendMessage((param1 ? "on" : "off") + RAW_STR + 0 + RAW_STR + SbiConstants.CHAT_TYPE_CUST_PVP + RAW_STR + param2);
      }
      
      public static function onSendMessage(param1:MouseEvent, param2:String = "") : void
      {
         var _loc5_:Sprite = null;
         var _loc6_:String = null;
         if(_playerSfsUserId == -1)
         {
            DebugUtility.debugTrace("WARNING - UserCommXtCommManager.init was never called or the playerAvatarId is bad");
            _playerSfsUserId = AvatarManager.playerSfsUserId;
         }
         var _loc3_:String = param2 == "" ? _mainHud.chatBar.text01_chat.text : param2;
         _loc3_ = _loc3_.split("\r").join("");
         _loc3_ = _loc3_.split(RAW_STR).join("");
         _loc3_ = StringUtil.trim(_loc3_);
         if(_loc3_.length <= 0)
         {
            return;
         }
         var _loc4_:Object = EmoticonUtility.matchEmoteString(_loc3_);
         if(_loc4_.status)
         {
            if(_loc4_.sprite)
            {
               sendAvatarEmote(_loc4_.sprite);
               AvatarManager.setAvatarEmote(_loc4_.sprite,-2);
            }
            else
            {
               _loc5_ = _actionMgr.matchActionString(_loc3_);
               if(_loc5_)
               {
                  sendAvatarAction(_loc5_);
                  AvatarManager.setAvatarAction(_loc5_,-2);
               }
               else
               {
                  _loc6_ = SafeChatManager.safeChatCodeForString(_loc3_);
                  if(_loc6_)
                  {
                     sendAvatarSafeChat(_loc3_,_loc6_,false);
                     AvatarManager.addAvatarMessage(_loc3_,_playerSfsUserId,0);
                  }
                  else
                  {
                     sendChatMessage(_playerSfsUserId,_loc3_,MinigameManager.inMinigame());
                  }
               }
            }
            return;
         }
         _chatHist.resetTreeSearch();
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
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:Object = null;
         var _loc12_:Array = null;
         var _loc13_:MinigameInfo = null;
         var _loc14_:Boolean = false;
         var _loc15_:String = null;
         var _loc16_:Sprite = null;
         var _loc17_:Sprite = null;
         var _loc18_:Array = null;
         var _loc19_:int = 0;
         var _loc20_:Avatar = null;
         var _loc21_:Array = null;
         var _loc2_:int = int(param1[2]);
         var _loc3_:Boolean = Boolean(int(param1[4]));
         var _loc4_:int = int(param1[5]);
         var _loc5_:Boolean = true;
         if(_loc5_)
         {
            if(_loc4_ == SbiConstants.CHAT_TYPE_PERM_EMOTE)
            {
               _loc7_ = int(param1[3]);
               if(_loc7_ >= 0)
               {
                  AvatarManager.setAvatarEmote(null,_loc2_,_loc7_);
               }
               else
               {
                  AvatarManager.setChatBalloonReadyForClear(_loc2_);
               }
            }
            else if(_loc4_ == SbiConstants.CHAT_TYPE_SLIDE)
            {
               if(_loc2_ != gMainFrame.server.userId)
               {
                  _roomMgr.attachAvatarToSlide(AvatarManager.avatarViewList[_loc2_],param1[3]);
               }
            }
            else if(_loc4_ == SbiConstants.CHAT_TYPE_PET_ACTION)
            {
               _loc8_ = param1[3].split(",");
               AvatarManager.setPetAction(_loc2_,_loc8_[0],_loc8_[1]);
            }
            else if(_loc4_ == SbiConstants.CHAT_TYPE_CUST_ADVENTURE)
            {
               _loc6_ = param1[3];
               if(_loc6_ == "off")
               {
                  AvatarManager.addCustomAdventureMessage("","off",_loc2_,0,0);
               }
               else
               {
                  _loc9_ = _loc6_.split("|");
                  _loc10_ = _loc9_[0].split(",");
                  _loc11_ = QuestXtCommManager.getScriptDef(_loc10_[0]);
                  if(_loc11_)
                  {
                     AvatarManager.addCustomAdventureMessage(LocalizationManager.translateIdOnly(_loc11_.titleStrId),_loc9_[1] + "|" + _loc10_[0],_loc2_,_loc10_[2],int(param1[6]));
                  }
               }
            }
            else if(_loc4_ == SbiConstants.CHAT_TYPE_CUST_PVP)
            {
               _loc6_ = param1[3];
               _loc12_ = param1[3].split("|");
               if(_loc12_[0] == "off")
               {
                  if(Boolean(_loc2_ == AvatarManager.playerSfsUserId) && Boolean(_loc12_[1]) && !MinigameManager.isInReadyModeForPVP())
                  {
                     MinigameManager.readySelfForPvpGame({"typeDefId":_loc12_[1]},_loc12_[2],true,true);
                  }
                  AvatarManager.addCustomPvpMessage("",_loc12_[0],_loc2_,0,0);
               }
               else
               {
                  _loc13_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc12_[1]);
                  AvatarManager.addCustomPvpMessage(LocalizationManager.translateIdOnly(_loc13_.titleStrId),_loc6_,_loc2_,0,int(param1[6]));
               }
               if(_customPVPMessageCallback)
               {
                  if(_customPVPPassback != null)
                  {
                     _customPVPMessageCallback(_customPVPPassback);
                  }
                  else
                  {
                     _customPVPMessageCallback();
                  }
                  _customPVPMessageCallback = null;
               }
            }
            else
            {
               _loc6_ = param1[3];
               _loc14_ = false;
               if(_loc4_ == SbiConstants.CHAT_TYPE_SAFE)
               {
                  _loc15_ = SafeChatManager.safeChatStringForCode(_loc6_);
                  if(_loc15_)
                  {
                     _loc6_ = _loc15_;
                  }
                  else
                  {
                     _loc14_ = true;
                  }
               }
               if(!_loc14_)
               {
                  switch(_loc4_)
                  {
                     case SbiConstants.CHAT_TYPE_TYPED:
                     case SbiConstants.CHAT_TYPE_LIMITED:
                     case SbiConstants.CHAT_TYPE_SAFE:
                        _loc6_ = adjustCamelCase(_loc6_);
                        if(_loc2_ == gMainFrame.server.userId)
                        {
                           _loc6_ = reverseSpecialWords(_loc6_);
                        }
                        AvatarManager.addAvatarMessage(_loc6_,_loc2_,int(param1[6]));
                        break;
                     case SbiConstants.CHAT_TYPE_EMOTE:
                        _loc16_ = EmoticonUtility.emoteForId(int(_loc6_));
                        if(_loc16_)
                        {
                           AvatarManager.setAvatarEmote(_loc16_,_loc2_);
                        }
                        else
                        {
                           _loc14_ = true;
                        }
                        _loc6_ = EmoticonUtility.stringForId(int(_loc6_));
                        break;
                     case SbiConstants.CHAT_TYPE_ACTION:
                        _loc17_ = _actionMgr.matchActionString(_loc6_);
                        if(_loc17_)
                        {
                           AvatarManager.setAvatarAction(_loc17_,_loc2_);
                        }
                        else
                        {
                           _loc14_ = true;
                        }
                        break;
                     case SbiConstants.CHAT_TYPE_ATTACHMENT:
                        _loc18_ = _loc6_.split(",");
                        _loc19_ = int(_loc18_[0]);
                        AvatarManager._setAvatarAttachmentEmot(_loc19_,_loc18_[1],_loc2_);
                        break;
                     case SbiConstants.CHAT_TYPE_BLEND_COLOR:
                        AvatarManager._setAvatarBlendColor(_loc2_,uint(param1[3]));
                        return;
                     case SbiConstants.CHAT_TYPE_ALPHA_LEVEL:
                        AvatarManager._setAvatarAlphaLevel(_loc2_,uint(param1[3]));
                        return;
                     default:
                        _loc14_ = true;
                  }
               }
               if(_loc14_)
               {
                  DebugUtility.debugTrace("WARNING - got bad chat! msg:" + _loc6_ + " chatType:" + _loc4_ + " from userId:" + _loc2_);
                  return;
               }
               if(_loc4_ != SbiConstants.CHAT_TYPE_ATTACHMENT)
               {
                  if(gMainFrame.clientInfo.extCallsActive)
                  {
                     _loc20_ = AvatarManager.getAvatarBySfsUserId(_loc2_);
                     DebugUtility.debugTrace("mrc:sending cm command - chattyUserId:" + _loc2_ + " chattyAv:" + _loc20_);
                     if(int(param1[6]) == 2)
                     {
                        _loc21_ = _loc6_.split("|");
                        _loc21_.splice(0,1);
                        _loc6_ = _loc21_.join("|");
                     }
                     ExternalInterface.call("mrc",["cm",_loc20_.userName,_loc6_,int(param1[6])]);
                     DebugUtility.debugTrace("mrc:cm command sent - chattyUserName:" + _loc20_.userName + " msg:" + _loc6_);
                  }
                  if((_loc2_ != gMainFrame.server.userId || _loc2_ == gMainFrame.server.userId && (_loc4_ == SbiConstants.CHAT_TYPE_TYPED || _loc4_ == SbiConstants.CHAT_TYPE_LIMITED)) && int(param1[6]) <= 1)
                  {
                     _chatHist.addMessageById(_loc2_,_loc6_);
                  }
               }
            }
         }
      }
      
      private static function userCommAdminMessageResponse(param1:Array) : void
      {
         var adminMsg:String = null;
         var jcDefHelper:JCDefHelper = null;
         var msgId:int = 0;
         var msgSplit:Array = null;
         var isSystemMsg:Boolean = false;
         var data:Array = param1;
         adminMsg = data[1];
         if(adminMsg == "__ABSU_CBS__")
         {
            jcDefHelper = new JCDefHelper();
            jcDefHelper.deleteIndexFileFromCache();
            jcDefHelper.destroy();
            jcDefHelper = null;
            GuiManager.refreshJammerCentral();
         }
         else if(adminMsg == "__FORCE_RELOGIN__")
         {
            setTimeout(refreshPage,Math.abs(_roomMgr.shardId) * 911 % 5000,{"status":true});
         }
         else
         {
            msgSplit = adminMsg.split("|");
            if(msgSplit.length > 1)
            {
               msgId = int(msgSplit[0]);
               adminMsg = LocalizationManager.translateIdAndInsertOnly(msgId,msgSplit.slice(1));
            }
            isSystemMsg = data[2] == null || int(data[2]) == 1;
            if(!isSystemMsg)
            {
               gMainFrame.clientInfo.lastBroadcastMessage = adminMsg;
               GuiManager.updateSettingsMessage();
            }
            if(isSystemMsg || !gMainFrame.isInMinigame() && gMainFrame.clientInfo.roomType != SbiConstants.ROOMTYPE_QUEST)
            {
               if(msgId != BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_FULL_DEPLOY_IN_N_MINUTES && msgId != BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_FULL_DEPLOY_IN_N_MINUTES && msgId != BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_HOTFIX_IN_N_MINUTES && msgId != BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_HOTFIX_IN_ONE_MINUTE)
               {
                  new SBAJOkPopup(GuiManager.guiLayer,adminMsg);
               }
               else
               {
                  setTimeout(function():void
                  {
                     new SBYesNoPopup(GuiManager.guiLayer,adminMsg,true,refreshPage);
                  },_drainPopupDelay);
               }
            }
            _chatHist.addPrivateMessage(LocalizationManager.translateIdOnly(15964),null,adminMsg);
         }
      }
      
      private static function refreshPage(param1:Object) : void
      {
         if(param1["status"])
         {
            Utility.reloadSWFOrGetIp();
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

