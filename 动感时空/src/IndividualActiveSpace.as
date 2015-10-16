package {
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReferenceList;
	import flash.ui.ContextMenu;
	import flash.ui.Mouse;
	import org.aswing.ASColor;
	import org.aswing.ASFont;
	import org.aswing.AssetIcon;
	import org.aswing.AsWingConstants;
	import org.aswing.AsWingManager;
	import org.aswing.border.CaveBorder;
	import org.aswing.BorderLayout;
	import org.aswing.event.AWEvent;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JTextArea;
	import org.aswing.JWindow;
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.materials.utils.PrecisionMode;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.view.BasicView;
	
	/**
	 * ***的婚纱纪念相册，个人独立版
	 * 《动感时空》
	 * @author 庆友互动传媒
	 */
	public class IndividualActiveSpace extends Sprite {
		
		/**
		 * 三维视图
		 */
		private var view:BasicView;
		
		/**
		 * 图片数量
		 */
		private var uintItem:uint = 10;
		
		/**
		 * 控制所有图片的BOSS
		 */
		private var planeCtrl:DisplayObject3D;
		
		/**
		 * Z轴上的目标位置
		 */
		private var numDeepZ:Number = 0;
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;
		
		/**
		 * 照片数组
		 */
		private var arrJpg:Array = new Array();
		
		public function IndividualActiveSpace():void {
			if (stage)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		/**
		 * 主函数
		 */
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.stage.align = StageAlign.TOP_LEFT;	//左上对齐
			this.stage.scaleMode = StageScaleMode.NO_SCALE;	//演员不缩放
			
			var contextMenuUserDefined:ContextMenu = new ContextMenu();
			contextMenuUserDefined.hideBuiltInItems();	//隐藏原有右键菜单
			this.contextMenu = contextMenuUserDefined;
			
			//背景圆点
			for (var i:uint = 0; i < 40; i++){
				this.graphics.beginFill(0xffffff*Math.random(), Math.random()-0.3);
				this.graphics.drawCircle(Math.random() * 1500 - 100, Math.random() * 1200 - 50, Math.random() * 100 - 100);
				this.graphics.endFill();
			}
			
			var jbtnAddPic:JButton = new JButton("", new AssetIcon(new MenuAddPic(), 400, 100, true));
			jbtnAddPic.name = "jbtnAddPic";
			jbtnAddPic.setX(300);
			jbtnAddPic.setY(300);
			jbtnAddPic.setSizeWH(400, 100);
			jbtnAddPic.addEventListener(MouseEvent.CLICK, meFucClickJbtnAddPic);
			jbtnAddPic.addEventListener(MouseEvent.MOUSE_OVER, meMouseOverJbtnaddpic);
			jbtnAddPic.addEventListener(MouseEvent.MOUSE_OUT, meMouseOutJbtnaddpic);
			this.addChild(jbtnAddPic);
			
			btnHelp = new JButton("", new AssetIcon(new icoHi(), 30, 20, true));	//hi，帮助
			btnHelp.setToolTipText("这里是帮助信息哦");
			btnHelp.setFont(new ASFont("微软雅黑"));
			btnHelp.setX(this.stage.stageWidth - 130);
			btnHelp.setY(this.stage.stageHeight - 130);
			btnHelp.setSizeWH(30, 30);
			btnHelp.setBackground(new ASColor(0xff6600, 0.9));
			btnHelp.addEventListener(MouseEvent.CLICK, eFucHelpBtnClick);
			this.addChild(btnHelp);
		}
		
		private function meMouseOutJbtnaddpic(e:MouseEvent):void 
		{
			var mouse:DisplayObject = this.getChildByName("mouseNew") as DisplayObject;
			this.removeChild(mouse);
			Mouse.show();
		}
		
		private function meMouseOverJbtnaddpic(e:MouseEvent):void 
		{
			Mouse.hide();
			
			var mouseNew:MouseStyle = new MouseStyle();
			mouseNew.name = "mouseNew";
			
			//设置放鼠标样子的容器类的鼠标事件无效
			//这样点击时就不会影响点击其它元件的效果
			//因为那个看不见的箭头永远是在最上面的
			mouseNew.mouseEnabled = false;
			mouseNew.mouseChildren = false;

			//在舞台鼠标位置显示
			mouseNew.x = stage.mouseX;
			mouseNew.y = stage.mouseY;
			
			mouseNew.width = 180;
			mouseNew.height = 130;
			
			mouseNew.addEventListener(Event.ENTER_FRAME, function():void {
				mouseNew.x = stage.mouseX;
				mouseNew.y = stage.mouseY;
			});

			//加入到舞台的显示列表中去
			this.addChild(mouseNew);
		}
		
		private function meFucClickJbtnAddPic(e:MouseEvent):void 
		{
			this.removeChild(this.getChildByName("jbtnAddPic"));
			
			var filterJpb:FileFilter = new FileFilter("jpg 图片", "*.jpg");	//控制可以被选择的图片格式
			var filterPng:FileFilter = new FileFilter("png 图片", "*.png");	//控制可以被选择的图片格式
			
			var fileReferenceList:FileReferenceList = new FileReferenceList();	//多选对话框
			fileReferenceList.browse([filterJpb, filterPng]);	//设置可选文件类型
			fileReferenceList.addEventListener(Event.SELECT, eFucMultiSelectFile);
			
			view = new BasicView(0, 0, true, true, CameraType.TARGET);			
			view.viewport.buttonMode = true;
			view.camera.z = -740;
			this.addChild(view);
			
			planeCtrl = new DisplayObject3D();
			planeCtrl.z = -2000;			
			
			var colorMat:ColorMaterial = new ColorMaterial(0x000000, 0);	//上下左右透明
			for (var j:uint = 1; j < uintItem; j++) {
				var bitmapData:MaterialKing = new MaterialKing();	//背面的庆友标志
				var bitmapMat:BitmapMaterial = new BitmapMaterial(bitmapData, true);								
				bitmapMat.interactive = true;
				
				var bmpMat:BitmapMaterial = new BitmapMaterial(arrJpg[j], true);
				bmpMat.interactive = true;	//交互模式
				bmpMat.smooth = true;	//平滑模式
				bmpMat.precise = true;	//精准模式
				bmpMat.precisionMode = PrecisionMode.ORIGINAL;	//精度模式
				
				//盒子使用的列表材质
				var ml:MaterialsList = new MaterialsList({
					top		:colorMat ,//上、下、左、右皆是使用色彩材质
					bottom	:colorMat,
					left	:colorMat,
					right	:colorMat,
					
					front	:bmpMat,//前：使用图标
					back	:bitmapMat//后：使用照片
				});
				
				var cube:Cube = new Cube(ml, 800, 1, 600);//建构Cube物件(材质列表,宽度,深度,高度)
				cube.useOwnContainer = true;//独立容器模式开启
				cube.alpha = 0.7;//透明度为0.7
				cube.extra = {
					isFlip:false
				};//自定义属性（动态添加），用来判断Cube是否已经翻转过
				cube.z = j * 600;//z轴递增
				cube.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, eFucObjectRelease);//侦听点击事件
				planeCtrl.addChild(cube);//将cube加入至rootNode				
			}
			view.scene.addChild(planeCtrl);	//将图片BOSS加入场景
			
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.stage.addEventListener(Event.RESIZE, eFucStageResize);
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
		}
		
		/**
		 * 鼠标滚轮转动
		 */
		private function eFucMouseWheel(e:MouseEvent):void{			
			if (e.delta < 0) {
				numDeepZ -= 300;
				//滚轮向上，目标z轴就减300。
			}else {
				numDeepZ += 300;
			}
		}
		
		/**
		 * 处理3D对象的鼠标弹起事件
		 */
		private function eFucObjectRelease(e:InteractiveScene3DEvent):void {
			var tweenObj:Object;
			var target:Cube = e.displayObject3D as Cube;
			
			if (target.extra.isFlip) {
				//是的话，就让rotationY转回0度。
				tweenObj = { rotationY:0, alpha:0.7 };
				target.extra.isFlip = false;
			}else {
				//否的话，就让rotationY转回至180度。
				tweenObj = { rotationY:180, alpha:1 };
				target.extra.isFlip = true;
			}
			tweenObj.time = 0.9;
			//该Tweener动作在0.9秒内完成
			tweenObj.transition = "easeInOutBack";
			//运动方式。
			Tweener.addTween(target, tweenObj)
			//执行Tweener。
		}
		
		/**
		 * 渲染三维场景
		 */
		private function eFucSceneRender(e:Event):void	{
			var targetX:Number = stage.mouseX - stage.stageWidth / 2; //滑鼠x座标距离场景中心点
			var targetY:Number = stage.stageHeight / 2 - stage.mouseY; //滑鼠y座标距离场景中心点
			view.camera.x += (targetX - view.camera.x) / 5;//渐近运动
			view.camera.y += (targetY - view.camera.y) / 5;
			planeCtrl.z += (numDeepZ - planeCtrl.z) / 3;
			
			view.singleRender();
		}
		
		/**
		 * 帮助信息
		 */
		private function eFucHelpBtnClick(e:Event):void {
			view.viewport.interactive = false;
			this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.removeEventListener(Event.ENTER_FRAME, eFucSceneRender);
			
			AsWingManager.initAsStandard( this);	//初始化AsWing
			
			var strPicString:String = 
				"\n             庆友互动传媒\n" +
				"     庆友互动电子纪念相册\n\n" +
				"     个人独立版《动感时空》\n\n\n" +
				"        滚动鼠标中键改变镜头距离。点击图标即可翻转图片。\n\n\n\n" +
				"           Code：崔维友\n" +
				"         QQ：731942771\n" +
				"       Tel：13141407390\n"+
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
		 * 构建照片数组
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
		 * 屏幕大小改变时，更新帮助按钮的位置
		 */
		private function eFucStageResize(e:Event):void {
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
		}
	}
}