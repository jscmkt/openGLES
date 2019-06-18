//
//  SceneModel.m
//  learnOpenGL
//
//  Created by you&me on 2019/6/14.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "SceneModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface SceneModel ()
@property(nonatomic,strong)SceneMesh *mesh;
@property(nonatomic,assign,readwrite)SceneAxisAllignedBoundingBox axisAlignedBoundingBox;
@property(nonatomic)GLsizei numberOfVertices;
@property(nonatomic,copy,readwrite)NSString *name;
@end
@implementation SceneModel

-(id)initWithName:(NSString *)aName mesh:(SceneMesh *)aMesh numberOfVertices:(GLsizei)aCount{
    if (self = [super init]) {
        self.name = aName;
        self.mesh = aMesh;
        self.numberOfVertices = aCount;
    }
    return self;
}
-(instancetype)init{
    NSAssert(0, @"Invslid initalizer");
    self = nil;
    return self;
}

-(void)preareToDraw{
    [self.mesh prepareToDraw];
}
-(void)draw{
    [self.mesh prepareToDraw];
    [self.mesh drawUnidexedWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:self.numberOfVertices];
}
//顶点树数据改变后，重新计算边界
-(void)updateAlignedBoundingBOxForVertices:(float *)verts count:(unsigned int)aCount{
    SceneAxisAllignedBoundingBox result = {{0,0,0},{0,0,0}};
    const GLKVector3 *positions = (const GLKVector3 *)verts;

    if (0<aCount) {
        result.min.x = result.max.x = positions[0].x;
        result.min.y = result.max.y = positions[0].y;
        result.min.z = result.max.z = positions[0].z;

    }
    for (int i=1; i<aCount; i++) {
        result.min.x = MIN(result.min.x, positions[i].x);
        result.min.y = MIN(result.min.y, positions[i].y);
        result.min.z = MIN(result.min.z, positions[i].z);
        result.max.x = MAX(result.max.x, positions[i].x);
        result.max.y = MAX(result.max.y, positions[i].y);
        result.max.z = MAX(result.max.z, positions[i].z);
    }
    self.axisAlignedBoundingBox = result;
}

@end
