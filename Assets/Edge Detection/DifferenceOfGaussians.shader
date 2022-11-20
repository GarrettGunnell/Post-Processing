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
        int _GaussianKernelSize, _Thresholding, _Invert;
        float _Sigma, _Threshold;
        
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
                float col = 0;
                float kernelSum = 0.0f;

                for (int x = -_GaussianKernelSize; x <= _GaussianKernelSize; ++x) {
                    float c = luminance(tex2D(_MainTex, i.uv + float2(x, 0) * _MainTex_TexelSize.xy));
                    float gauss = gaussian(_Sigma, x);

                    col += c * gauss;
                    kernelSum += gauss;
                }

                return col / kernelSum;
            }
            ENDCG
        }

        // Blur Pass 2
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 col = 0;
                float kernelSum = 0.0f;

                for (int y = -_GaussianKernelSize; y <= _GaussianKernelSize; ++y) {
                    float4 c = tex2D(_MainTex, i.uv + float2(0, y) * _MainTex_TexelSize.xy);
                    float gauss = gaussian(_Sigma, y);

                    col += c * gauss;
                    kernelSum += gauss;
                }

                return col / kernelSum;
            }
            ENDCG
        }

        // Difference Of Gaussians
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 g1 = tex2D(_GaussianTex, i.uv).r;
                float4 g2 = tex2D(_kGaussianTex, i.uv).r;
                float4 col = tex2D(_MainTex, i.uv);

                float4 D = (g1 - g2);

                if (_Thresholding)
                    D = (D >= _Threshold) ? 1 : 0;

                if (_Invert)
                    D = 1 - D;

                return D;
            }
            ENDCG
        }
    }
}