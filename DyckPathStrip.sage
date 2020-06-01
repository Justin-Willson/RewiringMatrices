import os
import itertools
os.system('sage --preparse UTnUtil.sage')
os.system('mv UTnUtil.sage.py UTnUtil.py')
from UTnUtil import *

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

def printPretty(mat, path):
    tempPath = copy(path)
    currentRow = []
    offset = int(0)
    while len(tempPath) > 0:
        currentPos = tempPath.pop(0)
        if currentRow == [] or currentRow[0][0] == currentPos[0]:
            currentRow.append(currentPos)
        else:            
            toPrint = " "*offset
            for pos in currentRow:
                toPrint += str(mat[pos[0],pos[1]]) + " "
            print(toPrint)
            offset += (len(currentRow) - 1) * 2
            currentRow = [currentPos]
    toPrint = " "*offset
    for pos in currentRow:
        toPrint += str(mat[pos[0],pos[1]]) + " "
    print(toPrint)

def isRookByRows(mat, n):    
    for r in range(n):
        count = int(0)
        for c in range(n):
            if mat[r,c] > 0:
                count += int(1)
        if count > 1:
            return False
    return True

def isRookByCols(mat, n):    
    for c in range(n):
        count = int(0)
        for r in range(n):
            if mat[r,c] > 0:
                count += int(1)
        if count > 1:
            return False
    return True 

p = 2
f = GF(p)
n = 10
M = MatrixSpace(f,n,n)


path = [[0,4],[0,5],[1,4],[1,5],[2,4],[2,5],[3,4],[3,5],[4,6],[4,7],[4,8],[4,9],[5,6],[5,7],[5,8],[5,9]]
#path = [[0,1],[0,2],[0,3],[1,3],[2,3],[2,4],[2,5],[3,5],[4,5]]
blackout = getBoxesAbovePath(path, n)
print(blackout)
print("Getting mats")
mats = getMatsOfShape(path, n, f)
print("Getting classes")

classes = getConjClasses(mats,blackout,n,f)

mat = matrix(f, [[0,0,1,0,0,0],[0,0,1,1,0,0],[0,0,0,0,0,1],[0,0,0,0,1,0],[0,0,0,0,0,0],[0,0,0,0,0,0]])
count = 0
for c in classes:    
    mat = c[0]
    if((not isRookByRows(mat,n)) or (not isRookByCols(mat,n))):
        count += 1
        print(mat)
        print("------------")

for c in classes:
    print(c[0])
    print("----------------")

print("Total non-rook: " + str(count))