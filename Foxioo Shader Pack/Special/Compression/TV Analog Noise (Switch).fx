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
            _PosX, _PosY,
            _Scale, _ScaleX, _ScaleY,
            
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453 + cos(_Pos * 34565.0)); }
float Fun_Noise(float2 _Pos)
{
    float2 _I = floor(_Pos + _Seed);    float2 _F = frac(_Pos);

        float _A = Fun_Hash21(_I + float2(0.0, 0.0) + _Seed);
        float _B = Fun_Hash21(_I + float2(1.0, 0.0) + _Seed);
        float _C = Fun_Hash21(_I + float2(0.0, 1.0) + _Seed);
        float _D = Fun_Hash21(_I + float2(1.0, 1.0) + _Seed);

    float2 _UV = _F * _F * (3.0 - 2.0 *_F);

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float3 Fun_NoiseGradient(float2 _UV)
{
    float2 _Offset = float2(12.9898, 78.233);
    float _Noise = Fun_Noise(_UV * 1.0 / float2(fPixelWidth, fPixelHeight) * 0.25);

    float _Noise1 = Fun_Noise((_UV * 1.5 / float2(fPixelWidth, fPixelHeight) * 0.25 + _Offset.yx) * 1.17);
    float _Noise2 = Fun_Noise((_UV * 1.5 / float2(fPixelWidth, fPixelHeight) * 0.25 - _Offset.xy) * 1.23);
    
    float3 _Render = lerp(_Noise1, _Noise2, _Noise) * 1.35;

    return _Render;
}

float3 Fun_NoiseSat(float3 _Color, float _Sat)
{
    float _Lum = dot(_Color, float3(0.299, 0.587, 0.114));

    return lerp(float3(_Lum, _Lum, _Lum), _Color, _Sat);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Background = tex2D(S2D_Background, In);

        float2 _UV = (In + float2(_PosX, _PosY)) * float2(_ScaleX, _ScaleY) * _Scale; 
        float4 _Result = 0.0;

            _Result.rgb = Fun_NoiseGradient(_UV);

                float4 _Render = _Blending_Mode ? lerp(_Render_Background, float4(_Result.rgb, 0), _Mixing) : lerp(_Render_Texture, float4(_Result.rgb, 0), _Mixing);
                _Render.a = _Render_Texture.a;

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
