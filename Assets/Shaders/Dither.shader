Shader "Hidden/Dither" {
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

            static const int bayer2[2 * 2] = {
                0, 2,
                3, 1
            };

            static const int bayer8[8 * 8] = {
                0, 32, 8, 40, 2, 34, 10, 42,
                48, 16, 56, 24, 50, 18, 58, 26,  
                12, 44,  4, 36, 14, 46,  6, 38, 
                60, 28, 52, 20, 62, 30, 54, 22,  
                3, 35, 11, 43,  1, 33,  9, 41,  
                51, 19, 59, 27, 49, 17, 57, 25, 
                15, 47,  7, 39, 13, 45,  5, 37, 
                63, 31, 55, 23, 61, 29, 53, 21
            };

            float GetBayer(int x, int y, int n) {
                return float(bayer8[(x % n) + (y % n) * n]) * (1.0f / (n * n)) - 0.5f;
            }

            fixed4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                int x = i.uv.x * _MainTex_TexelSize.z;
                int y = i.uv.y * _MainTex_TexelSize.w;

                float4 output = col + 0.75f * GetBayer(x, y, 8);

                int colorCount = 4;

                output.r = floor((colorCount - 1.0f) * output.r + 0.5) / (colorCount - 1.0f);
                output.g = floor((colorCount - 1.0f) * output.g + 0.5) / (colorCount - 1.0f);
                output.b = floor((colorCount - 1.0f) * output.b + 0.5) / (colorCount - 1.0f);

                return output;
            }
            ENDCG
        }
    }
}