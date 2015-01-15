package ru.antkarlov.anthill
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.filters.GlowFilter;
	import flash.sampler.getSize;
	
	import ru.antkarlov.anthill.debug.AntDrawer;
	
	/**
	 * Обычная текстовая метка используется для отображения текстовой информации.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  23.08.2012
	 */
	public class AntLabel extends AntEntity
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const CENTER:String = "center";
		public static const JUSTIFY:String = "justify";
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Режим смешивания цветов.
		 * @default    null
		 */
		public var blend:String;
		
		/**
		 * Сглаживание.
		 * @default    true
		 */
		public var smoothing:Boolean;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Стандартное текстовое поле которое используется для растеризации текста.
		 */
		protected var _textField:TextField;
		
		/**
		 * Стандартное текстовое форматирование которое используется для применения
		 * к тексту какого-либо оформления.
		 */
		protected var _textFormat:TextFormat;
		
		/**
		 * Текущее выравнивание текста.
		 * @default    ALIGN_LEFT
		 */
		protected var _align:String;
		
		/**
		 * Определяет авто обновление размера текстовой метки в зависимости от объема текста.
		 * @default    true
		 */
		protected var _autoSize:Boolean;
		
		/**
		 * Внутренний буфер в который производится растеризация текста.
		 */
		protected var _buffer:BitmapData;
		
		/**
		 * Цветовая трансформация. Инициализируется автоматически если задан цвет отличный от 0x00FFFFFF.
		 * @default    null
		 */
		protected var _colorTransform:ColorTransform;
		
		/**
		 * Текущий цвет.
		 * @default    0x00FFFFFF
		 */
		protected var _color:uint;
		
		/**
		 * Текущая прозрачность.
		 * @default    1
		 */
		protected var _alpha:Number;
		
		/**
		 * Внутренний помошник для отрисовки графического контента.
		 */
		protected var _flashPoint:Point;
		
		/**
		 * Внутренний помошник для отрисовки графического контента.
		 */
		protected var _flashPointZero:Point;
		
		/**
		 * Внутренний помошник для отрисовки графического контента.
		 */
		protected var _flashRect:Rectangle;
		
		/**
		 * Внутренний помошник для отрисовки графического контента.
		 */
		protected var _matrix:Matrix;
		
		/**
		 * Флаг определяющий возможно ли пересчитать растровый кадр при изменений данных.
		 */
		protected var _canRedraw:Boolean;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntLabel(aFontName:String, aFontSize:int = 8, aColor:uint = 0xFFFFFF, aEmbedFont:Boolean = true)
		{
			super();
			
			blend = null;
			smoothing = true;
			
			_textFormat = new TextFormat(aFontName, aFontSize, aColor);
			_textField = new TextField();
			_textField.multiline = false;
			_textField.wordWrap = false;
			_textField.embedFonts = aEmbedFont;
			_textField.antiAliasType = AntiAliasType.NORMAL;
			_textField.gridFitType = GridFitType.PIXEL;
			_textField.defaultTextFormat = _textFormat;
			_textField.autoSize = TextFieldAutoSize.LEFT;
			_autoSize = true;
			
			width = _textField.width = 100;
			height = _textField.height = 100;
			
			_flashRect = new Rectangle();
			_flashPoint = new Point();
			_flashPointZero = new Point();
			_matrix = new Matrix();
			
			_canRedraw = true;
			
			_align = LEFT;
			_color = 0xFFFFFF;
			_alpha = 1;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			_textField = null;
			_textFormat = null;
					
			_colorTransform = null;
			if (_buffer != null)
			{
				_buffer.dispose();
				_buffer = null;
			}
			
			super.destroy();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Задает цвет текста для всего текстового поля или для указанного диапазона символов.
		 * <p>Примичание: Цвет указанный через <code>setColor()</code> применяется непосредственно к стандартному
		 * текстовому полю и не имеет отношения к значению <color>color</color>. То есть если вы укажете цвет
		 * через <code>setColor()</code>, а потом зададите другой цвет через <code>color</code> - то цвета будут смешаны.</p>
		 * 
		 * @param	aColor	 Цвет в который необходимо перекрасить текст.
		 * @param	aStartIndex	 Начальный индекс символа скоторого начинать красить.
		 * @param	aEndIndex	 Конечный индекс символа до которого красить.
		 */
		public function setColor(aColor:uint, aStartIndex:int = -1, aEndIndex:int = -1):void
		{
			_textFormat.color = aColor;
			_textField.setTextFormat(_textFormat, aStartIndex, aEndIndex);
			calcFrame();
		}
		
		/**
		 * Подсвечивает указанный текст указанным цветом.
		 * 
		 * @param	aText	 Текст который необходимо подсветить.
		 * @param	aColor	 Цвет которым необходимо подсветить.
		 */
		public function highlightText(aText:String, aColor:uint):void
		{
			var str:String = _textField.text;
			var startIndex:int = str.indexOf(aText);
			var endIndex:int = 0;
			var offset:int = 0;
			while (startIndex >= 0)
			{
				offset += endIndex;
				endIndex = startIndex + aText.length;
				setColor(aColor, startIndex + offset, endIndex + offset);
				str = str.slice(endIndex, str.length);
				startIndex = str.indexOf(aText);
			}
		}
		
		/**
		 * Устанавливает размер текстового поля в ручную.
		 * Если autoSize = true то размеры будут автоматически изменены при обновлении текста.
		 * 
		 * @param	aWidth	 Размер текстового поля по ширине.
		 * @param	aHeight	 Размер текстового поля по высоте.
		 */
		public function setSize(aWidth:int, aHeight:int):void
		{
			width = _textField.width = aWidth;
			height = _textField.height = aHeight;
			resetHelpers();
		}
		
		/**
		 * Применяет массив указанных фильтров к текстовому полю и перерасчитывает растр.
		 * 
		 * @param	aFilteresArray	 Массив фильтров которые необходимо применить к тексту.
		 */
		public function applyFilters(aFiltersArray:Array):void
		{
			_textField.filters = aFiltersArray;
			calcFrame();
		}
		
		/**
		 * Устанавливает однопиксельную обводку для текстового поля.
		 * 
		 * @param	aColor	 Цвет обводки.
		 */
		public function setStroke(aColor:uint = 0xFF000000):void
		{
			applyFilters([ new GlowFilter(aColor, 1, 2, 2, 5) ]);
		}
		
		/**
		 * Запрещает обновление текста до тех пор пока не будет вызван <code>endChange()</code>.
		 * Следует вызывать перед тем как необходимо применить сразу много сложных операций к тексту.
		 * <p>Пример использования:</p>
		 * 
		 * <code>
		 * label.beginChange();
		 * label.setSize(200, 50);
		 * label.text = "some big text here";
		 * label.setColor(0x00FF00, 0, 4);
		 * label.endChange();
		 * </code>
		 */
		public function beginChange():void
		{
			_canRedraw = false;
		}
		
		/**
		 * Разрешает обновление текста. Обязательно вызывать после того как был вызван метод <code>beginChange()</code>.
		 */
		public function endChange():void
		{
			_canRedraw = true;
			resetHelpers();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw(aCamera:AntCamera):void
		{
			updateBounds();
			
			/*if (cameras == null)
			{
				cameras = AntG.cameras;
			}
			
			var cam:AntCamera;
			var i:int = 0;
			var n:int = cameras.length;
			while (i < n)
			{
				cam = cameras[i] as AntCamera;
				if (cam != null)
				{
					drawText(cam);
				}
				i++;
			}*/
			
			drawText(aCamera);
			super.draw(aCamera);
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		override protected function calcBounds():void
		{
			vertices[0].set(globalX - origin.x * scaleX, globalY - origin.y * scaleY); // top left
			vertices[1].set(globalX + width * scaleX - origin.x * scaleX, globalY - origin.y * scaleY); // top right
			vertices[2].set(globalX + width * scaleX - origin.x * scaleX, globalY + height * scaleY - origin.y * scaleY); // bottom right
			vertices[3].set(globalX - origin.x * scaleX, globalY + height * scaleY - origin.y * scaleY); // bottom left
			var tl:AntPoint = vertices[0];
			var br:AntPoint = vertices[2];
			bounds.set(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
			saveOldPosition();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function rotateBounds():void
		{
			vertices[0].set(globalX - origin.x * scaleX, globalY - origin.y * scaleY); // top left
			vertices[1].set(globalX + width * scaleX - origin.x * scaleX, globalY - origin.y * scaleY); // top right
			vertices[2].set(globalX + width * scaleX - origin.x * scaleX, globalY + height * scaleY - origin.y * scaleY); // bottom right
			vertices[3].set(globalX - origin.x * scaleX, globalY + height * scaleY - origin.y * scaleY); // bottom left
			
			var dx:Number;
			var dy:Number;
			var p:AntPoint = vertices[0];
			var maxX:Number = p.x;
			var maxY:Number = p.y;
			p = vertices[2];
			var minX:Number = p.x;
			var minY:Number = p.y;
			var rad:Number = -globalAngle * Math.PI / 180; // Radians
			
			var i:int = 0;
			while (i < 4)
			{
				p = vertices[i];
				dx = globalX + (p.x - globalX) * Math.cos(rad) + (p.y - globalY) * Math.sin(rad);
				dy = globalY - (p.x - globalX) * Math.sin(rad) + (p.y - globalY) * Math.cos(rad);
				maxX = (dx > maxX) ? dx : maxX;
				maxY = (dy > maxY) ? dy : maxY;
				minX = (dx < minX) ? dx : minX;
				minY = (dy < minY) ? dy : minY;
				p.x = dx;
				p.y = dy;
				i++;
			}
			
			bounds.set(minX, minY, maxX - minX, maxY - minY);
			saveOldPosition();
		}
		
		/**
		 * Отрисовка текста в буффер указанной камеры.
		 * 
		 * @param	aCamera	 Камера в буффер которой необходимо отрисовать текст.
		 */
		protected function drawText(aCamera:AntCamera):void
		{
			NUM_OF_VISIBLE++;
			BUFFERS_SIZE += memSize;
			
			if (_buffer == null || !onScreen(aCamera))
			{
				return;
			}
			
			NUM_ON_SCREEN++;
			var p:AntPoint = getScreenPosition(aCamera);
			if (aCamera._isMasked)
			{
				p.x -= aCamera._maskOffset.x;
				p.y -= aCamera._maskOffset.y;
			}
			
			_flashPoint.x = p.x - origin.x;
			_flashPoint.y = p.y - origin.y;
			
			// Если не применено никаких трансформаций то выполняем простой рендер через copyPixels().
			if (globalAngle == 0 && scaleX == 1 && scaleY == 1 && blend == null)
			{
				aCamera.buffer.copyPixels(_buffer, _flashRect, _flashPoint, null, null, true);
			}
			else
			// Если объект имеет какие-либо трансформации, используем более сложный рендер через draw().
			{
				_matrix.identity();
				_matrix.translate(-origin.x, -origin.y);
				_matrix.scale(scaleX, scaleY);
				
				if (globalAngle != 0)
				{
					_matrix.rotate(Math.PI * 2 * (globalAngle / 360));
				}
				
				_matrix.translate(_flashPoint.x + origin.x, _flashPoint.y + origin.y);
				aCamera.buffer.draw(_buffer, _matrix, null, blend, null, smoothing);
			}
		}
		
		/**
		 * Растеризация векторного TextField в битмап.
		 */
		protected function calcFrame():void
		{
			if (_buffer == null || !_canRedraw)
			{
				return;
			}
			
			_flashRect.width = _buffer.width;
			_flashRect.height = _buffer.height;
			_buffer.fillRect(_flashRect, 0x00FFFFFF);
			_buffer.draw(_textField);
			
			if (_colorTransform != null)
			{
				_buffer.colorTransform(_flashRect, _colorTransform);
			}
		}
		
		/**
		 * Сброс помошников и обновление битмапа.
		 */
		protected function resetHelpers():void
		{
			if (width == 0 || height == 0 || !_canRedraw)
			{
				return;
			}
			
			_flashRect.x = _flashRect.y = 0;
			_flashRect.width = width;
			_flashRect.height = height;
			
			if (_buffer == null || _buffer.width < width || _buffer.height < height)
			{
				if (_buffer != null)
				{
					_buffer.dispose();
				}
				
				_buffer = new BitmapData(width, height, true, 0x00FFFFFF);
			}
			
			calcFrame();
			updateBounds();
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет толщину начертания текста.
		 */
		public function get bold():Boolean { return _textFormat.bold; }
		public function set bold(value:Boolean):void
		{
			if (_textFormat.bold != value)
			{
				_textFormat.bold = value;
				_textField.setTextFormat(_textFormat);
				resetHelpers();
			}
		}
		
		/**
		 * Определяет текст для текстовой метки.
		 */
		public function get text():String { return _textField.text; }
		public function set text(value:String):void
		{
			if (_textField.text != value)
			{
				_textField.text = value;
				width = _textField.width;
				height = _textField.height;
				resetHelpers();
			}
		}
		
		/**
		 * Определяет изменяется ли текстовое поле автоматически исходя из количества текста.
		 * Выравнивание текста не работает при авто изменении размера поля.
		 */
		public function get autoSize():Boolean { return _autoSize; }
		public function set autoSize(value:Boolean):void
		{
			if (_autoSize != value)
			{
				_autoSize = value;
				_textField.autoSize = (_autoSize) ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;			
				align = _align;
				resetHelpers();
			}
		}
		
		/**
		 * Определяет возможен ли перенос строк.
		 */
		public function get wordWrap():Boolean { return _textField.wordWrap; }
		public function set wordWrap(value:Boolean):void
		{
			if (_textField.wordWrap != value)
			{
				_textField.wordWrap = value;
				_textField.multiline = value;
				resetHelpers();
			}
		}
		
		/**
		 * Определяет выравнивание текста.
		 */
		public function get align():String { return _align; }
		public function set align(value:String):void
		{
			_align = value;
			switch (_align)
			{				
				case LEFT : _textFormat.align = TextFormatAlign.LEFT; break;
				case RIGHT : _textFormat.align = TextFormatAlign.RIGHT; break;
				case CENTER : _textFormat.align = TextFormatAlign.CENTER; break;
				case JUSTIFY : _textFormat.align = TextFormatAlign.JUSTIFY; break;
			}

			_textField.setTextFormat(_textFormat);
			resetHelpers();
		}
		
		/**
		 * Определяет текущую прозрачность кэшированного битмапа текстовой метки.
		 */
		public function get alpha():Number { return _alpha; }
		public function set alpha(value:Number):void
		{
			value = (value > 1) ? 1 : (value < 0) ? 0 : value;
			
			if (_alpha != value)
			{
				_alpha = value;
				if (_alpha != 1 || _color != 0x00FFFFFF)
				{
					_colorTransform = new ColorTransform((_color >> 16) * 0.00392,
						(_color >> 8 & 0xFF) * 0.00392, 
						(_color & 0xFF) * 0.00392, _alpha);
				}
				else
				{
					_colorTransform = null;
				}
				
				calcFrame();
			}
		}
		
		
		
		/**
		 * Определяет текущий цвет кэшированного битмапа текстовой метки.
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void
		{
			value &= 0x00FFFFFF;
			if (_color != value)
			{
				_color = value;
				if (_alpha != 1 || _color != 0x00FFFFFF)
				{
					_colorTransform = new ColorTransform((_color >> 16) * 0.00392,
						(_color >> 8 & 0xFF) * 0.00392, 
						(_color & 0xFF) * 0.00392, _alpha);
				}
				else
				{
					_colorTransform = null;
				}
				
				calcFrame();
			}
		}
		
		
		/**
		 * Возвращает количество символов в тексте.
		 */
		public function get numChars():int
		{
			return _textField.length;
		}
		
		/**
		 * Возвращает количество строк в тексте.
		 */
		public function get numLines():int
		{
			return _textField.numLines;
		}
		
		/**
		 * @private
		 */
		public function get memSize():int
		{
			return (_buffer != null) ? getSize(_buffer) : 0;
		}
		
	}

}