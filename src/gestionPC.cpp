#include"gestionPC.h"

void gestionPC::mux(){
	
	switch (FuentePC.read()) {
	case 0: 
		tmpPC = resultadoALU.read();	break;
	case 2:
		tmpPC = (jumpDir.read() << 2); // sobreescribimos tmpPC al completo
		tmpPC(31,28) = PC.read()(31,28); // y ponemos bien los cuatro primeros
		break;
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
