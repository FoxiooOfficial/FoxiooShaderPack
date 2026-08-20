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
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = POINT;
    AddressU = BORDER;
    AddressV = BORDER;
    BorderColor = float4(0, 0, 1, 0);
};

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing, _PT, _DPI, 
            _Time, _Amplitude, _Wave, _Distortion,
            
            fPixelWidth, fPixelHeight;

    bool __;

    #define M_PI 3.14159265358979323846

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Result;
        
    float2 _Res = float2(fPixelWidth, fPixelHeight);
    float2 _FontSize = _DPI / 72.0 * _PT * _Res;

    float2 _CharsLine = 1.0 / (_Res.xy / _FontSize.xy * 1.25);

        float _Out;
        float2 _Quant = floor(In / _FontSize) * _FontSize;

        _Out = sin(_Quant.x *_CharsLine.y * _Wave + _Time + _Quant.y * _Distortion);
        _Out = floor(_Out / _FontSize.x) * _FontSize.y * _Amplitude;

        float2 _Coord = In + float2(0.0, _Out);

    float4 _Render_Texture = tex2D(S2D_Image, _Coord);

        _Result = lerp(_Render_Texture, _Render_Texture, _Mixing);

    if(__)
        return abs(float4((In.x - _Coord.x), In.y -_Coord.y, 0.0, 1.0)) * 64.;
    else
        return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
