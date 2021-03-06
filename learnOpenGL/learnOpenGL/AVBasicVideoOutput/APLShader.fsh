
varying highp vec2 texCoordVarying;
precision mediump float;

uniform float lumaThreshold;
uniform float chromaThreshold;
uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;
uniform mat3 colorConversionMatrix;

void main(){
    mediump vec3 yuv;
    lowp vec3 rgb;
    //减去常数来映射从0开始的视频范围
    yuv.x = (texture2D(SamplerY, texCoordVarying).r - (16.0/255.0)) * lumaThreshold;
    yuv.yz = (texture2D(SamplerUV,texCoordVarying).rg - vec2(0.5,0.5)) * chromaThreshold;

    rgb = colorConversionMatrix * yuv;
    gl_FragColor = vec4(rgb,1);

}
