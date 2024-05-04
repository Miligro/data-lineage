import re
import networkx as nx
import plotly.graph_objects as go

class DataLineageGraph:
    def __init__(self, columns, constraints, views, procedures, temp_operations, oracle=False):
        self.graph = nx.DiGraph()
        self.columns = columns
        self.constraints = constraints
        self.views = views
        self.procedures = procedures
        self.temp_operations = temp_operations
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
            cleaned_query = self.clean_query(procedure[3])
            results = self.parse_procedure(procedure[1], cleaned_query)
            for result in results:
                self.graph.add_edge(result[0], result[1], style='dashed')
                if len(result) == 3:
                    self.graph.add_edge(result[1], result[2], style='dashed')
    
    def add_system_operations_to_graph(self):
        operations = self.temp_operations
        for operation in operations:
            _, object_name, object_parent_name = operation
            self.graph.add_edge(object_parent_name, object_name, style='dashed')

    def build_lineage_graph(self):
        self.add_foreign_key_edges()
        self.add_view_dependencies_edges()
        self.add_procedures_edges()
        self.add_system_operations_to_graph()

    def parse_procedure(self, procedure_name, query):
        matches = re.finditer(r'\b(SELECT|INSERT|UPDATE|DELETE)\b', query, re.IGNORECASE)
        operations = []

        for match in matches:
            operation = match.group(1)
            start_index = match.end()
            end_index = query.find(';', start_index)

            operation_text = query[start_index:end_index]

            tables_from = set(re.findall(r'\bFROM\s+(\w+)', operation_text, re.IGNORECASE))
            tables_into = set(re.findall(r'\bINTO\s+(\w+)\b', operation_text, re.IGNORECASE))

            for table_from in tables_from:
                for table_into in tables_into:
                    operations.append((table_from, procedure_name, table_into))

        return operations

    def clean_query(self, query):
        cleaned_query = re.sub(r'[\n\t\r]+', ' ', query)
        cleaned_query = re.sub(r'\s{2,}', ' ', cleaned_query)

        cleaned_query = cleaned_query.strip()

        return cleaned_query

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
