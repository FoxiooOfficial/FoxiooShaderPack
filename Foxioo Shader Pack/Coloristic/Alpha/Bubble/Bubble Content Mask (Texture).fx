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

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;
    AddressU = clamp;
    AddressV = clamp;
    BorderColor = float4(0, 0, 0, 0);
};

sampler2D S2D_Background : register(s1) = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;
    AddressU = clamp;
    AddressV = clamp;
    BorderColor = float4(0, 0, 0, 0);
};

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            _OutlineOffset, _OutlineAlpha,

            fPixelWidth, fPixelHeight;

    float4 _ColorIn, _ColorBackground, _OutlineColor;

    bool    _OutlineCorner;

    #define _SIZE 1

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

    float4 _Result;
    float _Inside;

    if(all(_Render_Background.rgb == _ColorIn.rgb))
    {   
        /* inside */
        _Result.rgb = _Render_Texture.rgb;
        _Result.a = 1.0;
        _Inside = 1.0;

        _Result.rgb = lerp(_ColorBackground, _Render_Texture, _Render_Texture.a);
    }
    else
    {   
        /* outside!!! */
        _Result = float4(0.0, 0.0, 0.0, 0.0);
        _Inside = 0.0;
    }

        /* outline !! */
        float _Outline = 0.0;
        for (int y = -_SIZE; y <= _SIZE; y++)
        {
            for (int x = -_SIZE; x <= _SIZE; x++)
            {
                bool _Test = (x == 0) != (y == 0);
                bool _Include = _OutlineCorner ? true : _Test;

                if (_Include)
                {
                    float2 _Off = float2(fPixelWidth, fPixelHeight) * float2(x, y) * _OutlineOffset;
                    bool _Comp = all(tex2D(S2D_Background, In.texCoord + _Off).rgb == _ColorIn.rgb);
                    _Outline += (float)_Comp;
                }
            }
        }

            _Outline = saturate(_Outline);
            _Inside = saturate(_Inside);

        _Result = lerp(float4(_OutlineColor.rgb, _OutlineAlpha), _Result, 1.0 - (_Outline - _Inside));
        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
