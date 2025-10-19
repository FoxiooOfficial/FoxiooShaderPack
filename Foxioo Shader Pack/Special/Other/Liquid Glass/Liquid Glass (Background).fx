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
/* Variables */
/***********************************************************/

    float   _Mixing,
            _Distortion,
            _Intensity,

            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Liquid(float2 In, float _Size)
{
    float2 _Dist = min(In, 1.0 - In);
    float _DistMin = min(_Dist.x, _Dist.y);

        return 1.0 - smoothstep(0.0, _Size, _DistMin);
}

float3 Fun_Outline(float2 In, float3 _Color)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = tex2D(S2D_Image, In).a;

    /* Outline DARK! */
    float aL1 = tex2D(S2D_Image, In + float2(-_PX.x, 0)) .a;
    float aR1 = tex2D(S2D_Image, In + float2(_PX.x, 0))  .a;
    float aU1 = tex2D(S2D_Image, In + float2(0, -_PX.y)) .a;
    float aD1 = tex2D(S2D_Image, In + float2(0, _PX.y))  .a;

    /* Outline LIGHT! */
    float aL2 = tex2D(S2D_Image, In + float2(-_PX.x * 2, 0)) .a;
    float aR2 = tex2D(S2D_Image, In + float2(_PX.x * 2, 0))  .a;
    float aU2 = tex2D(S2D_Image, In + float2(0, -_PX.y * 2)) .a;
    float aD2 = tex2D(S2D_Image, In + float2(0, _PX.y * 2))  .a;

    /* no outline. */
    float aL3 = tex2D(S2D_Image, In + float2(-_PX.x * 1, 0)) .a;
    float aR3 = tex2D(S2D_Image, In + float2(_PX.x * 1, 0))  .a;
    float aU3 = tex2D(S2D_Image, In + float2(0, -_PX.y * 1)) .a;
    float aD3 = tex2D(S2D_Image, In + float2(0, _PX.y * 1))  .a;

        float _EdgeDark  = step(0.01, abs(aL1 - _Alpha) + abs(aR1 - _Alpha) + abs(aU1 - _Alpha) + abs(aD1 - _Alpha));
        float _EdgeLight = step(0.01, abs(aL2 - _Alpha) + abs(aR2 - _Alpha) + abs(aU2 - _Alpha) + abs(aD2 - _Alpha));

    if      (_EdgeDark > 0.5)   return _Color * 0.48;
    else if (_EdgeLight > 0.5)  return _Color * 5.56;
    else return lerp(_Color, float3(1.0, 1.0, 1.0), 0.269);
}

float2 Fun_Hash21(float2 _Pos) 
{ 
    float2 _Noise;
    _Noise.x = frac(sin(dot(_Pos, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
    _Noise.y = frac(sin(dot(_Pos, float2(63.7264, 10.873))) * 73156.8473) - 0.5;
    return _Noise;
}

float2 Fun_Noise(float2 _Pos) 
{
    float2 _Noise = Fun_Hash21(_Pos);

    return _Noise;
}

float4 Main(float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    //float4 _OutlineInter = tex2D(S2D_Background, Fun_Liquid(In, 1).rg);

    float2 _Mask = float2(  Fun_Liquid((In.x, In.x) * _Render_Texture.a, _Intensity * fPixelWidth),
                            Fun_Liquid((In.y, In.y) * _Render_Texture.a, _Intensity * fPixelHeight));


    float2 _UVB = frac(In * 0.5) * 2.0;
    float2 _UVM = abs(_UVB - 1.0);

    float2 _UV = lerp(_UVB, _UVM, _Mask * _Mask * _Distortion);


        float4 _Render_Background = 0;
        for(int i = 0; i < 36; i++) {
            float _Mul = (i % 2) ? 1 : -1;
            _Render_Background += tex2D(S2D_Background, _UV + Fun_Noise(In) * (5 + i) * _Mul * float2(fPixelWidth, fPixelHeight));
        }
        _Render_Background /= 36;

        float3 _Outline = Fun_Outline(In, _Render_Background.rgb);
        float4 _Render_Tint = lerp(_Render_Background, _Render_Texture, 0.5);

    float4 _Render = float4(lerp(_Render_Texture.rgb, (_Render_Tint.rgb * 0.75 + _Outline.rgb * 0.25) * 0.9, _Mixing), _Render_Texture.a);

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
