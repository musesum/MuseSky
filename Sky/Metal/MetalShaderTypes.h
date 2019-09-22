
#ifndef MetalShaderTypes_h
#define MetalShaderTypes_h

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float2 texCoord; // 2D texture coordinate
} MetalVertex;

typedef struct {
    float repeat[2];
    float mirror[2];
    float divide[2];
} MetalRenderBuf;

#endif
