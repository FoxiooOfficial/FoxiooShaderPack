/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Seed,

            _RainbowFreq,
            _RainbowStrength,

            _Saturation,
            _Value,

            _RingingMixing,
            _RainbowErrorNoise,

            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
}

float3 Fun_RGB_YCbCr(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;
    float _Cb = -0.168736 * _Result.r - 0.331264 * _Result.g + 0.5 * _Result.b + 0.5;
    float _Cr = 0.5 * _Result.r - 0.418688 * _Result.g - 0.081312 * _Result.b + 0.5;

    return float3(_Y, _Cb, _Cr);
}

float3 Fun_Sharp(sampler2D _Sampler, float2 _In, float3 _Color, float _Sharpness_Size)
{
    float3 _Result_Sharpness = 5 * _Color - (
                tex2D(_Sampler, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))
            ).rgb;

    return _Result_Sharpness * 0.15 + _Color * 0.85;
}

float3 Fun_Ringing(sampler2D _Sampler, float2 _In, float3 _Color)
{
    const int _Max = 3;
    const int _Offset = -12;
    const float _SampleMul = 1.5 / float(_Max);


    for(int i = _Max; i > 0; i--)
    {
        _Color += lerp(_Color, tex2D(_Sampler, saturate(_In + _Offset * i * float2(fPixelWidth, 0))).rgb, 0.5) * _SampleMul;
    }
    
    return _Color;
}

float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453); }
float Fun_Noise(float2 _Pos)
{
    float2 _I = floor(_Pos + _Seed);    float2 _F = frac(_Pos);

        float _A = Fun_Hash21(_I + float2(0.0, 0.0) + _Seed);
        float _B = Fun_Hash21(_I + float2(1.0, 0.0) + _Seed);
        float _C = Fun_Hash21(_I + float2(0.0, 1.0) + _Seed);
        float _D = Fun_Hash21(_I + float2(1.0, 1.0) + _Seed);

    float2 _UV = _F * _F * (3.0 - 2.0 *_F);

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float3 RGBtoHSV(float3 _Render)
{
    float _CMax = max(_Render.r, max(_Render.g, _Render.b));
    float _CMin = min(_Render.r, min(_Render.g, _Render.b));
    float _Delta = _CMax - _CMin;

    float _H = 0.0;
    float _S = 0.0;
    float _V = _CMax;

    if (_Delta > 0.0)
    {
        _S = (_V > 0.0) ? (_Delta / _V) : 0.0;

        if (_CMax == _Render.r)
        {
            _H = 60.0 * fmod(((_Render.g - _Render.b) / _Delta), 6.0);
        }
        else if (_CMax == _Render.g)
        {
            _H = 60.0 * (((_Render.b - _Render.r) / _Delta) + 2.0);
        }
        else
        {
            _H = 60.0 * (((_Render.r - _Render.g) / _Delta) + 4.0);
        }
    }

    if (_H < 0.0) { _H += 360.0; }
    return float3(_H, _S, _V);
}

float3 HSVtoRGB(float _H, float _S, float _V)
{
    float _C = _V * _S;
    float _X = _C * (1.0 - abs(fmod(_H / 60.0, 2.0) - 1.0));
    float _M = _V - _C;

    float3 _Render =    (_H < 60.0)   ? float3(_C, _X, 0) :
                        (_H < 120.0)  ? float3(_X, _C, 0) :
                        (_H < 180.0)  ? float3(0, _C, _X) :
                        (_H < 240.0)  ? float3(0, _X, _C) :
                        (_H < 300.0)  ? float3(_X, 0, _C) :
                                        float3(_C, 0, _X);

    return (_Render + _M);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result;

        _Result.rgb = Fun_Sharp(S2D_Background, In, _Render_Background.rgb, 1.5);

            /* Noise */
                /* Big */
                    float2 _Noise_In = In * float2(10, 80);

                    float3 _Noise = float3(Fun_Noise(_Noise_In), Fun_Noise(_Noise_In + 1.0), Fun_Noise(_Noise_In + 2.0)); _Noise.r *= _Noise.b;
                        float _Lum = Fun_Luminance(_Noise);
                        _Result.rgb += _Noise * _Lum * 0.05;

                /* Small (Chrominance noise) */
                    _Noise_In = In * float2(1.6 / fPixelWidth, 1.6 / fPixelHeight);

                    _Noise = float3(Fun_Noise(_Noise_In), Fun_Noise(_Noise_In + 1.0), Fun_Noise(_Noise_In + 2.0));
                        _Result.rgb += _Noise * _Lum * 0.22; 

            /* Rainbow effects */
                float Y = Fun_Luminance(_Result.rgb);
                float _Phase = (0.5 - abs(In.x / Y - 0.5)) * _RainbowFreq * 6.2831;

                    float3 _Rainbow = float3(   sin(_Phase + 0.0),  sin(_Phase + 2.094),    sin(_Phase + 4.188) );
                    float  _Rainbow_Pre = _RainbowStrength * _Rainbow;
                
                _Rainbow *= _RainbowStrength;
                _Result.rgb += _Rainbow * Y;

            /* Ringing */
                float3 _Ringing = Fun_Ringing(S2D_Background, In + _Rainbow_Pre.r * 0.05, _Result.rgb * _Rainbow);
                float _Ringing_Lum = Fun_Luminance(_Ringing);

                _Result.rgb += (_Ringing / _Rainbow) * _RainbowErrorNoise;
                _Result.rgb += Fun_RGB_YCbCr(_Ringing + _Rainbow_Pre * 0.1) * _Ringing_Lum * _RingingMixing;

            /* Saturation */
                float3 _HSV = RGBtoHSV(_Result.rgb);

                _HSV.y = (_HSV.y * (_Saturation / 50.0));
                _HSV.z = (_HSV.z + (_Value - 50.0) / 50.0);

                _Result.rgb = HSVtoRGB(_HSV.x, _HSV.y, _HSV.z);

            _Result.rgb = lerp(_Render_Background.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
