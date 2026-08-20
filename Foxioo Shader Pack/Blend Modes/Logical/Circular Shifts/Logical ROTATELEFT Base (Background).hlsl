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
    float _Mixing;
	bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	float2 bgCoord : TEXCOORD1;
    float4 Position : SV_POSITION;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};


/************************************************************/
/* Main */
/************************************************************/

void Fun_ByteArray(out bool _Result[8], float _Color)
{
    int _Color_Temp = int(_Color * 255);

    const uint _Power[8] = { 1, 2, 4, 8, 16, 32, 64, 128 };

    for (int i = 0; i < 8; ++i)
    {
        _Result[i] = ((_Color_Temp / _Power[i]) % 2) == 1;
    }
}

void Fun_Bitwise(out bool _Result[8], bool _Base[8], bool _Blend[8])
{
    // thanks for help, naitor
    // TODO: fox, keep in mind that [unroll] exists in D3D11!
    [unroll]
    for (int i = 0; i < 8; ++i)
    {
        int _Index = i + _Blend[i];
        if (_Index >= 8) _Index -= 8;
        _Result[i] = _Base[_Index];
    }
}

float Fun_ByteColor(bool _Blend[8])
{
    float _Result = 0;

    const int _Power[8] = { 1, 2, 4, 8, 16, 32, 64, 128 };  

    for(int i = 0; i < 8; i++)
    {   
        if(_Blend[i]) { _Result += _Power[i]; }
    }

    return _Result /= 255.0;
}

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        bool _Byte_Texture_Red[8];          Fun_ByteArray(_Byte_Texture_Red, _Render_Texture.r);
        bool _Byte_Texture_Green[8];        Fun_ByteArray(_Byte_Texture_Green, _Render_Texture.g);
        bool _Byte_Texture_Blue[8];         Fun_ByteArray(_Byte_Texture_Blue, _Render_Texture.b);

        bool _Byte_Background_Red[8];       Fun_ByteArray(_Byte_Background_Red, _Render_Background.r);
        bool _Byte_Background_Green[8];     Fun_ByteArray(_Byte_Background_Green, _Render_Background.g);
        bool _Byte_Background_Blue[8];      Fun_ByteArray(_Byte_Background_Blue, _Render_Background.b);

            Fun_Bitwise(_Byte_Texture_Red, _Byte_Texture_Red, _Byte_Background_Red);
            Fun_Bitwise(_Byte_Texture_Green, _Byte_Texture_Green, _Byte_Background_Green);
            Fun_Bitwise(_Byte_Texture_Blue, _Byte_Texture_Blue, _Byte_Background_Blue);

    float4 _Result;
    
            _Result.r = Fun_ByteColor(_Byte_Texture_Red);
            _Result.g = Fun_ByteColor(_Byte_Texture_Green);
            _Result.b = Fun_ByteColor(_Byte_Texture_Blue);

            _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

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