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