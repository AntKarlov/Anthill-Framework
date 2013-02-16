package ru.antkarlov.anthill.plugins
{
	import ru.antkarlov.anthill.*;
	
	/**
	 * Данный класс содержит статические методы для реализации сглаживаний.
	 * Все эти методы используются классом AntTween.
	 * 
	 * <p>Вы можете определить свои методы для реализации сглаживаний используя метод
	 * 'registerTransition()'. Метод для реализации должен следовать одному простому правилу:
	 * в качестве атрибута должен передаваться текущий прогресс в промежутке от 0 до 1.</p>
	 * 
	 * <pre>function myTransition(aRatio:Number):Number</pre>
	 * 
	 * <p>Идея и реализация подсмотрена у <a href="http://gamua.com/starling/">Starling Framework</a>.</p>
	 * 
	 * @author Антон Карлов
	 * @since  26.01.2013
	 */
	public class AntTransition extends Object
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const LINEAR:String = "linear";
		public static const EASE_IN:String = "easeIn";
		public static const EASE_OUT:String = "easeOut";
		public static const EASE_IN_OUT:String = "easeInOut";
		public static const EASE_OUT_IN:String = "easeOutIn";        
		public static const EASE_IN_BACK:String = "easeInBack";
		public static const EASE_OUT_BACK:String = "easeOutBack";
		public static const EASE_IN_OUT_BACK:String = "easeInOutBack";
		public static const EASE_OUT_IN_BACK:String = "easeOutInBack";
		public static const EASE_IN_ELASTIC:String = "easeInElastic";
		public static const EASE_OUT_ELASTIC:String = "easeOutElastic";
		public static const EASE_IN_OUT_ELASTIC:String = "easeInOutElastic";
		public static const EASE_OUT_IN_ELASTIC:String = "easeOutInElastic";  
		public static const EASE_IN_BOUNCE:String = "easeInBounce";
		public static const EASE_OUT_BOUNCE:String = "easeOutBounce";
		public static const EASE_IN_OUT_BOUNCE:String = "easeInOutBounce";
		public static const EASE_OUT_IN_BOUNCE:String = "easeOutInBounce";
		
		private static var _transitions:AntStorage;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntTransition()
		{
			super();
			throw new Error();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Извлекает зарегистрированный метод под указанным именем.
		 * 
		 * @param	aName	 Имя под которым зарегистрирован необходимый метод.
		 * @return		Возвращает указатель на метод.
		 */
		public static function getTransition(aName:String):Function
		{
			if (_transitions == null)
			{
				registerDefaults();
			}
			
			return _transitions.get(aName);
		}
		
		/**
		 * Регистрирует указанный метод под указанным именем для последующего его использования в
		 * классе AntTween для реализации рассчетов.
		 * 
		 * @param	aName	 Имя метода.
		 * @param	aFunc	 Указатель на регистрируемый метод.
		 */
		public static function register(aName:String, aFunc:Function):void
		{
			if (_transitions == null)
			{
				registerDefaults();
			}
			
			_transitions.set(aName, aFunc);
		}
		
		/**
		 * Регистрирует стандартные методы для реализации рассчетов.
		 */
		private static function registerDefaults():void
		{
			_transitions = new AntStorage();
			
			register(LINEAR, linear);
			register(EASE_IN, easeIn);
			register(EASE_OUT, easeOut);
			register(EASE_IN_OUT, easeInOut);
			register(EASE_OUT_IN, easeOutIn);
			register(EASE_IN_BACK, easeInBack);
			register(EASE_OUT_BACK, easeOutBack);
			register(EASE_IN_OUT_BACK, easeInOutBack);
			register(EASE_OUT_IN_BACK, easeOutInBack);
			register(EASE_IN_ELASTIC, easeInElastic);
			register(EASE_OUT_ELASTIC, easeOutElastic);
			register(EASE_IN_OUT_ELASTIC, easeInOutElastic);
			register(EASE_OUT_IN_ELASTIC, easeOutInElastic);
			register(EASE_IN_BOUNCE, easeInBounce);
			register(EASE_OUT_BOUNCE, easeOutBounce);
			register(EASE_IN_OUT_BOUNCE, easeInOutBounce);
			register(EASE_OUT_IN_BOUNCE, easeOutInBounce);
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		protected static function linear(aRatio:Number):Number
		{
			return aRatio;
		}
		
		/**
		 * @private
		 */
		protected static function easeIn(aRatio:Number):Number
		{
			return aRatio * aRatio * aRatio;
		}
		
		/**
		 * @private
		 */
		protected static function easeOut(aRatio:Number):Number
		{
			var invRatio:Number = aRatio - 1.0;
			return invRatio * invRatio * invRatio + 1;
		}
		
		/**
		 * @private
		 */
		protected static function easeInOut(aRatio:Number):Number
		{
			return easeCombined(easeIn, easeOut, aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeOutIn(aRatio:Number):Number
		{
			return easeCombined(easeOut, easeIn, aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeInBack(aRatio:Number):Number
		{
			var s:Number = 1.70158;
			return Math.pow(aRatio, 2) * ((s + 1.0) * aRatio - s);
		}
		
		/**
		 * @private
		 */
		protected static function easeOutBack(aRatio:Number):Number
		{
			var invRatio:Number = aRatio - 1.0;
			var s:Number = 1.70158;
			return Math.pow(invRatio, 2) * ((s + 1.0) * aRatio + s) + 1.0;
		}
		
		/**
		 * @private
		 */
		protected static function easeInOutBack(aRatio:Number):Number
		{
			return easeCombined(easeInBack, easeOutBack, aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeOutInBack(aRatio:Number):Number
		{
			return easeCombined(easeOutBack, easeInBack, aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeInElastic(aRatio:Number):Number
		{
			if (aRatio == 0 || aRatio == 1)
			{
				return aRatio;
			}
			else
			{
				var p:Number = 0.3;
				var s:Number = p / 4.0;
				var invRatio:Number = aRatio - 1;
				return -1.0 * Math.pow(2.0, 10.0 * invRatio) * Math.sin((invRatio - s) * (2.0 * Math.PI) / p);
			}
		}
		
		/**
		 * @private
		 */
		protected static function easeOutElastic(aRatio:Number):Number
		{
			if (aRatio == 0 || aRatio == 1)
			{
				return aRatio;
			}
			else
			{
				var p:Number = 0.3;
				var s:Number = p / 4.0;
				return Math.pow(2.0, -10.0 * aRatio) * Math.sin((aRatio - s) * (2.0 * Math.PI) / p) + 1;
			}
		}
		
		/**
		 * @private
		 */
		protected static function easeInOutElastic(aRatio:Number):Number
		{
			return easeCombined(easeInElastic, easeOutElastic, aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeOutInElastic(aRatio:Number):Number
		{
			return easeCombined(easeOutElastic, easeInElastic, aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeInBounce(aRatio:Number):Number
		{
			return 1.0 - easeOutBounce(1.0 - aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeOutBounce(aRatio:Number):Number
		{
			var s:Number = 7.5625;
			var p:Number = 2.75;
			var l:Number;
			if (aRatio < (1.0 / p))
			{
				l = s * Math.pow(aRatio, 2);
			}
			else
			{
				if (aRatio < (2.0 / p))
				{
					aRatio -= 1.5 / p;
					l = s * Math.pow(aRatio, 2) + 0.75;
				}
				else
				{
					if (aRatio < 2.5 / p)
					{
						aRatio -= 2.25 / p;
						l = s * Math.pow(aRatio, 2) + 0.9375;
					}
					else
					{
						aRatio -= 2.625 / p;
						l = s * Math.pow(aRatio, 2) + 0.984375;
					}
				}
			}
			
			return l;
		}
		
		/**
		 * @private
		 */
		protected static function easeInOutBounce(aRatio:Number):Number
		{
			return easeCombined(easeInBounce, easeOutBounce, aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeOutInBounce(aRatio:Number):Number
		{
			return easeCombined(easeOutBounce, easeInBounce, aRatio);
		}
		
		/**
		 * @private
		 */
		protected static function easeCombined(aStartFunc:Function, aEndFunc:Function, aRatio:Number):Number
		{
			if (aRatio < 0.5)
			{
				return 0.5 * aStartFunc(aRatio * 2.0);
			}
			else
			{
				return 0.5 * aEndFunc((aRatio - 0.5) * 2.0) + 0.5;
			}
		}
		
	}

}