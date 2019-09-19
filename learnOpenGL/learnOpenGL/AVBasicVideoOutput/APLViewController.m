//
//  APLViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/7/25.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "APLViewController.h"
#import "APLEAGView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define ONE_FRAME_DURATION 0.03
#define LUMA_SLIDER_TAG 0
#define CHROMA_SLIDER_TAG 1

static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;
@interface APLImagePickerController : UIImagePickerController

@end

@implementation APLImagePickerController

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

@end
@interface APLViewController (){
    AVPlayer *_player;
    dispatch_queue_t _myVideoOutputQueue;
    id _notificationToken;
    id _timeObserver;
}
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISlider *lumaLeverSlider;

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UISlider *chromaLevelSlider;

@property (strong, nonatomic) IBOutlet APLEAGView *playerView;

@property(nonatomic,strong)AVPlayerItemVideoOutput *videoOutput;
@property(nonatomic,strong)CADisplayLink *displayLink;
- (IBAction)updateLevels:(id)sender;
- (IBAction)loadMovieFromCameraRoll:(id)sender;
- (IBAction)handleTapGesture:(id)sender;
-(void)displayLinkCallback:(CADisplayLink *)sender;
@end

@implementation APLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.playerView.lumaThreshold = [[self lumaLeverSlider] value];
    self.playerView.chromaThreshold = [[self chromaLevelSlider] value];

    _player = [[AVPlayer alloc]init];
    [self addTimeObserverToPlayer];

    //设置CADisplayLink，它将在每次同步时回调displayPixelBuffer。
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.displayLink setPaused:YES];


    //使用所需的pixelbuffer属性设置AVPlayerItemVideoOutput。
    //设置输出格式
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithOutputSettings:pixBuffAttributes];
    _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoOutput setDelegate:self queue:_myVideoOutputQueue];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    [self addTimeObserverToPlayer];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:AVPlayerItemStatusContext];
    [self removeTimeOBserverFromPlayer];
    if (_notificationToken) {
        [[NSNotificationCenter defaultCenter] removeObserver:_notificationToken name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        _notificationToken = nil;
    }
}
-(void)displayLinkCallback:(CADisplayLink *)sender{

    /*
    每次同步都会调用回调。
    使用显示链接的时间戳和持续时间，我们可以计算下一次刷新屏幕时的时间，并复制该时间的像素缓冲区
    然后可以处理这个像素缓冲区，然后在屏幕上呈现。
    */
    CMTime outputItemTime = kCMTimeInvalid;
    //计算下一次刷新屏幕的时间，即下一次刷新屏幕的时间。
    CFTimeInterval nextVSync = [sender timestamp] + [sender duration];
    outputItemTime = [[self videoOutput] itemTimeForHostTime:nextVSync];
    if ([self.videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        //像素信息
        CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];

        [self.playerView displayPixelBuffer:pixelBuffer];
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
    }
}

-(void)addTimeObserverToPlayer{
    /*
     Adds a time ovserver to the player to periodically refresh the time label to reflect current time
     向播放器添加一个时间观察者,定时刷新时间标签以反映当前时间
     */
    if (_timeObserver) return;

    /*
     Use __weak reference to self to ensure that a strong reference cycle is not formed between the view controller ,player and notification block

     使用对self的弱引用来确保视图控制器、播放器和通知块之间没有形成强引用循环。
     */
    __weak APLViewController *weakSelf = self;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSLog(@"%lld %d",time.value, time.timescale);
        [weakSelf syncTImeLabel];
    }];

}
-(void)syncTImeLabel{
    double seconds = CMTimeGetSeconds([_player currentTime]);
    if (!isfinite(seconds)) {
        seconds = 0;
    }
    int secondsInt = round(seconds);
    int minutes = secondsInt/60;
    secondsInt -= minutes * 60;

    self.currentTime.textColor = [UIColor whiteColor];
    self.currentTime.textAlignment = NSTextAlignmentCenter;
    self.currentTime.text = [NSString stringWithFormat:@"%.2i:%.2i",minutes,secondsInt];

}
-(void)removeTimeOBserverFromPlayer{
    if (_timeObserver) {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

- (IBAction)updateLevels:(id)sender {
    NSInteger tag = [sender tag];
    switch (tag) {
        case LUMA_SLIDER_TAG:
            self.playerView.lumaThreshold = self.lumaLeverSlider.value;
            break;

        case CHROMA_SLIDER_TAG:
            self.playerView.chromaThreshold = self.chromaLevelSlider.value;
            break;
        default:
            break;
    }
}

- (IBAction)loadMovieFromCameraRoll:(id)sender {
    [_player pause];
    //初始化UIImagePickerController，从摄像机滚动中选择一个影片
    APLImagePickerController *videoPicker = [[APLImagePickerController alloc]init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];

    [self presentViewController:videoPicker animated:YES completion:nil];
}

- (IBAction)handleTapGesture:(id)sender {
    self.toolBar.hidden = !self.toolBar.hidden;
}

#pragma mark - PlaybackSetup
-(void)setupPlaybackForURL:(NSURL *)URL{
    /*

     设置播放器项并将视频输出添加到其中。
     asset的tracks属性通过异步键值加载加载，以访问用于在呈现时定位视频的视频跟踪的首选转换。
     添加视频输出后，我们请求媒体更改通知，以便重新启动CADisplayLink。
     */
    //删除旧项目中的视频输出(如果有的话)。
    [[_player currentItem] removeOutput:self.videoOutput];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:URL];
    AVAsset *asset = [item asset];
    //异步加载属性
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if (tracks.count > 0) {
                //choose the first video track
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                [videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
                    if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
                        CGAffineTransform preferredTransform = [videoTrack preferredTransform];

                        /*
                        记录时摄像机的方向会影响从AVPlayerItemVideoOutput接收到的图像的方向。这里我们计算一个旋转，用来正确定位视频。
                        */
                        self.playerView.preferredRotation = -1 * atan2(preferredTransform.b, preferredTransform.a);
                        [self addDidPlayToEndTimeNotificationForPlayerItem:item];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [item addOutput:self.videoOutput];
                            [_player replaceCurrentItemWithPlayerItem:item];
                            [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                            [_player play];
                        });
                    }
                }];
            }
        }
    }];

}

-(void)addDidPlayToEndTimeNotificationForPlayerItem:(AVPlayerItem*)item{
    if (_notificationToken) {
        _notificationToken = nil;
    }
    /*

     将actionAtItemEnd设置为None可以防止影片在项目结束时暂停。一个非常简单，而不是无间隙的，循环播放。
     */
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _notificationToken = [[NSNotificationCenter defaultCenter]addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        //简单的项目回放倒带。
        [[_player currentItem] seekToTime:kCMTimeZero];
        
    }];

}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
-(void)stopLoadingAnimationAndHandleError:(NSError*)error{
    if (error) {
        NSString *cancekButtonTitle = NSLocalizedString(@"OK", @"Cancel button title for animation load error");
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:cancekButtonTitle otherButtonTitles: nil];
        [alertView show];
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (context == AVPlayerItemStatusContext) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:

                break;
                case AVPlayerStatusReadyToPlay:
                self.playerView.presentationRect = [[_player currentItem] presentationSize];
                break;
            case AVPlayerStatusFailed:
                [self stopLoadingAnimationAndHandleError:[_player.currentItem error]];
            default:
                break;
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - AVPlayerItemOutputPullDelegate
-(void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender{
    [self.displayLink setPaused:NO];
}

#pragma mark - Image Picker Controller Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_player.currentItem == nil) {
        self.lumaLeverSlider.enabled = YES;
        self.chromaLevelSlider.enabled = YES;
        [self.playerView setupGL];
    }
    //time label shows the current time of the item
    if (self.timeView.hidden) {
        [self.timeView.layer setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.3].CGColor];
        [self.timeView.layer setCornerRadius:5.0f];
        self.timeView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:.15].CGColor;
        self.timeView.layer.borderWidth=1.0f;
        self.timeView.hidden = NO;
        self.currentTime.hidden = NO;

    }
    [self setupPlaybackForURL:info[UIImagePickerControllerMediaURL]];
    picker.delegate = self;

}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view != self.view) {
        return NO;
        //忽略工具栏上的触摸。
        return NO;
    }
    return YES;
}
@end
