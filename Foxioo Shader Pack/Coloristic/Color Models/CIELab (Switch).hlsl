/***********************************************************/

/* Autor shader: Foxioo */
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
    bool _Blending_Mode;
    float _Mixing;
    float _Luminance;
    float _A;
    float _B;
    bool __;

	bool _Is_Pre_296_Build;
	bool ___;
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

static const float D65_X0 = 0.95047;
static const float D65_Y0 = 1.0;
static const float D65_Z0 = 1.08883;

static const float _Threshold_1 = 0.04045;
static const float _Threshold_2 = 0.008856;
static const float _Threshold_3 = 0.2068966;

static const float _LinearScale_1 = 1.0 / 12.92;
static const float _LinearScale_2 = 1.0 / 1.055;
static const float _LinearScale_3 = 1.0 / 7.787;
static const float _LinearScale_4 = 16.0 / 116.0;

float3 RGBtoLab(float3 _Render)
{
    float3 _RGB = _Render;
    _RGB = (_RGB <= _Threshold_1) ? 
        _RGB * _LinearScale_1 : 
        pow(abs((_RGB + 0.055) * _LinearScale_2), 2.4);

    float3 XYZ;
    XYZ.x = dot(_RGB, float3(0.4124, 0.3576, 0.1805));
    XYZ.y = dot(_RGB, float3(0.2126, 0.7152, 0.0722));
    XYZ.z = dot(_RGB, float3(0.0193, 0.1192, 0.9505));

    XYZ.x /= D65_X0;
    XYZ.y /= D65_Y0;
    XYZ.z /= D65_Z0;

    float FX = (XYZ.x > _Threshold_2) ? pow(abs(XYZ.x), 1.0/3.0) : (7.787 * XYZ.x + _LinearScale_4);
    float FY = (XYZ.y > _Threshold_2) ? pow(abs(XYZ.y), 1.0/3.0) : (7.787 * XYZ.y + _LinearScale_4);
    float FZ = (XYZ.z > _Threshold_2) ? pow(abs(XYZ.z), 1.0/3.0) : (7.787 * XYZ.z + _LinearScale_4);

    float L = 116.0 * FY - 16.0;
    float a = 500.0 * (FX - FY);
    float b = 200.0 * (FY - FZ);

    return float3(L, a, b);
}

float3 LabtoRGB(float3 _LAB)
{
    float FY = (_LAB.x + 16.0) / 116.0;
    float FX = _LAB.y / 500.0 + FY;
    float FZ = FY - _LAB.z / 200.0;

    float X = (FX > _Threshold_3) ? FX*FX*FX : (FX - _LinearScale_4) * _LinearScale_3;
    float Y = (FY > _Threshold_3) ? FY*FY*FY : (FY - _LinearScale_4) * _LinearScale_3;
    float Z = (FZ > _Threshold_3) ? FZ*FZ*FZ : (FZ - _LinearScale_4) * _LinearScale_3;

    X *= D65_X0;
    Y *= D65_Y0;
    Z *= D65_Z0;

    float3 _Render;
    _Render.r = dot(float3(X, Y, Z), float3(3.2406, -1.5372, -0.4986));
    _Render.g = dot(float3(X, Y, Z), float3(-0.9689, 1.8758, 0.0415));
    _Render.b = dot(float3(X, Y, Z), float3(0.0557, -0.2040, 1.0570));

    _Render = max(0, _Render);
    float3 _Color = (_Render <= 0.0031308) ? 
        12.92 * _Render : 
        1.055 * pow(_Render, 1.0/2.4) - 0.055;

    return _Color;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result =    _Render;

        float3 Lab = RGBtoLab(_Render.rgb);
        
    /* Luminance Adjustment */
        Lab.x = (Lab.x + (_Luminance - 50.0) * 2.0);

    /* A Adjustment */
        Lab.y += (_A - 50.0) * 2.0;

    /* B Adjustment */
        Lab.z += (_B - 50.0) * 2.0;

        _Render.rgb = LabtoRGB(Lab);

    /* Mixing */
        _Render.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
    
    _Render.a = _Render_Texture.a;
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result =    _Render;

        float3 Lab = RGBtoLab(_Render.rgb);
        
    /* Luminance Adjustment */
        Lab.x = (Lab.x + (_Luminance - 50.0) * 2.0);

    /* A Adjustment */
        Lab.y += (_A - 50.0) * 2.0;

    /* B Adjustment */
        Lab.z += (_B - 50.0) * 2.0;

        _Render.rgb = LabtoRGB(Lab);

    /* Mixing */
        _Render.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);;
    
    _Render.a = _Render_Texture.a;
    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}