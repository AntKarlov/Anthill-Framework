package ru.antkarlov.anthill
{
	/**
	 * Базовый класс для сущностей.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  26.08.2012
	 */
	public class AntBasic extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Любое пользовательское значение которое может идентифицировать объект.
		 * @default    -1
		 */
		public var tag:int;
		
		/**
		 * Указатель на любые пользовательские данные.
		 * @default    null
		 */
		public var userData:Object;
		
		/**
		 * Определеяет существование объекта.
		 * Если <code>exists=true</code>, то вызываются методы:
		 * <code>preUpdate()</code>, <code>update()</code>, <code>postUpdate()</code> и <code>draw()</code>.
		 * @default    true
		 */
		public var exists:Boolean;
		
		/**
		 * Определяет активность объекта.
		 * Если <code>active=false</code>, то не вызываются методы:
		 * <code>preUpdate()</code>, <code>update()</code>, <code>postUpdate()</code>.
		 * @default    true
		 */
		public var active:Boolean;
		
		/**
		 * Определяет видимость объекта.
		 * Если <code>visible=false</code>, то не вызывается метод:
		 * <code>draw()</code>.
		 * @default    true
		 */
		public var visible:Boolean;
		
		/**
		 * Определяет "живой" объект или нет.
		 * Если <code>alive=false</code>, значит для объекта был вызван метод <code>kill()</code>.
		 * Для воскрешения объекта следует вызывать метод <code>revive()</code>.
		 * @default    true
		 */
		public var alive:Boolean;
		
		/**
		 * Указатель на массив камер <code>AntG.cameras</code>.
		 */
		public var cameras:Array;
		
		/**
		 * Определяет следует ли для объекта выполнять отладочную отрисовку.
		 * @default    true
		 */
		public var allowDebugDraw:Boolean;
		
		/**
		 * Используется для автоматического подсчета активных объектов. 
		 * Доступ к значению осуществляется через <code>AntG.numOfActive</code>.
		 */
		static internal var NUM_OF_ACTIVE:int = 0;
		
		/**
		 * Используется для автоматического подсчета видимых объектов. 
		 * Доступ к значению осуществляется через <code>AntG.numOfVisible</code>.
		 */
		static internal var NUM_OF_VISIBLE:int = 0;
		
		/**
		 * Используется для автоматического подсчета количества объектов видимых камерами.
		 * Доступ к значению осуществляется через <code>AntG.numOnScreen</code>.
		 */
		static internal var NUM_ON_SCREEN:int = 0;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBasic()
		{
			super();
			
			tag = -1;
			userData = null;
			
			exists = true;
			active = true;
			visible = true;
			alive = true;
			allowDebugDraw = true;
		}
		
		/**
		 * Используется для уничтожения объекта и освобождения занимаемых им ресурсов. 
		 * Перекройте этот метод чтобы корректно освобождать используемые ресурсы при уничтожении объекта.
		 */
		public function destroy():void
		{
			//
		}
		
		/**
		 * Вызывается каждый кадр перед вызовом метода <code>update()</code>.
		 */
		public function preUpdate():void
		{
			NUM_OF_ACTIVE++;
		}
		
		/**
		 * Вызывается каждый кадр.
		 */
		public function update():void
		{
			//
		}
		
		/**
		 * Вызывается каждый кадр сразу после вызова метода <code>update()</code>;
		 */
		public function postUpdate():void
		{
			//
		}
		
		/**
		 * Вызывается каждый кадр после вызова метода <code>postUpdate()</code> для отрисовки объекта.
		 */
		public function draw(aCamera:AntCamera):void
		{
			//
		}
		
		/**
		 * Отладочная отрисовка.
		 * 
		 * @param	aCamera	 Указатель на камеру для которой выполняется отдалочная отрисовка.
		 */
		public function debugDraw(aCamera:AntCamera):void
		{
			//
		}
		
		/**
		 * Вызывается когда объект необходимо временно "убить" и освободить для повторного использования.
		 */
		public function kill():void
		{
			exists = false;
			alive = false;
		}
		
		/**
		 * Воскрешает объект после "убийства" для повторного использования.
		 */
		public function revive():void
		{
			exists = true;
			alive = true;
		}
		
	}

}