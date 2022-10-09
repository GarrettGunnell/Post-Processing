Shader "Hidden/GeneralizedKuwahara" {
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
        float _Hardness, _Q, _ZeroCrossing, _Zeta;

        ENDCG
        
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                int k;
                float4 m[8];
                float3 s[8];

                int kernelRadius = _KernelSize / 2;

                //float zeta = 2.0f / (kernelRadius);
                float zeta = _Zeta;

                float zeroCross = _ZeroCrossing;
                float sinZeroCross = sin(zeroCross);
                float eta = (zeta + cos(zeroCross)) / (sinZeroCross * sinZeroCross);

                for (k = 0; k < _N; ++k) {
                    m[k] = 0.0f;
                    s[k] = 0.0f;
                }

                [loop]
                for (int y = -kernelRadius; y <= kernelRadius; ++y) {
                    [loop]
                    for (int x = -kernelRadius; x <= kernelRadius; ++x) {
                        float2 v = float2(x, y) / kernelRadius;
                        float3 c = tex2D(_MainTex, i.uv + float2(x, y) * _MainTex_TexelSize.xy).rgb;
                        c = saturate(c);
                        float sum = 0;
                        float w[8];
                        float z, vxx, vyy;
                        
                        /* Calculate Polynomial Weights */
                        vxx = zeta - eta * v.x * v.x;
                        vyy = zeta - eta * v.y * v.y;
                        z = max(0, v.y + vxx); 
                        w[0] = z * z;
                        sum += w[0];
                        z = max(0, -v.x + vyy); 
                        w[2] = z * z;
                        sum += w[2];
                        z = max(0, -v.y + vxx); 
                        w[4] = z * z;
                        sum += w[4];
                        z = max(0, v.x + vyy); 
                        w[6] = z * z;
                        sum += w[6];
                        v = sqrt(2.0f) / 2.0f * float2(v.x - v.y, v.x + v.y);
                        vxx = zeta - eta * v.x * v.x;
                        vyy = zeta - eta * v.y * v.y;
                        z = max(0, v.y + vxx); 
                        w[1] = z * z;
                        sum += w[1];
                        z = max(0, -v.x + vyy); 
                        w[3] = z * z;
                        sum += w[3];
                        z = max(0, -v.y + vxx); 
                        w[5] = z * z;
                        sum += w[5];
                        z = max(0, v.x + vyy); 
                        w[7] = z * z;
                        sum += w[7];
                        
                        float g = exp(-3.125f * dot(v,v)) / sum;
                        
                        for (int k = 0; k < 8; ++k) {
                            float wk = w[k] * g;
                            m[k] += float4(c * wk, wk);
                            s[k] += c * c * wk;
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

                return saturate(output / output.w);
            }
            ENDCG
        }
    }
}