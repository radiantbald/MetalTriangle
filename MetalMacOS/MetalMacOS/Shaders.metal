//
//  Shaders.metal
//  MetalMacOS
//
//  Created by Олег Попов on 30.05.2022.
//

#include <metal_stdlib>
#include "../ShaderDefinitions.h"

using namespace metal;

typedef struct VertexOut {
    float4 pos [[ position ]];
    float3 color;
} VertexOut;

vertex VertexOut vertex_main(const device VertexIn *verticies [[ buffer(0) ]],
                             const device VertexUniforms& uniforms [[ buffer(1) ]],
                          uint id [[ vertex_id ]] ) {
    VertexIn in = verticies[id];
    VertexOut out = {
        .pos = float4(uniforms.modelMatrix * in.pos, 1.0),
        .color = in.color
    };
    return out;
}


fragment float4 fragment_main(VertexOut in [[ stage_in ]]) {
    return float4(in.color, 1.0);
}
