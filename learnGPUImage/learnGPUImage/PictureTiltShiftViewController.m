//
//  PictureTiltShiftViewController.m
//  learnGPUImage
//
//  Created by you&me on 2019/8/14.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "PictureTiltShiftViewController.h"
#import <GPUImageView.h>
#import <GPUImagePicture.h>
#import <GPUImageTiltShiftFilter.h>
@interface PictureTiltShiftViewController ()
@property(nonatomic,strong)GPUImagePicture *sourcePicture;
@property(nonatomic,strong)GPUImageTiltShiftFilter *sepiaFilter;
@end

@implementation PictureTiltShiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    GPUImageView *primaryView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    self.view = primaryView;
    UIImage *inputImage = [UIImage imageNamed:@"face"];
    _sourcePicture = [[GPUImagePicture alloc]initWithImage:inputImage];
    _sepiaFilter = [[GPUImageTiltShiftFilter alloc]init];
    _sepiaFilter.blurRadiusInPixels = 40.0;//基础模糊的半径，以像素为单位。默认情况下这是7.0。
    [_sepiaFilter forceProcessingAtSize:primaryView.sizeInPixels];
    [_sourcePicture addTarget:_sepiaFilter];
    [_sepiaFilter addTarget:primaryView];
    [_sourcePicture processImage];

    //GPUImageContext相关的数据显示
    GLint size = [GPUImageContext maximumTextureSizeForThisDevice];
    GLint unit = [GPUImageContext maximumTextureUnitsForThisDevice];
    GLint vector = [GPUImageContext maximumVaryingVectorsForThisDevice];
    NSLog(@"%d %d %d", size, unit, vector);

}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    float rate = point.y / self.view.frame.size.height;
    NSLog(@"Processing");
    [_sepiaFilter setTopFocusLevel:rate - 0.1];
    [_sepiaFilter setBottomFocusLevel:rate + 0.1];
    [_sourcePicture processImage];
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
