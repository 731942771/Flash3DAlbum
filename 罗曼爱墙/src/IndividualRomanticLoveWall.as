package {
	import caurina.transitions.Tweener;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import milkmidi.display.MiniSlider;
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
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.PrecisionMode;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	
	/**
	 * ***的婚纱纪念相册，个人独立版
	 * 《罗曼爱墙》
	 * @author 庆友互动传媒
	 */
	public class IndividualRomanticLoveWall extends Sprite {
		private var view		:BasicView;
		private var uintItem	:uint = 10;		//图片数量
		
		/**
		 * camera的目标x轴，初始1000
		 */
		private var numCameraX	:Number = 1000;
		
		/**
		 * camera的目标y轴,初始0
		 */
		private var numCameraY	:Number = 0;
		
		/**
		 * camera的目标z轴，初始-2000
		 */
		private var numCameraZ	:Number = -2000;
		
		private var numMinCameraZ	:Number = -1700;//cameraZ轴的最小值
		private var numMaxCameraZ	:Number = -450;	//cameraZ轴的最大值
		private var sliderCameraPosition	:MiniSlider;	//迷你Slider物件。
		private var arrJpg:Array = new Array();
		private var spriteBackground:Sprite = new Sprite();
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;
		
		public function IndividualRomanticLoveWall():void {
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
			
			for (var k:uint = 0; k < 40; k++){
				this.graphics.beginFill(0xffffff*Math.random(), Math.random()-0.3);
				this.graphics.drawCircle(Math.random() * 1500 - 100, Math.random() * 1200 - 50, Math.random() * 100 - 100);
				this.graphics.endFill();
			}
			
			spriteBackground.x = 0;
			spriteBackground.y = 0;
			spriteBackground.graphics.beginFill(0x000000, 0);
			spriteBackground.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			spriteBackground.graphics.endFill();
			this.addChild(spriteBackground);
			
			fucReturnJpg();
			
			view = new BasicView(0, 0, true , true, "Free");
			view.camera.z = -3500;
			view.camera.x = -1000;
			view.viewport.buttonMode = true;
			this.addChild(view);
			
			var num:uint = arrJpg.length;
			for (var i:int = 0; i < uintItem; i++) {
				var refMat:BitmapMaterial = new BitmapMaterial(arrJpg[num - i - 1]);
				refMat.interactive = true;	//交互模式
				refMat.smooth = true;	//平滑模式
				refMat.precise = true;	//精准模式
				refMat.precisionMode = PrecisionMode.STABLE;
				
				var plane:Plane  = new Plane( refMat, 800, 600, 8, 8);
				plane.x = Math.floor( i / 2) * 900;
				plane.y = i % 2 * 750;
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, eFucObjectOver);
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, eFucObjectClick);
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, eFucObjectOut);
				view.scene.addChild(plane);
			}
			
			sliderCameraPosition = new MiniSlider(0, 2000, 200);
			sliderCameraPosition.addEventListener(MiniSlider.SLIDER, eFucSliderChange);	
			sliderCameraPosition.x = stage.stageWidth / 2 - 50;
			sliderCameraPosition.y = stage.stageHeight - 20;
			sliderCameraPosition.value = 1000;
			this.addChild(sliderCameraPosition);	
			
			var label:JButton = new JButton("优雅端庄，《罗曼爱墙》");
			label.setFont(new ASFont("微软雅黑",12));	//字体
			label.setX(3); label.setY(3);	//位置
			label.setSizeWH(160, 30);	//尺寸
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
		 * 刻度条滑块移动
		 */
		private function eFucSliderChange(e:Event):void {
			numCameraX = sliderCameraPosition.value;//slider物件其value属性可得到目前的值,范围为建构时所填写的0到2000。
		}
		
		/**
		 * 鼠标滚轮转动
		 */
		private function eFucMouseWheel(e:MouseEvent):void {	
			numCameraZ = view.camera.z - (e.delta * 100);//将 camera 要移动到的目标 z 轴值写入至 numCameraZ 变数里
			//判断目标 z 轴值是否小于最小值或是大于最大值, 再决定 camera 要移动到的目标
			if (numCameraZ < numMinCameraZ) {
				numCameraZ = numMinCameraZ
			}else if(numCameraZ > numMaxCameraZ){
				numCameraZ = numMaxCameraZ
			}
		}
		
		/**
		 * 鼠标移到图片上
		 */
		private function eFucObjectOver(e:InteractiveScene3DEvent):void {
			//当滑鼠滑入感应区时, 让广播者物件稍往前移
			Tweener.addTween( e.displayObject3D,{
                z		: -20,
                time	:1
			});
		}
		
		/**
		 * 鼠标移出图片处理
		 */
		private function eFucObjectOut(e:InteractiveScene3DEvent):void {
			//当滑鼠离开感应区, 让广播者的 z 轴回复到 0
			Tweener.addTween( e.displayObject3D,{
                z		: 0,
                time	:1
			});
		}
		
		/**
		 * 点击图片事件
		 */
		private function eFucObjectClick(e:InteractiveScene3DEvent):void{
			var _target:Plane = e.displayObject3D as Plane;
			//当使用者点选图片时, 先取得广播者 (被点选者),
			//其x,y,z属性即是Camera的目标值,
			//z轴要多减去150,让Camera可以往后一点
			numCameraX = _target.x;
			numCameraY = _target.y;
			numCameraZ = _target.z -350;
			spriteBackground.addEventListener(MouseEvent.CLICK, eFucBackgroundClick);
			//侦听场景上的bg_mc物件所发出的MouseEvent.CLICK事件。
		}
		
		/**
		 * 背景点击事件
		 */
		private function eFucBackgroundClick(e:MouseEvent):void {
			spriteBackground.removeEventListener(MouseEvent.CLICK, eFucBackgroundClick);
			
			numCameraZ = -2000;
		}
		
		/**
		 * 渲染
		 */
        private function eFucSceneRender(e:Event):void{			
			var incrementX:Number = (numCameraX - view.camera.x) / 40;//算出x轴的移动量	
			
			//把 x 轴的移动量当成 rotationY 的目标值, 套入至渐进公式里 这样可以做出 Camera 到达到目标 x 轴后, 再慢慢转正的效果
			var incrementRotation:Number = (incrementX - view.camera.rotationY) / 40;
			view.camera.rotationY += incrementRotation;
			
			view.camera.x += incrementX;// x 轴的渐进公式
			view.camera.y += (numCameraY - view.camera.y) / 15;// y 轴的渐进公式
			view.camera.z += (numCameraZ - view.camera.z) / 15;// z 轴的渐进公式
			
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
				"     个人独立版《罗曼爱墙》\n\n\n" +
				"        滚动鼠标中键改变镜头距离。点击图片即可查看大图，再次点击返回原视图。或者移动滑块改变视图\n\n\n\n" +
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
			spriteBackground.graphics.clear();
			spriteBackground.graphics.beginFill(0x000000, 0);
			spriteBackground.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			spriteBackground.graphics.endFill();
			
			sliderCameraPosition.x = stage.stageWidth / 2 - 50;
			sliderCameraPosition.y = stage.stageHeight - 20;
			
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
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