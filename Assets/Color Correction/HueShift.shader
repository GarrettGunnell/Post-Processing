Shader "Hidden/HueShift" {
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
            float _HueShift;


            // https://www.shadertoy.com/view/MsjXRt
            float4 HueShift(float3 col, float shift) {
                float3 P = 0.55735f * dot(0.55735, col);
                float3 U = col - P;
                float3 V = cross(0.55735, U);
                col = U * cos(shift * 6.2832) + V * sin(shift * 6.2832) + P;

                return float4(col, 1.0f);
            }

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                return HueShift(col, _HueShift);
            }
            ENDCG
        }
    }
}