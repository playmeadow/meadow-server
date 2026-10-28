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
      
      public function init(initInvId:int, initBaseMediaId:int, initIconMediaId:int, initNameId:int, initMediaText:String = "", initIsMyAchievement:Boolean = false) : void
      {
         var splitMediaText:Array = null;
         this._invId = initInvId;
         this._baseImageMediaId = initBaseMediaId;
         this._iconMediaId = initIconMediaId;
         this._nameId = initNameId;
         this._name = LocalizationManager.translateIdOnly(initNameId);
         if(initMediaText == "")
         {
            this._mediaText = initMediaText;
         }
         else
         {
            splitMediaText = initMediaText.split(",");
            if(splitMediaText.length > 1)
            {
               this._mediaText = Utility.convertNumberToString(int(splitMediaText.join("")));
            }
            else
            {
               this._mediaText = initMediaText;
            }
         }
         this._isMyAchievement = initIsMyAchievement;
         this._baseImage = new Sprite();
         this._baseImageHelper = new MediaHelper();
         this._baseImageHelper.init(this._baseImageMediaId,this.baseImageReceived);
         this._icon = new Sprite();
         this._iconHelper = new MediaHelper();
         this._iconHelper.init(this._iconMediaId,this.iconReceived);
      }
      
      public function destroy() : void
      {
         if(Boolean(this._iconHelper))
         {
            this._iconHelper.destroy();
         }
         if(Boolean(this._baseImageHelper))
         {
            this._baseImageHelper.destroy();
         }
      }
      
      public function clone() : Achievement
      {
         var a:Achievement = null;
         a = new Achievement();
         a.init(this._invId,this._baseImageMediaId,this._iconMediaId,this._nameId,this._mediaText,this._isMyAchievement);
         return a;
      }
      
      public function setScale(scalePercent:Number) : void
      {
         this._scalePercent = scalePercent;
         if(this._iconReceived && this._baseImageReceived)
         {
            this._baseImage.scaleX = this._scalePercent;
            this._baseImage.scaleY = this._scalePercent;
         }
      }
      
      public function setPosition(xPos:Number, yPos:Number) : void
      {
         this._xPos = xPos;
         this._yPos = yPos;
         if(this._iconReceived && this._baseImageReceived)
         {
            this._baseImage.x = -this._baseImage.width * this._xPos;
            this._baseImage.y = -this._baseImage.height * this._yPos;
         }
      }
      
      private function baseImageReceived(img:MovieClip) : void
      {
         var width:Number = NaN;
         if(Boolean(img))
         {
            img = MovieClip(img.getChildAt(0));
            this._baseImage.addChild(img);
            if(this._iconReceived)
            {
               img.itemBlock.addChild(this._icon);
               this.allImagesLoaded();
            }
            if(this._mediaText == "")
            {
               img.num.visible = false;
            }
            else
            {
               img.num.txt.text = this._mediaText;
               width = Number(img.num.txt.textWidth);
               if(width > 15)
               {
                  if(width > 25)
                  {
                     img.num.gotoAndStop(3);
                  }
                  else
                  {
                     img.num.gotoAndStop(2);
                  }
               }
            }
            this._baseImageHelper.destroy();
            this._baseImageHelper = null;
            this._baseImageReceived = true;
         }
      }
      
      private function iconReceived(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._icon.addChild(img);
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
         var scale:Number = 0.9;
         if(this._isMyAchievement)
         {
            scale = 1;
         }
         this._baseImage.scaleX = scale * this._scalePercent;
         this._baseImage.scaleY = scale * this._scalePercent;
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

