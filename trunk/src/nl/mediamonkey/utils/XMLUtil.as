package nl.mediamonkey.utils {
	
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	public class XMLUtil {
		
		public static const ELEMENT					:String = "element";
		public static const TEXT					:String = "text";
		public static const COMMENT					:String = "comment";
		public static const ATTRIBUTE				:String = "attribute";
		public static const PROCESSING_INSTRUCTION	:String = "processing-instruction";
		
		public static function isValidXML(data:*):Boolean {
			var xml:XML;
			
			try {
				xml = new XML(data);
				
			} catch(e:Error) {
				return false;
			}
			
			return (xml != null && xml.nodeKind() == XMLUtil.ELEMENT);
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
		
		/**
		 * Creates a CDATA section for the given data string.
		 * Use this method if you need to create a CDATA section with a binding
		 * expression in a literal XML declaration
		 *
		 * @param data the data string to create a CDATA section from.
		 * @return a CDATA section for the data
		 */
		public static function cdata(text:String):XML {
			var result:XML = new XML("<![CDATA[" + text + "]]>");
			return result;
		}
		
		/**
		 * Returns if the given xml node is an element node.
		 */
		public static function isElementNode(xml:XML):Boolean {
			if (xml == null) throw new Error("The xml must not be null");
			return (xml.nodeKind() == ELEMENT);
		}
		
		/**
		 * Returns if the given xml node is a text node.
		 */
		public static function isTextNode(xml:XML):Boolean {
			if (xml == null) throw new Error("The xml must not be null");
			return (xml.nodeKind() == TEXT);
		}
		
		/**
		 * Returns if the given xml node is a comment node.
		 */
		public static function isCommentNode(xml:XML):Boolean {
			if (xml == null) throw new Error("The xml must not be null");
			return (xml.nodeKind() == COMMENT);
		}
		
		/**
		 * Returns if the given xml node is a processing instruction node.
		 */
		public static function isProcessingInstructionNode(xml:XML):Boolean {
			if (xml == null) throw new Error("The xml must not be null");
			return (xml.nodeKind() == PROCESSING_INSTRUCTION);
		}
		
		/**
		 * Returns if the given xml node is an attribute node.
		 */
		public static function isAttributeNode(xml:XML):Boolean {
			if (xml == null) throw new Error("The xml must not be null");
			return (xml.nodeKind() == ATTRIBUTE);
		}
		
		/**
		 * Converts an attribute to a node.
		 *
		 * @param xml the xml node that contains the attribute
		 * @param attribute the name of the attribute that will be converted to a node
		 * @return the passed in xml node with the specified attribute converted to a node
		 */
		public static function convertAttributeToNode(xml:XML, attribute:String):XML {
			var attributes:XMLList = xml.attribute(attribute);
			
			if (attributes) {
				if (attributes[0] != undefined) {
					var node:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE, attribute);
					var value:XMLNode = new XMLNode(XMLNodeType.TEXT_NODE, attributes[0].toString());
					node.appendChild(value);
					var newNode:XML = new XML(node.toString());
					xml.appendChild(newNode);
					delete attributes[0];
				}
			}
			return xml;
		}
		
		public static function cleanXML(xmlData:XML):XML {
			return XML(cleanXMLString(xmlData));
		}
		
		public static function cleanXMLString(xmlData:XML):String {
			var output:String = xmlData.toXMLString();
			
			// replace escaped characters (hexadecimal representation)
			output = output.replace(/&#xD;&#xA;(&#x9;)*/, "");
			output = output.replace(/&#xD;/g, "");		// return
			output = output.replace(/&#xA;/g, "");		// newline
			output = output.replace(/&#x9;/g, "");		// tab
			output = output.replace(/&amp;/, "&");		// &
			output = output.replace(/&lt;/, "<");		// <
			output = output.replace(/&gt;/, ">");		// >
			output = output.replace(/&#x20;/g, " ");	// space
			
			return output;
		}
	}
}