#include"gestionPC.h"

void gestionPC::mux(){
	

	switch (FuentePC.read()) {
	case 0: 
		tmpPC = resultadoALU.read();	break;
	case 2:
		tmpPC = (( jumpDir.read() << 2 ) | ( PC.read() & (0b11110000000000000000000000000000) ));
			cout << "------" << endl << jumpDir.read() << endl << PC.read() << endl;  
			cout << "tmpPC: " << tmpPC << endl;
			cout << "------" << endl;
		break;
	default: 
		tmpPC = 0xdeaddead;
		cout << "Cuidao ahí que la estás liando avisado quedas" << endl;
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
