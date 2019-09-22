#include <metal_stdlib>
#include <simd/simd.h>


using namespace metal;

kernel void cellTimetunnel(texture2d<half, access::read_write> inTex  [[texture(0)]],
                           texture2d<half, access::read_write> outTex [[texture(1)]],
                           constant float &version [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]]) {

    if ((gid.x >= inTex.get_width()) ||
        (gid.y >= inTex.get_height())) { return; } // discard out of bounds

    const uint2 ni(gid.x, gid.y - 1);
    const uint2 ei(gid.x + 1, gid.y);
    const uint2 si(gid.x, gid.y + 1);
    const uint2 wi(gid.x - 1, gid.y);

    const uint2 nwi(gid.x - 1, gid.y - 1);
    const uint2 nei(gid.x + 1, gid.y - 1);
    const uint2 sei(gid.x + 1, gid.y + 1);
    const uint2 swi(gid.x - 1, gid.y + 1);

    const uint2 ci(gid.x,     gid.y);

    const uint N = uint(inTex.read(ni).b * 255);
    const uint E = uint(inTex.read(ei).b * 255);
    const uint S = uint(inTex.read(si).b * 255);
    const uint W = uint(inTex.read(wi).b * 255);

    const uint NW = uint(inTex.read(nwi).b * 255);
    const uint NE = uint(inTex.read(nei).b * 255);
    const uint SE = uint(inTex.read(sei).b * 255);
    const uint SW = uint(inTex.read(swi).b * 255);

    const uint C = uint(inTex.read(ci).b * 255);

    half4 inItem = inTex.read(gid);

    uint ua = uint(inItem.a*255);
    uint ur = uint(inItem.r*255);
    uint ug = uint(inItem.g*255);
    uint ub = uint(inItem.b*255);

    uint HiC = (ua << 8) + ur;
    uint LiC = (ug << 8) + ub;
    uint LiC2 = (LiC << 1); // center left 1;
    uint LiC1 = (LiC >> 1) & 1; //replace bit 0 with bit 1
    uint CC = (C&1);

    uint NSEW0 = (N&1)  + (S&1)  + (E&1)  + (W&1);
    uint NSEW1 = (NW&1) + (NE&1) + (SE&1) + (SW&1);
    uint NSEW2 = NSEW0+NSEW1;
    uint NSEWC0 = NSEW0 + CC;
    uint NSEWC1 = NSEW1 + CC;
    uint NSEWC2 = NSEW2 + CC;
    uint parity = 1;

    switch (uint(version*5)) {
        case 0: parity = ((NSEW0  == 0) ? 0 : (NSEW0  == 5) ? 0 : 1); break;
        case 1: parity = ((NSEW1  == 0) ? 0 : (NSEW1  == 5) ? 0 : 1); break;
        case 2: parity = ((NSEW2  == 0) ? 0 : (NSEW2  == 9) ? 0 : 1); break;
        case 3: parity = ((NSEWC0 == 0) ? 0 : (NSEWC0 == 5) ? 0 : 1); break;
        case 4: parity = ((NSEWC1 == 0) ? 0 : (NSEWC1 == 5) ? 0 : 1); break;
        case 5: parity = ((NSEWC2 == 0) ? 0 : (NSEWC2 == 9) ? 0 : 1); break;
    }
    uint r1 = (parity ^ LiC1) | LiC2;
    uint r2 = 256 - r1;
    uint r3 = HiC + (r1 & 3);

    ua = (r3 >> 8) & 0xFF;
    ur = r3 & 0xFF;
    ug = r2 & 0xFF;
    ub = r1 & 0xFF;

    float fa = float(ua)/255;
    float fr = float(ur)/255;
    float fg = float(ug)/255;
    float fb = float(ub)/255;

    half4 outItem = half4(fr,fg,fb,fa);

    outTex.write(outItem, gid);
}

/// this is kinda interesting
kernel void cellTimetunnelMistake(texture2d<half, access::read_write> inTex  [[texture(0)]],
                                  texture2d<half, access::read_write> outTex [[texture(1)]],
                                  constant float &version [[buffer(0)]],
                                  uint2 gid [[thread_position_in_grid]]) {

    uint xs = outTex.get_width();   // width
    uint ys = outTex.get_height();  // height// height
    if (gid.x >= xs || gid.y >= ys) { return; } // discard out of bounds

    const uint2 ni(gid.x, gid.y - 1);
    const uint2 si(gid.x, gid.y + 1);
    const uint2 wi(gid.x - 1, gid.y);
    const uint2 ei(gid.x + 1, gid.y);
    const uint2 ci(gid.x,     gid.y);

    const int N = int(inTex.read(ni).g * 255);
    const int S = int(inTex.read(si).g * 255);
    const int W = int(inTex.read(wi).g * 255);
    const int E = int(inTex.read(ei).g * 255);
    const int C = int(inTex.read(ci).g * 255);

    half4 inItem = inTex.read(gid);

    int ua = int(inItem.a*255);
    int ur = int(inItem.r*255);
    int ug = int(inItem.g*255);
    int ub = int(inItem.b*255);

    int HiC = (ua << 8) + ur;
    int LiC = (ug << 8) + ub;
    int LiC2 = (LiC << 1); // center left 1;
    int LiC1 = (LiC >> 1) & 1; //replace bit 0 with bit 1

        // next two lines replaces buf.map0[N&1+S&1+E&1+W&1+C&1] for int32_t map0[6]  = { 0,1,1,1,1,0 };
    int mapsum = N&1 + S&1 + E&1 + W&1 + C&1;
    int parity = mapsum == 0 ? 0 : mapsum == 5 ? 0 : 1;

    int r1 = (parity ^ LiC1) | LiC2;
    int r2 = 256-r1;
    int r3 = HiC + (r1 & 0x80);

    ua = (r3 >> 8) & 0xFF;
    ur = r3 & 0xFF;
    ug = r2 & 0xFF;
    ub = r1 & 0xFF;

    float fa = float(ua)/255;
    float fr = float(ur)/255;
    float fg = float(ug)/255;
    float fb = float(ub)/255;

    half4 outItem = half4(fr,fg,fb,fa);

    outTex.write(outItem, gid);
}

