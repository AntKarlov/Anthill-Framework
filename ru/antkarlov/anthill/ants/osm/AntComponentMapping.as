package ru.antkarlov.anthill.ants.osm
{
	
	public class AntComponentMapping extends Object
	{
		private var _componentClass:Class;
		private var _state:AntObjectState;
		private var _provider:IComponentProvider;
		
		public function AntComponentMapping(aState:AntObjectState, aClass:Class)
		{
			super();
			_state = aState;
			_componentClass = aClass;
			withClass(aClass)
		}
		
		public function withClass(aClass:Class):AntComponentMapping
		{
			setProvider(new AntClassProvider(aClass));
			return this;
		}
		
		public function withInstance(aComponent:*):AntComponentMapping
		{
			setProvider(new AntInstanceProvider(aComponent));
			return this;
		}
		
		public function withSingleton(aClass:Class = null):AntComponentMapping
		{
			if (aClass == null)
			{
				aClass = _componentClass;
			}
			
			setProvider(new AntSingletonProvider(aClass));
			return this;
		}
		
		public function withMethod(aMethod:Function):AntComponentMapping
		{
			setProvider(new AntMethodProvider(aMethod));
			return this;
		}
		
		public function withProvider(aProvider:IComponentProvider):AntComponentMapping
		{
			setProvider(aProvider);
			return this;
		}
		
		public function add(aClass:Class):AntComponentMapping
		{
			return _state.add(aClass);
		}
		
		private function setProvider(aProvider:IComponentProvider):void
		{
			_provider = aProvider;
			_state._providers[_componentClass] = aProvider;
		}
	
	}

}