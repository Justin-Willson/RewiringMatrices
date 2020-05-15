############################# Functions ######################################

#Gets the unipotent upertriangular nxn matrices over the field f
def getUTn(n: int, f: sage.rings.finite_rings.finite_field_prime_modn):
    toRet = []
    fillings = getListOfLength(((n-1)*n)/2, f)

    for filling in fillings:
        toRet.append(getUTnMatFromList(n, f, filling))
    return toRet

def getUTnMatFromList(n: int, f: sage.rings.finite_rings.finite_field_prime_modn, l: list):
    #((n-1)*n)/2 is the number of entries above the diagonal
    if len(l) != ((n-1)*n)/2:
        raise NameError('Invalid array length')
    
    mat = copy(MatrixSpace(f,n,n).identity_matrix())
    current = 0
    for i in range(n):
        for j in range(n-i-1):
            mat[i,j+i+1] = l[current]
            current += 1
    return mat

#Recursivley generates all lists of length n composed of element of f
#Returns a list of all such lists
def getListOfLength(n: int, f: sage.rings.finite_rings.finite_field_prime_modn):
    toRet = []
    if n == 1:
        for elem in f:
            toRet.append([elem])
        return toRet
    
    for elem in f:
        beginnings = getListOfLength(n-1,f)
        for beginning in beginnings:
            beginning.append(elem)
            toRet.append(beginning)
    return toRet

#Remember, python uses 0 indexed lists, so we have to offset our entries by 1
def blackout(mat: sage.matrix, entries: list):
    for entry in entries:
        mat[entry[0],entry[1]] = 0
    return mat

def getConjClasses(toSearch, n,f):
    found = []
    classes = []
    conjugators = getUTn(n,f)
    for mat in toSearch:
        if mat not in found:
            found.append(mat)
            conjClass = [mat]
            for c in conjugators:
                current = c*mat*c.inverse()
                if current not in conjClass:
                    found.append(current)
                    conjClass.append(current)
            classes.append(conjClass)
    return classes

def blackoutForBottomLeft(mat: sage.matrix, n: int):
    toBlackout = []
    for i in range(n):
        for j in range(n):
            if j >= i:
                toBlackout.append([i,j])
    return blackout(mat, toBlackout)

def fillMatFromList(toFill: list, entries: list, n: int, f: sage.rings.finite_rings.finite_field_prime_modn):
    if len(toFill) != len(entries):
        raise NameError('Inputs must have the same length')

    mat = MatrixSpace(f,n,n).identity_matrix() - MatrixSpace(f,n,n).identity_matrix()
    for i in range(len(entries)):
        e = toFill[i]
        mat[e[0],e[1]] = entries[i]

    return mat

def getMatsOfShape(shape: list, n: int, f: sage.rings.finite_rings.finite_field_prime_modn):
    toRet = []
    fillings = getListOfLength(len(shape),f)
    for filling in fillings:
        toRet.append(fillMatFromList(shape, filling, n, f))
    return toRet

def printClasses(classes):
    for c in classes:
        print("Size: " + str(len(c)))
        for e in c:
            print(e)
            print("------")
        print("######")
    print("Number of classes: " + str(len(classes)))

