package ru.antkarlov.anthill.ants
{
	
	public interface IFamily
	{
		/**
		 * @private
		 */
		function addObject(aObject:AntObject):void;
		
		/**
		 * @private
		 */
		function removeObject(aObject:AntObject):void;
		
		/**
		 * @private
		 */
		function componentAdded(aObject:AntObject, aComponentClass:Class):void;
		
		/**
		 * @private
		 */
		function componentRemoved(aObject:AntObject, aComponentClass:Class):void;
		
		/**
		 * @private
		 */
		function clear():void;
		
		/**
		 * @private
		 */
		function get nodes():AntNodeList;
	}

}