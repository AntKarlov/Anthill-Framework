package ru.antkarlov.anthill
{
	import flash.utils.Dictionary;
	
	/**
	 * Хранилище позволяет хранить любые данные под понятными для нас 
	 * текстовыми именами. Пример добавления и извлечения данных:
	 * <code>var o:SomeObject = new SomeObject();
	 * collection.set("someObject", o);
	 * 
	 * var o:SomeObject;
	 * o = collection.get("someObject") as SomeObject;
	 * </code>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  19.09.2011
	 */
	public dynamic class AntStorage extends Dictionary
	{
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntStorage(useWeakReference:Boolean = true)
		{
			super(useWeakReference);
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет данные в хранилище.
		 * 
		 * @param	aKey	 Ключевое имя данных.
		 * @param	aValue	 Какие-либо данные.
		 */
		public function set(aKey:String, aValue:*):void
		{
			this[aKey] = aValue;
		}
		
		/**
		 * Извлекает данные из хранилища.
		 * 
		 * @param	aKey	 Ключевое имя данных которые необходимо извлечь.
		 * @return		Возвращает какие-либо данные соотвествующие указанному ключу. Если данных нет, вернет null.
		 */
		public function get(aKey:String):*
		{
			return this[aKey];
		}
		
		/**
		 * Возвращает ключ соотвествущий указанным данным.
		 * 
		 * @param	value	 Данные для которых необходимо получить ключ.
		 * @return		Возвращает null если указанных данных нет в хранилище.
		 */
		public function getKey(aValue:*):String
		{
			for (var prop:String in this)
			{
				if (this[prop] == aValue)
				{
					return prop;
				}
			}
			return null;
		}
		
		/**
		 * Удаляет данные из хранилища по ключу.
		 * 
		 * @param	aKey	 Ключ данных которые необходимо удалить.
		 * @return		Возвращает указатель на удаленные данные.
		 */
		public function remove(aKey:String):*
		{
			var data:* = this[aKey];
			this[aKey] = null;
			return data;
		}
		
		/**
		 * Определяет содержит ли хранилище данные с указанным ключом.
		 * 
		 * @param	aKey	 Ключ для данных существование которых надо проверить.
		 * @return		Возвращает true если данные с указанным ключом существуют.
		 */
		public function containsKey(aKey:String):Boolean
		{
			return this[aKey] != null;
		}
	
		/**
		 * Определяет содержит ли хранилище указанные данные.
		 * 
		 * @param	aValue	 Данные наличие которых необходимо проверить.
		 * @return		Возвращает true если указанные данные имеются в хранилище.
		 */
		public function contains(aValue:*):Boolean
		{
			for (var prop:String in this)
			{
				if (this[prop] == aValue)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Очищает хранилище.
		 */
		public function clear():void
		{
			for (var prop:String in this)
			{
				this[prop] = null;
				delete this[prop];
			}
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает количество данных имеющихся в хранилище.
		 */
		public function get length():int
		{
			var len:int = 0;
			for (var prop:String in this)
			{
				if (this[prop] != null)
				{
					len++;
				}
			}
			
			return len;
		}
		
		/**
		 * Вернет true если хранилище пустое.
		 */
		public function get isEmpty():Boolean
		{
			return (this.length <= 0);
		}
		
	}

}