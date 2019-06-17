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
@end
