import os
import itertools
import threading
import queue

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



def getRookClassElements(rookMat,b,n,f):
    elem = getElemUTn(n,f)
    found = set()
    stack = [rookMat]
    count = 0
    while(len(stack) > 0):
        current = stack.pop()
        n = []
        for e in elem:
            #Compute next nodes in graph
            tempLeft = e*current
            tempRight = current*e
            left = blackout(tempLeft,b)
            right = blackout(tempRight,b)

            
            n.append(left)
            if left != right:
                n.append(right)

        for toCheck in n:  #check to see if we've found the new element
            toCheck.set_immutable()
            if toCheck not in found:                
                found.add(toCheck)
                stack.append(toCheck)
                count += 1
                if count % 100 == 0:
                    print(count)

    return found

p = 2
f = GF(p)
n = 11
M = MatrixSpace(f,n,n)

print("Running")

mat = copy(M.zero_matrix(), sparse=True)
# mat[0,3] = 1
# mat[1,2] = 1
# mat[3,4] = 1
# b = [[0,4],[0,5],[1,4],[1,5]]
mat[0,3] = 1
mat[1,5] = 1
mat[2,4] = 1
mat[4,10] = 1
mat[6,8] = 1
mat[7,9] = 1

b = [[0,9],[0,10],[1,9],[1,10],[2,9],[2,10],[3,9],[3,10]]

toSearch = getRookClassElements(mat,b,n,f)
print(mat)
print("Searching for conj classes")
reps = getConjClasses(toSearch, b, n,f, True)
for c in reps:
    print(c)
    print("-----")

print(len(reps))