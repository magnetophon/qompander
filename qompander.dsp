declare name 		"qompander";
declare version 	"0.1";
declare author 		"Bart Brouns";
declare license 	"GNU 3.0";
declare copyright 	"(c) Bart Brouns 2014";
declare coauthors	"translated into faust from qompander by Katja Vetter";
declare see "http://www.katjaas.nl/compander/compander.html";
//-----------------------------------------------
// imports
//-----------------------------------------------

import ("oscillator.lib");
import ("maxmsp.lib");
import ("effect.lib");

//-----------------------------------------------
// the GUI
//-----------------------------------------------
qompanderGroup(x)  = (vgroup("[1] qompander [tooltip: Reference: http://www.katjaas.nl/compander/compander.html]", x));
//PAFvocoderGroup(hslider("[2]thres[unit: dB]"
meter		= qompanderGroup(hbargraph("meter", 0, 1));
factor		= qompanderGroup(hslider("[1] factor[unit::1]",		1, 0.8, 8, 0):smooth(0.999));
point		= qompanderGroup(hslider("[2] point [unit: dB]",	-40, -96, -20, 0):smooth(0.999));
attack		= qompanderGroup(hslider("[3] attack[unit: ms]",	1, 1, 20, 0):smooth(0.999));
release		= qompanderGroup(hslider("[4] release[unit: ms]",	20, 20, 1000, 1):smooth(0.999));


magnitude = (point):db2linear;
exponent = log(magnitude)/log(sin(factor*magnitude*PI/2));

olli1(x) = x:tf2(0.161758, 0, -1, 0, 0.161758):tf2(0.733029, 0, -1, 0, 0.733029):tf2(0.94535 , 0, -1, 0, 0.94535 ):tf2(0.990598, 0, -1, 0, 0.990598);
olli2(x) = x:tf2( 0.479401, 0, -1, 0, 0.479401):tf2(0.876218, 0, -1, 0, 0.876218):tf2(0.976599, 0, -1, 0, 0.976599):tf2(0.9975  , 0, -1, 0, 0.9975  );

//max/msp biquad parameter sequence:
//olli1(x) = biquad(x, 0.161758, 0, -1, 0, 0.161758):biquad(_, 0.733029, 0, -1, 0, 0.733029):biquad(_, 0.94535 , 0, -1, 0, 0.94535 ):biquad(_, 0.990598, 0, -1, 0, 0.990598);
//olli2(x) = biquad(x, 0.479401, 0, -1, 0, 0.479401):biquad(_, 0.876218, 0, -1, 0, 0.876218):biquad(_, 0.976599, 0, -1, 0, 0.976599):biquad(_, 0.9975  , 0, -1, 0, 0.9975  );

//pd biquad parameter sequence:
//olli1(x) = biquad(x, 0, 0.161758, 0.161758, 0, -1):biquad(_, 0, 0.733029, 0.733029, 0, -1):biquad(_, 0, 0.94535, 0.94535, 0, -1):biquad(_, 0, 0.990598, 0.990598, 0, -1);
//olli2(x) = biquad(x, 0, 0.479401, 0.479401, 0, -1):biquad(_, 0, 0.876218, 0.876218, 0, -1):biquad(_, 0, 0.976599, 0.976599, 0, -1):biquad(_, 0, 0.9975, 0.9975, 0, -1);


pyth(x) = sqrt((olli1(x)*olli1(x))+(olli2(x)*olli2(x))):max(0.00001); //compute instantaneous amplitudes
attackDecay(x) = pyth(x) :amp_follower_ud(attack/1000,release/1000);
mapping(x) = attackDecay(x) : (exponent,(sin((min(1/factor)*(factor/4)) / (2*PI)): max(0.0000001)) : pow );
qompander(x) = (mapping(x) / attackDecay(x))<: (_,olli1(x):*),(_,olli2(x):*):+:_*(sqrt(0.5));

//bc(x) = biquad(x, 1, -1.41421, 1, 1.41407, -0.9998);
bc(x) = x:tf2np(1, -1.41421, 1, 1.41407, -0.9998);
process(x) =qompander(x);
//oscrs(5512.5):bc(_);
//oscrs(vslider("foo", 2000, 2000, 6000, 0.1)) : bc(x);
//hslider("foo", -100, -100, 80, 0):db2linear:hbargraph("bar", 0, 0.1);
//magnitude:hbargraph("foo", 0, 0);
//hslider("foo", 60, -1, 1, 0):amp_follower_ud(attack/1000,release/1000):hbargraph("foo", -1, 1);
//qompander(x);