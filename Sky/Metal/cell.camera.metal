#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

kernel void cellCamera(texture2d<float, access::read>  inTex  [[ texture(0) ]],
                       texture2d<float, access::write> outTex [[ texture(1) ]],
                       texture2d<float> altTex [[ texture(2) ]],
                       constant uint  &camType [[ buffer(0) ]],
                       constant float &version [[ buffer(1) ]],
                       constant float4  &frame [[ buffer(2) ]],
                       uint2 gid [[ thread_position_in_grid ]],
                       sampler samplr [[sampler(0)]]) {

    float ix(frame[0]);     // alt fill x offset 0...n
    float iy(frame[1]);     // alt fill y offset 0...n

    float iw(frame[2]);     // input total width 0...n
    float iiw = iw - 2*ix;  // input fill width 0...n
    float iiwf = iiw/iw;    // input fill fraction of total 0...1
    float iiwd = ix/iiw;    // input offset 0...1

    float ih(frame[3]);     // input total height 0...n
    float iih = ih - 2*iy;  // input fill height 0...n
    float iihf = iih/ih;    // input fill fraction of total 0...1
    float iihd = iy/iih;    // input offset 0...1

    float ow(outTex.get_width());  // output width 0...n
    float oh(outTex.get_height()); // output height 0...n

    float oox = gid.x/ow; // output x 0...1
    float ooy = gid.y/oh; // output y 0...1

    float iix = ix>iy ? (oox * iiwf + iiwd) : (oox * iihf + iihd); // x position inside input
    float iiy = ix>iy ? (ooy * iihf + iihd) : (ooy * iiwf + iiwd); // y position inside input

    float2 out;

    typedef enum  { frontPhone=0, frontPad, backPhone, backPad } CameraType;
    switch (camType) {
        case frontPhone: out.x = iiy; out.y =    iix; break; // iphone front facing
        case backPhone:  out.x = iiy; out.y = 1.-iix; break; // iphone back facing

        case frontPad:   out.x = iix; out.y = 1.-iiy; break; // iPad front facing
        case backPad:    out.x = iix; out.y =    iiy; break; // iPad back facing
    }

    float4 outItem = altTex.sample(samplr,out);
    
    outTex.write(outItem, gid);
}
