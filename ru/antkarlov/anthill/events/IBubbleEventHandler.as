package ru.antkarlov.anthill.events
{

	public interface IBubbleEventHandler
	{

		/**
		 * Обработчик для всплывающего события.
		 * 
		 * <p>Используйте данный метод чтобы решить что делать дальше с перехваченным событием.</p>
		 * 
		 * @param	aEvent	 Событие которое всплыло.
		 * @return		Определяет необходимо ли продолжать всплывание для перехваченного события.
		 */
		function onEventBubbled(aEvent:IEvent):Boolean;

	}

}