package nl.mediamonkey.utils {
	
	public class XMLUtil {
		
		public static const TEXT					:String = "text";
		public static const COMMENT					:String = "comment";
		public static const PROCESSING_INSTRUCTION	:String = "processing-instruction";
		public static const ATTRIBUTE				:String = "attribute";
		public static const ELEMENT					:String = "element";
		
		public static function isValidXML(data:String):Boolean {
			var xml:XML;
			
			try {
				xml = new XML(data);
				
			} catch(e:Error) {
				return false;
			}
			
			return (xml.nodeKind() == XMLUtil.ELEMENT);
		}
		
		/**
		 * Returns the next sibling of the specified node relative to the node's parent.
		 * 
		 * @param x The node whose next sibling will be returned.
		 * @return The next sibling of the node. null if the node does not have 
		 * a sibling after it, or if the node has no parent.
		 */		
		public static function getNextSibling(x:XML):XML {	
			return XMLUtil.getSiblingByIndex(x, 1);
		}
		
		/**
		 * Returns the sibling before the specified node relative to the node's parent.
		 * 
		 * @param x The node whose sibling before it will be returned.
		 * @return The sibling before the node. null if the node does not have 
		 * a sibling before it, or if the node has no parent.
		 */
		public static function getPreviousSibling(x:XML):XML {	
			return XMLUtil.getSiblingByIndex(x, -1);
		}
		
		protected static function getSiblingByIndex(x:XML, count:int):XML {
			var out:XML;
			
			try {
				out = x.parent().children()[x.childIndex() + count];	
				
			} catch(e:Error) {
				return null;
			}
			
			return out;			
		}
		
	}
}