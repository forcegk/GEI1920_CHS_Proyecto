#include "BRAM.h"

void BRAM::puertoA(){

	sc_int<32> dato;
	sc_uint<9> dir;
	bool we;

	dir = addrA->read();
	we = weA->read();
	if(we){
		dato = dinA->read();

		mem[dir] = dato;
	}else
		doutA->write( mem[dir] );
}

void BRAM::puertoB(){

	sc_int<32> dato;
	sc_uint<9> dir;
	bool we;
	
	dir = addrB->read();
	we = weB->read();

	if(we){
		dato = dinB->read();
		mem[dir] = dato;
	}else
		doutB->write( mem[dir] );
}

void BRAM::volcado(){
	printf("%s\n", name() );
	for (int i = 0; i < 64; ++i) {
		for (int j = 0; j < 8; ++j)
			printf("%03x: %08x%s", (i + j * 64) * 4, mem[i + j * 64].to_int(), (j==7) ? "\n" : "    ");				
	}
	printf("\n");

}

void BRAM::cargaContenido(unsigned int dato, int idx) {
		mem[idx] = dato;
}