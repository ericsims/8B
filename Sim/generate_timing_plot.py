import pydot



TIMESTEP = 10 #ns
DURATION = 500 + TIMESTEP #ns

signals = {}

graphs = pydot.graph_from_dot_file("timing_deps.dot")
graph = graphs[0]

def genstring(start, end, output=False):
    """generate WaveJSON string"""
    if output:
        return F"u{'.'*round(start/TIMESTEP)}{'x'*(round(end/TIMESTEP)-round(start/TIMESTEP))}5{'.'*round((DURATION-end)/TIMESTEP-2)}"
    return F"u{'.'*round(start/TIMESTEP)}{'x'*(round(end/TIMESTEP)-round(start/TIMESTEP))}2{'.'*round((DURATION-end)/TIMESTEP-2)}"

def get_min_max(label):
    """convern a edge label into a tuple that contains min, max pd"""
    if label is None:
        return 0, 0
    label = label.replace("\"", "")
    label = label.replace(" ", "")
    label = label.replace("ns", "")
    if label == "":
        return 0, 0
    x = label.split('-')
    if len(x) > 1:
        return int(x[0]),int(x[1])
    return int(x[0]),int(x[0])

def get_children(graph_, node_):
    """Returns all the leafs from the current node"""
    children = []
    for e in graph_.get_edges():
        if e.get_source().lower() == node_.lower():
            children.append((e.get_destination(),get_min_max(e.get_label())))
    return children

def traverse_tree(graph_,node_,current_delay=0):
    """traverse all branches starting from node_"""
    children = get_children(graph_,node_)
    print(node_, current_delay, children)
    if len(children) > 0:
        if node_ in signals:
            signals[node_]['time_start'] = min(signals[node_]['time_start'] , current_delay)
            signals[node_]['time_end'] = max(signals[node_]['time_end'], current_delay+children[0][1][1])
        else:
            signals[node_] = {}
            signals[node_]['time_start'] = current_delay
            signals[node_]['time_end'] = current_delay
            signals[node_]['num_gc'] = 0
        for c in children:
            signals[node_]['time_end'] = max(signals[node_]['time_end'], current_delay+c[1][1])
            signals[node_]['num_gc'] += len(get_children(graph_, c[0]))
            traverse_tree(graph_, c[0],current_delay+c[1][1])



traverse_tree(graph,'clk_falling')
graph.write_png("output.png")

for sig in signals:
    signals[sig]['str'] = genstring(signals[sig]['time_start'], signals[sig]['time_end'], signals[sig]['num_gc'] ==0 )


print("{signal: [")
for sig in signals:
    print(F"  {{name: '{sig}', wave: '{signals[sig]['str']}'}},")
print("],")
print("""foot:{
  tick:-1
}""")
print("}")
