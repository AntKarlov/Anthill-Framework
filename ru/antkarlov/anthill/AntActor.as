package ru.antkarlov.anthill
{	
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	import ru.antkarlov.anthill.debug.AntDrawer;

	/**
	 * Данный класс занимается воспроизведением и отображением растеризированных анимаций.
	 * От этого класса следует наследовать все визуальные игровые объекты.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  21.08.2012
	 */
	public class AntActor extends AntEntity
	{	
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
		 * Номер текущего кадра с учетом скорости анимации. Значение может быть дробным.
		 */
		public var currentFrame:Number;
		
		/**
		 * Общее количество кадров для текущей анимации.
		 */
		public var totalFrames:int;
		
		/**
		 * Проигрывание анимации в обратном порядке.
		 * @default    false
		 */
		public var reverse:Boolean;
		
		/**
		 * Зациклинность воспроизведения анимации.
		 * @default    true
		 */
		public var repeat:Boolean;
		
		/**
		 * Скорость воспроизведения анимации.
		 * @default    1
		 */
		public var animationSpeed:Number;
		
		/**
		 * Событие срабатывающее по окончанию проигрывания анимации.
		 * Добавляемый метод слушатель должен иметь аргумент типа <code>function onComplete(actor:AntActor):void {}</code>
		 */
		public var eventComplete:AntEvent;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Текущая прозрачность.
		 * @default    1
		 */
		protected var _alpha:Number;
		
		/**
		 * Текущий цвет.
		 * @default    0x00FFFFFF
		 */
		protected var _color:uint;
		
		/**
		 * Цветовая трансформация. Инициализируется автоматически если задан цвет отличный от 0x00FFFFFF.
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
		 * Флаг определяющий запущено ли проигрывание анимации.
		 * @default    false
		 */
		protected var _playing:Boolean;
		
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
		 * Инициализируется и удаляется автоматически при перекрашивании или прозрачности.
		 * @default    null
		 */
		protected var _buffer:BitmapData;
		
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
		 * @constructor
		 */
		public function AntActor()
		{
			blend = null;
			smoothing = true;
			currentFrame = 1;
			totalFrames = 0;
			reverse = false;
			repeat = true;
			animationSpeed = 1;
			eventComplete = new AntEvent();
			
			_alpha = 1;
			_color = 0x00FFFFFF;
			_colorTransform = null;
			
			_animations = new AntStorage();
			_curAnim = null;
			_curAnimName = null;
			_playing = false;
			
			_prevFrame = -1;
			_pixels = null;
			_buffer = null;
			
			_flashRect = new Rectangle();
			_flashPoint = new Point();
			_flashPointZero = new Point();
			_matrix = new Matrix();
			
			_lastSize = new AntPoint();
			_lastScale = new AntPoint();
			
			super();
			
			_isVisual = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_animations.clear();
			_animations = null;
			_curAnim = null;
			
			eventComplete.clear();
			eventComplete = null;
			
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
			updateBounds(true);
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
			updateAnimation();
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
					drawActor(cam);
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
			if (!onScreen(aCamera))
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
				currentFrame = 1;
				totalFrames = _curAnim.totalFrames;
				resetHelpers();
			}
			else
			{
				throw new Error("AntActor::switchAnimation() - Missing animation \"" + aName +"\".");
			}
		}
		
		/**
		 * Удаляет анимацию с указанным именем.
		 * 
		 * @param	aName	 Локальное имя анимации которую необходимо удалить.
		 */
		public function removeAnimation(aName:String):void
		{
			if (_animations.containsKey(aName))
			{
				_animations.remove(aName);
			}
		}
		
		/**
		 * Удаляет все анимации из актера.
		 */
		public function clearAnimations():void
		{
			_animations.clear();
		}
		
		/**
		 * Запускает воспроизведение текущией анимации.
		 */
		public function play():void
		{
			_playing = (!_playing) ? true : _playing;
		}

		/**
		 * Останавливает воспроизведение текущей анимации.
		 */
		public function stop():void
		{
			_playing = (_playing) ? false : _playing;
		}
		
		/**
		 * Переводит текущую анимацию на указанный кадр и останавливает воспроизведение.
		 * 
		 * @param	aFrame	 Номер кадра на который необходимо перевести текущую анимацию.
		 */
		public function gotoAndStop(aFrame:Number):void
		{
			currentFrame = (aFrame <= 0) ? 1 : (aFrame > totalFrames) ? totalFrames : aFrame;
			goto(currentFrame);
			stop();
		}
		
		/**
		 * Переводит текущую анимацию актера на указанный кадр и запускает воспроизведение.
		 * 
		 * @param	aFrame	 Номер кадра на который необходимо перевести текущую анимацию.
		 */
		public function gotoAndPlay(aFrame:Number):void
		{
			currentFrame = (aFrame <= 0) ? 1 : (aFrame > totalFrames) ? totalFrames : aFrame;
			goto(currentFrame);
			play();
		}
		
		/**
		 * Запускает воспроизведение текущей анимации со случайного кадра.
		 */
		public function playRandomFrame():void
		{
			gotoAndPlay(AntMath.randomRangeInt(1, totalFrames));
		}
		
		/**
		 * Выполняет переход к следущему кадру текущей анимации.
		 * 
		 * @param	aUseSpeed	 Флаг определяющий следует ли при переходе к следущему кадру использовать скорость анимации.
		 */
		public function nextFrame(aUseSpeed:Boolean = false):void
		{
			aUseSpeed ? currentFrame += animationSpeed : currentFrame++;
			goto(currentFrame);
		}
		
		/**
		 * Выполняет переход к предыдущему кадру текущей анимации.
		 * 
		 * @param	aUseSpeed	 Флаг определяющий следует ли при переходе к предыдущему кадру использовать скорость анимации.
		 */
		public function prevFrame(aUseSpeed:Boolean = false):void
		{
			aUseSpeed ? currentFrame -= animationSpeed : currentFrame--;
			goto(currentFrame);
		}
		
		/**
		 * Проверяет попадает ли актер на экран указанной камеры. Если камера не указана то используется камера по умолчанию.
		 * 
		 * @param	aCamera	 Камера для которой нужно проверить видимость актера.
		 * @return		Возвращает true если актер попадает в экран указанной камеры.
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
		 * Обновляет положение и размеры прямоугольника определяющего занимаеммую область актером в игровом мире.
		 * 
		 * <p>Примечание: Данный метод выполняется каждый раз перед отрисовкой объекта, но если вы изменили
		 * размеры объекта, положение объекта или положение оси объекта, то прежде чем производить
		 * какие-либо рассчеты с прямоугольником определяющего занимаемую область, необходимо вызывать данный
		 * метод вручную.</p>
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
		 * @inheritDoc
		 */
		override protected function saveLastPosition():void
		{
			super.saveLastPosition();
			_lastSize.set(width, height);
			_lastScale.set(scale.x, scale.y);
		}
		
		/**
		 * Отрисовка актера в буффер указанной камеры.
		 * 
		 * @param	aCamera	 Камера в буффер которой необходимо отрисовать актера.
		 */
		internal function drawActor(aCamera:AntCamera):void
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
		 * Сброс внутренних помошников.
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
		 * Обновление текущей анимации.
		 */
		protected function updateAnimation():void
		{
			if (_playing && _curAnim != null)
			{
				if (reverse)
				{
					currentFrame = (currentFrame <= 1) ? totalFrames : currentFrame;
					prevFrame(true);
					if (AntMath.floor(currentFrame) <= 1)
					{
						currentFrame = 1;
						animComplete();
					}
				}
				else
				{
					currentFrame = (currentFrame >= totalFrames) ? 1 : currentFrame;
					nextFrame(true);
					if (AntMath.floor(currentFrame) >= totalFrames)
					{
						currentFrame = totalFrames;
						animComplete();
					}
				}
			}
		}
		
		/**
		 * Переводит текущую анимацию на указанный кадр.
		 * 
		 * @param	aFrame	 Кадр на который необходимо перевести текущую анимацию.
		 */
		protected function goto(aFrame:Number):void
		{
			var i:int = AntMath.floor(aFrame - 1);
			i = (i <= 0) ? 0 : (i >= totalFrames - 1) ? totalFrames - 1 : i;
			if (_prevFrame != i)
			{
				calcFrame(i);
				_prevFrame = i;
			}
		}
		
		/**
		 * Выполняется когда цикл проигрывания текущей анимации завершен.
		 */
		protected function animComplete():void
		{
			if (!repeat)
			{
				stop();
			}
			
			eventComplete.send([ this ]);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает имя текущей анимации.
		 */
		public function get currentAnimation():String
		{
			return _curAnimName;
		}
		
		/**
		 * Определяет прозрачность.
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
				
				calcFrame();
			}
		}
		
		/**
		 * Определяет цвет.
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
				
				calcFrame();
			}
		}
		
	}
	
}