//
//  AGLKVertexAttribArrayBuffer.m
//  learnOpenGL
//
//  Created by you&me on 2019/4/9.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@interface AGLKVertexAttribArrayBuffer()
@property(nonatomic,assign)GLsizeiptr bufferSizeBytes;
@property(nonatomic,assign)GLsizeiptr stride;
@end

@implementation AGLKVertexAttribArrayBuffer
///This method creates a vertex attribute array buffer in the current OpenGL ES context for the thread upon which this method is called
-(id)initWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage{
    NSParameterAssert(0<stride);
    NSAssert((0 < count && NULL != dataPtr) || (0 == count && NULL == dataPtr), @"data must not be NUll or count >0");

    if(self = [super init]){
        self.stride = stride;
        self.bufferSizeBytes = stride * count;
        glGenBuffers(1, &_name);         // STEP 1
        glBindBuffer(GL_ARRAY_BUFFER, self.name); // STEP 2
        glBufferData(                  // STEP 3
                     GL_ARRAY_BUFFER,  // Initialize buffer contents
                     self.bufferSizeBytes,  // Number of bytes to copy
                     dataPtr,          // Address of bytes to copy
                     usage);           // Hint: cache in GPU memory
        NSAssert(0 != _name, @"Failed to generate name");
    }
    return self;
}
///This method loads the data storeed by the receiver.
-(void)reinitWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr{
    NSParameterAssert(0<stride);
    NSParameterAssert(0<count);
    NSParameterAssert(NULL != dataPtr);
    NSAssert(0 != self.name, @"Invalid name");

    self.stride = stride;
    self.bufferSizeBytes = stride * count;
    glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                 self.name);
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER,  // Initialize buffer contents
                 self.bufferSizeBytes,  // Number of bytes to copy
                 dataPtr,          // Address of bytes to copy
                 GL_DYNAMIC_DRAW);

}


-(void)prepareTodrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable{
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(offset < self.stride);
    NSAssert(0 != self.name, @"Invalid name");
    glBindBuffer(GL_ARRAY_BUFFER, self.name);//STEP 2
    if (shouldEnable) {
        glEnableVertexAttribArray(index); //step 4
    }

    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, self.stride, NULL + offset);
    // first coord for attribute
#ifdef DEBUG
    {  // Report any errors
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif


}


/////////////////////////////////////////////////////////////////
// Submits the drawing command identified by mode and instructs
// OpenGL ES to use count vertices from the buffer starting from
// the vertex at index first. Vertex indices start at 0.
- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count
{
    NSAssert(self.bufferSizeBytes >=
             ((first + count) * self.stride),
             @"Attempt to draw more vertex data than available.");

    glDrawArrays(mode, first, count); // Step 6
}


/////////////////////////////////////////////////////////////////
// Submits the drawing command identified by mode and instructs
// OpenGL ES to use count vertices from previously prepared
// buffers starting from the vertex at index first in the
// prepared buffers
+(void)drawPreparedArraysWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count{
    glDrawArrays(mode, first, count);//step6
}



// This method deletes the receiver's buffer from the current
// Context when the receiver is deallocated.
-(void)dealloc{
    if (0 != _name) {
        glDeleteBuffers(1, &_name);
        _name = 0;
    }
}
@end
