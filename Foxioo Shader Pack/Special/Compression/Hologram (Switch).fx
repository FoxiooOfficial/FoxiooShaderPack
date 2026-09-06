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

    float   _Mixing,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture;
    float4 _Render_Background;

    int2 _Pixel = float2((int)(In.texCoord.x / fPixelWidth), (int)(In.texCoord.y / fPixelHeight));

            float4 _Result = 0.0;   

                _Render_Texture = tex2D(S2D_Image, In.texCoord + float2(fPixelWidth, fPixelHeight));
                _Render_Background = tex2D(S2D_Background, In.bgCoord + (fPixelWidth, fPixelHeight));
                float4 _RenderOff2 = _Blending_Mode ? _Render_Background : _Render_Texture;
                
                _Render_Texture = tex2D(S2D_Image, In.texCoord);
                _Render_Background = tex2D(S2D_Background, In.bgCoord);
                float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

            /* x-axis */
            if ((_Pixel.x % 2) == 0)    _Result.rgb = float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.x % 2) == 1)    _Result.rgb = float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb = float3(_RenderOff2.r, 0.0, _Render.b);

            /* y-axis */
            if ((_Pixel.y % 2) == 0)    _Result.rgb += float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.y % 2) == 1)    _Result.rgb += float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb += float3(_RenderOff2.r, 0.0, _Render.b);


        _Result.rgb = lerp(_Render.rgb, _Result.rgb / 2.0, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
