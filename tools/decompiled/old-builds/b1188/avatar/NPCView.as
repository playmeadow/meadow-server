package avatar
{
   import com.sbi.graphics.LayerAnim;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Linear;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   
   public class NPCView extends Sprite
   {
      
      public static const NPC_STATE_LOADING:int = -2;
      
      public static const NPC_STATE_LOADED:int = -1;
      
      public static const NPC_STATE_IDLE:int = 0;
      
      public static const NPC_STATE_MOVE:int = 1;
      
      public static const NPC_STATE_ATTACK:int = 2;
      
      public static const NPC_STATE_RECOIL:int = 3;
      
      public static const NPC_STATE_DEATH:int = 4;
      
      public static const NPC_STATE_TREASURE_APPEAR:int = 5;
      
      public static const NPC_STATE_TREASURE_OPEN:int = 6;
      
      public static const NPC_STATE_TREASURE_DISAPPEAR:int = 7;
      
      public static const NPC_STATE_DANCE:int = 8;
      
      private var _npcDef:Object;
      
      private var _npcMC:MovieClip;
      
      private var _npcAvatarView:AvatarWorldView;
      
      private var _playerId:int;
      
      private var _namebar:NameBar;
      
      private var _mediaHelperObj:MediaHelper;
      
      private var _onLoadingCompleteCallback:Function;
      
      private var _npcState:int;
      
      private var _npcAngle:int;
      
      private var _healthBar:MovieClip;
      
      private var _hitText:TextField;
      
      private var _hitTextTween:GTween;
      
      private var _secondaryNpcMC:MovieClip;
      
      public var _eye:MovieClip;
      
      public var _beam:MovieClip;
      
      public var _npcFacingSW:Boolean;
      
      public function NPCView()
      {
         super();
      }
      
      public function get npcState() : int
      {
         return this._npcState;
      }
      
      public function get npcStateComplete() : Boolean
      {
         switch(this._npcState)
         {
            case NPC_STATE_LOADING:
               return false;
            case NPC_STATE_LOADED:
               return true;
            case NPC_STATE_TREASURE_APPEAR:
            case NPC_STATE_TREASURE_OPEN:
            case NPC_STATE_TREASURE_DISAPPEAR:
               return this._npcMC == null || Boolean(this._npcMC.finished);
            default:
               throw new Error("NPVView: npcStateComplete: Unsupported state");
         }
      }
      
      public function get readyToLaunchAttack() : Boolean
      {
         if(this._npcState == NPC_STATE_ATTACK)
         {
            if(this._npcMC != null)
            {
               if(this._npcMC.attacking == true)
               {
                  this._npcMC.attacking = false;
                  return true;
               }
               if(this._npcMC.hasOwnProperty("counterAttacking") && this._npcMC.counterAttacking == true)
               {
                  this._npcMC.counterAttacking = false;
                  return true;
               }
            }
            return false;
         }
         return true;
      }
      
      public function get readyToAttack() : Boolean
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this._npcMC != null && this._npcMC.hasOwnProperty("getCustomCollisionPoints"))
         {
            _loc1_ = this._npcMC.getCustomCollisionPoints();
            if(_loc1_ != null)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc1_.length)
               {
                  _loc3_ = _loc1_[_loc2_];
                  if(_loc3_.Type == 2)
                  {
                     return !this._npcMC.animActive && Boolean(this._npcMC.readyForAttack);
                  }
                  _loc2_++;
               }
            }
         }
         if(this._npcState != NPC_STATE_ATTACK && this._npcState != NPC_STATE_DEATH)
         {
            return true;
         }
         return false;
      }
      
      public function get isDead() : Boolean
      {
         if(this._npcState == NPC_STATE_DEATH && (this._npcMC == null || this._npcMC.animActive == false))
         {
            return true;
         }
         return false;
      }
      
      public function get isDying() : Boolean
      {
         return this._npcState == NPC_STATE_DEATH;
      }
      
      public function moveFaceAnim(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         if(this._npcAvatarView)
         {
            _loc2_ = 0;
            _loc3_ = false;
            while(param1 < 0)
            {
               param1 += 360;
            }
            while(param1 >= 360)
            {
               param1 -= 360;
            }
            if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_LAND)
            {
               if(param1 < 180)
               {
                  if(param1 < 35)
                  {
                     _loc2_ = LayerAnim.AN_MOVE_NNE;
                  }
                  else if(param1 < 70)
                  {
                     _loc2_ = LayerAnim.AN_MOVE_NE;
                  }
                  else if(param1 < 110)
                  {
                     _loc2_ = LayerAnim.AN_MOVE_E;
                  }
                  else if(param1 < 145)
                  {
                     _loc2_ = LayerAnim.AN_MOVE_SE;
                  }
                  else
                  {
                     _loc2_ = LayerAnim.AN_MOVE_SSE;
                  }
               }
               else
               {
                  _loc3_ = true;
                  if(param1 < 215)
                  {
                     _loc2_ = LayerAnim.AN_MOVE_SSE;
                  }
                  else if(param1 < 250)
                  {
                     _loc2_ = LayerAnim.AN_MOVE_SE;
                  }
                  else if(param1 < 290)
                  {
                     _loc2_ = LayerAnim.AN_MOVE_E;
                  }
                  else if(param1 < 325)
                  {
                     _loc2_ = LayerAnim.AN_MOVE_NE;
                  }
                  else
                  {
                     _loc2_ = LayerAnim.AN_MOVE_NNE;
                  }
               }
            }
            else if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
            {
               if(param1 < 180)
               {
                  _loc2_ = LayerAnim.AN_SWIM_E;
               }
               else
               {
                  _loc3_ = true;
                  _loc2_ = LayerAnim.AN_SWIM_E;
               }
            }
            this._npcAvatarView.playAnim(_loc2_,_loc3_,LayerAnim.PLAY_LOOP__KEEP_CURRENT_FRAME);
         }
      }
      
      public function setNpcState(param1:int, param2:Number = 0) : void
      {
         if(this._npcState != NPC_STATE_DEATH)
         {
            switch(param1)
            {
               case NPC_STATE_TREASURE_APPEAR:
                  if(this._npcMC)
                  {
                     this._npcMC.appear();
                     this._npcState = param1;
                  }
                  break;
               case NPC_STATE_TREASURE_OPEN:
                  if(this._npcMC)
                  {
                     this._npcMC.openChest();
                     this._npcState = param1;
                  }
                  break;
               case NPC_STATE_TREASURE_DISAPPEAR:
                  if(this._npcMC)
                  {
                     this._npcMC.disappear();
                     this._npcState = param1;
                  }
                  break;
               case NPC_STATE_DEATH:
                  if(this._npcMC)
                  {
                     this._npcState = param1;
                     this._npcMC.noHealth();
                  }
                  break;
               case NPC_STATE_IDLE:
                  if(this._npcMC)
                  {
                     if(this._npcMC.animActive == false)
                     {
                        this._npcState = param1;
                        this._npcMC.idle(270);
                     }
                     if(this._npcMC.hasOwnProperty("getSortHeight"))
                     {
                        if(this._npcMC.parent.parent)
                        {
                           this._npcMC.parent.parent.name = this._npcMC.getSortHeight();
                        }
                     }
                  }
                  else if(this._npcAvatarView)
                  {
                     if(this._npcState != param1)
                     {
                        if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_LAND)
                        {
                           this.playAnimationState(LayerAnim.AN_IDLE_SE,false,LayerAnim.PLAY_LOOP,null);
                        }
                        else if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
                        {
                           this.playAnimationState(LayerAnim.AN_FLOAT,false,LayerAnim.PLAY_LOOP,null);
                        }
                        this._npcState = param1;
                     }
                  }
                  break;
               case NPC_STATE_MOVE:
                  if(this._npcAvatarView != null)
                  {
                     this._npcState = param1;
                     if(this._npcAngle != param2)
                     {
                        this._npcAngle = param2;
                        this.moveFaceAnim(this._npcAngle);
                     }
                  }
                  else if(this._npcMC != null)
                  {
                     this._npcAngle = param2;
                     if(this._npcMC.animActive == false)
                     {
                        this._npcState = param1;
                        this._npcMC.moveCycle(this._npcAngle);
                     }
                  }
                  break;
               case NPC_STATE_ATTACK:
                  if(this._npcMC != null)
                  {
                     this._npcState = param1;
                     this._npcAngle = param2;
                     this._npcMC.attack(this._npcAngle);
                  }
                  break;
               case NPC_STATE_RECOIL:
                  if(this._npcMC != null)
                  {
                     if(this._npcState != NPC_STATE_RECOIL || this._npcMC.hasOwnProperty("animActive") == false || this._npcMC.animActive == false)
                     {
                        if(this._npcState == NPC_STATE_IDLE || this._npcState == NPC_STATE_MOVE)
                        {
                           this._npcState = param1;
                        }
                        this._npcMC.recoil(this._npcAngle);
                     }
                  }
                  break;
               case NPC_STATE_DANCE:
                  if(this._npcAvatarView != null)
                  {
                     this._npcState = param1;
                     if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_LAND)
                     {
                        this.playAnimationState(LayerAnim.AN_DANCE,false,LayerAnim.PLAY_LOOP,null);
                     }
                     else if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
                     {
                        this.playAnimationState(LayerAnim.AN_WATER_JIG,false,LayerAnim.PLAY_LOOP,null);
                     }
                  }
            }
         }
      }
      
      public function get collisionZapRadius() : Number
      {
         if(this._npcMC != null)
         {
            return this._npcMC.getCollisionRadius(0);
         }
         return 20;
      }
      
      public function get collisionRadiusMoving() : Number
      {
         if(this._npcMC != null)
         {
            if("getCollisionRadius" in this._npcMC)
            {
               return this._npcMC.getCollisionRadius(1);
            }
         }
         return 20;
      }
      
      public function get collisionRadiusAttack() : Number
      {
         if(this._npcMC != null)
         {
            if("getCollisionRadius" in this._npcMC)
            {
               return this._npcMC.getCollisionRadius(2);
            }
         }
         return 20;
      }
      
      public function get collisionMovingPoint() : Point
      {
         if(this._npcMC != null)
         {
            if("getCollisionPoint" in this._npcMC)
            {
               return this._npcMC.getCollisionPoint(1);
            }
         }
         return new Point(0,0);
      }
      
      public function get collisionZapPoint() : Point
      {
         if(this._npcMC != null)
         {
            if("getCollisionPoint" in this._npcMC)
            {
               return this._npcMC.getCollisionPoint(2);
            }
         }
         return new Point(0,0);
      }
      
      public function get collisionPointAttack() : Point
      {
         if(this._npcMC != null)
         {
            if("getCollisionPoint" in this._npcMC)
            {
               return this._npcMC.getCollisionPoint(0);
            }
         }
         return new Point(0,0);
      }
      
      public function get avatar() : Avatar
      {
         if(this._npcAvatarView != null)
         {
            return this._npcAvatarView.avatarData;
         }
         return null;
      }
      
      public function get talkingHeadMediaId() : int
      {
         if(this._npcDef != null)
         {
            return this._npcDef.headMediaRefId;
         }
         return 0;
      }
      
      public function reset() : void
      {
         this._npcState = NPC_STATE_LOADING;
      }
      
      public function init(param1:int, param2:int, param3:int = -1, param4:int = 0, param5:Boolean = false, param6:Function = null) : void
      {
         var _loc7_:Avatar = null;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:Item = null;
         var _loc11_:* = 0;
         var _loc12_:Array = null;
         var _loc13_:Array = null;
         var _loc14_:String = null;
         this._npcFacingSW = false;
         this._npcState = NPC_STATE_LOADING;
         this._npcAngle = 0;
         this._npcDef = QuestManager.getNPCDef(param1);
         this._playerId = param2;
         this._onLoadingCompleteCallback = param6;
         this._hitText = new TextField();
         this._hitText.selectable = false;
         this._hitText.multiline = false;
         this._hitText.autoSize = TextFieldAutoSize.CENTER;
         this._hitText.visible = false;
         this._hitText.embedFonts = true;
         this._hitText.defaultTextFormat = new TextFormat("TikiIsland-Regular",36,4286945);
         this._hitText.filters = [new GlowFilter(0,1,3,3,10,2)];
         switch(this._npcDef.type)
         {
            case 0:
               this._mediaHelperObj = new MediaHelper();
               this._mediaHelperObj.init(this._npcDef.mediaRefId,this.onMediaLoaded);
               break;
            case 1:
               _loc7_ = new Avatar();
               _loc7_.avName = "";
               _loc7_.userName = "";
               _loc7_.isShaman = param4 == 32;
               this._npcAvatarView = new AvatarWorldView();
               this._npcAvatarView.initWorldView(_loc7_,QuestManager._layerManager.room_chat,SbiConstants.NON_MEMBER,true);
               _loc7_.init(-1,_loc7_.avName,this._npcDef.avatarRefId,[this._npcDef.baseColor,this._npcDef.patternColor,this._npcDef.eyesColor]);
               _loc7_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(this._npcDef.avatarRefId,this._npcDef.patternItemRefId,this._npcDef.eyesItemRefId,false));
               if(param3 > 0)
               {
                  if(this._npcAvatarView != null && this._npcAvatarView.avatarData != null)
                  {
                     _loc14_ = LocalizationManager.translateIdOnly(param3);
                     this._npcAvatarView.avatarData.avName = _loc14_;
                     this._npcAvatarView.avatarData.userName = _loc14_;
                     if(this._npcAvatarView.nameBar != null)
                     {
                        this._npcAvatarView.nameBar.setAvName(_loc14_);
                        this._npcAvatarView.nameBar.visible = true;
                     }
                  }
               }
               _loc8_ = new Array();
               _loc11_ = 100;
               _loc9_ = 0;
               while(_loc9_ < this._npcAvatarView.avatarData.inventoryBodyMod.itemArray.length)
               {
                  _loc8_.push(this._npcAvatarView.avatarData.inventoryBodyMod.itemArray[_loc9_]);
                  _loc9_++;
               }
               if(this._npcDef.backItemRefId != 0)
               {
                  _loc10_ = new Item();
                  _loc12_ = ItemXtCommManager.getItemDef(this._npcDef.backItemRefId).colors;
                  _loc10_.init(this._npcDef.backItemRefId,_loc11_++,_loc12_[Math.min(this._npcDef.backColor,_loc12_.length - 1)],-1,-1);
                  _loc8_.push(_loc10_);
               }
               if(this._npcDef.headItemRefId != 0)
               {
                  _loc10_ = new Item();
                  _loc12_ = ItemXtCommManager.getItemDef(this._npcDef.headItemRefId).colors;
                  _loc10_.init(this._npcDef.headItemRefId,_loc11_++,_loc12_[Math.min(this._npcDef.headColor,_loc12_.length - 1)],-1,-1);
                  _loc8_.push(_loc10_);
               }
               if(this._npcDef.legItemRefId != 0)
               {
                  _loc10_ = new Item();
                  _loc12_ = ItemXtCommManager.getItemDef(this._npcDef.legItemRefId).colors;
                  _loc10_.init(this._npcDef.legItemRefId,_loc11_++,_loc12_[Math.min(this._npcDef.legColor,_loc12_.length - 1)],-1,-1);
                  _loc8_.push(_loc10_);
               }
               if(this._npcDef.neckItemRefId != 0)
               {
                  _loc10_ = new Item();
                  _loc12_ = ItemXtCommManager.getItemDef(this._npcDef.neckItemRefId).colors;
                  _loc10_.init(this._npcDef.neckItemRefId,_loc11_++,_loc12_[Math.min(this._npcDef.neckColor,_loc12_.length - 1)],-1,-1);
                  _loc8_.push(_loc10_);
               }
               if(this._npcDef.tailItemRefId != 0)
               {
                  _loc10_ = new Item();
                  _loc12_ = ItemXtCommManager.getItemDef(this._npcDef.tailItemRefId).colors;
                  _loc10_.init(this._npcDef.tailItemRefId,_loc11_++,_loc12_[Math.min(this._npcDef.tailColor,_loc12_.length - 1)],-1,-1);
                  _loc8_.push(_loc10_);
               }
               this._npcAvatarView.avatarData.itemResponseIntegrate(_loc8_);
               _loc13_ = new Array(15);
               this.redrawCallback(null);
         }
         if(param5)
         {
            this._healthBar = GETDEFINITIONBYNAME("NPCHealth");
            this._healthBar.x = -this._healthBar.width * 0.5;
            this._healthBar.y = 18;
            this._healthBar.hpBar.width = this._healthBar.hpEnemyBarContainer.width;
            addChild(this._healthBar);
         }
      }
      
      public function destroy() : void
      {
         if(this._mediaHelperObj)
         {
            this._mediaHelperObj.destroy();
            this._mediaHelperObj = null;
         }
         if(this._npcMC)
         {
            if(this._npcMC.hasOwnProperty("destroyPhantomNPC"))
            {
               this._npcMC.destroyPhantomNPC();
            }
            if(this._npcMC.parent != null)
            {
               this._npcMC.parent.removeChild(this._npcMC);
            }
         }
         if(Boolean(this._secondaryNpcMC) && Boolean(this._secondaryNpcMC.parent != null) && this._secondaryNpcMC.parent is MovieClip)
         {
            this._secondaryNpcMC.parent.removeChild(this._secondaryNpcMC);
         }
         if(this._namebar)
         {
            this._namebar.destroy();
            this._namebar = null;
         }
         if(this._healthBar)
         {
            this._healthBar = null;
         }
         if(this._npcAvatarView)
         {
            if(this._npcAvatarView.parent != null)
            {
               this._npcAvatarView.parent.removeChild(this._npcAvatarView);
            }
            this._npcAvatarView.destroy(true);
         }
         this._hitTextTween = null;
      }
      
      public function updateHealthBar(param1:int, param2:int, param3:Boolean, param4:Boolean) : void
      {
         var _loc5_:String = null;
         if(this._healthBar)
         {
            if(param1 == 0)
            {
               this._healthBar.visible = false;
            }
            else
            {
               this._healthBar.hpBar.width = this._healthBar.hpEnemyBarContainer.width * (param1 / 100);
            }
         }
         if(param4)
         {
            if(param2 > 0 && Boolean(this._npcMC))
            {
               if(param3)
               {
                  _loc5_ = "Fierce!\n" + Math.abs(param2) * -1;
               }
               else
               {
                  _loc5_ = String(Math.abs(param2) * -1);
               }
               this.playHitText(_loc5_);
            }
         }
      }
      
      public function playHitText(param1:String) : void
      {
         var attachmentPoint:Point = null;
         var hitString:String = param1;
         this._hitText.visible = true;
         this._hitText.alpha = 2;
         this._hitText.text = hitString;
         try
         {
            attachmentPoint = this._npcMC.getAttachmentPoint();
            this._hitText.x = attachmentPoint.x + this.x - this._hitText.textWidth * 0.5;
            this._hitText.y = attachmentPoint.y + this.y;
         }
         catch(e:Error)
         {
            _hitText.x = this.x - _hitText.textWidth * 0.5;
            _hitText.y = this.y - _hitText.textHeight;
         }
         if(parent != null)
         {
            this._hitText.x += parent.x;
            this._hitText.y += parent.y;
         }
         if(this._hitTextTween)
         {
            this._hitTextTween.resetValues({
               "y":this._hitText.y - 90,
               "alpha":0
            });
            this._hitTextTween.beginning();
            this._hitTextTween.paused = false;
         }
         else
         {
            this._hitTextTween = new GTween(this._hitText,1,{
               "y":this._hitText.y - 90,
               "alpha":0
            },{"ease":Linear.easeNone});
         }
      }
      
      public function playAnimationState(param1:int, param2:Boolean, param3:int, param4:Function) : void
      {
         if(this._npcAvatarView)
         {
            this._npcAvatarView.playAnim(param1,param2,param3,param4);
         }
      }
      
      public function get npcMC() : MovieClip
      {
         return this._npcMC;
      }
      
      public function get defId() : int
      {
         return this._npcDef.defId;
      }
      
      public function get npcDef() : Object
      {
         return this._npcDef;
      }
      
      public function get secondaryNpcMC() : MovieClip
      {
         return this._secondaryNpcMC;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         this._npcMC = param1;
         addChild(this._npcMC);
         if(this._npcMC.hasOwnProperty("eye"))
         {
            this._eye = this._npcMC.eye;
         }
         if(this._npcDef.headMediaRefId != 0)
         {
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._npcDef.headMediaRefId,this.secondaryNPCLoaded);
         }
         else
         {
            this.loadingComplete();
         }
      }
      
      private function secondaryNPCLoaded(param1:MovieClip) : void
      {
         if(param1.getChildAt(0) is MovieClip)
         {
            this._secondaryNpcMC = MovieClip(param1.getChildAt(0));
         }
         else
         {
            this._secondaryNpcMC = param1;
         }
         this._mediaHelperObj.destroy();
         this._mediaHelperObj = null;
         this.loadingComplete();
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(this._npcAvatarView)
         {
            if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_LAND)
            {
               this.playAnimationState(LayerAnim.AN_IDLE_SE,false,LayerAnim.PLAY_LOOP,null);
            }
            else if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
            {
               this.playAnimationState(LayerAnim.AN_FLOAT,false,LayerAnim.AN_FLOAT,null);
            }
            addChild(this._npcAvatarView);
            this.loadingComplete();
         }
      }
      
      private function loadingComplete() : void
      {
         this._npcState = NPC_STATE_LOADED;
         if(this._npcMC != null && this._npcMC.hasOwnProperty("setInit"))
         {
            this._npcMC.setInit(QuestManager._questDifficultyLevel);
            if(this._npcMC.hasOwnProperty("watcher"))
            {
               this._beam = this._npcMC.watcher;
            }
         }
         QuestManager._layerManager.room_chat.addChild(this._hitText);
         if(this._onLoadingCompleteCallback != null)
         {
            this._onLoadingCompleteCallback();
         }
      }
      
      public function setSwfState(param1:String) : Number
      {
         if(this._npcMC != null)
         {
            if(param1 == "facesw_k")
            {
               param1 = "facesw";
            }
            else if(param1 == "facese_k")
            {
               param1 = "facese";
            }
            return this._npcMC.setStateByScript(param1);
         }
         if(this._npcAvatarView != null)
         {
            if(param1 == "dance")
            {
               if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_LAND)
               {
                  this.playAnimationState(LayerAnim.AN_DANCE,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_WATER_JIG,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(param1 == "hop")
            {
               if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_LAND)
               {
                  this.playAnimationState(LayerAnim.AN_HOP,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_WATER_DIVE,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(param1 == "spin")
            {
               if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_WATER_SPIN,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(param1 == "idle" || param1 == "facese")
            {
               this._npcFacingSW = false;
               if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_LAND)
               {
                  this.playAnimationState(LayerAnim.AN_IDLE_SE,false,LayerAnim.PLAY_LOOP,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_FLOAT,false,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(param1 == "facesw")
            {
               this._npcFacingSW = true;
               if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_LAND)
               {
                  this.playAnimationState(LayerAnim.AN_IDLE_SE,true,LayerAnim.PLAY_LOOP,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == SbiConstants.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_FLOAT,true,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(param1 == "facesw_k")
            {
               if(this._npcFacingSW == false && Boolean(this._npcAvatarView))
               {
                  this._npcFacingSW = true;
                  this.playAnimationState(this._npcAvatarView.animId,true,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(param1 == "facese_k")
            {
               if(this._npcFacingSW == true && Boolean(this._npcAvatarView))
               {
                  this._npcFacingSW = false;
                  this.playAnimationState(this._npcAvatarView.animId,false,LayerAnim.PLAY_LOOP,null);
               }
            }
         }
         return 0;
      }
   }
}

