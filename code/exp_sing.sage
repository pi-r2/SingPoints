## This file runs some experiments on small UOV systems to 
## demonstrate the properties of the singular locus of a UOV system.
import os 
load("UOV.sage")
load("tools.sage")

q = 251

# Generate systems of equations 

for m in range(4, 10) : #Number of equations in the public key
    for n in range(2*m, 3*m+1) : #Number of variables
        d = 3*m-n-2 #Dimension of the singular locus - 1
        if d < 0 :
            continue
        (A,F), G = KeyGen(q, m, n-m) #Generate a UOV key pair
        R = PolynomialRing(GF(q), ['y'+str(i) for i in range(m-1)] + ['x'+str(i) for i in range(n-1)], m+n-2)
        X = vector([1] + list(R.gens())[m-1:]) #Deshomogeneize the system
        Y = vector([1] + list(R.gens())[:m-1]) #Obtain a one-to-one correspondance between singular points and y vectors
        J = matrix([X*g for g in G]) #Jacobian matrix
        sys = list(Y*J) + [X*g*X for g in G]
        rand_eqs = [] #Intersect with random hyperplanes to reach dimension 0.
        for _ in range(d) :
            rand_eqs.append(
            (matrix(GF(q), 1, n, [GF(q).random_element() for _ in range(n)])*X)[0]
            )
        ToMSolve(rand_eqs + sys, "/tmp/bi"+str(m)+"_"+str(n)+".ms") #Put the system in msolve input format

# Use msolve to solve the systems.
# The larger systems will be more expensive to solve.
# Set m below to a value of your choice in range(4,10).
m= 4
# 

for n in range(2*m, 3*m+1) :
    d = 3*m-n-2
    if d < 0 :
        continue
    print("(m,n)", m, n)
    R = PolynomialRing(GF(q), ['y'+str(i) for i in range(m-1)] + ['x'+str(i) for i in range(n-1)], m+n-2)
    X = vector([1] + list(R.gens())[m-1:])
    Y = vector([1] + list(R.gens())[:m-1])
    file="/tmp/bi"+str(m)+"_"+str(n)
    
    #Get the public key that defined the equations (deshomogeneized by x0 = 1)

    pub = FromMsolve(file+".ms", R)[-m:]

    #Solve the bihomogeneous system
    os.system("./msolve -v2 -g2 -f "+file+".ms -o "+file+".o > "+file+".log")
    
    #Study the result
    gb = FromMsolve(file+".o", R)
    print("The first equations of the Gröbner basis are linear:")
    for i in range(n-m) :
        print(gb[i])
    M = [[0] + [gb[i].coefficient(X[j+1]) for j in range(n-1)]
                for i in range(n-m+d)]
    M = matrix(GF(q), M)
    for i in range(n-m+d) :
        M[i,0] = gb[i]([0 for _ in range(n+m-2)])
    V = M.right_kernel().random_element()
    while V[0] == 0:
        V = M.right_kernel().random_element()
    V = V[0]**(-1)*V #Normalize to the same value used to deshomogeneize.
    evals = [GF(q).random_element() for _ in range(m-1)]
    print('Evaluation of the public key on a random vector from the intersection of the kernels of the hyperplanes:')
    for g in pub :
        print(g(evals+list(V[1:])))  

    hgb = [g.lt() for g in gb]
    I = Ideal(hgb)
    h = I.hilbert_series()
    deg = h.numerator()(1) #equal to 0 if the singular locus is of dimension d
    dim = h.denominator().degree()
    print("The degree of the variety is",deg)
    print(' ')