This folder contains the logs of our experiments on UOV instances of varying sizes.

The name structure is as follows:

 - `bi<m>_<n>.ms` contains the polynomial system obtained from a public key for parameters q=251, m = `<m>`, n =` <n>`

 - `bi<m>_<n` contains the corresponding Gröbner basis

 - `bi<m>_<n>.log` contains the log file detailing the execution of F4 on the polynomial system through msolve.

Note: the execution of the solver on bi7_18.ms ran out of time on the cluster we used, but the log file provides a lower bound to the degree of regularity, which we expect to be the actual value.
