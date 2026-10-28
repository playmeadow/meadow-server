package gui
{
   public class PredictiveTextNode
   {
      
      public var char:String;
      
      public var children:Vector.<PredictiveTextNode> = new Vector.<PredictiveTextNode>();
      
      public var weight:int;
      
      public var isSpecialCharacter:Boolean;
      
      public var useType:int;
      
      public function PredictiveTextNode(ch:String, isEndWord:int, childrenArray:Vector.<PredictiveTextNode>, isSpecial:Boolean = false, usabilityType:int = 0)
      {
         super();
         this.char = ch;
         this.weight = isEndWord;
         this.children = childrenArray;
         this.isSpecialCharacter = isSpecial;
         this.useType = usabilityType;
      }
      
      public function destroy() : void
      {
         this.children = null;
      }
      
      public function contains(c:String) : int
      {
         var childLength:int = 0;
         var i:int = 0;
         if(this.children != null)
         {
            childLength = int(this.children.length);
            for(i = 0; i < childLength; i++)
            {
               if(this.children[i].char == c)
               {
                  return i;
               }
            }
         }
         return -1;
      }
   }
}

