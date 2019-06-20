//
//  SceneCar.m
//  learnOpenGL
//
//  Created by you&me on 2019/6/18.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "SceneCar.h"

@interface SceneCar ()

@property(nonatomic,strong,readwrite)SceneModel *model;
@property(nonatomic,assign,readwrite)GLKVector3 postition;
@property(nonatomic,assign,readwrite)GLKVector3 nextPosition;
@property(nonatomic,assign,readwrite)GLKVector3 velocity;
@property(nonatomic,assign,readwrite)GLfloat yawRadians;
@property(nonatomic,assign,readwrite)GLfloat targetYawRadians;
@property(nonatomic,assign,readwrite)GLKVector4  color;
@property(nonatomic,assign,readwrite)GLfloat radius;
@end

@implementation SceneCar
static long bounceCount;

+(void)initialize{
    bounceCount = 0;
}

+(long)getBounceCount{
    return bounceCount;
}
-(id)init{
    NSAssert(0, @"Invalid initalizer");
    self = nil;
    return self;
}

//Designated initalizer
-(id)initWithModel:(SceneModel *)aModel position:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity color:(GLKVector4)aColor{
    if (self = [super init]) {
        self.postition = aPosition;
        self.color = aColor;
        self.velocity = aVelocity;
        self.model = aModel;

        SceneAxisAllignedBoundingBox axisAlignedBoundingBox = self.model.axisAlignedBoundingBox;
        self.radius = 0.5f * MAX(axisAlignedBoundingBox.max.x - axisAlignedBoundingBox.min.x, axisAlignedBoundingBox.max.z - axisAlignedBoundingBox.min.z);
    }
    return self;
}

//检测car和墙的碰撞
-(void)bounceOffWallsWithBoundingBox:(SceneAxisAllignedBoundingBox)rinkBoundingBox{
    if ((rinkBoundingBox.min.x + self.radius)/*边框最小的x+小车的半径*/ > self.nextPosition.x) {
        //下一个点超过X最小的边界
        self.nextPosition = GLKVector3Make(rinkBoundingBox.min.x + self.radius, self.nextPosition.y, self.nextPosition.z);
        //撞墙后x方向 相反
        self.velocity = GLKVector3Make(-self.velocity.x, self.velocity.y, self.velocity.z);
    }else if ((rinkBoundingBox.max.x - self.radius) < self.nextPosition.x){
        //下一个点超过了x最大的边界
        self.nextPosition = GLKVector3Make(rinkBoundingBox.max.x - self.radius, self.nextPosition.y, self.nextPosition.z);
        self.velocity = GLKVector3Make(-self.velocity.x, self.velocity.y, self.velocity.z);

    }

    //z的边界的判断
    if ((rinkBoundingBox.min.z + self.radius)/*边框最小的z+小车的半径*/ > self.nextPosition.z) {
        //下一个点超过X最小的边界
        self.nextPosition = GLKVector3Make(rinkBoundingBox.min.x, self.nextPosition.y, self.nextPosition.z + self.radius);
        //撞墙后x方向 相反
        self.velocity = GLKVector3Make(self.velocity.x, self.velocity.y, -self.velocity.z);
    }else if ((rinkBoundingBox.max.z - self.radius) < self.nextPosition.z){
        //下一个点超过了x最大的边界
        self.nextPosition = GLKVector3Make(rinkBoundingBox.max.x, self.nextPosition.y, self.nextPosition.z - self.radius);
        self.velocity = GLKVector3Make(self.velocity.x, self.velocity.y,-self.velocity.z);
        
    }
}

#pragma mark - 检测cars之间的碰撞
-(void)bounceOffcars:(NSArray *)cars elapsedTime:(NSTimeInterval)elapsedTimeeSeconds{
    for (SceneCar *currentCar in cars) {
        if (currentCar != self) {
            float distance = GLKVector3Distance(self.nextPosition, currentCar.nextPosition);
            if ((2.0f * self.radius) > distance) {
                ++bounceCount;
                GLKVector3 ownVelocity = self.velocity;
                GLKVector3 otherVelocity = currentCar.velocity;
                GLKVector3 directionToOtherCar = GLKVector3Subtract(currentCar.postition, self.postition);
                directionToOtherCar = GLKVector3Normalize(directionToOtherCar);

                GLKVector3 negDirectionToOtherCar = GLKVector3Negate(directionToOtherCar);
                GLKVector3 tanOwnVelocity = GLKVector3MultiplyScalar(directionToOtherCar, GLKVector3DotProduct(ownVelocity, negDirectionToOtherCar)/*点乘*/);
                GLKVector3 tanOtherVelocity = GLKVector3MultiplyScalar(directionToOtherCar, GLKVector3DotProduct(otherVelocity, directionToOtherCar));
                GLKVector3 travelDistance;
                //更新自己的速度
                self.velocity = GLKVector3Subtract(ownVelocity, tanOwnVelocity);
                travelDistance = GLKVector3MultiplyScalar(self.velocity, elapsedTimeeSeconds);
                self.nextPosition = GLKVector3Add(self.postition, travelDistance);

                //更新其他car的速度
                currentCar.velocity = GLKVector3Subtract(otherVelocity, tanOtherVelocity);
                travelDistance = GLKVector3MultiplyScalar(currentCar.velocity, elapsedTimeeSeconds);
                currentCar.nextPosition = GLKVector3Add(currentCar.postition, travelDistance);
            }
        }
    }
}

-(void)spinTowardDirectionOfMotion:(NSTimeInterval)elapsed{
    self.yawRadians = SceneScalarSlowLowPassFilter(elapsed, self.targetYawRadians, self.yawRadians);
    if (self.mCarId > 0) {
        NSLog(@"yawRadians %f",GLKMathRadiansToDegrees(self.yawRadians));
    }
}

//更新car 的位置、偏航角和速度
// 模拟与墙和其他car的碰撞
-(void)updateWithController:(id<SceneCarControllerProtocol>)controller{
    //0.01秒和0.5秒之间
    NSTimeInterval elapsedTimeSeconds = MIN(MAX([controller timeSinceLastUpdate], 0.01f), 0.5f);
    GLKVector3 travelDistace = GLKVector3MultiplyScalar(self.velocity, elapsedTimeSeconds);
    self.nextPosition = GLKVector3Add(self.nextPosition, travelDistace);

    SceneAxisAllignedBoundingBox rinkBoundingBox = [controller rinkBoundingBox];

    [self bounceOffcars:[controller cars] elapsedTime:elapsedTimeSeconds];
    [self bounceOffWallsWithBoundingBox:rinkBoundingBox];
    if (0.1 > GLKVector3Length(self.velocity)) {
        //速度太小，方向可能是死角，随机换一个方向
        self.velocity = GLKVector3Make((random() / (0.5f * RAND_MAX)) - 1.0f, 0, (random() / (0.5 * RAND_MAX))-1.0f);
    }
    else if (4 > GLKVector3Length(self.velocity))
    { //缓慢加速
        self.velocity = GLKVector3MultiplyScalar(self.velocity, 1.01f);
    }

    //car的方向和标准方向的余弦值
    float dotProduct = GLKVector3DotProduct(GLKVector3Normalize(self.velocity), GLKVector3Make(0, 0, -1.0));

    if (0.0 > self.velocity.x) {
        //偏航角为正
        self.targetYawRadians = acosf(dotProduct);
    }else{
        //偏航角为负
        self.targetYawRadians = -acosf(dotProduct);
    }
    [self spinTowardDirectionOfMotion:elapsedTimeSeconds];
    self.nextPosition = self.nextPosition;

}

//绘制
-(void)drawWithBaseEffect:(GLKBaseEffect *)anEffect{
    //缓存
    GLKMatrix4 savedModelViewMatrix = anEffect.transform.modelviewMatrix;
    GLKVector4 savedDiffuseColor = anEffect.material.diffuseColor;
    GLKVector4 savedAmbientColor = anEffect.material.ambientColor;

    // Translate to the model's position
    anEffect.transform.modelviewMatrix = GLKMatrix4Translate(savedModelViewMatrix, self.postition.x, self.postition.y, self.postition.z);
    //绕Y轴旋转偏航角大小
    anEffect.transform.modelviewMatrix =
    GLKMatrix4Rotate(anEffect.transform.modelviewMatrix, self.yawRadians, 0, 1.0, 0);
    //设置材质
    anEffect.material.diffuseColor = self.color;
    anEffect.material.ambientColor = self.color;
    [anEffect prepareToDraw];
    [self.model draw];

    anEffect.transform.modelviewMatrix = savedModelViewMatrix;
    anEffect.material.diffuseColor = savedDiffuseColor;
    anEffect.material.ambientColor = savedAmbientColor;
}

-(void)onSpeedChande:(BOOL)slow{
    if (slow) {
        self.velocity = GLKVector3MultiplyScalar(self.velocity, 0.9);
    }else{
        self.velocity = GLKVector3MultiplyScalar(self.velocity, 1.1);
    }
}
@end
extern GLfloat SceneScalarFastLowPassFilter(NSTimeInterval elapsed, GLfloat target,GLfloat current){
    return current + 50.0 * elapsed * (target - current);
}

extern GLfloat SceneScalarSlowLowPassFilter(NSTimeInterval elapsed, GLfloat target,GLfloat current){
    return current + 4.0 * elapsed * (target - current);
}
extern GLKVector3 SceneVector3FastLowPassFilter(NSTimeInterval elapsed, GLKVector3 target,GLKVector3 current){
    return GLKVector3Make(SceneScalarFastLowPassFilter(elapsed, target.x, current.x),
                          SceneScalarFastLowPassFilter(elapsed, target.y, current.y),
                          SceneScalarFastLowPassFilter(elapsed, target.z, current.z));
}
extern GLKVector3 SceneVector3SlowLowPassFilter(NSTimeInterval elapsed, GLKVector3 target,GLKVector3 current){
    return GLKVector3Make(SceneScalarSlowLowPassFilter(elapsed, target.x, current.x),
                          SceneScalarSlowLowPassFilter(elapsed, target.y, current.y),
                          SceneScalarSlowLowPassFilter(elapsed, target.z, current.z));
}


