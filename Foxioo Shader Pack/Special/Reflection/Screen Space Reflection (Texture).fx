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
//sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing, 
            _Angle, _Size, _Jump, 
            _Strength, _Threshold, _Fade,
            _OffsetX, _OffsetY,
            fPixelWidth, fPixelHeight;

    float4 _Color, _ColorIgnore;

/************************************************************/
/* Main */
/************************************************************/

static int _MaxSteps = 9;

bool Fun_Comp(float3 _Color)
{
    if (all(_ColorIgnore.rgb == 0.0))
        return false;
    else
        return all(abs(_Color.rgb - _ColorIgnore.rgb) <= 0.01);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

    if(Fun_Comp(_Render_Texture.rgb)) return 0.0;
    else if(_Render_Texture.a >= 1.0) return _Render_Texture;
    else
    {
        /* Screenspace Reflection! */
        float _Rad = _Angle * 0.0174532925199444; // (3.14159265359 / 180.0);

        float2 _SinCos;
        sincos(_Rad, _SinCos.x, _SinCos.y);

        float2 _Ray = _SinCos * float2(fPixelWidth, fPixelHeight) * _Size;
        float2 UV = In + float2(_OffsetX, _OffsetY) * float2(fPixelWidth, fPixelHeight);

            float4 _Render_Reflection = tex2D(S2D_Image, UV);
            float2 _Hit = float2(0.0, 0.0);

        /* raymarching */
        //bool _Break = false;
        for (int i = _MaxSteps; i > 1; i--)
        {
            UV += _Ray * (64.0 / _MaxSteps);

            //if (any(UV <= 0.0 || UV >= 1.0)) 
            //    _Break = true;

            float4 _Render_Reflected = tex2D(S2D_Image, UV);

            //if (Fun_Comp(_Render_Reflected.rgb))
            //    _Break = true;
                
            if (_Render_Reflected.a > _Threshold)
            {        
                float2 UV_Ref = In + (_Ray * float(i * (64.0 / _MaxSteps)) * _Jump);
                float4 _Render = tex2D(S2D_Image, UV_Ref);
                        
                //if (any(UV_Ref <= 0.0 || UV_Ref >= 1.0) || Fun_Comp(_Render.rgb)) 
                //    _Break = true;

                _Render.rgb *= _Color.rgb;

                    //if(_Render.a == 0.0)
                    //    _Break = true;
                    
                    if (_Render.a > _Threshold) 
                    {
                        _Render_Reflection = _Render;
                        _Hit = float2((float(i) * 2.0) / float(_MaxSteps), 1.0); 
                    }
                }
        }

        if (bool(_Hit.y))
        {
            float _InvertedFade = 1.0 - _Hit.x; 

            if(_InvertedFade <= 0.0)
                return 0.0;
            else
            {
                _InvertedFade = saturate(pow(abs(_InvertedFade * _InvertedFade), _Fade));

                float _Alpha = _Strength * _InvertedFade * _Render_Reflection.a;
                
                float4 _Render;
                _Render.rgb = lerp(_Render_Texture.rgb, _Render_Reflection.rgb, _Alpha);
                _Render.a = max(_Render_Texture.a, _Alpha); 

                _Render = lerp(_Render_Texture, _Render, _Mixing);

                return _Render;
            }
        }
        else
            return _Render_Reflection;
    }
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
