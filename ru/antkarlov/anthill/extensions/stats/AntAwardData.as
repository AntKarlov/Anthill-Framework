package ru.antkarlov.anthill.extensions.stats
{
	/**
	 * Класс AntAwardData является контейнером для хранения всей необходимой
	 * информации о награде или миссии.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  31.10.2013
	 */
	public class AntAwardData extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Уникальное имя награды.
		 */
		public var key:String;
		
		/**
		 * Уникальное имя статистики к которой привязана данная награда.
		 */
		public var statKey:String;
		
		/**
		 * Значение статистики при котором награда считается достигнутой.
		 */
		public var statCondition:int;
		
		/**
		 * Флаг определяющий заработана награда игроком или нет.
		 */
		public var isEarned:Boolean;
		
		/**
		 * Указатель на любые пользовательские данные, например: заголовок, описание и иконка награды.
		 */
		public var userData:Object;
		
		/**
		 * @constructor
		 */
		public function AntAwardData(aKey:String, aStatKey:String, aStatCondition:int, aUserData:Object)
		{
			super();
			
			key = aKey;
			statKey = aStatKey;
			statCondition = aStatCondition;
			isEarned = false;
			userData = aUserData;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Вызывается каждый раз при обновлении значения для связанной статистики.
		 * 
		 * @param	aStatValue	 Новое значение связанной статистики.
		 */
		public function updateValue(aStatValue:int):Boolean
		{
			if (aStatValue >= statCondition)
			{
				isEarned = true;
			}
			
			return isEarned;
		}
		
		/**
		 * Сбрасывает флаг о том что награда заработана.
		 */
		public function reset():void
		{
			isEarned = false;
		}
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return key + " => " + statKey + " (" + statCondition.toString() + "): " + isEarned.toString();
		}
	
	}

}

