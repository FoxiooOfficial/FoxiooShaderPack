/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.9 (08.11.2025) */
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
    float _PosZ;
    bool ___;
    float _RotX;
    float _RotY;
    float _RotZ;
    bool ____;
    float _RotXPointX;
    float _RotXPointY;
    float _RotYPointX;
    float _RotYPointY;
    bool _____;
    float _OffsetX;
    float _Distortion;
    bool ______;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    float _PosOffsetX;
    float _PosOffsetY;
    bool _______;
    int _Looping_Mode;
    bool _Render_Sky;
    bool _Blending_Mode;
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
    float4 Color : SV_Target;
};

#define RAD 0.0174532925

/***********************************************************/
/* Mode 7 */
/***********************************************************/

float2 Fun_Mode7(float2 In)
{
    float2 _UV = In;

        _UV.x += _OffsetX - 0.5;
        _UV /= (In.y * _Distortion) - 0.5;

    return _UV * _PosZ;
}

float2 Fun_RotationX(float2 In)
{
    float2 _UV = float2(In.x + _RotXPointX, In.y + _RotXPointY) * 0.5;

    float _RotX_Temp = _RotX * RAD;

        _UV = mul(float2x2(cos(_RotX_Temp), sin(_RotX_Temp), -sin(_RotX_Temp), cos(_RotX_Temp)), _UV);

    return _UV;

}

float2 Fun_RotationY(float2 In)
{
    float2 _UV = float2(In.x + _RotYPointX, In.y + _RotYPointY);

    float _RotY_Temp = (_RotY - 180.0) * RAD;

    _UV = 0.5 + mul(float2x2(cos(_RotY_Temp), sin(_RotY_Temp), -sin(_RotY_Temp), cos(_RotY_Temp)), _UV - 0.5);

    return _UV;
}

float Fun_Loop(float _UV, int _Mode)
{
    switch(_Mode)
    {
        case 0:
            return frac(_UV);
            
        case 1:
            return abs(frac(_UV / 2.0) * 2.0 - 1.0);
            
        case 2:
            return clamp(_UV, 0.0, 1.0);
            
        default:
            return _UV;
    }
}

bool Fun_CheckEdge(float _UV, int _Mode) { return (_Mode == 3 && (_UV < 0.0 || _UV > 1.0)); }

void Fun_SetLoop(int _Looping, out int2 _Mode)
{
    switch(_Looping)
    {
        case 0:  _Mode = int2(0, 0); break;
        case 1:  _Mode = int2(1, 1); break;
        case 2:  _Mode = int2(2, 2); break;
        case 3:  _Mode = int2(3, 3); break;

        case 4:  _Mode = int2(1, 0); break;
        case 5:  _Mode = int2(2, 0); break;
        case 6:  _Mode = int2(3, 0); break;

        case 7:  _Mode = int2(0, 1); break;
        case 8:  _Mode = int2(2, 1); break;
        case 9:  _Mode = int2(3, 1); break;

        case 10: _Mode = int2(0, 2); break;
        case 11: _Mode = int2(1, 2); break;
        case 12: _Mode = int2(3, 2); break;

        case 13: _Mode = int2(0, 3); break;
        case 14: _Mode = int2(1, 3); break;
        case 15: _Mode = int2(2, 3); break;

        default: _Mode = int2(2, 2); break;
    }
}

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main(PS_INPUT In)
{
    PS_OUTPUT Out;

    float2 _In = In.texCoord;
    _In = Fun_RotationY(_In);

    float _RotZ_Temp = _RotZ * RAD;

        float2 _In_Old = _In;
        _In.y += _RotZ_Temp;

        float2 _UV = Fun_Mode7(_In);
        float2 _Pos = float2(-_PosX, _PosY);
        float2 _PosOffset = float2(-_PosOffsetX, _PosOffsetY - 0.5);
        float2 _Scale_Temp = (float2(_ScaleX, _ScaleY)) * _Scale;

        _UV = Fun_RotationX(_UV);
        _UV -= _PosOffset;
        _UV *= _Scale_Temp;
        _UV -= _Pos - 0.5;

            int2 _Mode;
            float2 _In_Orginal = _UV;
            Fun_SetLoop(_Looping_Mode, _Mode);

                _UV = float2(
                    Fun_Loop(_UV.x, _Mode.x),
                    Fun_Loop(_UV.y, _Mode.y)
                );

    /* Rendering */
    float4 _Render;
    if(!_Blending_Mode) { _Render = S2D_Image.Sample(S2D_ImageSampler, _UV); }
    else { _Render = S2D_Background.Sample(S2D_BackgroundSampler, _UV); _Render.a = S2D_Image.Sample(S2D_ImageSampler, In.texCoord).a;}

        if(Fun_CheckEdge(_In_Orginal.x, _Mode.x) || Fun_CheckEdge(_In_Orginal.y, _Mode.y))      {   _Render = 0.0;    }
        if(((_In_Old.y + _RotZ_Temp) * _Distortion) > 0.5 && !_Render_Sky)                      {   _Render = 0.0;    }

    _Render *= In.Tint;

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

    float2 _In = In.texCoord;
    _In = Fun_RotationY(_In);

    float _RotZ_Temp = _RotZ * RAD;

        float2 _In_Old = _In;
        _In.y += _RotZ_Temp;

        float2 _UV = Fun_Mode7(_In);
        float2 _Pos = float2(-_PosX, _PosY);
        float2 _PosOffset = float2(-_PosOffsetX, _PosOffsetY - 0.5);
        float2 _Scale_Temp = (float2(_ScaleX, _ScaleY)) * _Scale;

        _UV = Fun_RotationX(_UV);
        _UV -= _PosOffset;
        _UV *= _Scale_Temp;
        _UV -= _Pos - 0.5;

            int2 _Mode;
            float2 _In_Orginal = _UV;
            Fun_SetLoop(_Looping_Mode, _Mode);

                _UV = float2(
                    Fun_Loop(_UV.x, _Mode.x),
                    Fun_Loop(_UV.y, _Mode.y)
                );

    /* Rendering */
    float4 _Render;
    if(!_Blending_Mode) { _Render = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _UV)); }
    else { _Render = S2D_Background.Sample(S2D_BackgroundSampler, _UV); _Render.a = S2D_Image.Sample(S2D_ImageSampler, In.texCoord).a;}

        if(Fun_CheckEdge(_In_Orginal.x, _Mode.x) || Fun_CheckEdge(_In_Orginal.y, _Mode.y))      {   _Render = 0.0;    }
        if(((_In_Old.y + _RotZ_Temp) * _Distortion) > 0.5 && !_Render_Sky)                      {   _Render = 0.0;    }

    _Render *= In.Tint;

    _Render.rgb *= _Render.a;
    Out.Color = _Render;

    return Out;
}