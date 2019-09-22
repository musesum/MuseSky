#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

kernel void cellZhabatinski(texture2d<half, access::read_write> inTex  [[texture(0)]],
                            texture2d<half, access::read_write> outTex [[texture(1)]],
                            constant float &version [[buffer(0)]],
                            constant float &bits    [[buffer(1)]],
                            uint2 gid [[thread_position_in_grid]]) {
    
   uint xs = outTex.get_width();   // width
   uint ys = outTex.get_height();  // height
   if (gid.x >= xs || gid.y >= ys) { return; } // discard out of bounds

    // 2:7 3:11 4:7 5:11?
    //  const float version = 4.0/7.0;
    // int32_t threshold = version >> 1;                   // zmap threshold
    // int32_t annealing = ((version&1) << 1) + threshold;  // zmap annealing

    const int thresholds[7] = { 0b0000,  0b0001,  0b0001,  0b0010,  0b0101,  0b0110,  0b0111 };
    const int annealers[7]  = { 0b0010,  0b0001,  0b0011,  0b0010,  0b0111,  0b0110,  0b1001 };
    const int versioni = int(version*6);
    const int threshold = thresholds[versioni];
    const int annealing = annealers[versioni];

    const int bitsi = uint(bits);
    // bits/repeat 2:7 3:11 4:19
    //#define bits 1               // 0        1       2       3
    const int shift = bitsi+1;       // 1        2       3       4
    const int mask = (1 << bitsi)-1; // '0001   '0011    '0111   '1111

    const uint2 ni(gid.x,      gid.y - 1);
    const uint2 ei(gid.x + 1,  gid.y    );
    const uint2 si(gid.x,      gid.y + 1);
    const uint2 wi(gid.x - 1,  gid.y    );
    const uint2 nwi(gid.x - 1, gid.y - 1);
    const uint2 nei(gid.x + 1, gid.y - 1);
    const uint2 sei(gid.x + 1, gid.y + 1);
    const uint2 swi(gid.x - 1, gid.y + 1);

    const uint N  = uint(inTex.read(ni).b * 255);
    const uint E  = uint(inTex.read(ei).b * 255);
    const uint S  = uint(inTex.read(si).b * 255);
    const uint W  = uint(inTex.read(wi).b * 255);
    const uint NW = uint(inTex.read(nwi).b * 255);
    const uint NE = uint(inTex.read(nei).b * 255);
    const uint SE = uint(inTex.read(sei).b * 255);
    const uint SW = uint(inTex.read(swi).b * 255);

    half4 inItem = inTex.read(gid);

    uint ua = uint(inItem.a*255);
    uint ur = uint(inItem.r*255);
    uint ug = uint(inItem.g*255);
    uint ub = uint(inItem.b*255);

    uint HiC = (ua << 8) + ur;
    uint LiC = (ug << 8) + ub;

    int alarm  = (LiC >> shift) & 1;
    int time   = (LiC >> 1) & mask;
    int newself = time==0 ? 1 : 0;

    if (time > 0) time --;
    if (LiC & alarm & 1) {
        time = mask; // reset countdown
    }

    int32_t sum = (N&1)  + (S&1)  + (E&1)  + (W&1) +
    (NW&1) + (NE&1) + (SE&1) + (SW&1);

    alarm = ((sum  > threshold) &&   // threshold
             (sum != annealing));    // annealed

    int r1 = (alarm << shift) | (time << 1) | newself;
    uint r2 = 256 - r1;
    uint r3 = HiC + (r1 & 0x80);

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
