Shader "Hidden/BlendModes" {
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
        
        sampler2D _MainTex, _BlendTex;
        int _BlendType;
        float _Strength;
        float4 _BlendColor;

        float4 GetBlendLayer(float2 uv) {
            if (_BlendType == 0)
                return tex2D(_MainTex, uv);
            else if (_BlendType == 1)
                return tex2D(_BlendTex, uv);
            else
                return _BlendColor;
        }

        ENDCG
        
        // No Blend
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            fixed4 fp(v2f i) : SV_Target {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }

        // Multiply
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            fixed4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);
                float4 blend = GetBlendLayer(i.uv);

                return float4(lerp(col.rgb, col.rgb * blend.rgb, _Strength), col.a);
            }
            ENDCG
        }
    }
}