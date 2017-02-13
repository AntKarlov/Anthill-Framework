package ru.antkarlov.anthill.debug
{
	import flash.display.BitmapData;
	import ru.antkarlov.anthill.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
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
		[Embed(source="../resources/DebugFont.png")] private static var ImgFont:Class;
		[Embed(source="../resources/DebugFont.xml", mimeType="application/octet-stream")] private static var XmlFont:Class;
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Флаг определяющий необходимость рисования осей сущности.
		 */
		public static var showAxis:Boolean = true;
		
		/**
		 * Флаг определяющий необходимость рисования краев сущности.
		 */
		public static var showBorders:Boolean = true;
		
		/**
		 * Флаг определяющий необходимость рисования занимаемую сущностью область.
		 */
		public static var showBounds:Boolean = true;
		
		/**
		 * Флаг определяющий необходимость отрисовки сетки.
		 */
		public static var showGrid:Boolean = true;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		private static var _lineFrom:AntPoint = new AntPoint();
		private static var _canvas:BitmapData = null;
		private static var _isTransparent:Boolean;
		
		/**
		 * Помошники для отрисовки текста.
		 */
		private static var _font:AntDebugFont = new AntDebugFont(ImgFont, XmlFont);
		private static var _charBitmap:BitmapData;
		private static var _flashRect:Rectangle = new Rectangle();
		private static var _flashPointZero:Point = new Point();
		private static var _flashPoint:Point = new Point();
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntDrawer()
		{
			super();
		}
		
		/**
		 * Устанавливает текущий рабочий холст в который будет выполнятся отрисовка.
		 * Например: AntDrawer.setCanvas(AntG.getCamera().buffer);
		 * 
		 * @param	aCanvas	 Указатель на BitmapData в который будет выполнятся отрисовка.
		 * @param	aIsTransparent	Определяет наличие Alpha канала у буфера.
		 */
		public static function setCanvas(aCanvas:BitmapData, aIsTransparent:Boolean = false):void
		{
			_canvas = aCanvas;
			_isTransparent = aIsTransparent;
		}
		
		/**
		 * Устанавливает начальное положение для рисования линии.
		 * 
		 * @param	aX	 Координата X.
		 * @param	aY	 Координата Y.
		 */
		public static function moveTo(aX:int, aY:int):void
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
		public static function lineTo(aX:int, aY:int, aColor:uint = 0):void
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
		public static function drawPoint(aX:Number, aY:Number, aColor:uint = 0):void
		{
			if (_canvas != null)
			{
				(_isTransparent) ? _canvas.setPixel32(aX, aY, aColor) : _canvas.setPixel(aX, aY, aColor);
			}
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
		public static function drawLine(aX1:int, aY1:int, aX2:int, aY2:int, aColor:uint = 0):void
		{
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
					drawPoint(aX1 + i * multDiff, aY1 + i, aColor);
				}
			}
			else
			{
				for (i = 0; i != longLen; i += inc)
				{
					drawPoint(aX1 + i, aY1 + i * multDiff, aColor);
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
		public static function drawRect(aX:int, aY:int, aWidth:int, aHeight:int, aColor:uint = 0):void
		{
			moveTo(aX, aY);
			lineTo(aX + aWidth, aY, aColor);
			lineTo(aX + aWidth, aY + aHeight, aColor);
			lineTo(aX, aY + aHeight, aColor);
			lineTo(aX, aY, aColor);
		}
		
		/**
		 * Рисует прямоугольник с заливкой.
		 * 
		 * @param	aX	Положение прямоугольника по X.
		 * @param	aY	 Положение прямоугольника по Y.
		 * @param	aWidth	 Ширина прямоугольника.
		 * @param	aHeight	 Высота прямоугольника.
		 * @param	aColor	 Цвет прямоугольника.
		 */
		public static function fillRect(aX:int, aY:int, aWidth:int, aHeight:int, aColor:uint = 0):void
		{
			if (_canvas != null)
			{
				_flashRect.x = aX;
				_flashRect.y = aY;
				_flashRect.width = aWidth;
				_flashRect.height = aHeight;
				
				if (_flashRect.width < 0)
				{
					_flashRect.width *= -1;
					_flashRect.x -= _flashRect.width;
				}
				
				if (_flashRect.height < 0)
				{
					_flashRect.height *= -1;
					_flashRect.y -= _flashRect.height;
				}

				_canvas.fillRect(_flashRect, aColor);
			}
		}
		
		/**
		 * Рисует круг.
		 * 
		 * @param	aX	 Положение центра круга по X.
		 * @param	aY	 Положение центра круга по Y.
		 * @param	aRadius	 Радиус круга.
		 * @param	aColor	 Цвет круга.
		 */
		public static function drawCircle(aX:int, aY:int, aRadius:int, aColor:uint = 0):void
		{
			if (_canvas == null)
			{
				return;
			}
			
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
		 * Помошник для метода drawCircle().
		 */
		protected static function plotCircle(aX:int, aY:int, cX:int, cY:int, aColor:uint):void
		{
			drawPoint(cX + aX, cY + aY, aColor);
			drawPoint(cX + aX, cY - aY, aColor);
			drawPoint(cX - aX, cY + aY, aColor);
			drawPoint(cX - aX, cY - aY, aColor);
		}
		
		/**
		 * Рисует оси (креcтик);
		 * 
		 * @param	aX	 Положение оси по X.
		 * @param	aY	 Положение оси по Y.
		 */
		public static function drawAxis(aX:int, aY:int, aColor:uint = 0):void
		{
			drawLine(aX, aY - 2, aX, aY + 3, aColor);
			drawLine(aX - 2, aY, aX + 3, aY, aColor);
		}
		
		/**
		 * Выводит текст в указанную позицию.
		 * 
		 * @param	aX	 Положение текста по X.
		 * @param	aY	 Положение текста по Y.
		 * @param	aText	 Текст который будет отрисован.
		 * @param	aColor	 Цвет текста.
		 */
		public static function drawText(aX:int, aY:int, aText:String, aColor:uint = 0):void
		{
			if (_canvas == null)
			{
				return;
			}
			
			var tx:int = aX;
			var ty:int = aY;
			
			const n:int = aText.length;
			var i:int = 0;
			var char:String;
			var originalBitmap:BitmapData;
			while (i < n)
			{
				originalBitmap = _font.getFrame(aText.charAt(i));
				if (originalBitmap != null)
				{
					_flashRect.x = 0;
					_flashRect.y = 0;
					_flashRect.width = originalBitmap.width;
					_flashRect.height = originalBitmap.height;
				
					_font.getPoint(aText.charAt(i), _flashPoint);
					_flashPoint.x += tx;
					_flashPoint.y += ty;
				
					if (aColor != 0)
					{
						if (_charBitmap == null || _charBitmap.width != _flashRect.width || _charBitmap.height != _flashRect.height)
						{
							_charBitmap = new BitmapData(_flashRect.width, _flashRect.height, true, 0x00FFFFFF);
						}

						_charBitmap.copyPixels(originalBitmap, _flashRect, _flashPointZero, null, null, false);
						for (var dy:int = 0; dy < _flashRect.height; dy++)
						{
							for (var dx:int = 0; dx < _flashRect.width; dx++)
							{
								if (extractAlpha(_charBitmap.getPixel32(dx, dy)) > 0)
								{
									_charBitmap.setPixel(dx, dy, aColor);
								}
							}
						}
					
						_canvas.copyPixels(_charBitmap, _flashRect, _flashPoint, null, null, true);
					}
					else
					{
						_canvas.copyPixels(originalBitmap, _flashRect, _flashPoint, null, null, true);
					}
				
					tx += _flashRect.width + 1;
				}
				
				i++;
			}
		}
		
		/**
		 * @private
		 */
		private static function extractAlpha(aColor:uint):int
		{
			return (aColor >> 24) & 0xFF;
		}
		
		/**
		 * @private
		 */
		public static function get canvas():BitmapData
		{
			return _canvas;
		}
		
		/**
		 * @private
		 */
		public static function get isTransparent():Boolean
		{
			return _isTransparent;
		}

	}

}