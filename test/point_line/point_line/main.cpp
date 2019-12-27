//
//  main.m
//  point_line
//
//  Created by you&me on 2019/7/8.
//  Copyright © 2019 you&me. All rights reserved.
//

//#import <Foundation/Foundation.h>
//#include <GLKit/GLKit.h>

#include "GLShaderManager.h"
#include "GLTools.h"
/*
 `#include<GLTools.h>`  GLTool.h头文件包含了大部分GLTool中类似C语言的独立函数
 */

#include <GLUT/GLUT.h>
/*
 在Mac 系统下，`#include<glut/glut.h>`
 在Windows 和 Linux上，我们使用freeglut的静态库版本并且需要添加一个宏
 */

// 定义一个，着色管理器
GLShaderManager shaderManager;
// 简单的批次容器，是GLTools的一个简单的容器类
GLBatch triangleBatch;
// blockSize 边长
GLfloat blockSize = 0.1f;

//正方形的4个点坐标
GLfloat vVerts[] = {
    -blockSize,-blockSize,0.0f,
    blockSize,-blockSize,0.0f,
    blockSize,blockSize,0.0f,
    -blockSize,blockSize,0.0f
};


/**
 在窗口大小改变时，接收心的宽度&高度
 */
void changeSize(int w, int h)
{
    /**
     x,y 参数代表窗口中视图的左下角坐标，而宽度、高度是像素为表示，通常x,y 都是为0
     */
    glViewport(0, 0, w, h);

}

void RenderScene(void)
{
    //1.清除一个或者一组特定的缓存区
    /**
     h缓冲区时一块存在图像信息的储存空间，红色、绿色、蓝色和alpha分量通常一起作为颜色缓存区或像素缓存区饮用。
     OpenGL 中不止一种缓冲区（颜色缓存区、深度缓存区和模板缓存区）
     清除缓存区对数值进行预置
     参数：指定将要清除的缓存的
     GL_COLOR_BUFFER_BIT :指示当前激活的用来进行颜色写入缓冲区
     GL_DEPTH_BUFFER_BIT :指示深度缓存区
     GL_STENCIL_BUFFER_BIT:指示模板缓冲区
     */
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    //2.设置一组浮点数来表示红色
    GLfloat vRed[] = {0.1,0.3,0.0,1.0f};

    //传递到存储着色器，即GLT_SHADER_IDENTITY着色器，这个着色器只是使用指定颜色以默认笛卡尔坐标第在屏幕上渲染几何图形GLT_SHADER_
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vRed);

    //提交着色器
    triangleBatch.Draw();

    //在开始的设置openGL 窗口的时候，我们指定要一个双缓冲区的渲染环境。这就意味着将在后台缓冲区进行渲染，渲染结束后交换给前台。这种方式可以防止观察者看到可能伴随着动画帧与动画帧之间的闪烁的渲染过程。缓冲区交换平台将以平台特定的方式进行。
    //将后台缓冲区进行渲染，然后结束后交换给前台
    glutSwapBuffers();

}

void setupRC()
{
    //设置清屏颜色（背景颜色）
    glClearColor(0.98f, 0.40f, 0.7f, 1);

    //没有着色器，在OpenGL 核心框架中是无法进行任何渲染的。初始化一个渲染管理器。
    //在前面的课程，我们会采用固管线渲染，后面会学着用OpenGL着色语言来写着色器
    shaderManager.InitializeStockShaders();

    //指定顶点
    //在OpenGL中，三角形是一种基本的3D图元绘图原素。
    // x,y,z
    //    GLfloat vVerts[] = {
    //        -0.5f,0.0f,0.0f,
    //        0.5f,0.0f,0.0f,
    //        0.0f,0.5f,0.0f
    //    };

    triangleBatch.Begin(GL_TRIANGLE_FAN, 4);
    triangleBatch.CopyVertexData3f(vVerts);
    triangleBatch.End();
}

void SpecialKes(int key, int x, int y) {

    GLfloat stepSize = 0.025f;

    GLfloat blockX = vVerts[0];
    GLfloat blockY = vVerts[10];

    printf("v[0] == %f\n", blockX);
    printf("v[10] == %f\n", blockY);

    if (key == GLUT_KEY_UP) {
        blockY += stepSize;
    }

    if (key == GLUT_KEY_DOWN) {
        blockY -= stepSize;
    }

    if (key == GLUT_KEY_LEFT) {
        blockX -= stepSize;
    }

    if (key == GLUT_KEY_RIGHT) {
        blockX += stepSize;
    }
    //触碰到边界（4个边界）的处理

    //正方形移动超过最左边的时候
    if (blockX < -1.0f) {
        blockX = -1.0f;
    }

    //正方形d移动超过最右边的时候
    //1.0 - blockSize * 2 = 总边长 - 正方形的边长 = 最左边点的位置
    if (blockX > 1.0 - blockSize * 2) {
        blockX = 1.0f - blockSize * 2;
    }

    // 当正方形移动到最下面时
    // -1.0 - blockSize * 2 = 总边长 - 正方形的边长 = 最下边点的位置
    if (blockY < -1.0f + blockSize * 2) {
        blockY = -1.0f + blockSize * 2;
    }

    //正方形移动到最上面时
    if (blockY > 1.0f) {
        blockY = 1.0f;
    }

    printf("blockX = %f\n", blockX);
    printf("blockY = %f\n", blockY);
    //移动时调整四个角的位置
    vVerts[0] = blockX;
    vVerts[1] = blockY - blockSize * 2;
    printf("%f, %f\n", vVerts[0], vVerts[1]);

    vVerts[3] = blockX + blockSize * 2;
    vVerts[4] = blockY - blockSize * 2;
    printf("%f, %f\n", vVerts[3], vVerts[4]);

    vVerts[6] = blockX + blockSize * 2;
    vVerts[7] = blockY;
    printf("%f, %f\n", vVerts[6], vVerts[7]);

    vVerts[9] = blockX;
    vVerts[10] = blockY;
    printf("%f, %f\n", vVerts[9], vVerts[10]);

    triangleBatch.CopyVertexData3f(vVerts);
    glutPostRedisplay();

}

int main(int argc, char *argv[])
{
    //设置当前工作目录，针对MAC OS X
    /*
     `GLTools`函数`glSetWorkingDrectory`用来设置当前工作目录。实际上在Windows中是不必要的，因为工作目录默认就是与程序可执行执行程序相同的目录。但是在Mac OS X中，这个程序将当前工作文件夹改为应用程序捆绑包中的`/Resource`文件夹。`GLUT`的优先设定自动进行了这个中设置，但是这样中方法更加安全。
     */
    gltSetWorkingDirectory(argv[0]);

    //初始化GLUT库,这个函数只是传说命令参数并且初始化glut库
    glutInit(&argc, argv);

    /*
     初始化双缓冲窗口，其中标志GLUT_DOUBLE、GLUT_RGBA、GLUT_DEPTH、GLUT_STENCIL分别指
     双缓冲窗口、RGBA颜色模式、深度测试、模板缓冲区

     --GLUT_DOUBLE`：双缓存窗口，是指绘图命令实际上是离屏缓存区执行的，然后迅速转换成窗口视图，这种方式，经常用来生成动画效果；
     --GLUT_DEPTH`：标志将一个深度缓存区分配为显示的一部分，因此我们能够执行深度测试；
     --GLUT_STENCIL`：确保我们也会有一个可用的模板缓存区。
     深度、模板测试后面会细致讲到
     */
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_DEPTH | GLUT_STENCIL);

    //GLUT 窗口大小、窗口标题
    glutInitWindowSize(800, 600);
    glutCreateWindow("Hello world!");

    /*
     GLUT 内部运行一个本地消息循环，拦截适当的消息。然后调用我们不同时间注册的回调函数。我们一共注册2个回调函数：
     1）为窗口改变大小而设置的一个回调函数
     2）包含OpenGL 渲染的回调函数
     */
    //注册重塑函数
    glutReshapeFunc(changeSize);
    //注册显示函数
    glutDisplayFunc(RenderScene);
    //注册特殊函数
    glutSpecialFunc(SpecialKes);
    /*
     初始化一个GLEW库,确保OpenGL API对程序完全可用。
     在试图做任何渲染之前，要检查确定驱动程序的初始化过程中没有任何问题
     */
    GLenum status = glewInit();
    if (GLEW_OK != status) {
        printf("GLEW Error: %s\n", glewGetErrorString(status));
        return 1;
    }

    setupRC();
    //设置我们的渲染环境
    //保护线程的运行
    glutMainLoop();

    return 0;
}

