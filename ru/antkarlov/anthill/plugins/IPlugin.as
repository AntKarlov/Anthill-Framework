package ru.antkarlov.anthill.plugins
{
	
	public interface IPlugin
	{
		function preUpdate():void;
		function update():void;
		function postUpdate():void;
	}

}