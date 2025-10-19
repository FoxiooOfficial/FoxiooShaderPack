/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.4 (18.10.2025) */
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

    float   _Mixing;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = 0;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

            const float _Kr = 0.299;
            const float _Kg = 0.587;
            const float _Kb = 0.114;

            float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;
            float _Cb = -0.168736 * _Result.r - 0.331264 * _Result.g + 0.5 * _Result.b + 0.5;
            float _Cr = 0.5 * _Result.r - 0.418688 * _Result.g - 0.081312 * _Result.b + 0.5;

        _Result.a = _Render_Texture.a;

        _Result.rgb = lerp(_Result.rgb, float3(_Y, _Cb, _Cr), _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
