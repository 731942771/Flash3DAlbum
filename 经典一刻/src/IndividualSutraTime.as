package {
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
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
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.PrecisionMode;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	
	/**
	 * ***的婚纱纪念相册，个人独立版
	 * 《经典一刻》
	 * @author 庆友互动传媒
	 */
	public class IndividualSutraTime extends Sprite {
		/**
		 * 三维视图
		 */
		private var view			:BasicView;
		
		/**
		 * 载入的图片数量，默认0
		 */
		private var loadedNumber	:int = 0;
		
		/**
		 * 显示的图片数量，默认10
		 */
		private var itemOfNumber	:int = 10; //物件数量。
		
		/**
		 * 图片索引，默认0
		 */
		private var currentPlaneIndex:Number = 0;//目前图片的索引值。
		
		/**
		 * 图片转身角度，默认45
		 */
		private var planeAngle		:Number = 45;   //角度。
		
		/**
		 * 图片间距，默认280
		 */
		private var planeSeparation	:Number = 280;  //左右二边Plane与Plane的间距。
		
		/**
		 * 当前图片间距，默认300
		 */
		private var planeOffset		:Number = 300;  //目前所选择的Plane其左右的间距。
		
		/**
		 * 当前图片y位置，默认-40
		 */
		private var selectPlaneY	:Number = -40;  //目前所选择Plane的y值。
		
		/**
		 * 当前图片z位置，默认-490
		 */
		private var selectPlaneZ	:Number = -490;	//目前所选择Plane的z值。
		
		/**
		 * 是否渲染，默认false
		 */
		private var powerRender		:Boolean = false;
		
		/**
		 * 是否滚动滚轮，默认false
		 */
		private var powerWheel:Boolean = false;
		
		/**
		 * 图片数组
		 */
		private var arrJpg:Array = new Array();
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;
		
		public function IndividualSutraTime():void {
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
			contextMenuUserDefined.hideBuiltInItems();	//隐藏原有右键菜单
			this.contextMenu = contextMenuUserDefined;
			
			for (var i:uint = 0; i < 30; i++){
				this.graphics.beginFill(0xffffff*Math.random(), Math.random()-0.3);
				this.graphics.drawCircle(Math.random() * 1500 - 100, Math.random() * 1200 - 50, Math.random() * 100 - 100);
				this.graphics.endFill();
			}
			
			fucReturnJpg();
			
			view = new BasicView(0, 0, true, true, "Target");
			view.camera.z = -1400; 
			view.viewport.buttonMode = true;			
			this.addChild(view);
			
			for (var j:uint = 0 ; j < itemOfNumber; j++) {
				var refMat:BitmapMaterial = new BitmapMaterial(arrJpg[j]);
				refMat.interactive = true;	//交互模式
				refMat.smooth = true;	//平滑模式
				refMat.precise = true;	//精准模式
				refMat.precisionMode = PrecisionMode.STABLE;
				
				var plane:Plane  = new Plane( refMat, 1000, 650, 10, 8);
				plane.name = "item" + j;
				plane.extra = { id:j };//为每个plane设定一个唯一的id值
				plane.z = j * 60;//让z轴递减
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, eFucObjectClick);//侦听InteractiveScene3DEvent.OBJECT_CLICK事件
				
				view.scene.addChild(plane);
				
				loadedNumber++;
				
				if (loadedNumber >= itemOfNumber) {
					//如果已经载入的图片数量大于总显示图片数量，总数量为10
					shiftToItem(0);
					//执行shiftToItem函式
				}
			}
			
			var btnMessage:JButton = new JButton("永享幸福时刻，即在《经典一刻》");
			btnMessage.setFont(new ASFont("微软雅黑",12));	//字体
			btnMessage.setX(3); btnMessage.setY(3);	//位置
			btnMessage.setSizeWH(300, 30);	//尺寸
			this.addChild(btnMessage);	//加入Sprite
			
			btnHelp = new JButton("", new AssetIcon(new icoHi(), 30, 20, true));	//hi，帮助
			btnHelp.setToolTipText("这里是帮助信息哦");
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
			btnHelp.setSizeWH(30, 30);
			btnHelp.setBackground(new ASColor(0xff6600, 0.9));
			btnHelp.addEventListener(MouseEvent.CLICK, eFucHelpBtnClick);
			this.addChild(btnHelp);
			
			this.stage.addEventListener( MouseEvent.MOUSE_WHEEL, eFucMouseWheel);
			this.stage.addEventListener(Event.RESIZE, eFucStageResize);
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
		}
		
		/**
		 * 点击图片
		 */
		private function eFucObjectClick(e:InteractiveScene3DEvent):void{
			var uintPlaneId:uint = e.displayObject3D.extra.id;
			shiftToItem(uintPlaneId);
		}
		
		/**
		 * 更新图片索引值，首次调用5
		 */
		public function shiftToItem(uintIdOfPlane:uint):void {
			stage.quality = StageQuality.MEDIUM;
			
			powerRender = true;
			currentPlaneIndex = uintIdOfPlane;
			
			var objTteener:Object;
			for (var i:int = 0; i < itemOfNumber; i++){
				var plane:Plane = view.scene.getChildByName("item" + i) as Plane;
				var dis	:int = i - currentPlaneIndex;//算出目前回圈值与目标编号值的差
				if (i == currentPlaneIndex) {//如果目前回圈值等于目标编号值，目前所算算的plane为正中间显示
					objTteener = {
						x			: 0,
						y			: selectPlaneY,
						z			: selectPlaneZ,
						rotationY	: 0,
						onComplete	: function ():void {
							stage.quality = StageQuality.HIGH;
							powerRender = false;
							//当Tweener完成时,再把品质调成高
						}
					};
					//把值写入到_tweenObj物件里
				}
				else if (i < currentPlaneIndex) {
					//如果回圈值小于目标编号值
					//表示该plane在左边。
					objTteener = {
						x			:dis * planeSeparation - planeOffset,//x轴位置等于：距离差乘上间距,再多减去planeOffset变数
						y			:0,
						z			:0,
						rotationY	: 0 - planeAngle	//负的
					};
					
				}
				else {
					//plane在右边。
					objTteener = {
						x			:dis * planeSeparation + planeOffset,
						//x轴位置等于：距离差乘上间距,再多加planeOffset变数
						y			:0,
						z			:0,
						rotationY	:planeAngle
					};
				}
				
				objTteener.time = 0.8;
				
				Tweener.addTween(plane, objTteener);//使用Tweener移动物件
				
			}// end of for
		}
		
		/**
		 * 鼠标滚轮转动
		 */
		private function eFucMouseWheel(e:MouseEvent):void {	
			if (e.delta > 0) {
				view.camera.moveBackward(40);
				powerWheel = true;
			}
			else if (e.delta < 0 ) {
				view.camera.moveForward(40);
				powerWheel = true;
			}
			else {
				powerWheel = false;
			}
		}
		
		/**
		 * 渲染场景
		 */
        private function eFucSceneRender(e:Event):void {
			if (powerRender || powerWheel) {
				powerWheel = false;
				
				view.singleRender();
			}			
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
				"     个人独立版《经典一刻》\n\n\n" +
				"        滚动鼠标中键改变镜头距离。点击图片即可移动位置。\n\n\n\n" +
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
		}
		
		/**
		 * 创建照片数组
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
	}
}