This folder contains code demonstrating the properties of the singular locus of a UOV public key, and the attacks on UOV and VOX.
It is recommended to use msolve: binaries are provided on the webpage
https://msolve.lip6.fr/binaries/index.html
Simply drop the binary in this folder and rename it "msolve".

The file **exp_sing.sage** generates equations for several parameter sets, and verifies the dimension of the singular locus by intersecting it with random hyperplanes.
If the number of hyperplanes matches the dimension, the system is zero-dimensional,
and the Hilbert Series of the ideal is a polynomial.
If the number of hyperplanes is greater, then the Gröbner basis is [1].
If the number of hyperplanes is lower, then the Hilbert Series has a denominator with positive degree.  

We see in practice that the number of hyperplanes always make the system zero-dimensional, which implies that the estimation is correct in these cases.

We also notice that the Gröbner bases we compute contain linear polynomials, which is very peculiar. 
We expect, if the singular locus is included in O, that these equations define the intersection of O with the random hyperplanes we added to the system.
We verify this in practice.

To run the experiments yourself on a computer with sage and compatible with the provided compiled msolve binary (the systems are harder to solve for the native sage Gröbner basis solver):

	sage exp_sing.sage

The file **VOX.sage** generates a VOX public key and computes singular points of the public key via both a Gröbner basis approach and the Kipnis-Shamir attack.
We also demonstrate the one vector key recovery.
To run it: 

	sage VOX.sage
	
The file **attack3.sage** generates a UOV public key and computes a grevlex Gröbner basis of the ideal describing the singular locus of a subset of equations, as described in Section 3.4. Then, it demonstrates that the linear equations define O. This file uses the native sage multivariate solver.
To run it:

	sage attack3.sage
	
