package nl.mediamonkey.utils {
	
	public class PopUpVO {
		
		public var x					:Number;
		public var y					:Number;
		public var width				:Number;
		public var minWidth				:Number;
		public var maxWidth				:Number;
		public var height				:Number;
		public var minHeight			:Number;
		public var maxHeight			:Number;
		
		public var title				:String;
		public var titleIcon			:Class;
		public var data					:Object;
		
		public var showCloseButton		:Boolean = true;
		public var center				:Boolean = true;
		public var draggable			:Boolean = true;
		public var modal				:Boolean = false;
		
		public function PopUpVO() {
		}
	 
	}
}