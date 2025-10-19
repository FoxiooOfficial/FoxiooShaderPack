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

    bool  _Blending_Mode;  

    float   _Mixing,
            _BlurScale,
            _Segments,

            _YLevels,
            _CLevels,

            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Y(float _R, float _G, float _B)   {   return 0.299* _R + 0.587 * _G + 0.114 * _B;    }

float Fun_Cb(float _b, float _Y)            {   return 0.5 + (_b - _Y) * 0.564;    }
float Fun_Cr(float _r, float _Y)            {   return 0.5 + (_r - _Y) * 0.713;    }

float3 Fun_YCbCr(float _Y, float _Cb, float _Cr)
{
    return float3(
        _Y + 1.402 * (_Cr - 0.5),
        _Y - 0.344 * (_Cb - 0.5) - 0.714 * (_Cr - 0.5),
        _Y + 1.772 * (_Cb - 0.5)
    );
    
}

float4 Fun_GetColor(float2 In, sampler2D _Texture)  {    return tex2D(_Texture, In); }

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

float Quantize(float _V, float _Levels, float _Mixing)
{
    float _Quantize = round(_V * _Levels) / _Levels;
    return lerp(_V, _Quantize, _Mixing);
}

float4 Main(float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float _Div = (_Segments * _Mixing * fPixelWidth) == 0 ? 0.00001 : (_Segments * _Mixing * fPixelWidth);
    float __Segments = 1.0 / _Div;

        float4 _Result = _Blending_Mode ? Fun_Interpolation(In, __Segments, S2D_Background, _BlurScale) : Fun_Interpolation(In, __Segments, S2D_Image, _BlurScale);
        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;
    float Y  = Fun_Y(_Result.r, _Result.g, _Result.b);
    float Cb = Fun_Cb(_Result.b, Y);
    float Cr = Fun_Cr(_Result.r, Y);
    float Yq  = Quantize(Y,  _YLevels, _Mixing);
    float Cbq = Quantize(Cb, _CLevels, _Mixing);
    float Crq = Quantize(Cr, _CLevels, _Mixing);

    _Result.rgb = Fun_YCbCr(Yq, Cbq, Crq);
    _Result.a   = _Render_Texture.a;
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
