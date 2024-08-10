# Start

## Environment
The P4 VM Ubuntu20.04. [Download](https://github.com/p4lang/tutorials?tab=readme-ov-file)

## Run SecureINT

Download this repo (SecureINT/BMv2) in the P4-VM.

Open a terminal, compile and run SecureINT:

    cd BMv2
    make

If find any compiling errors related to p4utils, please delete it (rm -rf p4utils) and reinstall [P4utils](https://nsg-ethz.github.io/p4-utils/installation.html). 

## Run controller

Open another terminal

    sudo python3 mycontroller.py

The controller issues keys to each switch and monitors INT reports.

## Send packet

In the first terminal, there is a running mininet. 

    xterm h1
    sudo python3 send.py

In the terminal of the controller, we can see the encrypted INT reports.

# Change/disable SecureINT

If disable encryption, comment out the following line in p4src/int_md.p4

    // process_encrypt.apply(hdr, local_metadata, standard_metadata);

If disable SipHash, comment out the following line in p4src/int_md.p4

    // process_SipHash_1_3.apply(hdr, local_metadata, standard_metadata);

If these two lines are both commented out, SecureINT becomes the ordinary INT, whose INT metadata is plaintext.

The P4 codes of SecureINT contain the decryption function, which is in p4src/include/encrypt.p4

If want to decrypt, uncomment the lines below:

    //decryption (if necessary)
        /*
        hdr.ciphertext_1.value = hdr.ciphertext_1.value ^ hdr.encryption_key.k;
        hdr.ciphertext_2.value = hdr.ciphertext_2.value ^ hdr.encryption_key.k;
        hdr.ciphertext_3.value = hdr.ciphertext_3.value ^ hdr.encryption_key.k;

        inverse_permutation_ciphertext_1();
        inverse_permutation_ciphertext_2();
        inverse_permutation_ciphertext_3();

        hdr.ciphertext_1.value = hdr.ciphertext_1.value ^ hdr.encryption_key.k;
        hdr.ciphertext_2.value = hdr.ciphertext_2.value ^ hdr.encryption_key.k;
        hdr.ciphertext_3.value = hdr.ciphertext_3.value ^ hdr.encryption_key.k;

        hdr.plaintext_1.value = hdr.ciphertext_1.value;
        hdr.plaintext_2.value = hdr.ciphertext_2.value;
        hdr.plaintext_3.value = hdr.ciphertext_3.value;

        */
