/**
 * XMLMetaParser by Derrick Grigg
 * November 2, 2009
 * www.dgrigg.com
 *
 * Copyright (c) 2009 Derrick Grigg
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

package nl.mediamonkey.core {
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	/**
	 * http://www.dgrigg.com/blog/default.cfm?page=3
	 * Add this to the compiler arguments: -keep-as3-metadata+=XML
	 *
	 * XMLMetaParser provides a mechanism to easily read and write xml from as3 objects.
	 * Using the parser is simple, mark any public properties on an object with the [XML] meta tag.
	 *
	 * Mark the class definition with the 'node' property to tell the parser the node name to use when outputting xml. The default value is 'node'
	 * [XML(node="person")]
	 *
	 * To mark properties as node attributes use the 'attribute' property.
	 * [XML(attribute="id")]
	 *
	 * To mark properties as nodes use the 'node' property. You can also note if the node should wrap the data in a CDATA node by using
	 * the 'cdata' property. The cdata default value is false.
	 * [XML(node="name", cdata="true")]
	 * or
	 * [XML(node="name")]
	 *
	 */
	public class XMLMetaParser {
		
		/**
		 * If these properties are the same, a getter/setter is expected
		 */
		public static var setXMLField:String = "xmlData";
		
		public static var getXMLField:String = "xmlData";
		
		/**
		 * Read values from xml and set them on an object.
		 * @param obj The value object to write the data into.
		 * @param xml The xml source to read the data from.
		 */
		public static function read(obj:IXMLMetaObject, xml:XML):void {
			var source:XML = describeType(obj);
			var meta:XMLList;
			var node:XML;
			var parent:XML;
			
			if (!obj) return;
			
			//read the attributes
			meta = getMetaNodes(source, "attribute");
			
			for each (node in meta) {
				parent = node.parent().parent();
				obj[parent.@name] = xml.attribute(node.@value);
			}
			
			//read the nodes
			meta = getMetaNodes(source, "node");
			
			for each (node in meta) {
				parent = node.parent().parent();
				
				if (parent.@type.lastIndexOf("::") == -1) { // simple type
					//if (obj[parent.@name] is Array) { //..
					obj[parent.@name] = xml.elements(node.@value);
					
				} else {
					// try to get the Class of this complex type child's class definition
					var Definition:Class = getDefinitionByName(parent.@type) as Class;
					
					if (Definition != null) {
						// create an instance if the class is available, or fail silently
						var instance:Object = new Definition();
						
						// if this class has the setXML method, populate the instance with the current node
						if (instance.hasOwnProperty(setXMLField)) {
							//if there is data to populate the instance with then populate and set in the obj
							var instanceNode:XML = xml.elements(node.@value)[0];
							
							if (instanceNode) {
								Function(instance[setXMLField]).call(null, xml.elements(node.@value)[0] as XML);
								// overwrite the property with our new instance
								obj[parent.@name] = instance;
							}
							
						}
					}
				}
			}
		}
		
		/**
		 * Write the values from an object into an xml object. Only public properties marked with the [XML] meta tag will be output.
		 *
		 * @param obj The object to read the values from.
		 * @return XML An xml object with the attribute and nodes mapped from the [XML] meta tag
		 */
		public static function write(obj:IXMLMetaObject):XML {
			var output:XML;
			var node:XML;
			var parent:XML;
			var source:XML = describeType(obj);
			
			var meta:XMLList;
			
			//setup the root node
			meta = source.metadata.(@name == "XML").arg.(@key == "node");
			output = (meta.length() > 0) ? <{meta.@value}/> : <node/>;
			//trace(source);
			
			//write the attributes
			meta = getMetaNodes(source, "attribute");
			
			for each (node in meta) {
				parent = node.parent().parent()
				output.@[node.@value] = obj[parent.@name];
			}
			
			//write the nodes
			meta = getMetaNodes(source, "node");
			var child:XML;
			var value:Object;
			var writeAsCDATA:Boolean; //flag used to note cdata nodes
			
			for each (node in meta) {
				parent = node.parent().parent();
				//writeAsCDATA = (parent.metadata.arg.(@key == "cdata").@value.toString().toLowerCase() == "true");
				writeAsCDATA = (parent.metadata.arg.(@key == "cdata").length() > 0);
				value = (writeAsCDATA) ? cdata(obj[parent.@name]) : obj[parent.@name];
				
				// if the value has a getXML method, use it to get the nested child as xml output
				if (value) {
					
					if (value is Array) {
						child = <{node.@value}/>;
						
						for (var i:uint=0; i<value.length; i++) {
							var item:Object = value[i];
							if (item.hasOwnProperty(getXMLField)) {
								var result:XML = item[getXMLField];
								if (result) child.appendChild(result);
							}
						}
						
					} else if (value.hasOwnProperty(getXMLField)) {
						child = Function(value[getXMLField]).call();
						child.setLocalName(node.@value);
						
					} else {
						child = <{node.@value}>{value}</{node.@value}>;
					}
					
					output.appendChild(child);
				}
			}
			
			return output;
		}
		
		/**
		 * @param xml Xml from describeType to read the meta tags from.
		 * @param key The meta key to search from, valid values are 'node' and 'attribute'.
		 * @return XMLList list of matching meta nodes
		 */
		private static function getMetaNodes(xml:XML, key:String):XMLList {
			// was in Flex 3.0.0: return xml.variable.metadata.(@name == "XML").arg.(@key == key);
			return xml.accessor.metadata.(@name == "XML").arg.(@key == key);
		}
		
		/**
		 * wraps data in a CDATA node
		 * @param value The data to wrap.
		 * @return XML The data in XML with a CDATA node.
		 */
		private static function cdata(value:String):XML {
			return new XML("<![CDATA["+value+"]]>");
		}
	}
}