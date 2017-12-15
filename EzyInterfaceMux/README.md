# EzyInterfaceMux

This perl script helps in generating a MUX implementation for interfaces - a point which makes SystemVerilog unnecessarily cumbersome.

Interfaces in SV make it easier to group signals together and connect them easily between modules. However, if we want to assign the signals on one interface to another, we have to do it manually. We cannot assign an interface directly to another.

This becomes cumbersome if the number of signals within the interface is large and sort of defeats the purpose of interfaces. This script makes it easy to generate a MUX for interfaces by automatically generating the required assignment statements. Every net in an input interface is assigned to the corresponding net in the output interface based on the 'select' logic and type of MUX required.

Note: I wrote this as a quick hack. It probably won't work in every case.
