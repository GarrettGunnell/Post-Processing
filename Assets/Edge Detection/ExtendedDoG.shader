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
        Texture2D _TFM;
        float4 _MainTex_TexelSize;
        int _Thresholding, _Invert, _CalcDiffBeforeConvolution;
        float _SigmaC, _SigmaE, _SigmaM, _Threshold, _Thresholds, _K, _Tau, _Phi;

        SamplerState point_clamp_sampler;
        
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

        // RGB to LAB
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                return float4(rgb2lab(tex2D(_MainTex, i.uv).rgb), 1.0f);
            }
            ENDCG
        }

        // Calculate Eigenvectors
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float2 d = _MainTex_TexelSize.xy;

                float3 Sx = (
                    1.0f * tex2D(_MainTex, i.uv + float2(-d.x, -d.y)).rgb +
                    2.0f * tex2D(_MainTex, i.uv + float2(-d.x,  0.0)).rgb +
                    1.0f * tex2D(_MainTex, i.uv + float2(-d.x,  d.y)).rgb +
                    -1.0f * tex2D(_MainTex, i.uv + float2(d.x, -d.y)).rgb +
                    -2.0f * tex2D(_MainTex, i.uv + float2(d.x,  0.0)).rgb +
                    -1.0f * tex2D(_MainTex, i.uv + float2(d.x,  d.y)).rgb
                ) / 4.0f;

                float3 Sy = (
                    1.0f * tex2D(_MainTex, i.uv + float2(-d.x, -d.y)).rgb +
                    2.0f * tex2D(_MainTex, i.uv + float2( 0.0, -d.y)).rgb +
                    1.0f * tex2D(_MainTex, i.uv + float2( d.x, -d.y)).rgb +
                    -1.0f * tex2D(_MainTex, i.uv + float2(-d.x, d.y)).rgb +
                    -2.0f * tex2D(_MainTex, i.uv + float2( 0.0, d.y)).rgb +
                    -1.0f * tex2D(_MainTex, i.uv + float2( d.x, d.y)).rgb
                ) / 4.0f;

                
                return float4(dot(Sx, Sx), dot(Sy, Sy), dot(Sx, Sy), 1.0f);
            }
            ENDCG
        }

        // TFM Blur Pass 1
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                int kernelRadius = max(1.0f, floor(_SigmaC * 2.45f));

                float4 col = 0;
                float kernelSum = 0.0f;

                for (int x = -kernelRadius; x <= kernelRadius; ++x) {
                    float4 c = tex2D(_MainTex, i.uv + float2(x, 0) * _MainTex_TexelSize.xy);
                    float gauss = gaussian(_SigmaC, x);

                    col += c * gauss;
                    kernelSum += gauss;
                }

                return col / kernelSum;
            }
            ENDCG
        }

        // TFM Blur Pass 2
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                int kernelRadius = max(1.0f, floor(_SigmaC * 2.45f));

                float4 col = 0;
                float kernelSum = 0.0f;

                for (int y = -kernelRadius; y <= kernelRadius; ++y) {
                    float4 c = tex2D(_MainTex, i.uv + float2(0, y) * _MainTex_TexelSize.xy);
                    float gauss = gaussian(_SigmaC, y);

                    col += c * gauss;
                    kernelSum += gauss;
                }

                float3 g = col.rgb / kernelSum;

                float lambda1 = 0.5f * (g.y + g.x + sqrt(g.y * g.y - 2.0f * g.x * g.y + g.x * g.x + 4.0 * g.z * g.z));
                float2 d = float2(g.x - lambda1, g.z);

                return length(d) ? float4(normalize(d), sqrt(lambda1), 1.0f) : float4(0.0f, 1.0f, 0.0f, 1.0f);
            }
            ENDCG
        }

        // FDoG Blur Pass 1
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {

                float2 t = _TFM.Sample(point_clamp_sampler, i.uv).xy;
                float2 n = float2(t.y, -t.x);
                float2 nabs = abs(n);
                float ds = 1.0 / ((nabs.x > nabs.y) ? nabs.x : nabs.y);
                n *= _MainTex_TexelSize.xy;

                float2 col = tex2D(_MainTex, i.uv).xx;
                float2 kernelSum = 1.0f;

                int kernelSize = (_SigmaE * 2 > 1) ? floor(_SigmaE * 2) : 1;

                [loop]
                for (int x = ds; x <= kernelSize; ++x) {
                    float gauss1 = gaussian(_SigmaE, x);
                    float gauss2 = gaussian(_SigmaE * _K, x);

                    float c1 = tex2D(_MainTex, i.uv - x * n).r;
                    float c2 = tex2D(_MainTex, i.uv + x * n).r;

                    col.r += (c1 + c2) * gauss1;
                    kernelSum.x += 2.0f * gauss1;

                    col.g += (c1 + c2) * gauss2;
                    kernelSum.y +=  2.0f * gauss2;
                }

                col /= kernelSum;

                return float4(col, (1 + _Tau) * (col.r * 100.0f) - _Tau * (col.g * 100.0f), 1.0f);
            }
            ENDCG
        }

        // FDoG Blur Pass 2 + Thresholding
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float kernelSize = _SigmaM * 2;

                float2 G = 0.0f;
                float2 w = 0.0f;

                float2 v = _TFM.Sample(point_clamp_sampler, i.uv).xy * _MainTex_TexelSize;

                float2 st0 = i.uv;
                float2 v0 = v;

                [loop]
                for (int d = 0; d < kernelSize; ++d) {
                    st0 += v0;
                    float3 c = tex2D(_MainTex, st0).rgb;
                    float gauss1 = gaussian(_SigmaM, d);


                    if (_CalcDiffBeforeConvolution) {
                        G.r += gauss1 * c.b;
                        w.x += gauss1;
                    } else {
                        float gauss2 = gaussian(_SigmaM * _K, d);

                        G.r += gauss1 * c.r;
                        w.x += gauss1;

                        G.g += gauss2 * c.g;
                        w.y += gauss2;
                    }

                    v0 = _TFM.Sample(point_clamp_sampler, st0).xy * _MainTex_TexelSize.xy;
                }

                float2 st1 = i.uv;
                float2 v1 = v;

                [loop]
                for (int d = 0; d < kernelSize; ++d) {
                    st1 -= v1;
                    float3 c = tex2D(_MainTex, st1).rgb;
                    float gauss1 = gaussian(_SigmaM, d);


                    if (_CalcDiffBeforeConvolution) {
                        G.r += gauss1 * c.b;
                        w.x += gauss1;
                    } else {
                        float gauss2 = gaussian(_SigmaM * _K, d);

                        G.r += gauss1 * c.r;
                        w.x += gauss1;

                        G.g += gauss2 * c.g;
                        w.y += gauss2;
                    }

                    v1 = _TFM.Sample(point_clamp_sampler, st1).xy * _MainTex_TexelSize.xy;
                }

                G /= w;

                float4 D = 0.0f;
                if (_CalcDiffBeforeConvolution) {
                    D = G.x;
                } else {
                    D = (1 + _Tau) * (G.r * 100.0f) - _Tau * (G.g * 100.0f);
                }

                if (_Thresholding == 1) {
                    D = (D >= _Threshold) ? 1 : 1 + tanh(_Phi * (D - _Threshold));
                } else if (_Thresholding == 2) {
                    float a = 1.0f / _Thresholds;
                    float b = _Threshold / 100.0f;
                    float x = D / 100.0f;

                    D = (x >= b) ? 1 : a * floor((pow(x, _Phi) - (a * b / 2.0f)) / (a * b) + 0.5f);
                } else if (_Thresholding == 3) {
                    float x = D / 100.0f;
                    float qn = floor(x * float(_Thresholds) + 0.5f) / float(_Thresholds);
                    float qs = smoothstep(-2.0, 2.0, _Phi * (x - qn) * 10.0f) - 0.5f;
                    
                    D = qn + qs / float(_Thresholds);
                } else {
                    D /= 100.0f;
                }

                if (_Invert)
                    D = 1 - D;

                return saturate(D);
            }
            ENDCG
        }

        // Non FDoG Blur Pass 1
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float2 col = 0;
                float kernelSum1 = 0.0f;
                float kernelSum2 = 0.0f;

                int kernelSize = (_SigmaE * 2 > 2) ? floor(_SigmaE * 2) : 2;

                for (int x = -kernelSize; x <= kernelSize; ++x) {
                    float c = tex2D(_MainTex, i.uv + float2(x, 0) * _MainTex_TexelSize.xy).r;
                    float gauss1 = gaussian(_SigmaE, x);
                    float gauss2 = gaussian(_SigmaE * _K, x);

                    col.r += c * gauss1;
                    kernelSum1 += gauss1;

                    col.g += c * gauss2;
                    kernelSum2 += gauss2;
                }

                return float4(col.r / kernelSum1, col.g / kernelSum2, 0, 0);
            }
            ENDCG
        }

        // Non FDoG Blur Pass 2
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float2 col = 0;
                float kernelSum1 = 0.0f;
                float kernelSum2 = 0.0f;

                int kernelSize = (_SigmaE * 2 > 2) ? floor(_SigmaE * 2) : 2;

                for (int y = -kernelSize; y <= kernelSize; ++y) {
                    float2 c = tex2D(_MainTex, i.uv + float2(0, y) * _MainTex_TexelSize.xy).rg;
                    float gauss1 = gaussian(_SigmaE, y);
                    float gauss2 = gaussian(_SigmaE * _K, y);

                    col.r += c.r * gauss1;
                    kernelSum1 += gauss1;

                    col.g += c.g * gauss2;
                    kernelSum2 += gauss2;
                }

                float2 G = float2(col.r / kernelSum1, col.g / kernelSum2);

                float4 D = (1 + _Tau) * (G.r * 100.0f) - _Tau * (G.g * 100.0f);

                if (_Thresholding == 1) {
                    D = (D >= _Threshold) ? 1 : 1 + tanh(_Phi * (D - _Threshold));
                } else if (_Thresholding == 2) {
                    float a = 1.0f / _Thresholds;
                    float b = _Threshold / 100.0f;
                    float x = D / 100.0f;

                    D = (x >= b) ? 1 : a * floor((pow(x, _Phi) - (a * b / 2.0f)) / (a * b) + 0.5f);
                } else if (_Thresholding == 3) {
                    float x = D / 100.0f;
                    float qn = floor(x * float(_Thresholds) + 0.5f) / float(_Thresholds);
                    float qs = smoothstep(-2.0, 2.0, _Phi * (x - qn) * 10.0f) - 0.5f;
                    
                    D = qn + qs / float(_Thresholds);
                } else {
                    D /= 100.0f;
                }

                if (_Invert)
                    D = 1 - D;

                return saturate(D);
            }
            ENDCG
        }
    }
}