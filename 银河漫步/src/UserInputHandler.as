package {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * 操作控制类
	 * 调用主类的舞台
	 */
	public class UserInputHandler {
		/**
		 * D键按下
		 */
		public static var isRightKeyDown:Boolean;
		
		/**
		 * A键按下
		 */
		public static var isLeftKeyDown:Boolean;
		
		/**
		 * W键按下
		 */
		public static var isForwardKeyDown:Boolean;
		
		/**
		 * S键按下
		 */
		public static var isBackwardKeyDown:Boolean;
		
		/**
		 * 鼠标按下
		 */
		public static var isMouseDown:Boolean;
		
		/**
		 * 摄像机模式
		 * 1：第三视觉，2：第一视觉
		 */
		public static var camMode:String = "thirdPerson";
		
		/**
		 * ？...
		 */
		public static var randomCamActive:Boolean;
		
		/**
		 * Q键按下
		 */
		public static var isRiseKeyDown:Boolean;
		
		/**
		 * E键按下
		 */
		public static var isDescentKeyDown:Boolean;
		
		//调用主类的舞台
		public function UserInputHandler(stage:Stage):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, eFucKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, eFucKeyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,eFucMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,eFucMouseUp);
		}
		
		public function eFucKeyDown(e:KeyboardEvent):void {
			switch(e.keyCode) {
				//如果按下的是W键
				case "W".charCodeAt(): 
					//关联小键盘区的向上键
					case Keyboard.UP: 
						UserInputHandler.isForwardKeyDown = true;	//前进开启
						UserInputHandler.isBackwardKeyDown = false; 	//后退关闭
						break;
				case "S".charCodeAt():
					case Keyboard.DOWN:
						UserInputHandler.isBackwardKeyDown = true;
						UserInputHandler.isForwardKeyDown = false;
						break;
				case "A".charCodeAt(): 
					case Keyboard.LEFT: 
						UserInputHandler.isLeftKeyDown = true;
						UserInputHandler.isRightKeyDown = false; 
						break;
				case "D".charCodeAt(): 
					case Keyboard.RIGHT: 
						UserInputHandler.isRightKeyDown = true;
						UserInputHandler.isLeftKeyDown = false; 
						break;
				case "Q".charCodeAt():
					UserInputHandler.isRiseKeyDown = true;
					UserInputHandler.isDescentKeyDown = false; 
					break;
				case "E".charCodeAt():
					UserInputHandler.isRiseKeyDown = false;
					UserInputHandler.isDescentKeyDown = true; 
					break;/*
				case "1".charCodeAt(): 
					camMode = "thirdPerson"; 
					break;
				case "2".charCodeAt():
					camMode = "firstPerson"; 
					break;*/
			}
		}
		
		public function eFucKeyUp(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case "W".charCodeAt(): 
					case Keyboard.UP: 
						UserInputHandler.isForwardKeyDown = false;
						break;
				case "S".charCodeAt(): 
					case Keyboard.DOWN: 
						UserInputHandler.isBackwardKeyDown = false; 
						break;
				case "A".charCodeAt():
					case Keyboard.LEFT: 
						UserInputHandler.isLeftKeyDown = false;
						break;
				case "D".charCodeAt(): 
					case Keyboard.RIGHT: 
						UserInputHandler.isRightKeyDown = false; 
						break;
				case "Q".charCodeAt():
					UserInputHandler.isRiseKeyDown = false;
					break;
				case "E".charCodeAt(): 
					UserInputHandler.isDescentKeyDown = false; 
					break;
			}
		}
		
		private function eFucMouseDown (e:MouseEvent):void {
			isMouseDown = true; 
		}
		
		private function eFucMouseUp (e:MouseEvent):void {
			isMouseDown = false; 
		}
	}
}