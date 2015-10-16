package {
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.PrecisionMode;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * 创建星系，继承自DisplayObject3D
	 * 星星：照片、恒星：中心球体
	 */
	public class Galaxy extends DisplayObject3D {
		private var earthSphere:Sphere;
		private var arrJpg:Array = new Array();
		private var arrWidth:Array = new Array();
		private var arrHeight:Array = new Array();
		
		public function Galaxy() {
			main();
		}
		
		private function main():void {
			fucReturnJpg();
			
			var material:BitmapMaterial = new BitmapMaterial(new Pinjie(), true);
			material.smooth = true;
			earthSphere = new Sphere(material, 400, 24, 16);
			addChild(earthSphere);
			
			for (var i:uint = 0; i < 20; i++) {
				var bmpMat:BitmapMaterial = new BitmapMaterial(arrJpg[i]);
				bmpMat.doubleSided = true;
				bmpMat.interactive = true;	//交互模式
				bmpMat.smooth = true;	//平滑模式
				bmpMat.precise = true;	//精准模式
				bmpMat.precisionMode = PrecisionMode.STABLE;
				
				var plane:Plane = new Plane( bmpMat, arrWidth[i], arrHeight[i], 10, 8);
				addChild(plane);
				plane.x = Math.random()*20000 - 10000;
				plane.y = Math.random()*1500 - 750;
				plane.z = Math.random()*20000 -10000;
				plane.localRotationY = Math.random() * 180 - 90;
			}
		}
		
		/**
		 * 旋转恒星
		 */
		public function fucUpdateGalaxy():void {
			earthSphere.localRotationY += 0.3;
		}
		
		private function fucReturnJpg():void {
			var jpg1:Jpg01 = new Jpg01();
			arrJpg.push(jpg1);
			arrWidth.push(jpg1.width);
			arrHeight.push(jpg1.height);
			var jpg2:Jpg02 = new Jpg02();
			arrJpg.push(jpg2);
			arrWidth.push(jpg2.width);
			arrHeight.push(jpg2.height);
			var jpg3:Jpg03 = new Jpg03();
			arrJpg.push(jpg3);
			arrWidth.push(jpg3.width);
			arrHeight.push(jpg3.height);
			var jpg4:Jpg04 = new Jpg04();
			arrJpg.push(jpg4);
			arrWidth.push(jpg4.width);
			arrHeight.push(jpg4.height);
			var jpg5:Jpg05 = new Jpg05();
			arrJpg.push(jpg5);
			arrWidth.push(jpg5.width);
			arrHeight.push(jpg5.height);
			var jpg6:Jpg06 = new Jpg06();
			arrJpg.push(jpg6);
			arrWidth.push(jpg6.width);
			arrHeight.push(jpg6.height);
			var jpg7:Jpg07 = new Jpg07();
			arrJpg.push(jpg7);
			arrWidth.push(jpg7.width);
			arrHeight.push(jpg7.height);
			var jpg8:Jpg08 = new Jpg08();
			arrJpg.push(jpg8);
			arrWidth.push(jpg8.width);
			arrHeight.push(jpg8.height);
			var jpg9:Jpg09 = new Jpg09();
			arrJpg.push(jpg9);
			arrWidth.push(jpg9.width);
			arrHeight.push(jpg9.height);
			var jpg10:Jpg10 = new Jpg10();
			arrJpg.push(jpg10);
			arrWidth.push(jpg10.width);
			arrHeight.push(jpg10.height);
			var jpg11:Jpg11 = new Jpg11();
			arrJpg.push(jpg11);
			arrWidth.push(jpg11.width);
			arrHeight.push(jpg1.height);
			var jpg12:Jpg12 = new Jpg12();
			arrJpg.push(jpg12);
			arrWidth.push(jpg12.width);
			arrHeight.push(jpg12.height);
			var jpg13:Jpg13 = new Jpg13();
			arrJpg.push(jpg13);
			arrWidth.push(jpg13.width);
			arrHeight.push(jpg13.height);
			var jpg14:Jpg14 = new Jpg14();
			arrJpg.push(jpg14);
			arrWidth.push(jpg14.width);
			arrHeight.push(jpg14.height);
			var jpg15:Jpg15 = new Jpg15();
			arrJpg.push(jpg15);
			arrWidth.push(jpg15.width);
			arrHeight.push(jpg15.height);
			var jpg16:Jpg16 = new Jpg16();
			arrJpg.push(jpg16);
			arrWidth.push(jpg16.width);
			arrHeight.push(jpg16.height);
			var jpg17:Jpg17 = new Jpg17();
			arrJpg.push(jpg17);
			arrWidth.push(jpg17.width);
			arrHeight.push(jpg17.height);
			var jpg18:Jpg18 = new Jpg18();
			arrJpg.push(jpg18);
			arrWidth.push(jpg18.width);
			arrHeight.push(jpg18.height);
			var jpg19:Jpg19 = new Jpg19();
			arrJpg.push(jpg19);
			arrWidth.push(jpg19.width);
			arrHeight.push(jpg19.height);
			var jpg20:Jpg20 = new Jpg20();
			arrJpg.push(jpg20);
			arrWidth.push(jpg20.width);
			arrHeight.push(jpg20.height);
		}
	}
}