package {
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.PaperPlane;
	import org.papervision3d.lights.PointLight3D;
	
	/**
	 * 角色控制类，继承自DisplayObject3D
	 * 前进，后退，上升，转弯...
	 */
	public class Player extends DisplayObject3D {
		//private var paperPlane:PaperPlane;	//飞机
		private var topSpeed:Number = 0;	//前进初始速度
		private var speed:Number = 0;	//前进速度
		private var topSteer:Number = 0;	//转弯初始速度
		private var steer:Number = 0;	//转弯速度
		private var topRise:Number = 0;	//升高初始速度
		private var rise:Number = 0;	//升高速度
		
		public function Player() {
			main();
		} 
		
		private function main():void {
			z= -1000;	//当前类Player的z属性
			//y = 300;
			/*
			var light:PointLight3D = new PointLight3D();	//点光源
			var paperPlaneMat:FlatShadeMaterial = new FlatShadeMaterial(light,0xddbbdd,0xffff77);
			paperPlaneMat.doubleSided = true;
			paperPlane = new PaperPlane(paperPlaneMat);
			
			addChild(paperPlane);*/
		}
		
		/**
		 * 控制飞机运动
		 */
		public function fucUpdatePlayer():void {
			if (UserInputHandler.isForwardKeyDown) { 
				topSpeed = 50; 
			}
			else if(UserInputHandler.isBackwardKeyDown) {
				topSpeed = -30;
			}
			else { 
				topSpeed = 0; 
			}
			speed -= (speed - topSpeed) * 0.1;
			moveForward(speed);
			//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if(UserInputHandler.isRiseKeyDown) {
				topRise = 50;
			}
			else if(UserInputHandler.isDescentKeyDown) {
				topRise = -30;
			}
			else {
				topRise = 0; 
			}
			rise -= (rise - topRise) * 0.1;
			moveUp(rise);
			//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if(UserInputHandler.isRightKeyDown) {	//D按下或右箭头按下
				if(topSteer < 10) {
					topSteer = 10;
				}
			}
			else if(UserInputHandler.isLeftKeyDown) {	//A按下或左箭头按下
				if(topSteer > -10) {
					topSteer = -10;
				}
			}
			else {
				topSteer -= topSteer * 0.1; 
			}
			steer -= (steer - topSteer) * 0.1;
			
			yaw(speed * steer * 0.002);
			//paperPlane.localRotationZ = steer;
		}
	}
}