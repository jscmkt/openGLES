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
