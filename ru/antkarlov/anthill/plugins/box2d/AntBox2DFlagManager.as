package ru.antkarlov.anthill.plugins.box2d
{
	import flash.utils.Dictionary;
	
	import ru.antkarlov.anthill.AntG;
	
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  22.09.2013
	 */
	public class AntBox2DFlagManager extends Object
	{
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private static var _instance:AntBox2DFlagManager;
		private var _numFlags:uint;
		private var _flagList:Dictionary;
		private var _bitList:Array;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DFlagManager()
		{
			super();
			
			if (_instance != null)
			{
				throw new Error("AntBox2DFlagManager already exists. Use the AntBox2DFlagManager.getInstance() to getting reference.");
			}
			
			_instance = this;
			reset();
		}
		
		/**
		 * @private
		 */
		public static function getInstance():AntBox2DFlagManager
		{
			return (_instance != null) ? _instance : new AntBox2DFlagManager();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function reset():void
		{
			_numFlags = 0;
			_flagList = new Dictionary();
			_bitList = [];
		}
		
		/**
		 * Возвращает значение флага по его имени. Добавляемый флаг будет автоматически
		 * добавлен в менеджер если он еще небыл добавлен ранее.
		 * 
		 * @param	aFlagName	 Имя флага значение которого необходимо получить.
		 * @return		Возвращает значение флага.
		 */
		public function getFlag(aFlagName:String):uint
		{
			if (!_flagList.hasOwnProperty(aFlagName))
			{
				if (_numFlags == 64)
				{
					AntG.log("Warning: In AntBox2DFlagManager only 64 unique flags can be created.", "error");
					return 0;
				}
				
				_flagList[aFlagName] = _numFlags;
				_bitList[1 << _numFlags] = aFlagName;
				_numFlags++;
			}
			
			return 1 << _flagList[aFlagName];
		}
		
		/**
		 * Возвращает имя флага по его значению.
		 * 
		 * @param	aValue	 Значение флага имя которого необходимо получить.
		 * @return		Возвращает имя флага.
		 */
		public function getFlagName(aValue:uint):String
		{
			return _bitList[aValue];
		}
		
		/**
		 * Определяет СТРОГОЕ соотвествие указанного флага для указанного имени.
		 * 
		 * @param	aFlag	 Флаг который необходимо проверить на соотвествие.
		 * @param	aFlagName	 Имя флага которое необходимо проверить на соотвествие.
		 * @return		Возвращает true если флаг соотвествует указанному имени флага.
		 * Если указанный флаг имеет несколько имен связанных с ним, то метод всегда вернет false.
		 */
		public function flagMatch(aFlag:AntBox2DFlag, aFlagName:String):Boolean
		{
			var t:* = _flagList[aFlagName];
			return (t != null) && aFlag.bits == 1 << t;
		}
		
		/**
		 * Определяет соотвествие указанного флага для указанного имени.
		 * 
		 * @param	aFlag	 Флаг который необходимо проверить на соотвествие.
		 * @param	aFlagName	 Имя флага которое необходимо проверить на соотвествие.
		 * @return		Возвращает true если флаг соотвествует указанному имени флага.
		 * Если указанный флаг имеет несколько имен связанных с ним, то метод всегда вернет false.
		 */
		public function flagOverlap(aFlag:AntBox2DFlag, aFlagName:String):Boolean
		{
			var t:* = _flagList[aFlagName];
			return (t != null) && (aFlag.bits & (1 << t)) != 0;
		}
		
		/**
		 * Определяет СТРОГОЕ соотвествие указанных флагов.
		 * 
		 * @param	aFlagA	 Первый флаг для проверки соотвествия.
		 * @param	aFlagB	 Второй флаг для проверки соотвествия.
		 * @return		Возвращает true если оба флага строго одинаковы.
		 */
		public function flagsMatch(aFlagA:AntBox2DFlag, aFlagB:AntBox2DFlag):Boolean
		{
			return aFlagA.bits == aFlagB.bits;
		}
		
		/**
		 * Определяет соотвествие указанных флагов.
		 * 
		 * @param	aFlagA	 Первый флаг для проверки соотвествия.
		 * @param	aFlagB	 Второй флаг для проверки соотвествия.
		 * @return		Возвращает true если оба флага одинаковы.
		 */
		public function flagsOverlap(aFlagA:AntBox2DFlag, aFlagB:AntBox2DFlag):Boolean
		{
			if (!aFlagA || !aFlagB)
			{
				return false;
			}
			
			return (aFlagA.bits & aFlagB.bits) != 0;
		}
		
		/**
		 * Регистрация нового флага.
		 * 
		 * @param	aBitIndex	 Новый уникальный индекс флага.
		 * @param	aFlagName	 Имя нового флага.
		 */
		public function registerFlag(aBitIndex:int, aFlagName:String):void
		{
			if (getFlagName(aBitIndex) != null)
			{
				throw new Error("(AntBox2DFlagManager): Bit already registerd in AntBox2DFlagManager.");
			}
			
			if (_flagList[aFlagName])
			{
				throw new Error("(AntBox2DFlagManager): Name already assigned to another bit in AntBox2DFlagManager.");
			}
			
			if (aBitIndex >= _numFlags)
			{
				_numFlags = aBitIndex + 1;
			}
			
			_flagList[aFlagName] = aBitIndex;
			_bitList[aBitIndex] = aFlagName;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает количество зарегистрированных флагов.
		 */
		public function get numFlags():uint { return _numFlags; }
		
	}

}