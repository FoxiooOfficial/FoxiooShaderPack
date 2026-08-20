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
sampler2D _Texture_Dithering : register(s2);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing, _Threshold,
            fPixelWidth, fPixelHeight;

    float4  _Color, _ColorShadow;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result, _Render;

        if(!_Blending_Mode)
        {
            _Result = _Render_Texture;
            _Render = _Render_Texture;
        }
        else
        {
            _Result.rgb = _Render_Background.rgb;
            _Result.a = _Render_Texture.a;
            
            _Render = _Render_Background;
        }
            
            float _Lum = dot(_Result.rgb, float3(0.2126, 0.7152, 0.0722)) * 63.0;
            _Lum = floor(_Lum);

                float2 _UV = frac(In / float2(fPixelWidth, fPixelHeight) / 32.0); 

                    _UV.x *= (32.0 / 2048.0);
                    _UV.x += (_Lum * 32.0 / 2048.0);
                    
                float3 _Dither = tex2D(_Texture_Dithering, _UV).rgb;
                _Result.rgb = _Dither;

            _Result.rgb = (_Lum * _Dither.r / 63.0 >= _Threshold) ? _Color.rgb : _ColorShadow.rgb;

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
