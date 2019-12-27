//
//  dataToImageViewController.m
//  learnGPUImage
//
//  Created by you&me on 2019/9/18.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "dataToImageViewController.h"
#import <GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface dataToImageViewController ()
@property(nonatomic,strong)UILabel *mLabel;
@property(nonatomic,strong)UIImageView *mImageView;
@property(nonatomic,strong)GPUImageRawDataOutput *mOutput;

@end

@implementation dataToImageViewController
{
    GPUImageVideoCamera *videoCamera;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    GPUImageView *filterView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    self.view = filterView;
    self.mImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.mImageView];

    self.mLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 200, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];

    videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:(AVCaptureDevicePositionFront)];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;

    self.mOutput =[[GPUImageRawDataOutput alloc]initWithImageSize:CGSizeMake(640, 480) resultsInBGRAFormat:YES];
    [videoCamera addTarget:self.mOutput];

    //输出的二进制数据转换为CVPixelBufferRef
    __weak typeof(self) wself = self;
    __weak typeof(self.mOutput) weakOutput = self.mOutput;
    [self.mOutput setNewFrameAvailableBlock:^{
        __strong GPUImageRawDataOutput *strongOutput = weakOutput;
        __strong typeof(wself) strongSelf = wself;
        [strongOutput lockFramebufferForReading];
        GLubyte *outputBytes = [strongOutput rawBytesForImage];
        NSInteger bytesPerRow = [strongOutput bytesPerRowInOutput];
        CVPixelBufferRef pixelBuffer = NULL;
        CVReturn ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, 640, 480, kCVPixelFormatType_32BGRA, outputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
        if (ret != kCVReturnSuccess) {
            NSLog(@"status %d",ret);
        }

        //        [ViewController convertBGRAtoRGBA:strongOutput.rawBytesForImage withSize:bytesPerRow * 480];
        //        NSData* data = [[NSData alloc] initWithBytes:strongOutput.rawBytesForImage length:bytesPerRow * 480];
        //        UIImage *uiimage = [[UIImage alloc] initWithData:data];
        [strongOutput unlockFramebufferAfterReading];
        if (pixelBuffer == NULL) {
            return;
        }
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, outputBytes, bytesPerRow * 480, NULL);
        CGImageRef cgImage = CGImageCreate(640, 480, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        [strongSelf updateWithImage:image];

        //        NSData *pngData = UIImagePNGRepresentation(image);

        CGImageRelease(cgImage);
        CFRelease(pixelBuffer);
    }];
    [videoCamera startCameraCapture];
    CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
}
+ (void)convertBGRAtoRGBA:(unsigned char *)data withSize:(size_t)sizeOfData {
    for (unsigned char *p = data; p < data + sizeOfData; p += 4) {
        unsigned char r = *(p + 2);
        unsigned char b = *p;
        *p = r;
        *(p + 2) = b;
    }
}

- (void)updateWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mImageView.image = image;
    });
}

- (void)updateProgress
{
    self.mLabel.text = [[NSDate dateWithTimeIntervalSinceNow:0] description];
    [self.mLabel sizeToFit];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
