package {
	import caurina.transitions.Tweener;
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextFormat;
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
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.PrecisionMode;
	import org.papervision3d.materials.VideoStreamMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	
	/**
	 * ***的婚纱纪念相册，个人独立版
	 * 《真美可视》
	 * @author 庆友互动传媒
	 */
    public class IndividualBeautifulVideo extends Sprite {
		private var view:BasicView;
		private var plane:Plane;
		/**
		 * 视频长度
		 */
		private var numVideoLength:Number = 0;
		
		/**
		 * 进度条滑块按下时的播放进度
		 */
		private var numNowTime:Number = -3;
		
		/**
		 * 视频播放进度标签
		 */
		private var labelTime:Label;
		
		/**
		 * 音量标签
		 */
		private var labelVolume:Label;
		
		/**
		 * 进度条
		 */
		private var sliderTime:Slider;
		
		/**
		 * 音量控制
		 */
		private var sliderVolume:Slider;
		
		/**
		 * 两个进度条的背景
		 */
		private var spriteBackgroundOfSlider:Sprite;
		 
		/**
		 * 播放/暂停
		 */
		private var btnPuse:Button;
		
		/**
		 * 停止
		 */
		private var btnStop:Button;
		
		/**
		 * 两个按钮的背景
		 */
		private var spriteBackgroundOfButton:Sprite;
		 
		/**
		 * 视频编号，从0开始
		 */
		private var uintIndex:uint = 0;
		
		/**
		 * 照片数组
		 */
		private var arrJpg:Array = new Array();
		
		/**
		 * 视频数组
		 */
		private var arrVideo:Array=new Array();
		
		/**
		 * 网络连接
		 */
		private var netConnection:NetConnection;
		/**
		 * 网络数据流
		 */
		private var netStream:NetStream;
		/**
		 * 视频
		 */
		private var netVideo:Video;
		/**
		 * NetStream的回调对象
		 */
		private var netClientor:Object;
		
		/**
		 * 被点击对象的拷贝
		 */
		private var do3dEmpty:DisplayObject3D;
		/**
		 * 被点击对象的二次拷贝，复位同一个点击对象
		 */
		private var do3dGhost:DisplayObject3D;
		/**
		 * 视频材质
		 */
		private var matVideoStream:VideoStreamMaterial;
		
		/**
		 * 是否有视频在播放
		 */
		private var powerShowTime:Boolean = false;
		
		/**
		 * 是否Tweener结束，默认true
		 */
		private var isTweenerring:Boolean = true;
		 
		/**
		 * 已播放视频的名称
		 */
		private var strCurrentObj:String = " ";
		
		/**
		 * 背景
		 */
		private var spriteBackground:Sprite;
		
		/**
		 * 帮助按钮
		 */
		private var btnHelp:JButton;

        public function IndividualBeautifulVideo() {
			main();
		}
		
		/**
		 * 构建视频墙
		 */
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
			
			spriteBackground = new Sprite();
			spriteBackground.graphics.beginFill(0x000000, 0);	//透明
			spriteBackground.graphics.drawRect(0, 0, 1024, 768);
			spriteBackground.graphics.endFill();
			this.addChild(spriteBackground);
			
			view = new BasicView(0, 0, true, true, "Free");
			view.viewport.buttonMode = true;
			//view.camera.z = -300;
			this.addChild(view);
			
			fucReturnJpg();	//加载照片
			
			//加载视频：迎亲，过门，喜宴，踏青，闹房，婚纱
			arrVideo = new Array("video/迎亲.flv", "video/过门.flv", "video/喜宴.flv", "video/踏青.flv", "video/婚纱.flv", "video/闹房.flv");
			
			netConnection = new NetConnection();
			netConnection.connect(null);	//连接本地
			
			netClientor = new Object();
			netClientor.onMetaData = fucOnMetaData;	//回调函数，获取总时长
			
			//横着3个，因为plane的x取值为i
			for (var i:uint = 0; i < 3; i++) {
				//竖着2个
				for (var j:uint = 0; j < 2; j++) {
					if(uintIndex<7){
						uintIndex++;
					}else {
						uintIndex = 1;
					}
					
					var refMat:BitmapMaterial = new BitmapMaterial(arrJpg[uintIndex - 1]);	//从数组第2个位-【1】-开始取
					refMat.interactive = true;	//交互模式
					refMat.smooth = true;	//平滑模式
					refMat.precise = true;	//精准模式
					refMat.precisionMode = PrecisionMode.STABLE;
					
					var plane:Plane  = new Plane( refMat, 800, 550, 10, 8);	//从数组提取对应的宽高
					plane.name = String(uintIndex - 1);	//第一个的名字是“1”
					plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, eFucClickPlane);
					
					Tweener.addTween(plane, {
						x : i * 920 - 900,
						y : j * 720 - 420,
						
						time : 3,
						transition : "easeOutElastic"
					});
					
					view.scene.addChild(plane);
				}
			}
			
			var btnMessage:JButton = new JButton("重温浪漫回忆，尽在《真美可视》");
			btnMessage.setX(10); btnMessage.setY(10);
			btnMessage.setSizeWH(255, 30);
			this.addChild(btnMessage);
			
			spriteBackgroundOfSlider = new Sprite();
			spriteBackgroundOfSlider.graphics.beginFill(0x66ff99, 1);
			spriteBackgroundOfSlider.graphics.drawRoundRect(10, 50, 255, 45, 10, 10);
			spriteBackgroundOfSlider.graphics.endFill();
			this.addChild(spriteBackgroundOfSlider);
			
			//显示风格
			var format:TextFormat = new TextFormat();
			format.font = "黑体";
			format.color = 0x0066ff;
			format.size = 13;
			
			labelVolume = new Label();
			labelVolume.x = 25;	labelVolume.y = 55;
			labelVolume.text = "音量: 50";
			labelVolume.setStyle("textFormat", format);
			labelVolume.selectable = false;
			this.addChild(labelVolume);
			
			sliderVolume = new Slider();
			sliderVolume.x = 25;	sliderVolume.y = 75;
			sliderVolume.width = 100;
			sliderVolume.maximum = 100;
			sliderVolume.minimum = 0;
			sliderVolume.value = 50;
			sliderVolume.liveDragging = true;
			sliderVolume.enabled = false;
			sliderVolume.addEventListener(SliderEvent.CHANGE, eFucVolumeSliderChange);
			this.addChild(sliderVolume);
			
			labelTime = new Label();
			labelTime.x = 155;	labelTime.y = 55;
			labelTime.text = "进度: 00:00 - 00:00";
			labelTime.setStyle("textFormat", format);
			labelTime.selectable = false;
			this.addChild(labelTime);
			
			sliderTime = new Slider();
			sliderTime.x = 155;	sliderTime.y = 75;
			sliderTime.width = 100;
			sliderTime.liveDragging = true;
			sliderTime.enabled = false;
			sliderTime.addEventListener(SliderEvent.THUMB_DRAG, eFucTimeSliderThumbDrag);
			this.addChild(sliderTime);
			
			spriteBackgroundOfButton = new Sprite();
			spriteBackgroundOfButton.x = stage.stageWidth - 280;
			spriteBackgroundOfButton.y = stage.stageHeight - 60;
			spriteBackgroundOfButton.graphics.beginFill(0x993366, 1);
			spriteBackgroundOfButton.graphics.drawRoundRect(0, 0, 210, 50, 10, 10);
			spriteBackgroundOfButton.graphics.endFill();
			this.addChild(spriteBackgroundOfButton);
			
			btnPuse = new Button();
			btnPuse.label = "暂停";
			btnPuse.setStyle("textFormat", format);
			btnPuse.x = stage.stageWidth - 265;	btnPuse.y = stage.stageHeight - 50;
			btnPuse.setSize(80, 30);
			btnPuse.enabled = false;
			btnPuse.addEventListener(MouseEvent.CLICK, eFucPauseBtnClick);
			this.addChild(btnPuse);
			
			btnStop = new Button();
			btnStop.label = "停止";
			btnStop.setStyle("textFormat", format);
			btnStop.x = stage.stageWidth - 165;	btnStop.y = stage.stageHeight - 50;
			btnStop.setSize(80, 30);
			btnStop.enabled = false;
			btnStop.addEventListener(MouseEvent.CLICK, eFucStopBtnClick);
			this.addChild(btnStop);
			
			btnHelp = new JButton("", new AssetIcon(new icoHi(), 30, 20, true));	//hi，帮助
			btnHelp.setToolTipText("这里是帮助信息哦");
			btnHelp.setFont(new ASFont("微软雅黑"));
			btnHelp.setX(this.stage.stageWidth - 55);
			btnHelp.setY(this.stage.stageHeight - 60);
			btnHelp.setSizeWH(50, 50);
			btnHelp.setBackground(new ASColor(0xff6600, 0.9));
			btnHelp.addEventListener(MouseEvent.CLICK, eFucHelpBtnClick);
			this.addChild(btnHelp);
			
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
			this.stage.addEventListener(Event.RESIZE, eFucStageResize);
        }
		
		/**
		 * 舞台尺寸改变后，更正Slider和Button的位置
		 */
		private function eFucStageResize(e:Event):void {
			spriteBackgroundOfButton.x = stage.stageWidth - 280;
			spriteBackgroundOfButton.y = stage.stageHeight - 60;
			
			btnPuse.x = stage.stageWidth - 265;	
			btnPuse.y = stage.stageHeight - 50;
			
			btnStop.x = stage.stageWidth - 165;
			btnStop.y = stage.stageHeight - 50;
			
			btnHelp.setX(this.stage.stageWidth - 55);
			btnHelp.setY(this.stage.stageHeight - 60);
		}
		
		/**
		 * 暂停按钮点击
		 */
		private function eFucPauseBtnClick(e:MouseEvent = null):void {
			if (btnPuse.label == "暂停") {
				btnPuse.label = "播放";
				netStream.togglePause();
			}else {
				btnPuse.label = "暂停";
				netStream.togglePause();
			}
		}
		
		/**
		 * 停止按钮点击事件,参数MouseEvent可以为空
		 */
		private function eFucStopBtnClick(e:MouseEvent = null):void {
			if(powerShowTime){
				powerShowTime = false;
				labelTime.text = "进度: 00:00 - 00:00";
				numVideoLength = 0;
				sliderTime.enabled = false;
				sliderTime.value = 0;
				sliderVolume.enabled = false;
				labelVolume.text = "音量: 50";
				sliderVolume.value = 50;
				btnPuse.label = "暂停";
				btnPuse.enabled = false;
				btnStop.enabled = false;
				numNowTime = -3;
				
				//那么，恢复上一个plane对象原有的材质-照片
				var refMat:BitmapMaterial = new BitmapMaterial(arrJpg[uint(strCurrentObj)]);
				refMat.interactive = true;
				view.scene.getChildByName(strCurrentObj).material = refMat;
				
				//如果已经有一个（上一个）视频在播放
				powerShowTime = false;
				//那么，关闭
				netStream.close();
				
				//将上一个对象复位
				Tweener.addTween(view.scene.getChildByName(strCurrentObj), {
					x : do3dGhost.x,
					y : do3dGhost.y,
					z : do3dGhost.z,
					
					rotationX : do3dGhost.rotationX,
					rotationY : do3dGhost.rotationY,
					rotationZ : do3dGhost.rotationZ,
					
					scale : do3dGhost.scale,
					
					time : 2,
					transition : "easeOutExpo"
				});
				
				//让摄像机归位
				Tweener.addTween(view.camera, {
					x:0,
					y:0,
					z: -1000,
					
					time:1,
					transition:"easeOutExpo"
				});
				
				strCurrentObj = " ";
			}
		}
		
		/**
		 * 3D对象点击事件，播放视频
		 */
		private function eFucClickPlane(e:InteractiveScene3DEvent):void {
			//防止连续点击，发生Tweener错乱
			view.viewport.interactive = false;
			//如果点击的不是正在播放（已经播放）的视频
			if (e.displayObject3D.name != strCurrentObj) {
				//隐藏播放时间
				labelTime.text = "进度: 00:00 - 00:00";
				numVideoLength = 0;
				sliderTime.enabled = false;
				sliderTime.value = 0;
				sliderVolume.enabled = false;
				labelVolume.text = "音量: 50";
				sliderVolume.value = 50;
				btnPuse.label = "暂停";
				btnPuse.enabled = false;
				btnStop.enabled = false;
				numNowTime = -3;
				
				//拷贝本次被点击的对象的属性
				do3dEmpty = new DisplayObject3D();
				do3dEmpty.copyTransform(e.displayObject3D);
				do3dEmpty.moveBackward(500);
				
				var i:uint = uint(e.displayObject3D.name);
				
				//如果不是打开swf后第一次点击plane
				if (strCurrentObj != " ") {
					//那么，恢复上一个plane对象原有的材质-照片
					var refMat:BitmapMaterial = new BitmapMaterial(arrJpg[uint(strCurrentObj)]);
					refMat.interactive = true;
					refMat.smooth = true;
					refMat.precise = true;
					refMat.precisionMode = PrecisionMode.STABLE;
					view.scene.getChildByName(strCurrentObj).material = refMat;
					
					//如果已经有一个（上一个）视频在播放
					powerShowTime = false;
					//那么，关闭
					netStream.close();
					
					//将上一个对象复位
					Tweener.addTween(view.scene.getChildByName(strCurrentObj), {
						x : do3dGhost.x,
						y : do3dGhost.y,
						z : do3dGhost.z,
						
						rotationX : do3dGhost.rotationX,
						rotationY : do3dGhost.rotationY,
						rotationZ : do3dGhost.rotationZ,
						
						scale : do3dGhost.scale,
						
						time : 2,
						transition : "easeOutExpo"
					});
				}
				
				//二次拷贝本次点击的对象属性
				do3dGhost = new DisplayObject3D();
				do3dGhost.copyTransform(e.displayObject3D);
				
				//根据本次点击对象,Tweener摄像机
				Tweener.addTween(view.camera, {
					x:do3dEmpty.x,
					y:do3dEmpty.y + 30,
					z:do3dEmpty.z,
					
					rotationX :do3dEmpty.rotationX,
					rotationY :do3dEmpty.rotationY,
					rotationZ :do3dEmpty.rotationZ,
					
					time:2,
					transition:"easeOutExpo",
					
					//Tweener摄像机完成后执行函数
					onComplete:function():void{
						//保存现在播放视频的对象名
						strCurrentObj = e.displayObject3D.name;
						
						var sodTransform:SoundTransform = new SoundTransform();
						sodTransform.volume = sliderVolume.value / 50;
						
						netStream = new NetStream(netConnection);	//数据流
						netStream.client = netClientor;	//触发回调函数
						netStream.play(arrVideo[i]);	//读取视频数据
						netStream.soundTransform = sodTransform;
						netStream.addEventListener(NetStatusEvent.NET_STATUS,eFucNetStatus);
						
						netVideo = new Video();
						netVideo.attachNetStream(netStream);	//播放视频数据
						netVideo.smoothing = true;
						
						matVideoStream = new VideoStreamMaterial (netVideo, netStream);
						matVideoStream.animated = true;
						matVideoStream.interactive = true;
						matVideoStream.smooth = true;	//这个是必须的
						matVideoStream.precise = true;
						matVideoStream.precisionMode = PrecisionMode.STABLE;
						
						//给本次点击对象赋予新材质-视频
						e.displayObject3D.material = matVideoStream;
						
						//有视频播放了
						powerShowTime = true;
						
						//显示播放时间
						sliderTime.enabled = true;
						sliderVolume.enabled = true;
						btnPuse.enabled = true;
						btnStop.enabled = true;
						view.viewport.interactive = true;
						
						//添加背景监听
						spriteBackground.addEventListener(MouseEvent.CLICK, eFucMouseClickStage);
					}
				});
				
				//放大新点击对象
				Tweener.addTween(e.displayObject3D, {
					scale : 1.3,
					z : -10,
					time : 1
				});
			}
			//如果点击的是正在播放的
			else {
				//让摄像机再拉近观看
				Tweener.addTween(view.camera, {
					x:do3dEmpty.x,
					y:do3dEmpty.y + 30,
					z:do3dEmpty.z,
					
					rotationX :do3dEmpty.rotationX,
					rotationY :do3dEmpty.rotationY,
					rotationZ :do3dEmpty.rotationZ,
					
					time:2,
					transition:"easeOutExpo",
					
					onComplete:function():void {
						view.viewport.interactive = true;
						
						//Tweener结束后，添加背景点击监听
						spriteBackground.addEventListener(MouseEvent.CLICK, eFucMouseClickStage);
					}
				});
				
				//再次放大正在播放的对象
				Tweener.addTween(e.displayObject3D, {
					scale : 1.3,
					z : -10,
					time : 1
				});
			}
		}
		
		/**
		 * 监听视频播放完毕等等等
		 */
		private function eFucNetStatus(e:NetStatusEvent):void {
			switch (e.info.code){
				case "NetStream.Play.StreamNotFound" :
					eFucStopBtnClick();
					break ;
				case "NetStream.Play.Failed" :
					eFucStopBtnClick();
					break ;
				case "NetStream.Seek.Failed" :
					eFucStopBtnClick();
					break ;
				case "NetStream.Seek.InvalidTime" :
					eFucStopBtnClick();
					break ;
				case "NetStream.Play.Stop" :
					eFucStopBtnClick();
					break ;
				default :
					break ;
			}
		}
		
		/**
		 * 点击背景事件，推远摄像机，总揽全局
		 */
		private function eFucMouseClickStage(e:MouseEvent):void {
			spriteBackground.removeEventListener(MouseEvent.CLICK, eFucMouseClickStage);
			//让摄像机推远，总揽全局
			Tweener.addTween(view.camera, {
				x:0,
				y:0,
				z: -1000,
				
				time:1,
				transition:"easeOutExpo"
			});
			
			//让播放视频的plane恢复原始尺寸
			if (strCurrentObj != " ") {
				Tweener.addTween(view.scene.getChildByName(strCurrentObj), {
					z : do3dGhost.z,
					scale : do3dGhost.scale,
					
					time : 1
				});
			}
		}
		
		/**
		 * 场景渲染
		 */
		private function eFucSceneRender(e:Event):void {
			view.singleRender();
			
			if(powerShowTime){
				labelTime.text = "进度: " + timeFormat(sliderTime.value) + " - " + timeFormat(numVideoLength);
				sliderTime.value = Math.round(netStream.time);
			}
		}
		
		/**
		 * 播放进度条上鼠标拖动滑块改变播放进度
		 */
		private function eFucTimeSliderThumbDrag(e:SliderEvent):void {
			powerShowTime = false;
			
			labelTime.text = "进度: " + timeFormat(sliderTime.value) + " - " + timeFormat(numVideoLength);
			sliderTime.addEventListener(SliderEvent.THUMB_RELEASE, eFucSliderTimeThumbRelease)
		}
		
		/**
		 * 播放进度条上鼠标弹起
		 */
		private function eFucSliderTimeThumbRelease(e:SliderEvent):void {
			sliderTime.removeEventListener(SliderEvent.THUMB_RELEASE, eFucSliderTimeThumbRelease);
			if(e.value < numVideoLength){
				netStream.pause();
				netStream.seek(sliderTime.value);
				netStream.resume();
				
				numNowTime = Math.round(e.value);
				
				//为防止滑块在鼠标松开时的跳跃
				this.addEventListener(Event.ENTER_FRAME, function eFucListenr(ev:Event):void {
					if (netStream.time > numNowTime) {
						ev.currentTarget.removeEventListener(Event.ENTER_FRAME, eFucListenr);
						
						powerShowTime = true;
					}
				});
			}else {
				powerShowTime = true;
				eFucStopBtnClick();
			}
		}
		
		/**
		 * 根据NetStream.time计算显示的数字
		 */
		private function timeFormat(n:Number):String {
			return ( "0" +uint(n/60)).substr(-2)+ ":" +( "0" +uint(n%60)).substr(-2);
		}
		
		/**
		 * 调整音量
		 */
		private function eFucVolumeSliderChange(e:SliderEvent):void {
			labelVolume.text = "音量: " + String(e.value);
			
			var sodTransform:SoundTransform = new SoundTransform();
			sodTransform.volume = e.value / 50;
			netStream.soundTransform = sodTransform;
		}
		
		/**
		 * 回调函数，获取视频长度
		 */
		public function fucOnMetaData(obj:Object):void {
			numVideoLength = Math.round(obj.duration);
			sliderTime.maximum = numVideoLength;
			//trace("metadata: duration=" + obj.duration + " width=" + obj.width + " height=" + obj.height + " framerate=" + obj.framerate);
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
		}
		
		/**
		 * 帮助信息
		 */
		private function eFucHelpBtnClick(e:Event):void {
			this.removeEventListener(Event.ENTER_FRAME, eFucSceneRender);
			btnHelp.setEnabled(false);
			view.viewport.interactive = false;
			
			if ((sliderTime.value > 0) && (btnPuse.label=="暂停")) {
				netStream.togglePause();
				btnPuse.enabled = false;
				btnStop.enabled = false;
				sliderTime.enabled = false;
				sliderVolume.enabled = false;
				spriteBackground.removeEventListener(MouseEvent.CLICK, eFucMouseClickStage);
			}
			
			AsWingManager.initAsStandard( this);	//初始化AsWing
			
			var strPicString:String = 
				"\n             庆友互动传媒\n" +
				"     庆友互动电子纪念相册\n\n" +
				"     个人独立版《真美可视》\n\n\n" +
				"        点击播放。可以拖动滑块调整音量或播放位置；亦可暂停或停止观看\n\n\n\n" +
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
			this.addEventListener(Event.ENTER_FRAME, eFucSceneRender);
			
			view.viewport.interactive = true;
			
			if ((sliderTime.value > 0) && (btnPuse.label == "暂停")) {
				netStream.togglePause();
				btnPuse.enabled = true;
				btnStop.enabled = true;
				sliderTime.enabled = true;
				sliderVolume.enabled = true;
				spriteBackground.addEventListener(MouseEvent.CLICK, eFucMouseClickStage);
			}
			btnHelp.setEnabled(true);
		}
	}
}