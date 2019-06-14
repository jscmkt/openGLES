//
//  AGLKVertexAttribArrayBuffer.h
//  learnOpenGL
//
//  Created by you&me on 2019/4/9.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AGLKElementIndexArrayBuffer;


typedef enum {
    AGLKVertexAttribPosition = GLKVertexAttribPosition,
    AGLKVertexAttribNormal = GLKVertexAttribNormal,
    AGLKVertexAttribColor = GLKVertexAttribColor,
    AGLKVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    AGLKVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
}AGLKVertexAttrib;

@interface AGLKVertexAttribArrayBuffer : NSObject
//{
//    GLsizeiptr  stride;
//    GLsizeiptr  bufferSizeBytes;
//    GLuint      name;
//}

@property(nonatomic,readonly)GLuint name;
@property(nonatomic,readonly)GLsizeiptr bufferSizeBytes;
@property(nonatomic,readonly)GLsizeiptr stride;


+(void)drawPreparedArraysWithMode:(GLenum)mode
                 startVertexIndex:(GLint)first
                 numberOfVertices:(GLsizei)count;

-(id)initWithAttribStride:(GLsizeiptr)stride
         numberOfVertices:(GLsizei)count
                    bytes:(const GLvoid*)dataPtr
                    usage:(GLenum)usage;

-(void)prepareTodrawWithAttrib:(GLuint)index
           numberOfCoordinates:(GLint)count
                  attribOffset:(GLsizeiptr)offset
                  shouldEnable:(BOOL)shouldEnable;

-(void)drawArrayWithMode:(GLenum)mode
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count;

-(void)reinitWithAttribStride:(GLsizeiptr)stride
             numberOfVertices:(GLsizei)count
                        bytes:(const GLvoid*)dataPtr;

@end

NS_ASSUME_NONNULL_END
