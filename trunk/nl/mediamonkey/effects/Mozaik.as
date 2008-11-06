package nl.mediamonkey.effects {
	
	import nl.mediamonkey.effects.MaskEffect;
	import nl.mediamonkey.effects.effectClasses.MozaikInstance;

	public class Mozaik extends MaskEffect {
		
		public function Mozaik(target:Object=null) {
			super(target);
			
			instanceClass = MozaikInstance;
		}
		
	}
}