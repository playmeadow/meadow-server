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
      
      public static const CHAT_TYPE_CUST_ADVENTURE:int = 11;
      
      public static const CHAT_TYPE_CUST_PVP:int = 12;
      
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
         var dpdh:DefPacksDefHelper = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_EMOTICON,onEmoticonDefsLoaded,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_EMOTICON] = dpdh;
         dpdh = new DefPacksDefHelper();
         dpdh.init(uint(DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE_TO_APPEND_TO + "" + 0),onAutoCorrectListLoaded,null,FileServerEvent.PLAIN_TEXT_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE_TO_APPEND_TO + "" + 0] = dpdh;
         _specialWords = {};
         _specialWords[LocalizationManager.translateIdOnly(14855)] = LocalizationManager.translateIdOnly(11142);
      }
      
      private static function onAutoCorrectListLoaded(df:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.AUTO_CORRECT_TEXT_FILE_TO_APPEND_TO + "" + 0] = null;
         var str:String = df.def.toString().toLowerCase() as String;
         _spellingCorrections = {};
         var autoCorrectList:Array = str.split("\r\n");
         for(var i:int = 0; i < autoCorrectList.length; i++)
         {
            autoCorrectList[i] = autoCorrectList[i].split(",");
            if(!(autoCorrectList[i][0] == null || autoCorrectList[i][0].length == 0 || autoCorrectList[i][1] == null || autoCorrectList[i][1].length == 0))
            {
               _spellingCorrections[StringUtil.trim(autoCorrectList[i][0])] = StringUtil.trim(autoCorrectList[i][1]);
            }
         }
      }
      
      private static function onEmoticonDefsLoaded(ed:DefPacksDefHelper) : void
      {
         var currObj:Object = null;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_EMOTICON] = null;
         var data:Object = ed.def;
         var emoteDefs:Object = new Object();
         for each(currObj in data)
         {
            emoteDefs[currObj.id] = int(currObj.mediaRef);
         }
         _emoteDefs = emoteDefs;
      }
      
      public static function destroy() : void
      {
      }
      
      public static function set playerSfsUserId(s:int) : void
      {
         _playerSfsUserId = s;
      }
      
      public static function getEmoticonMediaId(defId:int) : int
      {
         if(!_emoteDefs[defId])
         {
            return 0;
         }
         return _emoteDefs[defId];
      }
      
      public static function getEmoticonDefId(mediaId:int) : int
      {
         var defId:String = null;
         for(defId in _emoteDefs)
         {
            if(_emoteDefs[defId] == mediaId)
            {
               return int(defId);
            }
         }
         return 0;
      }
      
      public static function addChatMessage(msg:String) : void
      {
         _chatHist.addMessage(gMainFrame.userInfo.playerAvatarInfo.avName,gMainFrame.userInfo.playerAvatarInfo.userName,msg);
      }
      
      public static function sendAvatarSafeChat(sctString:String, sctCode:String, pressSafeChatBtn:Boolean = true) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode))
         {
            return;
         }
         AvatarManager.addAvatarMessage(sctString,_playerSfsUserId,0);
         addChatMessage(sctString);
         gMainFrame.server.sendMessage(sctCode + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_SAFE);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
         }
         if(pressSafeChatBtn)
         {
            GuiManager.safeChatBtnDownHandler(null);
         }
      }
      
      public static function sendAvatarEmote(emote:Sprite) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode))
         {
            return;
         }
         AvatarManager.setAvatarEmote(emote);
         if(!EmoticonUtility.getEmoteString(emote))
         {
            throw new Error("setAvatarEmote: sent invalid emote sprite?!");
         }
         addChatMessage(EmoticonUtility.getEmoteString(emote));
         gMainFrame.server.sendMessage(EmoticonUtility.idForEmote(emote) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_EMOTE);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
         }
      }
      
      public static function sendAvatarAction(action:Sprite) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode))
         {
            return;
         }
         AvatarManager.setAvatarAction(action);
         if(!_actionMgr.getActionString(action))
         {
            throw new Error("setAvatarAction: sent invalid action sprite?!");
         }
         addChatMessage(_actionMgr.getActionString(action));
         var avView:AvatarWorldView = AvatarManager.avatarViewList[AvatarManager.playerSfsUserId];
         var packAnimFlip:int = avView.lastIdleAnim;
         gMainFrame.server.sendMessage(_actionMgr.getActionString(action) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_ACTION + RAW_STR + packAnimFlip);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
         }
      }
      
      public static function sendAvatarAttachmentEmot(emotDefId:int, extra:String = null) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode))
         {
            return;
         }
         if(extra == null)
         {
            extra = "";
         }
         gMainFrame.server.sendMessage(emotDefId + "," + extra + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_ATTACHMENT);
      }
      
      public static function sendAvatarBlendColor(c:uint) : void
      {
         gMainFrame.server.sendMessage(int(c) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_BLEND_COLOR);
      }
      
      public static function sendAvatarAlphaLevel(a:uint) : void
      {
         gMainFrame.server.sendMessage(int(a) + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_ALPHA_LEVEL);
      }
      
      public static function sendChatMessage(senderId:int, msg:String, inGame:Boolean) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode) || !Utility.canChat())
         {
            return;
         }
         msg = fixMispellings(msg);
         msg = adjustCamelCase(msg);
         AvatarManager.addAvatarMessage("...",senderId,0);
         msg = adjustSpecialWords(msg);
         var chatType:int = gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_FREE ? CHAT_TYPE_TYPED : CHAT_TYPE_LIMITED;
         gMainFrame.server.sendMessage(msg + RAW_STR + int(inGame) + RAW_STR + chatType);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = _chatHist.chatMsgText;
         }
      }
      
      private static function adjustSpecialWords(msg:String) : String
      {
         var currWord:String = null;
         var currWordLowerCase:String = null;
         var specialWord:String = null;
         var idx:int = 0;
         var prev:String = null;
         var word:String = null;
         var post:String = null;
         _replacedWords = {};
         var words:Array = msg.split(" ");
         var caseType:int = 0;
         for(var i:int = 0; i < words.length; i++)
         {
            currWord = words[i];
            currWordLowerCase = currWord.toLowerCase();
            for(specialWord in _specialWords)
            {
               idx = currWordLowerCase.indexOf(specialWord);
               if(idx >= 0)
               {
                  prev = currWord.substr(0,idx);
                  word = currWord.substr(idx,specialWord.length);
                  post = currWord.substr(idx + specialWord.length);
                  caseType = getCaseType(word);
                  word = setCaseType(_specialWords[specialWord],caseType);
                  words[i] = prev + word + post;
                  _replacedWords[words[i]] = currWord;
               }
            }
         }
         return words.join(" ");
      }
      
      private static function getCaseType(word:String) : int
      {
         if(word.toLowerCase() == word)
         {
            return 0;
         }
         var firstLetter:String = word.charAt(0);
         var numCaps:int = int(word.match(/[A-Z]/g).length);
         if(numCaps == word.length)
         {
            return 1;
         }
         return 2;
      }
      
      private static function setCaseType(word:String, caseType:int) : String
      {
         if(caseType == 0)
         {
            return word.toLowerCase();
         }
         if(caseType == 1)
         {
            return word.toUpperCase();
         }
         word = word.toLowerCase();
         var firstLetter:String = word.charAt(0).toUpperCase();
         return firstLetter + word.substr(1);
      }
      
      private static function reverseSpecialWords(msg:String) : String
      {
         var currWord:String = null;
         if(_replacedWords == null)
         {
            return msg;
         }
         var words:Array = msg.split(" ");
         for(var i:int = 0; i < words.length; i++)
         {
            currWord = words[i].toLowerCase();
            if(!(_replacedWords[currWord] == null || currWord == "constructor"))
            {
               words[i] = _replacedWords[currWord];
            }
         }
         _replacedWords = null;
         return words.join(" ");
      }
      
      private static function adjustCamelCase(msg:String) : String
      {
         var numCaps:int = 0;
         var word:String = null;
         var lettersOnly:String = null;
         var firstLetter:String = null;
         var firstLetterIdx:int = 0;
         var words:Array = msg.split(" ");
         for(var i:int = 0; i < words.length; i++)
         {
            word = words[i];
            lettersOnly = word.match(/[a-zA-Z]/g).join("");
            firstLetter = lettersOnly.charAt(0);
            numCaps = int(lettersOnly.match(/[A-Z]/g).length);
            if(numCaps > 0 && numCaps != lettersOnly.length)
            {
               if(firstLetter.match(/[A-z]/g).length == 1)
               {
                  firstLetterIdx = getIndexOfFirstLetter(word,lettersOnly);
                  words[i] = word.substr(0,firstLetterIdx) + firstLetter + word.toLowerCase().substr(firstLetterIdx + 1,word.length);
               }
               else
               {
                  words[i] = word.toLowerCase();
               }
            }
         }
         return words.join(" ");
      }
      
      public static function getFirstLetter(msg:String) : String
      {
         var lettersOnly:String = msg.match(/[a-zA-Z]/g).join("");
         if(lettersOnly.length > 0)
         {
            return lettersOnly.charAt(0);
         }
         return null;
      }
      
      public static function getIndexOfFirstLetter(msg:String, lettersOnly:String) : int
      {
         if(lettersOnly == "")
         {
            lettersOnly = msg.match(/[a-zA-Z]/g).join();
         }
         for(var i:int = 0; i < msg.length; i++)
         {
            if(msg.charAt(i) == lettersOnly.charAt(0))
            {
               return i;
            }
         }
         return -1;
      }
      
      public static function fixMispellings(msg:String) : String
      {
         var word:String = null;
         if(!_spellingCorrections || LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
         {
            return msg;
         }
         var words:Array = msg.split(" ");
         for(var i:int = 0; i < words.length; i++)
         {
            word = words[i].toLowerCase();
            word = stripPunctuation(word);
            if(_spellingCorrections[word] != null)
            {
               word = _spellingCorrections[word];
               words[i] = word;
            }
         }
         return words.join(" ");
      }
      
      public static function stripPunctuation(word:String) : String
      {
         return word.replace(/[^A-Za-z0-9 ']+/g,"");
      }
      
      public static function sendAvatarSlide(name:String) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode))
         {
            return;
         }
         gMainFrame.server.sendMessage(name + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_SLIDE);
      }
      
      public static function sendPermEmote(emoteMediaId:int, inGame:Boolean) : void
      {
         gMainFrame.server.sendMessage(emoteMediaId + RAW_STR + int(inGame) + RAW_STR + CHAT_TYPE_PERM_EMOTE);
      }
      
      public static function sendPetAction(petActionId:int, extraId:int = 0) : void
      {
         gMainFrame.server.sendMessage(petActionId + "," + extraId + RAW_STR + int(MinigameManager.inMinigame) + RAW_STR + CHAT_TYPE_PET_ACTION);
      }
      
      public static function sendCustomAdventureMessage(show:Boolean) : void
      {
         gMainFrame.server.sendMessage((show ? "on" : "off") + RAW_STR + 0 + RAW_STR + CHAT_TYPE_CUST_ADVENTURE);
      }
      
      public static function sendCustomPVPMessage(show:Boolean, gameDefId:int) : void
      {
         gMainFrame.server.sendMessage((show ? "on" : "off") + RAW_STR + 0 + RAW_STR + CHAT_TYPE_CUST_PVP + RAW_STR + gameDefId);
      }
      
      public static function onSendMessage(evt:MouseEvent, myMsg:String = "") : void
      {
         var acts:Sprite = null;
         var scc:String = null;
         if(_playerSfsUserId == -1)
         {
            DebugUtility.debugTrace("WARNING - UserCommXtCommManager.init was never called or the playerAvatarId is bad");
            _playerSfsUserId = AvatarManager.playerSfsUserId;
         }
         var msg:String = myMsg == "" ? _mainHud.chatBar.text01_chat.text : myMsg;
         msg = msg.split("\r").join("");
         msg = msg.split(RAW_STR).join("");
         msg = StringUtil.trim(msg);
         if(msg.length <= 0)
         {
            return;
         }
         var es:Object = EmoticonUtility.matchEmoteString(msg);
         if(Boolean(es.status))
         {
            if(Boolean(es.sprite))
            {
               sendAvatarEmote(es.sprite);
               AvatarManager.setAvatarEmote(es.sprite,-2);
            }
            else
            {
               acts = _actionMgr.matchActionString(msg);
               if(Boolean(acts))
               {
                  sendAvatarAction(acts);
                  AvatarManager.setAvatarAction(acts,-2);
               }
               else
               {
                  scc = SafeChatManager.safeChatCodeForString(msg);
                  if(Boolean(scc))
                  {
                     sendAvatarSafeChat(msg,scc,false);
                     AvatarManager.addAvatarMessage(msg,_playerSfsUserId,0);
                  }
                  else
                  {
                     sendChatMessage(_playerSfsUserId,msg,MinigameManager.inMinigame());
                  }
               }
            }
            return;
         }
         _chatHist.resetTreeSearch();
         _chatHist.chatMsgText.text = "";
         gMainFrame.stage.focus = _chatHist.chatMsgText;
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Array = evt.obj;
         switch(data[0])
         {
            case "uc":
               userCommChatResponse(data);
               break;
            case "ua":
               userCommAdminMessageResponse(data);
               break;
            default:
               throw new Error("UserCommXtCommManager illegal data:" + data[0]);
         }
      }
      
      private static function userCommChatResponse(data:Array) : void
      {
         var msg:String = null;
         var permEmoteMediaId:int = 0;
         var petMsgSplit:Array = null;
         var split:Array = null;
         var adventureInfoSplit:Array = null;
         var questScriptDef:Object = null;
         var splitData:Array = null;
         var jmi:MinigameInfo = null;
         var badChat:Boolean = false;
         var scm:String = null;
         var es:Sprite = null;
         var cacts:Sprite = null;
         var msgSplit:Array = null;
         var attId:int = 0;
         var chattyAv:Avatar = null;
         var splitMessage:Array = null;
         var chattyUserId:int = int(data[2]);
         var inGame:Boolean = Boolean(int(data[4]));
         var chatType:int = int(data[5]);
         var showChatterMsg:Boolean = true;
         if(showChatterMsg)
         {
            if(chatType == CHAT_TYPE_PERM_EMOTE)
            {
               permEmoteMediaId = int(data[3]);
               if(permEmoteMediaId >= 0)
               {
                  AvatarManager.setAvatarEmote(null,chattyUserId,permEmoteMediaId);
               }
               else
               {
                  AvatarManager.setChatBalloonReadyForClear(chattyUserId);
               }
            }
            else if(chatType == CHAT_TYPE_SLIDE)
            {
               if(chattyUserId != gMainFrame.server.userId)
               {
                  _roomMgr.attachAvatarToSlide(AvatarManager.avatarViewList[chattyUserId],data[3]);
               }
            }
            else if(chatType == CHAT_TYPE_PET_ACTION)
            {
               petMsgSplit = data[3].split(",");
               AvatarManager.setPetAction(chattyUserId,petMsgSplit[0],petMsgSplit[1]);
            }
            else if(chatType == CHAT_TYPE_CUST_ADVENTURE)
            {
               msg = data[3];
               if(msg == "off")
               {
                  AvatarManager.addCustomAdventureMessage("","off",chattyUserId,0,0);
               }
               else
               {
                  split = msg.split("|");
                  adventureInfoSplit = split[0].split(",");
                  questScriptDef = QuestXtCommManager.getScriptDef(adventureInfoSplit[0]);
                  if(Boolean(questScriptDef))
                  {
                     AvatarManager.addCustomAdventureMessage(LocalizationManager.translateIdOnly(questScriptDef.titleStrId),split[1] + "|" + adventureInfoSplit[0],chattyUserId,adventureInfoSplit[2],int(data[6]));
                  }
               }
            }
            else if(chatType == CHAT_TYPE_CUST_PVP)
            {
               msg = data[3];
               splitData = data[3].split("|");
               if(splitData[0] == "off")
               {
                  if(chattyUserId == AvatarManager.playerSfsUserId)
                  {
                     MinigameManager.readySelfForPvpGame({"typeDefId":splitData[1]},splitData[2],true,true);
                  }
                  AvatarManager.addCustomPvpMessage("",splitData[0],chattyUserId,0,0);
               }
               else
               {
                  jmi = MinigameManager.minigameInfoCache.getMinigameInfo(splitData[1]);
                  AvatarManager.addCustomPvpMessage(LocalizationManager.translateIdOnly(jmi.titleStrId),msg,chattyUserId,0,int(data[6]));
               }
            }
            else
            {
               msg = data[3];
               badChat = false;
               if(chatType == CHAT_TYPE_SAFE)
               {
                  scm = SafeChatManager.safeChatStringForCode(msg);
                  if(Boolean(scm))
                  {
                     msg = scm;
                  }
                  else
                  {
                     badChat = true;
                  }
               }
               if(!badChat)
               {
                  switch(chatType)
                  {
                     case CHAT_TYPE_TYPED:
                     case CHAT_TYPE_LIMITED:
                     case CHAT_TYPE_SAFE:
                        msg = adjustCamelCase(msg);
                        if(chattyUserId == gMainFrame.server.userId)
                        {
                           msg = reverseSpecialWords(msg);
                        }
                        AvatarManager.addAvatarMessage(msg,chattyUserId,int(data[6]));
                        break;
                     case CHAT_TYPE_EMOTE:
                        es = EmoticonUtility.emoteForId(int(msg));
                        if(Boolean(es))
                        {
                           AvatarManager.setAvatarEmote(es,chattyUserId);
                        }
                        else
                        {
                           badChat = true;
                        }
                        msg = EmoticonUtility.stringForId(int(msg));
                        break;
                     case CHAT_TYPE_ACTION:
                        cacts = _actionMgr.matchActionString(msg);
                        if(Boolean(cacts))
                        {
                           AvatarManager.setAvatarAction(cacts,chattyUserId);
                        }
                        else
                        {
                           badChat = true;
                        }
                        break;
                     case CHAT_TYPE_ATTACHMENT:
                        msgSplit = msg.split(",");
                        attId = int(msgSplit[0]);
                        AvatarManager._setAvatarAttachmentEmot(attId,msgSplit[1],chattyUserId);
                        break;
                     case CHAT_TYPE_BLEND_COLOR:
                        AvatarManager._setAvatarBlendColor(chattyUserId,uint(data[3]));
                        return;
                     case CHAT_TYPE_ALPHA_LEVEL:
                        AvatarManager._setAvatarAlphaLevel(chattyUserId,uint(data[3]));
                        return;
                     default:
                        badChat = true;
                  }
               }
               if(badChat)
               {
                  DebugUtility.debugTrace("WARNING - got bad chat! msg:" + msg + " chatType:" + chatType + " from userId:" + chattyUserId);
                  return;
               }
               if(chatType != CHAT_TYPE_ATTACHMENT)
               {
                  if(Boolean(gMainFrame.clientInfo.extCallsActive))
                  {
                     chattyAv = AvatarManager.getAvatarBySfsUserId(chattyUserId);
                     DebugUtility.debugTrace("mrc:sending cm command - chattyUserId:" + chattyUserId + " chattyAv:" + chattyAv);
                     if(int(data[6]) == 2)
                     {
                        splitMessage = msg.split("|");
                        splitMessage.splice(0,1);
                        msg = splitMessage.join("|");
                     }
                     ExternalInterface.call("mrc",["cm",chattyAv.userName,msg,int(data[6])]);
                     DebugUtility.debugTrace("mrc:cm command sent - chattyUserName:" + chattyAv.userName + " msg:" + msg);
                  }
                  if((chattyUserId != gMainFrame.server.userId || chattyUserId == gMainFrame.server.userId && (chatType == CHAT_TYPE_TYPED || chatType == CHAT_TYPE_LIMITED)) && int(data[6]) <= 1)
                  {
                     _chatHist.addMessageById(chattyUserId,msg);
                  }
               }
            }
         }
      }
      
      private static function userCommAdminMessageResponse(data:Array) : void
      {
         var jcDefHelper:JCDefHelper = null;
         var msgSplit:Array = null;
         var isSystemMsg:Boolean = false;
         var adminMsg:String = data[1];
         if(adminMsg == "__ABSU_CBS__")
         {
            jcDefHelper = new JCDefHelper();
            jcDefHelper.deleteIndexFileFromCache();
            jcDefHelper.destroy();
            jcDefHelper = null;
            GuiManager.refreshJammerCentral();
         }
         else
         {
            msgSplit = adminMsg.split("|");
            if(msgSplit.length > 1)
            {
               adminMsg = LocalizationManager.translateIdAndInsertOnly(msgSplit[0],msgSplit.slice(1));
            }
            isSystemMsg = data[2] == null || int(data[2]) == 1;
            if(!isSystemMsg)
            {
               gMainFrame.clientInfo.lastBroadcastMessage = adminMsg;
               GuiManager.updateSettingsMessage();
            }
            if(isSystemMsg || !gMainFrame.isInMinigame() && gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST)
            {
               new SBAJOkPopup(GuiManager.guiLayer,adminMsg);
            }
            _chatHist.addPrivateMessage(LocalizationManager.translateIdOnly(15964),null,adminMsg);
         }
      }
      
      private static function getSpecialFormat() : TextFormat
      {
         var specialFormat:TextFormat = new TextFormat();
         specialFormat.color = 12845056;
         specialFormat.bold = true;
         return specialFormat;
      }
   }
}

