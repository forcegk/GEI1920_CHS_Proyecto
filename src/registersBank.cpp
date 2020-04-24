#include"registersBank.h"

void registersBank::readProcA(){
	
	sc_uint<5> r;

	r = rs.read();
	regA.write( regs[r] );
}

void registersBank::readProcB(){
	
	sc_uint<5> r;

	r = rt.read();
	regB.write( regs[r] );
}

void registersBank::writeProc(){

	sc_uint<5> r;

	if( rst.read() ){
		for (int i = 0; i < 32; ++i)	regs[i] = i; // artificio para tener datos con los que trabajar
	}else{
		if( EscrReg.read() ){
			r = rd.read();
			if (r) {
				regs[r] = rdValue.read();	// no se puede cambiar $0
				cout << "rdValue " << regs[r] << endl;
				cambio.write(!cambio.read());
				//cout << "Escr. @ " << hex << r << " = " << regs[r] << endl; // para depurar, si se desea
			}
		}
	}
}
