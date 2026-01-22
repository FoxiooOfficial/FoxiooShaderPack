/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (28.11.2025) */
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

    float   _Mul, _Mixing,
            _Distance;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In) * _Mul;

        float4 _Render;
        _Render.rgb = _Render_Texture.rgb + (_Render_Background.rgb * _Render_Background.rgb);
        _Render.a = _Render_Texture.r * _Render_Texture.g * _Render_Texture.b * _Render_Texture.a;

        float4 _RenderClose = _Render * 0.04705;
        float4 _RenderFar   = _Render + lerp(0.43529, 0.164705, In.y) * _Render_Texture.a;

        _RenderFar.rgb += _Render_Background.rgb * _RenderFar.rgb;

                
                float _DistanceEx = max(1.0 - abs(1.0 - abs(_Distance)), 0.1);
                float _DistanceExEx = max(1.0 - abs(1.0 - abs(_Distance)), 0.0);
                float _Alpha = max(_DistanceEx, 0.5);
                if(abs(_Distance) >= 1.0) _DistanceEx *= 1.5;

            float4 _Fade = lerp(_RenderClose, _RenderFar * 1.25, saturate(_DistanceEx)) * _Alpha;
            float _Fade_Alpha = _Fade.r * _Fade.g * _Fade.b * _Fade.a;

            float4 _Result = _Fade * _Fade_Alpha + _Render_Background + _Render_Texture * _DistanceExEx * 0.5 + _Fade * _DistanceExEx * 0.5;

            _Result = lerp(_Render_Texture, _Result * _Render_Texture.a, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
