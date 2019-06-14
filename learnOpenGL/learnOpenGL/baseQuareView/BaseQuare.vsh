
attribute vec3 aPos;
attribute vec2 aTexCoord;
varying vec2 TexCoord;

uniform highp mat4 model;
uniform highp mat4 view;
uniform highp mat4 projection;

void main(){
    gl_Position = projection * view *model *vec4(aPos,1.0);
    TexCoord = vec2(aTexCoord.x,1.0- aTexCoord.y);
}
