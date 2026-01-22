/***********************************************************/

/* Shader author: Foxioo */
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

    float _Mixing;

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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Background = tex2D(S2D_Background, In);

        float _Lum = Fun_Luminance(_Render_Texture.rgb);
        float _LumBg = Fun_Luminance(_Render_Background.rgb);
        float _Render_Texture_Lum = Fun_Luminance(tex2D(S2D_Image, In + (_Lum * 0.1 - _LumBg * 0.0025)).rgb);

        float2 CD = In - 0.5 - _Lum * 0.1;
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

            float4 _Result = tex2D(S2D_Background, In + CD * 0.1);
            _Result.rgb = lerp(float3(0.541, 0.611, 0.784) * _Result.rgb * 0.15, float3(0.529, 0.541, 0.568) + _Result.rgb * 0.5, Fun_Luminance(_Result.rgb));
            _Result.rgb = lerp(_Result.rgb, float3(0.541, 0.611, 0.784) * 0.5 + _Render_Texture.rgb * _Render_Texture_Lum * 0.1, 0.95 + _Lum * 0.05);

        float3 _CDRainbow = float3(
            sin(_Frag * atan(((In.x + In.y) + (CD.x - CD.y) * 0.1 - _LumBg))) * 0.5 + 0.5, 
            sin(_Frag * atan(((In.x - In.y) + (CD.x + CD.y) * 0.1 - _LumBg) * 1.2) + 2.0) * 0.5 + 0.5,
            sin(_Frag * atan(((In.x + In.y) + (CD.x - CD.y) * 0.1 - _LumBg) * 1.4) + 4.0) * 0.5 + 0.5
            );

            _Result.rgb += _CDRainbow * 0.1;
            _Result.rgb *= float3(0.541, 0.611, 0.784);

        float _OrFreq = lerp(300.0, 1000.0, _Dist * _LumBg);
        float _OrPtr = sin(_Dist * _OrFreq) * 0.5 + 0.5;
        _OrPtr = smoothstep(0.2, 0.5, _OrPtr);

                float _Angle = atan2((In.y + _OrPtr * 0.01) - 0.5, (In.x + _OrPtr * 0.01) - 0.5);
                float _RayPattern = abs(sin(_Angle + (1.0 - (_LumBg - _Lum))));
                _RayPattern = smoothstep(0.0, 3.0 * _Lum, 0.5 * saturate(_RayPattern * _Lum * 0.25 * abs(_LumBg - atan2((In.y + _OrPtr * 0.01), _LumBg - (In.x + _OrPtr * 0.01)))));
                
                    _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb + _CDRainbow.rgb * 1.2, _RayPattern * 2.0);

                _RayPattern = abs(sin(_Angle * 2 + (_LumBg - _Lum)));
                _RayPattern = smoothstep(0.0, 10.0 * _Lum, saturate(_RayPattern * _Lum * 0.25 * abs(atan2((_OrPtr * 0.01 - CD.y), (_OrPtr * 0.01 - CD.x)))));

                _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb + _CDRainbow.rgb * 1.2, _RayPattern * 25.0);

        _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb * 1.5 * _Dist, _OrPtr * 0.05);

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
