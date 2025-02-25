This repository implements experiments and attacks described in the paper https://ia.cr/2024/219. 
The polynomial systems are solved by computing Gröbner bases, either through sage or with msolve (https://github.com/algebraic-solving/msolve/).

code/ contains sage code used to generate UOV and VOX keys and runs various experiments to study the singular locii of the UOV varieties. 
In the file VOX.sage, two attacks against the VOX signature scheme are implemented, including a one-vector key recovery in polynomial time.


logs/ details the result of running msolve on the singular point systems from UOV systems for various parameters.


