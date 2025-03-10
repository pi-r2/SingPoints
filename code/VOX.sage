# In this file, we implement the attacks of Section 4.

import itertools   
load("tools.sage") #I/O 
load("UOV.sage")   #KeyGen for VOX and UOV


flag = False

def one_vector_FOX(G,x,t, verbose = False) :
    """ 
    Perform a key recovery on FOX from one known vector in the secret UOV subspace, using an enumerative approach.
    Public key G, vector x, hp parameter t.
    Return [] if the attack failed. This is also a membership test for x in O. 
    """
    n = G[0].dimensions()[0]
    o = len(G)
    v = n-o
    c = v-o
    if verbose: 
        print("First, we compute the right kernel of the Jacobian of the system at x.")
    J = matrix([x*g for g in G]) #This is (1/2) the Jacobian of the public key evaluated at x.
    C=matrix(J.right_kernel().basis()) #This is the change of variables that restricts to the kernel of the Jacobian.
    if verbose :
        print(f"Then, we restrict the public key equations to this subspace, which has dimension {C.dimensions()[0]}.")
    G3 = [C*g*C.transpose() for g in G] #This is the restriction of the public key to the kernel of J.

    N = G3[0].dimensions()[0]
    R = PolynomialRing(GF(q), 'x', N-1)
    X = vector(list(R.gens())+[1]) # we arbitrarily choose to set one of the hyperplanes to xN=1 which deshomogeneizes the equations.
    global flag
    if verbose:
        print(f"Next, we compute a grevlex Grobner basis for the ideal defined by the equations of this restriction to which we add o-2t-1={o-2*t-1} hyperplanes to obtain a zero-dimensional intersection with Ot.")
        print("X = ", X)
    eqs = [X*g*X for g in G3]+[X*vector([GF(q).random_element() for _ in range(N)]) for _ in range(o-2*t-1)] #Here we add 1 less hyperplane to compensate for xN-1 which was accounted for earlier.
    ToMSolve(eqs, "/tmp/ovox.ms")
    try:
        if flag :
            raise Exception("This branch will fail")
        if verbose :
            verb = "-v2"
        else :
            verb = ""
        os.system("./msolve "+verb+" -g2 -t8 -f /tmp/ovox.ms -o /tmp/ovox.o > /tmp/ovox.log")
        gb = FromMsolve("/tmp/ovox.o", R)
    except:
        flag = True
        if verbose :
            print("msolve not found, defaulting to sage (this may take some time).")
        gb = Ideal(eqs).groebner_basis(algorithm='libsingular:groebner')[::-1]
    if len(gb) == 1 :
        if verbose :
            print("The ideal is the trivial ideal.")
        return []
    
    
    M = [[gb[i].coefficient(X[j]) for j in range(N-1)] + [0]
                for i in range(o-1)]
    M = matrix(GF(q), M)
    for i in range(o-1) :
        M[i,-1] = gb[i]([0 for _ in range(N-1)])
    
    if verbose :
        print(f"There are {o-1} polynomials of the Groebner basis that are linear forms:")
        for g in gb[:o-1] :
            print(g)
        print("Its right kernel (the intersection of the hyperplanes in the basis) is Ot.")
    D = matrix((M.right_kernel()).basis())
    return D*C

def x_in_O(G,x,t) :
    l = one_vector_FOX(G,x,t)
    if l == [] :
        return False
    #print(l)
    return True 

def KipnisShamir_FOX(G,t,test, randomize = False) :
    """
    Perform a Kipnis-Shamir attack on FOX using the function provided in input for the test "x in O ?".
    If test is None, default to classical Kipnis-Shamir, ie compute rational singular points.
    """
    o = len(G)
    n= G[0].dimensions()[0]
    v = n-o
    q = G[0].base_ring().cardinality() 
    if test is None:
        def test(G,x,t) :
            for g in G :
                if x*g*x != 0 :
                    return False
            return True 
    if randomize:
        max_iter = q**(v-o+t+2)
        tries = 0
        R = PolynomialRing(GF(q), 'l')
        while tries < max_iter:     
            tries+=1
            guess = [R.gens()[0], 1]+[GF(q).random_element() for _ in range(o-1)]
            M = sum([guess[i]*G[i] for i in range(o)])
            for l, _ in M.determinant().roots() :
                for x in M(l).kernel().basis() :
                    if test(G,x,t) :
                        if test(G,x,t) :# We double the test (which is probabilistic) in low dimension to avoid false positive. 
                                        # Such false positives can not happen for real parameters, 
                                        # as the difference between the dimension of the generic variety and the variety corresponding to x in O is very large.
                            print("log_q attempts = ", float(log(tries, q)))
                            return x  
                    else :
                        continue
    
    r = o-1
    g = itertools.product(range(q),repeat=r)
    tries = 0
    for i in g :
        tries+=1
        guess =  [1] + list(i) 
        M = sum([guess[i]*G[i] for i in range(o)])
        if M.determinant() != 0 :
            continue
        #print(M.rank(), M.dimensions())
        for x in M.kernel().basis() :
            if test(G,x,t) :
                if test(G,x,t) :
                    print("log_q attempts = ", float(log(tries, q)))
                    return x  
            else :
                continue
    return []


def expKipnisShamir_FOX(params, N=10) :
    """
    Perform Experiment 5.2 on the parameter sets in params, with N runs of each trial.
    """

    def eKipnisShamir_FOX(G,t,A) :
        o = len(G)
        n= G[0].dimensions()[0]
        v = n-o
        q = G[0].base_ring().cardinality() 
        O = span(A.inverse().columns()[:o])

        r = o-2
        g = itertools.product(range(q),repeat=r)
        tries = 0
        R = PolynomialRing(GF(q), 'l')   
        for i in g :
            tries+=1
            guess = [R.gens()[0], 1] + list(i) 
            M = sum([guess[i]*G[i] for i in range(o)])
            for l, _ in M.determinant().roots() :
                for x in M(l).kernel().basis() :
                    if x in O :
                        return tries
        return []

    res = []
    for q,o,v,t in params:
        n = o + v
        res.append(0)
        (A,_,_, _), G2 = FOXKeyGen(q,o,v,t)
        for _ in range(N) :
            res[-1]+=eKipnisShamir_FOX(G2,t,A)
        res[-1] = log(res[-1]/N, q)
        print(q,o,v,t)
        print("prediction:", n-2*o+t)
        print("real:", float(res[-1]) )
        print()
    print("Done.")

params=[
 [7, 8, 9, 1],
 [7, 10, 12, 2],
 [7, 12, 15, 3],
]

#Uncomment the next line to test the number of trials required on average for a specific parameter set (this is slow: time N*q^(n-2o+t)n^omega)
#expKipnisShamir_FOX(params)




def bihom_FOX(G2, r, t) :
    """ 
    Output the 0 dimensional bihomogeneous system of equations describing the FOX public key singular locus. 
    """
    m = len(G2)
    q = G2[0].base_ring().characteristic() #prime field assumption
    n = G2[0].dimensions()[0]
    R = PolynomialRing(GF(q), ['y'+str(j) for j in range(r)]+['x'+str(i) for i in range(n-1)], n+r-1)

    y = vector(list(R.gens()[:r]) + [GF(q).random_element() for _ in range(m-r)])
    x = vector([1]+list(R.gens()[r:]))
    print(x)
    print(y)
    J = matrix([x*g for g in G2])
    eqs_quad = [x*g*x for g in G2]
    eqs_bilin = list(y*J)
    sys = eqs_quad + eqs_bilin 
    ToMSolve(sys, 'VOX' + str(m) + '.ms')
    return sys

print("########################################################################################################################################################")

print("First, we demonstrate Theorem 2 in practice by computing a grevlex Groebner basis of the ideal of the singular locus of a random FOX public key.")
q,o,v,t = 251, 6, 7, 1
print('We use parameters q,o,v,t=',q,o,v,t)
(A,Sp,F, G), G2 = FOXKeyGen(q,o,v,t)
n = o+v
d =  3*o-n-1-t
print("The dimension of the singular locus is", d)
r = o - d + 1 #We will set x0 = 1 to deshomogeneize, which drops the dimension by 1.
print("Therefore, we choose r=",r-1)
sys = bihom_FOX(G2, r, t) 
print("We solve the system with msolve:")
gb = []
"""
#The following code is commented in case the provided msolve binary is not compiled for your architecture.
#The native sagemath solver is very slow on these systems, but you may uncomment the following line if you wish to use it instead of msolve:
#gb = Ideal(sys).groebner_basis()[::-1]

#Computation ~ 20s 

"""
os.system("./msolve -v2 -g2 -t8 -f VOX"+str(o)+".ms -o VOX"+str(o)+".o > VOX"+str(o)+".log")
if len(gb) == 0 :
    try:
        gb = FromMsolve("VOX"+str(o)+".o", sys[0].parent())
    except:
        #Issue detected with msolve, defaulting to provided output.
        gb = FromMsolve("dVOX"+str(o)+".o", sys[0].parent())
print("The Groebner basis is composed of ", len(gb), "polynomials. The first v=",v ,"ones are linear, and define distinct hyperplanes containing O:")
for g in gb[:v] :
    print(g)
print("This does not imply that there are Fq-rational singular points, and we do not need their existence to compute a Groebner basis.")
print("  ")

print("########################################################################################################################################################")
print("Second, we demonstrate the one vector key recovery.")

q,o,v,t = 251, 48, 54, 6 # I
#q,o,v,t = 1021, 70, 77, 7 #III
#q,o,v,t = 4093, 96, 104, 8 # V
n=o+v
print('We use parameters for security level 1: q,o,v,t=',q,o,v,t)
print("With msolve, all security levels are solved in less than 15 seconds.")
print("Without msolve, it will take some time ~10 minutes to complete the computations for level 5, uncomment the above lines if you wish to try or if you have msolve installed.")

print("KeyGen will take some time.")

(A,Sp,F, G), G2 = FOXKeyGen(q,o,v,t)
print("These parameters are vulnerable to the one vector key recovery:", n-2*o+1<o-2*t)
    
print("An oracle gives us a vector of the underlying UOV secret subspace:")
O = span(A.inverse().columns()[:o])
x = O.random_element()
print("x=",x)

print("We compute a subspace of O of large enough dimension using the approach of Section 4.3.")
O2 = one_vector_FOX(G2, x, t, verbose=True)
print("The subspace we have computed has dimension d =", O2.dimensions()[0], " and t =",t)
#print(O2)

print(" ")


print("We test the function on a random vector:")
x = vector(GF(q), [GF(q).random_element() for _ in range(o+v)])
print("x=",x)

O2 = one_vector_FOX(G2, x, t, verbose=True)

if O2 == [] :
    print("Therefore, x is not in O.")
print(" ")



print("########################################################################################################################################################")

q,o,v,t = 7, 10, 12, 2
(A,Sp,F, G), G2 = FOXKeyGen(q,o,v,t)
n = o+v
d =  3*o-n-1-t
print("Last, we demonstrate the Kipnis-Shamir + one vector attack on the VOX public key.")
print("Parameters o,v,q,t:",o,v,q,t)
print("The dimension of the singular locus of the underlying key is expected to be:",d)
print("The key is vulnerable to the Kipnis-Shamir + one vector attack: ", n-2*o+1<o-2*t)
print(f"The expected log_q number of trials is {n-2*o+t}")
#print(f"The expected number of binary operations is 2^{round(log(q^(t)*q^(v-o)*(n^(10))*log(q)**2,2),1)}")

# In this comment, we decompose the previous bit cost analysis to match the paper
# q^(v-o)*n^3 is the expected cost of computing a vector in O that drops the rank of the Jacobian
# q^tn^3 is the cost of checkin     g whether a vector that drops the rank of the Jacobian is in O 
# We must pay this cost for all q^(v-o) candidates.
# Considering the small sizes, we expect that omega=3 is used under the hood instead of 2.81 (from Strassen).

#Computation time: ~1 minute. Depends on number of rational singular points of underlying UOV key, which closely matches the KPG99 analysis.
x1 = KipnisShamir_FOX(G2,t, x_in_O, randomize=True) 

print("The following vector has been found by one vector + Kipnis-Shamir (Section 4.4): x1=", x1)
print("We deduce the following subspace of O, which is large enough to complete a full key recovery attack:")
print(span(one_vector_FOX(G2, x1, t)))
