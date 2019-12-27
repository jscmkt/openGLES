#import <Foundation/Foundation.h>
#import "GPUImageContext.h"

@protocol GPUImageTextureOutputDelegate;

@interface GPUImageTextureOutput : NSObject <GPUImageInput>
{
    GPUImageFramebuffer *firstInputFramebuffer;
}

@property(readwrite, unsafe_unretained, nonatomic) id<GPUImageTextureOutputDelegate> delegate;//实现了GPUImageTextureOutputDelegate协议的回调对象；

@property(readonly) GLuint texture;//OpenGL ES的纹理，只读；
@property(nonatomic) BOOL enabled;

- (void)doneWithTexture;//结束处理纹理图像，解锁firstInputFramebuffer。

@end

@protocol GPUImageTextureOutputDelegate
- (void)newFrameReadyFromTextureOutput:(GPUImageTextureOutput *)callbackTextureOutput;
@end
