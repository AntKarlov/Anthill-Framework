package ru.antkarlov.anthill.plugins
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.signals.AntSignal;
	
	/**
	 * Класс реализации плавных трансформации каких-либо значений объектов. Класс использует различные
	 * методы для реализации разнообразных анимационных стилей.
	 * 
	 * <p>В первую очередь этот класс реализует стандартные анимации такие как движение, затухание,
	 * поврот и т.п. Но нет никаких ограничений на то, что вы хотите трансформировать. Вы можете трансформировать
	 * любое цифровое свойство объекта (<code>int, uint, Number</code>). Чтобы посмотреть список 
	 * возможных типов анимаций для трансформаций, посмотрите класс <code>AntTransition</code>.</p>
	 * 
	 * <p>Пример использования использующий движение объекта, вращение и затухание:</p>
	 * 
	 * <listing>
	 * var tween:AntTween = new AntTween(object, 2.0, AntTransition.EASE_IN_OUT);
	 * tween.animate("x", object.x + 50);
	 * tween.animate("angle", 45);
	 * tween.fadeTo(0); // Тоже самое что и animate("alpha", 0);
	 * tween.start();
	 * </listing>
	 * 
	 * <p>Идея и реализация подсмотрена у <a href="http://gamua.com/starling/">Starling Framework</a>.</p>
	 * 
	 * @see	AntTransition
	 * 
	 * @author Антон Карлов
	 * @since  26.01.2013
	 */
	public class AntTween implements IPlugin
	{
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Определяет следует ли округлять трансформируемое значение.
		 * @default    false
		 */
		public var roundToInt:Boolean;
		
		/**
		 * Указатель на следующий твин.
		 * Не используется твинером.
		 * @default    null
		 */
		public var nextTween:AntTween;
		
		/**
		 * Определяет автоматический переход к следующему твину, если он указан.
		 * @default    true
		 */
		public var autoStartOfNextTween:Boolean;
		
		/**
		 * Определяет количество циклов выполнения.
		 * @default    1
		 */
		public var repeatCount:int;
		
		/**
		 * Определяет задержку перед тем как будет выполнен переход к следующему циклу.
		 * @default    0
		 */
		public var repeatDelay:Number;
		
		/**
		 * Определяет необходимо ли выполнить реверс трансформации. Если <code>true</code>
		 * то при каждом повторе трансформация будет реверсирована (выполнятся в обратную сторону).
		 * @default    false
		 */
		public var reverse:Boolean;
		
		/**
		 * Событие срабатывающее при запуске твина.
		 */
		public var eventStart:AntSignal;
		
		/**
		 * Событие срабатывающее каждый тик твина.
		 */
		public var eventUpdate:AntSignal;
		
		/**
		 * Событие срабатывающее каждый повтор твина.
		 */
		public var eventRepeat:AntSignal;
		
		/**
		 * Событие срабатывающее при завершении выполнения твина.
		 */
		public var eventComplete:AntSignal;
		
		/**
		 * Пользовательские аргументы которые могут быть переданы в событие при запуске твина.
		 * @default    null
		 */
		public var startArgs:Array;
		
		/**
		 * Пользовательские аргументы которые могут быть переданы в событие при каждом тике твина.
		 * @default    null
		 */
		public var updateArgs:Array;
		
		/**
		 * Пользовательские аргументы которые могут быть переданы в событие при каждом повторе твина.
		 * @default    null
		 */
		public var repeatArgs:Array;
		
		/**
		 * Пользовательские аргументы которые могут быть переданы в событие при завершении твина.
		 * @default    null
		 */
		public var completeArgs:Array;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Объект к которому применяются трансформации.
		 * @default    null
		 */
		protected var _target:Object;
		
		/**
		 * Указатель на метод который используется для рассчетов.
		 * @default    null
		 */
		protected var _transitionFunc:Function;
		
		/**
		 * Имя метода который используется для рассчетов.
		 * @default    "linear"
		 */
		protected var _transitionName:String;
		
		/**
		 * Список свойств объекта которые трансформируются.
		 */
		protected var _properties:Vector.<String>;
		
		/**
		 * Начальные значения свойств объекта которые трансформируются.
		 */
		protected var _startValues:Vector.<Number>;
		
		/**
		 * Конечные значения свойств объекта которые трансформируются.
		 */
		protected var _endValues:Vector.<Number>;
		
		/**
		 * Общее время отведенное на трансформации.
		 */
		protected var _totalTime:Number;
		
		/**
		 * Текущее время.
		 */
		protected var _currentTime:Number;
		
		/**
		 * Задержка.
		 */
		protected var _delay:Number;
		
		/**
		 * Текущий цикл выполнения.
		 */
		protected var _currentCycle:int;
		
		/**
		 * Определяет запущена работа твина или нет.
		 */
		protected var _isStarted:Boolean;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntTween(aTarget:Object, aTime:Number, aTransition:Object = "linear")
		{
			super();
			_isStarted = false;
			autoStartOfNextTween = true;
			reset(aTarget, aTime, aTransition);
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Сбрасывает параметры твина на значения по умолчанию.
		 * 
		 * @param	aTarget	 Указатель на объект к которому применяется твинер.
		 * @param	aTime	 Продолжительность работы твинера.
		 * @param	aTransition	 Тип анимации твина.
		 * @return		Возвращает указатель на себя.
		 */
		public function reset(aTarget:Object, aTime:Number, aTransition:Object = "linear"):AntTween
		{
			stop();
			
			_target = aTarget;
			_totalTime = aTime;
			_currentTime = 0;
			_totalTime = Math.max(0.0001, aTime);
			_delay = repeatDelay = 0.0;
			startArgs = updateArgs = repeatArgs = completeArgs = null;
			roundToInt = reverse = false;
			repeatCount = 1;
			_currentCycle = -1;
			
			if (aTransition is String)
			{
				transition = aTransition as String;
			}
			else if (aTransition is Function)
			{
				transitionFunc = aTransition as Function;
			}
			else
			{
				throw new ArgumentError("Transition must be either a string or a function");
			}
			
			(eventStart == null) ? eventStart = new AntSignal() : eventStart.clear();
			(eventUpdate == null) ? eventUpdate = new AntSignal() : eventUpdate.clear();
			(eventRepeat == null) ? eventRepeat = new AntSignal() : eventRepeat.clear();
			(eventComplete == null) ? eventComplete = new AntSignal() : eventComplete.clear();
			
			// Отключение типизации для сигналов
			eventStart.strict = false;
			eventUpdate.strict = false;
			eventRepeat.strict = false;
			eventComplete.strict = false;
			
			(_properties == null) ? _properties = new <String>[] : _properties.length = 0;
			(_startValues == null) ? _startValues = new <Number>[] : _startValues.length = 0;
			(_endValues == null) ? _endValues = new <Number>[] : _endValues.length = 0;
			
			return this;
		}
		
		/**
		 * Задает атрибут объекта к которому будут применятся действия твинера.
		 * Количество одновременно изменяемых атрибутов не ограничено. Данный
		 * метод может быть вызван для одного твина много раз.
		 * 
		 * @param	aProperty	 Имя атрибута на которое будет воздействовать твинер.
		 * @param	aEndValue	 Конечное значение которого необходимо достигнуть.
		 */
		public function animate(aProperty:String, aEndValue:Number):void
		{
			if (_target != null)
			{
				var i:int = _properties.indexOf(aProperty);
				if (i == -1)
				{
					_properties.push(aProperty);
					_startValues.push(Number.NaN);
					_endValues.push(aEndValue);
				}
				else
				{
					_startValues[i] = Number.NaN;
					_endValues[i] = aEndValue;
				}
			}
		}
		
		/**
		 * Трансформирует свойства объекта <code>scaleX</code> и <code>scaleY</code>.
		 * 
		 * @param	aValue	 Значение свойства <code>scaleX</code> и <code>scaleY</code> которого необходимо достигнуть.
		 */
		public function scaleTo(aValue:Number):void
		{
			animate("scaleX", aValue);
			animate("scaleY", aValue);
		}
		
		/**
		 * Трансформирует свойства объекта <code>x</code> и <code>y</code>.
		 * 
		 * @param	aX	 Значение свойства <code>x</code> которого необходимо достигнуть.
		 * @param	aY	 Значение свойства <code>y</code> которого необходимо достигнуть.
		 */
		public function moveTo(aX:Number, aY:Number):void
		{
			animate("x", aX);
			animate("y", aY);
		}
		
		/**
		 * Трансформирует свойства объекта <code>alpha</code>.
		 * 
		 * @param	aAlpha	 Значения свойства <code>alpha</code>.
		 */
		public function fadeTo(aAlpha:Number):void
		{
			animate("alpha", aAlpha);
		}
				
		/**
		 * Запускает работу твина.
		 */
		public function start():void
		{
			if (!_isStarted)
			{
				AntG.addPlugin(this);
				_isStarted = true;
			}
		}
		
		/**
		 * Останавливает работу твина.
		 */
		public function stop():void
		{
			if (_isStarted)
			{
				AntG.removePlugin(this);
				_isStarted = false;
			}
		}
		
		/**
		 * Извлекает финальное значение для указанного свойства.
		 * 
		 * @param	aProperty	 Имя свойства для которого необходимо получить финальное значение.
		 * @return		Возвращает значение для указанного свойства.
		 */
		public function getEndValue(aProperty:String):Number
		{
			var i:int = _properties.indexOf(aProperty);
			if (i == -1)
			{
				throw new ArgumentError("The property '" + aProperty + "' is not animated.");
			}
			
			return _properties[i] as Number;
		}
		
		//---------------------------------------
		// IPlugin Implementation
		//---------------------------------------

		//import ru.antkarlov.anthill.plugins.IPlugin;
		
		/**
		 * @inheritDoc
		 */
		public function update():void
		{
			updateTween(AntG.elapsed);
		}
		
		/**
		 * @inheritDoc
		 */
		public function draw(aCamera:AntCamera):void
		{
			//
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Процессинг твина.
		 */
		protected function updateTween(aTime:Number):void
		{
			if (aTime == 0 || (repeatCount == 1 && _currentTime == _totalTime))
			{
				return;
			}
			
			var i:int = 0;
			var previousTime:Number = _currentTime;
			var restTime:Number = _totalTime - _currentTime;
			var carryOverTime:Number = aTime > restTime ? aTime - restTime : 0.0;
			
			_currentTime = Math.min(_totalTime, _currentTime + aTime);
			
			if (_currentTime <= 0)
			{
				// Задержка еще не закончилась.
				return;
			}
			
			if (_currentCycle < 0 && previousTime <= 0 && _currentTime > 0)
			{
				_currentCycle++;
				eventStart.dispatch.apply(null, startArgs);
			}
			
			var ratio:Number = _currentTime / _totalTime;
			var reversed:Boolean = reverse && (_currentCycle % 2 == 1);
			var numProperties:int = _startValues.length;
			
			for (i = 0; i < numProperties; ++i)
			{
				if (isNaN(_startValues[i]))
				{
					_startValues[i] = _target[_properties[i]] as Number;
				}
				
				var startValue:Number = _startValues[i];
				var endValue:Number = _endValues[i];
				var delta:Number = endValue - startValue;
				var transitionValue:Number = reversed ? _transitionFunc(1.0 - ratio) : _transitionFunc(ratio);
				
				var currentValue:Number = startValue + transitionValue * delta;
				if (roundToInt)
				{
					currentValue = Math.round(currentValue);
				}
				
				_target[_properties[i]] = currentValue;
			}
			
			eventUpdate.dispatch.apply(this, updateArgs);
			
			if (previousTime < _totalTime && _currentTime >= _totalTime)
			{
				if (repeatCount == 0 || repeatCount > 1)
				{
					_currentTime = -repeatDelay;
					_currentCycle++;
					if (repeatCount > 1)
					{
						repeatCount--;
					}
					
					eventRepeat.dispatch.apply(this, repeatArgs);
				}
				else
				{
					stop();
					eventComplete.dispatch.apply(this, completeArgs);
					if (autoStartOfNextTween && nextTween != null)
					{
						nextTween.start();
					}
				}
			}
			
			if (carryOverTime)
			{
				updateTween(carryOverTime);
			}
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет завершено выполнения твина или нет.
		 */
		public function get isComplete():Boolean
		{
			return _currentTime >= _totalTime && repeatCount == 1;
		}
		
		/**
		 * Возвращает указатель на объект для которого выполняются трансформации.
		 */
		public function get target():Object
		{
			return _target;
		}
		
		/**
		 * Определяет стиль перехода.
		 */
		public function get transition():String { return _transitionName; }
		public function set transition(value:String):void
		{
			_transitionName = value;
			_transitionFunc = AntTransition.getTransition(value);
			
			if (_transitionFunc == null)
			{
				throw new ArgumentError("Invalid transition: " + value);
			}
		}
		
		/**
		 * Определяет метод использующийся для рассчетов перехода.
		 */
		public function get transitionFunc():Function {	return _transitionFunc; }
		public function set transitionFunc(value:Function):void
		{
			_transitionName = "custom";
			_transitionFunc = value;
		}
		
		/**
		 * Возвращает общее время необходимое для выполнения твина.
		 */
		public function get totalTime():Number
		{
			return _totalTime;
		}
		
		/**
		 * Возвращает текущее время выполнения твина.
		 */
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		/**
		 * Определяет задержку перед стартом твина.
		 */
		public function get delay():Number { return _delay; }
		public function set delay(value:Number):void
		{
			_currentTime = _currentTime + _delay - value;
			_delay = value;
		}
		
	}

}