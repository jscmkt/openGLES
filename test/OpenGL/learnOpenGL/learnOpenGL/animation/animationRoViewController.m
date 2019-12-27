//
//  animationRoViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/5/23.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "animationRoViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"

#define const_length 512
@interface animationRoViewController ()
@property(nonatomic,strong)EAGLContext *mContext;
@property(nonatomic,strong)GLKBaseEffect *mBaseEffect;
@property(nonatomic,strong)GLKBaseEffect *mExtraEffect;

@property(nonatomic,assign)int mCount;
//FBO  帧缓存
@property(nonatomic,assign)GLint mDefaultFBO;
@property(nonatomic,assign)GLuint mExtraFBO;
@property(nonatomic,assign)GLuint mExtraDepthBuffer;
@property(nonatomic,assign)GLuint mExtraTexture;

@property(nonatomic,assign)long mBaseRotate;
@property(nonatomic,assign)long mExtraRotate;
@property (weak, nonatomic) IBOutlet UISwitch *mExtraSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mBaseSwitch;

@end

@implementation animationRoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    GLKView* view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    [EAGLContext setCurrentContext:self.mContext];


    //顶点数据，前三个是顶点坐标， 中间三个是顶点颜色，    最后两个是纹理坐标
    GLfloat attrArr[] =
    {
        -1.0f, 1.0f, 0.0f,      0.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
        1.0f, 1.0f, 0.0f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,//右上
        -1.0f, -1.0f, 0.0f,     1.0f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        1.0f, -1.0f, 0.0f,      0.0f, 0.0f, 1.0f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    //顶点索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        //可以去掉注释
                0, 2, 4,
                0, 4, 1,
                2, 3, 4,
                1, 4, 3,
    };
    self.mCount = sizeof(indices) / sizeof(GLuint);

    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);

    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);

    //可以去掉注释
    //    glEnableVertexAttribArray(GLKVertexAttribColor);
    //    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 3);

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 6);


    self.mBaseEffect = [[GLKBaseEffect alloc] init];
    self.mExtraEffect = [[GLKBaseEffect alloc] init];

    glEnable(GL_DEPTH_TEST);

    [self preparePointOfViewWithAspectRatio:
     CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds)];


    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"png"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];

    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    self.mExtraEffect.texture2d0.enabled = self.mBaseEffect.texture2d0.enabled = GL_TRUE;
    self.mExtraEffect.texture2d0.name = self.mBaseEffect.texture2d0.name = textureInfo.name;
    NSLog(@"panda texture %d", textureInfo.name);

    int width, height;
    width = self.view.bounds.size.width * self.view.contentScaleFactor;
    height = self.view.bounds.size.height * self.view.contentScaleFactor;
    [self extraInitWithWidth:width height:height]; //特别注意这里的大小

    self.mBaseRotate = self.mExtraRotate = 0;

}
-(void)extraInitWithWidth:(GLint)width height:(GLint)height{
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_mDefaultFBO);//创建临时变量保存纹理的真实大小
    glGenTextures(1, &_mExtraTexture);//生成纹理名称
    NSLog(@"render texture %d",self.mExtraTexture);
    glGenFramebuffers(1, &_mExtraFBO);//创建一个帧染缓冲区对象
    glGenRenderbuffers(1, &_mExtraDepthBuffer);//创建一个渲染缓冲区对象
    glBindFramebuffer(GL_FRAMEBUFFER, self.mExtraFBO);//将渲染缓冲区x绑定到对应的管线上
    glBindTexture(GL_TEXTURE_2D, self.mExtraTexture);
    glTexImage2D(GL_TEXTURE_2D,//指定活动纹理单元的目标纹理。必须是GL_TEXTURE_2D,GL_TEXTURE_CUBE_MAP_POSITIVE_X,GL_TEXTURE_CUBE_MAP_NEGATIVE_X,GL_TEXTURE_CUBE_MAP_POSITIVE_Y,GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,GL_TEXTURE_CUBE_MAP_POSITIVE_Z,或GL_TEXTURE_CUBE_MAP_NEGATIVE_Z.
                 0,//指定细节级别，0级表示基本图像，n级则表示Mipmap缩小n级之后的图像（缩小2^n）
                 GL_RGBA,// 指定纹理内部格式，必须是下列符号常量之一：GL_ALPHA，GL_LUMINANCE，GL_LUMINANCE_ALPHA，GL_RGB，GL_RGBA。
                 width,
                 height,//指定纹理图像的宽高，所有实现都支持宽高至少为64 纹素的2D纹理图像和宽高至少为16 纹素的立方体贴图纹理图像 。
                 0,// 指定边框的宽度。必须为0。
                 GL_RGBA,// 指定纹理数据的格式。必须匹配internalformat。下面的符号值被接受：GL_ALPHA，GL_RGB，GL_RGBA，GL_LUMINANCE，和GL_LUMINANCE_ALPHA。
                 GL_UNSIGNED_BYTE,//指定纹理数据的数据类型。下面的符号值被接受：GL_UNSIGNED_BYTE，GL_UNSIGNED_SHORT_5_6_5，GL_UNSIGNED_SHORT_4_4_4_4，和GL_UNSIGNED_SHORT_5_5_5_1。
                 NULL);//  指定一个指向内存中图像数据的指针。
    /*

     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
     GL_TEXTURE_2D: 操作2D纹理.
     GL_TEXTURE_WRAP_S: S方向上的贴图模式.
     GL_CLAMP: 将纹理坐标限制在0.0,1.0的范围之内.如果超出了会如何呢.不会错误,只是会边缘拉伸填充.

     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
     这里同上,只是它是T方向

     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
     这是纹理过滤
     GL_TEXTURE_MAG_FILTER: 放大过滤
     GL_LINEAR: 线性过滤, 使用距离当前渲染像素中心最近的4个纹素加权平均值.

     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
     GL_TEXTURE_MIN_FILTER: 缩小过滤
     GL_LINEAR_MIPMAP_NEAREST: 使用GL_NEAREST对最接近当前多边形的解析度的两个层级贴图进行采样,然后用这两个值进行线性插值.
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    //附加到帧缓冲上
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.mExtraTexture, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, self.mExtraDepthBuffer);//渲染缓冲对象绑定
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);//创建一个深度和模板渲染缓冲对象
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.mExtraDepthBuffer);//把帧缓冲对象附加上

    GLenum status;
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    switch (status) {
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"fbo complete width %d height %d",width, height);

            break;
        case GL_FRAMEBUFFER_UNSUPPORTED:
            NSLog(@"fbo unsupported");
            break;
        default:
            NSLog(@"framebuffer Error");
            break;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, self.mDefaultFBO);
    glBindTexture(GL_TEXTURE_2D, 0);

}

//MVP矩阵
- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
    self.mExtraEffect.transform.projectionMatrix = self.mBaseEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              20.0f);

    self.mExtraEffect.transform.modelviewMatrix = self.mBaseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 3.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
}
-(void)update{
    GLKMatrix4 modelViewMatrix;
    if (self.mBaseSwitch.on) {
        ++self.mBaseRotate;
        modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, -3);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(self.mBaseRotate), 1, 1, 1);
        self.mBaseEffect.transform.modelviewMatrix = modelViewMatrix;


    }
    if (self.mExtraSwitch.on) {
        self.mExtraRotate += 2;
        modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, -3);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(self.mExtraRotate), 1, 1, 1);
        self.mExtraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
}

- (void)renderFBO {
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, self.mExtraFBO);

    //如果视口和主缓存的不同，需要根据当前的大小调整，同时在下面的绘制时需要调整glviewport
    //    glViewport(0, 0, const_length, const_length)
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self.mExtraEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);

    glBindFramebuffer(GL_FRAMEBUFFER, self.mDefaultFBO);
    self.mBaseEffect.texture2d0.name = self.mExtraTexture;
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self renderFBO];
    [(GLKView *)self.view bindDrawable];

    //glviewport() 见上面
    glClearColor(0.3f, 0.3f, 0.3f, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self.mBaseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
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
