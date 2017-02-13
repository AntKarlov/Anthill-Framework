package ru.antkarlov.anthill.extensions.stats
{
	import ru.antkarlov.anthill.AntG;
	import ru.antkarlov.anthill.AntCookie;
	import ru.antkarlov.anthill.signals.*;
	
	/**
	 * Класс AntStatistic позволяет легко и быстро реализовать награды и миссии в игре
	 * на основе сбора статистики о действиях игрока.
	 * 
	 * <p>Подробно о том как использовать данный класс:
	 * http://anthill.ant-karlov.ru/wiki/extensions:MissionsAndAwards</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  31.10.2013
	 */
	public class AntStatistic extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Событие обновления какой-либо статистики. Срабатывает каждый раз когда
		 * происходит успешное обновление значения статистики.
		 */
		public static var eventUpdateState:AntSignal = new AntSignal(AntStatisticData);
		
		/**
		 * События обновления какой-либо награды. Срабатывает каждый раз когда происходит
		 * успешное обновление значения для достижения награды.
		 */
		public static var eventUpdateAward:AntSignal = new AntSignal(AntAwardData, Number);
		
		/**
		 * События получения какой-либо награды. Срабатывает при достижении награды.
		 */
		public static var eventAwardEarned:AntSignal = new AntSignal(AntAwardData);
		
		/**
		 * Уникальное имя игры использующееся для сохранения статистики и наград в SharedObject.
		 */
		public static var saveName:String = "AnthillStats";
		
		/**
		 * Определяет отладочный режим. Если флаг равен true то при сохранении и загрузке
		 * данных из SharedObject информация выводится в output.
		 */
		public static var debugMode:Boolean = false;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private static var _statData:Vector.<AntStatisticData> = new Vector.<AntStatisticData>();
		private static var _numStats:int = 0;
		
		private static var _awardData:Vector.<AntAwardData> = new Vector.<AntAwardData>();
		private static var _numAwards:int = 0;
		
		/**
		 * @constructor
		 */
		public function AntStatistic()
		{
			super();
			throw new Error("AntStatistic is a static class.");
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Регистрирует новую статистику.
		 * 
		 * @param	aStatKey	 Уникальное имя для статистики.
		 * @param	aStatKind	 Вид статистики, может быть четырех видов "max", "min", "add" и "replace".
		 * @param	aDefaultValue	 Значение по умолчанию.
		 * @return		Возращает указатель на созданный AntStatisticData, если статистика уже существует то вернет null.
		 */
		public static function registerStat(aStatKey:String, aStatKind:String, aDefaultValue:int = 0):AntStatisticData
		{
			if (!containsStat(aStatKey))
			{
				_statData[_numStats++] = new AntStatisticData(aStatKey, aStatKind, aDefaultValue);
				return _statData[_numStats-1];
			}
			
			AntG.log("(!) Statistic with key \"" + aStatKey + "\" already registered.", "result");
			return null;
		}
		
		/**
		 * Удаяет статистику.
		 * 
		 * @param	aStatKey	 Уникальное имя статистики которую необходимо удалить.
		 * @return		Возвращает указатель на удаленный AntStatisticData.
		 */
		public static function unregisterStat(aStatKey:String):AntStatisticData
		{
			var i:int = 0;
			var stat:AntStatisticData;
			while (i < _numStats)
			{
				stat = _statData[i];
				if (stat != null && stat.key == aStatKey)
				{
					_statData[i] = null;
					_statData.splice(i, 1);
					return stat;
				}
				i++;
			}
			
			return null;
		}
		
		/**
		 * Определяет существует ли статистика с указанным именем.
		 * 
		 * @param	aStatKey	 Уникальное имя статистики существование которой необходимо проверить.
		 * @return		Возвращает true если статистика с указанным именем была ранее зарегистрирована.
		 */
		public static function containsStat(aStatKey:String):Boolean
		{
			return (getStat(aStatKey) != null) ? true : false;
		}
		
		/**
		 * Извлекает данные статистики.
		 * 
		 * @param	aStatKey	 Уникальное имя статистики данные о которой необходимо получить.
		 * @return		Возвращает указатель на AntStatisticData или null если статистики с указанным именем не существует.
		 */
		public static function getStat(aStatKey:String):AntStatisticData
		{
			var i:int = 0;
			var stat:AntStatisticData;
			while (i < _numStats)
			{
				stat = _statData[i++];
				if (stat != null && stat.key == aStatKey)
				{
					return stat;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает значение статистики по её имени.
		 * 
		 * @param	aStatKey	 Уникальное именя статистики значение которой необходимо получить.
		 * @return		Возвращает -1 если статистики с указанным именем не существует.
		 */
		public static function getStatValue(aStatKey:String):int
		{
			var stat:AntStatisticData = getStat(aStatKey);
			if (stat != null)
			{
				return stat.value;
			}
			
			return -1;
		}
		
		/**
		 * Регистрация новой награды.
		 * 
		 * @param	aAwardKey	 Уникальное имя награды.
		 * @param	aStatKey	 Уникальное имя статистики которая используется для отслеживания достижения награды.
		 * @param	aStatCondition	 Значение статистики которое является условием для достижения награды.
		 * @param	aUserData	 Любые пользовательские данные.
		 * @return		Возвращает указатель на AntAwardData, или null если награду не удалось зарегистрировать.
		 */
		public static function registerAward(aAwardKey:String, aStatKey:String, aStatCondition:int,
			aUserData:Object = null):AntAwardData
		{
			if (!containsAward(aAwardKey))
			{
				_awardData[_numAwards++] = new AntAwardData(aAwardKey, aStatKey, aStatCondition, aUserData);
				return _awardData[_numAwards - 1];
			}
			
			AntG.log("(!) Award with key \"" + aAwardKey + "\" already registered.", "result");
			return null;
		}
		
		/**
		 * Удаляет награду.
		 * 
		 * @param	aAwardKey	 Уникальное имя награды которую необходимо удалить.
		 * @return		Возвращает указатель на удаленный AntAwardData, или null если награда с указанным именем не существует.
		 */
		public static function unregisterAward(aAwardKey:String):AntAwardData
		{
			var i:int = 0;
			var award:AntAwardData;
			while (i < _numAwards)
			{
				award = _awardData[i];
				if (award != null && award.key == aAwardKey)
				{
					_awardData[i] = null;
					_awardData.splice(i, 1);
					return award;
				}
				i++;
			}
			
			return null;
		}
		
		/**
		 * Проверяет зарегистрирован ли награда с указанным имемен.
		 * 
		 * @param	aAwardKey	 Имя награды существование которой необходимо проверить.
		 * @return		Возвращает true если награда с указанным именем зарегистрирована.
		 */
		public static function containsAward(aAwardKey:String):Boolean
		{
			return (getAward(aAwardKey) != null) ? true : false;
		}
		
		/**
		 * Возвращает указатель на AntAwardData по имени награды.
		 * 
		 * @param	aAwardKey	 Имя награды данные для которой необходимо получить.
		 * @return		Возвращает указатель на AntAwardData, или null если награда с указанным именем не зарегистрирована.
		 */
		public static function getAward(aAwardKey:String):AntAwardData
		{
			var i:int = 0;
			var award:AntAwardData;
			while (i < _numAwards)
			{
				award = _awardData[i++];
				if (award != null && award.key == aAwardKey)
				{
					return award;
				}
			}
			
			return null;
		}
		
		/**
		 * Проверят достигнута ли награда игроком.
		 * 
		 * @param	aAwardKey	 Имя награды которую необходимо проверить.
		 * @return		Возвращает true если награда заработана игроком.
		 */
		public static function awardIsEarned(aAwardKey:String):Boolean
		{
			var award:AntAwardData = getAward(aAwardKey);
			return (award != null) ? award.isEarned : false;
		}
		
		/**
		 * Определяет завершенность награды в процентах.
		 * 
		 * @param	aAwardKey	 Уникальное имя награды для которой необходимо получить процент завершенности.
		 * @return		Возвращает прогресс достижения награды в диапазоне от 0 до 1.
		 */
		public static function getAwardProgress(aAwardKey:String):Number
		{
			var award:AntAwardData = getAward(aAwardKey);
			if (award != null)
			{
				var stat:AntStatisticData = getStat(award.statKey);
				if (stat != null)
				{
					return stat.value / award.statCondition;
				}
			}
			
			return 0;
		}
		
		/**
		 * Вызывается для обновления данных статистики.
		 * 
		 * @param	aStatKey	 Уникальное имя статистики значение для которой необходимо обновить.
		 * @param	aValue	 Новое значение.
		 */
		public static function track(aStatKey:String, aValue:int):void
		{
			var stat:AntStatisticData = getStat(aStatKey);
			if (stat != null)
			{
				if (stat.updateValue(aValue))
				{
					// Отправка события об обновлении значения состояния.
					if (eventUpdateState.numListeners > 0)
					{
						eventUpdateState.dispatch(stat);
					}
					
					var i:int = 0;
					var award:AntAwardData;
					while (i < _numAwards)
					{
						award = _awardData[i++];
						if (award != null && !award.isEarned && award.statKey == stat.key)
						{
							if (award.updateValue(stat.value))
							{
								// Отправка события о достижении награды.
								if (eventAwardEarned.numListeners > 0)
								{
									eventAwardEarned.dispatch(award);
								}
							}
							else
							{
								// Отправка события о прогрессе к достижению награды.
								if (eventUpdateAward.numListeners > 0)
								{
									eventUpdateAward.dispatch(award, stat.value / award.statCondition);
								}
							}
						}
					}
				}
			}
			else
			{
				AntG.log("(!) Stat \"" + aStatKey + "\" is not registered in AntStatistic.", "result");
			}
		}
		
		/**
		 * Сохранение данных в SharedObject.
		 */
		public static function saveData():void
		{
			var i:int = 0;
			
			// Сохранение статистики.
			var stats:Object = {};
			var stat:AntStatisticData;
			while (i < _numStats)
			{
				stat = _statData[i++];
				if (stat != null)
				{
					stats[stat.key] = stat.value;
				}
			}
			
			// Сохранение наград.
			i = 0;
			var awards:Object = {};
			var award:AntAwardData;
			while (i < _numAwards)
			{
				award = _awardData[i++];
				if (award != null)
				{
					awards[award.key] = award.isEarned;
				}
			}
			
			var cookie:AntCookie = new AntCookie();
			cookie.open(saveName);
			cookie.write("stats", stats);
			cookie.write("awards", awards);
			
			printObject("Save Statistic", stats);
			printObject("Save Awards", awards);
		}
		
		/**
		 * Загрузка данных из SharedObject.
		 */
		public static function loadData():void
		{
			if (_numAwards == 0 || _numStats == 0)
			{
				AntG.log("(!) Before loading data you need to register all statistics and awards!", "result");
			}
			
			var cookie:AntCookie = new AntCookie();
			cookie.open(saveName);
			
			// Загрузка статистики.
			var stats:Object = cookie.read("stats") as Object;
			printObject("Load Statistic", stats);
			
			var stat:AntStatisticData;
			for (var statKey:String in stats)
			{
				stat = getStat(statKey);
				if (stat != null)
				{
					stat.value = stats[statKey];
				}
			}
			
			// Загрузка наград.
			var awards:Object = cookie.read("awards") as Object;
			printObject("Load Awards", awards);
			
			var award:AntAwardData;
			for (var awardKey:String in awards)
			{
				award = getAward(awardKey);
				if (award != null)
				{
					award.isEarned = awards[awardKey];
				}
			}
		}
		
		/**
		 * Сбрасывает зачения статистики и наград.
		 */
		public static function clearData():void
		{
			var i:int = 0;
			var stat:AntStatisticData;
			while (i < _numStats)
			{
				stat = _statData[i++];
				if (stat != null)
				{
					stat.reset();
				}
			}
			
			i = 0;
			var award:AntAwardData;
			while (i < _numAwards)
			{
				award = _awardData[i++];
				if (award != null)
				{
					award.reset();
				}
			}
		}
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		
		/**
		 * @private
		 */
		private static function printObject(aTitle:String, aObjectData:Object):void
		{
			if (debugMode)
			{
				trace("-==", aTitle, "==-");
				for (var key:String in aObjectData)
				{
					trace(key + ":", aObjectData[key]);
				}
				trace(" ");
			}
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает кол-во зарегистрированных наград.
		 */
		public function get numAwards():int { return _numAwards; }
		
		/**
		 * Возвращает указатель на список зарегистрированных наград.
		 */
		public function get awards():Vector.<AntAwardData> { return _awardData; }
		
		/**
		 * Возвращает кол-во зарегестрированных статистик.
		 */
		public function get numStats():int { return _numStats; }
		
		/**
		 * Возвращает указатель на список зарегистрированных статистик.
		 */
		public function get stats():Vector.<AntStatisticData> { return _statData; } 
		
	}

}

