package libraries.uanalytics.tracking
{
   import flash.utils.Dictionary;
   
   public class HitModel
   {
      
      private var _data:Dictionary;
      
      private var _metadata:Metadata;
      
      public function HitModel()
      {
         super();
         _metadata = new Metadata();
         clear();
      }
      
      public function set(param1:String, param2:String) : void
      {
         _data[_metadata.getHitModelKey(param1)] = param2;
      }
      
      public function get(param1:String) : String
      {
         return _data[_metadata.getHitModelKey(param1)];
      }
      
      public function add(param1:HitModel) : void
      {
         for(var _loc2_:String in param1._data)
         {
            _data[_loc2_] = param1._data[_loc2_];
         }
      }
      
      public function clone() : HitModel
      {
         var _loc2_:HitModel = new HitModel();
         for(var _loc1_:String in _data)
         {
            _loc2_._data[_loc1_] = _data[_loc1_];
         }
         return _loc2_;
      }
      
      public function clear() : void
      {
         _data = new Dictionary();
      }
      
      public function getFieldNames() : Vector.<String>
      {
         var _loc2_:Vector.<String> = new Vector.<String>();
         for(var _loc1_:String in _data)
         {
            _loc2_.push(_loc1_);
         }
         return _loc2_;
      }
   }
}

