package nl.mediamonkey.utils {
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class MatrixTransformer {
		
		public static const RAD_TO_DEG:Number = Math.PI / 180;
		public static const DEG_TO_RAD:Number = 180 / Math.PI;
		
		public static function getScaleX(m:Matrix):Number {
			return Math.sqrt(m.a * m.a + m.b * m.b);
		}
		
		public static function setScaleX(m:Matrix, value:Number):void {
			var oldValue:Number = getScaleX(m);
			// avoid division by zero 
			if (oldValue) {
				var ratio:Number = value / oldValue;
				m.a *= ratio;
				m.b *= ratio;
			} else {
				var skewYRad:Number = getSkewYRadians(m);
				m.a = Math.cos(skewYRad) * value;
				m.b = Math.sin(skewYRad) * value;
			}
		}
		
		public static function getScaleY(m:Matrix):Number {
			return Math.sqrt(m.c * m.c + m.d * m.d);
		}
		
		public static function setScaleY(m:Matrix, value:Number):void {
			var oldValue:Number = getScaleY(m);
			// avoid division by zero 
			if (oldValue) {
				var ratio:Number = value / oldValue;
				m.c *= ratio;
				m.d *= ratio;
			} else {
				var skewXRad:Number = getSkewXRadians(m);
				m.c = -Math.sin(skewXRad) * value;
				m.d = Math.cos(skewXRad) * value;
			}
		}
		
		public static function getSkewXRadians(m:Matrix):Number {
			return Math.atan2(-m.c, m.d);
		}
		
		public static function setSkewXRadians(m:Matrix, value:Number):void {
			var scaleY:Number = getScaleY(m);
			m.c = -scaleY * Math.sin(value);
			m.d = scaleY * Math.cos(value);
		}
		
		public static function getSkewYRadians(m:Matrix):Number {
			return Math.atan2(m.b, m.a);
		}
		
		public static function setSkewYRadians(m:Matrix, value:Number):void {
			var scaleX:Number = getScaleX(m);
			m.a = scaleX * Math.cos(value);
			m.b = scaleX * Math.sin(value);
		}
		
		public static function getSkewX(m:Matrix):Number {
			return Math.atan2(-m.c, m.d) * RAD_TO_DEG;
		}
		
		public static function setSkewX(m:Matrix, value:Number):void {
			setSkewXRadians(m, value * DEG_TO_RAD);
		}
		
		public static function getSkewY(m:Matrix):Number {
			return Math.atan2(m.b, m.a) * RAD_TO_DEG;
		}
		
		public static function setSkewY(m:Matrix, value:Number):void {
			setSkewYRadians(m, value * DEG_TO_RAD);
		}
		
		public static function getRotationRadians(m:Matrix):Number {
			return getSkewYRadians(m);
		}
		
		/**
		 * @param rotation The angle of rotation, in radians.
		 */
		public static function setRotationRadians(m:Matrix, rotation:Number):void {
			var oldRotation:Number = getRotationRadians(m);
			var oldSkewX:Number = getSkewXRadians(m);
			setSkewXRadians(m, oldSkewX + rotation - oldRotation);
			setSkewYRadians(m, rotation);
		}
		
		/**
		 * @return The angle of rotation, in degrees.
		 */
		public static function getRotation(m:Matrix):Number {
			return getRotationRadians(m) * RAD_TO_DEG;
		}
		
		/**
		 * @param rotation The angle of rotation, in degrees.
		 */
		public static function setRotation(m:Matrix, rotation:Number):void {
			setRotationRadians(m, rotation * DEG_TO_RAD);
		}
		
		/**
		 * @param angleDegrees The angle of rotation in degrees.
		 */
		public static function rotateAroundInternalPoint(m:Matrix, point:Point, angleDegrees:Number):void {
			point = m.transformPoint(point);
			m.tx -= point.x;
			m.ty -= point.y;
			m.rotate(angleDegrees * DEG_TO_RAD);
			m.tx += point.x;
			m.ty += point.y;
		}
		
		/**
		 * @param angleDegrees The angle of rotation in degrees.
		 */
		public static function rotateAroundExternalPoint(m:Matrix, point:Point, angleDegrees:Number):void {
			m.tx -= point.x;
			m.ty -= point.y;
			m.rotate(angleDegrees * DEG_TO_RAD);
			m.tx += point.x;
			m.ty += point.y;
		}
		
		/**
		 * @param internalPoint A Point instance defining a position within the matrix's transformation space.
		 * @param externalPoint A Point instance defining a reference position outside the matrix's transformation space.
		 */
		public static function matchInternalPointWithExternal(m:Matrix, internalPoint:Point, externalPoint:Point):void {
			var internalPointTransformed:Point = m.transformPoint(internalPoint);
			var dx:Number = externalPoint.x - internalPointTransformed.x;
			var dy:Number = externalPoint.y - internalPointTransformed.y;
			m.tx += dx;
			m.ty += dy;
		}
	}
}