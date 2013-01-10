package ru.antkarlov.anthill
{
	/**
	 * Используется для хранения значений в двухмерной системе координат.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  30.08.2012
	 */
	public class AntPoint extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Значение по X.
		 * @default    0
		 */
		public var x:Number;
		
		/**
		 * Значение по Y.
		 * @default    0
		 */
		public var y:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntPoint(aX:Number = 0, aY:Number = 0)
		{
			super();
			
			x = aX;
			y = aY;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Устанавливает новые значения.
		 * 
		 * @param	aX	 Значение X.
		 * @param	aY	 Значение Y.
		 * @return		Возвращает указатель на себя.
		 */
		public function set(aX:Number = 0, aY:Number = 0):AntPoint
		{
			x = aX;
			y = aY;
			return this;
		}
		
		/**
		 * Копирует свои значения в указанную точку.
		 * 
		 * @param	aPoint	 Точка куда необходимо скопировать свои значения.
		 * @return		Возвращает указатель на точку со скопированными значениями.
		 */
		public function copy(aPoint:AntPoint = null):AntPoint
		{
			if (aPoint == null)
			{
				aPoint = new AntPoint();
			}
			
			aPoint.set(x, y);
			return aPoint;
		}
		
		/**
		 * Копирует значения из указанной точки.
		 * 
		 * @param	aPoint	 Точка значения которой необходимо скопировать.
		 * @return		Возвращает указатель на себя.
		 */
		public function copyFrom(aPoint:AntPoint):AntPoint
		{
			set(aPoint.x, aPoint.y);
			return this;
		}
		
		/**
		 * Складывает значения указанной точки со своими.
		 * 
		 * @param	aPoint	 Точка значения которой необходимо сложить с текущими.
		 * @return		Возвращает указатель на себя.
		 */
		public function incrementPoint(aPoint:AntPoint):AntPoint
		{
			x += aPoint.x;
			y += aPoint.y;
			return this;
		}
		
		/**
		 * Прибавляет указанное значение к своим значениям.
		 * 
		 * @param	value	 Значение которое будет прибавлено к своим координатам.
		 * @return		Возвращает указатель на себя.
		 */
		public function increment(value:Number):AntPoint
		{
			x += value;
			y += value;
			return this;
		}
		
		/**
		 * Умножает значения указанной точки со своими.
		 * 
		 * @param	aPoint	 Точка значения которой необходимо сложить со своими.
		 * @return		Возвращает указатель на себя.
		 */
		public function multiplyPoint(aPoint:AntPoint):AntPoint
		{
			x *= aPoint.x;
			y *= aPoint.y;
			return this;
		}
		
		/**
		 * Умножает свои значения на указанное.
		 * 
		 * @param	value	 Значение на которое будут умножены свои координаты.
		 * @return		Возвращает указатель на себя.
		 */
		public function multiply(value:Number):AntPoint
		{
			x *= value;
			y *= value;
			return this;
		}
		
		/**
		 * Делит свои значения на указанные.
		 * 
		 * @param	aPoint	 Точка значения которой необходимо разделить на свои.
		 * @return		Возвращает указатель на себя.
		 */
		public function dividePoint(aPoint:AntPoint):AntPoint
		{
			x /= aPoint.x;
			y /= aPoint.y;
			return this;
		}
		
		/**
		 * Делит свои значение на указанное.
		 * 
		 * @param	value	 Значение на которое будут разделены свои.
		 * @return		Возвращает указатель на себя.
		 */
		public function divide(value:Number):AntPoint
		{
			x /= value;
			y /= value;
			return this;
		}
		
		/**
		 * Определяет длину точки.
		 */
		public function length():Number
		{
			return Math.sqrt(x * x + y * y);
		}
		
		/**
		 * Производит сравнивание указанных значений со значениями текущей точки.
		 * 
		 * @param	aX	 Координата X которую следует сравнить с текущей координатой.
		 * @param	aY	 Координата Y которую следует сравнить с текущей координатой.
		 * @param	aDiff	 Допустимая погрешность при сравнении.
		 * @return		Возвращает true если указанные значения равны значениям текущей точки с учетом допустимой погрешности.
		 */
		public function equal(aX:Number, aY:Number, aDiff:Number = 0.000001):Boolean
		{
			return (AntMath.equal(x, aX, aDiff) && AntMath.equal(y, aY, aDiff));
		}
		
		/**
		 * Производит сравнивание указанной точки со значениями текущей точки.
		 * 
		 * @param	aPoint	 Точка значения которой следует сравнить с текущими.
		 * @param	aDiff	 Допустимая погрешность при сравнении.
		 * @return		Возвращает true если значения указанной точки равны значениям текущей точки с учетом допустимой погрешности.
		 */
		public function equalPoint(aPoint:AntPoint, aDiff:Number = 0.000001):Boolean
		{
			return (AntMath.equal(x, aPoint.x, aDiff) && AntMath.equal(y, aPoint.y, aDiff));
		}
		
		/**
		 * Преобразует значения точки в текст.
		 */
		public function toString():String
		{
			return "[AntPoint x:" + x.toString() + " y:" + y.toString() + "]";
		}

	}

}