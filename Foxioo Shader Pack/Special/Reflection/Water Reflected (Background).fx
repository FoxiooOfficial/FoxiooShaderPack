/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (29.12.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);
sampler2D _Texture_NormalMap : register(s2);
sampler2D _Texture_Overlay : register(s3);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            _ReflectionMixing, _ReflectionCut,
            _NormalMapX, _NormalMapY, _NormalMapStrength,
            _NormalMapScaleX, _NormalMapScaleY,
            _OverlayX, _OverlayY, _OverlayScaleX, _OverlayScaleY, _OverlayMixing, _OverlayAddition,
            _PointX, _PointY,
            _RotX,
            _Line, _LineMixing, _LineAmbient, _LineAmbientMixing,
            _SafeAlphaTransition, _SafeAlphaPower, _SafeAlphaMixing;

    float4 _ColorMul, _ColorAdd, _ColorLine;

    bool    _X, _Y;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_RotationX(float2 In.texCoord)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _UV = In.texCoord;
    float _RotX_Fix = _RotX * 0.0174532925;

        In.texCoord = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), _UV - _Points);

    return _UV;
}


float4 ps_main(in PS_INPUT In) : COLOR0
{
    float2 In_Rot = Fun_RotationX(In.texCoord);

    //float _Fix =  lerp(1.0, 1.0 - (saturate((abs(In_Rot.y - _SafeAlphaTransition) * 2.0) * (abs(0.5 - _SafeAlphaTransition) * _SafeAlphaPower))), _SafeAlphaMixing);
    //return float4(_Fix, _Fix, _Fix, 1.0);
    //float _SafeAlpha = (1.0 - saturate((In_Rot.y) - _Fix) / (1.0 - _Fix)) * (_Fix * 16.);

    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;

    float3 _Render_Normal = normalize(tex2D(_Texture_NormalMap, frac(In.texCoord + float2(_NormalMapX , _NormalMapY)) * float2(_NormalMapScaleX, _NormalMapScaleY)).rgb * 2.0 - 1.0);
    float2 _Offset = _Render_Normal.xy * _NormalMapStrength;

    float4 _Render_Overlay = tex2D(_Texture_Overlay, frac(In.texCoord + float2(_OverlayX, _OverlayY) + _Offset) * float2(_OverlayScaleX, _OverlayScaleY));

        float4 _Result =  tex2D(S2D_Background, In.bgCoord);;

            float4 _Reflect = tex2D(S2D_Background, frac(float2(abs(_X - In.texCoord.x) + _Offset.x, abs(_Y - In.texCoord.y) + _Offset.y)));
            _Reflect.rgb = _Reflect.rgb * _ColorMul.rgb + _ColorAdd.rgb;

                if(In_Rot.y > _ReflectionCut - _Offset.y) 
                {
                    _Result = lerp(_Result, _Reflect, _ReflectionMixing);
                    _Result.rgb += saturate((1.0 - ((In_Rot.y - _ReflectionCut + _Offset.y) * _LineAmbient)) * _LineAmbientMixing * _ColorLine);

                    _Result.rgb = lerp(_Result, lerp(_Render_Overlay, _Render_Overlay + _Result, _OverlayAddition), _OverlayMixing * _Render_Overlay.a);

                    if(In_Rot.y < _ReflectionCut - _Offset.y + _Line) _Result.rgb += _ColorLine.rgb * _LineMixing;
                }


                _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a *= _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
