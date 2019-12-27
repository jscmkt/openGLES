//
//  ViewController.m
//  learnGPUImage
//
//  Created by you&me on 2019/8/8.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "ViewController.h"
#import "GPUImageBeautifyFilter.h"
#import <GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
@property(nonatomic,strong)UILabel * mLabel;
@property(nonatomic,strong)GPUImageVideoCamera *videoCamera;
@property(nonatomic,strong)GPUImageMovieWriter *moviewWriter;
@property(nonatomic,strong)GPUImageView *filterView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:(AVCaptureDevicePositionFront)];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorRearFacingCamera = YES;//是否镜像摄像头
    self.filterView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    self.filterView.center = self.view.center;
    [self.view addSubview:self.filterView];

    NSString *pathToMoview = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMoview UTF8String]);//释放这个文件占用的空间
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMoview];

    _moviewWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    self.videoCamera.audioEncodingTarget = _moviewWriter;
    _moviewWriter.encodingLiveVideo = YES;
    [self.videoCamera startCameraCapture];
    GPUImageBeautifyFilter *beautifyFilterFilter = [[GPUImageBeautifyFilter alloc]init];
    [self.videoCamera addTarget:beautifyFilterFilter];
    [beautifyFilterFilter addTarget:self.filterView];
    [beautifyFilterFilter addTarget:_moviewWriter];
    [_moviewWriter startRecording];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [beautifyFilterFilter removeTarget:_moviewWriter];
        [_moviewWriter finishRecording];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMoview)) {
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{

                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        }
        else {
            NSLog(@"error mssg)");
        }
    });
}


@end
