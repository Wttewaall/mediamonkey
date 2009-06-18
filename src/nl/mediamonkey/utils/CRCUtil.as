package nl.mediamonkey.utils {
	
	public class CRCUtil {
		
		public static function calcCRC(s:String):String {
			var crc:uint = 0xFFFF;
	
			// Process each character in the string.
			var n:int = s.length;
			for (var i:int = 0; i < n; i++) {
				var charCode:uint = s.charCodeAt(i);
				
				// Unicode characters can be greater than 255.
				// If so, we let both bytes contribute to the CRC.
				// If not, we let only the low byte contribute.
				var loByte:uint = charCode & 0x00FF;
				var hiByte:uint = charCode >> 8;
				if (hiByte != 0)
					crc = updateCRC(crc, hiByte);
				crc = updateCRC(crc, loByte);
			}
	
			// Process 2 additional zero bytes, as specified by the CCITT algorithm.
			crc = updateCRC(crc, 0);
			crc = updateCRC(crc, 0);
	
			return crc.toString(16);
		}
		
		private static function updateCRC(crc:uint, byte:uint):uint {
			const poly:uint = 0x1021; // CRC-CCITT mask
	
			var bitMask:uint = 0x80;
	
			// Process each bit in the byte.
			for (var i:int = 0; i < 8; i++) {
				var xorFlag:Boolean = (crc & 0x8000) != 0;
				
				crc <<= 1;
				crc &= 0xFFFF;
	
				if ((byte & bitMask) != 0)
					crc++;
	
				if (xorFlag)
					crc ^= poly;
	
				bitMask >>= 1;
			}
	
			return crc;
		}

	}
}