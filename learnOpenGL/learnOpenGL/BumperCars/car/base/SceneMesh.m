//
//  SceneMesh.m
//  learnOpenGL
//
//  Created by you&me on 2019/6/13.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface SceneMesh ()
@property(nonatomic,strong)AGLKVertexAttribArrayBuffer *veretexAttributeBuffer;
@property(nonatomic,assign)GLuint indexBufferID;
@property(nonatomic,strong)NSData *vertexData;
@property(nonatomic,strong)NSData *indexData;

@end
@implementation SceneMesh

-(id)initWithVertexAttributeData:(NSData *)vertexAttributes indexData:(NSData *)indices{
    if (self = [super init]) {
        self.vertexData = vertexAttributes;
        self.indexData = indices;
    }
    return self;
}
-(id)initWithPositionCoords:(const GLfloat *)somePositions normalCoords:(const GLfloat *)someNormals texCoords0:(const GLfloat *)someTexCoords0 numberOfPositions:(size_t)countPositions indices:(const GLushort *)someIndices numberOfIndices:(size_t)countIndices{
    NSParameterAssert(NULL != somePositions);
    NSParameterAssert(NULL != someNormals);
    NSParameterAssert(0 < countPositions);

    NSMutableData *vertexArributesData = [[NSMutableData alloc]init];
    NSMutableData *indicesData = [[NSMutableData alloc]init];

    [indicesData appendBytes:someIndices length:countIndices];

    //把顶点数据转成二进制
    for (size_t i=0; i<countPositions; i++) {
        SceneMeshVertex currentVertex;
        currentVertex.position.x = somePositions[i*3+0];
        currentVertex.position.y = somePositions[i*3+1];
        currentVertex.position.z = somePositions[i*3+2];

        currentVertex.normal.x = someNormals[i*3+0];
        currentVertex.normal.y = someNormals[i*3+1];
        currentVertex.normal.z = someNormals[i*3+2];
        if (NULL != someTexCoords0) {
            currentVertex.texCoords0.s = someTexCoords0[i * 2 + 0];
            currentVertex.texCoords0.t = someTexCoords0[i * 2 + 1];
        }else{

            currentVertex.texCoords0.s = 0.0f;
            currentVertex.texCoords0.t = 0.0f;
        }
        [vertexArributesData appendBytes:&currentVertex length:sizeof(currentVertex)];
    }
    return [self initWithVertexAttributeData:vertexArributesData indexData:indicesData];
}

-(void)dealloc{

    if (0!= self.indexBufferID) {
        glDeleteBuffers(1, &_indexBufferID);
        self.indexBufferID = 0;
    }
}

-(void)prepareToDraw{
    if (nil == self.veretexAttributeBuffer && 0 < [self.vertexData length]) {
        //顶点数据还没有送至GPU
        self.veretexAttributeBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneMeshVertex) numberOfVertices:[self.vertexData length] / sizeof(SceneMeshVertex)  bytes:[self.vertexData bytes] usage:GL_STATIC_DRAW];
        self.vertexData = nil;
    }
    if(0 == self.indexBufferID && 0 < [self.indexData length])
    {
        //索引数组还没缓存
        glGenBuffers(1, &_indexBufferID);
        NSAssert(0 != self.indexBufferID, @"Failed to generate element array buffer");
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, [self.indexData length], [self.indexData bytes], GL_STATIC_DRAW);
        self.indexData = nil;
    }
    [self.veretexAttributeBuffer prepareTodrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneMeshVertex, position) shouldEnable:YES];
    [self.veretexAttributeBuffer prepareTodrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneMeshVertex, normal) shouldEnable:YES];
    [self.veretexAttributeBuffer prepareTodrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneMeshVertex, texCoords0) shouldEnable:YES];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
}

//不使用索引绘制
-(void)drawUnidexedWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count{
    [self.veretexAttributeBuffer drawArrayWithMode:mode startVertexIndex:first numberOfVertices:count];
}

//分配经常改动的内存
-(void)makeDynamicAndUpdateWithVertices:(const SceneMeshVertex *)someVerts numberOfVertices:(size_t)count{
    NSParameterAssert(NULL!=someVerts);
    NSParameterAssert(0<count);
    if (!self.veretexAttributeBuffer) {
        //vertex attiributes haven't been sent to GPU yet
        self.veretexAttributeBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneMeshVertex) numberOfVertices:count bytes:someVerts usage:GL_DYNAMIC_DRAW];

    }else{
        [self.veretexAttributeBuffer reinitWithAttribStride:sizeof(SceneMeshVertex) numberOfVertices:count bytes:someVerts];
    }
}

@end
