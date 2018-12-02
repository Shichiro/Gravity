P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_UV vec2 pos = texCoord.xy;

		P_COLOR vec3 vColor = vec3( 0.0, 0.05, 0.1 );

		vColor.rgb += step( mod( pos.y,  36.0 / 540.0), 2.0 / 540.0) * 0.1;

		vColor.rgb += step( mod( pos.x,  36.0 / 960.0 ), 2.0 / 960.0) * 0.1;

    return CoronaColorScale(vec4(vec3(vColor), 1.0));
}
