/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0)  = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = Point;
    AddressU = Wrap;
    AddressV = Wrap;
};

sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _PosX, _PosY,
            _PointX, _PointY,
            _ScaleX, _ScaleY, _Scale,
            _Mixing,
            
            _DistortionXCenter, _DistortionXEdge, _DistortionXRadius, _DistortionXExponent,
            _DistortionYOffset, _DistortionYOffsetFactor, _DistortionYPow;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Jevil(float In)
{
    float _UV = In - _PosX * _ScaleX * _Scale;

    float _Distance = abs(_UV - 0.5);
        float _Size = saturate(_Distance / _DistortionXRadius);
        float _Smooth = pow(_Size, _DistortionXExponent);

    float _Scaler = lerp(_DistortionXCenter, _DistortionXEdge, _Smooth);
    float _In = (_UV - 0.5) / _Scaler + 0.5;

    float _Out = _In + _PosX  * _ScaleX * _Scale;

    return _Out;
}

float4 Main(float2 In: TEXCOORD) : COLOR
{   
    float4 _Render_Texture = tex2D(S2D_Image, In);
    //float4 _Render_Background = tex2D(S2D_Background, In);
    float4 _Render;

    float2  _Pos = float2(_PosX, _PosY),
        UV = (In + _Pos);
        UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

        //UV = lerp(UV, _UV_Temp, _Mixing);

        float2 UV_Extra = UV;

        float _In_Offset = distance(In.x + _DistortionYOffsetFactor, 0.5);
        float _In_Dist = abs(In.x - 0.5) - _PosX;

        float _UV_Distortion = pow(_In_Offset, _DistortionYPow);
            UV_Extra.y += _UV_Distortion * _DistortionYOffset;

        float _In_Scale = lerp(2.0, 1.0, (_In_Dist * 2.0));
            UV_Extra.x = Fun_Jevil(UV.x);

            UV = lerp(UV, UV_Extra, _Mixing);

        UV = frac(UV);

        //if (_Looping_Mode == 0)     {   UV = frac(UV);  }
        //else if(_Looping_Mode == 1) {   UV = abs(frac(UV / 2) * 2.0 - 1.0); }
        //else if(_Looping_Mode == 2) {   UV = clamp(UV, 0.0, 1.0);   }

    if(_Blending_Mode == 0) {   _Render = tex2D(S2D_Image, UV);  }
    else {                      _Render = tex2D(S2D_Background, UV) * _Render_Texture.a;  }

        //if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))
        //{
        //    _Render = 0;
        //}

    return _Render;
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }