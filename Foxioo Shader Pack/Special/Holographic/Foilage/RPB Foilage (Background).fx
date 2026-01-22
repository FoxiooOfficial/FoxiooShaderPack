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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = _Render_Background * float4(0.1, 1.0, 1.0, 1.0);

            float3 _Render = tex2D(S2D_Image, In + sin(Fun_Luminance(_Render_Texture.rgb + _Render_Background.rgb) * 3.14 + Fun_Luminance(_Render_Background.rgb) + Fun_Luminance(_Render_Texture.rgb)) * 0.05);

            const float3 _ColorR = float3(255.0, 70.0, 0.0) / 255;
            const float3 _ColorG = float3(128.0, 255.0, 132.0) / 255;
            const float3 _ColorB = float3(128.0, 0.0, 132.0) / 255;

            float3      _RenderO = lerp(_Render.rgb, _ColorR,  _Render.r * _Render.r);
                        _RenderO = lerp(_RenderO.rgb, _ColorG, _Render.g * _Render.g);
                        _RenderO = lerp(_RenderO.rgb, _ColorB, _Render.b * _Render.b);

            _Result.rgb = lerp(_Result.rgb, _RenderO.rgb * 1.2 + (_Result.rgb * _Render_Texture.rgb) * 0.78, Fun_Luminance(_Render.rgb));
            _Result.rgb += lerp(_Result.rgb, _RenderO, Fun_Luminance(_Render.rgb) * 1.5) * 0.25 * Fun_Luminance(_Render.rgb);

            _Result.rgb *= saturate(_Result.rgb + 0.5);

            _Result.rgb = lerp(_Render_Texture.rgb,  _Result.rgb, _Mixing); 

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
