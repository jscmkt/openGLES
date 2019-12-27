#import <Foundation/Foundation.h>
#import "GPUImageContext.h"

struct GPUByteColorVector {//RGBA颜色空间结构体，便于读取二进制数据；
    GLubyte red;
    GLubyte green;
    GLubyte blue;
    GLubyte alpha;
};
typedef struct GPUByteColorVector GPUByteColorVector;

@protocol GPUImageRawDataProcessor;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@interface GPUImageRawDataOutput : NSObject <GPUImageInput> {
    CGSize imageSize;
    GPUImageRotationMode inputRotation;
    BOOL outputBGRA;
}
#else
@interface GPUImageRawDataOutput : NSObject <GPUImageInput> {
    CGSize imageSize;
    GPUImageRotationMode inputRotation;
    BOOL outputBGRA;
}
#endif

@property(readonly) GLubyte *rawBytesForImage;//二进制数据的指针
@property(nonatomic, copy) void(^newFrameAvailableBlock)(void);
@property(nonatomic) BOOL enabled;

// Initialization and teardown
- (id)initWithImageSize:(CGSize)newImageSize resultsInBGRAFormat:(BOOL)resultsInBGRAFormat;

// Data access// 获取特定位置的像素向量
- (GPUByteColorVector)colorAtLocation:(CGPoint)locationInImage;
// 每行数据大小
- (NSUInteger)bytesPerRowInOutput;
// 设置纹理大小
- (void)setImageSize:(CGSize)newImageSize;
//锁定帧缓存
- (void)lockFramebufferForReading;
- (void)unlockFramebufferAfterReading;

@end
