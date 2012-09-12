package ru.antkarlov.anthill
{
	/**
	 * Менеджер задач используется для выполнения задач (вызова указанных методов) в заданном порядке.
	 * Позволяет легко и быстро программировать последовательность каких-либо действий, например появление кнопок в игровых меню.
	 * <p>Менеджер задач запускается автоматически при добавлении хотябы одной задачи и останавливается когда все задачи выполнены.</p>
	 * <p>Примечание: Идея взята у <a href="http://xitri.com/2010/10/27/ai-creation-tool-casual-connect-kiev-2010.html">Xitri.com</a></p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  22.08.2012
	 */
	public class AntTaskManager extends AntBasic
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Событие которое генерируется при завершении всех задач в менеджере задач.
		 * Пример использования: taskManager.eventComplete.add(function ():void { trace("All tasks completed!"); });
		 */
		public var eventComplete:AntEvent;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Список всех активных задач.
		 */
		protected var _task:AntList;
		
		/**
		 * Определяет запущенна ли работа менеджера.
		 * @default    false
		 */
		protected var _isStarted:Boolean;
		
		/**
		 * Определеяет поставленно ли выполнение задач на паузу.
		 * @default    false
		 */
		protected var _isPaused:Boolean;
		
		/**
		 * Помошник для определения завершения текущей задачи.
		 * @default    false
		 */
		protected var _result:Boolean;
		
		/**
		 * Определяет выполняются ли задачи в цикле.
		 * @default    false
		 */
		protected var _cycle:Boolean;
		
		/**
		 * Используется для рассчета текущей паузы между задачами.
		 * @default    0
		 */
		protected var _delay:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntTaskManager(aCycle:Boolean = false)
		{
			super();
			
			_task = null;
			_isStarted = false;
			_isPaused = false;
			_result = false;
			_cycle = aCycle;
			_delay = 0;
			
			eventComplete = new AntEvent();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			clear();
			eventComplete.clear();
			eventComplete = null;
			kill();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет задачу в конец очереди, указанный метод будет выполнятся до тех пор пока не вернет <code>true</code>.
		 * Только после того как метод вернет <code>true</code>, задача будет считаться выполненный и менеджер
		 * перейдет к следующей задачи.
		 * 
		 * @param	aFunc	 Метод-задача который будет выполнятся в порядке очереди.
		 * @param	aArgs	 Массив аргументов которые могут быть переданны методу задачи.
		 * @param	aIgnoreCycle	 Если true то задача будет удалена из менеджера сразу после выполнения.
		 */
		public function addTask(aFunc:Function, aArgs:Array = null, aIgnoreCycle:Boolean = false):void
		{
			push({ func:aFunc, args:aArgs, ignoreCycle:aIgnoreCycle, instant:false });
			start();
		}
		
		/**
		 * Добавляет задачу в конец очереди, указанный метод будет выполнен только один раз, после чего будет осуществлен
		 * переход к следующей задачи не зависимо от того, что вернет метод-задача и вернет ли вообще.
		 * 
		 * @param	aFunc	 Метод-задача который будет выполнятся в порядке очереди.
		 * @param	aArgs	 Массив аргументов которые могут быть переданны методу задачи.
		 * @param	aIgnoreCycle	 Если true то задача будет удалена из менеджера сразу после выполнения.
		 */
		public function addInstantTask(aFunc:Function, aArgs:Array = null, aIgnoreCycle:Boolean = false):void
		{
			push({ func:aFunc, args:aArgs, ignoreCycle:aIgnoreCycle, instant:true });
			start();
		}
		
		/**
		 * Добавляет задачу в начало очереди, указанный метод будет выполнятся до тех пор пока не вернет <code>true</code>.
		 * Только после того как метод вернет <code>true</code>, задача будет считаться выполненной и менеджер
		 * перейдет к следующей задачи.
		 * 
		 * @param	aFunc	 Метод-задача который будет выполнятся в порядке очереди.
		 * @param	aArgs	 Массив аргументов которые могут быть переданны методу задачи.
		 * @param	aIgnoreCycle	 Если true то задача будет удалена из менеджера сразу после выполнения.
		 */
		public function addUrgentTask(aFunc:Function, aArgs:Array = null, aIgnoreCycle:Boolean = false):void
		{
			unshift({ func:aFunc, args:aArgs, ignoreCycle:aIgnoreCycle, instant:false });
			start();
		}
		
		/**
		 * Добавляет задачу в начало очереди, указанный метод будет выполнен только один раз, после чего будет осуществлен
		 * переход к следующей задачи не зависимо от того, что вернет метод задача и вернет ли вообще.
		 * 
		 * @param	aFunc	 Метод-задача который будет выполнятся в порядке очереди.
		 * @param	aArgs	 Массив аргументов которые могут быть переданны методу задачи.
		 * @param	aIgnoreCycle	 Если true то задача будет удалена из менеджера сразу после выполнения.
		 */
		public function addUrgentInstantTask(aFunc:Function, aArgs:Array = null, aIgnoreCycle:Boolean = false):void
		{
			unshift({ func:aFunc, args:aArgs, ignoreCycle:aIgnoreCycle, instant:true });
			start();
		}
		
		/**
		 * Добавляет паузу между задачами.
		 * 
		 * @param	aDelay	 Время паузы.
		 * @param	aIgnoreCycle	 Если true то пауза будет выполнена только один раз за цикл.
		 */
		public function addPause(aDelay:Number, aIgnoreCycle:Boolean = false):void
		{
			addTask(taskPause, [ aDelay ], aIgnoreCycle);
		}
		
		/**
		 * Удаляет все задачи из менеджера и останавливает его работу.
		 */
		public function clear():void
		{
			stop();
			if (_task != null)
			{
				_task.dispose();
				_task = null;
			}
			
			_delay = 0;
		}
		
		/**
		 * Переход к следующей задаче.
		 * 
		 * @param	aIgnoreCycle	 Флаг определяющий следует ли оставить предыдущую задачу в диспетчере.
		 */
		public function nextTask(aIgnoreCycle:Boolean = false):void
		{
			if (_cycle && !aIgnoreCycle)
			{
				push(shift());
			}
			else
			{
				shift();
			}
		}
		
		/**
		 * Процессинг текущей задачи.
		 */
		override public function update():void
		{
			if (_task != null && _isStarted)
			{
				_result = (_task.data.func as Function).apply(this, _task.data.args);
				if (_isStarted && (_task.data.instant || _result))
				{
					nextTask(_task.data.ignoreCycle);
				}
			}
			else
			{
				stop();
				eventComplete.send();
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Запускает работу менеджера задача.
		 */
		protected function start():void
		{
			if (!_isStarted)
			{
				AntG.updater.add(this);
				_isStarted = true;
				_isPaused = false;
			}
		}
		
		/**
		 * Останавливает работу менеджера задач.
		 */
		protected function stop():void
		{
			if (_isStarted)
			{
				AntG.updater.remove(this);
				_isStarted = false;
			}
		}
		
		/**
		 * Метод-задача для реализации паузы между задачами.
		 * 
		 * @param	aDelay	 Задержка.
		 * @return		Возвращает true когда задача выполнена.
		 */
		protected function taskPause(aDelay:Number):Boolean
		{
			_delay += AntG.elapsed;
			if (_delay > aDelay)
			{
				_delay = 0;
				return true;
			}
			
			return false;
		}
		
		/**
		 * Добавляет указанный объект в конец списка.
		 * 
		 * @param	aObj	 Объект который необходимо добавить.
		 * @return		Возвращает указатель на добавленный объект.
		 */
		protected function push(aObj:Object):Object
		{
			if (aObj == null)
			{
				return null;
			}
			
			if (_task == null)
			{
				_task = new AntList(aObj);
				return aObj;
			}
			
			var item:AntList = new AntList(aObj); 
			var cur:AntList = _task;
			while (cur.next != null)
			{
				cur = cur.next;
			}

			cur.next = item;
			return aObj;
		}
		
		/**
		 * Добавляет указанный объект в начало списка.
		 * 
		 * @param	aObj	 Объект который необходимо добавить.
		 * @return		Возвращает указатель на добавленный объект.
		 */
		protected function unshift(aObj:Object):Object
		{
			if (_task == null)
			{
				_task = new AntList(aObj);
				return aObj;
			}
			
			var item:AntList = _task;
			_task = new AntList(aObj, item);
			return aObj;
		}
		
		/**
		 * Удаляет первый объект из списка.
		 * 
		 * @return		Возвращает указатель на удаленный объект.
		 */
		protected function shift():Object
		{
			if (_task == null)
			{
				return null;
			}
			
			var item:AntList = _task;
			var data:Object = item.data;
			_task = item.next;
			item.next = null;
			item.dispose();
			return data;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет режим паузы для менеджера задач.
		 */
		public function set pause(value:Boolean):void
		{
			if (value && !_isPaused)
			{
				if (_isStarted)
				{
					AntG.updater.remove(this);
				}
				_isPaused = true;
			}
			else
			{
				if (_isStarted)
				{
					AntG.updater.add(this);
				}
				_isPaused = false;
			}
		}
		
		/**
		 * @private
		 */
		public function get pause():Boolean
		{
			return _isPaused;
		}
		
		/**
		 * Определяет запущен ли менеджер задач.
		 */
		public function get isStarted():Boolean
		{
			return _isStarted;
		}
		
		/**
		 * Определяет количество задач.
		 */
		public function get length():int
		{
			if (_task == null)
			{
				return 0;
			}
			
			var num:int = 1;
			var cur:AntList = _task;
			while (cur.next != null)
			{
				cur = cur.next;
				num++;
			}
			
			return num;
		}
		
	}

}