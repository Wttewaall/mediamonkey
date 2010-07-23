package {
	
	import flash.display.BitmapData;
	import flash.system.System;
	
	public class BitmapDataCache {
		
		// ---- variables ----
		
		public var maxItems			:uint;
		public var dropoff			:Number = 0.25; // quarter
		
		protected var cache			:Array;
		protected var totalUsage	:uint;
		
		// ---- constructor ----
		
		public function BitmapDataCache(maxItems:uint = 10) {
			this.maxItems = maxItems;
			
			cache = new Array();
			totalUsage = 0;
		}
		
		// ---- public methods ----
		
		public function addCache(width:Number, height:Number, data:BitmapData, keep:Boolean = false):void {
			var item:CacheData = getCache(width, height);
			
			if (item) { // item already exists, overwrite data
				item.data = data;
				
			} else { // create item and store
				item = new CacheData(width, height, data, keep);
				cache.push(item);
			}
			
			totalUsage++;
		}
		
		public function getBitmapData(width:Number, height:Number):BitmapData {
			var item:CacheData = getCache(width, height);
			if (!item) return null;
			
			item.usage++;
			totalUsage++;
			
			if (cache.length > maxItems) cleanup();
			
			return item.data;
		}
		
		// ---- protected methods ----
		
		// get cached bitmapdata by width and height
		protected function getCache(width:Number, height:Number):CacheData {
			var item:CacheData;
			for each (item in cache) {
				if (item.width == width && item.height == height) return item;
			}
			return null;
		}
		
		protected function cleanup():void {
			var average:Number = totalUsage / cache.length;
			var minUsage:Number = average * dropoff;
			
			var item:CacheData;
			for each (item in cache) {
				
				if (item.usage < minUsage && cache.length > maxItems) {
					if (!item.keep) removeCache(item);
				}
			}
		}
		
		protected function removeCache(item:CacheData):void {
			var index:int = cache.indexOf(item);
			
			if (index > -1) {
				item.data.dispose();
				cache.splice(index, 1);
				System.gc();
			}
		}
		
	}
}

import flash.display.BitmapData;

internal class CacheData {
	
	public var width	:Number;
	public var height	:Number;
	public var data		:BitmapData;
	public var usage	:uint;
	public var keep		:Boolean;
	
	public function CacheData(width:Number, height:Number, data:BitmapData, keep:Boolean = false) {
		this.width = width;
		this.height = height;
		this.data = data;
		usage = 1;
		this.keep = keep;
	}
	
}