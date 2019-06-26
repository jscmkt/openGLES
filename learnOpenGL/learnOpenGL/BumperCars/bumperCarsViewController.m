//
//  bumperCarsViewController.m
//  learnOpenGL
//
//  Created by you&me on 2019/6/11.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "bumperCarsViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "SceneCarModel.h"
#import "SceneRinkModel.h"
#import "SceneCar.h"
@interface bumperCarsViewController ()
{
    NSMutableArray  *cars;
}

@property(strong,nonatomic)GLKBaseEffect *baseEffect;
@property(nonatomic,strong)SceneModel *carModel;
@property(nonatomic,strong)SceneModel *rinkModel;
@property(nonatomic,assign)BOOL shouldUseFirstPersonPOV;
@property(nonatomic,assign)GLfloat pointOfViewAnimationCountDown;
@property(nonatomic,assign)GLKVector3 eyePosition;
@property(nonatomic,assign)GLKVector3 lookAtPosition;
@property(nonatomic,assign)GLKVector3 targetEyePosition;
@property(nonatomic,assign)GLKVector3 targetLookAtPosition;
@property(nonatomic,assign,readwrite)SceneAxisAllignedBoundingBox rinkBoundingBox;
@property (weak, nonatomic) IBOutlet UILabel *myBounceLabel;
@property (weak, nonatomic) IBOutlet UILabel *myVelocityLabel;



@end

static const int  SceneNumberOfPOVAnimationSeconds = 2.0;

@implementation bumperCarsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //新建OpenGLES 上下文
    EAGLContext *mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];

    GLKView *view = (GLKView*)self.view;

    view.context = mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:view.context];
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);

    cars = [[NSMutableArray alloc]init];
    self.baseEffect = [[GLKBaseEffect alloc]init];

    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.6, 0.6, 0.6, 1.0);
    self.baseEffect.light0.position = GLKVector4Make(1.0, 0.8, 0.4, 0.0);
    self.carModel = [[SceneCarModel alloc]init];
    self.rinkModel = [[SceneRinkModel alloc]init];

    //场地
    self.rinkBoundingBox = self.rinkModel.axisAlignedBoundingBox;
    NSAssert(0 < (self.rinkBoundingBox.max.x - self.rinkBoundingBox.min.x) && 0 < (self.rinkBoundingBox.max.z - self.rinkBoundingBox.min.z), @"Rink has no area");

    SceneCar *newCar = [[SceneCar alloc]initWithModel:self.carModel position:GLKVector3Make(1.0, 0.0, 1.0) velocity:GLKVector3Make(1.5, 0.0, 1.5) color:GLKVector4Make(0.0, 0.5, 0, 1.0)];
    [cars addObject:newCar];

    newCar = [[SceneCar alloc]initWithModel:self.carModel position:GLKVector3Make(-1.0, 0.0, 1.0) velocity:GLKVector3Make(-1.5, 0.0, 1.5) color:GLKVector4Make(.5, .5, 0, 1.0)];
    [cars addObject:newCar];

    newCar = [[SceneCar alloc]initWithModel:self.carModel position:GLKVector3Make(1.0, 0, -1.0) velocity:GLKVector3Make(1.5, 0.0, 1.5) color:GLKVector4Make(0.5, 0, 0, 1.0)];
    [cars addObject:newCar];

    newCar = [[SceneCar alloc]initWithModel:self.carModel position:GLKVector3Make(2.0, 0, -2.0) velocity:GLKVector3Make(-1.5, 0, -0.5) color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)];
    [cars addObject:newCar];

    self.eyePosition = GLKVector3Make(10.5, 5.0, 0.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);

}
-(void)updatePointOfView{
    if (!self.shouldUseFirstPersonPOV) {
        self.targetEyePosition = GLKVector3Make(10.5, 5.0, 0.0);
        self.targetLookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
    }else{
        SceneCar *viewCar = [cars lastObject];
        self.targetEyePosition = GLKVector3Make(viewCar.postition.x, viewCar.postition.y + 0.45, viewCar.postition.z);
        self.targetLookAtPosition = GLKVector3Add(self.eyePosition, viewCar.velocity);


    }
}
-(void)update{
    if (0 < self.pointOfViewAnimationCountDown) {
        self.pointOfViewAnimationCountDown -= self.timeSinceLastUpdate;
        self.eyePosition = SceneVector3SlowLowPassFilter(self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        self.lookAtPosition = SceneVector3SlowLowPassFilter(self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    }else{
        NSLog(@"%f %f %f %f", self.timeSinceLastUpdate, self.eyePosition.x, self.eyePosition.y, self.eyePosition.z);
        self.eyePosition = SceneVector3FastLowPassFilter(self.timeSinceLastUpdate, self.targetEyePosition, self.eyePosition);
        self.lookAtPosition = SceneVector3FastLowPassFilter(self.timeSinceLastUpdate, self.targetLookAtPosition, self.lookAtPosition);
    }
    [cars makeObjectsPerformSelector:@selector(updateWithController:) withObject:self];

    [self updatePointOfView];
}

// 渲染场景代码
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3, 0.3, 0.3, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);

    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat) view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f), aspectRatio, 0.1, 25.0);
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         self.eyePosition.x,
                         self.eyePosition.y,
                         self.eyePosition.z,
                         self.lookAtPosition.x,
                         self.lookAtPosition.y,
                         self.lookAtPosition.z,
                         0, 1, 0);

    //场地
    [self.baseEffect prepareToDraw];
    [self.rinkModel draw];

    //碰碰车
    [cars makeObjectsPerformSelector:@selector(drawWithBaseEffect:) withObject:self.baseEffect];

    //碰撞次数
    self.myBounceLabel.text = [NSString stringWithFormat:@"%ld",[SceneCar getBounceCount]];
    SceneCar *viewerCar = [cars lastObject];
    self.myVelocityLabel.text = [NSString stringWithFormat:@"%.1f",GLKVector3Length(viewerCar.velocity)];

}

// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

/**
 *  设置特殊的界面支持的方向,这里特殊界面只支持Home在右侧的情况
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(NSArray *)cars{
    return cars;
}
- (IBAction)takeShouldUseFirstPersonPOVFrom:(UISwitch *)sender {
    self.shouldUseFirstPersonPOV = [sender isOn];
    self.pointOfViewAnimationCountDown = SceneNumberOfPOVAnimationSeconds;
}
- (IBAction)onSlow:(id)sender {
    SceneCar *car = [cars lastObject];
    [car onSpeedChande:YES];
}
- (IBAction)onFast:(id)sender {
    SceneCar *car = [cars lastObject];
    [car onSpeedChande:NO];
}
@end
