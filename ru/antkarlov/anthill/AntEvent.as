package ru.antkarlov.anthill
{
	/**
	 * Реализация простой системы событий. Используется для уведомления подписавшихся объектов о наступлении определенных событий.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  20.08.2012
	 */
	public class AntEvent extends Object
	{
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Список методов слушателей для текущего события.
		 */
		public var listeners:Array;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntEvent()
		{
			super();
			listeners = [];
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет новый метод слушателя.
		 * 
		 * @param	aFunc	 Указатель на метод слушателя.
		 */
		public function add(aFunc:Function):void
		{
			var i:int = 0;
			var n:int = listeners.length;
			while (i < n)
			{
				if (listeners[i] == null)
				{
					listeners[i] = aFunc;
					return;
				}
				i++;
			}
			
			listeners[listeners.length] = aFunc;
		}
		
		/**
		 * Удаляет метод слушателя.
		 * 
		 * @param	aFunc	 Указатель на метод слушателя.
		 */
		public function remove(aFunc:Function):void
		{
			var i:int = listeners.indexOf(aFunc);
			if (i >= 0 || i < listeners.length)
			{
				listeners[i] = null;
			}
		}
		
		/**
		 * Очищает список методов всех подписавшихся слушателей.
		 */
		public function clear():void
		{
			var i:int = 0;
			var n:int = listeners.length;
			while (i < n)
			{
				listeners[i] = null;
				i++;
			}
			
			listeners.length = 0;
		}
		
		/**
		 * Выполняет методы всех подписавшихся слушателей. Вызывается при наступлении какого-либо события.
		 * 
		 * @param	aArg	 Массив с аргументами которые необходимо передать слушателям.
		 */
		public function send(aArgs:Array = null):void
		{
			var i:int = 0;
			var n:int = listeners.length;
			if (n > 0)
			{
				var func:Function;
				while (i < n)
				{
					func = listeners[i] as Function;
					if (func != null)
					{
						func.apply(this, aArgs);
					}
					i++;
				}
			}
		}

	}

}