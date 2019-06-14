//
//  GLLearnView.m
//  learnOpenGL
//
//  Created by you&me on 2019/3/19.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "GLLearnView.h"
#import <OpenGLES/ES2/gl.h>


@interface GLLearnView ()
@property(nonatomic,strong)EAGLContext *myContext;
@property(nonatomic,strong)CAEAGLLayer *myEagLayer;
@property(nonatomic,assign)GLuint       myProgram;
@property(nonatomic,assign)GLuint       myColorRenderBuffer;
@property(nonatomic,assign)GLuint       myColorFrameBuffer;
-(void)setupLayer;
@end
@implementation GLLearnView


+(Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)layoutSubviews{
    [self setupLayer];
    [self setupContext];
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
}

-(void)render{
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    CGFloat scale = [[UIScreen mainScreen] scale];//获取视图放大倍数
    glViewport(self.frame.origin.x *scale, self.frame.origin.y*scale, self.frame.size.width * scale, self.frame.size.height *scale);//设置视图大小
    //读取文件路径
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
    NSString * fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];

    //加载shader
    self.myProgram = [self loadShaders:vertFile frag:fragFile];

    //链接
    glLinkProgram(self.myProgram);
    GLint linkSuccess;glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        MSLog(@"error:%@",messageString);
        return;
    }
    else{
        MSLog(@"link ok");
        glUseProgram(self.myProgram);//成功便使用，避免由于未使用导致的bug
    }

    //前三个是顶点坐标，后面两个是纹理坐标
    GLfloat attrArr[] = {

        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };

    GLuint attbuffer;
    glGenBuffers(1, &attbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);

    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    glEnableVertexAttribArray(position);

    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float*)NULL + 3);
    glEnableVertexAttribArray(textCoor);

    //加载纹理
    [self setupTexture:@"for_test"];

    //获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    GLuint rotate = glGetUniformLocation(self.myProgram, "rotateMatrix");

    float radians = 10 * 3.14159f / 180.0f;
    float s = sin(radians);
    float c = cos(radians);

    //z轴旋转矩阵
    GLfloat zRotation[16] = { //
        c, -s, 0, 0.2, //
        s, c, 0, 0,//
        0, 0, 1.0, 0,//
        0.0, 0, 0, 1.0//
    };

    //设置旋转矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);

    glDrawArrays(GL_TRIANGLES, 0, 6);

    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}
-(GLuint)setupTexture:(NSString*)fileName{
    //1.获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        MSLog(@"Fauked to load image %@",fileName);
        exit(1);

    }
    //2. 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);

    GLubyte *spriteData = (GLubyte*) calloc(width * height * 4, sizeof(GLubyte));//rgba 共4和字节

    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);

    //3.在cgcontextref上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);

    //4.绑定纹理到默认的纹理ID(这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做)
    glBindTexture(GL_TEXTURE_2D, 0);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    float fw = width,fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 9, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glBindTexture(GL_TEXTURE_2D, 0);
    return 0;



    return 0;
}
/**
 *  c语言变异流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glComplieShader、glAttachShader、glLinkProgram三步
 *  @param vert 顶点着色器
 *  @param frag 偏远着色器
 *
 *  @return 编译成功的shaders
 */
-(GLuint)loadShaders:(NSString*)vert frag:(NSString*)frag{
    GLuint verShader,fragShader;
    GLint program = glCreateProgram();
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];

    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);

    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    return program;
}

-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    //读取字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar*)[content UTF8String];

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}
-(void)setupFrameBuffer{
    GLuint buffer;
    glGenBuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    //设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    //将 _colorRenderBuffer 装配到GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

-(void)setupRenderBuffer{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer ;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    //为颜色缓冲区 分配存储空间
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];

}

-(void)destoryRenderAndFrameBuffer{
    glDeleteBuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    glDeleteBuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;

}



-(void)setupContext{
    //制定OpenGL渲染API的版本 ，在这里我们使用OpenGLES2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        MSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    //设置为当前上下文
    if (![EAGLContext setCurrentContext:context]) {
        MSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    self.myContext = context;
}

-(void)setupLayer{

    self.myEagLayer = (CAEAGLLayer*)self.layer;
    //设置放大倍数
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    //CALayer默认是透明的，必须将它设为不透明才能让其可见
    self.myEagLayer.opaque = YES;

    //设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.myEagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}


@end
