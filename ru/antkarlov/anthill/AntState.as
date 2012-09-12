package ru.antkarlov.anthill
{
	import flash.display.Sprite;
	
	/**
	 * Базовый класс для игровых состояний. Все игровые состояния будь то игровое меню или
	 * игровой процесс - следует наследовать от этого класса.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  30.08.2012
	 */
	public class AntState extends Sprite
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Основная группа объектов для текущего состояния.
		 */
		public var defGang:AntEntity;
		
		/**
		 * Указатель на метод <code>defGang.add()</code>.
		 */
		public var add:Function;
		
		/**
		 * Указатель на метод <code>defGang.remove()</code>.
		 */
		public var remove:Function;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntState()
		{
			super();
			defGang = new AntEntity();
			add = defGang.add;
			remove = defGang.remove;
		}
		
		/**
		 * Инициализация состояния. Вызывается автоматически после создания и добавления 
		 * в структуру игрового движка.
		 */
		public function create():void
		{
			// ...
		}
		
		/**
		 * Уничтожение остояния. Вызывается автоматически перед удалением состояния из 
		 * структуры игрового движка.
		 */
		public function dispose():void
		{
			defGang.dispose();
		}
		
		/**
		 * Вызывается каждый кадр перед вызовом метода <code>update()</code>.
		 */
		public function preUpdate():void
		{
			// ...
		}
		
		/**
		 * Вызывается каждый кадр.
		 */
		public function update():void
		{
			defGang.preUpdate();
			defGang.update();
			defGang.postUpdate();
		}
		
		/**
		 * Вызывается каждый кадр сразу после вызова метода <code>update()</code>.
		 */
		public function postUpdate():void
		{
			// ...
		}
		
		/**
		 * Вызывается каждый кадр после метода <code>postUpdate()</code> для отрисовки визуальных объектов.
		 */
		public function draw():void
		{
			defGang.draw();
		}

	}

}