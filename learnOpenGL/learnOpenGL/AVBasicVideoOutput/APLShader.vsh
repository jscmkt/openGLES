//绕x轴进行旋转（在yz平面顺时针旋转）
//
//[1 0 0;
// 0 cosalpha sinalpha;
// 0 -sinalpha cosalpha]
//绕y轴进行旋转（在zx平面顺时针旋转）
//
//
//[cosbeta 0 -sinbeta;
// 0 1 0;
// sinbeta 0 cosbeta]
//
//
//
//绕z轴进行旋转（在xy平面顺时针旋转）
//
//
//[cosgamma singamma 0;
// -singamma cosgamma 0;
// 0 0 1]
attribute vec4 position;
attribute vec2 texCoord;
uniform float preferredRotation;
varying vec2 texCoordVarying;
void main(){
    mat4 rotationMatrix = mat4( cos(preferredRotation),  -sin(preferredRotation),    0.0,    0.0,
                               sin(preferredRotation),   cos(preferredRotation),    0.0,    0.0,
                                                  0.0,                      0.0,    1.0,    0.0,
                               0.0,                      0.0,    0.0,    1.0);

    gl_Position = rotationMatrix * position;
    texCoordVarying = texCoord;
}
