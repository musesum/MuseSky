#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

kernel void cellSlide(texture2d<float, access::read> inTex  [[texture(0)]],
                      texture2d<float, access::write> outTex [[texture(1)]],
                      constant float &version [[buffer(0)]],
                      uint2 gid [[thread_position_in_grid]]) {


    uint xs = outTex.get_width();   // width
    uint ys = outTex.get_height();  // height// height
    if (gid.x >= xs || gid.y >= ys) { return; } // discard out of bounds

    // border issues
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

    const float4 C = inTex.read(ci);
    //const uint cb = uint(C.b * 255.);
    //const uint cg = uint(C.g * 255.);
    const uint cr = uint(C.r * 255.);
    const uint ca = uint(C.a * 255.);
    //const float c = inTex.read(ci).b;
    const uint n = uint(inTex.read(ni).b * 255.);
    const uint s = uint(inTex.read(si).b * 255.);
    const uint e = uint(inTex.read(ei).b * 255.);
    const uint w = uint(inTex.read(wi).b * 255.);

    const uint nw = uint(inTex.read(nwi).b * 255.);
    const uint ne = uint(inTex.read(nei).b * 255.);
    const uint se = uint(inTex.read(sei).b * 255.);
    const uint sw = uint(inTex.read(swi).b * 255.);
    const uint HiC = (ca << 8) + cr;

    uint cells[8] = { n, s, e, w, nw, se, sw, ne };

// each even/odd pair reverses order
//   index binary          000 001 010  011  100  101  110 111
//   cell position          n   s   e    w    nw   se   sw  ne
//
//  offset  = offset xor i = slide position
//  0   000 = 000 001 010  011  100  101  110 111 =  n   s   e    w    nw   se   sw  ne
//  1   001 = 001 000 011  010  101  100  111 110 =  s   n   w    e    se   nw   ne  sw
//  2   010 = 010 011 000  001  110  111  100 101 =  e   w   n    s    sw   ne   nw  se
//  3   011 = 011 010 001  000  111  110  101 100 =  w   e   s    n    ne   sw   se  nw
//  4   100 = 100 101 110  111  000  001  010 011 =  nw  se  sw   ne   n    s    e   w
//  5   101 = 101 100 111  110  001  000  011 010 =  se  nw  ne   sw   s    n    w   e
//  6   110 = 110 111 100  101  010  011  000 001 =  sw  ne  nw   se   e    w    n   s
//  7   111 = 111 110 101  100  011  010  001 000 =  ne  sw  se   nw   w    e    s   n


    uint r = 0;
    uint offset = uint(version * 7);
    for (int i=0, j=1; i<8; i++, j <<= 1) {
        int k = (i^offset);
        r += cells[k] & j;
    }
    uint r1 = r;
    uint r2 = 256 - r1;
    uint r3 = HiC;// + fmod(r1,7);

    float fa = float(r3 >> 8)   / 255.; // trunc(r3/255.) / 255.;
    float fr = float(r3 & 0xff) / 255.; //mod(r3,255.) / 255.;
    float fg = float(r2) / 255.;
    float fb = float(r1) / 255.;

    float4 outItem = float4(fr,fg,fb,fa);

    outTex.write(outItem, gid);
}
