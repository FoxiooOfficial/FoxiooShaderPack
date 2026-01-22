/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.5 (18.10.2025) */
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

    float _Mul, _Mixing;
    
    int _Render_Switch;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_Acos(float4 _Color)
{  
    float4 _2Color = _Color * _Color;
    return 3.14159265359 / 2 - (_Color + (_2Color * _Color) / 6 + (3 * _2Color * _2Color * _Color) / 40 + (5 * _2Color * _2Color * _2Color * _Color) / 112);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);
    float4 _Result;

		// _Render_Switch = 0 (Acos mode from Direct3D9)
        if (_Render_Switch == 0) 
		{
            if(_Blending_Mode == 0)
                _Result = acos(_Render_Texture - (_Render_Background * _Mul));
            else
                _Result = acos((_Render_Background * _Mul) - _Render_Texture);
        }

		// _Render_Switch = 1 (Acos mode SYMULATED from Direct3D9)
		else if (_Render_Switch == 1) 
		{
            if(_Blending_Mode == 0)
			    _Result = abs(Fun_Acos(_Render_Texture - (_Render_Background * _Mul)));
            else
                _Result = abs(Fun_Acos((_Render_Background * _Mul) - _Render_Texture));
		}

		// _Render_Switch = 2 (Acos mode SYMULATED from Direct3D11)
		else if (_Render_Switch == 2) 
		{
            if(_Blending_Mode == 0)
			    _Result = Fun_Acos(_Render_Texture - (_Render_Background * _Mul));
            else
                _Result = Fun_Acos((_Render_Background * _Mul) - _Render_Texture);
		}

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
