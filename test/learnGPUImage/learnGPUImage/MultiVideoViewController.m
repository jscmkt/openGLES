//
//  MultiVideoViewController.m
//  learnGPUImage
//
//  Created by you&me on 2019/9/25.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "MultiVideoViewController.h"
#import <GPUImage.h>
@interface MultiVideoViewController ()
@property(nonatomic,strong)NSMutableArray<GPUImageView *> *gpuImageViewArray;
@property(nonatomic,strong)NSMutableArray<GPUImageMovie *> *gpuImageMovieArray;
@end

@implementation MultiVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gpuImageViewArray = [[NSMutableArray<GPUImageView*> alloc]init];
    self.gpuImageMovieArray = [[NSMutableArray<GPUImageMovie*> alloc]init];
    NSArray *fileNamesArray = @[@"abc",@"def",@"abc",@"def",@"abc",@"def"];

    for (int indexRow = 0; indexRow<2; ++indexRow) {
        for (int indexColumn = 0; indexColumn < 3; ++indexColumn) {
            CGRect frame = CGRectMake(CGRectGetWidth(self.view.bounds) / 3 * indexColumn,
                                      100 + CGRectGetWidth(self.view.bounds) / 3 * indexRow,
                                      CGRectGetWidth(self.view.bounds) / 3,
                                      CGRectGetWidth(self.view.bounds) / 3);
            GPUImageMovie *movie = [self getGPUImageMovieWithFileName:fileNamesArray[indexRow * 3 + indexColumn]];
            GPUImageView *view = [self buildGPUImageViewWithFrame:frame imageMovie:movie];
            [self.gpuImageViewArray addObject:view];
            [self.gpuImageMovieArray addObject:movie];
        }
    }
}

-(GPUImageMovie *)getGPUImageMovieWithFileName:(NSString*)fileName{
    NSURL *videoUrl = [[NSBundle mainBundle]URLForResource:fileName withExtension:@"mp4"];

    GPUImageMovie *imageMovie = [[GPUImageMovie alloc]initWithURL:videoUrl];
    return imageMovie;
}

-(GPUImageView *)buildGPUImageViewWithFrame:(CGRect)frame imageMovie:(GPUImageMovie *)imageMovie{
    GPUImageView *imageView = [[GPUImageView alloc]initWithFrame:frame];
    [self.view addSubview:imageView];

    //1080  1920,这里已知视频的尺寸,可以限度去CVPixelBuffer,再用CVPixelBufferGetHeight/Width
    //剪裁
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] init];

    GPUImageTransformFilter *transformFilter = [[GPUImageTransformFilter alloc]init];
    transformFilter.affineTransform = CGAffineTransformMakeRotation(M_PI_2);

    GPUImageOutput *tmpFilter;
    tmpFilter = imageMovie;

    [tmpFilter addTarget:cropFilter];
    tmpFilter = cropFilter;

    [tmpFilter addTarget:transformFilter];
    tmpFilter = cropFilter;

    [tmpFilter addTarget:imageView];

    imageMovie.playAtActualSpeed = YES;
    imageMovie.shouldRepeat = YES;

    [imageMovie startProcessing];
    return imageView;
}
@end
