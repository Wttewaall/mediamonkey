package nl.mediamonkey.utils {
	
	import mx.core.IFactory;
	
	public class ObjectPool {
		
		public var autoGrow			:Boolean;
		
		private var initialSize		:uint;
		private var currentSize		:uint;
		private var usageCount		:uint;
		
		private var headNode		:ObjNode;
		private var tailNode		:ObjNode;
		private var emptyNode		:ObjNode;
		private var allocatedNode	:ObjNode;
		
		private var factory			:IFactory;
		
		// ---- getters & setters ----
		
		public function get size():uint {
			return currentSize;
		}
		
		public function get usageCounts():uint {
			return usageCount;
		}
		
		public function get wasteCount():uint {
			return currentSize - usageCount;	
		}
		
		// ---- constructor ----
		
		public function ObjectPool(autoGrow:Boolean=false) {
			this.autoGrow = autoGrow;
		}
		
		// ---- public methods ----
		
		public function setFactory(factory:IFactory):void {
			this.factory = factory;
		}
		
		public function allocate(size:uint, className:Class=null):void {
			deconstruct();
			
			if (className) factory = new SimpleFactory(className);
			else if (!factory) throw new Error("nothing to instantiate.");
			
			initialSize = currentSize = size;
			
			headNode = tailNode = new ObjNode();
			headNode.data = factory.newInstance();
			
			var node:ObjNode;
			
			for (var i:uint=1; i<initialSize; i++) {
				node = new ObjNode();
				node.data = factory.newInstance();
				node.next = headNode;
				headNode = node;
			}
			
			emptyNode = allocatedNode = headNode;
			tailNode.next = headNode;
		}
		
		public function getObject():* {
			
			if (usageCount == currentSize) {
				if (autoGrow) {
					currentSize += initialSize;
					
					var n:ObjNode = tailNode;
					var t:ObjNode = tailNode;
					
					var node:ObjNode;
					for (var i:uint = 0; i < initialSize; i++) {
						node = new ObjNode();
						node.data = factory.newInstance();
						
						t.next = node;
						t = node; 
					}
					
					tailNode = t;
					
					tailNode.next = emptyNode = headNode;
					allocatedNode = n.next;
					return getObject();
					
				} else throw new Error("object pool exhausted.");
				
			} else {
				var o:* = allocatedNode.data;
				allocatedNode.data = null;
				allocatedNode = allocatedNode.next;
				usageCount++;
				return o;
			}
		}
		
		public function setObject(value:*):void {
			if (usageCount > 0) {
				usageCount--;
				emptyNode.data = value;
				emptyNode = emptyNode.next;
			}
		}
		
		public function initialize(func:String, args:Array):void {
			var node:ObjNode = headNode;
			while (node) {
				node.data[func].apply(node.data, args);
				if (node == tailNode) break;
				node = node.next;	
			}
		}
		
		public function purge():void {
			var i:uint;
			var node:ObjNode;
			
			if (usageCount == 0) {
				if (currentSize == initialSize) return;
					
				if (currentSize > initialSize) {
					i = 0; 
					node = headNode;
					
					while (++i < initialSize) node = node.next;	
					
					tailNode = node;
					allocatedNode = emptyNode = headNode;
					currentSize = initialSize;
					return;	
				}
				
			} else {
				var a:Array = [];
				node = headNode;
				while (node) {
					if (!node.data) a[uint(i++)] = node;
					if (node == tailNode) break;
					node = node.next;	
				}
				
				currentSize = a.length;
				usageCount = currentSize;
				headNode = tailNode = a[0];
				
				for (i = 1; i < currentSize; i++) {
					node = a[i];
					node.next = headNode;
					headNode = node;
				}
				
				emptyNode = allocatedNode = headNode;
				tailNode.next = headNode;
				
				if (usageCount < initialSize) {
					currentSize = initialSize;
					
					var n:ObjNode = tailNode;
					var t:ObjNode = tailNode;
					var k:uint = initialSize - usageCount;
					for (i = 0; i < k; i++) {
						node = new ObjNode();
						node.data = factory.newInstance();
						
						t.next = node;
						t = node; 
					}
					
					tailNode = t;
					
					tailNode.next = emptyNode = headNode;
					allocatedNode = n.next;
					
				}
			}
		}
		
		public function deconstruct():void {
			var node:ObjNode = headNode;
			var t:ObjNode;
			while (node) {
				t = node.next;
				node.next = null;
				node.data = null;
				node = t;
			}
			
			headNode = tailNode = emptyNode = allocatedNode = null;
		}
		
	}
}

internal class ObjNode {
	
	public var next:ObjNode;
	public var data:*;
	
}

import mx.core.IFactory;

internal class SimpleFactory implements IFactory {
	
	private var className:Class;
	
	public function SimpleFactory(className:Class) {
		this.className = className;
	}
	
	public function newInstance():* {
		return new className();
	}
}