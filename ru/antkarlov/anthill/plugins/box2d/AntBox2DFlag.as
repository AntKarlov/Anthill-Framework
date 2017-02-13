package ru.antkarlov.anthill.plugins.box2d
{
	
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  21.09.2013
	 */
	public class AntBox2DFlag extends Object
	{
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private static var _wildcard:AntBox2DFlag;
		private var _manager:AntBox2DFlagManager;
		private var _bits:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DFlag(...aArgs)
		{
			super();
			
			_manager = AntBox2DFlagManager.getInstance();
			_bits = 0;
			
			if (aArgs.length == 1)
			{
				if (aArgs[0] is Array)
				{
					flagNames = aArgs[0];
				}
				else
				{
					flagName = aArgs[0];
				}
			}
			else if (aArgs.length > 1)
			{
				flagNames = aArgs;
			}
		}
		
		/**
		 * @private
		 */
		public static function get wildcard():AntBox2DFlag
		{
			if (!_wildcard)
			{
				_wildcard = new AntBox2DFlag();
			}
			
			_wildcard._bits = 0xFFFFFFFF;
			return _wildcard;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет имя типа.
		 */
		public function add(aFlagName:String):void
		{
			_bits |= _manager.getFlag(aFlagName);
		}
		
		/**
		 * Удаляет имя типа.
		 */
		public function remove(aFlagName:String):void
		{
			_bits &= (wildcard.bits - _manager.getFlag(aFlagName));
		}
		
		/**
		 * Выполняет операцию побитового сдвига против другого флага.
		 * 
		 * @return		Возвращает true если указанный флаг совпадает с текущим.
		 */
		public function and(aFlag:AntBox2DFlag):Boolean
		{
			return ((aFlag.bits & bits) != 0) ? true : false;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function get bits():int { return _bits; }
		
		/**
		 * Возвращает имя флага связанного с этим объектом. Если
		 * с этим флагом связано несколько имен, то вернется младший бит.
		 */
		public function get flagName():String
		{
			for (var i:int = 0; i < _manager.numFlags; i++)
			{
				if (_bits & (1 << i))
				{
					return _manager.getFlagName(1 << i);
				}
			}
			
			return "";
		}
		
		public function set flagName(aValue:String):void
		{
			_bits = _manager.getFlag(aValue);
		}
		
		/**
		 * Возвращает массив имен связанных с данным флагом.
		 */
		public function get flagNames():Array
		{
			var res:Array = [];
			for (var i:int = 0; i < _manager.numFlags; i++)
			{
				if (_bits & (1 << i))
				{
					res.push(_manager.getFlagName(1 << i));
				}
			}
			
			return res;
		}
		
		public function set flagNames(aValue:Array):void
		{
			_bits = 0;
			for each (var flagName:String in aValue)
			{
				_bits |= _manager.getFlag(flagName);
			}
		}

	}

}