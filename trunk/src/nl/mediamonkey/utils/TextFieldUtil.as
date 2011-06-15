package nl.mediamonkey.utils {
	
	import flash.display.BlendMode;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	public class TextFieldUtil {
		
		protected static const MARGIN	:int = 3; // 3-pixel margin
		protected static const GUTTER	:int = 2; // 2-pixel gutter
		
		public static function createTextField(autoSize:String="left", multiline:Boolean=true, wordWrap:Boolean=true, format:TextFormat=null):TextField {
			var textField:TextField = new TextField();
			textField.multiline = multiline;
			textField.autoSize = autoSize; // TextFieldAutoSize
			textField.wordWrap = wordWrap;
			if (format) textField.defaultTextFormat = format;
			
			/*textField.background = true;
			textField.border = true;
			textField.backgroundColor = 0xFFFFFF;
			textField.borderColor = 0x000000;*/
			
			// force into Bitmap for correct alpha
			textField.blendMode = BlendMode.LAYER;
			
			return textField;
		}
		
		public static function getTextLineWidth(text:String, format:TextFormat=null):Number {
			var textField:TextField = createTextField(TextFieldAutoSize.LEFT, true, false, format);
			textField.text = text;
			
			if (!format) format = textField.getTextFormat();
			textField.setTextFormat(format);
			
			var leftMargin:Number = (format.leftMargin) ? Number(format.leftMargin) : 0;
			var rightMargin:Number = (format.rightMargin) ? Number(format.rightMargin) : 0;
			var lineMetrics:TextLineMetrics = textField.getLineMetrics(0);
			
			var lineWidth:Number = GUTTER*2 + MARGIN*2 + leftMargin + textField.textWidth + rightMargin;
			return lineWidth;
		}
		
		public static function getTextHeight(width:Number, text:String, format:TextFormat=null):Number {
			var textField:TextField = createTextField(TextFieldAutoSize.LEFT, true, true, format);
			textField.width = width;
			textField.text = text;
			
			if (!format) format = textField.getTextFormat();
			textField.setTextFormat(format);
			
			var lineMetrics:TextLineMetrics = textField.getLineMetrics(0);
			var lineHeight:Number = lineMetrics.ascent + lineMetrics.descent + lineMetrics.leading;
			var lines:Number = (textField.textHeight + lineMetrics.leading) / lineHeight;
			
			return lineHeight * lines + GUTTER * 2;
		}
		
		/*protected function measure():void {
			
			var minTextWidth:Number = minWidth - paddingLeft - paddingRight;
			var maxTextWidth:Number = maxWidth - paddingLeft - paddingRight;
			tfLabel.textField.width = maxTextWidth;
			
			var lineMetrics:TextLineMetrics = tfLabel.textField.getLineMetrics(0);
			var lineHeight:Number = lineMetrics.ascent + lineMetrics.descent + lineMetrics.leading;
			var lines:Number = (tfLabel.textField.textHeight + lineMetrics.leading) / lineHeight;
			
			var margin:int = 6;// 2 x 3-pixel margin
			var gutter:int = 4;// 2 x 2-pixel gutter
			
			textWidth = Math.max(minTextWidth, Math.min(tfLabel.textField.textWidth + margin + gutter, maxTextWidth));
			textHeight = lines * lineHeight + gutter;
		}*/
		
	}
}