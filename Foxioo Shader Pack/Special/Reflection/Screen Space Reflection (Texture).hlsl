/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (18.01.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Angle;
    float _Size;
    float _Jump;
    float _Strength;
    float _Threshold;
    float _Fade;
    float4 _Color;
    float4 _ColorIgnore;
    float _OffsetX;
    float _OffsetY;
    bool __;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

static int _MaxSteps = 64;

bool Fun_Comp(float3 _Color)
{
    if (all(_ColorIgnore.rgb == 0.0))
        return false;

    return all(abs(_Color.rgb - _ColorIgnore.rgb) <= 0.01);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    
    if(Fun_Comp(_Render_Texture.rgb)) { Out.Color = float4(0.0, 0.0, 0.0, 0.0); return Out; }
    if (_Render_Texture.a > 0.95) { Out.Color = _Render_Texture; return Out;}

    /* Screenspace Reflection! */

    float _Rad = _Angle * 0.0174532925199444; //(3.14159265359 / 180.0);
    float2 _Ray = float2(cos(_Rad), sin(_Rad)) * float2(fPixelWidth, fPixelHeight) * _Size;
    
    float2 UV = In.texCoord + float2(_OffsetX, _OffsetY) * float2(fPixelWidth, fPixelHeight);

    float4 _Render_Reflection =  S2D_Image.Sample(S2D_ImageSampler, UV) * In.Tint;
    float2 _Hit = float2(0.0, 0.0);

    /* raymarching */
    [unroll(32)]
    for (int i = 1; i <= _MaxSteps; i++)
    {
        UV += _Ray;

        if (any(UV < 0.0 || UV > 1.0)) 
            break;

        float4 _Render_Reflected = S2D_Image.Sample(S2D_ImageSampler, UV) * In.Tint;
        
        if (Fun_Comp(_Render_Reflected.rgb))
            continue;
            
        if (_Render_Reflected.a > _Threshold)
        {        
            float2 UV_Ref = In.texCoord + (_Ray * float(i) * _Jump);

            if (all(UV >= 0.0 && UV <= 1.0)) 
            {
                float4 _Render = S2D_Image.Sample(S2D_ImageSampler, UV_Ref) * In.Tint;
                    
                _Render.rgb *= _Color.rgb;
                
                if (_Render.a > _Threshold && !Fun_Comp(_Render.rgb)) 
                {
                    _Render_Reflection = _Render;
                    _Hit = float2((float(i) * 2.0) / float(_MaxSteps), 1.0); 
                    break;
                }
            }
            break;
        }
    }

    /* fade :3 */
    if (bool(_Hit.y))
    {
        float __Fade = 1.0 - _Hit.x; 
        __Fade = saturate(pow(abs(__Fade * __Fade), _Fade));

        _Render_Reflection *= In.Tint; 

        float _Alpha = _Strength * __Fade * _Render_Reflection.a;
        
        float4 _Render;
        _Render.rgb = lerp(_Render_Texture.rgb, _Render_Reflection.rgb, _Alpha);
        _Render.a = max(_Render_Texture.a, _Alpha); 

        _Render = lerp(_Render_Texture, _Render, _Mixing);

        Out.Color = _Render;
    }
    else
        Out.Color = _Render_Texture;

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

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    
    if(Fun_Comp(_Render_Texture.rgb)) { Out.Color = float4(0.0, 0.0, 0.0, 0.0); return Out; }
    if (_Render_Texture.a > 0.95) { _Render_Texture.rgb *= _Render_Texture.a; Out.Color = _Render_Texture; return Out;}

    /* Screenspace Reflection! */

    float _Rad = _Angle * 0.0174532925199444; //(3.14159265359 / 180.0);
    float2 _Ray = float2(cos(_Rad), sin(_Rad)) * float2(fPixelWidth, fPixelHeight) * _Size;
    
    float2 UV = In.texCoord + float2(_OffsetX, _OffsetY) * float2(fPixelWidth, fPixelHeight);

    float4 _Render_Reflection =  Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV)) * In.Tint;
    float2 _Hit = float2(0.0, 0.0);

    /* raymarching */
    [unroll(32)]
    for (int i = 1; i <= _MaxSteps; i++)
    {
        UV += _Ray;

        if (any(UV < 0.0 || UV > 1.0)) 
            break;

        float4 _Render_Reflected = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV)) * In.Tint;
        
        if (Fun_Comp(_Render_Reflected.rgb))
            continue;
            
        if (_Render_Reflected.a > _Threshold)
        {        
            float2 UV_Ref = In.texCoord + (_Ray * float(i) * _Jump);

            if (all(UV >= 0.0 && UV <= 1.0))  
            {
                float4 _Render = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV_Ref)) * In.Tint;
                    
                _Render.rgb *= _Color.rgb;
                
                if (_Render.a > _Threshold && !Fun_Comp(_Render.rgb)) 
                {
                    _Render_Reflection = _Render;
                    _Hit = float2((float(i) * 2.0) / float(_MaxSteps), 1.0); 
                    break;
                }
            }
            break;
        }
    }

    /* fade :3 */
    if (bool(_Hit.y))
    {
        float __Fade = 1.0 - _Hit.x; 
        __Fade = saturate(pow(abs(__Fade * __Fade), _Fade));

        _Render_Reflection *= In.Tint; 

        float _Alpha = _Strength * __Fade * _Render_Reflection.a;
        
        float4 _Render;
        _Render.rgb = lerp(_Render_Texture.rgb, _Render_Reflection.rgb, _Alpha);
        _Render.a = max(_Render_Texture.a, _Alpha); 

        _Render = lerp(_Render_Texture, _Render, _Mixing);

        _Render.rgb *= _Render.a;
        Out.Color = _Render;
    }
    else
    {
        _Render_Texture.rgb *= _Render_Texture.a;
        Out.Color = _Render_Texture;
    }

    return Out;
}