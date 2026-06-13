# First phase
Moonkeeper peacefully walks toward player and slowly attacks. Sometimes dashes.
Counts and learn how player behaviour.


After losing 1/2 it proceeds to second phase.


# Second phase
Moonkeeper escapes to background and activates moon. Moon starts rolling (keep rollin until end of the phase)
and attacks player. It targets player position and rush with a "possible to dash" speed. Deals damage and bounce on screen.

# Third phase
Moonkeeper backs from background to arena. Moon stops rollin.
Now moonkeeper use his full power.
Instead of walking, he runs and it's faster
Dashes player attacks (not all time)
Jumps to moon and with its power dashes on player with attack
or shoots lasers from moon

with these many options moonkeeper will learn what player avoids less
and abuse this attack with a random chance to behave differently



-----
for phase three

counting up player actions
and boss actions


weighted selector:
	
	selector - w = 0.6:
		if parry > hit by attack:
			aggressive dash
		if last few player actions were jumps:
			use anti air attack few times
		if player avoids not sword attacks:
			go with ground_attack
	randomselector - weight 0.4:
		here change weights based on perception table in maybe action node? or leaf?
		
		rest attacks
