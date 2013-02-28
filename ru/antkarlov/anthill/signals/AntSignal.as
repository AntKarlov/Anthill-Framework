package ru.antkarlov.anthill.signals
{
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Сигнал используется для отправки сообщений с аргументам для произвольного количество подписанных слушателей.
	 * 
	 * <p>Вдохновлено C# событиями и делегатами, а так же <a target="_top" href="http://en.wikipedia.org/wiki/Signals_and_slots">signals and slots</a> in Qt.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.02.2013
	 */
	public class AntSignal extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Определяет необходимость строгого типа данных. 
		 * Следует использовать если необходимо строгое соотвествие 
		 * типов отправляемых аргументов в методы слушателей.
		 * @default    true
		 */
		public var strict:Boolean;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Список типов данных с которыми будет проводится сверка отправляемых
		 * аргументов в строгом режиме соответствия.
		 */
		protected var _valueClasses:Array;
		
		/**
		 * Список связей.
		 */
		protected var _bindings:AntSignalBindingList;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntSignal(...aValueClasses)
		{
			super();
			
			strict = true;
			_bindings = AntSignalBindingList.NIL;
			
			valueClasses = (aValueClasses.length == 1 && aValueClasses[0] is Array) ? aValueClasses[0] : aValueClasses;
		}
		
		/**
		 * Осовобождает используемые ресурсы.
		 */
		public function destroy():void
		{
			_bindings.destroy();
			_valueClasses = null;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Подписывает слушателя на сигнал.
		 * 
		 * @param	aListener	 Указатель на метод который будет выполнятся при возникновении сигнала и получать необходимые аргументы.
		 * @return		Возвращает AntSignalBinding который содержит параметры добавленного слушателя.
		 */
		public function add(aListener:Function):AntSignalBinding
		{
			return registerListener(aListener);
		}
		
		/**
		 * Подписывает одноразовый слушатель на сигнал.
		 * 
		 * <p>После первого наступления сигнала, однаразовый слушатель будет автоматически удален из 
		 * списка слушателей, после того как все слушатели будут обработаны.</p>
		 * 
		 * @param	aListener	 Указатель на метод который будет выполнятся при возникновении сигнала и получать необходимые аргументы.
		 * @return		Возвращает обновленный список.
		 */
		public function addInstant(aListener:Function):AntSignalBinding
		{
			return registerListener(aListener, true);
		}
		
		/**
		 * Отписывает слушателя от сигнала.
		 * 
		 * @param	aListener	 Указатель на метод который необходимо удалить из списка слушателей сигнала.
		 * @return		Возвращает обновленный список.
		 */
		public function remove(aListener:Function):AntSignalBinding
		{
			const binding:AntSignalBinding = _bindings.get(aListener);
			if (binding == null)
			{
				return null;
			}
			
			_bindings = _bindings.remove(aListener);
			return binding;
		}
		
		/**
		 * Отписывает всех слушателей от сигнала.
		 */
		public function clear():void
		{
			_bindings = AntSignalBindingList.NIL;
		}
		
		/**
		 * Отправляет сигнал слушателям.
		 * 
		 * <p>При использовании строгого режима будет выполнена проверка отправляемых аргументов на 
		 * соотвествие типам в valueClasses.</p>
		 * 
		 * @param	aValueObjects	 Произвольное количество аргументов отправляемых подписчикам. 
		 * @throws		ArgumentError	<code>ArgumentError</code>: aValueObjects не совпадают с типами классов в valueClasses.
		 */
		public function dispatch(...aValueObjects):void
		{
			// Проверяем типы аргументов в соотвествии с указанными типами данных.
			var valueObject:Object;
			var valueClass:Class;
			
			// Если список типов данных пустой, значит проверка не осуществляется.
			const numValueClasses:int = _valueClasses.length;
			const numValueObjects:int = aValueObjects.length;
			
			if (numValueObjects < numValueClasses)
			{
				throw new ArgumentError("Incorrect number of arguments. " +
					"Expected at least " + numValueClasses + " but received " +
					numValueObjects + ".");
			}
			
			for (var i:int = 0; i < numValueClasses; i++)
			{
				valueObject = aValueObjects[i];
				valueClass = _valueClasses[i];
				
				if (valueObject === null || valueObject is valueClass)
				{
					continue;
				}
				
				throw new ArgumentError("Value object <" + valueObject + 
					"> is not an instance of <" + valueClass + ">.");
			}
			
			// Рассылка слушателям.
			var bindingsToProcess:AntSignalBindingList = _bindings;
			if (!bindingsToProcess.isEmpty)
			{
				while (!bindingsToProcess.isEmpty)
				{
					bindingsToProcess.head.execute(aValueObjects);
					bindingsToProcess = bindingsToProcess.tail;
				}
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Регистрирует нового слушателя.
		 * 
		 * @param	aListener	 Указатель на метод слушателя.
		 * @param	aInstant	 Определяет является ли слушатель одноразовым.
		 * @return		Возвращает AntSignalBinding который содержит параметры добавленного слушателя.
		 */
		protected function registerListener(aListener:Function, aInstant:Boolean = false):AntSignalBinding
		{
			if (registrationPossible(aListener, aInstant))
			{
				const binding:AntSignalBinding = new AntSignalBinding(aListener, aInstant, this);
				_bindings = new AntSignalBindingList(binding, _bindings);
				return binding;
			}
			
			return _bindings.get(aListener);
		}
		
		/**
		 * Определяет возможно ли зарегистрировать указанный слушатель.
		 * 
		 * @param	aListener	 Указатель на метод слушателя.
		 * @param	aInstant	 Определяет является ли слушатель одноразовым.
		 * @return		Возвращает true если регистрация возможна.
		 */
		protected function registrationPossible(aListener:Function, aInstant:Boolean):Boolean
		{
			if (_bindings.isEmpty)
			{
				return true;
			}
			
			const existingBinding:AntSignalBinding = _bindings.get(aListener);
			if (existingBinding == null)
			{
				return true;
			}
			
			if (existingBinding.instant != aInstant)
			{
				// Если слушатель уже был добавлен раньше, то не добавляем его.
				// Исключением может быть только однаразовые слушатели.
				throw new IllegalOperationError("You cannot addOnce() then add() the same listener " + 
					"without removing the relationship first.");
			}
			
			// Слушатель уже зарегистрирован.
			return false;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Опциональный список классов для определения типов параметров которые будут отправлятся слушателям.
		 */
		public function get valueClasses():Array { return _valueClasses; }
		public function set valueClasses(value:Array):void
		{
			// Клонируем так как массив не может быть применем извне.
			_valueClasses = value ? value.slice() : [];
			for (var i:int = _valueClasses.length; i--; )
			{
				if (!(_valueClasses[i] is Class))
				{
					throw new ArgumentError("Invalid valueClasses argument: " +
						"item at index " + i + " should be a Class but was: <" +
						_valueClasses[i] + ">." + getQualifiedClassName(_valueClasses[i]));
				}
			}
 		}
		
		/**
		 * Возвращает количество слушателей подписавшихся на сигнал.
		 */
		public function get numListeners():uint { return _bindings.length }
		
	}

}