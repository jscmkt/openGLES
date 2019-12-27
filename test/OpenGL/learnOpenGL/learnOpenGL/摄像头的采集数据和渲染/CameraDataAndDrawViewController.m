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
    self.mGLView = (LYOpenGLView*)self.view;
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

}



@end
