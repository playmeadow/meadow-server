package gui
{
   public class PredictiveTextNode
   {
      
      public var char:String;
      
      public var children:Vector.<PredictiveTextNode> = new Vector.<PredictiveTextNode>();
      
      public var weight:int;
      
      public var isSpecialCharacter:Boolean;
      
      public var useType:int;
      
      public function PredictiveTextNode(param1:String, param2:int, param3:Vector.<PredictiveTextNode>, param4:Boolean = false, param5:int = 0)
      {
         super();
         this.char = param1;
         this.weight = param2;
         this.children = param3;
         this.isSpecialCharacter = param4;
         this.useType = param5;
      }
      
      public function destroy() : void
      {
         this.children = null;
      }
      
      public function contains(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.children != null)
         {
            _loc2_ = int(this.children.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(this.children[_loc3_].char == param1)
               {
                  return _loc3_;
               }
               _loc3_++;
            }
         }
         return -1;
      }
   }
}

