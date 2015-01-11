package ru.antkarlov.anthill
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	import ru.antkarlov.anthill.signals.AntSignal;
	import ru.antkarlov.anthill.utils.AntColor;
	
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
		 * Позволяет при возможности использовать более быстрые методы отрисовки актера.
		 * @default true
		 */
		public var quickDraw:Boolean;
		
		/**
		 * Номер текущего кадра с учетом скорости анимации. Значение может быть дробным.
		 * @default    1
		 */
		public var currentFrame:Number;
		
		/**
		 * Общее количество кадров для текущей анимации.
		 * @default    1
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
		 * Добавляемый метод должен иметь аргумент типа <code>function onComplete(actor:AntActor):void {}</code>
		 */
		public var eventComplete:AntSignal;
		
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
		
		protected var _strokeWeight:int;
		protected var _strokeColor:uint;
		protected var _stroke:Boolean;
		protected var _strokeCanvas:BitmapData;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntActor()
		{
			blend = null;
			smoothing = true;
			quickDraw = true;
			currentFrame = 1;
			totalFrames = 0;
			reverse = false;
			repeat = true;
			animationSpeed = 1;
			eventComplete = new AntSignal(AntActor);
			
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
			
			_strokeWeight = 2;
			_strokeColor = 0xFFFF00FF;
			_stroke = false;
			
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			clearAnimations();
			_animations = null;
			_curAnim = null;
			
			eventComplete.destroy();
			eventComplete = null;
			
			_colorTransform = null;
			if (_buffer != null)
			{
				_buffer.dispose();
				_buffer = null;
			}
			
			_pixels = null;
			super.destroy();
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
		override public function draw(aCamera:AntCamera):void
		{
			updateBounds();
			drawActor(aCamera);
			super.draw(aCamera);
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
			
			AntAnimation.useAnimation(aAnim.name);
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
			addAnimation(AntAnimation.getFromCache(aKey), aName, aSwitch);
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
				currentFrame = 1;
				totalFrames = _curAnim.totalFrames;
				resetHelpers();
			}
			else
			{
				throw new Error("AntActor: Missing animation \'" + aName +"\'.");
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
				var anim:AntAnimation = _animations.remove(aName) as AntAnimation;
				if (anim != null)
				{
					AntAnimation.unuseAnimation(anim.name);
				}
			}
		}
		
		/**
		 * Удаляет все анимации.
		 */
		public function clearAnimations():void
		{
			for (var animName:String in _animations)
			{
				removeAnimation(animName);
			}
		}
		
		/**
		 * Запускает воспроизведение текущией анимации.
		 */
		public function play():void
		{
			_playing = true;
		}

		/**
		 * Останавливает воспроизведение текущей анимации.
		 */
		public function stop():void
		{
			_playing = false;
		}
		
		/**
		 * Переводит текущую анимацию на указанный кадр и останавливает воспроизведение.
		 * 
		 * @param	aFrame	 Номер кадра на который необходимо перевести текущую анимацию.
		 */
		public function gotoAndStop(aFrame:Number):void
		{
			currentFrame = (aFrame <= 0) ? 1 : (aFrame > totalFrames) ? totalFrames : aFrame;
			switchFrame(currentFrame);
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
			switchFrame(currentFrame);
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
			aUseSpeed ? currentFrame += animationSpeed * AntG.timeScale : currentFrame++;
			switchFrame(currentFrame);
		}
		
		/**
		 * Выполняет переход к предыдущему кадру текущей анимации.
		 * 
		 * @param	aUseSpeed	 Флаг определяющий следует ли при переходе к предыдущему кадру использовать скорость анимации.
		 */
		public function prevFrame(aUseSpeed:Boolean = false):void
		{
			aUseSpeed ? currentFrame -= animationSpeed * AntG.timeScale : currentFrame--;
			switchFrame(currentFrame);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function hitTest(aX:Number, aY:Number, aPixelFlag:Boolean = false):Boolean
		{
			var res:Boolean = super.hitTest(aX, aY);
			if (res && aPixelFlag)
			{
				var absOrigin:AntPoint = new AntPoint(Math.abs(origin.x), Math.abs(origin.y));
				var dx:int = Math.floor((aX - globalX) / scaleX + absOrigin.x);
				var dy:int = Math.floor((aY - globalY) / scaleY + absOrigin.y);
				var p:AntPoint = AntMath.rotateDeg(dx, dy, absOrigin.x, absOrigin.y, -globalAngle);
				res = false;
				
				if (_buffer != null)
				{
					res = (AntColor.extractAlpha(_buffer.getPixel32(p.x, p.y)) > 0);
				}
				else if (_pixels != null)
				{
					res = (AntColor.extractAlpha(_pixels.getPixel32(p.x, p.y)) > 0);
				}
			}
			
			return res;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function hitTestPoint(aPoint:AntPoint, aPixelFlag:Boolean = false):Boolean
		{
			return hitTest(aPoint.x, aPoint.y, aPixelFlag);
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Отрисовка актера в буффер указанной камеры.
		 * 
		 * @param	aCamera	 Камера в буффер которой необходимо отрисовать актера.
		 */
		public function drawActor(aCamera:AntCamera):void
		{
			NUM_OF_VISIBLE++;
			
			// Если нет текущего кадра или объект не попадает в камеру.
			if (_pixels == null || !onScreen(aCamera))
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
			
			_flashPoint.x = p.x + origin.x;
			_flashPoint.y = p.y + origin.y;
			_flashRect.width = _pixels.width;
			_flashRect.height = _pixels.height;
			
			if (globalAngle == 0 && scaleX == 1 && scaleY == 1 && blend == null && quickDraw)
			{
				aCamera.buffer.copyPixels((_buffer != null) ? _buffer : _pixels, _flashRect, _flashPoint, null, null, true);
			}
			else
			{
				_matrix.identity();
				_matrix.translate(origin.x, origin.y);
				_matrix.scale(scaleX, scaleY);

				if (globalAngle != 0)
				{
					_matrix.rotate(Math.PI * 2 * (globalAngle / 360));
				}

				_matrix.translate(_flashPoint.x - origin.x, _flashPoint.y - origin.y);
				aCamera.buffer.draw((_buffer != null) ? _buffer : _pixels, _matrix, null, blend, null, smoothing);
			}
		}
		
		/**
		 * Сброс внутренних помошников.
		 */
		protected function resetHelpers():void
		{
			_flashRect.x = _flashRect.y = 0;
			
			if (_colorTransform != null || _stroke)
			{
				if (_buffer == null || _buffer.width != _curAnim.width || _buffer.height != _curAnim.height)
				{
					if (_buffer != null)
					{
						_buffer.dispose();
					}

					_buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
					
					if (_stroke)
					{
						_strokeCanvas = new BitmapData(_curAnim.width, _curAnim.height, true, _strokeColor);
					}
				}
			}
			
			calcFrame();
			updateBounds();
		}
		
		/**
		 * Перерасчет текущего кадра.
		 */
		protected function calcFrame(aFrame:int = 0):void
		{
			origin.set(_curAnim.offsetX[aFrame], _curAnim.offsetY[aFrame]);
		
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
			
			if (_stroke && _buffer != null)
			{
				calcStroke(_flashPointZero.x, _flashPointZero.y - _strokeWeight);
				//calcStroke(_flashPointZero.x + _strokeWeight, _flashPointZero.y - _strokeWeight);
				calcStroke(_flashPointZero.x + _strokeWeight, _flashPointZero.y);
				//calcStroke(_flashPointZero.x + _strokeWeight, _flashPointZero.y + _strokeWeight);
				calcStroke(_flashPointZero.x, _flashPointZero.y + _strokeWeight);
				//calcStroke(_flashPointZero.x - _strokeWeight, _flashPointZero.y + _strokeWeight);
				calcStroke(_flashPointZero.x - _strokeWeight, _flashPointZero.y);
				//calcStroke(_flashPointZero.x - _strokeWeight, _flashPointZero.y - _strokeWeight);
				
				_buffer.copyPixels(_pixels, _flashRect, _flashPointZero, null, null, true);
			}
		}
		
		/**
		 * @private
		 */
		private function calcStroke(aX:int, aY:int):void
		{
			if (_strokeCanvas != null)
			{
				_flashPointZero.x = aX;
				_flashPointZero.y = aY;
				
				_buffer.copyPixels(_strokeCanvas, _strokeCanvas.rect, _flashPointZero, _pixels, null, true);
			
				_flashPointZero.x = 0;
				_flashPointZero.y = 0;
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
					if (repeat && roundFrame(currentFrame) <= 0)
					{
						currentFrame = totalFrames;
					}

					prevFrame(true);
					
					if (roundFrame(currentFrame) <= 0)
					{
						currentFrame = 1;
						animComplete();
					}
				}
				else
				{
					if (repeat && roundFrame(currentFrame) >= totalFrames - 1)
					{
						currentFrame = 1;
					}
					
					nextFrame(true);
					
					if (roundFrame(currentFrame) >= totalFrames - 1)
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
		protected function switchFrame(aFrame:Number):void
		{
			var f:int = roundFrame(aFrame);
			if (_prevFrame != f)
			{
				calcFrame(f);
				_prevFrame = f;
			}
		}
		
		/**
		 * @private
		 */
		protected function roundFrame(aFrame:Number):int
		{
			var i:int = AntMath.floor(aFrame - 1);
			return (i <= 0) ? 0 : (i >= totalFrames - 1) ? totalFrames - 1 : i;
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
			
			if (eventComplete.numListeners > 0)
			{
				eventComplete.dispatch(this);
			}
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет проигрывается ли анимация.
		 */
		public function get isPlaying():Boolean { return _playing; }
		
		/**
		 * Возвращает имя текущей анимации.
		 */
		public function get currentAnimation():String { return _curAnimName; }
		
		/**
		 * @private
		 */
		public function get animations():AntStorage { return _animations; }
		
		/**
		 * Определяет прозрачность.
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
				
				calcFrame(roundFrame(currentFrame));
			}
		}
		
		/**
		 * Определяет цвет.
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

				calcFrame(roundFrame(currentFrame));
			}
		}
		
		/**
		 * @private
		 */
		public function get strokeWeight():int { return _strokeWeight; }
		public function set strokeWeight(aValue:int):void
		{
			_strokeWeight = aValue;
		}
		
		/**
		 * @private
		 */
		public function get strokeColor():uint { return _strokeColor; }
		public function set strokeColor(aValue:uint):void
		{
			if (_strokeColor != aValue)
			{
				_strokeColor = aValue;
				if (_strokeCanvas != null)
				{
					_strokeCanvas.fillRect(_strokeCanvas.rect, _strokeColor);
				}
			}
		}
		
		/**
		 * @private
		 */
		public function get stroke():Boolean { return _stroke; }
		public function set stroke(aValue:Boolean):void
		{
			_stroke = aValue;
			if (_stroke && _strokeCanvas == null)
			{
				if (_buffer == null && _curAnim != null)
				{
					_buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
					_strokeCanvas = new BitmapData(_curAnim.width, _curAnim.height, true, _strokeColor);
				}
			}
			else if (!_stroke && _strokeCanvas != null)
			{
				if (_colorTransform == null && _buffer != null)
				{
					_buffer.dispose();
					_buffer = null;
				}
				
				_strokeCanvas.dispose();
				_strokeCanvas = null;
			}
			
			calcFrame(roundFrame(currentFrame));
		}
		
		/**
		 * @private
		 */
		public function get pixels():BitmapData
		{
			return _pixels;
		}
		
		/**
		 * @private
		 */
		public function get buffer():BitmapData
		{
			return _buffer;
		}
		
	}

}