Shader "Hidden/ExtendedDoG" {
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
        int _Thresholding, _Invert;
        float _Sigma, _Threshold, _K, _Tau, _Phi;
        
        float gaussian(float sigma, float pos) {
            return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
        }

        float luminance(float3 color) {
            return dot(color, float3(0.299f, 0.587f, 0.114f));
        }

        // Color conversions from https://gist.github.com/mattatz/44f081cac87e2f7c8980
        float3 rgb2xyz(float3 c) {
            float3 tmp;

            tmp.x = (c.r > 0.04045) ? pow((c.r + 0.055) / 1.055, 2.4) : c.r / 12.92;
            tmp.y = (c.g > 0.04045) ? pow((c.g + 0.055) / 1.055, 2.4) : c.g / 12.92,
            tmp.z = (c.b > 0.04045) ? pow((c.b + 0.055) / 1.055, 2.4) : c.b / 12.92;
            
            const float3x3 mat = float3x3(
                0.4124, 0.3576, 0.1805,
                0.2126, 0.7152, 0.0722,
                0.0193, 0.1192, 0.9505 
            );

            return 100.0 * mul(tmp, mat);
        }

        float3 xyz2lab(float3 c) {
            float3 n = c / float3(95.047, 100, 108.883);
            float3 v;

            v.x = (n.x > 0.008856) ? pow(n.x, 1.0 / 3.0) : (7.787 * n.x) + (16.0 / 116.0);
            v.y = (n.y > 0.008856) ? pow(n.y, 1.0 / 3.0) : (7.787 * n.y) + (16.0 / 116.0);
            v.z = (n.z > 0.008856) ? pow(n.z, 1.0 / 3.0) : (7.787 * n.z) + (16.0 / 116.0);

            return float3((116.0 * v.y) - 16.0, 500.0 * (v.x - v.y), 200.0 * (v.y - v.z));
        }

        float3 rgb2lab(float3 c) {
            float3 lab = xyz2lab(rgb2xyz(c));

            return float3(lab.x / 100.0f, 0.5 + 0.5 * (lab.y / 127.0), 0.5 + 0.5 * (lab.z / 127.0));
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

                int kernelSize = (_Sigma * 2 > 2) ? floor(_Sigma * 2) : 2;

                for (int x = -kernelSize; x <= kernelSize; ++x) {
                    float c = rgb2lab(saturate(tex2D(_MainTex, i.uv + float2(x, 0) * _MainTex_TexelSize.xy)).rgb).r;
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

                int kernelSize = (_Sigma * 2 > 2) ? floor(_Sigma * 2) : 2;

                for (int y = -kernelSize; y <= kernelSize; ++y) {
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

                float4 D = (1 + _Tau) * (G.r * 100.0f) - _Tau * (G.g * 100.0f);

                if (_Thresholding)
                    D = (D >= _Threshold) ? 1 : 1 + tanh(_Phi * (D - _Threshold));

                if (_Invert)
                    D = 1 - D;

                return D;
            }
            ENDCG
        }
    }
}