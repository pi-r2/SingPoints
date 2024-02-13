This folder contains code demonstrating the properties of the singular locus of a UOV public key.

The file exp_sing.sage generates equations for several parameter sets, and verifies the dimension of the singular locus by intersecting it with random hyperplanes.
If the number of hyperplanes matches the dimension, the system is zero-dimensional,
and the Hilbert Series of the ideal is a polynomial.
If the number of hyperplanes is greater, then the Gröbner basis is [1].
If the number of hyperplanes is lower, then the Hilbert Series has a denominator with positive degree. 

We see in practice that the number of hyperplanes always make the system zero-dimensional, which implies that the estimation is correct in these cases.

Notice that the Gröbner bases we compute contain linear polynomials, which is very peculiar. 
If the singular locus is included in O, these equations define the intersection of O with the random hyperplanes we added to the system.
We also verify this in practice.

To run the experiments yourself on a computer with sage:

```sage exp_sing.sage ```

If you wish to test the larger instances (m>6), we recommend using the multithreading option in msolve: in line 50 of **exp_sing.sage**, change the command ```os.system("./msolve -v2 -g2 -f "+file+".ms -o "+file+".o > "+file+".log")```
to ```os.system("./msolve -t <n> -v2 -g2 -f "+file+".ms -o "+file+".o > "+file+".log")``` where you replace ```<n>``` by the number of threads you are willing to allocate.
