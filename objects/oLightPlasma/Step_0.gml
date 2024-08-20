if (false && destroying)
{
    light.intensity -= 0.2;
    
    if (light.intensity <= 0)
    {
        light.intensity = 0;
        light.Destroy();
        instance_destroy();
    }
}

light.intensity = lerp(5, 25, 0.5 + 0.5*dsin(current_time/4));

light.x = x;
light.y = y;