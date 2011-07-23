package {
	
	import mx.collections.ArrayList;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
 
	import spark.components.ComboBox;
	import spark.components.Form;
	import spark.skins.spark.ComboBoxSkin;
 
	public class FormUtil {
		
		private static var _numelements:ArrayList;
 
 
		/**
		 * @public
		 *  Static method to clear all values filled in a given Form
		 * 
		 * Usage FormManager.clearFields(myForm);
		 * @see spark.components.Form;
		 * @see mx.core.IVisualElementContainer;
		 * */
		public static function clearFields(value:Form):void {
			
			for (var i:int = 0 ;i <= value.numElements-1;i++) {
				var item:IVisualElementContainer = value.getElementAt(i) as IVisualElementContainer;
 
				for (var j:int = 0; j<=item.numElements-1;j++) {
					var input:UIComponent = item.getElementAt(j) as UIComponent;
						if(input.hasOwnProperty('text'))
							input['text'] = '';
						if(input.hasOwnProperty('textFlow'))
							input['textFlow'] = null;
						if(input.hasOwnProperty('selectedItem'))
							input['selectedItem'] = null;
						if(input is ComboBox)
							ComboBox(input).textInput.text =''; // fix the bug on default ComboBoxSkin class
						if(input.hasOwnProperty('selectedItems'))
							input['selectedItems'] = null;
						if(input.hasOwnProperty('selectedIndex'))
							input['selectedIndex'] = -1;
						if(input.hasOwnProperty('selected'))
							input['selected']= false;
 
				}
			}
		}
		/**
		 * @public
		 *  Static method to return an ArrayList of all fields in a given Form
		 * 
		 * Usage :  var elements:ArrayList = FormManager.getElements(myForm);
		 *            for each (var item:* in elements)
		 *                 {
		 *                   trace(item);
		 *                  }
		 * @see spark.components.Form;
		 * @see mx.core.IVisualElementContainer;
		 * */
		public static function getElements(value:Form):ArrayList { 
			_numelements = new ArrayList();
 
			for (var i:int = 0 ;i <= value.numElements-1;i++) {
				var item:IVisualElementContainer = value.getElementAt(i) as IVisualElementContainer;
 
				for (var j:int = 0; j<=item.numElements-1;j++) {
					var input:UIComponent = item.getElementAt(j) as UIComponent;
					_numelements.addItem(input);
				}
			}
			return _numelements;
		}
	}
}