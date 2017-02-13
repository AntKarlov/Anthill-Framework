package ru.antkarlov.anthill.ants
{
	import ru.antkarlov.anthill.signals.AntSignal;
	
	public class AntNodeList extends Object
	{
		public var eventNodeAdded:AntSignal;
		public var eventNodeRemoved:AntSignal;
		
		private var _nodes:Array;
		private var _numNodes:int;
		
		/**
		 * @constructor
		 */
		public function AntNodeList()
		{
			super();
			
			eventNodeAdded = new AntSignal(AntNode);
			eventNodeRemoved = new AntSignal(AntNode);
			
			_nodes = [];
			_numNodes = 0;
		}
		
		/**
		 * @private
		 */
		public function add(aNode:AntNode):void
		{
			if (!contains(aNode))
			{
				_nodes.push(aNode);
				_numNodes++;
				
				eventNodeAdded.dispatch(aNode);
			}
		}
		
		/**
		 * @private
		 */
		public function get(aIndex:int):AntNode
		{
			return (aIndex >= 0 && aIndex < _numNodes) ? _nodes[aIndex] : null;
		}
		
		/**
		 * @private
		 */
		public function applyForEach(aFunction:Function):void
		{
			var i:int = 0;
			while (i < _numNodes)
			{
				aFunction(_nodes[i++]);
			}
		}
		
		/**
		 * @private
		 */
		public function remove(aNode:AntNode):void
		{
			var i:int = _nodes.indexOf(aNode);
			if (i >= 0 && i < _numNodes)
			{
				_nodes[i] = null;
				_nodes.splice(i, 1);
				_numNodes--;
				
				eventNodeRemoved.dispatch(aNode);
			}
		}
		
		/**
		 * @private
		 */
		public function contains(aNode:AntNode):Boolean
		{
			var i:int = _nodes.indexOf(aNode);
			return (i >= 0 && i < _numNodes);
		}
		
		/**
		 * @private
		 */
		public function removeAll():void
		{
			var i:int = _numNodes - 1;
			while (i >= 0)
			{
				remove(_nodes[i--]);
			}
			
			_nodes.length = 0;
			_numNodes = 0;
		}
		
		/**
		 * @private
		 */
		public function get isEmpty():Boolean
		{
			return (_numNodes == 0);
		}
		
		/**
		 * @private
		 */
		public function get numNodes():int
		{
			return _numNodes;
		}
		
	}

}