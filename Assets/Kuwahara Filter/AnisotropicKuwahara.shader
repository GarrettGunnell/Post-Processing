Shader "Hidden/AnisotropicKuwahara" {
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
        
        sampler2D _MainTex, _K0;
        float4 _MainTex_TexelSize;
        int _KernelSize, _N, _Size;
        float _Hardness, _Q;

        float gaussian(float sigma, float2 pos) {
            return (1.0f / (2.0f * PI * sigma * sigma)) * exp(-((pos.x * pos.x + pos.y * pos.y) / (2.0f * sigma * sigma)));
        }

        ENDCG

        // Pre Compute Weights
        // Calculate Section
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float2 pos = i.uv - 0.5f;
                float phi = atan2(pos.y, pos.x);
                int Xk = (-PI / _N) < phi && phi <= (PI / _N);

                return dot(pos, pos) <= 0.25f ? Xk : 0;
            }
            ENDCG
        }

        // Gaussian Filter Section
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                // Calculated from the resolution of the gaussian weight texture, anything beyond 32x32 seems to make no difference so it is hard coded
                float sigmaR = 0.5f * ((32.0f) * 0.5f);
                float sigmaS = 0.33f * sigmaR;

                float4 col = 0;
                float kernelSum = 0.0f;
                for (int x = -floor(sigmaS); x <= floor(sigmaS); ++x) {
                    for (int y = -floor(sigmaS); y <= floor(sigmaS); ++y) {
                        float4 c = tex2D(_MainTex, i.uv + float2(x, y) * _MainTex_TexelSize.xy);
                        float gauss = gaussian(sigmaS, float2(x, y));

                        col += c * gauss;
                        kernelSum += gauss;
                    }
                }

                float4 output = (col / kernelSum) * gaussian(sigmaR, (i.uv - 0.5f) * sigmaR * 5);

                return output;
            }
            ENDCG
        }

        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                int k;
                float4 m[8];
                float3 s[8];

                for (k = 0; k < _N; ++k) {
                    m[k] = 0.0f;
                    s[k] = 0.0f;
                }

                float piN = 2.0f * PI / float(_N);
                float2x2 X = {cos(piN), sin(piN), 
                             -sin(piN), cos(piN)};

                for (int x = -_KernelSize; x <= _KernelSize; ++x) {
                    for (int y = -_KernelSize; y <= _KernelSize; ++y) {
                        float2 v = 0.5f * float2(x, y) / float(_KernelSize);
                        float3 c = tex2D(_MainTex, i.uv + float2(x, y) * _MainTex_TexelSize.xy).rgb;
                        for (k = 0; k < _N; ++k) {
                            float w = tex2D(_K0, 0.5f + v).x;

                            m[k] += float4(c * w, w);
                            s[k] += c * c * w;

                            v = mul(X, v);
                        }
                    }
                }

                float4 output = 0;
                for (k = 0; k < _N; ++k) {
                    m[k].rgb /= m[k].w;
                    s[k] = abs(s[k] / m[k].w - m[k].rgb * m[k].rgb);

                    float sigma2 = s[k].r + s[k].g + s[k].b;
                    float w = 1.0f / (1.0f + pow(_Hardness * 1000.0f * sigma2, 0.5f * _Q));

                    output += float4(m[k].rgb * w, w);
                }

                return output / output.w;
            }
            ENDCG
        }
    }
}