package nl.mediamonkey.utils {
	
	////////////////////////////////////////////////////////////////////////////////
	//
	//  ADOBE SYSTEMS INCORPORATED
	//  Copyright 2007 Adobe Systems Incorporated
	//  All Rights Reserved.
	//
	//  NOTICE: Adobe permits you to use, modify, and distribute this file
	//  in accordance with the terms of the license agreement accompanying it.
	//
	////////////////////////////////////////////////////////////////////////////////
	
	import flash.display.IBitmapDrawable;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	/**
	 *  A helper class used to capture a snapshot of any Flash component 
	 *  that implements <code>flash.display.IBitmapDrawable</code>,
	 *  including Flex UIComponents.
	 *
	 *  <p>An instance of this class can be sent via RemoteObject
	 *  to Adobe's LiveCycle Data Services in order to generate
	 *  a PDF file of a client-side image.
	 *  If you need to specify additional properties of the image
	 *  beyond its <code>contentType</code>, <code>width</code>,
	 *  and <code>height</code>, you should set name/value pairs
	 *  on the <code>properties</code> object.</p>
	 *
	 *  <p>In earlier versions of Flex, you set these additional
	 *  properties on the ImageSnapshot instance itself.
	 *  This class is still dynamic in order to allow that,
	 *  but in a future version of Flex it may no longer be dynamic.</p>
	 */
	public dynamic class ImageSnapshot
	{
		public static const MAX_BITMAP_DIMENSION:int = 2880;
		
		public static function captureBitmapData(
									source:IBitmapDrawable, matrix:Matrix = null,
									colorTransform:ColorTransform = null,
									blendMode:String = null,
									clipRect:Rectangle = null,
									smoothing:Boolean = false):BitmapData
		{
			var data:BitmapData;
			var width:int;
			var height:int;
	
			var normalState:Array;
			
			try
			{
				if (source != null)
				{
					if (source is DisplayObject)
					{
						width = DisplayObject(source).width;
						height = DisplayObject(source).height;
					}
					else if (source is BitmapData)
					{
						width = BitmapData(source).width;
						height = BitmapData(source).height;
					}
				}
	
				// We default to an identity matrix
				// which will match screen resolution
				if (!matrix)
					matrix = new Matrix(1, 0, 0, 1);
	
				var scaledWidth:Number = width * matrix.a;
				var scaledHeight:Number = height * matrix.d;
				var reductionScale:Number = 1;
	
				// Cap width to BitmapData max of 2880 pixels
				if (scaledWidth > MAX_BITMAP_DIMENSION)
				{
					reductionScale = scaledWidth / MAX_BITMAP_DIMENSION;
					scaledWidth = MAX_BITMAP_DIMENSION;
					scaledHeight = scaledHeight / reductionScale;
		
					matrix.a = scaledWidth / width;
					matrix.d = scaledHeight / height;
				}
	
				// Cap height to BitmapData max of 2880 pixels
				if (scaledHeight > MAX_BITMAP_DIMENSION)
				{
					reductionScale = scaledHeight / MAX_BITMAP_DIMENSION;
					scaledHeight = MAX_BITMAP_DIMENSION;
					scaledWidth = scaledWidth / reductionScale;
		
					matrix.a = scaledWidth / width;
					matrix.d = scaledHeight / height;
				}
	
				// the fill should be transparent: 0xARGB -> 0x00000000
				// only explicitly drawn pixels will show up
				data = new BitmapData(scaledWidth, scaledHeight, true, 0x00000000);
				data.draw(source, matrix, colorTransform,
						  blendMode, clipRect, smoothing);
				
			} catch(e:Error) {
				trace(e.message);
			}
	
			return data;
		}
	
	}

}