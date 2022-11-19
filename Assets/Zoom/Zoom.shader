Shader "Hidden/Zoom" {
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

            Texture2D _MainTex;
            SamplerState point_clamp_sampler, linear_clamp_sampler;
            float4 _MainTex_TexelSize;
            float4 _Offset;
            float _Zoom, _Rotation;
            int _ZoomMode;

            #define PI 3.14159265358979323846f

            float4 texture2DAA(float2 uv) {
                float2 uv_texspace = uv * _MainTex_TexelSize.zw;
                float2 seam = floor(uv_texspace + 0.5f);
                uv_texspace = (uv_texspace - seam) / fwidth(uv_texspace) + seam;
                uv_texspace = clamp(uv_texspace, seam - 0.5f, seam + 0.5f);
                return _MainTex.Sample(linear_clamp_sampler, uv_texspace / _MainTex_TexelSize.zw);
            }

            float4 fp(v2f i) : SV_Target {
                float2 zoomUV = i.uv * 2 - 1;
                zoomUV += float2(_Offset.x, _Offset.y);
                zoomUV *= _Zoom;

                float radians = _Rotation * PI / 180.0f;
                float2x2 R = {
                    cos(radians), -sin(radians),
                    sin(radians), cos(radians)
                };
                zoomUV = mul(R, zoomUV);
                zoomUV = zoomUV * 0.5f + 0.5f;
                
                if (_ZoomMode == 0)
                    return _MainTex.Sample(point_clamp_sampler, zoomUV);
                else if (_ZoomMode == 1)
                    return texture2DAA(zoomUV);
                else
                    return _MainTex.Sample(linear_clamp_sampler, zoomUV);
            }
            ENDCG
        }
    }
}