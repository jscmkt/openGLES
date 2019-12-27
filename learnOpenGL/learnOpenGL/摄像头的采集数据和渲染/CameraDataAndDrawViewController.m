//
//  CameraDataAndDrawViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/9/27.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "CameraDataAndDrawViewController.h"
#import "LYOpenGLView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface CameraDataAndDrawViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic,strong)UILabel *mLabel;
@property(nonatomic,strong)AVCaptureSession *mCaptureSession;//z负责输入和输出设备之间的数据传递
@property(nonatomic,strong)AVCaptureDeviceInput *mCaptureDeviceInput;//z负责从AVCaptureDevice获得输入数据
@property(nonatomic,strong)AVCaptureVideoDataOutput *mCaptureDeviceOutput;//Output

@property(nonatomic,strong)LYOpenGLView *mGLView;
@end

@implementation CameraDataAndDrawViewController{
    dispatch_queue_t mProcessQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mGLView = (LYOpenGLView *)self.view;
    [self.mGLView setupGL];

    self.mCaptureSession = [[AVCaptureSession alloc]init];
    self.mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;

    mProcessQueue = dispatch_queue_create("mProcessQueue", DISPATCH_QUEUE_SERIAL);

    AVCaptureDevice *inputCarema = nil;
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            inputCarema = device;
        }
    }

    self.mCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:inputCarema error:nil];
    if ([self.mCaptureSession canAddInput:self.mCaptureDeviceInput]) {
        [self.mCaptureSession addInput:self.mCaptureDeviceInput];
    }

    self.mCaptureDeviceOutput = [[AVCaptureVideoDataOutput alloc]init];
    [self.mCaptureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];//如果数据输出队列被阻塞，则丢弃(在处理静止图像时)

    self.mGLView.isFullYUVRange = YES;
    [self.mCaptureDeviceOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)}];
    [self.mCaptureDeviceOutput setSampleBufferDelegate:self queue:mProcessQueue];
    if ([self.mCaptureSession canAddOutput:self.mCaptureDeviceOutput]) {
        [self.mCaptureSession addOutput:self.mCaptureDeviceOutput];
    }

    AVCaptureConnection *connection = [self.mCaptureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:(AVCaptureVideoOrientationPortraitUpsideDown)];

    [self.mCaptureSession startRunning];

    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];

}
-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    static long frameID = 0;
    ++frameID;
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [self.mGLView displayPixelBuffer:pixelBuffer];
        self.mLabel.text = [NSString stringWithFormat:@"%ld",frameID];
        CFRelease(sampleBuffer);

    });
}

#pragma mark - Simple Editor

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




@end
