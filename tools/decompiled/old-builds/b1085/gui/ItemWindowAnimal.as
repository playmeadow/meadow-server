package gui
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarSwitch;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ItemWindowAnimal extends ItemWindowBase
   {
      
      private const COST_OF_NEW_ANIMAL:int = 1000;
      
      private const SLOTS_PER_NONMEMBER:int = 2;
      
      private var _isChoosing:Boolean;
      
      private var _isAnimal:Boolean;
      
      private var _recyclingOnly:Boolean;
      
      private var _addGrayChild:Boolean;
      
      private var _isChoosingOcean:Boolean;
      
      private var _ai:AvatarInfo;
      
      private var _nameBarData:int;
      
      public function ItemWindowAnimal(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._isChoosing = param9.isChoosing;
         this._isAnimal = param9.isAnimal;
         this._recyclingOnly = param9.recylingOnly;
         this._isChoosingOcean = param9.isChoosingOcean;
         this._nameBarData = param9.nameBarData;
         super("amlCont",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get aml() : MovieClip
      {
         return _window.aml;
      }
      
      public function get makeNew() : MovieClip
      {
         return _window.makeNew;
      }
      
      public function get recycle() : MovieClip
      {
         return _window.recycle;
      }
      
      public function get den() : MovieClip
      {
         return _window.den;
      }
      
      public function get lock() : MovieClip
      {
         return _window.lock;
      }
      
      public function get gray() : MovieClip
      {
         return _window.gray;
      }
      
      public function get checkbox() : MovieClip
      {
         return _window.checkbox;
      }
      
      public function get buyDen() : MovieClip
      {
         return _window.buyDen;
      }
      
      public function set currItem(param1:Object) : void
      {
         _currItem = param1;
      }
      
      public function get level() : int
      {
         return this._ai ? this._ai.questLevel : 0;
      }
      
      public function resetWindow(param1:int) : void
      {
         if(this._isAnimal)
         {
            _window.makeNew.visible = true;
            _window.priceTag.visible = false;
            _window.buy.visible = false;
            _window.lock.visible = false;
            _window.aml.visible = false;
            _window.aml.sel.visible = false;
            _window.recycle.visible = false;
            _window.gray.visible = false;
            _window.lock.visible = false;
            _window.makeNew.newAmlBtn.gray.visible = false;
            _window.xpShape.visible = false;
            --AvatarSwitch.numOpenNonMemberSlots;
            _isCurrItemLoaded = false;
            this.loadCurrItem();
         }
         else
         {
            if(param1 > 0)
            {
               while(_window.den.itemBlock.numChildren > 0)
               {
                  _window.den.itemBlock.removeChildAt(0);
               }
            }
            _window.buyDen.visible = true;
            _window.den.visible = false;
            _window.priceTag.visible = false;
            _window.buy.visible = false;
            _window.lock.visible = false;
            _window.aml.visible = false;
            _window.aml.sel.visible = false;
            _window.recycle.visible = false;
            _window.gray.visible = false;
         }
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Avatar = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(this._isAnimal)
         {
            if(!_isCurrItemLoaded)
            {
               _loc3_ = SwitchManager.NUM_AVATAR_SLOTS;
               _window.gray.grayDen.visible = false;
               _window.aml.bg.visible = true;
               _window.aml.gray.visible = false;
               _window.aml.nameTxt.visible = true;
               _window.priceTag.txt.text = this.COST_OF_NEW_ANIMAL;
               _window.aml.visible = true;
               _loc4_ = AvatarSwitch.avatars[_index];
               _loc5_ = AvatarSwitch.numNonMemberAvatars;
               _loc6_ = AvatarSwitch.numNonMemberOceanAvatars;
               if(_loc4_ != null)
               {
                  if(AvatarSwitch.isSlotAvailable(_index) || this._isChoosing)
                  {
                     _window.priceTag.visible = false;
                     _window.buy.visible = false;
                     _window.makeNew.visible = false;
                     _window.lock.visible = false;
                     _window.aml.visible = true;
                     _window.aml.sel.visible = false;
                     _window.aml.nameTxt.text = _loc4_.avName;
                     if(this._isChoosing)
                     {
                        _window.checkbox.visible = true;
                        _window.checkbox.check.visible = false;
                        _window.aml.bg.visible = false;
                        _window.aml.gray.visible = true;
                        if(_loc5_ > 0 && _loc5_ < 3)
                        {
                           if(!AvatarSwitch.isMemberOnlyAvatar(_index))
                           {
                              _window.checkbox.check.visible = false;
                           }
                        }
                        if(_loc5_ - _loc6_ < 1 || _loc5_ <= _loc3_ && AvatarSwitch.isMemberOnlyAvatar(_index))
                        {
                           _window.aml.visible = false;
                           _window.gray.visible = true;
                           _window.lock.visible = true;
                           _window.checkbox.visible = false;
                           _window.gray.nameTxt.text = _loc4_.avName;
                           this._addGrayChild = true;
                        }
                     }
                     else if(!this._isChoosingOcean)
                     {
                        _window.recycle.visible = false;
                     }
                     if(_index == AvatarSwitch.activeAvatarIdx)
                     {
                        _window.aml.sel.visible = true;
                     }
                     while(_window.xpShape.numChildren > 0)
                     {
                        _window.xpShape.removeChildAt(0);
                     }
                     this._ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenDbAvId(_loc4_.userName,_loc4_.dbAvId);
                     if(Boolean(this._ai) && this._ai.questLevel > 0)
                     {
                        this.loadQuestShape();
                     }
                     if(this._isChoosing)
                     {
                        if(!gMainFrame.userInfo.isMember && !AvatarSwitch.isMemberOnlyAvatar(_index))
                        {
                           ++AvatarSwitch.numOpenNonMemberSlots;
                        }
                     }
                     else
                     {
                        ++AvatarSwitch.numOpenNonMemberSlots;
                     }
                  }
                  else
                  {
                     _window.aml.visible = false;
                     _window.gray.visible = true;
                     _window.gray.nameTxt.text = _loc4_.avName;
                     this._addGrayChild = true;
                     _window.gray.amlMask.amlBox.addChild(_currItem);
                  }
                  if(Utility.isOcean(_currItem.avatarData.enviroTypeFlag))
                  {
                     if(Utility.isLand(_currItem.avatarData.enviroTypeFlag))
                     {
                        if(_window.aml.visible)
                        {
                           if(_window.aml.gray.visible)
                           {
                              _window.aml.gray.gotoAndStop(3);
                           }
                           else
                           {
                              _window.aml.bg.gotoAndStop(3);
                           }
                        }
                        else
                        {
                           _window.gray.grayAml.gotoAndStop(3);
                        }
                     }
                     else if(_window.aml.visible)
                     {
                        if(_window.aml.gray.visible)
                        {
                           _window.aml.gray.gotoAndStop(2);
                        }
                        else
                        {
                           _window.aml.bg.gotoAndStop(2);
                        }
                     }
                     else
                     {
                        _window.gray.grayAml.gotoAndStop(2);
                     }
                  }
               }
               else
               {
                  if(!gMainFrame.userInfo.isMember)
                  {
                     if(AvatarSwitch.numOpenNonMemberSlots < this.SLOTS_PER_NONMEMBER || this._isChoosing && _loc5_ - _loc6_ < 1)
                     {
                        ++AvatarSwitch.numOpenNonMemberSlots;
                        _window.makeNew.visible = true;
                        _window.lock.visible = false;
                     }
                     else
                     {
                        _window.makeNew.visible = false;
                        _window.lock.visible = true;
                     }
                  }
                  else
                  {
                     _window.makeNew.visible = true;
                     _window.lock.visible = false;
                  }
                  _window.priceTag.visible = false;
                  _window.buy.visible = false;
                  _window.aml.visible = false;
                  _window.aml.sel.visible = false;
                  _window.recycle.visible = false;
                  if(this._isChoosing && AvatarSwitch.numNonMemberAvatars > 1 && _loc5_ - _loc6_ > 0)
                  {
                     _window.makeNew.newAmlBtn.gray.visible = true;
                  }
                  else
                  {
                     _window.makeNew.newAmlBtn.gray.visible = false;
                  }
                  _isCurrItemLoaded = true;
               }
            }
         }
         else if(_currItem != null)
         {
            if(!_isCurrItemLoaded)
            {
               _isCurrItemLoaded = true;
               _window.den.sel.visible = false;
               if(gMainFrame.userInfo.isMember)
               {
                  _window.den.visible = true;
                  _window.den.txt.text = _currItem.name;
               }
               else if(_currItem.isMemberOnly)
               {
                  this._addGrayChild = true;
                  _window.den.visible = false;
                  _window.gray.visible = true;
                  _window.gray.nameTxt.text = _currItem.name;
               }
               else
               {
                  _window.den.visible = true;
                  _window.den.txt.text = _currItem.name;
               }
               if(_currItem.isLand)
               {
                  _window.den.greenBG.visible = true;
               }
               else
               {
                  _window.den.greenBG.visible = false;
               }
               if(_index == DenSwitch.activeDenIdx)
               {
                  _window.den.sel.visible = true;
               }
               _window.buyDen.visible = false;
               if(this._recyclingOnly)
               {
                  _window.recycle.visible = true;
               }
               else
               {
                  _window.recycle.visible = false;
               }
            }
         }
         else
         {
            _window.den.visible = false;
            _window.buyDen.visible = true;
         }
         if(Boolean(_currItem) && Boolean(!_isCurrItemLoaded) && this._isAnimal)
         {
            _isCurrItemLoaded = true;
            if(_iconLayerName != "" && _currItem.hasOwnProperty(_iconLayerName))
            {
               if(this._addGrayChild)
               {
                  _window.gray.amlMask.amlBox.addChild(_currItem[_iconLayerName]);
               }
               else
               {
                  _window.aml.amlMask.amlBox.addChild(_currItem[_iconLayerName]);
               }
            }
            else if(this._addGrayChild)
            {
               _window.gray.amlMask.amlBox.addChild(_currItem);
            }
            else
            {
               _window.aml.amlMask.amlBox.addChild(_currItem);
            }
         }
      }
      
      private function loadQuestShape() : void
      {
         var _loc1_:String = _window.xpShape.currentLabels[Utility.getColorId(this._nameBarData) - 1].name;
         _window.xpShape.visible = true;
         if(_loc1_ == "black")
         {
            _window.xpShape.gotoAndStop(2);
            _window.xpShape.gotoAndStop(_loc1_);
         }
         if(_window.xpShape.currentFrameLabel != _loc1_)
         {
            _window.xpShape.gotoAndStop(_loc1_);
         }
         Utility.createXpShape(this._ai.questLevel,true,_window.xpShape[_loc1_].mouse.up.icon,null,this._nameBarData);
      }
      
      override public function destroy() : void
      {
         AvatarSwitch.numOpenNonMemberSlots = 0;
         super.destroy();
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.priceTag.visible = false;
         _window.priceTag.txt.textColor = "0x386630";
         _window.buy.visible = false;
         _window.makeNew.visible = false;
         _window.lock.visible = false;
         _window.recycle.visible = false;
         _window.den.visible = false;
         _window.buyDen.visible = false;
         _window.xpShape.visible = false;
         if(this._isAnimal)
         {
            _window.aml.visible = true;
            _window.aml.bg.visible = false;
            _window.aml.gray.visible = true;
            _window.aml.sel.visible = false;
            _window.aml.nameTxt.visible = false;
         }
         else
         {
            _window.aml.visible = false;
         }
         _window.gray.visible = false;
         _window.buyDen.buyBtn.gray.visible = false;
         _window.buy.buyAmlBtn.gray.visible = false;
         _window.makeNew.newAmlBtn.gray.visible = false;
         _window.checkbox.visible = false;
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
         {
            if(_mouseDown != null)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener(MouseEvent.ROLL_OVER,_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener(MouseEvent.ROLL_OUT,_mouseOut,false,0,true);
            }
            if(_memberOnlyDown != null)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_memberOnlyDown,false,0,true);
            }
         }
      }
   }
}

