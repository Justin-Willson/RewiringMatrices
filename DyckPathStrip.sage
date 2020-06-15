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

def addColToCol(mat, h, c1, c2):
    for i in range(h):
        mat[i,c2] += mat[i,c1]

def addRowToRow(mat, w, r1, r2):
    for i in range(w):
        mat[r1,i] += mat[r2,i]

#Currently only works for p=2
def clearRow(mat, w, h, r):
    leftmost = getLeftmost(mat,w,r)
    if(leftmost > -1):
        for i in range(leftmost+1, w):
            if mat[r,i] > 0:
                addColToCol(mat, h, leftmost, i)

def getLeftmost(mat, w, r):
    for i in range(w):
        if mat[r,i] > 0:
            return i
    return -1

def addUpAfterClear(mat, w, r):
    leftmost = getLeftmost(mat, w, r)
    if leftmost > -1:
        for i in range(r):
            if  mat[i, leftmost] > 0:
                addRowToRow(mat, w, i, r)

def getRookClass(mat, w, h):
    for i in range(h-1):
        r = h - i - 1
        clearRow(mat, w, h, r)
        addUpAfterClear(mat, w, r)
    clearRow(mat, w, h, 0)

p = 2
f = GF(p)
n = 8
M = MatrixSpace(f,n,n)

path = [[0,2],[0,3],[0,4],[0,5],[1,2],[1,3],[1,4],[1,5],[2,6],[2,7],[3,6],[3,7],[4,6],[4,7],[5,6],[5,7]]
#path = [[0,3],[0,4],[0,5],[1,3],[1,4],[1,5],[2,3],[2,4],[2,5],[3,6],[3,7],[3,8],[4,6],[4,7],[4,8],[5,6],[5,7],[5,8]]
b = getBoxesAbovePath(path,n)
toSearch = getMatsOfShape(path,n,f)
classes = getConjClasses(toSearch, b, n, f)
reps = []
for c in classes:
    reps.append(c[0])

d = {}
for r in reps:
    getRookClass(r,n,n)
    r.set_immutable()
    if r in d.keys():
        d[r] += 1
    else:
        d[r] = 1

l = 0
for k in d.keys():    
    i = d[k]
    if not math.log(i, 2).is_integer():
        print(k)
        print(i)
        print("-------")
        l+=1
print(l)
