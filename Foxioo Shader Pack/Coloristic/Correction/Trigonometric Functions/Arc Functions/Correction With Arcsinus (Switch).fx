/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.4 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float _Mixing, _Mul;
    int _Render_Switch;
    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_Asin(float4 _Color, int _Mod)
{  
    float4 _2Color = _Color * (_Color * _Mod);
    return  (_Color + (_2Color * _Color) / 6 + (3 * _2Color * _2Color * _Color) / 40 + (5 * _2Color * _2Color * _2Color * _Color) / 112);
}


float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == false)
        {
            if (_Render_Switch == 0) { _Result = asin(_Render_Texture * _Mul); }
            if (_Render_Switch == 1) { _Result = abs(Fun_Asin(_Render_Texture * _Mul, -1)); }
            if (_Render_Switch == 2) { _Result = Fun_Asin(_Render_Texture * _Mul, 1); }
		    
            _Render = _Render_Texture;
        }
        else
        {
            if (_Render_Switch == 0) { _Result = asin(_Render_Background * _Mul); }
            if (_Render_Switch == 1) { _Result = abs(Fun_Asin(_Render_Background * _Mul, -1)); }
            if (_Render_Switch == 2) { _Result = Fun_Asin(_Render_Background * _Mul, 1); }
            _Render = _Render_Background;
        }

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
