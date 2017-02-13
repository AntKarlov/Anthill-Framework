package ru.antkarlov.anthill.extensions.stats
{
	/**
	 * Класс AntStatisticData является контейнером для хранения всей необходимой
	 * информации о статистике.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  31.10.2013
	 */
	public class AntStatisticData extends Object
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const MAXIMUM:String = "max";
		public static const MINIMUM:String = "min";
		public static const REPLACE:String = "replace";
		public static const ADD:String = "add";
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Уникальное имя статистики.
		 */
		public var key:String;
		
		/**
		 * Текущее значение статистики.
		 */
		public var value:int;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _kind:String;
		private var _oldValue:int;
		
		/**
		 * @constructor
		 */
		public function AntStatisticData(aKey:String, aKind:String = MAXIMUM, aValue:int = 0)
		{
			super();
			
			key = aKey;
			value = aValue;
			kind = aKind;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Вызывается для обновления значения статистики в соотвествии с её типом.
		 * 
		 * @param	aValue	 Новое значение статистики.
		 * @return		Возвращает true если значение было обновлено.
		 */
		public function updateValue(aValue:int):Boolean
		{
			_oldValue = value;
			switch (kind)
			{
				case MAXIMUM :
					value = (aValue > value) ? aValue : value;
				break;
				
				case MINIMUM :
					value = (aValue < value) ? aValue : value;
				break;
				
				case REPLACE :
					value = aValue;
				break;
				
				case ADD :
					value += aValue;
				break;
			}
			
			return _oldValue != value;
		}
		
		/**
		 * Сбрасывает значение статистики.
		 */
		public function reset():void
		{
			value = 0;
			kind = _kind;
		}
		
		/**
		 * Переводит значение статистики в строку.
		 */
		public function toString():String
		{
			return key + "(" + kind + "):" + value.toString();
		}
		
		/**
		 * @private
		 */
		public function get kind():String { return _kind; }
		public function set kind(aValue:String):void
		{
			_kind = aValue;
			if (value == 0)
			{
				value = (_kind == MAXIMUM) ? int.MIN_VALUE : (_kind == MINIMUM) ? int.MAX_VALUE : value; 
			}
		}
	
	}

}

