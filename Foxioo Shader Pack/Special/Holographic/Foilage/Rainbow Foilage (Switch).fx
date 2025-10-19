/***********************************************************/

/* Autor shader: Foxioo */
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
/* Variables */
/***********************************************************/

    float   _Mixing,
            _Phase,
            _PosX, _PosY;
    
    bool    _Blending_Mode;

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
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;
        
            float3 _Lum = Fun_Luminance(_Render.rgb);
            _Lum *= _Lum;

                float2 _UV = In + float2(_PosX, _PosY);

                    _Lum.r = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.r + _Lum.r * 0.2 + 4.0))) * _Render.r;
                    _Lum.g = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.g + _Lum.g * 0.2 + 2.0))) * _Render.g;
                    _Lum.b = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.b + _Lum.b * 0.2 + 0.0))) * _Render.b;

                //_Lum = abs(_Lum);

        _Render.rgb = lerp(_Render.rgb, pow(_Render.rgb * 0.45 + 0.75 * (_Lum * _Render.rgb * 0.5 + _Lum * 0.5), 2.2), _Mixing);
    
    _Render.a = _Render_Texture.a;
    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }