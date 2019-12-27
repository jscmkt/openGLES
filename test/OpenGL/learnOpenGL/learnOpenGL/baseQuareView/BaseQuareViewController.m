//
//  BaseQuareViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/6/4.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "BaseQuareViewController.h"

@interface BaseQuareViewController ()
@property(nonatomic,strong)EAGLContext *mContext;
@property(nonatomic,assign)int mCount;
@property(nonatomic,strong)GLKBaseEffect *mEffect;
@property(nonatomic,assign)unsigned int cubeVAO;
@property(nonatomic,assign)long rotote;
@property(nonatomic,assign)double clock;
@property(nonatomic,strong)NSMutableArray *cubePosition;

@property(nonatomic,assign)GLuint  myProgram;
@end

@implementation BaseQuareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cubePosition = [[NSMutableArray alloc]init];
    NSDate *date = [NSDate date];
    self.clock = [date timeIntervalSince1970];
    self.mContext = [[EAGLContext alloc]initWithAPI:(kEAGLRenderingAPIOpenGLES3)];

    GLKView *view = (GLKView*)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.mContext];
    glEnable(GL_DEPTH_TEST);
    //正方体
//    float vertices[] = {
//        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
//        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
//        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
//
//        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,//左下
//        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,//右下
//        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,//右上
//        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,//右上
//        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,//左上
//        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,//左下
//
//        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//
//        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//
//        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
//        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
//        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
//        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//
//        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
//        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
//        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
//    };
//    GLKVector3 cubePosition[] = {
//
//        GLKVector3Make( 0.0f,  0.0f,  -10.0f),
//        GLKVector3Make( 2.0f,  5.0f, -15.0f),
//        GLKVector3Make(-1.5f, -2.2f, -2.5f),
//        GLKVector3Make(-3.8f, -2.0f, -12.3f),
//        GLKVector3Make( 2.4f, -0.4f, -3.5f),
//        GLKVector3Make(-1.7f,  3.0f, -7.5f),
//        GLKVector3Make( 1.3f, -2.0f, -2.5f),
//        GLKVector3Make( 1.5f,  2.0f, -2.5f),
//        GLKVector3Make( 1.5f,  0.2f, -1.5f),
//        GLKVector3Make(-1.3f,  1.0f, -1.5f)
//    } ;
//
//    for (int i=0; i<sizeof(cubePosition)/sizeof(GLKVector3); i++) {
//        [self.cubePosition addObject:[NSValue valueWithBytes:&cubePosition[i] objCType:@encode(GLKVector3)]];
//    }
//    unsigned int VBO;
//    glGenBuffers(1, &VBO);
//    glBindBuffer(GL_ARRAY_BUFFER, VBO);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//    glGenBuffers(1, &_cubeVAO);
//    glGenVertexArraysOES(1,&_cubeVAO);
//    glBindVertexArrayOES(self.cubeVAO);
////    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cubeVAO);
////    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(<#expression-or-type#>), <#const GLvoid *data#>, <#GLenum usage#>)
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)NULL+0);
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (float*)NULL + 3);
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"for_test" ofType:@"png"];
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:@{GLKTextureLoaderOriginBottomLeft:@1} error:nil];
//
//    //着色器
//    self.mEffect = [[GLKBaseEffect alloc]init];
//    GLfloat aspectRatio = (self.view.bounds.size.width / self.view.bounds.size.height);
//    self.mEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathRadiansToDegrees(45.0f), aspectRatio, 0.1f, 100.0f);
//    self.mEffect.transform.modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -3.0f);
//    self.mEffect.texture2d0.enabled = GL_TRUE;
//    self.mEffect.texture2d0.name = textureInfo.name;
//    [self render];
}

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

//标准正方体加混合纹理
-(void)render{
    //创建标识
    GLuint vertShader,fragShader;
    //获取文件路径
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"BaseQuare" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle]pathForResource:@"BaseQuare" ofType:@"fsh"];
    [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertFile];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragFile];
    //创建一个着色器空程序
    _myProgram = glCreateProgram();
    //将顶点着色器链接到程序中
    glAttachShader(_myProgram, vertShader);
    //将片元着色器链接到程序中
    glAttachShader(_myProgram, fragShader);

    //删除着色器
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    //链接程序
    glLinkProgram(_myProgram);
    GLint linkSuccess;
    glGetProgramiv(_myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(_myProgram, sizeof(message), 0, &message);
        NSString*messageString = [NSString stringWithUTF8String:message];
        MSLog(@"error:%@",messageString);
        return;
    }else{
        MSLog(@"link ok");
        glUseProgram(_myProgram);
    }

    //正方体
    float vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,//左下
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,//右下
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,//右上
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,//右上
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,//左上
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,//左下

        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    GLKVector3 cubePosition[] = {

        GLKVector3Make( 0.0f,  0.0f,  -10.0f),
        GLKVector3Make( 2.0f,  5.0f, -15.0f),
        GLKVector3Make(-1.5f, -2.2f, -2.5f),
        GLKVector3Make(-3.8f, -2.0f, -12.3f),
        GLKVector3Make( 2.4f, -0.4f, -3.5f),
        GLKVector3Make(-1.7f,  3.0f, -7.5f),
        GLKVector3Make( 1.3f, -2.0f, -2.5f),
        GLKVector3Make( 1.5f,  2.0f, -2.5f),
        GLKVector3Make( 1.5f,  0.2f, -1.5f),
        GLKVector3Make(-1.3f,  1.0f, -1.5f)
    } ;

    for (int i=0; i<sizeof(cubePosition)/sizeof(GLKVector3); i++) {
        [self.cubePosition addObject:[NSValue valueWithBytes:&cubePosition[i] objCType:@encode(GLKVector3)]];
    }
    unsigned int VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glGenBuffers(1, &_cubeVAO);
    glGenVertexArraysOES(1,&_cubeVAO);
    glBindVertexArrayOES(self.cubeVAO);

    GLuint aPos = glGetAttribLocation(_myProgram, "aPos");
    GLuint aTexCoord = glGetAttribLocation(_myProgram, "aTexCoord");
    glVertexAttribPointer(aPos, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)NULL+0);
    glEnableVertexAttribArray(aPos);
    glVertexAttribPointer(aTexCoord, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (float*)NULL + 3);
    glEnableVertexAttribArray(aTexCoord);

    // load and create a texture
    GLuint texture1, texture2;
    glGenTextures(1 ,&texture1);

    // load image, create texture and generate mipmaps
//    UIImage *image = [UIImage imageNamed:@"for_test"];
//    float width = image.size.width;
//    float height = image.size.height;
//    NSMutableData *imageData = UIImagePNGRepresentation(image).mutableCopy;
//    void * imageDataPtr = imageData.mutableBytes;
    CGImageRef spriteImage = [UIImage imageNamed:@"for_test"].CGImage;
    if (!spriteImage) {
        MSLog(@"Fauked to load image %@",@"for_test");
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

    glBindTexture(GL_TEXTURE_2D, 0);
    // set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    float fw = width,fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glGenerateMipmap(GL_TEXTURE_2D);

    glGenTextures(1 ,&texture2);
    glBindTexture(GL_TEXTURE_2D, texture2);
    // set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // load image, create texture and generate mipmaps
//    UIImage *image2 = [UIImage imageNamed:@"r"];
//    float width2 = image2.size.width;
//    float height2 = image2.size.height;
//    NSMutableData *imageData2 = UIImagePNGRepresentation(image2).mutableCopy;
//    void * imageDataPtr2 = imageData2.mutableBytes;

    CGImageRef spriteImage2 = [UIImage imageNamed:@"r"].CGImage;
    if (!spriteImage2) {
        MSLog(@"Fauked to load image %@",@"r");
        exit(1);

    }
//    2. 读取图片的大小
    size_t width2 = CGImageGetWidth(spriteImage2);
    size_t height2 = CGImageGetHeight(spriteImage2);

    GLubyte *spriteData2 = (GLubyte*) calloc(width2 * height2 * 4, sizeof(GLubyte));//rgba 共4和字节

    CGContextRef spriteContext2 = CGBitmapContextCreate(spriteData2, width2, height2, 8, width2*4, CGImageGetColorSpace(spriteImage2), kCGImageAlphaPremultipliedLast);

//    3.在cgcontextref上绘图
    CGContextDrawImage(spriteContext2, CGRectMake(0, 0, width2, height2), spriteImage2);
    CGContextRelease(spriteContext2);
    float fw2 = width2,fh2 = height2;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw2, fh2, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData2);
    glGenerateMipmap(GL_TEXTURE_2D);

    glActiveTexture(GL_TEXTURE0);
    glUniform1i(glGetUniformLocation(_myProgram, "texture1"), 0);
    glBindTexture(GL_TEXTURE_2D, 0);//解绑
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);
    glUniform1i(glGetUniformLocation(_myProgram, "texture2"), 1);

    GLKMatrix4 projection = GLKMatrix4Identity;

    projection = GLKMatrix4MakePerspective( GLKMathRadiansToDegrees(45.0f ), Screen_width/Screen_height, 0.1f, 100.0f);
    glUniformMatrix4fv(glGetUniformLocation(_myProgram, "projection"), 1, GL_FALSE, projection.m);
    GLKMatrix4 view = GLKMatrix4Identity;
    view = GLKMatrix4Translate(view, 0.0f,0.0f,-3.0f);
    glUniformMatrix4fv(glGetUniformLocation(_myProgram, "view"), 1, GL_FALSE, view.m);

}
-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    //获取文件的内容 并进行UTF8StringEncoding
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    //根据类型创建着色器对象
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return;
    }
    *shader = glCreateShader(type);
    //第五步 获取着色器源代码和着色器关联
    glShaderSource(*shader, 1, &source, NULL);
    //第六步 开始编译器源代码
    glCompileShader(*shader);
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        MSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    //第七步. 查看是着色器源代码否编译成功
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return;
    }
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(.3f, .6f, .1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glBindVertexArrayOES(self.cubeVAO);
//        self.mEffect.transform.modelviewMatrix = GLKMatrix4Rotate(GLKMatrix4Identity, GLKMathRadiansToDegrees(self.rotote), 0.5f, 1.0f, 0.0f);
//    NSLog(@"%d",self.cubePosition.count);
    for (NSValue *value in self.cubePosition) {
        GLKVector3 pos;
        [value getValue:&pos];
        GLKMatrix4 modelViewMatrix;
        modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, pos.x,pos.y,pos.z);
        glUniformMatrix4fv(glGetUniformLocation(_myProgram, "model"), 1, GL_FALSE, modelViewMatrix.m);
//        NSDate *date = [NSDate date];
//        NSTimeInterval currentTime= [date timeIntervalSince1970];
//
//
//        self.mEffect.transform.modelviewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathRadiansToDegrees((currentTime - self.clock)/100.0 ), 0.5f, 1.0f, 0.0f);
        [self.mEffect prepareToDraw];
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
}
//-(void)update{
//    GLKMatrix4 modelViewMatrix;
//    modelViewMatrix = GLKMatrix4Identity;
//    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, -5);
//    NSDate *date = [NSDate date];
//    NSTimeInterval currentTime= [date timeIntervalSince1970];
//
//
//    self.mEffect.transform.modelviewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathRadiansToDegrees((currentTime - self.clock)/100.0 ), 0.5f, 1.0f, 0.0f);
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
