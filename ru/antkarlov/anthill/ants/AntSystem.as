package ru.antkarlov.anthill.ants
{
	
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  12.01.2015
	 */
	public class AntSystem extends Object
	{
		public var priority:int;
		
		protected var _isPaused:Boolean;
		
		/**
		 * @constructor
		 */
		public function AntSystem()
		{
			super();
			
			priority = 0;
		}
		
		/**
		 * Вызывается когда система добавляется в ядро.
		 * 
		 * <p>Перекройте данный метод чтобы инициализировать работу системы.</p>
		 * 
		 * @param	aCore	Указатель на ядро в которое добавлена система.
		 */
		public function addToCore(aCore:AntCore):void
		{
			//...
		}
		
		/**
		 * Вызывается когда система удаляется из ядра.
		 * 
		 * <p>Перекройте данный методы чтобы корректно прекратить работу системы.</p>
		 * 
		 * @param	aCore	Указатель на ядро из которого удалена система.
		 */
		public function removeFromCore(aCore:AntCore):void
		{
			//...
		}
		
		/**
		 * Вызывается каждый игровой тик для обновления состояния системы.
		 * 
		 * <p>Перекройте данный метод чтобы реализовать работу системы.</p>
		 */
		public function update():void
		{
			//...
		}
		
		/**
		 * Приостанавливает обработку системы.
		 */
		public function pause():void
		{
			_isPaused = true;
		}
		
		/**
		 * Возобновляет обработку системы.
		 */
		public function resume():void
		{
			_isPaused = false;
		}
		
		/**
		 * Определяет приостановлена обработка системы или нет.
		 */
		public function get isPaused():Boolean
		{
			return _isPaused;
		}
	
	}

}