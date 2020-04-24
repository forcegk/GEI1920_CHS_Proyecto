#include"alu.h"

void alu::entradas(){
	
	sc_uint<5> op;
	sc_uint<4> Am;
	sc_uint<5> Im;
	sc_uint<7> Om;

	op = aluOp.read();

	Im = 0;		Im.bit(4) = Im.bit(0) = op.bit(4);
	Om = 1;		Om.bit(2) = op.bit(4);
				Om.bit(5) = Om.bit(4) = Om.bit(1) = !op.bit(4);
				Om.bit(3) = op.bit(3);
				Am.bit(1) = Am.bit(0) = op.bit(0);		Am(3, 2) = op(2, 1);

	INMODE.write(Im);
	OPMODE.write(Om); 
	ALUMODE.write(Am);

	D.write(0);
	B.write(opB.read().range(17, 0));

	if (op.bit(4)) {	// multiplicacion
		
		// cuanto tienen que valer A y C para multiplicar???

		// La respuesta está en: https://www.xilinx.com/support/documentation/user_guides/ug479_7Series_DSP48E1.pdf
	}
	else {				// alu normal
		C.write(opA.read().to_int()); 
		A.write(opB.read().range(31, 18).to_int());
	}
	   
}

void alu::resultados(){
	
	sc_int<32> tmp; 
	tmp = R.read().range(31, 0);
	resultadoALU.write( tmp );
	zero.write(tmp == 0);
}

void alu::registro(){

	if( rst.read() ){
		salidaALU.write(0);
		///  LO?
	}else{
		salidaALU.write(R.read().range(31, 0));
///  LO?
	}
}
