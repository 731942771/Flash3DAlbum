package{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.ui.ContextMenu;
	import org.aswing.ASColor;
	import org.aswing.ASFont;
	import org.aswing.AssetIcon;
	import org.aswing.AsWingManager;
	import org.aswing.border.CaveBorder;
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JPanel;
	import org.aswing.JTextArea;
	import org.aswing.JWindow;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import caurina.transitions.Tweener;
	
	/**
	 * ***的婚纱纪念相册，个人独立版
	 * 《浪漫追逐》
	 * @author 庆友互动传媒
	 */
	public class IndividualRomanticAngle extends Sprite {
		private var view:BasicView;
		
		/**
		 * plane组成的虚拟的环形半径
		 */
		private var numRadius:Number = 1200;
		
		/**
		 * 图片总数
		 */
		private var numItem:Number = 10;
		
		/**
		 * 角度
		 */
		private var numAngle:Number = Math.PI * 2 / numItem;
		
		/**
		 * 目前的索引值
		 */
		private var uintCurrentIndex:uint = 1;
		
		/**
		 * 目前的物件
		 */
		private var objCurrent:DisplayObject3D = null;
		
		/**
		 * 是否小图示被点击
		 */
		private var powerThumb:Boolean = false;
		
		/**
		 * 目前的镜头角度
		 * EnterFrame 事件会一直抓取此角度值, 以计算 Camera 的座标,当要使用 Tweener 来修改该值时, 需设定成 public 变数
		 */
		public var numCameraAngle:Number = numAngle;
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;
		
		/**
		 * 视图方式，手动/自动
		 */
		private var btnView:JButton;
		
		/**
		 * 视图方式切换开关，默认true，开
		 */
		private var autoRounding:Boolean = true;
		
		/**
		 * 所有的图片总控制
		 */
		private var do3dPlaneCtrl:DisplayObject3D;
		
		private var arrJpg:Array = new Array();
		
		public function IndividualRomanticAngle() {
			main();
		}
		
		private function main():void {
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
			
			view = new BasicView(0, 0, true, false, "Target");
			view.viewport.buttonMode = true;
			view.camera.x = 10
			view.camera.y = 500;
			view.camera.z = 0;
			this.addChild(view);
			
			Tweener.addTween(view.camera, {
				x			: Math.cos(numCameraAngle) * 2000,
				y			: 600,
				z			: Math.sin(numCameraAngle) * 2000,
				rotationX 	: 0,
				rotationY 	: 0,
				rotationZ 	: 0,
				time		: 1.5,
				onComplete	: function():void {
					powerThumb = true;
				}
			});
			
			do3dPlaneCtrl = new DisplayObject3D();
			
			for (var i:int = 0 ; i < numItem; i++ ) {
				var refMat:BitmapMaterial = new BitmapMaterial(arrJpg[i], true);
				refMat.doubleSided = true;
				refMat.interactive = true;	//交互模式
				
				var plane:Plane  = new Plane( refMat, 900, 600, 8, 8);
				
				var radianor:Number =  i * numAngle; //弧度
				
				plane.name = "item" + i;
				plane.x = Math.cos(radianor) * numRadius;
				plane.y = 90;
				plane.z = Math.sin(radianor) * numRadius;
				plane.rotationX = 0;
				plane.rotationY = 0 - radianor * (180 / Math.PI);
				plane.rotationZ = 0;
				plane.extra = {
					id			: i,
					x			: Math.cos(radianor) * numRadius,	
					y			: 0,
					z			: Math.sin(radianor) * numRadius,
					rotationX 	: 0,
					rotationY 	: 0 - radianor *  (180 / Math.PI),
					rotationZ	: 0
				};
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, eFucObjectClick);
				
				do3dPlaneCtrl.addChild(plane);
				//view.scene.addChild(plane);
			}
			view.scene.addChild(do3dPlaneCtrl);
			
			var label:JButton = new JButton("庆友情侣婚纱相册-个人独立版-《浪漫追逐》");
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
			}else {
				//自动旋转
				autoRounding = true;
				btnView.setText("手动选看");
				view.viewport.interactive = false;
				this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			}
		}
		
		/**
		 * 渲染场景
		 */
		private function eFucSceneRender(e:Event):void {
			if (powerThumb) {
				view.camera.x = Math.cos(numCameraAngle) * 2000;
				view.camera.z = Math.sin(numCameraAngle) * 2000;
			}
			
			if (autoRounding) {
				do3dPlaneCtrl.rotationY -= 0.4;
			}
			
			view.singleRender();
		}
		
		/**
		 * 滚轮转动
		 */
		private function eFucMouseWheel(e:MouseEvent):void {
			if (e.delta > 0) {
				fucMoveRight();
			}else {
				fucMoveLeft();
			}
		}
		
		/**
		 * 滚轮向内转动
		 */
		private function fucMoveRight(e:MouseEvent = null):void {
			uintCurrentIndex++; //目前索引值加一
			
			fucUpdataCameraAngle(); //更新Camera座标
		}
		
		/**
		 * 滚轮向外转动
		 */
		private function fucMoveLeft(e:MouseEvent = null):void{
			uintCurrentIndex--; //目前索引值减一
			
			fucUpdataCameraAngle(); //更新Camera座标
		}
		
		/**
		 * 更新目前的镜头角度，索引*平均角度
		 */
		private function fucUpdataCameraAngle():void {			
			Tweener.addTween(this, { 
				numCameraAngle:uintCurrentIndex * numAngle, 
				time:0.5 
			});
		}
		
		/**
		 * 点击图片
		 */
		private function eFucObjectClick(e:InteractiveScene3DEvent):void{
			if(!Tweener.isTweening(objCurrent) && !Tweener.isTweening(view.camera)){
				stage.removeEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);//取消侦听滚轮事件
				stage.quality = StageQuality.LOW;//将品质设成低
				
				//将目前的广播者记录在objCurrent变量里
				objCurrent = e.displayObject3D;
				
				//使用Tweener移动目前的Plane物件
				Tweener.addTween(objCurrent, {
					x 			: 0,
					y			: 800,
					z			: 0,
					rotationX 	: -90,
					rotationY 	: 360 + do3dPlaneCtrl.rotationY,
					rotationZ 	: 180,
					time		: 1,
					delay		: 0.5,
					onComplete:function():void {
						objCurrent.material.smooth = true;	//平滑模式
					}
				});
				
				//把目前Camera的座标记录下来
				view.camera.extra = {
					x		:view.camera.x,
					y		:view.camera.y,
					z		:view.camera.z
				};
				powerThumb = false; //将isThumbClick设成false，这样eFucSceneRender就不会运算Camera座标，避免和Tweener产生冲突
				
				//移动Camera的座标
				Tweener.addTween(view.camera, {
					x			:0,
					y			:1200,
					z			:1,
					time		:1.6,
					
					//Tweener完成时会执行该function一次
					onComplete	:function() :void {
						view.viewport.interactive = false;
						btnView.setEnabled(false);
						
						stage.quality = StageQuality.HIGH; //将品质设成高
						stage.addEventListener(MouseEvent.MOUSE_DOWN, eFucStageClick); //侦听 MouseEvent.MOUSE_DOWN (按下滑鼠钮) 事件
					}
				});
			}
		}
		
		/**
		 * 点击背景，复位摄像机和目前独显的图片
		 */
		private function eFucStageClick(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, eFucStageClick); //取消侦听stage的点车事件
			
			if(!Tweener.isTweening(view.camera) && !Tweener.isTweening(objCurrent)) {
				//使用Tweener将camera移回预设的座标
				Tweener.addTween(view.camera, {
					x		:view.camera.extra.x,
					y		:view.camera.extra.y,
					z		:view.camera.extra.z,
					time	:1.5,
					
					//Tweener完成
					onComplete:function ():void {
						powerThumb = true; //将isThumbClick设成true
						view.viewport.interactive = true; //让onEventRender3D运算Camera的位置
						stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel); //重新侦听滚轮事件。
					}
				});
				
				//使用Tweener将目前Plane物件移回预设的座标
				Tweener.addTween(objCurrent, {
					x			:objCurrent.extra.x,
					y			:objCurrent.extra.y,
					z			:objCurrent.extra.z,
					rotationX 	:objCurrent.extra.rotationX,
					rotationY 	:objCurrent.extra.rotationY,
					rotationZ 	:objCurrent.extra.rotationZ,
					time		:1,
					onComplete:function():void {
						objCurrent.material.smooth = false;
						btnView.setEnabled(true);
					}
				});
			}
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
				"     个人独立版《浪漫追逐》\n\n\n" +
				"        滚动鼠标中键改变图片位置。点击图片即可查看大图，再次点击返回原视图。\n" +
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
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
		}
		
		/**
		 * 屏幕大小改变时，更新帮助按钮的位置
		 */
		private function eFucStageResize(e:Event):void {
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
			btnView.setY(this.stage.stageHeight - 30);
		}
		
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
	}
	
}