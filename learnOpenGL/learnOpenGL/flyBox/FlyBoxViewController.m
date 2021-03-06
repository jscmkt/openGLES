//
//  FlyBoxViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/7/5.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "FlyBoxViewController.h"
#import "starship.h"
#import "AGLKSkyBoxEffect.h"

@interface FlyBoxViewController ()

//上下文
@property(nonatomic,strong)EAGLContext *mContext;

//基于OpenGL渲染的简单照明和阴影系统
@property(nonatomic,strong)GLKBaseEffect *baseEffect;

//天空盒子效果
@property(nonatomic,strong)AGLKSkyBoxEffect *skyboxEffect;

//眼睛的位置
@property(nonatomic,assign)GLKVector3 eyePosition;
//观察者位置
@property(nonatomic,assign)GLKVector3 lookAtPosition;

//旋转角度
@property(nonatomic,assign)float angle;

//观察者向上的方向的世界坐标系的方向
@property(nonatomic,assign)GLKVector3 upVector;

//BUFFER 顶点\发现
@property(nonatomic,assign)GLuint mPositionBuffer;
@property(nonatomic,assign)GLuint mNormalBuffer;

//开关
@property(nonatomic,strong)UISwitch *mPauseSwitch;

@end

@implementation FlyBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.新建OpenGL ES上下文
    self.mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];

    //获取GLKView
    GLKView *view = (GLKView*)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    //设置self.mContext作为当前上下文
    [EAGLContext setCurrentContext:self.mContext];

    //视图矩阵定义3个position
    //相机(观察者)在世界坐标z系的位置 第一组:就是脑袋的位置
    self.eyePosition = GLKVector3Make(0.0, 10.0, 10.0);
    //观察者观察的物体在世界坐标系的位置 第二组:就是眼睛所看物体的位置
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    //观察者向上的方向的世界坐标系的方向.第三组:就是头顶朝向大的方向(因为你可以头歪着的状态)
    self.upVector = GLKVector3Make(0.0, 1.0, 0.0);

    //灯光
    self.baseEffect = [[GLKBaseEffect alloc]init];
    //是否使用光照
    self.baseEffect.light0.enabled = GL_TRUE;
    //光照的位置
    self.baseEffect.light0.position = GLKVector4Make(0.0, 0.0, 2.0, 1.0f);
    //反射光的颜色
    self.baseEffect.light0.specularColor = GLKVector4Make(0.25, 0.25, .25, 1.0);
    //漫反射光的颜色
    self.baseEffect.light0.diffuseColor = GLKVector4Make(.75, .75, .75, 1.0);

    //计算光照的策略
    //GLKlinghtingTypePerVertex:表示在三角形的每个顶点执行照明计算,r然后在三角形中插值
    //GLKLightingTypePerPixel:指示对照明计算的输入在三角形内进行插值,并在每个片段上执行照明计算
    self.baseEffect.lightingType = GLKLightingTypePerPixel;

    //旋转的角度:0.5度
    self.angle = .5;
    //更换矩阵
    [self setMatrices];

    //顶点缓存
    GLuint buffer;
    //OES拓展类
    //设置顶点属性指针
    //为vertexArrayID 申请一个标记
    glGenVertexArraysOES(1, &_mPositionBuffer);
    //绑定一块区域到vertexArrayID上
    glBindVertexArrayOES(_mPositionBuffer);

    //创建VBO的3个步骤
    //1.生成新缓存对象glGenBuffers
    //2.绑定缓存对象glBindBuffer
    //3.将顶点数据拷贝到缓存对象中glBufferData

    //创建缓存对象并返回缓存对象的标识符
    glGenBuffers(1, &buffer);
    //创建缓存对象并返回缓存对象的标识符

    /*
     glBindBuffer (GLenum target, GLuint buffer);
     target:告诉VBO缓存对象时保存顶点数组数据还是索引数组数据 :GL_ARRAY_BUFFER\GL_ELEMENT_ARRAY_BUFFER
     任何顶点属性，如顶点坐标、纹理坐标、法线与颜色分量数组都使用GL_ARRAY_BUFFER。用于glDraw[Range]Elements()的索引数据需要使用GL_ELEMENT_ARRAY绑定。注意，target标志帮助VBO确定缓存对象最有效的位置，如有些系统将索引保存AGP或系统内存中，将顶点保存在显卡内存中。
     buffer: 缓存区对象
     */
    glBindBuffer(GL_ARRAY_BUFFER, buffer);

    /*
     数据拷贝到缓存对象
     void glBufferData(GLenum target，GLsizeiptr size, const GLvoid*  data, GLenum usage);
     target:可以为GL_ARRAY_BUFFER或GL_ELEMENT_ARRAY
     size:待传递数据字节数量
     data:源数据数组指针
     usage:
     GL_STATIC_DRAW
     GL_STATIC_READ
     GL_STATIC_COPY
     GL_DYNAMIC_DRAW
     GL_DYNAMIC_READ
     GL_DYNAMIC_COPY
     GL_STREAM_DRAW
     GL_STREAM_READ
     GL_STREAM_COPY

     ”static“表示VBO中的数据将不会被改动（一次指定多次使用），
     ”dynamic“表示数据将会被频繁改动（反复指定与使用），
     ”stream“表示每帧数据都要改变（一次指定一次使用）。
     ”draw“表示数据将被发送到GPU以待绘制（应用程序到GL），
     ”read“表示数据将被客户端程序读取（GL到应用程序），”
     */
    //starshipPositions 飞机模型的顶点数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipPositions), starshipPositions, GL_STATIC_DRAW);

    //处于性能考虑,所有顶点着色器的属性(attribute)变量都是关闭的,以为这数据在找色漆是不可见的,哪怕数据已经上传到GPU,由glEnableVertexAttribArray启用指定属性,才可在顶点着色器中访问顶点s的属性数据

    //VBO只是简历CPU和GPU之间的逻辑连接,从而实现CPU数据上传至GPU.单数,数据在GPU端是否可见,即着色器能都读取到数据,由是否启动了对应的属性䦺,这就是glENableVertexAttribArray的功能,允许顶点着色器读取GPU(服务器端)数据.
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //顶点数据传入GPU之后,还需要通知OpenGL如何解释这些顶点数据,这个工作有函数glVertexAttribPointer完成

    /*
     glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
     indx:参数指定顶点属性位置
     size:指定顶点属性大小
     type:指定数据类型
     normalized:数据被标准化
     stride:步长
     ptr:偏移量
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);

    //给buffer重新绑定
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //将缓存对象对应到响应的缓存上
    //starshipNormals 飞机模型光照法线
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipNormals), starshipNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, NULL);

    //开启背面剔除
    glEnable(GL_CULL_FACE);

    //开启深度测试
    glEnable(GL_DEPTH_TEST);

    //加载纹理图片
    NSString *path = [[NSBundle mainBundle]pathForResource:@"skybox3" ofType:@"png"];
    NSError *error = nil;

    //加载纹理信息
    GLKTextureInfo *textInfo = [GLKTextureLoader cubeMapWithContentsOfFile:path options:nil error:&error];

    if (error) {
        NSLog(@"error:%@",error);
    }

    //配置天空盒特效
    self.skyboxEffect = [[AGLKSkyBoxEffect alloc]init];
    //纹理贴图名字
    self.skyboxEffect.textureCubeMap.name = textInfo.name;
    //纹理贴图的标记
    self.skyboxEffect.textureCubeMap.target = textInfo.target;;

    //天空盒子的长宽高
    self.skyboxEffect.xSize = 6.0f;
    self.skyboxEffect.ySize = 6.0;
    self.skyboxEffect.zSize = 6.0;

    //设置开关并添加到屏幕上
    self.mPauseSwitch = ({
        UISwitch *PS = [[UISwitch alloc]initWithFrame:CGRectMake(20, 30, 44, 44)];
        PS;
    });
    [self.view addSubview:self.mPauseSwitch];
}


//更换变化矩阵
-(void)setMatrices{
    //获取纵横比
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width)/(GLfloat)(self.view.bounds.size.height);
    //修改视图变换矩阵
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), aspectRatio, 0.1, 20.0);
    //获取世界坐标系去模型矩阵中.
    /*
     LKMatrix4 GLKMatrix4MakeLookAt(float eyeX, float eyeY, float eyeZ,
     float centerX, float centerY, float centerZ,
     float upX, float upY, float upZ)
     等价于 OpenGL 中
     void gluLookAt(GLdouble eyex,GLdouble eyey,GLdouble eyez,GLdouble centerx,GLdouble centery,GLdouble centerz,GLdouble upx,GLdouble upy,GLdouble upz);

     目的:根据你的设置返回一个4x4矩阵变换的世界坐标系坐标。
     参数1:眼睛位置的x坐标
     参数2:眼睛位置的y坐标
     参数3:眼睛位置的z坐标
     第一组:就是脑袋的位置

     参数4:正在观察的点的X坐标
     参数5:正在观察的点的Y坐标
     参数6:正在观察的点的Z坐标
     第二组:就是眼睛所看物体的位置

     参数7:摄像机上向量的x坐标
     参数8:摄像机上向量的y坐标
     参数9:摄像机上向量的z坐标
     第三组:就是头顶朝向的方向(因为你可以头歪着的状态看物体)
     */

    self.baseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(self.eyePosition.x,
                        self.eyePosition.y,
                         self.eyePosition.z,
                         self.lookAtPosition.x, self.lookAtPosition.y, self.lookAtPosition.z,
                         self.upVector.x, self.upVector.y, self.upVector.z);
    //增加角度
    self.angle += 0.01;

    //调整眼睛的位置 sinf:求正弦值
    self.eyePosition = GLKVector3Make(-5.0 * sinf(self.angle), -5.0f, -5.0 * cosf(self.angle));
    //调整观察的位置
    self.lookAtPosition = GLKVector3Make(0.0, 1.5 + -5.0f * sinf(0.3 * self.angle), 0.0);
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    //设置清屏颜色
    glClearColor(.5, .1, .1, 1.0);
    //清理颜色/深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //非暂停状态
    if (!self.mPauseSwitch.on) {
        //更新变换矩阵
        [self setMatrices];
    }

    //更新天空盒的眼镜/投影矩阵/模型视图矩阵
    self.skyboxEffect.center = self.eyePosition;
    self.skyboxEffect.transform .projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.skyboxEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;

    //准备绘制天空盒子
    [self.skyboxEffect prepareToDraw];

    /*
     1.深度缓冲区

     深度缓冲区原理就是把一个距离观察平面(近裁剪面)的深度值(或距离)与窗口中的每个像素相关联
     1>首先使用glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)来打开DEPTH_BUFFER
     void glutInitDisplayMode(unsigned int mode);

     2> 没帧开始绘制时,须清空深度缓存 glclear(GL_DEPTH_BUFFER_BIT); 该函数把所有像素的深度值设置为最大值(一般是远裁剪面)

     3> 必要时调用glDepthMask(GL_FALSE)来禁止对深度缓冲区的写入,绘制完后在调用glDepthMask(GL_TRUE)打开DEPTH_BUFFER的读写(否则物体有可能显示不出来)

     注意:只要存在深度缓冲区,无论是否启用深度测试(GL_DEPTH_TEST),OpenGL在像素被绘制时都会尝试将深度数据写入到缓冲区内,除非调用glDepthMask(GL_FLASE)来禁止写入.
     在绘制天空盒子的时候,禁止深度缓冲区

     */
    glDepthMask(false);

    //绘制天空盒子
    [self.skyboxEffect draw];

    //开启深度缓冲区
    glDepthMask(true);

    //将缓存区/纹理都清空
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);

    // 需要重新设置顶点数据，不需要缓存
    /*
     很多应用会在同一个渲染帧调用多次glBindBuffer()、glEnableVertexAttribArray()和glVertexAttribPointer()函数（用不同的顶点属性来渲染多个对象）
     新的顶点数据对象(VAO) 扩展会几率当前上下文中的与顶点属性相关的状态，并存储这些信息到一个小的缓存中。之后可以通过单次调用glBindVertexArrayOES() 函数来恢复，不需要在调用glBindBuffer()、glEnableVertexAttribArray()和glVertexAttribPointer()。
     */
    glBindVertexArrayOES(self.mPositionBuffer);
    //绘制飞船
    //sratshipMaterials 飞船材料
    for (int i=0; i<starshipMaterials; i++) {
        //设置材质的漫反射颜色
        self.baseEffect.material.diffuseColor = GLKVector4Make(starshipDiffuses[i][0], starshipDiffuses[i][1], starshipDiffuses[i][2], 1.0);
        self.baseEffect.material.specularColor = GLKVector4Make(starshipSpeculars[i][0], starshipSpeculars[i][1], starshipSpeculars[i][2], 1.0);

        //飞船准备绘制
        [self.baseEffect prepareToDraw];

        //绘制
        /*
         glDrawArrays (GLenum mode, GLint first, GLsizei count);提供绘制功能。当采用顶点数组方式绘制图形时，使用该函数。该函数根据顶点数组中的坐标数据和指定的模式，进行绘制。
         参数列表:
         mode，绘制方式，OpenGL2.0以后提供以下参数：GL_POINTS、GL_LINES、GL_LINE_LOOP、GL_LINE_STRIP、GL_TRIANGLES、GL_TRIANGLE_STRIP、GL_TRIANGLE_FAN。
         first，从数组缓存中的哪一位开始绘制，一般为0。
         count，数组中顶点的数量。
         */
        glDrawArrays(GL_TRIANGLES, starshipFirsts[i], starshipCounts[i]);
    }
}
@end
