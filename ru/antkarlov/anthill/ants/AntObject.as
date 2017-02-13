package ru.antkarlov.anthill.ants
{
	import ru.antkarlov.anthill.signals.AntSignal;
	import flash.utils.Dictionary;
	
	public class AntObject extends Object
	{
		public var eventComponentAdded:AntSignal;
		public var eventComponentRemoved:AntSignal;
		public var eventNameChanged:AntSignal;
		
		private var _name:String;
		private var _components:Dictionary;
		
		private static var _nameIndex:int = 0;
		
		/**
		 * @constructor
		 */
		public function AntObject(aName:String = null)
		{
			super();
			
			eventComponentAdded = new AntSignal(AntObject, Class);
			eventComponentRemoved = new AntSignal(AntObject, Class);
			eventNameChanged = new AntSignal(AntObject, String);
			
			_name = (aName == null) ? "Object" + (++_nameIndex) : aName;
			_components = new Dictionary();
		}
		
		/**
		 * Добавляет компонент в объект.
		 * 
		 * @param	aComponent	 Указатель на экземпляр компонента который необходимо добавить.
		 * @return		Возвращает указатель на самого себя.
		 */
		public function add(aComponent:Object, aClass:Class = null):AntObject
		{
			if (aClass == null)
			{
				aClass = aComponent.constructor as Class;
			}
			
			if (_components[aClass])
			{
				remove(aClass);
			}
			
			_components[aClass] = aComponent;
			eventComponentAdded.dispatch(this, aClass);
			return this;
		}
		
		/**
		 * Удаляет компонент из объекта.
		 * 
		 * @param	aComponentClass	 Класс компонента который необходимо удалить.
		 * @return		Возвращает указатель на удаленный компонент или null если компонента не существовало.
		 */
		public function remove(aComponentClass:Class):*
		{
			var component:* = _components[aComponentClass];
			if (component)
			{
				delete _components[aComponentClass];
				eventComponentRemoved.dispatch(this, aComponentClass);
				return component;
			}
			
			return null;
		}
		
		/**
		 * Извлекает необходимый компонент из объекта.
		 * 
		 * @param	aComponentClass	 Класс компонента который необходимо получить.
		 */
		public function get(aComponentClass:Class):*
		{
			return _components[aComponentClass];
		}
		
		/**
		 * Проверяет существование компонента в объекте.
		 * 
		 * @param	aComponentClass	 Класс компонента существование которого необходимо проверить.
		 */
		public function has(aComponentClass:Class):Boolean
		{
			return (_components[aComponentClass] != null);
		}
		
		/**
		 * Извлекает список всех добавленных компонентов.
		 * 
		 * @param	aResult	 Указатель на массив в который может быть записан результат.
		 * @return		Возвращает массив всех добавленных компонентов.
		 */
		public function getComponents(aResult:Array = null):Array
		{
			if (aResult == null)
			{
				aResult = [];
			}
			
			for each (var component:* in _components)
			{
				aResult[aResult.length] = component;
			}
			
			return aResult;
		}
		
		/**
		 * Определяет имя объекта.
		 */
		public function get name():String { return _name; }
		public function set name(aValue:String):void
		{
			if (_name != aValue)
			{
				var oldName:String = _name;
				_name = aValue;
				eventNameChanged.dispatch(this, oldName);
			}
			
		}
	
	}

}