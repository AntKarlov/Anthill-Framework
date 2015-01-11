package ru.antkarlov.anthill.ants
{
	import flash.utils.Dictionary;
	import ru.antkarlov.anthill.plugins.IPlugin;
	import ru.antkarlov.anthill.signals.AntSignal;
	import ru.antkarlov.anthill.AntCamera;
	
	public class AntCore extends Object implements IPlugin
	{
		public var eventUpdateComplete:AntSignal;
		public var familyClass:Class = AntFamily;
		
		private var _objects:Array;
		private var _numObjects:int;
		
		private var _systems:Array;
		private var _numSystems:int;
		
		private var _families:Dictionary;
		private var _objectNames:Dictionary;
		
		private var _isLocked:Boolean;
		private var _priority:int;
		private var _sortOrder:int;
		private var _tag:String;
		
		/**
		 * @constructor
		 */
		public function AntCore()
		{
			super();
			
			eventUpdateComplete = new AntSignal();
			
			_objects = [];
			_numObjects = 0;
			
			_systems = [];
			_numSystems = 0;
			
			_families = new Dictionary();
			_objectNames = new Dictionary();
			
			_isLocked = false;
		}
		
		/**
		 * @private
		 */
		public function addObject(aObject:AntObject):void
		{
			if (!containsObject(aObject))
			{
				if (_objectNames[aObject.name])
				{
					throw new Error("Object with name \"" + aObject.name + "\" is already uses by other object.");
				}
				
				_objectNames[aObject.name] = aObject;
				_objects[_objects.length] = aObject;
				_numObjects++;
				
				aObject.eventComponentAdded.add(onComponentAdded);
				aObject.eventComponentRemoved.add(onComponentRemoved);
				aObject.eventNameChanged.add(onObjectNameChanged);
				
				for each (var family:IFamily in _families)
				{
					family.addObject(aObject);
				}
			}
		}
		
		/**
		 * @private
		 */
		public function removeObject(aObject:AntObject, aDestroyFlag:Boolean = true):void
		{
			if (containsObject(aObject))
			{
				aObject.eventComponentAdded.remove(onComponentAdded);
				aObject.eventComponentRemoved.remove(onComponentRemoved);
				aObject.eventNameChanged.remove(onObjectNameChanged);
				
				for each (var family:IFamily in _families)
				{
					family.removeObject(aObject);
				}
				
				delete _objectNames[aObject.name];
				
				var i:int = _objects.indexOf(aObject);
				if (i >= 0 && i < _objects.length)
				{
					_objects[i] = null;
					_objects.splice(i, 1);
					_numObjects--;
				}
				
				if (aDestroyFlag)
				{
					i = 0;
					var component:Object;
					var components:Array = aObject.getComponents();
					const n:int = components.length;
					while (i < n)
					{
						component = components[i++];
						if (component != null && component.hasOwnProperty("destroy") &&
							(component["destroy"] is Function))
						{
							(component["destroy"] as Function).apply(this);
						}
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		public function containsObject(aObject:AntObject):Boolean
		{
			var i:int = _objects.indexOf(aObject);
			return (i >= 0 && i < _numObjects);
		}
		
		/**
		 * @private
		 */
		public function getObjectByName(aName:String):AntObject
		{
			var object:AntObject;
			var i:int = 0;
			while (i < _numObjects)
			{
				object = _objects[i++] as AntObject;
				if (object != null && object.name == aName)
				{
					return object;
				}
			}
			
			return null;
		}
		
		/**
		 * @private
		 */
		public function addSystem(aSystem:AntSystem, aPriority:int):void
		{
			if (!containsSystem(aSystem))
			{
				aSystem.priority = aPriority;
				aSystem.addToCore(this);
				
				_systems[_systems.length] = aSystem;
				_numSystems++;
				
				updatePriority();
			}
		}
		
		/**
		 * @private
		 */
		public function removeSystem(aSystem:AntSystem):void
		{
			if (containsSystem(aSystem))
			{
				var i:int = _systems.indexOf(aSystem);
				if (i >= 0 && i < _numSystems)
				{
					_systems[i] = null;
					_systems.splice(i, 1);
					_numSystems--;
				}
				
				aSystem.removeFromCore(this);
			}
		}
		
		/**
		 * @private
		 */
		public function containsSystem(aSystem:AntSystem):Boolean
		{
			var i:int = _systems.indexOf(aSystem);
			return (i >= 0 && i <= _numSystems);
		}
		
		/**
		 * @private
		 */
		public function hasSystem(aSystemClass:Class):Boolean
		{
			var i:int = 0;
			while (i < _numSystems)
			{
				if (_systems[i++] is aSystemClass)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * @private
		 */
		public function getSystem(aSystemClass:Class):*
		{
			var i:int = 0;
			var system:AntSystem;
			while (i < _numSystems)
			{
				system = _systems[i++];
				if (system is aSystemClass)
				{
					return system;
				}
			}
			
			return null;
		}
		
		/**
		 * @private
		 */
		public function clearSystems():void
		{
			var i:int = _numSystems - 1;
			while (i >= 0)
			{
				removeSystem(_systems[i--]);
			}
		}
		
		/**
		 * @private
		 */
		public function getSystems(aResult:Array = null):Array
		{
			if (aResult == null)
			{
				aResult = [];
			}
			
			var i:int = 0;
			while (i < _numSystems)
			{
				aResult[aResult.length] = _systems[i++];
			}
			
			return aResult;
		}
		
		/**
		 * @private
		 */
		public function getNodes(aNodeClass:Class):AntNodeList
		{
			if (_families[aNodeClass])
			{
				return (_families[aNodeClass] as IFamily).nodes;
			}
			
			var family:IFamily = new familyClass(aNodeClass, this);
			_families[aNodeClass] = family;
			
			var i:int = 0;
			while (i < _numObjects)
			{
				family.addObject(_objects[i++]);
			}
			
			return family.nodes;
		}
		
		/**
		 * @private
		 */
		public function releaseNodes(aNodeClass:Class):void
		{
			if (_families[aNodeClass])
			{
				_families[aNodeClass].clear();
				_families[aNodeClass] = null;
			}
			
			delete _families[aNodeClass];
		}
		
		/**
		 * @private
		 */
		private function onComponentAdded(aObject:AntObject, aComponentClass:Class):void
		{
			for each (var family:IFamily in _families)
			{
				family.componentAdded(aObject, aComponentClass);
			}
		}
		
		/**
		 * @private
		 */
		private function onComponentRemoved(aObject:AntObject, aComponentClass:Class):void
		{
			for each (var family:IFamily in _families)
			{
				family.componentRemoved(aObject, aComponentClass);
			}
		}
		
		/**
		 * @private
		 */
		private function onObjectNameChanged(aObject:AntObject, aOldName:String):void
		{
			if (_objectNames[aOldName] == aObject)
			{
				delete _objectNames[aOldName];
				_objectNames[aObject.name] = aObject;
			}
		}
		
		/**
		 * @private
		 */
		private function updatePriority():void
		{
			_systems.sort(sortHandler);
			
			//public static const ASCENDING:int = -1;
			//public static const DESCENDING:int = 1;
			_sortOrder = 1;
		}
		
		/**
		 * @private
		 */
		protected function sortHandler(aSystem1:AntSystem, aSystem2:AntSystem):int
		{
			if (aSystem1 == null)
			{
				return _sortOrder;
			}
			else if (aSystem2 == null)
			{
				return -_sortOrder;
			}
			
			if (aSystem1.priority < aSystem2.priority)
			{
				return _sortOrder;
			}
			else if (aSystem1.priority > aSystem2.priority)
			{
				return -_sortOrder;
			}
			
			return 0;
		}
		
		/**
		 * @private
		 */
		public function get isLocked():Boolean
		{
			return _isLocked;
		}
		
		//---------------------------------------
		// IPlugin Implementation
		//---------------------------------------
		
		//import ru.antkarlov.anthill.plugins.IPlugin;
		public function get tag():String { return _tag; }
		public function set tag(aValue:String):void
		{
			_tag = aValue;
		}
		
		public function get priority():int { return _priority; }
		public function set priority(aValue:int):void 
		{
			_priority = aValue;
		}
		
		public function update():void
		{
			_isLocked = true;
			
			var i:int = 0;
			var system:AntSystem;
			while (i < _numSystems)
			{
				system = _systems[i++] as AntSystem;
				if (system != null)
				{
					system.update();
				}
			}
			
			_isLocked = false;
			eventUpdateComplete.dispatch();
		}
		
		public function draw(aCamera:AntCamera):void
		{
			// ..
		}
		
	}

}