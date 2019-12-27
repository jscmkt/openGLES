//
//  main.m
//  line
//
//  Created by you&me on 2019/7/8.
//  Copyright © 2019 you&me. All rights reserved.
//

#include "GLShaderManager.h"
/*
 `#include<GLShaderManager.h>` 移入了GLTool 着色器管理器（shader Mananger）类。没有着色器，我们就不能在OpenGL（核心框架）进行着色。着色器管理器不仅允许我们创建并管理着色器，还提供一组“存储着色器”，他们能够进行一些初步䄦基本的渲染操作。
 */

#include "GLTools.h"
/*
 `#include<GLTools.h>`  GLTool.h头文件包含了大部分GLTool中类似C语言的独立函数
 */

#include <GLUT/GLUT.h>
/*
 在Mac 系统下，`#include<glut/glut.h>`
 在Windows 和 Linux上，我们使用freeglut的静态库版本并且需要添加一个宏
 */
//矩阵堆栈
#include "GLMatrixStack.h"
//投影矩阵
#include "GLFrame.h"

//矩阵
#include "GLFrustum.h"

//几何变换管道
#include "GLGeometryTransform.h"
#include <math.h>
//定义一个，着色器管理器
GLShaderManager shaderManager;
//观察者照相机
GLFrame viewFrame;
//使用GLFrustum类来z设置透视投影
GLFrustum viewFrustum;
//容器帮助类
GLTriangleBatch torusBatch;
//模型视图矩阵
GLMatrixStack modelViewMatix;
//投影视图矩阵
GLMatrixStack projectionMatrix;
//几何变换管道
GLGeometryTransform transformPipeline;


//标记背面剔除
int iCull = 0;
int iDepth = 0;

//这个函数不需要初始化渲染
//context 图像上下文
void SetupRc() {

    //设置背景颜色
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);

    //初始化着色器管理器
    shaderManager.InitializeStockShaders();

    //将照相机向后移动7个单元，这是肉眼到物体的距离
    viewFrame.MoveForward(7.0f);

    //创建一个甜甜圈
    // void gltMakeTorus(GLTriangleBatch& torusBatch, GLfloat majorRadius, GLfloat minorRadius, GLint numMajor, GLint numMinor);
    /**
     参数一：容器帮助类
     参数二：外边缘半径（主半径）
     参数三：内边缘半径（从半径）
     参数四五：主半径和从半径的细分单元（三角形）数量
     */
    gltMakeTorus(torusBatch, 1.0f, 0.3f, 52, 26);

    //设置点的大小
    glPointSize(4.0f);

}
// 召唤场景
void RenderScene(void) {

    //清除窗口和深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //根据设置iClull标记来判断是否开启背面剔除
    if (iCull) {

        //开启背面剔除
        glEnable(GL_CULL_FACE);
        //指定逆向针顺序三角形为正面/指定顺时针下三角形为正面
        glFrontFace(GL_CCW);
        //切除那个面
        glCullFace(GL_BACK);
    }
    //根据设置iDepth标记来判断是否开启深度测试
    if (iDepth) {
        glEnable(GL_DEPTH_TEST);
    }else {
        glDisable(GL_DEPTH_TEST);
    }
    /**
     模型视图矩阵：图形发生变化：平移/旋转/缩放 放射变换，模型视图矩阵就是为了记录这些矩阵值
     投影矩阵：投影方式正投影/透视，通过投影矩阵来记录这些矩阵值
     */
    //把摄像机矩阵压入模型矩阵中-压栈方式
    modelViewMatix.PushMatrix(viewFrame);

    GLfloat vRed[] = {1.0f, 0.0f, 0.0f, 1.0f};

    //使用平面着色器
    //参数1：平面着色器
    //参数2：模型视图投影矩阵
    //有几种方式：transformPipeline.GetModelViewMatrix()：模型视图矩阵,GetNormalMatrix()默认视图矩阵，GetProjectionMatrix()投影视图矩阵，GetModelViewProjectionMatrix() 模型视图投影矩阵
    //参数3：颜色
//    shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vRed);


    //使用默认光源着色器
    //通过光源、阴影效果跟提现立体效果
    //参数1：GLT_SHADER_DEFAULT_LIGHT 默认光源着色器 - 着色器类型
    //参数2：模型视图矩阵：
    //参数3：投影矩阵
    //参数4：基本颜色值
     shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vRed);

    //绘制
    torusBatch.Draw();

    //出栈
    modelViewMatix.PopMatrix();

    //
    glutSwapBuffers();
}

//右键菜单栏选项
void ProcessMunu(int value){
    switch (value) {
        case 1:
            //是否开启正/背面剔除
            iCull = !iCull;

            break;

        case 2:
            // 是否开启深度测试
            iDepth = !iDepth;
            break;

        case 3:
            // 填充方式-三角形
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            break;

        case 4:
            //填充方式-线
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            break;

        case 5:
            //填充方式-点
            glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
            break;
        default:
            break;
    }
    //重新刷新window
    glutPostRedisplay();
}
void SpecailKeys(int key,int x,int y){

    if (key == GLUT_KEY_UP) {
        viewFrame.RotateWorld(m3dDegToRad(-5.0), 1.0, 0.0, 0.0);
    }

    if (key == GLUT_KEY_DOWN) {
        viewFrame.RotateWorld(m3dDegToRad(5.0), 1.0, 0.0, 0.0);
    }

    if (key == GLUT_KEY_LEFT) {
        viewFrame.RotateWorld(m3dDegToRad(-5.0), 0.0, 1.0, 0.0);
    }

    if (key == GLUT_KEY_RIGHT) {
        viewFrame.RotateWorld(m3dDegToRad(5.0), 0.0, 1.0, 0.0);
    }

    //重新刷新window
    glutPostRedisplay();
}
void ChangeSize(int w,int h){
    //防止为0
    if (h==0) {
        h=1;
    }
    //设置窗口大小
    glViewport(0, 0, w, h);

    //创建透视投影， 并将它载入到投影矩阵堆栈中
    /*
     参数
     1.垂直方向的视场角度
     2.窗口的宽度和高度的纵横比
     3.近裁界面距离
     4.远裁剪面距离

     */
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 100.f);

    //吧透视矩阵加载到透视矩阵队列中
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    //h初始化渲染管线
    transformPipeline.SetMatrixStacks(modelViewMatix, projectionMatrix);

}


int main(int argc, char* argv[])
{
    //设置工作路径
    gltSetWorkingDirectory(argv[0]);
    //初始化
    glutInit(&argc, argv);
    //初始化渲染模型
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    //设置窗口大小
    glutInitWindowSize(800, 600);
    //设置窗口标题
    glutCreateWindow("Geometry Test Program");
    //注册回调函数（渲染、尺寸）
    glutReshapeFunc(ChangeSize);
    //特殊键位函数（上下左右）
    glutSpecialFunc(SpecailKeys);
    // 显示函数
    glutDisplayFunc(RenderScene);

    //创建右键菜单
    glutCreateMenu(ProcessMunu);

    glutAddMenuEntry("Toggle cull backFace", 1);
    glutAddMenuEntry("Toggle depth test", 2);
    glutAddMenuEntry("Set Line Mode", 3);
    glutAddMenuEntry("Set Line Mode", 4);
    glutAddMenuEntry("Set Point mode", 5);

    //设置右键
    glutAttachMenu(GLUT_RIGHT_BUTTON);

    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetString(err));
        return 1;
    }

    SetupRc();

    glutMainLoop();
    return 0;

}
