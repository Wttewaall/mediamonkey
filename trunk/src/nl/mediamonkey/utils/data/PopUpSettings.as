package nl.mediamonkey.utils.data {
	
	public class PopUpSettings {
		
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
		public var headerHeight			:Number;
		public var data					:Object;
		
		public var showCloseButton		:Boolean = true;
		public var center				:Boolean = true;
		public var draggable			:Boolean = true;
		public var modal				:Boolean = false;
		
		public function PopUpSettings(title:String = "", showCloseButton:Boolean = true, center:Boolean = true, draggable:Boolean = true, modal:Boolean = false) {
			this.title = title;
			this.showCloseButton = showCloseButton;
			this.center = center;
			this.draggable = draggable;
			this.modal = modal;
		}
	 
	}
}