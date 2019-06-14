//
//  PointFlyViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/5/20.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "PointFlyViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKPointParticleEffect.h"
@interface PointFlyViewController ()
@property(nonatomic,strong)EAGLContext *mContext;

@property(nonatomic,strong)AGLKPointParticleEffect *particleEffect;
@property(nonatomic,assign)NSTimeInterval autoSpawnDeleta;
@property(nonatomic,assign)NSTimeInterval lastSpwnTime;
@property(nonatomic,assign)NSInteger currentEmitterIndex;
@property(nonatomic,strong)NSArray *emitterBlocks;
@property(nonatomic,strong)GLKTextureInfo *ballParticleTexture;

@property(nonatomic,assign)long mElapseTime;

@end

@implementation PointFlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mElapseTime = 0;

    //新建OpenGLES上下文
    self.mContext = [[EAGLContext alloc]initWithAPI:(kEAGLRenderingAPIOpenGLES2)];

    GLKView *view = (GLKView*)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    [EAGLContext setCurrentContext:self.mContext];

    NSString *path = [[NSBundle mainBundle]pathForResource:@"ball" ofType:@"png"];
    NSAssert(nil != path, @"ball texture image not found");
    NSError *error = nil;
    self.ballParticleTexture = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&error];
    self.particleEffect = [[AGLKPointParticleEffect alloc]init];
    self.particleEffect.texture2d0.name = self.ballParticleTexture.name;
    self.particleEffect.texture2d0.target = self.ballParticleTexture.target;
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);//启动混合
    /**
     若源色为 ( 1.0 , 0.9 , 0.7 , 0.8 )

     源色使用 GL_SRC_ALPHA

     即 0.8*1.0 , 0.8*0.9 , 0.8*0.8 , 0.8*0.7

     结果为 0.8 , 0.72 , 0.64 , 0.56



     目标色为 ( 0.6 , 0.5 , 0.4 , 0.3 )

     目标色使用GL_ONE_MINUS_SRC_ALPHA

     即 1 - 0.8 = 0.2

     0.2*0.6 , 0.2*0.5 , 0.2*0.4 , 0.2*0.3

     结果为 0.12 , 0.1 , 0.08 , 0.06

     由此而见，使用这个混合函数，源色的α值决定了结果颜色的百分比。

     这里源色的α值为0.8，即结果颜色中源色占80%，目标色占20%。*/
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//混合函数

    self.emitterBlocks = [NSArray arrayWithObjects:[^{//1
        self.autoSpawnDeleta = 0.5f;
        self.particleEffect.gravity = AGLKDefaultGravity;
        float randomXVelocity = -0.5f +1.0f * (float)random()/(float)RAND_MAX;

        [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.9f) velocity:GLKVector3Make(randomXVelocity, 1.0f, -1.0f) force:GLKVector3Make(0.0f, 9.0f, 0.0f) size:4.0f lifeSpanSeconds:3.2f fadeDurationSeconds:0.5f];
    } copy],[^{//2
        self.autoSpawnDeleta = 0.05f;
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.5f, .0f);
        for (int i=0; i<20; i++) {

            float randomXVelocity = -0.1f +.2f * (float)random()/(float)RAND_MAX;
            float randomZVelocity = 0.1f +.2f * (float)random()/(float)RAND_MAX;
            [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f, -.5f, 0.0f) velocity:GLKVector3Make(randomXVelocity, 0.0f, randomZVelocity) force:GLKVector3Make(0.0f, 0.0f, 0.0f) size:16.0f lifeSpanSeconds:2.2f fadeDurationSeconds:3.0f];
        }

    } copy],[^{//3
        self.autoSpawnDeleta = 0.5f;
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.0f, .0f);
        for (int i=0; i<100; i++) {

            float randomXVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;

            [self.particleEffect
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     randomYVelocity,
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.5f];
        }

    } copy],[^{//4
        self.autoSpawnDeleta = 3.2f;
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.0f, .0f);
        for (int i=0; i<100; i++) {

            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            GLKVector3 velocity = GLKVector3Normalize(
                                                      GLKVector3Make(
                                                                     randomXVelocity,
                                                                     randomYVelocity,
                                                                     0.0f));

            [self.particleEffect
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:velocity
             force:GLKVector3MultiplyScalar(velocity, -1.5f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.1f];
        }

    } copy], nil];
    [self preparePointOfViewWithAspectRatio:CGRectGetWidth(self.view.bounds) /CGRectGetHeight( self.view.bounds) ];
}

-(void)update{
    NSTimeInterval timeElapsed = self.timeSinceFirstResume;
    self.particleEffect.elapsedSeconds = timeElapsed;

    if (self.autoSpawnDeleta <(timeElapsed - self.lastSpwnTime)) {

        self.lastSpwnTime = timeElapsed;
        void(^emitterBlock)(void) = [self.emitterBlocks objectAtIndex:self.currentEmitterIndex];
        emitterBlock();
    }
}
//MVP矩阵
-(void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio{
    /*

     参数1：视角，要求输入幅度，GLKMathDegreesToRadians帮助我们把角度值转换为幅度。
     参数2：算屏幕的宽高比，如果不正确设置，可能显示不出画面。
     参数3：near，
     参数4：far
     near和far共同决定了可视深度，都必须为正值，near一般设为一个比较小的数，far必须大于near。
     */
 self.particleEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f), aspectRatio, 0.1f, 20.0f);
    self.particleEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(0.0f, 0.0f, 1.0f,//eye position
                         0.0f, 0.0, 0.0,// Look-at position
                         0.0, 1.0, 0.0);//up direction
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    ++self.mElapseTime;
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glClearColor(0.3, .3, .3, 1);
    [self.particleEffect prepareToDraw];
    [self.particleEffect draw];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation !=
            UIInterfaceOrientationPortraitUpsideDown);
}
- (IBAction)takeSelectedEmitterFrom:(UISegmentedControl *)sender {
    self.currentEmitterIndex = [sender selectedSegmentIndex];
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
