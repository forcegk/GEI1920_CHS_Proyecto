#include"shifter.h"

void shifter::shift(){
	
	// osorio: "igual teneis que cambiar algún mux..."
	// also osorio:
	// sh16 = 0xdeaddead;

	sh16 = 0xdeaddead;

}


void shifter::registro(){

	if( rst.read() ){
		shifted.write(0);
	}else{
		shifted.write(sh16);
	}
}
