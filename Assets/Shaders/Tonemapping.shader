Shader "Hidden/Tonemapping" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {

        CGINCLUDE
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
        ENDCG

        // Debug HDR
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                if (col.r > 1.0f || col.g > 1.0f || col.b > 1.0f)
                    return col;
                
                return 0.0f;
            }
            ENDCG
        }

        // No Tonemapping (Clamp RGB)
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                return saturate(tex2D(_MainTex, i.uv));
            }
            ENDCG
        }
    }
}