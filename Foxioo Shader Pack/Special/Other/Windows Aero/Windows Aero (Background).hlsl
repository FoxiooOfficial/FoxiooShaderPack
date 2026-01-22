/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool __;
    float _PosX;
    float _PosY;
    bool ___;
    float _RotX;
    bool ____;
    float _PointX;
    float _PointY;
    bool ______;        
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool _______;
    float _Mixing;
    float _Intensity;
    bool ________;
	bool _Is_Pre_296_Build;
	bool _________;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

float Fun_Aero_Light(float2 In)
{   
    float _D = In.x - In.y;

        float _P1 = sin(_D * 0.75);
        float _P2 = sin(_D * 0.4 + 0.1);
        float _P3 = sin(_D * 0.65 + 0.2);
        float _P4 = sin(_D * 1.1 + 0.3);

    float _Light = 0.5 + 0.5 * ((_P1 + _P2 * 0.5 + _P3 * 0.25 - _P4 * 0.6) / 1.75);
    return _Light;
}

float3 Fun_Outline(float2 In, float3 _Color, float _Mul)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = S2D_Image.Sample(S2D_ImageSampler, In).a * _Mul;

    /* Outline DARK! */
    float aL1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x, 0)) .a * _Mul;
    float aR1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(_PX.x, 0))  .a * _Mul;
    float aU1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, -_PX.y)) .a * _Mul;
    float aD1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, _PX.y))  .a * _Mul;

    /* Outline LIGHT! */
    float aL2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x * 2, 0)) .a * _Mul;
    float aR2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(_PX.x * 2, 0))  .a * _Mul;
    float aU2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, -_PX.y * 2)) .a * _Mul;
    float aD2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, _PX.y * 2))  .a * _Mul;

    /* no outline. */
    float aL3 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x * 1, 0)) .a * _Mul;
    float aR3 = S2D_Image.Sample(S2D_ImageSampler, In + float2(_PX.x * 1, 0))  .a * _Mul;
    float aU3 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, -_PX.y * 1)) .a * _Mul;
    float aD3 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, _PX.y * 1))  .a * _Mul;

        float _EdgeDark  = step(0.01, abs(aL1 - _Alpha) + abs(aR1 - _Alpha) + abs(aU1 - _Alpha) + abs(aD1 - _Alpha));
        float _EdgeLight = step(0.01, abs(aL2 - _Alpha) + abs(aR2 - _Alpha) + abs(aU2 - _Alpha) + abs(aD2 - _Alpha));

    if (_EdgeDark > 0.5)        return - 0.5;
    else if (_EdgeLight > 0.5)  return 2.0;
    else return _Color;
}

float2 Fun_RotationX(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float _RotX_Fix = _RotX * (3.14159265 / 180);

        In = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), In - _Points);

    return In;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _UV = Fun_RotationX(float2((In.texCoord.x + _PosX) * _ScaleX, (In.texCoord.y + _PosY) * _ScaleY) * _Scale);

        float _In_Aero = Fun_Aero_Light((_UV * 0.05 / float2(fPixelWidth, fPixelHeight)));
        float3 _Result = _Render_Texture.rgb * ((abs(In.texCoord.x - 0.5) * (1.0 - (In.texCoord.y - 0.2))) + _In_Aero) * _Intensity;


        float3 _Outline = Fun_Outline(In.texCoord, _Result, In.Tint.a);
        float4 _Render_Tint = lerp(_Render_Background, _Render_Texture, 0.5);

    float4 _Render = float4(lerp(_Render_Texture.rgb, _Render_Tint.rgb + _Outline.rgb * 0.25, _Mixing), _Render_Texture.a);

    Out.Color = _Render;
    
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _UV = Fun_RotationX(float2((In.texCoord.x + _PosX) * _ScaleX, (In.texCoord.y + _PosY) * _ScaleY) * _Scale);

        float _In_Aero = Fun_Aero_Light((_UV * 0.05 / float2(fPixelWidth, fPixelHeight)));
        float3 _Result = _Render_Texture.rgb * ((abs(In.texCoord.x - 0.5) * (1.0 - (In.texCoord.y - 0.2))) + _In_Aero) * _Intensity;


        float3 _Outline = Fun_Outline(In.texCoord, _Result, In.Tint.a);
        float4 _Render_Tint = lerp(_Render_Background, _Render_Texture, 0.5);

    float4 _Render = float4(lerp(_Render_Texture.rgb, _Render_Tint.rgb + _Outline.rgb * 0.25, _Mixing), _Render_Texture.a);

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}