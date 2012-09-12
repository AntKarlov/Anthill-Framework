package ru.antkarlov.anthill
{
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	/**
	 * Обертка для работы с SharedObject для создания локальных игровых сохранений.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  23.08.2012
	 */
	public class AntCookie extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на данные в хранилище.
		 */
		public var data:Object;
		
		/**
		 * Имя хранилища.
		 */
		public var name:String;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на SharedObject.
		 */
		protected var _share:SharedObject;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntCookie()
		{
			super();
			
			name = null;
			_share = null;
			data = null;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Открывает хранилище с указанным именем для работы.
		 * Данный метод метод необходимо вызывать прежде чем считывать и записывать данные.
		 * 
		 * @param	aName	 Имя хранилища.
		 * @return		Возвращает true если хранилище открыто и готово к работе.
		 */
		public function open(aName:String):Boolean
		{
			name = null;
			_share = null;
			data = null;
			
			name = aName;
			
			try
			{
				_share = SharedObject.getLocal(name, "/");
			}
			catch (error:Error)
			{
				AntG.log("WARNING: Can`t connect to SharedObject with name \"" + name +"\".", "error");
				name = null;
				_share = null;
				data = null;
				return false;
			}
			
			data = _share.data;
			return true;
		}
		
		/**
		 * Записывает данные в хранилище.
		 * 
		 * @param	aKey	 Ключевое имя записываемых данных по которому их потом можно будет извлеч.
		 * @param	aValue	 Значение или какие либо данные которые необходимо сохранить в хранилище.
		 * @param	aMinFileSize	 Минимальный размер файла хранилища в байтах. Используется если необходимо 
		 * гарантированно получить необходимый объем дискового пространства для сохранения.
		 * @return		Возвращает true если данные успешно записаны в хранилище.
		 */
		public function write(aKey:String, aValue:Object, aMinFileSize:uint = 0):Boolean
		{
			if (_share == null)
			{
				AntG.log("WARNING: Can`t write data with key \"" + aKey + "\". AntCookie is not opened.");
				return false;
			}
			
			data[aKey] = aValue;
			return forceSave(aMinFileSize);
		}
		
		/**
		 * Считывает данные из хранилища.
		 * 
		 * @param	aKey	 Имя данных которые необходимо считать.
		 * @return		Возвращает null если данных с указанным именем не существует или если хранилище не доступно.
		 */
		public function read(aKey:String):Object
		{
			if (_share == null)
			{
				AntG.log("WARNING: Can`t read data with key \"" + aKey + "\". AntCookie is not opened.");
				return null;
			}
			
			return data[aKey];
		}
		
		/**
		 * Принудительное сохранение данных в хранилище.
		 * 
		 * @param	aMinFileSize	 Минимальный размер файла хранилища в байтах. Используется если необходимо 
		 * гарантированно получить необходимый объем дискового пространства для сохранения.
		 * @return		Возвращает true если сохранение прошло успешно.
		 */
		public function forceSave(aMinFileSize:uint = 0):Boolean
		{
			if (_share == null)
			{
				AntG.log("WARNING: Can`t save data to SharedObject. AntCookie is not opened.");
				return false;
			}
			
			var status:Object = null;
			try
			{
				status = _share.flush(aMinFileSize);
			}
			catch (error:Error)
			{
				AntG.log("WARNING: Can`t flush data to SharedObject.");
			}
			
			return status == SharedObjectFlushStatus.FLUSHED;
		}
		
		/**
		 * Очищает хранилище.
		 * 
		 * @param	aMinFileSize	 Минимальный размер файла хранилища в байтах. Используется если необходимо 
		 * гарантированно получить необходимый объем дискового пространства для сохранения.
		 * @return		Возвращает true если хранилище успешно очищено.
		 */
		public function clear(aMinFileSize:uint = 0):Boolean
		{
			if (_share == null)
			{
				AntG.log("WARNING: Can`t clear SharedObject. AntCookie is not opened.");
				return false;
			}
			
			for (var o:* in _share.data)
			{
				delete _share.data[o];
			}
			
			return forceSave(aMinFileSize);
		}
		
		/**
		 * Возвращает все содержимое хранилища в виде текстовой строки.
		 * Используется для просмотра содержимого хранилища в отладочных целях.
		 */
		public function toString():String
		{
			var arr:Array = [];
			for (var o:* in _share.data)
			{
				arr.push("{" + o + ": " + _share.data[o] + "}");
			}
			
			return "[AntCookie name: " + name + ", " + arr.joint(", ") + "]";
		}

	}

}