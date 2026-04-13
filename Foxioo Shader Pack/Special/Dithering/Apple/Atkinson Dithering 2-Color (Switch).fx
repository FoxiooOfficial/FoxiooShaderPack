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
sampler2D S2D_Dither : register(s2);

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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == 0) {   _Result = _Render_Texture;      _Render = _Render_Texture;  }
        else                    {   _Result = _Render_Background;   _Render = _Render_Background; }
            
            float _Lum = ((0.2126 * _Render.r + 0.7152 * _Render.g + 0.0722 * _Render.b) * 63.0);
            _Lum = floor(_Lum);
            //_Lum /= 15.0;

                float2 _UV = frac(In / float2(fPixelWidth, fPixelHeight) / 32.0); 

                    _UV.x *= (32.0 / 2048.0);
                    _UV.x += (_Lum * 32.0 / 2048.0);
                    
                float3 _Dither = tex2D(S2D_Dither, _UV).rgb;
                _Result.rgb = _Dither;

            _Result.rgb = (_Lum * _Dither.r / 63.0 >= _Threshold) ? _Color.rgb : _ColorShadow.rgb;

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
