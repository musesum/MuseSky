#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;


kernel void cellFader(texture2d<float, access::read> inTex  [[texture(0)]],
                      texture2d<float, access::write> outTex [[texture(1)]],
                      constant float &version [[buffer(0)]],
                      uint2 gid [[thread_position_in_grid]]) {
    
    uint xs = outTex.get_width();   // width
    uint ys = outTex.get_height();  // height// height
    if (gid.x >= xs || gid.y >= ys) { return; } // discard out of bounds
    
    float4 inItem = inTex.read(gid);
    
    float HiC = ((inItem.a * 256.) + inItem.r);
    
    float r1 = fmax(0,inItem.b - (version/128.));
    float r2 = 1.0 - r1;
    float r3 = HiC + fmod(r1,3./256.);
    
    float fa = trunc(r3)/256.;
    float fr = fract(r3);
    float fg = r2;
    float fb = r1;
    
    float4 outItem = float4(fr,fg,fb,fa);
    
    outTex.write(outItem, gid);
}
