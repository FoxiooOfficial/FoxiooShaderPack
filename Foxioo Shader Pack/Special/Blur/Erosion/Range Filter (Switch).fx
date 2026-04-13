/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (13.04.2026) */
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

static const int _Offset = 1.0;

/* Based on: https://www.digimizer.com/manual/m-image-rangefilter.php */
float3 Fun_Filter(sampler2D _Sampler, float2 In)
{
    float3 _Min = 1.0;
    float3 _Max = 0.0;
    
    for(int y = -_Offset; y <= _Offset; y++)
    {
        for(int x = -_Offset; x <= _Offset; x++)
        {
            float3 _Render = tex2D(_Sampler, In + (float2(x, y) / _Offset) * float2(fPixelWidth, fPixelHeight) * _Size).rgb;

            _Min = min(_Min, _Render);
            _Max = max(_Max, _Render);
        }
    }

    return _Max - _Min;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float3 _Filter = _Blending_Mode ? Fun_Filter(S2D_Background, In) : Fun_Filter(S2D_Image, In);

        _Result.rgb = lerp(_Result.rgb, _Filter, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
