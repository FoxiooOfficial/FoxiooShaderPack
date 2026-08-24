/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Frame;
    float _Size;
    int _Quality;
    bool _Interlacing;
    float _Alpha;
    float _Saturation;
    float _Value;
    float _Seed;
    float _Time;
    bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	//float2 bgCoord : TEXCOORD1;
    float4 Position : SV_POSITION;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

float4 Demultiply(float4 _Render, bool _Premultiplied)
{
    if(_Premultiplied)
    {
	    if ( _Render.a != 0.0 ) {
            _Render.rgb /= _Render.a;
        }
    }

	return _Render;
}

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
}

float3 Fun_Sharp(Texture2D _Texture, SamplerState _Sampler, float2 In, float2 _Off)
{
    float2 _Emboss;

    float3 _NW = _Texture.Sample(_Sampler, In + float2(-_Off.x,  -_Off.y)).rgb;
    float3 _N  = _Texture.Sample(_Sampler, In + float2(0.0,      -_Off.y)).rgb;
    float3 _NE = _Texture.Sample(_Sampler, In + float2( _Off.x,  -_Off.y)).rgb;
    float3 _W  = _Texture.Sample(_Sampler, In + float2(-_Off.x,   0.0))   .rgb;
    float3 _C  = _Texture.Sample(_Sampler, In)                            .rgb;
    float3 _E  = _Texture.Sample(_Sampler, In + float2( _Off.x,   0.0))   .rgb;
    float3 _SW = _Texture.Sample(_Sampler, In + float2(-_Off.x,  _Off.y)) .rgb;
    float3 _S  = _Texture.Sample(_Sampler, In + float2(0.0,      _Off.y)) .rgb;
    float3 _SE = _Texture.Sample(_Sampler, In + float2( _Off.x,  _Off.y)) .rgb;

        _Emboss.x = (Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE)) - (Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW));
        _Emboss.y = (Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE)) - (Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE));
        //_Emboss.y = -_Emboss.y;

    float _Diff = (_Emboss.x + _Emboss.y) * 0.5;
    float3 _Render = saturate(0.5 + _Diff * _Mixing);

    return _Render;
}

float3 Fun_ClipColor(float3 _Color)
{
    float _Y = Fun_Luminance(_Color);
    float _ColorMin = min(_Color.r, min(_Color.g, _Color.b));
    float _ColorMax = max(_Color.r, max(_Color.g, _Color.b));

    float _Div = _ColorMax - _Y;
    if(_Div == 0.0) _Div = 1e4;

    if(_ColorMin < 0.0) { _Color = _Y + (((_Color - _Y) * _Y) / (_Y - _ColorMin)); }
    if(_ColorMax > 1.0) { _Color = _Y + (((_Color - _Y) * (1.0 - _Y)) / _Div); }

    return _Color;
}

float3 Fun_SetLum(float3 _Color, float _Y)
{
    float _GetLum = _Y - Fun_Luminance(_Color);
    _Color += _GetLum;

    return Fun_ClipColor(_Color);
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
            _H = 60.0 * fmod(((_Render.g - _Render.b) / _Delta), 6.0);
        else if (_CMax == _Render.g)
            _H = 60.0 * (((_Render.b - _Render.r) / _Delta) + 2.0);
        else
            _H = 60.0 * (((_Render.r - _Render.g) / _Delta) + 4.0);
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

float Fun_Rand(float2 In)
{
    return frac(cos(dot(In.xy + _Seed, float2(67.4684,18.467)))* 3463456.95546);
}

#define M_PI 3.14159265358979323846

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float _UV_Y = cos(In.texCoord.y * 4.0 / tan(In.texCoord.y - _Time / 36.0) + _Time * 0.01 + sin(In.texCoord.y * 3.0 - _Time * 0.0001) * 0.01 + sin(In.texCoord.y / 5.0 - _Time * 0.32)) * fPixelHeight + fPixelHeight * 2.0 * sin(In.texCoord.y / 7.12 + _Time * 0.001);
    _UV_Y += Fun_Rand(In.texCoord.xy + _UV_Y) * fPixelHeight;

    float2 UV = In.texCoord + float2(sin(In.texCoord.y / fPixelWidth * 1.5 + _Time) * fPixelWidth * 0.5, _UV_Y * 0.5) * _Mixing;
    float _Rand = Fun_Rand(UV + Fun_Rand(UV));

    UV = lerp(In.texCoord, UV, _Mixing);

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV) * In.Tint, _Premultiplied);

       float4 _Result = _Render_Texture;

        /* etap 1; gain */
            _Result.rgb = lerp(_Result.rgb, _Result.rgb * (_Rand * 0.5 + 0.5), 0.3);

        /* etap 2; emboss! */
        float2 _EOffset = -2.5 * -float2(fPixelWidth, fPixelHeight);
        float3 _Render_Emboss = Fun_Sharp(S2D_Image, S2D_ImageSampler, UV, _EOffset);
        
            _Result.rgb = lerp(_Result.rgb, _Render_Emboss * _Result.rgb, 0.5);

        /* etap 3; color bleeding */
        float _UV_X = saturate((1.0 - sin(abs(0.5 - UV.x) * 0.8 * M_PI)) * 12.0);
        float _Lum = Fun_Luminance(_Result.rgb * _UV_X);

        int i;

        float _W = 0.0;

            for(i = 0; i < _Quality; i++)
            {
                float2 _BOffset = float2(float(i) / float(_Quality) * fPixelWidth, 0.0);
                float _Weight = sin((float(i + 1) / float(_Quality)) * M_PI);

                    float3 _Render_ColorB = S2D_Image.Sample(S2D_ImageSampler, UV - _BOffset * _Size).rgb;
                    _Render_ColorB *= (Fun_Rand(In.texCoord + Fun_Rand(In.texCoord + i) + i) * 0.5 + 0.5);

                    _Result.rgb += _Render_ColorB * _Weight;

                _W += _Weight;
            }
            _Result.rgb /= _W;

                _Result.rgb = Fun_SetLum(_Result.rgb, _Lum);

        /* etap 4; HSV */
        float3 _HSV = RGBtoHSV(_Result.rgb);

            _HSV.y = (_HSV.y * (_Saturation / 50.0));
            _HSV.z = (_HSV.z + (_Value - 50.0) / 50.0);
            
            float _UV_XN = saturate((1.0 - _UV_X) * 0.5) - abs(_UV_Y * 10.0);
                _Result.rgb = HSVtoRGB(_HSV.x + _UV_XN, _HSV.y + _UV_XN, _HSV.z + _UV_Y * 9.0);

            _Result.rgb = lerp(_Result.rgb, (float3)0.0, 0.3);
            _Result.rgb *= 1.3;
            _Result.rgb += abs(_UV_Y * 10.0);

        /* etap 5; interlacing!
        // drawing with arrival; direct3d only! */

        uint _LVertical = (uint)((In.texCoord.y + _Frame * fPixelHeight) / fPixelHeight);
        bool _LCondition = (_LVertical % 2 == 0);

            if(_Interlacing && _LCondition)
                _Result.a *= _LCondition ? _Alpha : 1.0;

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET{
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
