# SPI Interface Project

This repository contains the Verilog implementation of an SPI Interface designed for an FPGA using Vivado. The project involves creating an SPI Slave module, Single Port RAM, and an SPI Wrapper module that integrates both.

## Project Overview

The SPI Interface project is designed to facilitate communication between a master and a slave device. The system includes:
- **SPI Slave Module**: Handles the SPI protocol and communication with the master device.
- **Single Port RAM**: Used for data storage and retrieval in synchronization with the SPI Slave.
- **SPI Wrapper Module**: Integrates the SPI Slave and RAM, managing data flow and control signals between them.

## Block Diagram

![Block Diagram](path/to/your/diagram.png)

## Specifications

- **Clock Frequency**: [Specify Clock Frequency]
- **Memory Depth**: 256
- **Address Size**: 8 bits
- **Data Bus Width**: 8 bits

## Project Structure

- **SPI_Slave.v**: Verilog code for the SPI Slave module.
- **single_port_Ram.v**: Verilog code for the Single Port RAM module.
- **SPI_Wrapper.v**: Verilog code for the SPI Wrapper module.
- **testbench.v**: Testbench for simulating the SPI Interface.
- **constraints.xdc**: Constraints file used in Vivado for FPGA implementation.
- **waveforms/**: Directory containing waveform screenshots from simulations.
- **synthesis/**: Directory containing synthesis reports for different FSM encoding methods.

## FSM Encodings

The project includes synthesis reports for three FSM encoding schemes:
- **Gray Encoding**
- **One-hot Encoding**
- **Sequential Encoding**

## Acknowledgments

- Thanks to Eng. Kareem Waseem for guidance throughout the project.

**This README file provides a comprehensive overview of your SPI Interface project, including the structure, instructions, and details relevant to users and collaborators.**
