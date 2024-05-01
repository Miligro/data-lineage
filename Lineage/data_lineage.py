import networkx as nx
import matplotlib.pyplot as plt


class DataLineageGraph:
    def __init__(self, columns, constraints, views, procedures, oracle=False):
        self.graph = nx.DiGraph()
        self.columns = columns
        self.constraints = constraints
        self.views = views
        self.procedures = procedures
        self.oracleDB = oracle
        self.build_lineage_graph()

    def add_foreign_key_edges(self):
        for constraint in self.constraints:
            if self.oracleDB:
                if constraint[4] == 'R':
                    source = constraint[2]
                    target = constraint[3].split('_')[0]
                    self.graph.add_edge(source, target, label=constraint[0])
            else:
                if constraint[4] == 'FOREIGN KEY':
                    source = constraint[2]
                    target = constraint[3].split('_')[0]
                    self.graph.add_edge(source, target, label=constraint[0])

    def add_view_dependencies_edges(self):
        for view in self.views:
            if self.oracleDB:
                source_view = view[0]
            else:
                source_view = view[1]
            target_table = view[3]
            self.graph.add_edge(target_table, source_view, style='dashed')

    def add_procedures_edges(self):
        for procedure in self.procedures:
            if self.oracleDB:
                procedure_name = procedure[0]
            else:
                procedure_name = procedure[1]
            self.graph.add_node(procedure_name, style='filled', fillcolor='green')

    def build_lineage_graph(self):
        self.add_foreign_key_edges()
        self.add_view_dependencies_edges()
        self.add_procedures_edges()

    def draw_graph(self):
        pos = nx.spring_layout(self.graph)
        nx.draw(self.graph, pos, with_labels=True, node_color='skyblue', node_size=800, edge_color='k', linewidths=1,
                font_size=15)
        nx.draw_networkx_edge_labels(self.graph, pos, edge_labels=nx.get_edge_attributes(self.graph, 'label'))
        plt.show()

    def print_lineage_paths(self, source, target):
        print("Data Lineage (Dependency Graph):")
        try:
            for path in nx.all_simple_paths(self.graph, source=source, target=target):
                print(" -> ".join(path))
        except nx.NetworkXNoPath:
            print("No path exists between the specified nodes.")
        except nx.NodeNotFound as e:
            print(f"Error: Node {e} not found in the graph.")
