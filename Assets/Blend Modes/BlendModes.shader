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

        float luminance(float3 color) {
            return dot(color, float3(0.299f, 0.587f, 0.114f));
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
                float4 a = tex2D(_MainTex, i.uv);
                float4 b = GetBlendLayer(i.uv);

                return float4(lerp(a.rgb, a.rgb * b.rgb, _Strength), a.a);
            }
            ENDCG
        }

        // Screen
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            fixed4 fp(v2f i) : SV_Target {
                float4 a = tex2D(_MainTex, i.uv);
                float4 b = GetBlendLayer(i.uv);

                float3 blended = 1.0f - (1.0f - a.rgb) * (1.0f - b.rgb);

                return float4(lerp(a.rgb, blended, _Strength), a.a);
            }
            ENDCG
        }

        // Overlay
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            fixed4 fp(v2f i) : SV_Target {
                float4 a = tex2D(_MainTex, i.uv);
                float4 b = GetBlendLayer(i.uv);

                float3 blended = 1.0f;

                if (luminance(a) < 0.5)
                    blended = 2.0f * a.rgb * b.rgb;
                else
                    blended = 1.0f - 2.0f * (1.0f - a.rgb) * (1.0f - b.rgb);

                return float4(lerp(a.rgb, blended, _Strength), a.a);
            }
            ENDCG
        }

        // Hard Light
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            fixed4 fp(v2f i) : SV_Target {
                float4 a = tex2D(_MainTex, i.uv);
                float4 b = GetBlendLayer(i.uv);

                float3 blended = 1.0f;

                if (luminance(b) < 0.5)
                    blended = 1.0f - 2.0f * (1.0f - a.rgb) * (1.0f - b.rgb);
                else
                    blended = 2.0f * a.rgb * b.rgb;

                return float4(lerp(a.rgb, blended, _Strength), a.a);
            }
            ENDCG
        }

        // Soft Light
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            fixed4 fp(v2f i) : SV_Target {
                float4 a = tex2D(_MainTex, i.uv);
                float4 b = GetBlendLayer(i.uv);

                float4 blended = 1.0f;

                if (luminance(b) < 0.5)
                    blended = 2.0f * a * b + (a * a) * (1.0f - 2.0f * b);
                else
                    blended = 2.0f * a * (1.0f - b) + sqrt(a) * (2.0f * b - 1.0f);

                return float4(lerp(a.rgb, blended.rgb, _Strength), a.a);
            }
            ENDCG
        }
    }
}