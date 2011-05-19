package nl.mediamonkey.utils {
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class Matrix2 extends Matrix {
		
		public static const RAD_TO_DEG:Number = 180/Math.PI;
		public static const DEG_TO_RAD:Number = Math.PI/180;
		
		// ---- constructor ----
		
		public function Matrix2(a:Number=1, b:Number=0, c:Number=0, d:Number=1, tx:Number=0, ty:Number=0) {
			super(a, b, c, d, tx, ty);
		}
		
		// ---- getters & setters ----
		
		public function get scaleX():Number {
			return Math.sqrt(a * a + b * b);
		}
		
		public function set scaleX(value:Number):void {
			var oldValue:Number = scaleX;
			// avoid division by zero 
			if (oldValue) {
				var ratio:Number = value / oldValue;
				a *= ratio;
				b *= ratio;
			} else {
				a = Math.cos(skewYRadians) * value;
				b = Math.sin(skewYRadians) * value;
			}
		}
		
		public function get scaleY():Number {
			return Math.sqrt(c * c + d * d);
		}
		
		public function set scaleY(value:Number):void {
			var oldValue:Number = scaleY;
			// avoid division by zero 
			if (oldValue) {
				var ratio:Number = value / oldValue;
				c *= ratio;
				d *= ratio;
			} else {
				c = -Math.sin(skewXRadians) * value;
				d = Math.cos(skewXRadians) * value;
			}
		}
		
		public function get skewXRadians():Number {
			return Math.atan2(-c, d);
		}
		
		public function set skewXRadians(value:Number):void {
			c = -scaleY * Math.sin(value);
			d = scaleY * Math.cos(value);
		}
		
		public function get skewYRadians():Number {
			return Math.atan2(b, a);
		}
		
		public function set skewYRadians(value:Number):void {
			a = scaleX * Math.cos(value);
			b = scaleX * Math.sin(value);
		}
		
		public function get skewX():Number {
			return Math.atan2(-c, d) * RAD_TO_DEG;
		}
		
		public function set skewX(value:Number):void {
			skewXRadians = value * DEG_TO_RAD;
		}
		
		public function get skewY():Number {
			return Math.atan2(b, a) * RAD_TO_DEG;
		}
		
		public function set skewY(value:Number):void {
			skewYRadians = value * DEG_TO_RAD;
		}
		
		public function get rotationRadians():Number {
			return skewYRadians;
		}
		
		public function set rotationRadians(value:Number):void {
			var oldRotation:Number = rotationRadians;
			var oldSkewX:Number = skewXRadians;
			skewXRadians = oldSkewX + value - oldRotation;
			skewYRadians = value;
		}
		
		public function get rotation():Number {
			return rotationRadians * RAD_TO_DEG;
		}
		
		public function set rotation(value:Number):void {
			rotationRadians = value * DEG_TO_RAD;
		}
		
		// ---- public methods ----
		
		public function rotateAroundInternalPoint(point:Point, angleDegrees:Number):void {
			point = transformPoint(point);
			tx -= point.x;
			ty -= point.y;
			rotate(angleDegrees * DEG_TO_RAD);
			tx += point.x;
			ty += point.y;
		}
		
		public function rotateAroundExternalPoint(point:Point, angleDegrees:Number):void {
			tx -= point.x;
			ty -= point.y;
			rotate(angleDegrees * DEG_TO_RAD);
			tx += point.x;
			ty += point.y;
		}
		
		public function matchInternalPointWithExternal(internalPoint:Point, externalPoint:Point):void {
			var internalPointTransformed:Point = transformPoint(internalPoint);
			var dx:Number = externalPoint.x - internalPointTransformed.x;
			var dy:Number = externalPoint.y - internalPointTransformed.y;
			tx += dx;
			ty += dy;
		}
		
	}
}