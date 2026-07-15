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

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _DitheringSize; 
    float _Add;
    float _Mul;
    bool __;
	bool _Is_Pre_296_Build;
	bool ___;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
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

// https://gist.github.com/cesarmiquel/1780ab6078b9735371d1f10a9d60d233
static const float _Level_Lum[3] = { 1.0, 27.909 / 63.0, 16.002 / 63.0 };      // { 255, 113, 65 } -> { 63, ~27.909, ~16.002 }
static const float _Level_Sat[3] = { 0.0, 0.5, 5.0 / 7.0 };

float Fun_Quant(float _Level, float3 _Color, out int _Out)
{
    float3 _Diff = abs(_Level - _Color);

    if(_Diff.x <= _Diff.y && _Diff.x <= _Diff.z)
    {
        _Out = 0;
        return _Color.x;
    }
    else if(_Diff.y <= _Diff.x && _Diff.y <= _Diff.z)
    {
        _Out = 1;
        return _Color.y;
    }
    else
    {
        _Out = 2;
        return _Color.z;
    }
}

float3 Fun_Convert(float3 _Color)
{
    float _V = max(_Color.r, max(_Color.g, _Color.b));
    float _Min = min(_Color.r, min(_Color.g, _Color.b));
    float _Diff = _V - _Min;

    float _Sat = _V > 0.001 ? _Diff / _V : 0.0;

    // gray map
    if(_Sat < 0.06 || _V < 0.02)
        return floor(_Color * 15.0 + 0.5) / 15.0;

        int _V_In;
        float _V_High = Fun_Quant(_V, float3(_Level_Lum[0], _Level_Lum[1], _Level_Lum[2]), _V_In);

        int _S_In;
        float _Sat_High = Fun_Quant(_Sat, float3(_Level_Sat[0], _Level_Sat[1], _Level_Sat[2]), _S_In);

            float _Low = _V_High * (1.0 - _Sat_High);

    float _Hue;
    if(_V == _Color.r)      _Hue = 60.0 * fmod((_Color.g - _Color.b) / _Diff, 6.0);
    else if(_V == _Color.g) _Hue = 60.0 * ((_Color.b - _Color.r) / _Diff + 2.0);
    else                    _Hue = 60.0 * ((_Color.r - _Color.g) / _Diff + 4.0);

        if(_Hue < 0.0) _Hue += 360.0;

    float _Sec = _Hue / 60.0;
    uint _Step = floor(_Sec);
    float _Angle = floor((_Sec - _Step) * 4.0) / 4.0;
    float _Vviv;

        if((_Step % 2 == 0))
            _Vviv = lerp(_Low, _V_High, _Angle);
        else
            _Vviv = lerp(_V_High, _Low, _Angle);

    switch(_Step)
    {
        case 0: return float3(_V_High, _Vviv, _Low);
        case 1: return float3(_Vviv, _V_High, _Low);
        case 2: return float3(_Low, _V_High, _Vviv);
        case 3: return float3(_Low, _Vviv, _V_High);
        case 4: return float3(_Vviv, _Low, _V_High);
        case 5: return float3(_V_High, _Low, _Vviv); 
        default: return 0.0;
    }
}

static const float _Dithering[16] =
{
    0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
   12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
   15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
};

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

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    _Render_Texture.rgb = _Render_Texture.rgb * _Mul + _Add;
    _Render_Background.rgb = _Render_Background.rgb * _Mul + _Add;

        float4 _Result, _Render;

        if(!_Blending_Mode) {
            _Result = _Render_Texture;
            _Render = _Render_Texture;
        }
        else {
            _Result.rgb = _Render_Background.rgb;
            _Result.a = _Render_Texture.a;
            
            _Render = _Render_Background;
        }

        int2 _Dith = int2(  fmod(In.texCoord.x / fPixelWidth,   4.0), 
                            fmod(In.texCoord.y / fPixelHeight,  4.0)
                        );

        int _Index = _Dith.x + _Dith.y * 4;
        float _DithValue = _Dithering[_Index];
                
        float3 _Color = _Result.rgb + (_DithValue - 0.5) * _DitheringSize;
                    
            _Color = saturate(_Color);

            _Result.rgb = Fun_Convert(_Color);
            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);  

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET { 
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
