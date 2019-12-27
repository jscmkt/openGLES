//
//  AGLKPointParticleEffect.h
//  learnOpenGL
//
//  Created by you&me on 2019/5/14.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

extern const GLKVector3 AGLKDefaultGravity;

@interface AGLKPointParticleEffect : NSObject
@property(nonatomic,assign)GLKVector3 gravity;
@property(nonatomic,assign)GLfloat elapsedSeconds;
@property(nonatomic,strong,readonly)GLKEffectPropertyTexture *texture2d0;
@property(nonatomic,strong,readonly)GLKEffectPropertyTransform *transform;

-(void)addParticleAtPosition:(GLKVector3)aPosition
                    velocity:(GLKVector3)aVelocity
                       force:(GLKVector3)aForce
                        size:(float)aSize
             lifeSpanSeconds:(NSTimeInterval)aSpan
         fadeDurationSeconds:(NSTimeInterval)aDuration;

-(void)prepareToDraw;
-(void)draw;
@end

NS_ASSUME_NONNULL_END
