package ru.antkarlov.anthill.signals
{
	import ru.antkarlov.anthill.events.*;
	
	/**
	 * Расширенная версия <code>AntSignal</code> с возможностью использования приоритета для слушателей, и реализацией всплывающих сообщений.
	 * 
	 * <p>При использовании данного сигнала необходимо явно указывать объект который будет является
	 * родителем сообщений. Для реализации всплывающих сообщений необходимо чтобы объект породитель сообщения
	 * имплементировал интерфейс <code>IBubbleEventHandler</code> чтобы можно было перехватывать и обработать 
	 * всплывающие сообщения.</p>
	 * 
	 * @see	IBubbleEventHandler
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.02.2013
	 */
	public class AntDeluxeSignal extends AntSignal
	{
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на объект источник события.
		 */
		protected var _target:Object;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntDeluxeSignal(aTarget:Object = null, ...aValueClasses)
		{
			_target = aTarget;
			
			valueClasses = (aValueClasses.length == 1 && aValueClasses[0] is Array) ? aValueClasses[0] : aValueClasses;
			super(valueClasses);
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function add(aListener:Function):AntSignalBinding
		{
			return addWithPriority(aListener);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addInstant(aListener:Function):AntSignalBinding
		{
			return addInstantWithPriority(aListener);
		}
		
		/**
		 * Подписывает слушателя на сигнал с определенным приоритетом.
		 * 
		 * <p>После того как слушатель подписался на сигнал, приоритет не может быть изменен.
		 * Чтобы изменить приоритет необходимо удалить слушателя, а потом вновь подписаться 
		 * с новым приоритетом.</p>
		 * 
		 * @param	aListener	 Указатель на метод который будет выполнятся при возникновении сигнала и получать необходимые аргументы.
		 * @return		Возвращает обновленный список.
		 */
		public function addWithPriority(aListener:Function, aPriority:int = 0):AntSignalBinding
		{
			return registerListenerWithPriority(aListener, false, aPriority);
		}
		
		/**
		 * Подписывает одноразовый слушатель на сигнал с определенным приоритетом.
		 * 
		 * <p>После первого наступления сигнала, однаразовый слушатель будет автоматически удален из 
		 * списка слушателей, после того как все слушатели будут обработаны.</p>
		 * 
		 * @param	aListener	 Указатель на метод который будет выполнятся при возникновении сигнала и получать необходимые аргументы.
		 * @return		Возвращает обновленный список.
		 */
		public function addInstantWithPriority(aListener:Function, aPriority:int = 0):AntSignalBinding
		{
			return registerListenerWithPriority(aListener, true, aPriority);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispatch(...aValueObjects):void
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
				
				throw new ArgumentError("Value object <" + valueObject + "> is not an instance of <" + valueClass + ">.");
			}
			
			// Извлекаем и клонируем событие если необходимо.
			var event:IEvent = aValueObjects[0] as IEvent;
			if (event != null)
			{
				if (event.target != null)
				{
					event = event.clone();
					aValueObjects[0] = event;
				}
				
				event.target = target;
				event.currentTarget = target;
				event.signal = this;
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
			
			// Реализуем всплывающее событие если это возможно.
			if (event != null && event.bubbles)
			{
				var currentTarget:Object = target;
				while (currentTarget != null && currentTarget.hasOwnProperty("parent"))
				{
					currentTarget = currentTarget["parent"];
					if (currentTarget is IBubbleEventHandler)
					{
						event.currentTarget = currentTarget;
						if ((currentTarget as IBubbleEventHandler).onEventBubbled(event) == false)
						{
							break;
						}
					}
				}
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function registerListener(aListener:Function, aInstant:Boolean = false):AntSignalBinding
		{
			return registerListenerWithPriority(aListener, aInstant);
		}
		
		/**
		 * Регистрирует новый слушатель с указанными параметрами.
		 * 
		 * @param	aListener	 Указатель на метод слушателя.
		 * @param	aInstant	 Определяет является ли слушатель одноразовым.
		 * @param	aPriority	 Приоритет слушателя.
		 * @return		Возвращает AntSignalBinding который содержит параметры добавленного слушателя.
		 */
		protected function registerListenerWithPriority(aListener:Function, aInstant:Boolean = false, aPriority:int = 0):AntSignalBinding
		{
			if (registrationPossible(aListener, aInstant))
			{
				const binding:AntSignalBinding = new AntSignalBinding(aListener, aInstant, this, aPriority);
				_bindings = _bindings.insertWithPriority(binding);
				return binding;
			}
			
			return _bindings.get(aListener);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет объект который будет является источником события.
		 */
		public function get target():Object { return _target; }
		public function set target(value:Object):void
		{
			if (value != _target)
			{
				clear();
				_target = value;
			}
		}

	}

}