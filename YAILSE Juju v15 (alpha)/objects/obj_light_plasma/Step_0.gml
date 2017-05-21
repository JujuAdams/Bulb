///Step

event_inherited();

if ( destroying ) {
    image_alpha -= 0.05;
    if ( image_alpha <= 0 ) {
		image_alpha = 0;
		instance_destroy();
	}
}