createenemytablel2:
	.word	createsnail-1
	.word	createoctopus-1
	.word	createnative-1
	.word	createfish-1
	.word	createbanana-1
	.word	createapple-1
	.word	createtomato-1
	.word	createcarrot-1
	.word	createsignstart-1
	.word	createsign2-1
	.word	createsign3-1
	.word	createsign4-1
	.word	createsigngoal-1
	.word	createcloudplatform-1


#include "../levelcommon/snail.asm"
#include "../levelcommon/octopus.asm"
#include "../levelcommon/fish.asm"
#include "../levelcommon/native.asm"
#define PLATFORM_UP_DOWN
#define PLATFORM_LEFT_RIGHT
#define PLATFORM_FALL_DOWN
#include "../levelcommon/platform.asm"
#include "../levelcommon/cloudplatform.asm"
#include "../levelcommon/banana.asm"
#include "../levelcommon/apple.asm"
#include "../levelcommon/tomato.asm"
#include "../levelcommon/carrot.asm"
