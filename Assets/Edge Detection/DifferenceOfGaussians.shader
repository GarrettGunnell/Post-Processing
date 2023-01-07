Shader "Hidden/DifferenceOfGaussians" {
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
        
        sampler2D _MainTex, _GaussianTex, _kGaussianTex;
        float4 _MainTex_TexelSize;
        int _GaussianKernelSize, _Thresholding, _Invert, _Tanh;
        float _Sigma, _Threshold, _K, _Tau, _Phi;
        
        float gaussian(float sigma, float pos) {
            return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
        }

        float luminance(float3 color) {
            return dot(color, float3(0.299f, 0.587f, 0.114f));
        }

        ENDCG

        // Blur Pass 1
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float2 col = 0;
                float kernelSum1 = 0.0f;
                float kernelSum2 = 0.0f;

                for (int x = -_GaussianKernelSize; x <= _GaussianKernelSize; ++x) {
                    float c = luminance(tex2D(_MainTex, i.uv + float2(x, 0) * _MainTex_TexelSize.xy));
                    float gauss1 = gaussian(_Sigma, x);
                    float gauss2 = gaussian(_Sigma * _K, x);

                    col.r += c * gauss1;
                    kernelSum1 += gauss1;

                    col.g += c * gauss2;
                    kernelSum2 += gauss2;
                }

                return float4(col.r / kernelSum1, col.g / kernelSum2, 0, 0);
            }
            ENDCG
        }

        // Blur Pass 2
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float2 col = 0;
                float kernelSum1 = 0.0f;
                float kernelSum2 = 0.0f;

                for (int y = -_GaussianKernelSize; y <= _GaussianKernelSize; ++y) {
                    float4 c = tex2D(_MainTex, i.uv + float2(0, y) * _MainTex_TexelSize.xy);
                    float gauss1 = gaussian(_Sigma, y);
                    float gauss2 = gaussian(_Sigma * _K, y);

                    col.r += c.r * gauss1;
                    kernelSum1 += gauss1;

                    col.g += c.g * gauss2;
                    kernelSum2 += gauss2;
                }

                return float4(col.r / kernelSum1, col.g / kernelSum2, 0, 0);
            }
            ENDCG
        }

        // Difference Of Gaussians
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float2 G = tex2D(_GaussianTex, i.uv).rg;

                float4 D = (G.r - _Tau * G.g);

                if (_Thresholding) {
                    if (_Tanh)
                        D = (D >= _Threshold) ? 1 : 1 + tanh(_Phi * (D - _Threshold));
                    else
                        D = (D >= _Threshold) ? 1 : 0;
                }

                if (_Invert)
                    D = 1 - D;

                return D;
            }
            ENDCG
        }
    }
}