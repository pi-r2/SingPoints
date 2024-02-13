## This file contains i/o functions to feed polynomial systems to msolve 
## and exploit the output of the solver.

import os 

def ToMSolve(F, finput="/tmp/in.ms"): #From msolve library interfaces
    """Convert a system of sage polynomials into a msolve input file.

    Inputs :
    F (list of polynomials): system of polynomial to solve
    finput (string): name of the msolve input file.

    """
    A = F[0].parent()
    assert all(A1 == A for A1 in map(parent,F)),\
            "The polynomials in the system must belong to the same polynomial ring."
    variables, char = A.variable_names(), A.characteristic()
    s = (", ".join(variables) + " \n"
            + str(char) + "\n")

    B = A.change_ring(order = 'degrevlex') 
    F2 = [ str(B(f)).replace(" ", "") for f in F ]
    if "0" in F2:
        F2.remove("0")
    s += ",\n".join(F2) + "\n"

    fd = open(finput, 'w')
    fd.write(s)
    fd.close()
    
def FromMsolve(output,RR):
    with open(output, 'r') as o :
        sols = []
        for l2 in o.readlines()[2:] :
            l = ''
            for c in l2 :
                if c not in ['[', ']', '\n', ',' , ':'] :
                    l+=c    
            if l[0] == '#' :
                continue
            sols.append(RR(l))
    return sols