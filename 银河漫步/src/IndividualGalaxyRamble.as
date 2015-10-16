package {
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
	import org.papervision3d.view.BasicView;
	
	/**
	 * ***的婚纱纪念相册，个人独立版
	 * 《银河漫步》
	 * @author 庆友互动传媒
	 */
	public class IndividualGalaxyRamble extends Sprite {
		private var view:BasicView;
		private var galaxy:Galaxy;
		private var player:Player;
		private var cameraCtrl:CameraController;
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;
		
		public function IndividualGalaxyRamble():void {
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
			
			view = new BasicView();
			this.addChild(view);
			
			galaxy = new Galaxy();
			galaxy.z = 1000;
			view.scene.addChild(galaxy);
			
			player = new Player();
			view.scene.addChild(player);
			
			var userInput:UserInputHandler = new UserInputHandler(stage);
			
			cameraCtrl = new CameraController(view.camera, player);
			var label:JButton = new JButton("庆友互动传媒互动电子相册-个人独立版《银河漫步》");
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
			
			this.stage.addEventListener(Event.RESIZE, eFucStageResize);
			this.addEventListener(Event.ENTER_FRAME, eFucRenderScene);
		}
		
		private function eFucRenderScene(e:Event):void {
			galaxy.fucUpdateGalaxy();
			player.fucUpdatePlayer();
			cameraCtrl.fucUpdateCamera();
			
			view.singleRender();
		}
		
		/**
		 * 帮助信息
		 */
		private function eFucHelpBtnClick(e:Event):void {
			view.viewport.interactive = false;
			this.removeEventListener(Event.ENTER_FRAME, eFucRenderScene);
			
			AsWingManager.initAsStandard(this);	//初始化AsWing
			
			var strPicString:String = 
				"\n             庆友互动传媒\n" +
				"     庆友互动电子纪念相册\n\n" +
				"     个人独立版《银河漫步》\n\n\n" +
				"        滚动鼠标左键点下可以拉近视图，松开后复位。使用QE和WSAD或上下左右箭头移动镜头\n\n\n" +
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
		private function eFucMousedown(e:MouseEvent, w:JWindow):void {
			w.removeEventListener(MouseEvent.CLICK, eFucMousedown);	//不起作用，aswing...
			w.hide();
			
			view.viewport.interactive = true;
			this.addEventListener(Event.ENTER_FRAME, eFucRenderScene);
		}
		
		private function eFucStageResize(e:Event):void {
			btnHelp.setX(this.stage.stageWidth - 30);
			btnHelp.setY(this.stage.stageHeight - 30);
		}
	}
}