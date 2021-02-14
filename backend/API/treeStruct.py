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


def generateNode(product, product_id, direction, conn, trace_dict):
    t = treeNode(product[0])
    trace_dict[str(product_id)]={"name":product[0]} #add to dict
    # print("TYPE",type(product[2]))
    trace_dict[str(product_id)]["parents"] = [str(x) for x in product[2]]
    # trace_dict[str(product_id)]["children"] = [str(x) for x in product[3]]

    # trace = makeTree.conn.functions.getTrace(product_id).call()
    trace = conn.functions.getTrace(product_id).call()
    # print('trace', trace)
    print('product', product)
    arr = []
    t.quantity = json.loads(product[1])['quantity']
    # trace_dict[str(product_id)]["quantity"] = t.quantity

    if trace:
        t.maker = trace[0][2]
        maker_details = conn.functions.getParticipant(trace[0][2]).call()
        trace_dict[str(product_id)]["maker"] = [trace[0][2], maker_details[2],maker_details[3]]#add to dict
        t.owner = trace[-1][3]
        owner_details = conn.functions.getParticipant(trace[-1][3]).call()
        trace_dict[str(product_id)]["owner"] = [trace[-1][3],owner_details[2],owner_details[3]]#add to dict
        for i in trace: 
            sender_details = conn.functions.getParticipant(i[2]).call()
            # print('Sender Details', sender_details[2],sender_details[3])
            receiver_details = conn.functions.getParticipant(i[3]).call()
            # print('receiver Details', receiver_details[2],receiver_details[3])
            arr.append([[i[2],sender_details[2],sender_details[3]], [i[3],receiver_details[2],receiver_details[3]]])
        t.trace = arr
        trace_dict[str(product_id)]["trace"] = arr #add to dict
    else:
        t.maker = product[4]
        trace_dict[str(product_id)]["maker"] = product[4] #add to dict
        t.owner = product[4]
        trace_dict[str(product_id)]["owner"] = product[4] #add to dict
        trace_dict[str(product_id)]["trace"] = arr
    
    if direction == 'child' or direction == 'all':
        for i in product[3]:
            product_child = conn.functions.getProduct(i).call()
            t.children.append(generateNode(product_child, i, 'child',conn,trace_dict))

    if direction == 'parent' or direction == 'all':
        if product[2][0] != -1:
            for i in product[2]:
                product_parent = conn.functions.getProduct(i).call()
                t.parents.append(generateNode(product_parent, i, 'parent',conn,trace_dict))

    return t


# utility function to generate product trace
def makeTree(product, product_id,conn):
    trace_dict = {}
    t = generateNode(product, product_id, 'parent', conn, trace_dict)
    print("t_d",trace_dict)

    return trace_dict