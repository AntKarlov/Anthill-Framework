package ru.antkarlov.anthill.signals
{
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.02.2013
	 */
	public class AntSignalBindingList
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const NIL:AntSignalBindingList = new AntSignalBindingList(null, null);
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на данные связи для текущего элемента.
		 */
		public var head:AntSignalBinding;
		
		/**
		 * Указатель на следующий элемент списка.
		 */
		public var tail:AntSignalBindingList;
		
		
		//public var isEmpty:Boolean;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Определяет содержатся ли данные в текущем элементе.
		 */
		protected var _isEmpty:Boolean;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntSignalBindingList(aHead:AntSignalBinding, aTail:AntSignalBindingList)
		{
			super();
			
			if (aHead == null && aTail == null)
			{
				if (NIL != null)
				{
					throw new ArgumentError("Parameters head and tail are null. Use the NIL element instead.");
				}
				
				_isEmpty = true;
			}
			else
			{
				if (aTail == null)
				{
					throw new ArgumentError("Tail must not be null.");
				}
				
				head = aHead;
				tail = aTail;
				_isEmpty = false;
			}
		}
		
		/**
		 * @private
		 */
		public function destroy():void
		{
			if (head != null)
			{
				head.destroy();
				head = null;
			}
			
			if (tail != null)
			{
				tail.destroy();
			}
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет элемент в начало списка.
		 * 
		 * @param	aSignalBinding	 Данные для нового элемента списка.
		 * @return		Возвращает обновленный список (указатель на первый элемент).
		 */
		public function insert(aSignalBinding:AntSignalBinding):AntSignalBindingList
		{
			return new AntSignalBindingList(aSignalBinding, this);
		}
		
		/**
		 * Добавляет элемент с учетом приоритета.
		 * 
		 * @param	aSignalBinding	 Данные для нового элемента списка.
		 * @return		Возвращает обновленный список (указатель на первый элемент).
		 */
		public function insertWithPriority(aSignalBinding:AntSignalBinding):AntSignalBindingList
		{
			// Если список пуст, добавляем в начало.
			if (isEmpty)
			{
				return new AntSignalBindingList(aSignalBinding, this);
			}
			
			// Если приоритет больше чем у первого элемента списка, добавляем в начало.
			const priority:int = aSignalBinding.priority;
			if (priority > head.priority)
			{
				return new AntSignalBindingList(aSignalBinding, this); 
			}
			
			var p:AntSignalBindingList = this;
			var q:AntSignalBindingList = null;
			
			var first:AntSignalBindingList = null;
			var last:AntSignalBindingList = null;
			
			// Перебираем весь список связей.
			while (!p.isEmpty)
			{
				if (priority > p.head.priority)
				{
					q = new AntSignalBindingList(aSignalBinding, p);
					if (last != null)
					{
						last.tail = q;
					}
					
					return q;
				}
				else
				{
					q = new AntSignalBindingList(p.head, NIL);
					
					if (last != null)
					{
						last.tail = q;
					}
					
					if (first == null)
					{
						first = q;
					}
					
					last = q;
				}
				
				p = p.tail;
			}
			
			if (first == null || last == null)
			{
				throw new Error("Internal error.");
			}
			
			last.tail = new AntSignalBindingList(aSignalBinding, NIL);
			return first;
		}
		
		/**
		 * Удаляет элемент списка который содержит указанный метод.
		 * 
		 * @param	aListener	 Метод слушателя который следует удалить из списка.
		 * @return		Возвращает обновленный список (указатель на первый элемент списка).
		 */
		public function remove(aListener:Function):AntSignalBindingList
		{
			if (isEmpty || aListener == null)
			{
				return this;
			}
			
			if (aListener == head.listener)
			{
				return tail;
			}
			
			const first:AntSignalBindingList = new AntSignalBindingList(head, NIL);
			var current:AntSignalBindingList = tail;
			var previous:AntSignalBindingList = first;
			
			while (!current.isEmpty)
			{
				if (current.head.listener == aListener)
				{
					previous.tail = current.tail;
					return first;
				}
				
				previous = previous.tail = new AntSignalBindingList(current.head, NIL);
				current = current.tail;
			}
			
			return this;
		}
		
		/**
		 * Определяет содержится ли указанный метод в списке.
		 * 
		 * @param	aListener	 Метод слушателя наличие которого в списке следует проверить.
		 * @return		Возвращает true если метод содержится в списке.
		 */
		public function contains(aListener:Function):Boolean
		{
			if (isEmpty)
			{
				return false;
			}
			
			var p:AntSignalBindingList = this;
			while (!p.isEmpty)
			{
				if (p.head.listener == aListener)
				{
					return true;
				}
				
				p = p.tail;
			}
			
			return false;
		}
		
		/**
		 * Извлекает из списка связь с указанным методом слушателя.
		 * 
		 * @param	aListener	 Метод слушателя связь которого необходимо извлечь из списка.
		 * @return		Возвращает связь которая соотвествует указанному методу или null если список пуст или связь метод не существует в списке.
		 */
		public function get(aListener:Function):AntSignalBinding
		{
			if (isEmpty)
			{
				return null;
			}
			
			var p:AntSignalBindingList = this;
			while (!p.isEmpty)
			{
				if (p.head.listener == aListener)
				{
					return p.head;
				}
				
				p = p.tail;
			}
			
			return null;
		}
		
		/**
		 * Преобразует содержимое списка в строку.
		 * Используется для просмотра содержимого списка во время отладки.
		 */
		public function toString():String
		{
			var buffer:String = "";
			var p:AntSignalBindingList = this;
			while (!p.isEmpty)
			{
				buffer += p.head + " -> ";
				p = p.tail;
			}
			
			buffer += "Nil";
			return "[List " + buffer + "]";
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function get isEmpty():Boolean
		{
			return _isEmpty;
		}
		
		/**
		 * Возвращает количество элементов в списке.
		 */
		public function get length():uint
		{
			if (isEmpty)
			{
				return 0;
			}
			
			var res:uint = 0;
			var p:AntSignalBindingList = this;
			while (!p.isEmpty)
			{
				res++;
				p = p.tail;
			}
			
			return res;
		}
		
	}

}