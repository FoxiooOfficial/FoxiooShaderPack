/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 2.0 (21.03.2026) */
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
    /* THE REAL, M O D E  7  E F F E C T (the best function :3) */

        /* Perspective */
        float2 _UV = In / (In.y * _Distortion - 0.5);

    return _UV * _PosZ;
}


float2 Fun_Rotation(float2 In, float2 _Pivot, float _Mul, float _Off, float _Rot, float _RotSub)
{
    float2 _UV = float2(In.x + _Pivot.x, In.y + _Pivot.y) * _Mul;

    float _Rot_Temp = (_Rot - _RotSub) * RAD;

        float _Sin, _Cos;
        /*  sincos(_Rot_Temp, _Sin, _Cos)?
            Theoretically more optimized than this:
                -> cos(_Rot_Temp);
                -> sin(_Rot_Temp);
        */
        sincos(_Rot_Temp, _Sin, _Cos);
    
        /*  It could be optimized, but since it's working fine RIGHT NOW,
            I'm not going to touch it; 

            +-->I might change it in future updates if it goes over the limit in ps_2_x AGAIN
            |       wait, this should be in TODO... ^^^ ah right...
            +-------(TODO:)
                    fixed.
        */
        _UV = _Off + mul(float2x2(_Cos, _Sin, -_Sin, _Cos), _UV - _Off);

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
    /* _RotY -> Rotation around the CENTER of the screen (camera viewpoint) */
    _In = Fun_Rotation(In.texCoord, float2(_RotYPointX, _RotYPointY), 1.0, 0.5, _RotY, 180.0);

    float _RotZ_Temp = _RotZ * RAD;

        float2 _In_Old = _In;
        /* _RotZ -> Y-axis offset of texCoords; */
        _In.y += _RotZ_Temp;
        _In.x += _OffsetX - 0.5; /* ALSO OFFSET IN X AXIS RAHHHHHHH */

    /* Set Mode 7 Distortion! -> Set perspective depth OR orthographic projection!!! */
    /* TODO: add option to change the POV */
    float2 _UV = Fun_Mode7(_In);

        /* _PosX -> Camera rotation AROUND ITSELF */
        _UV = Fun_Rotation(_UV, float2(_RotXPointX, _RotXPointY), 0.5, 0.0, _RotX, 0.0);

        /* "Translation"
            (why is it called that? :sob:) ugh, whatever, change of position... wait
            these are points for scale!!!??
            AHHH WHY AM I EVEN COMMENTING ON THIS
        */
        /* +X; -Y */
         _UV += float2(_PosOffsetX, -_PosOffsetY + 0.5);


        /* "Scale"
            Changing the scale of texCoords -> the closer to zero, the larger texture!
        */
        _UV *= float2(_ScaleX, _ScaleY) * _Scale;
        
        /* "Translation" (but for real)
            The actual change in the "camera" position!!!
        */
        /* +X; -Y */
       _UV += float2(_PosX, -_PosY) + float2(0.5, 0.5);

            /* "Looping Mode"
                Specifies how the texture should loop
            */
            int2 _Mode;
            float2 _In_Orginal = _UV;
            Fun_SetLoop(_Looping_Mode, _Mode);

                _UV = float2(
                    Fun_Loop(_UV.x, _Mode.x),
                    Fun_Loop(_UV.y, _Mode.y)
                );

            if(Fun_CheckEdge(_In_Orginal.x, _Mode.x) || Fun_CheckEdge(_In_Orginal.y, _Mode.y)) discard;
            /* HEL YEA */

    /* Rendering */
    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, _UV);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, _UV);

    float4 _Render = lerp(_Render_Texture, float4(_Render_Background.rgb, _Render_Texture.a), _Blending_Mode);

        /* REMOVE THE SKY WHEN *necessary*; 

        -> check if _PosZ is positive
        -> check if the ground render is greater than 0.5

            I tried using IF/ELSE, but main goal is to get this function working on D3D9 at all

            (i have to comment on this because the code is becoming less readable due to optimization :sob:)
        */
        _Render *= lerp(abs(step(0.0, _PosZ) - step(0.5, _In.y * _Distortion)), 1.0, _Render_Sky);

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
    /* _RotY -> Rotation around the CENTER of the screen (camera viewpoint) */
    _In = Fun_Rotation(In.texCoord, float2(_RotYPointX, _RotYPointY), 1.0, 0.5, _RotY, 180.0);

    float _RotZ_Temp = _RotZ * RAD;

        float2 _In_Old = _In;
        /* _RotZ -> Y-axis offset of texCoords; */
        _In.y += _RotZ_Temp;
        _In.x += _OffsetX - 0.5; /* ALSO OFFSET IN X AXIS RAHHHHHHH */

    /* Set Mode 7 Distortion! -> Set perspective depth OR orthographic projection!!! */
    /* TODO: add option to change the POV */
    float2 _UV = Fun_Mode7(_In);

        /* _PosX -> Camera rotation AROUND ITSELF */
        _UV = Fun_Rotation(_UV, float2(_RotXPointX, _RotXPointY), 0.5, 0.0, _RotX, 0.0);

        /* "Translation"
            (why is it called that? :sob:) ugh, whatever, change of position... wait
            these are points for scale!!!??
            AHHH WHY AM I EVEN COMMENTING ON THIS
        */
        /* +X; -Y */
         _UV += float2(_PosOffsetX, -_PosOffsetY + 0.5);


        /* "Scale"
            Changing the scale of texCoords -> the closer to zero, the larger texture!
        */
        _UV *= float2(_ScaleX, _ScaleY) * _Scale;
        
        /* "Translation" (but for real)
            The actual change in the "camera" position!!!
        */
        /* +X; -Y */
       _UV += float2(_PosX, -_PosY) + float2(0.5, 0.5);

            /* "Looping Mode"
                Specifies how the texture should loop
            */
            int2 _Mode;
            float2 _In_Orginal = _UV;
            Fun_SetLoop(_Looping_Mode, _Mode);

                _UV = float2(
                    Fun_Loop(_UV.x, _Mode.x),
                    Fun_Loop(_UV.y, _Mode.y)
                );

            if(Fun_CheckEdge(_In_Orginal.x, _Mode.x) || Fun_CheckEdge(_In_Orginal.y, _Mode.y)) discard;
            /* HEL YEA */

    /* Rendering */
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _UV));
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, _UV);

    float4 _Render = lerp(_Render_Texture, float4(_Render_Background.rgb, _Render_Texture.a), _Blending_Mode);

        /* REMOVE THE SKY WHEN *necessary*; 

        -> check if _PosZ is positive
        -> check if the ground render is greater than 0.5

            I tried using IF/ELSE, but main goal is to get this function working on D3D9 at all

            (i have to comment on this because the code is becoming less readable due to optimization :sob:)
        */
        _Render *= lerp(abs(step(0.0, _PosZ) - step(0.5, _In.y * _Distortion)), 1.0, _Render_Sky);

    _Render *= In.Tint;

    _Render.rgb *= _Render.a;
    Out.Color = _Render;

    return Out;
}