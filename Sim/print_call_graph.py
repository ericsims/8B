def print_call_graph(call_graph, symbols):
    if len(call_graph) < 2:
        return
    # print(symbols)
    edge_counts = {}
    nodes = {}
    for jmp in range(len(call_graph)-1):
        key=f"x{call_graph[jmp]:04X} -> x{call_graph[jmp+1]:04X}"
        if key in edge_counts:
            edge_counts[key] += 1
        else:
            edge_counts[key] = 1

    # TODO: my symbol list is broken since it has labels and constants
    # for node in call_graph:
        # print(f"0x{node:04X}")
        # if node not in nodes:
        #     print(f"0x{node:04X}")
        #     nodes[node] = {
        #         'name': symbols[node],
        #         # 'key': f"x{call_graph[jmp]:04X}"
        #     }

    print("digraph call_graph {")
    for jmp, count in edge_counts.items():
        if count > 1:
            print(f"\t{jmp} [label=\"{count}\"];")
        else:
            print(f"\t{jmp};")
    print("}")