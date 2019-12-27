//
//  ViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/3/13.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "ViewController.h"
#import "GLLearnView.h"
@interface ViewController ()
@property(nonatomic,strong)EAGLContext* mContent;
@property(nonatomic,strong)GLKBaseEffect *mEffect;
@property(nonatomic,assign)int mCount;

@property (nonatomic , strong) GLLearnView*   myView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myView = (GLLearnView *)self.view;
}
-(void)firstLearnOpenGLES{

    [self setupConfig];
    [self uploadVertexArray];
    [self uploadTexture];
}
-(void)setupConfig{
    ///新建OpenGLES 上下文
    self.mContent = [[EAGLContext alloc]initWithAPI:(kEAGLRenderingAPIOpenGLES2)];//2.0
    GLKView* view = (GLKView*)self.view;//storyBoard标记
    view.context = self.mContent;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    [EAGLContext setCurrentContext:self.mContent];
}

-(void)uploadVertexArray{

    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat squareVertexData[] =
    {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上

        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    //顶点数据缓存
    GLuint buffer;
    /*
     glGenBuffers(GLsizei n,GLuint *buffers):任何非零的无符合整数都可以作为缓冲区对象的标识符使用。这个函数的作用就是向系统申请n个缓冲区，系统把这n个缓冲区的标识符都放进buffers数组中。还可以调用glIsBuffer()函数判断一个标识符是否正被使用。
     */
    glGenBuffers(1, &buffer);//申请一个标识符
    /*
     glBindBuffer(GLenum target, GLuint buffer) :把这个缓冲区绑定给顶点还是索引.通俗点,也就是定义了这个缓冲区存储的是什么.target用于决定绑定的是顶点数据(GL_ARRAY_BUFFER)还是索引数据(GL_ELEMENT_ARRAY_BUFFER).
     */
    glBindBuffer(GL_ARRAY_BUFFER, buffer);//把标识符绑定到GL_ARRAY_BUFFER上
    /*
     glBufferData (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage):把CPU中的内存中的数组复制到GPU的内存中.target用于决定绑定的是顶点数据(GL_ARRAY_BUFFER)还是索引数据(GL_ELEMENT_ARRAY_BUFFER).size决定数据的存储长度.data则是数据信息.usage表示数据的读写方式,是一个枚举类型,这里使用的是GL_STATIC_DRAW,它表示此缓冲区内容只能被修改一次，但可以无限次读取。
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);//把顶点数据从cpu内存赋值到gpu内存

    /*
     glEnableVertexAttribArray (GLuint index) : 激活顶点属性(默认它的关闭的).在刚开始,我们就说到顶点属性集中包含五种属性：位置、法线、颜色、纹理0，纹理1.顶点属性集是一个枚举值.这里我们只用到了位置和纹理这两个属性.
     */
    glEnableVertexAttribArray(GLKVertexAttribPosition);//顶点数据缓存，开启对应的顶点属性
    /*
     glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr) : 往对应的顶点属性中添加数据.indx为顶点属性类型.size为每个数据中的数据长度.type为元素数据类型,normalized填充时需不需要单位化.stride需要填写的是在数据数组中每行的跨度,最后一个ptr指针是说的是每一个数据的起始位置将从内存数据块的什么地方开始。例如顶点属性的数据填充示意图如下所示.
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 0);//设置合适的格式从buffer里面读取数据

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);//纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *5 , (GLfloat*)NULL + 3);

}

-(void)uploadTexture{
    //纹理贴图
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"for_test" ofType:@"jpg"];
    NSDictionary*option = @{GLKTextureLoaderOriginBottomLeft:@(1)};//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:option error:nil];//GLKTextureLoader读取图片，创建纹理GLKTextureInfo
    //着色器
    self.mEffect = [[GLKBaseEffect alloc]init];//创建着色器GLKBaseEffect，把纹理赋值给着色器
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
}

///渲染场景代码
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    /*
     glClearColor (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) : 渲染前的“清除”操作,指定在清除屏幕之后填充什么样的颜色.四个参数就是RGB值.
     */
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    /*
     glClear (GLbitfield mask) :指定需要清除的缓冲.mask指定缓冲的类型.可以使用 | 运算符组合不同的缓冲标志位，表明需要清除的缓冲.可以使用以下标识符.

     GL_COLOR_BUFFER_BIT: 当前可写的颜色缓冲

     GL_DEPTH_BUFFER_BIT: 深度缓冲

     GL_ACCUM_BUFFER_BIT: 累积缓冲

     GL_STENCIL_BUFFER_BIT: 模板缓冲


     */
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
@end
