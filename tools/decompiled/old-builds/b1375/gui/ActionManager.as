package gui
{
   import avatar.AvatarManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import pet.WorldPet;
   
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
      
      private var _petActions:MovieClip;
      
      private var _views:Array;
      
      private var _titleBanner:Sprite;
      
      public function ActionManager(param1:Function, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:Sprite, param6:MovieClip, param7:MovieClip)
      {
         super();
         if(setActionCallback != null)
         {
            throw new Error("ERROR: Singleton ActionManager did not expect to be created twice!");
         }
         setActionCallback = param1;
         actionBtn = param2;
         actionBtn.addEventListener("mouseDown",actionBtnDownHandler,false,0,true);
         actionWindow = param3;
         addAllActions();
         actionWindow.addChild(_actions);
         actionWindow.addChild(_petActions);
         _petActions.visible = false;
         actionWindow.poseBtns = _actions.poseBtns;
         actionWindow.diveBtn = _actions.diveBtn;
         actionWindow.swirlBtn = _actions.swirlBtn;
         actionWindow.sitBtns = _actions.sitBtns;
         actionWindow.visible = false;
         emoteBtn = param4;
         emoteWindow = param5;
         safeChatBtn = param6;
         safeChatTree = param7;
         setupTitleBanner();
      }
      
      public function turnOnOceanActions(param1:Boolean) : void
      {
         actionWindow.poseBtns.visible = param1;
         actionWindow.diveBtn.visible = param1;
         actionWindow.swirlBtn.visible = param1;
         actionWindow.sitBtns.visible = !param1;
      }
      
      public function turnOnPetActions(param1:Boolean) : void
      {
         if(param1)
         {
            _petActions.visible = true;
            _actions.visible = false;
         }
         else
         {
            _petActions.visible = false;
            _actions.visible = true;
         }
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:Sprite, param5:MovieClip, param6:MovieClip, param7:Function) : void
      {
         setActionCallback = param7;
         if(actionBtn)
         {
            actionBtn.removeEventListener("mouseDown",actionBtnDownHandler);
         }
         actionBtn = param1;
         actionBtn.addEventListener("mouseDown",actionBtnDownHandler,false,0,true);
         while(actionWindow.numChildren > 2)
         {
            actionWindow.removeChildAt(actionWindow.numChildren - 1);
         }
         actionWindow = param2;
         addAllActions();
         actionWindow.addChild(_actions);
         actionWindow.addChild(_petActions);
         _petActions.visible = false;
         actionWindow.poseBtns = _actions.poseBtns;
         actionWindow.diveBtn = _actions.diveBtn;
         actionWindow.swirlBtn = _actions.swirlBtn;
         actionWindow.sitBtns = _actions.sitBtns;
         actionWindow.visible = false;
         emoteBtn = param3;
         emoteWindow = param4;
         actionWindow = param2;
         safeChatBtn = param5;
         safeChatTree = param6;
         actionBtn.downToUpState();
         setupTitleBanner();
      }
      
      private function addAllActions() : void
      {
         var _loc13_:* = 0;
         _loc13_ = 10;
         var _loc7_:* = 0;
         _loc7_ = 25;
         var _loc16_:* = 0;
         _loc16_ = 40;
         var _loc8_:* = 0;
         _loc8_ = 91;
         var _loc3_:* = 0;
         _loc3_ = 2;
         var _loc11_:Number = NaN;
         _loc11_ = -72;
         var _loc12_:Number = NaN;
         _loc12_ = -50;
         var _loc5_:Number = NaN;
         _loc5_ = -88;
         var _loc1_:int = 0;
         _loc1_ = 4;
         var _loc15_:int = 0;
         _loc15_ = 2;
         var _loc14_:int = 0;
         _loc14_ = 8;
         var _loc9_:* = 0;
         var _loc2_:Sprite = null;
         var _loc10_:Sprite = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         _actions = new MovieClip();
         _petActions = new MovieClip();
         _loc9_ = 0;
         while(_loc9_ < actionSprites.length)
         {
            if(_loc9_ < 8)
            {
               _loc2_ = GETDEFINITIONBYNAME(_loc9_ < 4 ? "sitBtns" : actionSprites[_loc9_]);
               if(_loc9_ == 0)
               {
                  _loc2_.x = actionWindow.ba.width * 0.5 + -72 - 25 - 5;
                  _loc2_.y = 10 + Math.floor(_loc9_ / 2) * 40 + -50;
                  _actions.addChild(_loc2_);
                  _actions.sitBtns = _loc2_;
                  _loc4_ = 1;
                  while(_loc4_ <= 4)
                  {
                     _loc10_ = _loc2_["sit" + _loc4_ + "Btn"];
                     _loc10_.buttonMode = true;
                     _loc10_.useHandCursor = true;
                     _loc10_.tabEnabled = true;
                     _loc10_.tabChildren = false;
                     _loc10_.addEventListener("mouseDown",actionClickHandler,false,0,true);
                     _loc4_++;
                  }
               }
               else if(_loc9_ >= 4)
               {
                  _loc2_.x = 25 + (_loc9_ % 2 * 91 + -72);
                  _loc2_.y = 10 + Math.floor(_loc9_ / 2) * 40 + -88;
                  _actions.addChild(_loc2_);
                  _loc2_.buttonMode = true;
                  _loc2_.useHandCursor = true;
                  _loc2_.tabEnabled = true;
                  _loc2_.tabChildren = false;
                  _loc2_.addEventListener("mouseDown",actionClickHandler,false,0,true);
               }
            }
            else
            {
               _loc2_ = GETDEFINITIONBYNAME(_loc9_ == 8 ? "poseBtns" : actionSprites[_loc9_]);
               if(_loc9_ == 8)
               {
                  _loc2_.visible = false;
                  _actions.poseBtns = _loc2_;
                  _loc2_.x = actionWindow.ba.width * 0.5 + -72 - 25 - 5;
                  _loc2_.y = 10 + Math.floor((_loc9_ - 8) / 2) * 40 + -50;
                  _actions.addChild(_loc2_);
                  _loc6_ = 1;
                  while(_loc6_ <= 2)
                  {
                     _loc10_ = _loc2_["pose" + _loc6_ + "Btn"];
                     _loc10_.buttonMode = true;
                     _loc10_.useHandCursor = true;
                     _loc10_.tabEnabled = true;
                     _loc10_.tabChildren = false;
                     _loc10_.addEventListener("mouseDown",actionClickHandler,false,0,true);
                     _loc6_++;
                  }
               }
               else if(_loc9_ >= 8 + 2)
               {
                  _loc2_.visible = false;
                  if(_loc9_ == actionSprites.length - 1)
                  {
                     _actions.diveBtn = _loc2_;
                  }
                  else
                  {
                     _actions.swirlBtn = _loc2_;
                  }
                  _loc2_.x = 25 + ((_loc9_ - 5) % 2 * 91 + -72);
                  _loc2_.y = 10 + Math.floor((_loc9_ - 5) / 2) * 40 + -88;
                  _actions.addChild(_loc2_);
                  _loc2_.buttonMode = true;
                  _loc2_.useHandCursor = true;
                  _loc2_.tabEnabled = true;
                  _loc2_.tabChildren = false;
                  _loc2_.addEventListener("mouseDown",actionClickHandler,false,0,true);
               }
            }
            _loc9_++;
         }
         _loc2_ = GETDEFINITIONBYNAME("playPetAnim_btnCont");
         _loc2_.y = -31;
         _loc2_.buttonMode = true;
         _loc2_.useHandCursor = true;
         _loc2_.tabEnabled = true;
         _loc2_.tabChildren = false;
         _loc2_.addEventListener("mouseDown",onPetPlayBtn,false,0,true);
         _petActions.addChild(_loc2_);
         _loc2_ = GETDEFINITIONBYNAME("dancePetAnim_btnCont");
         _petActions.danceBtn = _loc2_;
         _loc2_.y = 31;
         _loc2_.buttonMode = true;
         _loc2_.useHandCursor = true;
         _loc2_.tabEnabled = true;
         _loc2_.tabChildren = false;
         _loc2_.addEventListener("mouseDown",actionClickHandler,false,0,true);
         _petActions.addChild(_loc2_);
         actionStrings = {};
         actionStrings["sit1BtnCont"] = actionStrings["pose1BtnCont"] = [":sitNW:",":poseLeft:"];
         actionStrings["sit2BtnCont"] = [":sitNE:"];
         actionStrings["sit3BtnCont"] = [":sitSE:"];
         actionStrings["sit4BtnCont"] = actionStrings["pose2BtnCont"] = [":sitSW:",":poseRight:"];
         actionStrings["danceAnim_btnCont"] = actionStrings["dancePetAnim_btnCont"] = [":dance:"];
         actionStrings["sleepAnim_btnCont"] = actionStrings["diveAnim_btnCont"] = [":sleep:",":dive:"];
         actionStrings["hopAnim_btnCont"] = actionStrings["swirlAnim_btnCont"] = [":hop:",":swirl:"];
         actionStrings["playAnim_btnCont"] = [":play:"];
      }
      
      private function setupTitleBanner() : void
      {
         if(emoteWindow.name.indexOf("Quest") == -1)
         {
            if(_titleBanner)
            {
               if(!actionWindow.contains(_titleBanner))
               {
                  actionWindow.addChild(_titleBanner);
               }
            }
            else
            {
               _titleBanner = GETDEFINITIONBYNAME("AnimsTitleBanner");
               _titleBanner.x = -91.75;
               _titleBanner.y = -91.25;
               actionWindow.addChild(_titleBanner);
            }
         }
      }
      
      public function destroy() : void
      {
         setActionCallback = null;
         actionBtn.removeEventListener("mouseDown",actionBtnDownHandler);
         actionBtn = null;
         actionWindow.visible = false;
         actionWindow = null;
         emoteBtn = null;
         emoteWindow = null;
         safeChatBtn = null;
         safeChatTree = null;
      }
      
      public function getActionString(param1:Sprite) : String
      {
         var _loc3_:String = param1["constructor"].toString();
         var _loc2_:String = _loc3_.slice(7,_loc3_.length - 1);
         if(actionStrings[_loc2_])
         {
            if(actionStrings[_loc2_].length > 1)
            {
               return actionStrings[_loc3_.slice(7,_loc3_.length - 1)][AvatarManager.roomEnviroType == 0 ? 0 : 1];
            }
            return actionStrings[_loc3_.slice(7,_loc3_.length - 1)][0];
         }
         return null;
      }
      
      public function matchActionString(param1:String) : Sprite
      {
         var _loc3_:int = 0;
         for each(var _loc2_:String in actionSprites)
         {
            _loc3_ = int(actionStrings[_loc2_].indexOf(param1));
            if(_loc3_ != -1)
            {
               if(actionStrings[_loc2_].length <= 1)
               {
                  return GETDEFINITIONBYNAME(_loc2_);
               }
               if(AvatarManager.roomEnviroType == 0 ? _loc3_ == 0 : _loc3_ == 1)
               {
                  return GETDEFINITIONBYNAME(_loc2_);
               }
            }
         }
         return null;
      }
      
      public function openActions() : void
      {
         if(!actionWindow.visible)
         {
            actionWindow.visible = true;
            brightenActions();
         }
      }
      
      public function dimActions() : void
      {
         if(actionWindow.visible && actionWindow.alpha != 0.5)
         {
            actionWindow.alpha = 0.5;
         }
      }
      
      public function brightenActions() : void
      {
         if(actionWindow.alpha != 1)
         {
            actionWindow.alpha = 1;
         }
      }
      
      public function closeActions() : void
      {
         if(actionWindow.visible)
         {
            actionWindow.visible = false;
            brightenActions();
            actionBtn.downToUpState();
         }
      }
      
      public function grayOutPetDanceBtn(param1:Boolean) : void
      {
         if(_petActions)
         {
            _petActions.danceBtn.activateGrayState(param1);
         }
      }
      
      private function actionBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(actionWindow.visible)
            {
               closeActions();
            }
            else
            {
               if(safeChatTree.visible)
               {
                  safeChatBtn.dispatchEvent(param1);
               }
               if(emoteWindow.visible)
               {
                  emoteBtn.dispatchEvent(param1);
               }
               openActions();
            }
         }
      }
      
      private function actionClickHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!actionBtn.isGray && !param1.currentTarget.isGray)
         {
            setActionCallback(new param1.currentTarget.constructor());
            actionBtn.dispatchEvent(new MouseEvent("mouseDown"));
            param1.currentTarget.downToUpState();
         }
      }
      
      private function onPetPlayBtn(param1:MouseEvent) : void
      {
         var _loc2_:WorldPet = null;
         param1.stopPropagation();
         if(AvatarManager.playerAvatarWorldView)
         {
            _loc2_ = AvatarManager.playerAvatarWorldView.getActivePet();
            if(_loc2_)
            {
               AvatarManager.playerAvatarWorldView.faceAnim(0,0,false);
               _loc2_.onClick(param1);
            }
         }
         actionBtn.dispatchEvent(new MouseEvent("mouseDown"));
         param1.currentTarget.downToUpState();
      }
   }
}

