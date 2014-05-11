package ru.antkarlov.anthill.events
{
	import ru.antkarlov.anthill.signals.AntDeluxeSignal;
	
	/**
	 * Простая реализация всплывающего события.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.02.2013
	 */
	public class AntEvent implements IEvent
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Любые пользовательские данные которые может нести в себе событие.
		 * @default    null;
		 */
		public var userData:Object;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		protected var _name:String;
		protected var _bubbles:Boolean;
		protected var _target:Object;
		protected var _currentTarget:Object;
		protected var _signal:AntDeluxeSignal;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function AntEvent(aName:String, aBubbles:Boolean = false, aUserData:Object = null)
		{
			super();
			_name = aName;
			_bubbles = aBubbles;
			userData = aUserData;
		}
		
		/**
		 * @private
		 */
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		
		/**
		 * @inheritDoc
		 */
		public function get signal():AntDeluxeSignal { return _signal; }
		public function set signal(value:AntDeluxeSignal):void { _signal = value; }
		
		/**
		 * @inheritDoc
		 */
		public function get target():Object { return _target; }
		public function set target(value:Object):void { _target = value; }
		
		/**
		 * @inheritDoc
		 */
		public function get currentTarget():Object { return _currentTarget; }
		public function set currentTarget(value:Object):void { _currentTarget = value; }
		
		/**
		 * @inheritDoc
		 */
		public function get bubbles():Boolean { return _bubbles; }
		public function set bubbles(value:Boolean):void { _bubbles = value; }
		
		/**
		 * @inheritDoc
		 */
		public function clone():IEvent
		{
			var newEvent:AntEvent = new AntEvent(_name, _bubbles);
			newEvent.userData = userData;
			return newEvent;
		}
		
	}

}