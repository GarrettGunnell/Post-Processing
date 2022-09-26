Shader "Hidden/Blur" {
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

        #define PI 3.14159265358979323846f
        
        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        int _KernelSize;
        float _Sigma;

        float gaussian(float sigma, float pos) {
            return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
        }

        ENDCG

        // Box Blur First Pass
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 output = 0;
                int sum = 0;
                for (int x = -_KernelSize; x <= _KernelSize; ++x) {
                    output += tex2D(_MainTex, i.uv + float2(x, 0) * _MainTex_TexelSize.xy);
                    ++sum;
                }

                return output / sum;
            }
            ENDCG
        }

        // Box Blur Second Pass
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 output = 0;
                int sum = 0;
                for (int y = -_KernelSize; y <= _KernelSize; ++y) {
                    output += tex2D(_MainTex, i.uv + float2(0, y) * _MainTex_TexelSize.xy);
                    ++sum;
                }
                
                return output / sum;
            }
            ENDCG
        }

        // Gaussian Blur First Pass
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 output = 0;
                float sum = 0;

                for (int x = -_KernelSize; x <= _KernelSize; ++x) {
                    float4 c = tex2D(_MainTex, i.uv + float2(x, 0) * _MainTex_TexelSize.xy);
                    float gauss = gaussian(_Sigma, x);
                    
                    output += c * gauss;
                    sum += gauss;
                }

                return output / sum;
            }
            ENDCG
        }

        // Gaussian Blur Second Pass
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 output = 0;
                float sum = 0;

                for (int y = -_KernelSize; y <= _KernelSize; ++y) {
                    float4 c = tex2D(_MainTex, i.uv + float2(0, y) * _MainTex_TexelSize.xy);
                    float gauss = gaussian(_Sigma, y);
                    
                    output += c * gauss;
                    sum += gauss;
                }

                return output / sum;
            }
            ENDCG
        }
    }
}