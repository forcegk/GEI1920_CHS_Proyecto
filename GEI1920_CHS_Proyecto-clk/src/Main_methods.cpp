#include "systemc.h"

//#include "productorConsumidor.h"
#include "mipsCA.h"


SC_MODULE(dummy) {
public:
	sc_out<sc_int<32>>	extDataIn;
	sc_out<sc_uint<10>>	extAddrIn;
	sc_out<bool>		incomingW;
	sc_in<sc_int<32>>	extDataOut;
	sc_in<sc_uint<10>>	extAddrOut;
	sc_in<bool>			outgoingW;
	sc_out<sc_int<32>>	io0, io2;
	sc_in<sc_int<32>>	io1, io3;
	sc_out<bool>		Wio0, Wio2;
	sc_in<bool>			Wio1, Wio3;
	SC_CTOR(dummy) {
	}
};



class top : public sc_module
{
public:
	sc_in < bool > clk, rst;

mipsCA *instMIPS;
dummy* instDummy;

sc_signal<sc_int<32>>	extDataIn;
sc_signal<sc_uint<10>>	extAddrIn;
sc_signal<bool>			incomingW;

sc_signal<sc_int<32>>	extDataOut;
sc_signal<sc_uint<10>>	extAddrOut;
sc_signal<bool>			outgoingW;

sc_signal<sc_int<32>>	io0, io2;
sc_signal<sc_int<32>>	io1, io3;
sc_signal<bool>			Wio0, Wio2;
sc_signal<bool>			Wio1, Wio3;


sc_signal<sc_uint<16>>	datoA, datoB, resultado;
sc_signal<bool>			valido, listo;

	SC_CTOR(top){
	
		int i;
		
		#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) && !defined(__CYGWIN__)
			instMIPS = new mipsCA("instMIPS", "doc\\programaJAL.txt", "doc\\datos.txt");
		#else
			instMIPS = new mipsCA("instMIPS", "doc/programaJAL.txt", "doc/datos.txt");
		#endif

		instDummy = new dummy("instDummy");

		// EL RESTL YA EST� BIEN CONECTADO

		instMIPS->extDataIn(extDataIn);
		instMIPS->extAddrIn(extAddrIn);
		instMIPS->incomingW(incomingW);
		instMIPS->extDataOut(extDataOut);
		instMIPS->extAddrOut(extAddrOut);
		instMIPS->outgoingW(outgoingW);
		instMIPS->io0(io0);
		instMIPS->io2(io2);
		instMIPS->io1(io1);
		instMIPS->io3(io3);
		instMIPS->Wio0(Wio0);
		instMIPS->Wio2(Wio2);
		instMIPS->Wio1(Wio1);
		instMIPS->Wio3(Wio3);
		instMIPS->clk(clk);
		instMIPS->rst(rst);

		instDummy->extDataIn(extDataIn);
		instDummy->extAddrIn(extAddrIn);
		instDummy->incomingW(incomingW);
		instDummy->extDataOut(extDataOut);
		instDummy->extAddrOut(extAddrOut);
		instDummy->outgoingW(outgoingW);
		instDummy->io0(io0);
		instDummy->io2(io2);
		instDummy->io1(io1);
		instDummy->io3(io3);
		instDummy->Wio0(Wio0);
		instDummy->Wio2(Wio2);
		instDummy->Wio1(Wio1);
		instDummy->Wio3(Wio3);


	}

	~top() {
		delete instDummy;
		delete instMIPS;
	}

};

int sc_main(int nargs, char* vargs[]){

	sc_clock clk ("clk", 1, SC_NS);
	sc_signal <bool> rst;

	top principal("top");
	principal.clk( clk );
	principal.rst( rst );


	rst.write(true);
	sc_start(2, SC_NS);				

	rst.write(false);
	sc_start();

	if (! sc_end_of_simulation_invoked()) {
		cerr << "KKK" << endl; 
		sc_stop();
	}

	return 0;

}