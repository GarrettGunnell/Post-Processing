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

            float4 fp(v2f i) : SV_Target {
                int x, y;
                float windowSize = 2.0f * _KernelSize + 1;
                int quadrantSize = int(ceil(windowSize / 2.0f));
                int numSamples = quadrantSize * quadrantSize;

                // First Quadrant
                float luminance_sum_1 = 0.0f;
                float luminance_sum2_1 = 0.0f;
                float3 col_sum_1 = 0.0f;
                for (x = -_KernelSize; x <= 0; ++x) {
                    for (y = -_KernelSize; y <= 0; ++y) {
                        float3 sample = tex2D(_MainTex, i.uv + float2(x, y) * _MainTex_TexelSize.xy).rgb;
                        float l = luminance(sample);
                        luminance_sum_1 += l;
                        luminance_sum2_1 += l * l;
                        col_sum_1 += sample;
                    }
                }

                float mean_1 = luminance_sum_1 / numSamples;
                float std_1 = sqrt((luminance_sum2_1 / numSamples) - (mean_1 * mean_1));
                
                // Second Quadrant
                float luminance_sum_2 = 0.0f;
                float luminance_sum2_2 = 0.0f;
                float3 col_sum_2 = 0.0f;
                for (x = 0; x <= _KernelSize; ++x) {
                    for (y = -_KernelSize; y <= 0; ++y) {
                        float3 sample = tex2D(_MainTex, i.uv + float2(x, y) * _MainTex_TexelSize.xy).rgb;
                        float l = luminance(sample);
                        luminance_sum_2 += l;
                        luminance_sum2_2 += l * l;
                        col_sum_2 += sample;
                    }
                }

                float mean_2 = luminance_sum_2 / numSamples;
                float std_2 = sqrt((luminance_sum2_2 / numSamples) - (mean_2 * mean_2));

                // Third Quadrant
                float luminance_sum_3 = 0.0f;
                float luminance_sum2_3 = 0.0f;
                float3 col_sum_3 = 0.0f;
                for (x = 0; x <= _KernelSize; ++x) {
                    for (y = 0; y <= _KernelSize; ++y) {
                        float3 sample = tex2D(_MainTex, i.uv + float2(x, y) * _MainTex_TexelSize.xy).rgb;
                        float l = luminance(sample);
                        luminance_sum_3 += l;
                        luminance_sum2_3 += l * l;
                        col_sum_3 += sample;
                    }
                }

                float mean_3 = luminance_sum_3 / numSamples;
                float std_3 = sqrt((luminance_sum2_3 / numSamples) - (mean_3 * mean_3));

                // Fourth Quadrant
                float luminance_sum_4 = 0.0f;
                float luminance_sum2_4 = 0.0f;
                float3 col_sum_4 = 0.0f;
                for (x = -_KernelSize; x <= 0; ++x) {
                    for (y = 0; y <= _KernelSize; ++y) {
                        float3 sample = tex2D(_MainTex, i.uv + float2(x, y) * _MainTex_TexelSize.xy).rgb;
                        float l = luminance(sample);
                        luminance_sum_4 += l;
                        luminance_sum2_4 += l * l;
                        col_sum_4 += sample;
                    }
                }

                float mean_4 = luminance_sum_4 / numSamples;
                float std_4 = sqrt((luminance_sum2_4 / numSamples) - (mean_4 * mean_4));
                
                if (std_1 < std_2 && std_1 < std_3 && std_1 < std_4)
                    return float4(col_sum_1 / numSamples, 1.0f);
                else if (std_2 < std_1 && std_2 < std_3 && std_2 < std_4)
                    return float4(col_sum_2 / numSamples, 1.0f);
                else if (std_3 < std_1 && std_3 < std_2 && std_3 < std_4)
                    return float4(col_sum_3 / numSamples, 1.0f);
                else
                    return float4(col_sum_4 / numSamples, 1.0f);
            }
            ENDCG
        }
    }
}