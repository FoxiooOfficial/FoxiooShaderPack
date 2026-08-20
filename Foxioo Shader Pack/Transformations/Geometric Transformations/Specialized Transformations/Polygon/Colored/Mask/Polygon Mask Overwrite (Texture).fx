/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (05.04.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;

    AddressU = Border;
    AddressV = Border;

    BorderColor = float4(0.0, 0.0, 1.0, 0.0);
};

/***********************************************************/
/* Variables */
/***********************************************************/

struct VS_INPUT
{
    float4 Pos          : POSITION;
    float2 Coord        : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 Pos          : POSITION;
    float2 Coord        : TEXCOORD0;

    float3 Polygon      : TEXCOORD1;
    float  WReflected   : TEXCOORD2; 
};

    float   xA, yA,
            xB, yB,
            xC, yC,
            xD, yD,

            _Width, _Height,
            _Error,

            _PosX, _PosY,
            
            _Scale,
            _ScaleX, _ScaleY;

    int     _A, _B, _C, _D;

/************************************************************/
/* Main Vertex */
/************************************************************/

float4x4 Fun_OrthoMatrix(float _Left, float _Right, float _Bottom, float _Top, float _Near, float _Far)
{
    return float4x4(
        float4(2.0 / (_Right - _Left), 0.0, 0.0, 0.0),
        float4(0.0, 2.0 / (_Top - _Bottom), 0.0, 0.0),
        float4(0.0, 0.0, 1.0 / (_Far - _Near), 0.0),
        float4((_Left + _Right) / (_Left - _Right), (_Top + _Bottom) / (_Bottom - _Top), _Near / (_Near - _Far), 1.0)
    );
}

float4x4 Fun_OrthoMatrix_Center(float2 _Pos, float2 _Res, float2 _Z)
{
    return Fun_OrthoMatrix(
        _Pos.x - _Res.x * 0.5, _Pos.x + _Res.x * 0.5,
        _Pos.y + _Res.y * 0.5, _Pos.y - _Res.y * 0.5,
        _Z.x, _Z.y
    );
}

VS_OUTPUT vs_main(const VS_INPUT In)
{
    VS_OUTPUT Out;

    /* vertex setup */
    float4 _Offset = float4(In.Coord.x, In.Coord.y, 0.0, 0.0);
    float2 _Resolution = float2(_Width, _Height);

    float4x4 _Proj = Fun_OrthoMatrix_Center(_Resolution / 2.0, _Resolution, float2(-1.0, 1.0));
    Out.Pos = mul(In.Pos - _Offset, _Proj);

    Out.Coord = In.Coord;

    /* polygon */
    float a11 = xC - xB;
    float a12 = xC - xD;
    float b1  = xB + xD - xA - xC;

    float a21 = yC - yB;
    float a22 = yC - yD;
    float b2  = yB + yD - yA - yC;

    float _Denom = a11 * a22 - a12 * a21;

    if (abs(_Denom) < _Error)
    {
        Out.Polygon = float3(0.0, 0.0, 0.0);
        Out.WReflected = 0.0;
        return Out;
    }
    else
    {
        float H20 = (b1 * a22 - a12 * b2) / _Denom;
        float H21 = (a11 * b2 - b1 * a21) / _Denom;

        float H00 = xB * (H20 + 1.0) - xA;
        float H10 = yB * (H20 + 1.0) - yA;
        float H01 = xD * (H21 + 1.0) - xA;
        float H11 = yD * (H21 + 1.0) - yA;

        float DET_H = H00 * (H11 - yA * H21) -
                    H01 * (H10 - yA * H20) +
                    xA  * (H10 * H21 - H11 * H20);

        if (abs(DET_H) < _Error)
        {
            Out.Polygon = float3(0.0, 0.0, 0.0);
            Out.WReflected = 0.0;
            return Out;
        }
        else
        {
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

            float _U = C00 * In.Coord.x + C10 * In.Coord.y + C20;
            float _V = C01 * In.Coord.x + C11 * In.Coord.y + C21;
            float _W = C02 * In.Coord.x + C12 * In.Coord.y + C22;

            Out.Polygon = float3(_U, _V, _W);

            float _WReflected = 0.0;
            if (_A == 1)        _WReflected = C02 * xA + C12 * yA + C22;
            else if (_B == 1)   _WReflected = C02 * xB + C12 * yB + C22;
            else if (_C == 1)   _WReflected = C02 * xC + C12 * yC + C22;
            else if (_D == 1)   _WReflected = C02 * xD + C12 * yD + C22;
            else                _WReflected = C02 * xA + C12 * yA + C22;

            if (abs(_WReflected) < 1e-4)
            {
                float wB = C02 * xB + C12 * yB + C22;
                float wC = C02 * xC + C12 * yC + C22;
                float wD = C02 * xD + C12 * yD + C22;

                if      (abs(wB) > 1e-4)    _WReflected = wB;
                else if (abs(wC) > 1e-4)    _WReflected = wC;
                else if (abs(wD) > 1e-4)    _WReflected = wD;
                else                        _WReflected = 1.0;
            }

            Out.WReflected = _WReflected;

            return Out;
        }
    }
}

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float3 Polygon : TEXCOORD1, in float  WReflected : TEXCOORD2) : COLOR0
{  
    /* polygon checks */
    if (isnan(Polygon.z) || isnan(WReflected))                      clip(-1);
    if (abs(Polygon.z) <= 1e-4)                                     clip(-1);
    if (Polygon.z * WReflected <= 0)                                clip(-1);

    float2 _UV = float2(Polygon.x, Polygon.y) / Polygon.z;

    if (any(_UV < 0.0 || _UV > 1.0))                                clip(-1);

    /* pixel shader */
        float4 _Render_Texture = tex2D(S2D_Image, frac(In * _Scale * float2(_ScaleX, _ScaleY) + float2(_PosX, _PosY)));
        _Render_Texture.a = 1.0;

    return _Render_Texture;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main
{
    pass P0
    {
        PixelShader = compile ps_2_0 ps_main();
        VertexShader = compile vs_1_1 vs_main();
    }
}