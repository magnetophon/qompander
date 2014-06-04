declare name 		"qompander";
declare version 	"1.0";
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
meter		= qompanderGroup(hbargraph("meter", 0, 1));
factor		= qompanderGroup(hslider("[1] factor[unit::1]"	,	3, 0.8, 8, 0):smooth(0.999));
threshold		= qompanderGroup(hslider("[2] threshold [unit: dB]"	,	-40, -96, -20, 0):smooth(0.999));
attack		= qompanderGroup(hslider("[3] attack[unit: ms]"	,	1, 1, 20, 0):smooth(0.999));
release		= qompanderGroup(hslider("[4] release[unit: ms]",	20, 20, 1000, 1):smooth(0.999));



//-----------------------------------------------
// the DSP
//-----------------------------------------------

magnitude = (threshold):db2linear;
exponent = log(magnitude)/log(sin(factor*magnitude*PI/2));

// to go from puredata biquad coefficients to max/msp and faust notation: the first two parameters are negated and put last
olli1(x) = x:		tf2(0.161758, 0, -1, 0, -0.161758):tf2(0.733029, 0, -1, 0, -0.733029):tf2(0.94535 , 0, -1, 0, -0.94535 ):tf2(0.990598, 0, -1, 0, -0.990598);
olli2(x) = x:mem:	tf2(0.479401, 0, -1, 0, -0.479401):tf2(0.876218, 0, -1, 0, -0.876218):tf2(0.976599, 0, -1, 0, -0.976599):tf2(0.9975  , 0, -1, 0, -0.9975  );

pyth(x) = sqrt((olli1(x)*olli1(x))+(olli2(x)*olli2(x))):max(0.00001):min(100); //compute instantaneous amplitudes
attackDecay(x) = pyth(x) :amp_follower_ud(attack/1000,release/1000);
mapping(x) = attackDecay(x) : ((sin((min(1/factor)*(factor/4)) * (2*PI)): max(0.0000001):min(1),exponent) : pow );
qompander(x) = (mapping(x) / attackDecay(x))<: (_,olli1(x):*),(_,olli2(x):*):+:_*(sqrt(0.5));

//optional gain and output meter
//gain = hslider("gain", 60, 0, 1, 0):smooth(0.999);
envelope	= abs : max ~ -(1.0/SR) : max(db2linear(-70)) : linear2db;
OutMeter =  _<:_,(envelope:hbargraph("[2][unit:dB][tooltip: output level in dB]", -70, +6)):attach;
//tstMeter =  _<:_,(abs : max ~ -(1.0/SR):hbargraph("TST", 0, 1)):attach;

process(x) = qompander(x);
