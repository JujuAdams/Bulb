//Demonstration value, normally you'd set a light to "deferred" or "not deferred" and leave it!
demo_is_deferred = choose( true, false );

lighting_light_create( demo_is_deferred );

//Demo starts with deferred lighting forced off, so we should force that here as well
light_deferred = false;