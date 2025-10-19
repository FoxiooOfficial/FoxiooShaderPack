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

                _Lum.r = lerp(_Lum.r, cos(_Lum.r * 9.0 + _UV.y * 9.0 + _Render.r) *  sin(_UV.x * 6.0 - _Lum.r), _Phase * sin(_Lum.r * 15. + 2. * _Render.r));
                _Lum.g = lerp(_Lum.g, cos(_Lum.g * 8.0 + _UV.x * 10.0 + _Render.g) * sin(_UV.y * 6.0 - _Lum.g), _Phase * sin(_Lum.g * 17. + 2. * _Render.g));
                _Lum.b = lerp(_Lum.b, cos(_Lum.b * 10. + _UV.y * 13.0 + _Render.b) * sin(_UV.x * 6.0 - _Lum.b), _Phase * sin(_Lum.b * 13. + 2. * _Render.b));

                _Lum.r += abs(0.1 * sin(_Lum.r * 4. + _UV.x * 4.0 + _Render.r) * sin(_UV.y * 9.0 - _Lum.r));
                _Lum.g += abs(0.1 * sin(_Lum.g * 4. + _UV.y * 4.0 + _Render.g) * sin(_UV.x * 9.0 - _Lum.g));
                _Lum.b += abs(0.1 * sin(_Lum.b * 4. + _UV.x * 4.0 + _Render.b) * sin(_UV.y * 9.0 - _Lum.b));

            float3 _LumEx = Fun_Luminance(_Lum.rgb);

                _Lum.r = lerp(_Lum.r, cos(_LumEx.r * 9.0 + _UV.y * 9.0 +  _Lum.r) * sin(_UV.x * 6.0 - _LumEx.r), 0.2 * sin(_LumEx.r * 15. + 2. * _Lum.r));
                _Lum.g = lerp(_Lum.g, cos(_LumEx.g * 8.0 + _UV.x * 10.0 + _Lum.g) * sin(_UV.y * 6.0 - _LumEx.g), 0.2 * sin(_LumEx.g * 17. + 2. * _Lum.g));
                _Lum.b = lerp(_Lum.b, cos(_LumEx.b * 10. + _UV.y * 13.0 + _Lum.b) * sin(_UV.x * 6.0 - _LumEx.b), 0.2 * sin(_LumEx.b * 13. + 2. * _Lum.b));

        _Render.rgb = lerp(_Render.rgb, _Lum, _Mixing);
    
    _Render.a = _Render_Texture.a;
    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }