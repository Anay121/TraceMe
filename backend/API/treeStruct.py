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
        return '\nName:'+ self.name + '\n' + 'Maker: ' + self.maker + '\tOwner: ' + self.owner + '\n' + 'Quantity: ' + str(self.quantity) + '\nTrace: ' + str(self.trace) + '\n' + 'children:[ ' + str(self.children) + ' ]' + '\n' + 'parents:[ ' + str(self.parents) + ' ]' 


def generateNode(product, product_id, direction,conn):
    t = treeNode(product[0])
    # trace = makeTree.conn.functions.getTrace(product_id).call()
    trace = conn.functions.getTrace(product_id).call()
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
            product_child = conn.functions.getProduct(i).call()
            t.children.append(generateNode(product_child, i, 'child',conn))

    if direction == 'parent' or direction == 'all':
        if product[2][0] != -1:
            for i in product[2]:
                product_parent = conn.functions.getProduct(i).call()
                t.parents.append(generateNode(product_parent, i, 'parent',conn))

    return t


# utility function to generate product trace
def makeTree(product, product_id,conn):
    t = generateNode(product, product_id, 'parent',conn)

    return t