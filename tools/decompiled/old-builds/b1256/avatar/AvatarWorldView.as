package avatar
{
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.input.SBTextField;
   import com.sbi.corelib.math.Collision;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
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
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.MySettings;
   import gui.UpsellManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   import pet.WorldPet;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   
   public class AvatarWorldView extends AvatarView
   {
      
      public static const AV_MODE_DEFAULT:int = 0;
      
      public static const AV_MODE_QUESTCOMBAT:int = 1;
      
      private static const ACTION_TIME:int = 3000;
      
      private static const SELNUB_SHOW_DIST:Number = 150;
      
      private static const AVATAR_MOVEDIR_ANGLE_OFFSET:Number = 0.20943951;
      
      private static const NAMEBAR_X_OFFSET:int = -15;
      
      private static const NAMEBAR_Y_OFFSET:int = 18;
      
      private static const ATTACHMENT_X_OFFSET:int = -310;
      
      private static const ATTACHMENT_Y_OFFSET:int = -320;
      
      private static const SLIDE_FRAME_TIME:Number = 41.666666666666664;
      
      private static const GLOW_LAND_DEFAULT_COLOR:int = 5586479;
      
      private static const GLOW_OCEAN_DEFAULT_COLOR:int = 2775381;
      
      private static var _guiObj:Object;
      
      public static var _actionLookup:Array = [{
         "name":":dance:",
         "land":23,
         "water":38,
         "flip":false
      },{
         "name":":sleep:",
         "land":22,
         "water":41,
         "flip":false
      },{
         "name":":dive:",
         "land":22,
         "water":41,
         "flip":false
      },{
         "name":":hop:",
         "land":17,
         "water":33,
         "flip":false
      },{
         "name":":swirl:",
         "land":17,
         "water":33,
         "flip":false
      },{
         "name":":play:",
         "land":6,
         "water":39,
         "flip":false
      },{
         "name":":sitNW:",
         "land":2,
         "water":40,
         "flip":true
      },{
         "name":":poseLeft:",
         "land":2,
         "water":40,
         "flip":true
      },{
         "name":":sitNE:",
         "land":2,
         "water":40,
         "flip":false
      },{
         "name":":sitSE:",
         "land":4,
         "water":40,
         "flip":true
      },{
         "name":":poseRight:",
         "land":2,
         "water":40,
         "flip":false
      },{
         "name":":sitSW:",
         "land":4,
         "water":40,
         "flip":false
      }];
      
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
      
      private var _emitParticles:Boolean;
      
      private var _timeSinceLastParticle:Number;
      
      private var _lastParticleLoc:Point;
      
      private var _particleOffset:int;
      
      private var _particleIdling:MovieClip;
      
      private var _patternIndex:int;
      
      private var _currSpecialPatternColors:Array;
      
      private var _timeSinceLastHostingUpdate:Number;
      
      public function AvatarWorldView()
      {
         super();
      }
      
      public static function init(param1:Object = null) : void
      {
         _guiObj = param1;
      }
      
      public static function destroy() : void
      {
         _guiObj = null;
      }
      
      public static function convertToIdle(param1:Number) : Object
      {
         var _loc3_:int = 14;
         var _loc2_:Boolean = false;
         var _loc4_:Number = 1.5707963267948966;
         if(param1 > -2 * _loc4_ && param1 < -_loc4_)
         {
            _loc3_ = 16;
            _loc2_ = true;
         }
         else if(param1 >= -_loc4_ && param1 < 0)
         {
            _loc3_ = 16;
         }
         else if(param1 >= 0 && param1 < _loc4_)
         {
            _loc3_ = 14;
         }
         else
         {
            _loc3_ = 14;
            _loc2_ = true;
         }
         return {
            "anim":_loc3_,
            "flip":_loc2_
         };
      }
      
      public static function updateScreenPositionAndDirection(param1:MovieClip, param2:Rectangle, param3:Point) : void
      {
         if(param3.x > param2.width)
         {
            if(param3.x > param2.width)
            {
               param3.x = 900 - param1.mouse.width * 0.5;
            }
            param1.openChat(180,0);
         }
         else if(param3.x - param1.mouse.width * 0.5 < 0)
         {
            param1.openChat(0,0);
            if(param3.x - param1.mouse.width * 0.5 < 0)
            {
               param3.x += 0 - param3.x + param1.mouse.width * 0.5;
            }
         }
         if(param3.y > param2.height - 73.5)
         {
            param3.y = 550 - param1.mouse.height * 0.5 - 73.5;
            if(param3.x - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5) < 0)
            {
               param1.openChat(-90,param3.x + (0 - param3.x + (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5)));
            }
            else if(param3.x - (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5) > param2.width)
            {
               param1.openChat(-90,param3.x - (900 - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5)),true);
            }
            else
            {
               param1.openChat(-90,0);
            }
         }
         else if(param3.y - param1.mouse.height * 0.5 < 0)
         {
            param3.y += 0 - param3.y + param1.mouse.height * 0.5;
            if(param3.x - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5) < 0)
            {
               param1.openChat(90,param3.x + (0 - param3.x + (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5)));
            }
            else if(param3.x - (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5) > param2.width)
            {
               param1.openChat(90,param3.x - (900 - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5)),true);
            }
            else
            {
               param1.openChat(90,0);
            }
         }
      }
      
      override public function init(param1:Avatar, param2:Function = null) : void
      {
         throw new Error("Don\'t use this!  Use initWorldView instead!  ...I miss overloading...");
      }
      
      public function initWorldView(param1:Avatar, param2:Object, param3:int, param4:Boolean, param5:Boolean = false, param6:Object = null, param7:Object = null, param8:int = 0, param9:int = 0) : void
      {
         var _loc12_:int = 0;
         _avatar = param1;
         if(!param2)
         {
            throw new Error("AvatarWorldView got invalid chatLayer:null!");
         }
         _chatLayer = param2;
         _actionMgr = param6;
         _guiMgr = param7;
         _roomType = param9;
         if(param5)
         {
            visible = false;
         }
         param1.addEventListener("OnAvatarChanged",avatarChanged,false,0,true);
         _isGuide = param4;
         _scale = new Point(1,1);
         _pos = new Point(0,0);
         _slideCurrentPosition = -1;
         lastAnimToHappen = -1;
         if(param1.perUserAvId != 0 && gMainFrame.clientInfo.roomType == 7 && QuestManager.hasJustJoinedQuest)
         {
            AvatarManager.setOffScreenMapBySfsId(userId,new Point(0,0),gMainFrame.server.getCurrentRoomName(false));
         }
         initNamebar(param3);
         if(param1.avName == "")
         {
            _namebar.visible = false;
         }
         if(_avatar.isShaman)
         {
            _loc12_ = 2;
         }
         else if(_isGuide)
         {
            _loc12_ = 3;
         }
         else
         {
            _loc12_ = 1;
         }
         _chatBalloon = GETDEFINITIONBYNAME("ChatBalloonAsset");
         _chatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,_loc12_,SBTextField,onChatBallonAdventureDown,onChatBalloonPVPDown);
         _chatLayer.addChild(_chatBalloon);
         _moving = 0;
         _lastMoveAngle = 2;
         _lastIdleAnim = getBaseIdle();
         _lastIdleFlip = false;
         setNamebarListenersWithUserName(param1.userName);
         toggleNamebarSelNub(param8);
         _namebar.setColorAndBadge(param8);
         var _loc10_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
         if(_loc10_)
         {
            _namebar.isHostingCustomParty = _loc10_.isStillHosting;
         }
         _layerAnim = LayerAnim.getNew();
         _layerAnim.avDefId = param1.avTypeId;
         if(param1.colors)
         {
            _layerAnim.layers = setLayerHelper();
         }
         _layerAnim.local = userId == AvatarManager.playerSfsUserId;
         var _loc11_:LayerBitmap = _layerAnim.bitmap;
         _loc11_.x = 0;
         _loc11_.y = 0;
         _glow = new GlowFilter(0,1,4,4,4);
         _layerAnim.bitmap.filters = [_glow];
         setBlendColor();
         _splash = new AvatarViewExt_Splash(this,_loc11_);
         if(_roomType == 1)
         {
            _splash.showShadow(false);
         }
         if(userId == AvatarManager.playerSfsUserId || gMainFrame.clientInfo.roomType == 7)
         {
            _namebar.mouseChildren = false;
            _namebar.mouseEnabled = false;
            _chatBalloon.mouseChildren = false;
            _chatBalloon.mouseEnabled = false;
         }
         if(gMainFrame.clientInfo.roomType == 7 && AvatarManager.getViewHudMCBySfsId(userId))
         {
            _hudViewHolder = AvatarManager.getViewHudMCBySfsId(userId);
            if(_hudViewHolder)
            {
               if(_flashTimer)
               {
                  _flashTimer.reset();
               }
               _flashTimer = new Timer(2500);
               _flashTimer.addEventListener("timer",onFlashTimer,false,0,true);
               _hudViewHolder.mouse.gotoAndStop("up");
            }
         }
         _shouldShowPetOnly = GuiManager.isBeYourPetRoom();
         if(_shouldShowPetOnly)
         {
            _layerAnim.alpha = 0;
            _layerAnim.avatarEnabled = false;
         }
         else
         {
            _layerAnim.alpha = 1;
            _namebar.setAvName(param1,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),gMainFrame.userInfo.getUserInfoByUserName(param1.userName));
            _layerAnim.avatarEnabled = true;
            _timeSinceLastParticle = -1;
            _particleOffset = 1;
            setupParticles();
         }
         _bInSplashVolume = false;
         _isLoadingEmoteId = -1;
      }
      
      override public function destroy(param1:Boolean = false) : void
      {
         QuestManager.removeTorch(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         if(param1 && _avatar)
         {
            _avatar.destroy();
            _avatar = null;
         }
         var _loc2_:LayerBitmap = _layerAnim.bitmap;
         removeChild(_loc2_);
         _loc2_.filters = null;
         super.destroy();
         if(_chatBalloon && _chatBalloon.parent == _chatLayer)
         {
            _chatLayer.removeChild(_chatBalloon);
         }
         removeChild(_namebar);
         if(_secondaryEmot && _chatLayer.contains(_secondaryEmot))
         {
            _chatLayer.removeChild(_secondaryEmot);
         }
         _splash.destroy();
         if(_particleIdling)
         {
            clearSpecialPattern();
         }
         removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _namebar.removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _namebar["selnub"].removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _namebar.removeEventListener("mouseDown",ownNamebarDownHandler);
         _chatBalloon = null;
         if(_namebar)
         {
            _namebar.destroy();
         }
         _namebar = null;
         avTypeChangedCallback = null;
         _slidePositions = null;
         _glow = null;
         if(_flashTimer)
         {
            _flashTimer.reset();
            _flashTimer.removeEventListener("timer",onFlashTimer);
            _flashTimer = null;
            _hudViewHolder.mouse.gotoAndStop("up");
         }
         if(_hudAvtOrPetView)
         {
            _hudAvtOrPetView.destroy();
            _hudAvtOrPetView = null;
         }
      }
      
      public function get radius() : Number
      {
         return _radius;
      }
      
      public function get attachmentVisible() : Boolean
      {
         return _secondaryEmot == null;
      }
      
      public function get moving() : Boolean
      {
         return _moving == 1 || _slideCurrentPosition >= 0;
      }
      
      public function get hFlip() : Boolean
      {
         return _layerAnim.hFlip;
      }
      
      public function get lastIdleAnim() : int
      {
         return _lastIdleAnim;
      }
      
      public function get lastIdleFlip() : Boolean
      {
         return _lastIdleFlip;
      }
      
      public function get splashLiquid() : String
      {
         return _splashLiquid;
      }
      
      public function get roomType() : int
      {
         return _roomType;
      }
      
      public function set roomType(param1:int) : void
      {
         _roomType = param1;
      }
      
      public function set deleteOnMoveComplete(param1:Boolean) : void
      {
         _deleteOnMoveComplete = param1;
      }
      
      public function get currentLevel() : int
      {
         if(_namebar)
         {
            return _namebar.currentLevel;
         }
         return 0;
      }
      
      public function isThisAttachmentOn(param1:int) : Boolean
      {
         if(_secondaryEmot == null)
         {
            return false;
         }
         if(_avAttMediaId == param1)
         {
            return true;
         }
         return false;
      }
      
      public function getBaseIdle() : int
      {
         return _roomType == 1 ? 32 : 14;
      }
      
      public function setPath(param1:Array) : void
      {
         _followPath = param1;
         if(_slideCurrentPosition == -1)
         {
            _moving = -1;
            followPath();
         }
      }
      
      public function get avatarPos() : Point
      {
         return _pos;
      }
      
      public function setPos(param1:Number, param2:Number, param3:Boolean, param4:Boolean = true) : void
      {
         var _loc5_:Number = NaN;
         if(param4)
         {
            _followPath = null;
         }
         if(param3)
         {
            _dirX = param1 - _pos.x;
            _dirY = param2 - _pos.y;
            _loc5_ = Math.sqrt(_dirX * _dirX + _dirY * _dirY);
            if(_loc5_)
            {
               _dirX /= _loc5_ * _scale.x;
               _dirY /= _loc5_ * _scale.y;
            }
            faceAnim(_dirX,_dirY,true);
            _moving = 1;
            _moveToX = param1;
            _moveToY = param2;
         }
         else
         {
            _dirX = 0;
            _dirY = 0;
            updatePos(param1,param2);
         }
      }
      
      public function get currAvatar() : Avatar
      {
         return _avatar;
      }
      
      public function get nameBar() : NameBar
      {
         return _namebar;
      }
      
      public function get nameBarIconIds() : Array
      {
         return _namebar.iconIds;
      }
      
      public function get nubData() : Array
      {
         return _namebar.nubData;
      }
      
      public function get xpShapeIcons() : Object
      {
         return _namebar.xpShapeIcons;
      }
      
      public function setSplashVolume(param1:Boolean, param2:String) : void
      {
         _bInSplashVolume = param1;
         _splashLiquid = param2;
      }
      
      public function setAvatarMode(param1:int) : void
      {
         switch(param1 - 1)
         {
            case 0:
               _layerAnim.bitmap.filters = null;
               if(_splash)
               {
                  _splash.showShadow(false);
               }
               if(_namebar != null)
               {
                  _namebar.visible = false;
               }
         }
      }
      
      public function setupParticles() : void
      {
         _emitParticles = _avatar.colors && _avatar.customAvId != -1;
         updateSpecialPatternColors();
         clearSpecialPattern();
      }
      
      public function clearSpecialPattern() : void
      {
         var _loc1_:Loader = null;
         if(_particleIdling)
         {
            _loc1_ = _particleIdling.getChildAt(0) as Loader;
            if(_loc1_.content)
            {
               (_loc1_.content as MovieClip).readyToUse = true;
            }
            if(_particleIdling.parent)
            {
               _particleIdling.parent.removeChild(_particleIdling);
            }
            _particleIdling = null;
         }
      }
      
      public function updateSpecialPatternColors() : void
      {
         if(_avatar && _avatar.colors)
         {
            _currSpecialPatternColors = PaletteHelper.getHexColorsFromPalette(_avatar.colors[1]);
         }
      }
      
      public function updateSpecialPatternColorsAndApply() : void
      {
         var _loc1_:Loader = null;
         if(_avatar && _avatar.colors)
         {
            _currSpecialPatternColors = PaletteHelper.getHexColorsFromPalette(_avatar.colors[1]);
            if(_particleIdling)
            {
               _loc1_ = _particleIdling.getChildAt(0) as Loader;
               setupSpecialPattern(_loc1_.content as MovieClip);
            }
         }
      }
      
      public function updateNameBarLevelShape(param1:int) : void
      {
         var _loc2_:UserInfo = null;
         if(_namebar != null)
         {
            if(_shouldShowPetOnly)
            {
               param1 = 0;
               _namebar.removeShape();
            }
            else
            {
               _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
               if(_loc2_ || gMainFrame.clientInfo.roomType == 7 || gMainFrame.clientInfo.roomType == 8)
               {
                  _namebar.setColorBadgeAndXp(_loc2_ ? _loc2_.nameBarData : 0,param1,_isMember,gMainFrame.clientInfo.roomType == 7 || gMainFrame.clientInfo.roomType == 8);
               }
            }
         }
      }
      
      public function updateNameBarHealth(param1:int) : void
      {
         if(_namebar != null)
         {
            _namebar.updateMeter(param1);
         }
      }
      
      public function getNameBarHealthPercentage() : int
      {
         if(_namebar != null)
         {
            return _namebar.getMeterValue();
         }
         return 100;
      }
      
      public function setBlendColor(param1:uint = 0, param2:uint = 4294967295, param3:Boolean = false) : void
      {
         var _loc4_:Array = null;
         if(_layerAnim == null || _layerAnim.bitmap == null)
         {
            return;
         }
         if(param2 == 4294967295)
         {
            if(param1 == 0 || param3)
            {
               param2 = uint(_roomType == 0 ? 5586479 : 2775381);
            }
            else
            {
               param2 = uint(param1 & 0xFFFFFF);
            }
         }
         if(_layerAnim.bitmap.filters != null && _layerAnim.bitmap.filters[0].color != param2)
         {
            _loc4_ = _layerAnim.bitmap.filters;
            _loc4_[0].color = param2;
            _layerAnim.bitmap.filters = _loc4_;
         }
         _layerAnim.bitmap.setBlendColor(param1);
      }
      
      public function setAlphaLevel(param1:int) : void
      {
         if(gMainFrame.clientInfo.invisMode && userId == AvatarManager.playerSfsUserId)
         {
            param1 = 50;
         }
         var _loc2_:Number = param1 / 100;
         this.alpha = _loc2_;
      }
      
      public function isSameMessage(param1:String) : Boolean
      {
         if(_chatBalloon)
         {
            if(_chatBalloon.visible)
            {
               return _chatBalloon.msgTxt.text == param1;
            }
         }
         return false;
      }
      
      public function setMessage(param1:String, param2:int) : void
      {
         var _loc3_:Boolean = false;
         if(param2 > 1)
         {
            if(param2 == 2)
            {
               param1 = LocalizationManager.translateIdOnly(int(param1.split("|")[0]));
            }
            _loc3_ = true;
         }
         _chatBalloon.setText(param1,_loc3_);
         updateOffScreenChat(param1,_loc3_);
      }
      
      public function setCustomAdventureMessage(param1:String, param2:String, param3:int, param4:int, param5:Boolean = false) : void
      {
         var _loc6_:Boolean = false;
         if(gMainFrame.userInfo.isModerator && param4 > 1)
         {
            _loc6_ = true;
         }
         _chatBalloon.setCustomAdventureMessage(param1,param2,param3,_loc6_,param5);
         if(_chatBalloon.visible && _chatBalloon.isPvpCustom)
         {
            loadCustomPVPImage(_chatBalloon.pvpGameId);
         }
      }
      
      private function loadCustomPVPImage(param1:int) : void
      {
         var _loc2_:MinigameInfo = null;
         if(param1 != 0)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(param1);
            _customPVPImageLoader = new MediaHelper();
            _customPVPImageLoader.init(_loc2_.gameCardMediaId,onCustomPVPImageLoaded);
         }
      }
      
      private function onCustomPVPImageLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            if(_customPVPImageLoader)
            {
               _customPVPImageLoader.destroy();
               _customPVPImageLoader = null;
            }
            _loc2_ = param1.height;
            param1.scaleX = param1.scaleY = 0.5;
            if(_chatBalloon)
            {
               _chatBalloon.setCustomPVPImage(param1);
            }
         }
      }
      
      public function setEmote(param1:Sprite, param2:int = -1) : void
      {
         if(param1 || param2 >= 0)
         {
            _chatBalloon.setEmote(param1,param2);
         }
         else
         {
            _chatBalloon.setReadyForClear();
         }
      }
      
      public function setChatBalloonReadyForClear() : void
      {
         _chatBalloon.setReadyForClear();
      }
      
      public function updateChatBallonBgOffsets() : void
      {
         _chatBalloon.updateEmoteBgOffsets();
      }
      
      public function getPermEmoteId() : int
      {
         if(_chatBalloon)
         {
            return _chatBalloon.perEmoteMediaId;
         }
         return -1;
      }
      
      public function setAction(param1:Sprite) : void
      {
         var _loc4_:int = 0;
         if(!_actionMgr)
         {
            return;
         }
         _lastIdleAnim = getBaseIdle();
         _lastIdleFlip = false;
         var _loc2_:String = _actionMgr.getActionString(param1);
         for each(var _loc3_:Object in _actionLookup)
         {
            if(_loc3_.name == _loc2_)
            {
               _loc4_ = int(_roomType == 0 ? _loc3_.land : _loc3_.water);
               if(_loc4_ > 0)
               {
                  _lastIdleAnim = _loc4_;
                  _lastIdleFlip = _loc3_.flip;
                  playAnim(_loc4_,_loc3_.flip);
               }
               break;
            }
         }
      }
      
      public function circleTest(param1:int, param2:int, param3:int) : Boolean
      {
         return Collision.circleHitCircle(new Point(param1,param2),param3,new Point(_pos.x,_pos.y),_radius);
      }
      
      public function bmpDataHitTest(param1:BitmapData, param2:Point) : Boolean
      {
         return param1.hitTest(new Point(_pos.x,_pos.y),255,param1,param2,255);
      }
      
      public function moveToFront() : void
      {
         if(!parent || !_chatLayer)
         {
            return;
         }
         parent.setChildIndex(this,parent.numChildren - 1);
         if(_chatBalloon.parent == _chatLayer)
         {
            _chatLayer.setChildIndex(_chatBalloon,_chatLayer.numChildren - 1);
         }
         if(_secondaryEmot)
         {
            if(_secondaryEmot.parent == _chatLayer)
            {
               _chatLayer.setChildIndex(_secondaryEmot,_chatLayer.numChildren - 1);
            }
            _secondaryEmot.scaleX = _secondaryEmot.scaleY = 1;
         }
      }
      
      public function setAvAttachment(param1:int, param2:String) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:FrameLabel = null;
         _avAttMediaId = param1;
         if(param1 == 0)
         {
            if(_secondaryEmot && _isLoadingEmoteId == -1)
            {
               _secondaryEmot.attachment.gotoAndPlay("_hide");
               if(_secondaryEmot["getAttachedSound"] && _secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.stopItemEmoticonSound(this);
               }
            }
         }
         else
         {
            if(_secondaryEmot && _isLoadingEmoteId == -1 && _secondaryEmot.id != param1)
            {
               _secondaryEmot.attachment.gotoAndPlay("_hide");
               if(_secondaryEmot["getAttachedSound"] && _secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.stopItemEmoticonSound(this);
               }
            }
            if(_secondaryEmot != null && (_secondaryEmot.id == param1 && _avAttachmentExtra == param2) || _isLoadingEmoteId == param1)
            {
               if(_secondaryEmot && _secondaryEmot.attachment)
               {
                  _loc4_ = int(_secondaryEmot.attachment.currentLabels.length);
                  _loc5_;
                  while(_loc5_ < _loc4_)
                  {
                     _loc3_ = _secondaryEmot.attachment.currentLabels[_loc5_];
                     if(_loc3_.name == "_main")
                     {
                        _secondaryEmot.attachment.gotoAndStop("_main");
                        return;
                     }
                     _loc5_++;
                  }
                  _secondaryEmot.attachment.gotoAndStop("_show");
               }
               return;
            }
            _avAttachmentExtra = param2;
            _isLoadingEmoteId = param1;
            if(!_avAttMediaHelper)
            {
               _avAttMediaHelper = new MediaHelper();
            }
            _avAttMediaHelper.init(param1,onAttachLoaded);
         }
      }
      
      private function setOffScreenAvAttachment(param1:MovieClip, param2:int) : void
      {
         var _loc4_:MovieClip = AvatarManager.getOffScreenAttachmentBySfsId(param2);
         var _loc3_:int = int(param1.attachmentId);
         if(_loc3_ == 0)
         {
            if(_loc4_)
            {
               if(_loc4_.attachment.currentFrameLabel == "_gone")
               {
                  while(param1.charLayer.numChildren > 0)
                  {
                     param1.charLayer.removeChildAt(0);
                  }
                  if(param1.avtView)
                  {
                     param1.charLayer.addChild(param1.avtView);
                  }
               }
               else
               {
                  _loc4_.attachment.gotoAndPlay("_hide");
               }
               AvatarManager.setOffScreenAttachmentBySfsId(param2,_loc4_);
            }
            else if(param1.avtView && !param1.charLayer.contains(param1.avtView))
            {
               param1.charLayer.addChild(param1.avtView);
            }
         }
         else
         {
            if(_loc4_ != null && (_loc4_.id == _loc3_ || _loc4_.isLoadingEmoteId == _loc3_))
            {
               if(!param1.charLayer.contains(_loc4_))
               {
                  while(param1.charLayer.numChildren > 0)
                  {
                     param1.charLayer.removeChildAt(0);
                  }
                  param1.charLayer.addChild(_loc4_);
               }
               return;
            }
            param1.isLoadingEmoteId = _loc3_;
            AvatarManager.setViewHudMCBySfsId(param2,param1);
            if(!_avOffscreenMediaHelper)
            {
               _avOffscreenMediaHelper = new MediaHelper();
            }
            _avOffscreenMediaHelper.init(_loc3_,onOffscreenAttachLoaded,{
               "offscreenMC":param1,
               "sfsId":param2
            });
         }
      }
      
      private function onOffscreenAttachLoaded(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = param1.passback.offscreenMC;
         if(param1 && param1.hasOwnProperty("attachment"))
         {
            while(_loc3_.charLayer.numChildren > 0)
            {
               _loc3_.charLayer.removeChildAt(0);
            }
            _loc2_ = param1;
            _loc2_.id = _loc3_.isLoadingEmoteId;
            _loc3_.charLayer.addChild(_loc2_);
            _loc2_.scaleX = _loc2_.scaleY = 0.5;
            _loc2_.x = -355 * _loc2_.scaleX;
            _loc2_.y = -235 * _loc2_.scaleX;
            _loc2_.attachment.gotoAndPlay("_show");
            AvatarManager.setOffScreenAttachmentBySfsId(param1.passback.sfsId,_loc2_);
         }
      }
      
      private function emoteLoader(param1:int, param2:Function = null) : void
      {
         _emoteMediaHelper = new MediaHelper();
         _emoteMediaHelper.init(param1,param2);
      }
      
      private function onAttachLoaded(param1:MovieClip) : void
      {
         if(param1 && param1.hasOwnProperty("attachment") && _avAttMediaId)
         {
            if(_avAttachmentExtra && _avAttachmentExtra.length)
            {
               param1.setState(_avAttachmentExtra);
            }
            if(_chatLayer)
            {
               if(_secondaryEmot && _chatLayer.contains(_secondaryEmot))
               {
                  _chatLayer.removeChild(_secondaryEmot);
               }
               _secondaryEmot = param1;
               _secondaryEmot.id = _isLoadingEmoteId;
               if(isOffScreen)
               {
                  if(_hudViewHolder.charLayer.contains(_hudAvtOrPetView))
                  {
                     _hudViewHolder.charLayer.removeChild(_hudAvtOrPetView);
                  }
                  _hudViewHolder.charLayer.addChild(_secondaryEmot);
                  updateSecondaryEmoteOffScreenPosition();
                  _secondaryEmot.lastKnownX = this.x + -310;
                  _secondaryEmot.lastKnownY = this.y + -320;
               }
               else
               {
                  _secondaryEmot.x = this.x + -310;
                  _secondaryEmot.y = this.y + -320;
                  _secondaryEmot.scaleX = _secondaryEmot.scaleY = 1;
                  _chatLayer.addChild(_secondaryEmot);
               }
               _secondaryEmot.attachment.gotoAndPlay("_show");
               if(_secondaryEmot["getAttachedSound"] && _secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.playItemEmoticonSound(this,_secondaryEmot.getAttachedSound());
               }
            }
         }
         _isLoadingEmoteId = -1;
      }
      
      public function checkSelnub(param1:MouseEvent) : void
      {
         var _loc2_:Number = Point.distance(this.localToGlobal(new Point(0,0)),new Point(gMainFrame.stage.mouseX,gMainFrame.stage.mouseY));
         if(_loc2_ < 150)
         {
            overHandler(param1);
         }
         else
         {
            outHandler(param1);
         }
      }
      
      public function heartbeat(param1:int, param2:int) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc19_:Number = NaN;
         var _loc14_:MovieClip = null;
         var _loc11_:int = 0;
         var _loc5_:Loader = null;
         var _loc28_:Loader = null;
         var _loc23_:* = null;
         var _loc25_:* = null;
         var _loc20_:Object = null;
         var _loc24_:int = 0;
         var _loc8_:Dictionary = null;
         var _loc27_:Point = null;
         var _loc21_:MovieClip = null;
         var _loc26_:Point = null;
         var _loc10_:Point = null;
         var _loc16_:int = 0;
         var _loc12_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:Rectangle = null;
         var _loc17_:UserInfo = null;
         if(_slideCurrentPosition >= 0)
         {
            updateSlide(param1);
         }
         _frameTime = param2 / 1000;
         _timeSinceLastHostingUpdate += _frameTime;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         var _loc13_:int = 1;
         _splash.heartbeat(_bInSplashVolume,isSplashAnim(),_splashLiquid,avatarData != null && (avatarData.enviroTypeFlag & 1 << 2) != 0);
         if(!_bInSplashVolume && _emitParticles)
         {
            if(_moving == 1)
            {
               if(_particleIdling)
               {
                  _particleIdling.visible = false;
               }
               _loc3_ = true;
               _loc19_ = _loc3_ ? 0.1 : 0.05;
               if(_timeSinceLastParticle < 0 || _timeSinceLastParticle > _loc19_)
               {
                  _loc14_ = AvatarManager.getFlower();
                  if(_loc3_)
                  {
                     _loc14_.x = x - 20;
                     _loc14_.y = y;
                     _loc14_.scaleX = 0.22;
                     _loc14_.scaleY = 0.13;
                     if(_lastParticleLoc)
                     {
                        _lastParticleLoc.x = _loc14_.x - _lastParticleLoc.x;
                        _lastParticleLoc.y = _loc14_.y - _lastParticleLoc.y;
                        _lastParticleLoc.normalize(1);
                        _loc11_ = 5;
                        _loc14_.x -= _loc11_ * _particleOffset * _lastParticleLoc.y;
                        _loc14_.y += _loc11_ * _particleOffset * _lastParticleLoc.x;
                        _particleOffset *= -1;
                        _lastParticleLoc.x = x - 20;
                        _lastParticleLoc.y = y;
                     }
                     else
                     {
                        _loc14_.visible = false;
                        _lastParticleLoc = new Point(_loc14_.x,_loc14_.y);
                     }
                  }
                  else
                  {
                     _loc14_.x = x - 55;
                     _loc14_.y = y - 80;
                     _loc14_.scaleX = _loc14_.scaleY = 0.5;
                  }
                  _loc5_ = _loc14_.getChildAt(0) as Loader;
                  if(_loc5_.content == null)
                  {
                     _loc5_.contentLoaderInfo.addEventListener("complete",flowerLoaderComplete);
                  }
                  else
                  {
                     resetFlower(_loc5_.content as MovieClip);
                  }
                  _timeSinceLastParticle = 0;
               }
               _timeSinceLastParticle += _frameTime;
            }
            else
            {
               if(_particleIdling)
               {
                  if(!_particleIdling.visible)
                  {
                     _particleIdling.visible = true;
                     _loc28_ = _particleIdling.getChildAt(0) as Loader;
                     (_loc28_.content as MovieClip).animate();
                  }
               }
               else
               {
                  _particleIdling = AvatarManager.getFlower(true);
                  _loc28_ = _particleIdling.getChildAt(0) as Loader;
                  if(_loc28_.content)
                  {
                     setupSpecialPattern(_loc28_.content as MovieClip);
                  }
                  else
                  {
                     _loc28_.contentLoaderInfo.addEventListener("complete",flowerIdleLoaderComplete);
                  }
               }
               _particleIdling.x = x - 30;
               _particleIdling.y = y - 15;
            }
         }
         var _loc7_:Number = _pos.x;
         var _loc6_:Number = _pos.y;
         var _loc22_:Number = _dirX * 24 * _loc13_ * _frameTime / 0.07;
         var _loc18_:Number = _dirY * 24 * _loc13_ * _frameTime / 0.07;
         if(_dirX || _dirY)
         {
            checkSelnub(null);
         }
         if(_loc22_)
         {
            if(_loc22_ > 0 && _loc22_ + _pos.x >= _moveToX || _loc22_ < 0 && _loc22_ + _pos.x <= _moveToX)
            {
               _dirX = 0;
               _loc7_ = _moveToX;
            }
            else
            {
               _loc7_ += _loc22_;
            }
         }
         if(_loc18_)
         {
            if(_loc18_ > 0 && _loc18_ + _pos.y >= _moveToY || _loc18_ < 0 && _loc18_ + _pos.y <= _moveToY)
            {
               _dirY = 0;
               _loc6_ = _moveToY;
            }
            else
            {
               _loc6_ += _loc18_;
            }
         }
         if(_loc7_ != _pos.x || _loc6_ != _pos.y || gMainFrame.clientInfo.roomType == 7)
         {
            _numFramesForOffscreen = _numFramesForOffscreen + 1;
            updatePos(_loc7_,_loc6_);
            _loc20_ = AvatarManager.getOffScreenMap();
            for(var _loc15_:String in _loc20_)
            {
               _loc24_ = int(_loc15_);
               if(AvatarManager.avatarList[_loc15_] == null)
               {
                  _loc8_ = AvatarManager.getOffScreenMapBySfsId(_loc24_);
                  _loc27_ = _loc8_[gMainFrame.server.getCurrentRoomName(false)];
                  _loc21_ = AvatarManager.getViewHudMCBySfsId(_loc24_);
                  if(_loc21_)
                  {
                     if(_loc27_)
                     {
                        _loc26_ = RoomManagerWorld.instance.bkgScalePoint();
                        _loc10_ = RoomManagerWorld.instance.convertWorldToScreen(_loc27_.x * _loc26_.x,_loc27_.y * _loc26_.y);
                        _loc16_ = _loc21_.mouse.height * 0.5 * _loc26_.x;
                        _loc12_ = _loc21_.mouse.width * 0.5 * _loc26_.y;
                        _loc4_ = 73.5 * _loc26_.y;
                        _loc9_ = new Rectangle(0,0,900 - _loc12_,550 - _loc16_ - _loc4_ + _radius * 2 * _loc26_.x);
                        if(!_loc9_.containsPoint(_loc10_))
                        {
                           if(_loc21_.parent == null)
                           {
                              GuiManager.guiLayer.addChild(_loc21_);
                           }
                           if(_loc21_.avtView == null)
                           {
                              if(_loc21_.charLayer.numChildren > 0)
                              {
                                 _loc21_.avtView = _loc21_.charLayer.getChildAt(0);
                              }
                           }
                           _loc21_.visible = true;
                           updateScreenPositionAndDirection(_loc21_,_loc9_,_loc10_);
                           _loc21_.x = _loc10_.x;
                           _loc21_.y = _loc10_.y;
                           _loc21_.questChatBalloon.heartbeat(param1);
                           if(_numFramesForOffscreen >= 48 && _loc21_.avtView != null)
                           {
                              if(_loc21_.charLayer.contains(_loc21_.avtView))
                              {
                                 setOffScreenAvAttachment(_loc21_,_loc24_);
                              }
                              else
                              {
                                 while(_loc21_.charLayer.numChildren > 0)
                                 {
                                    _loc21_.charLayer.removeChildAt(0);
                                 }
                                 _loc21_.charLayer.addChild(_loc21_.avtView);
                              }
                           }
                        }
                        else
                        {
                           _loc21_.visible = false;
                        }
                     }
                     else if(_loc21_.parent != null && _loc21_.parent == GuiManager.guiLayer)
                     {
                        GuiManager.guiLayer.addChild(_loc21_);
                     }
                  }
               }
            }
         }
         _chatBalloon.heartbeat(param1);
         offScreenChatHeartbeat(param1);
         if(_secondaryEmot && _secondaryEmot.attachment)
         {
            if(_secondaryEmot.attachment.currentFrameLabel == "_gone")
            {
               if(_secondaryEmot.parent && _secondaryEmot.parent is MovieClip)
               {
                  _secondaryEmot.parent.removeChild(_secondaryEmot);
               }
               _secondaryEmot = null;
            }
            else if(isOffScreen && _numFramesForOffscreen >= 48)
            {
               if(_hudViewHolder.charLayer.contains(_hudAvtOrPetView))
               {
                  while(_hudViewHolder.charLayer.numChildren > 0)
                  {
                     _hudViewHolder.charLayer.removeChildAt(0);
                  }
                  updateSecondaryEmoteOffScreenPosition();
                  _hudViewHolder.charLayer.addChild(_secondaryEmot);
               }
               else if(_hudViewHolder.charLayer.contains(_secondaryEmot))
               {
                  while(_hudViewHolder.charLayer.numChildren > 0)
                  {
                     _hudViewHolder.charLayer.removeChildAt(0);
                  }
                  _hudViewHolder.charLayer.addChild(_hudAvtOrPetView);
               }
            }
         }
         else if(_hudViewHolder && _hudAvtOrPetView && !_hudViewHolder.charLayer.contains(_hudAvtOrPetView))
         {
            while(_hudViewHolder.charLayer.numChildren > 0)
            {
               _hudViewHolder.charLayer.removeChildAt(0);
            }
            _hudViewHolder.charLayer.addChild(_hudAvtOrPetView);
         }
         if(_numFramesForOffscreen >= 48)
         {
            _numFramesForOffscreen = 0;
         }
         if(!_dirX && !_dirY)
         {
            if(_deleteOnMoveComplete)
            {
               return false;
            }
            switch(_moving - -1)
            {
               case 0:
                  playAnim(_lastIdleAnim,_lastIdleFlip);
                  _moving = 0;
                  if(isSelf)
                  {
                     RoomManagerWorld.instance.resetThrottle();
                  }
                  break;
               case 2:
                  if(_followPath)
                  {
                     followPath();
                  }
                  else if(_layerAnim.bounceEnabled)
                  {
                     if(isSelf)
                     {
                        RoomManagerWorld.instance.resetThrottle();
                        _moving = 0;
                     }
                  }
                  else
                  {
                     _moving = -1;
                  }
            }
         }
         if(_pet)
         {
            _pet.heartbeat(_layerAnim.bounceOffSet);
         }
         if(_timeSinceLastHostingUpdate >= 10)
         {
            _loc17_ = gMainFrame.userInfo.getUserInfoByUserName(userName);
            if(_loc17_)
            {
               _namebar.isHostingCustomParty = _loc17_.isStillHosting;
            }
            _timeSinceLastHostingUpdate = 0;
         }
         return true;
      }
      
      private function setupSpecialPattern(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_currSpecialPatternColors == null)
            {
               updateSpecialPatternColors();
            }
            param1.setColors(_currSpecialPatternColors);
            param1.animate();
            param1.readyToUse = false;
         }
      }
      
      private function flowerIdleLoaderComplete(param1:Event) : void
      {
         setupSpecialPattern(param1.target.content);
      }
      
      private function flowerLoaderComplete(param1:Event) : void
      {
         resetFlower(param1.target.content);
      }
      
      private function resetFlower(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_currSpecialPatternColors == null)
            {
               updateSpecialPatternColors();
            }
            param1.setColor(_currSpecialPatternColors[_patternIndex]);
            param1.animate();
            _patternIndex = _patternIndex + 1 == _currSpecialPatternColors.length ? 0 : _patternIndex + 1;
         }
      }
      
      public function playIdle() : void
      {
         _slideCurrentPosition = -1;
         playAnim(getBaseIdle(),_lastIdleFlip);
      }
      
      public function setActivePet(param1:uint, param2:uint, param3:uint, param4:String, param5:int = 0) : void
      {
         if(_pet)
         {
            if(_pet.parent == this)
            {
               this.removeChild(_pet);
            }
            _pet = null;
         }
         if(gMainFrame.clientInfo.roomType != 7 || _shouldShowPetOnly)
         {
            if(param1 != 0 && PetManager.canCurrAvatarUsePet(_avatar.enviroTypeFlag,PetManager.petTypeForDefId(param1 & 0xFF)))
            {
               _pet = new WorldPet(this,param1,param2,param3,param5);
            }
            if(_shouldShowPetOnly)
            {
               if(!isActivePetGroundPet())
               {
                  _splash.showShadow(false);
               }
               _currPetName = LocalizationManager.translatePetName(param4);
               _namebar.setAvName(_currPetName);
            }
            else
            {
               _splash.showShadow(true);
            }
         }
      }
      
      public function getActivePet() : WorldPet
      {
         return _pet;
      }
      
      public function isActivePetGroundPet() : Boolean
      {
         if(_pet)
         {
            return _pet.isGround();
         }
         return true;
      }
      
      public function flipSplash(param1:Boolean) : void
      {
         _splash.flipSplash(param1);
      }
      
      public function isSplashAnim() : Boolean
      {
         return !(_layerAnim.animId == 14 || _layerAnim.animId == 16);
      }
      
      public function isPetMovingTest() : Boolean
      {
         return !(_layerAnim.animId == 14 || _layerAnim.animId == 16 || _layerAnim.animId == 3 || _layerAnim.animId == 2 || _layerAnim.animId == 1 || _layerAnim.animId == 4 || _layerAnim.animId == 5 || _layerAnim.animId == 6 || _layerAnim.animId == 22 || _layerAnim.animId == 32 || _layerAnim.animId == 40 || _layerAnim.animId == 33);
      }
      
      public function inSplashVolume() : Boolean
      {
         return _bInSplashVolume;
      }
      
      public function updateIsHostingCustomParty(param1:Boolean) : void
      {
         if(_namebar)
         {
            _namebar.isHostingCustomParty = param1;
         }
      }
      
      private function initNamebar(param1:int) : void
      {
         _isMember = Utility.isMember(param1);
         if(_isMember || _isGuide)
         {
            _namebar = GETDEFINITIONBYNAME("memberNameBar");
         }
         else
         {
            _namebar = GETDEFINITIONBYNAME("FreeNameBar");
         }
         _timeSinceLastHostingUpdate = 0;
         _namebar.x = -15;
         _namebar.y = 18;
         addChild(_namebar);
      }
      
      private function setNamebarListenersWithUserName(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1 != gMainFrame.server.userName || Boolean(gMainFrame.userInfo.isModerator))
         {
            _namebar.addEventListener("mouseDown",namebarAndAvatarDownHandler,false,0,true);
            _namebar["selnub"].addEventListener("mouseDown",namebarAndAvatarDownHandler,false,0,true);
         }
         else
         {
            _namebar.removeListeners();
         }
      }
      
      public function toggleNamebarSelNub(param1:int = -1) : void
      {
         var _loc2_:int = 0;
         if(_isGuide)
         {
            _namebar.setNubType(NameBar.GUIDE);
         }
         else
         {
            if(param1 == -1)
            {
               _loc2_ = _namebar.packedNameBarData;
            }
            else
            {
               _loc2_ = param1;
            }
            if(BuddyManager.isBuddy(_avatar.userName) || isSelf || _isMember && NameBar.isVIPBadge(_loc2_))
            {
               _namebar.setNubType(NameBar.BUDDY);
            }
            else
            {
               _namebar.setNubType(NameBar.NON_BUDDY);
            }
         }
         if(!isSelf)
         {
            if(BuddyManager.isBlocked(_avatar.userName))
            {
               _namebar.isBlocked = true;
            }
            else
            {
               _namebar.isBlocked = false;
            }
         }
         else
         {
            _namebar.isBlocked = false;
         }
      }
      
      private function get isSelf() : Boolean
      {
         if(userName)
         {
            return userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase();
         }
         return false;
      }
      
      private function followPath() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = int(_followPath.length);
         if(_loc2_)
         {
            _loc1_ = _followPath[0];
            if(_loc2_ > 1)
            {
               _followPath.splice(0,1);
            }
            else
            {
               _followPath = null;
            }
            setPos(_loc1_.x,_loc1_.y,true,false);
         }
      }
      
      private function updatePos(param1:Number, param2:Number) : void
      {
         _pos.x = param1;
         _pos.y = param2;
         param1 *= _scale.x;
         param2 *= _scale.y;
         this.x = param1;
         this.y = param2;
         var _loc3_:Point = AvatarUtility.getAvatarChatOffset(_avatar.avTypeId);
         _chatBalloon.x = this.x + _loc3_.x;
         _chatBalloon.y = this.y + _loc3_.y;
         if(_secondaryEmot)
         {
            if(!isOffScreen)
            {
               _secondaryEmot.x = this.x + -310;
               _secondaryEmot.y = this.y + -320;
            }
            else
            {
               _secondaryEmot.lastKnownX = this.x + -310;
               _secondaryEmot.lastKnownY = this.y + -320;
            }
         }
         if(gMainFrame.clientInfo.roomType == 7 && gMainFrame.userInfo.myUserName != _avatar.userName)
         {
            updateOffScreenPositions();
         }
      }
      
      public function updateOffScreenPositions() : void
      {
         var _loc1_:AvatarInfo = null;
         if(!_hudViewHolder)
         {
            _hudViewHolder = GETDEFINITIONBYNAME("offScreenIconQuest");
            _hudViewHolder.mouse.gotoAndStop("up");
            _hudViewHolder.questChatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,7,SBTextField);
            if(_flashTimer)
            {
               _flashTimer.reset();
            }
            _flashTimer = new Timer(2500);
            _flashTimer.addEventListener("timer",onFlashTimer,false,0,true);
            AvatarManager.setViewHudMCBySfsId(userId,_hudViewHolder);
         }
         var _loc4_:Point = RoomManagerWorld.instance.bkgScalePoint();
         var _loc5_:Point = RoomManagerWorld.instance.convertWorldToScreen(this.x * _loc4_.x,this.y * _loc4_.y);
         var _loc7_:int = _hudViewHolder.mouse.height * 0.5 * _loc4_.x;
         var _loc6_:int = _hudViewHolder.mouse.width * 0.5 * _loc4_.y;
         var _loc3_:int = 73.5 * _loc4_.y;
         var _loc2_:Rectangle = new Rectangle(0,0,900 - _loc6_,550 - _loc7_ - _loc3_ + _radius * 2 * _loc4_.x);
         if(!_loc2_.containsPoint(_loc5_))
         {
            updateScreenPositionAndDirection(_hudViewHolder,_loc2_,_loc5_);
            if(!isOffScreen)
            {
               if(_hudViewHolder.mouse.currentFrameLabel != "up")
               {
                  _hudViewHolder.mouse.gotoAndStop("up");
               }
               if(GuiManager.isBeYourPetRoom())
               {
                  _loc1_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(userName,perUserAvId);
                  _hudAvtOrPetView = new GuiPet(0,_loc1_.currPet.lBits,_loc1_.currPet.uBits,_loc1_.currPet.eBits,_loc1_.currPet.type,_loc1_.currPet.name,onHudAvtOrPetView);
               }
               else
               {
                  _hudAvtOrPetView = new AvatarView();
                  _hudAvtOrPetView.init(_avatar);
                  _hudAvtOrPetView.playAnim(15,false,1,onHudAvtOrPetView);
                  _hudAvtOrPetView.avTypeChangedCallback = updateHudViewPosition;
               }
               this.visible = false;
               isOffScreen = true;
               _hudViewHolder.visible = true;
               _chatLayer.removeChild(_chatBalloon);
               if(_secondaryEmot)
               {
                  _chatLayer.removeChild(_secondaryEmot);
               }
            }
            _hudViewHolder.x = _loc5_.x;
            _hudViewHolder.y = _loc5_.y;
         }
         else if(isOffScreen || _hudViewHolder.visible)
         {
            if(_hudViewHolder.mouse.currentFrameLabel != "up")
            {
               _hudViewHolder.mouse.gotoAndStop("up");
            }
            if(_hudViewHolder && _hudViewHolder.parent && _hudViewHolder.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_hudViewHolder);
            }
            _hudViewHolder.visible = false;
            isOffScreen = false;
            this.visible = true;
            _chatLayer.addChild(_chatBalloon);
            if(_secondaryEmot)
            {
               _chatLayer.addChild(_secondaryEmot);
               _secondaryEmot.x = _secondaryEmot.lastKnownX;
               _secondaryEmot.y = _secondaryEmot.lastKnownY;
               _secondaryEmot.scaleX = _secondaryEmot.scaleY = 1;
            }
            if(lastAnimToHappen != -1)
            {
               playAnim(lastAnimToHappen,_lastIdleFlip);
               lastAnimToHappen = -1;
            }
            else
            {
               playAnim(_lastIdleAnim,_lastIdleFlip);
            }
         }
      }
      
      private function updateOffScreenItemsForOthers(param1:MovieClip, param2:Point) : void
      {
      }
      
      private function onHudAvtOrPetView(param1:Object, param2:Object) : void
      {
         updateHudViewPosition();
         while(_hudViewHolder.charLayer.numChildren > 0)
         {
            _hudViewHolder.charLayer.removeChildAt(0);
         }
         if(param2 is GuiPet)
         {
            (param2 as GuiPet).animatePet(false);
         }
         _hudViewHolder.charLayer.addChild(_hudAvtOrPetView);
         GuiManager.guiLayer.addChild(_hudViewHolder);
      }
      
      private function updateHudViewPosition() : void
      {
         var _loc2_:Point = null;
         var _loc1_:Number = NaN;
         if(GuiManager.isBeYourPetRoom())
         {
            _hudAvtOrPetView.y = 15;
         }
         else
         {
            _loc2_ = AvatarUtility.getAvatarHudPosition(_hudAvtOrPetView.avTypeId);
            _hudAvtOrPetView.scaleX = _hudAvtOrPetView.scaleY = 1;
            _loc1_ = 41 / _hudAvtOrPetView.width;
            if(_hudAvtOrPetView.height * _loc1_ > 41)
            {
               _loc1_ = 41 / _hudAvtOrPetView.height;
            }
            _hudAvtOrPetView.scaleX = _loc1_;
            _hudAvtOrPetView.scaleY = _loc1_;
            _hudAvtOrPetView.x = _loc2_.x * _loc1_;
            _hudAvtOrPetView.y = _loc2_.y * _loc1_;
         }
      }
      
      private function updateSecondaryEmoteOffScreenPosition() : void
      {
         _secondaryEmot.scaleX = _secondaryEmot.scaleY = 1;
         var _loc1_:Number = 0.5;
         _secondaryEmot.scaleX = _loc1_;
         _secondaryEmot.scaleY = _loc1_;
         _secondaryEmot.x = -355 * _loc1_;
         _secondaryEmot.y = -235 * _loc1_;
      }
      
      private function updateOffScreenChat(param1:String, param2:Boolean) : void
      {
         if(gMainFrame.clientInfo.roomType == 7 && gMainFrame.userInfo.myUserName != _avatar.userName && _hudViewHolder)
         {
            _hudViewHolder.questChatBalloon.setText(param1,param2,false);
         }
      }
      
      private function offScreenChatHeartbeat(param1:int) : void
      {
         if(gMainFrame.clientInfo.roomType == 7 && gMainFrame.userInfo.myUserName != _avatar.userName && _hudViewHolder)
         {
            _hudViewHolder.questChatBalloon.heartbeat(param1);
         }
      }
      
      public function faceAnim(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         var _loc9_:Number = Math.atan2(param2,param1);
         var _loc6_:Number = 0.3141592653589793;
         var _loc8_:Number = 0.6283185307179586;
         _lastMoveAngle = _loc9_;
         var _loc5_:Object = convertToIdle(_lastMoveAngle);
         _lastIdleAnim = _loc5_.anim;
         if(_roomType == 1)
         {
            _lastIdleAnim = getBaseIdle();
         }
         _lastIdleFlip = _loc5_.flip;
         var _loc10_:int = 0;
         var _loc4_:Boolean = false;
         if(_loc9_ >= 5 * _loc8_ - _loc6_ || _loc9_ < -5 * _loc8_ + _loc6_)
         {
            _loc10_ = 2;
            _loc4_ = true;
         }
         else if(_loc9_ >= -4 * _loc8_ - _loc6_ && _loc9_ < -4 * _loc8_ + _loc6_)
         {
            _loc10_ = 1;
            _loc4_ = true;
         }
         else if(_loc9_ >= -3 * _loc8_ - _loc6_ && _loc9_ < -3 * _loc8_ + _loc6_)
         {
            _loc10_ = 0;
            _loc4_ = true;
         }
         else if(_loc9_ >= -2 * _loc8_ - _loc6_ && _loc9_ < -2 * _loc8_ + _loc6_)
         {
            _loc10_ = 0;
         }
         else if(_loc9_ >= -_loc8_ - _loc6_ && _loc9_ < -_loc8_ + _loc6_)
         {
            _loc10_ = 1;
         }
         else if(_loc9_ >= -_loc6_ && _loc9_ < _loc6_)
         {
            _loc10_ = 2;
         }
         else if(_loc9_ >= _loc8_ - _loc6_ && _loc9_ < _loc8_ + _loc6_)
         {
            _loc10_ = 3;
         }
         else if(_loc9_ >= 2 * _loc8_ - _loc6_ && _loc9_ < 2 * _loc8_ + _loc6_)
         {
            _loc10_ = 4;
         }
         else if(_loc9_ >= 3 * _loc8_ - _loc6_ && _loc9_ < 3 * _loc8_ + _loc6_)
         {
            _loc10_ = 4;
            _loc4_ = true;
         }
         else
         {
            _loc10_ = 3;
            _loc4_ = true;
         }
         var _loc7_:int = 7 + _loc10_;
         if(!param3)
         {
            switch(_loc10_)
            {
               case 0:
               case 1:
                  _loc7_ = 16;
                  break;
               case 2:
               case 3:
               case 4:
                  _loc7_ = 14;
            }
         }
         if(_roomType == 1)
         {
            _loc7_ = 29;
         }
         if(_layerAnim.bounceEnabled)
         {
            _loc7_ = 17;
         }
         playAnim(_loc7_,_loc4_,2);
      }
      
      public function updateNameBarName() : void
      {
         var _loc1_:UserInfo = null;
         if(_namebar)
         {
            _loc1_ = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
            _namebar.setAvName(_avatar,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_loc1_);
         }
      }
      
      override protected function avatarChanged(param1:AvatarEvent) : void
      {
         var _loc2_:UserInfo = null;
         super.avatarChanged(param1);
         if(_namebar)
         {
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
            if(_loc2_ != null)
            {
               toggleNamebarSelNub(_loc2_.nameBarData);
            }
            if(_loc2_ && !_isGuide && !_shouldShowPetOnly)
            {
               _namebar.setColorAndBadge(_loc2_.nameBarData);
               _namebar.setColorBadgeAndXp(_loc2_.nameBarData,gMainFrame.userInfo.getAvatarInfoByUserName(_avatar.userName).questLevel,_isMember,gMainFrame.clientInfo.roomType == 7 || gMainFrame.clientInfo.roomType == 8);
               _namebar.setAvName(_avatar,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_loc2_);
            }
            else
            {
               _namebar.setColorAndBadge(0);
               _namebar.setColorBadgeAndXp(0,0,_isMember);
               if(_shouldShowPetOnly && _currPetName)
               {
                  _namebar.setAvName(_currPetName);
               }
               else
               {
                  _namebar.setAvName(_avatar.avName);
               }
            }
            _chatBalloon.avType = _avatar.avTypeId;
         }
         if(_particleIdling)
         {
            updateSpecialPatternColorsAndApply();
         }
      }
      
      public function overHandler(param1:MouseEvent) : void
      {
         _namebar["selnub"].visible = true;
      }
      
      public function outHandler(param1:MouseEvent) : void
      {
         if(_namebar["n"].visible)
         {
            return;
         }
         if(param1 && param1.relatedObject && param1.relatedObject is DisplayObject && _namebar.contains(DisplayObject(param1.relatedObject)))
         {
            return;
         }
         _namebar["selnub"].visible = false;
      }
      
      public function preload(param1:Function) : void
      {
         var _loc2_:Array = new Array(7,8,9,10,11,14);
         _layerAnim.preload(_loc2_,param1);
      }
      
      public function handleOffScreenSleep(param1:Boolean = false) : void
      {
         if(isOffScreen && _hudViewHolder != null)
         {
            if(param1)
            {
               if(_hudViewHolder.mouse.currentFrameLabel == "sleeping")
               {
                  _hudViewHolder.zzz.visible = false;
                  _hudViewHolder.mouse.gotoAndStop("up");
               }
               return;
            }
            if(_hudViewHolder.mouse.currentFrameLabel != "sleeping")
            {
               _hudViewHolder.mouse.gotoAndStop("sleeping");
               if(_hudViewHolder.mouse.rotation == 180 && _hudViewHolder.zzz.rotation != 180)
               {
                  _hudViewHolder.zzz.rotation = 180;
                  _hudViewHolder.zzz.x = 0.1;
                  _hudViewHolder.zzz.y = 9.2;
               }
               else if(_hudViewHolder.zzz.rotation != 0)
               {
                  _hudViewHolder.zzz.rotation = 0;
                  _hudViewHolder.zzz.x = 0.1;
                  _hudViewHolder.zzz.y = 0.2;
               }
            }
         }
      }
      
      public function handleOffScreenHit() : void
      {
         if(isOffScreen && _hudViewHolder != null)
         {
            if(_flashTimer)
            {
               _flashTimer.reset();
               _flashTimer.start();
            }
            if(_hudViewHolder.mouse.currentFrameLabel != "flash")
            {
               _hudViewHolder.mouse.gotoAndStop("flash");
            }
         }
      }
      
      private function onFlashTimer(param1:TimerEvent) : void
      {
         if(_flashTimer)
         {
            _flashTimer.reset();
         }
         if(_hudViewHolder)
         {
            _hudViewHolder.mouse.gotoAndStop("up");
         }
      }
      
      private function ownNamebarDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_guiMgr)
         {
            _guiMgr.openAvatarEditor();
         }
      }
      
      private function onChatBallonAdventureDown(param1:int) : void
      {
         var _loc2_:Object = QuestXtCommManager.getScriptDef(param1);
         if(_loc2_.membersOnly && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup(16,"adventure/" + param1);
            return;
         }
         QuestXtCommManager.sendQuestJoinPrivate(userName);
      }
      
      private function onChatBalloonPVPDown(param1:int) : void
      {
         QuestManager.privateAdventureJoinClose(true);
         if(MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            DarkenManager.showLoadingSpiral(true);
            UserCommXtCommManager.sendCustomPVPMessage(false,0,onChatBalloonPVPDown,param1);
            MinigameManager.readySelfForCustomPVPGame(-1,"");
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.readySelfForPvpGame({"typeDefId":param1},userName,true,true);
         MinigameXtCommManager.sendMinigameCustomPvpJoinMsg(param1,0,userName);
      }
      
      private function namebarAndAvatarDownHandler(param1:MouseEvent) : void
      {
         var pt:Point;
         var vo:Object;
         var player:Object;
         var m:MouseEvent = param1;
         m.stopPropagation();
         if(gMainFrame.clientInfo.roomType != 7)
         {
            pt = RoomManagerWorld.instance.convertScreenToWorldSpace(m.stageX,m.stageY);
            vo = RoomManagerWorld.instance.volumeManager.testMouseVolumes(pt,true,function(param1:String):Boolean
            {
               return false;
            });
            if(vo == null || vo.name == "dark")
            {
               player = {
                  "userName":userName,
                  "onlineStatus":1
               };
               if(_guiObj)
               {
                  _guiObj.showUserInfoPopup(player);
               }
            }
         }
      }
      
      private function namebarAndAvatarOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.mouse.currentFrameLabel != "over")
         {
            AJAudio.playExitBtnRollover();
            param1.currentTarget.mouse.gotoAndStop("over");
         }
      }
      
      private function namebarAndAvatarOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.mouse.currentFrameLabel != "up")
         {
            param1.currentTarget.mouse.gotoAndStop("up");
         }
      }
      
      private function attachmentMouseDownHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.parent.getChildAt(0).play();
         param1.stopPropagation();
      }
      
      public function startSlide(param1:Array) : void
      {
         _moving = 0;
         _slidePositions = param1;
         _slideSpinCurrentDirection = 0;
         _slideSpinTimer = 0;
         _slideCurrentPosition = 0;
         _slideFrameTime = 0;
         _followPath = null;
      }
      
      public function updateSlide(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         if(_slideCurrentPosition >= 0)
         {
            while(param1 > 0)
            {
               if(_slideCurrentPosition >= _slidePositions.length - 1)
               {
                  if(_avatar.userName.toLowerCase() == gMainFrame.server.userName.toLowerCase())
                  {
                     AchievementXtCommManager.requestSetUserVar(96,1);
                  }
                  _slideCurrentPosition = -1;
                  playAnim(getBaseIdle());
                  _moving = _followPath ? 1 : 0;
                  break;
               }
               if(_slideFrameTime + param1 < 41.666666666666664)
               {
                  _slideFrameTime += param1;
                  param1 = 0;
               }
               else
               {
                  param1 -= 41.666666666666664 - _slideFrameTime;
                  _slideFrameTime = 41.666666666666664;
               }
               setPos(_slidePositions[_slideCurrentPosition].x + (_slidePositions[_slideCurrentPosition + 1].x - _slidePositions[_slideCurrentPosition].x) * _slideFrameTime / 41.666666666666664,_slidePositions[_slideCurrentPosition].y + (_slidePositions[_slideCurrentPosition + 1].y - _slidePositions[_slideCurrentPosition].y) * _slideFrameTime / 41.666666666666664,false,false);
               if(param1 > 0)
               {
                  _slideFrameTime = 0;
                  _slideCurrentPosition = _slideCurrentPosition + 1;
               }
            }
            if(_roomType != 1)
            {
               if(_slideCurrentPosition >= 0 && (_slideSpinTimer == 0 || _slideSpinTimer < getTimer()))
               {
                  _slideSpinCurrentDirection = _slideSpinCurrentDirection + 1;
                  if(_slideSpinCurrentDirection > 9)
                  {
                     _slideSpinCurrentDirection = 0;
                  }
                  _loc2_ = 0;
                  _loc3_ = _slideSpinCurrentDirection > 4 ? true : false;
                  switch(_slideSpinCurrentDirection)
                  {
                     case 0:
                        _loc2_ = 0;
                        break;
                     case 1:
                        _loc2_ = 1;
                        break;
                     case 2:
                        _loc2_ = 2;
                        break;
                     case 3:
                        _loc2_ = 3;
                        break;
                     case 4:
                        _loc2_ = 4;
                        break;
                     case 5:
                        _loc2_ = 4;
                        break;
                     case 6:
                        _loc2_ = 3;
                        break;
                     case 7:
                        _loc2_ = 2;
                        break;
                     case 8:
                        _loc2_ = 1;
                        break;
                     case 9:
                        _loc2_ = 0;
                  }
                  _slideSpinTimer = getTimer() + 100;
                  playAnim(1 + _loc2_,_loc3_,2);
               }
            }
         }
      }
      
      public function setBounce(param1:Boolean) : void
      {
         _layerAnim.bounceEnabled = param1;
         if(param1 && _layerAnim.animId != 17 && (_dirX != 0 || _dirY != 0 || _layerAnim.animId == 14 || _layerAnim.animId == 16))
         {
            faceAnim(_dirX,_dirY,true);
         }
      }
   }
}

