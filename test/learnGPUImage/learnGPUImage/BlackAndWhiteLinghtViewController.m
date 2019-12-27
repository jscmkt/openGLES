//
//  BlackAndWhiteLinghtViewController.m
//  learnGPUImage
//
//  Created by you&me on 2019/9/25.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "BlackAndWhiteLinghtViewController.h"

#import <GPUImage.h>
@interface BlackAndWhiteLinghtViewController ()
@property(nonatomic,strong)GPUImageVideoCamera *videoCamera;
@property(nonatomic,strong)GPUImageSobelEdgeDetectionFilter *filter;
@property(nonatomic,strong)GPUImageMovieWriter *movieWriter;
@property(nonatomic,strong)GPUImageView *filterView;

@property(nonatomic,strong)CADisplayLink *mDisplayLink;
@end

@implementation BlackAndWhiteLinghtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:(AVCaptureDevicePositionBack)];
    _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;

    _filter = [[GPUImageSobelEdgeDetectionFilter alloc]init];
    _filter.edgeStrength = 2;

    _filterView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    self.view = _filterView;
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_filterView];
    [_videoCamera startCameraCapture];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }];

//    self.mDisplayLink = [cad]

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
