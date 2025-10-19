/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    AddressU = BORDER;
    AddressV = BORDER;
    BorderColor = float4(0, 0, 0, 0);
};
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing, 
            _Seed,

            _Speed,
            _LineLength,    _Softness,
            _Weirdness,     _Radius,
            _Freq,  
            _PointX, _PointY,

            fPixelWidth, fPixelHeight;

    float4  _Color;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453); }
float Fun_Noise(float2 _Pos, float2 _Ran)

{       float _A = Fun_Hash21(floor(_Pos * _Ran + float2(0.0, 0.0) + _Seed) / _Ran);
        float _B = Fun_Hash21(floor(_Pos * _Ran + float2(1.0, 0.0) + _Seed) / _Ran);
        float _C = Fun_Hash21(floor(_Pos * _Ran + float2(0.0, 1.0) + _Seed) / _Ran);
        float _D = Fun_Hash21(floor(_Pos * _Ran + float2(1.0, 1.0) + _Seed) / _Ran);

    float2 _Smooth = smoothstep((0.0), (1.0), (_Pos * _Ran) % 1.0);
    return lerp(lerp(_A, _B, _Smooth.y), lerp(_C, _D, _Smooth.y), _Smooth.x);
}

float Fun_Noise(float2 _Value)
{
    float _Sum = 0.0;

        for (int i = 1; i < 6; i++)
        {
            float _Pow = 2.0 * pow(2.0, i);
            _Sum += Fun_Noise(_Value + float2(i, i), float2(_Pow, _Pow)) / pow(2.0, i);
        }

    return _Sum;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

    float2 _UV = (In - float2(_PointX, _PointY)) * 2.0;
    float2 _UVZoom = float2(    _Weirdness * length(_UV) + _Speed,    _Freq * atan2(_UV.y, _UV.x) );

            float _Noise = Fun_Noise(_UVZoom);
            _Noise = length(_UV) - _Radius - _LineLength * (_Noise - 0.5);
            _Noise = smoothstep(-_Softness, _Softness, _Noise);

        float4 _Result;

        _Result.rgb = lerp(_Render.rgb, _Color.rgb, _Mixing * _Noise * _Render_Texture.a);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
