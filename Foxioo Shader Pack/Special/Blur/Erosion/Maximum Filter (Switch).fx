/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (07.04.2026) */
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

    float   _Size, _Mixing,
            
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

static const int _Offset = 1;

float3 Fun_Filter(sampler2D _Sampler, float2 In, float3 _Render)
{
    float3 _Result = _Render;

    for(int y = -_Offset; y <= _Offset; y++)
    {
        for(int x = -_Offset; x <= _Offset; x++)
        {
            _Result.rgb = max(_Result.rgb, tex2D(_Sampler, In + (float2(x, y) / _Offset) * float2(fPixelWidth, fPixelHeight) * _Size).rgb);
        }
    }

    return _Result;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float3 _Filter = _Blending_Mode ? Fun_Filter(S2D_Background, In, _Render_Background.rgb) : Fun_Filter(S2D_Image, In, _Render_Texture.rgb);

        _Result.rgb = lerp(_Result.rgb, _Filter, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
