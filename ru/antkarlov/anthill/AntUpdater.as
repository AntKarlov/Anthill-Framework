package ru.antkarlov.anthill
{
	/**
	 * Используется для процессинга любых объектов унаследованных от AntBasic.
	 * При инициализации игрового движка <code>AntUpdater</code> доступен через <code>AntG.updater</code>.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  22.08.2012
	 */
	public class AntUpdater extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Список объектов для процессинга.
		 */
		public var children:Array;
		
		/**
		 * Количество объектов в процессоре. Учитывает так же пустые ячейки, 
		 * которые остаются после удаления объектов из процессора с атрибутом 
		 * <code>aSplice == false</code>.
		 */
		public var length:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntUpdater()
		{
			super();
			children = [];
			length = 0;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет указанные объект в процессор.
		 * 
		 * @param	aBasic	 Объект который необходимо добавить в процессор.
		 * @return		Возвращает указатель на добавленный объект.
		 */
		public function add(aBasic:AntBasic):AntBasic
		{
			if (children.indexOf(aBasic) > -1)
			{
				return aBasic;
			}
			
			for (var i:int = 0; i < length; i++)
			{
				if (children[i] == null)
				{
					children[i] = aBasic;
					return aBasic;
				}
			}
			
			children[length] = aBasic;
			length++;
			return aBasic;
		}
		
		/**
		 * Удаляет указанный объект из процессора.
		 * 
		 * @param	aBasic	 Объект который необходимо удалить из процессора.
		 * @param	aSplice	 Если true то ячейка занимаемая удаляемым объектом так же будет удалена.
		 * @return		Вовзращает указатель на удаленный объект.
		 */
		public function remove(aBasic:AntBasic, aSplice:Boolean = false):AntBasic
		{
			var index:int = children.indexOf(aBasic);
			if (index < 0 || index >= children.length)
			{
				return aBasic;
			}
			
			children[index] = null;
			if (aSplice)
			{
				children.splice(index, 1);
				length--;
			}
			
			return aBasic;
		}
		
		/**
		 * Проверяет находится ли указанный объект в процессоре.
		 * 
		 * @param	aBasic	 Объект наличие которого необходимо проверить в процессоре.
		 * @return		Возвращает true если объект уже добавлен в процессор.
		 */
		public function contains(aBasic:AntBasic):Boolean
		{
			return (children.indexOf(aBasic) > -1) ? true : false;
		}
		
		/**
		 * Удаляет все объекты из процессора.
		 */
		public function clear():void
		{
			for (var i:int = 0; i < length; i++)
			{
				children[i] = null;
			}
		}
		
		/**
		 * Процессит все объекты в процессоре.
		 */
		public function update():void
		{
			var basic:AntBasic;
			for (var i:int = length; i >= 0; i--)
			{
				basic = children[i] as AntBasic;
				if (basic != null && basic.exists && basic.active)
				{
					basic.preUpdate();
					basic.update();
					basic.postUpdate();
				}
			}
		}
		
	}

}