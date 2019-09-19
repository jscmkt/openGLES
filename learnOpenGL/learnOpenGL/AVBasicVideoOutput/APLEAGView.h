//
//  APLEAGView.h
//  learnOpenGL
//
//  Created by you&me on 2019/7/22.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
NS_ASSUME_NONNULL_BEGIN

@interface APLEAGView : UIView
@property(nonatomic)GLfloat preferredRotation;///< 旋转的弧度
@property(nonatomic)CGSize presentationRect;///< 显示视频的大小
@property(nonatomic)GLfloat chromaThreshold;///< 色度
@property(nonatomic)GLfloat lumaThreshold;///< 亮度

-(void)setupGL;

-(void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
