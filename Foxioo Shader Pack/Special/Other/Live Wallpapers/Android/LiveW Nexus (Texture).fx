/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing, _Time, _Scale,

            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

static const float _Size = 8.0;
static const float4 _Background = float4(0.51, 0.42, 0.34, 0.25);

static const float3 _Palette[4] = 
{
    float3(0.98, 0.1, 0.23), // red - 0
    float3(0.07, 0.73, 0.98), // blue - 1
    float3(0.11, 0.91, 0.08), // green - 2
    float3(1.0, 0.99, 0.31) // yellow - 3
};

float3 Fun_Square(float2 In, float2 _Offset, float2 _Dir, int _Color)
{
    float2 _PixelSize = float2(fPixelWidth, fPixelHeight);
    
    float2 _Round = round(_Offset * 16.0 / 3.0) / 16.0;
    float2 _Grid = (_Round) / _Size;

        float2 _Anim = (_Time * _Dir) / 16.0;
        float2 _Up = _Grid + _Anim;

    float2 _Off = In - _Up;
        _Off = frac(_Off + 0.5) - 0.5; // loop!

    // tail
    float2 _OffPIXEL = _Off / _PixelSize;
    float2 _Norm = _Dir / length(_Dir);

    float _Dot = dot(_OffPIXEL, _Norm);
    float _DirSide = abs(dot(_OffPIXEL, _Norm.yx));

    float2 _TailSize = _Size * float2(15.0, 0.4);

        float _Tail = saturate(1.0 + _Dot / _TailSize.x);
        float _TailMask = saturate(1.0 - max(0.0, _DirSide - _TailSize.y));

        float _Trail = (_Dot < 0.0) * (_Tail * _TailMask);

    //glow
    float2 _Dist = abs(_Off / _PixelSize) - _Size / 2.0;
    
    float _Distance = length(max(_Dist, 0.0));

        float _Glow = exp(-_Distance * 0.1) * 0.5;
        float _Alpha = saturate((max(_Dist.x, _Dist.y) <= 0.0) + _Glow + _Trail * 0.35);

    return _Alpha * _Palette[_Color];
}

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

        float4 _Result = 0.0;

        // Background
        float2 _UV = In / 2.0 * _Scale;
        float2 _In_Background = _UV / _Size / float2(fPixelWidth, fPixelHeight);
        float2 _In_Frac = frac(_In_Background - float2(0.5, 0.0));

            _Result.rgb =   lerp(_Background.w,
                                lerp(_Background.x, lerp(_Background.y, _Background.z, step(_In_Frac.x, 0.5)),
                                    step(abs((0.5 - _In_Frac.x) / _In_Frac.y * 0.5), 0.5)
                                    ),
                                step(abs((0.5 - _In_Frac.x) / (_In_Frac.y - 1.0) * 0.5), 0.5)
                                );
            
            //_Result.rgb -= lerp(_Background.z, 0.0, step((1.5 - _In_Frac.x), 1.0)) * (1.0 - _Background.w);

            // nexus!
            _Result.rgb += Fun_Square(_UV, float2(1.0, 3.0),    float2(0.0, -1.0),      0);
            _Result.rgb += Fun_Square(_UV, float2(5.0, 1.0),    float2(0.0, 0.5),       1);
            _Result.rgb += Fun_Square(_UV, float2(5.0, -7.0),   float2(-0.25, 0.0),     2);
            _Result.rgb += Fun_Square(_UV, float2(1.5, 1.0),    float2(0.75, 0.0),      3);
            _Result.rgb += Fun_Square(_UV, float2(15.0, 11.0),  float2(-0.5, 0.0),      0);
            _Result.rgb += Fun_Square(_UV, float2(-6.0, 5.0),   float2(0.5, 0.0),       1);
            _Result.rgb += Fun_Square(_UV, float2(-4.0, 0.0),   float2(0.0, 1.0),       3);

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
