Shader "Hidden/ColorCorrection" {
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
            float4 _ColorFilter;
            float _Exposure, _Temperature, _Tint, _Contrast, _Brightness, _Saturation, _Gamma;

            float luminance(float3 color) {
                return dot(color, float3(0.299f, 0.587f, 0.114f));
            }

            //https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/White-Balance-Node.html
            float3 WhiteBalance(float3 col, float temp, float tint) {
                float t1 = temp * 10.0f / 6.0f;
                float t2 = tint * 10.0f / 6.0f;

                float x = 0.31271 - t1 * (t1 < 0 ? 0.1 : 0.05);
                float standardIlluminantY = 2.87 * x - 3 * x * x - 0.27509507;
                float y = standardIlluminantY + t2 * 0.05;

                float3 w1 = float3(0.949237, 1.03542, 1.08728);

                float Y = 1;
                float X = Y * x / y;
                float Z = Y * (1 - x - y) / y;
                float L = 0.7328 * X + 0.4296 * Y - 0.1624 * Z;
                float M = -0.7036 * X + 1.6975 * Y + 0.0061 * Z;
                float S = 0.0030 * X + 0.0136 * Y + 0.9834 * Z;
                float3 w2 = float3(L, M, S);

                float3 balance = float3(w1.x / w2.x, w1.y / w2.y, w1.z / w2.z);

                float3x3 LIN_2_LMS_MAT = {
                    3.90405e-1, 5.49941e-1, 8.92632e-3,
                    7.08416e-2, 9.63172e-1, 1.35775e-3,
                    2.31082e-2, 1.28021e-1, 9.36245e-1
                };

                float3x3 LMS_2_LIN_MAT = {
                    2.85847e+0, -1.62879e+0, -2.48910e-2,
                    -2.10182e-1,  1.15820e+0,  3.24281e-4,
                    -4.18120e-2, -1.18169e-1,  1.06867e+0
                };

                float3 lms = mul(LIN_2_LMS_MAT, col);
                lms *= balance;
                return mul(LMS_2_LIN_MAT, lms);
            }

            fixed4 fp(v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);

                col.rgb *= _Exposure;
                col = max(0.0f, col);

                col.rgb = WhiteBalance(col.rgb, _Temperature, _Tint);
                col = max(0.0f, col);

                col.rgb = _Contrast * (col.rgb - 0.5f) + 0.5f + _Brightness;
                col = max(0.0f, col);

                col.rgb *= _ColorFilter.rgb;
                col = max(0.0f, col);

                col.rgb = lerp(luminance(col.rgb), col.rgb, _Saturation);
                col = max(0.0f, col);

                return col;
            }
            ENDCG
        }
    }
}