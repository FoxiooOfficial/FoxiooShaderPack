/***********************************************************/

/* Autor shader: Foxioo and Adam Hawker (aka Sketchy / MuddyMole) */
/* Version shader: 1.0 (09.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float xA;
    float yA;
    float xB;
    float yB;
    float xC;
    float yC;
    float xD;
    float yD;
    bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color : SV_TARGET;
};

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_Quad(float2 UV)
{
    float a = ((xA - UV.x) * (yB - UV.y) - (xB - UV.x) * (yA - UV.y));
    float b = ((xB - UV.x) * (yC - UV.y) - (xC - UV.x) * (yB - UV.y));
    float c = ((xC - UV.x) * (yD - UV.y) - (xD - UV.x) * (yC - UV.y));
    float d = ((xD - UV.x) * (yA - UV.y) - (xA - UV.x) * (yD - UV.y));

    if (sign(a)==sign(b) && sign(b)==sign(c) && sign(c)==sign(d))
    {
        float2 p0 = float2(xA, yA);
        float2 p1 = float2(xB, yB);
        float2 p2 = float2(xC, yC);
        float2 p3 = float2(xD, yD);
        
        float2 v0 = p1 - p0;
        float2 v1 = p2 - p0;
        float2 v2 = UV - p0;
        
        float d00 = dot(v0, v0);
        float d01 = dot(v0, v1);
        float d11 = dot(v1, v1);
        float d20 = dot(v2, v0);
        float d21 = dot(v2, v1);

            float denom = d00 * d11 - d01 * d01;

            float v = (d11 * d20 - d01 * d21) / denom;
            float w = (d00 * d21 - d01 * d20) / denom;
            float u = 1.0 - v - w;
        
        if (all(float3(u, v, w) >= 0.0)) { return float2(v + w, w);}
        else
        {
            v0 = p2 - p0;
            v1 = p3 - p0;
            v2 = UV - p0;
            
            d00 = dot(v0, v0);
            d01 = dot(v0, v1);
            d11 = dot(v1, v1);
            d20 = dot(v2, v0);
            d21 = dot(v2, v1);

                denom = d00 * d11 - d01 * d01;
                
                v = (d11 * d20 - d01 * d21) / denom;
                w = (d00 * d21 - d01 * d20) / denom;
                u = 0.0 - v - w;
            
            return float2(v, v + w);
        }
    }
    else return -1;
}

float2 Fun_PSXFloat(float2 UV) { return floor(UV * 256.0) / 256.0; }

PS_OUTPUT ps_main(in PS_INPUT In)
{
    PS_OUTPUT Out;

    float2 _In = Fun_PSXFloat(Fun_Quad(Fun_PSXFloat(In.texCoord)));
    bool _Border = (_In.x >= 0.0 && _In.y >= 0.0) ? 1.0 : 0.0;

        float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, _In) * In.Tint;

        _Render_Texture.a *= _Border;

    Out.Color = _Render_Texture;
    return Out;
}

/***********************************************************/
/* Premultiplied Alpha */
/***********************************************************/

float4 Demultiply(float4 _color)
{
    if (_color.a != 0)
        _color.rgb /= _color.a;
    return _color;
}

PS_OUTPUT ps_main_pm(in PS_INPUT In)
{
    PS_OUTPUT Out;

    float2 _In = Fun_PSXFloat(Fun_Quad(Fun_PSXFloat(In.texCoord)));
    bool _Border = (_In.x >= 0.0 && _In.y >= 0.0) ? 1.0 : 0.0;

        float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _In)) * In.Tint;

        _Render_Texture.a *= _Border;
        _Render_Texture.rgb *= _Render_Texture.a;

    Out.Color = _Render_Texture;
    return Out;
}
