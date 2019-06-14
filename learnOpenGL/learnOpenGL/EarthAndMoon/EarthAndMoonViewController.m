//
//  EarthAndMoonViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/4/11.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "EarthAndMoonViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"


@interface EarthAndMoonViewController ()
@property(nonatomic,strong)EAGLContext *mContext;


@property(nonatomic,strong)AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property(nonatomic,strong)AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property(nonatomic,strong)AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@property(nonatomic)GLKBaseEffect *baseEffect;
@property(nonatomic)GLKTextureInfo *earthTextureInfo;
@property(nonatomic)GLKTextureInfo *moonTextureInfo;
@property(nonatomic)GLKMatrixStackRef modelviewMatrixStack;
@property(nonatomic)GLfloat earthRotationAngleDegrees;
@property(nonatomic)GLfloat moonRotationAngleDegrees;
- (IBAction)takeShouldUsePerspectiveFrom:(UISwitch *)aControl;
@end

@implementation EarthAndMoonViewController


static const GLfloat SceneEarthAxialTiltDeg = 12.5f;
static const GLfloat SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat  SceneMoonDistanceFromEarth = 2.0;


- (void)viewDidLoad {
    [super viewDidLoad];
    //新建openGLES上下文
    self.mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView*)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.mContext];
    glEnable(GL_DEPTH_TEST);
    self.baseEffect = [[GLKBaseEffect alloc]init];
    [self configureLight];

    GLfloat aspectRatio = (self.view.bounds.size.width / self.view.bounds.size.height);

    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * aspectRatio, 1.0 *aspectRatio, -1.0, 1.0, 1.0, 120.0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f , 0.0f, -5.0f);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

    ///顶点数据
    [self bufferData];

}

-(void)bufferData{
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    ///顶部数据缓存
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:3*sizeof(GLfloat) numberOfVertices:sizeof(sphereVerts)/(3*sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(3*sizeof(GLfloat)) numberOfVertices:sizeof(sphereNormals)/(3*sizeof(GLfloat)) bytes:sphereNormals usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(2*sizeof(GLfloat)) numberOfVertices:sizeof(sphereTexCoords)/(2*sizeof(GLfloat)) bytes:sphereTexCoords usage:GL_STATIC_DRAW];

    //地球纹理
    CGImageRef earthImageRef = [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    self.earthTextureInfo = [GLKTextureLoader textureWithCGImage:earthImageRef options:@{GLKTextureLoaderOriginBottomLeft:@1} error:NULL];

    //月球纹理
    CGImageRef moonImageRef = [UIImage imageNamed:@"Moon256x128.png"].CGImage;
    self.moonTextureInfo = [GLKTextureLoader textureWithCGImage:moonImageRef options:@{GLKTextureLoaderOriginBottomLeft:@1} error:nil];


    //矩阵堆
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack, self.baseEffect.transform.modelviewMatrix);

    //Initialize Moon position in orbit
    self.moonRotationAngleDegrees = -20.0f;

}
-(void)configureLight{
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,//red
                                                         1.0f,//green
                                                         1.0f,//blue
                                                         1.0f);//alpha
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 0.0f, 0.8f, 0.0f);

    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
}

///渲染场景代码
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    self.earthRotationAngleDegrees += 360.0/60.0f;
    self.moonRotationAngleDegrees += (360.0f / 60.0f) / SceneDaysPerMoonOrbit;

    [self.vertexPositionBuffer prepareTodrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexNormalBuffer prepareTodrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexTextureCoordBuffer prepareTodrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    [self drawEarth];
    [self drawMoon];
}

//地球
-(void)drawEarth{
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;

    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 1.000000 0.000000 0.000000
     0.000000 0.000000 1.000000 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(self.modelviewMatrixStack, GLKMathDegreesToRadians(SceneEarthAxialTiltDeg), 1.0, 0.0, 0.0);

    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.000000 -0.398749 0.917060 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */

    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.earthRotationAngleDegrees),
                         0.0, 1.0, 0.0);
    /*
     current matrix:
     0.994522 0.041681 -0.095859 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.104528 -0.396565 0.912036 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);

    [self.baseEffect prepareToDraw];

    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];


    /*

     current matrix:
     0.994522 0.041681 -0.095859 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.104528 -0.396565 0.912036 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    GLKMatrixStackPop(self.modelviewMatrixStack);

    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 1.000000 0.000000 0.000000
     0.000000 0.000000 1.000000 0.000000
     0.000000 0.000000 -5.000000 1.000000

     */
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);

}

- (void)drawMoon
{
    self.baseEffect.texture2d0.name = self.moonTextureInfo.name;
    self.baseEffect.texture2d0.target = self.moonTextureInfo.target;

    GLKMatrixStackPush(self.modelviewMatrixStack);

    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.moonRotationAngleDegrees),
                         0.0, 1.0, 0.0);
    GLKMatrixStackTranslate(
                            self.modelviewMatrixStack,
                            0.0, 0.0, SceneMoonDistanceFromEarth);
    GLKMatrixStackScale(
                        self.modelviewMatrixStack,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth);
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.moonRotationAngleDegrees),
                         0.0, 1.0, 0.0);

    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);

    [self.baseEffect prepareToDraw];


    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];

    GLKMatrixStackPop(self.modelviewMatrixStack);

    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}
- (IBAction)takeShouldUsePerspectiveFrom:(UISwitch *)aControl {

    GLfloat aspectRatio = (float)((GLKView*)self.view).drawableWidth /
    (float)((GLKView*)self.view).drawableHeight;
    if ([aControl isOn]) {
        self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeFrustum(-1.0*aspectRatio, 1.0*aspectRatio, -1.0, 1.0, 2.0, 120.0);
    }else{

        self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0*aspectRatio, 1.0*aspectRatio, -1.0, 1.0, 1.0, 120.0);
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}
@end
