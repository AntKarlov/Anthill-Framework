package ru.antkarlov.anthill.plugins
{
	import ru.antkarlov.anthill.AntCamera;
	
	public interface IPlugin
	{
		function preUpdate():void;
		function update():void;
		function postUpdate():void;
		function draw(aCamera:AntCamera):void;
	}

}