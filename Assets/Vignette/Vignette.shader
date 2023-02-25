Shader "Hidden/Vignette" {
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
            float2 _VignetteOffset, _VignetteSize;
            float _Intensity, _Roundness, _Smoothness;
            float3 _VignetteColor;

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                float2 pos = i.uv - 0.5f;
                pos *= _VignetteSize;
                pos += 0.5f;

                float2 d = abs(pos - (float2(0.5f, 0.5f) + _VignetteOffset)) * _Intensity;
                d = pow(saturate(d), _Roundness);
                float vfactor = pow(saturate(1.0f - dot(d, d)), _Smoothness);

                return float4(lerp(_VignetteColor, col.rgb, vfactor), 1.0f);
            }
            ENDCG
        }
    }
}
