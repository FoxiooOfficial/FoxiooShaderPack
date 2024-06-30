/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (30.06.2024) */
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
    bool _X;
    bool _Y;
    bool ___;
    float _PosX;
    float _PosY;
    bool ____;
    float _AmplitudeX;
    float _AmplitudeY;
    bool _____;
    float _FraqX;
    float _FraqY;
    bool ______;
    float _PeriodsX;
    float _PeriodsY;
    bool _______;
    bool _Blending_Mode;
    float _Mixing;
    bool ________;
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

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main( in PS_INPUT In )
{ 
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;

    float2 UV = In.texCoord;
    if(_X == true) { UV.x = In.texCoord.x + ( _AmplitudeX * sin(((In.texCoord.y *_PeriodsX) + _PosX) * _FraqX)); } else { In.texCoord.x; }
    if(_Y == true) { UV.y = In.texCoord.y + ( _AmplitudeY * sin(((In.texCoord.x *_PeriodsY) + _PosY) * _FraqY)); } else { In.texCoord.y; }

    float4 _Render = 0;

    if(_Blending_Mode == 1)
    {   
        _Render = S2D_Image.Sample(S2D_ImageSampler, UV) * In.Tint;
    }
    else
    {   
        _Render = S2D_Background.Sample(S2D_BackgroundSampler, UV) * In.Tint;
        _Render.a *= _Render_Texture.a;
    }

    Out.Color = _Render * _Mixing;
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _color)
{
	float4 color = _color;
	if ( color.a != 0 )
		color.rgb /= color.a;
	return color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;

    float2 UV = In.texCoord;
    if(_X == true) { UV.x = In.texCoord.x + ( _AmplitudeX * sin(((In.texCoord.y *_PeriodsX) + _PosX) * _FraqX)); } else { In.texCoord.x; }
    if(_Y == true) { UV.y = In.texCoord.y + ( _AmplitudeY * sin(((In.texCoord.x *_PeriodsY) + _PosY) * _FraqY)); } else { In.texCoord.y; }

    float4 _Render = 0;

    if(_Blending_Mode == 1)
    {   
        _Render = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV)) * In.Tint;
    }
    else
    {   
        _Render = S2D_Background.Sample(S2D_BackgroundSampler, UV) * In.Tint;
        _Render.a *= _Render_Texture.a;
    }

    _Render.rgb *= _Mixing * _Render.a;

    Out.Color = _Render;
    return Out;  
}