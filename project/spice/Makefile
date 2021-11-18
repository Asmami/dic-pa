
plt=python3 ../../py/plot.py

pixSens:
	${MAKE} ngspice	 TB=MyPixelSensor_tb

Sens:
	${MAKE} ngspice TB=MySensor_tb

Comp:
	${MAKE} ngspice TB=MyComp_tb

ngspice:
	ngspice -a ${TB}.cir
