/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
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

    float _Mixing, _Segments, _BlurScale, fPixelWidth, fPixelHeight;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_GetColor(float2 In, sampler2D _Texture)
{
    return tex2D(_Texture, In);
}

float4 Fun_Interpolation(float2 In, float _Segm, sampler2D _Texture, float _Smoothness)
{
    float2 _In_Segment = floor(In * _Segm) / _Segm;
    float2 _In_Segment_Next = (floor(In * _Segm) + 1.0) / _Segm;
    
    float2 _UV = frac(In * _Segm);

        float4 _Render_0X = Fun_GetColor(_In_Segment, _Texture);
        float4 _Render_1X = Fun_GetColor(float2(_In_Segment_Next.x, _In_Segment.y), _Texture);
            
            float4 _Render_X = lerp(_Render_0X, _Render_1X, smoothstep(0.0, _Smoothness, _UV.x));


        float4 _Render_0Y = Fun_GetColor(float2(_In_Segment.x, _In_Segment_Next.y), _Texture);
        float4 _Render_1Y = Fun_GetColor(_In_Segment_Next, _Texture);
       
            float4 _Render_Y = lerp(_Render_0Y, _Render_1Y, smoothstep(0.0, _Smoothness, _UV.x));

    return lerp(_Render_X, _Render_Y, smoothstep(0.0, _Smoothness, _UV.y));
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float _Div = (_Segments * _Mixing * fPixelWidth) == 0 ? 0.00001 : (_Segments * _Mixing * fPixelWidth);
    float __Segments = 1.0 / _Div;

    float4 _Result = _Blending_Mode ? Fun_Interpolation(In, __Segments, S2D_Background, _BlurScale) : Fun_Interpolation(In, __Segments, S2D_Image, _BlurScale);
    float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

    _Result.rgb = lerp(_Render.rgb, _Render.rgb + _Result.rgb * _Result.rgb, _Mixing);
    
    if (_Blending_Mode) 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
