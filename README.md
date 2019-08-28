# ARC4 Decryption

ARC4 Decryption was a school project (or assignment, I would say) I did during the Summer of 2019 while I was in a Digital Systems Design course. During this time, I was learning about FPGAs and this project was an application on ARC4 (which is a popular symmetric stream cipher, and was widely used in encrypting web traffic, wireless data) Decryption circuit.

The project's running on a De1-SoC board, synthesized using Quartus II 17.1.

* Designing the Decryption Circuit
  * Task 1: Embedded memories and ARC4 state initialization
    * Creating a RAM block using the Wizard
    * Implementing the S\-array initialization step
    * Examining memory contents inside the FPGA
    * Simulating Altera memories in ModelSim
    * Initializing memories
  * Task 2: The Key\-Scheduling Algorithm
  * Task 3: The Pseudo\-Random Generation Algorithm
  * Task 4: Cracking ARC4
  * Task 5: Cracking in parallel
