package nl.mediamonkey.utils {
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class MatrixUtil {
		
		public static const RAD_TO_DEG:Number = Math.PI / 180;
		public static const DEG_TO_RAD:Number = 180 / Math.PI;
		
		public static function getX(matrix:Matrix):Number {
			return matrix.tx;
		}
		
		public static function getY(matrix:Matrix):Number {
			return matrix.ty;
		}
		
		public static function getScaleX(matrix:Matrix):Number {
			return Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b);
		}
		
		public static function setScaleX(matrix:Matrix, value:Number):void {
			var oldValue:Number = getScaleX(matrix);
			// avoid division by zero 
			if (oldValue) {
				var ratio:Number = value / oldValue;
				matrix.a *= ratio;
				matrix.b *= ratio;
			} else {
				var angle:Number = getSkewYRadians(matrix);
				matrix.a = Math.cos(angle) * value;
				matrix.b = Math.sin(angle) * value;
			}
		}
		
		public static function getScaleY(matrix:Matrix):Number {
			return Math.sqrt(matrix.c * matrix.c + matrix.d * matrix.d);
		}
		
		public static function setScaleY(matrix:Matrix, value:Number):void {
			var oldValue:Number = getScaleY(matrix);
			// avoid division by zero 
			if (oldValue) {
				var ratio:Number = value / oldValue;
				matrix.c *= ratio;
				matrix.d *= ratio;
			} else {
				var angle:Number = getSkewXRadians(matrix);
				matrix.c = -Math.sin(angle) * value;
				matrix.d = Math.cos(angle) * value;
			}
		}
		
		public static function getSkewXRadians(matrix:Matrix):Number {
			return Math.atan2(-matrix.c, matrix.d);
		}
		
		public static function setSkewXRadians(matrix:Matrix, value:Number):void {
			matrix.c = -getScaleY(matrix) * Math.sin(value);
			matrix.d = getScaleY(matrix) * Math.cos(value);
		}
		
		public static function getSkewYRadians(matrix:Matrix):Number {
			return Math.atan2(matrix.b, matrix.a);
		}
		
		public static function setSkewYRadians(matrix:Matrix, value:Number):void {
			matrix.a = getScaleX(matrix) * Math.cos(value);
			matrix.b = getScaleX(matrix) * Math.sin(value);
		}
		
		public static function getSkewX(matrix:Matrix):Number {
			return Math.atan2(-matrix.c, matrix.d) * RAD_TO_DEG;
		}
		
		public static function setSkewX(matrix:Matrix, value:Number):void {
			setSkewXRadians(matrix, value * DEG_TO_RAD);
		}
		
		public static function getSkewY(matrix:Matrix):Number {
			return Math.atan2(matrix.b, matrix.a) * RAD_TO_DEG;
		}
		
		public static function setSkewY(matrix:Matrix, value:Number):void {
			setSkewYRadians(matrix, value * DEG_TO_RAD);
		}
		
		public static function getAngle(matrix:Matrix):Number {
			return getSkewYRadians(matrix);
		}
		
		public static function setAngle(matrix:Matrix, value:Number):void {
			var oldAngle:Number = getAngle(matrix);
			var oldSkewX:Number = getSkewXRadians(matrix);
			setSkewXRadians(matrix, oldSkewX + value - oldAngle);
			setSkewYRadians(matrix, value);
		}
		
		public static function getRotation(matrix:Matrix):Number {
			return getAngle(matrix) * RAD_TO_DEG;
		}
		
		public static function setRotation(matrix:Matrix, value:Number):void {
			setAngle(matrix, value * DEG_TO_RAD);
		}
		
		public static function rotateAroundInternalPoint(matrix:Matrix, point:Point, rotation:Number):void {
			point = matrix.transformPoint(point);
			matrix.tx -= point.x;
			matrix.ty -= point.y;
			matrix.rotate(rotation * DEG_TO_RAD);
			matrix.tx += point.x;
			matrix.ty += point.y;
		}
		
		public static function rotateAroundExternalPoint(matrix:Matrix, point:Point, rotation:Number):void {
			matrix.tx -= point.x;
			matrix.ty -= point.y;
			matrix.rotate(rotation * DEG_TO_RAD);
			matrix.tx += point.x;
			matrix.ty += point.y;
		}
		
		public static function matchInternalPointWithExternal(matrix:Matrix, internalPoint:Point, externalPoint:Point):void {
			var internalPointTransformed:Point = matrix.transformPoint(internalPoint);
			var dx:Number = externalPoint.x - internalPointTransformed.x;
			var dy:Number = externalPoint.y - internalPointTransformed.y;
			matrix.tx += dx;
			matrix.ty += dy;
		}
		
	}
}