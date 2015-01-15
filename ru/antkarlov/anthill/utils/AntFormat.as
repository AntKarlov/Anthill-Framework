package ru.antkarlov.anthill.utils
{
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  05.02.2013
	 */
	public class AntFormat extends Object
	{
		
		/**
		 * Корректное форматирование дробных чисел в строку.
		 * 
		 * @param	aValue	 Значение которое необходимо перевести в строку.
		 * @param	aMaxDecimals	 Максимально допустимое количество цифр в дробной части.
		 * @param	aForceDecimals	 Определяет принудительное добавление дробной части даже если значение не является дробным.
		 * @param	aSiStyle	 Определяет стиль отображения, если <code>true</code> то в качестве разделителя используется точка, иначе запятая.
		 * @return		Возвращает текстовое отформатированное значение.
		 */
		public static function formatNumber(aValue:*, aMaxDecimals:int = 2, 
			aForceDecimals:Boolean = true, aSiStyle:Boolean = false):String
		{
			aForceDecimals = (aMaxDecimals == 0) ? false : aForceDecimals;
			
			var i:int = 0;
			var inc:Number = Math.pow(10, aMaxDecimals);
			var str:String = String(Math.round(inc * Number(aValue)) / inc);
			var hasSep:Boolean = str.indexOf(".") == -1, sep:int = hasSep ? str.length : str.indexOf(".");
		    var ret:String = (hasSep && !aForceDecimals ? "" : (aSiStyle ? "," : ".")) + str.substr(sep + 1);
		    if (aForceDecimals)
			{
				for (var j:int = 0; j <= aMaxDecimals - (str.length - (hasSep ? sep - 1 : sep)); j++)
				{
					ret += "0";
				}
			}
			
		    while (i + 3 < (str.substr(0, 1) == "-" ? sep - 1 : sep))
			{
				ret = (aSiStyle ? "." : ",") + str.substr(sep - (i += 3), 3) + ret;
			}
			
		    return str.substr(0, sep - i) + ret;
		}
		
		/**
		 * Форматирует строку в .Net стиль, заменяет значение в фигурных скобках на переданные аргументы.
		 * 
		 * <p>Пример использования:</p>
		 * 
		 * <listing>
		 * var str:String = AntFormat.formatString("Hello {0}! It's a {1}.", "World", "UFO");
		 * trace(str); - // Output the "Hello World! It's a UFO.";
		 * </listing>
		 * 
		 * @param	aFormat	 Текст который будет отформатирован.
		 * @param	...args	 Аргументы через запятую которые будут добавлены в форматируемую строку.
		 * @return		Возвращает отформатированную строку.
		 */
		public static function formatString(aFormat:String, ...args):String
		{
			var i:int = 0;
			var n:int = args.length;
			while (i < n)
			{
				aFormat = aFormat.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
				i++;
			}
			
			return aFormat;
		}
		
		/**
		 * @private
		 */
		public static function formatCommas(aValue:*):String
		{
			var numString:String = aValue.toString();
			var res:String = "";

			while (numString.length > 3)
			{
				var chunk:String = numString.substr(-3);
				numString = numString.substr(0, numString.length - 3);
				res = "," + chunk + res;
			}

			if (numString.length > 0)
			{
				res = numString + res;
			}

			return res;
		}
		
		/**
		 * @private
		 */
		public static function formatSize(aSize:Number):String
		{
			if (aSize >= 1073741824)
			{
				aSize = aSize / 1073741824;
				return aSize.toFixed(2) + " Gb";
			}
			else if (aSize >= 1048576)
			{
				aSize = aSize / 1048576;
				return aSize.toFixed(2) + " Mb";
			}
			else if (aSize >= 1024)
			{
				aSize = aSize / 1024;
				return aSize.toFixed(2) + " Kb";
			}
			else
			{
				return aSize.toFixed(0) + " B";
			}
		}
		
		/**
		 * @private
		 */
		public static function formatTime(aValue:int, aShowMS:Boolean = false):String
		{
			var hours:int = aValue / (1000 * 60 * 60);
			var minutes:int = (aValue % (1000 * 60 * 60)) / (1000 * 60);
			var seconds:int = ((aValue % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
			var ms:int = aValue % 10;
			
			var zeroHour:String = (hours < 10) ? "0" : "";
			var zeroSec:String = (seconds < 10) ? "0" : "";
			var zeroMin:String = (minutes < 10) ? "0" : "";
			
			if (aShowMS)
			{
				return formatString("{0}:{1}:{2}.{3}", 
					zeroHour + hours.toString(), 
					zeroMin + minutes.toString(), 
					zeroSec + seconds.toString(), ms);
			}
			else
			{
				return formatString("{0}:{1}:{2}",
					zeroHour + hours.toString(),
					zeroMin + minutes.toString(),
					zeroSec + seconds.toString());
			}
		}

	}

}