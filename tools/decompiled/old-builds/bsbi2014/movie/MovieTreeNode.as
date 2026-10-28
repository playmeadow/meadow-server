package movie
{
   public class MovieTreeNode extends MovieNode
   {
      
      private var _isCorrectChoice:Boolean;
      
      private var _nodeIndex:int;
      
      private var _parentDefId:int;
      
      public function MovieTreeNode(node:Object)
      {
         super(node);
         this.nodeIndex = 1;
      }
      
      public function get isCorrectChoice() : Boolean
      {
         return this._isCorrectChoice;
      }
      
      public function set isCorrectChoice(value:Boolean) : void
      {
         this._isCorrectChoice = value;
      }
      
      public function get nodeIndex() : int
      {
         return this._nodeIndex;
      }
      
      public function set nodeIndex(value:int) : void
      {
         this._nodeIndex = value;
      }
      
      public function get parentDefId() : int
      {
         return this._parentDefId;
      }
      
      public function set parentDefId(value:int) : void
      {
         this._parentDefId = value;
      }
   }
}

