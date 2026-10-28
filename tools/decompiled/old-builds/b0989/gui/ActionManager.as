package gui
{
   import avatar.AvatarManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class ActionManager
   {
      
      private const ACTIONWINDOW_DIM_ALPHA:Number = 0.5;
      
      private const ACTIONWINDOW_BRIGHT_ALPHA:Number = 1;
      
      public var actionBtn:MovieClip;
      
      public var actionWindow:MovieClip;
      
      public var emoteBtn:MovieClip;
      
      public var emoteWindow:Sprite;
      
      public var safeChatBtn:MovieClip;
      
      public var safeChatTree:MovieClip;
      
      public var setActionCallback:Function;
      
      public var actionSprites:Array = ["sit1BtnCont","sit2BtnCont","sit3BtnCont","sit4BtnCont","danceAnim_btnCont","sleepAnim_btnCont","hopAnim_btnCont","playAnim_btnCont","pose1BtnCont","pose2BtnCont","diveAnim_btnCont","swirlAnim_btnCont"];
      
      public var actionStrings:Object;
      
      private var _actions:MovieClip;
      
      public function ActionManager(param1:Function, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:Sprite, param6:MovieClip, param7:MovieClip)
      {
         super();
         if(this.setActionCallback != null)
         {
            throw new Error("ERROR: Singleton ActionManager did not expect to be created twice!");
         }
         this.setActionCallback = param1;
         this.actionBtn = param2;
         this.actionBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler,false,0,true);
         this.actionWindow = param3;
         this.addAllActions();
         this.actionWindow.addChild(this._actions);
         this.actionWindow.poseBtns = this._actions.poseBtns;
         this.actionWindow.diveBtn = this._actions.diveBtn;
         this.actionWindow.swirlBtn = this._actions.swirlBtn;
         this.actionWindow.visible = false;
         this.emoteBtn = param4;
         this.emoteWindow = param5;
         this.safeChatBtn = param6;
         this.safeChatTree = param7;
      }
      
      public function turnOnOceanActions(param1:Boolean) : void
      {
         this.actionWindow.poseBtns.visible = param1;
         this.actionWindow.diveBtn.visible = param1;
         this.actionWindow.swirlBtn.visible = param1;
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:Sprite, param5:MovieClip, param6:MovieClip) : void
      {
         if(this.actionBtn)
         {
            this.actionBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler);
         }
         this.actionBtn = param1;
         this.actionBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler,false,0,true);
         while(this.actionWindow.numChildren > 2)
         {
            this.actionWindow.removeChildAt(this.actionWindow.numChildren - 1);
         }
         this.actionWindow = param2;
         while(this.actionWindow.numChildren > 2)
         {
            this.actionWindow.removeChildAt(this.actionWindow.numChildren - 1);
         }
         this.actionWindow.addChild(this._actions);
         this.actionWindow.poseBtns = this._actions.poseBtns;
         this.actionWindow.diveBtn = this._actions.diveBtn;
         this.actionWindow.swirlBtn = this._actions.swirlBtn;
         this.actionWindow.visible = false;
         this.emoteBtn = param3;
         this.emoteWindow = param4;
         this.actionWindow = param2;
         this.safeChatBtn = param5;
         this.safeChatTree = param6;
      }
      
      private function addAllActions() : void
      {
         var _loc3_:uint = 0;
         var _loc13_:Sprite = null;
         var _loc14_:Sprite = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc1_:uint = 10;
         var _loc2_:uint = 25;
         _loc3_ = 40;
         var _loc4_:uint = 91;
         var _loc5_:uint = 2;
         var _loc6_:Number = -72;
         var _loc7_:Number = -50;
         var _loc8_:Number = -88;
         var _loc9_:int = 4;
         var _loc10_:int = 2;
         var _loc11_:int = 8;
         this._actions = new MovieClip();
         var _loc12_:uint = 0;
         while(_loc12_ < this.actionSprites.length)
         {
            if(_loc12_ < _loc11_)
            {
               _loc13_ = new (getDefinitionByName(_loc12_ < _loc9_ ? "sitBtns" : this.actionSprites[_loc12_]) as Class)();
               if(_loc12_ == 0)
               {
                  _loc13_.x = this.actionWindow.width * 0.5 + _loc6_ - _loc2_ - 4;
                  _loc13_.y = _loc1_ + Math.floor(_loc12_ / _loc5_) * _loc3_ + _loc7_;
                  this._actions.addChild(_loc13_);
                  _loc15_ = 1;
                  while(_loc15_ <= 4)
                  {
                     _loc14_ = _loc13_["sit" + _loc15_ + "Btn"];
                     _loc14_.buttonMode = true;
                     _loc14_.useHandCursor = true;
                     _loc14_.mouseChildren = false;
                     _loc14_.tabEnabled = true;
                     _loc14_.tabChildren = false;
                     _loc14_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
                     _loc15_++;
                  }
               }
               else if(_loc12_ >= _loc9_)
               {
                  _loc13_.x = _loc2_ + (_loc12_ % _loc5_ * _loc4_ + _loc6_);
                  _loc13_.y = _loc1_ + Math.floor(_loc12_ / _loc5_) * _loc3_ + _loc8_;
                  this._actions.addChild(_loc13_);
                  _loc13_.buttonMode = true;
                  _loc13_.useHandCursor = true;
                  _loc13_.mouseChildren = false;
                  _loc13_.tabEnabled = true;
                  _loc13_.tabChildren = false;
                  _loc13_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
               }
            }
            else
            {
               _loc13_ = new (getDefinitionByName(_loc12_ == _loc11_ ? "poseBtns" : this.actionSprites[_loc12_]) as Class)();
               if(_loc12_ == _loc11_)
               {
                  _loc13_.visible = false;
                  this._actions.poseBtns = _loc13_;
                  _loc13_.x = this.actionWindow.width * 0.5 + _loc6_ - _loc2_ - 4;
                  _loc13_.y = _loc1_ + Math.floor((_loc12_ - _loc11_) / _loc5_) * _loc3_ + _loc7_;
                  this._actions.addChild(_loc13_);
                  _loc16_ = 1;
                  while(_loc16_ <= 2)
                  {
                     _loc14_ = _loc13_["pose" + _loc16_ + "Btn"];
                     _loc14_.buttonMode = true;
                     _loc14_.useHandCursor = true;
                     _loc14_.mouseChildren = false;
                     _loc14_.tabEnabled = true;
                     _loc14_.tabChildren = false;
                     _loc14_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
                     _loc16_++;
                  }
               }
               else if(_loc12_ >= _loc11_ + _loc10_)
               {
                  _loc13_.visible = false;
                  if(_loc12_ == this.actionSprites.length - 1)
                  {
                     this._actions.diveBtn = _loc13_;
                  }
                  else
                  {
                     this._actions.swirlBtn = _loc13_;
                  }
                  _loc13_.x = _loc2_ + ((_loc12_ - 5) % _loc5_ * _loc4_ + _loc6_);
                  _loc13_.y = _loc1_ + Math.floor((_loc12_ - 5) / _loc5_) * _loc3_ + _loc8_;
                  this._actions.addChild(_loc13_);
                  _loc13_.buttonMode = true;
                  _loc13_.useHandCursor = true;
                  _loc13_.mouseChildren = false;
                  _loc13_.tabEnabled = true;
                  _loc13_.tabChildren = false;
                  _loc13_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
               }
            }
            _loc12_++;
         }
         this.actionStrings = new Object();
         this.actionStrings["sit1BtnCont"] = this.actionStrings["pose1BtnCont"] = [":sitNW:",":poseLeft:"];
         this.actionStrings["sit2BtnCont"] = [":sitNE:"];
         this.actionStrings["sit3BtnCont"] = [":sitSE:"];
         this.actionStrings["sit4BtnCont"] = this.actionStrings["pose2BtnCont"] = [":sitSW:",":poseRight:"];
         this.actionStrings["danceAnim_btnCont"] = [":dance:"];
         this.actionStrings["sleepAnim_btnCont"] = this.actionStrings["diveAnim_btnCont"] = [":sleep:",":dive:"];
         this.actionStrings["hopAnim_btnCont"] = this.actionStrings["swirlAnim_btnCont"] = [":hop:",":swirl:"];
         this.actionStrings["playAnim_btnCont"] = [":play:"];
      }
      
      public function destroy() : void
      {
         this.setActionCallback = null;
         this.actionBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler);
         this.actionBtn = null;
         this.actionWindow.visible = false;
         this.actionWindow = null;
         this.emoteBtn = null;
         this.emoteWindow = null;
         this.safeChatBtn = null;
         this.safeChatTree = null;
      }
      
      public function getActionString(param1:Sprite) : String
      {
         var _loc2_:String = param1["constructor"].toString();
         var _loc3_:String = _loc2_.slice(7,_loc2_.length - 1);
         if(this.actionStrings[_loc3_])
         {
            if(this.actionStrings[_loc3_].length > 1)
            {
               return this.actionStrings[_loc2_.slice(7,_loc2_.length - 1)][AvatarManager.roomEnviroType == Utility.ENVIRO_LAND ? 0 : 1];
            }
            return this.actionStrings[_loc2_.slice(7,_loc2_.length - 1)][0];
         }
         return null;
      }
      
      public function matchActionString(param1:String) : Sprite
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         for each(_loc2_ in this.actionSprites)
         {
            _loc3_ = int(this.actionStrings[_loc2_].indexOf(param1));
            if(_loc3_ != -1)
            {
               if(this.actionStrings[_loc2_].length <= 1)
               {
                  return new (getDefinitionByName(_loc2_) as Class)();
               }
               if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND ? _loc3_ == 0 : _loc3_ == 1)
               {
                  return new (getDefinitionByName(_loc2_) as Class)();
               }
            }
         }
         return null;
      }
      
      public function openActions() : void
      {
         if(!this.actionWindow.visible)
         {
            this.actionWindow.visible = true;
            this.brightenActions();
         }
      }
      
      public function dimActions() : void
      {
         if(this.actionWindow.visible && this.actionWindow.alpha != this.ACTIONWINDOW_DIM_ALPHA)
         {
            this.actionWindow.alpha = this.ACTIONWINDOW_DIM_ALPHA;
         }
      }
      
      public function brightenActions() : void
      {
         if(this.actionWindow.alpha != this.ACTIONWINDOW_BRIGHT_ALPHA)
         {
            this.actionWindow.alpha = this.ACTIONWINDOW_BRIGHT_ALPHA;
         }
      }
      
      public function closeActions() : void
      {
         if(this.actionWindow.visible)
         {
            this.actionWindow.visible = false;
            this.brightenActions();
            this.actionBtn.downToUpState();
         }
      }
      
      private function actionBtnDownHandler(param1:MouseEvent) : void
      {
         if(this.actionWindow.visible)
         {
            this.closeActions();
         }
         else
         {
            if(this.safeChatTree.visible)
            {
               this.safeChatBtn.dispatchEvent(param1);
            }
            if(this.emoteWindow.visible)
            {
               this.emoteBtn.dispatchEvent(param1);
            }
            this.openActions();
         }
      }
      
      private function actionClickHandler(param1:MouseEvent) : void
      {
         this.setActionCallback(new param1.target.constructor());
         this.actionBtn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
         param1.currentTarget.downToUpState();
      }
   }
}

