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
 ){
    NSCAssert(AGLKFrustumHasDimention(frustumPtr), @"Invalid frustumPtr parameter");

    AGLKFrustumIntersectionType result = AGLKFrustumIn;

    //eye到point的向量
    const GLKVector3 eyeToPoint = GLKVector3Subtract(frustumPtr->eyePosition, point);

    //z轴的分量
    const GLfloat pointZComponent = GLKVector3DotProduct(eyeToPoint, frustumPtr->zUnitVector);

    if (pointZComponent > frustumPtr->farDistance || pointZComponent < frustumPtr->nearDistance) {
        return AGLKFrustumOut;
    }else{
        const GLfloat pointYComponent = GLKVector3DotProduct(eyeToPoint, frustumPtr->yUnitVector);
        const GLfloat frustumHeightAtZ = pointZComponent * frustumPtr->tangentOfHalfFieldOfView;

        if (pointYComponent > frustumHeightAtZ || pointYComponent < -frustumHeightAtZ) {
            result = AGLKFrustumOut;
        }else{
            //X轴分量
            const GLfloat pointXComponent = GLKVector3DotProduct(eyeToPoint, frustumPtr->xUnitVector);
            const GLfloat frustumWidthAtZ = frustumHeightAtZ * frustumPtr->aspectRatio;

            if (pointXComponent > frustumWidthAtZ || pointXComponent < -frustumWidthAtZ) {
                result = AGLKFrustumOut;
            }
        }
    }
    return  result;
}


//判断球体是否子啊平截体内
extern AGLKFrustumIntersectionType AGLKFrustumCompareSphere
(
 const AGLKFrustum *frustumPtr,
 GLKVector3 center,
 GLfloat radius
 ){
    NSCAssert(AGLKFrustumHasDimention(frustumPtr), @"Invalid frustumPtr parameter");
    AGLKFrustumIntersectionType result = AGLKFrustumIn;

    const GLKVector3 eyeToCenter = GLKVector3Subtract(frustumPtr->eyePosition , center);
    const GLfloat centerZCompontent = GLKVector3DotProduct(eyeToCenter, frustumPtr->zUnitVector);
    if (centerZCompontent > (frustumPtr->farDistance + radius) || centerZCompontent < (frustumPtr->nearDistance - radius)) {
        result = AGLKFrustumOut;
    }else if (centerZCompontent > (frustumPtr->farDistance - radius) || centerZCompontent < (frustumPtr->nearDistance + radius)){
        result = AGLKFrustumInterSects;
    }

    if (AGLKFrustumOut != result) {
        const GLfloat centerYcomponent = GLKVector3DotProduct(eyeToCenter, frustumPtr->yUnitVector);
        const GLfloat yDistance = frustumPtr->sphereFactorY * radius;
        const GLfloat frustumHalfHeightAtZ = centerZCompontent * frustumPtr->tangentOfHalfFieldOfView;
        if (centerYcomponent > (frustumHalfHeightAtZ + yDistance) || centerYcomponent < (-frustumHalfHeightAtZ - yDistance)) {
            result = AGLKFrustumOut;
        }
        else if (centerYcomponent > (frustumHalfHeightAtZ - yDistance) || centerYcomponent < (-frustumHalfHeightAtZ + yDistance)){
            result = AGLKFrustumInterSects;
        }


    }
    return result;
}

extern GLKMatrix4 AGLKFrustumMakePerspective(
                                             const AGLKFrustum *frustumPtr
                                             ){
    NSCAssert(AGLKFrustumHasDimention(frustumPtr), @"Invalid frustumPtr parameter");
    const GLfloat cotan = 1.0 / frustumPtr-> tangentOfHalfFieldOfView;
    const GLfloat nearZ = frustumPtr->nearDistance;
    const GLfloat farZ = frustumPtr->farDistance;
    GLKMatrix4 m = {
        cotan / frustumPtr->aspectRatio, 0.0, 0.0, 0.0,
        0.0, cotan, 0.0, 0.0,
        0.0, 0.0, (farZ + nearZ) / (nearZ - farZ), -1.0f,
        0.0, 0.0, (2.0 * farZ * nearZ) / (nearZ - farZ),0.0

    };
    return m;
}

extern GLKMatrix4 AGLKFrustumMakeModelView(
                                           const AGLKFrustum *frustumMakePtr
                                           ){
    NSCAssert(AGLKFrustumHasDimention(frustumMakePtr), @"Invalid frustumPtr parameter");
    const GLKVector3 eyePosition = frustumMakePtr->eyePosition;
    const GLKVector3 xNormal = frustumMakePtr->xUnitVector;
    const GLKVector3 yNormal = frustumMakePtr->yUnitVector;
    const GLKVector3 zNormal = frustumMakePtr->zUnitVector;
    const GLfloat xTranslation = GLKVector3DotProduct(xNormal, eyePosition);
    const GLfloat yTranslation = GLKVector3DotProduct(yNormal, eyePosition);
    const GLfloat zTranslation = GLKVector3DotProduct(zNormal, eyePosition);

    GLKMatrix4 m ={
        xNormal.x, yNormal.x, zNormal.x, 0.0,
        xNormal.y, yNormal.y, zNormal.y, 0.0,
        xNormal.z, yNormal.z, zNormal.z, 0.0,

        -xTranslation, -yTranslation, -zTranslation, 1.0f
    };
    return m;
}

