struct VS_INPUT { // Input to VS
    float4 Position : POSITION;
    float4 Color    : COLOR0;
    float2 Texcoord : TEXCOORD0;
};


struct VS_OUTPUT { // Output to PS from VS
    float4 Position : SV_POSITION;
    float4 Color    : COLOR0;
    float2 Texcoord : TEXCOORD0;
};


VS_OUTPUT main(VS_INPUT IN)
{
    VS_OUTPUT OUT;
    OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], IN.Position);
    OUT.Color = IN.Color;
    OUT.Texcoord = IN.Texcoord;
    return OUT;
}