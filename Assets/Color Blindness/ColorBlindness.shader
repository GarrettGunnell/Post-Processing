Shader "Hidden/ColorBlindess" {
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
            float _Severity;
        ENDCG

        // Normal
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }

        // Protanopia
        Pass {
            CGPROGRAM

            #pragma vertex vp
            #pragma fragment fp

            #include "Protanomaly.cginc"

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                int p1 = min(10.0f, floor(_Severity * 10.0f));
                int p2 = min(10.0f, floor((_Severity + 0.1f) * 10.0f));
                float weight = frac(_Severity * 10.0f);

                float3x3 blindness = lerp(protanomalySeverities[p1], protanomalySeverities[p2], weight);

                col.rgb = mul(col.rgb, blindness);

                return col;
            }
            ENDCG
        }

        // Deuteranopia
        Pass {
            CGPROGRAM

            #pragma vertex vp
            #pragma fragment fp

            #include "Deuteranomaly.cginc"

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                int p1 = min(10.0f, floor(_Severity * 10.0f));
                int p2 = min(10.0f, floor((_Severity + 0.1f) * 10.0f));
                float weight = frac(_Severity * 10.0f);

                float3x3 blindness = lerp(deuteranomalySeverities[p1], deuteranomalySeverities[p2], weight);

                col.rgb = mul(col.rgb, blindness);

                return col;
            }
            ENDCG
        }
    }
}