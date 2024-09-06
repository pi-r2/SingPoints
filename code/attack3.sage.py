

# This file was *autogenerated* from the file attack3.sage
from sage.all_cmdline import *   # import sage library

_sage_const_5 = Integer(5); _sage_const_12 = Integer(12); _sage_const_251 = Integer(251); _sage_const_3 = Integer(3); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0)#This file implements the attack described in section 3.3.

load("tools.sage") #I/O 
load("UOV.sage")   #KeyGen for VOX and UOV

m = _sage_const_5 
n = _sage_const_12 
q= _sage_const_251 
d = _sage_const_3 *m-n-_sage_const_2  #Dimension of the singular locus after dehomogeneization
r = n - _sage_const_2 *m + _sage_const_1  #Number of equations/y-variables for zero-dimensional system

print("We use the parameter set q, m, n:", q,m,n)
print("In this case, we expect the singular locus to have dimension", d+_sage_const_1 )
print("Therefore, we choose r=", r) #Notice that we have dimension d-1 by dehomogeneization and use r instead of r+1: this is because for each singular point, the whole line span(y) is solution to the yJacG(x) = 0 system of equations. 
vars = ['y'+str(i) for i in range(r)] + ['x'+str(i) for i in range(n-_sage_const_1 )]
(A,F), G = KeyGen(q,m,n-m)

R = PolynomialRing(GF(q),vars , n+r-_sage_const_1 )
X = vector(list(R.gens())[r:] + [_sage_const_1 ])
Y = vector([_sage_const_1 ] + list(R.gens())[:r])
print("The vectors are")
print("x =", X)
print("y =", Y )
sys = [X*g*X for g in G] + list(Y*matrix([X*(g+g.transpose()) for g in G[:r+_sage_const_1 ]]))
print("The system is [X^T.gi.X, 1<= i <= m] + Y^T.jac(G)(x) and has",n+m, "equations.")

ToMSolve(sys, "sing"+str(m)+"_"+str(n)+".ms")
print("We solve the system using msolve:")
try: 
    os.system('./msolve -v2 -g2 -t8 -f sing'+str(m)+"_"+str(n)+".ms -o sing"+str(m)+"_"+str(n)+".o > log"+str(m)+"_"+str(n))
    gb = FromMsolve("sing"+str(m)+"_"+str(n)+".o", R)
except :
    print("Issue with msolve, using Sagemath instead")
    gb = Ideal(sys).groebner_basis()[::-_sage_const_1 ]
print("")
print(f"There are {n-m} polynomials of the Groebner basis that are linear forms:")
for g in gb[:n-m] :
    print(g)
print(f"The matrix representing this system is (the constant terms correspond to the dehomogeneized variable x{n-_sage_const_1 }):")
M = [[gb[i].coefficient(X[j]) for j in range(n-_sage_const_1 )] + [_sage_const_0 ]
            for i in range(n-m)]
M = matrix(GF(q), M)
for i in range(n-m) :
    M[i,-_sage_const_1 ] = gb[i]([_sage_const_0  for _ in range(n-_sage_const_1 +r)])
print(M)

print("")
print("Its right kernel (the intersection of the hyperplanes they define) is O.")
C = matrix((M.right_kernel()).basis())
print("We show this by computing the evaluation of the polar forms of the public key on the basis (Lemma 1):")
for g in G :
    print(C*g*C.transpose(), '\n')
