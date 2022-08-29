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
            int _KernelSize;

            float luminance(float3 color) {
                return dot(color, float3(0.299f, 0.587f, 0.114f));
            }

            // Returns avg color in .rgb, std in .a
            float4 SampleQuadrant(float2 uv, int x1, int x2, int y1, int y2, float n) {
                float luminance_sum = 0.0f;
                float luminance_sum2 = 0.0f;
                float3 col_sum = 0.0f;

                for (int x = x1; x <= x2; ++x) {
                    for (int y = y1; y <= y2; ++y) {
                        float3 sample = tex2D(_MainTex, uv + float2(x, y) * _MainTex_TexelSize.xy).rgb;
                        float l = luminance(sample);
                        luminance_sum += l;
                        luminance_sum2 += l * l;
                        col_sum += sample;
                    }
                }

                float mean = luminance_sum / n;
                float std = abs(luminance_sum2 / n - mean * mean);

                return float4(col_sum / n, std);
            }

            float4 fp(v2f i) : SV_Target {
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
                    return float4((q1.rgb + q2.rgb + q3.rgb + q4.rgb) / 4.0f, 1.0f);
                else
                    return float4(q1.rgb * q.x + q2.rgb * q.y + q3.rgb * q.z + q4.rgb * q.w, 1.0f);
            }
            ENDCG
        }
    }
}