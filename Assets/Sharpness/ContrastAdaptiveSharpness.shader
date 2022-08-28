Shader "Hidden/ContrastAdaptiveSharpness" {
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
            float _Amount;

            float3 Sample(float2 uv, float deltaX, float deltaY) {
                return saturate(tex2D(_MainTex, uv + float2(deltaX, deltaY) * _MainTex_TexelSize.xy).rgb);
            }

            float3 GetMin(float3 x, float3 y, float3 z) {
                return min(x, min(y, z));
            }

            float3 GetMax(float3 x, float3 y, float3 z) {
                return max(x, max(y, z));
            }

            float4 fp(v2f i) : SV_Target {
                float sharpness = -(1.0f / lerp(10.0f, 7.0f, saturate(_Amount)));

                float3 a = Sample(i.uv, -1, -1);
                float3 b = Sample(i.uv,  0, -1);
                float3 c = Sample(i.uv,  1, -1);
                float3 d = Sample(i.uv, -1,  0);
                float3 e = Sample(i.uv,  0,  0);
                float3 f = Sample(i.uv,  1,  0);
                float3 g = Sample(i.uv, -1,  1);
                float3 h = Sample(i.uv,  0,  1);
                float3 j = Sample(i.uv,  1,  1);

                float3 minRGB = GetMin(GetMin(d, e, f), b, h);
                float3 minRGB2 = GetMin(GetMin(minRGB, a, c), g, j);

                minRGB += minRGB2;

                float3 maxRGB = GetMax(GetMax(d, e, f), b, h);
                float3 maxRGB2 = GetMax(GetMax(maxRGB, a, c), g, j);

                maxRGB += maxRGB2;

                float3 rcpM = 1.0f / maxRGB;
                float3 amp = saturate(min(minRGB, 2.0f - maxRGB) * rcpM);
                amp = sqrt(amp);

                float3 w = amp * sharpness;
                float3 rcpW = 1.0f / (1.0f + 4.0f * w);

                float3 output = saturate((b * w + d * w + f * w + h * w + e) * rcpW);

                return float4(output, 1.0f);
            }
            ENDCG
        }
    }
}