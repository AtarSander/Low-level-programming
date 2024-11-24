# Low-level programming
This repository contains projects developed as part of the Computer Architecture course at Warsaw University of Technology.
## Overview
The **Barcode Project** processes `.bmp` images containing Code 128 barcodes, translating them into human-readable text. It also verifies the barcode integrity by checking for errors and validating the checksum. 
The project was implemented in assembly languages of two architectures:
- RISC-V
- x86
## Running the Project
### RISC-V Barcode Reader
To run the RISC-V barcode reader (assuming you are not using a RISC-V device), you will need to use the [RARS simulator](https://github.com/TheThirdOne/rars). Simply open the project in RARS and run it, replacing the image filenames as needed.
### x86 Barcode Reader
To use the x86 barcode reader, clone this repository, run make, and execute the generated `main` file.
