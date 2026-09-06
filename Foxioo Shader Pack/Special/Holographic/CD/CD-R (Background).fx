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

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float _Lum = Fun_Luminance(_Render_Texture.rgb);
        float _LumBg = Fun_Luminance(_Render_Background.rgb);
        float _Render_Texture_Lum = Fun_Luminance(tex2D(S2D_Image, In.texCoord + float2(fPixelWidth, fPixelHeight) * (_Lum - _LumBg)).rgb);

        float2 CD = In.texCoord - 0.5 - _Lum * 0.1;
        float _Dist = length(CD);
        CD = smoothstep(0.5, 0, length(float2(CD.x - 0.5, CD.y)) * 0.1 + cos(CD.y) * 0.1);
        CD = frac(CD / 2.0);
        CD = abs(CD * 2.0 - 1.0);
        
        static const float _Frag = 6.28318;
        float4 _CDOffset = float4(
            sin(_Frag * CD.x + CD.y) * 0.5 + 0.5, 
            sin(_Frag * CD.x + CD.y + 2.0) * 0.5 + 0.5,
            sin(_Frag * CD.x + CD.y + 4.0) * 0.5 + 0.5, 
            1);

            float4 _Result = tex2D(S2D_Background, In.bgCoord + CD * 0.1);
            _Result.rgb = lerp(float3(0.529, 0.541, 0.568) * _Result.rgb * 0.15, float3(0.529, 0.541, 0.568) + _Result.rgb * 0.5, Fun_Luminance(_Result.rgb));
            _Result.rgb = lerp(_Result.rgb, _Render_Texture_Lum * 0.5, 0.95 + _Lum * 0.05);

        float3 _CDRainbow = float3(
            sin(_Frag * atan(((In.texCoord.x - In.texCoord.y) + (CD.x + CD.y) * 0.1 - _LumBg))) * 0.5 + 0.5, 
            sin(_Frag * atan(((In.texCoord.x + In.texCoord.y) + (CD.x - CD.y) * 0.1 - _LumBg) * 1.2) + 2.0) * 0.5 + 0.5,
            sin(_Frag * atan(((In.texCoord.x - In.texCoord.y) + (CD.x + CD.y) * 0.1 - _LumBg) * 1.4) + 4.0) * 0.5 + 0.5
            );

            _Result.rgb += _CDRainbow * 0.1;

        float _OrFreq = lerp(300.0, 1000.0, _Dist * _LumBg);
        float _OrPtr = sin(_Dist * _OrFreq) * 0.5 + 0.5;
        _OrPtr = smoothstep(0.3, 0.7, _OrPtr);

                float _Angle = atan2((In.texCoord.y + _OrPtr * 0.01) - 0.5, (In.texCoord.x + _OrPtr * 0.01) - 0.5);
                float _RayPattern = abs(sin(_Angle + (1.0 - (_LumBg - _Lum))));
                _RayPattern = smoothstep(0.0, 3.0 * _Lum, 0.5 * saturate(_RayPattern * _Lum * 0.25 * abs(_LumBg - atan2((In.texCoord.y + _OrPtr * 0.01), _LumBg - (In.texCoord.x + _OrPtr * 0.01)))));
                
                    _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb + _CDRainbow.rgb * 1.2, _RayPattern * 2.0);

                _RayPattern = abs(sin(_Angle * 2 + (_LumBg - _Lum)));
                _RayPattern = smoothstep(0.0, 3.0 * _Lum, saturate(_RayPattern * _Lum * 0.25 * abs(atan2((_OrPtr * 0.01 - CD.y), (_OrPtr * 0.01 - CD.x)))));

                _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb + _CDRainbow.rgb * 1.2, _RayPattern * 3.0);

        _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb * 1.5 * _Dist, _OrPtr * 0.05);
        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
