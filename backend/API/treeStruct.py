import json

class treeNode:
    ## children, name, trace, who made it, parents   
    def __init__(self, name):
        self.children = []
        self.name = name
        self.parents = []
        self.maker = ''
        self.trace = []
        self.owner = ''
        self.quantity = 0

    def __repr__(self):
        return '\nName:'+ self.name + '\n' + 'Maker: ' + self.maker + '\tOwner: ' + self.owner + '\n' + 'Quantity: ' + str(self.quantity) + '\n' + str(self.trace) + '\n' + 'children:[ ' + str(self.children) + ' ]' + '\n' + 'parents:[ ' + str(self.parents) + ' ]' 


def generateNode(product, product_id, direction):
    t = treeNode(product[0])
    trace = makeTree.conn.functions.getTrace(product_id).call()
    # print('trace', trace)
    print('product', product)
    arr = []
    t.quantity = json.loads(product[1])['quantity']
    if trace:
        t.maker = trace[0][2]
        t.owner = trace[-1][3]
        for i in trace: 
            arr.append(f'Transfered to {i[3]}')
        t.trace = arr
    else:
        t.maker = product[4]
        t.owner = product[4]
    
    if direction == 'child' or direction == 'all':
        for i in product[3]:
            product_child = makeTree.conn.functions.getProduct(i).call()
            t.children.append(generateNode(product_child, i, 'child'))

    if direction == 'parent' or direction == 'all':
        if product[2][0] != -1:
            for i in product[2]:
                product_parent = makeTree.conn.functions.getProduct(i).call()
                t.parents.append(generateNode(product_parent, i, 'parent'))

    return t


# utility function to generate product trace
def makeTree(product, product_id):
    t = generateNode(product, product_id, 'both')

    return t