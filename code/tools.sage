## This file contains i/o functions to feed polynomial systems to msolve 
## and exploit the output of the solver.

import os 
import csv
def write_example(Gstar, q,k, dire= "") : #Given public key Gstar, store it as a csv file for further use
    with open(dire+'pub'+str(q)+'_'+str(k)+'.csv', 'w') as f:
        c = csv.writer(f)
        c.writerows(Gstar)

def read_example(q,k, dire = "") : #Given a public key as a csv file, turn it into a usable input for sage implem.
    with open(dire+'pub'+str(q)+'_'+str(k)+'.csv', 'r') as f:
        FF = GF(q)
        c = csv.reader(f)
        Gs = []
        for Ge in c :
            vecs = []
            for Gev in Ge :
                vecs.append(vector(FF,list(map(FF,(Gev[1:-1]).split(',')))))
            Gs.append(matrix(FF,vecs))
        
        return Gs

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
    

def complete_basis(B, E) :
    """
    This function takes as input a list of linearily independant vectors B in E and 
    completes them into a basis naively.
    If the list is empty, a random basis of E is returned
    """
    res = list(B) #Avoid modifying the input.
    if len(res) == 0 :
        b = E.random_element()
        while b.is_zero() :
            b = E.random_element()
        res.append(b)

    while len(res) != E.dimension() :
        b = E.random_element()
        if not(b in span(res)) :
            res.append(b)
    return res


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