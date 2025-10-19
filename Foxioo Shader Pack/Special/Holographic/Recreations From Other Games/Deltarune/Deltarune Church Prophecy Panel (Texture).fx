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
//sampler2D S2D_Background : register(s1);
sampler2D _Texture : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _PosX, _PosY,
            _Scale, _ScaleX, _ScaleY,

            _PosXEcho, _PosYEcho,

            fPixelWidth, fPixelHeight;

    bool    _Color;
    
    float4  _ColorLight, _ColorShadow;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Lum (float4 _Result) { return 0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b; }

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    //float4 _Render_Background = tex2D(S2D_Background, In);

        /* Main Overlay */
        float2 _UV = ((In * 0.0025 + float2(_PosX, _PosY)) / float2(fPixelWidth, fPixelHeight)) * float2(_ScaleX, _ScaleY) * _Scale;
        _UV = frac(_UV);

            float4 _Result = tex2D(_Texture, _UV);
            float _Lum = Fun_Lum(_Result);
            _Result.a = _Render_Texture.a;

            /* Sub Texture 1 */
            float4 _Echo1 = tex2D(_Texture, _UV) * tex2D(S2D_Image, In + (float2(_PosXEcho, _PosYEcho) * float2(fPixelWidth, fPixelHeight)));
                _Echo1.a = Fun_Lum(_Echo1);
                _Result += _Echo1;

            /* Sub Texture 2 */
            float4 _Echo2 = tex2D(_Texture, _UV) * tex2D(S2D_Image, In + (float2(_PosXEcho * 2.0, _PosYEcho * 2.0) * float2(fPixelWidth, fPixelHeight)));
                _Echo2.a = Fun_Lum(_Echo2);
                _Result += _Echo2 * 0.5;

        /* End */
        if(_Color) _Result.rgb = lerp(_ColorShadow.rgb, _ColorLight.rgb, _Lum);

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
