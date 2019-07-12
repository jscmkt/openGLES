//
//  AGLKSkyBoxEffect.h
//  learnOpenGL
//
//  Created by you&me on 2019/7/5.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKSkyBoxEffect : NSObject
@property(nonatomic,assign)GLKVector3 center;
@property(nonatomic,assign)GLfloat xSize;
@property(nonatomic,assign)GLfloat ySize;
@property(nonatomic,assign)GLfloat zSize;
@property(nonatomic,strong,readonly)GLKEffectPropertyTexture *textureCubeMap;
@property(nonatomic,strong,readonly)GLKEffectPropertyTransform *transform;

-(void)prepareToDraw;
-(void)draw;
 
@end

NS_ASSUME_NONNULL_END
