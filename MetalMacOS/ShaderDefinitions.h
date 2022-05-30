//
//  ShaderDefinitions.h
//  MetalMacOS
//
//  Created by Олег Попов on 30.05.2022.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#import <simd/simd.h>

typedef struct {
    vector_float3 pos;
    vector_float3 color;
} VertexIn;

typedef struct {
    simd_float3x3 modelMatrix;
} VertexUniforms;

#endif /* ShaderDefinitions_h */
