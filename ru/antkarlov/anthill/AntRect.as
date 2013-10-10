package ru.antkarlov.anthill
{
	
	/**
	 * Помошник для работы с прямоугольниками.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  30.08.2012
	 */
	public class AntRect extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Позиция прямоугольника по X.
		 * @default    0
		 */
		public var x:Number;
		
		/**
		 * Позиция прямоугольника по Y.
		 * @default    0
		 */
		public var y:Number;
		
		/**
		 * Ширина прямоугольника.
		 * @default    0
		 */
		public var width:Number;
		
		/**
		 * Высота прямоугольника.
		 * @default    0
		 */
		public var height:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntRect(aX:Number = 0, aY:Number = 0, aWidth:Number = 0, aHeight:Number = 0)
		{
			super();
			
			x = aX;
			y = aY;
			width = aWidth;
			height = aHeight;
		}
		
		/**
		 * Устанавливает новые значения прямоугольника.
		 * 
		 * @param	aX	 Позиция прямгоугольника по X.
		 * @param	aY	 Позиция прямгоугольника по Y.
		 * @param	aWidth	 Ширина прямоугольника.
		 * @param	aHeight	 Высота прямоугольника.
		 */
		public function set(aX:Number = 0, aY:Number = 0, aWidth:Number = 0, aHeight:Number = 0):void
		{
			x = aX;
			y = aY;
			width = aWidth;
			height = aHeight;
		}
				
		/**
		 * Копирует значения в указанный прямоугольник или создает новый с идентичными значениями.
		 * 
		 * @param	aRect	 Указатель на другой прямоугольник куда произвести клонирование.
		 * @return		Возвращает указатель на новый экземпляр класса прямоугольника с идентичными значениями.
		 */
		public function copy(aRect:AntRect = null):AntRect
		{
			if (aRect == null)
			{
				aRect = new AntRect();
			}
			
			aRect.x = x;
			aRect.y = y;
			aRect.width = width;
			aRect.height = height;
			return aRect;
		}
		
		/**
		 * Копирует значения из указанного прямоугольника.
		 * 
		 * @param	aRect	 Прямоугольник значения которого необходимо скопировать.
		 * @return		Возвращает указатель на себя.
		 */
		public function copyFrom(aRect:AntRect):AntRect
		{
			x = aRect.x;
			y = aRect.y;
			width = aRect.width;
			height = aRect.height;
			return this;
		}
		
		/**
		 * Определяет пересечение текущего прямоугольника с точкой.
		 * 
		 * @param	aPoint	 Точка пересечение с которой необходимо проверить.
		 * @return		Возвращает true если точка внутри прямоугольника.
		 */
		public function intersectsPoint(aPoint:AntPoint):Boolean
		{
			return (aPoint.x > left && aPoint.x < right && aPoint.y > top && aPoint.y < bottom) ? true : false;
		}
		
		/**
		 * Определеяет пересечение текущего прямоугольника с указанным.
		 * 
		 * @param	aRect	 Другой прямоугольник с которым необходимо проверить пересечение.
		 * @return		Возвращает true если прямоугольники пересекаются.
		 */
		public function intersectsRect(aRect:AntRect):Boolean
		{
			return ((aRect.right > left && aRect.left < right) && (aRect.bottom > top && aRect.top < bottom)) ? true : false;
		}
		
		/**
		 * Определеяет пересечение текущего прямоугольника с заданной областью или точкой.
		 * 
		 * @param	aX	 Начало области по x.
		 * @param	aY	 Начало области по y.
		 * @param	aWidth	 Ширина области.
		 * @param	aHeight	 Высота области.
		 * @return		Возвращает true если прямоугольник пересекается с заданной областью.
		 */
		public function intersects(aX:Number, aY:Number, aWidth:Number = 0, aHeight:Number = 0):Boolean
		{
			// Если высота и ширина не указаны, проверяем пересечение с точкой.
			if (aWidth == 0 && aHeight == 0)
			{
				return (aX > left && aX < right && aY > top && aY < bottom) ? true : false;
			}
			
			// Проверяем пересечение с областью.
			var t:Number = aY;
			var r:Number = aX + aWidth;
			var b:Number = aY + aHeight;
			var l:Number = aX;
			
			return ((r > left && l < right) && (b > top && t < bottom)) ? true : false; 
		}
		
		/**
		 * Возвращает позицию верхней грани прямоугольника.
		 */
		public function get top():Number
		{
			return y;
		}
		
		/**
		 * Возвращает позицию нижней грани прямоугольника.
		 */
		public function get bottom():Number
		{
			return y + height;
		}
		
		/**
		 * Возвращает позицию левой грани прямоугольника.
		 */
		public function get left():Number
		{
			return x;
		}
		
		/**
		 * Возвращает позицию правой грани прямоугольника.
		 */
		public function get right():Number
		{
			return x + width;
		}

	}

}