/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.7 (20.06.2026) */
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

/************************************************************/
/* Main */
/************************************************************/

#define M_PI 3.14159265359

float3 Fun_Asin(float3 _Color, int _Case)
{   
    float3 _Render = asin(_Color);

    if(_Case == 0) // Native
        return _Render;

    else if(_Case == 1) // D3D9 simulated
    { 
        float a = -1.0 / M_PI * 1.07596f;
        float p = -M_PI;

        if(any(_Color < -1.0))
            return a * pow((_Color - p), 2.0f);

        else if(any(_Color > 1.0))
            return -a * pow((-_Color - p), 2.0f);

        else
            return _Render;
    }

    else if(_Case == 2) // D3D11, OGL simulated
    {
        float NaN = _Mixing < 0.0f ? 0x7FC00000 : 0.0f;

        float3 _Result;

            _Result.r = abs(_Color.r) > 1.0f ? NaN : _Render.r;
            _Result.g = abs(_Color.g) > 1.0f ? NaN : _Render.g;
            _Result.b = abs(_Color.b) > 1.0f ? NaN : _Render.b;
            //_Result.a = abs(_Color.a) > 1.0 ? NaN : _Render.a;

        return _Result;
    }

    else return float3(0.0f, 0.0f, 0.0f);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

		float4 _Result = _Render_Texture + (_Render_Background * _Mul);

        _Result.rgb = Fun_Asin(_Result.rgb, clamp(_Render_Switch, 0, 2));
        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
