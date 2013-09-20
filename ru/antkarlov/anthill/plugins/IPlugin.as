package ru.antkarlov.anthill.plugins
{
	import ru.antkarlov.anthill.AntCamera;
	
	public interface IPlugin
	{
		/**
		 * Вызывается автоматически каждый кадр когда плагин добавлен в стркутуру Anthill 
		 * методом <code>AntG.addPlugin()</code>.
		 */
		function update():void;
		
		/**
		 * Вызывается автоматически каждый кадр когда плагин добавлен в структуру Anthill
		 * методом <code>AntG.addPlugin()</code>.
		 * 
		 * <p>Если ваш плагин не имеет средств визуализации, то просто оставьте этот метод пустым.</p>
		 * 
		 * @param	aCamera	 Указатель на текущую камеру.
		 */
		function draw(aCamera:AntCamera):void;
		
		/**
		 * Задает идентификатор для плагина.
		 * 
		 * <p>Используя идентификаторы можно объеденять плагины в группы и, например, останавливать 
		 * сразу несколько плагинов и возобновлять их работу.</p>
		 */
		function get tag():String;
		function set tag(aValue:String):void;
		
		/**
		 * Задает приоритет для плагина.
		 * 
		 * <p>Приоритет влияет только на порядок обновления и отрисовки плагинов. Плагины с наибольшим 
		 * приоритетом выполняются в первую очередь чем с наименьшим.</p>
		 */
		function get priority():int;
		function set priority(aValue:int):void;
		
	}

}