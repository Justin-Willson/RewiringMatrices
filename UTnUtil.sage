############################# Functions ######################################

#Gets the unipotent upertriangular nxn matrices over the field f
#It does so by generating all possible ways to fill in the entries
#above the diagonal and then using the getUTnMatFromList function
#to turn them into matrices
def getUTn(n: int, f: sage.rings.finite_rings.finite_field_prime_modn):
    toRet = []
    fillings = getListOfLength(((n-1)*n)/2, f)

    for filling in fillings:
        toRet.append(getUTnMatFromList(n, f, filling))
    return toRet

#Gets the elements of UTn that have the form I +e_ij,
#That is the elements with exactly one 1 above the diagonal
#It does so by making lists that have one 1 and filling in upper triangular matrices from that list
#using the getUTnMatFromList function
def getElemUTn(n: int, f: sage.rings.finite_rings.finite_field_prime_modn):
    toRet = []
    fillings = []
    l = ((n-1)*n)/2
    for i in range(l):
        toAdd = [0]*int(l)
        toAdd[i] = 1
        fillings.append(toAdd)

    for filling in fillings:
        toRet.append(getUTnMatFromList(n, f, filling))
    return toRet

#This function takes a list of entries and puts them into the above diagonal entries of a matrix
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

#Given a matrix, this function zeroes out the entries in the list provided
#Remember, python uses 0 indexed lists, so we have to offset our entries by 1
def blackout(mat: sage.matrix, entries: list):
    for entry in entries:
        mat[entry[0],entry[1]] = 0
    return mat


#This function takes a set of matrices(toSearch) and find all of the conjugacy classes containing elements in that set
#It also takes a list of entries (toBlackout) that allows us to blackout entries. This makes sure our conjjugacy classes
#consider two elements to be the same if they are the same in the regions we care about
#The v flag turns on verbose mode and causes this function to print out results as it finds them
#We use a depth first approach to finding all elements of the conjugacy class as each element in the
#conjugacy class can be find by successivly conjugating by the elementary elements of UTn, that is the
#elements with exctly one 1 above the diagonal.
def getConjClasses(toSearch, toBlackout, n,f, v=False):
    found = set()
    classes = []
    lefts = getElemUTn(n,f)
    rights = []
    for i in range( len(lefts) ):
        rights.append(lefts[i].inverse())

    for mat in toSearch:
        mat.set_immutable()
        if mat not in found:            
            if v:
                print("Found new class with rep:")
                print(mat)
                print("Current number of classes: " + str(len(classes)+1)) #have to add one since current isn't added yet

            stack = [mat]
            found.add(mat)
            conjClass = set()
            conjClass.add(mat)
            while len(stack) > 0:
                n = stack.pop()
                mightAdd = []
                for i in range( len(lefts) ):
                    raw = lefts[i]*n*rights[i]
                    current = blackout(raw, toBlackout)
                    if current not in mightAdd:
                        mightAdd.append(current)

                for current in mightAdd:
                    current.set_immutable()
                    if current not in conjClass:
                        found.add(current)
                        conjClass.add(current)
                        stack.append(current)

            classes.append(conjClass)
            if v:
                print("This conjugacy class has size: " + str(len(conjClass)))
    return classes

#This is a function that blacks out all entries on the diagonal and above. 
#This cooresponds to the case where we have a staricase in the bottom left corner
def blackoutForBottomLeft(mat: sage.matrix, n: int):
    toBlackout = []
    for i in range(n):
        for j in range(n):
            if j >= i:
                toBlackout.append([i,j])
    return blackout(mat, toBlackout)

#This function starts with a zero matrix and fills in the entries provided with the elements in the to fill list
# for example the inputs ([1,0,1],[[0,1],[0,2],[1,2]],3,f) would make the matrix
#|0 1 0|
#|0 0 1|
#|0 0 0|
def fillMatFromList(toFill: list, entries: list, n: int, f: sage.rings.finite_rings.finite_field_prime_modn):
    if len(toFill) != len(entries):
        raise NameError('Inputs must have the same length')

    mat = MatrixSpace(f,n,n).identity_matrix() - MatrixSpace(f,n,n).identity_matrix()
    for i in range(len(entries)):
        e = toFill[i]
        mat[e[0],e[1]] = entries[i]

    return mat

#This takes a list of entries and generates all matrices whose only non-zero entries are
#in the list of entries provided. For example, giving the function the list [[0,1],[0,2],[1,2]]
#would make the set of matrices
#|0 * *|
#|0 0 *|
#|0 0 0|
def getMatsOfShape(shape: list, n: int, f: sage.rings.finite_rings.finite_field_prime_modn):
    toRet = []
    fillings = getListOfLength(len(shape),f)
    for filling in fillings:
        toRet.append(fillMatFromList(shape, filling, n, f))
    return toRet


#Takes a list of classes and prints each class seperated by ######
#It also prints the size of the class and the total number of classes
#Generaly, this function will be fed the output of the getConjClass function
def printClasses(classes):
    for c in classes:
        print("Size: " + str(len(c)))
        for e in c:
            print(e)
            print("------")
        print("######")
    print("Number of classes: " + str(len(classes)))

