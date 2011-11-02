package nl.mediamonkey.behaviors.mouseBehaviors {
	
	import flash.display.InteractiveObject;
	
	public class ClickBehavior extends MouseBehavior {
		
		// ---- variables ----
		
		
		// ---- getters & setters ----
		
		
		// ---- constructor ----
		
		/**
		 * A behavior that injects mouse click logic into an InteractiveObject as a target.
		 * This workings of this class are highly adaptable through the many properties.
		 */
		public function ClickBehavior(target:InteractiveObject = null, dispatchFromTarget:Boolean = true) {
			super(target, dispatchFromTarget);
		}
		
	}
}