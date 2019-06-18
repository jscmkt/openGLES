//
//  SceneRinkModel.m
//  learnOpenGL
//
//  Created by you&me on 2019/6/17.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "SceneRinkModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperRink.h"
@implementation SceneRinkModel
-(id)init{
    SceneMesh *rinkMesh = [[SceneMesh alloc]initWithPositionCoords:bumperRinkVerts normalCoords:bumperRinkNormals texCoords0:NULL numberOfPositions:bumperRinkNumVerts indices:NULL numberOfIndices:0];
    if (self = [super initWithName:@"bumberRink" mesh:rinkMesh numberOfVertices:bumperRinkNumVerts]) {
        [self updateAlignedBoundingBOxForVertices:bumperRinkVerts count:bumperRinkNumVerts];
    }
    return self;
}
@end
