#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

kernel void drawScroll(texture2d<half, access::read_write> inTex  [[texture(0)]],
                       texture2d<half, access::read_write> outTex [[texture(1)]],
                       constant float2 &scroll [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]]) {
    
    int xs = outTex.get_width();   // width
    int ys = outTex.get_height();  // height
    
    int x = (gid.x + xs + int((scroll.x-0.5) * 256.)) % xs;
    int y = (gid.y + ys + int((0.5-scroll.y) * 256.)) % ys;

    half4 item = inTex.read(uint2(x,y));

    outTex.write(item, gid);
}
