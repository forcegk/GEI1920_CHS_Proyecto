#include"control.h"


void control::registros() {

	if (rst.read()) {
		IR = 0;
		estado.write(buff);
		selDatoReg_o.write(0);
	}
	else {
		if(estado.read()== inicial) IR = instruction.read().to_uint(); // S�, IR se carga as�
		estado.write(state);
		selDatoReg_o.write(selDatoReg);
	}
}



void control::controlProc(){

	sc_uint<6> opCode;
	sc_uint<6> functCode;
	sc_uint<5> reg1, reg2, reg3;

	
	// fijos
	opCode = IR(31, 26);
	functCode = IR(5, 0);

	rs		.write( IR(25, 21) );
	rt		.write( IR(20, 16) );
	rd		.write( IR(15, 11) );
	inm		.write( IR(15, 0).to_int() );
	inmJ	.write( IR(25, 0));
	shamt	.write( IR(10, 6));

	// por defecto y por pura conveniencia 
	EscrPC_Cond.write(0);	FuentePC.write(0);		SelALUB.write(0);	IoD.write(0);
	EscrMem.write(0);		selDatoReg=0;			SelALUA.write(0);	rd.write(IR(20,16));
	EscrPC.write(0);		EscrReg.write(0);		CondSel.write(IR(27, 26)); 
	ALUop.write(0);			EscrLO.write(0);		LeerMem.write(0);
	shiftSel.write(0);		direc.write(0);			arith.write(0);
	


	switch (estado.read()) {
	case buff:
		LeerMem.write(1);
		SelALUB.write(1);
		state = inicial; 	break;
	case inicial:
		EscrIR.write(1);
		EscrPC.write(1);
		SelALUB.write(1);
		state = segundo;	break;
	case segundo:					// puede ser necesario a�adir c�digo para implementar nuevas instrucciones
		SelALUB.write(3);
		state = segundo;
		//cerr << "Opcode: " << hex << opCode << endl;
		if (opCode == 0x23)
			state = lw1;
		else if (opCode == 0x2b)
			state = sw;
		else if (opCode == 0x00)
			state = arith1;
		else if (opCode(5, 3) == 1)
			state = inme1;
		else if (opCode(5, 2) == 1)
			state = branch;
		else if (opCode == 0x02)
			state = jump;
		else if (opCode == 0x03)
			state = jal;
		else if (opCode == 0x3f) {	// apagar Esta instrucci�n ficticia hace que se pueda terminar la simulaci�n desde ensamblador
			sc_stop();
		}
		else {
			cerr << "Error, codigo de operacion ilegal: " << hex << opCode << endl;
			sc_stop();
		}
		break;
	case lw1:
		LeerMem.write(1);
		SelALUA.write(1);
		IoD.write(1);
		SelALUB.write(2);
		state = lw2;		break;
	case lw2:
		LeerMem.write(1);
		EscrReg.write(1);
		state = inicial;	break;
	case sw:
		SelALUA.write(1);
		IoD.write(1);
		SelALUB.write(2);
		EscrMem.write(1);
		state = buff;		break;

	case arith1:
		SelALUA.write(1);
		ALUop.write(0x0e);	// or por defecto
		selDatoReg = 1;		// salida de la ALU por defecto
		state = arith2;		// por defecto

		switch (functCode) {
		case 0x20: 	 ALUop.write(0x00);					break;	// sumar;
		case 0x22: 	 ALUop.write(0x01);					break;	// restar;
		case 0x24: 	 ALUop.write(0x06);					break;	// and
		case 0x25: 	 ALUop.write(0x0e);					break;	// or
		case 0x26: 	 ALUop.write(0x02);					break; // xor
		case 0x2A: 	 ALUop.write(0x01);	selDatoReg = 4;	break;	//slt
		case 0x18: 	 /* MULT NO EST� IMPLEMENTADA */	break;	// mult
		case 0x00:		break;	//sll
		case 0x04: 		break;	//sllv
		case 0x02: 		break;	//srl
		case 0x06: 		break;	//srlv			�CUANTO VALES selDatoReg PARA UNA INSTRUCCI�N DE DESPLAZAMIENTO 
		case 0x03: 		break;	//sra
		case 0x07: 		break;	//srav
		case 0x12: 	 /*  LO NO EST� IMPLEMENTADA */		break;	// LO	
		default:	 state = buff;			// nunca se deber�a llegar aqu�
		};
		break;
	case arith2:
		LeerMem.write(1);
		EscrReg.write(1);   // seleccionado en arith1
		rd.write(IR(15, 11));
		state = inicial;	break;
	case mult2:

		///??????

		state = buff;		break;
	case inme1:
		SelALUA.write(1);
		SelALUB.write(2);     //inmediato extendido en signo por defecto, pero no siempre
		state = inme2;
		selDatoReg = 1;	//por defecto
		switch (opCode(2, 0)) {
		case 0: ALUop.write(0x00);						break;	//addi
		case 2: ALUop.write(0x01);   selDatoReg = 4;	break;	//slti / restar
		case 4: ALUop.write(0x06);   SelALUB.write(4);	break;	//andi
		case 5: ALUop.write(0x0e);   SelALUB.write(4);	break;	//ori
		case 7: ALUop.write(0x0e);   selDatoReg = 5;	break;	//lui
		default: ALUop.write(0x0e);  state = buff;		//no deber�a suceder nunca
		};
		break;
	case inme2:
		LeerMem.write(1);
		EscrReg.write(1);	// seleccionado en inme1
		state = inicial;	break;
	case branch:

		//??????

		state = inicial;	break;
	case jump:
		//??????
		state = inicial;	break;

	case jal:
		// Seleccionamos la salida del mux con una señal de control registrada
		selDatoReg = 5;

		state = jal2;
		break;
	case jal2:
		// Escribe el valor de selDatoReg (ciclo anterior): $ra = PC
		EscrReg.write(1);
		rd.write((unsigned int) 31);

		// Realizamos el salto
		FuentePC.write(2);
		EscrPC.write(1);

		// Cargamos la siguiente instrucción
		LeerMem.write(1);
		IoD.write(3);

		state = inicial;
		break;

	default: // una copia de buff. Nunca se deber�a llegar aqu�
		LeerMem.write(1);
		SelALUB.write(1);
		state = inicial;
	};

}

