package ru.antkarlov.anthill.signals
{
	/**
	 * Данный класс является связующим звеном между сигналом и слушателем. 
	 * Фактически это ячейка с информацией о методе слушателя и его настройках.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.02.2013
	 */
	public class AntSignalBinding extends Object
	{
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _signal:AntSignal;
		private var _enabled:Boolean;
		private var _strict:Boolean;
		private var _listener:Function;
		private var _instant:Boolean;
		private var _priority:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntSignalBinding(aListener:Function, aInstant:Boolean = false, aSignal:AntSignal = null, aPriority:int = 0)
		{
			super();
			
			_signal = aSignal;
			_enabled = true;
			_strict = aSignal.strict;
			_listener = aListener;
			_instant = aInstant;
			_priority = aPriority;
			
			verifyListener(aListener);
		}
		
		/**
		 * @private
		 */
		public function destroy():void
		{
			_signal = null;
			_listener = null;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Выполняет метод подписавшегося слушателя.
		 * 
		 * @param	aValueObjects	 Массив аргументов которые будут отправлены слушателю.
		 */
		public function execute(aValueObjects:Array):void
		{
			if (!_enabled)
			{
				return;
			}
			
			if (_instant)
			{
				remove();
			}
			
			if (_strict)
			{
				const numValueObjects:int = aValueObjects.length;
				if (numValueObjects == 0)
				{
					_listener();
				}
				else if (numValueObjects == 2)
				{
					_listener(aValueObjects[0], aValueObjects[1]);
				}
				else if (numValueObjects == 3)
				{
					_listener(aValueObjects[0], aValueObjects[1], aValueObjects[2]);
				}
				else
				{
					_listener.apply(null, aValueObjects);
				}
			}
			else
			{
				_listener.apply(null, aValueObjects);
			}
		}
		
		/**
		 * Удаляет связь из сигнала.
		 */
		public function remove():void
		{
			_signal.remove(_listener);
		}
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return "[SignalBinding listener: " + _listener + ", instant: " + _instant + ", priority: " + _priority + ", enabled: " + _enabled + "]";
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Проверяет указанный метод слушателя на соотвествие требованием сигнала.
		 * 
		 * @param	aListener	 Метод слушателя который будет проверен на соотвествие требованиям.
		 */
		protected function verifyListener(aListener:Function):void
		{
			if (aListener == null)
			{
				throw new ArgumentError("Given listener is null.");
			}
			
			if (_signal == null)
			{
				throw new Error("Internal signal reference has not been set yet.");
			}
			
			const numListenerArgs:int = aListener.length;
			const argumentString:String = (numListenerArgs == 1) ? "argument" : "arguments";
			
			if (_strict)
			{
				if (numListenerArgs < _signal.valueClasses.length)
				{
					throw new ArgumentError("Listener has " + numListenerArgs + " " + argumentString +
						" but it needs to be " + _signal.valueClasses.length + " to math the signals value classes.");
				}
			}
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Слушатель который ассоциирован с данной связью.
		 */
		public function get listener():Function { return _listener; }
		public function set listener(value:Function):void
		{
			if (value == null)
			{
				throw new ArgumentError("Given listener is null. Did you want to set enabled to false instead?");
			}
			
			verifyListener(value);
			_listener = value;
		}
		
		/**
		 * Определяет будет ли уничтоженна данная связь после того как используется однажды.
		 */
		public function get instant():Boolean { return _instant; }
		
		/**
		 * Определяет приоритет для данной связи.
		 */
		public function get priority():int { return _priority; }
		
		/**
		 * Определяет может ли данная связь быть выполнена. По умолчанию равна true.
		 */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void { _enabled = value; }
		
		/**
		 * Определяет необходимость строгого типа данных. Полезно использовать если вам необходимо строгое
		 * соотвествие типов отправляемых аргументов в методы слушателей.
		 */
		public function get strict():Boolean { return _strict; }
		public function set strict(value:Boolean):void
		{
			_strict = value;
			verifyListener(listener);
		}
		
	}

}