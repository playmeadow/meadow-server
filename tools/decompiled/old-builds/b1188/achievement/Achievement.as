package achievement
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class Achievement
   {
      
      public static var GEMS_EARNED:int = 1;
      
      public static var GEMS_SPENT:int = 2;
      
      public static var SHOP_DEN_ITEM:int = 3;
      
      public static var SHOP_ACCESSORY:int = 4;
      
      public static var MAIL_SEND:int = 38;
      
      public static var MAIL_GIFT:int = 39;
      
      public static var BUDDY_ADDED:int = 40;
      
      public static var MEMBER_NEW:int = 66;
      
      public static var HOLIDAY_BANNER:int = 409;
      
      public static var BASE_MEDAL_ID:int = 289;
      
      public static var BASE_RIBBON_ID:int = 290;
      
      public static var BASE_TROPHY_ID:int = 291;
      
      private var _invId:int;
      
      private var _baseImageMediaId:int;
      
      private var _iconMediaId:int;
      
      private var _name:String;
      
      private var _descr:String;
      
      private var _mediaText:String;
      
      private var _nameId:int;
      
      private var _baseImage:Sprite;
      
      private var _baseImageHelper:MediaHelper;
      
      private var _icon:Sprite;
      
      private var _iconHelper:MediaHelper;
      
      private var _baseImageReceived:Boolean;
      
      private var _iconReceived:Boolean;
      
      private var _isMyAchievement:Boolean;
      
      private var _scalePercent:Number = 1;
      
      private var _xPos:Number = 0;
      
      private var _yPos:Number = 0;
      
      public function Achievement()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:int, param4:int, param5:String = "", param6:Boolean = false) : void
      {
         var _loc7_:Array = null;
         this._invId = param1;
         this._baseImageMediaId = param2;
         this._iconMediaId = param3;
         this._nameId = param4;
         this._name = LocalizationManager.translateIdOnly(param4);
         if(param5 == "")
         {
            this._mediaText = param5;
         }
         else
         {
            _loc7_ = param5.split(",");
            if(_loc7_.length > 1)
            {
               this._mediaText = Utility.convertNumberToString(int(_loc7_.join("")));
            }
            else
            {
               this._mediaText = param5;
            }
         }
         this._isMyAchievement = param6;
         this._baseImage = new Sprite();
         this._baseImageHelper = new MediaHelper();
         this._baseImageHelper.init(this._baseImageMediaId,this.baseImageReceived);
         this._icon = new Sprite();
         this._iconHelper = new MediaHelper();
         this._iconHelper.init(this._iconMediaId,this.iconReceived);
      }
      
      public function destroy() : void
      {
         if(this._iconHelper)
         {
            this._iconHelper.destroy();
         }
         if(this._baseImageHelper)
         {
            this._baseImageHelper.destroy();
         }
      }
      
      public function clone() : Achievement
      {
         var _loc1_:Achievement = null;
         _loc1_ = new Achievement();
         _loc1_.init(this._invId,this._baseImageMediaId,this._iconMediaId,this._nameId,this._mediaText,this._isMyAchievement);
         return _loc1_;
      }
      
      public function setScale(param1:Number) : void
      {
         this._scalePercent = param1;
         if(this._iconReceived && this._baseImageReceived)
         {
            this._baseImage.scaleX = this._scalePercent;
            this._baseImage.scaleY = this._scalePercent;
         }
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         this._xPos = param1;
         this._yPos = param2;
         if(this._iconReceived && this._baseImageReceived)
         {
            this._baseImage.x = -this._baseImage.width * this._xPos;
            this._baseImage.y = -this._baseImage.height * this._yPos;
         }
      }
      
      private function baseImageReceived(param1:MovieClip) : void
      {
         var _loc2_:Number = NaN;
         if(param1)
         {
            param1 = MovieClip(param1.getChildAt(0));
            this._baseImage.addChild(param1);
            if(this._iconReceived)
            {
               param1.itemBlock.addChild(this._icon);
               this.allImagesLoaded();
            }
            if(this._mediaText == "")
            {
               param1.num.visible = false;
            }
            else
            {
               param1.num.txt.text = this._mediaText;
               _loc2_ = Number(param1.num.txt.textWidth);
               if(_loc2_ > 15)
               {
                  if(_loc2_ > 25)
                  {
                     param1.num.gotoAndStop(3);
                  }
                  else
                  {
                     param1.num.gotoAndStop(2);
                  }
               }
            }
            this._baseImageHelper.destroy();
            this._baseImageHelper = null;
            this._baseImageReceived = true;
         }
      }
      
      private function iconReceived(param1:MovieClip) : void
      {
         if(param1)
         {
            this._icon.addChild(param1);
            if(this._baseImageReceived)
            {
               MovieClip(this._baseImage.getChildAt(0)).itemBlock.addChild(this._icon);
               this.allImagesLoaded();
            }
            this._iconHelper.destroy();
            this._iconHelper = null;
            this._iconReceived = true;
         }
      }
      
      private function allImagesLoaded() : void
      {
         var _loc1_:Number = 0.9;
         if(this._isMyAchievement)
         {
            _loc1_ = 1;
         }
         this._baseImage.scaleX = _loc1_ * this._scalePercent;
         this._baseImage.scaleY = _loc1_ * this._scalePercent;
         this._baseImage.x = -this._baseImage.width * this._xPos;
         this._baseImage.y = -this._baseImage.height * this._yPos;
      }
      
      public function get invId() : int
      {
         return this._invId;
      }
      
      public function get baseImageMediaId() : int
      {
         return this._baseImageMediaId;
      }
      
      public function get iconMediaId() : int
      {
         return this._iconMediaId;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get descr() : String
      {
         return this._descr;
      }
      
      public function get mediaText() : String
      {
         return this._mediaText;
      }
      
      public function get image() : Sprite
      {
         return this._baseImage;
      }
   }
}

