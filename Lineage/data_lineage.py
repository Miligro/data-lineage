import networkx as nx
import plotly.graph_objects as go

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
        node_colors = ['green' if 'style' in d and d['style'] == 'filled' else 'skyblue' for _, d in self.graph.nodes(data=True)]

        edge_x = []
        edge_y = []
        for edge in self.graph.edges():
            x0, y0 = pos[edge[0]]
            x1, y1 = pos[edge[1]]
            edge_x.extend([x0, x1, None])
            edge_y.extend([y0, y1, None])

        edge_trace = go.Scatter(
            x=edge_x, y=edge_y,
            line=dict(width=1, color='#888'),
            hoverinfo='none',
            mode='lines')

        node_x = []
        node_y = []
        node_text = []
        for node in self.graph.nodes():
            x, y = pos[node]
            node_x.append(x)
            node_y.append(y)
            node_text.append(f"{node}\n{self.graph.nodes[node].get('type', '')}")

        node_trace = go.Scatter(
            x=node_x, y=node_y,
            mode='markers+text',
            hoverinfo='text',
            marker=dict(
                showscale=False,
                colorscale='YlGnBu',
                reversescale=True,
                color=node_colors,
                size=33,
                colorbar=dict(
                    thickness=15,
                    title='Node Connections',
                    xanchor='left',
                    titleside='right'
                ),
                line_width=2),
            text=node_text,
            textposition="top center")

        fig = go.Figure(data=[edge_trace, node_trace],
                        layout=go.Layout(
                            title='Data Lineage Graph',
                            titlefont_size=16,
                            showlegend=False,
                            hovermode='closest',
                            margin=dict(b=20, l=5, r=5, t=40),
                            annotations=[dict(
                                text="",
                                showarrow=False,
                                xref="paper", yref="paper",
                                x=0.005, y=-0.002)],
                            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False)))

        for edge in self.graph.edges(data=True):
            x0, y0 = pos[edge[0]]
            x1, y1 = pos[edge[1]]
            fig.add_annotation(
                x=x1, y=y1,
                ax=x0, ay=y0,
                axref='x', ayref='y',
                xref='x', yref='y',
                showarrow=True,
                arrowhead=2,
                arrowsize=1,
                arrowwidth=1,
                arrowcolor="#888"
            )

        fig.show()
    
    def print_lineage_paths(self, source, target):
        print("Data Lineage (Dependency Graph):")
        try:
            for path in nx.all_simple_paths(self.graph, source=source, target=target):
                print(" -> ".join(path))
        except nx.NetworkXNoPath:
            print("No path exists between the specified nodes.")
        except nx.NodeNotFound as e:
            print(f"Error: Node {e} not found in the graph.")
