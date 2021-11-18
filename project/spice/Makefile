
plt=python3 ../../py/plot.py

pixSens:
	${MAKE} ngspice	 TB=MyPixelSensor_tb



ngspice:
	ngspice -a ${TB}.cir
