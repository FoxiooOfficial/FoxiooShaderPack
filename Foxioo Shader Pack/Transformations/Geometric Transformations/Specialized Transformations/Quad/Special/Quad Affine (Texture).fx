/***********************************************************/

/* Shader author: Foxioo and Adam Hawker (aka Sketchy / MuddyMole) */
/* Version shader: 1.0 (09.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;

    AddressU = Border;
    AddressV = Border;

    BorderColor = float4(0, 0, 1, 0);
};

/***********************************************************/
/* Variables */
/***********************************************************/

    float xA;
    float yA;
    float xB;
    float yB;
    float xC;
    float yC;
    float xD;
    float yD;

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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float2 _In = Fun_Quad(In);

    float4 _Render_Texture = tex2D(S2D_Image, _In);

    return _Render_Texture;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } };