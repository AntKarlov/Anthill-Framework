package ru.antkarlov.anthill.events
{
	import ru.antkarlov.anthill.signals.AntDeluxeSignal;
	
	public interface IEvent
	{
		/**
		 * Указатель на объект который произвел событие.
		 */
		function get target():Object;
		function set target(value:Object):void;
		
		/**
		 * Указатель на текущий объект посредник через который прошло событие.
		 */
		function get currentTarget():Object;
		function set currentTarget(value:Object):void;
		
		/**
		 * Сигнал который произвел событие.
		 */
		function get signal():AntDeluxeSignal;
		function set signal(value:AntDeluxeSignal):void;
		
		/**
		 * Определяет является ли событие всплывающим.
		 */
		function get bubbles():Boolean;
		function set bubbles(value:Boolean):void;
		
		/**
		 * Создает копию события.
		 */
		function clone():IEvent;
		
	}

}