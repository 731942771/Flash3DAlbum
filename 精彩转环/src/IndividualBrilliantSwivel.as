package {
	import caurina.transitions.Tweener;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
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
	import org.papervision3d.core.culling.ViewportObjectFilter;
	import org.papervision3d.core.culling.ViewportObjectFilterMode;
	import org.papervision3d.core.effects.BitmapColorEffect;
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.effects.utils.BitmapClearMode;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.PrecisionMode;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	
	/**
	 * ***的婚纱纪念相册，个人独立版
	 * 《精彩转环》
	 * @author 庆友互动传媒
	 */
	public class IndividualBrilliantSwivel extends Sprite {
		/**
		 * 三维视图
		 */
		private var view:BasicView;
		
		/**
		 * 图片控制总对象
		 */
		private var do3dPlaneCtrl:DisplayObject3D;
		
		/**
		 * 被点击的图片拷贝
		 */
		private var do3dPlaneGhost:DisplayObject3D;
		
		/**
		 * 当前选择图片
		 */
		private var do3dCurrentPlane:DisplayObject3D;
		
		/**
		 * 当前索引值，初始为0
		 */
		private var numCurrentIndex:Number = 0;//目前的索引值
		
		/**
		 * 显示的图片目标总数,10
		 */
		private var numItem:int = 10;//物件数量
		
		/**
		 * 图片排列圈的半径,1600
		 */
		private var numRadius:Number = 1650;
		
		/**
		 * 图片旋转角度,36
		 */
		private var numAngle:Number = (Math.PI * 2) / numItem;	//角度=360/10
		
		/**
		 * 图片数组
		 */
		private var arrJpg:Array = new Array();
		
		/**
		 * 向右箭头
		 */
		private var btnRight:Arrow = new Arrow();
		
		/**
		 * 向左箭头
		 */
		private var btnLeft:Arrow = new Arrow();
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;
		
		/**
		 * 背景
		 */
		private var spriteBack:Sprite;
		
		/**
		 * 运动开关。防止首先点击箭头，点击图片后为true，点击箭头或背景后为false
		 */
		private var powerMove:Boolean = false;
		
		/**
		 * 视图方式，手动/自动
		 */
		private var btnView:JButton;
		
		/**
		 * 视图方式切换开关，默认true，开
		 */
		private var autoRounding:Boolean = true;
		
		public function IndividualBrilliantSwivel():void {
			if (stage) main();
			else addEventListener(Event.ADDED_TO_STAGE, main);
		}
		
		/**
		 * 主函数
		 */
		private function main(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, main);
			
			this.stage.align = StageAlign.TOP_LEFT;	//左上对齐
			this.stage.scaleMode = StageScaleMode.NO_SCALE;	//演员不缩放
			
			var contextMenuUserDefined:ContextMenu = new ContextMenu();
			contextMenuUserDefined.hideBuiltInItems();
			this.contextMenu = contextMenuUserDefined;
			
			for (var k:uint = 0; k < 30; k++){
				this.graphics.beginFill(0xffffff*Math.random(), Math.random()-0.3);
				this.graphics.drawCircle(Math.random() * 1500 - 100, Math.random() * 1200 - 50, Math.random() * 100 - 100);
				this.graphics.endFill();
			}
			
			spriteBack = new Sprite();
			spriteBack.graphics.beginFill(0x000000, 0);
			spriteBack.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			spriteBack.graphics.endFill();
			this.addChild(spriteBack);
			
			fucReturnJpg();
			
			view = new BasicView(0, 0, true, false, "Target");	
			view.camera.y = 500;
			view.camera.z = -2400;
			//view.viewport.interactive = false;
			view.viewport.buttonMode = true;
			this.addChild(view);
			
			do3dPlaneCtrl = new DisplayObject3D();
			
			for (var i:int = 0; i < numItem; i++) {
				var bmpMaterial:BitmapMaterial = new BitmapMaterial(arrJpg[i]);
				bmpMaterial.interactive = true; //互动模式
				bmpMaterial.doubleSided = true; //双面模式
				bmpMaterial.smooth = true; // 平滑模式
				bmpMaterial.precise = true;	//精准模式
				bmpMaterial.precisionMode = PrecisionMode.STABLE;
				
				var plane	:Plane = new Plane(bmpMaterial, 800, 600, 10, 8);
				var radian	:Number = i * numAngle - 5.98;
				plane.x = Math.cos(radian) * numRadius;
				plane.y = 300;
				plane.z = Math.sin(radian) * numRadius;
				
				plane.rotationX = 15;
				plane.rotationY = 270 - (radian * 180 / Math.PI) ;	//角度=弧度*180/π
				plane.useOwnContainer = true;
				plane.name = "plane" + i;
				plane.extra = { id:i };
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, eFucPressObject);
				
				do3dPlaneCtrl.addChild(plane);
			}
			
			view.scene.addChild(do3dPlaneCtrl);
			
			btnLeft.x = 30;
			btnLeft.y = stage.stageHeight / 2.5;
			btnLeft.rotationZ = 180;
			//btnLeft.addEventListener(MouseEvent.CLICK, eFucButtonClick);
			this.addChild(btnLeft);
			
			btnRight.x = stage.stageWidth - 30;
			btnRight.y = stage.stageHeight / 2.5;
			//btnRight.addEventListener(MouseEvent.CLICK, eFucButtonClick);
			this.addChild(btnRight);
			
			var label:JButton = new JButton("庆友互动相册,个人独立版《精彩转环》");
			label.setFont(new ASFont("微软雅黑",12));
			label.setX(3); label.setY(3);
			label.setSizeWH(300, 30);
			label.setBackground(new ASColor(0xff6600));
			label.setForeground(new ASColor(0xcccc66));
			this.addChild(label);
			
			btnHelp = new JButton("", new AssetIcon(new icoHi(), 30, 20, true));	//hi，帮助
			btnHelp.setToolTipText("这里是帮助信息哦");
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
			this.addEventListener(Event.ENTER_FRAME, eFucRenderScene);
		}
		
		/**
		 * 点击图片处理 226
		 */
		private function eFucPressObject(e:InteractiveScene3DEvent):void {
			if(! powerMove){
				do3dCurrentPlane = e.displayObject3D as DisplayObject3D;
				
				do3dPlaneGhost = new DisplayObject3D();
				do3dPlaneGhost.copyTransform(e.displayObject3D);	//它的属性都是相对于父对象do3dPlaneCtrl的
				
				fucScalePlane();
				
				Tweener.addTween(do3dPlaneCtrl, {
					rotationY   :(e.displayObject3D.extra.id - 7) * numAngle * 180 / Math.PI,
					time		:1
				});
				
				spriteBack.addEventListener(MouseEvent.CLICK, eFucMouseClickBackground);
			}
			powerMove = true;
		}
		
		/**
		 * 放大图片
		 */
		private function fucScalePlane():void {
			Tweener.addTween(do3dCurrentPlane, {
				y			:300,
				scale		:2,
				time		:1
			});
		}
		
		/**
		 * 点击背景
		 */
		private function eFucMouseClickBackground(e:MouseEvent = null):void {
			if(powerMove){
				Tweener.addTween(do3dCurrentPlane, {
					y			:do3dPlaneGhost.y,
					scale		:do3dPlaneGhost.scale,
					time		:1,
					onComplete : function():void {
						spriteBack.removeEventListener(MouseEvent.CLICK, eFucMouseClickBackground);
						powerMove = false;
					}
				});
			}
		}
		
		/**
		 * 箭头点击
		 */
		private function eFucButtonClick(e:Event):void {
			if(e.currentTarget == btnRight){
				numCurrentIndex --;
			}else{
				numCurrentIndex ++;
			}
			fucUpdateAngle();
		}
		
		/**
		 * 鼠标滚轮事件
		 */
		private function eFucMouseWheel(e:MouseEvent):void {
			if (e.delta >0) {
				numCurrentIndex++;
			}else {
				numCurrentIndex--;
			}
			
			fucUpdateAngle();
		}
		
		/**
		 * 更新角度
		 */
		private function fucUpdateAngle():void {
			eFucMouseClickBackground();
			
			Tweener.addTween(do3dPlaneCtrl, {
				rotationY   :numCurrentIndex * numAngle * 180 / Math.PI,
				time		:1.5
			} );
		}
		
		/**
		 * 帮助信息 319
		 */
		private function eFucHelpBtnClick(e:Event):void {
			view.viewport.interactive = false;
			btnLeft.removeEventListener(MouseEvent.CLICK, eFucButtonClick);
			btnRight.removeEventListener(MouseEvent.CLICK, eFucButtonClick);
			this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.removeEventListener(Event.ENTER_FRAME, eFucRenderScene);
			
			AsWingManager.initAsStandard( this);	//初始化AsWing
			
			var strPicString:String = 
				"\n             庆友互动传媒\n" +
				"     庆友互动电子纪念相册\n\n" +
				"     个人独立版《精彩转环》\n\n\n" +
				"        滚动鼠标中键改变图片位置。点击图片即可放大观看。\n" +
				"        还可以切换“手动选看”和“自动环览”模式。\n\n\n\n" +
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
		 * 隐藏帮助信息 365
		 */
		private function eFucMousedown(e:MouseEvent,w:JWindow):void {
			w.removeEventListener(MouseEvent.CLICK, eFucMousedown);	//不起作用，aswing...
			w.hide();
			
			view.viewport.interactive = true;
			
			btnLeft.addEventListener(MouseEvent.CLICK, eFucButtonClick);
			btnRight.addEventListener(MouseEvent.CLICK, eFucButtonClick);
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.addEventListener(Event.ENTER_FRAME, eFucRenderScene);
		}
		
		/**
		 * 改变视图方式，自动/手动 379
		 */
		private function eFucViewBtnClick(e:Event):void {
			if (autoRounding) {
				//停止旋转
				autoRounding = false;
				btnView.setText("自动环览");
				view.viewport.interactive = true;
				this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
				btnLeft.addEventListener(MouseEvent.CLICK, eFucButtonClick);
				btnRight.addEventListener(MouseEvent.CLICK, eFucButtonClick);
			}else {
				//自动旋转
				autoRounding = true;
				btnView.setText("手动选看");
				view.viewport.interactive = false;
				this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
				btnLeft.removeEventListener(MouseEvent.CLICK, eFucButtonClick);
				btnRight.removeEventListener(MouseEvent.CLICK, eFucButtonClick);
			}
		}
		
		/**
		 * 渲染场景 
		 */
		private function eFucRenderScene(e:Event):void {
			view.singleRender();
			
			if (autoRounding) {
				do3dPlaneCtrl.rotationY -= 0.4;
			}
		}
		
		/**
		 * 创建图片数组
		 */
		private function fucReturnJpg():void {
			var jpg0:Jpg23 = new Jpg23();
			arrJpg.push(jpg0);
			var jpg1:Jpg02 = new Jpg02();
			arrJpg.push(jpg1);
			var jpg2:Jpg24 = new Jpg24();
			arrJpg.push(jpg2);
			var jpg3:Jpg30 = new Jpg30();
			arrJpg.push(jpg3);
			var jpg4:Jpg05 = new Jpg05();
			arrJpg.push(jpg4);
			var jpg5:Jpg13 = new Jpg13();
			arrJpg.push(jpg5);
			var jpg6:Jpg07 = new Jpg07();
			arrJpg.push(jpg6);
			var jpg7:Jpg08 = new Jpg08();
			arrJpg.push(jpg7);
			var jpg8:Jpg28 = new Jpg28();
			arrJpg.push(jpg8);
			var jpg9:Jpg10 = new Jpg10();
			arrJpg.push(jpg9);
		}
		
		/**
		 * 屏幕改变
		 */
		private function eFucStageResize(e:Event):void {
			spriteBack.graphics.clear();
			spriteBack.graphics.beginFill(0x000000, 0);
			spriteBack.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			spriteBack.graphics.endFill();
			
			btnRight.x = stage.stageWidth - 30;
			
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
			btnView.setY(this.stage.stageHeight - 30);
		}
	}
}
