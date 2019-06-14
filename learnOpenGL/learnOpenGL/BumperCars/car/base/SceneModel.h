//
//  SceneModel.h
//  learnOpenGL
//
//  Created by you&me on 2019/6/14.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;
@class SceneMesh;
NS_ASSUME_NONNULL_BEGIN


// 边界，注意min和max 都是vector3
typedef struct {
    GLKVector3 min;
    GLKVector3 max;
}
SceneAxisAllignedBoundingBox;

@interface SceneModel : NSObject
@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,assign,readonly)SceneAxisAllignedBoundingBox axisAlignedBoundingBox;

-(id)initWithName:(NSString *)aName
             mesh:(SceneMesh *)aMesh
 numberOfVertices:(GLsizei)aCount;

-(void)draw;

-(void)updateAlignedBoundingBOxForVertices:(float *)verts
                                     count:(unsigned int)aCount;
@end

NS_ASSUME_NONNULL_END
