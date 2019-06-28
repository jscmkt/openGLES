//
//  AGLKFrustum.m
//  learnOpenGL
//
//  Created by you&me on 2019/6/26.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "AGLKFrustum.h"

//调用此函数
//投影矩阵通过AGLKFrustumMakePerspective()返回
AGLKFrustum AGLKFrustumMakeFrustumWithParameters
(
 GLfloat fieldOfViewRad,
 GLfloat aspectRatio,
 GLfloat nearDistance,
 GLfloat farDistance
 ){
    AGLKFrustum frustum;
    AGLKFrustumSetPerspective(&frustum,
                              fieldOfViewRad,
                              aspectRatio,
                              nearDistance,
                              farDistance);
    return frustum;
}

//设置平截体
extern void AGLKFrustumSetPerspective(
                                             AGLKFrustum *frustumPtr,
                                             GLfloat fieldOfViewRad,
                                             GLfloat aspectRatio,
                                             GLfloat nearDistance,
                                             GLfloat farDistance
                                             ){
    NSCAssert(NULL != frustumPtr, @"Invalid fieldOfViewRad");
    NSCAssert(0.0 < fieldOfViewRad && M_PI > fieldOfViewRad, @"Invalid fieldOfViewRad");
    NSCAssert(0.0 < aspectRatio, @"Invalid aspectRatio");
    NSCAssert(nearDistance < farDistance, @"Invalid farDistance");

    const GLfloat halfFieldOfViewRad = 0.5 *fieldOfViewRad;
    frustumPtr->aspectRatio = aspectRatio;
    frustumPtr->nearDistance = nearDistance;
    frustumPtr->farDistance = farDistance;

    //正弦值
    frustumPtr->tangentOfHalfFieldOfView = tanf(halfFieldOfViewRad);
    frustumPtr->nearHeight = nearDistance * frustumPtr->tangentOfHalfFieldOfView;
    frustumPtr->nearWidth = frustumPtr->nearHeight *aspectRatio;

    //计算球体放大因子
    frustumPtr->sphereFactorY = 1.0/cosf(halfFieldOfViewRad);
    const GLfloat angleX = atanf(frustumPtr->tangentOfHalfFieldOfView * aspectRatio);
    frustumPtr->sphereFactorX = 1.0/cosf(angleX);
}

GLK_INLINE GLfloat AGLKVector3LengthSquared(GLKVector3 vector)
{
    return (vector.v[0] * vector.v[0] +
            vector.v[1] * vector.v[1] +
            vector.v[2] * vector.v[2]
            );
}

//eye位置和朝向
extern void AGLKFrustumSetPositionAndDirection
(
 AGLKFrustum *frustumPtr,
 GLKVector3 postion,
 GLKVector3 lookAtPosition,
 GLKVector3 up
 ){
    NSCAssert(NULL != frustumPtr, @"Invalid frustumPtr parameter");

    frustumPtr->eyePosition = postion;

    //Z轴 从 yeye position 到 look at position
    const GLKVector3 lookAtVector = GLKVector3Subtract(postion, lookAtPosition);
    NSCAssert(0.0 < AGLKVector3LengthSquared(lookAtVector), @"Invalid eyeLookPosition parameter");
    frustumPtr->zUnitVector = GLKVector3Normalize(lookAtVector);

    //x轴 z轴和up向量的叉积
    frustumPtr->xUnitVector = GLKVector3CrossProduct(GLKVector3Normalize(up), frustumPtr->zUnitVector);

    // Y轴 x轴和z轴的叉积
    frustumPtr->yUnitVector = GLKVector3CrossProduct(frustumPtr->zUnitVector, frustumPtr->xUnitVector);
}

extern void AGLKFrustumSetToMatchModelView(AGLKFrustum *frustumPtr, GLKMatrix4 modelView){
    frustumPtr->xUnitVector = GLKVector3Make(modelView.m00, modelView.m10, modelView.m20);
    frustumPtr->yUnitVector = GLKVector3Make(modelView.m01, modelView.m11, modelView.m21);
    frustumPtr->zUnitVector = GLKVector3Make(modelView.m02, modelView.m12, modelView.m22);

}

//判断平截体是否初始化
extern BOOL AGLKFrustumHasDimention
(
 const AGLKFrustum *frustumPtr
 ){
    NSCAssert(NULL != frustumPtr, @"Invalid frustumPtr parameter");
    return (frustumPtr->nearDistance < frustumPtr->farDistance) && (0.0f < frustumPtr->tangentOfHalfFieldOfView) && (0.0 < fabs(frustumPtr->aspectRatio));
}

//判断点是否在平截体内
extern AGLKFrustumIntersectionType AGLKFrustumComparePoint
(
 const AGLKFrustum *frustumPtr,
 GLKVector3 point
 );

//判断球体是否子啊平截体内
extern AGLKFrustumIntersectionType AGLKFrustumCompareSphere
(
 const AGLKFrustum *frustumPtr,
 GLKVector3 center,
 GLfloat radius
 );

extern GLKMatrix4 AGLKFrustumMakePerspective(
                                             const AGLKFrustum *frustumPtr
                                             );

extern GLKMatrix4 AGLKFrustumMakeModelView(
                                           const AGLKFrustum *frustumMakePtr
                                           );

