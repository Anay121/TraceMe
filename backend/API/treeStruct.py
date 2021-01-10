class treeNode:
    ## children, name, trace, who made it, parents   
    def __init__(self, name):
        self.children = []
        self.name = name
        self.parents = []
        self.maker = ''
        self.trace = []
        self.owner = ''
    
    def __repr__(self):
        return '\nName:'+ self.name + '\n' + 'Maker: ' + self.maker + '\tOwner: ' + self.owner + '\n' + str(self.trace) + '\n' + 'children:[ ' + str(self.children) + ' ]' + '\n' + 'parents:[ ' + str(self.parents) + ' ]' 

# utility function to generate product trace
def makeTree(product, product_id):
    t = treeNode(product[0])
    trace = makeTree.conn.functions.getTrace(product_id).call()
    arr = []
    
    if trace:
        t.maker = trace[0][2]
        t.owner = trace[-1][3]
        for i in trace: 
            arr.append(f'Transfered to {i[3]}')
        t.trace = arr
    
    ### Since New product isnt inheriting the old trace array, need to make an extra check for that
    # else:
    #     t.maker = 

    print(t)
    # get children and enumerate
    for i in product[3]:
        product_child = makeTree.conn.functions.getProduct(i).call()
        t.children.append(makeTree(product_child, i))
    # get parents and enumerate
    # t.parents = 
    return t