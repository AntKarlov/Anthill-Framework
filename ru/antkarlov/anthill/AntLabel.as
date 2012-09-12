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
		
		/**
		 * Выранивание отсуствует.
		 */
		public static const ALIGN_NONE:String = "none";
		
		/**
		 * Выравнивание по левому краю.
		 */
		public static const ALIGN_LEFT:String = "left";
		
		/**
		 * Выравнивание по правому краю.
		 */
		public static const ALIGN_RIGHT:String = "right";
		
		/**
		 * Выравнивание по центру.
		 */
		public static const ALIGN_CENTER:String = "center";
		
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
		 * Предыдущий размер, используется для оптимизации перерассчетов.
		 */
		protected var _lastSize:AntPoint;
		
		/**
		 * Предыдущее масштабирование, используется для оптимизации перерассчетов.
		 */
		protected var _lastScale:AntPoint;
		
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
		public function AntLabel(aFontName:String, aFontSize:int = 8, aColor:uint = 0xFFFFFF,
			aEmbedFont:Boolean = true)
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
			
			width = _textField.width;
			height = _textField.height;
			
			_flashRect = new Rectangle();
			_flashPoint = new Point();
			_flashPointZero = new Point();
			_matrix = new Matrix();
			
			_lastSize = new AntPoint();
			_lastScale = new AntPoint();
			
			_canRedraw = true;
			
			_align = ALIGN_LEFT;
			_color = 0xFFFFFF;
			_alpha = 1;
			
			_isVisual = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_textField = null;
			_textFormat = null;
					
			_colorTransform = null;
			if (_buffer != null)
			{
				_buffer.dispose();
				_buffer = null;
			}
			
			super.dispose();
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
		 * Устанавливает размер текстового поля в ручную. Актуально только если 
		 * <code>align = ALIGN_NONE</code> и <code>wordWrap = true</code>.
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
		 * Запрещает растерезацию текста до тех пор пока не будет вызван метод <code>endUpdate()</code>.
		 * Следует вызывать перед тем как необходимо применить сразу много сложных операций к тексту.
		 * <p>Пример использования:
		 * <code>label.beginUpdate();
		 * label.setSize(200, 50);
		 * label.text = "some big text here";
		 * label.setColor(0x00FF00, 0, 4);
		 * label.endUpdate();</code></p>
		 */
		public function beginUpdate():void
		{
			_canRedraw = false;
		}
		
		/**
		 * Разрешает растеризацию текста. Обязательно вызывать после того как был вызван метод <code>beginUpdate()</code>.
		 */
		public function endUpdate():void
		{
			_canRedraw = true;
			calcFrame();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void
		{
			if (cameras == null)
			{
				cameras = AntG.cameras;
			}
			
			var cam:AntCamera;
			var n:int = cameras.length;
			for (var i:int = 0; i < n; i++)
			{
				cam = cameras[i] as AntCamera;
				if (cam != null)
				{
					drawText(cam);
					_numOfVisible++;
					if (AntG.debugDrawer != null && allowDebugDraw)
					{
						debugDraw(cam);
					}
				}
			}
			
			super.draw();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function debugDraw(aCamera:AntCamera):void
		{
			if (!onScreen())
			{
				return;
			}
			
			var p1:AntPoint = new AntPoint();
			var p2:AntPoint = new AntPoint();
			var drawer:AntDrawer = AntG.debugDrawer;
			drawer.setCamera(aCamera);
			
			if (drawer.showBorders)
			{
				toScreenPosition(vertices[0].x, vertices[0].y, aCamera, p1);
				drawer.moveTo(p1.x, p1.y);			
				var n:int = vertices.length;
				for (var i:int = 0; i < n; i++)
				{
					toScreenPosition(vertices[i].x, vertices[i].y, aCamera, p1);
					drawer.lineTo(p1.x, p1.y, 0xffadff54);
				}
				toScreenPosition(vertices[0].x, vertices[0].y, aCamera, p1);
				drawer.lineTo(p1.x, p1.y, 0xffadff54);
			}
			
			if (drawer.showBounds)
			{
				toScreenPosition(bounds.x, bounds.y, aCamera, p1);
				drawer.drawRect(p1.x, p1.y, bounds.width, bounds.height);
			}
			
			if (drawer.showAxis)
			{
				toScreenPosition(x, y, aCamera, p1);
				drawer.drawAxis(p1.x, p1.y, 0xff70cbff);
			}
		}
		
		/**
		 * Проверяет попадает ли текст на экран указанной камеры. Если камера не указана то используется камера по умолчанию.
		 * 
		 * @param	aCamera	 Камера для которой нужно проверить видимость текста.
		 * @return		Возвращает true если текст попадает в экран указанной камеры.
		 */
		override public function onScreen(aCamera:AntCamera = null):Boolean
		{
			if (aCamera == null)
			{
				aCamera = AntG.getDefaultCamera();
			}
			
			updateBounds();
			
			return bounds.intersects(aCamera.scroll.x * -1 * scrollFactor.x, aCamera.scroll.y * -1 * scrollFactor.y, 
				aCamera.width / aCamera.zoom, aCamera.height / aCamera.zoom);
		}
		
		/**
		 * Обновляет положение и размеры прямоугольника определяющего занимаеммую область объектом в игровом мире.
		 * <p>Внимание: Данный метод выполняется каждый раз перед отрисовкой объекта, но если вы изменили
		 * размеры объекта, положение объекта или положение оси объекта, то прежде чем производить
		 * какие-либо рассчеты с прямоугольником определяющего занимаемую область, необходимо вызывать данный
		 * метод вручную!</p>
		 * 
		 * @param	aForce	 Если true то положение и размеры прямоугольника будут обновлены принудительно.
		 */
		public function updateBounds(aForce:Boolean = false):void
		{
			var p:AntPoint;
			var i:int;
			
			// Если угол не изменился...
			if (_lastAngle == angle && _lastScale.x == scale.x && _lastScale.y == scale.y && !aForce)
			{
				// Но изменилось положение, то обновляем позицию баундсректа и углов.
				if (_lastPosition.x != x || _lastPosition.y != y)
				{
					var mx:Number = x - _lastPosition.x;
					var my:Number = y - _lastPosition.y;
					bounds.x += mx;
					bounds.y += my;

					for (i = 0; i < 4; i++)
					{
						p = vertices[i];
						p.x += mx;
						p.y += my;
					}

					saveLastPosition();
				}
				
				return;
			}
			
			// Делаем полноценный перерассчет положения углов и баундсректа.
			
			vertices[0].set(x - axis.x * scale.x, y - axis.y * scale.y); // top left
			vertices[1].set(x + width * scale.x - axis.x * scale.x, y - axis.y * scale.y); // top right
			vertices[2].set(x + width * scale.x - axis.x * scale.x, y + height * scale.y - axis.y * scale.y); // bottom right
			vertices[3].set(x - axis.x * scale.x, y + height * scale.y - axis.y * scale.y); // bottom left

			var maxX:Number = 0;
			var maxY:Number = 0;
			var minX:Number = 10000;
			var minY:Number = 10000;
			var dx:Number;
			var dy:Number;
			var ang:Number = -angle * Math.PI / 180; // Angle in radians

			for (i = 0; i < 4; i++)
			{
				p = vertices[i];
				
				dx = x + (p.x - x) * Math.cos(ang) + (p.y - y) * Math.sin(ang);
				dy = y - (p.x - x) * Math.sin(ang) + (p.y - y) * Math.cos(ang);
				
				maxX = (dx > maxX) ? dx : maxX;
				maxY = (dy > maxY) ? dy : maxY;
				minX = (dx < minX) ? dx : minX;
				minY = (dy < minY) ? dy : minY;
				p.set(dx, dy);
			}

			bounds.set(minX, minY, maxX - minX, maxY - minY);
			saveLastPosition();
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function saveLastPosition():void
		{
			super.saveLastPosition();
			_lastSize.set(width, height);
			_lastScale.set(scale.x, scale.y);
		}
		
		/**
		 * Отрисовка текста в буффер указанной камеры.
		 * 
		 * @param	aCamera	 Камера в буффер которой необходимо отрисовать текст.
		 */
		protected function drawText(aCamera:AntCamera):void
		{
			if (_buffer == null || !onScreen(aCamera))
			{
				return;
			}
			
			_numOnScreen++;
			var p:AntPoint = getScreenPosition(aCamera);
			_flashPoint.x = p.x - axis.x;
			_flashPoint.y = p.y - axis.y;
			
			// Если не применено никаких трансформаций то выполняем простой рендер через copyPixels().
			if (angle == 0 && scale.x == 1 && scale.y == 1 && blend == null)
			{
				aCamera.buffer.copyPixels(_buffer, _flashRect, _flashPoint, null, null, true);
			}
			else
			// Если объект имеет какие-либо трансформации, используем более сложный рендер через draw().
			{
				_matrix.identity();
				_matrix.translate(-axis.x, -axis.y);
				_matrix.scale(scale.x, scale.y);
				
				if (angle != 0)
				{
					_matrix.rotate(Math.PI * 2 * (angle / 360));
				}
				
				_matrix.translate(_flashPoint.x + axis.x, _flashPoint.y + axis.y);
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
		 * Сброс помошников.
		 */
		protected function resetHelpers():void
		{
			if (width == 0 || height == 0)
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
			updateBounds(true);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет толщину начертания текста.
		 */
		public function set bold(value:Boolean):void
		{
			if (_textFormat.bold != value)
			{
				_textFormat.bold = value;
				_textField.setTextFormat(_textFormat, 0, _textField.length);
				calcFrame();
			}
		}
		
		/**
		 * @private
		 */
		public function get bold():Boolean
		{
			return _textFormat.bold;
		}
		
		/**
		 * Определяет текст для текстовой метки.
		 */
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
		 * @private
		 */
		public function get text():String
		{
			return _textField.text;
		}

		/**
		 * Определяет возможен ли перенос строк.
		 */
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
		 * @private
		 */
		public function get wordWrap():Boolean
		{
			return _textField.wordWrap;
		}
		
		/**
		 * Определяет выравнивание текста.
		 */
		public function set align(value:String):void
		{
			if (_align != value)
			{
				_align = value;
				switch (_align)
				{
					case ALIGN_NONE :
						_textField.autoSize = TextFieldAutoSize.NONE;
					break;
					
					case ALIGN_LEFT :
						_textField.autoSize = TextFieldAutoSize.LEFT;
					break;
					
					case ALIGN_RIGHT :
						_textField.autoSize = TextFieldAutoSize.RIGHT;
					break;
					
					case ALIGN_CENTER :
						_textField.autoSize = TextFieldAutoSize.CENTER;
					break;
				}
				
				resetHelpers();
			}
		}
		
		/**
		 * @private
		 */
		public function get align():String
		{
			return _align;
		}
		
		/**
		 * Определяет текущую прозрачность.
		 */
		public function get alpha():Number
		{
			return _alpha;
		}
		
		/**
		 * @private
		 */
		public function set alpha(value:Number):void
		{
			value = (value > 1) ? 1 : (value < 0) ? 0 : value;
			
			if (_alpha != value)
			{
				_alpha = value;
				if (_alpha != 1 || _color != 0x00FFFFFF)
				{
					_colorTransform = new ColorTransform(Number(_color >> 16) / 255,
						Number(_color >> 8&0xFF) / 255,
						Number(_color & 0xFF) / 255, _alpha);
				}
				else
				{
					_colorTransform = null;
				}
				
				calcFrame();
			}
		}
		
		/**
		 * Определяет текущий цвет.
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * @private
		 */
		public function set color(value:uint):void
		{
			value &= 0x00FFFFFF;
			if (_color != value)
			{
				_color = value;
				if (_alpha != 1 || _color != 0x00FFFFFF)
				{
					_colorTransform = new ColorTransform(Number(_color >> 16) / 255,
						Number(_color >> 8&0xFF) / 255,
						Number(_color & 0xFF) / 255, _alpha);
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
		
	}

}