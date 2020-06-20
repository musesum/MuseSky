#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;
#define Range(x,min,max) (x<min ? min : (x>max ? max : x))

kernel void cellMelt(texture2d<half, access::read_write> inTex  [[texture(0)]],
                     texture2d<half, access::read_write> outTex [[texture(1)]],
                     constant float &version [[buffer(0)]],
                     constant float &bits    [[buffer(1)]],
                     uint2 gid [[thread_position_in_grid]]) {
    
    uint xs = outTex.get_width();   // width
    uint ys = outTex.get_height();  // height// height
    if (gid.x >= xs || gid.y >= ys) { return; } // discard out of bounds
    
        // border issues
    if (gid.x == 0 || gid.y == 0 || gid.x == xs-1 || gid.y == ys-1) {
          outTex.write(inTex.read(gid), gid);
          return;
      }

    const uint2 ci(gid.x, gid.y);     // center index
    const uint2 ni(gid.x, gid.y - 1); // north index
    const uint2 si(gid.x, gid.y + 1); // south index
    const uint2 ei(gid.x + 1, gid.y); // east index
    const uint2 wi(gid.x - 1, gid.y); // west index

    const half4 c = inTex.read(ci); // center
    const half4 n = inTex.read(ni); // north
    const half4 s = inTex.read(si); // south
    const half4 e = inTex.read(ei); // east
    const half4 w = inTex.read(wi); // west

    const float HiN = (n.a * 255) * exp2(8.) + (n.r * 255); // hi north
    const float LiN = (n.g * 255) * exp2(8.) + (n.b * 255); // lo north
    const float HiS = (s.a * 255) * exp2(8.) + (s.r * 255); // hi south
    const float LiS = (s.g * 255) * exp2(8.) + (s.b * 255); // lo south
    const float HiE = (e.a * 255) * exp2(8.) + (e.r * 255); // hi east
    const float LiE = (e.g * 255) * exp2(8.) + (e.b * 255); // lo east
    const float HiW = (w.a * 255) * exp2(8.) + (w.r * 255); // hi west
    const float LiW = (w.g * 255) * exp2(8.) + (w.b * 255); // lo west
    const float HiC = (c.a * 255) * exp2(8.) + (c.r * 255); // hi center
    const float LiC = (c.g * 255) * exp2(8.) + (c.b * 255); // lo cennter 
    const float C = HiC * exp2(16.) + LiC;

    float r1 = (LiC + LiN + LiS + LiE + LiW) / 5;
    float r2 = ((C / exp2(10+version*4)) + HiN + HiS + HiE + HiW) / (68 - 56 * version);
    float d1 = (0xffff - r1) / exp2(9 - 4 * version);

    r1 = Range(r1+d1, 0, 0xffff);
    r2 = Range(r2   , 0, 0xffff);

    float fa = trunc(r2/exp2(8.)) / 255.;
    float fr = fmod(r2     ,256.) / 255.;
    float fg = trunc(r1/exp2(8.)) / 255.;
    float fb = fmod(r1     ,256.) / 255.;

    half4 outItem = half4(fr,fg,fb,fa);

    outTex.write(outItem, gid);
}
