//
//  AGLKSkyBoxEffect.m
//  learnOpenGL
//
//  Created by you&me on 2019/7/5.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "AGLKSkyBoxEffect.h"

///Cube has 2 triangles x 6 sides + 2 for strip = 14; 2e个观察者的weiz
const static int AGLKSkyBoxNumVertexIndices = 14;

//cube has 8corners x 3 float pre vertex = 24;
const static int AGLKSkyBoxNumCoords = 24;


//GLSL progrom uniform indices
enum{
    AGLKMVPMatrix,//MVP变换矩阵
    AGLKSamplersCube,//立体纹理贴图
    AGLKNumUniforms//Uniform数量
};
@interface AGLKSkyBoxEffect ()


{
    GLuint vertexBufferID;
    GLuint indexBufferID;
    GLuint program;
    GLuint vertexArrayID;
    GLint uniforms[AGLKNumUniforms];

}
//加载Shader
-(BOOL)loadShaders;
//编译Shader
-(BOOL)compileShader:(GLuint *)shader
                type:(GLenum)type
                file:(NSString *)file;
//链接Program
-(BOOL)linkProgram:(GLuint)prog;
//验证Progrom
-(BOOL)validateProgram:(GLuint)prog;

@end
@implementation AGLKSkyBoxEffect

@synthesize center;
@synthesize xSize;
@synthesize ySize;
@synthesize zSize;
@synthesize textureCubeMap;
@synthesize transform;


-(instancetype)init{
    if (self = [super init]) {
        //初始化纹理
        textureCubeMap = [[GLKEffectPropertyTexture alloc]init];
        //是否使用原始纹理
        textureCubeMap.enabled = YES;
        //该纹理阶段采样的纹理的OpenGL 名称
        textureCubeMap.name = 0;

        //设置使用的纹理类型
        /*
         GLKTextureTarget2D  --2D纹理 等价于OpenGL 中的GL_TEXTURE_2D
         GLKTextureTargetCubeMa  --立方体贴图 等价于OpenGL 中的GL_TEXTURE_CUBE_MAP
         */

        textureCubeMap.target = GLKTextureTargetCubeMap;
        //纹理用于计算其输出片段颜色的模式
        /*
         GLKTextureEnvModeReplace,输出颜色由从纹理获取的颜色，忽略输入的颜色
         GLKTextureEnvModeModulate，输出颜色是通过将纹理颜色与输入颜色来计算所得
         GLKTextureEnvModeDecal,输出颜色是通过使用纹理的alpha组件来混合纹理颜色和输入颜色

         */
        textureCubeMap.envMode = GLKTextureEnvModeReplace;
        //变换
        transform = [[GLKEffectPropertyTransform alloc]init];
        self.center = GLKVector3Make(0, 0, 0);
        self.xSize = 1.0;
        self.ySize = 1.0;
        self.zSize = 1.0;

        //立方体的8个角
        const float vertices[AGLKSkyBoxNumCoords] = {
            -0.5, -0.5, 0.5,
            0.5, -0.5, 0.5,
            -0.5, 0.5, 0.5,
            0.5, 0.5, 0.5,
            -0.5, -0.5, -0.5,
            0.5, -0.5, -0.5,
            -0.5, 0.5, -0.5,
            0.5, 0.5, -0.5,
        };

        //创建缓存对象，并返回缓存标志-顶点
        glGenBuffers(1, &vertexBufferID);
        //将缓存区绑定到相应的缓存区上-数据缓存区
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
        //将数据拷贝到缓冲区上
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

        //绘制立方体的三角形带索引
        const GLubyte indices[AGLKSkyBoxNumVertexIndices] = {
            1, 2, 3, 7, 1, 5, 4, 7, 6, 2,4,0,1,2

        };

        //创建缓存对象，并返回缓存标识符-索引
        glGenBuffers(1, &indexBufferID);
        //将缓存区绑定到相应的缓存区-索引缓存区
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
        //将数据拷贝到缓冲区
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    }
    return self;
}
#pragma mark - OpenGL ES shader compilation
//加载着色器
-(BOOL)loadShaders{
    GLuint vertShader,fragShader;
    NSString *vertShaderPathName, *fragShaderPathName;
    program = glCreateProgram();
    //指定顶点着色器路径
    vertShaderPathName = [[NSBundle mainBundle]pathForResource:@"AGLKSkyboxShader" ofType:@"vsh"];
    //编译顶点着色器路径
    if(![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathName]){
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    //指定片元着色器路径
    fragShaderPathName = [[NSBundle mainBundle]pathForResource:@"AGLKSkyboxShader" ofType:@"fsh"];
    if (![self compileShader:(GLuint *)&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathName]) {
        NSLog(@"Failed to campile fragment shader");
        return NO;
    }
    //将顶点着色器附着到程序program上
    glAttachShader(program, vertShader);

    //将片元着色器附着到程序program上
    glAttachShader(program, fragShader);

    //绑定属性位置
    glBindAttribLocation(program, GLKVertexAttribPosition, "a_position");
    //链接程序
    if (![self linkProgram:program]) {
        NSLog(@"Failed to link program:%d",program);

        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        return NO;
    }
    //获取uniform变量的位置
    //mvpMatrix
    uniforms[AGLKMVPMatrix] = glGetUniformLocation(program, "u_mvpMatrix");
    uniforms[AGLKSamplersCube] = glGetUniformLocation(program, "u_samplersCube");
    NSLog(@"%d",uniforms[AGLKSamplersCube]);
    if (vertShader) {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

//编译着色器程序
-(BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    //路径-C语言
    const GLchar *source;
    //从OC字符串中获取C语言d字符串
    //获取路径
    source = (GLchar*)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]UTF8String];
    //判断路径
    if (!source) {
        NSLog(@"Failed to load vertec shader");
        return NO;
    }

    //创建shader-顶点/片元
    *shader = glCreateShader(type);
    //绑定shader
    glShaderSource(*shader, 1, &source, NULL);
    //完成Shader
    glCompileShader(*shader);

    //获取加载Shader的日志信息
    //日志信息长度
    GLint logLength;

    /*
     在OpenGL中有方法能够获取到 shader错误
     参数1:对象,从哪个Shader
     参数2:获取信息类别,
     GL_COMPILE_STATUS       //编译状态
     GL_INFO_LOG_LENGTH      //日志长度
     GL_SHADER_SOURCE_LENGTH //着色器源文件长度
     GL_SHADER_COMPILER  //着色器编译器
     参数3:获取长度
     */

    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);

    //判断日志的长度
    if (logLength > 0) {

        //创建日志字符串
        GLchar *log = (GLchar *)malloc(logLength);

        /*
         获取日志信息
         参数1:着色器
         参数2:日志信息长度
         参数3:日志信息长度地址
         参数4:日志存储的位置
         */
        glGetShaderInfoLog(*shader, logLength, &logLength, log);

        //打印日志信息
        NSLog(@"Shader comile log:\n %s", log);

        //释放字符串日志
        free(log);

        return 0;
    }

    return YES;
}

//链接program
-(BOOL)linkProgram:(GLuint)prog{
    glLinkProgram(prog);
    //打印链接program的日志信息
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);

    if (logLength > 0) {

        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);

        NSLog(@"Program link log:\n%s", log);
        free(log);

        return NO;
    }

    return YES;
}

//验证Program
-(BOOL)validateProgram:(GLuint)prog{
    GLint logLength, status;
    //验证program

    /*
     glValidateProgram 检测program中包含的执行段在给定的当前OpenGL状态下是否可执行。验证过程产生的信息会被存储在program日志中。验证信息可能由一个空字符串组成，或者可能是一个包含当前程序对象如何与余下的OpenGL当前状态交互的信息的字符串。这为OpenGL实现提供了一个方法来调查更多关于程序效率低下、低优化、执行失败等的信息。
     验证操作的结果状态值会被存储为程序对象状态的一部分。如果验证成功，这个值会被置为GL_TURE，反之置为GL_FALSE。调用函数 glGetProgramiv 传入参数 program和GL_VALIDATE_STATUS可以查询这个值。在给定当前状态下，如果验证成功，那么 program保证可以执行，反之保证不会执行

     GL_INVALID_VALUE 错误：如果 program 不是由 OpenGL生成的值.
     GL_INVALID_OPERATION 错误：如果 program 不是一个程序对象.
     */
    glValidateProgram(prog);
    //获取验证的日志信息
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s",log);
        free(log);
    }

    //获取验证的状态--验证结果
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);

    if (status == 0) {
        return NO;
    }
    return YES;
}
@end
