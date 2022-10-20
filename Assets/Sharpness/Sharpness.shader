Shader "Hidden/Sharpness" {
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

            float4 fp(v2f i) : SV_Target {
                float4 col = saturate(tex2D(_MainTex, i.uv));

                float neighbor = _Amount * -1;
                float center = _Amount * 4 + 1;

                float4 n = tex2D(_MainTex, i.uv + _MainTex_TexelSize * float2(0, 1));
                float4 e = tex2D(_MainTex, i.uv + _MainTex_TexelSize * float2(1, 0));
                float4 s = tex2D(_MainTex, i.uv + _MainTex_TexelSize * float2(0, -1));
                float4 w = tex2D(_MainTex, i.uv + _MainTex_TexelSize * float2(-1, 0));

                float4 output = n * neighbor + e * neighbor + col * center + s * neighbor + w * neighbor;

                return saturate(output);
            }
            ENDCG
        }
    }
}