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

@end
