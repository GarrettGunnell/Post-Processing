Shader "Hidden/AcerolaLensFlare" {
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

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float _Threshold, _Sigma;
        int _KernelSize;
        
        #define PI 3.14159265358979323846f

        float gaussian(float sigma, float pos) {
            return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
        }

        ENDCG

        // Downscale
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float luminance(float3 color) {
                return dot(color, float3(0.299f, 0.587f, 0.114f));
            }

            float3 ApplyThreshold(float3 col) {
                return luminance(col) > _Threshold ? col : 0.0f;
            }

            float4 fp(v2f i) : SV_Target {
                return float4(ApplyThreshold(tex2D(_MainTex, i.uv).rgb), 1.0f);
            }
            ENDCG
        }

        // Feature Generation
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            Texture2D _NoiseTex;
            SamplerState point_repeat_sampler;
            int _SampleCount;
            float _SampleDistance, _HaloRadius, _HaloThickness;

            float WindowCubic(float x, float center, float radius) {
                x = min(abs(x - center) / radius, 1.0);
                return 1.0 - x * x * (3.0 - 2.0 * x);
            }

            float3 hsv2rgb(float3 hsv) {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(hsv.xxx + K.xyz) * 6.0 - K.www);

                return hsv.z * lerp(K.xxx, saturate(p - K.xxx), hsv.y);
            }

            float4 fp(v2f i) : SV_Target {
                float2 uv = 1.0f - i.uv;
                float3 ret = 0.0f;
                float2 ghostVec = (0.5f - uv) * _SampleDistance;
                for (int j = 0; j < _SampleCount; ++j) {
                    float2 suv = frac(uv + ghostVec * j);
                    float d = distance(suv, 0.5f);
                    float weight = 1.0f - smoothstep(0.0f, 0.75f, d);
                    float3 s = tex2D(_MainTex, suv).rgb;
                    ret += s * weight;
                }

                float aspectRatio = _MainTex_TexelSize.z / _MainTex_TexelSize.w;
                float2 haloVec = 0.5f - i.uv;
                haloVec.x /= aspectRatio;
                haloVec = normalize(haloVec);
                haloVec.x *= aspectRatio;
                float2 wuv = (i.uv - float2(0.5f, 0.0f)) / float2(aspectRatio, 1.0f) + float2(0.5f, 0.0f);
                float d = distance(wuv, 0.5f);
                float haloWeight = WindowCubic(d, _HaloRadius, _HaloThickness);
                haloVec *= _HaloRadius;
                ret += tex2D(_MainTex, haloVec).rgb * haloWeight;

                float3 gradient = hsv2rgb(float3(d, 0.5, 1.0));

                float2 centerVec = i.uv - 0.5f;
                d = length(centerVec);
                float radial = acos(centerVec.x / d);
                float mask = _NoiseTex.SampleLevel(point_repeat_sampler, float2(radial + 1.0f * 1.0f, 0.0f), 0).r * _NoiseTex.SampleLevel(point_repeat_sampler, float2(radial - 1.0f * 0.5f, 0.0f), 0).r;
                mask = saturate(mask + (1.0f - smoothstep(0.0f, 0.3f, d)));

                return float4(saturate(ret) * mask, 1.0f);
            }
            ENDCG
        }

        // Chromatic Aberration
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float3 _ColorOffsets;

            float4 fp(v2f i) : SV_Target {
                float2 pos = i.uv - 0.5f;
                pos += 0.5f;

                float2 d = pos - 0.5f;


                float4 col = 1.0f;
                float2 redUV = i.uv + (d * _ColorOffsets.r * _MainTex_TexelSize.xy);
                float2 blueUV = i.uv + (d * _ColorOffsets.b * _MainTex_TexelSize.xy);
                float2 greenUV = i.uv + (d * _ColorOffsets.g * _MainTex_TexelSize.xy);

                col.r = tex2D(_MainTex, redUV).r;
                col.g = tex2D(_MainTex, blueUV).g;
                col.b = tex2D(_MainTex, greenUV).b;

                return col;
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

        // Upsample/Composite
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            sampler2D _LensFlareTex;

            float4 fp(v2f i) : SV_Target {
                return tex2D(_MainTex, i.uv) + tex2D(_LensFlareTex, i.uv);
            }
            ENDCG
        }
        
        // Create Noise
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float hash(uint n) {
                // integer hash copied from Hugo Elias
                n = (n << 13U) ^ n;
                n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
                return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
            }

            float4 fp(v2f i) : SV_Target {
                uint seed = i.uv.x * _MainTex_TexelSize.z;
                return hash(seed);
            }
            ENDCG
        }
    }
}