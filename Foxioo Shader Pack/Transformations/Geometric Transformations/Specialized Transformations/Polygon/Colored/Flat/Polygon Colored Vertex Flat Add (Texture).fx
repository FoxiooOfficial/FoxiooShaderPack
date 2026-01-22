/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (16.01.2026) */
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
    BorderColor = float4(0, 0, 1, 0);
};

/***********************************************************/
/* Variables */
/***********************************************************/

    float   xA, yA,
            xB, yB,
            xC, yC,
            xD, yD;

    int     _A,
            _B,
            _C,
            _D;
    
    float4  _ColorA,
            _ColorC;

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_Polygon(float2 UV)
{
    float a11 = xC - xB;
    float a12 = xC - xD;
    float b1  = xB + xD - xA - xC;

    float a21 = yC - yB;
    float a22 = yC - yD;
    float b2  = yB + yD - yA - yC;

    float _Denom = a11 * a22 - a12 * a21;

    //if (abs(_Denom) < 1e-4)
        //return float4(0, 0, 1, -1);
    //else
    //{
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

            return float4(_U, _V, _W, _WReflected);
    //}
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{  
    float4 _Polygon = Fun_Polygon(In);

        // if (_Polygon.z != _Polygon.z || _Polygon.w != _Polygon.w)       clip(-1);
        // if (abs(_Polygon.z) <= 1e-4)                                    clip(-1);
        // if (_Polygon.z * _Polygon.w <= 0)                               clip(-1);

        float2 _UV = float2(_Polygon.x, _Polygon.y) / _Polygon.z;

        //if (_UV.x < 0.0 || _UV.x > 1.0 || _UV.y < 0.0 || _UV.y > 1.0)   clip(-1);


        float4 _Render_Texture = tex2D(S2D_Image, _UV);
        _Render_Texture.rgb += _UV.x + _UV.y <= 1.0 ? _ColorA.rgb : _ColorC.rgb;
        
    return _Render_Texture;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } };