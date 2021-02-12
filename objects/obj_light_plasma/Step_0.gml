if (destroying)
{
    light.alpha -= 0.05;
    
    if (light.alpha <= 0)
    {
        light.alpha = 0;
        instance_destroy();
    }
}

light.x = x;
light.y = y;