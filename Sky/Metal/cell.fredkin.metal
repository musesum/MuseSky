#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

kernel void cellFredkin(texture2d<half, access::read_write> inTex  [[texture(0)]],
                        texture2d<half, access::read_write> outTex [[texture(1)]],
                        constant float &version [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]]) {

    uint xs = outTex.get_width();   // width
    uint ys = outTex.get_height();  // height// height
    if (gid.x >= xs || gid.y >= ys) { return; } // discard out of bounds
    
    // no modulos to wrap, so borders are pre-wrapped by drawScroll.metal
    if (gid.x == 0 || gid.y == 0 || gid.x == xs-1 || gid.y == ys-1) {
        outTex.write(inTex.read(gid), gid);
        return;
    }

    const uint2 ci(gid.x, gid.y);
    const uint2 ni(gid.x, gid.y + 1);
    const uint2 si(gid.x, gid.y - 1);
    const uint2 ei(gid.x + 1, gid.y);
    const uint2 wi(gid.x - 1, gid.y);
    const uint2 nwi(gid.x - 1, gid.y + 1);
    const uint2 nei(gid.x + 1, gid.y + 1);
    const uint2 sei(gid.x + 1, gid.y - 1);
    const uint2 swi(gid.x - 1, gid.y - 1);

    const half4 C = inTex.read(ci);

    const uint c = uint(inTex.read(ci).b * 256.);
    const uint n = uint(inTex.read(ni).b * 256.);
    const uint s = uint(inTex.read(si).b * 256.);
    const uint e = uint(inTex.read(ei).b * 256.);
    const uint w = uint(inTex.read(wi).b * 256.);

    const uint nw = uint(inTex.read(nwi).b * 256.);
    const uint ne = uint(inTex.read(nei).b * 256.);
    const uint se = uint(inTex.read(sei).b * 256.);
    const uint sw = uint(inTex.read(swi).b * 256.);

    const uint HiC = (uint(C.a * 256.) << 8) + uint(C.r * 256.);

    int versioni = int(version*4);

    uint r1 = 0;
#define sum(n) ((c<<1) + ((c>>1) + n ) & 1) & 0xff;
    switch (versioni) {
        case 0: r1 = sum( n  + e  + s  + w); break;
        case 1: r1 = sum( nw + ne + se + sw); break;
        case 2: r1 = sum( n  + e  + s  + w + c); break;
        case 3: r1 = sum( nw + ne + se + sw + c); break;
        case 4: r1 = sum( n  + e  + s  + w + nw + ne + se + sw); break;
    }


    r1 = r1 + (r1<<6);
    uint r2 =  255 - r1;
    uint r3 = HiC + (r1 & 0x03);

    float fa = float(r3 >> 8) / 256.;
    float fr = float(r3 & 0xff) / 256.;
    float fg = float(r2) / 256.;
    float fb = float(r1) / 256.;
    half4 outItem = half4(fr,fg,fb,fa);
    outTex.write(outItem, gid);

}
