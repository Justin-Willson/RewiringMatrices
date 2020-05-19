import os
os.system('sage --preparse UTnUtil.sage')
os.system('mv UTnUtil.sage.py UTnUtil.py')
from UTnUtil import *

p = 2
f = GF(p)
n = 9
M = MatrixSpace(f,n,n)

def getHook(n,h):
    if n-h < 1:
        raise NameError('Height is too large for matrix size')

    toRet = []
    for i in range(1,n):
        toRet.append([0,i])
    for i in range(1,h):
        toRet.append([i,n-1])

    return toRet

print("Running")

def getBoxesAbovePath(path, n):
    rows = {}
    for b in path:
        if b[0] not in rows.keys():
            rows[b[0]] = b[1]
        if rows[b[0]] < b[1]:
            rows[b[0]] = b[1]

    toRet = []
    for k in rows.keys():
        for i in range(rows[k]+1,n):
            toRet.append([k,i])
    return toRet

path = [[0,4],[1,4],[2,4],[2,5],[2,6],[3,6],[4,6],[5,6],[5,7],[5,8]]
blackout = getBoxesAbovePath(path, n)
print(blackout)
print("Getting mats")
mats = getMatsOfShape(path, n, f)
print("Getting classes")

classes = getConjClasses(mats,blackout,n,f,True)
