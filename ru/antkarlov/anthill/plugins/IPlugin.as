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
		
	}

}