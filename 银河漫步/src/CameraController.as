package {
	import org.papervision3d.core.proto.CameraObject3D;
	
	/**
	 * 镜头控制类
	 * 调用主类的摄像机、用户角色
	 */
	public class CameraController {
		private var camera:CameraObject3D;
		private var player:Player;
		
		public function CameraController(camera3D:CameraObject3D, player3D:Player):void {
			camera = camera3D;
			player = player3D;
			
			main(); 
		}
		
		private function main():void {
			camera.z = -3500;
			camera.y = 400;
			camera.focus = 20;
			camera.far = 20000;
			camera.target = player; 
		}
		
		/**
		 * 控制摄像机
		 */
		public function fucUpdateCamera():void {
			var cameraZoom:Number;
			if (UserInputHandler.isMouseDown) { 
				cameraZoom = 100; 
			}
			else {
				cameraZoom = 40; 
			}
			camera.zoom -= (camera.zoom - cameraZoom) * 0.05;
			/*
			switch(UserInputHandler.camMode) {
				case "thirdPerson":
					camera.copyTransform(player);
					camera.moveBackward(400);
					camera.moveUp(100);
					player.visible = true; 
					break;
				case "firstPerson": */
					camera.copyTransform(player);
					camera.moveBackward(1);
					//player.visible = false; 
			//		break;
			//}
		}
	}
}