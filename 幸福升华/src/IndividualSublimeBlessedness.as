package {
	import caurina.transitions.Tweener;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
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
	 * 《幸福升华》
	 * @author 庆友互动传媒
	 */
	public class IndividualSublimeBlessedness extends Sprite {
		private var view:BasicView;
		private var uintItem:uint = 20; //物件数量
		private var currentPlane		:Plane;//用来暂存被点击的plane物件。
		private var uintRotatieFuc		:uint = 2;  //旋转多少圈
		private var numAngle			:Number = (Math.PI * 2 * uintRotatieFuc) / uintItem;//单元弧度
		private var filterGlow			:GlowFilter;//高光滤镜
		private var do3dCameraTarget	:DisplayObject3D;//Camera3D的目标物件。
		private var arrJpg:Array = new Array();
		private var arrWidth:Array = new Array();
		private var arrHeight:Array = new Array();
		private var spriteBackground:Sprite = new Sprite();
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;
		
		/**
		 * 图片控制总对象
		 */
		private var do3dPlaneCtrl:DisplayObject3D;
		
		/**
		 * 视图方式，手动/自动
		 */
		private var btnView:JButton;
		
		/**
		 * 视图方式切换开关，默认true，开
		 */
		private var autoRounding:Boolean = true;
		
		public function IndividualSublimeBlessedness():void {
			if (stage) main();
			else addEventListener(Event.ADDED_TO_STAGE, main);
		}
		
		private function main(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, main);
			
			this.stage.align = StageAlign.TOP_LEFT;	//左上对齐
			this.stage.scaleMode = StageScaleMode.NO_SCALE;	//演员不缩放
			
			var ceFuctextMenuUserDefined:ContextMenu = new ContextMenu();
			ceFuctextMenuUserDefined.hideBuiltInItems();	//隐藏原有右键菜单
			this.contextMenu = ceFuctextMenuUserDefined;
			
			for (var k:uint = 0; k < 40; k++){
				this.graphics.beginFill(0xffffff*Math.random(), Math.random()-0.3);
				this.graphics.drawCircle(Math.random() * 1500 - 100, Math.random() * 1200 - 50, Math.random() * 100 - 100);
				this.graphics.endFill();
			}
			
			spriteBackground.x = 0; spriteBackground.y = 0;
			spriteBackground.graphics.beginFill(0x000000, 0);
			spriteBackground.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			spriteBackground.graphics.endFill();
			this.addChild(spriteBackground);
			
			fucReturnJpg();
			
			view = new BasicView(0, 0, true, false, "Target");
			view.viewport.buttonMode = true;
			view.camera.y = 200;
			view.camera.z = -3500;
			this.addChild(view);
			
			filterGlow = new GlowFilter(0xeeeeee, 1, 16, 16, 3);//建构高光类别。
			
			var ypos:Number = -1600;//设定_ypos变数, 用来递减用。
			
			do3dPlaneCtrl = new DisplayObject3D();
			for (var i:uint = 0; i < uintItem; i++) {
				var bmpMat:BitmapMaterial = new BitmapMaterial(arrJpg[i], true);
				bmpMat.doubleSided = true;
				bmpMat.interactive = true;	//交互模式
				bmpMat.precisionMode = PrecisionMode.STABLE;
				
				var plane:Plane = new Plane( bmpMat, arrWidth[i], arrHeight[i], 10, 8);
				plane.name = "plane" + i;
				plane.useOwnContainer = true;//独立容器模式。
				
				plane.extra = new Object();
				plane.extra.id = i;//为每个plane物件指定一个唯一的变数值。
				
				Tweener.addTween(plane, {
					x:Math.cos(i * numAngle) * 1600,
					y:ypos,
					z:Math.sin(i * numAngle) * 1600,
					rotationY:( -i * numAngle) * (180 / Math.PI) + 270,
					alpha:1,
					delay:i * 0.02,
					time:2
				} );
				plane.moveBackward(5000);//plane物件以目前的轴心往后移5000
				plane.alpha = 0;//透明度为0
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, eFuc3DRelease);
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, eFuc3DOver);
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, eFuc3DOut);//侦听事件
				
				do3dPlaneCtrl.addChild(plane);
				
				ypos += 160;//y轴递增。
			}
			view.scene.addChild(do3dPlaneCtrl);//加入至scene物件。
			do3dCameraTarget = new DisplayObject3D();
			view.camera.target = do3dCameraTarget;//让camera的目标物件设定为cameraTargetObj3D,只要cameraTargetObj3D移动, camera就会自动转向该物件的座标方向
			
			var label:JButton = new JButton("庆友互动传媒-个人独立版情侣婚纱相册《幸福升华》");
			label.setFont(new ASFont("微软雅黑",12));	//字体
			label.setX(3); label.setY(3);	//位置
			label.setSizeWH(300, 30);	//尺寸
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
			
			btnView = new JButton("手动选看")
			btnView.setToolTipText("改变观看方式");
			btnView.setX(3);
			btnView.setY(this.stage.stageHeight - 30);
			btnView.setSizeWH(80, 30);
			btnView.setBackground(new ASColor(0x0066ff, 0.9));
			btnView.addEventListener(MouseEvent.CLICK, eFucViewBtnClick);
			this.addChild(btnView);
			
			this.stage.addEventListener(Event.RESIZE, eFucStageResize);
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
		}
		
		private function eFuc3DOver(e:InteractiveScene3DEvent):void {
			//滑入感应区时，增加高光滤镜。
			e.displayObject3D.scale = 1.1;
			e.displayObject3D.filters = [filterGlow];
		}
		private function eFuc3DOut(e:InteractiveScene3DEvent):void {
			//移除滤镜。
			e.displayObject3D.scale = 1;
			e.displayObject3D.filters = [];
		}
		
		private function eFuc3DRelease(e:InteractiveScene3DEvent):void {
			//点击plane物件时。
			currentPlane = e.displayObject3D as Plane;
			//将广播者物件指派到currentPlane变数里。
			
			var empty:DisplayObject3D = new DisplayObject3D();
			//建构一个空白的DisplayObject3D物件。
			empty.copyTransform(currentPlane);
			//复制座标属性。
			empty.moveBackward(700);
			//往后移动500。
			Tweener.addTween(do3dPlaneCtrl, {
				rotationY : 0,
				time:3
			});
			Tweener.addTween(view.camera, {
				//移动camera座标。
				x	: empty.x,
				y	: empty.y,
				z	: empty.z,
				time:3
			} );
			Tweener.addTween(do3dCameraTarget, {
				//移动camera的目标点。
				x	:currentPlane.x,
				y	:currentPlane.y,
				z	:currentPlane.z,
				time:3,
				onComplete:function ():void {
					currentPlane.material.smooth = true;	//平滑模式
					eFucTweenerComplete();
				}
			});
			
		}
		
		private function eFucTweenerComplete():void {
			spriteBackground.addEventListener(MouseEvent.CLICK, eFucBackGroundClick);
			//侦听场景上bg_mc物件的MouseEvent.CLICK事件。
		}
		
		private function eFucBackGroundClick(e:MouseEvent = null):void {
			currentPlane.material.smooth = false;
			
			//当场景上的bg_mc被点击时，
			//让Camera回到原本的位置。	
			Tweener.addTween(do3dCameraTarget, {
				//移动Camera目标点。
				x	:0,
				y	:0,
				z	:0,
				time:2
			});
			
			var empty:DisplayObject3D = new DisplayObject3D();			
			empty.copyTransform(currentPlane);
			empty.moveBackward(2000);
			//复制物件的座标。
			Tweener.addTween(view.camera, {
				//移动Camera座标。
				x	: empty.x,
				y	: 0,
				z	: empty.z,
				time:2
			} );
			spriteBackground.removeEventListener(MouseEvent.CLICK, eFucBackGroundClick);
			//取消侦听。
		}
		
		/**
		 * 改变视图方式，自动/手动
		 */
		private function eFucViewBtnClick(e:Event):void {
			if (autoRounding) {
				//停止旋转
				autoRounding = false;
				btnView.setText("自动环览");
				view.viewport.interactive = true;
				this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			}else {
				//自动旋转
				autoRounding = true;
				btnView.setText("手动选看");
				view.viewport.interactive = false;
				this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			}
		}
		
		private function eFucSceneRender(e:Event):void	{
			view.singleRender();
			
			if (autoRounding) {
				do3dPlaneCtrl.rotationY -= 0.4;
			}
		}
		
		/**
		 * 帮助信息
		 */
		private function eFucHelpBtnClick(e:Event):void {
			view.viewport.interactive = false;
			this.removeEventListener(Event.ENTER_FRAME, eFucSceneRender);
			
			AsWingManager.initAsStandard(this);	//初始化AsWing
			
			var strPicString:String = 
				"\n             庆友互动传媒\n" +
				"     庆友互动电子纪念相册\n\n" +
				"     个人独立版《幸福升华》\n\n\n" +
				"        滚动鼠标左键点击图片即可查看大图，点击背景返回视图。\n" +
				"        还可以切换“手动选看”和“自动环览”模式观看哦。\n\n\n\n" +
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
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
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
		
		private function eFucMouseWheel(e:MouseEvent):void {
			if (e.delta > 0) {
				view.camera.moveBackward(300);
			}else {
				view.camera.moveForward(300);
			}
		}
		
		private function eFucStageResize(e:Event):void {
			spriteBackground.graphics.clear();
			
			spriteBackground.graphics.beginFill(0x000000, 0);
			spriteBackground.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			spriteBackground.graphics.endFill();
			
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
			btnView.setY(this.stage.stageHeight - 30);
		}
		
	}
	
}