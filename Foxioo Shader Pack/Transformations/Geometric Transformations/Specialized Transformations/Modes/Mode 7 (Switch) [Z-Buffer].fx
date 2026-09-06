/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 2.0 (21.03.2026) */
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

/*
sampler2D S2D_Background : register(s1) = sampler_state 
{
    MinFilter = Point;
    MagFilter = Point;
    AddressU = Border;
    AddressV = Border;
    BorderColor = float4(0, 0, 1, 0);
};
*/

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _PosX, _PosY, _PosZ,

            _OffsetX,

            _ScaleX, _ScaleY, _Scale,

            _RotX, _RotY, _RotZ,
            _Distortion,

            _RotXPointX, _RotXPointY,
            _RotYPointX, _RotYPointY,

            _PosOffsetX, _PosOffsetY;

    int     _Looping_Mode;

    bool    _Render_Sky; //_Blending_Mode;

    #define RAD 0.0174532925

    struct PS_OUTPUT
    {
        float4 Color : COLOR0;
        float Depth : DEPTH;
    };

/***********************************************************/
/* Mode 7 */
/***********************************************************/

float2 Fun_Mode7(float2 In)
{
        float2 _UV = In / (In.y * _Distortion - 0.5);

    return _UV * _PosZ;
}

float2 Fun_Rotation(float2 In, float2 _Pivot, float _Mul, float _Off, float _Rot, float _RotSub)
{
    float2 _UV = float2(In.x + _Pivot.x, In.y + _Pivot.y) * _Mul;

    float _Rot_Temp = (_Rot - _RotSub) * RAD;

        float _Sin, _Cos;
        sincos(_Rot_Temp, _Sin, _Cos);
    
        _UV = _Off + mul(float2x2(_Cos, _Sin, -_Sin, _Cos), _UV - _Off);

    return _UV;
}
/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main(float2 In: TEXCOORD)
{   
    PS_OUTPUT Out;

    In.texCoord = Fun_Rotation(In.texCoord, float2(_RotYPointX, _RotYPointY), 1.0, 0.5, _RotY, 180.0);

    /* _RotZ -> Y-axis offset of texCoords; Pseudo-3D (possibly true 3D in the future...? i NEED ps_3_0!!!!) */
    In.texCoord.y += _RotZ * RAD;
    In.texCoord.x += _OffsetX - 0.5;
    float2 _UV = Fun_Mode7(In.texCoord);

        _UV = Fun_Rotation(_UV, float2(_RotXPointX, _RotXPointY), 0.5, 0.0, _RotX, 0.0);
        float2 _UVPos = _UV;

         _UV += float2(_PosOffsetX, -_PosOffsetY + 0.5);
        _UV *= float2(_ScaleX, _ScaleY) * _Scale;
       _UV += float2(_PosX, -_PosY) + float2(0.5, 0.5);

            float2 _UV_REPEAT = frac(_UV);
            float2 _UV_MIRROR = abs(frac(_UV / 2.0) * 2.0 - 1.0);
            float2 _UV_CLAMP  = clamp(_UV, 0.0, 0.999);

                float _1 = step(0.5, _Looping_Mode); /* It's Looping Mode >= 1? */
                float _2 = step(1.5, _Looping_Mode); /* It's Looping Mode >= 2? */
                float _3 = step(2.5, _Looping_Mode); /* It's Looping Mode >= 3? */

                _UV = lerp(
                            _UV_REPEAT,         /* IF _Looping_Mode <= 0;   Return REPEAT! */
                            lerp(_UV_MIRROR,    /* IF _Looping_Mode == 1;   Return MIRROR! */
                            lerp(_UV_CLAMP,     /* IF _Looping_Mode == 2;   Return CLAMP!  */
                            _UV,                /* ELSE;                    Return BORDER! */
                        _3), _2), _1);

        float4 _Render_Texture = tex2D(S2D_Image, _UV);
        //float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

 float4 _Render = _Render_Texture;
 //float4 _Render = _Render_Texture + _Render_Background / 128.0;
        
        float _Depth =  saturate(sqrt(_UVPos.x * _UVPos.x + _UVPos.y * _UVPos.y) / 65536.0);

        _Render *= lerp(abs(step(0.0, _PosZ) - step(0.5, In.texCoord.y * _Distortion)), 1.0, _Render_Sky);
        if(abs(step(0.0, _PosZ) - step(0.5, In.texCoord.y * _Distortion)) && !_Render_Sky) _Depth = 1.0;

    Out.Depth = 1.0 - _Depth * _Render.a;
    Out.Color = _Render;
    

    return Out;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
