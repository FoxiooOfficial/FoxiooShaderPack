/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (18.01.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

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

static int _MaxSteps = 12;

bool Fun_Comp(float3 _Color)
{
    if (all(_ColorIgnore.rgb == 0.0))
        return false;
    else
        return all(abs(_Color.rgb - _ColorIgnore.rgb) <= 0.01);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Texture_Save = _Render_Texture;
    
    if(Fun_Comp(_Render_Texture.rgb)) return float4(0.0, 0.0, 0.0, 0.0);
    else
    {
        float _Rad = _Angle * 0.0174532925199444; //(3.14159265359 / 180.0);
        float2 _Ray = float2(cos(_Rad), sin(_Rad)) * float2(fPixelWidth, fPixelHeight) * _Size;

        float2 UV = In + float2(_OffsetX, _OffsetY) * float2(fPixelWidth, fPixelHeight);

        float4 _Render_Reflection = tex2D(S2D_Image, In);
        float2 _Hit = float2(0.0, 0.0);
        
            for (int i = _MaxSteps; i > 1; i--)
            {
                UV += _Ray;

                float2 UV_Ref = In + (_Ray * float(i) * _Jump); 

                float4 _Render = tex2D(S2D_Image, UV_Ref) * float4(_Color.rgb, 1.0);
                _Render_Texture = _Render;
                _Hit = float2((float(i) * 2.0) / float(_MaxSteps), 1.0); 
            }
            //_Render_Reflection /= _MaxSteps;

        return lerp(_Render_Texture_Save, lerp(_Render_Texture, tex2D(S2D_Image, In), tex2D(S2D_Image, In).a), _Mixing);
    }
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
