package ru.antkarlov.anthill.ants
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	public class AntFamily extends Object implements IFamily
	{
		private var _nodes:AntNodeList;
		private var _nodeClass:Class;
		private var _objects:Dictionary;
		private var _components:Dictionary;
		private var _pool:AntNodePool;
		private var _core:AntCore;
		
		/**
		 * @constructor
		 */
		public function AntFamily(aNodeClass:Class, aCore:AntCore)
		{
			super();
			
			_nodeClass = aNodeClass;
			_core = aCore;
			
			init();
		}
		
		/**
		 * @private
		 */
		private function init():void
		{
			_nodes = new AntNodeList();
			_objects = new Dictionary();
			_components = new Dictionary();
			_pool = new AntNodePool(_nodeClass, _components);
			
			_pool.set(_pool.get());
			
			var variables:XMLList = describeType(_nodeClass).factory.variable;
			for each (var atom:XML in variables)
			{
				if (atom.@name != "object")
				{
					var componentClass:Class = getDefinitionByName(atom.@type) as Class;
					_components[componentClass] = atom.@name.toString();
				}
			}
		}
		
		/**
		 * @private
		 */
		public function add(aObject:AntObject):void
		{
			if (!_objects[aObject])
			{
				var componentClass:*;
				for (componentClass in _components)
				{
					if (!aObject.has(componentClass))
					{
						return;
					}
				}
				
				var node:AntNode = _pool.get();
				node.object = aObject;
				for (componentClass in _components)
				{
					node[_components[componentClass]] = aObject.get(componentClass);
				}
				
				_objects[aObject] = node;
				_nodes.add(node);
			}
		}
		
		/**
		 * @private
		 */
		public function remove(aObject:AntObject):void
		{
			if (_objects[aObject])
			{
				var node:AntNode = _objects[aObject];
				delete _objects[aObject];
				_nodes.remove(node);
				
				if (_core.isLocked)
				{
					_pool.setToCache(node);
					_core.eventUpdateComplete.add(onCoreUpdateCompleted);
				}
				else
				{
					_pool.set(node);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function onCoreUpdateCompleted():void
		{
			_core.eventUpdateComplete.remove(onCoreUpdateCompleted);
			_pool.releaseCache();
		}
		
		//---------------------------------------
		// IFamily Implementation
		//---------------------------------------
		
		//import ru.antkarlov.anthill.ants.IFamily;
		public function get nodes():AntNodeList
		{
			return _nodes;
		}
		
		public function addObject(aObject:AntObject):void
		{
			add(aObject);
		}
		
		public function removeObject(aObject:AntObject):void
		{
			remove(aObject);
		}
		
		public function componentAdded(aObject:AntObject, aComponentClass:Class):void
		{
			add(aObject);
		}
		
		public function componentRemoved(aObject:AntObject, aComponentClass:Class):void
		{
			if (_components[aComponentClass])
			{
				remove(aObject);
			}
		}
		
		public function clear():void
		{
			var i:int = 0;
			var node:AntNode;
			while (i < _nodes.numNodes)
			{
				node = _nodes.get(i++);
				delete _objects[node.object];
			}
			
			_nodes.removeAll();
			_nodes = null;
		}
	
	}

}