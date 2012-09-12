package ru.antkarlov.anthill
{
	
	/**
	 * Позволяет быстро рассчитать среднее значение из имеющегося диапазона значений.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  23.11.2011
	 */
	public class AntRating extends Object
	{

		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Максимальное количество значений.
		 */
		protected var _size:uint;
		
		/**
		 * Индекс ячейки в которую будет записано новое значение.
		 */
		protected var _ind:uint;
		
		/**
		 * Массив значений.
		 */
		protected var _data:Array;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntRating(aSize:uint, aDefault:Number = 0)
		{
			super();
			
			_size = (aSize <= 0) ? 1 : aSize;
			_ind = 0;
			_data = new Array(_size);
			for (var i:uint = 0; i < _size; i++)
			{
				_data[i] = aDefault;
			}
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет новое значение.
		 * 
		 * @param	value	 Новое значение.
		 */
		public function add(value:Number):void
		{
			_data[_ind++] = value;
			if (_ind >= _size)
			{
				_ind = 0;
			}
		}
		
		/**
		 * Рассчитывает среднее значение.
		 * 
		 * @return		Среднее значение из текущего диапазона.
		 */
		public function average():Number
		{
			var sum:Number = 0;
			for (var i:uint = 0; i < _size; i++)
			{
				sum += _data[i];
			}
			return sum / _size;
		}
		
		/**
		 * Возвращает количество значений.
		 */
		public function length():int
		{
			return _size;
		}

	}

}