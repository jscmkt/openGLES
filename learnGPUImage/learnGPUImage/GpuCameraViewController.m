//
//  GpuCameraViewController.m
//  learnGPUImage
//
//  Created by you&me on 2019/8/15.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "GpuCameraViewController.h"
#import <GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface GpuCameraViewController ()

@property(nonatomic,strong)GPUImageVideoCamera *videoCamera;
@property(nonatomic,strong)GPUImageOutput<GPUImageInput> *filter;
@property(nonatomic,strong)GPUImageMovieWriter *movieWriter;
@property(nonatomic,strong)GPUImageView *filterView;

@property(nonatomic,strong)UIButton *mButton;
@property(nonatomic,strong)UILabel *mLabel;
@property(nonatomic,assign) long mLableTime;
@property(nonatomic,strong)NSTimer *mTimer;
@property(nonatomic,strong)CADisplayLink *mDisplayLink;

@end

@implementation GpuCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:(AVCaptureDevicePositionBack)];
    _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;//输出方向

    _filter = [[GPUImageSepiaFilter alloc]init];
    _filterView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    self.view = _filterView;

    _mButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 50, 50)];
    [_mButton setTitle:@"录制" forState:(UIControlStateNormal)];
    [_mButton sizeToFit];
    [self.view addSubview:_mButton];
    [_mButton addTarget:self action:@selector(onClick:) forControlEvents:(UIControlEventTouchUpInside)];

    _mLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 30, 50, 100)];
    _mLabel.hidden = YES;
    _mLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_mLabel];

    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(10, 50, 100, 40)];
    [slider addTarget:self action:@selector(updateSliderValue:) forControlEvents:(UIControlEventValueChanged)];
    [self.view addSubview:slider];

    [_videoCamera addTarget:_filter];
    [_filter addTarget:_filterView];
    [_videoCamera startCameraCapture];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;

    }];
    self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLink:)];
    [self.mDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];


}
-(void)displayLink:(CADisplayLink *)displaylink{
//    NSLog(@"test");
}
-(void)onClick:(UIButton*)sender{
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie4.m4v"];
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    if ([sender.currentTitle isEqualToString:@"录制"]) {
        [sender setTitle:@"结束" forState:(UIControlStateNormal)];
        NSLog(@"Start recording");
        unlink([pathToMovie UTF8String]);//如果已经存在文件,AVAssetWriter会有移仓,删除旧文件
        _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        _movieWriter.encodingLiveVideo = YES;
        [_filter addTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];

        _mLableTime = 0;
        _mLabel.hidden = NO;
        [self onTimer:nil];
        _mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    }else{
        [sender setTitle:@"录制" forState:(UIControlStateNormal)];
        NSLog(@"End recording");
        _mLabel.hidden = YES;
        if (_mTimer) {
            [_mTimer invalidate];
        }
        [_filter removeTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecording];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];  
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie)) {//特定的视频是否有资格保存到已保存的相册中?
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"视频保存失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"视频保存成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        }
#pragma clang diagnostic pop
    }
}
-(void)onTimer:(id)sender{
    _mLabel.text = [NSString stringWithFormat:@"录制时间:%lds",_mLableTime++];
    [_mLabel sizeToFit];
}
-(void)updateSliderValue:(UISlider*)sender{
    [(GPUImageSepiaFilter *)_filter setIntensity:sender.value];
}
@end
