/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    AddressU = BORDER;
    AddressV = BORDER;
    BorderColor = float4(0, 0, 0, 0);
};
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,

            fPixelWidth, fPixelHeight;

    float4 _ColorShadow, _Color, _ColorLight;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Lum (float4 _Result) { return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b); }

float3 Fun_Outline(float2 In, float3 _Color)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = tex2D(S2D_Image, In).a;

    float aL1 = tex2D(S2D_Image, In + float2(-_PX.x, 0.0)).a;
    float aR1 = tex2D(S2D_Image, In + float2( _PX.x, 0.0)).a;
    float aU1 = tex2D(S2D_Image, In + float2(0.0, -_PX.y)).a;
    float aD1 = tex2D(S2D_Image, In + float2(0.0,  _PX.y)).a;

    float aL2 = tex2D(S2D_Image, In + float2(-_PX.x * 2.0, 0.0)).a;
    float aR2 = tex2D(S2D_Image, In + float2( _PX.x * 2.0, 0.0)).a;
    float aU2 = tex2D(S2D_Image, In + float2(0.0, -_PX.y * 2.0)).a;
    float aD2 = tex2D(S2D_Image, In + float2(0.0,  _PX.y * 2.0)).a;

        float _Edge1  = step(0.01, abs(aL1 - _Alpha) + abs(aR1 - _Alpha) + abs(aU1 - _Alpha) + abs(aD1 - _Alpha));
        float _Edge2 = step(0.01, abs(aL2 - _Alpha) + abs(aR2 - _Alpha) + abs(aU2 - _Alpha) + abs(aD2 - _Alpha));

    return lerp(_Color, _Color + _Color * 0.25, _Edge1 * _Alpha) + _Edge2 * 0.15;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Background = tex2D(S2D_Background, In);

        float _Lum = pow(Fun_Lum(_Render_Texture), 2);
        float _Lum_Background = pow(Fun_Lum(_Render_Background), 2);

        float4 _Result;

            _Result.rgb = lerp(_ColorShadow.rgb, lerp(_ColorLight.rgb, _Color.rgb, _Lum * _Lum), _Lum);

                float2 _Center_Off = float2(0.5, 1.0 - 0.2);
                float2 _Center = float2(0.5, 0.5);

                float _Dist = distance(In, _Center_Off);
                float _Dist_Cen = distance(In, _Center);

                        _Result.rgb += saturate(1.0 - (_Dist / 0.25)) * 0.15;
                        _Result.rgb += saturate(1.0 - (_Dist / 0.75)) * 0.35;

                    _Result.rgb += saturate((_Dist_Cen / 0.75)) * 0.15;

                    /* Arc */
                        float _Inside = step(_Dist, 0.75);

                        float _Arc_Out = smoothstep(0.75 + 0.15, 0.75, _Dist);
                        _Result.rgb += _Arc_Out * (1.0 - _Inside) * 0.15;

                        float _Arc_In = smoothstep(0.75 - 0.4, 0.75, _Dist);
                        _Result.rgb += _Arc_In * (_Inside) * 0.15;

                    _Result.rgb = (Fun_Outline(In, _Result.rgb));

                float _Lum_Aero = Fun_Lum(float4(_Result.rgb, 1.0));
                float4 _Render_Background_Ex = (tex2D(S2D_Background, In - (_Lum_Aero * 0.25) + 0.125));

            _Result.rgb += _Render_Background_Ex.rgb * _Lum * _Lum;
            _Result.rgb = lerp(_Result.rgb, _Result.rgb * _Result.rgb * lerp(1.0, _Result.rgb * _Lum, 0.5), 0.85);

        _Result.a = _Render_Texture.a;
        _Result = lerp(_Render_Texture, _Result * lerp(1.0, _Lum, 0.1 * (1.0 - _Lum)), _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
