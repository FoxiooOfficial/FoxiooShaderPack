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
    AddressU = Border;
    AddressV = Border;
    BorderColor = float4(0.0, 0.0, 1.0, 0.0);
};
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Size,

            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 _OverlayTop    = float4(0.41, 0.4, 0.44, 1.0);
float4 _OverlayBottom = float4(0.4, 0.4, 0.42, 1.0);

float3 _InnerLight     = float3(0.65, 0.64, 0.73);
float3 _InnerShadow    = float3(0.96, 0.95, 0.97);

float Fun_Luminance(float4 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y * _Result.a;
}

float4 Fun_Border(sampler2D _Sampler, float2 In, float2 _Off, float4 _Render)
{
    float _Up      = Fun_Luminance(tex2D(_Sampler, In + float2(0.0,  _Off.y))) * 1.75;
    float _Down    = Fun_Luminance(tex2D(_Sampler, In + float2(0.0, -_Off.y))) * 1.75;
    float _Left    = Fun_Luminance(tex2D(_Sampler, In + float2( _Off.x, 0.0))) * 1.75;
    float _Right   = Fun_Luminance(tex2D(_Sampler, In + float2(-_Off.x, 0.0))) * 1.75;

        float _Glow = _Render.a - _Up;
        float _Shadow = (_Render.a * 3.0) - (_Down + _Left + _Right);

    float4 _Result = 0.0;
    _Result = lerp(_Result, _OverlayTop, _Glow);
    _Result = lerp(_Result, _OverlayBottom, _Shadow);

    return _Result;
}

float3 Fun_Sharp(sampler2D _Sampler, float2 In, float2 _Off)
{
    float2 _Emboss;

    float4 _NW = tex2D(_Sampler, In + float2(-_Off.x, -_Off.y));
    float4 _N  = tex2D(_Sampler, In + float2(0.0, -_Off.y));
    float4 _NE = tex2D(_Sampler, In + float2( _Off.x, -_Off.y));
    float4 _W  = tex2D(_Sampler, In + float2(-_Off.x, 0.0));
    //float4 _C  = tex2D(_Sampler, In);
    float4 _E  = tex2D(_Sampler, In + float2( _Off.x, 0.0));
    float4 _SW = tex2D(_Sampler, In + float2(-_Off.x, _Off.y));
    float4 _S  = tex2D(_Sampler, In + float2(0.0,_Off.y));
    float4 _SE = tex2D(_Sampler, In + float2( _Off.x, _Off.y));

        _Emboss.x = (Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE)) - (Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW));
        _Emboss.y = (Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE)) - (Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE));
        _Emboss.y = -_Emboss.y;

    float3 _Render = normalize(float3(_Emboss.x, _Emboss.y, 0.8));
    _Render = pow(abs(_Render * 0.5 + 0.5), 0.75);

    return _Render;
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);
    
        float4 _Result, _Render;
        float _Alpha;
        float2 _Offset = _Size * -float2(fPixelWidth, fPixelHeight);

            if(!_Blending_Mode)
            {
                _Result = _Render_Texture;
                _Render = Fun_Border(S2D_Image, In, _Offset, _Render_Texture);

                float3 _Sharp = float3(Fun_Sharp(S2D_Image, In, _Offset));
                _Alpha = Fun_Luminance(float4(_Sharp.r, _Sharp.g, _Sharp.b, _Render_Texture.a));
            }
            else
            {
                _Result.rgb = _Render_Background.rgb;
                _Result.a = _Render_Texture.a;

                _Render = Fun_Border(S2D_Background, In, _Offset, _Render_Background);

                float3 _Sharp = float3(Fun_Sharp(S2D_Background, In, _Offset));
                _Alpha = Fun_Luminance(float4(_Sharp.r, _Sharp.g, _Sharp.b, _Render_Texture.a));
            }
            
                float _InnerMask = saturate((_Alpha * _Alpha) * 2.0) * 0.85;
                float3 _InnerColor = lerp(_InnerShadow, _InnerLight, _InnerMask);

                _InnerColor += (_InnerColor * (abs(In.y * 1.3 - 0.75) * _InnerLight)) * 0.25;
                _InnerColor -= pow(abs(In.x * 2.0 - 1.0), 3.0) * 0.5 * _InnerShadow;

            _Render.rgb = lerp(_InnerColor, _Render.rgb, _Render.a / 18.0);

        _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
