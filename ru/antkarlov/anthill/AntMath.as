package ru.antkarlov.anthill
{	
	/**
	 * Утилитный класс с полезными математическими методами.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  18.05.2011
	 */
	public class AntMath extends Object
	{
		/**
		 * @private
		 */
		private static const MAX_RATIO:Number = 1 / uint.MAX_VALUE;
		
		/**
		 * @private
		 */
		private static var r:uint = Math.random() * uint.MAX_VALUE;
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Округляет указанное значение в меньшую сторону.
		 * 
		 * @param	value	 Значение которое необходимо округлить.
		 * @return		Округленное значение.
		 */
		public static function floor(value:Number):Number
		{
			var n:Number = int(value);
			return (value > 0) ? (n) : ((n != value) ? n - 1 : n);
		}
		
		/**
		 * Округляет указанное значение в большую сторону.
		 * 
		 * @param	value	 Значение которое необходимо округлить.
		 * @return		Округленное значение.
		 */
		public static function ceil(value:Number):Number
		{
			var n:Number = int(value);
			return (value > 0) ? ((n != value) ? n + 1 : n) : n;
		}
		
		/**
		 * Убирает минус у отрицательных значений, позитивные значения остаются без изменений.
		 * 
		 * @param	value	 Значение для которого необходимо убрать минус.
		 * @return		Позитивное значение.
		 */
		public static function abs(value:Number):Number
		{
			return (value < 0) ? value * -1 : value;
		}
		
		/**
		 * Проверяет вхождение значение в заданный диапазон.
		 * 
		 * @param	value	 Значение вхождение которого необходимо проверить.
		 * @param	aLower	 Наименьшее значение диапазона.
		 * @param	aUpper	 Наибольшоее значение диапазона.
		 * @return		Возвращает true если указанное значение в заданном диапазоне.
		 */
		public static function range(value:Number, aLower:Number, aUpper:Number):Boolean
		{
			return ((value > aLower) && (value < aUpper));
		}
		
		/**
		 * Возрващает ближайшее значение к заданному.
		 * 
		 * @param	value	 Заданное значение.
		 * @param	out1	 Первое возможно ближайшее значение.
		 * @param	out2	 Второе возможно ближайшее значение.
		 * @return		Возвращает ближайшее из out1 и out2 к value.
		 */
		public static function closest(value:Number, out1:Number, out2:Number):Number
		{
			return (Math.abs(value - out1) < Math.abs(value - out1)) ? out1 : out2;
		}
		
		/**
		 * Возвращает случайное целочисленное число из заданного диапазона.
		 * 
		 * @param	aLower	 Меньшее значание в диапазоне.
		 * @param	aUpper	 Большее значание в диапазоне.
		 * @return		Случайное целочисленное число из заданного диапазона.
		 */
		public static function randomRangeInt(aLower:int, aUpper:int):int
		{
			return int(random() * (aUpper - aLower + 1)) + aLower;
		}
		
		/**
		 * Возвращает случайное число из заданного диапазона.
		 * 
		 * @param	aLower	 Меньшее значание в диапазоне.
		 * @param	aUpper	 Большее значание в диапазоне.
		 * @return		Случайное число из заданного диапазона.
		 */
		public static function randomRangeNumber(aLower:Number, aUpper:Number):Number
		{
			return random() * (aUpper - aLower) + aLower;
		}
		
		/**
		 * Возвращает случайное число.
		 * 
		 * @return		Случайное число.
		 */
		public static function random():Number
		{
			r ^= (r << 21);
			r ^= (r >>> 35);
			r ^= (r << 4);
			return r * MAX_RATIO;
		}
		
		/**
		 * Сравнивает указанные значения с возможной погрешностью.
		 * 
		 * @param	aValueA	 Первое значение.
		 * @param	aValueB	 Второе значение.
		 * @param	aDiff	 Допустимая для сравнения погрешность.
		 * @return		Возвращает true если указанные значения равны с допустимой погрешностью.
		 */
		public static function equal(aValueA:Number, aValueB:Number, aDiff:Number = 0.00001):Boolean
		{
			return (Math.abs(aValueA - aValueB) <= aDiff);
		}
		
		/**
		 * Переводит указанное значение из одного диапазона в другой.
		 * 
		 * @param	value	 Значение которое необходимо перевести.
		 * @param	aLower	 Наименьшее значение первого диапазона.
		 * @param	aUpper	 Наибольшее значение первого диапазона.
		 * @param	bLower	 Наименьшее значение второго диапазона.
		 * @param	bUpper	 Наибольшее значение второго диапазона.
		 * @return		Новое значение.
		 */
		public static function remap(value:Number, aLower:Number, aUpper:Number, bLower:Number, bUpper:Number):Number
		{
			return bLower + (bUpper - bLower) * (value - aLower) / (aUpper - aLower);
		}
		
		/**
		 * Ограничивает указанное значение заданным диапазоном.
		 * 
		 * @param	value	 Значение которое необходимо ограничить.
		 * @param	aLower	 Наименьшее значение диапазона.
		 * @param	aUpper	 Наибольшее значение диапазона.
		 * @return		Если значение меньше или больше заданного диапазона, то будет возвращена граница диапазона.
		 */
		public static function trimToRange(value:Number, aLower:Number, aUpper:Number):Number
		{
			return (value > aUpper) ? aUpper : (value < aLower) ? aLower : value;
		}
		
		/**
		 * Возрващает значение из заданного диапазона с заданным коэффицентом.
		 * <p>Например: 
		 * <code>if (aCoef == 0.0) return aLower;
		 * if (aCoef == 1.0) return aUpper;</code></p>
		 * 
		 * @param	aLower	 Наименьшее значение диапазона.
		 * @param	aUpper	 Наибольшее значение диапазона.
		 * @param	aCoef	 Коэффицент.
		 * @return		Значение из диапазона согласно коэфиценту.
		 */
		public static function lerp(aLower:Number, aUpper:Number, aCoef:Number):Number
		{
			return aLower + aCoef * (aUpper - aLower);
		}
		
		/**
		 * Проверяет пересечение двух отрезков.
		 * 
		 * @param	aLineX1	 Первая координата X первого отрезка.
		 * @param	aLineY1	 Первая координата Y первого отрезка.
		 * @param	aLineX2	 Вторая координата X первого отрезка.
		 * @param	aLineY2	 Вторая координата Y первого отрезка.
		 * @param	bLineX1	 Первая координата X второго отрезка.
		 * @param	bLineY1	 Первая координата Y второго отрезка.
		 * @param	bLineX2	 Вторая координата X второго отрезка.
		 * @param	bLineY2	 Вторая координата Y второго отрезка.
		 * @return		Возвращает true если отрезки пересекаются.
		 */
		public static function linesCross(aLineX1:Number, aLineY1:Number, aLineX2:Number, aLineY2:Number,
			bLineX1:Number, bLineY1:Number, bLineX2:Number, bLineY2:Number):Boolean
		{
			var d:Number = (aLineX2 - aLineX1) * (bLineY1 - bLineY2) - (bLineX1 - bLineX2) * (aLineY2 - aLineY1);
			
			// Отрезки паралельны.
			if (d == 0)
			{
				return false;
			}
			
			var d1:Number = (bLineX1 - aLineX1) * (bLineY1 - bLineY2) - (bLineX1 - bLineX2) * (bLineY1 - aLineY1);
			var d2:Number = (aLineX2 - aLineX1) * (bLineY1 - aLineY1) - (bLineX1 - aLineX1) * (aLineY2 - aLineY1);
			
			var t1:Number = d1 / d;
			var t2:Number = d2 / d;
			
			return (t1 >= 0 && t1 <= 1 && t2 >= 0 && t2 <= 1) ? true : false;
		}
		
		/**
		 * Проверят пересечение двух отрезков и рассчитывает точку пересечения.
		 * 
		 * @param	aLine1a	 Первая точка первого отрезка.
		 * @param	aLine1b	 Вторая точка первого отрезка.
		 * @param	aLine2a	 Первая точка второго отрезка.
		 * @param	aLine2b	 ВТорая точка второго отрезка.
		 * @param	aResultPoint	 Указатель на точку в которую будут записаны координаты персечения отрезков.
		 * @return		Возвращает true если отрезки пересекаются.
		 */
		public static function linesCrossPoint(aLine1a:AntPoint, aLine1b:AntPoint, aLine2a:AntPoint, aLine2b:AntPoint,
			aResultPoint:AntPoint = null):Boolean
		{
			var isCollided:Boolean = false;
			var d:Number = (aLine2b.y - aLine2a.y) * (aLine1b.x - aLine1a.x) - (aLine2b.x - aLine2a.x) * (aLine1b.y - aLine1a.y);
			var na:Number = (aLine2b.x - aLine2a.x) * (aLine1a.y - aLine2a.y) -	(aLine2b.y - aLine2a.y) * (aLine1a.x - aLine2a.x);
			var nb:Number = (aLine1b.x - aLine1a.x) * (aLine1a.y - aLine2a.y) -	(aLine1b.y - aLine1a.y) * (aLine1a.x - aLine2a.x);
				
			if (d == 0)
			{
				return isCollided;
			}
			
			var ua:Number = na / d;
			var ub:Number = nb / d;
			
			if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1)
			{
				if (aResultPoint != null)
				{
					aResultPoint.x = aLine1a.x + (ua * (aLine1b.x - aLine1a.x));
					aResultPoint.y = aLine1a.y + (ua * (aLine1b.y - aLine1a.y));
				}
				
				isCollided = true;
			}
			
			return isCollided;
		}
		
		/**
		 * Рассчитывает дистанцию между указанными точками.
		 * 
		 * @param	x1	 Координата X первой точки.
		 * @param	y1	 Координата Y первой точки.
		 * @param	x2	 Координата X второй точки.
		 * @param	y2	 Коордианат Y второй точки.
		 * @return		Возрвщает дистанцию между точками.
		 */
		public static function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/**
		 * Рассчитывает угол между двумя точками в радианах.
		 * 
		 * @param	x1	 Координата X первой точки.
		 * @param	y1	 Координата Y первой точки.
		 * @param	x2	 Координата X второй точки.
		 * @param	y2	 Коордианат Y второй точки.
		 * @param	norm	 Если true, то угол будет нормализован.
		 * @return		Возвращает угол между двумя точками в радианах.
		 */
		public static function angle(x1:Number, y1:Number, x2:Number, y2:Number, norm:Boolean = true):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			var angle:Number = Math.atan2(dy, dx);
			return (norm) ? normAngle(angle) : angle;
		}
		
		/**
		 * Рассчитывает угол между двумя точками в градусах.
		 * 
		 * @param	x1	 Координата X первой точки.
		 * @param	y1	 Координата Y первой точки.
		 * @param	x2	 Координата X второй точки.
		 * @param	y2	 Коордианат Y второй точки.
		 * @param	norm	 Если true, то угол будет нормализован.
		 * @return		Возвращает угол между двумя точками в градусах.
		 */
		public static function angleDeg(x1:Number, y1:Number, x2:Number, y2:Number, norm:Boolean = true):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			var angle:Number = Math.atan2(dy, dx) / Math.PI * 180;
			return (norm) ? normAngleDeg(angle) : angle;
		}
		
		/**
		 * Вращает точку вокруг оси на указанный угол в градусах.
		 * 
		 * @param	aX	 Координата X точки которую необходимо повернуть.
		 * @param	aY	 Координата Y точки которую необходимо повернуть.
		 * @param	aPivotX	 Координата X оси вокруг которой необходимо вращать.
		 * @param	aPivotY	 Координата Y оси вокруг которой необходимо вращать.
		 * @param	aAngle	 Угол в радианах на который необходимо повернуть точку.
		 * @param	aResult	 Указатель на точку куда могут быть сохранены результаты вращения.
		 * @return		Возвращает новые координаты поворачиваемой точки в типе AntPoint.
		 */
		public static function rotateDeg(aX:Number, aY:Number, aPivotX:Number, aPivotY:Number, 
			aAngle:Number, aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			var radians:Number = -aAngle / 180 * Math.PI;
			var dx:Number = aX - aPivotX;
			var dy:Number = aPivotY - aY;
			
			aResult.x = aPivotX + Math.cos(radians) * dx - Math.sin(radians) * dy;
			aResult.y = aPivotY - (Math.sin(radians) * dx + Math.cos(radians) * dy);
			
			return aResult;
		}
		
		/**
		 * Вращает точку вокруг оси на указанный угол в градусах.
		 * 
		 * @param	aPoint	 Точка которую необходимо повернуть.
		 * @param	aPivot	 Точка ось вокруг которой необходимо вращать.
		 * @param	aAngle	 Угол в радианах на который необходимо повернуть точку.
		 * @param	aResult	 Указатель на точку куда могут быть сохранены результаты вращения.
		 * @return		Возвращает новые координаты поворачиваемой точки в типе AntPoint.
		 */
		public static function rotatePointDeg(aPoint:AntPoint, aPivot:AntPoint, aAngle:Number, 
			aResult:AntPoint):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			var radians:Number = -aAngle / 180 * Math.PI;
			var dx:Number = aPoint.x - aPivot.x;
			var dy:Number = aPivot.y - aPoint.y;
			
			aResult.x = aPivot.x + Math.cos(radians) * dx - Math.sin(radians) * dy;
			aResult.y = aPivot.y - (Math.sin(radians) * dx + Math.cos(radians) * dy);
			
			return aResult;
		}
		
		/**
		 * Переводит радианы в градусы.
		 * 
		 * @param	aRadians	 Угол в радианах.
		 * @return		Возвращает угол в градусах.
		 */
		public static function toDegrees(aRadians:Number):Number
		{
			return aRadians * 180 / Math.PI;
		}
		
		/**
		 * Переводит градусы в радианы.
		 * 
		 * @param	aDegrees	 Угол в градусах.
		 * @return		Возвращает угол в радианах.
		 */
		public static function toRadians(aDegrees:Number):Number
		{
			return aDegrees * Math.PI / 180;
		}
		
		/**
		 * Нормализирует угол в градусах.
		 * 
		 * @param	aAngle	 Угол в градусах который необходимо нормализировать.
		 * @return		Возвращает нормализированный угол в градусах.
		 */
		public static function normAngleDeg(aAngle:Number):Number
		{
			return (aAngle < 0) ? 360 + aAngle : (aAngle >= 360) ? aAngle - 360 : aAngle;
		}
		
		/**
		 * Нормализирует угол в радианах.
		 * 
		 * @param	aAngle	 Угол в радианах который необходимо нормализировать.
		 * @return		Возвращает нормализированный угол в радианах.
		 */
		public static function normAngle(aAngle:Number):Number
		{
			return (aAngle < 0) ? Math.PI * 2 + aAngle : (aAngle >= Math.PI * 2) ? aAngle - Math.PI * 2 : aAngle;
		}
		
		/**
		 * Рассчитывает процент исходя из текущего и общего значения.
		 * 
		 * @param	aCurrent	 Текущее значание.
		 * @param	aTotal	 Общее значение.
		 * @return		Возвращает процент текущего значения.
		 */
		public static function toPercent(aCurrent:Number, aTotal:Number):Number
		{
			return (aCurrent / aTotal) * 100;
		}
		
		/**
		 * Рассчитывает текущее значение исходя из текущего процента и общего значения.
		 * 
		 * @param	aPercent	 Текущий процент.
		 * @param	aTotal	 Общее значение.
		 * @return		Возвращает текущее значение.
		 */
		public static function fromPercent(aPercent:Number, aTotal:Number):Number
		{
			return (aPercent * aTotal) / 100;
		}
		
		/**
		 * Определяет наибольшее число из указанного массива.
		 * 
		 * @param	aArray	 Массив значений.
		 * @return		Возвращает наибольшее число из массива.
		 */
		public static function maxFrom(aArray:Array):Number
		{
			return Math.max.apply(null, aArray);
		}
		
		/**
		 * Определяет наименьшее число из указанного массива.
		 * 
		 * @param	aArray	 Массив значений.
		 * @return		Возвращает наименьшее число из массива.
		 */
		public static function minFrom(aArray:Array):Number
		{
			return Math.min.apply(null, aArray);
		}
		
		/**
		 * Рассчет скорости.
		 * 
		 * @param	aVelocity	 Текущая скорость.
		 * @param	aAcceleration	 Ускорение.
		 * @param	aDrag	 Замедление.
		 * @param	aMax	 Максимально допустимая скорость.
		 * @return		Возвращает новую скорость на основе входящих параметров.
		 */
		public static function calcVelocity(aVelocity:Number, aAcceleration:Number = 0, 
			aDrag:Number = 0, aMax:Number = 10000):Number
		{
			if (aAcceleration != 0)
			{
				aVelocity += aAcceleration * AntG.elapsed;
			}
			else if (aDrag != 0)
			{
				var dv:Number = aDrag * AntG.elapsed;
				if (aVelocity - dv > 0)
				{
					aVelocity -= dv;
				}
				else if (aVelocity + dv < 0)
				{
					aVelocity += dv;
				}
				else
				{
					aVelocity = 0;
				}
			}
			
			if (aVelocity != 0 && aMax != 10000)
			{
				if (aVelocity > aMax)
				{
					aVelocity = aMax;
				}
				else if (aVelocity < -aMax)
				{
					aVelocity = -aMax;
				}
			}
			
			return aVelocity;
		}
		
	}

}