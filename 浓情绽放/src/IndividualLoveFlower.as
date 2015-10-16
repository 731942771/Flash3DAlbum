package {
	import caurina.transitions.Tweener;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import org.aswing.ASColor;
	import org.aswing.ASFont;
	import org.aswing.AssetIcon;
	import org.aswing.AsWingManager;
	import org.aswing.border.CaveBorder;
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JPanel;
	import org.aswing.JTextArea;
	import org.aswing.JWindow;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.PrecisionMode;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	
	/**
	 * ***的婚纱纪念相册，个人独立版
	 * 《浓情绽放》
	 * @author 庆友互动传媒
	 */
	public class IndividualLoveFlower extends Sprite {
		private var view:BasicView;
		private var arrJpg:Array = new Array();
		private var arrWidth:Array = new Array();
		private var arrHeight:Array = new Array();
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;
		
		/**
		 * 当前独显的图片
		 */
		private var uintCurr:uint = 99;
		
		public function IndividualLoveFlower():void {
			if (stage) main();
			else addEventListener(Event.ADDED_TO_STAGE, main);
		}
		
		private function main(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, main);
			
			this.stage.align = StageAlign.TOP_LEFT;	//左上对齐
			this.stage.scaleMode = StageScaleMode.NO_SCALE;	//演员不缩放
			
			var contextMenuUserDefined:ContextMenu = new ContextMenu();
			contextMenuUserDefined.hideBuiltInItems();	//隐藏原有右键菜单
			this.contextMenu = contextMenuUserDefined;
			
			for (var k:uint = 0; k < 40; k++){
				this.graphics.beginFill(0xffffff*Math.random(), Math.random()-0.3);
				this.graphics.drawCircle(Math.random() * 1500 - 100, Math.random() * 1200 - 50, Math.random() * 100 - 100);
				this.graphics.endFill();
			}
			
			fucReturnJpg();
			
			view = new BasicView(0, 0, true, true, "Free");
			view.viewport.buttonMode = true;
			view.camera.z = -3000;
			this.addChild(view);
			
			for (var i:int = 0 ; i < 10; i++) {//使用回圈建立30个Plane物件。
				var refMat:BitmapMaterial = new BitmapMaterial(arrJpg[i], true);
				refMat.doubleSided = true;
				refMat.interactive = true;	//交互模式
				refMat.precisionMode = PrecisionMode.STABLE;
				
				var plane:Plane  = new Plane( refMat, arrWidth[i], arrHeight[i], 10, 8);
				plane.name = String(i);
				
				//使用Tweener移动Plane物件到指定的座标。
				Tweener.addTween(plane, {
					x : Math.random() * 3000 - 1500 ,
					y : Math.random() * 3000 - 1500 ,
					z : Math.random() * 3000 - 1500 ,
					/*在这儿我们希望x的范围是   -500到500的乱数值
					 * Math.random()会回传0到1的乱数浮点数，乘上radius变数，
					 * 即可得到0到1000的乱数，再减去500，即可达到我们要的范围。
					 **/
					rotationX : Math.random() * 360,
					rotationY : Math.random() * 360,
					rotationZ : Math.random() * 360,
					/*
					 * 乱数旋转方向。
					 * */
					time : 3,
					transition : "easeOutExpo",
					delay : i * 0.02
				} );
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, eFucObjectPress); //侦听Plane物件所广播的InteractiveScene3DEvent.OBJECT_PRESS事件。
				view.scene.addChild(plane);
			}
			
			var label:JButton = new JButton("对爱充满理想-期待《浓情绽放》");
			label.setFont(new ASFont("微软雅黑",12));	//字体
			label.setX(3); label.setY(3);	//位置
			label.setSizeWH(200, 30);	//尺寸
			label.setBackground(new ASColor(0xff6600));
			label.setForeground(new ASColor(0xcccc66));
			this.addChild(label);	//加入Sprite
			
			btnHelp = new JButton("", new AssetIcon(new icoHi(), 30, 20, true));	//hi，帮助
			btnHelp.setToolTipText("这里是帮助信息哦");
			btnHelp.setFont(new ASFont("微软雅黑"));
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
			btnHelp.setSizeWH(30, 30);
			btnHelp.setBackground(new ASColor(0xff6600, 0.9));
			btnHelp.addEventListener(MouseEvent.CLICK, eFucHelpBtnClick);
			this.addChild(btnHelp);
			
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.stage.addEventListener(Event.RESIZE, eFucStageResize);
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
		}
		
		/**
		 * 点击图片
		 */
		private function eFucObjectPress(e:InteractiveScene3DEvent):void {
			if (uint(e.displayObject3D.name) != uintCurr) {
				if(uintCurr!=99){
					view.scene.getChildByName(String(uintCurr)).material.smooth = false;
				}
				uintCurr = uint(e.displayObject3D.name);
				
				var emptyObj3D:DisplayObject3D = new DisplayObject3D();
				emptyObj3D.copyTransform( e.displayObject3D );
				emptyObj3D.moveBackward( 500 );
				
				Tweener.addTween( view.camera, {
					x :emptyObj3D.x,
					y :emptyObj3D.y,
					z :emptyObj3D.z,
					rotationX :emptyObj3D.rotationX,
					rotationY :emptyObj3D.rotationY,
					rotationZ :emptyObj3D.rotationZ,
					time :3,
					transition :"easeOutExpo",
					onComplete:function():void {
						e.displayObject3D.material.smooth = true;	//平滑模式
					}
				} );
			}
		}
		
		/**
		 * 渲染场景
		 */
		private function eFucSceneRender(e:Event):void{
			view.singleRender();
		}
		
		/**
		 * 帮助信息
		 */
		private function eFucHelpBtnClick(e:Event):void {
			view.viewport.interactive = false;
			this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.removeEventListener(Event.ENTER_FRAME, eFucSceneRender);
			
			AsWingManager.initAsStandard(this);	//初始化AsWing
			
			var strPicString:String = 
				"\n             庆友互动传媒\n" +
				"     庆友互动电子纪念相册\n\n" +
				"     个人独立版《浓情绽放》\n\n\n" +
				"        滚动鼠标中键改变镜头距离。点击图片即可查看大图\n\n\n\n" +
				"           Code：崔维友\n" +
				"         QQ：811370002\n" +
				"       Tel：18253395109\n"+
				"   Email：vigiles@163.com\n\n"+
				"        庆友互动，娱乐出众\n\n" +
				"      (请点击此提示以关闭)";
			var textareaCtrlPicMessageAlter:JTextArea = new JTextArea();
			textareaCtrlPicMessageAlter.setWordWrap(true);
			textareaCtrlPicMessageAlter.setEditable(false);
			textareaCtrlPicMessageAlter.setText(strPicString);
			
			var panelCtrlPicMessage:JPanel = new JPanel();
			panelCtrlPicMessage.setLayout(new BorderLayout());
			panelCtrlPicMessage.setOpaque(true);
			panelCtrlPicMessage.setBackground(new ASColor(0xffffff));
			panelCtrlPicMessage.append(textareaCtrlPicMessageAlter);
			
			var windowCtrlPicMessageAlter:JWindow = new JWindow();
			windowCtrlPicMessageAlter.setX(this.stage.stageWidth / 2.5);
			windowCtrlPicMessageAlter.setY(this.stage.stageHeight / 4.5);
			windowCtrlPicMessageAlter.setSizeWH(170, 340);
			windowCtrlPicMessageAlter.setBorder(new CaveBorder(null, 5));
			windowCtrlPicMessageAlter.getContentPane().append(panelCtrlPicMessage);
			windowCtrlPicMessageAlter.addEventListener(MouseEvent.CLICK, function(ev:MouseEvent):void {
				eFucMousedown(ev,windowCtrlPicMessageAlter);
			});
			windowCtrlPicMessageAlter.show();
		}
		
		/**
		 * 隐藏帮助信息
		 */
		private function eFucMousedown(e:MouseEvent,w:JWindow):void {
			w.removeEventListener(MouseEvent.CLICK, eFucMousedown);	//不起作用，aswing...
			w.hide();
			
			view.viewport.interactive = true;
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
		}
		
		/**
		 * 滚轮转动
		 */
		private function eFucMouseWheel(e:MouseEvent):void {
			view.camera.moveBackward(e.delta*20);
		}
		
		/**
		 * 屏幕大小改变时，更新帮助按钮的位置
		 */
		private function eFucStageResize(e:Event):void {
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
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
			var jpg0:Jpg10 = new Jpg10();
			arrJpg.push(jpg0);
			arrWidth.push(jpg0.width);
			arrHeight.push(jpg0.height);
		}
	}
}