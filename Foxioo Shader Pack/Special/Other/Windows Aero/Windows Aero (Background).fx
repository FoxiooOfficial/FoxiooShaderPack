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
            _PosX, _PosY,
            _PointX, _PointY,
            _RotX,
            _ScaleX, _ScaleY, _Scale,
            
            _Intensity,

            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

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

float4 Main(float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float2 _UV = Fun_RotationX(float2((In.x + _PosX) * _ScaleX, (In.y + _PosY) * _ScaleY) * _Scale);

        float _In_Aero = Fun_Aero_Light((_UV * 0.05 / float2(fPixelWidth, fPixelHeight)));
        float3 _Result = _Render_Texture * ((abs(In.x - 0.5) * (1.0 - (In.y - 0.2))) + _In_Aero) * _Intensity;


        float3 _Outline = Fun_Outline(In, _Result);
        float4 _Render_Tint = lerp(_Render_Background, _Render_Texture, 0.5);

    float4 _Render = float4(lerp(_Render_Texture.rgb, _Render_Tint.rgb + _Outline.rgb * 0.25, _Mixing), _Render_Texture.a);

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
