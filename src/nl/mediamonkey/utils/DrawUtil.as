package nl.mediamonkey.utils {
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class DrawUtil {
		
		/**
		 * Example
			<code>
				var rect:Rectangle = new Rectangle(10, 10, 100, 100);
				var offset:Number = 0;
				var lines:Array = [10, 5, 20, 5];
				
				this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
				protected function enterFrameHandler(event:Event):void {
					DrawUtil.drawDashedRect(this.graphics, rect, offset, lines);
					offset++; // offset-- to animate backwards
				}
			</code>
		**/
		
		public static function dashTo(graphics:Graphics, from:Point, to:Point, offset:Number=0, lines:Array=null, thickness:Number=1, color:uint=0x000000, alpha:Number=1):Number {
			
			if (lines == null) lines = [3, 3];
			
			DebugUtil.assert(lines.length > 0 && lines.length % 2 == 0,
				"lines must have two or more elements, and be an even set");
			
			// segment is the total length of the lines array
			var segment:Number = 0;
			
			// totals is a lookup table for total values up until the value in the lines array
			var totals:Array = [];
			
			// create totals and calculate segment length
			for (var i:uint=0; i<lines.length; i++) {
				
				DebugUtil.assert(lines[i] is Number,
					"value must be of type Number, int or uint");
				
				totals[i] = segment;
				segment += lines[i] as Number;
			}
			
			var dx:Number = to.x - from.x;
			var dy:Number = to.y - from.y;
			var totalDistance:Number = Math.sqrt(dx*dx + dy*dy);
			var angle:Number = Math.atan2(dx, dy);
			var isStraight:Boolean = (angle * (180 / Math.PI) % 90 == 0);
			
			// normalize offset to a positive value within a segment length
			offset = ((offset % segment) + segment) % segment;
			
			// search cursor by offset
			var cursor:uint;
			for (i=0; i<totals.length; i++) {
				var min:Number = totals[i];
				var max:Number = (i+1 < totals.length) ? totals[i+1] : Infinity;
				
				if (offset >= min && offset < max) {
					cursor = i;
					break;
				}
			}
			
			// get distance to start drawing
			var startDistance:Number = lines[cursor] - (offset - totals[cursor]);
			var useStartDistance:Boolean = true;
			
			var drawnDistance:Number = 0;
			var currentDistance:Number = startDistance;
			
			// style
			graphics.lineStyle(thickness, color, alpha, isStraight);
			
			// draw commands and data for Graphics.drawPath method
			var commands:Vector.<int> = new Vector.<int>();
			var data:Vector.<Number> = new Vector.<Number>();
			
			// first point
			var x:Number = from.x;
			var y:Number = from.y;
			
			commands.push(1);
			data.push(x);
			data.push(y);
			
			while (drawnDistance < totalDistance) {
				
				if (useStartDistance) {
					currentDistance = startDistance;
					useStartDistance = false;
					
				} else {
					// get next distance (rotate cursor through the lines array)
					cursor += 1;
					cursor %= lines.length;
					currentDistance = lines[cursor];
				}
				
				// last step
				if (drawnDistance + currentDistance >= totalDistance) {
					currentDistance = totalDistance - drawnDistance;
					offset = totals[cursor] + currentDistance;
				}
				
				x += Math.sin(angle) * currentDistance;
				y += Math.cos(angle) * currentDistance;
				
				commands.push((cursor % 2 == 0) ? 2 : 1);
				data.push(x);
				data.push(y);
				
				drawnDistance += currentDistance;
			}
			
			graphics.drawPath(commands, data);
			
			return offset;
		}
		
		/**
		 * drawDashedRect draws dashed lines in a rectangle uninterrupted through corners
		 * <p>example:</p>
		 * <code>var rect:Rectangle = new Rectangle(50, 50, 200, 200);
		 * var offset:Number = 13;
		 * var lines:Array = [10, 3, 2, 3, 20, 5];
		 * DrawUtil.drawDashedRect(drawGroup.graphics, rect, offset, lines);<code>
		 */
		public static function drawDashedRect(g:Graphics, rect:Rectangle, offset:Number=0, lines:Array=null, thickness:Number=1, color:uint=0x000000, alpha:Number=1):Number {
			
			var p1:Point = new Point(rect.left, rect.top);
			var p2:Point = new Point(rect.right, rect.top);
			var p3:Point = new Point(rect.right, rect.bottom);
			var p4:Point = new Point(rect.left, rect.bottom);
			
			var rest:Number;
			rest = DrawUtil.dashTo(g, p1, p2, offset, lines, thickness, color, alpha);
			rest = DrawUtil.dashTo(g, p2, p3, rest, lines, thickness, color, alpha);
			rest = DrawUtil.dashTo(g, p3, p4, rest, lines, thickness, color, alpha);
			rest = DrawUtil.dashTo(g, p4, p1, rest, lines, thickness, color, alpha);
			
			return rest;
		}
		
		/**
		 * drawDashedRect2 that draws dashed lines in a rectangle uninterrupted and in union from the top-left corner to the bottom-right corner
		 */
		public static function drawDashedRect2(g:Graphics, rect:Rectangle, offset:Number=0, lines:Array=null, thickness:Number=1, color:uint=0x000000, alpha:Number=1):Number {
			
			var p1:Point = new Point(rect.left, rect.top);
			var p2:Point = new Point(rect.right, rect.top);
			var p3:Point = new Point(rect.right, rect.bottom);
			var p4:Point = new Point(rect.left, rect.bottom);
			
			var rest:Number;
			rest = DrawUtil.dashTo(g, p1, p4, offset, lines, thickness, color, alpha);
			rest = DrawUtil.dashTo(g, p4, p3, rest, lines, thickness, color, alpha);
			rest = DrawUtil.dashTo(g, p1, p2, offset, lines, thickness, color, alpha);
			rest = DrawUtil.dashTo(g, p2, p3, rest, lines, thickness, color, alpha);
			
			return rest;
		}
		
		// OLD TRIAL, I GOT STUCK AND GAVE UP: TOO ABSTRACT AND COMPLEX WAY :P
		/*public static function dashTo(g:Graphics, from:Point, to:Point, offset:Number=25, dash:Number=50, space:Number=50):Number {
			var dx:Number = to.x - from.x;
			var dy:Number = to.y - from.y;
			var dist:Number = Math.sqrt(dx*dx + dy*dy);
			var angle:Number = Math.atan2(dx, dy);
			
			var segment:Number = dash + space;
			offset %= segment; // normalize
			
			// first segment
			var s1:Number = segment - Math.abs(offset);
			
			var numSegments:uint = Math.ceil((dist - s1) / segment)
			var rest:Number = (dist - s1) % segment;
			
			var startWithDash:Boolean = (s1 <= dash);
			var endWithDash:Boolean = (segment - rest <= dash);
			
			var numDashes:uint = numSegments + ((startWithDash && endWithDash) ? 1 : 0);
			var numSpaces:uint = numSegments + ((!startWithDash && !endWithDash) ? 1 : 0);
			
			var x:Number = from.x;
			var y:Number = from.y;
			var drawDash:Boolean;
			var value:Number;
			
			var totalSteps:uint = numDashes + numSpaces;
			for (var i:uint=0; i<totalSteps; i++) {
				
				drawDash = Boolean(uint(i % 2 == 0) ^ uint(!startWithDash)); // inverts boolean
				
				graphics.lineStyle(1, (drawDash) ? 0x000000 : 0xFFFFFF, (drawDash) ? 1 : 1, true);
				
				value = (drawDash) ? dash : space;
				
				// first step
					if (i == 0) {
					value = (offset <= dash) ? dash - offset : segment - offset;
				}
				
				// last element
					if (i == totalSteps-1) {
					var lastLength:Number = (rest <= dash) ? rest : rest - dash;
					value = lastLength;
				}
				
				x += Math.sin(angle) * value;
				y += Math.cos(angle) * value;
				graphics.lineTo(x, y);
			}
			
			return rest - segment;
		}*/
		
	}
}