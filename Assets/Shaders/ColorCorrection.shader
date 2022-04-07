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
            float _Exposure, _Contrast, _Brightness, _Saturation, _Gamma;

            float luminance(float3 color) {
                return dot(color, float3(0.299f, 0.587f, 0.114f));
            }

            fixed4 fp(v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);

                col.rgb *= _Exposure;

                col = max(0.0f, col);
                col = min(1.0f, col);

                col.rgb = _Contrast * (col.rgb - 0.5f) + 0.5f + _Brightness;

                col = max(0.0f, col);
                col = min(1.0f, col);

                col.rgb *= _ColorFilter.rgb;
                
                col = max(0.0f, col);
                col = min(1.0f, col);

                float4 desaturated = luminance(col.rgb);

                col.rgb = lerp(desaturated.rgb, col.rgb, _Saturation);

                col = max(0.0f, col);
                col = min(1.0f, col);

                return col;
            }
            ENDCG
        }
    }
}