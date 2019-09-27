#import <UIKit/UIKit.h>
#import "GPUImageOutput.h"


@interface GPUImagePicture : GPUImageOutput
{
    CGSize pixelSizeOfImage;// 图像的像素大小
    BOOL hasProcessedImage;///< 图像是否已处理
    
    dispatch_semaphore_t imageUpdateSemaphore;///< 图像处理的GCD信号量
}

// Initialization and teardown
- (id)initWithURL:(NSURL *)url;
- (id)initWithImage:(UIImage *)newImageSource;
- (id)initWithCGImage:(CGImageRef)newImageSource;
- (id)initWithImage:(UIImage *)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput;
- (id)initWithCGImage:(CGImageRef)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput;///< 用源图像newImageSource和是否采用mipmaps来初始化GPUImagePicture。
//如果图像大小超过OpenGL ES最大纹理宽高，或者使用mipmaps，或者图像数据是浮点型、颜色空间不对等都会采用CoreGraphics重新绘制图像。
//然后通过glTexImage2D把图像数据发送给GPU，最后释放掉CPU的图像数据。



// Image rendering
- (void)processImage;
- (CGSize)outputImageSize;

/**
 * Process image with all targets and filters asynchronously
 * The completion handler is called after processing finished in the
 * GPU's dispatch queue - and only if this method did not return NO.
 *
 * @returns NO if resource is blocked and processing is discarded, YES otherwise
 */
/*通知targets处理图像，并在完成后调用complete代码块。在处理开始时，会标记hasProcessedImage为YES，并调用dispatch_semaphore_wait()，确定上次处理已经完成，否则取消这次处理。*/
- (BOOL)processImageWithCompletionHandler:(void (^)(void))completion;
- (void)processImageUpToFilter:(GPUImageOutput<GPUImageInput> *)finalFilterInChain withCompletionHandler:(void (^)(UIImage *processedImage))block;

@end
