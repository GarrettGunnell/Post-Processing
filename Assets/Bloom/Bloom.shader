Shader "Hidden/Bloom" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {

        CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float2 _MainTex_TexelSize;

            struct VertexData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float3 Sample(float2 uv) {
                return tex2D(_MainTex, uv).rgb;
            }

            float3 SampleBox(float2 uv, float delta) {
                float4 o = _MainTex_TexelSize.xyxy * float2(-delta, delta).xxyy;
                float3 s = Sample(uv + o.xy) + Sample(uv + o.zy) + Sample(uv + o.xw) + Sample(uv + o.zw);

                return s * 0.25f;
            }

            v2f vp(VertexData v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
        ENDCG

        // Filter pixels
        Pass {
            CGPROGRAM
            #pragma vertex vp 
            #pragma fragment fp

            float _Threshold, _SoftThreshold;

            float4 Prefilter(float4 col) {
                half brightness = max(col.r, max(col.g, col.b));
                half knee = _Threshold * _SoftThreshold;
                half soft = brightness - _Threshold + knee;
                soft = clamp(soft, 0, 2 * knee);
                soft = soft * soft / (4 * knee * 0.00001);
                half contribution = max(soft, brightness - _Threshold);
                contribution /= max(contribution, 0.00001);

                return col * contribution;
            }

            float4 fp(v2f i) : SV_TARGET {
                return Prefilter(pow(float4(SampleBox(i.uv, 1.0f), 1.0f), 2.2f));
            }
            ENDCG
        }

        // Box Downsample
        Pass {
            CGPROGRAM
            #pragma vertex vp 
            #pragma fragment fp

            float _DownDelta;

            float4 fp(v2f i) : SV_TARGET {
                return float4(SampleBox(i.uv, _DownDelta), 1.0f);
            }
            ENDCG
        }

        // Box Upsample
        Pass {
            Blend One One

            CGPROGRAM
            #pragma vertex vp 
            #pragma fragment fp

            float _UpDelta;

            float4 fp(v2f i) : SV_TARGET {
                return float4(SampleBox(i.uv, _UpDelta), 1.0f);
            }
            ENDCG
        }

        // Additive Blend Bloom
        Pass {
            CGPROGRAM
            #pragma vertex vp 
            #pragma fragment fp

            sampler2D _OriginalTex;
            float _Intensity;
            float _UpDelta;

            float4 fp(v2f i) : SV_TARGET {
                float4 col = tex2D(_OriginalTex, i.uv);
                col.rgb += _Intensity * pow(SampleBox(i.uv, _UpDelta), 1.0f / 2.2f);

                return col;
            }
            ENDCG
        }
    }
}