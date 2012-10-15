package ru.antkarlov.anthill.debug
{
	import flash.display.BitmapData;
	import ru.antkarlov.anthill.*;
	
	/**
	 * Отладочный невизуальный класс выполняющий отладочную отрисовку сущностей.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  11.09.2012
	 */
	public class AntDrawer extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Флаг определяющий необходимость рисования осей сущности.
		 */
		public var showAxis:Boolean;
		
		/**
		 * Флаг определяющий необходимость рисования краев сущности.
		 */
		public var showBorders:Boolean;
		
		/**
		 * Флаг определяющий необходимость рисования занимаемую сущностью область.
		 */
		public var showBounds:Boolean;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Точка помошник определяющая откуда будет нарисована линия.
		 */
		protected var _lineFrom:AntPoint;
		
		/**
		 * Указатель на буффер текущей камеры.
		 */
		protected var _buffer:BitmapData;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntDrawer()
		{
			super();
			
			_buffer = null;
			showAxis = true;
			showBorders = true;
			showBounds = true;
			
			_lineFrom = new AntPoint();
		}
		
		/**
		 * Устанавливает камеру в буффер которой будет производится отрисовка.
		 * 
		 * @param	aCamera	 Указатель на камеру в котору необходимо производить отрисовку.
		 */
		public function setCamera(aCamera:AntCamera = null):void
		{
			if (aCamera == null)
			{
				_buffer = null;
				return;
			}
			
			_buffer = aCamera.buffer;
		}
		
		/**
		 * Устанавливает начальное положение для рисования линии.
		 * 
		 * @param	aX	 Координата X.
		 * @param	aY	 Координата Y.
		 */
		public function moveTo(aX:int, aY:int):void
		{
			_lineFrom.set(aX, aY);
		}
		
		/**
		 * Рисует линию от ранее установленного положения в указанную точку.
		 * 
		 * @param	aX	 Координата X.
		 * @param	aY	 Координата Y.
		 * @param	aColor	 Цвет линии.
		 */
		public function lineTo(aX:int, aY:int, aColor:uint = 0xffff00ff):void
		{
			drawLine(_lineFrom.x, _lineFrom.y, aX, aY, aColor);
			_lineFrom.set(aX, aY);
		}
		
		/**
		 * Рисует однопиксельную точку.
		 * 
		 * @param	aX	 Координата X.
		 * @param	aY	 Координата Y.
		 * @param	aColor	 Цвет точки.
		 */
		public function drawPoint(aX:Number, aY:Number, aColor:uint = 0xffff00ff):void
		{
			if (_buffer == null)
			{
				return;
			}
			
			_buffer.setPixel(aX, aY, aColor);
		}
		
		/**
		 * Рисует линию из точки A в точку B.
		 * 
		 * "Extremely Fast Line Algorithm"
		 * @author Po-Han Lin (original version: http://www.edepot.com/algorithm.html)
		 * @author Simo Santavirta (AS3 port: http://www.simppa.fi/blog/?p=521)
		 * @author Jackson Dunstan (minor formatting)
		 * 
		 * @param	aX1	 Координата X точки A.
		 * @param	aY1	 Координата Y точки A.
		 * @param	aX2	 Координата X точки B.
		 * @param	aY2	 Координата Y точки B.
		 * @param	aColor	 Цвет линии.
		 */
		public function drawLine(aX1:int, aY1:int, aX2:int, aY2:int, aColor:uint = 0xffff00ff):void
		{
			if (_buffer == null)
			{
				return;
			}
			
			var shortLen:int = aY2 - aY1;
			var longLen:int = aX2 - aX1;

			if ((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31))
			{
				shortLen ^= longLen;
				longLen ^= shortLen;
				shortLen ^= longLen;

				var yLonger:Boolean = true;
			}
			else
			{
				yLonger = false;
			}

			var inc:int = longLen < 0 ? -1 : 1;

			var multDiff:Number = longLen == 0 ? shortLen : shortLen / longLen;

			if (yLonger)
			{
				for (var i:int = 0; i != longLen; i += inc)
				{
					_buffer.setPixel(aX1 + i * multDiff, aY1 + i, aColor);
				}
			}
			else
			{
				for (i = 0; i != longLen; i += inc)
				{
					_buffer.setPixel(aX1 + i, aY1 + i * multDiff, aColor);
				}
			}
		}
		
		/**
		 * Рисует прямоугольник.
		 * 
		 * @param	aX	 Положение прямоугольника по X.
		 * @param	aY	 Положение прямоугольника по Y.
		 * @param	aWidth	 Ширина прямоугольника.
		 * @param	aHeight	 Высота прямоугольника.
		 * @param	aColor	 Цвет прямоугольника.
		 */
		public function drawRect(aX:int, aY:int, aWidth:int, aHeight:int, aColor:uint = 0xffff00ff):void
		{
			moveTo(aX, aY);
			lineTo(aX + aWidth, aY, aColor);
			lineTo(aX + aWidth, aY + aHeight, aColor);
			lineTo(aX, aY + aHeight, aColor);
			lineTo(aX, aY, aColor);
		}
		
		/**
		 * Рисует круг.
		 * 
		 * @param	aX	 Положение центра круга по X.
		 * @param	aY	 Положение центра круга по Y.
		 * @param	aRadius	 Радиус круга.
		 * @param	aColor	 Цвет круга.
		 */
		public function drawCircle(aX:int, aY:int, aRadius:int, aColor:uint = 0xffff00ff):void
		{
			var dx:int = 0;
			var dy:int = aRadius;
			var delta:int = 2 - 2 * aRadius;
			while (dx < dy)
			{
				plotCircle(dx, dy, aX, aY, aColor);
				plotCircle(dy, dx, aX, aY, aColor);
				if (delta < 0)
				{
					delta += 4 * dx + 6;
				}
				else
				{
					delta += 4 * (dx - dy) + 10;
					dy--;
				}
				dx++;

				if (dx == dy)
				{
					plotCircle(dx, dy, aX, aY, aColor);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function plotCircle(aX:int, aY:int, cX:int, cY:int, aColor:uint):void
		{
			if (_buffer == null)
			{
				return;
			}
			
			_buffer.setPixel(cX + aX, cY + aY, aColor);
			_buffer.setPixel(cX + aX, cY - aY, aColor);
			_buffer.setPixel(cX - aX, cY + aY, aColor);
			_buffer.setPixel(cX - aX, cY - aY, aColor);
		}
		
		/**
		 * Рисует оси (креcтик);
		 * 
		 * @param	aX	 Положение оси по X.
		 * @param	aY	 Положение оси по Y.
		 */
		public function drawAxis(aX:int, aY:int, aColor:uint = 0xffff00ff):void
		{
			drawLine(aX, aY - 2, aX, aY + 3, aColor);
			drawLine(aX - 2, aY, aX + 3, aY, aColor);
		}

	}

}