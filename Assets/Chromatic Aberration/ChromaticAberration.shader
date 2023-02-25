Shader "Hidden/ChromaticAberration" {
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
            bool _DebugMask;
            float2 _FocalOffset, _Radius;
            float _Hardness, _Intensity;
            float3 _ColorOffsets;

            float4 fp(v2f i) : SV_Target {
                float2 pos = i.uv - 0.5f;
                pos -= _FocalOffset;
                pos *= _Radius;
                pos += 0.5f;

                float2 d = pos - 0.5f;
                float intensity = saturate(pow(abs(length(pos - 0.5f)), _Hardness)) * _Intensity;
                
                if (_DebugMask)
                    return intensity;

                float4 col = 1.0f;
                float2 redUV = i.uv + (d * _ColorOffsets.r * _MainTex_TexelSize.xy) * intensity;
                float2 blueUV = i.uv + (d * _ColorOffsets.b * _MainTex_TexelSize.xy) * intensity;
                float2 greenUV = i.uv + (d * _ColorOffsets.g * _MainTex_TexelSize.xy) * intensity;

                col.r = tex2D(_MainTex, redUV).r;
                col.g = tex2D(_MainTex, blueUV).g;
                col.b = tex2D(_MainTex, greenUV).b;

                return col;
            }
            ENDCG
        }
    }
}
