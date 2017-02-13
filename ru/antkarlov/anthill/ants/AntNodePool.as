package ru.antkarlov.anthill.ants
{
	import flash.utils.Dictionary;
	
	public class AntNodePool extends Object
	{
		private var _nodeClass:Class;
		private var _components:Dictionary;
		
		private var _freeNodes:Array;
		private var _cacheNodes:Array;
		
		/**
		 * @constructor
		 */
		public function AntNodePool(aNodeClass:Class, aComponents:Dictionary)
		{
			super();
			
			_nodeClass = aNodeClass;
			_components = aComponents;
			
			_freeNodes = [];
			_cacheNodes = [];
		}
		
		/**
		 * @private
		 */
		public function get():AntNode
		{
			return (_freeNodes.length > 0) ? _freeNodes.pop() : new _nodeClass();
		}
		
		/**
		 * @private
		 */
		public function set(aNode:AntNode):void
		{
			for each (var componentName:String in _components)
			{
				aNode[componentName] = null;
			}
			
			aNode.object = null;
			_freeNodes[_freeNodes.length] = aNode;
		}
		
		/**
		 * @private
		 */
		public function setToCache(aNode:AntNode):void
		{
			_cacheNodes[_cacheNodes.length] = aNode;
		}
		
		/**
		 * @private
		 */
		public function releaseCache():void
		{
			var i:int = 0;
			const n:int = _cacheNodes.length;
			while (i < n)
			{
				set(_cacheNodes[i++]);
			}
			
			_cacheNodes.length = 0;
		}
	
	}

}