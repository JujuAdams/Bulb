if (destroying)
{
    light.intensity -= 0.2;
    
    if (light.intensity <= 0)
    {
        light.intensity = 0;
        light.Destroy();
        instance_destroy();
    }
}

light.x = x;
light.y = y;