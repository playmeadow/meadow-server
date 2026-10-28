package avatar
{
   import achievement.AchievementXtCommManager;
   import com.sbi.client.SFClient;
   import com.sbi.corelib.input.SBTextField;
   import com.sbi.corelib.math.Collision;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.LayerBitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.MinigameInfo;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.BuddyManager;
   import gui.ChatBalloon;
   import gui.GuiManager;
   import gui.UpsellManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   import pet.WorldPet;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerView;
   import room.RoomManagerWorld;
   
   public class AvatarWorldView extends AvatarView
   {
      
      private static var _guiObj:Object;
      
      public static const AV_MODE_DEFAULT:int = 0;
      
      public static const AV_MODE_QUESTCOMBAT:int = 1;
      
      private static const ACTION_TIME:int = 3000;
      
      private static const SELNUB_SHOW_DIST:Number = 150;
      
      private static const AVATAR_MOVEDIR_ANGLE_OFFSET:Number = 0.20943951;
      
      private static const NAMEBAR_X_OFFSET:int = -15;
      
      private static const NAMEBAR_Y_OFFSET:int = 18;
      
      private static const ATTACHMENT_X_OFFSET:int = -310;
      
      private static const ATTACHMENT_Y_OFFSET:int = -320;
      
      private static const SLIDE_FRAME_TIME:Number = 1000 / 24;
      
      private static const GLOW_LAND_DEFAULT_COLOR:int = 5586479;
      
      private static const GLOW_OCEAN_DEFAULT_COLOR:int = 2775381;
      
      private var _chatBalloon:ChatBalloon;
      
      private var _namebar:NameBar;
      
      private var _pos:Point;
      
      private var _scale:Point;
      
      private var _moveToX:Number;
      
      private var _moveToY:Number;
      
      private var _dirX:Number;
      
      private var _dirY:Number;
      
      private var _radius:Number = 30;
      
      private var _deleteOnMoveComplete:Boolean = false;
      
      private var _moving:int;
      
      private var _chatLayer:Object;
      
      private var _followPath:Array;
      
      private var _roomType:int;
      
      private var _secondaryEmot:MovieClip;
      
      private var _avAttMediaHelper:MediaHelper;
      
      private var _avAttachmentExtra:String;
      
      private var _avAttMediaId:int;
      
      private var _actionMgr:Object;
      
      private var _guiMgr:Object;
      
      private var _isGuide:Boolean;
      
      private var _lastMoveAngle:Number;
      
      private var _lastIdleAnim:int;
      
      private var _lastIdleFlip:Boolean;
      
      private var _glow:GlowFilter;
      
      private var _splashLiquid:String;
      
      private var _bInSplashVolume:Boolean;
      
      private var _slideCurrentPosition:int;
      
      private var _slideFrameTime:int;
      
      private var _slidePositions:Array;
      
      private var _slideSpinTimer:Object;
      
      private var _slideSpinCurrentDirection:int;
      
      private var _pet:WorldPet;
      
      private var _splash:AvatarViewExt_Splash;
      
      private var _emoteMediaHelper:MediaHelper;
      
      private var _isLoadingEmoteId:int;
      
      private var _isMember:Boolean;
      
      private var _hudViewHolder:MovieClip;
      
      private var _hudAvtOrPetView:Object;
      
      private var _flashTimer:Timer;
      
      private var _frameTime:Number;
      
      private var _numFramesForOffscreen:int;
      
      private var _avOffscreenMediaHelper:MediaHelper;
      
      private var _customPVPImageLoader:MediaHelper;
      
      private var _currPetName:String;
      
      private var _shouldShowPetOnly:Boolean;
      
      public function AvatarWorldView()
      {
         super();
      }
      
      public static function init(guiObj:Object = null) : void
      {
         _guiObj = guiObj;
      }
      
      public static function destroy() : void
      {
         _guiObj = null;
      }
      
      public static function convertToIdle(moveAngle:Number) : Object
      {
         var retAnimId:int = LayerAnim.AN_IDLE_SE;
         var retFlip:Boolean = false;
         var step:Number = Math.PI * 0.5;
         if(moveAngle > -2 * step && moveAngle < -step)
         {
            retAnimId = LayerAnim.AN_IDLE_NE;
            retFlip = true;
         }
         else if(moveAngle >= -step && moveAngle < 0)
         {
            retAnimId = LayerAnim.AN_IDLE_NE;
         }
         else if(moveAngle >= 0 && moveAngle < step)
         {
            retAnimId = LayerAnim.AN_IDLE_SE;
         }
         else
         {
            retAnimId = LayerAnim.AN_IDLE_SE;
            retFlip = true;
         }
         return {
            "anim":retAnimId,
            "flip":retFlip
         };
      }
      
      public static function updateScreenPositionAndDirection(hudViewIcon:MovieClip, iconRect:Rectangle, screenPoint:Point) : void
      {
         if(screenPoint.x > iconRect.width)
         {
            if(screenPoint.x > iconRect.width)
            {
               screenPoint.x = MainFrame.VIEW_WIDTH - hudViewIcon.mouse.width * 0.5;
            }
            hudViewIcon.openChat(180,0);
         }
         else if(screenPoint.x - hudViewIcon.mouse.width * 0.5 < 0)
         {
            hudViewIcon.openChat(0,0);
            if(screenPoint.x - hudViewIcon.mouse.width * 0.5 < 0)
            {
               screenPoint.x += 0 - screenPoint.x + hudViewIcon.mouse.width * 0.5;
            }
         }
         if(screenPoint.y > iconRect.height - 73.5)
         {
            screenPoint.y = MainFrame.VIEW_HEIGHT - hudViewIcon.mouse.height * 0.5 - 73.5;
            if(screenPoint.x - hudViewIcon.mouse.width * 0.5 - (hudViewIcon.questChatBalloon.width * 0.5 - hudViewIcon.mouse.width * 0.5) < 0)
            {
               hudViewIcon.openChat(-90,screenPoint.x + (0 - screenPoint.x + (hudViewIcon.mouse.width * 0.5 - hudViewIcon.questChatBalloon.width * 0.5)));
            }
            else if(screenPoint.x - (hudViewIcon.mouse.width * 0.5 - hudViewIcon.questChatBalloon.width * 0.5) > iconRect.width)
            {
               hudViewIcon.openChat(-90,screenPoint.x - (MainFrame.VIEW_WIDTH - hudViewIcon.mouse.width * 0.5 - (hudViewIcon.questChatBalloon.width * 0.5 - hudViewIcon.mouse.width * 0.5)),true);
            }
            else
            {
               hudViewIcon.openChat(-90,0);
            }
         }
         else if(screenPoint.y - hudViewIcon.mouse.height * 0.5 < 0)
         {
            screenPoint.y += 0 - screenPoint.y + hudViewIcon.mouse.height * 0.5;
            if(screenPoint.x - hudViewIcon.mouse.width * 0.5 - (hudViewIcon.questChatBalloon.width * 0.5 - hudViewIcon.mouse.width * 0.5) < 0)
            {
               hudViewIcon.openChat(90,screenPoint.x + (0 - screenPoint.x + (hudViewIcon.mouse.width * 0.5 - hudViewIcon.questChatBalloon.width * 0.5)));
            }
            else if(screenPoint.x - (hudViewIcon.mouse.width * 0.5 - hudViewIcon.questChatBalloon.width * 0.5) > iconRect.width)
            {
               hudViewIcon.openChat(90,screenPoint.x - (MainFrame.VIEW_WIDTH - hudViewIcon.mouse.width * 0.5 - (hudViewIcon.questChatBalloon.width * 0.5 - hudViewIcon.mouse.width * 0.5)),true);
            }
            else
            {
               hudViewIcon.openChat(90,0);
            }
         }
      }
      
      override public function init(initAvatar:Avatar, avTypeCallback:Function = null) : void
      {
         throw new Error("Don\'t use this!  Use initWorldView instead!  ...I miss overloading...");
      }
      
      public function initWorldView(initAvatar:Avatar, chatLayer:Object, accountType:int, isGuide:Boolean, initInvisible:Boolean = false, initActionMgr:Object = null, initGuiMgr:Object = null, nameBarData:int = 0, roomType:int = 0) : void
      {
         var frameId:int = 0;
         var layerBitmap:LayerBitmap = null;
         _avatar = initAvatar;
         if(!chatLayer)
         {
            throw new Error("AvatarWorldView got invalid chatLayer:null!");
         }
         this._chatLayer = chatLayer;
         this._actionMgr = initActionMgr;
         this._guiMgr = initGuiMgr;
         this._roomType = roomType;
         if(initInvisible)
         {
            visible = false;
         }
         initAvatar.addEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged,false,0,true);
         this._isGuide = isGuide;
         this._scale = new Point(1,1);
         this._pos = new Point(0,0);
         this._slideCurrentPosition = -1;
         lastAnimToHappen = -1;
         if(initAvatar.perUserAvId != 0 && gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && QuestManager.hasJustJoinedQuest)
         {
            AvatarManager.setOffScreenMapBySfsId(userId,new Point(0,0),gMainFrame.server.getCurrentRoomName(false));
         }
         this.initNamebar(accountType);
         if(initAvatar.avName == "")
         {
            this._namebar.visible = false;
         }
         if(_avatar.isShaman)
         {
            frameId = 2;
         }
         else if(this._isGuide)
         {
            frameId = 3;
         }
         else
         {
            frameId = 1;
         }
         this._chatBalloon = GETDEFINITIONBYNAME("ChatBalloonAsset");
         this._chatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,frameId,SBTextField,this.onChatBallonAdventureDown,this.onChatBalloonPVPDown);
         this._chatLayer.addChild(this._chatBalloon);
         this._moving = 0;
         this._lastMoveAngle = 2;
         this._lastIdleAnim = this.getBaseIdle();
         this._lastIdleFlip = false;
         this.setNamebarListenersWithUserName(initAvatar.userName);
         this.toggleNamebarSelNub(nameBarData);
         this._namebar.setColorAndBadge(nameBarData);
         _layerAnim = LayerAnim.getNew();
         _layerAnim.avDefId = initAvatar.avTypeId;
         if(Boolean(initAvatar.colors))
         {
            _layerAnim.layers = setLayerHelper();
         }
         layerBitmap = _layerAnim.bitmap;
         layerBitmap.x = 0;
         layerBitmap.y = 0;
         this._glow = new GlowFilter(0,1,4,4,4);
         _layerAnim.bitmap.filters = [this._glow];
         this.setBlendColor();
         this._splash = new AvatarViewExt_Splash(this,layerBitmap);
         if(this._roomType == Utility.ENVIRO_OCEAN)
         {
            this._splash.showShadow(false);
         }
         if(userId == AvatarManager.playerSfsUserId || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            this._namebar.mouseChildren = false;
            this._namebar.mouseEnabled = false;
            this._chatBalloon.mouseChildren = false;
            this._chatBalloon.mouseEnabled = false;
         }
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && Boolean(AvatarManager.getViewHudMCBySfsId(userId)))
         {
            this._hudViewHolder = AvatarManager.getViewHudMCBySfsId(userId);
            if(Boolean(this._hudViewHolder))
            {
               if(Boolean(this._flashTimer))
               {
                  this._flashTimer.reset();
               }
               this._flashTimer = new Timer(2500);
               this._flashTimer.addEventListener(TimerEvent.TIMER,this.onFlashTimer,false,0,true);
               this._hudViewHolder.mouse.gotoAndStop("up");
            }
         }
         this._shouldShowPetOnly = GuiManager.isBeYourPetRoom();
         if(this._shouldShowPetOnly)
         {
            _layerAnim.alpha = 0;
            _layerAnim.avatarEnabled = false;
         }
         else
         {
            _layerAnim.alpha = 1;
            this._namebar.setAvName(initAvatar.avName);
            _layerAnim.avatarEnabled = true;
         }
         this._bInSplashVolume = false;
         this._isLoadingEmoteId = -1;
      }
      
      override public function destroy(destroyAvatar:Boolean = false) : void
      {
         QuestManager.removeTorch(this);
         if(Boolean(parent))
         {
            parent.removeChild(this);
         }
         if(destroyAvatar && Boolean(_avatar))
         {
            _avatar.destroy();
            _avatar = null;
         }
         var layerBitmap:LayerBitmap = _layerAnim.bitmap;
         removeChild(layerBitmap);
         layerBitmap.filters = null;
         super.destroy();
         if(Boolean(this._chatBalloon) && this._chatBalloon.parent == this._chatLayer)
         {
            this._chatLayer.removeChild(this._chatBalloon);
         }
         removeChild(this._namebar);
         if(Boolean(this._secondaryEmot) && Boolean(this._chatLayer.contains(this._secondaryEmot)))
         {
            this._chatLayer.removeChild(this._secondaryEmot);
         }
         this._splash.destroy();
         removeEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler);
         this._namebar.removeEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler);
         this._namebar["selnub"].removeEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler);
         this._namebar.removeEventListener(MouseEvent.MOUSE_DOWN,this.ownNamebarDownHandler);
         this._chatBalloon = null;
         if(Boolean(this._namebar))
         {
            this._namebar.destroy();
         }
         this._namebar = null;
         avTypeChangedCallback = null;
         this._slidePositions = null;
         this._glow = null;
         if(Boolean(this._flashTimer))
         {
            this._flashTimer.reset();
            this._flashTimer.removeEventListener(TimerEvent.TIMER,this.onFlashTimer);
            this._flashTimer = null;
            this._hudViewHolder.mouse.gotoAndStop("up");
         }
         if(Boolean(this._hudAvtOrPetView))
         {
            this._hudAvtOrPetView.destroy();
            this._hudAvtOrPetView = null;
         }
      }
      
      public function get radius() : Number
      {
         return this._radius;
      }
      
      public function get attachmentVisible() : Boolean
      {
         return this._secondaryEmot == null;
      }
      
      public function get moving() : Boolean
      {
         return this._moving == 1 || this._slideCurrentPosition >= 0;
      }
      
      public function get hFlip() : Boolean
      {
         return _layerAnim.hFlip;
      }
      
      public function get lastIdleAnim() : int
      {
         return this._lastIdleAnim;
      }
      
      public function get lastIdleFlip() : Boolean
      {
         return this._lastIdleFlip;
      }
      
      public function get splashLiquid() : String
      {
         return this._splashLiquid;
      }
      
      public function get roomType() : int
      {
         return this._roomType;
      }
      
      public function set roomType(type:int) : void
      {
         this._roomType = type;
      }
      
      public function set deleteOnMoveComplete(flag:Boolean) : void
      {
         this._deleteOnMoveComplete = flag;
      }
      
      public function get currentLevel() : int
      {
         if(Boolean(this._namebar))
         {
            return this._namebar.currentLevel;
         }
         return 0;
      }
      
      public function isThisAttachmentOn(attachmentMediaId:int) : Boolean
      {
         if(this._secondaryEmot == null)
         {
            return false;
         }
         if(this._avAttMediaId == attachmentMediaId)
         {
            return true;
         }
         return false;
      }
      
      public function getBaseIdle() : int
      {
         return this._roomType == Utility.ENVIRO_OCEAN ? LayerAnim.AN_FLOAT : LayerAnim.AN_IDLE_SE;
      }
      
      public function setPath(p:Array) : void
      {
         this._followPath = p;
         if(this._slideCurrentPosition == -1)
         {
            this._moving = -1;
            this.followPath();
         }
      }
      
      public function get avatarPos() : Point
      {
         return this._pos;
      }
      
      public function setPos(xp:Number, yp:Number, bInterpolate:Boolean, bClearPath:Boolean = true) : void
      {
         var norm:Number = NaN;
         if(bClearPath)
         {
            this._followPath = null;
         }
         if(bInterpolate)
         {
            this._dirX = xp - this._pos.x;
            this._dirY = yp - this._pos.y;
            norm = Math.sqrt(this._dirX * this._dirX + this._dirY * this._dirY);
            if(Boolean(norm))
            {
               this._dirX /= norm * this._scale.x;
               this._dirY /= norm * this._scale.y;
            }
            this.faceAnim(this._dirX,this._dirY,true);
            this._moving = 1;
            this._moveToX = xp;
            this._moveToY = yp;
         }
         else
         {
            this._dirX = 0;
            this._dirY = 0;
            this.updatePos(xp,yp);
         }
      }
      
      public function get nameBar() : NameBar
      {
         return this._namebar;
      }
      
      public function get nameBarIconIds() : Array
      {
         return this._namebar.iconIds;
      }
      
      public function get nubData() : Array
      {
         return this._namebar.nubData;
      }
      
      public function get xpShapeIcons() : Object
      {
         return this._namebar.xpShapeIcons;
      }
      
      public function setSplashVolume(splash:Boolean, liquid:String) : void
      {
         this._bInSplashVolume = splash;
         this._splashLiquid = liquid;
      }
      
      public function setAvatarMode(inMode:int) : void
      {
         switch(inMode)
         {
            case AV_MODE_QUESTCOMBAT:
               _layerAnim.bitmap.filters = null;
               if(Boolean(this._splash))
               {
                  this._splash.showShadow(false);
               }
               if(this._namebar != null)
               {
                  this._namebar.visible = false;
               }
         }
      }
      
      public function updateNameBarLevelShape(level:int) : void
      {
         var ui:UserInfo = null;
         if(this._namebar != null)
         {
            if(this._shouldShowPetOnly)
            {
               level = 0;
               this._namebar.removeShape();
            }
            else
            {
               ui = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
               if(Boolean(ui) || Boolean(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST) || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST_STAGING)
               {
                  this._namebar.setColorBadgeAndXp(Boolean(ui) ? ui.nameBarData : 0,level,this._isMember,gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST_STAGING);
               }
            }
         }
      }
      
      public function updateNameBarHealth(percent:int) : void
      {
         if(this._namebar != null)
         {
            this._namebar.updateMeter(percent);
         }
      }
      
      public function getNameBarHealthPercentage() : int
      {
         if(this._namebar != null)
         {
            return this._namebar.getMeterValue();
         }
         return 100;
      }
      
      public function setBlendColor(c:uint = 0, outline:uint = 4294967295, forceDefaultOutline:Boolean = false) : void
      {
         var temp:Array = null;
         if(_layerAnim == null || _layerAnim.bitmap == null)
         {
            return;
         }
         if(outline == 4294967295)
         {
            if(c == 0 || forceDefaultOutline)
            {
               outline = this._roomType == Utility.ENVIRO_LAND ? uint(GLOW_LAND_DEFAULT_COLOR) : uint(GLOW_OCEAN_DEFAULT_COLOR);
            }
            else
            {
               outline = uint(c & 0xFFFFFF);
            }
         }
         if(_layerAnim.bitmap.filters != null && _layerAnim.bitmap.filters[0].color != outline)
         {
            temp = _layerAnim.bitmap.filters;
            temp[0].color = outline;
            _layerAnim.bitmap.filters = temp;
         }
         _layerAnim.bitmap.setBlendColor(c);
      }
      
      public function setAlphaLevel(a:int) : void
      {
         if(Boolean(gMainFrame.clientInfo.invisMode) && userId == AvatarManager.playerSfsUserId)
         {
            a = 50;
         }
         var an:Number = a / 100;
         this.alpha = an;
      }
      
      public function isSameMessage(msg:String) : Boolean
      {
         if(Boolean(this._chatBalloon))
         {
            if(this._chatBalloon.visible)
            {
               return this._chatBalloon.msgTxt.text == msg;
            }
         }
         return false;
      }
      
      public function setMessage(text:String, severity:int) : void
      {
         var changeFontColor:Boolean = false;
         if(severity > 1)
         {
            if(severity == 2)
            {
               text = LocalizationManager.translateIdOnly(int(text.split("|")[0]));
            }
            changeFontColor = true;
         }
         this._chatBalloon.setText(text,changeFontColor);
         this.updateOffScreenChat(text,changeFontColor);
      }
      
      public function setCustomAdventureMessage(adventureInfoText:String, userMessage:String, difficulty:int, severity:int, isForPVP:Boolean = false) : void
      {
         var changeFontColor:Boolean = false;
         if(Boolean(gMainFrame.userInfo.isModerator) && severity > 1)
         {
            changeFontColor = true;
         }
         this._chatBalloon.setCustomAdventureMessage(adventureInfoText,userMessage,difficulty,changeFontColor,isForPVP);
         if(this._chatBalloon.visible && this._chatBalloon.isPvpCustom)
         {
            this.loadCustomPVPImage(this._chatBalloon.pvpGameId);
         }
      }
      
      private function loadCustomPVPImage(gameId:int) : void
      {
         var jmi:MinigameInfo = null;
         if(gameId != 0)
         {
            jmi = MinigameManager.minigameInfoCache.getMinigameInfo(gameId);
            this._customPVPImageLoader = new MediaHelper();
            this._customPVPImageLoader.init(jmi.gameCardMediaId,this.onCustomPVPImageLoaded);
         }
      }
      
      private function onCustomPVPImageLoaded(img:MovieClip) : void
      {
         var imgHeight:int = 0;
         if(Boolean(img))
         {
            if(Boolean(this._customPVPImageLoader))
            {
               this._customPVPImageLoader.destroy();
               this._customPVPImageLoader = null;
            }
            imgHeight = img.height;
            img.scaleX = img.scaleY = 0.5;
            if(Boolean(this._chatBalloon))
            {
               this._chatBalloon.setCustomPVPImage(img);
            }
         }
      }
      
      public function setEmote(emote:Sprite, permEmoteMediaId:int = -1) : void
      {
         if(Boolean(emote) || permEmoteMediaId >= 0)
         {
            this._chatBalloon.setEmote(emote,permEmoteMediaId);
         }
         else
         {
            this._chatBalloon.setReadyForClear();
         }
      }
      
      public function setChatBalloonReadyForClear() : void
      {
         this._chatBalloon.setReadyForClear();
      }
      
      public function updateChatBallonBgOffsets() : void
      {
         this._chatBalloon.updateEmoteBgOffsets();
      }
      
      public function getPermEmoteId() : int
      {
         if(Boolean(this._chatBalloon))
         {
            return this._chatBalloon.perEmoteMediaId;
         }
         return -1;
      }
      
      public function setAction(action:Sprite) : void
      {
         var o:Object = null;
         var animId:int = 0;
         if(!this._actionMgr)
         {
            return;
         }
         var actionLookup:Array = [{
            "name":":dance:",
            "land":LayerAnim.AN_DANCE,
            "water":LayerAnim.AN_WATER_JIG,
            "flip":false
         },{
            "name":":sleep:",
            "land":LayerAnim.AN_SLEEP,
            "water":LayerAnim.AN_WATER_DIVE,
            "flip":false
         },{
            "name":":dive:",
            "land":LayerAnim.AN_SLEEP,
            "water":LayerAnim.AN_WATER_DIVE,
            "flip":false
         },{
            "name":":hop:",
            "land":LayerAnim.AN_HOP,
            "water":LayerAnim.AN_WATER_SPIN,
            "flip":false
         },{
            "name":":swirl:",
            "land":LayerAnim.AN_HOP,
            "water":LayerAnim.AN_WATER_SPIN,
            "flip":false
         },{
            "name":":play:",
            "land":LayerAnim.AN_PLAY,
            "water":LayerAnim.AN_WATER_PLAY,
            "flip":false
         },{
            "name":":sitNW:",
            "land":LayerAnim.AN_SIT_NE,
            "water":LayerAnim.AN_WATER_POSE,
            "flip":true
         },{
            "name":":poseLeft:",
            "land":LayerAnim.AN_SIT_NE,
            "water":LayerAnim.AN_WATER_POSE,
            "flip":true
         },{
            "name":":sitNE:",
            "land":LayerAnim.AN_SIT_NE,
            "water":LayerAnim.AN_WATER_POSE,
            "flip":false
         },{
            "name":":sitSE:",
            "land":LayerAnim.AN_SIT_SE,
            "water":LayerAnim.AN_WATER_POSE,
            "flip":true
         },{
            "name":":poseRight:",
            "land":LayerAnim.AN_SIT_NE,
            "water":LayerAnim.AN_WATER_POSE,
            "flip":false
         },{
            "name":":sitSW:",
            "land":LayerAnim.AN_SIT_SE,
            "water":LayerAnim.AN_WATER_POSE,
            "flip":false
         }];
         this._lastIdleAnim = this.getBaseIdle();
         this._lastIdleFlip = false;
         var actionString:String = this._actionMgr.getActionString(action);
         for each(o in actionLookup)
         {
            if(o.name == actionString)
            {
               animId = this._roomType == Utility.ENVIRO_LAND ? int(o.land) : int(o.water);
               if(animId > 0)
               {
                  this._lastIdleAnim = animId;
                  this._lastIdleFlip = o.flip;
                  playAnim(animId,o.flip);
               }
               break;
            }
         }
      }
      
      public function circleTest(x:int, y:int, r:int) : Boolean
      {
         return Boolean(Collision.circleHitCircle(new Point(x,y),r,new Point(this._pos.x,this._pos.y),this._radius));
      }
      
      public function bmpDataHitTest(sourceBmpData:BitmapData, sourcePoint:Point) : Boolean
      {
         return sourceBmpData.hitTest(new Point(this._pos.x,this._pos.y),255,sourceBmpData,sourcePoint,255);
      }
      
      public function moveToFront() : void
      {
         if(!parent || !this._chatLayer)
         {
            return;
         }
         parent.setChildIndex(this,parent.numChildren - 1);
         if(this._chatBalloon.parent == this._chatLayer)
         {
            this._chatLayer.setChildIndex(this._chatBalloon,this._chatLayer.numChildren - 1);
         }
         if(Boolean(this._secondaryEmot))
         {
            if(this._secondaryEmot.parent == this._chatLayer)
            {
               this._chatLayer.setChildIndex(this._secondaryEmot,this._chatLayer.numChildren - 1);
            }
            this._secondaryEmot.scaleX = this._secondaryEmot.scaleY = 1;
         }
      }
      
      public function setAvAttachment(mediaId:int, extra:String) : void
      {
         var i:int = 0;
         var k:int = 0;
         var label:FrameLabel = null;
         this._avAttMediaId = mediaId;
         if(mediaId == 0)
         {
            if(Boolean(this._secondaryEmot) && this._isLoadingEmoteId == -1)
            {
               this._secondaryEmot.attachment.gotoAndPlay("_hide");
               if(Boolean(this._secondaryEmot["getAttachedSound"]) && this._secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.stopItemEmoticonSound(this);
               }
            }
         }
         else
         {
            if(Boolean(this._secondaryEmot) && Boolean(this._isLoadingEmoteId == -1) && this._secondaryEmot.id != mediaId)
            {
               this._secondaryEmot.attachment.gotoAndPlay("_hide");
               if(Boolean(this._secondaryEmot["getAttachedSound"]) && this._secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.stopItemEmoticonSound(this);
               }
            }
            if(this._secondaryEmot != null && (this._secondaryEmot.id == mediaId && this._avAttachmentExtra == extra) || this._isLoadingEmoteId == mediaId)
            {
               if(Boolean(this._secondaryEmot) && Boolean(this._secondaryEmot.attachment))
               {
                  for(k = int(this._secondaryEmot.attachment.currentLabels.length); i < k; )
                  {
                     label = this._secondaryEmot.attachment.currentLabels[i];
                     if(label.name == "_main")
                     {
                        this._secondaryEmot.attachment.gotoAndStop("_main");
                        return;
                     }
                     i++;
                  }
                  this._secondaryEmot.attachment.gotoAndStop("_show");
               }
               return;
            }
            this._avAttachmentExtra = extra;
            this._isLoadingEmoteId = mediaId;
            if(!this._avAttMediaHelper)
            {
               this._avAttMediaHelper = new MediaHelper();
            }
            this._avAttMediaHelper.init(mediaId,this.onAttachLoaded);
         }
      }
      
      private function setOffScreenAvAttachment(offScreenMC:MovieClip, sfsId:int) : void
      {
         var attachmentMC:MovieClip = AvatarManager.getOffScreenAttachmentBySfsId(sfsId);
         var mediaId:int = int(offScreenMC.attachmentId);
         if(mediaId == 0)
         {
            if(Boolean(attachmentMC))
            {
               if(attachmentMC.attachment.currentFrameLabel == "_gone")
               {
                  while(offScreenMC.charLayer.numChildren > 0)
                  {
                     offScreenMC.charLayer.removeChildAt(0);
                  }
                  if(Boolean(offScreenMC.avtView))
                  {
                     offScreenMC.charLayer.addChild(offScreenMC.avtView);
                  }
               }
               else
               {
                  attachmentMC.attachment.gotoAndPlay("_hide");
               }
               AvatarManager.setOffScreenAttachmentBySfsId(sfsId,attachmentMC);
            }
            else if(Boolean(offScreenMC.avtView) && !offScreenMC.charLayer.contains(offScreenMC.avtView))
            {
               offScreenMC.charLayer.addChild(offScreenMC.avtView);
            }
         }
         else
         {
            if(attachmentMC != null && (attachmentMC.id == mediaId || attachmentMC.isLoadingEmoteId == mediaId))
            {
               if(!offScreenMC.charLayer.contains(attachmentMC))
               {
                  while(offScreenMC.charLayer.numChildren > 0)
                  {
                     offScreenMC.charLayer.removeChildAt(0);
                  }
                  offScreenMC.charLayer.addChild(attachmentMC);
               }
               return;
            }
            offScreenMC.isLoadingEmoteId = mediaId;
            AvatarManager.setViewHudMCBySfsId(sfsId,offScreenMC);
            if(!this._avOffscreenMediaHelper)
            {
               this._avOffscreenMediaHelper = new MediaHelper();
            }
            this._avOffscreenMediaHelper.init(mediaId,this.onOffscreenAttachLoaded,{
               "offscreenMC":offScreenMC,
               "sfsId":sfsId
            });
         }
      }
      
      private function onOffscreenAttachLoaded(img:MovieClip) : void
      {
         var newEmote:MovieClip = null;
         var offScreenMC:MovieClip = img.passback.offscreenMC;
         if(Boolean(img) && img.hasOwnProperty("attachment"))
         {
            while(offScreenMC.charLayer.numChildren > 0)
            {
               offScreenMC.charLayer.removeChildAt(0);
            }
            newEmote = img;
            newEmote.id = offScreenMC.isLoadingEmoteId;
            offScreenMC.charLayer.addChild(newEmote);
            newEmote.scaleX = newEmote.scaleY = 0.5;
            newEmote.x = (0 - 355) * newEmote.scaleX;
            newEmote.y = (0 - 235) * newEmote.scaleX;
            newEmote.attachment.gotoAndPlay("_show");
            AvatarManager.setOffScreenAttachmentBySfsId(img.passback.sfsId,newEmote);
         }
      }
      
      private function emoteLoader(id:int, callback:Function = null) : void
      {
         this._emoteMediaHelper = new MediaHelper();
         this._emoteMediaHelper.init(id,callback);
      }
      
      private function onAttachLoaded(mc:MovieClip) : void
      {
         if(Boolean(mc) && Boolean(mc.hasOwnProperty("attachment")) && Boolean(this._avAttMediaId))
         {
            if(Boolean(this._avAttachmentExtra) && Boolean(this._avAttachmentExtra.length))
            {
               mc.setState(this._avAttachmentExtra);
            }
            if(Boolean(this._chatLayer))
            {
               if(Boolean(this._secondaryEmot) && Boolean(this._chatLayer.contains(this._secondaryEmot)))
               {
                  this._chatLayer.removeChild(this._secondaryEmot);
               }
               this._secondaryEmot = mc;
               this._secondaryEmot.id = this._isLoadingEmoteId;
               if(isOffScreen)
               {
                  if(Boolean(this._hudViewHolder.charLayer.contains(this._hudAvtOrPetView)))
                  {
                     this._hudViewHolder.charLayer.removeChild(this._hudAvtOrPetView);
                  }
                  this._hudViewHolder.charLayer.addChild(this._secondaryEmot);
                  this.updateSecondaryEmoteOffScreenPosition();
                  this._secondaryEmot.lastKnownX = this.x + ATTACHMENT_X_OFFSET;
                  this._secondaryEmot.lastKnownY = this.y + ATTACHMENT_Y_OFFSET;
               }
               else
               {
                  this._secondaryEmot.x = this.x + ATTACHMENT_X_OFFSET;
                  this._secondaryEmot.y = this.y + ATTACHMENT_Y_OFFSET;
                  this._secondaryEmot.scaleX = this._secondaryEmot.scaleY = 1;
                  this._chatLayer.addChild(this._secondaryEmot);
               }
               this._secondaryEmot.attachment.gotoAndPlay("_show");
               if(Boolean(this._secondaryEmot["getAttachedSound"]) && this._secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.playItemEmoticonSound(this,this._secondaryEmot.getAttachedSound());
               }
            }
         }
         this._isLoadingEmoteId = -1;
      }
      
      public function checkSelnub(evt:MouseEvent) : void
      {
         var n:Number = Point.distance(this.localToGlobal(new Point(0,0)),new Point(gMainFrame.stage.mouseX,gMainFrame.stage.mouseY));
         if(n < SELNUB_SHOW_DIST)
         {
            this.overHandler(evt);
         }
         else
         {
            this.outHandler(evt);
         }
      }
      
      public function heartbeat(ms:int, frameTimems:int) : Boolean
      {
         var point:Point = null;
         var entry:Object = null;
         var o:Object = null;
         var key:String = null;
         var playerSfsId:int = 0;
         var currMap:Dictionary = null;
         var myPos:Point = null;
         var currOffScreenMC:MovieClip = null;
         var scalePoint:Point = null;
         var myScreenPoint:Point = null;
         var holderHeight:int = 0;
         var holderWidth:int = 0;
         var hudHeight:int = 0;
         var iconRect:Rectangle = null;
         if(this._slideCurrentPosition >= 0)
         {
            this.updateSlide(ms);
         }
         this._frameTime = frameTimems / 1000;
         if(this._frameTime > 0.5)
         {
            this._frameTime = 0.5;
         }
         var speedMultiplier:int = 1;
         speedMultiplier = RoomManagerView._speedMutiplier;
         this._splash.heartbeat(this._bInSplashVolume,this.isSplashAnim(),this._splashLiquid,avatarData != null && (avatarData.enviroTypeFlag & 1 << Utility.ENVIRO_AIR) != 0);
         var nx:Number = this._pos.x;
         var ny:Number = this._pos.y;
         var addX:Number = this._dirX * 24 * speedMultiplier * this._frameTime / 0.07;
         var addY:Number = this._dirY * 24 * speedMultiplier * this._frameTime / 0.07;
         if(Boolean(this._dirX) || Boolean(this._dirY))
         {
            this.checkSelnub(null);
         }
         if(Boolean(addX))
         {
            if(addX > 0 && addX + this._pos.x >= this._moveToX || addX < 0 && addX + this._pos.x <= this._moveToX)
            {
               this._dirX = 0;
               nx = this._moveToX;
            }
            else
            {
               nx += addX;
            }
         }
         if(Boolean(addY))
         {
            if(addY > 0 && addY + this._pos.y >= this._moveToY || addY < 0 && addY + this._pos.y <= this._moveToY)
            {
               this._dirY = 0;
               ny = this._moveToY;
            }
            else
            {
               ny += addY;
            }
         }
         if(nx != this._pos.x || ny != this._pos.y || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            ++this._numFramesForOffscreen;
            this.updatePos(nx,ny);
            o = AvatarManager.getOffScreenMap();
            for(key in o)
            {
               playerSfsId = int(key);
               if(AvatarManager.avatarList[key] == null)
               {
                  currMap = AvatarManager.getOffScreenMapBySfsId(playerSfsId);
                  myPos = currMap[gMainFrame.server.getCurrentRoomName(false)];
                  currOffScreenMC = AvatarManager.getViewHudMCBySfsId(playerSfsId);
                  if(Boolean(currOffScreenMC))
                  {
                     if(Boolean(myPos))
                     {
                        scalePoint = RoomManagerWorld.instance.bkgScalePoint();
                        myScreenPoint = RoomManagerWorld.instance.convertWorldToScreen(myPos.x * scalePoint.x,myPos.y * scalePoint.y);
                        holderHeight = currOffScreenMC.mouse.height * 0.5 * scalePoint.x;
                        holderWidth = currOffScreenMC.mouse.width * 0.5 * scalePoint.y;
                        hudHeight = 73.5 * scalePoint.y;
                        iconRect = new Rectangle(0,0,MainFrame.VIEW_WIDTH - holderWidth,MainFrame.VIEW_HEIGHT - holderHeight - hudHeight + this._radius * 2 * scalePoint.x);
                        if(!iconRect.containsPoint(myScreenPoint))
                        {
                           if(currOffScreenMC.parent == null)
                           {
                              GuiManager.guiLayer.addChild(currOffScreenMC);
                           }
                           if(currOffScreenMC.avtView == null)
                           {
                              if(currOffScreenMC.charLayer.numChildren > 0)
                              {
                                 currOffScreenMC.avtView = currOffScreenMC.charLayer.getChildAt(0);
                              }
                           }
                           currOffScreenMC.visible = true;
                           updateScreenPositionAndDirection(currOffScreenMC,iconRect,myScreenPoint);
                           currOffScreenMC.x = myScreenPoint.x;
                           currOffScreenMC.y = myScreenPoint.y;
                           currOffScreenMC.questChatBalloon.heartbeat(ms);
                           if(this._numFramesForOffscreen >= 48 && currOffScreenMC.avtView != null)
                           {
                              if(Boolean(currOffScreenMC.charLayer.contains(currOffScreenMC.avtView)))
                              {
                                 this.setOffScreenAvAttachment(currOffScreenMC,playerSfsId);
                              }
                              else
                              {
                                 while(currOffScreenMC.charLayer.numChildren > 0)
                                 {
                                    currOffScreenMC.charLayer.removeChildAt(0);
                                 }
                                 currOffScreenMC.charLayer.addChild(currOffScreenMC.avtView);
                              }
                           }
                        }
                        else
                        {
                           currOffScreenMC.visible = false;
                        }
                     }
                     else if(currOffScreenMC.parent != null && currOffScreenMC.parent == GuiManager.guiLayer)
                     {
                        GuiManager.guiLayer.addChild(currOffScreenMC);
                     }
                  }
               }
            }
         }
         this._chatBalloon.heartbeat(ms);
         this.offScreenChatHeartbeat(ms);
         if(Boolean(this._secondaryEmot) && Boolean(this._secondaryEmot.attachment))
         {
            if(this._secondaryEmot.attachment.currentFrameLabel == "_gone")
            {
               if(Boolean(this._secondaryEmot.parent) && this._secondaryEmot.parent is MovieClip)
               {
                  this._secondaryEmot.parent.removeChild(this._secondaryEmot);
               }
               this._secondaryEmot = null;
            }
            else if(isOffScreen && this._numFramesForOffscreen >= 48)
            {
               if(Boolean(this._hudViewHolder.charLayer.contains(this._hudAvtOrPetView)))
               {
                  while(this._hudViewHolder.charLayer.numChildren > 0)
                  {
                     this._hudViewHolder.charLayer.removeChildAt(0);
                  }
                  this.updateSecondaryEmoteOffScreenPosition();
                  this._hudViewHolder.charLayer.addChild(this._secondaryEmot);
               }
               else if(Boolean(this._hudViewHolder.charLayer.contains(this._secondaryEmot)))
               {
                  while(this._hudViewHolder.charLayer.numChildren > 0)
                  {
                     this._hudViewHolder.charLayer.removeChildAt(0);
                  }
                  this._hudViewHolder.charLayer.addChild(this._hudAvtOrPetView);
               }
            }
         }
         else if(Boolean(this._hudViewHolder) && Boolean(this._hudAvtOrPetView) && !this._hudViewHolder.charLayer.contains(this._hudAvtOrPetView))
         {
            while(this._hudViewHolder.charLayer.numChildren > 0)
            {
               this._hudViewHolder.charLayer.removeChildAt(0);
            }
            this._hudViewHolder.charLayer.addChild(this._hudAvtOrPetView);
         }
         if(this._numFramesForOffscreen >= 48)
         {
            this._numFramesForOffscreen = 0;
         }
         if(!this._dirX && !this._dirY)
         {
            if(this._deleteOnMoveComplete)
            {
               return false;
            }
            switch(this._moving)
            {
               case 1:
                  if(Boolean(this._followPath))
                  {
                     this.followPath();
                  }
                  else if(_layerAnim.bounceEnabled)
                  {
                     if(this.isSelf)
                     {
                        RoomManagerWorld.instance.resetThrottle();
                        RoomManagerWorld.instance.killPlayerPath();
                     }
                  }
                  else
                  {
                     this._moving = -1;
                  }
                  break;
               case -1:
                  playAnim(this._lastIdleAnim,this._lastIdleFlip);
                  this._moving = 0;
                  if(this.isSelf)
                  {
                     RoomManagerWorld.instance.resetThrottle();
                  }
            }
         }
         if(Boolean(this._pet))
         {
            this._pet.heartbeat();
         }
         return true;
      }
      
      public function playIdle() : void
      {
         playAnim(this.getBaseIdle(),this._lastIdleFlip);
      }
      
      public function setActivePet(lBits:uint, uBits:uint, eBits:uint, petName:String, sparkle:int = 0) : void
      {
         if(Boolean(this._pet))
         {
            if(this._pet.parent == this)
            {
               this.removeChild(this._pet);
            }
            this._pet = null;
         }
         if(gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST || this._shouldShowPetOnly)
         {
            if(lBits != 0 && PetManager.canCurrAvatarUsePet(_avatar.enviroTypeFlag,PetManager.petTypeForDefId(lBits & 0xFF)))
            {
               this._pet = new WorldPet(this,lBits,uBits,eBits,sparkle);
            }
            if(this._shouldShowPetOnly)
            {
               if(!this.isActivePetGroundPet())
               {
                  this._splash.showShadow(false);
               }
               this._currPetName = LocalizationManager.translatePetName(petName);
               this._namebar.setAvName(this._currPetName);
            }
            else
            {
               this._splash.showShadow(true);
            }
         }
      }
      
      public function getActivePet() : WorldPet
      {
         return this._pet;
      }
      
      public function isActivePetGroundPet() : Boolean
      {
         if(Boolean(this._pet))
         {
            return this._pet.isGround();
         }
         return true;
      }
      
      public function flipSplash(b:Boolean) : void
      {
         this._splash.flipSplash(b);
      }
      
      public function isSplashAnim() : Boolean
      {
         return !(_layerAnim.animId == LayerAnim.AN_IDLE_SE || _layerAnim.animId == LayerAnim.AN_IDLE_NE);
      }
      
      public function isPetMovingTest() : Boolean
      {
         return !(_layerAnim.animId == LayerAnim.AN_IDLE_SE || _layerAnim.animId == LayerAnim.AN_IDLE_NE || _layerAnim.animId == LayerAnim.AN_SIT_E || _layerAnim.animId == LayerAnim.AN_SIT_NE || _layerAnim.animId == LayerAnim.AN_SIT_NNE || _layerAnim.animId == LayerAnim.AN_SIT_SE || _layerAnim.animId == LayerAnim.AN_SIT_SSE || _layerAnim.animId == LayerAnim.AN_PLAY || _layerAnim.animId == LayerAnim.AN_SLEEP || _layerAnim.animId == LayerAnim.AN_FLOAT || _layerAnim.animId == LayerAnim.AN_WATER_POSE || _layerAnim.animId == LayerAnim.AN_WATER_SPIN);
      }
      
      public function inSplashVolume() : Boolean
      {
         return this._bInSplashVolume;
      }
      
      private function initNamebar(accountType:int) : void
      {
         this._isMember = Utility.isMember(accountType);
         if(this._isMember || this._isGuide)
         {
            this._namebar = GETDEFINITIONBYNAME("memberNameBar");
         }
         else
         {
            this._namebar = GETDEFINITIONBYNAME("FreeNameBar");
         }
         this._namebar.x = NAMEBAR_X_OFFSET;
         this._namebar.y = NAMEBAR_Y_OFFSET;
         addChild(this._namebar);
      }
      
      private function setNamebarListenersWithUserName(setUserName:String) : void
      {
         if(!setUserName)
         {
            return;
         }
         if(setUserName != gMainFrame.server.userName || Boolean(gMainFrame.userInfo.isModerator))
         {
            this._namebar.addEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler,false,0,true);
            this._namebar["selnub"].addEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler,false,0,true);
         }
         else
         {
            this._namebar.removeListeners();
         }
      }
      
      public function toggleNamebarSelNub(packedNameBarData:int = -1) : void
      {
         var packedData:int = 0;
         if(this._isGuide)
         {
            this._namebar.setNubType(NameBar.GUIDE);
         }
         else
         {
            if(packedNameBarData == -1)
            {
               packedData = this._namebar.packedNameBarData;
            }
            else
            {
               packedData = packedNameBarData;
            }
            if(BuddyManager.isBuddy(_avatar.userName) || this.isSelf || this._isMember && NameBar.isVIPBadge(packedData))
            {
               this._namebar.setNubType(NameBar.BUDDY);
            }
            else
            {
               this._namebar.setNubType(NameBar.NON_BUDDY);
            }
         }
         if(!this.isSelf)
         {
            if(BuddyManager.isBlocked(_avatar.userName))
            {
               this._namebar.isBlocked = true;
            }
            else
            {
               this._namebar.isBlocked = false;
            }
         }
         else
         {
            this._namebar.isBlocked = false;
         }
      }
      
      private function get isSelf() : Boolean
      {
         return userName == gMainFrame.userInfo.myUserName;
      }
      
      private function followPath() : void
      {
         var o:Object = null;
         var len:int = int(this._followPath.length);
         if(Boolean(len))
         {
            o = this._followPath[0];
            if(len > 1)
            {
               this._followPath.splice(0,1);
            }
            else
            {
               this._followPath = null;
            }
            this.setPos(o.x,o.y,true,false);
         }
      }
      
      private function updatePos(x:Number, y:Number) : void
      {
         this._pos.x = x;
         this._pos.y = y;
         x *= this._scale.x;
         y *= this._scale.y;
         this.x = x;
         this.y = y;
         var p:Point = AvatarUtility.getAvatarChatOffset(_avatar.avTypeId);
         this._chatBalloon.x = this.x + p.x;
         this._chatBalloon.y = this.y + p.y;
         if(Boolean(this._secondaryEmot))
         {
            if(!isOffScreen)
            {
               this._secondaryEmot.x = this.x + ATTACHMENT_X_OFFSET;
               this._secondaryEmot.y = this.y + ATTACHMENT_Y_OFFSET;
            }
            else
            {
               this._secondaryEmot.lastKnownX = this.x + ATTACHMENT_X_OFFSET;
               this._secondaryEmot.lastKnownY = this.y + ATTACHMENT_Y_OFFSET;
            }
         }
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && gMainFrame.userInfo.myUserName != _avatar.userName)
         {
            this.updateOffScreenPositions();
         }
      }
      
      public function updateOffScreenPositions() : void
      {
         var acAvCacheInfo:AvatarInfo = null;
         if(!this._hudViewHolder)
         {
            this._hudViewHolder = GETDEFINITIONBYNAME("offScreenIconQuest");
            this._hudViewHolder.mouse.gotoAndStop("up");
            this._hudViewHolder.questChatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,7,SBTextField);
            if(Boolean(this._flashTimer))
            {
               this._flashTimer.reset();
            }
            this._flashTimer = new Timer(2500);
            this._flashTimer.addEventListener(TimerEvent.TIMER,this.onFlashTimer,false,0,true);
            AvatarManager.setViewHudMCBySfsId(userId,this._hudViewHolder);
         }
         var scalePoint:Point = RoomManagerWorld.instance.bkgScalePoint();
         var myScreenPoint:Point = RoomManagerWorld.instance.convertWorldToScreen(this.x * scalePoint.x,this.y * scalePoint.y);
         var holderHeight:int = this._hudViewHolder.mouse.height * 0.5 * scalePoint.x;
         var holderWidth:int = this._hudViewHolder.mouse.width * 0.5 * scalePoint.y;
         var hudHeight:int = 73.5 * scalePoint.y;
         var iconRect:Rectangle = new Rectangle(0,0,MainFrame.VIEW_WIDTH - holderWidth,MainFrame.VIEW_HEIGHT - holderHeight - hudHeight + this._radius * 2 * scalePoint.x);
         if(!iconRect.containsPoint(myScreenPoint))
         {
            updateScreenPositionAndDirection(this._hudViewHolder,iconRect,myScreenPoint);
            if(!isOffScreen)
            {
               if(this._hudViewHolder.mouse.currentFrameLabel != "up")
               {
                  this._hudViewHolder.mouse.gotoAndStop("up");
               }
               if(GuiManager.isBeYourPetRoom())
               {
                  acAvCacheInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(userName,perUserAvId);
                  this._hudAvtOrPetView = new GuiPet(0,acAvCacheInfo.currPet.lBits,acAvCacheInfo.currPet.uBits,acAvCacheInfo.currPet.eBits,acAvCacheInfo.currPet.type,acAvCacheInfo.currPet.name,this.onHudAvtOrPetView);
               }
               else
               {
                  this._hudAvtOrPetView = new AvatarView();
                  this._hudAvtOrPetView.init(_avatar);
                  this._hudAvtOrPetView.playAnim(LayerAnim.AN_HUD_AVT,false,LayerAnim.PLAY_ONE_SHOT,this.onHudAvtOrPetView);
                  this._hudAvtOrPetView.avTypeChangedCallback = this.updateHudViewPosition;
               }
               this.visible = false;
               isOffScreen = true;
               this._hudViewHolder.visible = true;
               this._chatLayer.removeChild(this._chatBalloon);
               if(Boolean(this._secondaryEmot))
               {
                  this._chatLayer.removeChild(this._secondaryEmot);
               }
            }
            this._hudViewHolder.x = myScreenPoint.x;
            this._hudViewHolder.y = myScreenPoint.y;
         }
         else if(isOffScreen || this._hudViewHolder.visible)
         {
            if(this._hudViewHolder.mouse.currentFrameLabel != "up")
            {
               this._hudViewHolder.mouse.gotoAndStop("up");
            }
            if(Boolean(this._hudViewHolder) && Boolean(this._hudViewHolder.parent) && this._hudViewHolder.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(this._hudViewHolder);
            }
            this._hudViewHolder.visible = false;
            isOffScreen = false;
            this.visible = true;
            this._chatLayer.addChild(this._chatBalloon);
            if(Boolean(this._secondaryEmot))
            {
               this._chatLayer.addChild(this._secondaryEmot);
               this._secondaryEmot.x = this._secondaryEmot.lastKnownX;
               this._secondaryEmot.y = this._secondaryEmot.lastKnownY;
               this._secondaryEmot.scaleX = this._secondaryEmot.scaleY = 1;
            }
            if(lastAnimToHappen != -1)
            {
               playAnim(lastAnimToHappen,this._lastIdleFlip);
               lastAnimToHappen = -1;
            }
            else
            {
               playAnim(this._lastIdleAnim,this._lastIdleFlip);
            }
         }
      }
      
      private function updateOffScreenItemsForOthers(hudViewIcon:MovieClip, lastPositions:Point) : void
      {
      }
      
      private function onHudAvtOrPetView(layerOrContent:Object, animIdOrPet:Object) : void
      {
         this.updateHudViewPosition();
         while(this._hudViewHolder.charLayer.numChildren > 0)
         {
            this._hudViewHolder.charLayer.removeChildAt(0);
         }
         this._hudViewHolder.charLayer.addChild(this._hudAvtOrPetView);
         GuiManager.guiLayer.addChild(this._hudViewHolder);
      }
      
      private function updateHudViewPosition() : void
      {
         var avatarOffset:Point = null;
         var scale:Number = NaN;
         if(GuiManager.isBeYourPetRoom())
         {
            this._hudAvtOrPetView.y = 15;
         }
         else
         {
            avatarOffset = AvatarUtility.getAvatarHudPosition(this._hudAvtOrPetView.avTypeId);
            this._hudAvtOrPetView.scaleX = this._hudAvtOrPetView.scaleY = 1;
            scale = 41 / this._hudAvtOrPetView.width;
            if(this._hudAvtOrPetView.height * scale > 41)
            {
               scale = 41 / this._hudAvtOrPetView.height;
            }
            this._hudAvtOrPetView.scaleX = scale;
            this._hudAvtOrPetView.scaleY = scale;
            this._hudAvtOrPetView.x = avatarOffset.x * scale;
            this._hudAvtOrPetView.y = avatarOffset.y * scale;
         }
      }
      
      private function updateSecondaryEmoteOffScreenPosition() : void
      {
         this._secondaryEmot.scaleX = this._secondaryEmot.scaleY = 1;
         var scale:Number = 0.5;
         this._secondaryEmot.scaleX = scale;
         this._secondaryEmot.scaleY = scale;
         this._secondaryEmot.x = (0 - 355) * scale;
         this._secondaryEmot.y = (0 - 235) * scale;
      }
      
      private function updateOffScreenChat(text:String, changeFontColor:Boolean) : void
      {
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && gMainFrame.userInfo.myUserName != _avatar.userName && Boolean(this._hudViewHolder))
         {
            this._hudViewHolder.questChatBalloon.setText(text,changeFontColor,false);
         }
      }
      
      private function offScreenChatHeartbeat(ms:int) : void
      {
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST && gMainFrame.userInfo.myUserName != _avatar.userName && Boolean(this._hudViewHolder))
         {
            this._hudViewHolder.questChatBalloon.heartbeat(ms);
         }
      }
      
      public function faceAnim(xdiff:Number, ydiff:Number, bMove:Boolean = true) : void
      {
         var angle:Number = Math.atan2(ydiff,xdiff);
         var offset:Number = Math.PI * 0.1;
         var step:Number = Math.PI * 0.2;
         this._lastMoveAngle = angle;
         var cti:Object = convertToIdle(this._lastMoveAngle);
         this._lastIdleAnim = cti.anim;
         if(this._roomType == Utility.ENVIRO_OCEAN)
         {
            this._lastIdleAnim = this.getBaseIdle();
         }
         this._lastIdleFlip = cti.flip;
         var animDir:int = 0;
         var animFlip:Boolean = false;
         if(angle >= 5 * step - offset || angle < -5 * step + offset)
         {
            animDir = 2;
            animFlip = true;
         }
         else if(angle >= -4 * step - offset && angle < -4 * step + offset)
         {
            animDir = 1;
            animFlip = true;
         }
         else if(angle >= -3 * step - offset && angle < -3 * step + offset)
         {
            animDir = 0;
            animFlip = true;
         }
         else if(angle >= -2 * step - offset && angle < -2 * step + offset)
         {
            animDir = 0;
         }
         else if(angle >= -step - offset && angle < -step + offset)
         {
            animDir = 1;
         }
         else if(angle >= -offset && angle < offset)
         {
            animDir = 2;
         }
         else if(angle >= step - offset && angle < step + offset)
         {
            animDir = 3;
         }
         else if(angle >= 2 * step - offset && angle < 2 * step + offset)
         {
            animDir = 4;
         }
         else if(angle >= 3 * step - offset && angle < 3 * step + offset)
         {
            animDir = 4;
            animFlip = true;
         }
         else
         {
            animDir = 3;
            animFlip = true;
         }
         var animId:int = LayerAnim.AN_MOVE_NNE + animDir;
         if(!bMove)
         {
            switch(animDir)
            {
               case 0:
               case 1:
                  animId = LayerAnim.AN_IDLE_NE;
                  break;
               case 2:
               case 3:
               case 4:
                  animId = LayerAnim.AN_IDLE_SE;
            }
         }
         if(this._roomType == Utility.ENVIRO_OCEAN)
         {
            animId = LayerAnim.AN_SWIM_E;
         }
         if(_layerAnim.bounceEnabled)
         {
            animId = LayerAnim.AN_HOP;
         }
         playAnim(animId,animFlip,LayerAnim.PLAY_LOOP__KEEP_CURRENT_FRAME);
      }
      
      override protected function avatarChanged(evt:AvatarEvent) : void
      {
         var ui:UserInfo = null;
         super.avatarChanged(evt);
         if(Boolean(this._namebar))
         {
            ui = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
            if(ui != null)
            {
               this.toggleNamebarSelNub(ui.nameBarData);
            }
            if(Boolean(ui) && Boolean(!this._isGuide) && !this._shouldShowPetOnly)
            {
               this._namebar.setColorAndBadge(ui.nameBarData);
               this._namebar.setColorBadgeAndXp(ui.nameBarData,gMainFrame.userInfo.getAvatarInfoByUserName(_avatar.userName).questLevel,this._isMember,gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST_STAGING);
               this._namebar.setAvName(_avatar.avName);
            }
            else
            {
               this._namebar.setColorAndBadge(0);
               this._namebar.setColorBadgeAndXp(0,0,this._isMember);
               if(this._shouldShowPetOnly && Boolean(this._currPetName))
               {
                  this._namebar.setAvName(this._currPetName);
               }
               else
               {
                  this._namebar.setAvName(_avatar.avName);
               }
            }
            this._chatBalloon.avType = _avatar.avTypeId;
         }
      }
      
      public function overHandler(m:MouseEvent) : void
      {
         this._namebar["selnub"].visible = true;
      }
      
      public function outHandler(m:MouseEvent) : void
      {
         if(Boolean(this._namebar["n"].visible))
         {
            return;
         }
         if(Boolean(m && m.relatedObject) && Boolean(m.relatedObject is DisplayObject) && this._namebar.contains(DisplayObject(m.relatedObject)))
         {
            return;
         }
         this._namebar["selnub"].visible = false;
      }
      
      public function preload(callback:Function) : void
      {
         var a:Array = new Array(LayerAnim.AN_MOVE_NNE,LayerAnim.AN_MOVE_NE,LayerAnim.AN_MOVE_E,LayerAnim.AN_MOVE_SE,LayerAnim.AN_MOVE_SSE,LayerAnim.AN_IDLE_SE);
         _layerAnim.preload(a,callback);
      }
      
      public function handleOffScreenSleep(isReviving:Boolean = false) : void
      {
         if(isOffScreen && this._hudViewHolder != null)
         {
            if(isReviving)
            {
               if(this._hudViewHolder.mouse.currentFrameLabel == "sleeping")
               {
                  this._hudViewHolder.zzz.visible = false;
                  this._hudViewHolder.mouse.gotoAndStop("up");
               }
               return;
            }
            if(this._hudViewHolder.mouse.currentFrameLabel != "sleeping")
            {
               this._hudViewHolder.mouse.gotoAndStop("sleeping");
               if(this._hudViewHolder.mouse.rotation == 180 && this._hudViewHolder.zzz.rotation != 180)
               {
                  this._hudViewHolder.zzz.rotation = 180;
                  this._hudViewHolder.zzz.x = 0.1;
                  this._hudViewHolder.zzz.y = 9.2;
               }
               else if(this._hudViewHolder.zzz.rotation != 0)
               {
                  this._hudViewHolder.zzz.rotation = 0;
                  this._hudViewHolder.zzz.x = 0.1;
                  this._hudViewHolder.zzz.y = 0.2;
               }
            }
         }
      }
      
      public function handleOffScreenHit() : void
      {
         if(isOffScreen && this._hudViewHolder != null)
         {
            if(Boolean(this._flashTimer))
            {
               this._flashTimer.reset();
               this._flashTimer.start();
            }
            if(this._hudViewHolder.mouse.currentFrameLabel != "flash")
            {
               this._hudViewHolder.mouse.gotoAndStop("flash");
            }
         }
      }
      
      private function onFlashTimer(t:TimerEvent) : void
      {
         if(Boolean(this._flashTimer))
         {
            this._flashTimer.reset();
         }
         if(Boolean(this._hudViewHolder))
         {
            this._hudViewHolder.mouse.gotoAndStop("up");
         }
      }
      
      private function ownNamebarDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(Boolean(this._guiMgr))
         {
            this._guiMgr.openAvatarEditor();
         }
      }
      
      private function onChatBallonAdventureDown(scriptDefId:int) : void
      {
         var scriptDef:Object = QuestXtCommManager.getScriptDef(scriptDefId);
         if(Boolean(scriptDef.membersOnly) && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup(UpsellManager.ADVENTURES,"adventure/" + scriptDefId);
            return;
         }
         QuestXtCommManager.sendQuestJoinPrivate(userName);
      }
      
      private function onChatBalloonPVPDown(gameDefId:int) : void
      {
         QuestManager.privateAdventureJoinClose(true);
         MinigameManager.readySelfForPvpGame({"typeDefId":gameDefId},userName,true,true);
         MinigameXtCommManager.sendMinigameCustomPvpJoinMsg(gameDefId,0,userName);
      }
      
      private function namebarAndAvatarDownHandler(m:MouseEvent) : void
      {
         var pt:Point = null;
         var vo:Object = null;
         var player:Object = null;
         m.stopPropagation();
         if(gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST)
         {
            pt = RoomManagerWorld.instance.convertScreenToWorldSpace(m.stageX,m.stageY);
            vo = RoomManagerWorld.instance.volumeManager.testMouseVolumes(pt,true,function(s:String):Boolean
            {
               return false;
            });
            if(vo == null || vo.name == "dark")
            {
               player = {
                  "userName":userName,
                  "onlineStatus":SFClient.STATUS_ONLINE
               };
               if(Boolean(_guiObj))
               {
                  _guiObj.showUserInfoPopup(player);
               }
            }
         }
      }
      
      private function namebarAndAvatarOverHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(m.currentTarget.mouse.currentFrameLabel != "over")
         {
            AJAudio.playExitBtnRollover();
            m.currentTarget.mouse.gotoAndStop("over");
         }
      }
      
      private function namebarAndAvatarOutHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(m.currentTarget.mouse.currentFrameLabel != "up")
         {
            m.currentTarget.mouse.gotoAndStop("up");
         }
      }
      
      private function attachmentMouseDownHandler(m:MouseEvent) : void
      {
         m.currentTarget.parent.getChildAt(0).play();
         m.stopPropagation();
      }
      
      public function startSlide(points:Array) : void
      {
         this._moving = 0;
         this._slidePositions = points;
         this._slideSpinCurrentDirection = 0;
         this._slideSpinTimer = 0;
         this._slideCurrentPosition = 0;
         this._slideFrameTime = 0;
         this._followPath = null;
      }
      
      public function updateSlide(ms:int) : void
      {
         var slideDir:int = 0;
         var slideDirFlip:Boolean = false;
         if(this._slideCurrentPosition >= 0)
         {
            while(ms > 0)
            {
               if(this._slideCurrentPosition >= this._slidePositions.length - 1)
               {
                  if(_avatar.userName == gMainFrame.server.userName)
                  {
                     AchievementXtCommManager.requestSetUserVar(96,1);
                  }
                  this._slideCurrentPosition = -1;
                  playAnim(this.getBaseIdle());
                  this._moving = Boolean(this._followPath) ? 1 : 0;
                  break;
               }
               if(this._slideFrameTime + ms < SLIDE_FRAME_TIME)
               {
                  this._slideFrameTime += ms;
                  ms = 0;
               }
               else
               {
                  ms -= SLIDE_FRAME_TIME - this._slideFrameTime;
                  this._slideFrameTime = SLIDE_FRAME_TIME;
               }
               this.setPos(this._slidePositions[this._slideCurrentPosition].x + (this._slidePositions[this._slideCurrentPosition + 1].x - this._slidePositions[this._slideCurrentPosition].x) * this._slideFrameTime / SLIDE_FRAME_TIME,this._slidePositions[this._slideCurrentPosition].y + (this._slidePositions[this._slideCurrentPosition + 1].y - this._slidePositions[this._slideCurrentPosition].y) * this._slideFrameTime / SLIDE_FRAME_TIME,false,false);
               if(ms > 0)
               {
                  this._slideFrameTime = 0;
                  ++this._slideCurrentPosition;
               }
            }
            if(this._roomType != Utility.ENVIRO_OCEAN)
            {
               if(this._slideCurrentPosition >= 0 && (this._slideSpinTimer == 0 || this._slideSpinTimer < getTimer()))
               {
                  ++this._slideSpinCurrentDirection;
                  if(this._slideSpinCurrentDirection > 9)
                  {
                     this._slideSpinCurrentDirection = 0;
                  }
                  slideDir = 0;
                  slideDirFlip = this._slideSpinCurrentDirection > 4 ? true : false;
                  switch(this._slideSpinCurrentDirection)
                  {
                     case 0:
                        slideDir = 0;
                        break;
                     case 1:
                        slideDir = 1;
                        break;
                     case 2:
                        slideDir = 2;
                        break;
                     case 3:
                        slideDir = 3;
                        break;
                     case 4:
                        slideDir = 4;
                        break;
                     case 5:
                        slideDir = 4;
                        break;
                     case 6:
                        slideDir = 3;
                        break;
                     case 7:
                        slideDir = 2;
                        break;
                     case 8:
                        slideDir = 1;
                        break;
                     case 9:
                        slideDir = 0;
                  }
                  this._slideSpinTimer = getTimer() + 100;
                  playAnim(LayerAnim.AN_SIT_NNE + slideDir,slideDirFlip,LayerAnim.PLAY_LOOP__KEEP_CURRENT_FRAME);
               }
            }
         }
      }
      
      public function setBounce(bounce:Boolean) : void
      {
         _layerAnim.bounceEnabled = bounce;
      }
   }
}

