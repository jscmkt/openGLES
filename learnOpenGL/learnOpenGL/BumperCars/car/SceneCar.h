//
//  SceneCar.h
//  learnOpenGL
//
//  Created by you&me on 2019/6/18.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SceneModel.h"


NS_ASSUME_NONNULL_BEGIN

@protocol SceneCarControllerProtocol

-(NSTimeInterval)timeSinceLastUpdate;
-(SceneAxisAllignedBoundingBox)rinkBoundingBox;
-(NSArray *)cars;

@end

@interface SceneCar : NSObject

@property(nonatomic,assign)long mCarId;
@property(nonatomic,strong,readonly)SceneModel *model;
@property(nonatomic,assign,readonly)GLKVector3 postition;
@property(nonatomic,assign,readonly)GLKVector3 nextPosition;
@property(nonatomic,assign,readonly)GLKVector3 velocity;
@property(nonatomic,assign,readonly)GLfloat yawRadians;
@property(nonatomic,assign,readonly)GLfloat targetYawRadians;
@property(nonatomic,assign,readonly)GLKVector4  color;
@property(nonatomic,assign,readonly)GLfloat radius;

-(id)initWithModel:(SceneModel *)aModel
          position:(GLKVector3)aPosition
          velocity:(GLKVector3)aVelocity
             color:(GLKVector4)aColor;

-(void)updateWithController:(id<SceneCarControllerProtocol>)controller;

-(void)drawWithBaseEffect:(GLKBaseEffect *)anEffect;

+(long)getBounceCount;

-(void)onSpeedChande:(BOOL)slow;

@end
///滤波器函数
///高通滤波器函数，可以模拟撞墙后震动的效果
extern GLfloat SceneScalarFastLowPassFilter(NSTimeInterval timeSineceLastUpdate, GLfloat target,GLfloat current);

extern GLfloat SceneScalarSlowLowPassFilter(NSTimeInterval timeSineceLastUpdate, GLfloat target,GLfloat current);
extern GLKVector3 SceneVector3FastLowPassFilter(NSTimeInterval timeSineceLastUpdate, GLKVector3 target,GLKVector3 current);
extern GLKVector3 SceneVector3SlowLowPassFilter(NSTimeInterval timeSineceLastUpdate, GLKVector3 target,GLKVector3 current);

NS_ASSUME_NONNULL_END
