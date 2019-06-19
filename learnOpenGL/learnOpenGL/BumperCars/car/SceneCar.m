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
    
}
@end
