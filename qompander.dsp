declare name 		"qompander";
declare version 	"1.3";
declare author 		"Bart Brouns";
declare license 	"GNU 3.0";
declare copyright 	"(c) Bart Brouns 2014";
declare credits		"ported from qompander in pd by Katja Vetter";
declare see		"http://www.katjaas.nl/compander/compander.html";
declare additional	"filter coefficients by Olli Niemitalo";

//-----------------------------------------------
// imports
//-----------------------------------------------

import ("./qompander.lib");

//-----------------------------------------------
// the GUI
//-----------------------------------------------
qompanderGroup(x)  = (vgroup("[0] qompander [tooltip: Reference: http://www.katjaas.nl/compander/compander.html]", x));
factor		= qompanderGroup(hslider("[0] factor[unit::1]",		3, 0.8, 8, 0.01):smooth(0.999));
threshold	= qompanderGroup(hslider("[1] threshold [unit: dB]",	-40, -96, -20, 0.01):smooth(0.999));
attack		= qompanderGroup(hslider("[2] attack[unit: ms]",	1, 1, 20, 0.01):smooth(0.999));
release		= qompanderGroup(hslider("[3] release[unit: ms]",	20, 20, 1000, 0.01):smooth(0.999));

process(x) = qompander(x,factor,threshold,attack,release);
