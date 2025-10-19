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
            _Alpha,
            _Seed,
            _PosX, _PosY,
            _Scale, _ScaleX, _ScaleY,
            _Offset, _OffsetDistortion,
            
            fPixelWidth, fPixelHeight;

    float4  _ColorShadow, 
            _Color, 
            _ColorLight;

/************************************************************/
/* Main */
/************************************************************/

static const float2 _OffsetEx[8] = 
{
    float2(-1.0,  0.0),
    float2( 1.0,  0.0),
    float2( 0.00001, -1.0),
    float2( 0.00001,  1.0),

    float2(-1.0, -1.0),
    float2(-1.0,  1.0),
    float2( 1.0, -1.0),
    float2( 1.0,  1.0) 
};

float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453); }
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

float3 Fun_NoiseGradient(float2 _UV, float3 _Color_1, float3 _Color_2, float3 _Color_3)
{
    float _Noise = Fun_Noise(_UV * 4.0);

    float3 _Render_1  = lerp(_Color_1, _Color_2, smoothstep(0.0, 0.5, _Noise));
    float3 _Render_2 = lerp(_Render_1, _Color_3, smoothstep(0.5, 1.0, _Noise));

    return _Render_2;
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
        float4 _Result = _Color;

            _Result.rgb = Fun_NoiseGradient(_UV, _Color.rgb, _ColorShadow.rgb, _ColorLight.rgb);

                float _Noise = Fun_Noise(_UV * 8.0);     float _Sat = lerp(0.5, 2.5, _Noise);
                _Result.rgb = Fun_NoiseSat(_Result.rgb, _Sat);

                    float _Mask = _Render_Texture.a;

                    for (int i = 0; i < 8; i++)
                    {
                        _Mask += tex2D(S2D_Image, In + _OffsetEx[i] * float2(fPixelWidth, fPixelHeight) * (_Offset + sin(In + _Noise) * _OffsetDistortion)).a;
                        _Mask = saturate(_Mask);
                    }
                
                    _Result.a = _Mask;

                _Result.rgb = lerp(_Result.rgb, _Result.rgb + _Render_Background.rgb, _Mixing);
                float4 _Render = lerp(_Result, _Render_Texture, _Render_Texture.a * _Alpha);

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
