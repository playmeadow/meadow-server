package avatar
{
   import achievement.AchievementXtCommManager;
   import com.sbi.client.SFClient;
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
      
      public static var _actionLookup:Array = [{
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
         var _loc2_:int = LayerAnim.AN_IDLE_SE;
         var _loc3_:Boolean = false;
         var _loc4_:Number = Math.PI * 0.5;
         if(param1 > -2 * _loc4_ && param1 < -_loc4_)
         {
            _loc2_ = LayerAnim.AN_IDLE_NE;
            _loc3_ = true;
         }
         else if(param1 >= -_loc4_ && param1 < 0)
         {
            _loc2_ = LayerAnim.AN_IDLE_NE;
         }
         else if(param1 >= 0 && param1 < _loc4_)
         {
            _loc2_ = LayerAnim.AN_IDLE_SE;
         }
         else
         {
            _loc2_ = LayerAnim.AN_IDLE_SE;
            _loc3_ = true;
         }
         return {
            "anim":_loc2_,
            "flip":_loc3_
         };
      }
      
      public static function updateScreenPositionAndDirection(param1:MovieClip, param2:Rectangle, param3:Point) : void
      {
         if(param3.x > param2.width)
         {
            if(param3.x > param2.width)
            {
               param3.x = MainFrame.VIEW_WIDTH - param1.mouse.width * 0.5;
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
            param3.y = MainFrame.VIEW_HEIGHT - param1.mouse.height * 0.5 - 73.5;
            if(param3.x - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5) < 0)
            {
               param1.openChat(-90,param3.x + (0 - param3.x + (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5)));
            }
            else if(param3.x - (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5) > param2.width)
            {
               param1.openChat(-90,param3.x - (MainFrame.VIEW_WIDTH - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5)),true);
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
               param1.openChat(90,param3.x - (MainFrame.VIEW_WIDTH - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5)),true);
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
         var _loc10_:int = 0;
         var _loc11_:LayerBitmap = null;
         _avatar = param1;
         if(!param2)
         {
            throw new Error("AvatarWorldView got invalid chatLayer:null!");
         }
         this._chatLayer = param2;
         this._actionMgr = param6;
         this._guiMgr = param7;
         this._roomType = param9;
         if(param5)
         {
            visible = false;
         }
         param1.addEventListener(AvatarEvent.AVATAR_CHANGED,this.avatarChanged,false,0,true);
         this._isGuide = param4;
         this._scale = new Point(1,1);
         this._pos = new Point(0,0);
         this._slideCurrentPosition = -1;
         lastAnimToHappen = -1;
         if(param1.perUserAvId != 0 && gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && QuestManager.hasJustJoinedQuest)
         {
            AvatarManager.setOffScreenMapBySfsId(userId,new Point(0,0),gMainFrame.server.getCurrentRoomName(false));
         }
         this.initNamebar(param3);
         if(param1.avName == "")
         {
            this._namebar.visible = false;
         }
         if(_avatar.isShaman)
         {
            _loc10_ = 2;
         }
         else if(this._isGuide)
         {
            _loc10_ = 3;
         }
         else
         {
            _loc10_ = 1;
         }
         this._chatBalloon = GETDEFINITIONBYNAME("ChatBalloonAsset");
         this._chatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,_loc10_,SBTextField,this.onChatBallonAdventureDown,this.onChatBalloonPVPDown);
         this._chatLayer.addChild(this._chatBalloon);
         this._moving = 0;
         this._lastMoveAngle = 2;
         this._lastIdleAnim = this.getBaseIdle();
         this._lastIdleFlip = false;
         this.setNamebarListenersWithUserName(param1.userName);
         this.toggleNamebarSelNub(param8);
         this._namebar.setColorAndBadge(param8);
         _layerAnim = LayerAnim.getNew();
         _layerAnim.avDefId = param1.avTypeId;
         if(param1.colors)
         {
            _layerAnim.layers = setLayerHelper();
         }
         _layerAnim.local = userId == AvatarManager.playerSfsUserId;
         _loc11_ = _layerAnim.bitmap;
         _loc11_.x = 0;
         _loc11_.y = 0;
         this._glow = new GlowFilter(0,1,4,4,4);
         _layerAnim.bitmap.filters = [this._glow];
         this.setBlendColor();
         this._splash = new AvatarViewExt_Splash(this,_loc11_);
         if(this._roomType == SbiConstants.ENVIRO_OCEAN)
         {
            this._splash.showShadow(false);
         }
         if(userId == AvatarManager.playerSfsUserId || gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST)
         {
            this._namebar.mouseChildren = false;
            this._namebar.mouseEnabled = false;
            this._chatBalloon.mouseChildren = false;
            this._chatBalloon.mouseEnabled = false;
         }
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && Boolean(AvatarManager.getViewHudMCBySfsId(userId)))
         {
            this._hudViewHolder = AvatarManager.getViewHudMCBySfsId(userId);
            if(this._hudViewHolder)
            {
               if(this._flashTimer)
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
            this._namebar.setAvName(param1.avName);
            _layerAnim.avatarEnabled = true;
            this._timeSinceLastParticle = -1;
            this._particleOffset = 1;
            this.setupParticles();
         }
         this._bInSplashVolume = false;
         this._isLoadingEmoteId = -1;
      }
      
      override public function destroy(param1:Boolean = false) : void
      {
         QuestManager.removeTorch(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         if(param1 && Boolean(_avatar))
         {
            _avatar.destroy();
            _avatar = null;
         }
         var _loc2_:LayerBitmap = _layerAnim.bitmap;
         removeChild(_loc2_);
         _loc2_.filters = null;
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
         if(this._particleIdling)
         {
            this.clearSpecialPattern();
         }
         removeEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler);
         this._namebar.removeEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler);
         this._namebar["selnub"].removeEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler);
         this._namebar.removeEventListener(MouseEvent.MOUSE_DOWN,this.ownNamebarDownHandler);
         this._chatBalloon = null;
         if(this._namebar)
         {
            this._namebar.destroy();
         }
         this._namebar = null;
         avTypeChangedCallback = null;
         this._slidePositions = null;
         this._glow = null;
         if(this._flashTimer)
         {
            this._flashTimer.reset();
            this._flashTimer.removeEventListener(TimerEvent.TIMER,this.onFlashTimer);
            this._flashTimer = null;
            this._hudViewHolder.mouse.gotoAndStop("up");
         }
         if(this._hudAvtOrPetView)
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
      
      public function set roomType(param1:int) : void
      {
         this._roomType = param1;
      }
      
      public function set deleteOnMoveComplete(param1:Boolean) : void
      {
         this._deleteOnMoveComplete = param1;
      }
      
      public function get currentLevel() : int
      {
         if(this._namebar)
         {
            return this._namebar.currentLevel;
         }
         return 0;
      }
      
      public function isThisAttachmentOn(param1:int) : Boolean
      {
         if(this._secondaryEmot == null)
         {
            return false;
         }
         if(this._avAttMediaId == param1)
         {
            return true;
         }
         return false;
      }
      
      public function getBaseIdle() : int
      {
         return this._roomType == SbiConstants.ENVIRO_OCEAN ? LayerAnim.AN_FLOAT : LayerAnim.AN_IDLE_SE;
      }
      
      public function setPath(param1:Array) : void
      {
         this._followPath = param1;
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
      
      public function setPos(param1:Number, param2:Number, param3:Boolean, param4:Boolean = true) : void
      {
         var _loc5_:Number = NaN;
         if(param4)
         {
            this._followPath = null;
         }
         if(param3)
         {
            this._dirX = param1 - this._pos.x;
            this._dirY = param2 - this._pos.y;
            _loc5_ = Math.sqrt(this._dirX * this._dirX + this._dirY * this._dirY);
            if(_loc5_)
            {
               this._dirX /= _loc5_ * this._scale.x;
               this._dirY /= _loc5_ * this._scale.y;
            }
            this.faceAnim(this._dirX,this._dirY,true);
            this._moving = 1;
            this._moveToX = param1;
            this._moveToY = param2;
         }
         else
         {
            this._dirX = 0;
            this._dirY = 0;
            this.updatePos(param1,param2);
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
      
      public function setSplashVolume(param1:Boolean, param2:String) : void
      {
         this._bInSplashVolume = param1;
         this._splashLiquid = param2;
      }
      
      public function setAvatarMode(param1:int) : void
      {
         switch(param1)
         {
            case AV_MODE_QUESTCOMBAT:
               _layerAnim.bitmap.filters = null;
               if(this._splash)
               {
                  this._splash.showShadow(false);
               }
               if(this._namebar != null)
               {
                  this._namebar.visible = false;
               }
         }
      }
      
      public function setupParticles() : void
      {
         this._emitParticles = Boolean(_avatar.colors) && _avatar.customAvId != -1;
         this.updateSpecialPatternColors();
         this.clearSpecialPattern();
      }
      
      public function clearSpecialPattern() : void
      {
         var _loc1_:Loader = null;
         if(this._particleIdling)
         {
            _loc1_ = this._particleIdling.getChildAt(0) as Loader;
            if(_loc1_.content)
            {
               (_loc1_.content as MovieClip).readyToUse = true;
            }
            if(this._particleIdling.parent)
            {
               this._particleIdling.parent.removeChild(this._particleIdling);
            }
            this._particleIdling = null;
         }
      }
      
      public function updateSpecialPatternColors() : void
      {
         if(Boolean(_avatar) && Boolean(_avatar.colors))
         {
            this._currSpecialPatternColors = PaletteHelper.getHexColorsFromPalette(_avatar.colors[1]);
         }
      }
      
      public function updateSpecialPatternColorsAndApply() : void
      {
         var _loc1_:Loader = null;
         if(Boolean(_avatar) && Boolean(_avatar.colors))
         {
            this._currSpecialPatternColors = PaletteHelper.getHexColorsFromPalette(_avatar.colors[1]);
            if(this._particleIdling)
            {
               _loc1_ = this._particleIdling.getChildAt(0) as Loader;
               this.setupSpecialPattern(_loc1_.content as MovieClip);
            }
         }
      }
      
      public function updateNameBarLevelShape(param1:int) : void
      {
         var _loc2_:UserInfo = null;
         if(this._namebar != null)
         {
            if(this._shouldShowPetOnly)
            {
               param1 = 0;
               this._namebar.removeShape();
            }
            else
            {
               _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
               if(Boolean(_loc2_) || Boolean(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST) || gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST_STAGING)
               {
                  this._namebar.setColorBadgeAndXp(_loc2_ ? _loc2_.nameBarData : 0,param1,this._isMember,gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST || gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST_STAGING);
               }
            }
         }
      }
      
      public function updateNameBarHealth(param1:int) : void
      {
         if(this._namebar != null)
         {
            this._namebar.updateMeter(param1);
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
               param2 = this._roomType == SbiConstants.ENVIRO_LAND ? uint(GLOW_LAND_DEFAULT_COLOR) : uint(GLOW_OCEAN_DEFAULT_COLOR);
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
         if(Boolean(gMainFrame.clientInfo.invisMode) && userId == AvatarManager.playerSfsUserId)
         {
            param1 = 50;
         }
         var _loc2_:Number = param1 / 100;
         this.alpha = _loc2_;
      }
      
      public function isSameMessage(param1:String) : Boolean
      {
         if(this._chatBalloon)
         {
            if(this._chatBalloon.visible)
            {
               return this._chatBalloon.msgTxt.text == param1;
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
         this._chatBalloon.setText(param1,_loc3_);
         this.updateOffScreenChat(param1,_loc3_);
      }
      
      public function setCustomAdventureMessage(param1:String, param2:String, param3:int, param4:int, param5:Boolean = false) : void
      {
         var _loc6_:Boolean = false;
         if(Boolean(gMainFrame.userInfo.isModerator) && param4 > 1)
         {
            _loc6_ = true;
         }
         this._chatBalloon.setCustomAdventureMessage(param1,param2,param3,_loc6_,param5);
         if(this._chatBalloon.visible && this._chatBalloon.isPvpCustom)
         {
            this.loadCustomPVPImage(this._chatBalloon.pvpGameId);
         }
      }
      
      private function loadCustomPVPImage(param1:int) : void
      {
         var _loc2_:MinigameInfo = null;
         if(param1 != 0)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(param1);
            this._customPVPImageLoader = new MediaHelper();
            this._customPVPImageLoader.init(_loc2_.gameCardMediaId,this.onCustomPVPImageLoaded);
         }
      }
      
      private function onCustomPVPImageLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            if(this._customPVPImageLoader)
            {
               this._customPVPImageLoader.destroy();
               this._customPVPImageLoader = null;
            }
            _loc2_ = param1.height;
            param1.scaleX = param1.scaleY = 0.5;
            if(this._chatBalloon)
            {
               this._chatBalloon.setCustomPVPImage(param1);
            }
         }
      }
      
      public function setEmote(param1:Sprite, param2:int = -1) : void
      {
         if(Boolean(param1) || param2 >= 0)
         {
            this._chatBalloon.setEmote(param1,param2);
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
         if(this._chatBalloon)
         {
            return this._chatBalloon.perEmoteMediaId;
         }
         return -1;
      }
      
      public function setAction(param1:Sprite) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         if(!this._actionMgr)
         {
            return;
         }
         this._lastIdleAnim = this.getBaseIdle();
         this._lastIdleFlip = false;
         var _loc2_:String = this._actionMgr.getActionString(param1);
         for each(_loc3_ in _actionLookup)
         {
            if(_loc3_.name == _loc2_)
            {
               _loc4_ = this._roomType == SbiConstants.ENVIRO_LAND ? int(_loc3_.land) : int(_loc3_.water);
               if(_loc4_ > 0)
               {
                  this._lastIdleAnim = _loc4_;
                  this._lastIdleFlip = _loc3_.flip;
                  playAnim(_loc4_,_loc3_.flip);
               }
               break;
            }
         }
      }
      
      public function circleTest(param1:int, param2:int, param3:int) : Boolean
      {
         return Boolean(Collision.circleHitCircle(new Point(param1,param2),param3,new Point(this._pos.x,this._pos.y),this._radius));
      }
      
      public function bmpDataHitTest(param1:BitmapData, param2:Point) : Boolean
      {
         return param1.hitTest(new Point(this._pos.x,this._pos.y),255,param1,param2,255);
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
         if(this._secondaryEmot)
         {
            if(this._secondaryEmot.parent == this._chatLayer)
            {
               this._chatLayer.setChildIndex(this._secondaryEmot,this._chatLayer.numChildren - 1);
            }
            this._secondaryEmot.scaleX = this._secondaryEmot.scaleY = 1;
         }
      }
      
      public function setAvAttachment(param1:int, param2:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:FrameLabel = null;
         this._avAttMediaId = param1;
         if(param1 == 0)
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
            if(Boolean(this._secondaryEmot) && Boolean(this._isLoadingEmoteId == -1) && this._secondaryEmot.id != param1)
            {
               this._secondaryEmot.attachment.gotoAndPlay("_hide");
               if(Boolean(this._secondaryEmot["getAttachedSound"]) && this._secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.stopItemEmoticonSound(this);
               }
            }
            if(this._secondaryEmot != null && (this._secondaryEmot.id == param1 && this._avAttachmentExtra == param2) || this._isLoadingEmoteId == param1)
            {
               if(Boolean(this._secondaryEmot) && Boolean(this._secondaryEmot.attachment))
               {
                  _loc4_ = int(this._secondaryEmot.attachment.currentLabels.length);
                  while(_loc3_ < _loc4_)
                  {
                     _loc5_ = this._secondaryEmot.attachment.currentLabels[_loc3_];
                     if(_loc5_.name == "_main")
                     {
                        this._secondaryEmot.attachment.gotoAndStop("_main");
                        return;
                     }
                     _loc3_++;
                  }
                  this._secondaryEmot.attachment.gotoAndStop("_show");
               }
               return;
            }
            this._avAttachmentExtra = param2;
            this._isLoadingEmoteId = param1;
            if(!this._avAttMediaHelper)
            {
               this._avAttMediaHelper = new MediaHelper();
            }
            this._avAttMediaHelper.init(param1,this.onAttachLoaded);
         }
      }
      
      private function setOffScreenAvAttachment(param1:MovieClip, param2:int) : void
      {
         var _loc3_:MovieClip = AvatarManager.getOffScreenAttachmentBySfsId(param2);
         var _loc4_:int = int(param1.attachmentId);
         if(_loc4_ == 0)
         {
            if(_loc3_)
            {
               if(_loc3_.attachment.currentFrameLabel == "_gone")
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
                  _loc3_.attachment.gotoAndPlay("_hide");
               }
               AvatarManager.setOffScreenAttachmentBySfsId(param2,_loc3_);
            }
            else if(Boolean(param1.avtView) && !param1.charLayer.contains(param1.avtView))
            {
               param1.charLayer.addChild(param1.avtView);
            }
         }
         else
         {
            if(_loc3_ != null && (_loc3_.id == _loc4_ || _loc3_.isLoadingEmoteId == _loc4_))
            {
               if(!param1.charLayer.contains(_loc3_))
               {
                  while(param1.charLayer.numChildren > 0)
                  {
                     param1.charLayer.removeChildAt(0);
                  }
                  param1.charLayer.addChild(_loc3_);
               }
               return;
            }
            param1.isLoadingEmoteId = _loc4_;
            AvatarManager.setViewHudMCBySfsId(param2,param1);
            if(!this._avOffscreenMediaHelper)
            {
               this._avOffscreenMediaHelper = new MediaHelper();
            }
            this._avOffscreenMediaHelper.init(_loc4_,this.onOffscreenAttachLoaded,{
               "offscreenMC":param1,
               "sfsId":param2
            });
         }
      }
      
      private function onOffscreenAttachLoaded(param1:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:MovieClip = param1.passback.offscreenMC;
         if(Boolean(param1) && param1.hasOwnProperty("attachment"))
         {
            while(_loc2_.charLayer.numChildren > 0)
            {
               _loc2_.charLayer.removeChildAt(0);
            }
            _loc3_ = param1;
            _loc3_.id = _loc2_.isLoadingEmoteId;
            _loc2_.charLayer.addChild(_loc3_);
            _loc3_.scaleX = _loc3_.scaleY = 0.5;
            _loc3_.x = (0 - 355) * _loc3_.scaleX;
            _loc3_.y = (0 - 235) * _loc3_.scaleX;
            _loc3_.attachment.gotoAndPlay("_show");
            AvatarManager.setOffScreenAttachmentBySfsId(param1.passback.sfsId,_loc3_);
         }
      }
      
      private function emoteLoader(param1:int, param2:Function = null) : void
      {
         this._emoteMediaHelper = new MediaHelper();
         this._emoteMediaHelper.init(param1,param2);
      }
      
      private function onAttachLoaded(param1:MovieClip) : void
      {
         if(Boolean(param1) && Boolean(param1.hasOwnProperty("attachment")) && Boolean(this._avAttMediaId))
         {
            if(Boolean(this._avAttachmentExtra) && Boolean(this._avAttachmentExtra.length))
            {
               param1.setState(this._avAttachmentExtra);
            }
            if(this._chatLayer)
            {
               if(Boolean(this._secondaryEmot) && Boolean(this._chatLayer.contains(this._secondaryEmot)))
               {
                  this._chatLayer.removeChild(this._secondaryEmot);
               }
               this._secondaryEmot = param1;
               this._secondaryEmot.id = this._isLoadingEmoteId;
               if(isOffScreen)
               {
                  if(this._hudViewHolder.charLayer.contains(this._hudAvtOrPetView))
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
      
      public function checkSelnub(param1:MouseEvent) : void
      {
         var _loc2_:Number = Point.distance(this.localToGlobal(new Point(0,0)),new Point(gMainFrame.stage.mouseX,gMainFrame.stage.mouseY));
         if(_loc2_ < SELNUB_SHOW_DIST)
         {
            this.overHandler(param1);
         }
         else
         {
            this.outHandler(param1);
         }
      }
      
      public function heartbeat(param1:int, param2:int) : Boolean
      {
         var _loc4_:Point = null;
         var _loc5_:Object = null;
         var _loc10_:Boolean = false;
         var _loc11_:Number = NaN;
         var _loc12_:MovieClip = null;
         var _loc13_:Loader = null;
         var _loc14_:int = 0;
         var _loc15_:Loader = null;
         var _loc16_:Object = null;
         var _loc17_:String = null;
         var _loc18_:int = 0;
         var _loc19_:Dictionary = null;
         var _loc20_:Point = null;
         var _loc21_:MovieClip = null;
         var _loc22_:Point = null;
         var _loc23_:Point = null;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc27_:Rectangle = null;
         if(this._slideCurrentPosition >= 0)
         {
            this.updateSlide(param1);
         }
         this._frameTime = param2 / 1000;
         if(this._frameTime > 0.5)
         {
            this._frameTime = 0.5;
         }
         var _loc3_:int = 1;
         this._splash.heartbeat(this._bInSplashVolume,this.isSplashAnim(),this._splashLiquid,avatarData != null && (avatarData.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR) != 0);
         if(!this._bInSplashVolume && this._emitParticles)
         {
            if(this._moving == 1)
            {
               if(this._particleIdling)
               {
                  this._particleIdling.visible = false;
               }
               _loc10_ = true;
               _loc11_ = _loc10_ ? 0.1 : 0.05;
               if(this._timeSinceLastParticle < 0 || this._timeSinceLastParticle > _loc11_)
               {
                  _loc12_ = AvatarManager.getFlower();
                  if(_loc10_)
                  {
                     _loc12_.x = x - 20;
                     _loc12_.y = y;
                     _loc12_.scaleX = 0.22;
                     _loc12_.scaleY = 0.13;
                     if(this._lastParticleLoc)
                     {
                        this._lastParticleLoc.x = _loc12_.x - this._lastParticleLoc.x;
                        this._lastParticleLoc.y = _loc12_.y - this._lastParticleLoc.y;
                        this._lastParticleLoc.normalize(1);
                        _loc14_ = 5;
                        _loc12_.x -= _loc14_ * this._particleOffset * this._lastParticleLoc.y;
                        _loc12_.y += _loc14_ * this._particleOffset * this._lastParticleLoc.x;
                        this._particleOffset *= -1;
                        this._lastParticleLoc.x = x - 20;
                        this._lastParticleLoc.y = y;
                     }
                     else
                     {
                        _loc12_.visible = false;
                        this._lastParticleLoc = new Point(_loc12_.x,_loc12_.y);
                     }
                  }
                  else
                  {
                     _loc12_.x = x - 55;
                     _loc12_.y = y - 80;
                     _loc12_.scaleX = _loc12_.scaleY = 0.5;
                  }
                  _loc13_ = _loc12_.getChildAt(0) as Loader;
                  if(_loc13_.content == null)
                  {
                     _loc13_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.flowerLoaderComplete);
                  }
                  else
                  {
                     this.resetFlower(_loc13_.content as MovieClip);
                  }
                  this._timeSinceLastParticle = 0;
               }
               this._timeSinceLastParticle += this._frameTime;
            }
            else
            {
               if(this._particleIdling)
               {
                  if(!this._particleIdling.visible)
                  {
                     this._particleIdling.visible = true;
                     _loc15_ = this._particleIdling.getChildAt(0) as Loader;
                     (_loc15_.content as MovieClip).animate();
                  }
               }
               else
               {
                  this._particleIdling = AvatarManager.getFlower(true);
                  _loc15_ = this._particleIdling.getChildAt(0) as Loader;
                  if(_loc15_.content)
                  {
                     this.setupSpecialPattern(_loc15_.content as MovieClip);
                  }
                  else
                  {
                     _loc15_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.flowerIdleLoaderComplete);
                  }
               }
               this._particleIdling.x = x - 30;
               this._particleIdling.y = y - 15;
            }
         }
         var _loc6_:Number = this._pos.x;
         var _loc7_:Number = this._pos.y;
         var _loc8_:Number = this._dirX * 24 * _loc3_ * this._frameTime / 0.07;
         var _loc9_:Number = this._dirY * 24 * _loc3_ * this._frameTime / 0.07;
         if(Boolean(this._dirX) || Boolean(this._dirY))
         {
            this.checkSelnub(null);
         }
         if(_loc8_)
         {
            if(_loc8_ > 0 && _loc8_ + this._pos.x >= this._moveToX || _loc8_ < 0 && _loc8_ + this._pos.x <= this._moveToX)
            {
               this._dirX = 0;
               _loc6_ = this._moveToX;
            }
            else
            {
               _loc6_ += _loc8_;
            }
         }
         if(_loc9_)
         {
            if(_loc9_ > 0 && _loc9_ + this._pos.y >= this._moveToY || _loc9_ < 0 && _loc9_ + this._pos.y <= this._moveToY)
            {
               this._dirY = 0;
               _loc7_ = this._moveToY;
            }
            else
            {
               _loc7_ += _loc9_;
            }
         }
         if(_loc6_ != this._pos.x || _loc7_ != this._pos.y || gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST)
         {
            ++this._numFramesForOffscreen;
            this.updatePos(_loc6_,_loc7_);
            _loc16_ = AvatarManager.getOffScreenMap();
            for(_loc17_ in _loc16_)
            {
               _loc18_ = int(_loc17_);
               if(AvatarManager.avatarList[_loc17_] == null)
               {
                  _loc19_ = AvatarManager.getOffScreenMapBySfsId(_loc18_);
                  _loc20_ = _loc19_[gMainFrame.server.getCurrentRoomName(false)];
                  _loc21_ = AvatarManager.getViewHudMCBySfsId(_loc18_);
                  if(_loc21_)
                  {
                     if(_loc20_)
                     {
                        _loc22_ = RoomManagerWorld.instance.bkgScalePoint();
                        _loc23_ = RoomManagerWorld.instance.convertWorldToScreen(_loc20_.x * _loc22_.x,_loc20_.y * _loc22_.y);
                        _loc24_ = _loc21_.mouse.height * 0.5 * _loc22_.x;
                        _loc25_ = _loc21_.mouse.width * 0.5 * _loc22_.y;
                        _loc26_ = 73.5 * _loc22_.y;
                        _loc27_ = new Rectangle(0,0,MainFrame.VIEW_WIDTH - _loc25_,MainFrame.VIEW_HEIGHT - _loc24_ - _loc26_ + this._radius * 2 * _loc22_.x);
                        if(!_loc27_.containsPoint(_loc23_))
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
                           updateScreenPositionAndDirection(_loc21_,_loc27_,_loc23_);
                           _loc21_.x = _loc23_.x;
                           _loc21_.y = _loc23_.y;
                           _loc21_.questChatBalloon.heartbeat(param1);
                           if(this._numFramesForOffscreen >= 48 && _loc21_.avtView != null)
                           {
                              if(_loc21_.charLayer.contains(_loc21_.avtView))
                              {
                                 this.setOffScreenAvAttachment(_loc21_,_loc18_);
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
         this._chatBalloon.heartbeat(param1);
         this.offScreenChatHeartbeat(param1);
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
               if(this._hudViewHolder.charLayer.contains(this._hudAvtOrPetView))
               {
                  while(this._hudViewHolder.charLayer.numChildren > 0)
                  {
                     this._hudViewHolder.charLayer.removeChildAt(0);
                  }
                  this.updateSecondaryEmoteOffScreenPosition();
                  this._hudViewHolder.charLayer.addChild(this._secondaryEmot);
               }
               else if(this._hudViewHolder.charLayer.contains(this._secondaryEmot))
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
                  if(this._followPath)
                  {
                     this.followPath();
                  }
                  else if(_layerAnim.bounceEnabled)
                  {
                     if(this.isSelf)
                     {
                        RoomManagerWorld.instance.resetThrottle();
                        this._moving = 0;
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
         if(this._pet)
         {
            this._pet.heartbeat(_layerAnim.bounceOffSet);
         }
         return true;
      }
      
      private function setupSpecialPattern(param1:MovieClip) : void
      {
         if(param1)
         {
            if(this._currSpecialPatternColors == null)
            {
               this.updateSpecialPatternColors();
            }
            param1.setColors(this._currSpecialPatternColors);
            param1.animate();
            param1.readyToUse = false;
         }
      }
      
      private function flowerIdleLoaderComplete(param1:Event) : void
      {
         this.setupSpecialPattern(param1.target.content);
      }
      
      private function flowerLoaderComplete(param1:Event) : void
      {
         this.resetFlower(param1.target.content);
      }
      
      private function resetFlower(param1:MovieClip) : void
      {
         if(param1)
         {
            if(this._currSpecialPatternColors == null)
            {
               this.updateSpecialPatternColors();
            }
            param1.setColor(this._currSpecialPatternColors[this._patternIndex]);
            param1.animate();
            this._patternIndex = this._patternIndex + 1 == this._currSpecialPatternColors.length ? 0 : int(this._patternIndex + 1);
         }
      }
      
      public function playIdle() : void
      {
         this._slideCurrentPosition = -1;
         playAnim(this.getBaseIdle(),this._lastIdleFlip);
      }
      
      public function setActivePet(param1:uint, param2:uint, param3:uint, param4:String, param5:int = 0) : void
      {
         if(this._pet)
         {
            if(this._pet.parent == this)
            {
               this.removeChild(this._pet);
            }
            this._pet = null;
         }
         if(gMainFrame.clientInfo.roomType != SbiConstants.ROOMTYPE_QUEST || this._shouldShowPetOnly)
         {
            if(param1 != 0 && PetManager.canCurrAvatarUsePet(_avatar.enviroTypeFlag,PetManager.petTypeForDefId(param1 & 0xFF)))
            {
               this._pet = new WorldPet(this,param1,param2,param3,param5);
            }
            if(this._shouldShowPetOnly)
            {
               if(!this.isActivePetGroundPet())
               {
                  this._splash.showShadow(false);
               }
               this._currPetName = LocalizationManager.translatePetName(param4);
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
         if(this._pet)
         {
            return this._pet.isGround();
         }
         return true;
      }
      
      public function flipSplash(param1:Boolean) : void
      {
         this._splash.flipSplash(param1);
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
      
      private function initNamebar(param1:int) : void
      {
         this._isMember = Utility.isMember(param1);
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
      
      private function setNamebarListenersWithUserName(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1 != gMainFrame.server.userName || Boolean(gMainFrame.userInfo.isModerator))
         {
            this._namebar.addEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler,false,0,true);
            this._namebar["selnub"].addEventListener(MouseEvent.MOUSE_DOWN,this.namebarAndAvatarDownHandler,false,0,true);
         }
         else
         {
            this._namebar.removeListeners();
         }
      }
      
      public function toggleNamebarSelNub(param1:int = -1) : void
      {
         var _loc2_:int = 0;
         if(this._isGuide)
         {
            this._namebar.setNubType(NameBar.GUIDE);
         }
         else
         {
            if(param1 == -1)
            {
               _loc2_ = this._namebar.packedNameBarData;
            }
            else
            {
               _loc2_ = param1;
            }
            if(BuddyManager.isBuddy(_avatar.userName) || this.isSelf || this._isMember && NameBar.isVIPBadge(_loc2_))
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
         return userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase();
      }
      
      private function followPath() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = int(this._followPath.length);
         if(_loc1_)
         {
            _loc2_ = this._followPath[0];
            if(_loc1_ > 1)
            {
               this._followPath.splice(0,1);
            }
            else
            {
               this._followPath = null;
            }
            this.setPos(_loc2_.x,_loc2_.y,true,false);
         }
      }
      
      private function updatePos(param1:Number, param2:Number) : void
      {
         this._pos.x = param1;
         this._pos.y = param2;
         param1 *= this._scale.x;
         param2 *= this._scale.y;
         this.x = param1;
         this.y = param2;
         var _loc3_:Point = AvatarUtility.getAvatarChatOffset(_avatar.avTypeId);
         this._chatBalloon.x = this.x + _loc3_.x;
         this._chatBalloon.y = this.y + _loc3_.y;
         if(this._secondaryEmot)
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
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && gMainFrame.userInfo.myUserName != _avatar.userName)
         {
            this.updateOffScreenPositions();
         }
      }
      
      public function updateOffScreenPositions() : void
      {
         var _loc7_:AvatarInfo = null;
         if(!this._hudViewHolder)
         {
            this._hudViewHolder = GETDEFINITIONBYNAME("offScreenIconQuest");
            this._hudViewHolder.mouse.gotoAndStop("up");
            this._hudViewHolder.questChatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,7,SBTextField);
            if(this._flashTimer)
            {
               this._flashTimer.reset();
            }
            this._flashTimer = new Timer(2500);
            this._flashTimer.addEventListener(TimerEvent.TIMER,this.onFlashTimer,false,0,true);
            AvatarManager.setViewHudMCBySfsId(userId,this._hudViewHolder);
         }
         var _loc1_:Point = RoomManagerWorld.instance.bkgScalePoint();
         var _loc2_:Point = RoomManagerWorld.instance.convertWorldToScreen(this.x * _loc1_.x,this.y * _loc1_.y);
         var _loc3_:int = this._hudViewHolder.mouse.height * 0.5 * _loc1_.x;
         var _loc4_:int = this._hudViewHolder.mouse.width * 0.5 * _loc1_.y;
         var _loc5_:int = 73.5 * _loc1_.y;
         var _loc6_:Rectangle = new Rectangle(0,0,MainFrame.VIEW_WIDTH - _loc4_,MainFrame.VIEW_HEIGHT - _loc3_ - _loc5_ + this._radius * 2 * _loc1_.x);
         if(!_loc6_.containsPoint(_loc2_))
         {
            updateScreenPositionAndDirection(this._hudViewHolder,_loc6_,_loc2_);
            if(!isOffScreen)
            {
               if(this._hudViewHolder.mouse.currentFrameLabel != "up")
               {
                  this._hudViewHolder.mouse.gotoAndStop("up");
               }
               if(GuiManager.isBeYourPetRoom())
               {
                  _loc7_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(userName,perUserAvId);
                  this._hudAvtOrPetView = new GuiPet(0,_loc7_.currPet.lBits,_loc7_.currPet.uBits,_loc7_.currPet.eBits,_loc7_.currPet.type,_loc7_.currPet.name,this.onHudAvtOrPetView);
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
               if(this._secondaryEmot)
               {
                  this._chatLayer.removeChild(this._secondaryEmot);
               }
            }
            this._hudViewHolder.x = _loc2_.x;
            this._hudViewHolder.y = _loc2_.y;
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
            if(this._secondaryEmot)
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
      
      private function updateOffScreenItemsForOthers(param1:MovieClip, param2:Point) : void
      {
      }
      
      private function onHudAvtOrPetView(param1:Object, param2:Object) : void
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
         var _loc1_:Point = null;
         var _loc2_:Number = NaN;
         if(GuiManager.isBeYourPetRoom())
         {
            this._hudAvtOrPetView.y = 15;
         }
         else
         {
            _loc1_ = AvatarUtility.getAvatarHudPosition(this._hudAvtOrPetView.avTypeId);
            this._hudAvtOrPetView.scaleX = this._hudAvtOrPetView.scaleY = 1;
            _loc2_ = 41 / this._hudAvtOrPetView.width;
            if(this._hudAvtOrPetView.height * _loc2_ > 41)
            {
               _loc2_ = 41 / this._hudAvtOrPetView.height;
            }
            this._hudAvtOrPetView.scaleX = _loc2_;
            this._hudAvtOrPetView.scaleY = _loc2_;
            this._hudAvtOrPetView.x = _loc1_.x * _loc2_;
            this._hudAvtOrPetView.y = _loc1_.y * _loc2_;
         }
      }
      
      private function updateSecondaryEmoteOffScreenPosition() : void
      {
         this._secondaryEmot.scaleX = this._secondaryEmot.scaleY = 1;
         var _loc1_:Number = 0.5;
         this._secondaryEmot.scaleX = _loc1_;
         this._secondaryEmot.scaleY = _loc1_;
         this._secondaryEmot.x = (0 - 355) * _loc1_;
         this._secondaryEmot.y = (0 - 235) * _loc1_;
      }
      
      private function updateOffScreenChat(param1:String, param2:Boolean) : void
      {
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && gMainFrame.userInfo.myUserName != _avatar.userName && Boolean(this._hudViewHolder))
         {
            this._hudViewHolder.questChatBalloon.setText(param1,param2,false);
         }
      }
      
      private function offScreenChatHeartbeat(param1:int) : void
      {
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST && gMainFrame.userInfo.myUserName != _avatar.userName && Boolean(this._hudViewHolder))
         {
            this._hudViewHolder.questChatBalloon.heartbeat(param1);
         }
      }
      
      public function faceAnim(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         var _loc4_:Number = Math.atan2(param2,param1);
         var _loc5_:Number = Math.PI * 0.1;
         var _loc6_:Number = Math.PI * 0.2;
         this._lastMoveAngle = _loc4_;
         var _loc7_:Object = convertToIdle(this._lastMoveAngle);
         this._lastIdleAnim = _loc7_.anim;
         if(this._roomType == SbiConstants.ENVIRO_OCEAN)
         {
            this._lastIdleAnim = this.getBaseIdle();
         }
         this._lastIdleFlip = _loc7_.flip;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         if(_loc4_ >= 5 * _loc6_ - _loc5_ || _loc4_ < -5 * _loc6_ + _loc5_)
         {
            _loc8_ = 2;
            _loc9_ = true;
         }
         else if(_loc4_ >= -4 * _loc6_ - _loc5_ && _loc4_ < -4 * _loc6_ + _loc5_)
         {
            _loc8_ = 1;
            _loc9_ = true;
         }
         else if(_loc4_ >= -3 * _loc6_ - _loc5_ && _loc4_ < -3 * _loc6_ + _loc5_)
         {
            _loc8_ = 0;
            _loc9_ = true;
         }
         else if(_loc4_ >= -2 * _loc6_ - _loc5_ && _loc4_ < -2 * _loc6_ + _loc5_)
         {
            _loc8_ = 0;
         }
         else if(_loc4_ >= -_loc6_ - _loc5_ && _loc4_ < -_loc6_ + _loc5_)
         {
            _loc8_ = 1;
         }
         else if(_loc4_ >= -_loc5_ && _loc4_ < _loc5_)
         {
            _loc8_ = 2;
         }
         else if(_loc4_ >= _loc6_ - _loc5_ && _loc4_ < _loc6_ + _loc5_)
         {
            _loc8_ = 3;
         }
         else if(_loc4_ >= 2 * _loc6_ - _loc5_ && _loc4_ < 2 * _loc6_ + _loc5_)
         {
            _loc8_ = 4;
         }
         else if(_loc4_ >= 3 * _loc6_ - _loc5_ && _loc4_ < 3 * _loc6_ + _loc5_)
         {
            _loc8_ = 4;
            _loc9_ = true;
         }
         else
         {
            _loc8_ = 3;
            _loc9_ = true;
         }
         var _loc10_:int = LayerAnim.AN_MOVE_NNE + _loc8_;
         if(!param3)
         {
            switch(_loc8_)
            {
               case 0:
               case 1:
                  _loc10_ = LayerAnim.AN_IDLE_NE;
                  break;
               case 2:
               case 3:
               case 4:
                  _loc10_ = LayerAnim.AN_IDLE_SE;
            }
         }
         if(this._roomType == SbiConstants.ENVIRO_OCEAN)
         {
            _loc10_ = LayerAnim.AN_SWIM_E;
         }
         if(_layerAnim.bounceEnabled)
         {
            _loc10_ = LayerAnim.AN_HOP;
         }
         playAnim(_loc10_,_loc9_,LayerAnim.PLAY_LOOP__KEEP_CURRENT_FRAME);
      }
      
      override protected function avatarChanged(param1:AvatarEvent) : void
      {
         var _loc2_:UserInfo = null;
         super.avatarChanged(param1);
         if(this._namebar)
         {
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
            if(_loc2_ != null)
            {
               this.toggleNamebarSelNub(_loc2_.nameBarData);
            }
            if(Boolean(_loc2_) && Boolean(!this._isGuide) && !this._shouldShowPetOnly)
            {
               this._namebar.setColorAndBadge(_loc2_.nameBarData);
               this._namebar.setColorBadgeAndXp(_loc2_.nameBarData,gMainFrame.userInfo.getAvatarInfoByUserName(_avatar.userName).questLevel,this._isMember,gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST || gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST_STAGING);
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
         if(this._particleIdling)
         {
            this.updateSpecialPatternColorsAndApply();
         }
      }
      
      public function overHandler(param1:MouseEvent) : void
      {
         this._namebar["selnub"].visible = true;
      }
      
      public function outHandler(param1:MouseEvent) : void
      {
         if(this._namebar["n"].visible)
         {
            return;
         }
         if(Boolean(param1 && param1.relatedObject) && Boolean(param1.relatedObject is DisplayObject) && this._namebar.contains(DisplayObject(param1.relatedObject)))
         {
            return;
         }
         this._namebar["selnub"].visible = false;
      }
      
      public function preload(param1:Function) : void
      {
         var _loc2_:Array = new Array(LayerAnim.AN_MOVE_NNE,LayerAnim.AN_MOVE_NE,LayerAnim.AN_MOVE_E,LayerAnim.AN_MOVE_SE,LayerAnim.AN_MOVE_SSE,LayerAnim.AN_IDLE_SE);
         _layerAnim.preload(_loc2_,param1);
      }
      
      public function handleOffScreenSleep(param1:Boolean = false) : void
      {
         if(isOffScreen && this._hudViewHolder != null)
         {
            if(param1)
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
            if(this._flashTimer)
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
      
      private function onFlashTimer(param1:TimerEvent) : void
      {
         if(this._flashTimer)
         {
            this._flashTimer.reset();
         }
         if(this._hudViewHolder)
         {
            this._hudViewHolder.mouse.gotoAndStop("up");
         }
      }
      
      private function ownNamebarDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._guiMgr)
         {
            this._guiMgr.openAvatarEditor();
         }
      }
      
      private function onChatBallonAdventureDown(param1:int) : void
      {
         var _loc2_:Object = QuestXtCommManager.getScriptDef(param1);
         if(Boolean(_loc2_.membersOnly) && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup(UpsellManager.ADVENTURES,"adventure/" + param1);
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
            UserCommXtCommManager.sendCustomPVPMessage(false,0,this.onChatBalloonPVPDown,param1);
            MinigameManager.readySelfForCustomPVPGame(-1,"");
            return;
         }
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.readySelfForPvpGame({"typeDefId":param1},userName,true,true);
         MinigameXtCommManager.sendMinigameCustomPvpJoinMsg(param1,0,userName);
      }
      
      private function namebarAndAvatarDownHandler(param1:MouseEvent) : void
      {
         var pt:Point = null;
         var vo:Object = null;
         var player:Object = null;
         var m:MouseEvent = param1;
         m.stopPropagation();
         if(gMainFrame.clientInfo.roomType != SbiConstants.ROOMTYPE_QUEST)
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
                  "onlineStatus":SFClient.STATUS_ONLINE
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
         this._moving = 0;
         this._slidePositions = param1;
         this._slideSpinCurrentDirection = 0;
         this._slideSpinTimer = 0;
         this._slideCurrentPosition = 0;
         this._slideFrameTime = 0;
         this._followPath = null;
      }
      
      public function updateSlide(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         if(this._slideCurrentPosition >= 0)
         {
            while(param1 > 0)
            {
               if(this._slideCurrentPosition >= this._slidePositions.length - 1)
               {
                  if(_avatar.userName.toLowerCase() == gMainFrame.server.userName.toLowerCase())
                  {
                     AchievementXtCommManager.requestSetUserVar(96,1);
                  }
                  this._slideCurrentPosition = -1;
                  playAnim(this.getBaseIdle());
                  this._moving = this._followPath ? 1 : 0;
                  break;
               }
               if(this._slideFrameTime + param1 < SLIDE_FRAME_TIME)
               {
                  this._slideFrameTime += param1;
                  param1 = 0;
               }
               else
               {
                  param1 -= SLIDE_FRAME_TIME - this._slideFrameTime;
                  this._slideFrameTime = SLIDE_FRAME_TIME;
               }
               this.setPos(this._slidePositions[this._slideCurrentPosition].x + (this._slidePositions[this._slideCurrentPosition + 1].x - this._slidePositions[this._slideCurrentPosition].x) * this._slideFrameTime / SLIDE_FRAME_TIME,this._slidePositions[this._slideCurrentPosition].y + (this._slidePositions[this._slideCurrentPosition + 1].y - this._slidePositions[this._slideCurrentPosition].y) * this._slideFrameTime / SLIDE_FRAME_TIME,false,false);
               if(param1 > 0)
               {
                  this._slideFrameTime = 0;
                  ++this._slideCurrentPosition;
               }
            }
            if(this._roomType != SbiConstants.ENVIRO_OCEAN)
            {
               if(this._slideCurrentPosition >= 0 && (this._slideSpinTimer == 0 || this._slideSpinTimer < getTimer()))
               {
                  ++this._slideSpinCurrentDirection;
                  if(this._slideSpinCurrentDirection > 9)
                  {
                     this._slideSpinCurrentDirection = 0;
                  }
                  _loc2_ = 0;
                  _loc3_ = this._slideSpinCurrentDirection > 4 ? true : false;
                  switch(this._slideSpinCurrentDirection)
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
                  this._slideSpinTimer = getTimer() + 100;
                  playAnim(LayerAnim.AN_SIT_NNE + _loc2_,_loc3_,LayerAnim.PLAY_LOOP__KEEP_CURRENT_FRAME);
               }
            }
         }
      }
      
      public function setBounce(param1:Boolean) : void
      {
         _layerAnim.bounceEnabled = param1;
         if(param1 && _layerAnim.animId != LayerAnim.AN_HOP && (this._dirX != 0 || this._dirY != 0 || _layerAnim.animId == LayerAnim.AN_IDLE_SE || _layerAnim.animId == LayerAnim.AN_IDLE_NE))
         {
            this.faceAnim(this._dirX,this._dirY,true);
         }
      }
   }
}

