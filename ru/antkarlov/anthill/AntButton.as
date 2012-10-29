package ru.antkarlov.anthill
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	import ru.antkarlov.anthill.debug.AntDrawer;
	
	/**
	 * Кнопка обыкновенная.
	 * 
	 * <p>Для визуального представления кнопки используются заранее растеризированные анимации 
	 * как и для AntActor, но с определенными условиями. Анимация кнопки должна состоять 
	 * как минимум из двух кадров, каждый из которых должен представлять определенное состояние 
	 * кнопки: первый кадр - нормальное состояние, второй кадр - подсвеченное состояние при наведении мыши,
	 * третий кадр - нажатое состояние. Если нет необходимости подсвечивать кнопку при наведении мыши,
	 * то нажатое состояние должно быть вторым кадром.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  24.08.2012
	 */
	public class AntButton extends AntEntity
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const NORMAL:uint = 1;
		public static const OVER:uint = 2;
		public static const DOWN:uint = 3;
		
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
		
		/**
		 * Текущее состояние кнопки.
		 * @default    NORMAL
		 */
		public var status:uint;
		
		/**
		 * Событие выполняющееся когда кнопка нажата. В качестве атрибута в метод подписчика передается указатель на кнопку.
		 */
		public var eventDown:AntEvent;
		
		/**
		 * Событие выполняющееся когда на кнопку наведен курсор мыши. В качестве атрибута в метод подписчика передается указатель на кнопку.
		 */
		public var eventOver:AntEvent;
		
		/**
		 * Событие выполняющееся когда курсор мыши вышел за пределы кнопки. В качестве атрибута в метод подписчика передается указатель на кнопку.
		 */
		public var eventOut:AntEvent;
		
		/**
		 * Событие выполняющееся когда кнопка отпущена. В качестве атрибута в метод подписчика передается указатель на кнопку.
		 */
		public var eventUp:AntEvent;
		
		/**
		 * Смещение текстовой метки при нажатии на кнопку.
		 * @default    0,1
		 */
		public var labelOffset:AntPoint;
				
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Текущая прозрачность кнопки.
		 * @default    1
		 */
		protected var _alpha:Number;
		
		/**
		 * Текущий цвет кнопки.
		 * @default    0x00FFFFFF
		 */
		protected var _color:uint;
		
		/**
		 * Цветовая трансформация кнопки. Инициализируется автоматически если кнопке задан цвет отличный от 0x00FFFFFF.
		 * @default    null
		 */
		protected var _colorTransform:ColorTransform;
		
		/**
		 * Хранилище указателей на все добавленные анимации.
		 * @default    AntStorage
		 */
		protected var _animations:AntStorage;
		
		/**
		 * Указатель на текущую анимацию.
		 * @default    null
		 */
		protected var _curAnim:AntAnimation;
		
		/**
		 * Локальное имя текущей анимации.
		 * @default    null
		 */
		protected var _curAnimName:String;
		
		/**
		 * Номер предыдущего кадра.
		 * @default    -1
		 */
		protected var _prevFrame:int;
		
		/**
		 * Указатель на битмап кадра в текущей анимации.
		 */
		protected var _pixels:BitmapData;
		
		/**
		 * Вспомогательный буфер для рендера анимаций с цветовыми трансформациями.
		 * Инициализируется автоматически при перекрашивании или прозрачности.
		 * @default    null
		 */
		protected var _buffer:BitmapData;
		
		/**
		 * Помошник для определения пересечения точки с кнопкой.
		 */
		protected var _point:AntPoint;
		
		/**
		 * Определяет может ли быть кнопка выбрана (зажата).
		 * @default    false
		 */
		protected var _toggle:Boolean;
		
		/**
		 * Определяет является ли кнопка в данный момент выбранной (зажатой). 
		 * @default    false
		 */
		protected var _selected:Boolean;
		
		/**
		 * Определяет наведен ли курсор мышки на кнопку.
		 * @default    false
		 */
		protected var _over:Boolean;
		
		/**
		 * Внутренний помошник для отрисовки графического контента.
		 */
		protected var _flashRect:Rectangle;
		
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
		 * Предыдущее положение, используется для возвращения текстовой метки в исходное положение.
		 */
		protected var _lastLabelPosition:AntPoint;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntButton()
		{
			blend = null;
			smoothing = true;
			status = NORMAL;
			
			_alpha = 1;
			_color = 0x00FFFFFF;
			_colorTransform = null;
			
			_animations = new AntStorage();
			_curAnim = null;
			_curAnimName = null;
			
			_prevFrame = -1;
			_pixels = null;
			_buffer = null;
			_point = new AntPoint();
			_toggle = false;
			_selected = false;
			_over = false;
			
			_flashRect = new Rectangle();
			_flashPoint = new Point();
			_flashPointZero = new Point();
			_matrix = new Matrix();
			
			_lastSize = new AntPoint();
			_lastScale = new AntPoint();
			_lastLabelPosition = new AntPoint();
			
			super();
			
			_isVisual = true;
			
			eventDown = new AntEvent();
			eventOver = new AntEvent();
			eventOut = new AntEvent();
			eventUp = new AntEvent();
			
			AntG.mouse.eventUp.add(onMouseUp);
			
			labelOffset = new AntPoint(0, 1);
		}
		
		/**
		 * Альтернативный конструктор позволяющий быстро создать кнопку с текстом.
		 * 
		 * @param	aAnimName	 Глобальное имя анимации кнопки в кэше анимаций.
		 * @param	aText	 Текст на кнопке.
		 * @param	aFontName	 Имя шрифта для текстовой метки.
		 * @param	aFontSize	 Размер шрифта для текстовой метки.
		 * @param	aFontColor	 Цвет шрифта которым будет написан текст.
		 * @param	aEmbedFont	 Если false то предполагается что необходимо использовать шрифт установленый в ОС, иначе шрифт зашит в флешку.
		 * @return		Возвращает указатель на кнопку с вложенной текстовой меткой.
		 */
		public static function makeTextButton(aAnimName:String, aText:String, aFontName:String = "system", 
			aFontSize:int = 8, aFontColor:uint = 0xFFFFFF, aEmbedFont:Boolean = true, aIsScrolled:Boolean = false):AntButton
		{
			var label:AntLabel = new AntLabel(aFontName, aFontSize, aFontColor, aEmbedFont);
			label.text = aText;
			
			var button:AntButton = new AntButton();
			button.addAnimationFromCache(aAnimName);
			button.add(label);
			
			label.x = button.width * 0.5 - label.width * 0.5 + button.axis.x;
			label.y = button.height * 0.5 - label.height * 0.5 + button.axis.y;
			
			if (!aIsScrolled)
			{
				button.scrollFactor.set(0, 0);
				label.scrollFactor.set(0, 0);
			}
			
			
			return button;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			AntG.mouse.eventUp.remove(onMouseUp);
			
			eventDown.clear();
			eventOver.clear();
			eventOut.clear();
			eventUp.clear();
			
			eventDown = null;
			eventOver = null;
			eventOut = null;
			eventUp = null;
			
			_animations.clear();
			_animations = null;
			_curAnim = null;
			_curAnimName = null;
			
			_colorTransform = null;
			if (_buffer != null)
			{
				_buffer.dispose();
				_buffer = null;
			}
					
			_pixels = null;
			
			super.dispose();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function reset(aX:Number = 0, aY:Number = 0):void
		{
			super.reset(aX, aY);
			updateBounds();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function resetRotation(aAngle:Number = 0):void
		{
			super.resetRotation(aAngle);
			updateBounds();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			updateButton();
			super.update();
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
					drawButton(cam);
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
		 * Добавляет новую анимацию. Если локальное имя анимации не указано, то добавленная анимация будет доступна
		 * по глобальному имени.
		 * 
		 * @param	aAnim	 Анимация которую необходимо добавить.
		 * @param	aName	 Локальное имя анимации по которому можно будет произвести переключение на эту анимацию.
		 * @param	aSwitch	 Переключение на добавленную анимацию.
		 */
		public function addAnimation(aAnim:AntAnimation, aName:String = null, aSwitch:Boolean = true):void
		{
			if (aName == null)
			{
				aName = aAnim.name;
			}

			_animations.set(aName, aAnim);
			if (aSwitch)
			{
				switchAnimation(aName);
			}
		}
		
		/**
		 * Добавляет новую анимацию из кэша анимаций. Если локальное имя анимации не указано, то добавленная анимация 
		 * будет доступна по глобальному имени.
		 * 
		 * @param	aKey	 Имя анимации в кэше которую необходимо добавить.
		 * @param	aName	 Локальное имя анимации по которому можно будет произвести переключение на эту анимацию.
		 * @param	aSwitch	 Переключение на добавленную анимацию.
		 */
		public function addAnimationFromCache(aKey:String, aName:String = null, aSwitch:Boolean = true):void
		{
			addAnimation(AntG.cache.getAnimation(aKey), aName, aSwitch);
		}
		
		/**
		 * Переключение анимации.
		 * 
		 * @param	aName	 Локальное имя анимации на которую следует переключится.
		 */
		public function switchAnimation(aName:String):void
		{
			if (_curAnimName == aName)
			{
				return;
			}
			
			if (_animations.containsKey(aName))
			{
				_curAnim = _animations.get(aName);
				_curAnimName = aName;
				_prevFrame = -1;
				resetHelpers();
				goto(status);
			}
			else
			{
				throw new Error("AntActor::switchAnimation() - Missing animation \"" + aName +"\".");
			}
		}
		
		/**
		 * Проверяет попадает ли кнопка на экран указанной камеры. Если камера не указана то используется камера по умолчанию.
		 * 
		 * @param	aCamera	 Камера для которой нужно проверить видимость кнопки.
		 * @return		Возвращает true если кнопка попадает в экран указанной камеры.
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
		 * 
		 * <p>Примечание: Данный метод выполняется каждый раз перед отрисовкой объекта, но если вы изменили
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

			// Если угол и размеры не изменились, то...
			if (_lastAngle == angle && _lastSize.x == width && _lastSize.y == height &&
				_lastScale.x == scale.x && _lastScale.y == scale.y && !aForce)
			{
				// Если изменилось положение, то обновляем позицию баундсректа и углов.
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
				}
				
				saveLastPosition();
				return;
			}
			
			// Делаем полноценный перерассчет положения углов и баундсректа.
			vertices[0].set(x + axis.x * scale.x, y + axis.y * scale.y); // top left
			vertices[1].set(x + width * scale.x + axis.x * scale.x, y + axis.y * scale.y); // top right
			vertices[2].set(x + width * scale.x + axis.x * scale.x, y + height * scale.y + axis.y * scale.y); // bottom right
			vertices[3].set(x + axis.x * scale.x, y + height * scale.y + axis.y * scale.y); // bottom left
			
			var dx:Number;
			var dy:Number;
			var maxX:Number = 0;
			var maxY:Number = 0;
			var minX:Number = 10000;
			var minY:Number = 10000;
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
		 * Обработка логики кнопки.
		 */
		protected function updateButton():void
		{
			if (cameras == null)
			{
				cameras = AntG.cameras;
			}
			
			var l:AntLabel = label;
			var cam:AntCamera;
			var n:int = cameras.length;
			var resetStatus:Boolean = true;
			for (var i:int = 0; i < n; i++)
			{
				cam = cameras[i] as AntCamera;
				if (cam != null)
				{
					(scrolled) ? AntG.mouse.getWorldPosition(cam, _point) : AntG.mouse.getScreenPosition(cam, _point);
					if (intersectsPoint(_point))
					{
						resetStatus = false;
						if (AntG.mouse.isPressed())
						{
							status = DOWN;
							goto(status);
							if (l != null)
							{
								_lastLabelPosition.set(l.x, l.y);
								l.x += labelOffset.x;
								l.y += labelOffset.y;
							}
							eventDown.send([ this ]);
						}
						
						if (status == NORMAL)
						{
							_over = true;
							status = OVER;
							goto(status);
							eventOver.send([ this ]);
						}
					}
				}
			}
			
			if (resetStatus && status != DOWN)
			{
				if (!_selected)
				{
					if (status != NORMAL)
					{
						eventOut.send([ this ]);
					}
					status = NORMAL;
					goto(status);
				}
				
				_over = false;
			}
		}
		
		/**
		 * Отрисовка кнопки в буффер указанной камеры.
		 * 
		 * @param	aCamera	 Камера в буффер которой необходимо отрисовать актера.
		 */
		protected function drawButton(aCamera:AntCamera):void
		{
			// Если нет текущего кадра или объект не попадает в камеру.
			if (_pixels == null || !onScreen(aCamera))
			{
				return;
			}
			
			_numOnScreen++;
			var p:AntPoint = getScreenPosition(aCamera);
			_flashPoint.x = p.x + axis.x;
			_flashPoint.y = p.y + axis.y;
			_flashRect.width = _pixels.width;
			_flashRect.height = _pixels.height;
			
			// Если не применено никаких трансформаций то выполняем простой рендер через copyPixels().
			if (angle == 0 && scale.x == 1 && scale.y == 1 && blend == null)
			{
				aCamera.buffer.copyPixels((_buffer != null) ? _buffer : _pixels, _flashRect, _flashPoint, null, null, true);
			}
			else
			// Если объект имеет какие-либо трансформации, используем более сложный рендер через draw().
			{
				_matrix.identity();
				_matrix.translate(axis.x, axis.y);
				_matrix.scale(scale.x, scale.y);
				
				if (angle != 0)
				{
					_matrix.rotate(Math.PI * 2 * (angle / 360));
				}
				
				_matrix.translate(_flashPoint.x - axis.x, _flashPoint.y - axis.y);
				aCamera.buffer.draw((_buffer != null) ? _buffer : _pixels, _matrix, null, blend, null, smoothing);
			}
		}
		
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
		 * Сброс локальных помошников.
		 */
		protected function resetHelpers():void
		{
			_flashRect.x = _flashRect.y = 0;
			
			if (_colorTransform != null)
			{
				if (_buffer == null || _buffer.width != _curAnim.width || _buffer.height != _curAnim.height)
				{
					if (_buffer != null)
					{
						_buffer.dispose();
					}

					_buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
				}
			}
			
			calcFrame();
			updateBounds(true);
		}
		
		/**
		 * Перерасчет текущего кадра.
		 */
		protected function calcFrame(aFrame:int = 0):void
		{
			axis.set(_curAnim.offsetX[aFrame], _curAnim.offsetY[aFrame]);
		
			if (_buffer != null)
			{
				_flashRect.width = _buffer.width;
				_flashRect.height = _buffer.height;
				_buffer.fillRect(_flashRect, 0x00FFFFFF);
			}
			
			_pixels = _curAnim.frames[aFrame];
			width = _flashRect.width = _pixels.width;
			height = _flashRect.height = _pixels.height;
			
			// Если имеются какие-либо цветовые трансформации, то используем внутренний буффер для применения эффектов.
			if (_colorTransform != null)
			{
				_buffer.copyPixels(_pixels, _flashRect, _flashPointZero, null, null, false);
				_buffer.colorTransform(_flashRect, _colorTransform);
			}
		}
		
		/**
		 * Переводит состояние кнопки на указанный кадр.
		 * 
		 * @param	aFrame	 Кадр на который необходимо перевести состояние кнопки.
		 */
		protected function goto(aFrame:int):void
		{
			if (_curAnim == null)
			{
				return;
			}
			
			if (_curAnim.totalFrames == 2 && aFrame == 2)
			{
				aFrame = 1;
			}
			else if (_selected && _curAnim.totalFrames == 4)
			{
				aFrame = 4;
			}
			
			aFrame = (aFrame <= 1) ? 1 : (aFrame >= _curAnim.totalFrames) ? _curAnim.totalFrames : aFrame;
			if (_prevFrame != aFrame)
			{
				calcFrame(aFrame - 1);
				_prevFrame = aFrame;
			}
		}
		
		/**
		 * Обработчик отпускания кнопки мыши.
		 */
		protected function onMouseUp():void
		{
			if (!exists || !visible || !active || status != DOWN)
			{
				return;
			}
			
			var sendEvent:Boolean = !_toggle;
			if (_toggle)
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
						(scrolled) ? AntG.mouse.getWorldPosition(cam, _point) : AntG.mouse.getScreenPosition(cam, _point);
						if (intersectsPoint(_point))
						{
							_selected = !_selected;
							sendEvent = true;
							break;
						}
					}
				}
			}
			
			status = (_selected) ? DOWN : ((_over) ? OVER : NORMAL);
			
			if (status != DOWN)
			{
				var l:AntLabel = label;
				if (l != null)
				{
					label.x = width * 0.5 - label.width * 0.5 + axis.x + x;
					label.y = height * 0.5 - label.height * 0.5 + axis.y + y;

					var p:AntPoint = AntMath.rotateDeg(label.x, label.y, x, y, angle);
					label.x = p.x;
					label.y = p.y;
				}
			}
			
			goto(status);
			if (sendEvent)
			{
				eventUp.send([ this ]);
			}
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает первую попавшуюся текстовую метку кнопки. Если текстовых меток нет, то вернет <code>null</code>.
		 */
		public function get label():AntLabel
		{
			return getExtant(AntLabel) as AntLabel;
		}
		
		/**
		 * Устанавливает новый текст для текстовой метки и выравнивает метку по центру кнопки. 
		 * Работает только в том случае если у кнопки есть хотя бы одна вложенная текстовая метка.
		 * Если у кнопки более одной вложенной текстовой метки, то текст будет применен 
		 * только для первой попавшейся.
		 * 
		 * @param	value	 Новый текст.
		 */
		public function set text(value:String):void
		{
			var label:AntLabel = getExtant(AntLabel) as AntLabel;
			if (label != null)
			{
				label.text = value;
				label.x = width * 0.5 - label.width * 0.5 + axis.x + x;
				label.y = height * 0.5 - label.height * 0.5 + axis.y + y;
				
				if (status == DOWN)
				{
					label.x += labelOffset.x;
					label.y += labelOffset.y;
				}
				
				var p:AntPoint = AntMath.rotateDeg(label.x, label.y, x, y, angle);
				label.x = p.x;
				label.y = p.y;
			}
		}
		
		/**
		 * Возвращает текст кнопки. Если у кнопки нет ни одной вложенной текстовой метки, то вернет <code>null</code>.
		 */
		public function get text():String
		{
			var label:AntLabel = getExtant(AntLabel) as AntLabel;
			if (label != null)
			{
				return label.text;
			}
			
			return null;
		}
		
		/**
		 * Определяет состояние выбранности кнопки. Работает только если для кнопки установлен режим чекбокса <code>toggle = true;</code>
		 */
		public function set selected(value:Boolean):void
		{
			if (!_toggle)
			{
				value = false;
			}
			
			_selected = value;
			status = (_selected) ? DOWN : NORMAL;
			goto(status);
		}
		
		/**
		 * @private
		 */
		public function get selected():Boolean
		{
			return _selected;
		}
		
		/**
		 * Определяет режим чекбокса для кнопки.
		 */
		public function set toggle(value:Boolean):void
		{
			_toggle = value;
		}
		
		/**
		 * @private
		 */
		public function get toggle():Boolean
		{
			return _toggle;
		}
		
		/**
		 * Возвращает имя текущей анимации кнопки.
		 */
		public function get currentAnimation():String
		{
			return _curAnimName;
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
						
					if (_buffer == null && _curAnim != null)
					{
						_buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
					}
				}
				else
				{
					_colorTransform = null;
					if (_buffer != null)
					{
						_buffer.dispose();
						_buffer = null;
					}
				}
				
				calcFrame(status - 1);
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
						
					if (_buffer == null && _curAnim != null)
					{
						_buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
					}
				}
				else
				{
					_colorTransform = null;
					if (_buffer != null)
					{
						_buffer.dispose();
						_buffer = null;
					}
				}
				
				calcFrame(status - 1);
			}
		}

	}

}