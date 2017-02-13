package ru.antkarlov.anthill
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import ru.antkarlov.anthill.signals.AntSignal;
	
	/**
	 * Анимированная маска которая может быть применена к любой сущности.
	 * 
	 * <p>Работа с маской очень похожа на работу с актером. Для маски подходят точно
	 * такие же анимации как и для актеров. При использовании анимации прозрачные области
	 * кадров считаются как не прозрачные, а непрозрачные области являются своеобразным
	 * окном в которое можно видеть что находится под маской.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  26.02.2013
	 */
	public class AntMask extends AntBasic
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var buffer:BitmapData;
		
		/**
		 * Положение маски по X относительно сущности к которой она применена.
		 * @default    0
		 */
		public var x:Number;
		
		/**
		 * Положение маски по Y относительно сущности к которой она применена.
		 * @default    0
		 */
		public var y:Number;
		
		/**
		 * Размер маски по ширине, зависит от размера текущего кадра анимации.
		 * @default    0
		 */
		public var width:int;
		
		/**
		 * Размер маски по высоте, зависит от размера текущего кадра анимации.
		 * @default    0
		 */
		public var height:int;
		
		/**
		 * Глобальная позиция маски по X в игровом мире с учетом положения сущности
		 * к которой применена маска.
		 * @default    0
		 */
		public var globalX:Number;
		
		/**
		 * Глобальная позиция маски по Y в игровом мире с учетом положения сущности
		 * к которой применена маска.
		 * @default    0
		 */
		public var globalY:Number;
		
		/**
		 * Осевая точка маски.
		 * @default    (0,0)
		 */
		public var origin:AntPoint;
		
		/**
		 * Флаг определяющий следует ли выполнять заливку буфера маски.
		 * @default    false
		 */
		public var fillBackground:Boolean;
		
		/**
		 * Цвет которым будет заливаться буфер маски.
		 * @default    0xFF000000
		 */
		public var backgroundColor:uint;
		
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
		protected var _animations:AntStorage;
		protected var _curAnim:AntAnimation;
		protected var _curAnimName:String;
		protected var _playing:Boolean;
		protected var _prevFrame:int;
		protected var _pixels:BitmapData;
		
		protected var _backendBuffer:BitmapData;
		protected var _flashRect:Rectangle;
		protected var _flashPointZero:Point;
		protected var _flashPointTarget:Point;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntMask()
		{
			super();
			
			x = 0;
			y = 0;
			width = 0;
			height = 0;
			globalX = 0;
			globalY = 0;
			origin = new AntPoint();
			
			_flashRect = new Rectangle(0, 0, width, height);
			_flashPointZero = new Point();
			_flashPointTarget = new Point();
			
			fillBackground = false;
			backgroundColor = 0xFF000000;
			
			//--
			currentFrame = 1;
			totalFrames = 0;
			reverse = false;
			repeat = true;
			animationSpeed = 1;
			eventComplete = new AntSignal(AntMask);
			
			_animations = new AntStorage();
			_curAnim = null;
			_curAnimName = null;
			_playing = false;
			
			_prevFrame = -1;
			_pixels = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			_animations.clear();
			_animations = null;
			_curAnim = null;

			eventComplete.destroy();
			eventComplete = null;

			_pixels = null;
			super.destroy();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
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
				currentFrame = 1;
				totalFrames = _curAnim.totalFrames;
				resetHelpers();
			}
			else
			{
				throw new Error("AntMask: Missing animation \'" + aName +"\'.");
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
		 * Обновляет позицию маски с учетом родительской сущности и текущей камеры.
		 * 
		 * @param	aParent	 Указатель на сущность для которой применена маска.
		 * @param	aCamera	 Текущая камера.
		 */
		public function updatePosition(aParent:AntEntity, aCamera:AntCamera):void
		{
			globalX = aParent.globalX + aCamera.scroll.x * aParent.scrollFactorX + x + origin.x;
			globalY = aParent.globalY + aCamera.scroll.y * aParent.scrollFactorY + y + origin.y;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			updateAnimation();
			
			if (fillBackground && _curAnim != null)
			{
				buffer.fillRect(_flashRect, backgroundColor);
			}
			
			super.update();
		}
		
		/**
		 * Применяет альфа канал к буферу маски и выполняет отрисовку содержимого буфера в указанный битмап.
		 * 
		 * @param	aTarget	 Битмап в который будет отрисовано содержимое буфера маски.
		 */
		public function drawTo(aTarget:BitmapData):void
		{
			if (_curAnim != null && _pixels != null)
			{
				_flashPointTarget.x = globalX;
				_flashPointTarget.y = globalY;
				_backendBuffer.copyPixels(_pixels, _flashRect, _flashPointZero, null, null, false);
				_backendBuffer.merge(buffer, _flashRect, _flashPointZero, 0x100, 0x100, 0x100, 0);
				aTarget.copyPixels(_backendBuffer, _flashRect, _flashPointTarget, null, null, true);
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Сброс внутренних помошников.
		 */
		protected function resetHelpers():void
		{
			_flashRect.x = _flashRect.y = 0;
			
			if (buffer == null || buffer.width != _curAnim.width || buffer.height != _curAnim.height)
			{
				if (buffer != null) buffer.dispose();
				if (_backendBuffer != null) _backendBuffer.dispose();				

				buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
				_backendBuffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
			}
			
			calcFrame();
		}
		
		/**
		 * Перерасчет текущего кадра.
		 */
		protected function calcFrame(aFrame:int = 0):void
		{
			origin.set(_curAnim.offsetX[aFrame], _curAnim.offsetY[aFrame]);
			_pixels = _curAnim.frames[aFrame];
			width = _flashRect.width = _pixels.width;
			height = _flashRect.height = _pixels.height;
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
		protected function switchFrame(aFrame:Number):void
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
			if (!repeat) stop();
			eventComplete.dispatch(this);
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

	}

}