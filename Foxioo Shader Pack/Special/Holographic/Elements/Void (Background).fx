/***********************************************************/

/* Shader author: Foxioo */
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

    float   _Mixing, _Border,

            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Lum (float4 _Result) { return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b) * _Result.a; }

float Fun_OuterOutline(float2 In)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = tex2D(S2D_Image, In).a;

    float aL = tex2D(S2D_Image, In + float2(-_PX.x * _Border, 0.0)).a;
    float aR = tex2D(S2D_Image, In + float2( _PX.x * _Border, 0.0)).a;
    float aU = tex2D(S2D_Image, In + float2(0.0, -_PX.y * _Border)).a;
    float aD = tex2D(S2D_Image, In + float2(0.0,  _PX.y * _Border)).a;


    return step(0.01, aL + aR + aU + aD) * (1.0 - _Alpha) * ( (aL + aR + aU + aD));
}

float3 Fun_Outline(float2 In, float3 _Color)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = tex2D(S2D_Image, In).a;

    float aL1 = tex2D(S2D_Image, In + float2(-_PX.x * _Border, 0.0)).a;
    float aR1 = tex2D(S2D_Image, In + float2( _PX.x * _Border, 0.0)).a;
    float aU1 = tex2D(S2D_Image, In + float2(0.0, -_PX.y * _Border)).a;
    float aD1 = tex2D(S2D_Image, In + float2(0.0,  _PX.y * _Border)).a;

    float aL2 = tex2D(S2D_Image, In + float2(-_PX.x * 2.0 * _Border, 0.0)).a;
    float aR2 = tex2D(S2D_Image, In + float2( _PX.x * 2.0 * _Border, 0.0)).a;
    float aU2 = tex2D(S2D_Image, In + float2(0.0, -_PX.y * 2.0 * _Border)).a;
    float aD2 = tex2D(S2D_Image, In + float2(0.0,  _PX.y * 2.0 * _Border)).a;

        float _Edge1  = step(0.01, abs(aL1 - _Alpha) + abs(aR1 - _Alpha) + abs(aU1 - _Alpha) + abs(aD1 - _Alpha));
        float _Edge2 = step(0.01, abs(aL2 - _Alpha) + abs(aR2 - _Alpha) + abs(aU2 - _Alpha) + abs(aD2 - _Alpha));

    return lerp(_Color * 0.5, float3(1.0, 1.0, 1.0), _Edge1 * _Alpha) + _Edge2 * 0.25;
}

float Fun_Random(float2 In)
{
    return frac(sin(dot(In, float2(12.9898, 78.233))) * 43758.5453);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    In = frac(In);

    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Background = tex2D(S2D_Background, In);
        
        float _Rand = Fun_Random(In + _Render_Texture.rb + _Render_Texture.bg + _Render_Background.rg + _Render_Background.br);

        float _Lum = Fun_Lum(_Render_Texture);
        float _Lum_Background = Fun_Lum(_Render_Background);

        float3 _Space = lerp(float3(0.0, 0.0, 0.0), float3(0.15, 0.05, 0.25), _Lum);
        _Space += (_Space * (tex2D(S2D_Background, In + tan(_Lum) * _Lum * 0.25 - tan(_Lum_Background) * 0.25 - _Rand).rgb) * 1.5);
        _Space *= 0.5;

            float _Render_Background_Void_R = tex2D(S2D_Background, In + (_Render_Background.r * (1.0 - _Render_Texture.r) + _Rand) * 0.1).r;
            float _Render_Background_Void_G = tex2D(S2D_Background, In + (_Render_Background.g * (1.0 - _Render_Texture.g) + _Rand) * 0.1).b;
            float _Render_Background_Void_B = tex2D(S2D_Background, In + (_Render_Background.b * (1.0 - _Render_Texture.b) + _Rand) * 0.1).b;

            _Space = lerp(_Space, _Space + float3(_Render_Background_Void_R, _Render_Background_Void_G, _Render_Background_Void_B) * float3(0.15, 0.05, 0.25), 1.0 - _Lum);


        float4 _Result = _Render_Texture;
        _Result.rgb = lerp(_Render_Texture.rgb, _Space + pow(Fun_Random(In + _Space.rb + _Space.bg + _Render_Background.rg + _Render_Background.br + _Rand), 255.0), _Mixing);
        _Result.rgb += (Fun_Outline(In, _Space) + pow(_Lum, 6.0)) * saturate(_Mixing);

        float3 _Cosmos = pow(Fun_Random(In), 128.0) * 0.5;
        _Result = lerp(float4(_Cosmos.rgb, 1.0), _Result, 1.0 - pow(Fun_OuterOutline(In), 4.0));

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
