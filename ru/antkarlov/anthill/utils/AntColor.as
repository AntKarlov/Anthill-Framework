package ru.antkarlov.anthill.utils
{
	/**
	 * Утилитный класс предназначенный для работы с цветами. Содержит константы базовых цветов 
	 * и статические методы для конвертации цветов в разные представления.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  19.01.2013
	 */
	public class AntColor
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const WHITE:uint = 0xffffff;
		public static const SILVER:uint = 0xc0c0c0;
		public static const GRAY:uint = 0x808080;
		public static const BLACK:uint = 0x000000;
		public static const RED:uint = 0xff0000;
		public static const MAROON:uint = 0x800000;
		public static const YELLOW:uint = 0xffff00;
		public static const OLIVE:uint = 0x808000;
		public static const LIME:uint = 0x00ff00;
		public static const GREEN:uint = 0x008000;
		public static const AQUA:uint = 0x00ffff;
		public static const TEAL:uint = 0x008080;
		public static const BLUE:uint = 0x0000ff;
		public static const NAVY:uint = 0x000080;
		public static const FUCHSIA:uint = 0xff00ff;
		public static const PURPLE:uint = 0x800080;
				
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Извлекает целочисленное значение прозрачности из шестнадцатиричного значения цвета.
		 * 
		 * @param	aColor	 Шестнадцатиричное значение цвета.
		 * @return		Значение прозрачности от 0 до 255.
		 */
		public static function extractAlpha(aColor:uint):int
		{
			return (aColor >> 24) & 0xFF;
		}
		
		/**
		 * Извлекает целочисленное значение красного цвета из шестнадцатиричного значения цвета.
		 * 
		 * @param	aColor	 Шестнадцатиричное значение цвета.
		 * @return		Значение красного цвета от 0 до 255.
		 */
		public static function extractRed(aColor:uint):int
		{
			return (aColor >> 16) & 0xFF;
		}
		
		/**
		 * Извлекает целочисленное значение зеленого цвета из шестнадцатиричного значения цвета.
		 * 
		 * @param	aColor	 Шестнадцатиричное значение цвета.
		 * @return		Значение зеленого цвета от 0 до 255.
		 */
		public static function extractGreen(aColor:uint):int
		{
			return (aColor >> 8) & 0xFF;
		}
		
		/**
		 * Извлекает целочисленное значение синего цвета из шестнадцатиричного значения цвета.
		 * 
		 * @param	aColor	 Шестнадцатиричное значение цвета.
		 * @return		Значение синего цвета от 0 до 255.
		 */
		public static function extractBlue(aColor:uint):int
		{
			return aColor & 0xFF;
		}
		
		/**
		 * Комбинирует целочисленные значения цвета в шестнадцатиричный формат.
		 * 
		 * @param	aRed	 Значение красного цвета от 0 до 255.
		 * @param	aGreen	 Значение зеленого цвета от 0 до 255.
		 * @param	aBlue	 Значение синего цвета от 0 до 255.
		 * @return		Возвращает шестнадцатиричное значение цвета.
		 */
		public static function combineRGB(aRed:int, aGreen:int, aBlue:int):uint
		{
			return (aRed << 16) | (aGreen << 8) | aBlue;
		}
		
		/**
		 * Комбинирует целочисленные значения цвета с прозрачностью в шастнадцатиричный формат.
		 * 
		 * @param	aRed	 Значение красного цвета от 0 до 255.
		 * @param	aGreen	 Значение зеленого цвета от 0 до 255.
		 * @param	aBlue	 Значение синего цвета от 0 до 255.
		 * @return		Возвращает шестнадцатиричное значение цвета.
		 */
		public static function combineARGB(aAlpha:int, aRed:int, aGreen:int, aBlue:int):uint
		{
			return (aAlpha << 24) | (aRed << 16) | (aGreen << 8) | aBlue;
		}

	}

}