package avatar
{
   import com.adobe.utils.StringUtil;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
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
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   
   public class UserCommXtCommManager
   {
      
      public static var RAW_STR:String;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_FULL_DEPLOY_IN_ONE_MINUTE:int = 22368;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_FULL_DEPLOY_IN_N_MINUTES:int = 22367;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_HOTFIX_IN_ONE_MINUTE:int = 22370;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_HOTFIX_IN_N_MINUTES:int = 22369;
      
      private static var _drainPopupDelay:Number;
      
      private static var _playerSfsUserId:int = -1;
      
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
      
      private static var _originalPermEmoteBeingDisplayed:int;
      
      private static var _secondPermEmoteInUse:Boolean;
      
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
         if(_drainPopupDelay < 300000)
         {
            _drainPopupDelay = Math.random() * 10 * 60 * 1000;
         }
         _playerSfsUserId = AvatarManager.playerSfsUserId;
         RAW_STR = gMainFrame.server.rawProtocolSeparator;
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init(1036,onEmoticonDefsLoaded,null,2);
         DefPacksDefHelper.mediaArray[1036] = _loc1_;
         _loc1_ = new DefPacksDefHelper();
         _loc1_.init(10,onAutoCorrectListLoaded,null,1);
         DefPacksDefHelper.mediaArray["10"] = _loc1_;
         _specialWords = {};
         _specialWords[LocalizationManager.translateIdOnly(14855)] = LocalizationManager.translateIdOnly(11142);
         _originalPermEmoteBeingDisplayed = -1;
      }
      
      private static function onAutoCorrectListLoaded(param1:DefPacksDefHelper) : void
      {
         var _loc4_:int = 0;
         DefPacksDefHelper.mediaArray["10"] = null;
         var _loc2_:String = param1.def.toString().toLowerCase() as String;
         _spellingCorrections = {};
         _spellingCorrections["constructor"] = "constructor";
         var _loc3_:Array = _loc2_.split("\r\n");
         _loc4_ = 0;
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
         DefPacksDefHelper.mediaArray[1036] = null;
         var _loc4_:Object = param1.def;
         var _loc3_:Object = {};
         for each(var _loc2_:Object in _loc4_)
         {
            _loc3_[_loc2_.id] = int(_loc2_.mediaRef);
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
         for(var _loc2_:String in _emoteDefs)
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
         gMainFrame.server.sendMessage(param2 + RAW_STR + 1);
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
         gMainFrame.server.sendMessage(EmoticonUtility.idForEmote(param1) + RAW_STR + 2);
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
         var _loc3_:AvatarWorldView = AvatarManager.avatarViewList[AvatarManager.playerSfsUserId];
         var _loc2_:int = _loc3_.lastIdleAnim;
         gMainFrame.server.sendMessage(_actionMgr.getActionString(param1) + RAW_STR + 3 + RAW_STR + _loc2_);
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
         gMainFrame.server.sendMessage(param1 + "," + param2 + RAW_STR + 4);
      }
      
      public static function sendAvatarBlendColor(param1:uint) : void
      {
         gMainFrame.server.sendMessage(int(param1) + RAW_STR + 8);
      }
      
      public static function sendAvatarAlphaLevel(param1:uint) : void
      {
         gMainFrame.server.sendMessage(int(param1) + RAW_STR + 10);
      }
      
      public static function sendChatMessage(param1:int, param2:String) : void
      {
         if(gMainFrame.clientInfo.invisMode || !Utility.canChat())
         {
            return;
         }
         param2 = fixMispellings(param2);
         param2 = adjustCamelCase(param2);
         AvatarManager.addAvatarMessage("...",param1,0);
         param2 = adjustSpecialWords(param2);
         var _loc3_:int = gMainFrame.userInfo.sgChatType == 1 ? 0 : 9;
         gMainFrame.server.sendMessage(param2 + RAW_STR + _loc3_);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = _chatHist.chatMsgText;
         }
      }
      
      public static function adjustSpecialWords(param1:String) : String
      {
         var _loc7_:String = null;
         var _loc11_:String = null;
         var _loc10_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:String = null;
         var _loc8_:String = null;
         var _loc3_:String = null;
         _replacedWords = {};
         var _loc5_:Array = param1.split(" ");
         var _loc2_:int = 0;
         _loc10_ = 0;
         while(_loc10_ < _loc5_.length)
         {
            _loc11_ = _loc5_[_loc10_];
            _loc7_ = _loc11_.toLowerCase();
            for(var _loc6_:String in _specialWords)
            {
               _loc4_ = _loc7_.indexOf(_loc6_);
               if(_loc4_ >= 0)
               {
                  _loc9_ = _loc11_.substr(0,_loc4_);
                  _loc8_ = _loc11_.substr(_loc4_,_loc6_.length);
                  _loc3_ = _loc11_.substr(_loc4_ + _loc6_.length);
                  _loc2_ = getCaseType(_loc8_);
                  _loc8_ = setCaseType(_specialWords[_loc6_],_loc2_);
                  _loc5_[_loc10_] = _loc9_ + _loc8_ + _loc3_;
                  _replacedWords[_loc5_[_loc10_]] = _loc11_;
               }
            }
            _loc10_++;
         }
         return _loc5_.join(" ");
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
         var _loc4_:String = null;
         var _loc3_:int = 0;
         if(_replacedWords == null)
         {
            return param1;
         }
         var _loc2_:Array = param1.split(" ");
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_].toLowerCase();
            if(!(_replacedWords[_loc4_] == null || _loc4_ == "constructor"))
            {
               _loc2_[_loc3_] = _replacedWords[_loc4_];
            }
            _loc3_++;
         }
         _replacedWords = null;
         return _loc2_.join(" ");
      }
      
      public static function adjustCamelCase(param1:String) : String
      {
         var _loc4_:int = 0;
         var _loc6_:String = null;
         var _loc5_:String = null;
         var _loc2_:String = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:Array = param1.split(" ");
         _loc8_ = 0;
         while(_loc8_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc8_];
            _loc6_ = _loc5_.match(/[a-zA-Z]/g).join("");
            _loc2_ = _loc6_.charAt(0);
            _loc4_ = int(_loc6_.match(/[A-Z]/g).length);
            if(_loc4_ > 0 && _loc4_ != _loc6_.length)
            {
               if(_loc2_.match(/[A-z]/g).length == 1)
               {
                  _loc7_ = getIndexOfFirstLetter(_loc5_,_loc6_);
                  _loc3_[_loc8_] = _loc5_.substr(0,_loc7_) + _loc2_ + _loc5_.toLowerCase().substr(_loc7_ + 1,_loc5_.length);
               }
               else
               {
                  _loc3_[_loc8_] = _loc5_.toLowerCase();
               }
            }
            _loc8_++;
         }
         return _loc3_.join(" ");
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
         var _loc3_:int = 0;
         if(param2 == "")
         {
            param2 = param1.match(/[a-zA-Z]/g).join();
         }
         _loc3_ = 0;
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
         var _loc4_:int = 0;
         if(!_spellingCorrections || LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
         {
            return param1;
         }
         var _loc2_:Array = param1.split(" ");
         _loc4_ = 0;
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
         gMainFrame.server.sendMessage(param1 + RAW_STR + 6);
      }
      
      public static function sendPermEmote(param1:int) : void
      {
         if(_originalPermEmoteBeingDisplayed != -1)
         {
            if(param1 == -1)
            {
               if(_secondPermEmoteInUse)
               {
                  param1 = _originalPermEmoteBeingDisplayed;
                  _secondPermEmoteInUse = false;
               }
               _originalPermEmoteBeingDisplayed = -1;
            }
            else
            {
               _secondPermEmoteInUse = true;
            }
         }
         else
         {
            _originalPermEmoteBeingDisplayed = param1;
         }
         gMainFrame.server.sendMessage(param1 + RAW_STR + 5);
      }
      
      public static function sendPetAction(param1:int, param2:int = 0) : void
      {
         gMainFrame.server.sendMessage(param1 + "," + param2 + RAW_STR + 7);
      }
      
      public static function sendCustomAdventureMessage(param1:Boolean) : void
      {
         gMainFrame.server.sendMessage((param1 ? "on" : "off") + RAW_STR + 11);
      }
      
      public static function sendCustomPVPMessage(param1:Boolean, param2:int, param3:Function = null, param4:Object = null) : void
      {
         _customPVPMessageCallback = param3;
         _customPVPPassback = param4;
         gMainFrame.server.sendMessage((param1 ? "on" : "off") + RAW_STR + 12 + RAW_STR + param2);
      }
      
      public static function onSendMessage(param1:MouseEvent, param2:String = "") : void
      {
         var _loc4_:Sprite = null;
         var _loc3_:String = null;
         if(_playerSfsUserId == -1)
         {
            DebugUtility.debugTrace("WARNING - UserCommXtCommManager.init was never called or the playerAvatarId is bad");
            _playerSfsUserId = AvatarManager.playerSfsUserId;
         }
         var _loc6_:String = param2 == "" ? _mainHud.chatBar.text01_chat.text : param2;
         _loc6_ = _loc6_.split("\r").join("");
         _loc6_ = _loc6_.split(RAW_STR).join("");
         _loc6_ = StringUtil.trim(_loc6_);
         if(_loc6_.length <= 0)
         {
            return;
         }
         var _loc5_:Object = EmoticonUtility.matchEmoteString(_loc6_);
         if(_loc5_.status)
         {
            if(_loc5_.sprite)
            {
               sendAvatarEmote(_loc5_.sprite);
               AvatarManager.setAvatarEmote(_loc5_.sprite,-2);
            }
            else
            {
               _loc4_ = _actionMgr.matchActionString(_loc6_);
               if(_loc4_)
               {
                  sendAvatarAction(_loc4_);
                  AvatarManager.setAvatarAction(_loc4_,-2);
               }
               else
               {
                  _loc3_ = SafeChatManager.safeChatCodeForString(_loc6_,0);
                  if(_loc3_)
                  {
                     sendAvatarSafeChat(_loc6_,_loc3_,false);
                     AvatarManager.addAvatarMessage(_loc6_,_playerSfsUserId,0);
                  }
                  else
                  {
                     sendChatMessage(_playerSfsUserId,_loc6_);
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
         var _loc7_:String = null;
         var _loc6_:int = 0;
         var _loc11_:Array = null;
         var _loc16_:Array = null;
         var _loc3_:Array = null;
         var _loc5_:Object = null;
         var _loc14_:Array = null;
         var _loc12_:MinigameInfo = null;
         var _loc20_:Boolean = false;
         var _loc19_:String = null;
         var _loc18_:Sprite = null;
         var _loc15_:Sprite = null;
         var _loc4_:Array = null;
         var _loc8_:int = 0;
         var _loc10_:Avatar = null;
         var _loc17_:Array = null;
         var _loc9_:int = int(param1[2]);
         var _loc2_:int = int(param1[4]);
         var _loc13_:Boolean = true;
         if(_loc13_)
         {
            if(_loc2_ == 5)
            {
               _loc6_ = int(param1[3]);
               if(_loc6_ >= 0)
               {
                  AvatarManager.setAvatarEmote(null,_loc9_,_loc6_);
               }
               else
               {
                  AvatarManager.setChatBalloonReadyForClear(_loc9_);
               }
            }
            else if(_loc2_ == 6)
            {
               if(_loc9_ != gMainFrame.server.userId)
               {
                  _roomMgr.attachAvatarToSlide(AvatarManager.avatarViewList[_loc9_],param1[3]);
               }
            }
            else if(_loc2_ == 7)
            {
               _loc11_ = param1[3].split(",");
               AvatarManager.setPetAction(_loc9_,_loc11_[0],_loc11_[1]);
            }
            else if(_loc2_ == 11)
            {
               _loc7_ = param1[3];
               if(_loc7_ == "off")
               {
                  AvatarManager.addCustomAdventureMessage("","off",_loc9_,0,0);
                  QuestManager.privateAdventureJoinClose(false,false);
               }
               else
               {
                  _loc16_ = _loc7_.split("|");
                  _loc3_ = _loc16_[0].split(",");
                  _loc5_ = QuestXtCommManager.getScriptDef(_loc3_[0]);
                  if(_loc5_)
                  {
                     AvatarManager.addCustomAdventureMessage(LocalizationManager.translateIdOnly(_loc5_.titleStrId),_loc16_[1] + "|" + _loc3_[0],_loc9_,_loc3_[2],int(param1[5]));
                  }
               }
            }
            else if(_loc2_ == 12)
            {
               _loc7_ = param1[3];
               _loc14_ = param1[3].split("|");
               if(_loc14_[0] == "off")
               {
                  if(_loc9_ == AvatarManager.playerSfsUserId && _loc14_[1] && !MinigameManager.isInReadyModeForPVP())
                  {
                     MinigameManager.readySelfForPvpGame({"typeDefId":_loc14_[1]},_loc14_[2],true,true);
                  }
                  AvatarManager.addCustomPvpMessage("",_loc14_[0],_loc9_,0,0);
               }
               else
               {
                  _loc12_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc14_[1]);
                  AvatarManager.addCustomPvpMessage(LocalizationManager.translateIdOnly(_loc12_.titleStrId),_loc7_,_loc9_,0,int(param1[5]));
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
               _loc7_ = param1[3];
               _loc20_ = false;
               if(_loc2_ == 1)
               {
                  _loc19_ = SafeChatManager.safeChatStringForCode(_loc7_);
                  if(_loc19_)
                  {
                     _loc7_ = _loc19_;
                  }
                  else
                  {
                     _loc20_ = true;
                  }
               }
               if(!_loc20_)
               {
                  switch(_loc2_)
                  {
                     case 0:
                     case 1:
                     case 9:
                        _loc7_ = adjustCamelCase(_loc7_);
                        if(_loc9_ == gMainFrame.server.userId)
                        {
                           _loc7_ = reverseSpecialWords(_loc7_);
                        }
                        AvatarManager.addAvatarMessage(_loc7_,_loc9_,int(param1[5]));
                        break;
                     case 2:
                        _loc18_ = EmoticonUtility.emoteForId(int(_loc7_));
                        if(_loc18_)
                        {
                           AvatarManager.setAvatarEmote(_loc18_,_loc9_);
                        }
                        else
                        {
                           _loc20_ = true;
                        }
                        _loc7_ = EmoticonUtility.stringForId(int(_loc7_));
                        break;
                     case 3:
                        _loc15_ = _actionMgr.matchActionString(_loc7_);
                        if(_loc15_)
                        {
                           AvatarManager.setAvatarAction(_loc15_,_loc9_);
                        }
                        else
                        {
                           _loc20_ = true;
                        }
                        break;
                     case 4:
                        _loc4_ = _loc7_.split(",");
                        _loc8_ = int(_loc4_[0]);
                        AvatarManager._setAvatarAttachmentEmot(_loc8_,_loc4_[1],_loc9_);
                        break;
                     case 8:
                        AvatarManager._setAvatarBlendColor(_loc9_,uint(param1[3]));
                        return;
                     case 10:
                        AvatarManager._setAvatarAlphaLevel(_loc9_,uint(param1[3]));
                        return;
                     default:
                        _loc20_ = true;
                  }
               }
               if(_loc20_)
               {
                  DebugUtility.debugTrace("WARNING - got bad chat! msg:" + _loc7_ + " chatType:" + _loc2_ + " from userId:" + _loc9_);
                  return;
               }
               if(_loc2_ != 4)
               {
                  if(gMainFrame.clientInfo.extCallsActive)
                  {
                     _loc10_ = AvatarManager.getAvatarBySfsUserId(_loc9_);
                     DebugUtility.debugTrace("mrc:sending cm command - chattyUserId:" + _loc9_ + " chattyAv:" + _loc10_);
                     if(int(param1[5]) == 2)
                     {
                        _loc17_ = _loc7_.split("|");
                        _loc17_.splice(0,1);
                        _loc7_ = _loc17_.join("|");
                     }
                     ExternalInterface.call("mrc",["cm",_loc10_.userName,_loc7_,int(param1[5])]);
                     DebugUtility.debugTrace("mrc:cm command sent - chattyUserName:" + _loc10_.userName + " msg:" + _loc7_);
                  }
                  if((_loc9_ != gMainFrame.server.userId || _loc9_ == gMainFrame.server.userId && (_loc2_ == 0 || _loc2_ == 9)) && int(param1[5]) <= 1)
                  {
                     _chatHist.addMessageById(_loc9_,_loc7_);
                  }
               }
            }
         }
      }
      
      private static function userCommAdminMessageResponse(param1:Array) : void
      {
         var jcDefHelper:JCDefHelper;
         var msgId:int;
         var msgSplit:Array;
         var isSystemMsg:Boolean;
         var data:Array = param1;
         var adminMsg:String = data[1];
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
            if(isSystemMsg || !gMainFrame.isInMinigame() && gMainFrame.clientInfo.roomType != 7)
            {
               if(msgId != 22367 && msgId != 22368 && msgId != 22369 && msgId != 22370)
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

