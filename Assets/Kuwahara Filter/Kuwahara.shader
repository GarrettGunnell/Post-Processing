Shader "Hidden/Kuwahara" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {

        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            #include "UnityCG.cginc"

            struct VertexData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vp(VertexData v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            int _KernelSize, _MinKernelSize, _AnimateSize, _AnimateOrigin;
            float _SizeAnimationSpeed, _NoiseFrequency;

            float luminance(float3 color) {
                return dot(color, float3(0.299f, 0.587f, 0.114f));
            }

            float hash(uint n) {
                // integer hash copied from Hugo Elias
                n = (n << 13U) ^ n;
                n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
                return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
            }

            // Returns avg color in .rgb, std in .a
            float4 SampleQuadrant(float2 uv, int x1, int x2, int y1, int y2, float n) {
                float luminance_sum = 0.0f;
                float luminance_sum2 = 0.0f;
                float3 col_sum = 0.0f;

                [loop]
                for (int x = x1; x <= x2; ++x) {
                    [loop]
                    for (int y = y1; y <= y2; ++y) {
                        float3 sample = tex2D(_MainTex, uv + float2(x, y) * _MainTex_TexelSize.xy).rgb;
                        float l = luminance(sample);
                        luminance_sum += l;
                        luminance_sum2 += l * l;
                        col_sum += saturate(sample);
                    }
                }

                float mean = luminance_sum / n;
                float std = abs(luminance_sum2 / n - mean * mean);

                return float4(col_sum / n, std);
            }

            float4 fp(v2f i) : SV_Target {
                if (_AnimateSize) {
                    uint seed = i.uv.x + _MainTex_TexelSize.z * i.uv.y + _MainTex_TexelSize.z * _MainTex_TexelSize.w;
                    seed = i.uv.y * _MainTex_TexelSize.z * _MainTex_TexelSize.w;
                    float kernelRange = (sin(_Time.y * _SizeAnimationSpeed + hash(seed) * _NoiseFrequency) * 0.5f + 0.5f) * _KernelSize + _MinKernelSize;
                    int minKernelSize = floor(kernelRange);
                    int maxKernelSize = ceil(kernelRange);
                    float t = frac(kernelRange);

                    float windowSize = 2.0f * minKernelSize + 1;
                    int quadrantSize = int(ceil(windowSize / 2.0f));
                    int numSamples = quadrantSize * quadrantSize;

                    float4 q1 = SampleQuadrant(i.uv, -minKernelSize, 0, -minKernelSize, 0, numSamples);
                    float4 q2 = SampleQuadrant(i.uv, 0, minKernelSize, -minKernelSize, 0, numSamples);
                    float4 q3 = SampleQuadrant(i.uv, 0, minKernelSize, 0, minKernelSize, numSamples);
                    float4 q4 = SampleQuadrant(i.uv, -minKernelSize, 0, 0, minKernelSize, numSamples);

                    float minstd = min(q1.a, min(q2.a, min(q3.a, q4.a)));
                    int4 q = float4(q1.a, q2.a, q3.a, q4.a) == minstd;
    
                    float4 result1 = 0;
                    if (dot(q, 1) > 1)
                        result1 = saturate(float4((q1.rgb + q2.rgb + q3.rgb + q4.rgb) / 4.0f, 1.0f));
                    else
                        result1 = saturate(float4(q1.rgb * q.x + q2.rgb * q.y + q3.rgb * q.z + q4.rgb * q.w, 1.0f));

                    windowSize = 2.0f * maxKernelSize + 1;
                    quadrantSize = int(ceil(windowSize / 2.0f));
                    numSamples = quadrantSize * quadrantSize;

                    q1 = SampleQuadrant(i.uv, -maxKernelSize, 0, -maxKernelSize, 0, numSamples);
                    q2 = SampleQuadrant(i.uv, 0, maxKernelSize, -maxKernelSize, 0, numSamples);
                    q3 = SampleQuadrant(i.uv, 0, maxKernelSize, 0, maxKernelSize, numSamples);
                    q4 = SampleQuadrant(i.uv, -maxKernelSize, 0, 0, maxKernelSize, numSamples);

                    minstd = min(q1.a, min(q2.a, min(q3.a, q4.a)));
                    q = float4(q1.a, q2.a, q3.a, q4.a) == minstd;
    
                    float4 result2 = 0;
                    if (dot(q, 1) > 1)
                        result2 = saturate(float4((q1.rgb + q2.rgb + q3.rgb + q4.rgb) / 4.0f, 1.0f));
                    else
                        result2 = saturate(float4(q1.rgb * q.x + q2.rgb * q.y + q3.rgb * q.z + q4.rgb * q.w, 1.0f));

                    return lerp(result1, result2, t);
                } else {
                    float windowSize = 2.0f * _KernelSize + 1;
                    int quadrantSize = int(ceil(windowSize / 2.0f));
                    int numSamples = quadrantSize * quadrantSize;


                    float4 q1 = SampleQuadrant(i.uv, -_KernelSize, 0, -_KernelSize, 0, numSamples);
                    float4 q2 = SampleQuadrant(i.uv, 0, _KernelSize, -_KernelSize, 0, numSamples);
                    float4 q3 = SampleQuadrant(i.uv, 0, _KernelSize, 0, _KernelSize, numSamples);
                    float4 q4 = SampleQuadrant(i.uv, -_KernelSize, 0, 0, _KernelSize, numSamples);

                    float minstd = min(q1.a, min(q2.a, min(q3.a, q4.a)));
                    int4 q = float4(q1.a, q2.a, q3.a, q4.a) == minstd;
    
                    if (dot(q, 1) > 1)
                        return saturate(float4((q1.rgb + q2.rgb + q3.rgb + q4.rgb) / 4.0f, 1.0f));
                    else
                        return saturate(float4(q1.rgb * q.x + q2.rgb * q.y + q3.rgb * q.z + q4.rgb * q.w, 1.0f));
                }
            }
            ENDCG
        }
    }
}