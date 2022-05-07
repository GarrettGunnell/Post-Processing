Shader "Hidden/Tonemapping" {
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

            float luminance(float3 color) {
                return dot(color, float3(0.299f, 0.587f, 0.114f));
            }

            v2f vp(VertexData v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex, _LuminanceTex;
        ENDCG

        // Debug HDR
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                return luminance(col);
            }
            ENDCG
        }

        // Debug HDR
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                if (col.r > 1.0f || col.g > 1.0f || col.b > 1.0f)
                    return col;
                
                return 0.0f;
            }
            ENDCG
        }

        // No Tonemapping (Clamp RGB)
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                return saturate(tex2D(_MainTex, i.uv));
            }
            ENDCG
        }

        // Tumblin Rushmeier
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float _Ldmax, _Cmax;

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;

                float Lin = luminance(col);

                float Lavg = tex2Dlod(_LuminanceTex, float4(i.uv.x, i.uv.y, 0, 10.0f)).r;

                float logLrw = log10(Lavg) + 0.84;
                float alphaRw = 0.4 * logLrw + 2.92;
                float betaRw = -0.4 * logLrw * logLrw - 2.584 * logLrw + 2.0208;
                float Lwd = _Ldmax / sqrt(_Cmax);
                float logLd = log10(Lwd) + 0.84;
                float alphaD = 0.4 * logLd + 2.92;
                float betaD = -0.4 * logLd * logLd - 2.584 * logLd + 2.0208;
                float Lout = pow(Lin, alphaRw / alphaD) / _Ldmax * pow(10.0, (betaRw - betaD) / alphaD) - (1.0 / _Cmax);

                float3 Cout = col / Lin * Lout;

                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }

        // Schlick
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float _P, _HiVal;

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;

                float Lin = luminance(col);

                float Lout = (_P * Lin) / (_P * Lin - Lin + _HiVal);

                float3 Cout = col / Lin * Lout;

                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }

        // Ward
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float _Ldmax;

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;

                float Lin = luminance(col);

                float m = (1.219f + pow(_Ldmax / 2.0f, 0.4f)) / (1.219f + pow(Lin, 0.4f));
                m = pow(m, 2.5f); 

                float Lout = m / _Ldmax * Lin;

                float3 Cout = col / Lin * Lout;

                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }

        // Reinhard
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;

                float Lin = luminance(col);

                float Lout = Lin / (1.0f + Lin);

                float3 Cout = col / Lin * Lout;

                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }

        // Reinhard Extended
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float _Cwhite;

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;

                float Lin = luminance(col);

                float Lout = (Lin * (1.0 + Lin / (_Cwhite * _Cwhite))) / (1.0 + Lin);

                float3 Cout = col / Lin * Lout;
                
                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }

        // Hable
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float _A, _B, _C, _D, _E, _F, _W;

            float3 Uncharted2Tonemap(float3 x) {
                return ((x*(_A*x+_C*_B)+_D*_E)/(x*(_A*x+_B)+_D*_F))-_E/_F;
            }

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;

                float ExposureBias = 2.0f;
                float3 curr = ExposureBias * Uncharted2Tonemap(col);

                float3 whiteScale = 1.0f / Uncharted2Tonemap(float3(_W, _W, _W));

                float3 Cout = curr * whiteScale;
                
                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }

        // Uchimura
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float _M, _a, _m, _l, _c, _b;

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;

                float l0 = ((_M - _m) * _l) / _a;
                float S0 = _m + l0;
                float S1 = _m + _a * l0;
                float C2 = (_a * _M) / (_M - S1);
                float CP = -C2 / _M;

                float3 w0 = 1.0f - smoothstep(float3(0.0f, 0.0f, 0.0f), float3(_m, _m, _m), col);
                float3 w2 = step(float3(_m + l0, _m + l0, _m + l0), col);
                float3 w1 = float3(1.0f, 1.0f, 1.0f) - w0 - w2;

                float3 T = _m * pow(col / _m, _c) + _b;
                float3 L = _m + _a * (col - _m);
                float3 S = _M - (_M - S1) * exp(CP * (col - S0));

                float3 Cout = T * w0 + L * w1 + S * w2;
                
                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }

        // Narkowicz ACES
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;
               
                float3 Cout = (col*(2.51f*col+0.03f))/(col*(2.43f*col+0.59f)+0.14f);

                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }

        // Hill ACES
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            static const float3x3 ACESInputMat =
            {
                {0.59719, 0.35458, 0.04823},
                {0.07600, 0.90834, 0.01566},
                {0.02840, 0.13383, 0.83777}
            };

            static const float3x3 ACESOutputMat =
            {
                { 1.60475, -0.53108, -0.07367},
                {-0.10208,  1.10813, -0.00605},
                {-0.00327, -0.07276,  1.07602}
            };

            float3 RRTAndODTFit(float3 v) {
                float3 a = v * (v + 0.0245786f) - 0.000090537f;
                float3 b = v * (0.983729f * v + 0.4329510f) + 0.238081f;
                return a / b;
            }

            float4 fp(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv).rgb;
               
                col = mul(ACESInputMat, col);

                col = RRTAndODTFit(col);

                float3 Cout = mul(ACESOutputMat, col);

                return float4(saturate(Cout), 1.0f);
            }
            ENDCG
        }
    }
}