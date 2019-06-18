//
//  SceneCarModel.m
//  learnOpenGL
//
//  Created by you&me on 2019/6/17.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "SceneCarModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperCar.h"
@implementation SceneCarModel

-(id)init{
    SceneMesh *carMesh = [[SceneMesh alloc]initWithPositionCoords:bumperCarVerts normalCoords:bumperCarNormals texCoords0:NULL numberOfPositions:bumperCarNumVerts indices:NULL numberOfIndices:0];
    if (self = [super initWithName:@"bumberCar" mesh:carMesh numberOfVertices:bumperCarNumVerts]) {
        [self updateAlignedBoundingBOxForVertices:bumperCarVerts count:bumperCarNumVerts];
    }
    return self;
}
@end
