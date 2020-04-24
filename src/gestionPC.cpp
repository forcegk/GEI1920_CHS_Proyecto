#include"gestionPC.h"

void gestionPC::mux(){
	
	switch (FuentePC.read()) {
	case 0: 
		tmpPC = resultadoALU.read();	break;
	default: 
		tmpPC = 0xdeaddead;
	};

	nuevoPC.write(tmpPC);

}


void gestionPC::registro() {

	if (rst.read()) {
		PC.write(0);
		regPC.write(0);
	}
	else {
		if (EscrPC.read() ) {
			PC.write(tmpPC);
			regPC.write(tmpPC);
		}
	}

}
