////
////  APLEAGView.m
////  learnOpenGL
////
////  Created by you&me on 2019/7/22.
////  Copyright © 2019 you&me. All rights reserved.
////
//
//#import "APLEAGView.h"
//#import <QuartzCore/QuartzCore.h>
//#import <AVFoundation/AVFoundation.h>
//#import <mach/mach_time.h>
//
////Uniform index
//enum{
//    UNIFORM_Y,
//    UNIFORM_UV,
//    UNIFORM_LUMA_THRESHOLD,
//    UNIFORM_CHROMA_THRESHOLD,
//    UNIFORM_ROTATION_ANGLE,
//    UNIFORM_COLOR_CONVERSION_MATRIX,
//    NUM_UNIFORMS
//};
//GLint uniforms[NUM_UNIFORMS];
//
////Attribute index
//enum{
//    ATTRIB_VERTEX,
//    ATTRIB_TEXCOORD,
//    NUM_ATTRIBUTES
//};
//
////颜色转换常数(YUV到RGB)，包括从16-235/16-240(视频范围)调整
//
////// BT.601, which is the standard for SDTV.
//static const GLfloat kColorConversion601[] = {
//    1.164,  1.164, 1.164,
//    0.0, -0.392, 2.017,
//    1.596, -0.813,   0.0,
//};
//
//// BT.709, which is the standard for HDTV.
//static const GLfloat kColorConversion709[] = {
//    1.164,  1.164, 1.164,
//    0.0, -0.213, 2.112,
//    1.793, -0.533,   0.0,
//};
//
//@interface APLEAGView   ()
//{
//    //CAEAGLLayer的像素尺寸。
//    GLint _backingWidth;
//    GLint _backingHeight;
//
//    EAGLContext *_context;
//    CVOpenGLESTextureRef _lumaTexture;
//    CVOpenGLESTextureRef _chromaTexture;
//    CVOpenGLESTextureCacheRef _videoTextureCache;
//
//    GLuint _frameBufferHandle;
//    GLuint _colorBufferHandle;
//
//    const GLfloat *_preferredConversion;
//
//}
//
//@property(nonatomic) GLuint program;
//
//-(void)setupBuffers;
//-(void)cleanUptextures;
//
//
//- (BOOL)loadShaders;
//- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL;
//- (BOOL)linkProgram:(GLuint)prog;
//- (BOOL)validateProgram:(GLuint)prog;
//@end
//
//@implementation APLEAGView
//
//+(Class)layerClass{
//    return [CAEAGLLayer class];
//}
//
//-(instancetype)initWithCoder:(NSCoder *)aDecoder{
//    if (self = [super initWithCoder:aDecoder]) {
//        //在显示器上使用2x比例
//        self.contentScaleFactor = [[UIScreen mainScreen]scale];
//
//        //配置layer
//        CAEAGLLayer *eaglLayer = (CAEAGLLayer *) self.layer;
//
//        eaglLayer.opaque = YES;
//        eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
//        _context = [[EAGLContext alloc]initWithAPI:(kEAGLRenderingAPIOpenGLES2)];
//        if (!_context || ![EAGLContext setCurrentContext:_context] || ![self loadShaders]) {
//            return nil;
//        }
//        _preferredConversion = kColorConversion709;
//    }
//    return self;
//}
//
//
//#pragma mark - OpenGL setup
//-(void)setupGL{
//    [EAGLContext setCurrentContext:_context];
//    [self setupBuffers];
//    [self loadShaders];
//
//    glUseProgram(self.program);
//
//    //0 and 1 are the texture IDs of _lumaTexture and _chromaTexture respectively
//    glUniform1i(uniforms[UNIFORM_Y], 0);
//    glUniform1i(uniforms[UNIFORM_UV], 1);
//    glUniform1f(uniforms[UNIFORM_LUMA_THRESHOLD], self.lumaThreshold);
//    glUniform1f(uniforms[UNIFORM_CHROMA_THRESHOLD], self.chromaThreshold);
//    glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], self.preferredRotation);
//    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
//
//    //Create CVOpenGLESTextureCacheRef for optiomal CVPixelBufferRef to GLES texture conversion
//    if (!_videoTextureCache) {
//        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
//        if (err != noErr) {
//            MSLog(@"Error at CVOpenGLESTextureCacheCreate %d",err);
//            return;
//        }
//    }
//}
//
//
//#pragma mark - Utilities
//-(void)setupBuffers{
//    glDisable(GL_DEPTH_TEST);
//
//    glEnableVertexAttribArray(ATTRIB_VERTEX);
//    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
//    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
//    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
//
//    glGenFramebuffers(1, &_frameBufferHandle);
//    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
//
//    glGenRenderbuffers(1, &_colorBufferHandle);
//    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
//
//    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
//
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
//
//    //将renderbuffer对象附加到framebuffer对象
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
//    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
//        NSLog(@"Failed to make complete framebuffer pbject %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
//    }
//}
//
//-(void)cleanUptextures{
//    if (_lumaTexture) {
//        CFRelease(_lumaTexture);
//        _lumaTexture = NULL;
//    }
//    if(_chromaTexture){
//        CFRelease(_chromaTexture);
//        _chromaTexture = NULL;
//    }
//    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
//}
//
//-(void)dealloc{
//    [self cleanUptextures];
//    if (_videoTextureCache) {
//        CFRelease(_videoTextureCache);
//    }
//}
//
//#pragma mark - OpenGLES drawing
//-(void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer{
//    CVReturn err;
//    if (pixelBuffer != NULL) {
//        int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
//        int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
//
//        if (!_videoTextureCache) {
//            MSLog(@"No video texture cache");
//            return;
//        }
//
//        [self cleanUptextures];
//        /*
//         使用像素缓冲区的颜色附件来确定适当的颜色转换矩阵。
//         判断视频数据格式
//         */
//        CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
//        if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
//            _preferredConversion = kColorConversion601;
//        }else{
//            _preferredConversion = kColorConversion709;
//        }
//        //cvopenglestexturececreatetexturefromimage将从CVPixelBufferRef创建最佳的纹理。
//        //从像素缓冲区创建Y和UV纹理。这些纹理将绘制在帧缓冲区y平面上。
//        glActiveTexture(GL_TEXTURE0);
//        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RED_EXT, frameWidth, frameHeight, GL_RED_EXT, GL_UNSIGNED_BYTE, 0, &_lumaTexture);
//        if (err) {
//            MSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d",err);
//        }
//
//        glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//        //UV-plane
//        glActiveTexture(GL_TEXTURE1);
//        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RG_EXT, frameWidth / 2, frameHeight / 2 , GL_RG_EXT, GL_UNSIGNED_BYTE, 1, &_chromaTexture);
//        if (err) {
//            MSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
//        }
//        glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
//        MSLog(@"id %d",CVOpenGLESTextureGetName(_chromaTexture));
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//        glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
//
//        //set the view port to the entire view
//        glViewport(0, 0, _backingWidth, _backingHeight);
//    }
//    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT);
//
//    //use shader program
//    glUseProgram(self.program);
//    glUniform1f(uniforms[UNIFORM_LUMA_THRESHOLD], self.lumaThreshold);
//    glUniform1f(uniforms[UNIFORM_CHROMA_THRESHOLD], self.chromaThreshold);
//    glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], self.preferredRotation);
//    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
//
//    //根据视频的方向和长宽比设置四顶点。
//    CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(self.presentationRect, self.layer.bounds);
//
//
//    //计算归一化的四坐标来绘制坐标系。
//    CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
//    CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width / self.layer.bounds.size.width, vertexSamplingRect.size.height / self.layer.bounds.size.height);
//
//    //对顶点标准化
//    if(cropScaleAmount.width > cropScaleAmount.height){
//        normalizedSamplingSize.width = 1.0;
//        normalizedSamplingSize.height = cropScaleAmount.height / cropScaleAmount.width;
//    }else{
//        normalizedSamplingSize.width = 1.0;
//        normalizedSamplingSize.height = cropScaleAmount.width / cropScaleAmount.height;
//    }
//
//    //四顶点数据定义了二维平面的区域，我们在该区域上绘制像素缓冲区。
//    //使用(- 1,1)和(1,1)分别作为左下角和右上角坐标形成的顶点数据覆盖整个屏幕。
//    GLfloat quadVertexData[] = {
//        -1 * normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
//        normalizedSamplingSize.width    , -1 * normalizedSamplingSize.height,
//        -1 * normalizedSamplingSize.width, normalizedSamplingSize.height,
//        normalizedSamplingSize.width,   normalizedSamplingSize.height
//    };
//    //update attribute values
//    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, quadVertexData);
//    glEnableVertexAttribArray(ATTRIB_VERTEX);
//
//
////    纹理顶点的设置使我们垂直翻转纹理。这样一来，左上角的原始缓冲区就与OpenGL的左下角纹理坐标系统相匹配。
//    CGRect textureSamplingRect = CGRectMake(0, 0, 1, 1);
//    GLfloat quadTextureData[] = {
//        0,1,
//        1,1,
//        0,0,
//        1,0
//    };
//    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, 0, 0, quadTextureData);
//    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
//    [_context presentRenderbuffer:GL_RENDERBUFFER];
//
//}
//
//#pragma mark -  OpenGL ES 2 shader compilation
//
//- (BOOL)loadShaders
//{
//    GLuint vertShader, fragShader;
//    NSURL *vertShaderURL, *fragShaderURL;
//
//    // Create the shader program.
//    self.program = glCreateProgram();
//
//    // Create and compile the vertex shader.
//    vertShaderURL = [[NSBundle mainBundle] URLForResource:@"APLShader" withExtension:@"vsh"];
//    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER URL:vertShaderURL]) {
//        NSLog(@"Failed to compile vertex shader");
//        return NO;
//    }
//
//    // Create and compile fragment shader.
//    fragShaderURL = [[NSBundle mainBundle] URLForResource:@"APLShader" withExtension:@"fsh"];
//    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER URL:fragShaderURL]) {
//        NSLog(@"Failed to compile fragment shader");
//        return NO;
//    }
//
//    // Attach vertex shader to program.
//    glAttachShader(self.program, vertShader);
//
//    // Attach fragment shader to program.
//    glAttachShader(self.program, fragShader);
//
//    // Bind attribute locations. This needs to be done prior to linking.
//    glBindAttribLocation(self.program, ATTRIB_VERTEX, "position");
//    glBindAttribLocation(self.program, ATTRIB_TEXCOORD, "texCoord");
//
//    // Link the program.
//    if (![self linkProgram:self.program]) {
//        NSLog(@"Failed to link program: %d", self.program);
//
//        if (vertShader) {
//            glDeleteShader(vertShader);
//            vertShader = 0;
//        }
//        if (fragShader) {
//            glDeleteShader(fragShader);
//            fragShader = 0;
//        }
//        if (self.program) {
//            glDeleteProgram(self.program);
//            self.program = 0;
//        }
//
//        return NO;
//    }
//
//    // Get uniform locations.
//    uniforms[UNIFORM_Y] = glGetUniformLocation(self.program, "SamplerY");
//    uniforms[UNIFORM_UV] = glGetUniformLocation(self.program, "SamplerUV");
//    uniforms[UNIFORM_LUMA_THRESHOLD] = glGetUniformLocation(self.program, "lumaThreshold");
//    uniforms[UNIFORM_CHROMA_THRESHOLD] = glGetUniformLocation(self.program, "chromaThreshold");
//    uniforms[UNIFORM_ROTATION_ANGLE] = glGetUniformLocation(self.program, "preferredRotation");
//    uniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(self.program, "colorConversionMatrix");
//
//    // Release vertex and fragment shaders.
//    if (vertShader) {
//        glDetachShader(self.program, vertShader);
//        glDeleteShader(vertShader);
//    }
//    if (fragShader) {
//        glDetachShader(self.program, fragShader);
//        glDeleteShader(fragShader);
//    }
//
//    return YES;
//}
//
//- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL
//{
//    NSError *error;
//    NSString *sourceString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
//    if (sourceString == nil) {
//        NSLog(@"Failed to load vertex shader: %@", [error localizedDescription]);
//        return NO;
//    }
//
//    GLint status;
//    const GLchar *source;
//    source = (GLchar *)[sourceString UTF8String];
//
//    *shader = glCreateShader(type);
//    glShaderSource(*shader, 1, &source, NULL);
//    glCompileShader(*shader);
//
//#if defined(DEBUG)
//    GLint logLength;
//    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0) {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetShaderInfoLog(*shader, logLength, &logLength, log);
//        NSLog(@"Shader compile log:\n%s", log);
//        free(log);
//    }
//#endif
//
//    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
//    if (status == 0) {
//        glDeleteShader(*shader);
//        return NO;
//    }
//
//    return YES;
//}
//
//- (BOOL)linkProgram:(GLuint)prog
//{
//    GLint status;
//    glLinkProgram(prog);
//
//#if defined(DEBUG)
//    GLint logLength;
//    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0) {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(prog, logLength, &logLength, log);
//        NSLog(@"Program link log:\n%s", log);
//        free(log);
//    }
//#endif
//
//    glGetProgramiv(prog, GL_LINK_STATUS, &status);
//    if (status == 0) {
//        return NO;
//    }
//
//    return YES;
//}
//
//- (BOOL)validateProgram:(GLuint)prog
//{
//    GLint logLength, status;
//
//    glValidateProgram(prog);
//    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0) {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(prog, logLength, &logLength, log);
//        NSLog(@"Program validate log:\n%s", log);
//        free(log);
//    }
//
//    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
//    if (status == 0) {
//        return NO;
//    }
//
//    return YES;
//}
//@end
