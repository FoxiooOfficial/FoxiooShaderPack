/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (16.01.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float4 _ColorA;
    float4 _ColorC;
    float _Width;
    float _Height;
    bool _A;
    float xA;
    float yA;
    bool _B;
    float xB;
    float yB;
    bool _C;
    float xC;
    float yC;
    bool _D;
    float xD;
    float yD;
    bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};


/************************************************************/
/* Main */
/************************************************************/

float4 Fun_Polygon(float2 UV)
{
    float2 _DistX = float2(min(min(xA, xB), min(xC, xD)), max(max(xA, xB), max(xC, xD)));
    float2 _DistY = float2(min(min(yA, yB), min(yC, yD)), max(max(yA, yB), max(yC, yD)));

    if ((_DistX.y - _DistX.x) < (_Width) ||
        (_DistY.y - _DistY.x) < (_Height))
        return float4(0.0, 0.0, 1.0, -1.0);

    float a11 = xC - xB;
    float a12 = xC - xD;
    float b1  = xB + xD - xA - xC;

    float a21 = yC - yB;
    float a22 = yC - yD;
    float b2  = yB + yD - yA - yC;

    float _Denom = a11 * a22 - a12 * a21;

    if (abs(_Denom) < 1e-4)
        return float4(0, 0, 1, 0);

    float H20 = (b1 * a22 - a12 * b2) / _Denom;
    float H21 = (a11 * b2 - b1 * a21) / _Denom;

    float H00 = xB * (H20 + 1.0) - xA;
    float H10 = yB * (H20 + 1.0) - yA;
    float H01 = xD * (H21 + 1.0) - xA;
    float H11 = yD * (H21 + 1.0) - yA;

    float DET_H =
        H00 * (H11 - yA * H21) -
        H01 * (H10 - yA * H20) +
        xA  * (H10 * H21 - H11 * H20);

    if (abs(DET_H) < 1e-4)
        return float4(0, 0, 1, 0);

    float INV_H = 1.0 / DET_H;

    float C00 = (H11 - yA * H21) * INV_H;
    float C01 = (yA * H20 - H10) * INV_H;
    float C02 = (H10 * H21 - H11 * H20) * INV_H;

    float C10 = (xA * H21 - H01) * INV_H;
    float C11 = (H00 - xA * H20) * INV_H;
    float C12 = (H01 * H20 - H00 * H21) * INV_H;

    float C20 = (H01 * yA - xA * H11) * INV_H;
    float C21 = (xA * H10 - H00 * yA) * INV_H;
    float C22 = (H00 * H11 - H01 * H10) * INV_H;

    float _U = C00 * UV.x + C10 * UV.y + C20;
    float _V = C01 * UV.x + C11 * UV.y + C21;
    float _W = C02 * UV.x + C12 * UV.y + C22;

    float _WReflected = 0.0;

    if (_A == 1)      _WReflected = C02 * xA + C12 * yA + C22;
    else if (_B == 1) _WReflected = C02 * xB + C12 * yB + C22;
    else if (_C == 1) _WReflected = C02 * xC + C12 * yC + C22;
    else if (_D == 1) _WReflected = C02 * xD + C12 * yD + C22;

    if (abs(_WReflected) < 1e-4)
        _WReflected = _W;

    return float4(_U, _V, _W, _WReflected);
}

PS_OUTPUT ps_main(in PS_INPUT In)
{
    PS_OUTPUT Out;

    float4 _Polygon = Fun_Polygon(In.texCoord);
    
        if (_Polygon.z != _Polygon.z || _Polygon.w != _Polygon.w)       clip(-1);
        if (abs(_Polygon.z) <= 1e-6)                                    clip(-1);
        if (_Polygon.z * _Polygon.w <= 0)                               clip(-1);

        float2 _UV = float2(_Polygon.x, _Polygon.y) / _Polygon.z;

        if (_UV.x < 0.0 || _UV.x > 1.0 || _UV.y < 0.0 || _UV.y > 1.0)   clip(-1);

    float4  _Render_Texture =  S2D_Image.Sample(S2D_ImageSampler, _UV) * In.Tint;
            _Render_Texture.rgb -= _UV.x + _UV.y <= 1.0 ? _ColorA.rgb : _ColorC.rgb;

    Out.Color = _Render_Texture;
    return Out;
}

/***********************************************************/
/* Premultiplied Alpha */
/***********************************************************/

float4 Demultiply(float4 _color)
{
    if (_color.a != 0)
        _color.rgb /= _color.a;
    return _color;
}

PS_OUTPUT ps_main_pm(in PS_INPUT In)
{
    PS_OUTPUT Out;

    float4 _Polygon = Fun_Polygon(In.texCoord);
    
        if (_Polygon.z != _Polygon.z || _Polygon.w != _Polygon.w)       clip(-1);
        if (abs(_Polygon.z) <= 1e-4)                                    clip(-1);
        if (_Polygon.z * _Polygon.w <= 0)                               clip(-1);

        float2 _UV = float2(_Polygon.x, _Polygon.y) / _Polygon.z;

        if (_UV.x < 0.0 || _UV.x > 1.0 || _UV.y < 0.0 || _UV.y > 1.0)   clip(-1);

    float4  _Render_Texture =  S2D_Image.Sample(S2D_ImageSampler, _UV) * In.Tint;
            _Render_Texture.rgb -= _UV.x + _UV.y <= 1.0 ? _ColorA.rgb : _ColorC.rgb;

        _Render_Texture = Demultiply(_Render_Texture);

    _Render_Texture.rgb *= _Render_Texture.a;

    Out.Color = _Render_Texture;
    return Out;
}
