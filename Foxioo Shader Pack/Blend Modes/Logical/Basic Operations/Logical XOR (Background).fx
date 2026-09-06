/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

/***********************************************************/

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

void Fun_ByteArray(out bool _Result[8], float _Color)
{
    int _Color_Temp = int(_Color * 255);

    const int _Power[8] = { 1, 2, 4, 8, 16, 32, 64, 128 };

    for (int i = 0; i < 8; ++i)
    {
        _Result[i] = ((_Color_Temp / _Power[i]) % 2) == 1;
    }
}

void Fun_Bitwise(out bool _Result[8], bool _Base[8], bool _Blend[8])
{
    _Result[0] = _Base[0] != _Blend[0];
    _Result[1] = _Base[1] != _Blend[1];
    _Result[2] = _Base[2] != _Blend[2];
    _Result[3] = _Base[3] != _Blend[3];
    _Result[4] = _Base[4] != _Blend[4];
    _Result[5] = _Base[5] != _Blend[5];
    _Result[6] = _Base[6] != _Blend[6];
    _Result[7] = _Base[7] != _Blend[7];
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

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);
    
        bool _Byte_Texture_Red[8];          Fun_ByteArray(_Byte_Texture_Red, _Render_Texture.r);
        bool _Byte_Texture_Green[8];        Fun_ByteArray(_Byte_Texture_Green, _Render_Texture.g);
        bool _Byte_Texture_Blue[8];         Fun_ByteArray(_Byte_Texture_Blue, _Render_Texture.b);

        bool _Byte_Background_Red[8];       Fun_ByteArray(_Byte_Background_Red, _Render_Background.r);
        bool _Byte_Background_Green[8];     Fun_ByteArray(_Byte_Background_Green, _Render_Background.g);
        bool _Byte_Background_Blue[8];      Fun_ByteArray(_Byte_Background_Blue, _Render_Background.b);

            Fun_Bitwise(_Byte_Texture_Red, _Byte_Texture_Red, _Byte_Background_Red);
            Fun_Bitwise(_Byte_Texture_Green, _Byte_Texture_Green, _Byte_Background_Green);
            Fun_Bitwise(_Byte_Texture_Blue, _Byte_Texture_Blue, _Byte_Background_Blue);

    float4 _Result = 0;
    
        _Result.r = Fun_ByteColor(_Byte_Texture_Red);
        _Result.g = Fun_ByteColor(_Byte_Texture_Green);
        _Result.b = Fun_ByteColor(_Byte_Texture_Blue);

            _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;
    
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
