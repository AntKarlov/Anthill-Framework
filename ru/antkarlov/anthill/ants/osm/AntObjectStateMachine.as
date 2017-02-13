package ru.antkarlov.anthill.ants.osm
{
	import ru.antkarlov.anthill.ants.AntObject;
	import flash.utils.Dictionary;
	
	public class AntObjectStateMachine extends Object
	{
		
		public var object:AntObject;
		private var _states:Dictionary;
		private var _currentState:AntObjectState;
		
		public function AntObjectStateMachine(aObject:AntObject)
		{
			super();
			object = aObject;
			_states = new Dictionary();
			_currentState = null;
		}
		
		public function addState(aName:String, aState:AntObjectState):AntObjectStateMachine
		{
			_states[aName] = aState;
			return this;
		}
		
		public function createState(aName:String):AntObjectState
		{
			var state:AntObjectState = new AntObjectState();
			_states[aName] = state;
			return state;
		}
		
		public function changeState(aName:String):void
		{
			var newState:AntObjectState = _states[aName];
			if (!newState)
			{
				throw(new Error("(AntObjectStateMachine): Object state with name \"" + aName +"\" doesn't exists."));
			}
			
			if (newState == _currentState)
			{
				newState = null;
				return;
			}
			
			var other:IComponentProvider;
			var toAdd:Dictionary;
			var type:Class;
			var t:*;
			
			if (_currentState)
			{
				toAdd = new Dictionary();
				for (t in newState._providers)
				{
					type = t as Class;
					toAdd[type] = newState._providers[type];
				}
				
				for (t in _currentState._providers)
				{
					type = t as Class;
					other = toAdd[type] as IComponentProvider;
					if (other != null && other.identifier == _currentState._providers[type].identifier)
					{
						delete toAdd[type];
					}
					else
					{
						object.remove(type);
					}
				}
			}
			else
			{
				toAdd = newState._providers;
			}
			
			for (t in toAdd)
			{
				type = t as Class;
				other = toAdd[type] as IComponentProvider;
				object.add(other.component, type);
			}
			
			_currentState = newState;
		}
	
	}

}