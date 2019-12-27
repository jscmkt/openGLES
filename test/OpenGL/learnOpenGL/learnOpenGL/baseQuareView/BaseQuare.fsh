
varying highp  vec2 TexCoord;
//vec4 FragColor;
uniform sampler2D texture1;
uniform sampler2D texture2;

void main(){
    gl_FragColor = mix(texture2D(texture1,TexCoord),texture2D(texture2,TexCoord),0.5);
//    gl_FragColor = texture2D(texture1,TexCoord);
}
