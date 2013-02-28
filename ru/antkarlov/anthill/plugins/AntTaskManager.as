package ru.antkarlov.anthill.plugins
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.signals.AntSignal; 
	import ru.antkarlov.anthill.events.AntEvent; 
	import ru.antkarlov.anthill.utils.AntList;
	
	/**
	 * Менеджер задач используется для выполнения задач (вызова указанных методов) в заданном порядке.
	 * 
	 * <p>Позволяет легко и быстро программировать последовательность каких-либо действий. Менеджер 
	 * задач запускается автоматически при наличии одной и более задачь завершает свою работу если
	 * все задачи были выполнены или удалены.</p>
	 * 
	 * <p>Пример использования:</p>
	 * 
	 * <listing>
	 * var tm:AntTaskManager = new AntTaskManager();
	 * tm.addTask(onMove);
	 * tm.addInstantTask(onSwitchAnim);
	 * 
	 * ..Этот метод будет выполнятся менеджером до тех пор пока не вернет true.
	 * function onMove():Boolean
	 * {
	 *   x += 1;
	 *   return (x > 100);
	 * }
	 * 
	 * ..Этот метод будет выполнен один раз не зависимо от того что вернет.
	 * function onSwitchAnim():void
	 * {
	 *   ..какой-нибудь код
	 * }
	 * </listing>
	 * 
	 * <p>Позаимствовано у <a href="http://xitri.com/2010/10/27/ai-creation-tool-casual-connect-kiev-2010.html">Xitri.com</a></p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  22.08.2012
	 */
	public class AntTaskManager implements IPlugin
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Событие которое генерируется при завершении всех задач в менеджере задач.
		 * 
		 * <p>В качестве аргумента при вызове подписавшихся методов передается указатель 
		 * на экземпляр класса <code>AntTaskManager</code>.</p>
		 * 
		 * <p>Пример использования:</p>
		 * 
		 * <listing>
		 * taskManager.eventComplete.add(onComplete);
		 * 
		 * function onComplete(aTaskManager:AntTaskManager):void
		 * {
		 *   trace("All tasks completed!");
		 * }
		 * </listing>
		 */
		public var eventComplete:AntSignal;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Список всех активных задач.
		 * @default    null
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
			
			eventComplete = new AntSignal(AntTaskManager);
		}
		
		/**
		 * Освобождает ресурсы занимаемые мендежером задач.
		 * Следует вызывать перед удалением.
		 */
		public function destroy():void
		{
			clear();
			eventComplete.destroy();
			eventComplete = null;
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
				_task.destroy();
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
				
		//---------------------------------------
		// IPlugin Implementation
		//---------------------------------------

		//import ru.antkarlov.anthill.plugins.IPlugin;
		
		/**
		 * @inheritDoc
		 */
		public function update():void
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
				eventComplete.dispatch(this);
			}
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
		 * Запускает работу менеджера задача.
		 */
		protected function start():void
		{
			if (!_isStarted)
			{
				AntG.addPlugin(this);
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
				AntG.removePlugin(this);
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
			if (_task != null)
			{
				var item:AntList = _task;
				var data:Object = item.data;
				_task = item.next;
				item.next = null;
				item.destroy();
				return data;
			}
			
			return null;
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
					AntG.removePlugin(this);
				}
				_isPaused = true;
			}
			else
			{
				if (_isStarted)
				{
					AntG.addPlugin(this);
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
		public function get numTasks():int
		{
			if (_task != null)
			{
				var num:int = 1;
				var cur:AntList = _task;
				while (cur.next != null)
				{
					cur = cur.next;
					num++;
				}

				return num;
			}
			
			return 0;
		}
		
	}

}